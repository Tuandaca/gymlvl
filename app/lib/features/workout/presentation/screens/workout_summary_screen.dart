import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../ui/theme/app_theme.dart';
import '../../workout_copy.dart';
import '../../domain/workout.dart';
import '../../domain/workout_exercise.dart';

/// Whether [extra] carries a real workout summary context.
///
/// A summary is only legitimate when it is backed by an actual workout or an
/// already constructed summary screen. Missing context must never be replaced
/// with a synthetic completed workout.
bool hasWorkoutSummaryContext(Object? extra) =>
    extra is WorkoutSummaryScreen ||
    extra is Workout ||
    (extra is Map<String, dynamic> && extra['workout'] is Workout);

class WorkoutSummaryScreen extends ConsumerWidget {
  final Workout workout;
  final Map<String, dynamic>? xpResult;
  final double totalVolumeKg;
  final int durationSeconds;
  final int completedSetsCount;
  final int totalSetsCount;
  final List<WorkoutExercise> exercises;

  const WorkoutSummaryScreen({
    super.key,
    required this.workout,
    this.xpResult,
    required this.totalVolumeKg,
    required this.durationSeconds,
    required this.completedSetsCount,
    required this.totalSetsCount,
    this.exercises = const [],
  });

  static Future<void> show(
    BuildContext context, {
    required Workout workout,
    Map<String, dynamic>? xpResult,
    required double totalVolumeKg,
    required int durationSeconds,
    required int completedSetsCount,
    required int totalSetsCount,
    List<WorkoutExercise> exercises = const [],
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => WorkoutSummaryScreen(
          workout: workout,
          xpResult: xpResult,
          totalVolumeKg: totalVolumeKg,
          durationSeconds: durationSeconds,
          completedSetsCount: completedSetsCount,
          totalSetsCount: totalSetsCount,
          exercises: exercises,
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m >= 60) {
      final h = m ~/ 60;
      final remM = m % 60;
      return '${h}h ${remM}m';
    }
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earnedXp = (xpResult?['earnedXP'] as num?)?.toInt();
    final totalXp = (xpResult?['totalXP'] as num?)?.toInt();
    final newLevel = (xpResult?['newLevel'] as num?)?.toInt();
    final leveledUp = xpResult?['leveledUp'] as bool? ?? false;
    final newTitle = xpResult?['newTitle'] as String?;
    final nextLevelXp = (xpResult?['nextLevelXp'] as num?)?.toInt();

    // A receipt may carry only part of the progression data. Show a value only
    // when the receipt actually contains it; never substitute a default level,
    // XP total, or progress fraction.
    final hasLevelProgress =
        totalXp != null && nextLevelXp != null && nextLevelXp > 0;
    final hasLevelReceipt = newLevel != null || hasLevelProgress;

    // Calculate level progress
    final double levelProgress =
        (totalXp != null && nextLevelXp != null && nextLevelXp > 0)
        ? ((totalXp % nextLevelXp) / nextLevelXp).clamp(0.0, 1.0)
        : 0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          workoutText(ref, 'workout_summary'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: workoutText(ref, 'dismiss'),
            icon: const Icon(Icons.close),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/workout');
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Celebration Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.cyanNeon.withValues(alpha: 0.15),
                      AppTheme.purpleNeon.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.cyanNeon.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.cyanNeon.withValues(alpha: 0.15),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.cyanNeon, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.cyanNeon.withValues(alpha: 0.4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: AppTheme.cyanNeon,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      workoutText(ref, 'finish_workout_celebration'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textMain,
                      ),
                    ),
                    if (earnedXp != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.successGreen.withValues(alpha: 0.6),
                          ),
                        ),
                        child: Text(
                          '+$earnedXp XP',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.successGreen,
                            fontFamily: 'Space Mono',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Level Progress Bar
              if (hasLevelReceipt) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.panelBackground.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: leveledUp
                          ? AppTheme.goldWarning
                          : AppTheme.textDim.withValues(alpha: 0.2),
                      width: leveledUp ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (newLevel != null)
                                Text(
                                  'LVL $newLevel',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.cyanNeon,
                                    fontFamily: 'Space Mono',
                                  ),
                                ),
                              if (newTitle != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  newTitle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textDim,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (leveledUp)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.goldWarning.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'LEVEL UP!',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.goldWarning,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (hasLevelProgress) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: levelProgress,
                            minHeight: 8,
                            backgroundColor: AppTheme.background,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.cyanNeon,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '$totalXp / $nextLevelXp XP',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textDim,
                              fontFamily: 'Space Mono',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 3 KPI Metrics
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      label: workoutText(ref, 'total_volume'),
                      value: '${totalVolumeKg.toStringAsFixed(1)} kg',
                      icon: Icons.fitness_center,
                      color: AppTheme.cyanNeon,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      label: workoutText(ref, 'duration'),
                      value: _formatDuration(durationSeconds),
                      icon: Icons.timer_outlined,
                      color: AppTheme.purpleNeon,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      label: workoutText(ref, 'completed_sets'),
                      value: '$completedSetsCount / $totalSetsCount',
                      icon: Icons.done_all,
                      color: AppTheme.successGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Exercises Completed List
              if (exercises.isNotEmpty) ...[
                Text(
                  workoutText(ref, 'exercises').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: AppTheme.textDim,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.panelBackground.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.textDim.withValues(alpha: 0.15),
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: exercises.length,
                    separatorBuilder: (_, index) => Divider(
                      height: 1,
                      color: AppTheme.textDim.withValues(alpha: 0.1),
                    ),
                    itemBuilder: (context, i) {
                      final ex = exercises[i];
                      final completedInEx = ex.sets
                          .where((s) => s.isCompleted)
                          .length;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                ex.exercise?.localizedName() ??
                                    ex.exercise?.name ??
                                    'Exercise',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textMain,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              '$completedInEx sets',
                              style: const TextStyle(
                                fontFamily: 'Space Mono',
                                color: AppTheme.cyanNeon,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Return CTA Button
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/workout');
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.cyanNeon,
                    foregroundColor: AppTheme.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    workoutText(ref, 'return_home'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.panelBackground.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'Space Mono',
              color: AppTheme.textMain,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: AppTheme.textDim),
          ),
        ],
      ),
    );
  }
}
