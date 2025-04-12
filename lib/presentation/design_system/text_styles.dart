import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class to define consistent text styles used throughout the app
class AppTextStyles {
  // Headings
  static TextStyle get heading1 => GoogleFonts.roboto(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primaryTextColor,
      );

  static TextStyle get heading2 => GoogleFonts.roboto(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: primaryTextColor,
      );

  static TextStyle get heading3 => GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      );

  // Body text
  static TextStyle get bodyLarge => GoogleFonts.roboto(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
      );

  static TextStyle get bodyMedium => GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
      );

  static TextStyle get bodySmall => GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primaryTextColor,
      );

  // Button text
  static TextStyle get buttonLarge => GoogleFonts.roboto(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: white,
      );

  static TextStyle get buttonMedium => GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: white,
      );

  // Label text
  static TextStyle get label => GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
      );

  // Caption text
  static TextStyle get caption => GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryTextColor,
      );

  // Helper functions to modify styles
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
} 