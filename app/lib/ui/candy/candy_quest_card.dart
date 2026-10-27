import 'package:flutter/material.dart';
import '../../core/theme/candy_colors.dart';
import 'candy_badge.dart';
import 'candy_button.dart';
import 'candy_card.dart';
import 'candy_progress_bar.dart';

enum CandyQuestStatus { notStarted, inProgress, completedUnclaimed, claimed }

/// Daily quest card with category icon, XP reward badge,
/// progress bar, and contextual claim / start action button.
class CandyQuestCard extends StatelessWidget {
  final String title;
  final String description;
  final int currentProgress;
  final int targetProgress;
  final int xpReward;
  final CandyQuestStatus status;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onStart;
  final VoidCallback? onClaim;

  const CandyQuestCard({
    super.key,
    required this.title,
    required this.description,
    required this.currentProgress,
    required this.targetProgress,
    required this.xpReward,
    this.status = CandyQuestStatus.inProgress,
    this.icon = Icons.fitness_center_rounded,
    this.iconColor = CandyColors.softLilac,
    this.onStart,
    this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final double progressFraction = targetProgress > 0
        ? (currentProgress / targetProgress).clamp(0.0, 1.0)
        : 0.0;

    return CandyCard(
      shadow: CandyCardShadow.small,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon pill
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                  border: CandyColors.standardBorder(),
                  boxShadow: CandyColors.shadowPressed(),
                ),
                child: Icon(icon, color: CandyColors.ink, size: 22),
              ),
              const SizedBox(width: 12),

              // Title and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: CandyFonts.display,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: CandyColors.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                        fontFamily: CandyFonts.body,
                        fontSize: 12,
                        color: CandyColors.charcoal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // XP Reward Badge
              const SizedBox(width: 8),
              CandyBadge(
                label: '+$xpReward XP',
                variant: CandyBadgeVariant.mint,
                fontSize: 11,
                hasShadow: true,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress bar with counts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TIẾN ĐỘ',
                style: TextStyle(
                  fontFamily: CandyFonts.body,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: CandyColors.charcoal,
                ),
              ),
              Text(
                '$currentProgress / $targetProgress',
                style: const TextStyle(
                  fontFamily: CandyFonts.mono,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: CandyColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          CandyProgressBar(
            progress: progressFraction,
            height: 12,
            fillColor:
                status == CandyQuestStatus.completedUnclaimed ||
                    status == CandyQuestStatus.claimed
                ? CandyColors.mintGreen
                : CandyColors.canaryYellow,
          ),
          const SizedBox(height: 12),

          // Action CTA
          _buildActionRow(context),
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    switch (status) {
      case CandyQuestStatus.completedUnclaimed:
        return CandyButton(
          label: 'NHẬN THƯỞNG (+$xpReward XP)',
          variant: CandyButtonVariant.mint,
          size: CandyButtonSize.small,
          icon: Icons.card_giftcard_rounded,
          onPressed: onClaim,
        );
      case CandyQuestStatus.claimed:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: CandyColors.mintGreen, width: 1.5),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 16,
                color: CandyColors.ink,
              ),
              SizedBox(width: 6),
              Text(
                'ĐÃ HOÀN THÀNH',
                style: TextStyle(
                  fontFamily: CandyFonts.display,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: CandyColors.ink,
                ),
              ),
            ],
          ),
        );
      case CandyQuestStatus.inProgress:
      case CandyQuestStatus.notStarted:
        if (onStart != null) {
          return CandyButton(
            label: 'BẮT ĐẦU NHIỆM VỤ',
            variant: CandyButtonVariant.secondary,
            size: CandyButtonSize.small,
            icon: Icons.play_arrow_rounded,
            onPressed: onStart,
          );
        }
        return const SizedBox.shrink();
    }
  }
}
