import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_tokens.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: DesignTokens.backgroundDark,
      colorScheme: ColorScheme.dark(
        primary: DesignTokens.primaryPurple,
        secondary: DesignTokens.primaryPurpleDark,
        surface: DesignTokens.backgroundCard,
        error: DesignTokens.statusError,
      ),
      textTheme: GoogleFonts.interTextTheme(
        TextTheme(
          displayLarge: DesignTokens.displayLarge,
          displayMedium: DesignTokens.headingMedium,
          displaySmall: DesignTokens.headingSmall,
          bodyLarge: DesignTokens.bodyMedium,
          bodyMedium: DesignTokens.caption,
          bodySmall: DesignTokens.bodySmall,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: DesignTokens.backgroundDark,
        elevation: 0,
        titleTextStyle: DesignTokens.headingMedium,
        iconTheme: const IconThemeData(color: DesignTokens.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: DesignTokens.backgroundCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignTokens.backgroundCardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          borderSide: const BorderSide(
            color: DesignTokens.borderPrimary,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          borderSide: const BorderSide(
            color: DesignTokens.primaryPurple,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing16,
          vertical: DesignTokens.spacing16,
        ),
        hintStyle: DesignTokens.bodyMedium.copyWith(
          color: DesignTokens.textTertiary,
        ),
        labelStyle: DesignTokens.bodyMedium.copyWith(
          color: DesignTokens.textSecondary,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: DesignTokens.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.primaryPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing24,
            vertical: DesignTokens.spacing16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          ),
          textStyle: DesignTokens.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DesignTokens.primaryPurple,
          side: const BorderSide(color: DesignTokens.primaryPurple, width: 1.5),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing24,
            vertical: DesignTokens.spacing16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          ),
          textStyle: DesignTokens.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
