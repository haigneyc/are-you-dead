import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:are_you_dead/widgets/app_text_field.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppTextField', () {
    group('rendering', () {
      testWidgets('renders with label', (tester) async {
        await tester.pumpAppWithScaffold(
          const AppTextField(label: 'Email'),
        );

        expect(find.text('Email'), findsOneWidget);
      });

      testWidgets('renders with hint text', (tester) async {
        await tester.pumpAppWithScaffold(
          const AppTextField(hint: 'Enter your email'),
        );

        expect(find.text('Enter your email'), findsOneWidget);
      });

      testWidgets('renders with both label and hint', (tester) async {
        await tester.pumpAppWithScaffold(
          const AppTextField(
            label: 'Email',
            hint: 'Enter your email',
          ),
        );

        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Enter your email'), findsOneWidget);
      });

      testWidgets('renders prefix icon', (tester) async {
        await tester.pumpAppWithScaffold(
          const AppTextField(
            label: 'Email',
            prefixIcon: Icon(Icons.email),
          ),
        );

        expect(find.byIcon(Icons.email), findsOneWidget);
      });

      testWidgets('renders suffix icon', (tester) async {
        await tester.pumpAppWithScaffold(
          const AppTextField(
            label: 'Password',
            suffixIcon: Icon(Icons.visibility),
          ),
        );

        expect(find.byIcon(Icons.visibility), findsOneWidget);
      });
    });

    group('validation', () {
      testWidgets('shows error message from validator', (tester) async {
        final formKey = GlobalKey<FormState>();

        await tester.pumpAppWithScaffold(
          Form(
            key: formKey,
            child: AppTextField(
              label: 'Email',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                return null;
              },
            ),
          ),
        );

        // Trigger validation
        formKey.currentState!.validate();
        await tester.pump();

        expect(find.text('Email is required'), findsOneWidget);
      });

      testWidgets('shows no error when validation passes', (tester) async {
        final formKey = GlobalKey<FormState>();
        final controller = TextEditingController(text: 'test@example.com');

        await tester.pumpAppWithScaffold(
          Form(
            key: formKey,
            child: AppTextField(
              label: 'Email',
              controller: controller,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                return null;
              },
            ),
          ),
        );

        // Trigger validation
        formKey.currentState!.validate();
        await tester.pump();

        expect(find.text('Email is required'), findsNothing);
      });
    });

    group('interaction', () {
      testWidgets('updates controller value on input', (tester) async {
        final controller = TextEditingController();

        await tester.pumpAppWithScaffold(
          AppTextField(
            label: 'Name',
            controller: controller,
          ),
        );

        await tester.enterText(find.byType(TextFormField), 'John Doe');
        await tester.pump();

        expect(controller.text, 'John Doe');
      });

      testWidgets('calls onChanged callback', (tester) async {
        String? changedValue;

        await tester.pumpAppWithScaffold(
          AppTextField(
            label: 'Name',
            onChanged: (value) => changedValue = value,
          ),
        );

        await tester.enterText(find.byType(TextFormField), 'Test');
        await tester.pump();

        expect(changedValue, 'Test');
      });

      testWidgets('calls onFieldSubmitted callback', (tester) async {
        String? submittedValue;

        await tester.pumpAppWithScaffold(
          AppTextField(
            label: 'Name',
            onFieldSubmitted: (value) => submittedValue = value,
          ),
        );

        await tester.enterText(find.byType(TextFormField), 'Test');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(submittedValue, 'Test');
      });
    });

    group('obscureText', () {
      testWidgets('obscures text when obscureText is true', (tester) async {
        await tester.pumpAppWithScaffold(
          const AppTextField(
            label: 'Password',
            obscureText: true,
          ),
        );

        // Find the underlying TextField which has the obscureText property
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.obscureText, isTrue);
      });

      testWidgets('does not obscure text when obscureText is false',
          (tester) async {
        await tester.pumpAppWithScaffold(
          const AppTextField(
            label: 'Email',
            obscureText: false,
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.obscureText, isFalse);
      });
    });

    group('enabled state', () {
      testWidgets('is enabled by default', (tester) async {
        await tester.pumpAppWithScaffold(
          const AppTextField(label: 'Name'),
        );

        final textField = tester.widget<TextFormField>(find.byType(TextFormField));
        expect(textField.enabled, isTrue);
      });

      testWidgets('is disabled when enabled is false', (tester) async {
        await tester.pumpAppWithScaffold(
          const AppTextField(
            label: 'Name',
            enabled: false,
          ),
        );

        final textField = tester.widget<TextFormField>(find.byType(TextFormField));
        expect(textField.enabled, isFalse);
      });

      testWidgets('does not accept input when disabled', (tester) async {
        final controller = TextEditingController();

        await tester.pumpAppWithScaffold(
          AppTextField(
            label: 'Name',
            controller: controller,
            enabled: false,
          ),
        );

        // Try to enter text - should not work when disabled
        await tester.enterText(find.byType(TextFormField), 'Test');
        await tester.pump();

        expect(controller.text, isEmpty);
      });
    });

    group('maxLines', () {
      testWidgets('defaults to single line', (tester) async {
        await tester.pumpAppWithScaffold(
          const AppTextField(label: 'Name'),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.maxLines, 1);
      });

      testWidgets('supports multiple lines', (tester) async {
        await tester.pumpAppWithScaffold(
          const AppTextField(
            label: 'Description',
            maxLines: 5,
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.maxLines, 5);
      });
    });

    group('keyboard type', () {
      testWidgets('uses email keyboard type when specified', (tester) async {
        await tester.pumpAppWithScaffold(
          const AppTextField(
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.keyboardType, TextInputType.emailAddress);
      });

      testWidgets('uses phone keyboard type when specified', (tester) async {
        await tester.pumpAppWithScaffold(
          const AppTextField(
            label: 'Phone',
            keyboardType: TextInputType.phone,
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.keyboardType, TextInputType.phone);
      });
    });
  });
}
