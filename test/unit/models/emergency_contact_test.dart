import 'package:flutter_test/flutter_test.dart';

import 'package:are_you_dead/models/emergency_contact.dart';

void main() {
  group('EmergencyContact', () {
    group('fromJson', () {
      test('parses complete JSON correctly', () {
        final json = {
          'id': 'contact-123',
          'user_id': 'user-456',
          'name': 'Jane Doe',
          'phone': '+15551234567',
          'email': 'jane@example.com',
          'priority': 2,
          'notify_on_add': true,
          'created_at': '2026-01-05T00:00:00.000Z',
          'updated_at': '2026-01-10T00:00:00.000Z',
        };

        final contact = EmergencyContact.fromJson(json);

        expect(contact.id, equals('contact-123'));
        expect(contact.userId, equals('user-456'));
        expect(contact.name, equals('Jane Doe'));
        expect(contact.phone, equals('+15551234567'));
        expect(contact.email, equals('jane@example.com'));
        expect(contact.priority, equals(2));
        expect(contact.notifyOnAdd, isTrue);
        expect(contact.createdAt, isNotNull);
        expect(contact.updatedAt, isNotNull);
      });

      test('handles null email', () {
        final json = {
          'id': 'contact-no-email',
          'user_id': 'user-789',
          'name': 'No Email Contact',
          'phone': '+15559876543',
          'email': null,
        };

        final contact = EmergencyContact.fromJson(json);

        expect(contact.email, isNull);
        expect(contact.name, equals('No Email Contact'));
        expect(contact.phone, equals('+15559876543'));
      });

      test('handles missing email field', () {
        final json = {
          'id': 'contact-missing-email',
          'user_id': 'user-abc',
          'name': 'Missing Email',
          'phone': '+15550001111',
        };

        final contact = EmergencyContact.fromJson(json);

        expect(contact.email, isNull);
      });

      test('applies default values (priority: 1, notifyOnAdd: false)', () {
        final json = {
          'id': 'contact-defaults',
          'user_id': 'user-def',
          'name': 'Default Contact',
          'phone': '+15552223333',
        };

        final contact = EmergencyContact.fromJson(json);

        expect(contact.priority, equals(1));
        expect(contact.notifyOnAdd, isFalse);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final contact = EmergencyContact(
          id: 'contact-serialize',
          userId: 'user-serialize',
          name: 'Serialized Contact',
          phone: '+15554445555',
          email: 'serialize@example.com',
          priority: 3,
          notifyOnAdd: true,
          createdAt: DateTime.utc(2026, 1, 5),
          updatedAt: DateTime.utc(2026, 1, 10),
        );

        final json = contact.toJson();

        expect(json['id'], equals('contact-serialize'));
        expect(json['user_id'], equals('user-serialize'));
        expect(json['name'], equals('Serialized Contact'));
        expect(json['phone'], equals('+15554445555'));
        expect(json['email'], equals('serialize@example.com'));
        expect(json['priority'], equals(3));
        expect(json['notify_on_add'], isTrue);
      });

      test('serializes null email correctly', () {
        final contact = EmergencyContact(
          id: 'contact-null-email',
          userId: 'user-null',
          name: 'Null Email',
          phone: '+15556667777',
          email: null,
        );

        final json = contact.toJson();

        expect(json['email'], isNull);
      });

      test('roundtrip preserves data', () {
        final original = EmergencyContact(
          id: 'contact-roundtrip',
          userId: 'user-roundtrip',
          name: 'Roundtrip Contact',
          phone: '+15558889999',
          email: 'roundtrip@example.com',
          priority: 2,
          notifyOnAdd: false,
        );

        final json = original.toJson();
        final restored = EmergencyContact.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.userId, equals(original.userId));
        expect(restored.name, equals(original.name));
        expect(restored.phone, equals(original.phone));
        expect(restored.email, equals(original.email));
        expect(restored.priority, equals(original.priority));
        expect(restored.notifyOnAdd, equals(original.notifyOnAdd));
      });
    });

    group('copyWith', () {
      test('works correctly for all fields', () {
        final original = EmergencyContact(
          id: 'contact-copy',
          userId: 'user-copy',
          name: 'Original Name',
          phone: '+15551112222',
          email: 'original@example.com',
          priority: 1,
          notifyOnAdd: false,
        );

        final updated = original.copyWith(
          name: 'Updated Name',
          phone: '+15553334444',
          email: 'updated@example.com',
          priority: 2,
          notifyOnAdd: true,
        );

        expect(updated.name, equals('Updated Name'));
        expect(updated.phone, equals('+15553334444'));
        expect(updated.email, equals('updated@example.com'));
        expect(updated.priority, equals(2));
        expect(updated.notifyOnAdd, isTrue);
        // ID and userId should remain unchanged
        expect(updated.id, equals(original.id));
        expect(updated.userId, equals(original.userId));
      });

      test('preserves unchanged fields', () {
        final original = EmergencyContact(
          id: 'contact-preserve',
          userId: 'user-preserve',
          name: 'Preserve Name',
          phone: '+15555556666',
          email: 'preserve@example.com',
          priority: 1,
        );

        final updated = original.copyWith(priority: 3);

        expect(updated.name, equals(original.name));
        expect(updated.phone, equals(original.phone));
        expect(updated.email, equals(original.email));
        expect(updated.priority, equals(3));
      });
    });
  });
}
