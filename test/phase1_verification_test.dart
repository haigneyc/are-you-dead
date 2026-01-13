/// Phase 1 Verification Tests
///
/// These tests verify that the testing infrastructure from Phase 1 is working:
/// - ISupabaseService interface
/// - MockSupabaseService and TestableSupabaseService
/// - Test fixtures
/// - Riverpod DI with supabaseServiceProvider
///
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:are_you_dead/services/service_providers.dart';
import 'package:are_you_dead/services/supabase_service_interface.dart';

import 'mocks/mock_supabase_service.dart';
import 'mocks/test_fixtures.dart';
import 'helpers/pump_app.dart';

void main() {
  group('Phase 1 Infrastructure Verification', () {
    group('ISupabaseService Interface', () {
      test('MockSupabaseService implements ISupabaseService', () {
        final mock = MockSupabaseService();
        expect(mock, isA<ISupabaseService>());
      });

      test('TestableSupabaseService implements ISupabaseService', () {
        final testable = TestableSupabaseService();
        expect(testable, isA<ISupabaseService>());
      });
    });

    group('TestableSupabaseService functionality', () {
      late TestableSupabaseService service;

      setUp(() {
        service = TestableSupabaseService();
      });

      tearDown(() {
        service.dispose();
      });

      test('starts with null currentUser', () {
        expect(service.currentUser, isNull);
      });

      test('signIn sets currentUser', () async {
        await service.signIn(email: 'test@example.com', password: 'password');
        expect(service.currentUser, isNotNull);
        expect(service.currentUser!.email, equals('test@example.com'));
      });

      test('signOut clears currentUser', () async {
        await service.signIn(email: 'test@example.com', password: 'password');
        await service.signOut();
        expect(service.currentUser, isNull);
      });

      test('performCheckIn updates user profile', () async {
        service.currentUserOverride = FakeUser();
        service.userProfileOverride = TestFixtures.sampleUser;

        final before = service.userProfileOverride!.lastCheckInAt;
        final result = await service.performCheckIn();

        expect(result.lastCheckInAt, isNotNull);
        expect(result.lastCheckInAt, isNot(equals(before)));
      });

      test('shouldThrowOnCheckIn causes performCheckIn to fail', () async {
        service.currentUserOverride = FakeUser();
        service.shouldThrowOnCheckIn = true;

        expect(
          () => service.performCheckIn(),
          throwsException,
        );
      });

      test('contacts CRUD operations work', () async {
        service.currentUserOverride = FakeUser();

        // Initially empty
        var contacts = await service.getContacts();
        expect(contacts, isEmpty);

        // Add contact
        final added = await service.addContact(
          name: 'Test Contact',
          phone: '+15551234567',
          email: 'contact@example.com',
        );
        expect(added.name, equals('Test Contact'));

        // List shows contact
        contacts = await service.getContacts();
        expect(contacts.length, equals(1));

        // Update contact
        await service.updateContact(
          contactId: added.id,
          name: 'Updated Name',
        );
        contacts = await service.getContacts();
        expect(contacts.first.name, equals('Updated Name'));

        // Delete contact
        await service.deleteContact(added.id);
        contacts = await service.getContacts();
        expect(contacts, isEmpty);
      });
    });

    group('Test Fixtures', () {
      test('sampleUser has required fields', () {
        final user = TestFixtures.sampleUser;
        expect(user.id, isNotEmpty);
        expect(user.email, isNotEmpty);
        expect(user.checkInIntervalHours, greaterThan(0));
      });

      test('overdueUser is actually overdue', () {
        final user = TestFixtures.overdueUser;
        expect(user.nextCheckInDue, isNotNull);
        expect(user.nextCheckInDue!.isBefore(DateTime.now()), isTrue);
      });

      test('sampleContacts list is populated', () {
        final contacts = TestFixtures.sampleContacts;
        expect(contacts.length, equals(3));
        expect(contacts.first.name, isNotEmpty);
      });

      test('maxContacts has exactly 5 contacts', () {
        final contacts = TestFixtures.maxContacts;
        expect(contacts.length, equals(ISupabaseService.maxContacts));
      });

      test('validation test data is available', () {
        expect(TestFixtures.validEmails, isNotEmpty);
        expect(TestFixtures.invalidEmails, isNotEmpty);
        expect(TestFixtures.validPhones, isNotEmpty);
        expect(TestFixtures.invalidPhones, isNotEmpty);
        expect(TestFixtures.validPasswords, isNotEmpty);
        expect(TestFixtures.invalidPasswords, isNotEmpty);
      });
    });

    group('Riverpod DI', () {
      test('supabaseServiceProvider can be overridden', () {
        final mockService = TestableSupabaseService();

        final container = ProviderContainer(
          overrides: [
            supabaseServiceProvider.overrideWithValue(mockService),
          ],
        );

        final service = container.read(supabaseServiceProvider);
        expect(service, same(mockService));

        container.dispose();
        mockService.dispose();
      });

      test('createTestContainer helper works', () {
        final mockService = TestableSupabaseService();
        final container = createTestContainer(supabaseService: mockService);

        final service = container.read(supabaseServiceProvider);
        expect(service, same(mockService));

        container.dispose();
        mockService.dispose();
      });
    });
  });
}
