import 'package:flutter/material.dart';
import '../../core/theme/candy_colors.dart';

/// Neubrutalist loading placeholder with hard edges, optional 2px border,
/// and smooth opacity pulsing animation.
class CandySkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final bool hasBorder;
  final bool hasShadow;
  final Color fillColor;

  const CandySkeleton({
    super.key,
    this.width,
    this.height = 20.0,
    this.borderRadius = 8.0,
    this.hasBorder = true,
    this.hasShadow = false,
    this.fillColor = const Color(0xFFE8E5DD),
  });

  /// Skeleton for a text line.
  const CandySkeleton.text({
    super.key,
    this.width,
    this.height = 14.0,
    this.borderRadius = 4.0,
    this.hasBorder = false,
    this.hasShadow = false,
    this.fillColor = const Color(0xFFE8E5DD),
  });

  /// Skeleton for a full card.
  const CandySkeleton.card({
    super.key,
    this.width = double.infinity,
    this.height = 120.0,
    this.borderRadius = CandyColors.cardRadius,
    this.hasBorder = true,
    this.hasShadow = true,
    this.fillColor = CandyColors.card,
  });

  /// Skeleton for an avatar or circular icon.
  const CandySkeleton.circle({
    super.key,
    double size = 48.0,
    this.hasBorder = true,
    this.hasShadow = false,
    this.fillColor = const Color(0xFFE8E5DD),
  }) : width = size,
       height = size,
       borderRadius = 999.0;

  @override
  State<CandySkeleton> createState() => _CandySkeletonState();
}

class _CandySkeletonState extends State<CandySkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.45,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.fillColor.withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.hasBorder
                ? CandyColors.standardBorder(width: 1.5)
                : null,
            boxShadow: widget.hasShadow ? CandyColors.shadowSmall() : null,
          ),
        );
      },
    );
  }
}
