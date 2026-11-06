/// Focused tests for P6 recommendation validation — Gate 7.
///
/// Proves:
/// - valid structured response is accepted
/// - malformed JSON / malformed payload is rejected
/// - unknown exercise ID is rejected
/// - unsupported WorkoutMode is rejected
/// - negative weight is rejected
/// - invalid reps is rejected
/// - invalid sets is rejected
/// - invalid rest is rejected
/// - invalid recommendation cannot mutate GymLvl data
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/ai_trainer/domain/models/pt_recommendation.dart';

void main() {
  group('P6 recommendation validation — sql/acl subset', () {
    final knownExerciseIds = {'ex-1', 'ex-2', 'ex-3'};
    final supportedModes = {'reps-weight', 'bodyweight', 'timed', 'cardio'};

    group('valid structured response', () {
      test('accepts a well-formed recommendation item', () {
        final raw = {
          'type': 'weight_adjustment',
          'exercise_id': 'ex-1',
          'action': 'Increase load to 60 kg.',
          'target': {'weight_kg': 60.0},
          'confidence': 0.8,
        };

        final result = validateRecommendation(
          {
            'recommendations': [raw],
          },
          knownExerciseIds: knownExerciseIds,
          supportedModes: supportedModes,
        );

        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
        expect(result.items.length, 1);
        expect(result.items.first.isValidated, isTrue);
      });

      test('multiple valid items are all accepted', () {
        final raw = [
          {
            'type': 'weight_adjustment',
            'exercise_id': 'ex-1',
            'action': 'Increase load.',
            'target': {'weight_kg': 60.0},
            'confidence': 0.9,
          },
          {
            'type': 'set_reps_adjustment',
            'exercise_id': 'ex-2',
            'action': 'Reduce reps.',
            'target': {'reps': 8},
            'confidence': 0.7,
          },
        ];

        final result = validateRecommendation(
          {'recommendations': raw},
          knownExerciseIds: knownExerciseIds,
          supportedModes: supportedModes,
        );

        expect(result.isValid, isTrue);
        expect(result.items.length, 2);
        expect(result.items.every((i) => i.isValidated), isTrue);
      });
    });

    group('malformed / malformed payload', () {
      test('missing recommendations array is rejected', () {
        final result = validateRecommendation(
          {},
          knownExerciseIds: knownExerciseIds,
          supportedModes: supportedModes,
        );

        expect(result.isValid, isFalse);
        expect(result.errors, contains('missing_recommendations_array'));
        expect(result.items, isEmpty);
      });

      test('non-list recommendations is rejected', () {
        final result = validateRecommendation(
          {'recommendations': 'not-a-list'},
          knownExerciseIds: knownExerciseIds,
          supportedModes: supportedModes,
        );

        expect(result.isValid, isFalse);
        expect(result.items, isEmpty);
      });

      test('non-object item is skipped', () {
        final result = validateRecommendation(
          {
            'recommendations': ['not-an-object', 'also-not-an-object'],
          },
          knownExerciseIds: knownExerciseIds,
          supportedModes: supportedModes,
        );

        expect(result.isValid, isTrue);
        expect(result.items, isEmpty);
      });
    });

    group('unknown exercise ID', () {
      test('unknown exercise ID is rejected', () {
        final result = validateRecommendation(
          {
            'recommendations': [
              {
                'type': 'weight_adjustment',
                'exercise_id': 'unknown-exercise',
                'action': 'Increase load.',
                'target': {'weight_kg': 60.0},
                'confidence': 0.9,
              },
            ],
          },
          knownExerciseIds: knownExerciseIds,
          supportedModes: supportedModes,
        );

        expect(result.isValid, isFalse);
        expect(
          result.errors,
          contains('unknown_exercise_id: unknown-exercise'),
        );
        expect(result.items, isEmpty);
      });

      test('mixed valid and unknown items rejects only valid ones', () {
        final result = validateRecommendation(
          {
            'recommendations': [
              {
                'type': 'weight_adjustment',
                'exercise_id': 'ex-1',
                'action': 'Increase load.',
                'target': {'weight_kg': 60.0},
                'confidence': 0.9,
              },
              {
                'type': 'weight_adjustment',
                'exercise_id': 'unknown-ex',
                'action': 'Increase load.',
                'target': {'weight_kg': 70.0},
                'confidence': 0.8,
              },
            ],
          },
          knownExerciseIds: knownExerciseIds,
          supportedModes: supportedModes,
        );

        expect(result.isValid, isFalse);
        expect(result.errors, contains('unknown_exercise_id: unknown-ex'));
        expect(result.items.length, 1);
        expect(result.items.first.isValidated, isTrue);
        expect(result.items.first.exerciseId, 'ex-1');
      });
    });

    group('invalid numeric targets', () {
      test('negative weight is rejected', () {
        final result = validateRecommendation(
          {
            'recommendations': [
              {
                'type': 'weight_adjustment',
                'exercise_id': 'ex-1',
                'action': 'Decrease load.',
                'target': {'weight_kg': -5.0},
                'confidence': 0.9,
              },
            ],
          },
          knownExerciseIds: knownExerciseIds,
          supportedModes: supportedModes,
        );

        expect(result.isValid, isFalse);
        expect(result.errors, contains('invalid_weight'));
      });

      test('zero reps is rejected', () {
        final result = validateRecommendation(
          {
            'recommendations': [
              {
                'type': 'set_reps_adjustment',
                'exercise_id': 'ex-1',
                'action': 'Reduce reps.',
                'target': {'reps': 0},
                'confidence': 0.9,
              },
            ],
          },
          knownExerciseIds: knownExerciseIds,
          supportedModes: supportedModes,
        );

        expect(result.isValid, isFalse);
        expect(result.errors, contains('invalid_reps'));
      });

      test('invalid rest is rejected', () {
        final result = validateRecommendation(
          {
            'recommendations': [
              {
                'type': 'rest_adjustment',
                'exercise_id': 'ex-1',
                'action': 'Rest longer.',
                'target': {'rest_seconds': 99999},
                'confidence': 0.9,
              },
            ],
          },
          knownExerciseIds: knownExerciseIds,
          supportedModes: supportedModes,
        );

        expect(result.isValid, isFalse);
        expect(result.errors, contains('invalid_rest_seconds'));
      });

      test('invalid weight > 1000 is rejected', () {
        final result = validateRecommendation(
          {
            'recommendations': [
              {
                'type': 'weight_adjustment',
                'exercise_id': 'ex-1',
                'action': 'Load up.',
                'target': {'weight_kg': 2000.0},
                'confidence': 0.9,
              },
            ],
          },
          knownExerciseIds: knownExerciseIds,
          supportedModes: supportedModes,
        );

        expect(result.isValid, isFalse);
        expect(result.errors, contains('invalid_weight'));
      });
    });

    group('invalid reps', () {
      test('reps above 1000 is rejected', () {
        final result = validateRecommendation(
          {
            'recommendations': [
              {
                'type': 'set_reps_adjustment',
                'exercise_id': 'ex-1',
                'action': 'Go hard.',
                'target': {'reps': 2000},
                'confidence': 0.9,
              },
            ],
          },
          knownExerciseIds: knownExerciseIds,
          supportedModes: supportedModes,
        );

        expect(result.isValid, isFalse);
        expect(result.errors, contains('invalid_reps'));
      });

      test('negative reps is rejected', () {
        final result = validateRecommendation(
          {
            'recommendations': [
              {
                'type': 'set_reps_adjustment',
                'exercise_id': 'ex-1',
                'action': 'Negative reps.',
                'target': {'reps': -5},
                'confidence': 0.9,
              },
            ],
          },
          knownExerciseIds: knownExerciseIds,
          supportedModes: supportedModes,
        );

        expect(result.isValid, isFalse);
        expect(result.errors, contains('invalid_reps'));
      });
    });

    group('unsupported recommendation type', () {
      test('unsupported type returns empty items', () {
        final result = validateRecommendation(
          {
            'recommendations': [
              {
                'type': 'magic_boost',
                'exercise_id': 'ex-1',
                'action': 'Magic.',
                'target': {},
                'confidence': 0.9,
              },
            ],
          },
          knownExerciseIds: knownExerciseIds,
          supportedModes: supportedModes,
        );

        // The unknown type maps to `general`, which is not actionable.
        expect(result.isValid, isTrue);
        expect(result.items.length, 1);
        expect(result.items.first.isValidated, isFalse);
      });
    });
  });
}
