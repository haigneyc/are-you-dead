import 'package:freezed_annotation/freezed_annotation.dart';

part 'check_in.freezed.dart';
part 'check_in.g.dart';

/// Check-in record model matching the database schema
@Freezed(fromJson: true, toJson: true)
class CheckIn with _$CheckIn {
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CheckIn({
    required String id,
    required String userId,
    required DateTime checkedInAt,
    @Default(true) bool wasOnTime,
    Map<String, dynamic>? deviceInfo,
  }) = _CheckIn;

  factory CheckIn.fromJson(Map<String, dynamic> json) => _$CheckInFromJson(json);
}
