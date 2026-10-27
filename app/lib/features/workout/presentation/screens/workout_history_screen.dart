import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../workout_copy.dart';
import '../controllers/workout_history_controller.dart';
import '../widgets/workout_summary_card.dart';

class WorkoutHistoryScreen extends ConsumerWidget {
  const WorkoutHistoryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(workoutHistoryProvider);
    return Scaffold(
      appBar: AppBar(title: Text(workoutText(ref, 'history'))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: history.when(
            data: (workouts) => RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(workoutHistoryProvider);
                await ref.read(workoutHistoryProvider.future);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  if (workouts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 80),
                      child: Text(
                        workoutText(ref, 'no_history'),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ...workouts.map(
                    (workout) => WorkoutSummaryCard(
                      workout: workout,
                      onTap: () =>
                          context.push('/workout/detail/${workout.id}'),
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  workoutText(ref, 'save_failed'),
                  textAlign: TextAlign.center,
                ),
                TextButton(
                  onPressed: () => ref.invalidate(workoutHistoryProvider),
                  child: Text(workoutText(ref, 'retry')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
