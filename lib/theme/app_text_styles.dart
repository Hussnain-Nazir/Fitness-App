// app_text_styles.dart
// Typography scale: Poppins for headings, Inter for body and stats.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle heading1({Color color = AppColors.textPrimaryLight}) =>
      GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.2,
      );

  static TextStyle heading2({Color color = AppColors.textPrimaryLight}) =>
      GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.25,
      );

  static TextStyle heading3({Color color = AppColors.textPrimaryLight}) =>
      GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle body({Color color = AppColors.textPrimaryLight}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle bodySmall({Color color = AppColors.textSecondary}) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle stat({Color color = AppColors.textPrimaryLight}) =>
      GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle statLabel({Color color = AppColors.textSecondary}) =>
      GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 0.4,
      );

  static TextStyle button({Color color = Colors.white}) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color,
      );
}
