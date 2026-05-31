import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryPurple = Color(0xFF7B2FBE);
  static const Color accentPurple = Color(0xFF9D4EDD);
  static const Color lightPurple = Color(0xFFB57BEE);
  static const Color darkBg = Color(0xFF0F0F13);
  static const Color cardDark = Color(0xFF1A1A24);
  static const Color cardDark2 = Color(0xFF22222F);
  static const Color surfaceDark = Color(0xFF16161F);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C0);
  static const Color textMuted = Color(0xFF6B6B80);
  static const Color success = Color(0xFF00C896);
  static const Color warning = Color(0xFFFFB020);
  static const Color error = Color(0xFFFF4D4D);
  static const Color info = Color(0xFF4DA6FF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, accentPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E1E2E), Color(0xFF16162A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF00B09B), Color(0xFF00C896)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFFB020)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF2193B0), Color(0xFF6DD5FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    primaryColor: primaryPurple,
    colorScheme: const ColorScheme.dark(
      primary: primaryPurple,
      secondary: accentPurple,
      surface: cardDark,
      background: darkBg,
      error: error,
    ),
    fontFamily: 'Nunito',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          color: textPrimary, fontSize: 32, fontWeight: FontWeight.w800),
      displayMedium: TextStyle(
          color: textPrimary, fontSize: 26, fontWeight: FontWeight.w700),
      headlineLarge: TextStyle(
          color: textPrimary, fontSize: 22, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(
          color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(
          color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(
          color: textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(
          color: textPrimary, fontSize: 14, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(
          color: textSecondary, fontSize: 13, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(
          color: textMuted, fontSize: 11, fontWeight: FontWeight.w400),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        fontFamily: 'Nunito',
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardDark,
      selectedItemColor: primaryPurple,
      unselectedItemColor: textMuted,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPurple,
        foregroundColor: textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle:
            const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardDark2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2A2A3A), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryPurple, width: 1.5),
      ),
      hintStyle: const TextStyle(color: textMuted, fontSize: 14),
      labelStyle: const TextStyle(color: textSecondary),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardTheme(
      color: cardDark,
      elevation: 0,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF2A2A3A),
      thickness: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: cardDark2,
      labelStyle: const TextStyle(color: textSecondary, fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryPurple,
    colorScheme: const ColorScheme.light(
      primary: primaryPurple,
      secondary: accentPurple,
    ),
    fontFamily: 'Nunito',
  );
}
