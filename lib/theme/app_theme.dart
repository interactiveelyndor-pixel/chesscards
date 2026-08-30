import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.abyssBlack,
      primaryColor: AppColors.bloodWine,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.bloodWine,
        secondary: AppColors.cursePurple,
        surface: AppColors.hauntedCharcoal,
        onPrimary: AppColors.candleIvory,
        onSurface: AppColors.candleIvory,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.bloodWine),
        titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.candleIvory),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.candleIvory),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.candleIvory),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.candleIvory),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.fogGray),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.hauntedCharcoal,
        elevation: 4,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bloodWine,
          foregroundColor: AppColors.candleIvory,
          textStyle: AppTextStyles.titleMedium,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.hauntedCharcoal,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.bloodWine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.fogGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.bloodWine, width: 2),
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.fogGray),
      ),
    );
  }
}
