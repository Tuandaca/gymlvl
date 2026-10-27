import 'package:flutter/material.dart';
import '../../core/theme/candy_colors.dart';

enum CandyBadgeVariant { pink, yellow, mint, lilac, coral, card }

/// Status pill badge with 2px solid ink border and vibrant candy fill.
class CandyBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final CandyBadgeVariant variant;
  final Color? customColor;
  final Color? textColor;
  final bool hasShadow;
  final VoidCallback? onTap;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const CandyBadge({
    super.key,
    required this.label,
    this.icon,
    this.variant = CandyBadgeVariant.mint,
    this.customColor,
    this.textColor,
    this.hasShadow = false,
    this.onTap,
    this.fontSize = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
  });

  Color _getFillColor() {
    if (customColor != null) return customColor!;
    switch (variant) {
      case CandyBadgeVariant.pink:
        return CandyColors.hotPink;
      case CandyBadgeVariant.yellow:
        return CandyColors.canaryYellow;
      case CandyBadgeVariant.mint:
        return CandyColors.mintGreen;
      case CandyBadgeVariant.lilac:
        return CandyColors.softLilac;
      case CandyBadgeVariant.coral:
        return CandyColors.coral;
      case CandyBadgeVariant.card:
        return CandyColors.card;
    }
  }

  Color _getTextColor() {
    if (textColor != null) return textColor!;
    switch (variant) {
      case CandyBadgeVariant.pink:
      case CandyBadgeVariant.coral:
        return Colors.white;
      case CandyBadgeVariant.yellow:
      case CandyBadgeVariant.mint:
      case CandyBadgeVariant.lilac:
      case CandyBadgeVariant.card:
        return CandyColors.ink;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fill = _getFillColor();
    final textCol = _getTextColor();

    Widget badgeContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: CandyColors.pillBorderRadius,
        border: CandyColors.standardBorder(),
        boxShadow: hasShadow ? CandyColors.shadowPressed() : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: textCol),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: CandyFonts.body,
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: textCol,
                letterSpacing: 0.3,
                height: 1.25,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: badgeContent);
    }

    return badgeContent;
  }
}
