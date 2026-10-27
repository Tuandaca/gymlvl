import 'package:flutter/material.dart';

/// Design tokens for Candy Neubrutalism visual system.
class CandyColors {
  CandyColors._();

  // Core Palette
  static const Color canvas = Color(0xFFFDF9F0);
  static const Color card = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF111111);
  static const Color hotPink = Color(0xFFFF3D81);
  static const Color canaryYellow = Color(0xFFFFD23F);
  static const Color mintGreen = Color(0xFF3DDC97);
  static const Color softLilac = Color(0xFFC8A2FF);
  static const Color coral = Color(0xFFFF6B5E);

  // Dark Candy Mode Tokens
  static const Color darkCanvas = Color(0xFF121216);
  static const Color darkCard = Color(0xFF1F1F27);
  static const Color darkInk = Color(0xFFFDF9F0);

  // Supporting Neutrals & Utility
  static const Color charcoal = Color(0xFF4A4A4A);
  static const Color muted = Color(0xFF7E7E7E);
  static const Color gridLine = Color(0x0D111111); // rgba(17,17,17,0.05)
  static const Color gridLineDark = Color(0x1AFFFFFF);

  // Geometry & Radii
  static const double borderWidth = 2.0;
  static const double cardRadius = 18.0;
  static const double pillRadius = 999.0;
  static const double buttonRadius = 16.0;

  static final BorderRadius cardBorderRadius = BorderRadius.circular(
    cardRadius,
  );
  static final BorderRadius pillBorderRadius = BorderRadius.circular(
    pillRadius,
  );
  static final BorderRadius buttonBorderRadius = BorderRadius.circular(
    buttonRadius,
  );

  // Borders
  static Border standardBorder({
    Color color = ink,
    double width = borderWidth,
  }) => Border.all(color: color, width: width);

  // Drop Shadows (hard zero-blur)
  static const Offset shadowSmallOffset = Offset(4, 4);
  static const Offset shadowMediumOffset = Offset(6, 6);
  static const Offset shadowLargeOffset = Offset(9, 9);
  static const Offset pressTranslation = Offset(2, 2);
  static const Offset pressedShadowOffset = Offset(2, 2);

  static List<BoxShadow> shadowSmall({Color color = ink}) => [
    BoxShadow(color: color, offset: shadowSmallOffset, blurRadius: 0.0),
  ];

  static List<BoxShadow> shadowMedium({Color color = ink}) => [
    BoxShadow(color: color, offset: shadowMediumOffset, blurRadius: 0.0),
  ];

  static List<BoxShadow> shadowLarge({Color color = ink}) => [
    BoxShadow(color: color, offset: shadowLargeOffset, blurRadius: 0.0),
  ];

  static List<BoxShadow> shadowPressed({Color color = ink}) => [
    BoxShadow(color: color, offset: pressedShadowOffset, blurRadius: 0.0),
  ];
}

/// Font family constants for Candy Neubrutalism.
class CandyFonts {
  CandyFonts._();

  static const String display = 'Archivo';
  static const String body = 'Space Grotesk';
  static const String mono = 'Space Mono';
  static const String fallback = 'Inter';
}

/// Interaction timings for tactile Neubrutalism micro-interactions.
class CandyTimings {
  CandyTimings._();

  static const Duration press = Duration(milliseconds: 100);
  static const Duration quick = Duration(milliseconds: 150);
  static const Duration modal = Duration(milliseconds: 200);
  static const Duration progress = Duration(milliseconds: 350);
}
