import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../models/emergency_contact.dart';
import '../../../services/service_providers.dart';
import '../../../services/supabase_service_interface.dart';

part 'contacts_provider.freezed.dart';
part 'contacts_provider.g.dart';

/// Contacts state containing the list of emergency contacts
@freezed
class ContactsState with _$ContactsState {
  const factory ContactsState({
    @Default([]) List<EmergencyContact> contacts,
    @Default(false) bool isLoading,
    String? error,
  }) = _ContactsState;
}

/// Contacts notifier for managing emergency contacts
@riverpod
class ContactsNotifier extends _$ContactsNotifier {
  @override
  ContactsState build() {
    // Load contacts on initialization using Future.microtask to defer
    // state access until after build() returns
    Future.microtask(_loadContacts);
    return const ContactsState(isLoading: true);
  }

  /// Load contacts from Supabase
  Future<void> _loadContacts() async {
    try {
      final supabase = ref.read(supabaseServiceProvider);
      final contacts = await supabase.getContacts();
      state = state.copyWith(
        contacts: contacts,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh contacts from server
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    await _loadContacts();
  }

  /// Add a new emergency contact
  Future<bool> addContact({
    required String name,
    required String phone,
    String? email,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final supabase = ref.read(supabaseServiceProvider);
      final newContact = await supabase.addContact(
        name: name,
        phone: phone,
        email: email,
      );

      state = state.copyWith(
        contacts: [...state.contacts, newContact],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Update an existing contact
  Future<bool> updateContact({
    required String contactId,
    required String name,
    required String phone,
    String? email,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final supabase = ref.read(supabaseServiceProvider);
      await supabase.updateContact(
        contactId: contactId,
        name: name,
        phone: phone,
        email: email,
      );

      // Update local state
      final updatedContacts = state.contacts.map((c) {
        if (c.id == contactId) {
          return c.copyWith(
            name: name,
            phone: phone,
            email: email,
          );
        }
        return c;
      }).toList();

      state = state.copyWith(
        contacts: updatedContacts,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Delete a contact
  Future<bool> deleteContact(String contactId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final supabase = ref.read(supabaseServiceProvider);
      await supabase.deleteContact(contactId);

      // Remove from local state
      final updatedContacts =
          state.contacts.where((c) => c.id != contactId).toList();

      state = state.copyWith(
        contacts: updatedContacts,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Clear any error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for the number of contacts
@riverpod
int contactsCount(ContactsCountRef ref) {
  final contactsState = ref.watch(contactsNotifierProvider);
  return contactsState.contacts.length;
}

/// Provider to check if user has any contacts
@riverpod
bool hasContacts(HasContactsRef ref) {
  final count = ref.watch(contactsCountProvider);
  return count > 0;
}

/// Provider to check if user can add more contacts
@riverpod
bool canAddContact(CanAddContactRef ref) {
  final count = ref.watch(contactsCountProvider);
  return count < ISupabaseService.maxContacts;
}

/// Provider to get a specific contact by ID
@riverpod
EmergencyContact? contactById(ContactByIdRef ref, String contactId) {
  final contactsState = ref.watch(contactsNotifierProvider);
  try {
    return contactsState.contacts.firstWhere((c) => c.id == contactId);
  } catch (_) {
    return null;
  }
}
