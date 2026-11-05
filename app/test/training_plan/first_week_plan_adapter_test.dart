import 'package:app/features/training_plan/first_week_plan_adapter.dart';
import 'package:app/features/training_plan/first_week_plan_models.dart';
import 'package:app/features/training_plan/routine_models.dart';
import 'package:app/features/workout/domain/workout_mode_contract.dart';
import 'package:flutter_test/flutter_test.dart';

PlannedExercise _exercise(
  String id, {
  required int orderIndex,
  WorkoutMode mode = WorkoutMode.repsWeight,
  double weightKg = 10,
}) {
  return PlannedExercise(
    exerciseId: id,
    exerciseName: id,
    category: 'Chest',
    mode: mode,
    sets: 3,
    reps: 10,
    starterWeightKg: weightKg,
    orderIndex: orderIndex,
  );
}

PlanDay _day(int dayNumber, List<PlannedExercise> exercises) {
  return PlanDay(
    dayNumber: dayNumber,
    dayName: 'Day $dayNumber',
    exercises: exercises,
  );
}

FirstWeekPlan _plan() {
  return FirstWeekPlan(
    userId: 'user-1',
    days: [
      _day(1, [
        _exercise(
          'push-up',
          orderIndex: 0,
          mode: WorkoutMode.bodyweight,
          weightKg: 0,
        ),
        _exercise('bench-press', orderIndex: 1, weightKg: 20),
        _exercise('overhead-press', orderIndex: 2, weightKg: 15),
      ]),
      _day(2, [
        _exercise('row', orderIndex: 0, weightKg: 25),
        _exercise('lat-pulldown', orderIndex: 1, weightKg: 30),
        _exercise('curl', orderIndex: 2, weightKg: 10),
      ]),
      _day(3, [
        _exercise('squat', orderIndex: 0, weightKg: 40),
        _exercise(
          'lunge',
          orderIndex: 1,
          mode: WorkoutMode.bodyweight,
          weightKg: 0,
        ),
        _exercise('plank', orderIndex: 2, mode: WorkoutMode.timed, weightKg: 0),
      ]),
    ],
  );
}

void main() {
  const adapter = FirstWeekPlanAdapter();

  group('FirstWeekPlanAdapter.convert', () {
    test('converts an existing plan into one routine and schedule per day', () {
      final converted = adapter.convert(_plan(), 'user-1');

      expect(converted, hasLength(3));
      expect(converted.map((item) => item.routine.name), [
        'First Week - Day 1',
        'First Week - Day 2',
        'First Week - Day 3',
      ]);
      expect(
        converted.map((item) => item.routine.userId),
        everyElement('user-1'),
      );
      expect(converted.map((item) => item.routine.emoji), everyElement('🌱'));
    });

    test('maps plan days to Monday, Wednesday, Friday', () {
      final converted = adapter.convert(_plan(), 'user-1');

      final weekdays = converted
          .map((item) => item.schedule)
          .map((schedule) => schedule.weekday)
          .toList();

      expect(weekdays, [1, 3, 5]);
      expect(
        converted.map((item) => item.schedule.isFixedWeek),
        everyElement(isTrue),
      );
    });

    test('links every schedule to its own routine', () {
      final converted = adapter.convert(_plan(), 'user-1');

      for (final item in converted) {
        expect(item.schedule.routineId, item.routine.id);
      }

      final routineIds = converted.map((item) => item.routine.id).toSet();
      expect(routineIds, hasLength(converted.length));
    });

    test('preserves exercise order, sets, reps and starter load', () {
      final converted = adapter.convert(_plan(), 'user-1');
      final dayOne = converted.first.routine;

      expect(dayOne.exercises.map((e) => e.exerciseId), [
        'push-up',
        'bench-press',
        'overhead-press',
      ]);
      expect(dayOne.exercises.map((e) => e.orderIndex), [0, 1, 2]);
      expect(dayOne.exercises.map((e) => e.sets), everyElement(3));
      expect(dayOne.exercises.map((e) => e.reps), everyElement(10));
      expect(dayOne.exercises.map((e) => e.weightKg), [0.0, 20.0, 15.0]);
    });

    test('preserves canonical WorkoutMode values', () {
      final converted = adapter.convert(_plan(), 'user-1');

      expect(converted[0].routine.exercises.map((e) => e.mode), [
        WorkoutMode.bodyweight,
        WorkoutMode.repsWeight,
        WorkoutMode.repsWeight,
      ]);
      expect(converted[2].routine.exercises.map((e) => e.mode), [
        WorkoutMode.repsWeight,
        WorkoutMode.bodyweight,
        WorkoutMode.timed,
      ]);
    });

    test('generates unique routine and exercise ids across days', () {
      final converted = adapter.convert(_plan(), 'user-1');

      final routineIds = converted.map((item) => item.routine.id).toList();
      final exerciseIds = converted
          .expand((item) => item.routine.exercises)
          .map((e) => e.id)
          .toList();

      expect(routineIds.toSet(), hasLength(routineIds.length));
      expect(exerciseIds.toSet(), hasLength(exerciseIds.length));
      expect(routineIds.toSet().intersection(exerciseIds.toSet()), isEmpty);
    });

    test('converts an empty plan into an empty result', () {
      final converted = adapter.convert(
        FirstWeekPlan.empty('user-1'),
        'user-1',
      );

      expect(converted, isEmpty);
    });
  });
}
