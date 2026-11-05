import 'package:app/features/training_plan/routine_engine.dart';
import 'package:app/features/training_plan/routine_models.dart';
import 'package:app/features/training_plan/schedule_engine.dart';
import 'package:app/features/workout/domain/workout_mode_contract.dart';
import 'package:flutter_test/flutter_test.dart';

Routine _routine(
  RoutineEngine engine, {
  String id = 'routine-1',
  String name = 'Push Day',
  double weightKg = 20,
}) {
  return engine.create(
    userId: 'user-1',
    name: name,
    exercises: [
      RoutineExerciseConfig(
        exerciseId: 'exercise-1',
        orderIndex: 0,
        sets: 3,
        reps: 10,
        weightKg: weightKg,
        restSeconds: 90,
        mode: WorkoutMode.repsWeight,
      ),
    ],
  );
}

List<Map<String, dynamic>> _snapshotExercises(PlannedWorkout planned) {
  final routine = planned.routineSnapshot['routine'] as Map<String, dynamic>;
  return (routine['exercises'] as List).cast<Map<String, dynamic>>();
}

void main() {
  const engine = RoutineEngine();
  const schedules = ScheduleEngine();
  const timezone = 'Asia/Ho_Chi_Minh';

  group('weekday convention', () {
    test('uses 1=Monday through 7=Sunday', () {
      expect(DateTime(2026, 1, 5).weekday, DateTime.monday);
      expect(DateTime(2026, 1, 5).weekday, 1);
      expect(DateTime(2026, 1, 11).weekday, DateTime.sunday);
      expect(DateTime(2026, 1, 11).weekday, 7);
    });
  });

  group('fixed-week assignment', () {
    test('assigns a routine to a weekday and generates that occurrence', () {
      final routine = _routine(engine);
      final assigned = schedules.assignToWeekday(
        current: const [],
        routineId: routine.id,
        weekday: 1,
      );

      expect(assigned, hasLength(1));
      expect(assigned.single, isA<FixedWeekSchedule>());
      expect((assigned.single as FixedWeekSchedule).weekday, 1);

      final occurrences = schedules.getPlannedWorkouts(
        routines: [routine],
        schedules: assigned,
        startDate: DateTime(2026, 1, 5),
        endDate: DateTime(2026, 1, 11),
        userTimezone: timezone,
      );

      expect(occurrences, hasLength(1));
      expect(occurrences.single.scheduledDate, DateTime(2026, 1, 5));
      expect(occurrences.single.routineId, routine.id);
      expect(occurrences.single.routineName, routine.name);
    });

    test('leaves unassigned days as rest days', () {
      final routine = _routine(engine);
      final assigned = schedules.assignToWeekday(
        current: const [],
        routineId: routine.id,
        weekday: 1,
      );

      final occurrences = schedules.getPlannedWorkouts(
        routines: [routine],
        schedules: assigned,
        startDate: DateTime(2026, 1, 6),
        endDate: DateTime(2026, 1, 6),
        userTimezone: timezone,
      );

      expect(occurrences, isEmpty);
    });

    test('reassigning the same routine replaces its fixed-week schedule', () {
      final routine = _routine(engine);
      final first = schedules.assignToWeekday(
        current: const [],
        routineId: routine.id,
        weekday: 1,
      );
      final second = schedules.assignToWeekday(
        current: first,
        routineId: routine.id,
        weekday: 3,
      );

      expect(second, hasLength(1));
      expect((second.single as FixedWeekSchedule).weekday, 3);
    });

    test('rejects weekdays outside 1..7', () {
      expect(
        () => schedules.assignToWeekday(
          current: const [],
          routineId: 'routine-1',
          weekday: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () => schedules.assignToWeekday(
          current: const [],
          routineId: 'routine-1',
          weekday: 8,
        ),
        throwsArgumentError,
      );
    });

    test('skips archived routines', () {
      final routine = _routine(engine).copyWith(isArchived: true);
      final assigned = schedules.assignToWeekday(
        current: const [],
        routineId: routine.id,
        weekday: 1,
      );

      final occurrences = schedules.getPlannedWorkouts(
        routines: [routine],
        schedules: assigned,
        startDate: DateTime(2026, 1, 5),
        endDate: DateTime(2026, 1, 11),
        userTimezone: timezone,
      );

      expect(occurrences, isEmpty);
    });
  });

  group('upcoming workout', () {
    test('resolves the next planned occurrence from today', () {
      final monday = _routine(engine, id: 'routine-mon', name: 'Monday Push');
      final wednesday = _routine(
        engine,
        id: 'routine-wed',
        name: 'Wednesday Pull',
      );
      final assigned = [
        ...schedules.assignToWeekday(
          current: const [],
          routineId: monday.id,
          weekday: 1,
        ),
        ...schedules.assignToWeekday(
          current: const [],
          routineId: wednesday.id,
          weekday: 3,
        ),
      ];

      final next = schedules.getNextWorkout(
        routines: [monday, wednesday],
        schedules: assigned,
        now: DateTime(2026, 1, 5, 8),
        userTimezone: timezone,
      );

      expect(next, isNotNull);
      expect(next!.scheduledDate, DateTime(2026, 1, 5));
      expect(next.routineId, monday.id);
    });
  });

  group('reschedule', () {
    test('moves only the targeted occurrence', () {
      final routine = _routine(engine);
      final assigned = schedules.assignToWeekday(
        current: const [],
        routineId: routine.id,
        weekday: 1,
      );
      final planned = schedules.getPlannedWorkouts(
        routines: [routine],
        schedules: assigned,
        startDate: DateTime(2026, 1, 5),
        endDate: DateTime(2026, 1, 19),
        userTimezone: timezone,
      );
      expect(planned, hasLength(3));

      final moved = schedules.reschedule(
        planned: planned,
        plannedWorkoutId: planned.first.id,
        newDate: DateTime(2026, 1, 7),
      );

      expect(moved.first.scheduledDate, DateTime(2026, 1, 7));
      expect(moved[1].scheduledDate, planned[1].scheduledDate);
      expect(moved[2].scheduledDate, planned[2].scheduledDate);
    });
  });

  group('snapshot semantics', () {
    test('editing a routine never rewrites an existing scheduled snapshot', () {
      final original = _routine(engine, weightKg: 20);
      final assigned = schedules.assignToWeekday(
        current: const [],
        routineId: original.id,
        weekday: 1,
      );

      final first = schedules
          .getPlannedWorkouts(
            routines: [original],
            schedules: assigned,
            startDate: DateTime(2026, 1, 5),
            endDate: DateTime(2026, 1, 5),
            userTimezone: timezone,
          )
          .single;

      final snapshot = first.routineSnapshot;
      expect(_snapshotExercises(first).single['weight_kg'], 20.0);

      final edited = original.copyWith(
        name: 'Push Day v2',
        exercises: [original.exercises.single.copyWith(weightKg: 50)],
      );

      // The captured snapshot is a value, not a live view of the routine.
      expect(snapshot['routine']['name'], 'Push Day');
      expect(_snapshotExercises(first).single['weight_kg'], 20.0);

      final second = schedules
          .getPlannedWorkouts(
            routines: [edited],
            schedules: assigned,
            startDate: DateTime(2026, 1, 5),
            endDate: DateTime(2026, 1, 5),
            userTimezone: timezone,
          )
          .single;

      expect(second.routineSnapshot['routine']['name'], 'Push Day v2');
      expect(_snapshotExercises(second).single['weight_kg'], 50.0);
    });

    test(
      'occurrences scheduled before and after an edit keep independent snapshots',
      () {
        final v1 = _routine(engine, weightKg: 20);
        final assigned = schedules.assignToWeekday(
          current: const [],
          routineId: v1.id,
          weekday: 1,
        );

        final first = schedules
            .getPlannedWorkouts(
              routines: [v1],
              schedules: assigned,
              startDate: DateTime(2026, 1, 5),
              endDate: DateTime(2026, 1, 5),
              userTimezone: timezone,
            )
            .single;

        final v2 = v1.copyWith(
          exercises: [v1.exercises.single.copyWith(weightKg: 50)],
        );
        final second = schedules
            .getPlannedWorkouts(
              routines: [v2],
              schedules: assigned,
              startDate: DateTime(2026, 1, 12),
              endDate: DateTime(2026, 1, 12),
              userTimezone: timezone,
            )
            .single;

        final v3 = v1.copyWith(
          exercises: [v1.exercises.single.copyWith(weightKg: 80)],
        );
        final third = schedules
            .getPlannedWorkouts(
              routines: [v3],
              schedules: assigned,
              startDate: DateTime(2026, 1, 19),
              endDate: DateTime(2026, 1, 19),
              userTimezone: timezone,
            )
            .single;

        expect(_snapshotExercises(first).single['weight_kg'], 20.0);
        expect(_snapshotExercises(second).single['weight_kg'], 50.0);
        expect(_snapshotExercises(third).single['weight_kg'], 80.0);
        expect(first.routineSnapshot, isNot(equals(second.routineSnapshot)));
        expect(second.routineSnapshot, isNot(equals(third.routineSnapshot)));
      },
    );
  });
}
