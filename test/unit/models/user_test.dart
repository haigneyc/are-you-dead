import 'package:flutter_test/flutter_test.dart';

import 'package:are_you_dead/models/user.dart';

void main() {
  group('AppUser', () {
    group('fromJson', () {
      test('parses complete JSON correctly', () {
        final json = {
          'id': 'user-123',
          'email': 'test@example.com',
          'phone': '+15551234567',
          'display_name': 'Test User',
          'check_in_interval_hours': 72,
          'last_check_in_at': '2026-01-12T10:00:00.000Z',
          'next_check_in_due': '2026-01-15T10:00:00.000Z',
          'timezone': 'America/New_York',
          'fcm_token': 'fake-token-123',
          'location_enabled': true,
          'created_at': '2026-01-01T00:00:00.000Z',
          'updated_at': '2026-01-12T10:00:00.000Z',
        };

        final user = AppUser.fromJson(json);

        expect(user.id, equals('user-123'));
        expect(user.email, equals('test@example.com'));
        expect(user.phone, equals('+15551234567'));
        expect(user.displayName, equals('Test User'));
        expect(user.checkInIntervalHours, equals(72));
        expect(user.lastCheckInAt, isNotNull);
        expect(user.nextCheckInDue, isNotNull);
        expect(user.timezone, equals('America/New_York'));
        expect(user.fcmToken, equals('fake-token-123'));
        expect(user.locationEnabled, isTrue);
        expect(user.createdAt, isNotNull);
        expect(user.updatedAt, isNotNull);
      });

      test('handles missing optional fields', () {
        final json = {
          'id': 'user-456',
          'email': 'minimal@example.com',
        };

        final user = AppUser.fromJson(json);

        expect(user.id, equals('user-456'));
        expect(user.email, equals('minimal@example.com'));
        expect(user.phone, isNull);
        expect(user.displayName, isNull);
        expect(user.lastCheckInAt, isNull);
        expect(user.nextCheckInDue, isNull);
        expect(user.fcmToken, isNull);
        expect(user.createdAt, isNull);
        expect(user.updatedAt, isNull);
      });

      test('applies default values (checkInIntervalHours: 48, timezone: UTC)', () {
        final json = {
          'id': 'user-789',
          'email': 'defaults@example.com',
        };

        final user = AppUser.fromJson(json);

        expect(user.checkInIntervalHours, equals(48));
        expect(user.timezone, equals('UTC'));
        expect(user.locationEnabled, isFalse);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final user = AppUser(
          id: 'user-123',
          email: 'test@example.com',
          phone: '+15551234567',
          displayName: 'Test User',
          checkInIntervalHours: 72,
          lastCheckInAt: DateTime.utc(2026, 1, 12, 10, 0),
          nextCheckInDue: DateTime.utc(2026, 1, 15, 10, 0),
          timezone: 'America/New_York',
          fcmToken: 'fake-token',
          locationEnabled: true,
        );

        final json = user.toJson();

        expect(json['id'], equals('user-123'));
        expect(json['email'], equals('test@example.com'));
        expect(json['phone'], equals('+15551234567'));
        expect(json['display_name'], equals('Test User'));
        expect(json['check_in_interval_hours'], equals(72));
        expect(json['timezone'], equals('America/New_York'));
        expect(json['fcm_token'], equals('fake-token'));
        expect(json['location_enabled'], isTrue);
      });

      test('roundtrip (fromJson -> toJson -> fromJson) preserves data', () {
        final original = AppUser(
          id: 'user-roundtrip',
          email: 'roundtrip@example.com',
          phone: '+15559876543',
          displayName: 'Roundtrip User',
          checkInIntervalHours: 24,
          lastCheckInAt: DateTime.utc(2026, 1, 10),
          nextCheckInDue: DateTime.utc(2026, 1, 11),
          timezone: 'Europe/London',
          fcmToken: 'roundtrip-token',
          locationEnabled: false,
        );

        final json = original.toJson();
        final restored = AppUser.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.email, equals(original.email));
        expect(restored.phone, equals(original.phone));
        expect(restored.displayName, equals(original.displayName));
        expect(restored.checkInIntervalHours, equals(original.checkInIntervalHours));
        expect(restored.timezone, equals(original.timezone));
        expect(restored.fcmToken, equals(original.fcmToken));
        expect(restored.locationEnabled, equals(original.locationEnabled));
      });
    });

    group('copyWith', () {
      test('creates new instance with updated fields', () {
        final original = AppUser(
          id: 'user-copy',
          email: 'original@example.com',
          displayName: 'Original Name',
          checkInIntervalHours: 48,
        );

        final updated = original.copyWith(
          displayName: 'Updated Name',
          checkInIntervalHours: 72,
        );

        expect(updated.displayName, equals('Updated Name'));
        expect(updated.checkInIntervalHours, equals(72));
        // Verify it's a new instance
        expect(identical(original, updated), isFalse);
      });

      test('preserves unchanged fields', () {
        final original = AppUser(
          id: 'user-preserve',
          email: 'preserve@example.com',
          phone: '+15551111111',
          displayName: 'Preserve Me',
          checkInIntervalHours: 48,
          timezone: 'UTC',
        );

        final updated = original.copyWith(displayName: 'New Name');

        expect(updated.id, equals(original.id));
        expect(updated.email, equals(original.email));
        expect(updated.phone, equals(original.phone));
        expect(updated.checkInIntervalHours, equals(original.checkInIntervalHours));
        expect(updated.timezone, equals(original.timezone));
      });
    });
  });
}
