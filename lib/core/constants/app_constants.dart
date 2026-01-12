/// App-wide constants
class AppConstants {
  AppConstants._();

  /// Default check-in interval in hours (2 days)
  static const int defaultCheckInIntervalHours = 48;

  /// Minimum check-in interval in hours (1 day)
  static const int minCheckInIntervalHours = 24;

  /// Maximum check-in interval in hours (7 days)
  static const int maxCheckInIntervalHours = 168;

  /// Maximum number of emergency contacts per user
  static const int maxEmergencyContacts = 5;

  /// Grace period before alerting contacts (in hours)
  static const int gracePeriodHours = 1;

  /// App name
  static const String appName = 'Are You Dead?';

  /// App version
  static const String appVersion = '1.0.0';
}
