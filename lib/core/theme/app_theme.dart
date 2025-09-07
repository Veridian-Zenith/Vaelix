import 'package:flutter/material.dart';

// Inspired by the customizable and sleek themes of browsers like Vivaldi and OperaGX.
// This will be the foundation for our custom theme.

const Color _darkPrimaryColor = Color(0xFF0D1117); // A deep, dark grey for the main background
const Color _darkAccentColor = Color(0xFF00B8D4); // A vibrant teal for accents

ThemeData buildVaelixTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: _darkPrimaryColor,
    scaffoldBackgroundColor: _darkPrimaryColor,

    colorScheme: const ColorScheme.dark(
      primary: _darkAccentColor,
      secondary: _darkAccentColor,
      background: _darkPrimaryColor,
      surface: Color(0xFF161B22), // Slightly lighter grey for surfaces like cards or dialogs
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.white,
      onSurface: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      color: Color(0xFF161B22),
      elevation: 0,
      iconTheme: IconThemeData(color: _darkAccentColor),
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    
    // We can add more theme properties here as the app grows.
    // e.g., buttonTheme, inputDecorationTheme, etc.
  );
}
