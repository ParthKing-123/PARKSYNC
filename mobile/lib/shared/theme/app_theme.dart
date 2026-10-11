import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Parking & Navigation Intuitive Theme
  static const Color backgroundDark = Color(0xFF0B0F19); // Midnight Asphalt
  static const Color surfaceDark = Color(0xFF151C2C); // Elevated Asphalt
  static const Color surfaceLight = Color(0xFF1E293B); // UI Elements
  
  // High contrast text
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  
  // Intuitive Accents (Navigation Blue & Road Paint Yellow)
  static const Color accent = Color(0xFF00E5FF); // Electric Digital Cyan (Navigation path)
  static const Color accentSecondary = Color(0xFFFFD600); // Neon Road Yellow (Markings)
  
  // Status Colors
  static const Color success = Color(0xFF00FFA3);
  static const Color error = Color(0xFFFF3366);
  static const Color warning = Color(0xFFFFB800);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: accent,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentSecondary,
        surface: surfaceDark,
        background: backgroundDark,
        error: error,
        onPrimary: backgroundDark,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.manropeTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.manrope(
          color: textPrimary,
          fontSize: 36,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.2,
          height: 1.1,
        ),
        displayMedium: GoogleFonts.manrope(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
        bodyLarge: GoogleFonts.manrope(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: GoogleFonts.manrope(
          color: textSecondary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: GoogleFonts.manrope(
          color: backgroundDark,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Softer cards
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: backgroundDark,
          elevation: 0,
          minimumSize: const Size.fromHeight(60), // Taller premium buttons
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100), // Pill shape buttons
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        hintStyle: GoogleFonts.manrope(color: textSecondary, fontWeight: FontWeight.w500),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100), // Pill shape inputs
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: const BorderSide(color: error, width: 2),
        ),
      ),
    );
  }
}
