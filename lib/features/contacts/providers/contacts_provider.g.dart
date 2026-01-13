// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactsCountHash() => r'9416519842d9d0a631075f2e5352a04621753344';

/// Provider for the number of contacts
///
/// Copied from [contactsCount].
@ProviderFor(contactsCount)
final contactsCountProvider = AutoDisposeProvider<int>.internal(
  contactsCount,
  name: r'contactsCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contactsCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContactsCountRef = AutoDisposeProviderRef<int>;
String _$hasContactsHash() => r'4f3491f19901f7c609ad8df821a343090f445f7e';

/// Provider to check if user has any contacts
///
/// Copied from [hasContacts].
@ProviderFor(hasContacts)
final hasContactsProvider = AutoDisposeProvider<bool>.internal(
  hasContacts,
  name: r'hasContactsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$hasContactsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasContactsRef = AutoDisposeProviderRef<bool>;
String _$canAddContactHash() => r'2f7dca0a1d6a7b7a980e4131568652434f71f94f';

/// Provider to check if user can add more contacts
///
/// Copied from [canAddContact].
@ProviderFor(canAddContact)
final canAddContactProvider = AutoDisposeProvider<bool>.internal(
  canAddContact,
  name: r'canAddContactProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$canAddContactHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CanAddContactRef = AutoDisposeProviderRef<bool>;
String _$contactByIdHash() => r'cbd76412344b1a67d52a76e10d5fcecc450d5c69';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider to get a specific contact by ID
///
/// Copied from [contactById].
@ProviderFor(contactById)
const contactByIdProvider = ContactByIdFamily();

/// Provider to get a specific contact by ID
///
/// Copied from [contactById].
class ContactByIdFamily extends Family<EmergencyContact?> {
  /// Provider to get a specific contact by ID
  ///
  /// Copied from [contactById].
  const ContactByIdFamily();

  /// Provider to get a specific contact by ID
  ///
  /// Copied from [contactById].
  ContactByIdProvider call(
    String contactId,
  ) {
    return ContactByIdProvider(
      contactId,
    );
  }

  @override
  ContactByIdProvider getProviderOverride(
    covariant ContactByIdProvider provider,
  ) {
    return call(
      provider.contactId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'contactByIdProvider';
}

/// Provider to get a specific contact by ID
///
/// Copied from [contactById].
class ContactByIdProvider extends AutoDisposeProvider<EmergencyContact?> {
  /// Provider to get a specific contact by ID
  ///
  /// Copied from [contactById].
  ContactByIdProvider(
    String contactId,
  ) : this._internal(
          (ref) => contactById(
            ref as ContactByIdRef,
            contactId,
          ),
          from: contactByIdProvider,
          name: r'contactByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$contactByIdHash,
          dependencies: ContactByIdFamily._dependencies,
          allTransitiveDependencies:
              ContactByIdFamily._allTransitiveDependencies,
          contactId: contactId,
        );

  ContactByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contactId,
  }) : super.internal();

  final String contactId;

  @override
  Override overrideWith(
    EmergencyContact? Function(ContactByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContactByIdProvider._internal(
        (ref) => create(ref as ContactByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contactId: contactId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<EmergencyContact?> createElement() {
    return _ContactByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactByIdProvider && other.contactId == contactId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contactId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContactByIdRef on AutoDisposeProviderRef<EmergencyContact?> {
  /// The parameter `contactId` of this provider.
  String get contactId;
}

class _ContactByIdProviderElement
    extends AutoDisposeProviderElement<EmergencyContact?> with ContactByIdRef {
  _ContactByIdProviderElement(super.provider);

  @override
  String get contactId => (origin as ContactByIdProvider).contactId;
}

String _$contactsNotifierHash() => r'0afad5657c9f8a80b1ac33a23b2a54b5c0e65ed0';

/// Contacts notifier for managing emergency contacts
///
/// Copied from [ContactsNotifier].
@ProviderFor(ContactsNotifier)
final contactsNotifierProvider =
    AutoDisposeNotifierProvider<ContactsNotifier, ContactsState>.internal(
  ContactsNotifier.new,
  name: r'contactsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contactsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ContactsNotifier = AutoDisposeNotifier<ContactsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
