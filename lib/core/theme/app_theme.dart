import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_dev_summative/core/theme/app_colors.dart';

class AppTheme {
  static ThemeData get light => _buildTheme(Brightness.light);

  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    ).copyWith(secondary: AppColors.secondary);

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
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: colorScheme.secondary.withValues(alpha: 0.25),
        labelTextStyle: WidgetStateProperty.all(textTheme.labelMedium),
      ),
    );
  }
}
