// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppUser _$AppUserFromJson(Map<String, dynamic> json) {
  return _AppUser.fromJson(json);
}

/// @nodoc
mixin _$AppUser {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  int get checkInIntervalHours => throw _privateConstructorUsedError;
  DateTime? get lastCheckInAt => throw _privateConstructorUsedError;
  DateTime? get nextCheckInDue => throw _privateConstructorUsedError;
  String get timezone => throw _privateConstructorUsedError;
  String? get fcmToken => throw _privateConstructorUsedError;
  bool get locationEnabled => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppUserCopyWith<AppUser> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppUserCopyWith<$Res> {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) then) =
      _$AppUserCopyWithImpl<$Res, AppUser>;
  @useResult
  $Res call(
      {String id,
      String email,
      String? phone,
      String? displayName,
      int checkInIntervalHours,
      DateTime? lastCheckInAt,
      DateTime? nextCheckInDue,
      String timezone,
      String? fcmToken,
      bool locationEnabled,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$AppUserCopyWithImpl<$Res, $Val extends AppUser>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? phone = freezed,
    Object? displayName = freezed,
    Object? checkInIntervalHours = null,
    Object? lastCheckInAt = freezed,
    Object? nextCheckInDue = freezed,
    Object? timezone = null,
    Object? fcmToken = freezed,
    Object? locationEnabled = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      checkInIntervalHours: null == checkInIntervalHours
          ? _value.checkInIntervalHours
          : checkInIntervalHours // ignore: cast_nullable_to_non_nullable
              as int,
      lastCheckInAt: freezed == lastCheckInAt
          ? _value.lastCheckInAt
          : lastCheckInAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextCheckInDue: freezed == nextCheckInDue
          ? _value.nextCheckInDue
          : nextCheckInDue // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      timezone: null == timezone
          ? _value.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String,
      fcmToken: freezed == fcmToken
          ? _value.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String?,
      locationEnabled: null == locationEnabled
          ? _value.locationEnabled
          : locationEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppUserImplCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$$AppUserImplCopyWith(
          _$AppUserImpl value, $Res Function(_$AppUserImpl) then) =
      __$$AppUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String email,
      String? phone,
      String? displayName,
      int checkInIntervalHours,
      DateTime? lastCheckInAt,
      DateTime? nextCheckInDue,
      String timezone,
      String? fcmToken,
      bool locationEnabled,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$AppUserImplCopyWithImpl<$Res>
    extends _$AppUserCopyWithImpl<$Res, _$AppUserImpl>
    implements _$$AppUserImplCopyWith<$Res> {
  __$$AppUserImplCopyWithImpl(
      _$AppUserImpl _value, $Res Function(_$AppUserImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? phone = freezed,
    Object? displayName = freezed,
    Object? checkInIntervalHours = null,
    Object? lastCheckInAt = freezed,
    Object? nextCheckInDue = freezed,
    Object? timezone = null,
    Object? fcmToken = freezed,
    Object? locationEnabled = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$AppUserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      checkInIntervalHours: null == checkInIntervalHours
          ? _value.checkInIntervalHours
          : checkInIntervalHours // ignore: cast_nullable_to_non_nullable
              as int,
      lastCheckInAt: freezed == lastCheckInAt
          ? _value.lastCheckInAt
          : lastCheckInAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextCheckInDue: freezed == nextCheckInDue
          ? _value.nextCheckInDue
          : nextCheckInDue // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      timezone: null == timezone
          ? _value.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String,
      fcmToken: freezed == fcmToken
          ? _value.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String?,
      locationEnabled: null == locationEnabled
          ? _value.locationEnabled
          : locationEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$AppUserImpl implements _AppUser {
  const _$AppUserImpl(
      {required this.id,
      required this.email,
      this.phone,
      this.displayName,
      this.checkInIntervalHours = 48,
      this.lastCheckInAt,
      this.nextCheckInDue,
      this.timezone = 'UTC',
      this.fcmToken,
      this.locationEnabled = false,
      this.createdAt,
      this.updatedAt});

  factory _$AppUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppUserImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String? phone;
  @override
  final String? displayName;
  @override
  @JsonKey()
  final int checkInIntervalHours;
  @override
  final DateTime? lastCheckInAt;
  @override
  final DateTime? nextCheckInDue;
  @override
  @JsonKey()
  final String timezone;
  @override
  final String? fcmToken;
  @override
  @JsonKey()
  final bool locationEnabled;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'AppUser(id: $id, email: $email, phone: $phone, displayName: $displayName, checkInIntervalHours: $checkInIntervalHours, lastCheckInAt: $lastCheckInAt, nextCheckInDue: $nextCheckInDue, timezone: $timezone, fcmToken: $fcmToken, locationEnabled: $locationEnabled, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.checkInIntervalHours, checkInIntervalHours) ||
                other.checkInIntervalHours == checkInIntervalHours) &&
            (identical(other.lastCheckInAt, lastCheckInAt) ||
                other.lastCheckInAt == lastCheckInAt) &&
            (identical(other.nextCheckInDue, nextCheckInDue) ||
                other.nextCheckInDue == nextCheckInDue) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.fcmToken, fcmToken) ||
                other.fcmToken == fcmToken) &&
            (identical(other.locationEnabled, locationEnabled) ||
                other.locationEnabled == locationEnabled) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      email,
      phone,
      displayName,
      checkInIntervalHours,
      lastCheckInAt,
      nextCheckInDue,
      timezone,
      fcmToken,
      locationEnabled,
      createdAt,
      updatedAt);

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppUserImplCopyWith<_$AppUserImpl> get copyWith =>
      __$$AppUserImplCopyWithImpl<_$AppUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppUserImplToJson(
      this,
    );
  }
}

abstract class _AppUser implements AppUser {
  const factory _AppUser(
      {required final String id,
      required final String email,
      final String? phone,
      final String? displayName,
      final int checkInIntervalHours,
      final DateTime? lastCheckInAt,
      final DateTime? nextCheckInDue,
      final String timezone,
      final String? fcmToken,
      final bool locationEnabled,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$AppUserImpl;

  factory _AppUser.fromJson(Map<String, dynamic> json) = _$AppUserImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String? get phone;
  @override
  String? get displayName;
  @override
  int get checkInIntervalHours;
  @override
  DateTime? get lastCheckInAt;
  @override
  DateTime? get nextCheckInDue;
  @override
  String get timezone;
  @override
  String? get fcmToken;
  @override
  bool get locationEnabled;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppUserImplCopyWith<_$AppUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
