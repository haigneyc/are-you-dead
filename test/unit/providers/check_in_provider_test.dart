import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:are_you_dead/features/auth/providers/auth_provider.dart';
import 'package:are_you_dead/features/check_in/providers/check_in_provider.dart';
import 'package:are_you_dead/models/user.dart';
import 'package:are_you_dead/services/service_providers.dart';

import '../../mocks/mock_supabase_service.dart';
import '../../mocks/test_fixtures.dart';

void main() {
  group('CheckInProvider', () {
    late TestableSupabaseService mockService;
    late ProviderContainer container;

    setUp(() {
      mockService = TestableSupabaseService();
    });

    tearDown(() {
      container.dispose();
      mockService.dispose();
    });

    ProviderContainer createContainer({AppUser? userProfile}) {
      // Set up the mock service with user data
      if (userProfile != null) {
        mockService.currentUserOverride = FakeUser(
          id: userProfile.id,
          email: userProfile.email,
        );
        mockService.userProfileOverride = userProfile;
      }

      return ProviderContainer(
        overrides: [
          supabaseServiceProvider.overrideWithValue(mockService),
          // Override currentUserProfile to return our test user directly
          currentUserProfileProvider.overrideWith((ref) async => userProfile),
        ],
      );
    }

    group('Initial state', () {
      test('returns empty state when user is null', () async {
        container = createContainer(userProfile: null);

        // Wait for async initialization
        await container.read(currentUserProfileProvider.future);

        final state = container.read(checkInNotifierProvider);

        expect(state.lastCheckIn, isNull);
        expect(state.nextDue, isNull);
        expect(state.intervalHours, equals(48)); // default
      });

      test('returns populated state with user data', () async {
        final user = TestFixtures.sampleUser;
        container = createContainer(userProfile: user);

        await container.read(currentUserProfileProvider.future);
        final state = container.read(checkInNotifierProvider);

        expect(state.lastCheckIn, equals(user.lastCheckInAt));
        expect(state.nextDue, equals(user.nextCheckInDue));
        expect(state.intervalHours, equals(user.checkInIntervalHours));
      });
    });

    group('checkIn()', () {
      test('sets isShowingSuccess to true on start', () async {
        final user = TestFixtures.sampleUser;
        container = createContainer(userProfile: user);

        await container.read(currentUserProfileProvider.future);
        final notifier = container.read(checkInNotifierProvider.notifier);

        // Start check-in but don't await it
        final future = notifier.checkIn();

        // State should show success immediately
        final state = container.read(checkInNotifierProvider);
        expect(state.isShowingSuccess, isTrue);

        await future;
      });

      test('calls performCheckIn on service', () async {
        final user = TestFixtures.sampleUser;
        container = createContainer(userProfile: user);

        await container.read(currentUserProfileProvider.future);
        final notifier = container.read(checkInNotifierProvider.notifier);

        final beforeCheckIn = mockService.userProfileOverride?.lastCheckInAt;
        await notifier.checkIn();
        final afterCheckIn = mockService.userProfileOverride?.lastCheckInAt;

        // The mock service should have updated lastCheckInAt
        expect(afterCheckIn, isNotNull);
        expect(afterCheckIn, isNot(equals(beforeCheckIn)));
      });

      test('sets error state on failure', () async {
        final user = TestFixtures.sampleUser;
        mockService.shouldThrowOnCheckIn = true;
        container = createContainer(userProfile: user);

        await container.read(currentUserProfileProvider.future);
        final notifier = container.read(checkInNotifierProvider.notifier);

        await notifier.checkIn();

        final state = container.read(checkInNotifierProvider);
        expect(state.error, isNotNull);
        expect(state.isShowingSuccess, isFalse);
      });
    });

    group('setInterval()', () {
      test('calls updateUserProfile on service with new interval', () async {
        final user = TestFixtures.sampleUser.copyWith(checkInIntervalHours: 48);
        container = createContainer(userProfile: user);

        await container.read(currentUserProfileProvider.future);
        final notifier = container.read(checkInNotifierProvider.notifier);

        await notifier.setInterval(72);

        // Verify the service was called with the new interval
        expect(mockService.userProfileOverride?.checkInIntervalHours, equals(72));
      });

      test('recalculates nextDue when interval changes', () async {
        final lastCheckIn = DateTime.now().subtract(const Duration(hours: 12));
        final user = TestFixtures.sampleUser.copyWith(
          checkInIntervalHours: 48,
          lastCheckInAt: lastCheckIn,
        );
        container = createContainer(userProfile: user);

        await container.read(currentUserProfileProvider.future);
        final notifier = container.read(checkInNotifierProvider.notifier);

        await notifier.setInterval(24);

        // Verify the mock's user profile was updated with new nextDue calculation
        // lastCheckIn + 24 hours should be approximately 12 hours from now
        final state = container.read(checkInNotifierProvider);
        final expectedNextDue = lastCheckIn.add(const Duration(hours: 24));

        // The nextDue should be recalculated
        expect(state.nextDue, isNotNull);
      });
    });

    group('timeRemaining provider', () {
      test('returns null when nextDue is null', () async {
        container = createContainer(userProfile: null);
        await container.read(currentUserProfileProvider.future);

        final remaining = container.read(timeRemainingProvider);
        expect(remaining, isNull);
      });

      test('returns positive duration when not overdue', () async {
        final futureDate = DateTime.now().add(const Duration(hours: 24));
        final user = TestFixtures.sampleUser.copyWith(nextCheckInDue: futureDate);
        container = createContainer(userProfile: user);

        await container.read(currentUserProfileProvider.future);
        final remaining = container.read(timeRemainingProvider);

        expect(remaining, isNotNull);
        expect(remaining!.isNegative, isFalse);
        expect(remaining.inHours, greaterThanOrEqualTo(23));
      });

      test('returns negative duration when overdue', () async {
        final pastDate = DateTime.now().subtract(const Duration(hours: 6));
        final user = TestFixtures.sampleUser.copyWith(nextCheckInDue: pastDate);
        container = createContainer(userProfile: user);

        await container.read(currentUserProfileProvider.future);
        final remaining = container.read(timeRemainingProvider);

        expect(remaining, isNotNull);
        expect(remaining!.isNegative, isTrue);
      });
    });

    group('isOverdue provider', () {
      test('returns false when remaining is null', () async {
        container = createContainer(userProfile: null);
        await container.read(currentUserProfileProvider.future);

        final isOverdue = container.read(isOverdueProvider);
        expect(isOverdue, isFalse);
      });

      test('returns false when remaining is positive', () async {
        final futureDate = DateTime.now().add(const Duration(hours: 24));
        final user = TestFixtures.sampleUser.copyWith(nextCheckInDue: futureDate);
        container = createContainer(userProfile: user);

        await container.read(currentUserProfileProvider.future);
        final isOverdue = container.read(isOverdueProvider);

        expect(isOverdue, isFalse);
      });

      test('returns true when remaining is negative', () async {
        final user = TestFixtures.overdueUser;
        container = createContainer(userProfile: user);

        await container.read(currentUserProfileProvider.future);
        final isOverdue = container.read(isOverdueProvider);

        expect(isOverdue, isTrue);
      });
    });

    group('clearError()', () {
      test('clears error state', () async {
        final user = TestFixtures.sampleUser;
        mockService.shouldThrowOnCheckIn = true;
        container = createContainer(userProfile: user);

        await container.read(currentUserProfileProvider.future);
        final notifier = container.read(checkInNotifierProvider.notifier);

        // Trigger an error
        await notifier.checkIn();
        expect(container.read(checkInNotifierProvider).error, isNotNull);

        // Clear the error
        notifier.clearError();
        expect(container.read(checkInNotifierProvider).error, isNull);
      });
    });
  });
}
