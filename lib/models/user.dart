import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// User model matching the database schema
@Freezed(fromJson: true, toJson: true)
class AppUser with _$AppUser {
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory AppUser({
    required String id,
    required String email,
    String? phone,
    String? displayName,
    @Default(48) int checkInIntervalHours,
    DateTime? lastCheckInAt,
    DateTime? nextCheckInDue,
    @Default('UTC') String timezone,
    String? fcmToken,
    @Default(false) bool locationEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
}
