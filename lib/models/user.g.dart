// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) =>
    _$AppUserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      displayName: json['display_name'] as String?,
      checkInIntervalHours:
          (json['check_in_interval_hours'] as num?)?.toInt() ?? 48,
      lastCheckInAt: json['last_check_in_at'] == null
          ? null
          : DateTime.parse(json['last_check_in_at'] as String),
      nextCheckInDue: json['next_check_in_due'] == null
          ? null
          : DateTime.parse(json['next_check_in_due'] as String),
      timezone: json['timezone'] as String? ?? 'UTC',
      fcmToken: json['fcm_token'] as String?,
      locationEnabled: json['location_enabled'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'phone': instance.phone,
      'display_name': instance.displayName,
      'check_in_interval_hours': instance.checkInIntervalHours,
      'last_check_in_at': instance.lastCheckInAt?.toIso8601String(),
      'next_check_in_due': instance.nextCheckInDue?.toIso8601String(),
      'timezone': instance.timezone,
      'fcm_token': instance.fcmToken,
      'location_enabled': instance.locationEnabled,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
