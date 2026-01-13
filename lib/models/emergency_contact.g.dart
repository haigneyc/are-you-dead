// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emergency_contact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EmergencyContactImpl _$$EmergencyContactImplFromJson(
        Map<String, dynamic> json) =>
    _$EmergencyContactImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      priority: (json['priority'] as num?)?.toInt() ?? 1,
      notifyOnAdd: json['notify_on_add'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$EmergencyContactImplToJson(
        _$EmergencyContactImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'phone': instance.phone,
      'email': instance.email,
      'priority': instance.priority,
      'notify_on_add': instance.notifyOnAdd,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
