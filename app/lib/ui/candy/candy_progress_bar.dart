import 'package:flutter/material.dart';
import '../../core/theme/candy_colors.dart';

/// Hard-bordered XP and progression bar with 2px ink border,
/// smooth animated fill, and vibrant candy coloring (Mint / Pink).
class CandyProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color fillColor;
  final Color trackColor;
  final double height;
  final double borderRadius;
  final bool showLabel;
  final String? customLabel;
  final Duration animationDuration;

  const CandyProgressBar({
    super.key,
    required this.progress,
    this.fillColor = CandyColors.mintGreen,
    this.trackColor = CandyColors.card,
    this.height = 18.0,
    this.borderRadius = 999.0,
    this.showLabel = false,
    this.customLabel,
    this.animationDuration = CandyTimings.progress,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final percentageText = customLabel ?? '${(clampedProgress * 100).toInt()}%';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showLabel) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TIẾN TRÌNH',
                  style: TextStyle(
                    fontFamily: CandyFonts.body,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: CandyColors.charcoal,
                  ),
                ),
                Text(
                  percentageText,
                  style: const TextStyle(
                    fontFamily: CandyFonts.mono,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: CandyColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: CandyColors.standardBorder(),
            boxShadow: CandyColors.shadowPressed(),
          ),
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: clampedProgress),
                    duration: animationDuration,
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedValue, child) {
                      return FractionallySizedBox(
                        widthFactor: animatedValue,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: fillColor,
                            border: animatedValue > 0.02 && animatedValue < 0.99
                                ? const Border(
                                    right: BorderSide(
                                      color: CandyColors.ink,
                                      width: 1.5,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
