import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../ui/candy/candy.dart';
import '../../../progression/domain/progression_engine.dart';

/// Hero XP progression card with Neubrutalist CandyProgressBar,
/// Space Grotesk level indicator, Space Mono XP counters, and level milestones.
class HeroXpCard extends ConsumerWidget {
  final Map<String, dynamic> user;

  const HeroXpCard({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final level = (user['level'] as num?)?.toInt() ?? 1;
    final xp = (user['current_level_xp'] as num?)?.toInt() ?? 0;
    final requiredXp = ProgressionEngine.xpRequiredForLevel(level);
    final progress = requiredXp > 0 ? (xp / requiredXp).clamp(0.0, 1.0) : 0.0;
    final remainingXp = (requiredXp - xp).clamp(0, requiredXp);
    final percent = (progress * 100).toInt();

    final remainingText = translateText(
      ref,
      vi: 'Còn $remainingXp XP để lên Cấp ${level + 1}',
      en: '$remainingXp XP to reach Level ${level + 1}',
    );

    return CandyCard(
      shadow: CandyCardShadow.medium,
      padding: const EdgeInsets.all(18.0),
      backgroundColor: CandyColors.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Level Badge and Title Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: CandyColors.hotPink,
                          borderRadius: BorderRadius.circular(999),
                          border: CandyColors.standardBorder(width: 2.0),
                          boxShadow: CandyColors.shadowPressed(),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.bolt_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${'level'.tr(ref).toUpperCase()} $level',
                                style: const TextStyle(
                                  fontFamily: CandyFonts.display,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Percentage Badge
              CandyBadge(
                label: '$percent%',
                variant: CandyBadgeVariant.mint,
                fontSize: 12,
                hasShadow: true,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Current XP vs Required XP
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  'TIẾN TRÌNH KINH NGHIỆM',
                  style: const TextStyle(
                    fontFamily: CandyFonts.body,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: CandyColors.charcoal,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '$xp / $requiredXp XP',
                  style: const TextStyle(
                    fontFamily: CandyFonts.mono,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: CandyColors.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Neubrutalist Progress Bar
          CandyProgressBar(
            progress: progress,
            height: 18.0,
            fillColor: CandyColors.mintGreen,
            trackColor: CandyColors.canvas,
          ),
          const SizedBox(height: 10),

          // Milestone hint
          Row(
            children: [
              const Icon(
                Icons.stars_rounded,
                size: 16,
                color: CandyColors.hotPink,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  remainingText,
                  style: const TextStyle(
                    fontFamily: CandyFonts.body,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CandyColors.charcoal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
