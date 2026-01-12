import 'package:flutter/material.dart';

/// App color palette
class AppColors {
  AppColors._();

  /// Primary brand color - deep red
  static const Color primary = Color(0xFFB71C1C);
  static const Color primaryLight = Color(0xFFE53935);
  static const Color primaryDark = Color(0xFF7F0000);

  /// Secondary color
  static const Color secondary = Color(0xFF424242);

  /// Success green (for check-in confirmation)
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFF4CAF50);

  /// Warning orange (for reminders)
  static const Color warning = Color(0xFFF57C00);

  /// Error red
  static const Color error = Color(0xFFD32F2F);

  /// Background colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);

  /// Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// Timer colors based on urgency
  static const Color timerNormal = Color(0xFF757575);
  static const Color timerUrgent = Color(0xFFF57C00);
  static const Color timerCritical = Color(0xFFD32F2F);
}
