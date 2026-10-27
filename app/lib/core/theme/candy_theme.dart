import 'package:flutter/material.dart';
import 'candy_colors.dart';

/// Complete ThemeData configurations for Candy Neubrutalism.
class CandyTheme {
  CandyTheme._();

  /// Default Candy Neubrutalism Theme (alias to lightTheme).
  static ThemeData get theme => lightTheme;

  /// Primary Candy Neubrutalism Light (Canvas) Theme.
  static ThemeData get lightTheme {
    final textTheme = _buildTextTheme(isDark: false);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: CandyColors.canvas,
      cardColor: CandyColors.card,
      canvasColor: CandyColors.canvas,
      fontFamily: CandyFonts.body,
      colorScheme: const ColorScheme.light(
        primary: CandyColors.hotPink,
        onPrimary: Colors.white,
        secondary: CandyColors.canaryYellow,
        onSecondary: CandyColors.ink,
        tertiary: CandyColors.mintGreen,
        onTertiary: CandyColors.ink,
        surface: CandyColors.card,
        onSurface: CandyColors.ink,
        error: CandyColors.coral,
        onError: Colors.white,
        outline: CandyColors.ink,
        shadow: CandyColors.ink,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: CandyColors.ink),
        actionsIconTheme: IconThemeData(color: CandyColors.ink),
        titleTextStyle: TextStyle(
          fontFamily: CandyFonts.display,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: CandyColors.ink,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: CandyColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: CandyColors.cardBorderRadius,
          side: const BorderSide(
            color: CandyColors.ink,
            width: CandyColors.borderWidth,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: CandyColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: CandyColors.cardBorderRadius,
          side: const BorderSide(
            color: CandyColors.ink,
            width: CandyColors.borderWidth,
          ),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: CandyFonts.display,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: CandyColors.ink,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: CandyFonts.body,
          fontSize: 15,
          color: CandyColors.ink,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: CandyColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          side: BorderSide(
            color: CandyColors.ink,
            width: CandyColors.borderWidth,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CandyColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(
            color: CandyColors.ink,
            width: CandyColors.borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(
            color: CandyColors.ink,
            width: CandyColors.borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(color: CandyColors.hotPink, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(
            color: CandyColors.coral,
            width: CandyColors.borderWidth,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(color: CandyColors.coral, width: 2.5),
        ),
        labelStyle: const TextStyle(
          fontFamily: CandyFonts.body,
          color: CandyColors.charcoal,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(
          fontFamily: CandyFonts.body,
          color: CandyColors.muted,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: CandyColors.ink,
        thickness: CandyColors.borderWidth,
        space: 1,
      ),
    );
  }

  /// Dark Candy Neubrutalism Theme.
  static ThemeData get darkTheme {
    final textTheme = _buildTextTheme(isDark: true);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: CandyColors.darkCanvas,
      cardColor: CandyColors.darkCard,
      canvasColor: CandyColors.darkCanvas,
      fontFamily: CandyFonts.body,
      colorScheme: const ColorScheme.dark(
        primary: CandyColors.hotPink,
        onPrimary: Colors.white,
        secondary: CandyColors.canaryYellow,
        onSecondary: CandyColors.ink,
        tertiary: CandyColors.mintGreen,
        onTertiary: CandyColors.ink,
        surface: CandyColors.darkCard,
        onSurface: CandyColors.darkInk,
        error: CandyColors.coral,
        onError: Colors.white,
        outline: CandyColors.darkInk,
        shadow: Colors.black,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: CandyColors.darkInk),
        actionsIconTheme: IconThemeData(color: CandyColors.darkInk),
        titleTextStyle: TextStyle(
          fontFamily: CandyFonts.display,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: CandyColors.darkInk,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: CandyColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: CandyColors.cardBorderRadius,
          side: const BorderSide(
            color: CandyColors.darkInk,
            width: CandyColors.borderWidth,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: CandyColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: CandyColors.cardBorderRadius,
          side: const BorderSide(
            color: CandyColors.darkInk,
            width: CandyColors.borderWidth,
          ),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: CandyFonts.display,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: CandyColors.darkInk,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: CandyFonts.body,
          fontSize: 15,
          color: CandyColors.darkInk,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: CandyColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          side: BorderSide(
            color: CandyColors.darkInk,
            width: CandyColors.borderWidth,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CandyColors.darkCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(
            color: CandyColors.darkInk,
            width: CandyColors.borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(
            color: CandyColors.darkInk,
            width: CandyColors.borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(color: CandyColors.hotPink, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(
            color: CandyColors.coral,
            width: CandyColors.borderWidth,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(color: CandyColors.coral, width: 2.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: CandyColors.darkInk,
        thickness: CandyColors.borderWidth,
        space: 1,
      ),
    );
  }

  static TextTheme _buildTextTheme({required bool isDark}) {
    final textColor = isDark ? CandyColors.darkInk : CandyColors.ink;
    final mutedColor = isDark ? CandyColors.muted : CandyColors.charcoal;

    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: CandyFonts.display,
        fontSize: 34,
        fontWeight: FontWeight.w900,
        color: textColor,
        height: 1.15,
      ),
      displayMedium: TextStyle(
        fontFamily: CandyFonts.display,
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: textColor,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontFamily: CandyFonts.display,
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: textColor,
        height: 1.2,
      ),
      headlineLarge: TextStyle(
        fontFamily: CandyFonts.display,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: CandyFonts.display,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: textColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: CandyFonts.display,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: textColor,
      ),
      titleLarge: TextStyle(
        fontFamily: CandyFonts.display,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontFamily: CandyFonts.body,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      titleSmall: TextStyle(
        fontFamily: CandyFonts.body,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: CandyFonts.body,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.4,
      ),
      bodyMedium: TextStyle(
        fontFamily: CandyFonts.body,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontFamily: CandyFonts.body,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: mutedColor,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontFamily: CandyFonts.body,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      labelMedium: TextStyle(
        fontFamily: CandyFonts.mono,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      labelSmall: TextStyle(
        fontFamily: CandyFonts.mono,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: mutedColor,
      ),
    );
  }
}
