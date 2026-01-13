import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:are_you_dead/widgets/app_button.dart';
import 'package:are_you_dead/core/theme/app_colors.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppButton', () {
    group('rendering', () {
      testWidgets('renders child widget', (tester) async {
        await tester.pumpApp(
          AppButton(
            onPressed: () {},
            child: const Text('Test Button'),
          ),
        );

        expect(find.text('Test Button'), findsOneWidget);
      });

      testWidgets('renders as ElevatedButton for primary variant',
          (tester) async {
        await tester.pumpApp(
          AppButton(
            onPressed: () {},
            variant: AppButtonVariant.primary,
            child: const Text('Primary'),
          ),
        );

        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('renders as OutlinedButton for secondary variant',
          (tester) async {
        await tester.pumpApp(
          AppButton(
            onPressed: () {},
            variant: AppButtonVariant.secondary,
            child: const Text('Secondary'),
          ),
        );

        expect(find.byType(OutlinedButton), findsOneWidget);
      });

      testWidgets('renders as ElevatedButton for danger variant',
          (tester) async {
        await tester.pumpApp(
          AppButton(
            onPressed: () {},
            variant: AppButtonVariant.danger,
            child: const Text('Danger'),
          ),
        );

        expect(find.byType(ElevatedButton), findsOneWidget);
      });
    });

    group('interaction', () {
      testWidgets('calls onPressed when tapped', (tester) async {
        var pressed = false;

        await tester.pumpApp(
          AppButton(
            onPressed: () => pressed = true,
            child: const Text('Tap Me'),
          ),
        );

        await tester.tap(find.text('Tap Me'));
        await tester.pump();

        expect(pressed, isTrue);
      });

      testWidgets('does not call onPressed when onPressed is null',
          (tester) async {
        await tester.pumpApp(
          const AppButton(
            onPressed: null,
            child: Text('Disabled'),
          ),
        );

        // Button should be disabled - verify it's there but not responsive
        expect(find.text('Disabled'), findsOneWidget);
        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNull);
      });
    });

    group('loading state', () {
      testWidgets('shows CircularProgressIndicator when isLoading is true',
          (tester) async {
        await tester.pumpApp(
          AppButton(
            onPressed: () {},
            isLoading: true,
            child: const Text('Loading'),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Loading'), findsNothing);
      });

      testWidgets('shows child when isLoading is false', (tester) async {
        await tester.pumpApp(
          AppButton(
            onPressed: () {},
            isLoading: false,
            child: const Text('Not Loading'),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Not Loading'), findsOneWidget);
      });

      testWidgets('disables tap when isLoading is true', (tester) async {
        var pressed = false;

        await tester.pumpApp(
          AppButton(
            onPressed: () => pressed = true,
            isLoading: true,
            child: const Text('Loading'),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(pressed, isFalse);
      });

      testWidgets('shows loading indicator for secondary variant',
          (tester) async {
        await tester.pumpApp(
          AppButton(
            onPressed: () {},
            isLoading: true,
            variant: AppButtonVariant.secondary,
            child: const Text('Loading'),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(OutlinedButton), findsOneWidget);
      });

      testWidgets('shows loading indicator for danger variant', (tester) async {
        await tester.pumpApp(
          AppButton(
            onPressed: () {},
            isLoading: true,
            variant: AppButtonVariant.danger,
            child: const Text('Loading'),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('fullWidth', () {
      testWidgets('renders full width by default', (tester) async {
        await tester.pumpApp(
          AppButton(
            onPressed: () {},
            child: const Text('Full Width'),
          ),
        );

        final button =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        final style = button.style;
        expect(style?.minimumSize?.resolve({}), const Size.fromHeight(48));
      });

      testWidgets('renders without full width when fullWidth is false',
          (tester) async {
        await tester.pumpApp(
          AppButton(
            onPressed: () {},
            fullWidth: false,
            child: const Text('Not Full Width'),
          ),
        );

        final button =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        final style = button.style;
        expect(style?.minimumSize?.resolve({}), isNull);
      });
    });
  });
}
