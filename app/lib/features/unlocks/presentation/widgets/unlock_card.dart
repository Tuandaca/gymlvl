import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../ui/candy/candy.dart';
import '../../domain/unlock.dart';

/// A single unlock card. Unlocked unlocks show a mint fill; locked ones show
/// the threshold required and a lock icon.
class UnlockCard extends StatelessWidget {
  final Unlock unlock;
  final WidgetRef ref;

  const UnlockCard({super.key, required this.unlock, required this.ref});

  @override
  Widget build(BuildContext context) {
    return CandyCard(
      shadow: CandyCardShadow.small,
      padding: const EdgeInsets.all(16.0),
      backgroundColor: unlock.isUnlocked
          ? CandyColors.mintGreen.withValues(alpha: 0.12)
          : CandyColors.card,
      borderColor: unlock.isUnlocked
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
              color: unlock.isUnlocked
                  ? CandyColors.mintGreen
                  : CandyColors.muted.withValues(alpha: 0.35),
              shape: BoxShape.circle,
              border: CandyColors.standardBorder(),
              boxShadow: CandyColors.shadowPressed(),
            ),
            child: Icon(
              unlock.isUnlocked
                  ? Icons.lock_open_rounded
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
                        unlock.title,
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
                    if (unlock.isUnlocked)
                      CandyBadge(
                        label: translateText(
                          ref,
                          vi: 'Đã mở khóa',
                          en: 'Unlocked',
                        ),
                        variant: CandyBadgeVariant.mint,
                        fontSize: 10,
                        hasShadow: true,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                if (unlock.description != null &&
                    unlock.description!.isNotEmpty)
                  Text(
                    unlock.description!,
                    style: const TextStyle(
                      fontFamily: CandyFonts.body,
                      fontSize: 12,
                      color: CandyColors.charcoal,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 6),
                // Threshold info
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.flag_rounded,
                      size: 14,
                      color: CandyColors.charcoal,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      translateText(
                        ref,
                        vi: 'Ngưỡng ${unlock.thresholdValue}',
                        en: 'Threshold ${unlock.thresholdValue}',
                      ),
                      style: const TextStyle(
                        fontFamily: CandyFonts.mono,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: CandyColors.charcoal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          if (unlock.isUnlocked) ...[
            CandyBadge(
              label: translateText(
                ref,
                vi: '${unlock.rewardValue}',
                en: '${unlock.rewardValue}',
              ),
              variant: CandyBadgeVariant.yellow,
              fontSize: 10,
              hasShadow: true,
            ),
          ] else ...[
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
