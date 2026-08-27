import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    required Color color,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle headlineLarge(Color color) => _base(
    size: 28,
    weight: FontWeight.w700,
    color: color,
    letterSpacing: -0.5,
  );

  static TextStyle headlineMedium(Color color) => _base(
    size: 22,
    weight: FontWeight.w700,
    color: color,
    letterSpacing: -0.3,
  );

  static TextStyle titleLarge(Color color) =>
      _base(size: 18, weight: FontWeight.w600, color: color);

  static TextStyle bodyLarge(Color color) =>
      _base(size: 16, weight: FontWeight.w400, color: color);

  static TextStyle bodyMedium(Color color) =>
      _base(size: 14, weight: FontWeight.w400, color: color);

  static TextStyle bodySmall(Color color) =>
      _base(size: 12, weight: FontWeight.w400, color: color);

  static TextStyle labelLarge(Color color) =>
      _base(size: 14, weight: FontWeight.w600, color: color);

  static TextStyle button(Color color) => _base(
    size: 15,
    weight: FontWeight.w600,
    color: color,
    letterSpacing: 0.2,
  );
}
