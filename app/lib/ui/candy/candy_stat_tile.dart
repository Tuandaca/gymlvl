import 'package:flutter/material.dart';
import '../../core/theme/candy_colors.dart';
import 'candy_card.dart';

/// Compact KPI stat tile with value in Space Mono, label in Space Grotesk,
/// and vibrant accent color styling.
class CandyStatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final IconData? icon;
  final Color accentColor;
  final String? subtitle;
  final VoidCallback? onTap;

  const CandyStatTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.icon,
    this.accentColor = CandyColors.canaryYellow,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CandyCard(
      shadow: CandyCardShadow.small,
      padding: const EdgeInsets.all(12.0),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: CandyFonts.body,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: CandyColors.charcoal,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                    border: CandyColors.standardBorder(width: 1.5),
                  ),
                  child: Icon(icon, size: 14, color: CandyColors.ink),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontFamily: CandyFonts.mono,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: CandyColors.ink,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: const TextStyle(
                    fontFamily: CandyFonts.body,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CandyColors.charcoal,
                  ),
                ),
              ],
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                fontFamily: CandyFonts.body,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: CandyColors.muted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
