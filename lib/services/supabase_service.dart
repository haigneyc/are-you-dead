import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/supabase_constants.dart';
import '../models/emergency_contact.dart';
import '../models/user.dart';

/// Service for interacting with Supabase
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  /// Initialize Supabase
  static Future<void> initialize() async {
    if (!SupabaseConstants.isConfigured) {
      throw Exception(
        'Supabase is not configured. '
        'Please provide SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY via --dart-define',
      );
    }

    await Supabase.initialize(
      url: SupabaseConstants.url,
      // SDK uses 'anonKey' param name, but this is the publishable key
      anonKey: SupabaseConstants.publishableKey,
    );
  }

  // --- Authentication ---

  /// Current authenticated user
  static User? get currentUser => client.auth.currentUser;

  /// Stream of auth state changes
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: displayName != null ? {'display_name': displayName} : null,
    );

    // Create user profile in the users table
    if (response.user != null) {
      await _createUserProfile(
        userId: response.user!.id,
        email: email,
        displayName: displayName,
      );
    }

    return response;
  }

  /// Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out
  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Send password reset email
  static Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  // --- User Profile ---

  /// Create user profile in the users table
  static Future<void> _createUserProfile({
    required String userId,
    required String email,
    String? displayName,
  }) async {
    await client.from('users').insert({
      'id': userId,
      'email': email,
      'display_name': displayName,
    });
  }

  /// Get current user profile, creating it if it doesn't exist
  static Future<AppUser?> getUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    // Try to get existing profile
    final response = await client
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response != null) {
      return AppUser.fromJson(response);
    }

    // Profile doesn't exist - create it
    // This handles the case where email confirmation bypassed profile creation
    await _createUserProfile(
      userId: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['display_name'] as String?,
    );

    // Fetch the newly created profile
    final newResponse = await client
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

    return AppUser.fromJson(newResponse);
  }

  /// Update user profile
  static Future<void> updateUserProfile({
    String? displayName,
    String? phone,
    int? checkInIntervalHours,
    String? timezone,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');

    final updates = <String, dynamic>{};
    if (displayName != null) updates['display_name'] = displayName;
    if (phone != null) updates['phone'] = phone;
    if (checkInIntervalHours != null) updates['check_in_interval_hours'] = checkInIntervalHours;
    if (timezone != null) updates['timezone'] = timezone;

    if (updates.isNotEmpty) {
      await client.from('users').update(updates).eq('id', user.id);
    }
  }

  /// Delete user account
  static Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');

    // Delete user data (cascade will handle related tables)
    await client.from('users').delete().eq('id', user.id);

    // Sign out
    await signOut();
  }

  // --- FCM Token ---

  /// Update FCM token for push notifications
  static Future<void> updateFCMToken(String? token) async {
    final user = currentUser;
    if (user == null) return;

    await client
        .from('users')
        .update({'fcm_token': token})
        .eq('id', user.id);
  }

  // --- Check-In ---

  /// Perform a check-in using the database function
  /// Returns the updated user profile
  static Future<AppUser> performCheckIn() async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');

    // Call the database function
    await client.rpc('perform_check_in', params: {'p_user_id': user.id});

    // Return updated user profile
    final profile = await getUserProfile();
    if (profile == null) throw Exception('Failed to get user profile');
    return profile;
  }

  // --- Emergency Contacts ---

  /// Maximum number of contacts allowed per user
  static const int maxContacts = 5;

  /// Get all emergency contacts for the current user
  static Future<List<EmergencyContact>> getContacts() async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');

    final response = await client
        .from('emergency_contacts')
        .select()
        .eq('user_id', user.id)
        .order('priority');

    return (response as List)
        .map((json) => EmergencyContact.fromJson(json))
        .toList();
  }

  /// Add a new emergency contact
  static Future<EmergencyContact> addContact({
    required String name,
    required String phone,
    String? email,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');

    // Check contact limit
    final existingContacts = await getContacts();
    if (existingContacts.length >= maxContacts) {
      throw Exception('Maximum of $maxContacts contacts allowed');
    }

    // Calculate next priority
    final nextPriority = existingContacts.isEmpty
        ? 1
        : existingContacts.map((c) => c.priority).reduce((a, b) => a > b ? a : b) + 1;

    final response = await client.from('emergency_contacts').insert({
      'user_id': user.id,
      'name': name,
      'phone': phone,
      'email': email,
      'priority': nextPriority,
    }).select().single();

    return EmergencyContact.fromJson(response);
  }

  /// Update an existing emergency contact
  static Future<void> updateContact({
    required String contactId,
    String? name,
    String? phone,
    String? email,
    int? priority,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (email != null) updates['email'] = email;
    if (priority != null) updates['priority'] = priority;

    if (updates.isNotEmpty) {
      await client
          .from('emergency_contacts')
          .update(updates)
          .eq('id', contactId)
          .eq('user_id', user.id);
    }
  }

  /// Delete an emergency contact
  static Future<void> deleteContact(String contactId) async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');

    await client
        .from('emergency_contacts')
        .delete()
        .eq('id', contactId)
        .eq('user_id', user.id);
  }
}
