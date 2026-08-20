// app_colors.dart
// Central color palette for Vexon. Every screen pulls colors from here so
// the theme stays consistent - do not hardcode hex values in screens.

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core brand
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color accentBlue = Color(0xFF3B82F6);

  // Backgrounds
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF16213A);
  static const Color darkSurfaceAlt = Color(0xFF1C2740);
  static const Color lightSurface = Color(0xFFF8FAFC);

  // Text
  static const Color textPrimaryLight = Colors.white;
  static const Color textPrimaryDark = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF94A3B8);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  // Borders / dividers
  static const Color divider = Color(0xFF27324A);
  static const Color cardBorderLight = Color(0xFFE2E8F0);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, accentBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
