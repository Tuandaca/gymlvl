import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/candy_colors.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../ui/widgets/system_button.dart';
import '../providers/exercise_providers.dart';
import '../controllers/active_workout_controller.dart';
import '../controllers/workout_history_controller.dart';
import '../widgets/workout_summary_card.dart';
import '../../workout_copy.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  @override
  void initState() {
    super.initState();
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
      appBar: AppBar(title: Text('training_title'.tr(ref))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active workout resume card
            if (workoutState.hasActiveWorkout)
              _buildResumeCard(
                workoutState,
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

            // Start new workout
            if (!workoutState.hasActiveWorkout) ...[
              _buildStartCard(),
              const SizedBox(height: 32),
            ],

            // Recent workouts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'recent'.tr(ref),
                  style: const TextStyle(
                    fontFamily: CandyFonts.display,
                    color: AppTheme.cyanNeon,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/workout/history'),
                  child: Text(
                    'view_all'.tr(ref),
                    style: const TextStyle(
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
                      color: AppTheme.panelBackground.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.cyanNeon.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 40,
                          color: AppTheme.textDim.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'no_workouts_yet'.tr(ref),
                          style: const TextStyle(
                            color: AppTheme.textDim,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: workouts
                      .map(
                        (w) => WorkoutSummaryCard(
                          workout: w,
                          onTap: () => context.push('/workout/detail/${w.id}'),
                        ),
                      )
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
                child: Text(
                  'Error: $err',
                  style: const TextStyle(color: AppTheme.dangerOrange),
                ),
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
            gradient: LinearGradient(
              colors: [
                AppTheme.cyanNeon.withValues(alpha: 0.06),
                AppTheme.purpleNeon.withValues(alpha: 0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.cyanNeon.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.cyanNeon.withValues(alpha: 0.05),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(
                Icons.fitness_center_rounded,
                size: 60,
                color: AppTheme.cyanNeon,
              ),
              const SizedBox(height: 16),
              Text(
                'ready_to_level_up'.tr(ref),
                style: const TextStyle(
                  color: AppTheme.textMain,
                  fontSize: 20,
                  fontFamily: CandyFonts.display,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'start_workout_desc'.tr(ref),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textDim, fontSize: 14),
              ),
              const SizedBox(height: 24),
              SystemButton(
                text: 'start_session'.tr(ref),
                onPressed: () => context.push('/workout/active'),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms)
        .scale(
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
            AppTheme.successGreen.withValues(alpha: 0.15),
            AppTheme.cyanNeon.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.successGreen.withValues(alpha: 0.1),
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
                      color: AppTheme.successGreen.withValues(alpha: 0.6),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'active_workout'.tr(ref),
                style: const TextStyle(
                  fontFamily: CandyFonts.display,
                  color: AppTheme.successGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            workoutText(ref, 'interrupted_title'),
            style: const TextStyle(
              color: AppTheme.textMain,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${workoutState.exercises.length} ${'exercises'.tr(ref).toLowerCase()} · ${workoutState.totalSets} sets · ${workoutState.formattedElapsed}',
            style: const TextStyle(color: AppTheme.textDim, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: BorderSide(
                      color: AppTheme.dangerOrange.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(workoutText(ref, 'discard_interrupted')),
                        content: Text(workoutText(ref, 'leave_hint')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(workoutText(ref, 'cancel')),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.dangerOrange,
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(
                              workoutText(ref, 'discard_interrupted'),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && mounted) {
                      await ref
                          .read(activeWorkoutControllerProvider.notifier)
                          .discardLocalBackup();
                    }
                  },
                  child: Text(
                    workoutText(ref, 'discard_interrupted'),
                    style: const TextStyle(
                      color: AppTheme.dangerOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SystemButton(
                  text: workoutText(ref, 'resume_interrupted'),
                  onPressed: () => context.push('/workout/active'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
