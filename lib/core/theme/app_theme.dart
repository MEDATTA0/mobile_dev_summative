import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_dev_summative/core/theme/app_colors.dart';

class AppTheme {
  static ThemeData get light => _buildTheme(Brightness.light);

  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    // Seed for M3 harmony, then pin the exact brand colors from the design.
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
    );

    final base = ThemeData(colorScheme: colorScheme, useMaterial3: true);

    final textTheme = GoogleFonts.interTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.poppins(textStyle: base.textTheme.displayLarge),
      displayMedium: GoogleFonts.poppins(
        textStyle: base.textTheme.displayMedium,
      ),
      displaySmall: GoogleFonts.poppins(textStyle: base.textTheme.displaySmall),
      headlineLarge: GoogleFonts.poppins(
        textStyle: base.textTheme.headlineLarge,
      ),
      headlineMedium: GoogleFonts.poppins(
        textStyle: base.textTheme.headlineMedium,
      ),
      headlineSmall: GoogleFonts.poppins(
        textStyle: base.textTheme.headlineSmall,
      ),
      titleLarge: GoogleFonts.poppins(textStyle: base.textTheme.titleLarge),
      titleMedium: GoogleFonts.poppins(textStyle: base.textTheme.titleMedium),
      titleSmall: GoogleFonts.poppins(textStyle: base.textTheme.titleSmall),
    );

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor:
          isLight ? AppColors.background : colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: isLight ? AppColors.surface : colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isLight ? AppColors.surface : colorScheme.surface,
        indicatorColor: AppColors.primaryLight,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textSecondary,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
