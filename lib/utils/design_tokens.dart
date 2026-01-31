import 'package:flutter/material.dart';

/// Design tokens for the Billify app
/// Based on the new dark theme design with AI-powered features
class DesignTokens {
  // Private constructor to prevent instantiation
  DesignTokens._();

  // ==================== COLORS ====================

  /// Primary purple color for CTAs and accents
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color primaryPurpleLight = Color(0xFF9F67FF);
  static const Color primaryPurpleDark = Color(0xFF6D28D9);
  static const Color accentCyan = Color(0xFF00F2FF);

  /// Background colors
  static const Color backgroundDark = Color(0xFF0F0A1F);
  static const Color backgroundCard = Color(0xFF1A1625);
  static const Color backgroundCardLight = Color(0xFF221B2E);

  /// Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF4B5563);

  /// Status colors
  static const Color statusVerified = Color(0xFF10B981); // Green
  static const Color statusReviewing = Color(0xFFF59E0B); // Orange
  static const Color statusRecurring = Color(0xFF06B6D4); // Cyan
  static const Color statusError = Color(0xFFEF4444); // Red

  /// Category colors
  static const Color categoryGroceries = Color(0xFFEC4899); // Pink
  static const Color categoryTech = Color(0xFFF59E0B); // Orange
  static const Color categoryDining = Color(0xFF8B5CF6); // Purple
  static const Color categoryUtilities = Color(0xFF06B6D4); // Cyan
  static const Color categoryTransport = Color(0xFF10B981); // Green
  static const Color categoryHealth = Color(0xFFEF4444); // Red

  /// Border colors
  static const Color borderPrimary = Color(0xFF2D2640);
  static const Color borderSecondary = Color(0xFF3F3851);
  static const Color borderPurple = Color(0xFF7C3AED);

  /// Overlay colors
  static const Color overlayDark = Color(0x80000000);
  static const Color overlayLight = Color(0x40FFFFFF);

  // ==================== GRADIENTS ====================

  /// Primary purple gradient for buttons and accents
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF9F67FF), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Subtle background gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0F0A1F), Color(0xFF1A1625)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Card gradient with glassmorphism effect
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF221B2E), Color(0xFF1A1625)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==================== SPACING ====================

  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;

  // ==================== BORDER RADIUS ====================

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusRound = 999.0;

  // ==================== TYPOGRAPHY ====================

  /// Display text style (large headings)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  /// Heading text styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  /// Body text styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  /// Label text styles
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    letterSpacing: 1.0,
  );

  /// Caption text style
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  // ==================== SHADOWS ====================

  static const List<BoxShadow> shadowSmall = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> shadowMedium = [
    BoxShadow(color: Color(0x26000000), blurRadius: 8, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> shadowLarge = [
    BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> shadowPurple = [
    BoxShadow(color: Color(0x407C3AED), blurRadius: 20, offset: Offset(0, 4)),
  ];

  // ==================== ANIMATION DURATIONS ====================

  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ==================== HELPER METHODS ====================

  /// Get category color by category name
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'groceries':
        return categoryGroceries;
      case 'tech':
      case 'technology':
        return categoryTech;
      case 'dining':
      case 'food':
      case 'restaurant':
        return categoryDining;
      case 'utilities':
        return categoryUtilities;
      case 'transport':
      case 'transportation':
        return categoryTransport;
      case 'health':
      case 'healthcare':
        return categoryHealth;
      default:
        return primaryPurple;
    }
  }

  /// Get status color by status type
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
      case 'verified ai':
        return statusVerified;
      case 'reviewing':
        return statusReviewing;
      case 'recurring':
        return statusRecurring;
      case 'error':
      case 'failed':
        return statusError;
      default:
        return textSecondary;
    }
  }

  /// Get category icon by category name
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'groceries':
        return Icons.shopping_cart;
      case 'tech':
      case 'technology':
        return Icons.devices;
      case 'dining':
      case 'food':
      case 'restaurant':
        return Icons.restaurant;
      case 'utilities':
        return Icons.bolt;
      case 'transport':
      case 'transportation':
        return Icons.directions_car;
      case 'health':
      case 'healthcare':
        return Icons.local_hospital;
      default:
        return Icons.category;
    }
  }
}
