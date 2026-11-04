import 'package:app/features/workout/domain/exercise.dart';
import 'package:app/features/workout/domain/workout_mode_contract.dart';
import 'first_week_plan_models.dart';

/// Deterministic first-week plan engine for beginners.
///
/// Pure Dart: no I/O, no randomness, no clock, no server calls. Same input
/// always yields the same plan, in the same order, which makes retry safe —
/// regenerating a plan yields the identical plan and never creates duplicate
/// plans or workouts at the domain level.
///
/// The client never persists progression. This engine only previews a plan;
/// `complete_workout` remains the sole authoritative award path.
class FirstWeekPlanEngine {
  /// Beginner plans are capped at 3 days per week.
  static const int _planDays = 3;

  /// Exercises per plan day (full-body routine).
  static const int _exercisesPerDay = 3;

  /// Sets per exercise for beginners.
  static const int _sets = 3;

  /// Prescribed reps per set (beginner range 8-12, midpoint).
  static const int _reps = 10;

  /// Light starter weight in kg for reps-weight exercises.
  static const double _starterWeightKg = 5.0;

  /// Generates a first-week plan for [profile] from [catalog].
  ///
  /// Returns an empty plan (no days) when the user is a returning user
  /// ([BeginnerProfile.completedWorkoutCount] > 0) or not a beginner, so
  /// existing history is never overwritten.
  ///
  /// Throws [ArgumentError] when [profile] is null or [catalog] is empty, and
  /// when the catalog does not contain enough beginner-suitable exercises.
  FirstWeekPlan generate(BeginnerProfile? profile, List<Exercise> catalog) {
    if (profile == null) {
      throw ArgumentError('profile must not be null');
    }
    if (catalog.isEmpty) {
      throw ArgumentError('exercise catalog must not be empty');
    }

    // Returning users and non-beginners do not receive a generated plan.
    // Existing history is preserved and never overwritten at the domain level.
    if (profile.isReturningUser || !profile.isBeginner) {
      return FirstWeekPlan.empty(profile.userId);
    }

    // Deterministic selection: sort by stable exercise id, no random, no clock.
    final suitable = <Exercise>[];
    for (final exercise in catalog) {
      if (_isBeginnerSuitable(exercise)) {
        suitable.add(exercise);
      }
    }
    suitable.sort((a, b) => a.id.compareTo(b.id));

    final needed = _planDays * _exercisesPerDay;
    if (suitable.length < needed) {
      throw ArgumentError(
        'exercise catalog has ${suitable.length} beginner-suitable exercises, '
        '$needed are required for a first-week plan',
      );
    }

    final selected = suitable.take(needed).toList();

    final days = <PlanDay>[];
    for (var dayIndex = 0; dayIndex < _planDays; dayIndex++) {
      final dayExercises = <PlannedExercise>[];
      for (var exIndex = 0; exIndex < _exercisesPerDay; exIndex++) {
        final exercise = selected[dayIndex * _exercisesPerDay + exIndex];
        final isBodyweight = exercise.isBodyweight;
        final mode = isBodyweight
            ? WorkoutMode.bodyweight
            : WorkoutMode.repsWeight;
        dayExercises.add(
          PlannedExercise(
            exerciseId: exercise.id,
            exerciseName: exercise.name,
            category: exercise.category,
            mode: mode,
            sets: _sets,
            reps: _reps,
            // weight_kg for bodyweight mode is external load, not body mass.
            // 0 means bodyweight only with no added load.
            starterWeightKg: isBodyweight ? 0.0 : _starterWeightKg,
            orderIndex: exIndex,
          ),
        );
      }
      days.add(
        PlanDay(
          dayNumber: dayIndex + 1,
          dayName: 'Day ${dayIndex + 1}',
          exercises: dayExercises,
        ),
      );
    }

    return FirstWeekPlan(userId: profile.userId, days: days, version: 1);
  }

  /// True when [exercise] is suitable for a beginner reps-based first week.
  ///
  /// Timed/cardio exercises are excluded. Bodyweight and reps-weight exercises
  /// are included and mapped to their respective modes.
  bool _isBeginnerSuitable(Exercise exercise) => !exercise.isTimeBased;
}
