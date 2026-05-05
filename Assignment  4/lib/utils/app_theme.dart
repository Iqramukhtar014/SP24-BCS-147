import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF1A237E);
  static const Color accentBlue = Color(0xFF3949AB);
  static const Color deepPurple = Color(0xFF4527A0);
  static const Color lightPurple = Color(0xFF7B1FA2);
  static const Color cardBg = Color(0x1AFFFFFF);
  static const Color cardBorder = Color(0x26FFFFFF);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color textHint = Color(0x73FFFFFF);

  static const gradientStart = Color(0xFF1A1F6E);
  static const gradientMid = Color(0xFF2D3494);
  static const gradientEnd = Color(0xFF5C2D91);

  static LinearGradient get backgroundGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [gradientStart, gradientMid, Color(0xFF3B2F8F), gradientEnd],
        stops: [0.0, 0.4, 0.7, 1.0],
      );

  static LinearGradient get buttonGradient => const LinearGradient(
        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
      );

  static BoxDecoration get glassCard => BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder, width: 1),
      );

  static BoxDecoration get glassCardSmall => BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder, width: 1),
      );
}

class AppConstants {
  static const List<String> defaultCities = [
    'Karachi',
    'Lahore',
    'Peshawar',
    'Quetta',
    'Multan',
    'Faisalabad',
  ];
}
