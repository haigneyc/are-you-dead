// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contacts_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ContactsState {
  List<EmergencyContact> get contacts => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of ContactsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ContactsStateCopyWith<ContactsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContactsStateCopyWith<$Res> {
  factory $ContactsStateCopyWith(
          ContactsState value, $Res Function(ContactsState) then) =
      _$ContactsStateCopyWithImpl<$Res, ContactsState>;
  @useResult
  $Res call({List<EmergencyContact> contacts, bool isLoading, String? error});
}

/// @nodoc
class _$ContactsStateCopyWithImpl<$Res, $Val extends ContactsState>
    implements $ContactsStateCopyWith<$Res> {
  _$ContactsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ContactsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contacts = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      contacts: null == contacts
          ? _value.contacts
          : contacts // ignore: cast_nullable_to_non_nullable
              as List<EmergencyContact>,
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
abstract class _$$ContactsStateImplCopyWith<$Res>
    implements $ContactsStateCopyWith<$Res> {
  factory _$$ContactsStateImplCopyWith(
          _$ContactsStateImpl value, $Res Function(_$ContactsStateImpl) then) =
      __$$ContactsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<EmergencyContact> contacts, bool isLoading, String? error});
}

/// @nodoc
class __$$ContactsStateImplCopyWithImpl<$Res>
    extends _$ContactsStateCopyWithImpl<$Res, _$ContactsStateImpl>
    implements _$$ContactsStateImplCopyWith<$Res> {
  __$$ContactsStateImplCopyWithImpl(
      _$ContactsStateImpl _value, $Res Function(_$ContactsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ContactsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? contacts = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$ContactsStateImpl(
      contacts: null == contacts
          ? _value._contacts
          : contacts // ignore: cast_nullable_to_non_nullable
              as List<EmergencyContact>,
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

class _$ContactsStateImpl implements _ContactsState {
  const _$ContactsStateImpl(
      {final List<EmergencyContact> contacts = const [],
      this.isLoading = false,
      this.error})
      : _contacts = contacts;

  final List<EmergencyContact> _contacts;
  @override
  @JsonKey()
  List<EmergencyContact> get contacts {
    if (_contacts is EqualUnmodifiableListView) return _contacts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_contacts);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'ContactsState(contacts: $contacts, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContactsStateImpl &&
            const DeepCollectionEquality().equals(other._contacts, _contacts) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_contacts), isLoading, error);

  /// Create a copy of ContactsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContactsStateImplCopyWith<_$ContactsStateImpl> get copyWith =>
      __$$ContactsStateImplCopyWithImpl<_$ContactsStateImpl>(this, _$identity);
}

abstract class _ContactsState implements ContactsState {
  const factory _ContactsState(
      {final List<EmergencyContact> contacts,
      final bool isLoading,
      final String? error}) = _$ContactsStateImpl;

  @override
  List<EmergencyContact> get contacts;
  @override
  bool get isLoading;
  @override
  String? get error;

  /// Create a copy of ContactsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContactsStateImplCopyWith<_$ContactsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
