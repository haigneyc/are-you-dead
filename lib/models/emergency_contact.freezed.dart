// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'emergency_contact.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EmergencyContact _$EmergencyContactFromJson(Map<String, dynamic> json) {
  return _EmergencyContact.fromJson(json);
}

/// @nodoc
mixin _$EmergencyContact {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  int get priority => throw _privateConstructorUsedError;
  bool get notifyOnAdd => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this EmergencyContact to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EmergencyContact
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EmergencyContactCopyWith<EmergencyContact> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmergencyContactCopyWith<$Res> {
  factory $EmergencyContactCopyWith(
          EmergencyContact value, $Res Function(EmergencyContact) then) =
      _$EmergencyContactCopyWithImpl<$Res, EmergencyContact>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String phone,
      String? email,
      int priority,
      bool notifyOnAdd,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$EmergencyContactCopyWithImpl<$Res, $Val extends EmergencyContact>
    implements $EmergencyContactCopyWith<$Res> {
  _$EmergencyContactCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EmergencyContact
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? phone = null,
    Object? email = freezed,
    Object? priority = null,
    Object? notifyOnAdd = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      notifyOnAdd: null == notifyOnAdd
          ? _value.notifyOnAdd
          : notifyOnAdd // ignore: cast_nullable_to_non_nullable
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
abstract class _$$EmergencyContactImplCopyWith<$Res>
    implements $EmergencyContactCopyWith<$Res> {
  factory _$$EmergencyContactImplCopyWith(_$EmergencyContactImpl value,
          $Res Function(_$EmergencyContactImpl) then) =
      __$$EmergencyContactImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String phone,
      String? email,
      int priority,
      bool notifyOnAdd,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$EmergencyContactImplCopyWithImpl<$Res>
    extends _$EmergencyContactCopyWithImpl<$Res, _$EmergencyContactImpl>
    implements _$$EmergencyContactImplCopyWith<$Res> {
  __$$EmergencyContactImplCopyWithImpl(_$EmergencyContactImpl _value,
      $Res Function(_$EmergencyContactImpl) _then)
      : super(_value, _then);

  /// Create a copy of EmergencyContact
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? phone = null,
    Object? email = freezed,
    Object? priority = null,
    Object? notifyOnAdd = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$EmergencyContactImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      notifyOnAdd: null == notifyOnAdd
          ? _value.notifyOnAdd
          : notifyOnAdd // ignore: cast_nullable_to_non_nullable
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
class _$EmergencyContactImpl implements _EmergencyContact {
  const _$EmergencyContactImpl(
      {required this.id,
      required this.userId,
      required this.name,
      required this.phone,
      this.email,
      this.priority = 1,
      this.notifyOnAdd = false,
      this.createdAt,
      this.updatedAt});

  factory _$EmergencyContactImpl.fromJson(Map<String, dynamic> json) =>
      _$$EmergencyContactImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  final String phone;
  @override
  final String? email;
  @override
  @JsonKey()
  final int priority;
  @override
  @JsonKey()
  final bool notifyOnAdd;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'EmergencyContact(id: $id, userId: $userId, name: $name, phone: $phone, email: $email, priority: $priority, notifyOnAdd: $notifyOnAdd, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmergencyContactImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.notifyOnAdd, notifyOnAdd) ||
                other.notifyOnAdd == notifyOnAdd) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, name, phone, email,
      priority, notifyOnAdd, createdAt, updatedAt);

  /// Create a copy of EmergencyContact
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmergencyContactImplCopyWith<_$EmergencyContactImpl> get copyWith =>
      __$$EmergencyContactImplCopyWithImpl<_$EmergencyContactImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EmergencyContactImplToJson(
      this,
    );
  }
}

abstract class _EmergencyContact implements EmergencyContact {
  const factory _EmergencyContact(
      {required final String id,
      required final String userId,
      required final String name,
      required final String phone,
      final String? email,
      final int priority,
      final bool notifyOnAdd,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$EmergencyContactImpl;

  factory _EmergencyContact.fromJson(Map<String, dynamic> json) =
      _$EmergencyContactImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get name;
  @override
  String get phone;
  @override
  String? get email;
  @override
  int get priority;
  @override
  bool get notifyOnAdd;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of EmergencyContact
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmergencyContactImplCopyWith<_$EmergencyContactImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
