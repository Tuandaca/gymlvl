import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/training_plan/first_week_plan_models.dart';
import 'package:app/features/workout/domain/workout_mode_contract.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../core/theme/candy_colors.dart';
import '../../../../ui/candy/candy_card.dart';

/// Candy widget for one first-week plan day: day header plus exercise cards.
///
/// Displays each [PlannedExercise] with its mode (bodyweight vs reps-weight),
/// sets x reps, and starter weight. For bodyweight exercises the weight is
/// external/added load ("Tạ thêm / Added load"), never body mass.
class PlanDayCard extends StatelessWidget {
  final PlanDay day;
  final WidgetRef ref;

  const PlanDayCard({super.key, required this.day, required this.ref});

  String _formatWeight(double kg) {
    if (kg == kg.truncateToDouble()) {
      return '${kg.toInt()} kg';
    }
    return '${kg.toStringAsFixed(1)} kg';
  }

  String _modeLabel(WorkoutMode mode) {
    switch (mode) {
      case WorkoutMode.bodyweight:
        return 'mode_bodyweight'.tr(ref);
      case WorkoutMode.repsWeight:
        return 'mode_reps_weight'.tr(ref);
      case WorkoutMode.timed:
      case WorkoutMode.cardio:
        return mode.wireValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            day.dayName,
            style: const TextStyle(
              fontFamily: CandyFonts.display,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: CandyColors.ink,
            ),
          ),
        ),
        ...day.exercises.map((ex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Semantics(
              label: _exerciseSemanticsLabel(ex),
              child: _PlannedExerciseCard(exercise: ex, ref: ref),
            ),
          );
        }),
      ],
    );
  }

  String _exerciseSemanticsLabel(PlannedExercise ex) {
    return '${ex.exerciseName}, ${_modeLabel(ex.mode)}, '
        '${ex.sets} x ${ex.reps}, ${_formatWeight(ex.starterWeightKg)}.';
  }
}

/// One prescribed exercise card: name, category, mode, sets x reps, weight.
class _PlannedExerciseCard extends StatelessWidget {
  final PlannedExercise exercise;
  final WidgetRef ref;

  const _PlannedExerciseCard({required this.exercise, required this.ref});

  String _formatWeight(double kg) {
    if (kg == kg.truncateToDouble()) {
      return '${kg.toInt()} kg';
    }
    return '${kg.toStringAsFixed(1)} kg';
  }

  String _modeLabel(WorkoutMode mode) {
    switch (mode) {
      case WorkoutMode.bodyweight:
        return 'mode_bodyweight'.tr(ref);
      case WorkoutMode.repsWeight:
        return 'mode_reps_weight'.tr(ref);
      case WorkoutMode.timed:
      case WorkoutMode.cardio:
        return mode.wireValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBodyweight = exercise.mode == WorkoutMode.bodyweight;
    return CandyCard(
      shadow: CandyCardShadow.medium,
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  exercise.exerciseName,
                  style: const TextStyle(
                    fontFamily: CandyFonts.display,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: CandyColors.ink,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isBodyweight
                      ? CandyColors.mintGreen.withValues(alpha: 0.2)
                      : CandyColors.hotPink.withValues(alpha: 0.2),
                  border: Border.all(
                    color: isBodyweight
                        ? CandyColors.mintGreen
                        : CandyColors.hotPink,
                    width: CandyColors.borderWidth,
                  ),
                  borderRadius: BorderRadius.circular(CandyColors.pillRadius),
                ),
                child: Text(
                  _modeLabel(exercise.mode),
                  style: const TextStyle(
                    fontFamily: CandyFonts.body,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: CandyColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            exercise.category,
            style: const TextStyle(
              fontFamily: CandyFonts.body,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: CandyColors.charcoal,
            ),
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              Expanded(
                child: _StatChip(
                  label: 'reps'.tr(ref),
                  value: '${exercise.reps}',
                  accent: CandyColors.hotPink,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: _StatChip(
                  label: 'sets'.tr(ref),
                  value: '${exercise.sets}',
                  accent: CandyColors.mintGreen,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: _StatChip(
                  label: isBodyweight
                      ? 'added_load'.tr(ref)
                      : 'weight_kg'.tr(ref),
                  value: _formatWeight(exercise.starterWeightKg),
                  accent: CandyColors.canaryYellow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tiny stat chip inside an exercise card.
class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _StatChip({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        border: Border.all(color: accent, width: CandyColors.borderWidth),
        borderRadius: BorderRadius.circular(CandyColors.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: CandyFonts.body,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: CandyColors.ink,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            value,
            style: const TextStyle(
              fontFamily: CandyFonts.mono,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: CandyColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
