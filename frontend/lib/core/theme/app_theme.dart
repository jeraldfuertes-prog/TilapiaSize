import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFF5F8F6);
  static const surface = Colors.white;
  static const surfaceSoft = Color(0xFFEEF7F2);
  static const surfaceBlue = Color(0xFFEDF7FA);
  static const ink = Color(0xFF153229);
  static const muted = Color(0xFF6C7F77);
  static const line = Color(0xFFDCE8E1);
  static const primary = Color(0xFF0F8064);
  static const primaryDark = Color(0xFF09654F);
  static const primarySoft = Color(0xFFDFF2EA);
  static const accent = Color(0xFF1E9AB3);
  static const accentSoft = Color(0xFFE3F6FA);
  static const warning = Color(0xFFF1A63B);
  static const danger = Color(0xFFC65353);
  static const sidebar = Color(0xFF0D3A31);
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF13382E),
        contentTextStyle: TextStyle(color: Colors.white, fontSize: 12),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
