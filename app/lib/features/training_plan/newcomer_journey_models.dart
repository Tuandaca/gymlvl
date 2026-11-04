// Models for the newcomer journey state machine.
//
// Pure Dart, immutable value types. No code generation, no I/O. The state
// machine is deterministic and fully reconstructable from stored inputs.

/// Events that drive the newcomer journey.
enum JourneyEvent {
  /// Profile completed; no completed-workout history.
  profileComplete,

  /// User opened the generated plan.
  planOpened,

  /// First workout of the plan was started.
  workoutStarted,

  /// A workout was completed via complete_workout.
  workoutCompleted,

  /// First week finished (3rd workout completed -> progression unlocked).
  firstWeekComplete,
}

/// Outcome of a journey transition. Describes which side effects (if any) the
/// caller should perform. Used to avoid duplicate workout creation and duplicate
/// completion/reward awards on retry.
class JourneyOutcome {
  /// Create a new workout (true) — performed exactly once per workout start.
  final bool workoutCreated;

  /// Award completion (true) — performed exactly once per workout completion.
  final bool completionAwarded;

  /// Unlock progression (true) — performed when the 3rd workout completes.
  final bool progressionUnlocked;

  const JourneyOutcome({
    required this.workoutCreated,
    required this.completionAwarded,
    required this.progressionUnlocked,
  });

  /// No side effects.
  static const JourneyOutcome none = JourneyOutcome(
    workoutCreated: false,
    completionAwarded: false,
    progressionUnlocked: false,
  );

  /// Returns a copy of [this] with the given fields replaced.
  JourneyOutcome copyWith({
    bool? workoutCreated,
    bool? completionAwarded,
    bool? progressionUnlocked,
  }) {
    return JourneyOutcome(
      workoutCreated: workoutCreated ?? this.workoutCreated,
      completionAwarded: completionAwarded ?? this.completionAwarded,
      progressionUnlocked: progressionUnlocked ?? this.progressionUnlocked,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JourneyOutcome &&
          runtimeType == other.runtimeType &&
          workoutCreated == other.workoutCreated &&
          completionAwarded == other.completionAwarded &&
          progressionUnlocked == other.progressionUnlocked;

  @override
  int get hashCode =>
      Object.hash(workoutCreated, completionAwarded, progressionUnlocked);

  @override
  String toString() =>
      'JourneyOutcome(workoutCreated: $workoutCreated, '
      'completionAwarded: $completionAwarded, '
      'progressionUnlocked: $progressionUnlocked)';
}

/// Durable inputs used to reconstruct and drive the journey state machine.
///
/// All values are read-only inputs owned elsewhere (server-owned completion
/// count, UI flags). The client never writes progression.
class NewcomerJourneyContext {
  /// Server-owned count of completed workouts. Greater than zero means a
  /// returning user.
  final int completedWorkoutCount;

  /// Whether the plan has been opened (planAvailable -> planStarted).
  final bool planStarted;

  /// Last completed plan day (1-3), or null when none completed.
  final int? lastCompletedDay;

  const NewcomerJourneyContext({
    required this.completedWorkoutCount,
    required this.planStarted,
    this.lastCompletedDay,
  });

  /// Returns a copy of [this] with the given fields replaced.
  NewcomerJourneyContext copyWith({
    int? completedWorkoutCount,
    bool? planStarted,
    int? lastCompletedDay,
  }) {
    return NewcomerJourneyContext(
      completedWorkoutCount:
          completedWorkoutCount ?? this.completedWorkoutCount,
      planStarted: planStarted ?? this.planStarted,
      lastCompletedDay: lastCompletedDay ?? this.lastCompletedDay,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewcomerJourneyContext &&
          runtimeType == other.runtimeType &&
          completedWorkoutCount == other.completedWorkoutCount &&
          planStarted == other.planStarted &&
          lastCompletedDay == other.lastCompletedDay;

  @override
  int get hashCode =>
      Object.hash(completedWorkoutCount, planStarted, lastCompletedDay);

  @override
  String toString() =>
      'NewcomerJourneyContext(completedWorkoutCount: $completedWorkoutCount, '
      'planStarted: $planStarted, lastCompletedDay: $lastCompletedDay)';
}

/// Result of a journey transition: the next state and the side-effect outcome.
class NewcomerJourneyResult {
  final NewcomerJourneyState state;
  final JourneyOutcome outcome;

  const NewcomerJourneyResult({required this.state, required this.outcome});

  /// Returns a copy of [this] with the given fields replaced.
  NewcomerJourneyResult copyWith({
    NewcomerJourneyState? state,
    JourneyOutcome? outcome,
  }) {
    return NewcomerJourneyResult(
      state: state ?? this.state,
      outcome: outcome ?? this.outcome,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewcomerJourneyResult &&
          runtimeType == other.runtimeType &&
          state == other.state &&
          outcome == other.outcome;

  @override
  int get hashCode => Object.hash(state, outcome);

  @override
  String toString() =>
      'NewcomerJourneyResult(state: $state, outcome: $outcome)';
}

/// State of a newcomer's first-week journey.
///
/// Linear lifecycle:
///   noHistory -> planAvailable -> planStarted -> workoutPartial ->
///   workoutComplete -> progressionAvailable -> returningUser
///
/// `returningUser` is a stable terminal state.
sealed class NewcomerJourneyState {
  const NewcomerJourneyState();
}

/// Fresh newcomer: no profile, no plan, no history.
final class NoHistory extends NewcomerJourneyState {
  const NoHistory();

  @override
  String toString() => 'noHistory';
}

/// Profile complete, plan generated, plan not yet opened.
final class PlanAvailable extends NewcomerJourneyState {
  const PlanAvailable();

  @override
  String toString() => 'planAvailable';
}

/// Plan opened, first workout not yet started.
final class PlanStarted extends NewcomerJourneyState {
  const PlanStarted();

  @override
  String toString() => 'planStarted';
}

/// First workout started, not yet completed.
final class WorkoutPartial extends NewcomerJourneyState {
  const WorkoutPartial();

  @override
  String toString() => 'workoutPartial';
}

/// A workout completed (not yet the 3rd).
final class WorkoutComplete extends NewcomerJourneyState {
  const WorkoutComplete();

  @override
  String toString() => 'workoutComplete';
}

/// 3rd workout completed: progression unlocked.
final class ProgressionAvailable extends NewcomerJourneyState {
  const ProgressionAvailable();

  @override
  String toString() => 'progressionAvailable';
}

/// Returning user (has completed-workout history): terminal stable state.
final class ReturningUser extends NewcomerJourneyState {
  const ReturningUser();

  @override
  String toString() => 'returningUser';
}
