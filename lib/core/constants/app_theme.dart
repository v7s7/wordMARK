import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Tile colors - dark mode
  static const correct = Color(0xFF538D4E);
  static const present = Color(0xFFB59F3B);
  static const absent = Color(0xFF3A3A3C);
  static const emptyBorder = Color(0xFF3A3A3C);
  static const tbdBorder = Color(0xFF565758);

  // Tile colors - light mode
  static const correctLight = Color(0xFF6AAA64);
  static const presentLight = Color(0xFFC9B458);
  static const absentLight = Color(0xFF787C7E);
  static const emptyBorderLight = Color(0xFFD3D6DA);
  static const tbdBorderLight = Color(0xFF878A8C);

  // Keyboard
  static const keyDark = Color(0xFF818384);
  static const keyLight = Color(0xFFD3D6DA);

  // Backgrounds
  static const darkBg = Color(0xFF121213);
  static const lightBg = Color(0xFFFFFFFF);
  static const darkSurface = Color(0xFF1A1A1B);
  static const darkCard = Color(0xFF262626);

  // Brand
  static const premium = Color(0xFFFFD700);
  static const accent = Color(0xFF538D4E);
}

class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.correct,
        surface: AppColors.darkSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 5,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF3A3A3C)),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      cardColor: AppColors.darkCard,
    );
  }

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.correctLight,
        surface: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: Colors.black,
          letterSpacing: 5,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFD3D6DA)),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      cardColor: const Color(0xFFF5F5F5),
    );
  }
}
