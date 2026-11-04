import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/training_plan/first_week_plan_engine.dart';
import 'package:app/features/training_plan/first_week_plan_models.dart';
import 'package:app/features/workout/domain/exercise.dart';
import 'package:app/features/workout/domain/workout_mode_contract.dart';

const _categories = <String>[
  'Chest',
  'Back',
  'Legs',
  'Shoulders',
  'Arms',
  'Core',
];

Exercise _exercise({
  required String id,
  required String name,
  required String category,
  required bool isBodyweight,
}) {
  return Exercise(
    id: id,
    name: name,
    category: category,
    equipment: isBodyweight ? 'Bodyweight' : 'Dumbbell',
  );
}

List<Exercise> _fullCatalog() {
  final exercises = <Exercise>[];
  var counter = 0;
  for (final category in _categories) {
    for (var j = 0; j < 3; j++) {
      counter += 1;
      exercises.add(
        _exercise(
          id: 'ex_${counter.toString().padLeft(2, '0')}',
          name: '$category Exercise $j',
          category: category,
          isBodyweight: counter.isEven,
        ),
      );
    }
  }
  return exercises;
}

void main() {
  group('FirstWeekPlanEngine', () {
    late BeginnerProfile profile;
    late List<Exercise> catalog;
    late FirstWeekPlanEngine engine;

    setUp(() {
      engine = FirstWeekPlanEngine();
      profile = const BeginnerProfile(
        userId: 'user_1',
        experienceLevel: 'beginner',
        completedWorkoutCount: 0,
      );
      catalog = _fullCatalog();
    });

    test(
      'deterministic: same input yields identical output incl. set order',
      () {
        final plan1 = engine.generate(profile, catalog);
        final plan2 = engine.generate(profile, catalog);
        expect(plan2, equals(plan1));
        expect(plan2.hashCode, equals(plan1.hashCode));
      },
    );

    test('first-time beginner gets exactly 3 days x 3 exercises', () {
      final plan = engine.generate(profile, catalog);
      expect(plan.isEmpty, isFalse);
      expect(plan.dayCount, 3);
      expect(plan.userId, 'user_1');
      expect(plan.version, 1);

      var totalExercises = 0;
      for (var dayIndex = 0; dayIndex < 3; dayIndex++) {
        final day = plan.days[dayIndex];
        expect(day.dayNumber, dayIndex + 1);
        expect(day.dayName, 'Day ${dayIndex + 1}');
        expect(day.exerciseCount, 3);
        totalExercises += day.exerciseCount;

        for (var exIndex = 0; exIndex < 3; exIndex++) {
          final ex = day.exercises[exIndex];
          expect(ex.orderIndex, exIndex);
          // Beginner-appropriate: 3 sets, reps in 8-12.
          expect(ex.sets, 3);
          expect(ex.reps, greaterThanOrEqualTo(8));
          expect(ex.reps, lessThanOrEqualTo(12));
          // Beginner modes only: bodyweight or reps-weight.
          expect(
            ex.mode,
            anyOf(WorkoutMode.bodyweight, WorkoutMode.repsWeight),
          );
        }
      }
      expect(totalExercises, 9);
    });

    test(
      'exercises selected deterministically by stable id, sorted, no duplicates',
      () {
        final plan = engine.generate(profile, catalog);
        final ids = <String>[];
        for (final day in plan.days) {
          for (final ex in day.exercises) {
            ids.add(ex.exerciseId);
          }
        }
        expect(ids.length, 9);
        expect(ids.toSet().length, 9); // no duplicates within a plan
        // ids are selected in stable sorted order
        for (var i = 1; i < ids.length; i++) {
          expect(ids[i - 1].compareTo(ids[i]), lessThanOrEqualTo(0));
        }
        // every selected id comes from the source catalog
        final catalogIds = catalog.map((e) => e.id).toSet();
        for (final id in ids) {
          expect(catalogIds.contains(id), isTrue);
        }
      },
    );

    test('bodyweight sets use weight_kg as external load, not body mass', () {
      final plan = engine.generate(profile, catalog);
      for (final day in plan.days) {
        for (final ex in day.exercises) {
          if (ex.mode == WorkoutMode.bodyweight) {
            // weight_kg is external/added load for bodyweight; 0 = no added load.
            expect(ex.starterWeightKg, 0.0);
          } else {
            expect(ex.mode, WorkoutMode.repsWeight);
            expect(ex.starterWeightKg, 5.0);
          }
        }
      }
    });

    test(
      'existing-history user gets an empty plan, history not overwritten',
      () {
        final returning = profile.copyWith(completedWorkoutCount: 2);
        final plan = engine.generate(returning, catalog);
        expect(plan.isEmpty, isTrue);
        expect(plan.dayCount, 0);
        expect(plan.userId, 'user_1');
      },
    );

    test('non-beginner gets an empty plan', () {
      final advanced = profile.copyWith(
        experienceLevel: 'advanced',
        completedWorkoutCount: 0,
      );
      final plan = engine.generate(advanced, catalog);
      expect(plan.isEmpty, isTrue);
    });

    test('null profile throws descriptive ArgumentError', () {
      expect(() => engine.generate(null, catalog), throwsA(isArgumentError));
    });

    test('empty catalog throws descriptive ArgumentError', () {
      expect(() => engine.generate(profile, []), throwsA(isArgumentError));
    });

    test('insufficient beginner-suitable exercises throws ArgumentError', () {
      final few = [
        _exercise(id: 'a', name: 'A', category: 'Chest', isBodyweight: true),
      ];
      expect(() => engine.generate(profile, few), throwsA(isArgumentError));
    });

    test('retry is idempotent: generate twice returns equal plans', () {
      final p1 = engine.generate(profile, catalog);
      final p2 = engine.generate(profile, catalog);
      expect(identical(p1, p2), isFalse); // distinct instances
      expect(p2, equals(p1)); // equal by value
    });

    test('timed/cardio exercises are excluded from beginner plan', () {
      final catalogWithCardio = <Exercise>[
        ..._fullCatalog().take(9),
        Exercise(
          id: 'cardio_1',
          name: 'Treadmill',
          category: 'Cardio',
          equipment: 'Treadmill',
        ),
      ];
      final plan = engine.generate(profile, catalogWithCardio);
      final ids = <String>{};
      for (final day in plan.days) {
        for (final ex in day.exercises) {
          ids.add(ex.exerciseId);
        }
      }
      expect(ids.contains('cardio_1'), isFalse);
    });
  });
}
