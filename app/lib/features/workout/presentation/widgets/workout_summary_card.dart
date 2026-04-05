import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../ui/theme/app_theme.dart';
import '../../domain/workout.dart';

class WorkoutSummaryCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback? onTap;

  const WorkoutSummaryCard({
    super.key,
    required this.workout,
    this.onTap,
  });

  String get _formattedDuration {
    final totalSeconds = workout.durationSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  String get _formattedDate {
    final date = workout.completedAt ?? workout.startedAt ?? workout.createdAt;
    if (date == null) return 'N/A';
    final local = date.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);

    if (diff.inDays == 0) return 'Hôm nay';
    if (diff.inDays == 1) return 'Hôm qua';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${local.day}/${local.month}/${local.year}';
  }

  int get _totalExercises => workout.exercises.length;

  int get _totalSets =>
      workout.exercises.fold(0, (sum, ex) => sum + ex.sets.length);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.panelBackground.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.cyanNeon.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: AppTheme.cyanNeon.withOpacity(0.1),
            highlightColor: AppTheme.cyanNeon.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Date icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppTheme.cyanNeon.withOpacity(0.2),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.fitness_center_rounded,
                        color: AppTheme.cyanNeon,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formattedDate,
                          style: const TextStyle(
                            color: AppTheme.textMain,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _buildStatChip(
                              Icons.timer_outlined,
                              _formattedDuration,
                            ),
                            const SizedBox(width: 10),
                            _buildStatChip(
                              Icons.list_alt_rounded,
                              '$_totalExercises bài',
                            ),
                            const SizedBox(width: 10),
                            _buildStatChip(
                              Icons.repeat_rounded,
                              '$_totalSets sets',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.chevron_right,
                    color: AppTheme.textDim,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppTheme.textDim),
        const SizedBox(width: 3),
        Text(
          text,
          style: const TextStyle(
            color: AppTheme.textDim,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
