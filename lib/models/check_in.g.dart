// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CheckInImpl _$$CheckInImplFromJson(Map<String, dynamic> json) =>
    _$CheckInImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      checkedInAt: DateTime.parse(json['checked_in_at'] as String),
      wasOnTime: json['was_on_time'] as bool? ?? true,
      deviceInfo: json['device_info'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$CheckInImplToJson(_$CheckInImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'checked_in_at': instance.checkedInAt.toIso8601String(),
      'was_on_time': instance.wasOnTime,
      'device_info': instance.deviceInfo,
    };
