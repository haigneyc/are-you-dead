import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:are_you_dead/app.dart';
import 'package:are_you_dead/core/theme/app_theme.dart';
import 'package:are_you_dead/features/check_in/screens/check_in_screen.dart';
import 'package:are_you_dead/features/check_in/widgets/check_in_button.dart';
import 'package:are_you_dead/features/check_in/widgets/countdown_timer.dart';
import 'package:are_you_dead/models/user.dart';
import 'package:are_you_dead/services/service_providers.dart';

import '../mocks/mock_supabase_service.dart';

void main() {
  group('Check-In Flow Integration Tests', () {
    late TestableSupabaseService supabaseService;
    late GoRouter router;

    setUp(() {
      supabaseService = TestableSupabaseService();
    });

    tearDown(() {
      supabaseService.dispose();
    });

    /// Helper to build test app with authenticated user.
    Widget buildTestApp({AppUser? userProfile}) {
      supabaseService.currentUserOverride = FakeUser();
      supabaseService.userProfileOverride = userProfile ??
          AppUser(
            id: 'test-user-id',
            email: 'test@example.com',
            displayName: 'Test User',
            checkInIntervalHours: 48,
            lastCheckInAt: DateTime.now().subtract(const Duration(hours: 12)),
            nextCheckInDue: DateTime.now().add(const Duration(hours: 36)),
          );

      router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const CheckInScreen(),
          ),
        ],
      );

      return ProviderScope(
        overrides: [
          supabaseServiceProvider.overrideWithValue(supabaseService),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: router,
        ),
      );
    }

    group('Check-In Screen Layout', () {
      testWidgets('displays app bar with title', (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        expect(find.text('Check In'), findsOneWidget);
      });

      testWidgets('displays countdown timer widget', (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        expect(find.byType(CountdownTimer), findsOneWidget);
      });

      testWidgets('displays check-in button widget', (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        expect(find.byType(CheckInButton), findsOneWidget);
      });

      testWidgets('displays "I\'M OK" text on button', (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        expect(find.text("I'M OK"), findsOneWidget);
      });
    });

    // NOTE: Button action behavior (success state, animation, revert) is tested
    // in widget tests (test/widget/check_in/check_in_button_test.dart).
    // Integration tests for check-in action would require waiting for the
    // 2-second success animation timer, which complicates testing.

    group('No Check-In Scheduled', () {
      testWidgets('shows "No check-in scheduled" when nextDue is null',
          (tester) async {
        final user = AppUser(
          id: 'test-user-id',
          email: 'test@example.com',
          displayName: 'Test User',
          checkInIntervalHours: 24,
          lastCheckInAt: null,
          nextCheckInDue: null,
        );

        await tester.pumpWidget(buildTestApp(userProfile: user));
        await tester.pumpAndSettle();

        expect(find.text('No check-in scheduled'), findsOneWidget);
      });
    });

    group('App Shell Integration', () {
      testWidgets('check-in screen is accessible from bottom nav',
          (tester) async {
        supabaseService.currentUserOverride = FakeUser();
        supabaseService.userProfileOverride = AppUser(
          id: 'test-user-id',
          email: 'test@example.com',
          displayName: 'Test User',
          checkInIntervalHours: 48,
          lastCheckInAt: DateTime.now().subtract(const Duration(hours: 12)),
          nextCheckInDue: DateTime.now().add(const Duration(hours: 36)),
        );

        final appRouter = GoRouter(
          initialLocation: '/settings',
          redirect: (context, state) {
            final isAuth = supabaseService.currentUser != null;
            if (!isAuth) return '/login';
            return null;
          },
          routes: [
            GoRoute(
              path: '/login',
              builder: (_, __) => const Scaffold(body: Text('Login')),
            ),
            ShellRoute(
              builder: (context, state, child) => MainShell(child: child),
              routes: [
                GoRoute(
                  path: '/',
                  builder: (_, __) => const CheckInScreen(),
                ),
                GoRoute(
                  path: '/contacts',
                  builder: (_, __) =>
                      const Scaffold(body: Text('Contacts Screen')),
                ),
                GoRoute(
                  path: '/settings',
                  builder: (_, __) =>
                      const Scaffold(body: Text('Settings Screen')),
                ),
              ],
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              supabaseServiceProvider.overrideWithValue(supabaseService),
            ],
            child: MaterialApp.router(
              theme: AppTheme.light,
              routerConfig: appRouter,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Start on settings
        expect(find.text('Settings Screen'), findsOneWidget);

        // Tap Check In in bottom nav
        await tester.tap(find.byIcon(Icons.favorite));
        await tester.pumpAndSettle();

        // Should now show check-in screen
        expect(find.byType(CheckInScreen), findsOneWidget);
        expect(find.text("I'M OK"), findsOneWidget);
      });
    });
  });
}
