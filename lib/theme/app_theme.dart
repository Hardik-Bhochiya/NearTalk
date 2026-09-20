import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Pure GitHub Dark Color Palette
  static const Color githubBg = Color(0xFF0D1117);
  static const Color githubCard = Color(0xFF161B22);
  static const Color githubElevated = Color(0xFF21262D);
  static const Color githubBorder = Color(0xFF30363D);
  static const Color githubTextPrimary = Color(0xFFF0F6FC);
  static const Color githubTextSecondary = Color(0xFF8B949E);
  static const Color githubBlue = Color(0xFF58A6FF);
  static const Color githubGreen = Color(0xFF238636);
  static const Color githubGreenBright = Color(0xFF2EA043);
  static const Color githubPurple = Color(0xFF8957E5);
  static const Color githubRed = Color(0xFFDA3633);
  static const Color githubOrange = Color(0xFFD29922);

  // Brand aliases
  static const Color primaryColor = githubBlue;
  static const Color primaryLight = githubBlue;
  static const Color secondaryColor = githubGreen;
  static const Color accentOrange = githubOrange;
  static const Color accentRose = githubRed;

  static const Color darkBg = githubBg;
  static const Color darkCard = githubCard;
  static const Color darkCardElevated = githubElevated;
  static const Color darkBorder = githubBorder;
  static const Color darkTextPrimary = githubTextPrimary;
  static const Color darkTextSecondary = githubTextSecondary;

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: githubBg,
      primaryColor: githubBlue,
      canvasColor: githubBg,
      colorScheme: const ColorScheme.dark(
        primary: githubBlue,
        secondary: githubGreen,
        surface: githubCard,
        error: githubRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: githubTextPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: githubTextPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: githubTextPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: githubTextPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 14.5,
          color: githubTextPrimary,
          height: 1.45,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          color: githubTextSecondary,
          height: 1.4,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: githubBg,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        iconTheme: IconThemeData(color: githubTextPrimary),
        titleTextStyle: TextStyle(
          color: githubTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: githubCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: githubBorder, width: 1.2),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: githubGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0x33FFFFFF), width: 1),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: githubTextPrimary,
          backgroundColor: githubElevated,
          side: const BorderSide(color: githubBorder, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: githubElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.inter(
          color: githubTextSecondary,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.inter(
          color: githubTextSecondary,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: githubBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: githubBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: githubBlue, width: 1.8),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: githubBorder,
        thickness: 1,
      ),
    );
  }

  // Pure GitHub Dark enforced - no light theme!
  static ThemeData get lightTheme => darkTheme;
}
