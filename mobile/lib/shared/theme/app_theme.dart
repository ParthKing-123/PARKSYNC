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
  static const Color forestSurface    = Color(0xFF0D2D26); // Dark mode card surface (distinct elevation)
  static const Color forestElevated   = Color(0xFF143B33); // Dark mode raised card
  static const Color forestBase       = Color(0xFF051714); // Dark mode deep base
  static const Color forestShadow     = Color(0xFF000504); // Dark mode deep obsidian shadow
  static const Color forestHighlight  = Color(0xFF226759); // Dark mode top highlight

  // Supporting status accents
  static const Color success    = Color(0xFF10B981); // Emerald check
  static const Color amber      = Color(0xFFFFB800); // Warning/pending amber
  static const Color error      = Color(0xFFDC2626); // Alert red
  static const Color accentGold = Color(0xFFFFD54F); // Radiant Butter Gold for rates & badges

  // ── Backward-compatible Aliases (mapped to vibrant contrast tokens) ───
  static const Color cyan      = Color(0xFF2DD4BF); // Vibrant mint accent (visible on both dark & light)
  static const Color cyanLight = forestGreen;      // Replaced with Forest Green in light mode
  static const Color violet    = Color(0xFFFFD54F); // Radiant Butter Gold accent

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
  static const Color bgInputDark        = Color(0xFF0C241E);
  static const Color borderDark         = Color(0xFF1B4D41);

  static const Color textPrimaryDark    = butter;
  static const Color textSecondaryDark  = Color(0xFFD6EAE5); // Much brighter, crisp contrast
  static const Color textMutedDark      = Color(0xFFA5C9C1); // Highly readable muted tone

  // Semantic Helpers
  static Color rateColor(bool isDark) => isDark ? accentGold : forestGreen;
  static Color brandAccent(bool isDark) => isDark ? butter : forestGreen;

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
    double distance = 5.0,
    double blur = 14.0,
    double intensity = 1.0,
  }) {
    if (isDark) {
      return [
        // 1. Top-Left luminous emerald highlight reflection
        BoxShadow(
          color: const Color(0xFF1E5E50).withValues(alpha: 0.65 * intensity),
          offset: Offset(-distance, -distance),
          blurRadius: blur * 0.75,
          spreadRadius: 0,
        ),
        // 2. Bottom-Right deep obsidian cast shadow
        BoxShadow(
          color: const Color(0xFF000504).withValues(alpha: 0.95 * intensity),
          offset: Offset(distance, distance),
          blurRadius: blur,
          spreadRadius: 1,
        ),
        // 3. Ambient contact shadow
        BoxShadow(
          color: const Color(0xFF020D0B).withValues(alpha: 0.5 * intensity),
          offset: const Offset(0, 2),
          blurRadius: 4,
        ),
      ];
    } else {
      return [
        // 1. Top-Left luminous white reflection
        BoxShadow(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.95 * intensity),
          offset: Offset(-distance, -distance),
          blurRadius: blur * 0.7,
          spreadRadius: 0,
        ),
        // 2. Bottom-Right warm golden butter shadow
        BoxShadow(
          color: const Color(0xFFCEB070).withValues(alpha: 0.65 * intensity),
          offset: Offset(distance, distance),
          blurRadius: blur,
          spreadRadius: 1,
        ),
        // 3. Ambient warm depth
        BoxShadow(
          color: const Color(0xFFE2C889).withValues(alpha: 0.4 * intensity),
          offset: const Offset(1, 2),
          blurRadius: 4,
        ),
      ];
    }
  }

  static List<BoxShadow> neumorphicPressedShadows({
    required bool isDark,
    double distance = 3.0,
    double blur = 6.0,
  }) {
    if (isDark) {
      return [
        BoxShadow(
          color: const Color(0xFF000504).withValues(alpha: 0.9),
          offset: Offset(distance, distance),
          blurRadius: blur,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: const Color(0xFF184E43).withValues(alpha: 0.4),
          offset: Offset(-distance * 0.5, -distance * 0.5),
          blurRadius: blur * 0.5,
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: const Color(0xFFC7A965).withValues(alpha: 0.75),
          offset: Offset(distance, distance),
          blurRadius: blur,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.6),
          offset: Offset(-distance * 0.5, -distance * 0.5),
          blurRadius: blur * 0.5,
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
    bool useGradient = true,
  }) {
    final surfaceColor = color ?? (isDark ? bgSurfaceDark : bgSurfaceLight);

    // Physical convex surface lighting gradient
    Gradient? surfaceGradient;
    if (useGradient && color == null) {
      if (isDark) {
        surfaceGradient = isPressed
            ? const LinearGradient(
                colors: [Color(0xFF071E1A), Color(0xFF10362E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF143E35), Color(0xFF0A2621)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );
      } else {
        surfaceGradient = isPressed
            ? const LinearGradient(
                colors: [Color(0xFFF0DC9D), Color(0xFFFFFBE8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFFFFDF5), Color(0xFFF7E5B0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );
      }
    }

    return BoxDecoration(
      color: surfaceGradient == null ? surfaceColor : null,
      gradient: surfaceGradient,
      borderRadius: BorderRadius.circular(radius),
      border: border ??
          Border.all(
            color: isDark
                ? const Color(0xFF23695B).withValues(alpha: isPressed ? 0.3 : 0.65)
                : const Color(0xFFFFFFFF).withValues(alpha: isPressed ? 0.4 : 0.85),
            width: 1.0,
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
