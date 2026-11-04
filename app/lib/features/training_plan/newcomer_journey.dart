import 'newcomer_journey_models.dart';

/// Pure state-transition logic for the newcomer journey.
///
/// No I/O, no randomness, no clock. Invalid transitions throw
/// [ArgumentError]. The machine is retry-safe: repeating a transition returns
/// the same state with no side effects, and re-entering a terminal state keeps
/// it unchanged. No duplicate workout creation or completion reward occurs on
/// retry.
///
/// State is reconstructable from durable inputs via [reconstruct], so the
/// journey can be resumed safely after a restart without duplicating workouts
/// or rewards.
class NewcomerJourney {
  /// Apply [event] to [current] using [context], returning the next state and
  /// the side-effect outcome the caller should perform.
  ///
  /// The outcome flags tell the caller whether to create a workout, award a
  /// completion, or unlock progression. Flags are false for no-op/retry
  /// transitions, preventing duplicates.
  NewcomerJourneyResult transition({
    required NewcomerJourneyState current,
    required JourneyEvent event,
    required NewcomerJourneyContext context,
  }) {
    switch (current) {
      case NoHistory():
        if (event == JourneyEvent.profileComplete &&
            context.completedWorkoutCount == 0) {
          return NewcomerJourneyResult(
            state: const PlanAvailable(),
            outcome: JourneyOutcome.none,
          );
        }
        break;
      case PlanAvailable():
        if (event == JourneyEvent.planOpened) {
          return NewcomerJourneyResult(
            state: const PlanStarted(),
            outcome: JourneyOutcome.none,
          );
        }
        break;
      case PlanStarted():
        if (event == JourneyEvent.workoutStarted) {
          return NewcomerJourneyResult(
            state: const WorkoutPartial(),
            outcome: const JourneyOutcome(
              workoutCreated: true,
              completionAwarded: false,
              progressionUnlocked: false,
            ),
          );
        }
        break;
      case WorkoutPartial():
        if (event == JourneyEvent.workoutCompleted) {
          return NewcomerJourneyResult(
            state: const WorkoutComplete(),
            outcome: const JourneyOutcome(
              workoutCreated: false,
              completionAwarded: true,
              progressionUnlocked: false,
            ),
          );
        }
        break;
      case WorkoutComplete():
        if (event == JourneyEvent.workoutCompleted) {
          final isThird = context.completedWorkoutCount >= 3;
          if (isThird) {
            return NewcomerJourneyResult(
              state: const ProgressionAvailable(),
              outcome: const JourneyOutcome(
                workoutCreated: false,
                completionAwarded: true,
                progressionUnlocked: true,
              ),
            );
          }
          // Retry / re-completion before the 3rd workout: no duplicate award.
          return NewcomerJourneyResult(
            state: const WorkoutComplete(),
            outcome: JourneyOutcome.none,
          );
        }
        break;
      case ProgressionAvailable():
        if (event == JourneyEvent.firstWeekComplete) {
          return NewcomerJourneyResult(
            state: const ReturningUser(),
            outcome: JourneyOutcome.none,
          );
        }
        break;
      case ReturningUser():
        return NewcomerJourneyResult(
          state: const ReturningUser(),
          outcome: JourneyOutcome.none,
        );
    }

    throw ArgumentError(
      'Invalid newcomer journey transition: $current --$event-->',
    );
  }

  /// Reconstructs the current state from durable inputs.
  ///
  /// The client never persists progression; this rebuilds the machine state
  /// from the server-owned completion count and UI flags so the journey can be
  /// resumed safely after a restart.
  static NewcomerJourneyState reconstruct({
    required int completedWorkoutCount,
    required bool planStarted,
    required int? lastCompletedDay,
  }) {
    if (completedWorkoutCount > 0) {
      return const ReturningUser();
    }
    if (lastCompletedDay != null && lastCompletedDay >= 3) {
      return const ProgressionAvailable();
    }
    if (lastCompletedDay != null) {
      return const WorkoutComplete();
    }
    if (planStarted) {
      return const WorkoutPartial();
    }
    return const PlanAvailable();
  }

  /// True when [state] is the stable terminal returning-user state.
  static bool isTerminal(NewcomerJourneyState state) => state is ReturningUser;

  /// True when [state] represents an active, incomplete workout.
  static bool isWorkoutInProgress(NewcomerJourneyState state) =>
      state is PlanStarted || state is WorkoutPartial;

  /// True when [state] means at least one plan workout was completed.
  static bool hasCompletedWorkout(NewcomerJourneyState state) =>
      state is WorkoutComplete ||
      state is ProgressionAvailable ||
      state is ReturningUser;
}
