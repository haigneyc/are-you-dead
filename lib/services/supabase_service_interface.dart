import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/emergency_contact.dart';
import '../models/user.dart';

/// Abstract interface for Supabase operations.
/// Enables dependency injection for testing.
abstract class ISupabaseService {
  /// Maximum number of contacts allowed per user
  static const int maxContacts = 5;

  // --- Authentication ---

  /// Current authenticated user
  User? get currentUser;

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges;

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });

  /// Sign out
  Future<void> signOut();

  /// Send password reset email
  Future<void> resetPassword(String email);

  // --- User Profile ---

  /// Get current user profile, creating it if it doesn't exist
  Future<AppUser?> getUserProfile();

  /// Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? phone,
    int? checkInIntervalHours,
    String? timezone,
  });

  /// Delete user account
  Future<void> deleteAccount();

  // --- FCM Token ---

  /// Update FCM token for push notifications
  Future<void> updateFCMToken(String? token);

  // --- Check-In ---

  /// Perform a check-in using the database function
  /// Returns the updated user profile
  Future<AppUser> performCheckIn();

  // --- Emergency Contacts ---

  /// Get all emergency contacts for the current user
  Future<List<EmergencyContact>> getContacts();

  /// Add a new emergency contact
  Future<EmergencyContact> addContact({
    required String name,
    required String phone,
    String? email,
  });

  /// Update an existing emergency contact
  Future<void> updateContact({
    required String contactId,
    String? name,
    String? phone,
    String? email,
    int? priority,
  });

  /// Delete an emergency contact
  Future<void> deleteContact(String contactId);
}
