import 'package:flutter_test/flutter_test.dart';

import 'package:are_you_dead/models/check_in.dart';

void main() {
  group('CheckIn', () {
    group('fromJson', () {
      test('parses timestamps correctly', () {
        final json = {
          'id': 'checkin-123',
          'user_id': 'user-456',
          'checked_in_at': '2026-01-12T14:30:00.000Z',
          'was_on_time': true,
        };

        final checkIn = CheckIn.fromJson(json);

        expect(checkIn.id, equals('checkin-123'));
        expect(checkIn.userId, equals('user-456'));
        expect(checkIn.checkedInAt, isNotNull);
        expect(checkIn.checkedInAt.year, equals(2026));
        expect(checkIn.checkedInAt.month, equals(1));
        expect(checkIn.checkedInAt.day, equals(12));
        expect(checkIn.checkedInAt.hour, equals(14));
        expect(checkIn.checkedInAt.minute, equals(30));
      });

      test('handles all fields', () {
        final json = {
          'id': 'checkin-full',
          'user_id': 'user-full',
          'checked_in_at': '2026-01-10T08:00:00.000Z',
          'was_on_time': false,
          'device_info': {
            'platform': 'android',
            'version': '14',
            'model': 'Pixel 8',
          },
        };

        final checkIn = CheckIn.fromJson(json);

        expect(checkIn.id, equals('checkin-full'));
        expect(checkIn.userId, equals('user-full'));
        expect(checkIn.wasOnTime, isFalse);
        expect(checkIn.deviceInfo, isNotNull);
        expect(checkIn.deviceInfo!['platform'], equals('android'));
        expect(checkIn.deviceInfo!['version'], equals('14'));
        expect(checkIn.deviceInfo!['model'], equals('Pixel 8'));
      });

      test('applies default values (wasOnTime: true)', () {
        final json = {
          'id': 'checkin-defaults',
          'user_id': 'user-defaults',
          'checked_in_at': '2026-01-11T12:00:00.000Z',
        };

        final checkIn = CheckIn.fromJson(json);

        expect(checkIn.wasOnTime, isTrue);
        expect(checkIn.deviceInfo, isNull);
      });

      test('handles null device_info', () {
        final json = {
          'id': 'checkin-null-device',
          'user_id': 'user-null',
          'checked_in_at': '2026-01-12T16:00:00.000Z',
          'device_info': null,
        };

        final checkIn = CheckIn.fromJson(json);

        expect(checkIn.deviceInfo, isNull);
      });
    });

    group('toJson', () {
      test('serializes correctly', () {
        final checkIn = CheckIn(
          id: 'checkin-serialize',
          userId: 'user-serialize',
          checkedInAt: DateTime.utc(2026, 1, 12, 10, 30),
          wasOnTime: true,
          deviceInfo: {'platform': 'ios', 'version': '17'},
        );

        final json = checkIn.toJson();

        expect(json['id'], equals('checkin-serialize'));
        expect(json['user_id'], equals('user-serialize'));
        expect(json['was_on_time'], isTrue);
        expect(json['device_info'], isNotNull);
        expect(json['device_info']['platform'], equals('ios'));
      });

      test('roundtrip preserves data', () {
        final original = CheckIn(
          id: 'checkin-roundtrip',
          userId: 'user-roundtrip',
          checkedInAt: DateTime.utc(2026, 1, 13, 9, 15),
          wasOnTime: false,
          deviceInfo: {'app_version': '1.0.0'},
        );

        final json = original.toJson();
        final restored = CheckIn.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.userId, equals(original.userId));
        expect(restored.wasOnTime, equals(original.wasOnTime));
        expect(restored.deviceInfo, equals(original.deviceInfo));
      });
    });

    group('copyWith', () {
      test('creates new instance with updated fields', () {
        final original = CheckIn(
          id: 'checkin-copy',
          userId: 'user-copy',
          checkedInAt: DateTime.utc(2026, 1, 10),
          wasOnTime: true,
        );

        final updated = original.copyWith(wasOnTime: false);

        expect(updated.wasOnTime, isFalse);
        expect(updated.id, equals(original.id));
        expect(updated.userId, equals(original.userId));
        expect(identical(original, updated), isFalse);
      });

      test('can update deviceInfo', () {
        final original = CheckIn(
          id: 'checkin-device',
          userId: 'user-device',
          checkedInAt: DateTime.utc(2026, 1, 11),
        );

        final updated = original.copyWith(
          deviceInfo: {'new_field': 'new_value'},
        );

        expect(updated.deviceInfo, isNotNull);
        expect(updated.deviceInfo!['new_field'], equals('new_value'));
        expect(original.deviceInfo, isNull);
      });
    });
  });
}
