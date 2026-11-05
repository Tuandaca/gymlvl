import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../ui/candy/candy.dart';
import '../../domain/achievement.dart';

/// A single achievement card. Earned achievements show a mint fill and
/// unlocked-at timestamp; locked ones show a muted fill and a lock icon.
class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final WidgetRef ref;

  const AchievementCard({
    super.key,
    required this.achievement,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return CandyCard(
      shadow: CandyCardShadow.small,
      padding: const EdgeInsets.all(16.0),
      backgroundColor: achievement.isEarned
          ? CandyColors.mintGreen.withValues(alpha: 0.12)
          : CandyColors.card,
      borderColor: achievement.isEarned
          ? CandyColors.mintGreen
          : CandyColors.muted,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon pill
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: achievement.isEarned
                  ? CandyColors.mintGreen
                  : CandyColors.muted.withValues(alpha: 0.35),
              shape: BoxShape.circle,
              border: CandyColors.standardBorder(),
              boxShadow: CandyColors.shadowPressed(),
            ),
            child: Icon(
              achievement.isEarned
                  ? Icons.emoji_events_rounded
                  : Icons.lock_outline_rounded,
              color: CandyColors.ink,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          // Title / description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: const TextStyle(
                          fontFamily: CandyFonts.display,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: CandyColors.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (achievement.isEarned)
                      CandyBadge(
                        label: translateText(ref, vi: 'Đã nhận', en: 'Earned'),
                        variant: CandyBadgeVariant.mint,
                        fontSize: 10,
                        hasShadow: true,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: const TextStyle(
                    fontFamily: CandyFonts.body,
                    fontSize: 12,
                    color: CandyColors.charcoal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Unlocked-at timestamp (earned only)
          if (achievement.isEarned && achievement.unlockedAt != null) ...[
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  achievement.unlockedAt!.toString().substring(0, 10),
                  style: const TextStyle(
                    fontFamily: CandyFonts.mono,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: CandyColors.mintGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  translateText(ref, vi: 'Đã nhận', en: 'Earned'),
                  style: const TextStyle(
                    fontFamily: CandyFonts.body,
                    fontSize: 10,
                    color: CandyColors.muted,
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(width: 14),
            CandyBadge(
              label: translateText(ref, vi: 'Khóa', en: 'Locked'),
              variant: CandyBadgeVariant.card,
              fontSize: 10,
              hasShadow: false,
            ),
          ],
        ],
      ),
    );
  }
}
