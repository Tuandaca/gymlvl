import 'package:app/features/workout/domain/workout_mode_contract.dart';

/// Input profile for first-week plan generation.
///
/// Only beginners ([experienceLevel] == 'beginner') with no completed-workout
/// history receive a generated plan. Returning users and non-beginners get an
/// empty plan — the client never overwrites existing history.
class BeginnerProfile {
  /// Stable user identifier.
  final String userId;

  /// Experience level: 'beginner', 'intermediate', or 'advanced'.
  final String experienceLevel;

  /// Server-owned count of completed workouts. The client reads this but never
  /// writes it. Greater than zero means a returning user.
  final int completedWorkoutCount;

  const BeginnerProfile({
    required this.userId,
    required this.experienceLevel,
    this.completedWorkoutCount = 0,
  });

  /// Returns a copy of [this] with the given fields replaced.
  BeginnerProfile copyWith({
    String? userId,
    String? experienceLevel,
    int? completedWorkoutCount,
  }) {
    return BeginnerProfile(
      userId: userId ?? this.userId,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      completedWorkoutCount:
          completedWorkoutCount ?? this.completedWorkoutCount,
    );
  }

  /// True when the profile is a beginner.
  bool get isBeginner => experienceLevel.toLowerCase() == 'beginner';

  /// True when the user already has completed-workout history.
  bool get isReturningUser => completedWorkoutCount > 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BeginnerProfile &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          experienceLevel == other.experienceLevel &&
          completedWorkoutCount == other.completedWorkoutCount;

  @override
  int get hashCode =>
      Object.hash(userId, experienceLevel, completedWorkoutCount);

  @override
  String toString() =>
      'BeginnerProfile(userId: $userId, experienceLevel: $experienceLevel, '
      'completedWorkoutCount: $completedWorkoutCount)';
}

/// One prescribed exercise within a first-week plan day.
class PlannedExercise {
  /// Stable catalogue exercise id.
  final String exerciseId;

  /// Human-readable exercise name (localized by the UI layer).
  final String exerciseName;

  /// Catalogue category (e.g. 'Chest', 'Back', 'Legs', 'Shoulders', 'Arms',
  /// 'Core').
  final String category;

  /// Workout mode. Beginners use [WorkoutMode.bodyweight] or
  /// [WorkoutMode.repsWeight]; timed/cardio are not used in the first week.
  final WorkoutMode mode;

  /// Number of sets (beginner: 3).
  final int sets;

  /// Prescribed reps (beginner range 8-12).
  final int reps;

  /// Starter weight in kg.
  ///
  /// For [WorkoutMode.bodyweight] this is EXTERNAL/ADDED load (weight_kg),
  /// never body mass. A value of 0 means bodyweight only with no added load.
  /// For [WorkoutMode.repsWeight] this is a light starter load.
  final double starterWeightKg;

  /// Position of the exercise within the day (0-based).
  final int orderIndex;

  const PlannedExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.category,
    required this.mode,
    required this.sets,
    required this.reps,
    required this.starterWeightKg,
    required this.orderIndex,
  });

  /// Returns a copy of [this] with the given fields replaced.
  PlannedExercise copyWith({
    String? exerciseId,
    String? exerciseName,
    String? category,
    WorkoutMode? mode,
    int? sets,
    int? reps,
    double? starterWeightKg,
    int? orderIndex,
  }) {
    return PlannedExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      category: category ?? this.category,
      mode: mode ?? this.mode,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      starterWeightKg: starterWeightKg ?? this.starterWeightKg,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlannedExercise &&
          runtimeType == other.runtimeType &&
          exerciseId == other.exerciseId &&
          exerciseName == other.exerciseName &&
          category == other.category &&
          mode == other.mode &&
          sets == other.sets &&
          reps == other.reps &&
          starterWeightKg == other.starterWeightKg &&
          orderIndex == other.orderIndex;

  @override
  int get hashCode => Object.hash(
    exerciseId,
    exerciseName,
    category,
    mode,
    sets,
    reps,
    starterWeightKg,
    orderIndex,
  );

  @override
  String toString() =>
      'PlannedExercise(exerciseId: $exerciseId, exerciseName: $exerciseName, '
      'category: $category, mode: ${mode.wireValue}, sets: $sets, reps: $reps, '
      'starterWeightKg: $starterWeightKg, orderIndex: $orderIndex)';
}

/// One day within the first-week plan (Day 1, Day 2, or Day 3).
class PlanDay {
  /// Day number within the first week (1, 2, or 3).
  final int dayNumber;

  /// Display name, e.g. 'Day 1'.
  final String dayName;

  /// Exercises planned for this day. Exactly 3 for a complete beginner plan.
  final List<PlannedExercise> exercises;

  const PlanDay({
    required this.dayNumber,
    required this.dayName,
    required this.exercises,
  });

  /// Number of exercises planned for this day.
  int get exerciseCount => exercises.length;

  /// Returns a copy of [this] with the given fields replaced.
  PlanDay copyWith({
    int? dayNumber,
    String? dayName,
    List<PlannedExercise>? exercises,
  }) {
    return PlanDay(
      dayNumber: dayNumber ?? this.dayNumber,
      dayName: dayName ?? this.dayName,
      exercises: exercises ?? this.exercises,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlanDay &&
          runtimeType == other.runtimeType &&
          dayNumber == other.dayNumber &&
          dayName == other.dayName &&
          _plannedExerciseListEquals(exercises, other.exercises);

  @override
  int get hashCode =>
      Object.hash(dayNumber, dayName, Object.hashAll(exercises));

  @override
  String toString() =>
      'PlanDay(dayNumber: $dayNumber, dayName: $dayName, exerciseCount: $exerciseCount)';
}

/// The complete first-week plan: exactly 3 days, 3 exercises per day.
///
/// Deterministic: the same [BeginnerProfile] and exercise catalog always
/// produce the same plan, in the same order. An empty plan ([isEmpty]) means
/// no plan was generated (returning user, non-beginner, or generation not
/// applicable) and no history was overwritten.
class FirstWeekPlan {
  final String userId;
  final List<PlanDay> days;
  final int version;

  const FirstWeekPlan({
    required this.userId,
    required this.days,
    this.version = 1,
  });

  /// An empty (no-plan) result for [userId].
  factory FirstWeekPlan.empty(String userId) =>
      FirstWeekPlan(userId: userId, days: const []);

  bool get isEmpty => days.isEmpty;
  bool get isNotEmpty => days.isNotEmpty;
  int get dayCount => days.length;

  /// Returns a copy of [this] with the given fields replaced.
  FirstWeekPlan copyWith({String? userId, List<PlanDay>? days, int? version}) {
    return FirstWeekPlan(
      userId: userId ?? this.userId,
      days: days ?? this.days,
      version: version ?? this.version,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FirstWeekPlan &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          version == other.version &&
          _planDayListEquals(days, other.days);

  @override
  int get hashCode => Object.hash(userId, version, Object.hashAll(days));

  @override
  String toString() =>
      'FirstWeekPlan(userId: $userId, version: $version, dayCount: $dayCount)';
}

bool _plannedExerciseListEquals(
  List<PlannedExercise> a,
  List<PlannedExercise> b,
) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool _planDayListEquals(List<PlanDay> a, List<PlanDay> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
