import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core colors
  static const Color background = Color(0xFF0A0A12);
  static const Color panelBackground = Color(0xD90D1423); // 85% opacity
  static const Color cyanNeon = Color(0xFF00E5FF);
  static const Color darkCyan = Color.fromARGB(255, 0, 80, 90);
  static const Color purpleNeon = Color(0xFF7C4DFF);
  static const Color successGreen = Color(0xFF00E676);
  static const Color dangerOrange = Color(0xFFFF6D00);
  static const Color warningYellow = Color(0xFFFFD600);
  static const Color textMain = Color(0xFFE0E0E0);
  static const Color textDim = Color(0xFF8B949E);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: cyanNeon,
        secondary: purpleNeon,
        background: background,
        surface: panelBackground,
        error: dangerOrange,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.orbitron(color: cyanNeon, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.orbitron(color: cyanNeon, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.orbitron(color: cyanNeon, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.orbitron(color: textMain, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.orbitron(color: textMain, fontWeight: FontWeight.bold),
        headlineSmall: GoogleFonts.orbitron(color: textMain, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.orbitron(color: textMain, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(color: textMain),
        bodyMedium: GoogleFonts.inter(color: textMain),
        bodySmall: GoogleFonts.inter(color: textDim),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.orbitron(
          color: textMain, // Using textMain since cyanNeon was undefined in this scope if defined inside the class methods.
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
      ),
    );
  }
}
