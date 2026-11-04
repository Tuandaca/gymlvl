import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/progression/domain/progression_engine.dart';
import 'package:app/features/workout/domain/workout_set.dart';
import '../../../../core/theme/candy_colors.dart';
import '../../../../ui/candy/candy_badge.dart';
import '../../../../ui/candy/candy_card.dart';
import '../../../../core/localization/localization_engine.dart';
import 'rpe_rir_tile.dart';

/// Per-set card: estimated 1RM, personal-record indicator, and RPE/RIR.
///
/// All figures are client-side estimates from `ProgressionEngine`; the server
/// owns confirmed PRs and rewards. A set with weight <= 0 or reps <= 0 (e.g.
/// timed/cardio) shows no 1RM or PR.
class ExerciseProgressionCard extends ConsumerWidget {
  final WorkoutSet set;

  /// Previous max weight for PR comparison, null when there is no history.
  final double? previousMaxWeight;

  /// Previous max reps for PR comparison, null when there is no history.
  final int? previousMaxReps;

  const ExerciseProgressionCard({
    super.key,
    required this.set,
    this.previousMaxWeight,
    this.previousMaxReps,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStrength = set.isCompleted && set.weightKg > 0 && set.reps > 0;
    final estimated1rm = isStrength
        ? ProgressionEngine.calculateOneRepMax(
            weightKg: set.weightKg,
            reps: set.reps,
          )
        : null;
    final personalRecord = isStrength
        ? ProgressionEngine.detectPersonalRecord(
            existingMaxWeight: previousMaxWeight,
            existingMaxReps: previousMaxReps,
            newWeight: set.weightKg,
            newReps: set.reps,
          )
        : null;
    final isPR = personalRecord != null && personalRecord.kind != 'none';

    return CandyCard(
      shadow: CandyCardShadow.small,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Set ${set.setNumber}',
                  style: const TextStyle(
                    fontFamily: CandyFonts.mono,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: CandyColors.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isPR)
                Semantics(
                  label: 'personal_record'.tr(ref),
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 48.0,
                      minHeight: 48.0,
                    ),
                    child: CandyBadge(
                      label: 'personal_record'.tr(ref),
                      variant: CandyBadgeVariant.pink,
                      fontSize: 10.0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              Expanded(
                child: _statTile(
                  ref,
                  'estimated_1rm',
                  estimated1rm == null
                      ? '—'
                      : '${estimated1rm.toStringAsFixed(1)} kg',
                  CandyColors.canaryYellow,
                  Icons.fitness_center,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: _statTile(
                  ref,
                  'weight_kg',
                  '${set.weightKg.toStringAsFixed(1)} kg',
                  CandyColors.mintGreen,
                  Icons.monitor_weight,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: _statTile(
                  ref,
                  'reps',
                  '${set.reps}',
                  CandyColors.softLilac,
                  Icons.repeat,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          RpeRirTile(rpe: set.rpe, rir: set.rir),
          const SizedBox(height: 6.0),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              isPR
                  ? 'PR!'
                  : set.isCompleted
                  ? 'completed'.tr(ref)
                  : 'pending'.tr(ref),
              style: TextStyle(
                fontFamily: CandyFonts.mono,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isPR ? CandyColors.hotPink : CandyColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statTile(
    WidgetRef ref,
    String labelKey,
    String value,
    Color accent,
    IconData icon,
  ) {
    return Semantics(
      label: '${labelKey.tr(ref)} $value',
      child: Container(
        constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: CandyColors.canvas,
          borderRadius: BorderRadius.circular(10.0),
          border: CandyColors.standardBorder(width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    border: CandyColors.standardBorder(width: 1.0),
                  ),
                  child: Icon(icon, size: 12, color: CandyColors.ink),
                ),
                const SizedBox(width: 6.0),
                Expanded(
                  child: Text(
                    labelKey.tr(ref),
                    style: const TextStyle(
                      fontFamily: CandyFonts.body,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: CandyColors.charcoal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Text(
              value,
              style: const TextStyle(
                fontFamily: CandyFonts.mono,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: CandyColors.ink,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
