// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$checkInIntervalDaysHash() =>
    r'3c6db271680887db727a7fd166ce8fbad1888c23';

/// Helper provider to get check-in interval in days
///
/// Copied from [checkInIntervalDays].
@ProviderFor(checkInIntervalDays)
final checkInIntervalDaysProvider = AutoDisposeProvider<int>.internal(
  checkInIntervalDays,
  name: r'checkInIntervalDaysProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$checkInIntervalDaysHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CheckInIntervalDaysRef = AutoDisposeProviderRef<int>;
String _$notificationsEnabledHash() =>
    r'6253221c62572909971cb5af0ceae91b575cc971';

/// Helper provider to check if notifications are enabled
///
/// Copied from [notificationsEnabled].
@ProviderFor(notificationsEnabled)
final notificationsEnabledProvider = AutoDisposeProvider<bool>.internal(
  notificationsEnabled,
  name: r'notificationsEnabledProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationsEnabledHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationsEnabledRef = AutoDisposeProviderRef<bool>;
String _$userProfileNotifierHash() =>
    r'4e90133dd1c9208a645cead9689b25b0ff9a8728';

/// Notifier for user profile mutations
///
/// Copied from [UserProfileNotifier].
@ProviderFor(UserProfileNotifier)
final userProfileNotifierProvider =
    AutoDisposeNotifierProvider<UserProfileNotifier, UserProfileState>.internal(
  UserProfileNotifier.new,
  name: r'userProfileNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userProfileNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserProfileNotifier = AutoDisposeNotifier<UserProfileState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
