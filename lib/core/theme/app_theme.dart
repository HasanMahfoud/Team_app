// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette — Deep Teal/Emerald
  static const Color primary = Color(0xFF0A8F6B);
  static const Color primaryLight = Color(0xFF16C490);
  static const Color primaryDark = Color(0xFF065C45);
  static const Color primaryGlow = Color(0x2616C490);

  // Surface & Background
  static const Color background = Color(0xFFF6F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F4F3);
  static const Color cardSurface = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF0D1B1A);
  static const Color textSecondary = Color(0xFF5A6B69);
  static const Color textTertiary = Color(0xFF9BB0AD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Accent colors
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentRose = Color(0xFFEC4899);
  static const Color accentViolet = Color(0xFF8B5CF6);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A8F6B), Color(0xFF065C45)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A8F6B), Color(0xFF16C490), Color(0xFF3B82F6)],
    stops: [0.0, 0.6, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF0F7F5)],
  );

  // Shadow
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF0A8F6B).withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get navShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 24,
          offset: const Offset(0, -4),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: const Color(0xFF0A8F6B).withValues(alpha: 0.35),
          blurRadius: 16,
          offset: const Offset(0, 6),
          spreadRadius: 0,
        ),
      ];
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        surface: AppColors.surface,
        background: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Cairo', // Arabic-first font
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primaryLight,
        onPrimary: AppColors.textOnPrimary,
        surface: const Color(0xFF121B20),
        background: const Color(0xFF0E1620),
      ),
      scaffoldBackgroundColor: const Color(0xFF0E1620),
      fontFamily: 'Cairo',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textOnPrimary),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF151F28),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}

final ValueNotifier<ThemeMode> appThemeModeNotifier =
    ValueNotifier(ThemeMode.light);
