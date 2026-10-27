import 'package:flutter/material.dart';
import '../../core/theme/candy_colors.dart';
import 'candy_badge.dart';
import 'candy_card.dart';

/// Exercise catalog item card with category pill, muscle tags,
/// and optional selection action.
class CandyExerciseCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String category;
  final String? equipment;
  final String? movementPattern;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isSelected;
  final CandyBadgeVariant categoryVariant;

  const CandyExerciseCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.category,
    this.equipment,
    this.movementPattern,
    this.onTap,
    this.trailing,
    this.isSelected = false,
    this.categoryVariant = CandyBadgeVariant.mint,
  });

  @override
  Widget build(BuildContext context) {
    return CandyCard(
      shadow: isSelected ? CandyCardShadow.large : CandyCardShadow.small,
      backgroundColor: isSelected ? const Color(0xFFFFF9DB) : CandyColors.card,
      borderColor: isSelected ? CandyColors.hotPink : CandyColors.ink,
      padding: const EdgeInsets.all(14.0),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CandyBadge(
                      label: category.toUpperCase(),
                      variant: categoryVariant,
                      fontSize: 10,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                    ),
                    if (equipment != null) ...[
                      const SizedBox(width: 6),
                      CandyBadge(
                        label: equipment!,
                        variant: CandyBadgeVariant.card,
                        fontSize: 10,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: CandyFonts.display,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: CandyColors.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontFamily: CandyFonts.body,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: CandyColors.charcoal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ] else if (onTap != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? CandyColors.hotPink
                    : CandyColors.canaryYellow,
                shape: BoxShape.circle,
                border: CandyColors.standardBorder(width: 1.5),
              ),
              child: Icon(
                isSelected ? Icons.check : Icons.arrow_forward_ios_rounded,
                size: 14,
                color: isSelected ? Colors.white : CandyColors.ink,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
