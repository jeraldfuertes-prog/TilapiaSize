import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFF3FBFD);
  static const surface = Colors.white;
  static const surfaceSoft = Color(0xFFEAF8FB);
  static const surfaceBlue = Color(0xFFE6F7FB);
  static const ink = Color(0xFF0A3542);
  static const muted = Color(0xFF617E87);
  static const line = Color(0xFFCFE8EE);
  static const primary = Color(0xFF0AA7B8);
  static const primaryDark = Color(0xFF087789);
  static const primarySoft = Color(0xFFD8F4F7);
  static const accent = Color(0xFF2D8FE0);
  static const accentSoft = Color(0xFFE7F3FD);
  static const warning = Color(0xFFF1A63B);
  static const danger = Color(0xFFC65353);
  static const sidebar = Color(0xFF063F50);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF064A5B),
        contentTextStyle: TextStyle(color: Colors.white, fontSize: 12),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
