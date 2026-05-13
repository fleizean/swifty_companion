import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextStyle get display => GoogleFonts.lilitaOne(
        fontSize: 40,
        height: 48 / 40,
        letterSpacing: 1,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineLg => GoogleFonts.lilitaOne(
        fontSize: 28,
        height: 34 / 28,
        letterSpacing: 0.5,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineMd => GoogleFonts.lilitaOne(
        fontSize: 22,
        height: 28 / 22,
        letterSpacing: 0.5,
        color: AppColors.onSurface,
      );

  static TextStyle get taglineItalic => GoogleFonts.hankenGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        height: 24 / 18,
        color: AppColors.tertiaryContainer,
      );

  static TextStyle get bodyLg => GoogleFonts.hankenGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.onSurface,
      );

  static TextStyle get bodySm => GoogleFonts.hankenGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: AppColors.muted,
      );

  static TextStyle get labelCode => GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        letterSpacing: 0.05 * 12,
        color: AppColors.secondary,
      );
}
