import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../services/supabase_service.dart';
import '../../auth/providers/auth_provider.dart';

part 'check_in_provider.freezed.dart';
part 'check_in_provider.g.dart';

/// Check-in state containing timing information
@freezed
class CheckInState with _$CheckInState {
  const factory CheckInState({
    required DateTime? lastCheckIn,
    required DateTime? nextDue,
    required int intervalHours,
    @Default(false) bool isShowingSuccess,
    @Default(false) bool isLoading,
    String? error,
  }) = _CheckInState;
}

/// Check-in notifier for managing check-in state and actions
@riverpod
class CheckInNotifier extends _$CheckInNotifier {
  @override
  CheckInState build() {
    // Watch the user profile to get real data
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return userProfileAsync.when(
      data: (user) {
        if (user == null) {
          // Not logged in - return empty state
          return const CheckInState(
            lastCheckIn: null,
            nextDue: null,
            intervalHours: 48,
          );
        }
        // Use real user data from Supabase
        return CheckInState(
          lastCheckIn: user.lastCheckInAt,
          nextDue: user.nextCheckInDue,
          intervalHours: user.checkInIntervalHours,
        );
      },
      loading: () => const CheckInState(
        lastCheckIn: null,
        nextDue: null,
        intervalHours: 48,
        isLoading: true,
      ),
      error: (e, _) => CheckInState(
        lastCheckIn: null,
        nextDue: null,
        intervalHours: 48,
        error: e.toString(),
      ),
    );
  }

  /// Perform a check-in
  Future<void> checkIn() async {
    // Show loading/success immediately for responsiveness
    state = state.copyWith(isShowingSuccess: true, error: null);

    try {
      // Call Supabase to persist the check-in
      final updatedUser = await SupabaseService.performCheckIn();

      // Update state with data from server
      state = state.copyWith(
        lastCheckIn: updatedUser.lastCheckInAt,
        nextDue: updatedUser.nextCheckInDue,
        intervalHours: updatedUser.checkInIntervalHours,
        isShowingSuccess: true,
      );

      // Invalidate the user profile provider so it refetches
      ref.invalidate(currentUserProfileProvider);

      // Hide success state after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      state = state.copyWith(isShowingSuccess: false);
    } catch (e) {
      state = state.copyWith(
        isShowingSuccess: false,
        error: e.toString(),
      );
    }
  }

  /// Update the check-in interval (in hours)
  Future<void> setInterval(int hours) async {
    try {
      await SupabaseService.updateUserProfile(checkInIntervalHours: hours);

      // Recalculate next due based on new interval
      final lastCheckIn = state.lastCheckIn;
      final newNextDue = lastCheckIn != null
          ? lastCheckIn.add(Duration(hours: hours))
          : DateTime.now().add(Duration(hours: hours));

      state = state.copyWith(
        intervalHours: hours,
        nextDue: newNextDue,
      );

      // Invalidate the user profile provider so it refetches
      ref.invalidate(currentUserProfileProvider);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Clear any error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for the time remaining until next check-in
@riverpod
Duration? timeRemaining(TimeRemainingRef ref) {
  final checkInState = ref.watch(checkInNotifierProvider);
  final nextDue = checkInState.nextDue;

  if (nextDue == null) return null;

  final now = DateTime.now();
  final remaining = nextDue.difference(now);

  return remaining;
}

/// Provider to check if user is overdue
@riverpod
bool isOverdue(IsOverdueRef ref) {
  final remaining = ref.watch(timeRemainingProvider);
  if (remaining == null) return false;
  return remaining.isNegative;
}
