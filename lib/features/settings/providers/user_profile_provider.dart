import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../services/notification_service.dart';
import '../../../services/service_providers.dart';
import '../../auth/providers/auth_provider.dart';

part 'user_profile_provider.freezed.dart';
part 'user_profile_provider.g.dart';

/// State for user profile operations
@freezed
class UserProfileState with _$UserProfileState {
  const factory UserProfileState({
    @Default(false) bool isSaving,
    String? error,
  }) = _UserProfileState;
}

/// Notifier for user profile mutations
@riverpod
class UserProfileNotifier extends _$UserProfileNotifier {
  @override
  UserProfileState build() {
    return const UserProfileState();
  }

  /// Update display name and phone
  Future<bool> updateProfile({
    required String displayName,
    String? phone,
  }) async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      final supabase = ref.read(supabaseServiceProvider);
      await supabase.updateUserProfile(
        displayName: displayName,
        phone: phone,
      );

      // Invalidate the currentUserProfileProvider to refresh data
      ref.invalidate(currentUserProfileProvider);

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  /// Update check-in interval (1-7 days converted to hours)
  Future<bool> updateCheckInInterval(int days) async {
    final hours = days * 24;
    state = state.copyWith(isSaving: true, error: null);

    try {
      final supabase = ref.read(supabaseServiceProvider);
      await supabase.updateUserProfile(
        checkInIntervalHours: hours,
      );

      ref.invalidate(currentUserProfileProvider);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  /// Toggle notifications by setting/clearing FCM token
  Future<bool> setNotificationsEnabled(bool enabled) async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      if (enabled) {
        // Re-register FCM token
        await NotificationService.registerToken();
      } else {
        // Clear FCM token to disable notifications
        final supabase = ref.read(supabaseServiceProvider);
        await supabase.updateFCMToken(null);
      }

      ref.invalidate(currentUserProfileProvider);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  /// Clear any error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Helper provider to get check-in interval in days
@riverpod
int checkInIntervalDays(CheckInIntervalDaysRef ref) {
  final profile = ref.watch(currentUserProfileProvider);
  final hours = profile.valueOrNull?.checkInIntervalHours ?? 48;
  return (hours / 24).round().clamp(1, 7);
}

/// Helper provider to check if notifications are enabled
@riverpod
bool notificationsEnabled(NotificationsEnabledRef ref) {
  final profile = ref.watch(currentUserProfileProvider);
  return profile.valueOrNull?.fcmToken != null;
}
