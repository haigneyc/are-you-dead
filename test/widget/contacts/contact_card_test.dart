import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:are_you_dead/features/contacts/widgets/contact_card.dart';
import 'package:are_you_dead/models/emergency_contact.dart';

import '../../helpers/pump_app.dart';
import '../../mocks/test_fixtures.dart';

void main() {
  group('ContactCard', () {
    group('rendering', () {
      testWidgets('displays contact name', (tester) async {
        await tester.pumpAppWithScaffold(
          ContactCard(
            contact: TestFixtures.sampleContact,
            onTap: () {},
            onDelete: () {},
          ),
        );

        expect(find.text('Jane Doe'), findsOneWidget);
      });

      testWidgets('displays contact initial in avatar', (tester) async {
        await tester.pumpAppWithScaffold(
          ContactCard(
            contact: TestFixtures.sampleContact,
            onTap: () {},
            onDelete: () {},
          ),
        );

        // Should show 'J' for 'Jane Doe'
        expect(find.text('J'), findsOneWidget);
      });

      testWidgets('displays masked phone number', (tester) async {
        final contact = EmergencyContact(
          id: 'test-id',
          userId: 'user-id',
          name: 'Test Contact',
          phone: '+15551234567',
          priority: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpAppWithScaffold(
          ContactCard(
            contact: contact,
            onTap: () {},
            onDelete: () {},
          ),
        );

        // Phone should be masked: +15551234567 -> ***-***-4567
        expect(find.text('***-***-4567'), findsOneWidget);
        expect(find.text('+15551234567'), findsNothing);
      });

      testWidgets('displays masked email when provided', (tester) async {
        await tester.pumpAppWithScaffold(
          ContactCard(
            contact: TestFixtures.sampleContact, // has jane@example.com
            onTap: () {},
            onDelete: () {},
          ),
        );

        // Email should be masked: jane@example.com -> j***@example.com
        expect(find.text('j***@example.com'), findsOneWidget);
        expect(find.text('jane@example.com'), findsNothing);
      });

      testWidgets('handles null email gracefully', (tester) async {
        await tester.pumpAppWithScaffold(
          ContactCard(
            contact: TestFixtures.contactWithoutEmail,
            onTap: () {},
            onDelete: () {},
          ),
        );

        // Should display contact without crashing
        expect(find.text('Bob Jones'), findsOneWidget);
        // Should not show any masked email placeholder
        expect(find.textContaining('***@'), findsNothing);
      });

      testWidgets('handles empty email gracefully', (tester) async {
        final contact = EmergencyContact(
          id: 'test-id',
          userId: 'user-id',
          name: 'Test Contact',
          phone: '+15551234567',
          email: '',
          priority: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpAppWithScaffold(
          ContactCard(
            contact: contact,
            onTap: () {},
            onDelete: () {},
          ),
        );

        expect(find.text('Test Contact'), findsOneWidget);
        expect(find.textContaining('***@'), findsNothing);
      });

      testWidgets('shows ? for empty name', (tester) async {
        final contact = EmergencyContact(
          id: 'test-id',
          userId: 'user-id',
          name: '',
          phone: '+15551234567',
          priority: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpAppWithScaffold(
          ContactCard(
            contact: contact,
            onTap: () {},
            onDelete: () {},
          ),
        );

        expect(find.text('?'), findsOneWidget);
      });
    });

    group('phone masking', () {
      testWidgets('masks long phone number correctly', (tester) async {
        final contact = EmergencyContact(
          id: 'test-id',
          userId: 'user-id',
          name: 'Test',
          phone: '+14155551234',
          priority: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpAppWithScaffold(
          ContactCard(
            contact: contact,
            onTap: () {},
            onDelete: () {},
          ),
        );

        expect(find.text('***-***-1234'), findsOneWidget);
      });

      testWidgets('handles short phone number', (tester) async {
        final contact = EmergencyContact(
          id: 'test-id',
          userId: 'user-id',
          name: 'Test',
          phone: '123',
          priority: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpAppWithScaffold(
          ContactCard(
            contact: contact,
            onTap: () {},
            onDelete: () {},
          ),
        );

        // Short phone should be shown as-is
        expect(find.text('123'), findsOneWidget);
      });
    });

    group('email masking', () {
      testWidgets('masks standard email correctly', (tester) async {
        final contact = EmergencyContact(
          id: 'test-id',
          userId: 'user-id',
          name: 'Test',
          phone: '+15551234567',
          email: 'john@example.com',
          priority: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpAppWithScaffold(
          ContactCard(
            contact: contact,
            onTap: () {},
            onDelete: () {},
          ),
        );

        expect(find.text('j***@example.com'), findsOneWidget);
      });

      testWidgets('handles email without @ symbol', (tester) async {
        final contact = EmergencyContact(
          id: 'test-id',
          userId: 'user-id',
          name: 'Test',
          phone: '+15551234567',
          email: 'invalid-email',
          priority: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpAppWithScaffold(
          ContactCard(
            contact: contact,
            onTap: () {},
            onDelete: () {},
          ),
        );

        // Invalid email should be shown as-is
        expect(find.text('invalid-email'), findsOneWidget);
      });
    });

    group('interaction - card tap', () {
      testWidgets('calls onTap when card is tapped', (tester) async {
        var tapped = false;

        await tester.pumpAppWithScaffold(
          ContactCard(
            contact: TestFixtures.sampleContact,
            onTap: () => tapped = true,
            onDelete: () {},
          ),
        );

        // Tap on the Card which contains the InkWell
        await tester.tap(find.byType(Card));
        await tester.pump();

        expect(tapped, isTrue);
      });

      testWidgets('calls onTap when tapping contact name', (tester) async {
        var tapped = false;

        await tester.pumpAppWithScaffold(
          ContactCard(
            contact: TestFixtures.sampleContact,
            onTap: () => tapped = true,
            onDelete: () {},
          ),
        );

        await tester.tap(find.text('Jane Doe'));
        await tester.pump();

        expect(tapped, isTrue);
      });
    });

    group('interaction - popup menu', () {
      testWidgets('shows popup menu when more button is tapped',
          (tester) async {
        await tester.pumpAppWithScaffold(
          ContactCard(
            contact: TestFixtures.sampleContact,
            onTap: () {},
            onDelete: () {},
          ),
        );

        // Tap the more_vert icon
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();

        // Menu items should be visible
        expect(find.text('Edit'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);
      });

      testWidgets('calls onTap when Edit menu item is selected',
          (tester) async {
        var tapped = false;

        await tester.pumpAppWithScaffold(
          ContactCard(
            contact: TestFixtures.sampleContact,
            onTap: () => tapped = true,
            onDelete: () {},
          ),
        );

        // Open menu
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();

        // Tap Edit
        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();

        expect(tapped, isTrue);
      });

      testWidgets('calls onDelete when Delete menu item is selected',
          (tester) async {
        var deleted = false;

        await tester.pumpAppWithScaffold(
          ContactCard(
            contact: TestFixtures.sampleContact,
            onTap: () {},
            onDelete: () => deleted = true,
          ),
        );

        // Open menu
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();

        // Tap Delete
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        expect(deleted, isTrue);
      });

      testWidgets('shows edit icon in menu', (tester) async {
        await tester.pumpAppWithScaffold(
          ContactCard(
            contact: TestFixtures.sampleContact,
            onTap: () {},
            onDelete: () {},
          ),
        );

        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.edit), findsOneWidget);
      });

      testWidgets('shows delete icon in menu', (tester) async {
        await tester.pumpAppWithScaffold(
          ContactCard(
            contact: TestFixtures.sampleContact,
            onTap: () {},
            onDelete: () {},
          ),
        );

        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.delete), findsOneWidget);
      });
    });

    group('styling', () {
      testWidgets('renders as a Card widget', (tester) async {
        await tester.pumpAppWithScaffold(
          ContactCard(
            contact: TestFixtures.sampleContact,
            onTap: () {},
            onDelete: () {},
          ),
        );

        expect(find.byType(Card), findsOneWidget);
      });

      testWidgets('has CircleAvatar for contact initial', (tester) async {
        await tester.pumpAppWithScaffold(
          ContactCard(
            contact: TestFixtures.sampleContact,
            onTap: () {},
            onDelete: () {},
          ),
        );

        expect(find.byType(CircleAvatar), findsOneWidget);
      });

      testWidgets('uppercase first letter in avatar', (tester) async {
        final contact = EmergencyContact(
          id: 'test-id',
          userId: 'user-id',
          name: 'lowercase name',
          phone: '+15551234567',
          priority: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpAppWithScaffold(
          ContactCard(
            contact: contact,
            onTap: () {},
            onDelete: () {},
          ),
        );

        // Should show uppercase 'L', not 'l'
        expect(find.text('L'), findsOneWidget);
        expect(find.text('l'), findsNothing);
      });
    });
  });
}
