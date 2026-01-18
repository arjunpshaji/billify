import 'package:flutter/material.dart';

// Color Tokens
class AppColors {
  // Brand / Accent
  static const Color primary = Color(0xFF5BA3FF); // Blue accent
  static const Color secondary = Color(0xFF3A5BFF);
  static const Color accentGlow = Color(0xFF7CF3FF);

  // Backgrounds (Dark Theme)
  static const Color bgMain = Color(0xFF1A1D26); // Main dark background
  static const Color bgCard = Color(0xFF252932); // Card background
  static const Color bgInput = Color(0xFF2A2E38); // Input field background

  // Text (Dark Theme)
  static const Color textPrimary = Color(0xFFFFFFFF); // White text
  static const Color textSecondary = Color(0xFF94A3B8); // Gray text
  static const Color textMuted = Color(0xFF64748B); // Muted gray

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFFF6B6B); // Red for delete

  // Borders
  static const Color borderInput = Color(0xFF3A3E48);
  static const Color borderDashed = Color(0xFF4A5568);

  // Special
  static const Color strikethrough = Color(0xFF64748B); // For original amounts
  static const Color iconBlue = Color(0xFF5BA3FF);
}

// Spacing Tokens
class AppSpacing {
  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 20.0;
  static const double space6 = 24.0;
  static const double space7 = 32.0;
}

// Radius Tokens
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 28.0;
}

// Shadow Tokens
class AppShadows {
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF0F172A).withOpacity(0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> floatingButton = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.35),
      blurRadius: 30,
      offset: const Offset(0, 10),
    ),
  ];
}

// Typography Tokens
class AppTypography {
  static const String fontFamily = 'Inter';

  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle tiny = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
  );
}
