import 'package:flutter/material.dart';

class AppColors {
  // Primary gradient colors
  static const Color primaryStart = Color(0xFF2E6DD1);
  static const Color primaryEnd = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFF3A80E9);
  static const Color primaryLighter = Color(0xFF2563EB);

  // Background colors
  static const Color backgroundGradientStart = Color(0xFFDCEAFF);
  static const Color backgroundGradientEnd = Color(0xFFF4F9FF);

  // Text colors
  static const Color textPrimary = Color(0xFF3A5D84);
  static const Color textDark = Color(0xFF1D4ED8);
  static const Color textMuted = Color(0xFF5A7B9B);
  static const Color textLight = Color(0xFF94B1C9);
  static const Color textLighter = Color(0xFFA0BCE0);

  // Status colors
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFCA5A5);

  // Surface colors
  static const Color surface = Colors.white;
  static const Color surfaceLight = Color(0xFFE8F1FF);
  static const Color borderLight = Color(0xFFEFF6FF); // blue-50

  // Other
  static const Color shadowBlue = Color(0x0F1E60DC);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryStart, primaryEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient primaryGradient2 = LinearGradient(
    colors: [primaryLight, primaryLighter],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundGradientStart, backgroundGradientEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [primaryStart, primaryEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        fontFamily: 'SF Pro Display',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryEnd,
          primary: AppColors.primaryEnd,
        ),
        scaffoldBackgroundColor: AppColors.backgroundGradientEnd,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: AppColors.surface,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryEnd,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
}
