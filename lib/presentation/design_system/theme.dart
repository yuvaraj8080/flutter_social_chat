import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';

class AppTheme {
  // Base text styles
  static final _baseTextStyle = GoogleFonts.getFont('Roboto');

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: customIndigoColor,
      colorScheme: _createColorScheme(),
      scaffoldBackgroundColor: white,

      // AppBar theme
      appBarTheme: _createAppBarTheme(),

      // Button themes
      elevatedButtonTheme: _createElevatedButtonTheme(),

      textButtonTheme: _createTextButtonTheme(),

      // Input decoration theme
      inputDecorationTheme: _createInputDecorationTheme(),

      // Text theme
      textTheme: _createTextTheme(),

      // Icon theme
      iconTheme: const IconThemeData(color: black, size: 24),

      // Divider theme
      dividerTheme: const DividerThemeData(color: customGreyColor400, thickness: 1, space: 1),

      // Text selection theme
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: customIndigoColor,
        selectionColor: customIndigoColor,
        selectionHandleColor: customIndigoColor,
      ),
    );
  }

  static ColorScheme _createColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: customIndigoColor,
      primary: customIndigoColor,
      secondary: customIndigoColorSecondary,
      surface: white,
      surfaceContainerHighest: white,
      onSurface: black,
      onSurfaceVariant: secondaryTextColor,
      error: errorColor,
    );
  }

  static AppBarTheme _createAppBarTheme() {
    return const AppBarTheme(
      elevation: 0,
      backgroundColor: white,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      iconTheme: IconThemeData(color: black),
      titleTextStyle: TextStyle(
        color: black,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static ElevatedButtonThemeData _createElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(customIndigoColor),
        foregroundColor: WidgetStateProperty.all(white),
        elevation: WidgetStateProperty.all(0),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
        textStyle: WidgetStateProperty.all(
          _baseTextStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static TextButtonThemeData _createTextButtonTheme() {
    return TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(customIndigoColor),
        textStyle: WidgetStateProperty.all(
          _baseTextStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered)) {
              return customIndigoColor.withValues(alpha: 0.04);
            }
            if (states.contains(WidgetState.focused) || states.contains(WidgetState.pressed)) {
              return customIndigoColor.withValues(alpha: 0.12);
            }
            return null;
          },
        ),
      ),
    );
  }

  static InputDecorationTheme _createInputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: customGreyColor400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: customGreyColor400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: customIndigoColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: errorColor),
      ),
      hintStyle: _baseTextStyle.copyWith(color: customGreyColor600, fontSize: 16),
      labelStyle: _baseTextStyle.copyWith(color: black, fontSize: 16),
    );
  }

  static TextTheme _createTextTheme() {
    return TextTheme(
      displayLarge: _baseTextStyle.copyWith(color: black, fontSize: 28, fontWeight: FontWeight.w700),
      displayMedium: _baseTextStyle.copyWith(color: black, fontSize: 24, fontWeight: FontWeight.w700),
      displaySmall: _baseTextStyle.copyWith(color: black, fontSize: 20, fontWeight: FontWeight.w600),
      bodyLarge: _baseTextStyle.copyWith(color: black, fontSize: 20, fontWeight: FontWeight.w500),
      bodyMedium: _baseTextStyle.copyWith(color: black, fontSize: 16, fontWeight: FontWeight.w500),
      bodySmall: _baseTextStyle.copyWith(color: black, fontSize: 12, fontWeight: FontWeight.w400),
    );
  }
}
