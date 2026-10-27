import 'package:flutter/material.dart';
import 'candy_colors.dart';
import 'candy_theme.dart';

class AppTheme {
  // Core colors mapped to Candy Neubrutalism
  static const Color background = CandyColors.canvas;
  static const Color panelBackground = CandyColors.card;
  static const Color cyanNeon = CandyColors.hotPink;
  static const Color darkCyan = Color(0xFF2B0A1A);
  static const Color purpleNeon = CandyColors.softLilac;
  static const Color successGreen = CandyColors.mintGreen;
  static const Color dangerOrange = CandyColors.coral;
  static const Color textMain = CandyColors.ink;
  static const Color textDim = CandyColors.charcoal;
  static const Color warningYellow = CandyColors.canaryYellow;
  static const Color goldWarning = CandyColors.canaryYellow;

  // Candy Theme accessors
  static ThemeData get lightTheme => CandyTheme.lightTheme;
  static ThemeData get candyTheme => CandyTheme.lightTheme;
  static ThemeData get darkCandyTheme => CandyTheme.darkTheme;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF030308),
      visualDensity: VisualDensity.standard,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: const Color(0xFF030308),
          textStyle: const TextStyle(
            fontFamily: CandyFonts.body,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      colorScheme: const ColorScheme.dark(
        primary: CandyColors.hotPink,
        secondary: CandyColors.softLilac,
        surface: Color(0xD90A0D1A),
        error: CandyColors.coral,
      ),
      textTheme: ThemeData.dark().textTheme
          .apply(fontFamily: CandyFonts.body)
          .copyWith(
            displayLarge: const TextStyle(
              fontFamily: CandyFonts.display,
              color: CandyColors.hotPink,
              fontWeight: FontWeight.w900,
            ),
            displayMedium: const TextStyle(
              fontFamily: CandyFonts.display,
              color: CandyColors.hotPink,
              fontWeight: FontWeight.w900,
            ),
            displaySmall: const TextStyle(
              fontFamily: CandyFonts.display,
              color: CandyColors.hotPink,
              fontWeight: FontWeight.w900,
            ),
            headlineLarge: const TextStyle(
              fontFamily: CandyFonts.display,
              color: Color(0xFFE2E8F0),
              fontWeight: FontWeight.w800,
            ),
            headlineMedium: const TextStyle(
              fontFamily: CandyFonts.display,
              color: Color(0xFFE2E8F0),
              fontWeight: FontWeight.w800,
            ),
            headlineSmall: const TextStyle(
              fontFamily: CandyFonts.display,
              color: Color(0xFFE2E8F0),
              fontWeight: FontWeight.w800,
            ),
            titleLarge: const TextStyle(
              fontFamily: CandyFonts.display,
              color: Color(0xFFE2E8F0),
              fontWeight: FontWeight.w700,
            ),
            bodyLarge: const TextStyle(
              fontFamily: CandyFonts.body,
              color: Color(0xFFE2E8F0),
            ),
            bodyMedium: const TextStyle(
              fontFamily: CandyFonts.body,
              color: Color(0xFFE2E8F0),
            ),
            bodySmall: const TextStyle(
              fontFamily: CandyFonts.body,
              color: Color(0xFF94A3B8),
            ),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: CandyFonts.display,
          color: Color(0xFFE2E8F0),
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
