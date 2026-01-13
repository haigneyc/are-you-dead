import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:are_you_dead/features/check_in/widgets/check_in_button.dart';
import 'package:are_you_dead/core/theme/app_colors.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('CheckInButton', () {
    group('rendering', () {
      testWidgets('renders "I\'M OK" text in default state', (tester) async {
        await tester.pumpAppWithScaffold(
          Center(
            child: CheckInButton(
              onPressed: () {},
            ),
          ),
        );

        expect(find.text("I'M OK"), findsOneWidget);
      });

      testWidgets('shows circular shape', (tester) async {
        await tester.pumpAppWithScaffold(
          Center(
            child: CheckInButton(
              onPressed: () {},
            ),
          ),
        );

        // Find the AnimatedContainer with BoxShape.circle
        final animatedContainers =
            tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));
        final circularContainer = animatedContainers.where((container) {
          final decoration = container.decoration as BoxDecoration?;
          return decoration?.shape == BoxShape.circle;
        });
        expect(circularContainer.isNotEmpty, isTrue);
      });

      testWidgets('has correct dimensions (140x140)', (tester) async {
        await tester.pumpAppWithScaffold(
          Center(
            child: CheckInButton(
              onPressed: () {},
            ),
          ),
        );

        final animatedContainers =
            tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));
        final circularContainer = animatedContainers.where((container) {
          return container.constraints?.maxWidth == 140 &&
              container.constraints?.maxHeight == 140;
        });
        expect(circularContainer.isNotEmpty, isTrue);
      });
    });

    group('success state', () {
      testWidgets('shows checkmark icon when isShowingSuccess is true',
          (tester) async {
        await tester.pumpAppWithScaffold(
          Center(
            child: CheckInButton(
              onPressed: () {},
              isShowingSuccess: true,
            ),
          ),
        );

        expect(find.byIcon(Icons.check), findsOneWidget);
        expect(find.text("I'M OK"), findsNothing);
      });

      testWidgets('uses success color when isShowingSuccess is true',
          (tester) async {
        await tester.pumpAppWithScaffold(
          Center(
            child: CheckInButton(
              onPressed: () {},
              isShowingSuccess: true,
            ),
          ),
        );

        final animatedContainers =
            tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));
        final successContainer = animatedContainers.where((container) {
          final decoration = container.decoration as BoxDecoration?;
          return decoration?.color == AppColors.success;
        });
        expect(successContainer.isNotEmpty, isTrue);
      });

      testWidgets('animates when transitioning to success state',
          (tester) async {
        await tester.pumpAppWithScaffold(
          Center(
            child: CheckInButton(
              onPressed: () {},
              isShowingSuccess: false,
            ),
          ),
        );

        // Verify initial state
        expect(find.text("I'M OK"), findsOneWidget);

        // Rebuild with success state
        await tester.pumpAppWithScaffold(
          Center(
            child: CheckInButton(
              onPressed: () {},
              isShowingSuccess: true,
            ),
          ),
        );

        // Pump some frames for animation
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byIcon(Icons.check), findsOneWidget);
      });
    });

    group('overdue state', () {
      testWidgets('shows "OVERDUE" text when isOverdue is true',
          (tester) async {
        await tester.pumpAppWithScaffold(
          Center(
            child: CheckInButton(
              onPressed: () {},
              isOverdue: true,
            ),
          ),
        );

        expect(find.text('OVERDUE'), findsOneWidget);
        expect(find.text("I'M OK"), findsOneWidget);
      });

      testWidgets('uses error color when isOverdue is true', (tester) async {
        await tester.pumpAppWithScaffold(
          Center(
            child: CheckInButton(
              onPressed: () {},
              isOverdue: true,
            ),
          ),
        );

        final animatedContainers =
            tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));
        final overdueContainer = animatedContainers.where((container) {
          final decoration = container.decoration as BoxDecoration?;
          return decoration?.color == AppColors.error;
        });
        expect(overdueContainer.isNotEmpty, isTrue);
      });
    });

    group('disabled state', () {
      testWidgets('uses grey color when disabled', (tester) async {
        await tester.pumpAppWithScaffold(
          Center(
            child: CheckInButton(
              onPressed: () {},
              isEnabled: false,
            ),
          ),
        );

        final animatedContainers =
            tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));
        final disabledContainer = animatedContainers.where((container) {
          final decoration = container.decoration as BoxDecoration?;
          return decoration?.color == Colors.grey;
        });
        expect(disabledContainer.isNotEmpty, isTrue);
      });

      testWidgets('does not call onPressed when disabled', (tester) async {
        var pressed = false;

        await tester.pumpAppWithScaffold(
          Center(
            child: CheckInButton(
              onPressed: () => pressed = true,
              isEnabled: false,
            ),
          ),
        );

        await tester.tap(find.byType(GestureDetector));
        await tester.pump();

        expect(pressed, isFalse);
      });
    });

    group('interaction', () {
      testWidgets('calls onPressed when tapped', (tester) async {
        var pressed = false;

        await tester.pumpAppWithScaffold(
          Center(
            child: CheckInButton(
              onPressed: () => pressed = true,
            ),
          ),
        );

        await tester.tap(find.text("I'M OK"));
        await tester.pump();

        expect(pressed, isTrue);
      });

      testWidgets('triggers haptic feedback on tap', (tester) async {
        final List<MethodCall> log = <MethodCall>[];
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (MethodCall methodCall) async {
            log.add(methodCall);
            return null;
          },
        );

        await tester.pumpAppWithScaffold(
          Center(
            child: CheckInButton(
              onPressed: () {},
            ),
          ),
        );

        await tester.tap(find.text("I'M OK"));
        await tester.pump();

        // Verify haptic feedback was called
        expect(
          log.where((call) => call.method == 'HapticFeedback.vibrate'),
          isNotEmpty,
        );
      });

      testWidgets('uses Transform widget for scale animation', (tester) async {
        await tester.pumpAppWithScaffold(
          Center(
            child: CheckInButton(
              onPressed: () {},
            ),
          ),
        );

        // Verify Transform.scale is used for animation
        expect(find.byType(Transform), findsWidgets);

        // Verify GestureDetector handles tap events
        expect(find.byType(GestureDetector), findsOneWidget);
      });
    });

    group('priority: success > overdue > normal', () {
      testWidgets('success state takes priority over overdue state',
          (tester) async {
        await tester.pumpAppWithScaffold(
          Center(
            child: CheckInButton(
              onPressed: () {},
              isShowingSuccess: true,
              isOverdue: true,
            ),
          ),
        );

        // Should show success (checkmark), not overdue text
        expect(find.byIcon(Icons.check), findsOneWidget);
        expect(find.text('OVERDUE'), findsNothing);
      });
    });
  });
}
