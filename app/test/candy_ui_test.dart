import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Specification and contract for Candy Neubrutalism design tokens per PROJECT.md and TEST_INFRA.md.
class CandyTokenSpecification {
  // Core Neubrutalist Color Palette
  static const Color canvas = Color(0xFFFDF9F0);
  static const Color card = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF111111);
  static const Color hotPink = Color(0xFFFF3D81);
  static const Color canaryYellow = Color(0xFFFFD23F);
  static const Color mintGreen = Color(0xFF3DDC97);
  static const Color softLilac = Color(0xFFC8A2FF);
  static const Color coral = Color(0xFFFF6B5E);

  // Border & Shape Standards
  static const double borderWidth = 2.0;
  static const double cardRadius = 18.0;
  static const double pillRadius = 999.0;

  // Unblurred Hard Drop Shadow Constants
  static const Offset shadowSmall = Offset(4.0, 4.0);
  static const Offset shadowMedium = Offset(6.0, 6.0);
  static const Offset shadowLarge = Offset(9.0, 9.0);
  static const double shadowBlurRadius = 0.0; // Hard, unblurred shadow

  // Tactile Press Constants
  static const Duration pressDuration = Duration(milliseconds: 100);
  static const Offset pressTranslation = Offset(2.0, 2.0);
  static const Offset pressedShadowOffset = Offset(2.0, 2.0);
}

enum CandyButtonVariant { primary, secondary, mint, lilac, danger }

/// Reference tactile Neubrutalist button demonstrating contract behavior.
class TactileCandyButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final CandyButtonVariant variant;
  final IconData? icon;
  final bool isLoading;

  const TactileCandyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = CandyButtonVariant.primary,
    this.icon,
    this.isLoading = false,
  });

  Color get backgroundColor {
    switch (variant) {
      case CandyButtonVariant.primary:
        return CandyTokenSpecification.hotPink;
      case CandyButtonVariant.secondary:
        return CandyTokenSpecification.canaryYellow;
      case CandyButtonVariant.mint:
        return CandyTokenSpecification.mintGreen;
      case CandyButtonVariant.lilac:
        return CandyTokenSpecification.softLilac;
      case CandyButtonVariant.danger:
        return CandyTokenSpecification.coral;
    }
  }

  @override
  State<TactileCandyButton> createState() => _TactileCandyButtonState();
}

class _TactileCandyButtonState extends State<TactileCandyButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  void _onTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final translation = _isPressed
        ? CandyTokenSpecification.pressTranslation
        : Offset.zero;
    final shadowOffset = _isPressed
        ? CandyTokenSpecification.pressedShadowOffset
        : CandyTokenSpecification.shadowSmall;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: CandyTokenSpecification.pressDuration,
        transform: Matrix4.translationValues(translation.dx, translation.dy, 0),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CandyTokenSpecification.ink,
            width: CandyTokenSpecification.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: CandyTokenSpecification.ink,
              offset: shadowOffset,
              blurRadius: CandyTokenSpecification.shadowBlurRadius,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: CandyTokenSpecification.ink, size: 20),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                widget.label,
                style: const TextStyle(
                  color: CandyTokenSpecification.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reference Neubrutalist Card widget demonstrating contract behavior.
class CandyCardWidget extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final double borderWidth;
  final Offset shadowOffset;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const CandyCardWidget({
    super.key,
    required this.child,
    this.backgroundColor = CandyTokenSpecification.card,
    this.borderWidth = CandyTokenSpecification.borderWidth,
    this.shadowOffset = CandyTokenSpecification.shadowMedium,
    this.borderRadius = CandyTokenSpecification.cardRadius,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: CandyTokenSpecification.ink,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: CandyTokenSpecification.ink,
            offset: shadowOffset,
            blurRadius: CandyTokenSpecification.shadowBlurRadius,
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

void main() {
  group('Candy Neubrutalism Visual Tokens Verification', () {
    test('Palette hex codes match specification exactly', () {
      expect(CandyTokenSpecification.canvas.toARGB32(), 0xFFFDF9F0);
      expect(CandyTokenSpecification.card.toARGB32(), 0xFFFFFFFF);
      expect(CandyTokenSpecification.ink.toARGB32(), 0xFF111111);
      expect(CandyTokenSpecification.hotPink.toARGB32(), 0xFFFF3D81);
      expect(CandyTokenSpecification.canaryYellow.toARGB32(), 0xFFFFD23F);
      expect(CandyTokenSpecification.mintGreen.toARGB32(), 0xFF3DDC97);
      expect(CandyTokenSpecification.softLilac.toARGB32(), 0xFFC8A2FF);
      expect(CandyTokenSpecification.coral.toARGB32(), 0xFFFF6B5E);
    });

    test('Borders and shadows conform to Neubrutalist rules', () {
      expect(CandyTokenSpecification.borderWidth, 2.0);
      expect(CandyTokenSpecification.cardRadius, 18.0);
      expect(CandyTokenSpecification.shadowBlurRadius, 0.0);
      expect(CandyTokenSpecification.shadowSmall, const Offset(4.0, 4.0));
      expect(CandyTokenSpecification.shadowMedium, const Offset(6.0, 6.0));
      expect(CandyTokenSpecification.shadowLarge, const Offset(9.0, 9.0));
    });

    test('Luminance and contrast ratios meet accessibility standards', () {
      double relativeLuminance(Color c) {
        double channel(double s) {
          return s <= 0.03928
              ? s / 12.92
              : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
        }

        return 0.2126 * channel(c.r) +
            0.7152 * channel(c.g) +
            0.0722 * channel(c.b);
      }

      double contrastRatio(Color c1, Color c2) {
        final l1 = relativeLuminance(c1);
        final l2 = relativeLuminance(c2);
        final lighter = math.max(l1, l2);
        final darker = math.min(l1, l2);
        return (lighter + 0.05) / (darker + 0.05);
      }

      // Ink (#111111) on Canvas (#FDF9F0) must exceed WCAG AAA (7.0:1)
      final inkOnCanvas = contrastRatio(
        CandyTokenSpecification.ink,
        CandyTokenSpecification.canvas,
      );
      expect(inkOnCanvas, greaterThan(14.0));

      // Ink (#111111) on Canary Yellow (#FFD23F) must exceed 7.0:1
      final inkOnYellow = contrastRatio(
        CandyTokenSpecification.ink,
        CandyTokenSpecification.canaryYellow,
      );
      expect(inkOnYellow, greaterThan(10.0));

      // Ink (#111111) on Mint Green (#3DDC97) must exceed 7.0:1
      final inkOnMint = contrastRatio(
        CandyTokenSpecification.ink,
        CandyTokenSpecification.mintGreen,
      );
      expect(inkOnMint, greaterThan(8.0));
    });

    testWidgets(
      'CandyCardWidget renders 2px ink border, 18px radius, and hard drop shadow',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CandyCardWidget(child: Text('Candy Card Content')),
            ),
          ),
        );

        final containerFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).border != null &&
              (widget.decoration as BoxDecoration).boxShadow != null,
        );

        expect(containerFinder, findsOneWidget);
        final container = tester.widget<Container>(containerFinder);
        final decoration = container.decoration as BoxDecoration;

        // Assert 2px solid #111111 border
        final border = decoration.border as Border;
        expect(border.top.color, CandyTokenSpecification.ink);
        expect(border.top.width, 2.0);

        // Assert 18px radius
        final borderRadius = decoration.borderRadius as BorderRadius;
        expect(borderRadius.topLeft.x, 18.0);

        // Assert hard, unblurred drop shadow
        final shadow = decoration.boxShadow!.first;
        expect(shadow.color, CandyTokenSpecification.ink);
        expect(shadow.blurRadius, 0.0);
        expect(shadow.offset, const Offset(6.0, 6.0));
      },
    );
  });

  group('Tactile Button Press Simulation', () {
    testWidgets(
      'Button translates downward-right and reduces shadow when pressed',
      (tester) async {
        var pressedCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: TactileCandyButton(
                  label: 'Tập Luyện',
                  variant: CandyButtonVariant.primary,
                  onPressed: () => pressedCount++,
                ),
              ),
            ),
          ),
        );

        // 1. Initial resting state: translation is zero, shadow is (4, 4)
        final initialContainerFinder = find.byType(AnimatedContainer);
        expect(initialContainerFinder, findsOneWidget);
        var container = tester.widget<AnimatedContainer>(
          initialContainerFinder,
        );
        expect(container.transform, Matrix4.translationValues(0, 0, 0));
        var decoration = container.decoration as BoxDecoration;
        expect(decoration.boxShadow!.first.offset, const Offset(4.0, 4.0));
        expect(decoration.boxShadow!.first.blurRadius, 0.0);

        // 2. Simulate pointer down (press)
        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(TactileCandyButton)),
        );
        await tester.pump(const Duration(milliseconds: 100)); // Animate press

        // Verify pressed state: translated by (2, 2), shadow reduced to (2, 2)
        container = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        expect(container.transform, Matrix4.translationValues(2.0, 2.0, 0));
        decoration = container.decoration as BoxDecoration;
        expect(decoration.boxShadow!.first.offset, const Offset(2.0, 2.0));
        expect(decoration.color, CandyTokenSpecification.hotPink);

        // 3. Simulate pointer up (release)
        await gesture.up();
        await tester.pumpAndSettle();

        // Verify return to resting state
        container = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        expect(container.transform, Matrix4.translationValues(0, 0, 0));
        decoration = container.decoration as BoxDecoration;
        expect(decoration.boxShadow!.first.offset, const Offset(4.0, 4.0));

        // Assert click callback fired
        expect(pressedCount, 1);
      },
    );

    testWidgets(
      'Disabled / loading button does not translate or trigger callback',
      (tester) async {
        var pressedCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: TactileCandyButton(
                  label: 'Đang tải...',
                  isLoading: true,
                  onPressed: () => pressedCount++,
                ),
              ),
            ),
          ),
        );

        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(TactileCandyButton)),
        );
        await tester.pump(const Duration(milliseconds: 100));

        // Transform must remain zero
        final container = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        expect(container.transform, Matrix4.translationValues(0, 0, 0));

        await gesture.up();
        await tester.pumpAndSettle();
        expect(pressedCount, 0);
      },
    );
  });

  group('Responsive Layout at 320px Mobile Viewport', () {
    testWidgets(
      'Neubrutalist dashboard card and tactile controls layout cleanly at 320px',
      (tester) async {
        // Set to 320px ultra-compact mobile viewport
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              scaffoldBackgroundColor: CandyTokenSpecification.canvas,
            ),
            home: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero Level Card
                    CandyCardWidget(
                      backgroundColor: CandyTokenSpecification.card,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  'CHIẾN BINH LVL 12',
                                  style: TextStyle(
                                    color: CandyTokenSpecification.ink,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: CandyTokenSpecification.canaryYellow,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: CandyTokenSpecification.ink,
                                    width: 2,
                                  ),
                                ),
                                child: const Text(
                                  '+350 XP',
                                  style: TextStyle(
                                    color: CandyTokenSpecification.ink,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Bilingual exercise description with diacritics
                          const Text(
                            'Đẩy Ngực Trên Với Tạ Đơn (Incline Dumbbell Bench Press)',
                            style: TextStyle(
                              color: CandyTokenSpecification.ink,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // KPI Grid inside 320px width
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: CandyTokenSpecification.mintGreen,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: CandyTokenSpecification.ink,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Column(
                                    children: [
                                      Text(
                                        'KHỐI LƯỢNG',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '1,250 kg',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: CandyTokenSpecification.softLilac,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: CandyTokenSpecification.ink,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Column(
                                    children: [
                                      Text(
                                        'CHUỖI NGÀY',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '7 NGÀY',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Primary CTA Button spanning full width
                    TactileCandyButton(
                      label: 'Bắt Đầu Tập Luyện',
                      variant: CandyButtonVariant.primary,
                      icon: Icons.fitness_center,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Verify no overflow exceptions occurred during render
        expect(tester.takeException(), isNull);
        expect(find.text('CHIẾN BINH LVL 12'), findsOneWidget);
        expect(find.text('Bắt Đầu Tập Luyện'), findsOneWidget);
        expect(find.text('1,250 kg'), findsOneWidget);
      },
    );

    testWidgets(
      'Large text scale factor (1.5x) does not crash or overflow at 320px',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                textScaler: TextScaler.linear(1.5),
                size: Size(320, 640),
              ),
              child: Scaffold(
                body: SingleChildScrollView(
                  child: CandyCardWidget(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Cơ ngực & Tay sau',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TactileCandyButton(
                          label: 'Xong Hiệp',
                          variant: CandyButtonVariant.mint,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('Cơ ngực & Tay sau'), findsOneWidget);
        expect(find.text('Xong Hiệp'), findsOneWidget);
      },
    );
  });
}
