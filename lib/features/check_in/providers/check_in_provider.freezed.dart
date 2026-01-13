// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_in_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CheckInState {
  DateTime? get lastCheckIn => throw _privateConstructorUsedError;
  DateTime? get nextDue => throw _privateConstructorUsedError;
  int get intervalHours => throw _privateConstructorUsedError;
  bool get isShowingSuccess => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of CheckInState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CheckInStateCopyWith<CheckInState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckInStateCopyWith<$Res> {
  factory $CheckInStateCopyWith(
          CheckInState value, $Res Function(CheckInState) then) =
      _$CheckInStateCopyWithImpl<$Res, CheckInState>;
  @useResult
  $Res call(
      {DateTime? lastCheckIn,
      DateTime? nextDue,
      int intervalHours,
      bool isShowingSuccess,
      bool isLoading,
      String? error});
}

/// @nodoc
class _$CheckInStateCopyWithImpl<$Res, $Val extends CheckInState>
    implements $CheckInStateCopyWith<$Res> {
  _$CheckInStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CheckInState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lastCheckIn = freezed,
    Object? nextDue = freezed,
    Object? intervalHours = null,
    Object? isShowingSuccess = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      lastCheckIn: freezed == lastCheckIn
          ? _value.lastCheckIn
          : lastCheckIn // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextDue: freezed == nextDue
          ? _value.nextDue
          : nextDue // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      intervalHours: null == intervalHours
          ? _value.intervalHours
          : intervalHours // ignore: cast_nullable_to_non_nullable
              as int,
      isShowingSuccess: null == isShowingSuccess
          ? _value.isShowingSuccess
          : isShowingSuccess // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CheckInStateImplCopyWith<$Res>
    implements $CheckInStateCopyWith<$Res> {
  factory _$$CheckInStateImplCopyWith(
          _$CheckInStateImpl value, $Res Function(_$CheckInStateImpl) then) =
      __$$CheckInStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime? lastCheckIn,
      DateTime? nextDue,
      int intervalHours,
      bool isShowingSuccess,
      bool isLoading,
      String? error});
}

/// @nodoc
class __$$CheckInStateImplCopyWithImpl<$Res>
    extends _$CheckInStateCopyWithImpl<$Res, _$CheckInStateImpl>
    implements _$$CheckInStateImplCopyWith<$Res> {
  __$$CheckInStateImplCopyWithImpl(
      _$CheckInStateImpl _value, $Res Function(_$CheckInStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of CheckInState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lastCheckIn = freezed,
    Object? nextDue = freezed,
    Object? intervalHours = null,
    Object? isShowingSuccess = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$CheckInStateImpl(
      lastCheckIn: freezed == lastCheckIn
          ? _value.lastCheckIn
          : lastCheckIn // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextDue: freezed == nextDue
          ? _value.nextDue
          : nextDue // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      intervalHours: null == intervalHours
          ? _value.intervalHours
          : intervalHours // ignore: cast_nullable_to_non_nullable
              as int,
      isShowingSuccess: null == isShowingSuccess
          ? _value.isShowingSuccess
          : isShowingSuccess // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$CheckInStateImpl implements _CheckInState {
  const _$CheckInStateImpl(
      {required this.lastCheckIn,
      required this.nextDue,
      required this.intervalHours,
      this.isShowingSuccess = false,
      this.isLoading = false,
      this.error});

  @override
  final DateTime? lastCheckIn;
  @override
  final DateTime? nextDue;
  @override
  final int intervalHours;
  @override
  @JsonKey()
  final bool isShowingSuccess;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'CheckInState(lastCheckIn: $lastCheckIn, nextDue: $nextDue, intervalHours: $intervalHours, isShowingSuccess: $isShowingSuccess, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckInStateImpl &&
            (identical(other.lastCheckIn, lastCheckIn) ||
                other.lastCheckIn == lastCheckIn) &&
            (identical(other.nextDue, nextDue) || other.nextDue == nextDue) &&
            (identical(other.intervalHours, intervalHours) ||
                other.intervalHours == intervalHours) &&
            (identical(other.isShowingSuccess, isShowingSuccess) ||
                other.isShowingSuccess == isShowingSuccess) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, lastCheckIn, nextDue,
      intervalHours, isShowingSuccess, isLoading, error);

  /// Create a copy of CheckInState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckInStateImplCopyWith<_$CheckInStateImpl> get copyWith =>
      __$$CheckInStateImplCopyWithImpl<_$CheckInStateImpl>(this, _$identity);
}

abstract class _CheckInState implements CheckInState {
  const factory _CheckInState(
      {required final DateTime? lastCheckIn,
      required final DateTime? nextDue,
      required final int intervalHours,
      final bool isShowingSuccess,
      final bool isLoading,
      final String? error}) = _$CheckInStateImpl;

  @override
  DateTime? get lastCheckIn;
  @override
  DateTime? get nextDue;
  @override
  int get intervalHours;
  @override
  bool get isShowingSuccess;
  @override
  bool get isLoading;
  @override
  String? get error;

  /// Create a copy of CheckInState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CheckInStateImplCopyWith<_$CheckInStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
