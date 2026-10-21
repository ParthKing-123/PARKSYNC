import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ParkSync Master Design System:
/// Minimalist Neumorphic theme built with Butter (#FFEFB3) and Forest Green (#013E37).
/// Headings: Bodoni Moda (Bodoni Oldstyle)
/// Body & Controls: DM Sans (Neometric)
class AppTheme {
  // ── Brand Tokens ──────────────────────────────────────────────────────
  static const Color butter           = Color(0xFFFFEFB3); // Primary butter #ffefb3
  static const Color butterCream      = Color(0xFFFFF6D1); // Soft card surface
  static const Color butterElevated   = Color(0xFFFFFBE8); // Lighter raised surface
  static const Color butterInput      = Color(0xFFFEEDBA); // Slightly sunken input
  static const Color butterShadow     = Color(0xFFDFC68A); // Organic warm drop shadow
  static const Color butterHighlight  = Color(0xFFFFFFFC); // Top-left soft highlight

  static const Color forestGreen      = Color(0xFF013E37); // Primary deep forest #013e37
  static const Color forestGreenDark  = Color(0xFF002722); // Deepest forest
  static const Color forestGreenLight = Color(0xFF0A584F); // Rich forest emerald
  static const Color forestEmerald    = Color(0xFF157B6E); // Vibrant mid-green
  static const Color forestSurface    = Color(0xFF0D2520); // Dark mode card surface
  static const Color forestElevated   = Color(0xFF15332C); // Dark mode raised card
  static const Color forestBase       = Color(0xFF071714); // Dark mode deep base
  static const Color forestShadow     = Color(0xFF020907); // Dark mode deep shadow
  static const Color forestHighlight  = Color(0xFF1B4239); // Dark mode top highlight

  // Supporting status accents
  static const Color success = Color(0xFF10B981); // Emerald check
  static const Color amber   = Color(0xFFFFB800); // Warning/pending amber
  static const Color error   = Color(0xFFDC2626); // Alert red

  // ── Backward-compatible Aliases (mapped to Butter & Forest Green) ─────
  static const Color cyan      = forestGreen;      // Replaced with Forest Green
  static const Color cyanLight = forestGreen;      // Replaced with Forest Green
  static const Color violet    = forestGreenLight; // Replaced with Forest Emerald

  // ── Palette: Light Mode (Butter Base) ─────────────────────────────────
  static const Color bgBaseLight        = butter;
  static const Color bgSurfaceLight     = butterCream;
  static const Color bgElevatedLight    = butterElevated;
  static const Color bgInputLight       = butterInput;
  static const Color borderLight        = Color(0xFFE8D49B);

  static const Color textPrimaryLight   = forestGreen;
  static const Color textSecondaryLight = Color(0xFF2C564F);
  static const Color textMutedLight     = Color(0xFF6E8F88);

  // ── Palette: Dark Mode (Forest Base) ──────────────────────────────────
  static const Color bgBaseDark         = forestBase;
  static const Color bgSurfaceDark      = forestSurface;
  static const Color bgElevatedDark     = forestElevated;
  static const Color bgInputDark        = Color(0xFF102A24);
  static const Color borderDark         = Color(0xFF1B3D35);

  static const Color textPrimaryDark    = butter;
  static const Color textSecondaryDark  = Color(0xFFB8D3CC);
  static const Color textMutedDark      = Color(0xFF6C8C85);

  // Common aliases (defaults)
  static const Color bgBase        = bgBaseLight;
  static const Color bgSurface     = bgSurfaceLight;
  static const Color bgElevated    = bgElevatedLight;
  static const Color bgInput       = bgInputLight;
  static const Color textPrimary   = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color textMuted     = textMutedLight;

  static const LinearGradient forestGradient = LinearGradient(
    colors: [forestGreen, forestGreenLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient butterGradient = LinearGradient(
    colors: [butter, butterElevated],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = forestGradient; // Backward-compatible alias

  // ── Neumorphic Shadow Generators ──────────────────────────────────────
  static List<BoxShadow> neumorphicShadows({
    required bool isDark,
    double distance = 4.0,
    double blur = 10.0,
    double intensity = 1.0,
  }) {
    if (isDark) {
      return [
        BoxShadow(
          color: forestHighlight.withValues(alpha: 0.45 * intensity),
          offset: Offset(-distance, -distance),
          blurRadius: blur,
        ),
        BoxShadow(
          color: forestShadow.withValues(alpha: 0.75 * intensity),
          offset: Offset(distance, distance),
          blurRadius: blur,
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: butterHighlight.withValues(alpha: 0.95 * intensity),
          offset: Offset(-distance, -distance),
          blurRadius: blur,
        ),
        BoxShadow(
          color: butterShadow.withValues(alpha: 0.60 * intensity),
          offset: Offset(distance, distance),
          blurRadius: blur,
        ),
      ];
    }
  }

  static List<BoxShadow> neumorphicPressedShadows({
    required bool isDark,
    double distance = 2.0,
    double blur = 5.0,
  }) {
    if (isDark) {
      return [
        BoxShadow(
          color: forestShadow.withValues(alpha: 0.7),
          offset: Offset(distance, distance),
          blurRadius: blur,
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: butterShadow.withValues(alpha: 0.55),
          offset: Offset(distance, distance),
          blurRadius: blur,
        ),
      ];
    }
  }

  static BoxDecoration neumorphicBox({
    required bool isDark,
    bool isPressed = false,
    double radius = 18.0,
    Color? color,
    Border? border,
  }) {
    final surfaceColor = color ?? (isDark ? bgSurfaceDark : bgSurfaceLight);
    return BoxDecoration(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(radius),
      border: border ??
          Border.all(
            color: isDark
                ? forestHighlight.withValues(alpha: 0.3)
                : butterHighlight.withValues(alpha: 0.6),
            width: 0.8,
          ),
      boxShadow: isPressed
          ? neumorphicPressedShadows(isDark: isDark)
          : neumorphicShadows(isDark: isDark),
    );
  }

  // ── Light Theme (Butter Background & Forest Green Accents) ───────────
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: bgBaseLight,
      primaryColor: forestGreen,
      colorScheme: const ColorScheme.light(
        primary:                 forestGreen,
        secondary:               forestGreenLight,
        tertiary:                amber,
        surface:                 bgSurfaceLight,
        surfaceContainerHighest: bgElevatedLight,
        error:                   error,
        onPrimary:               butter,
        onSecondary:             Colors.white,
        onSurface:               textPrimaryLight,
        outline:                 textMutedLight,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.bodoniModa(
          color: textPrimaryLight,
          fontSize: 34,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
          height: 1.15,
        ),
        displayMedium: GoogleFonts.bodoniModa(
          color: textPrimaryLight,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
        ),
        displaySmall: GoogleFonts.bodoniModa(
          color: textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        headlineMedium: GoogleFonts.bodoniModa(
          color: textPrimaryLight,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: GoogleFonts.bodoniModa(
          color: textPrimaryLight,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.bodoniModa(
          color: textPrimaryLight,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: GoogleFonts.dmSans(
          color: textPrimaryLight,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          height: 1.45,
        ),
        bodyMedium: GoogleFonts.dmSans(
          color: textSecondaryLight,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          height: 1.45,
        ),
        bodySmall: GoogleFonts.dmSans(
          color: textMutedLight,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: GoogleFonts.dmSans(
          color: butter,
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
          backgroundColor: forestGreen,
          foregroundColor: butter,
          elevation: 0,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgInputLight,
        hintStyle: GoogleFonts.dmSans(
          color: textMutedLight,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: forestGreen, width: 1.8),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bgSurfaceLight,
        elevation: 0,
        indicatorColor: forestGreen.withValues(alpha: 0.12),
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textSecondaryLight),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: forestGreen, size: 23);
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

  // ── Dark Theme (Forest Base & Luminous Butter Accents) ────────────────
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: bgBaseDark,
      primaryColor: butter,
      colorScheme: const ColorScheme.dark(
        primary:                 butter,
        secondary:               forestEmerald,
        tertiary:                amber,
        surface:                 bgSurfaceDark,
        surfaceContainerHighest: bgElevatedDark,
        error:                   error,
        onPrimary:               forestGreenDark,
        onSecondary:             Colors.white,
        onSurface:               textPrimaryDark,
        outline:                 textMutedDark,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.bodoniModa(
          color: textPrimaryDark,
          fontSize: 34,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
          height: 1.15,
        ),
        displayMedium: GoogleFonts.bodoniModa(
          color: textPrimaryDark,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
        ),
        displaySmall: GoogleFonts.bodoniModa(
          color: textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        headlineMedium: GoogleFonts.bodoniModa(
          color: textPrimaryDark,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: GoogleFonts.bodoniModa(
          color: textPrimaryDark,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.bodoniModa(
          color: textPrimaryDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: GoogleFonts.dmSans(
          color: textPrimaryDark,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          height: 1.45,
        ),
        bodyMedium: GoogleFonts.dmSans(
          color: textSecondaryDark,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          height: 1.45,
        ),
        bodySmall: GoogleFonts.dmSans(
          color: textMutedDark,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: GoogleFonts.dmSans(
          color: forestGreenDark,
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
          backgroundColor: butter,
          foregroundColor: forestGreenDark,
          elevation: 0,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgInputDark,
        hintStyle: GoogleFonts.dmSans(
          color: textMutedDark,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: butter, width: 1.8),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bgSurfaceDark,
        elevation: 0,
        indicatorColor: butter.withValues(alpha: 0.18),
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textSecondaryDark),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: butter, size: 23);
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
}
