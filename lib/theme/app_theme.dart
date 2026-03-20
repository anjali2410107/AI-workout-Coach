import 'package:flutter/material.dart';

class AppTheme {
  static const primary   = Color(0xFF6C63FF);
  static const secondary = Color(0xFF03DAC6);
  static const error     = Color(0xFFCF6679);
  static const bgDark    = Color(0xFF0A0A0F);
  static const surface   = Color(0xFF13131A);
  static const card      = Color(0xFF1C1C26);
  static const border    = Color(0xFF2A2A3A);
  static const white     = Color(0xFFFFFFFF);
  static const grey      = Color(0xFF9E9E9E);

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: white),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
    );
  }
}