import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:are_you_dead/core/theme/app_theme.dart';
import 'package:are_you_dead/services/service_providers.dart';
import 'package:are_you_dead/services/supabase_service_interface.dart';

import '../mocks/mock_supabase_service.dart';

/// Helper to pump a widget with proper app context for testing.
///
/// This wraps the widget in a [MaterialApp] with the app theme and
/// a [ProviderScope] with any necessary overrides.
///
/// Example:
/// ```dart
/// testWidgets('MyWidget renders correctly', (tester) async {
///   await tester.pumpApp(MyWidget());
///   expect(find.text('Hello'), findsOneWidget);
/// });
/// ```
extension PumpApp on WidgetTester {
  /// Pumps a widget wrapped in MaterialApp and ProviderScope.
  ///
  /// - [widget]: The widget to test
  /// - [supabaseService]: Optional mock Supabase service
  /// - [overrides]: Additional provider overrides
  Future<void> pumpApp(
    Widget widget, {
    ISupabaseService? supabaseService,
    List<Override>? overrides,
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: [
          supabaseServiceProvider
              .overrideWithValue(supabaseService ?? MockSupabaseService()),
          ...?overrides,
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: widget,
        ),
      ),
    );
  }

  /// Pumps a widget with a Scaffold wrapper.
  ///
  /// Useful for testing widgets that expect to be inside a Scaffold.
  Future<void> pumpAppWithScaffold(
    Widget widget, {
    ISupabaseService? supabaseService,
    List<Override>? overrides,
  }) async {
    await pumpApp(
      Scaffold(body: widget),
      supabaseService: supabaseService,
      overrides: overrides,
    );
  }

  /// Pumps a widget and waits for all animations to complete.
  Future<void> pumpAppAndSettle(
    Widget widget, {
    ISupabaseService? supabaseService,
    List<Override>? overrides,
    Duration? duration,
  }) async {
    await pumpApp(
      widget,
      supabaseService: supabaseService,
      overrides: overrides,
    );
    await pumpAndSettle(duration ?? const Duration(seconds: 1));
  }
}

/// Creates a ProviderContainer for unit testing providers.
///
/// Example:
/// ```dart
/// test('provider returns correct value', () {
///   final container = createTestContainer();
///   final value = container.read(myProvider);
///   expect(value, expectedValue);
/// });
/// ```
ProviderContainer createTestContainer({
  ISupabaseService? supabaseService,
  List<Override>? overrides,
}) {
  return ProviderContainer(
    overrides: [
      supabaseServiceProvider
          .overrideWithValue(supabaseService ?? MockSupabaseService()),
      ...?overrides,
    ],
  );
}

/// A test wrapper widget that provides theme and providers.
///
/// Useful when you need more control over the widget tree.
class TestApp extends StatelessWidget {
  const TestApp({
    super.key,
    required this.child,
    this.supabaseService,
    this.overrides,
  });

  final Widget child;
  final ISupabaseService? supabaseService;
  final List<Override>? overrides;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        supabaseServiceProvider
            .overrideWithValue(supabaseService ?? MockSupabaseService()),
        ...?overrides,
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: child,
      ),
    );
  }
}
