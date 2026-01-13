import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:are_you_dead/models/emergency_contact.dart';
import 'package:are_you_dead/models/user.dart';
import 'package:are_you_dead/services/supabase_service_interface.dart';

/// Mock implementation of [ISupabaseService] for testing.
class MockSupabaseService extends Mock implements ISupabaseService {}

/// Fake [AuthState] for testing auth state streams.
class FakeAuthState extends Fake implements AuthState {
  FakeAuthState({this.session});

  @override
  final Session? session;

  @override
  AuthChangeEvent get event =>
      session != null ? AuthChangeEvent.signedIn : AuthChangeEvent.signedOut;
}

/// Fake [Session] for testing.
class FakeSession extends Fake implements Session {
  FakeSession({required this.user});

  @override
  final User user;

  @override
  String get accessToken => 'fake-access-token';

  @override
  String? get refreshToken => 'fake-refresh-token';

  @override
  int get expiresIn => 3600;

  @override
  String get tokenType => 'bearer';
}

/// Fake [User] for testing (Supabase Auth User).
class FakeUser extends Fake implements User {
  FakeUser({
    this.id = 'test-user-id',
    this.email = 'test@example.com',
  });

  @override
  final String id;

  @override
  final String? email;

  @override
  Map<String, dynamic>? get userMetadata => {'display_name': 'Test User'};
}

/// Fake [AuthResponse] for testing.
class FakeAuthResponse extends Fake implements AuthResponse {
  FakeAuthResponse({this.user, this.session});

  @override
  final User? user;

  @override
  final Session? session;
}

/// A configurable mock Supabase service for common test scenarios.
class TestableSupabaseService implements ISupabaseService {
  TestableSupabaseService({
    this.currentUserOverride,
    this.userProfileOverride,
    this.contactsOverride,
    this.shouldThrowOnCheckIn = false,
    this.shouldThrowOnAuth = false,
  });

  User? currentUserOverride;
  AppUser? userProfileOverride;
  List<EmergencyContact>? contactsOverride;
  bool shouldThrowOnCheckIn;
  bool shouldThrowOnAuth;

  final _authStateController = StreamController<AuthState>.broadcast();

  @override
  User? get currentUser => currentUserOverride;

  @override
  Stream<AuthState> get authStateChanges => _authStateController.stream;

  void emitAuthState(AuthState state) {
    _authStateController.add(state);
  }

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (shouldThrowOnAuth) {
      throw Exception('Sign up failed');
    }
    final user = FakeUser(email: email);
    currentUserOverride = user;
    return FakeAuthResponse(user: user);
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    if (shouldThrowOnAuth) {
      throw Exception('Sign in failed');
    }
    final user = FakeUser(email: email);
    currentUserOverride = user;
    return FakeAuthResponse(
      user: user,
      session: FakeSession(user: user),
    );
  }

  @override
  Future<void> signOut() async {
    currentUserOverride = null;
    userProfileOverride = null;
  }

  @override
  Future<void> resetPassword(String email) async {
    if (shouldThrowOnAuth) {
      throw Exception('Reset password failed');
    }
  }

  @override
  Future<AppUser?> getUserProfile() async {
    if (currentUserOverride == null) return null;
    return userProfileOverride ??
        AppUser(
          id: currentUserOverride!.id,
          email: currentUserOverride!.email ?? '',
          displayName: 'Test User',
          checkInIntervalHours: 48,
          lastCheckInAt: DateTime.now().subtract(const Duration(hours: 24)),
          nextCheckInDue: DateTime.now().add(const Duration(hours: 24)),
        );
  }

  @override
  Future<void> updateUserProfile({
    String? displayName,
    String? phone,
    int? checkInIntervalHours,
    String? timezone,
  }) async {
    if (userProfileOverride != null) {
      userProfileOverride = userProfileOverride!.copyWith(
        displayName: displayName ?? userProfileOverride!.displayName,
        phone: phone ?? userProfileOverride!.phone,
        checkInIntervalHours:
            checkInIntervalHours ?? userProfileOverride!.checkInIntervalHours,
        timezone: timezone ?? userProfileOverride!.timezone,
      );
    }
  }

  @override
  Future<void> deleteAccount() async {
    currentUserOverride = null;
    userProfileOverride = null;
    contactsOverride = null;
  }

  @override
  Future<void> updateFCMToken(String? token) async {
    if (userProfileOverride != null) {
      userProfileOverride = userProfileOverride!.copyWith(fcmToken: token);
    }
  }

  @override
  Future<AppUser> performCheckIn() async {
    if (shouldThrowOnCheckIn) {
      throw Exception('Check-in failed');
    }
    final now = DateTime.now();
    final intervalHours = userProfileOverride?.checkInIntervalHours ?? 48;
    userProfileOverride = (userProfileOverride ??
            AppUser(
              id: currentUserOverride?.id ?? 'test-id',
              email: currentUserOverride?.email ?? 'test@example.com',
            ))
        .copyWith(
      lastCheckInAt: now,
      nextCheckInDue: now.add(Duration(hours: intervalHours)),
    );
    return userProfileOverride!;
  }

  @override
  Future<List<EmergencyContact>> getContacts() async {
    return contactsOverride ?? [];
  }

  @override
  Future<EmergencyContact> addContact({
    required String name,
    required String phone,
    String? email,
  }) async {
    final contact = EmergencyContact(
      id: 'contact-${DateTime.now().millisecondsSinceEpoch}',
      userId: currentUserOverride?.id ?? 'test-user-id',
      name: name,
      phone: phone,
      email: email,
      priority: (contactsOverride?.length ?? 0) + 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    contactsOverride = [...(contactsOverride ?? []), contact];
    return contact;
  }

  @override
  Future<void> updateContact({
    required String contactId,
    String? name,
    String? phone,
    String? email,
    int? priority,
  }) async {
    contactsOverride = contactsOverride?.map((c) {
      if (c.id == contactId) {
        return c.copyWith(
          name: name ?? c.name,
          phone: phone ?? c.phone,
          email: email ?? c.email,
          priority: priority ?? c.priority,
        );
      }
      return c;
    }).toList();
  }

  @override
  Future<void> deleteContact(String contactId) async {
    contactsOverride =
        contactsOverride?.where((c) => c.id != contactId).toList();
  }

  void dispose() {
    _authStateController.close();
  }
}
