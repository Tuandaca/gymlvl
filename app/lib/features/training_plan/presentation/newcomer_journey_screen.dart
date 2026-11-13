import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/training_plan/first_week_plan_models.dart';
import 'package:app/features/training_plan/presentation/providers/training_plan_providers.dart';
import 'package:app/features/training_plan/presentation/screens/routine_list_screen.dart';
import 'package:app/features/training_plan/newcomer_journey.dart';
import 'package:app/features/training_plan/newcomer_journey_models.dart';
import 'package:app/features/workout/domain/workout_mode_contract.dart';
import '../../../../core/localization/localization_engine.dart';
import '../../../../core/theme/candy_colors.dart';
import '../../../../ui/candy/candy_button.dart';
import '../../../../ui/candy/candy_card.dart';
import '../../../../ui/candy/candy_empty_state.dart';
import '../../../../ui/candy/candy_error_state.dart';
import '../../../../ui/candy/candy_scaffold.dart';

/// Plan entry point that keeps first-week and experienced routing explicit.
/// Experienced users enter the existing routine selector; this widget never
/// creates prescriptions or assigns starter loads.
class PlanEntryScreen extends ConsumerWidget {
  const PlanEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(planRouteProvider);
    return route.when(
      loading: () =>
          const CandyScaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) =>
          CandyScaffold(body: Center(child: Text(error.toString()))),
      data: (destination) => destination == PlanRoute.routineSelection
          ? const RoutineListScreen()
          : const NewcomerJourneyScreen(),
    );
  }
}

/// Newcomer journey screen: first-week plan + journey state machine UI.
///
/// Displays the [NewcomerJourneyState] and, when a [FirstWeekPlan] exists, the
/// 3 days x 3 exercises as Candy cards. Bodyweight exercises render
/// `starterWeightKg` as added load ("Tạ thêm / Added load") — never body mass.
///
/// Retry-safe: start/continue taps are gated behind [JourneyOutcome] flags so a
/// re-tap never creates a duplicate workout or award. Side effects (workout
/// creation, completion, progression unlock) are delegated to callbacks owned
/// by the caller; this screen never writes progression or calls the server.
class NewcomerJourneyScreen extends ConsumerWidget {
  /// Current journey state (reconstructed from durable inputs by the caller).
  final NewcomerJourneyState state;

  /// Generated first-week plan, or null/empty when no plan exists.
  final FirstWeekPlan? plan;

  /// Server-owned completed-workout count (read-only).
  final int completedWorkoutCount;

  /// Whether the plan has been opened.
  final bool planStarted;

  /// Last completed plan day (1-3), or null.
  final int? lastCompletedDay;

  /// Invoked when the user starts the first workout and
  /// [JourneyOutcome.workoutCreated] is true.
  final VoidCallback? onStartWorkout;

  /// Invoked when the user continues an in-progress workout.
  final VoidCallback? onContinueWorkout;

  /// Invoked when the user retries after an error.
  final VoidCallback? onRetry;

  /// True while data is being loaded.
  final bool isLoading;

  /// Error message when loading failed.
  final String? error;

  const NewcomerJourneyScreen({
    super.key,
    this.state = const NoHistory(),
    this.plan,
    this.completedWorkoutCount = 0,
    this.planStarted = false,
    this.lastCompletedDay,
    this.onStartWorkout,
    this.onContinueWorkout,
    this.onRetry,
    this.isLoading = false,
    this.error,
  });

  String _dayLabel(int dayNumber, WidgetRef ref) {
    switch (dayNumber) {
      case 1:
        return 'day_1'.tr(ref);
      case 2:
        return 'day_2'.tr(ref);
      case 3:
        return 'day_3'.tr(ref);
      default:
        return 'Day $dayNumber';
    }
  }

  String _modeLabel(WorkoutMode mode, WidgetRef ref) {
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

  String _formatWeight(double kg) {
    if (kg == kg.truncateToDouble()) {
      return '${kg.toInt()} kg';
    }
    return '${kg.toStringAsFixed(1)} kg';
  }

  String _journeyStateLabel(NewcomerJourneyState s, WidgetRef ref) {
    if (s is NoHistory) return 'journey_no_history'.tr(ref);
    if (s is PlanAvailable) return 'journey_plan_available'.tr(ref);
    if (s is PlanStarted) return 'journey_plan_started'.tr(ref);
    if (s is WorkoutPartial) return 'journey_workout_partial'.tr(ref);
    if (s is WorkoutComplete) return 'journey_workout_complete'.tr(ref);
    if (s is ProgressionAvailable) {
      return 'journey_progression_available'.tr(ref);
    }
    if (s is ReturningUser) return 'journey_returning_user'.tr(ref);
    return '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (error != null) {
      return _buildError(ref);
    }
    if (isLoading) {
      return _buildLoading(ref);
    }
    if (plan == null || plan!.isEmpty) {
      return _buildEmpty(ref);
    }
    return _buildContent(ref);
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // States
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildLoading(WidgetRef ref) => CandyScaffold(
    appBar: AppBar(
      title: Text('plan_title'.tr(ref)),
      backgroundColor: CandyColors.canvas,
      elevation: 0,
      centerTitle: true,
    ),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16.0),
          Text(
            'loading'.tr(ref),
            style: const TextStyle(
              fontFamily: CandyFonts.body,
              fontSize: 14,
              color: CandyColors.charcoal,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildError(WidgetRef ref) => CandyScaffold(
    appBar: AppBar(
      title: Text('plan_title'.tr(ref)),
      backgroundColor: CandyColors.canvas,
      elevation: 0,
      centerTitle: true,
    ),
    body: Center(
      child: CandyErrorState(
        title: 'error_title'.tr(ref),
        message: error ?? '',
        retryLabel: 'retry'.tr(ref),
        onRetry: onRetry,
      ),
    ),
  );

  Widget _buildEmpty(WidgetRef ref) => CandyScaffold(
    appBar: AppBar(
      title: Text('plan_title'.tr(ref)),
      backgroundColor: CandyColors.canvas,
      elevation: 0,
      centerTitle: true,
    ),
    body: Center(
      child: CandyEmptyState(
        icon: Icons.fitness_center_outlined,
        title: state is ReturningUser
            ? 'journey_returning_user'.tr(ref)
            : state is NoHistory
            ? 'journey_no_history'.tr(ref)
            : 'plan_empty'.tr(ref),
        message: 'plan_empty'.tr(ref),
        actionLabel: null,
        onAction: null,
      ),
    ),
  );

  Widget _buildContent(WidgetRef ref) {
    final current = state;

    return CandyScaffold(
      appBar: AppBar(
        title: Text(
          'plan_title'.tr(ref),
          style: const TextStyle(fontFamily: CandyFonts.display),
        ),
        backgroundColor: CandyColors.canvas,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Journey state badge.
            Semantics(
              label:
                  '${'plan_title'.tr(ref)}: ${_journeyStateLabel(current, ref)}',
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: CandyColors.card,
                  border: CandyColors.standardBorder(),
                  borderRadius: BorderRadius.circular(CandyColors.pillRadius),
                ),
                child: Text(
                  _journeyStateLabel(current, ref),
                  style: const TextStyle(
                    fontFamily: CandyFonts.display,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: CandyColors.ink,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Bodyweight reference note (added load, not body mass).
            CandyCard(
              shadow: CandyCardShadow.small,
              backgroundColor: CandyColors.canaryYellow.withValues(alpha: 0.15),
              borderColor: CandyColors.canaryYellow,
              padding: const EdgeInsets.all(14.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info, size: 20, color: CandyColors.ink),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      'bodyweight_note'.tr(ref),
                      style: const TextStyle(
                        fontFamily: CandyFonts.body,
                        fontSize: 13,
                        color: CandyColors.ink,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),

            // 3 days x 3 exercises.
            Text(
              'exercises'.tr(ref),
              style: const TextStyle(
                fontFamily: CandyFonts.display,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: CandyColors.ink,
              ),
            ),
            const SizedBox(height: 12.0),
            ...plan!.days.map((day) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      _dayLabel(day.dayNumber, ref),
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
                        label: _exerciseSemanticsLabel(ex, ref),
                        child: _PlannedExerciseCard(exercise: ex, ref: ref),
                      ),
                    );
                  }),
                ],
              );
            }),
            const SizedBox(height: 24.0),

            // Primary start / continue action, gated behind journey outcome flags.
            _buildActionButton(ref, current),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }

  String _exerciseSemanticsLabel(PlannedExercise ex, WidgetRef ref) {
    return '${ex.exerciseName}, ${_modeLabel(ex.mode, ref)}, '
        '${ex.sets} x ${ex.reps}, ${_formatWeight(ex.starterWeightKg)}.';
  }

  Widget _buildActionButton(WidgetRef ref, NewcomerJourneyState current) {
    // Plan available but not opened yet: "Open plan" triggers planOpened
    // (no side effect). The caller advances state to PlanStarted.
    if (current is PlanAvailable) {
      return CandyButton(
        label: 'plan_open'.tr(ref),
        variant: CandyButtonVariant.primary,
        size: CandyButtonSize.medium,
        onPressed: () => _handleOpenPlan(),
      );
    }
    // Plan opened, first workout not started: "Start workout" triggers
    // workoutStarted. The side effect is gated behind outcome.workoutCreated
    // so the caller only creates a workout when the domain allows it.
    if (current is PlanStarted) {
      return CandyButton(
        label: 'start_workout'.tr(ref),
        variant: CandyButtonVariant.primary,
        size: CandyButtonSize.medium,
        onPressed: () => _handleStartWorkout(),
      );
    }
    // Workout in progress: "Continue" opens the active workout.
    if (current is WorkoutPartial) {
      return CandyButton(
        label: 'continue'.tr(ref),
        variant: CandyButtonVariant.mint,
        size: CandyButtonSize.medium,
        onPressed: onContinueWorkout,
      );
    }
    // Completed / progression / returning: no client action here; completion
    // and progression are server-authoritative via complete_workout.
    return const SizedBox.shrink();
  }

  void _handleOpenPlan() {
    final current = state;
    if (current is! PlanAvailable) return;
    final context = NewcomerJourneyContext(
      completedWorkoutCount: completedWorkoutCount,
      planStarted: planStarted,
      lastCompletedDay: lastCompletedDay,
    );
    // planOpened has no side effect (outcome.none); state advancement is
    // owned by the caller. Calling transition validates the event.
    NewcomerJourney().transition(
      current: current,
      event: JourneyEvent.planOpened,
      context: context,
    );
  }

  void _handleStartWorkout() {
    final current = state;
    if (current is! PlanStarted) return;
    final context = NewcomerJourneyContext(
      completedWorkoutCount: completedWorkoutCount,
      planStarted: planStarted,
      lastCompletedDay: lastCompletedDay,
    );

    final result = NewcomerJourney().transition(
      current: current,
      event: JourneyEvent.workoutStarted,
      context: context,
    );

    // Gate the side effect behind the outcome flag: only create a workout
    // when the domain says so. The caller advances state to WorkoutPartial
    // after a successful start, so a re-tap cannot re-fire workoutStarted.
    if (result.outcome.workoutCreated) {
      onStartWorkout?.call();
    }
  }
}

/// One prescribed exercise card: name, category, mode, sets x reps, weight.
class _PlannedExerciseCard extends StatelessWidget {
  final PlannedExercise exercise;
  final WidgetRef ref;

  const _PlannedExerciseCard({required this.exercise, required this.ref});

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
                  _modeLabel(exercise.mode, ref),
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

  String _modeLabel(WorkoutMode mode, WidgetRef ref) {
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

  String _formatWeight(double kg) {
    if (kg == kg.truncateToDouble()) {
      return '${kg.toInt()} kg';
    }
    return '${kg.toStringAsFixed(1)} kg';
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
