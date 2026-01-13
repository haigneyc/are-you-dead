import 'package:flutter_test/flutter_test.dart';

import 'package:are_you_dead/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('returns null for valid email', () {
        expect(Validators.validateEmail('test@example.com'), isNull);
        expect(Validators.validateEmail('user.name@domain.co'), isNull);
        expect(Validators.validateEmail('user+tag@example.org'), isNull);
      });

      test('returns error for empty input', () {
        expect(Validators.validateEmail(''), equals('Email is required'));
        expect(Validators.validateEmail(null), equals('Email is required'));
      });

      test('returns error for invalid format (no @)', () {
        expect(
          Validators.validateEmail('invalidemail'),
          equals('Please enter a valid email address'),
        );
      });

      test('returns error for invalid format (no domain)', () {
        expect(
          Validators.validateEmail('missing@'),
          equals('Please enter a valid email address'),
        );
        expect(
          Validators.validateEmail('@nodomain.com'),
          equals('Please enter a valid email address'),
        );
      });

      test('returns error for invalid format (incomplete domain)', () {
        expect(
          Validators.validateEmail('test@domain'),
          equals('Please enter a valid email address'),
        );
      });
    });

    group('validatePassword', () {
      test('returns null for valid password (8+ chars)', () {
        expect(Validators.validatePassword('password123'), isNull);
        expect(Validators.validatePassword('securePass!'), isNull);
        expect(Validators.validatePassword('12345678'), isNull);
        expect(Validators.validatePassword('aB3\$efgh'), isNull);
      });

      test('returns error for empty input', () {
        expect(
          Validators.validatePassword(''),
          equals('Password is required'),
        );
        expect(
          Validators.validatePassword(null),
          equals('Password is required'),
        );
      });

      test('returns error for short password (<8 chars)', () {
        expect(
          Validators.validatePassword('short'),
          equals('Password must be at least 8 characters'),
        );
        expect(
          Validators.validatePassword('1234567'),
          equals('Password must be at least 8 characters'),
        );
        expect(
          Validators.validatePassword('abc'),
          equals('Password must be at least 8 characters'),
        );
      });
    });

    group('validatePasswordConfirm', () {
      test('returns null when passwords match', () {
        expect(
          Validators.validatePasswordConfirm('password123', 'password123'),
          isNull,
        );
        expect(
          Validators.validatePasswordConfirm('mySecret!', 'mySecret!'),
          isNull,
        );
      });

      test('returns error for empty input', () {
        expect(
          Validators.validatePasswordConfirm('', 'password123'),
          equals('Please confirm your password'),
        );
        expect(
          Validators.validatePasswordConfirm(null, 'password123'),
          equals('Please confirm your password'),
        );
      });

      test('returns error when passwords do not match', () {
        expect(
          Validators.validatePasswordConfirm('password123', 'password456'),
          equals('Passwords do not match'),
        );
        expect(
          Validators.validatePasswordConfirm('abc12345', 'ABC12345'),
          equals('Passwords do not match'),
        );
      });
    });

    group('validatePhone (optional)', () {
      test('returns null for valid phone', () {
        expect(Validators.validatePhone('+15551234567'), isNull);
        expect(Validators.validatePhone('5551234567'), isNull);
        expect(Validators.validatePhone('+447911123456'), isNull);
        expect(Validators.validatePhone('1234567890'), isNull);
      });

      test('returns null for empty input (optional field)', () {
        expect(Validators.validatePhone(''), isNull);
        expect(Validators.validatePhone(null), isNull);
      });

      test('returns error for invalid format', () {
        expect(
          Validators.validatePhone('123'),
          equals('Please enter a valid phone number'),
        );
        expect(
          Validators.validatePhone('abcdefghij'),
          equals('Please enter a valid phone number'),
        );
        expect(
          Validators.validatePhone('+1'),
          equals('Please enter a valid phone number'),
        );
      });

      test('handles formatting characters (spaces, dashes)', () {
        expect(Validators.validatePhone('+1 555 123 4567'), isNull);
        expect(Validators.validatePhone('555-123-4567'), isNull);
        expect(Validators.validatePhone('(555) 123-4567'), isNull);
      });
    });

    group('validatePhoneRequired', () {
      test('returns null for valid phone', () {
        expect(Validators.validatePhoneRequired('+15551234567'), isNull);
        expect(Validators.validatePhoneRequired('5551234567'), isNull);
      });

      test('returns error for empty input (required)', () {
        expect(
          Validators.validatePhoneRequired(''),
          equals('Phone number is required'),
        );
        expect(
          Validators.validatePhoneRequired(null),
          equals('Phone number is required'),
        );
      });

      test('returns error for invalid format', () {
        expect(
          Validators.validatePhoneRequired('123'),
          equals('Please enter a valid phone number'),
        );
        expect(
          Validators.validatePhoneRequired('abcdefghij'),
          equals('Please enter a valid phone number'),
        );
      });
    });

    group('validateName', () {
      test('returns null for valid name', () {
        expect(Validators.validateName('John Doe'), isNull);
        expect(Validators.validateName('A'), isNull);
        expect(Validators.validateName('Jane'), isNull);
      });

      test('returns error for empty input', () {
        expect(
          Validators.validateName(''),
          equals('Name is required'),
        );
        expect(
          Validators.validateName(null),
          equals('Name is required'),
        );
      });

      test('returns error for name >100 characters', () {
        final longName = 'A' * 101;
        expect(
          Validators.validateName(longName),
          equals('Name must be 100 characters or less'),
        );
      });

      test('accepts name with exactly 100 characters', () {
        final maxLengthName = 'A' * 100;
        expect(Validators.validateName(maxLengthName), isNull);
      });
    });
  });
}
