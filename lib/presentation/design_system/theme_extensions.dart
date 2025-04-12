import 'package:flutter/material.dart';

/// Extension methods for easier theme access
extension ThemeExtension on BuildContext {
  /// Get the current theme data
  ThemeData get theme => Theme.of(this);
  
  /// Get the primary color from the theme
  Color get primaryColor => theme.primaryColor;
  
  /// Get the scaffold background color
  Color get scaffoldBackgroundColor => theme.scaffoldBackgroundColor;
  
  /// Get the text theme
  TextTheme get textTheme => theme.textTheme;
  
  /// Get the app bar theme
  AppBarTheme get appBarTheme => theme.appBarTheme;
  
  /// Get the button theme
  ButtonThemeData get buttonTheme => theme.buttonTheme;
  
  /// Get the color scheme
  ColorScheme get colorScheme => theme.colorScheme;
  
  /// Get the current media query data
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  
  /// Get the screen width
  double get screenWidth => mediaQuery.size.width;
  
  /// Get the screen height
  double get screenHeight => mediaQuery.size.height;
  
  /// Check if the device is in dark mode
  bool get isDarkMode => theme.brightness == Brightness.dark;
} 