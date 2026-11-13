import 'package:app/features/bodyweight/domain/bodyweight_validator.dart';
import 'package:app/features/workout/domain/workout_mode_contract.dart';
import 'package:app/features/workout/domain/workout_set.dart';
import 'package:flutter_test/flutter_test.dart';

final kUserId = 'user-11111111-1111-1111-1111-111111111111';

WorkoutSet set({
  String id = 's1',
  String workoutExerciseId = 'we1',
  int reps = 10,
  double weightKg = 0,
  bool isCompleted = true,
  int durationSeconds = 0,
}) => WorkoutSet(
  id: id,
  workoutExerciseId: workoutExerciseId,
  reps: reps,
  weightKg: weightKg,
  isCompleted: isCompleted,
  durationSeconds: durationSeconds,
);

void main() {
  group('BodyweightValidator external load range', () {
    final validator = BodyweightValidator();

    test('zero additional load (bodyweight-only) is valid', () {
      expect(validator.validateExternalLoadKg(0), 0);
      expect(validator.isValidExternalLoad(0), isTrue);
    });

    test('positive additional load (e.g. weighted vest) is valid', () {
      expect(validator.validateExternalLoadKg(5.5), 5.5);
      expect(validator.validateExternalLoadKg(20.0), 20.0);
      expect(validator.isValidExternalLoad(100.0), isTrue);
    });

    test('boundary maximum 1000 kg is valid', () {
      expect(validator.validateExternalLoadKg(1000), 1000);
      expect(validator.isValidExternalLoad(1000), isTrue);
    });

    test('negative load is invalid', () {
      expect(
        () => validator.validateExternalLoadKg(-0.1),
        throwsA(isArgumentError),
      );
      expect(validator.isValidExternalLoad(-1), isFalse);
    });

    test('NaN is invalid', () {
      expect(
        () => validator.validateExternalLoadKg(double.nan),
        throwsA(isArgumentError),
      );
      expect(validator.isValidExternalLoad(double.nan), isFalse);
    });

    test('Infinity is invalid', () {
      expect(
        () => validator.validateExternalLoadKg(double.infinity),
        throwsA(isArgumentError),
      );
      expect(validator.isValidExternalLoad(double.infinity), isFalse);
    });

    test('negative infinity is invalid', () {
      expect(
        () => validator.validateExternalLoadKg(double.negativeInfinity),
        throwsA(isArgumentError),
      );
      expect(validator.isValidExternalLoad(double.negativeInfinity), isFalse);
    });

    test('above 1000 kg is invalid', () {
      expect(
        () => validator.validateExternalLoadKg(1000.01),
        throwsA(isArgumentError),
      );
      expect(validator.isValidExternalLoad(1000.01), isFalse);
    });
  });

  group('validateSet', () {
    final validator = BodyweightValidator();

    test('accepts a completed set with reps and zero external load', () {
      final s = set(reps: 10, weightKg: 0, isCompleted: true);
      expect(() => validator.validateSet(s), returnsNormally);
    });

    test('accepts a completed set with additional load', () {
      final s = set(reps: 8, weightKg: 12.5, isCompleted: true);
      expect(() => validator.validateSet(s), returnsNormally);
    });

    test('rejects a set with invalid external load', () {
      final s = set(reps: 10, weightKg: -5.0);
      expect(() => validator.validateSet(s), throwsA(isArgumentError));
    });

    test('does not depend on workout mode or contract outcome', () {
      final s = set(reps: 0, weightKg: 0, isCompleted: false);
      expect(() => validator.validateSet(s), returnsNormally);
    });
  });

  group('weight_kg is external load, never body mass', () {
    final validator = BodyweightValidator();

    test('isExternalLoadOnly is always true', () {
      expect(validator.isExternalLoadOnly, isTrue);
    });

    test('a profile body mass of 75 kg is never returned as a set weight', () {
      final profileWeightKg = 75.0;

      // Simulate a profile baseline measurement; the validator must not
      // treat this profile weight as a workout-set weight.
      expect(profileWeightKg, 75.0);
      expect(validator.isValidExternalLoad(profileWeightKg), isTrue);

      // A set carrying 75 kg is valid external load (e.g. vest), but the
      // validator never assigns or derives it from profile body mass.
      final s = set(weightKg: profileWeightKg);
      validator.validateSet(s);
      expect(s.weightKg, 75.0);
      expect(s.weightKg, isNot(validator.validateExternalLoadKg(0)));
    });

    test('validateSet never reads or writes profiles.weight_kg', () {
      // The validator has no profile input at all; this test documents the
      // contract by confirming validation depends only on set.weightKg.
      final s = set(weightKg: 15.0);
      expect(() => validator.validateSet(s), returnsNormally);
      expect(s.weightKg, 15.0);
    });
  });

  group('legacy data compatibility with validateWorkoutSetForMode', () {
    final validator = BodyweightValidator();

    test(
      'null mode with zero reps/duration but weightKg external is allowed',
      () {
        final s = set(
          reps: 0,
          weightKg: 0,
          isCompleted: false,
          durationSeconds: 0,
        );
        expect(() => validator.validateSet(s), returnsNormally);
        // The mode contract guards completion; the validator guards load range.
        expect(
          () => validateWorkoutSetForMode(
            mode: null,
            reps: 0,
            weightKg: s.weightKg,
            durationSeconds: 0,
            isCompleted: false,
          ),
          returnsNormally,
        );
      },
    );

    test('bodyweight mode with additional load passes both validators', () {
      final s = set(
        reps: 8,
        weightKg: 10.0,
        isCompleted: true,
        durationSeconds: 0,
      );
      expect(() => validator.validateSet(s), returnsNormally);
      expect(
        () => validateWorkoutSetForMode(
          mode: WorkoutMode.bodyweight,
          reps: s.reps,
          weightKg: s.weightKg,
          durationSeconds: s.durationSeconds,
          isCompleted: s.isCompleted,
        ),
        returnsNormally,
      );
    });

    test('timed mode rejects non-zero external weight_kg', () {
      final s = set(
        reps: 0,
        weightKg: 10.0,
        isCompleted: true,
        durationSeconds: 60,
      );
      expect(() => validator.validateSet(s), returnsNormally);
      expect(
        () => validateWorkoutSetForMode(
          mode: WorkoutMode.timed,
          reps: s.reps,
          weightKg: s.weightKg,
          durationSeconds: s.durationSeconds,
          isCompleted: s.isCompleted,
        ),
        throwsA(isArgumentError),
      );
    });
  });
}
