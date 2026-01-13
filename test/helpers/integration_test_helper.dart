import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import 'package:are_you_dead/app.dart';
import 'package:are_you_dead/core/theme/app_theme.dart';
import 'package:are_you_dead/features/auth/providers/auth_provider.dart';
import 'package:are_you_dead/features/check_in/providers/check_in_provider.dart';
import 'package:are_you_dead/features/contacts/providers/contacts_provider.dart';
import 'package:are_you_dead/models/emergency_contact.dart';
import 'package:are_you_dead/models/user.dart';
import 'package:are_you_dead/services/service_providers.dart';
import 'package:are_you_dead/services/supabase_service_interface.dart';

import '../mocks/mock_supabase_service.dart';

/// A test app wrapper that sets up the full app with GoRouter and providers.
///
/// This helper enables integration testing by:
/// 1. Providing a mock Supabase service
/// 2. Setting up the router with proper auth state handling
/// 3. Exposing methods to control auth state and navigate programmatically
class IntegrationTestApp extends StatefulWidget {
  const IntegrationTestApp({
    super.key,
    required this.supabaseService,
    this.initialRoute = '/login',
    this.isAuthenticated = false,
    this.userProfile,
    this.contacts,
    this.overrides = const [],
  });

  final TestableSupabaseService supabaseService;
  final String initialRoute;
  final bool isAuthenticated;
  final AppUser? userProfile;
  final List<EmergencyContact>? contacts;
  final List<Override> overrides;

  @override
  State<IntegrationTestApp> createState() => IntegrationTestAppState();
}

class IntegrationTestAppState extends State<IntegrationTestApp> {
  late final TestableSupabaseService _supabaseService;
  late final StreamController<AuthState> _authStateController;
  late ProviderContainer _container;
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _supabaseService = widget.supabaseService;
    _authStateController = StreamController<AuthState>.broadcast();

    _setupProviders();
    _setupRouter();
  }

  void _setupProviders() {
    // Set initial state
    if (widget.isAuthenticated) {
      _supabaseService.currentUserOverride = FakeUser();
      _supabaseService.userProfileOverride = widget.userProfile;
      _supabaseService.contactsOverride = widget.contacts ?? [];
    }
  }

  void _setupRouter() {
    _router = GoRouter(
      initialLocation: widget.initialRoute,
      redirect: (context, state) {
        final isAuthenticated = _supabaseService.currentUser != null;
        final isAuthRoute = state.matchedLocation == '/login' ||
            state.matchedLocation == '/signup' ||
            state.matchedLocation == '/forgot-password';

        if (!isAuthenticated && !isAuthRoute) {
          return '/login';
        }

        if (isAuthenticated && isAuthRoute) {
          return '/';
        }

        return null;
      },
      routes: _buildRoutes(),
    );
  }

  List<RouteBase> _buildRoutes() {
    return [
      // Auth routes - imported from app.dart structure
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            const _LazyScreen(screenName: 'LoginScreen'),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) =>
            const _LazyScreen(screenName: 'SignupScreen'),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) =>
            const _LazyScreen(screenName: 'ForgotPasswordScreen'),
      ),

      // Main app with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                const _LazyScreen(screenName: 'CheckInScreen'),
          ),
          GoRoute(
            path: '/contacts',
            builder: (context, state) =>
                const _LazyScreen(screenName: 'ContactsScreen'),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) =>
                const _LazyScreen(screenName: 'SettingsScreen'),
          ),
        ],
      ),

      // Contact management routes
      GoRoute(
        path: '/contacts/add',
        builder: (context, state) =>
            const _LazyScreen(screenName: 'AddContactScreen'),
      ),
      GoRoute(
        path: '/contacts/edit/:id',
        builder: (context, state) {
          final contactId = state.pathParameters['id']!;
          return _LazyScreen(screenName: 'EditContactScreen:$contactId');
        },
      ),

      // Settings routes
      GoRoute(
        path: '/settings/profile',
        builder: (context, state) =>
            const _LazyScreen(screenName: 'EditProfileScreen'),
      ),
    ];
  }

  @override
  void dispose() {
    _authStateController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        supabaseServiceProvider.overrideWithValue(_supabaseService),
        ...widget.overrides,
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// Lazy screen placeholder for testing routes without full widget trees.
class _LazyScreen extends StatelessWidget {
  const _LazyScreen({required this.screenName});

  final String screenName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(screenName, key: Key('screen_$screenName')),
      ),
    );
  }
}

/// Extension for integration testing with full app.
extension IntegrationTestExtension on WidgetTester {
  /// Pumps the integration test app with optional configuration.
  Future<TestableSupabaseService> pumpIntegrationApp({
    bool isAuthenticated = false,
    String initialRoute = '/login',
    AppUser? userProfile,
    List<EmergencyContact>? contacts,
    List<Override>? overrides,
  }) async {
    final supabaseService = TestableSupabaseService(
      userProfileOverride: userProfile,
      contactsOverride: contacts,
    );

    if (isAuthenticated) {
      supabaseService.currentUserOverride = FakeUser();
    }

    await pumpWidget(
      IntegrationTestApp(
        supabaseService: supabaseService,
        initialRoute: initialRoute,
        isAuthenticated: isAuthenticated,
        userProfile: userProfile,
        contacts: contacts,
        overrides: overrides ?? [],
      ),
    );

    return supabaseService;
  }

  /// Pumps the full real app screens with mocked services.
  Future<TestableSupabaseService> pumpFullApp({
    bool isAuthenticated = false,
    AppUser? userProfile,
    List<EmergencyContact>? contacts,
    List<Override>? overrides,
  }) async {
    final supabaseService = TestableSupabaseService(
      userProfileOverride: userProfile,
      contactsOverride: contacts,
    );

    if (isAuthenticated) {
      supabaseService.currentUserOverride = FakeUser();
    }

    await pumpWidget(
      ProviderScope(
        overrides: [
          supabaseServiceProvider.overrideWithValue(supabaseService),
          ...?overrides,
        ],
        child: const AreYouDeadApp(),
      ),
    );

    return supabaseService;
  }

  /// Helper to find widgets by key suffix.
  Finder findByKey(String key) => find.byKey(Key(key));

  /// Helper to find text button by label.
  Finder findTextButton(String label) => find.widgetWithText(TextButton, label);

  /// Helper to find elevated button by label.
  Finder findElevatedButton(String label) =>
      find.widgetWithText(ElevatedButton, label);

  /// Helper to enter text in a labeled text field.
  Future<void> enterTextInField(String label, String text) async {
    final field = find.widgetWithText(TextFormField, label);
    await enterText(field, text);
    await pump();
  }

  /// Helper to tap a text containing widget.
  Future<void> tapText(String text) async {
    await tap(find.text(text));
    await pump();
  }

  /// Helper to tap a button by label.
  Future<void> tapButton(String label) async {
    final button = find.widgetWithText(ElevatedButton, label);
    if (button.evaluate().isEmpty) {
      // Try TextButton or FilledButton
      final textButton = find.widgetWithText(TextButton, label);
      if (textButton.evaluate().isNotEmpty) {
        await tap(textButton);
      } else {
        final filledButton = find.widgetWithText(FilledButton, label);
        await tap(filledButton);
      }
    } else {
      await tap(button);
    }
    await pump();
  }

  /// Helper to verify snackbar message.
  void expectSnackbar(String message) {
    expect(find.text(message), findsOneWidget);
  }

  /// Helper to verify current route (by screen text).
  void expectScreen(String screenName) {
    expect(find.byKey(Key('screen_$screenName')), findsOneWidget);
  }
}

/// Test fixtures specific to integration tests.
class IntegrationFixtures {
  IntegrationFixtures._();

  /// Default authenticated user profile.
  static AppUser get authenticatedUser => AppUser(
        id: 'test-user-id',
        email: 'test@example.com',
        displayName: 'Test User',
        checkInIntervalHours: 48,
        lastCheckInAt: DateTime.now().subtract(const Duration(hours: 12)),
        nextCheckInDue: DateTime.now().add(const Duration(hours: 36)),
      );

  /// User who is overdue.
  static AppUser get overdueUser => AppUser(
        id: 'overdue-user-id',
        email: 'overdue@example.com',
        displayName: 'Overdue User',
        checkInIntervalHours: 24,
        lastCheckInAt: DateTime.now().subtract(const Duration(hours: 48)),
        nextCheckInDue: DateTime.now().subtract(const Duration(hours: 24)),
      );

  /// Sample contacts list.
  static List<EmergencyContact> get sampleContacts => [
        EmergencyContact(
          id: 'contact-1',
          userId: 'test-user-id',
          name: 'Jane Doe',
          phone: '+15559876543',
          email: 'jane@example.com',
          priority: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        EmergencyContact(
          id: 'contact-2',
          userId: 'test-user-id',
          name: 'John Smith',
          phone: '+15551234567',
          email: null,
          priority: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

  /// Max contacts (5).
  static List<EmergencyContact> get maxContacts => List.generate(
        5,
        (i) => EmergencyContact(
          id: 'contact-$i',
          userId: 'test-user-id',
          name: 'Contact ${i + 1}',
          phone: '+1555000000$i',
          priority: i + 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
}
