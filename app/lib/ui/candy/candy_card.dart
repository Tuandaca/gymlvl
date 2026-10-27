import 'package:flutter/material.dart';
import '../../core/theme/candy_colors.dart';

enum CandyCardShadow {
  none,
  small, // 4px
  medium, // 6px
  large, // 9px
}

/// Tactile Neubrutalist card container featuring 2px solid ink border,
/// 18px corner radius, and hard unblurred drop shadow.
class CandyCard extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final CandyCardShadow shadow;
  final Offset? customShadowOffset;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const CandyCard({
    super.key,
    required this.child,
    this.backgroundColor = CandyColors.card,
    this.borderColor = CandyColors.ink,
    this.borderWidth = CandyColors.borderWidth,
    this.borderRadius = CandyColors.cardRadius,
    this.shadow = CandyCardShadow.medium,
    this.customShadowOffset,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  State<CandyCard> createState() => _CandyCardState();
}

class _CandyCardState extends State<CandyCard> {
  bool _isPressed = false;

  Offset _getShadowOffset() {
    if (widget.customShadowOffset != null) {
      return widget.customShadowOffset!;
    }
    switch (widget.shadow) {
      case CandyCardShadow.none:
        return Offset.zero;
      case CandyCardShadow.small:
        return CandyColors.shadowSmallOffset;
      case CandyCardShadow.medium:
        return CandyColors.shadowMediumOffset;
      case CandyCardShadow.large:
        return CandyColors.shadowLargeOffset;
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseShadowOffset = _getShadowOffset();
    final isInteractive = widget.onTap != null;

    final currentOffset = _isPressed && isInteractive
        ? CandyColors.pressTranslation
        : Offset.zero;
    final currentShadow = baseShadowOffset == Offset.zero
        ? <BoxShadow>[]
        : [
            BoxShadow(
              color: widget.borderColor,
              offset: _isPressed && isInteractive
                  ? CandyColors.pressedShadowOffset
                  : baseShadowOffset,
              blurRadius: 0.0,
            ),
          ];

    Widget cardContent = Transform.translate(
      offset: currentOffset,
      child: AnimatedContainer(
        duration: CandyTimings.press,
        curve: Curves.easeInOut,
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.borderColor,
            width: widget.borderWidth,
          ),
          boxShadow: currentShadow,
        ),
        child: widget.child,
      ),
    );

    if (widget.margin != null) {
      cardContent = Padding(padding: widget.margin!, child: cardContent);
    }

    if (!isInteractive) {
      return cardContent;
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: cardContent,
    );
  }
}
