import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Palette: Dark Mode ────────────────────────────────────────────────
  static const Color bgBaseDark     = Color(0xFF080B12); // Deep carbon base
  static const Color bgSurfaceDark  = Color(0xFF0F1420); // Cards & sheets
  static const Color bgElevatedDark = Color(0xFF171D2E); // Elevated containers
  static const Color bgInputDark    = Color(0xFF1C2336); // Input fields
  static const Color borderDark     = Color(0xFF1C2A42);

  static const Color textPrimaryDark   = Color(0xFFF0F4FF);
  static const Color textSecondaryDark = Color(0xFF8B9ABF);
  static const Color textMutedDark     = Color(0xFF4D5A7A);

  // ── Palette: Light Mode ───────────────────────────────────────────────
  static const Color bgBaseLight     = Color(0xFFF8FAFC); // Clean snow/slate base
  static const Color bgSurfaceLight  = Color(0xFFFFFFFF); // Pure white cards
  static const Color bgElevatedLight = Color(0xFFF1F5F9); // Light pill container
  static const Color bgInputLight    = Color(0xFFF1F5F9); // Crisp inputs
  static const Color borderLight     = Color(0xFFE2E8F0);

  static const Color textPrimaryLight   = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight     = Color(0xFF94A3B8);

  // Common aliases (defaulting to dark base tokens)
  static const Color bgBase        = bgBaseDark;
  static const Color bgSurface     = bgSurfaceDark;
  static const Color bgElevated    = bgElevatedDark;
  static const Color bgInput       = bgInputDark;
  static const Color textPrimary   = textPrimaryDark;
  static const Color textSecondary = textSecondaryDark;
  static const Color textMuted     = textMutedDark;

  // ── Brand Accents ─────────────────────────────────────────────────────
  static const Color cyan   = Color(0xFF00D4FF); // Primary electric cyan
  static const Color cyanLight = Color(0xFF0284C7); // High-contrast cyan for light mode
  static const Color violet = Color(0xFF7C3AED); // Secondary rich violet
  static const Color amber  = Color(0xFFFFB800); // Tertiary amber
  static const Color success = Color(0xFF10B981);
  static const Color error   = Color(0xFFEF4444);

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
  );

  // ── Dark Theme ────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: bgBaseDark,
      primaryColor: cyan,
      colorScheme: const ColorScheme.dark(
        primary:                 cyan,
        secondary:               violet,
        tertiary:                amber,
        surface:                 bgSurfaceDark,
        surfaceContainerHighest: bgElevatedDark,
        error:                   error,
        onPrimary:               bgBaseDark,
        onSecondary:             textPrimaryDark,
        onSurface:               textPrimaryDark,
        outline:                 textMutedDark,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          color: textPrimaryDark,
          fontSize: 34,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.2,
          height: 1.15,
        ),
        displayMedium: GoogleFonts.inter(
          color: textPrimaryDark,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
        displaySmall: GoogleFonts.inter(
          color: textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        headlineMedium: GoogleFonts.inter(
          color: textPrimaryDark,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        bodyLarge: GoogleFonts.inter(
          color: textPrimaryDark,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          height: 1.45,
        ),
        bodyMedium: GoogleFonts.inter(
          color: textSecondaryDark,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          height: 1.45,
        ),
        bodySmall: GoogleFonts.inter(
          color: textMutedDark,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: GoogleFonts.inter(
          color: bgBaseDark,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: bgSurfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: borderDark, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cyan,
          foregroundColor: bgBaseDark,
          elevation: 0,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgInputDark,
        hintStyle: GoogleFonts.inter(
          color: textMutedDark,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: cyan, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bgSurfaceDark,
        elevation: 4,
        indicatorColor: cyan.withValues(alpha: 0.18),
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textSecondaryDark),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: cyan, size: 22);
          }
          return const IconThemeData(color: textMutedDark, size: 22);
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: borderDark,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // ── Light Theme ───────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: bgBaseLight,
      primaryColor: cyanLight,
      colorScheme: const ColorScheme.light(
        primary:                 cyanLight,
        secondary:               violet,
        tertiary:                amber,
        surface:                 bgSurfaceLight,
        surfaceContainerHighest: bgElevatedLight,
        error:                   error,
        onPrimary:               Colors.white,
        onSecondary:             Colors.white,
        onSurface:               textPrimaryLight,
        outline:                 textMutedLight,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          color: textPrimaryLight,
          fontSize: 34,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.2,
          height: 1.15,
        ),
        displayMedium: GoogleFonts.inter(
          color: textPrimaryLight,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
        displaySmall: GoogleFonts.inter(
          color: textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        headlineMedium: GoogleFonts.inter(
          color: textPrimaryLight,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        bodyLarge: GoogleFonts.inter(
          color: textPrimaryLight,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          height: 1.45,
        ),
        bodyMedium: GoogleFonts.inter(
          color: textSecondaryLight,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          height: 1.45,
        ),
        bodySmall: GoogleFonts.inter(
          color: textMutedLight,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: bgSurfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cyanLight,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgInputLight,
        hintStyle: GoogleFonts.inter(
          color: textMutedLight,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: cyanLight, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bgSurfaceLight,
        elevation: 4,
        indicatorColor: cyanLight.withValues(alpha: 0.15),
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textSecondaryLight),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: cyanLight, size: 22);
          }
          return const IconThemeData(color: textMutedLight, size: 22);
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
