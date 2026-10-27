import 'package:flutter/material.dart';
import '../../core/theme/candy_colors.dart';

/// Lightweight custom painter drawing a 24px subtle Neubrutalist grid overlay.
class CandyGridPainter extends CustomPainter {
  final Color gridColor;
  final double step;

  const CandyGridPainter({
    this.gridColor = CandyColors.gridLine,
    this.step = 24.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CandyGridPainter oldDelegate) =>
      oldDelegate.gridColor != gridColor || oldDelegate.step != step;
}

/// Full screen Scaffold featuring Candy warm canvas background,
/// subtle 24px grid painter, and optional custom Neubrutalist App Bar.
class CandyScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Widget? drawer;
  final Color backgroundColor;
  final bool gridBackground;
  final bool safeArea;
  final bool? resizeToAvoidBottomInset;

  const CandyScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.drawer,
    this.backgroundColor = CandyColors.canvas,
    this.gridBackground = true,
    this.safeArea = true,
    this.resizeToAvoidBottomInset,
  });

  @override
  Widget build(BuildContext context) {
    Widget? content = body;
    if (content != null && safeArea) {
      content = SafeArea(child: content);
    }

    Widget scaffoldBody = Stack(
      children: [
        if (gridBackground)
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(painter: const CandyGridPainter()),
            ),
          ),
        if (content != null) Positioned.fill(child: content),
      ],
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: scaffoldBody,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      drawer: drawer,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}
