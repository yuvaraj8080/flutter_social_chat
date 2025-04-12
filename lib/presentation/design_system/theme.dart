import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/dimens.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: customIndigoColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: customIndigoColor,
        primary: customIndigoColor,
        secondary: customIndigoColor,
        surface: surfaceColor,
        surfaceContainerHighest: surfaceContainerColor,
        onSurface: primaryTextColor,
        onSurfaceVariant: secondaryTextColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: surfaceColor,

      // AppBar theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: surfaceColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        iconTheme: IconThemeData(color: iconColor),
        titleTextStyle: TextStyle(
          color: primaryTextColor,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: customIndigoColor,
          foregroundColor: white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.borderRadius25),
          ),
          padding: const EdgeInsets.symmetric(vertical: Dimens.padding16, horizontal: Dimens.padding24),
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: customIndigoColor,
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(vertical: Dimens.padding16, horizontal: Dimens.padding20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimens.borderRadius25),
          borderSide: BorderSide(color: customGreyColor400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimens.borderRadius25),
          borderSide: BorderSide(color: customGreyColor400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimens.borderRadius25),
          borderSide: const BorderSide(color: customIndigoColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimens.borderRadius25),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimens.borderRadius25),
          borderSide: const BorderSide(color: errorColor),
        ),
        hintStyle: GoogleFonts.roboto(
          color: customGreyColor600,
          fontSize: 16,
        ),
        labelStyle: GoogleFonts.roboto(
          color: primaryTextColor,
          fontSize: 16,
        ),
      ),

      // Text theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.roboto(
          color: primaryTextColor,
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
        displayMedium: GoogleFonts.roboto(
          color: primaryTextColor,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        displaySmall: GoogleFonts.roboto(
          color: primaryTextColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.roboto(
          color: primaryTextColor,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: GoogleFonts.roboto(
          color: primaryTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodySmall: GoogleFonts.roboto(
          color: primaryTextColor,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: iconColor,
        size: Dimens.iconSize24,
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: customGreyColor400,
        thickness: Dimens.size1,
        space: Dimens.size1,
      ),

      // Text selection theme
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: customIndigoColor,
        selectionColor: customIndigoColor,
        selectionHandleColor: customIndigoColor,
      ),
    );
  }
}
