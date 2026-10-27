import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../workout_copy.dart';
import '../controllers/workout_history_controller.dart';
import '../widgets/workout_exercise_tile.dart';

class WorkoutDetailScreen extends ConsumerWidget {
  final String workoutId;
  const WorkoutDetailScreen({super.key, required this.workoutId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(workoutDetailProvider(workoutId));
    return Scaffold(
      appBar: AppBar(title: Text(workoutText(ref, 'details'))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: detail.when(
            data: (workout) {
              if (workout == null) {
                return Center(child: Text(workoutText(ref, 'not_found')));
              }
              final sets = workout.exercises
                  .expand((e) => e.sets)
                  .where((s) => s.isCompleted)
                  .toList();
              final volume = sets.fold<double>(
                0,
                (sum, set) => sum + set.reps * set.weightKg,
              );
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Wrap(
                        spacing: 24,
                        runSpacing: 16,
                        children: [
                          _stat(
                            workoutText(ref, 'duration'),
                            '${workout.durationSeconds ~/ 60}m',
                          ),
                          _stat(workoutText(ref, 'sets'), '${sets.length}'),
                          _stat(
                            workoutText(ref, 'volume'),
                            '${volume.toStringAsFixed(0)} kg',
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (workout.completedAt != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        workout.completedAt!.toLocal().toString().substring(
                          0,
                          16,
                        ),
                      ),
                    ),
                  if (workout.notes?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(workout.notes!),
                    ),
                  ...workout.exercises.map(
                    (exercise) => WorkoutExerciseTile(
                      key: ValueKey(exercise.id),
                      workoutExercise: exercise,
                      isEditable: false,
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  workoutText(ref, 'save_failed'),
                  textAlign: TextAlign.center,
                ),
                TextButton(
                  onPressed: () =>
                      ref.invalidate(workoutDetailProvider(workoutId)),
                  child: Text(workoutText(ref, 'retry')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    ],
  );
}
