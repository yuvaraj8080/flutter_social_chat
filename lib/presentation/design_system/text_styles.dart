import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class to define consistent text styles used throughout the app
class AppTextStyles {
  // Base Roboto style to be extended for all text styles
  static final TextStyle _baseStyle = GoogleFonts.getFont('Roboto');

  // Headings
  static TextStyle get heading1 => _baseStyle.copyWith(fontSize: 28, fontWeight: FontWeight.w700, color: black);

  static TextStyle get heading2 => _baseStyle.copyWith(fontSize: 24, fontWeight: FontWeight.w700, color: black);

  static TextStyle get heading3 => _baseStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w600, color: black);

  // Body text
  static TextStyle get bodyLarge => _baseStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w500, color: black);

  static TextStyle get bodyMedium => _baseStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w500, color: black);

  static TextStyle get bodySmall => _baseStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w400, color: black);

  // Button text
  static TextStyle get buttonLarge => _baseStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w600, color: white);

  static TextStyle get buttonMedium => _baseStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: white);

  // Label text
  static TextStyle get label => _baseStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w500, color: black);

  // Caption text
  static TextStyle get caption =>
      _baseStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w400, color: secondaryTextColor);

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
