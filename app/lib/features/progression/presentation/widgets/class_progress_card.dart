import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/progression/domain/rpg_bridge.dart';
import '../../../../core/theme/candy_colors.dart';
import '../../../../ui/candy/candy_badge.dart';
import '../../../../ui/candy/candy_card.dart';
import '../../../../ui/candy/candy_progress_bar.dart';
import '../../../../core/localization/localization_engine.dart';

/// Card showing the user's class level, XP progress bar, and level-up state.
///
/// All values are display-only estimates projected by `RPGBridge`; the server
/// owns the authoritative level and graduation.
class ClassProgressCard extends ConsumerWidget {
  /// Projection computed by `RPGBridge.projectClass`.
  final RPGProjection projection;

  /// Display name of the class (e.g. "Fat Slayer").
  final String className;

  /// ``class_definitions.xp_base`` for the progress bar scale.
  final int xpBase;

  /// ``class_definitions.xp_slope`` for the progress bar scale.
  final double xpSlope;

  /// Optional callback tapped when a level up is displayed.
  final VoidCallback? onLevelUp;

  const ClassProgressCard({
    super.key,
    required this.projection,
    required this.className,
    required this.xpBase,
    required this.xpSlope,
    this.onLevelUp,
  });

  /// Cumulative XP at the start of the current level. Level 1 starts at 0.
  int get _xpAtLevelStart => projection.newLevel <= 1
      ? 0
      : RPGBridge.classXPForLevel(projection.newLevel, xpBase, xpSlope);

  /// Cumulative XP required to reach the next level.
  int get _xpAtLevelEnd => projection.newLevel >= 20
      ? projection.newXP
      : RPGBridge.classXPForLevel(projection.newLevel + 1, xpBase, xpSlope);

  /// Fraction of the current level completed, clamped to [0, 1].
  double get _progress {
    if (projection.newLevel >= 20) return 1.0;
    final start = _xpAtLevelStart;
    final end = _xpAtLevelEnd;
    if (end <= start) return 0.0;
    return ((projection.newXP - start) / (end - start)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leveledUp = projection.leveledUp;
    final progress = _progress;

    return CandyCard(
      shadow: CandyCardShadow.large,
      onTap: leveledUp && onLevelUp != null ? onLevelUp : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            label:
                '${'class_progress'.tr(ref)} $className, ${'level'.tr(ref)} ${projection.newLevel}, ${projection.newXP} XP',
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 48.0,
                minHeight: 48.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      '${'class_progress'.tr(ref)} — $className',
                      style: const TextStyle(
                        fontFamily: CandyFonts.display,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: CandyColors.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  if (leveledUp)
                    Semantics(
                      label: 'level_up'.tr(ref),
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 48.0,
                          minHeight: 48.0,
                        ),
                        child: CandyBadge(
                          label: 'level_up'.tr(ref),
                          variant: CandyBadgeVariant.yellow,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${'level'.tr(ref)} ${projection.newLevel}',
                  style: const TextStyle(
                    fontFamily: CandyFonts.mono,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: CandyColors.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  '${projection.newXP} XP',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: CandyFonts.mono,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: CandyColors.charcoal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          CandyProgressBar(
            progress: progress,
            showLabel: true,
            customLabel: '${(progress * 100).toInt()}%',
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${'xp_to_next'.tr(ref)}: ${projection.xpToNextLevel} XP',
                  style: const TextStyle(
                    fontFamily: CandyFonts.body,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: CandyColors.muted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (leveledUp && projection.newLevel >= 20)
                Expanded(
                  child: Text(
                    'level_cap'.tr(ref),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: CandyFonts.body,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: CandyColors.hotPink,
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
