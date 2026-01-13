import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:are_you_dead/features/contacts/providers/contacts_provider.dart';
import 'package:are_you_dead/services/service_providers.dart';
import 'package:are_you_dead/services/supabase_service_interface.dart';

import '../../mocks/mock_supabase_service.dart';
import '../../mocks/test_fixtures.dart';

void main() {
  group('ContactsProvider', () {
    late TestableSupabaseService mockService;
    late ProviderContainer container;

    setUp(() {
      mockService = TestableSupabaseService();
      mockService.currentUserOverride = FakeUser();
    });

    tearDown(() {
      container.dispose();
      mockService.dispose();
    });

    ProviderContainer createContainer() {
      return ProviderContainer(
        overrides: [
          supabaseServiceProvider.overrideWithValue(mockService),
        ],
      );
    }

    group('Initial state', () {
      test('starts with loading state', () {
        mockService.contactsOverride = [];
        container = createContainer();

        final state = container.read(contactsNotifierProvider);
        expect(state.isLoading, isTrue);
        expect(state.contacts, isEmpty);
        expect(state.error, isNull);
      });
    });

    group('ContactsState', () {
      test('default values are correct', () {
        const state = ContactsState();
        expect(state.contacts, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });

      test('copyWith works correctly', () {
        const state = ContactsState();
        final updated = state.copyWith(
          contacts: TestFixtures.sampleContacts,
          isLoading: true,
          error: 'Test error',
        );

        expect(updated.contacts, equals(TestFixtures.sampleContacts));
        expect(updated.isLoading, isTrue);
        expect(updated.error, equals('Test error'));
      });
    });

    group('Helper providers with mocked state', () {
      // Override the notifier to provide pre-loaded state
      test('contactsCount returns correct count', () {
        container = ProviderContainer(
          overrides: [
            supabaseServiceProvider.overrideWithValue(mockService),
            contactsNotifierProvider.overrideWith(() {
              return _TestContactsNotifier(TestFixtures.sampleContacts);
            }),
          ],
        );

        final count = container.read(contactsCountProvider);
        expect(count, equals(3));
      });

      test('hasContacts returns true when contacts exist', () {
        container = ProviderContainer(
          overrides: [
            supabaseServiceProvider.overrideWithValue(mockService),
            contactsNotifierProvider.overrideWith(() {
              return _TestContactsNotifier([TestFixtures.sampleContact]);
            }),
          ],
        );

        final hasContacts = container.read(hasContactsProvider);
        expect(hasContacts, isTrue);
      });

      test('hasContacts returns false when no contacts', () {
        container = ProviderContainer(
          overrides: [
            supabaseServiceProvider.overrideWithValue(mockService),
            contactsNotifierProvider.overrideWith(() {
              return _TestContactsNotifier([]);
            }),
          ],
        );

        final hasContacts = container.read(hasContactsProvider);
        expect(hasContacts, isFalse);
      });

      test('canAddContact returns true when under limit', () {
        container = ProviderContainer(
          overrides: [
            supabaseServiceProvider.overrideWithValue(mockService),
            contactsNotifierProvider.overrideWith(() {
              return _TestContactsNotifier([TestFixtures.sampleContact]);
            }),
          ],
        );

        final canAdd = container.read(canAddContactProvider);
        expect(canAdd, isTrue);
      });

      test('canAddContact returns false when at limit', () {
        container = ProviderContainer(
          overrides: [
            supabaseServiceProvider.overrideWithValue(mockService),
            contactsNotifierProvider.overrideWith(() {
              return _TestContactsNotifier(TestFixtures.maxContacts);
            }),
          ],
        );

        final canAdd = container.read(canAddContactProvider);
        expect(canAdd, isFalse);
      });

      test('contactById returns correct contact', () {
        container = ProviderContainer(
          overrides: [
            supabaseServiceProvider.overrideWithValue(mockService),
            contactsNotifierProvider.overrideWith(() {
              return _TestContactsNotifier(TestFixtures.sampleContacts);
            }),
          ],
        );

        final contact = container.read(
          contactByIdProvider(TestFixtures.sampleContact.id),
        );
        expect(contact, isNotNull);
        expect(contact?.name, equals(TestFixtures.sampleContact.name));
      });

      test('contactById returns null for unknown id', () {
        container = ProviderContainer(
          overrides: [
            supabaseServiceProvider.overrideWithValue(mockService),
            contactsNotifierProvider.overrideWith(() {
              return _TestContactsNotifier(TestFixtures.sampleContacts);
            }),
          ],
        );

        final contact = container.read(contactByIdProvider('unknown-id'));
        expect(contact, isNull);
      });
    });

    group('Max contacts limit', () {
      test('ISupabaseService.maxContacts is 5', () {
        expect(ISupabaseService.maxContacts, equals(5));
      });
    });
  });
}

/// Test notifier that provides pre-loaded state without async loading
class _TestContactsNotifier extends ContactsNotifier {
  final List<dynamic> _contacts;

  _TestContactsNotifier(this._contacts);

  @override
  ContactsState build() {
    // Return pre-loaded state, no async loading
    return ContactsState(
      contacts: _contacts.cast(),
      isLoading: false,
    );
  }
}
