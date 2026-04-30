// lib/widgets/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primary = Color(0xFF6C2BD9);
  static const Color primaryDark = Color(0xFF4A1A9E);
  static const Color primaryLight = Color(0xFF9B59E8);
  static const Color accent = Color(0xFFF5A623);

  // Backgrounds
  static const Color bgDark = Color(0xFF1A0A3D);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgLight = Color(0xFFF5F3FF);

  // Result Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFF2196F3);

  // Text
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF9E9E9E);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
      ),
      scaffoldBackgroundColor: bgLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: bgCard,
        foregroundColor: primary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: primary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primary,
        unselectedItemColor: Color(0xFF9E9E9E),
        backgroundColor: bgCard,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

// Reusable gradient decoration
BoxDecoration splashGradient() => const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppTheme.primaryDark, AppTheme.primary, AppTheme.primaryLight],
      ),
    );
