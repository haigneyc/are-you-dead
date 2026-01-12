import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/supabase_constants.dart';
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
        'Please provide SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define',
      );
    }

    await Supabase.initialize(
      url: SupabaseConstants.url,
      anonKey: SupabaseConstants.anonKey,
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

  /// Get current user profile
  static Future<AppUser?> getUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final response = await client
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

    return AppUser.fromJson(response);
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
}
