import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:are_you_dead/widgets/loading_overlay.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('LoadingOverlay', () {
    group('rendering', () {
      testWidgets('renders child widget', (tester) async {
        await tester.pumpApp(
          LoadingOverlay(
            isLoading: false,
            child: const Text('Child Content'),
          ),
        );

        expect(find.text('Child Content'), findsOneWidget);
      });

      testWidgets('renders child widget even when loading', (tester) async {
        await tester.pumpApp(
          LoadingOverlay(
            isLoading: true,
            child: const Text('Child Content'),
          ),
        );

        // Child should still be in the widget tree (just covered by overlay)
        expect(find.text('Child Content'), findsOneWidget);
      });
    });

    group('loading indicator', () {
      testWidgets('shows loading indicator when isLoading is true',
          (tester) async {
        await tester.pumpApp(
          LoadingOverlay(
            isLoading: true,
            child: const Text('Content'),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('hides loading indicator when isLoading is false',
          (tester) async {
        await tester.pumpApp(
          LoadingOverlay(
            isLoading: false,
            child: const Text('Content'),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets('shows loading indicator inside a Card', (tester) async {
        await tester.pumpApp(
          LoadingOverlay(
            isLoading: true,
            child: const Text('Content'),
          ),
        );

        expect(find.byType(Card), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('message', () {
      testWidgets('shows message when provided and loading', (tester) async {
        await tester.pumpApp(
          LoadingOverlay(
            isLoading: true,
            message: 'Please wait...',
            child: const Text('Content'),
          ),
        );

        expect(find.text('Please wait...'), findsOneWidget);
      });

      testWidgets('does not show message when not loading', (tester) async {
        await tester.pumpApp(
          LoadingOverlay(
            isLoading: false,
            message: 'Please wait...',
            child: const Text('Content'),
          ),
        );

        expect(find.text('Please wait...'), findsNothing);
      });

      testWidgets('does not show message when message is null', (tester) async {
        await tester.pumpApp(
          LoadingOverlay(
            isLoading: true,
            message: null,
            child: const Text('Content'),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        // Only the progress indicator should be visible, no text message
        final column = tester.widget<Column>(find.byType(Column));
        expect(column.children.length, 1);
      });
    });

    group('overlay behavior', () {
      testWidgets('overlay covers entire screen when loading', (tester) async {
        await tester.pumpApp(
          LoadingOverlay(
            isLoading: true,
            child: const Text('Content'),
          ),
        );

        // Find the semi-transparent container
        final containers = find.byType(Container);
        expect(containers, findsWidgets);

        // The overlay container should have Colors.black54
        final overlayContainer = tester.widgetList<Container>(containers).where(
          (c) => c.color == Colors.black54,
        );
        expect(overlayContainer.isNotEmpty, isTrue);
      });

      testWidgets('no overlay when not loading', (tester) async {
        await tester.pumpApp(
          LoadingOverlay(
            isLoading: false,
            child: const Text('Content'),
          ),
        );

        // The overlay container should not exist
        final containers = tester.widgetList<Container>(find.byType(Container));
        final overlayContainer = containers.where(
          (c) => c.color == Colors.black54,
        );
        expect(overlayContainer.isEmpty, isTrue);
      });

      testWidgets('blocks interaction when loading', (tester) async {
        var tapped = false;

        await tester.pumpApp(
          LoadingOverlay(
            isLoading: true,
            child: ElevatedButton(
              onPressed: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        );

        // Try to tap the button behind the overlay
        await tester.tap(find.text('Tap Me'));
        await tester.pump();

        // The overlay should block the tap
        expect(tapped, isFalse);
      });

      testWidgets('allows interaction when not loading', (tester) async {
        var tapped = false;

        await tester.pumpApp(
          LoadingOverlay(
            isLoading: false,
            child: ElevatedButton(
              onPressed: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        );

        await tester.tap(find.text('Tap Me'));
        await tester.pump();

        expect(tapped, isTrue);
      });
    });

    group('state transitions', () {
      testWidgets('can transition from not loading to loading', (tester) async {
        var isLoading = false;

        await tester.pumpApp(
          StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() => isLoading = true),
                    child: const Text('Start Loading'),
                  ),
                  Expanded(
                    child: LoadingOverlay(
                      isLoading: isLoading,
                      child: const Text('Content'),
                    ),
                  ),
                ],
              );
            },
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsNothing);

        await tester.tap(find.text('Start Loading'));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('can transition from loading to not loading', (tester) async {
        var isLoading = true;

        await tester.pumpApp(
          StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() => isLoading = false),
                    child: const Text('Stop Loading'),
                  ),
                  Expanded(
                    child: LoadingOverlay(
                      isLoading: isLoading,
                      child: const Text('Content'),
                    ),
                  ),
                ],
              );
            },
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.tap(find.text('Stop Loading'));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });
  });
}
