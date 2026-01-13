import 'package:are_you_dead/models/emergency_contact.dart';
import 'package:are_you_dead/models/user.dart';

/// Test fixtures containing sample data for tests.
class TestFixtures {
  TestFixtures._();

  /// Sample user profile
  static AppUser get sampleUser => AppUser(
        id: 'test-user-id',
        email: 'test@example.com',
        displayName: 'Test User',
        phone: '+15551234567',
        checkInIntervalHours: 48,
        lastCheckInAt: DateTime(2026, 1, 12, 10, 0),
        nextCheckInDue: DateTime(2026, 1, 14, 10, 0),
        timezone: 'America/Los_Angeles',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 12),
      );

  /// User who is overdue for check-in
  static AppUser get overdueUser => AppUser(
        id: 'overdue-user-id',
        email: 'overdue@example.com',
        displayName: 'Overdue User',
        checkInIntervalHours: 24,
        lastCheckInAt: DateTime.now().subtract(const Duration(hours: 48)),
        nextCheckInDue: DateTime.now().subtract(const Duration(hours: 24)),
      );

  /// User with notifications disabled
  static AppUser get userWithoutFCM => AppUser(
        id: 'no-fcm-user-id',
        email: 'nofcm@example.com',
        displayName: 'No FCM User',
        checkInIntervalHours: 48,
        fcmToken: null,
      );

  /// User with notifications enabled
  static AppUser get userWithFCM => sampleUser.copyWith(
        fcmToken: 'fake-fcm-token-12345',
      );

  /// Sample emergency contact
  static EmergencyContact get sampleContact => EmergencyContact(
        id: 'contact-1',
        userId: 'test-user-id',
        name: 'Jane Doe',
        phone: '+15559876543',
        email: 'jane@example.com',
        priority: 1,
        createdAt: DateTime(2026, 1, 5),
        updatedAt: DateTime(2026, 1, 5),
      );

  /// Second sample contact
  static EmergencyContact get sampleContact2 => EmergencyContact(
        id: 'contact-2',
        userId: 'test-user-id',
        name: 'John Smith',
        phone: '+15551112222',
        email: 'john@example.com',
        priority: 2,
        createdAt: DateTime(2026, 1, 6),
        updatedAt: DateTime(2026, 1, 6),
      );

  /// Contact without email
  static EmergencyContact get contactWithoutEmail => EmergencyContact(
        id: 'contact-3',
        userId: 'test-user-id',
        name: 'Bob Jones',
        phone: '+15553334444',
        email: null,
        priority: 3,
        createdAt: DateTime(2026, 1, 7),
        updatedAt: DateTime(2026, 1, 7),
      );

  /// List of sample contacts
  static List<EmergencyContact> get sampleContacts => [
        sampleContact,
        sampleContact2,
        contactWithoutEmail,
      ];

  /// Maximum contacts (5)
  static List<EmergencyContact> get maxContacts => List.generate(
        5,
        (i) => EmergencyContact(
          id: 'contact-${i + 1}',
          userId: 'test-user-id',
          name: 'Contact ${i + 1}',
          phone: '+1555000000${i + 1}',
          priority: i + 1,
          createdAt: DateTime(2026, 1, i + 1),
          updatedAt: DateTime(2026, 1, i + 1),
        ),
      );

  /// Valid test emails
  static const validEmails = [
    'test@example.com',
    'user.name@domain.co',
    'user+tag@example.org',
  ];

  /// Invalid test emails
  static const invalidEmails = [
    'invalid',
    'missing@',
    '@nodomain.com',
    'spaces in@email.com',
  ];

  /// Valid test phone numbers
  static const validPhones = [
    '+15551234567',
    '5551234567',
    '+447911123456',
    '1234567890',
  ];

  /// Invalid test phone numbers
  static const invalidPhones = [
    '123',
    'abcdefghij',
    '+1',
  ];

  /// Valid passwords
  static const validPasswords = [
    'password123',
    'securePass!',
    'aB3\$efgh',
  ];

  /// Invalid passwords (too short)
  static const invalidPasswords = [
    'short',
    '1234567',
    'abc',
  ];
}
