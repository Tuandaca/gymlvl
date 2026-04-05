import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/theme/app_theme.dart';
import '../controllers/workout_history_controller.dart';
import '../widgets/workout_exercise_tile.dart';

class WorkoutDetailScreen extends ConsumerWidget {
  final String workoutId;

  const WorkoutDetailScreen({super.key, required this.workoutId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(workoutDetailProvider(workoutId));

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('CHI TIẾT BUỔI TẬP'),
      ),
      body: detailAsync.when(
        data: (workout) {
          if (workout == null) {
            return const Center(
              child: Text('Không tìm thấy buổi tập',
                  style: TextStyle(color: AppTheme.textDim)),
            );
          }

          final duration = workout.durationSeconds;
          final hours = duration ~/ 3600;
          final minutes = (duration % 3600) ~/ 60;
          final durationText = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

          final totalSets = workout.exercises.fold(
              0, (sum, ex) => sum + ex.sets.length);
          final completedSets = workout.exercises.fold(
              0,
              (sum, ex) =>
                  sum + ex.sets.where((s) => s.isCompleted).length);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.panelBackground.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppTheme.cyanNeon.withOpacity(0.15)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(Icons.timer_outlined, durationText, 'Thời gian'),
                      _buildDivider(),
                      _buildStat(Icons.list_alt_rounded,
                          '${workout.exercises.length}', 'Bài tập'),
                      _buildDivider(),
                      _buildStat(
                          Icons.repeat_rounded, '$completedSets/$totalSets', 'Sets'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Date info
                if (workout.completedAt != null)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Text(
                      'Hoàn thành: ${_formatDateTime(workout.completedAt!)}',
                      style: const TextStyle(
                          color: AppTheme.textDim, fontSize: 12),
                    ),
                  ),

                // Notes
                if (workout.notes != null && workout.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.panelBackground.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppTheme.purpleNeon.withOpacity(0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'GHI CHÚ',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            color: AppTheme.purpleNeon,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          workout.notes!,
                          style: const TextStyle(
                              color: AppTheme.textMain, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Exercises
                const Text(
                  'BÀI TẬP',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    color: AppTheme.cyanNeon,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),

                ...workout.exercises.map(
                  (we) => WorkoutExerciseTile(
                    workoutExercise: we,
                    isEditable: false,
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.cyanNeon),
        ),
        error: (err, stack) => Center(
          child: Text('Lỗi: $err',
              style: const TextStyle(color: AppTheme.dangerOrange)),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.cyanNeon, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textMain,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'Orbitron',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textDim, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppTheme.cyanNeon.withOpacity(0.15),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    return '${local.day}/${local.month}/${local.year} lúc ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
