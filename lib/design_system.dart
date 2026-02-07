import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Color Palette
class AppColors {
  static const Color primary = Color(0xFF3751FF); // Brand Indigo
  static const Color primaryVariant = Color(0xFF2747E6);
  static const Color accent = Color(0xFFFF6B6B); // Coral
  static const Color success = Color(0xFF00C2A8);
  static const Color background = Color(0xFFF7FAFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFF6B7280);
  static const Color textPrimary = Color(0xFF0F1724);
  static const Color error = Color(0xFFEF4444);
  static const Color divider = Color(0xFFE6E9F2);

  // Dark mode variants (not used by default)
  static const Color darkBackground = Color(0xFF0B1220);
  static const Color darkSurface = Color(0xFF0F1724);
  static const Color darkPrimary = Color(0xFF5B8CFF);
}

// Spacing and radii
class AppSpacing {
  static const double base = 8.0;
  static const double small = 8.0;
  static const double regular = 16.0;
  static const double large = 24.0;
  static const double card = 16.0;
}

class AppRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
}

// Typography
class AppTextStyles {
  static TextStyle h1 = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  static TextStyle h2 = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.25,
  );
  static TextStyle h3 = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.25,
  );
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  static TextStyle body = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.muted,
  );
  static TextStyle button = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
