import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/user.dart';
import '../../../services/notification_service.dart';
import '../../../services/service_providers.dart';

part 'auth_provider.g.dart';

/// Provides the current auth state
@riverpod
Stream<AuthState> authState(AuthStateRef ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return supabase.authStateChanges;
}

/// Provides the current Supabase User
@riverpod
User? currentAuthUser(CurrentAuthUserRef ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull?.session?.user;
}

/// Provides the current user profile from the database
@riverpod
Future<AppUser?> currentUserProfile(CurrentUserProfileRef ref) async {
  final authUser = ref.watch(currentAuthUserProvider);
  if (authUser == null) return null;
  final supabase = ref.read(supabaseServiceProvider);
  return await supabase.getUserProfile();
}

/// Auth notifier for handling auth actions
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  /// Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = const AsyncLoading();
    try {
      final supabase = ref.read(supabaseServiceProvider);
      await supabase.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final supabase = ref.read(supabaseServiceProvider);
      await supabase.signIn(
        email: email,
        password: password,
      );
      // Register FCM token after successful sign in
      await NotificationService.registerToken();
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      // Clear FCM token before signing out
      await NotificationService.clearToken();
      final supabase = ref.read(supabaseServiceProvider);
      await supabase.signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Send password reset email
  Future<bool> resetPassword(String email) async {
    state = const AsyncLoading();
    try {
      final supabase = ref.read(supabaseServiceProvider);
      await supabase.resetPassword(email);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  /// Clear any error state
  void clearError() {
    state = const AsyncData(null);
  }
}
