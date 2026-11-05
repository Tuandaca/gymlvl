// FirstWeekPlan → P2 Routine/Schedule Adapter
//
// Converts M5 FirstWeekPlan output to P2 Routine + Schedule representation.
// This provides compatibility without duplicating the planning universe.

import 'routine_models.dart';
import 'first_week_plan_models.dart';
import 'routine_repository.dart';

class FirstWeekPlanAdapter {
  const FirstWeekPlanAdapter();

  static int _idSequence = 0;

  String _nextId(String suffix) =>
      '${DateTime.now().microsecondsSinceEpoch}-${_idSequence++}-$suffix';

  /// Converts a FirstWeekPlan into a list of P2 Routines + Schedules.
  ///
  /// The FirstWeekPlan generates a 3-day beginner plan. We map each PlanDay
  /// to a P2 Routine, and assign it to the corresponding weekday via
  /// RoutineSchedule (fixed_week mode).
  ///
  /// Returns a list of (Routine, ScheduleConfig) pairs ready for persistence.
  List<({Routine routine, ScheduleRoutineConfig schedule})> convert(
    FirstWeekPlan plan,
    String userId,
  ) {
    final results = <({Routine routine, ScheduleRoutineConfig schedule})>[];

    for (var planIndex = 0; planIndex < plan.days.length; planIndex++) {
      final day = plan.days[planIndex];
      // Create routine for this day
      final routine = _createRoutineFromPlanDay(
        userId: userId,
        day: day,
        planIndex: planIndex,
      );

      // Schedule on the corresponding weekday (1=Mon...7=Sun)
      // day.dayNumber is 1, 2, 3 for the 3-day plan
      // We map: day 1 -> Monday (1), day 2 -> Wednesday (3), day 3 -> Friday (5)
      final weekday = _mapPlanDayToWeekday(day.dayNumber);

      final schedule = ScheduleRoutineConfig.fixedWeek(
        routineId: routine.id,
        weekday: weekday,
      );

      results.add((routine: routine, schedule: schedule));
    }

    return results;
  }

  /// Creates a P2 Routine from a PlanDay.
  Routine _createRoutineFromPlanDay({
    required String userId,
    required PlanDay day,
    required int planIndex,
  }) {
    final exercises = <RoutineExercise>[];

    for (var i = 0; i < day.exercises.length; i++) {
      final plannedEx = day.exercises[i];
      exercises.add(
        RoutineExercise(
          id: _nextId('exercise-$planIndex-$i'),
          routineId: '', // Set after routine creation
          exerciseId: plannedEx.exerciseId,
          orderIndex: i,
          sets: plannedEx.sets,
          reps: plannedEx.reps,
          weightKg: plannedEx.starterWeightKg,
          restSeconds: 90,
          mode: plannedEx.mode,
          notes: plannedEx.category,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }

    return Routine(
      id: _nextId('routine-$planIndex'),
      userId: userId,
      name: 'First Week - Day ${day.dayNumber}',
      emoji: '🌱',
      exercises: exercises,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Maps FirstWeekPlan day number (1, 2, 3) to weekday (1=Mon...7=Sun).
  ///
  /// Standard beginner schedule: Mon, Wed, Fri
  int _mapPlanDayToWeekday(int planDayNumber) {
    switch (planDayNumber) {
      case 1:
        return 1; // Monday
      case 2:
        return 3; // Wednesday
      case 3:
        return 5; // Friday
      default:
        return 1; // Default to Monday
    }
  }

  /// Persists the converted routines and schedules to the repository.
  Future<void> persist({
    required RoutineRepository repository,
    required FirstWeekPlan plan,
    required String userId,
  }) async {
    final converted = convert(plan, userId);

    for (final item in converted) {
      // Create routine
      final createdRoutine = await repository.createRoutine(item.routine);

      // Schedule it
      await repository.scheduleRoutine(
        routineId: createdRoutine.id,
        config: item.schedule,
      );
    }
  }
}
