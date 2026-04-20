import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core colors (Solo Leveling & Cyberpunk Aesthetic)
  static const Color background = Color(0xFF030308); // Deepest void black
  static const Color panelBackground = Color(0xD90A0D1A);
  static const Color cyanNeon = Color(0xFF00E5FF);
  static const Color darkCyan = Color.fromARGB(255, 0, 40, 60);
  static const Color purpleNeon = Color(0xFFD500F9); // More vibrant magenta-purple
  static const Color successGreen = Color(0xFF00E676);
  static const Color dangerOrange = Color(0xFFFF3D00); // More blood red/orange
  static const Color textMain = Color(0xFFE2E8F0);
  static const Color textDim = Color(0xFF64748B);

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
          color: textMain,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
      ),
    );
  }
}
