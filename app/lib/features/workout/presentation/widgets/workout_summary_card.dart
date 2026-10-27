import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../ui/theme/app_theme.dart';
import '../../domain/workout.dart';
import '../../workout_copy.dart';

class WorkoutSummaryCard extends ConsumerWidget {
  final Workout workout;
  final VoidCallback? onTap;
  const WorkoutSummaryCard({super.key, required this.workout, this.onTap});

  static int calendarDaysApart(DateTime now, DateTime then) {
    final localNow = now.toLocal();
    final localThen = then.toLocal();
    return DateTime.utc(localNow.year, localNow.month, localNow.day)
        .difference(
          DateTime.utc(localThen.year, localThen.month, localThen.day),
        )
        .inDays;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = (workout.completedAt ?? workout.startedAt ?? workout.createdAt)
        ?.toLocal();
    final days = date == null ? -1 : calendarDaysApart(DateTime.now(), date);
    final label = days == 0
        ? workoutText(ref, 'today')
        : days == 1
        ? workoutText(ref, 'yesterday')
        : date == null
        ? '—'
        : '${date.day}/${date.month}/${date.year}';
    final completed = workout.exercises
        .expand((e) => e.sets)
        .where((s) => s.isCompleted)
        .length;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.fitness_center, color: AppTheme.cyanNeon),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        Text('${workout.durationSeconds ~/ 60}m'),
                        Text(
                          '${workout.exercises.length} ${workoutText(ref, 'exercises')}',
                        ),
                        Text('$completed ${workoutText(ref, 'sets')}'),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
