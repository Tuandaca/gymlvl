import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/workout/domain/workout_set.dart';
import 'package:app/features/workout/presentation/providers/exercise_providers.dart';
import 'package:app/features/workout/workout_copy.dart';
import '../../../../ui/theme/app_theme.dart';

/// Streams the most recent completed set for [exerciseId] across the owner's
/// completed workouts, so the active workout can show a compact previous
/// performance hint without mutating history.
final previousSetProvider = FutureProvider.family<WorkoutSet?, String>((
  ref,
  String exerciseId,
) async {
  final repository = ref.read(workoutRepositoryProvider);
  return repository.getLastSetForExercise(exerciseId);
});

/// Compact read-only hint shown inside an active-workout exercise tile.
///
/// Owner-scoped, same-exercise only, historical completed workouts only.
/// Gracefully renders nothing when there is no prior data.
class PreviousPerformanceHint extends ConsumerWidget {
  final String exerciseId;

  const PreviousPerformanceHint({super.key, required this.exerciseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(previousSetProvider(exerciseId));
    return async.when(
      data: (set) {
        if (set == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history, size: 14, color: AppTheme.textDim),
              const SizedBox(width: 6),
              Text(
                '${workoutText(ref, 'previous_best')}: '
                '${set.weightKg.toStringAsFixed(set.weightKg == set.weightKg.truncateToDouble() ? 0 : 1)} kg '
                'x ${set.reps}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textDim,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (Object? error, StackTrace? stackTrace) => const SizedBox.shrink(),
    );
  }
}
