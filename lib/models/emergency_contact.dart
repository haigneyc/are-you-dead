import 'package:freezed_annotation/freezed_annotation.dart';

part 'emergency_contact.freezed.dart';
part 'emergency_contact.g.dart';

/// Emergency contact model matching the database schema
@Freezed(fromJson: true, toJson: true)
class EmergencyContact with _$EmergencyContact {
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory EmergencyContact({
    required String id,
    required String userId,
    required String name,
    required String phone,
    String? email,
    @Default(1) int priority,
    @Default(false) bool notifyOnAdd,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _EmergencyContact;

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      _$EmergencyContactFromJson(json);
}
