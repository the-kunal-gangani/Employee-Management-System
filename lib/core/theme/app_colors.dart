import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryDark = Color(0xFF6366F1);
  static const Color secondary = Color(0xFF14B8A6);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Pill buttons / high-contrast CTAs (the black "Home"/"Get in touch" pills)
  static const Color pillDark = Color(0xFF14161A);

  // Pastel stat-tile backgrounds (light mode)
  static const Color statBlueLight = Color(0xFFE3F0FF);
  static const Color statGreenLight = Color(0xFFE3F9EC);
  static const Color statPurpleLight = Color(0xFFF1E9FF);
  static const Color statYellowLight = Color(0xFFFFF6DD);

  // Pastel stat-tile backgrounds (dark mode) — desaturated, low-luminance versions
  static const Color statBlueDark = Color(0xFF16233A);
  static const Color statGreenDark = Color(0xFF15281F);
  static const Color statPurpleDark = Color(0xFF241C3A);
  static const Color statYellowDark = Color(0xFF332C13);

  // Stat-tile icon/accent colors (same in both themes)
  static const Color statBlueIcon = Color(0xFF2E7CF6);
  static const Color statGreenIcon = Color(0xFF1FAE5C);
  static const Color statPurpleIcon = Color(0xFF8B5CF6);
  static const Color statYellowIcon = Color(0xFFD69E0A);

  // Light theme surfaces
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Dark theme surfaces
  static const Color darkBackground = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF161B29);
  static const Color darkBorder = Color(0xFF2A3142);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
}
