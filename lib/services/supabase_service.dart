import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/supabase_constants.dart';
import '../models/emergency_contact.dart';
import '../models/user.dart';
import 'supabase_service_interface.dart';

/// Production implementation of [ISupabaseService].
/// Wraps the Supabase client for all backend operations.
class SupabaseService implements ISupabaseService {
  SupabaseService();

  SupabaseClient get _client => Supabase.instance.client;

  /// Initialize Supabase (call once at app startup)
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

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await _client.auth.signUp(
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

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // --- User Profile ---

  /// Create user profile in the users table
  Future<void> _createUserProfile({
    required String userId,
    required String email,
    String? displayName,
  }) async {
    await _client.from('users').insert({
      'id': userId,
      'email': email,
      'display_name': displayName,
    });
  }

  @override
  Future<AppUser?> getUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    // Try to get existing profile
    final response = await _client
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
    final newResponse = await _client
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

    return AppUser.fromJson(newResponse);
  }

  @override
  Future<void> updateUserProfile({
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
      await _client.from('users').update(updates).eq('id', user.id);
    }
  }

  @override
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');

    // Delete user data (cascade will handle related tables)
    await _client.from('users').delete().eq('id', user.id);

    // Sign out
    await signOut();
  }

  // --- FCM Token ---

  @override
  Future<void> updateFCMToken(String? token) async {
    final user = currentUser;
    if (user == null) return;

    await _client
        .from('users')
        .update({'fcm_token': token})
        .eq('id', user.id);
  }

  // --- Check-In ---

  @override
  Future<AppUser> performCheckIn() async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');

    // Call the database function
    await _client.rpc('perform_check_in', params: {'p_user_id': user.id});

    // Return updated user profile
    final profile = await getUserProfile();
    if (profile == null) throw Exception('Failed to get user profile');
    return profile;
  }

  // --- Emergency Contacts ---

  @override
  Future<List<EmergencyContact>> getContacts() async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');

    final response = await _client
        .from('emergency_contacts')
        .select()
        .eq('user_id', user.id)
        .order('priority');

    return (response as List)
        .map((json) => EmergencyContact.fromJson(json))
        .toList();
  }

  @override
  Future<EmergencyContact> addContact({
    required String name,
    required String phone,
    String? email,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');

    // Check contact limit
    final existingContacts = await getContacts();
    if (existingContacts.length >= ISupabaseService.maxContacts) {
      throw Exception('Maximum of ${ISupabaseService.maxContacts} contacts allowed');
    }

    // Calculate next priority
    final nextPriority = existingContacts.isEmpty
        ? 1
        : existingContacts.map((c) => c.priority).reduce((a, b) => a > b ? a : b) + 1;

    final response = await _client.from('emergency_contacts').insert({
      'user_id': user.id,
      'name': name,
      'phone': phone,
      'email': email,
      'priority': nextPriority,
    }).select().single();

    return EmergencyContact.fromJson(response);
  }

  @override
  Future<void> updateContact({
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
      await _client
          .from('emergency_contacts')
          .update(updates)
          .eq('id', contactId)
          .eq('user_id', user.id);
    }
  }

  @override
  Future<void> deleteContact(String contactId) async {
    final user = currentUser;
    if (user == null) throw Exception('Not authenticated');

    await _client
        .from('emergency_contacts')
        .delete()
        .eq('id', contactId)
        .eq('user_id', user.id);
  }
}
