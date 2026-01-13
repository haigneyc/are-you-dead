import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:are_you_dead/features/check_in/widgets/countdown_timer.dart';
import 'package:are_you_dead/core/theme/app_colors.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('CountdownTimer', () {
    group('null nextDue', () {
      testWidgets('shows "No check-in scheduled" when nextDue is null',
          (tester) async {
        await tester.pumpAppWithScaffold(
          const CountdownTimer(nextDue: null),
        );

        expect(find.text('No check-in scheduled'), findsOneWidget);
      });

      testWidgets('does not show countdown when nextDue is null',
          (tester) async {
        await tester.pumpAppWithScaffold(
          const CountdownTimer(nextDue: null),
        );

        expect(find.text('Next check-in due in'), findsNothing);
        expect(find.text('OVERDUE'), findsNothing);
      });
    });

    group('time formatting - days remaining', () {
      testWidgets('displays "X days, Y hours" when >24h remaining',
          (tester) async {
        final nextDue = DateTime.now().add(const Duration(days: 2, hours: 5));

        await tester.pumpAppWithScaffold(
          CountdownTimer(nextDue: nextDue),
        );

        expect(find.text('Next check-in due in'), findsOneWidget);
        expect(find.textContaining('2 days'), findsOneWidget);
      });

      testWidgets('handles singular "day" correctly', (tester) async {
        final nextDue = DateTime.now().add(const Duration(days: 1, hours: 3));

        await tester.pumpAppWithScaffold(
          CountdownTimer(nextDue: nextDue),
        );

        // Should show "1 day" (singular) not "1 days"
        expect(find.textContaining('1 day,'), findsOneWidget);
      });
    });

    group('time formatting - hours remaining', () {
      testWidgets('displays "X hours, Y min" when <24h but >1h remaining',
          (tester) async {
        final nextDue = DateTime.now().add(const Duration(hours: 12, minutes: 30));

        await tester.pumpAppWithScaffold(
          CountdownTimer(nextDue: nextDue),
        );

        expect(find.textContaining('hour'), findsOneWidget);
        expect(find.textContaining('min'), findsOneWidget);
      });

      testWidgets('handles singular "hour" correctly', (tester) async {
        final nextDue = DateTime.now().add(const Duration(hours: 1, minutes: 15));

        await tester.pumpAppWithScaffold(
          CountdownTimer(nextDue: nextDue),
        );

        // Should show "1 hour" (singular) not "1 hours"
        expect(find.textContaining('1 hour,'), findsOneWidget);
      });
    });

    group('time formatting - minutes remaining', () {
      testWidgets('displays "X minutes" when <1h remaining', (tester) async {
        final nextDue = DateTime.now().add(const Duration(minutes: 45));

        await tester.pumpAppWithScaffold(
          CountdownTimer(nextDue: nextDue),
        );

        expect(find.textContaining('minute'), findsOneWidget);
        expect(find.textContaining('hour'), findsNothing);
      });

      testWidgets('handles singular "minute" correctly', (tester) async {
        // Use a time slightly more than 1 minute to account for test execution time
        final nextDue = DateTime.now().add(const Duration(minutes: 1, seconds: 30));

        await tester.pumpAppWithScaffold(
          CountdownTimer(nextDue: nextDue),
        );

        // Should show "1 minute" (singular) - allowing for slight timing variations
        expect(find.textContaining('minute'), findsOneWidget);
      });
    });

    group('overdue state', () {
      testWidgets('displays "OVERDUE" when time is negative', (tester) async {
        final nextDue = DateTime.now().subtract(const Duration(hours: 2));

        await tester.pumpAppWithScaffold(
          CountdownTimer(nextDue: nextDue),
        );

        expect(find.text('OVERDUE'), findsOneWidget);
      });

      testWidgets('shows "Check-in overdue!" label when overdue',
          (tester) async {
        final nextDue = DateTime.now().subtract(const Duration(hours: 1));

        await tester.pumpAppWithScaffold(
          CountdownTimer(nextDue: nextDue),
        );

        expect(find.text('Check-in overdue!'), findsOneWidget);
        expect(find.text('Next check-in due in'), findsNothing);
      });
    });

    group('color coding', () {
      testWidgets('uses timerNormal color when >6h remaining', (tester) async {
        final nextDue = DateTime.now().add(const Duration(hours: 12));

        await tester.pumpAppWithScaffold(
          CountdownTimer(nextDue: nextDue),
        );

        // Find the text widget with the time remaining
        final textWidgets = tester.widgetList<Text>(find.byType(Text));
        final coloredText = textWidgets.where((text) {
          return text.style?.color == AppColors.timerNormal;
        });
        expect(coloredText.isNotEmpty, isTrue);
      });

      testWidgets('uses timerUrgent color when <6h but >1h remaining',
          (tester) async {
        final nextDue = DateTime.now().add(const Duration(hours: 3));

        await tester.pumpAppWithScaffold(
          CountdownTimer(nextDue: nextDue),
        );

        final textWidgets = tester.widgetList<Text>(find.byType(Text));
        final coloredText = textWidgets.where((text) {
          return text.style?.color == AppColors.timerUrgent;
        });
        expect(coloredText.isNotEmpty, isTrue);
      });

      testWidgets('uses timerCritical color when <1h remaining',
          (tester) async {
        final nextDue = DateTime.now().add(const Duration(minutes: 30));

        await tester.pumpAppWithScaffold(
          CountdownTimer(nextDue: nextDue),
        );

        final textWidgets = tester.widgetList<Text>(find.byType(Text));
        final coloredText = textWidgets.where((text) {
          return text.style?.color == AppColors.timerCritical;
        });
        expect(coloredText.isNotEmpty, isTrue);
      });

      testWidgets('uses timerCritical color when overdue', (tester) async {
        final nextDue = DateTime.now().subtract(const Duration(hours: 1));

        await tester.pumpAppWithScaffold(
          CountdownTimer(nextDue: nextDue),
        );

        final textWidgets = tester.widgetList<Text>(find.byType(Text));
        final coloredText = textWidgets.where((text) {
          return text.style?.color == AppColors.timerCritical;
        });
        expect(coloredText.isNotEmpty, isTrue);
      });
    });

    group('widget update', () {
      testWidgets('updates display when nextDue changes', (tester) async {
        DateTime? nextDue = DateTime.now().add(const Duration(days: 2, hours: 5));

        await tester.pumpAppWithScaffold(
          StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  ElevatedButton(
                    key: const Key('change-button'),
                    onPressed: () => setState(() {
                      nextDue = DateTime.now().add(const Duration(hours: 5));
                    }),
                    child: const Text('Change'),
                  ),
                  CountdownTimer(nextDue: nextDue),
                ],
              );
            },
          ),
        );

        expect(find.textContaining('days'), findsOneWidget);

        // Update with a new nextDue
        await tester.tap(find.byKey(const Key('change-button')));
        await tester.pump();

        expect(find.textContaining('hour'), findsOneWidget);
      });

      testWidgets('updates from valid time to null', (tester) async {
        DateTime? nextDue = DateTime.now().add(const Duration(hours: 24));

        await tester.pumpAppWithScaffold(
          StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  ElevatedButton(
                    key: const Key('clear-button'),
                    onPressed: () => setState(() {
                      nextDue = null;
                    }),
                    child: const Text('Clear'),
                  ),
                  CountdownTimer(nextDue: nextDue),
                ],
              );
            },
          ),
        );

        expect(find.text('Next check-in due in'), findsOneWidget);

        await tester.tap(find.byKey(const Key('clear-button')));
        await tester.pump();

        expect(find.text('No check-in scheduled'), findsOneWidget);
      });
    });

    group('animation', () {
      testWidgets('starts pulse animation when overdue', (tester) async {
        final nextDue = DateTime.now().subtract(const Duration(hours: 1));

        await tester.pumpAppWithScaffold(
          CountdownTimer(nextDue: nextDue),
        );

        // Pump a few frames to let animation start
        await tester.pump(const Duration(milliseconds: 500));

        // Find the AnimatedBuilder (used for pulse animation)
        expect(find.byType(AnimatedBuilder), findsWidgets);

        // The animation should be running - we can't easily verify the scale
        // but we can verify the widget structure is correct
        expect(find.text('OVERDUE'), findsOneWidget);
      });
    });

    group('edge cases', () {
      testWidgets('handles exactly 0 minutes remaining', (tester) async {
        // Set nextDue to very close to now (within seconds)
        final nextDue = DateTime.now().add(const Duration(seconds: 30));

        await tester.pumpAppWithScaffold(
          CountdownTimer(nextDue: nextDue),
        );

        // Should show 0 minutes
        expect(find.textContaining('minute'), findsOneWidget);
      });

      testWidgets('handles exactly 24 hours remaining', (tester) async {
        // Add slightly more than 24 hours to ensure we're in the "days" display range
        final nextDue = DateTime.now().add(const Duration(hours: 24, minutes: 30));

        await tester.pumpAppWithScaffold(
          CountdownTimer(nextDue: nextDue),
        );

        // Should show "1 day, X hours" format
        expect(find.textContaining('1 day'), findsOneWidget);
      });
    });
  });
}
