import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../ui/theme/app_theme.dart';
import '../../../../ui/widgets/system_button.dart';
import '../providers/exercise_providers.dart';
import '../controllers/active_workout_controller.dart';
import '../controllers/workout_history_controller.dart';
import '../widgets/workout_summary_card.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  @override
  void initState() {
    super.initState();
    // Check cho active workout khi mở tab (auto-resume)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(activeWorkoutControllerProvider.notifier)
          .checkForActiveWorkout();
    });
  }

  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(activeWorkoutControllerProvider);
    final recentAsync = ref.watch(recentWorkoutsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('LUYỆN TẬP'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active workout resume card
            if (workoutState.hasActiveWorkout)
              _buildResumeCard(workoutState)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.2, end: 0),

            // Start new workout
            if (!workoutState.hasActiveWorkout) ...[
              _buildStartCard(),
              const SizedBox(height: 32),
            ],

            // Recent workouts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'GẦN ĐÂY',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    color: AppTheme.cyanNeon,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/workout/history'),
                  child: const Text(
                    'Xem tất cả →',
                    style: TextStyle(
                      color: AppTheme.textDim,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            recentAsync.when(
              data: (workouts) {
                if (workouts.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppTheme.panelBackground.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.cyanNeon.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.history_rounded,
                            size: 40,
                            color: AppTheme.textDim.withOpacity(0.3)),
                        const SizedBox(height: 12),
                        const Text(
                          'Chưa có buổi tập nào',
                          style:
                              TextStyle(color: AppTheme.textDim, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: workouts
                      .map((w) => WorkoutSummaryCard(
                            workout: w,
                            onTap: () =>
                                context.push('/workout/detail/${w.id}'),
                          ))
                      .toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: AppTheme.cyanNeon),
                ),
              ),
              error: (err, _) => Center(
                child: Text('Lỗi: $err',
                    style: const TextStyle(color: AppTheme.dangerOrange)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.panelBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cyanNeon.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cyanNeon.withOpacity(0.05),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.fitness_center_rounded,
              size: 60, color: AppTheme.cyanNeon),
          const SizedBox(height: 16),
          const Text(
            'Sẵn sàng để thăng cấp?',
            style: TextStyle(
              color: AppTheme.textMain,
              fontSize: 20,
              fontFamily: 'Orbitron',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bắt đầu buổi tập để kiếm XP và thăng cấp!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textDim,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          SystemButton(
            text: 'BẮT ĐẦU BUỔI TẬP',
            onPressed: () => context.push('/workout/active'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 500.ms,
        );
  }

  Widget _buildResumeCard(ActiveWorkoutState workoutState) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.successGreen.withOpacity(0.15),
            AppTheme.cyanNeon.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.successGreen.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.successGreen.withOpacity(0.1),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppTheme.successGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.successGreen.withOpacity(0.6),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'BUỔI TẬP ĐANG DỞ',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  color: AppTheme.successGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${workoutState.exercises.length} bài tập · ${workoutState.totalSets} sets · ${workoutState.formattedElapsed}',
            style: const TextStyle(color: AppTheme.textMain, fontSize: 14),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: SystemButton(
              text: 'TIẾP TỤC TẬP',
              onPressed: () => context.push('/workout/active'),
            ),
          ),
        ],
      ),
    );
  }
}
