import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout_mode_contract.dart';
import 'package:flutter_test/flutter_test.dart';

/// Asserts [fn] throws an `ArgumentError` whose [message] matches the contract.
void expectArgumentError(void Function() fn, String message) {
  try {
    fn();
    fail('Expected ArgumentError("$message"), but nothing was thrown.');
  } on ArgumentError catch (error) {
    expect(error.message, message);
  }
}

void main() {
  group('bodyweight mode contract (M3/M4, D-044)', () {
    test(
      'completed bodyweight set requires reps > 0; boundaries 1 and 1000 valid',
      () {
        // Minimum reps.
        validateWorkoutSetForMode(
          mode: WorkoutMode.bodyweight,
          reps: 1,
          weightKg: 0,
          durationSeconds: 0,
          isCompleted: true,
        );
        // Maximum reps.
        validateWorkoutSetForMode(
          mode: WorkoutMode.bodyweight,
          reps: 1000,
          weightKg: 0,
          durationSeconds: 0,
          isCompleted: true,
        );
        // Completed set with zero reps is invalid.
        expectArgumentError(
          () => validateWorkoutSetForMode(
            mode: WorkoutMode.bodyweight,
            reps: 0,
            weightKg: 0,
            durationSeconds: 0,
            isCompleted: true,
          ),
          'invalid_reps',
        );
      },
    );

    test(
      'accepts external added load 0, 5, 20, 1000 kg with reps > 0 and duration 0',
      () {
        for (final weightKg in <double>[0.0, 5.0, 20.0, 1000.0]) {
          validateWorkoutSetForMode(
            mode: WorkoutMode.bodyweight,
            reps: 10,
            weightKg: weightKg,
            durationSeconds: 0,
            isCompleted: true,
          );
        }
      },
    );

    test(
      'weight_kg == 0 with reps > 0 is valid bodyweight-only, never "no body mass"',
      () {
        // weight_kg on a set is external / added load, not the user's body mass.
        validateWorkoutSetForMode(
          mode: WorkoutMode.bodyweight,
          reps: 12,
          weightKg: 0,
          durationSeconds: 0,
          isCompleted: true,
        );
      },
    );

    group('invalid values throw', () {
      test('reps < 0 throws invalid_reps', () {
        expectArgumentError(
          () => validateWorkoutSetForMode(
            mode: WorkoutMode.bodyweight,
            reps: -1,
            weightKg: 0,
            durationSeconds: 0,
            isCompleted: true,
          ),
          'invalid_reps',
        );
      });

      test('reps > 1000 throws invalid_reps', () {
        expectArgumentError(
          () => validateWorkoutSetForMode(
            mode: WorkoutMode.bodyweight,
            reps: 1001,
            weightKg: 0,
            durationSeconds: 0,
            isCompleted: true,
          ),
          'invalid_reps',
        );
      });

      test('weightKg < 0 throws invalid_weight', () {
        expectArgumentError(
          () => validateWorkoutSetForMode(
            mode: WorkoutMode.bodyweight,
            reps: 10,
            weightKg: -0.1,
            durationSeconds: 0,
            isCompleted: true,
          ),
          'invalid_weight',
        );
      });

      test('weightKg > 1000 throws invalid_weight', () {
        expectArgumentError(
          () => validateWorkoutSetForMode(
            mode: WorkoutMode.bodyweight,
            reps: 10,
            weightKg: 1000.01,
            durationSeconds: 0,
            isCompleted: true,
          ),
          'invalid_weight',
        );
      });

      test(
        'non-finite weightKg (NaN, Infinity, -Infinity) throws invalid_weight',
        () {
          for (final weightKg in <double>[
            double.nan,
            double.infinity,
            double.negativeInfinity,
          ]) {
            expectArgumentError(
              () => validateWorkoutSetForMode(
                mode: WorkoutMode.bodyweight,
                reps: 10,
                weightKg: weightKg,
                durationSeconds: 0,
                isCompleted: true,
              ),
              'invalid_weight',
            );
          }
        },
      );

      test(
        'durationSeconds != 0 for completed bodyweight throws invalid_duration',
        () {
          expectArgumentError(
            () => validateWorkoutSetForMode(
              mode: WorkoutMode.bodyweight,
              reps: 10,
              weightKg: 0,
              durationSeconds: 60,
              isCompleted: true,
            ),
            'invalid_duration',
          );
        },
      );

      test(
        'reps == 0 with durationSeconds == 0 and isCompleted throws invalid_reps',
        () {
          expectArgumentError(
            () => validateWorkoutSetForMode(
              mode: WorkoutMode.bodyweight,
              reps: 0,
              weightKg: 0,
              durationSeconds: 0,
              isCompleted: true,
            ),
            'invalid_reps',
          );
        },
      );

      test(
        'bodyweight mode with durationSeconds > 0 as draft throws invalid_duration',
        () {
          // The bodyweight branch requires durationSeconds == 0 regardless of completion.
          expectArgumentError(
            () => validateWorkoutSetForMode(
              mode: WorkoutMode.bodyweight,
              reps: 0,
              weightKg: 0,
              durationSeconds: 1,
              isCompleted: false,
            ),
            'invalid_duration',
          );
        },
      );
    });

    test(
      'legacy mode == null is not inferred as bodyweight; null branch governs',
      () {
        final legacy = WorkoutExercise.fromJson(<String, dynamic>{
          'id': 'we-legacy',
          'workout_id': 'w',
          'exercise_id': 'e',
          // No "mode" key -> legacy NULL mode; it must not be inferred as bodyweight.
          'workout_sets': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 's1',
              'workout_exercise_id': 'we-legacy',
              'reps': 10,
              'duration_seconds': 0,
            },
          ],
        });
        expect(legacy.mode, isNull);

        // Legacy completed set with reps > 0 validates under the null branch.
        expect(
          () => validateWorkoutSetForMode(
            mode: legacy.mode,
            reps: legacy.sets.single.reps,
            weightKg: legacy.sets.single.weightKg,
            durationSeconds: legacy.sets.single.durationSeconds,
            isCompleted: true,
          ),
          returnsNormally,
        );

        // Null-mode completed set with reps == 0 && durationSeconds == 0 throws
        // invalid_measurements under the null branch — never the bodyweight branch.
        expectArgumentError(
          () => validateWorkoutSetForMode(
            mode: null,
            reps: 0,
            weightKg: 0,
            durationSeconds: 0,
            isCompleted: true,
          ),
          'invalid_measurements',
        );
      },
    );

    test(
      'set weight_kg is external load; bodyweight validation never reads or derives body mass',
      () {
        // weight_kg on a workout set != body mass. profiles.weight_kg is the separate
        // authoritative onboarding body-mass source; validation has no profile input.
        validateWorkoutSetForMode(
          mode: WorkoutMode.bodyweight,
          reps: 8,
          weightKg:
              20, // e.g. weighted vest, independent of any body-mass source
          durationSeconds: 0,
          isCompleted: true,
        );
        // A set carrying a load equal to a plausible body mass is still treated as
        // external load only; validation never derives or assigns body mass.
        expectArgumentError(
          () => validateWorkoutSetForMode(
            mode: WorkoutMode.bodyweight,
            reps: 10,
            weightKg: 1000.01, // out of load range, not a body-mass rejection
            durationSeconds: 0,
            isCompleted: true,
          ),
          'invalid_weight',
        );
      },
    );

    test('timed and cardio reject weightKg > 0 and reps > 0', () {
      for (final mode in <WorkoutMode>[WorkoutMode.timed, WorkoutMode.cardio]) {
        expectArgumentError(
          () => validateWorkoutSetForMode(
            mode: mode,
            reps: 0,
            weightKg: 5.0,
            durationSeconds: 60,
            isCompleted: true,
          ),
          'invalid_weight',
        );
        expectArgumentError(
          () => validateWorkoutSetForMode(
            mode: mode,
            reps: 5,
            weightKg: 0,
            durationSeconds: 60,
            isCompleted: true,
          ),
          'invalid_reps',
        );
      }
    });

    test('reps-weight rejects durationSeconds > 0', () {
      expectArgumentError(
        () => validateWorkoutSetForMode(
          mode: WorkoutMode.repsWeight,
          reps: 10,
          weightKg: 0,
          durationSeconds: 30,
          isCompleted: true,
        ),
        'invalid_duration',
      );
    });
  });
}
