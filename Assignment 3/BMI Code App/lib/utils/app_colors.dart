// ============================================================
// utils/app_colors.dart — Centralized color palette
// ============================================================

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary dark background (deep navy)
  static const Color background = Color(0xFF0F0E2A);
  static const Color cardDark   = Color(0xFF1C1B3A);
  static const Color cardLight  = Color(0xFF252447);

  // Accent — hot pink / magenta (matches the reference "CALCULATE" button)
  static const Color accent      = Color(0xFFFF0D6B);
  static const Color accentLight = Color(0xFFFF4D94);

  // Text
  static const Color textPrimary   = Colors.white;
  static const Color textSecondary = Color(0xFFB0B3C6);
  static const Color textLabel     = Color(0xFF8C8FA8);

  // Gender selected highlight
  static const Color genderSelected = Color(0xFF1C1B3A);
  static const Color genderBorder   = Color(0xFFFF0D6B);

  // BMI category colors
  static const Color colorUnderweight = Color(0xFF42A5F5); // blue
  static const Color colorNormal      = Color(0xFF66BB6A); // green
  static const Color colorOverweight  = Color(0xFFFFA726); // orange/yellow
  static const Color colorObese       = Color(0xFFEF5350); // red

  // Slider active track
  static const Color sliderActive   = Color(0xFFFF0D6B);
  static const Color sliderInactive = Color(0xFF3D3B6B);
}

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle displayLarge = TextStyle(
    fontSize: 72,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -2,
  );

  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textLabel,
    letterSpacing: 1.2,
  );

  static const TextStyle bodyRegular = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}

class AppDimensions {
  AppDimensions._();

  static const double paddingS  = 8.0;
  static const double paddingM  = 16.0;
  static const double paddingL  = 24.0;
  static const double paddingXL = 32.0;
  static const double radiusM   = 16.0;
  static const double radiusL   = 24.0;
}
