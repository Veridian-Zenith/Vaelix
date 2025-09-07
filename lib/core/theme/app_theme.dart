import 'package:flutter/material.dart';

// Vaelix theming
// Dark theme: Absolute Black background, Rosewater accents, and warm Gold highlights.
// Light theme: "Blue Diamond" inspired — a cool, gem-like light theme for an alternative.

// --- Palette (Dark) ---
const Color kAbsoluteBlack = Color(0xFF000000);
const Color kRosewater = Color(0xFFFFA6AD); // #ffa6ad
const Color kGold = Color(0xFFFFD54A); // gold highlight (#FFD54A) per spec
const Color kSurfaceDark = Color(0xFF0A0A0A); // subtle surface differentiation

// --- Palette (Blue Diamond / Light) ---
const Color kBlueDiamondBg = Color(0xFFEAF6FF);
const Color kBlueDiamondPrimary = Color(0xFF2F80ED);
const Color kBlueDiamondAccent = Color(0xFF60A5FA);

ThemeData buildVaelixDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    brightness: Brightness.dark,
    primaryColor: kRosewater,
    scaffoldBackgroundColor: kAbsoluteBlack,
    canvasColor: kAbsoluteBlack,

    colorScheme: ColorScheme.dark(
      primary: kRosewater,
      secondary: kGold,
      background: kAbsoluteBlack,
      surface: kSurfaceDark,
      onPrimary: kAbsoluteBlack, // Rosewater is light — use dark text on it
      onSecondary: kAbsoluteBlack,
      onBackground: Colors.white,
      onSurface: Colors.white,
    ),

    appBarTheme: AppBarTheme(
      color: kAbsoluteBlack,
      elevation: 0,
      iconTheme: const IconThemeData(color: kRosewater),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: kRosewater,
      foregroundColor: kAbsoluteBlack,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kRosewater,
        foregroundColor: kAbsoluteBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: kRosewater),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kRosewater,
        side: BorderSide(color: kRosewater.withOpacity(0.18)),
      ),
    ),

    iconTheme: const IconThemeData(color: Colors.white70),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurfaceDark,
      hintStyle: const TextStyle(color: Colors.white38),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0x1FFFFFFF)),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: kRosewater),
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    cardColor: kSurfaceDark,

    textTheme: TextTheme(
      bodyLarge: const TextStyle(color: Colors.white),
      bodyMedium: const TextStyle(color: Colors.white70),
      titleLarge: TextStyle(color: kGold),
    ),
  );
}

ThemeData buildVaelixLightBlueDiamondTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    brightness: Brightness.light,
    primaryColor: kBlueDiamondPrimary,
    scaffoldBackgroundColor: kBlueDiamondBg,
    canvasColor: kBlueDiamondBg,

    colorScheme: ColorScheme.light(
      primary: kBlueDiamondPrimary,
      secondary: kBlueDiamondAccent,
      background: kBlueDiamondBg,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.black87,
      onSurface: Colors.black87,
    ),

    appBarTheme: AppBarTheme(
      color: kBlueDiamondPrimary,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kBlueDiamondPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kBlueDiamondPrimary,
      foregroundColor: Colors.white,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: TextStyle(color: Colors.black38),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: kBlueDiamondPrimary.withOpacity(0.12)),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: kBlueDiamondPrimary),
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black54),
    ),
  );
}

// Backwards-compatible default used across the app.
ThemeData buildVaelixTheme() => buildVaelixDarkTheme();
