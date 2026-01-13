// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$timeRemainingHash() => r'e10815d41f8be43e6d9df4d71c8fab18e7488a19';

/// Provider for the time remaining until next check-in
///
/// Copied from [timeRemaining].
@ProviderFor(timeRemaining)
final timeRemainingProvider = AutoDisposeProvider<Duration?>.internal(
  timeRemaining,
  name: r'timeRemainingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$timeRemainingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TimeRemainingRef = AutoDisposeProviderRef<Duration?>;
String _$isOverdueHash() => r'0a22ffd529b1c5ba6b8eaa01fa8d528be3fff720';

/// Provider to check if user is overdue
///
/// Copied from [isOverdue].
@ProviderFor(isOverdue)
final isOverdueProvider = AutoDisposeProvider<bool>.internal(
  isOverdue,
  name: r'isOverdueProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isOverdueHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsOverdueRef = AutoDisposeProviderRef<bool>;
String _$checkInNotifierHash() => r'7496a746fb25ee23984973f3c6e4da3bc961790a';

/// Check-in notifier for managing check-in state and actions
///
/// Copied from [CheckInNotifier].
@ProviderFor(CheckInNotifier)
final checkInNotifierProvider =
    AutoDisposeNotifierProvider<CheckInNotifier, CheckInState>.internal(
  CheckInNotifier.new,
  name: r'checkInNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$checkInNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CheckInNotifier = AutoDisposeNotifier<CheckInState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
