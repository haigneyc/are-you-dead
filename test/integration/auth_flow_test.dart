import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import 'package:are_you_dead/core/theme/app_theme.dart';
import 'package:are_you_dead/features/auth/providers/auth_provider.dart';
import 'package:are_you_dead/features/auth/screens/forgot_password_screen.dart';
import 'package:are_you_dead/features/auth/screens/login_screen.dart';
import 'package:are_you_dead/features/auth/screens/signup_screen.dart';
import 'package:are_you_dead/features/check_in/screens/check_in_screen.dart';
import 'package:are_you_dead/models/user.dart';
import 'package:are_you_dead/services/service_providers.dart';

import '../mocks/mock_supabase_service.dart';

void main() {
  group('Auth Flow Integration Tests', () {
    late TestableSupabaseService supabaseService;
    late GoRouter router;

    setUp(() {
      supabaseService = TestableSupabaseService();
    });

    tearDown(() {
      supabaseService.dispose();
    });

    /// Helper to build the test app with routing.
    Widget buildTestApp({
      String initialRoute = '/login',
      bool isAuthenticated = false,
      AppUser? userProfile,
    }) {
      if (isAuthenticated) {
        supabaseService.currentUserOverride = FakeUser();
        supabaseService.userProfileOverride =
            userProfile ?? _defaultUserProfile;
      }

      router = GoRouter(
        initialLocation: initialRoute,
        redirect: (context, state) {
          final isAuth = supabaseService.currentUser != null;
          final isAuthRoute = state.matchedLocation == '/login' ||
              state.matchedLocation == '/signup' ||
              state.matchedLocation == '/forgot-password';

          if (!isAuth && !isAuthRoute) return '/login';
          if (isAuth && isAuthRoute) return '/';
          return null;
        },
        routes: [
          GoRoute(
            path: '/login',
            builder: (_, __) => const LoginScreen(),
          ),
          GoRoute(
            path: '/signup',
            builder: (_, __) => const SignupScreen(),
          ),
          GoRoute(
            path: '/forgot-password',
            builder: (_, __) => const ForgotPasswordScreen(),
          ),
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

    group('Login Screen', () {
      testWidgets('displays login form elements', (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        expect(find.text('Are You Dead?'), findsOneWidget);
        expect(find.text('Sign in to continue'), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Sign In'), findsOneWidget);
        expect(find.text('Forgot password?'), findsOneWidget);
        expect(find.text('Sign Up'), findsOneWidget);
      });

      testWidgets('shows validation errors for empty fields', (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Tap sign in without entering anything
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        // Should show validation errors
        expect(find.text('Email is required'), findsOneWidget);
        expect(find.text('Password is required'), findsOneWidget);
      });

      testWidgets('shows validation error for invalid email', (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Enter invalid email
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Email'), 'invalid-email');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Password'), 'password123');
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        expect(find.text('Please enter a valid email address'), findsOneWidget);
      });

      testWidgets('shows validation error for short password', (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Password'), 'short');
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        expect(find.text('Password must be at least 8 characters'),
            findsOneWidget);
      });

      testWidgets('successful login navigates to home', (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Enter valid credentials
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Password'), 'password123');
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        // Should navigate to home (CheckInScreen)
        expect(find.text('Check In'), findsOneWidget);
      });

      testWidgets('shows error snackbar on login failure', (tester) async {
        supabaseService.shouldThrowOnAuth = true;

        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Password'), 'wrongpassword');
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        // Should show error snackbar
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Sign in failed. Please try again.'), findsOneWidget);
      });

      testWidgets('navigates to signup screen', (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        // Signup screen has "Create Account" as both title and button
        expect(find.text('Create Account'), findsAtLeastNWidgets(1));
        expect(find.text('Sign up to get started'), findsOneWidget);
      });

      testWidgets('navigates to forgot password screen', (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Forgot password?'));
        await tester.pumpAndSettle();

        expect(find.text('Reset Password'), findsOneWidget);
      });

      testWidgets('toggles password visibility', (tester) async {
        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Find visibility toggle button - password is obscured initially
        final visibilityButton = find.byIcon(Icons.visibility);
        expect(visibilityButton, findsOneWidget);

        // Toggle visibility
        await tester.tap(visibilityButton);
        await tester.pumpAndSettle();

        // Should now show visibility_off icon (meaning password is visible)
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);

        // Toggle back
        await tester.tap(find.byIcon(Icons.visibility_off));
        await tester.pumpAndSettle();

        // Should show visibility icon again
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      });

      testWidgets('shows loading state during sign in', (tester) async {
        // Use a completer to control when sign in completes
        final completer = Completer<void>();
        supabaseService = _DelayedSupabaseService(completer);

        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Password'), 'password123');
        await tester.tap(find.text('Sign In'));
        await tester.pump();

        // Should show loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Complete the sign in
        completer.complete();
        await tester.pumpAndSettle();
      });
    });

    group('Signup Screen', () {
      testWidgets('displays signup form elements', (tester) async {
        await tester.pumpWidget(buildTestApp(initialRoute: '/signup'));
        await tester.pumpAndSettle();

        // "Create Account" appears twice: as title and button
        expect(find.text('Create Account'), findsNWidgets(2));
        expect(find.text('Sign up to get started'), findsOneWidget);
        expect(find.text('Display Name (optional)'), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Confirm Password'), findsOneWidget);
      });

      testWidgets('shows validation errors for empty required fields',
          (tester) async {
        await tester.pumpWidget(buildTestApp(initialRoute: '/signup'));
        await tester.pumpAndSettle();

        // Find the Create Account button (not the title)
        final createButton = find.widgetWithText(ElevatedButton, 'Create Account');
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        expect(find.text('Email is required'), findsOneWidget);
        expect(find.text('Password is required'), findsOneWidget);
      });

      testWidgets('shows error when passwords do not match', (tester) async {
        await tester.pumpWidget(buildTestApp(initialRoute: '/signup'));
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(TextFormField, 'Email'), 'new@example.com');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Password'), 'password123');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Confirm Password'),
            'password456');

        final createButton = find.widgetWithText(ElevatedButton, 'Create Account');
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        expect(find.text('Passwords do not match'), findsOneWidget);
      });

      testWidgets('successful signup shows confirmation and navigates to login',
          (tester) async {
        // Use a service that doesn't auto-authenticate on signup
        supabaseService = _SignupOnlySupabaseService();

        await tester.pumpWidget(buildTestApp(initialRoute: '/signup'));
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(TextFormField, 'Display Name (optional)'),
            'New User');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Email'), 'new@example.com');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Password'), 'password123');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Confirm Password'),
            'password123');

        final createButton = find.widgetWithText(ElevatedButton, 'Create Account');
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        // Should show success snackbar
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.textContaining('Account created'), findsOneWidget);

        // Should navigate to login (not home, since user isn't authenticated yet)
        expect(find.text('Are You Dead?'), findsOneWidget);
      });

      testWidgets('shows error snackbar on signup failure', (tester) async {
        supabaseService.shouldThrowOnAuth = true;

        await tester.pumpWidget(buildTestApp(initialRoute: '/signup'));
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(TextFormField, 'Email'), 'existing@example.com');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Password'), 'password123');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Confirm Password'),
            'password123');

        final createButton = find.widgetWithText(ElevatedButton, 'Create Account');
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Sign up failed. Please try again.'), findsOneWidget);
      });

      testWidgets('back button navigates to login', (tester) async {
        // Start from login and navigate to signup to build history
        await tester.pumpWidget(buildTestApp(initialRoute: '/login'));
        await tester.pumpAndSettle();

        // Navigate to signup
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        // Verify we're on signup
        expect(find.text('Create Account'), findsNWidgets(2));

        // Tap back button
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        expect(find.text('Are You Dead?'), findsOneWidget);
      });

      testWidgets('sign in link navigates to login', (tester) async {
        // Start from login and navigate to signup to build history
        await tester.pumpWidget(buildTestApp(initialRoute: '/login'));
        await tester.pumpAndSettle();

        // Navigate to signup
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(TextButton, 'Sign In'));
        await tester.pumpAndSettle();

        expect(find.text('Are You Dead?'), findsOneWidget);
      });
    });

    group('Forgot Password Screen', () {
      testWidgets('displays reset password form', (tester) async {
        await tester.pumpWidget(buildTestApp(initialRoute: '/forgot-password'));
        await tester.pumpAndSettle();

        expect(find.text('Reset Password'), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Send Reset Link'), findsOneWidget);
      });

      testWidgets('shows validation error for empty email', (tester) async {
        await tester.pumpWidget(buildTestApp(initialRoute: '/forgot-password'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Send Reset Link'));
        await tester.pumpAndSettle();

        expect(find.text('Email is required'), findsOneWidget);
      });

      testWidgets('shows validation error for invalid email', (tester) async {
        await tester.pumpWidget(buildTestApp(initialRoute: '/forgot-password'));
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(TextFormField, 'Email'), 'invalid');
        await tester.tap(find.text('Send Reset Link'));
        await tester.pumpAndSettle();

        expect(find.text('Please enter a valid email address'), findsOneWidget);
      });

      testWidgets('successful reset shows confirmation UI', (tester) async {
        await tester.pumpWidget(buildTestApp(initialRoute: '/forgot-password'));
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
        await tester.tap(find.text('Send Reset Link'));
        await tester.pumpAndSettle();

        // Should show success UI (not snackbar)
        expect(find.text('Check Your Email'), findsOneWidget);
        expect(find.textContaining('reset link'), findsOneWidget);
        expect(find.text('Back to Sign In'), findsOneWidget);
      });

      testWidgets('back button navigates to login', (tester) async {
        // Start from login and navigate to forgot password to build history
        await tester.pumpWidget(buildTestApp(initialRoute: '/login'));
        await tester.pumpAndSettle();

        // Navigate to forgot password
        await tester.tap(find.text('Forgot password?'));
        await tester.pumpAndSettle();

        expect(find.text('Reset Password'), findsOneWidget);

        // Tap back button
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        expect(find.text('Are You Dead?'), findsOneWidget);
      });
    });

    group('Auth Redirects', () {
      testWidgets('unauthenticated user is redirected to login',
          (tester) async {
        await tester.pumpWidget(buildTestApp(initialRoute: '/'));
        await tester.pumpAndSettle();

        // Should be redirected to login
        expect(find.text('Are You Dead?'), findsOneWidget);
        expect(find.text('Sign in to continue'), findsOneWidget);
      });

      testWidgets('authenticated user on login is redirected to home',
          (tester) async {
        await tester.pumpWidget(buildTestApp(
          initialRoute: '/login',
          isAuthenticated: true,
        ));
        await tester.pumpAndSettle();

        // Should be redirected to home
        expect(find.text('Check In'), findsOneWidget);
      });

      testWidgets('authenticated user on signup is redirected to home',
          (tester) async {
        await tester.pumpWidget(buildTestApp(
          initialRoute: '/signup',
          isAuthenticated: true,
        ));
        await tester.pumpAndSettle();

        expect(find.text('Check In'), findsOneWidget);
      });
    });
  });
}

/// Default user profile for tests.
AppUser get _defaultUserProfile => AppUser(
      id: 'test-user-id',
      email: 'test@example.com',
      displayName: 'Test User',
      checkInIntervalHours: 48,
      lastCheckInAt: DateTime.now().subtract(const Duration(hours: 12)),
      nextCheckInDue: DateTime.now().add(const Duration(hours: 36)),
    );

/// A delayed Supabase service for testing loading states.
class _DelayedSupabaseService extends TestableSupabaseService {
  _DelayedSupabaseService(this._completer);

  final Completer<void> _completer;

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    await _completer.future;
    return super.signIn(email: email, password: password);
  }
}

/// A Supabase service that doesn't auto-authenticate on signup.
/// In real apps, users need to verify email before being authenticated.
class _SignupOnlySupabaseService extends TestableSupabaseService {
  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    // Don't set currentUserOverride - user isn't authenticated until email verification
    return FakeAuthResponse(user: FakeUser(email: email), session: null);
  }
}
