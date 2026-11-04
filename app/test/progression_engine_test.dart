import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/progression/domain/progression_engine.dart';
import 'package:app/features/workout/domain/workout_set.dart';

List<WorkoutSet> sets(int count, {double weight = 20, double baseline = 20}) =>
    List.generate(
      count,
      (i) => WorkoutSet(
        id: '$i',
        workoutExerciseId: 'exercise',
        reps: 10,
        weightKg: weight,
        baselineWeightKg: baseline,
        isCompleted: true,
      ),
    );

void main() {
  test('completed sets and variety earn XP without rewarding duration', () {
    for (final seconds in [60, 1800, 7200]) {
      expect(
        ProgressionEngine.calculateXP(
          durationSeconds: seconds,
          completedSets: sets(12),
          uniqueCategories: 3,
        ),
        76,
      );
    }
  });
  test('streak multiplier matches server 1.5 cap', () {
    expect(
      ProgressionEngine.calculateXP(
        durationSeconds: 1800,
        completedSets: sets(10),
        uniqueCategories: 2,
        userStreak: 20,
      ),
      87,
    );
  });
  test('baseline effort has bounded effect and total caps at 1000', () {
    expect(
      ProgressionEngine.calculateXP(
        durationSeconds: 1800,
        completedSets: sets(100, weight: 200),
        uniqueCategories: 6,
      ),
      1000,
    );
  });
  test(
    'no valid completed sets never earn XP, including suspicious estimate',
    () {
      expect(
        ProgressionEngine.calculateXP(
          durationSeconds: 1800,
          completedSets: [],
          uniqueCategories: 3,
          isSuspicious: true,
        ),
        0,
      );
      expect(
        ProgressionEngine.calculateXP(
          durationSeconds: 1800,
          completedSets: [
            const WorkoutSet(
              id: 'x',
              workoutExerciseId: 'e',
              isCompleted: true,
            ),
          ],
          uniqueCategories: 1,
        ),
        0,
      );
    },
  );
  test('suspicious completed work earns reduced estimate', () {
    expect(
      ProgressionEngine.calculateXP(
        durationSeconds: 60,
        completedSets: sets(10),
        uniqueCategories: 1,
        isSuspicious: true,
      ),
      10,
    );
  });
  test(
    'pace boundary is more than four sets per minute with more than three sets',
    () {
      expect(ProgressionEngine.checkSuspiciousPace(4, 60), false);
      expect(ProgressionEngine.checkSuspiciousPace(5, 60), true);
      expect(ProgressionEngine.checkSuspiciousPace(3, 1), false);
    },
  );
  test('global cumulative level thresholds remain stable', () {
    expect(ProgressionEngine.xpRequiredForLevel(1), 100);
    expect(ProgressionEngine.xpRequiredForLevel(10), 3162);
  });

  WorkoutSet oneSet({
    double weight = 20,
    int reps = 10,
    bool completed = true,
  }) => WorkoutSet(
    id: 's',
    workoutExerciseId: 'ex',
    reps: reps,
    weightKg: weight,
    baselineWeightKg: 0,
    isCompleted: completed,
  );

  test('calculateOneRepMax: Epley known values rounded to 2 decimals', () {
    expect(
      ProgressionEngine.calculateOneRepMax(weightKg: 100, reps: 10),
      133.33,
    );
    expect(
      ProgressionEngine.calculateOneRepMax(weightKg: 100, reps: 1),
      103.33,
    );
    expect(ProgressionEngine.calculateOneRepMax(weightKg: 50, reps: 5), 58.33);
    expect(
      ProgressionEngine.calculateOneRepMax(weightKg: 100, reps: 30),
      200.0,
    );
    expect(ProgressionEngine.calculateOneRepMax(weightKg: 1, reps: 1), 1.03);
  });

  test(
    'calculateOneRepMax: invalid inputs return null, never NaN/Infinity',
    () {
      expect(
        ProgressionEngine.calculateOneRepMax(weightKg: 0, reps: 10),
        isNull,
      );
      expect(
        ProgressionEngine.calculateOneRepMax(weightKg: -10, reps: 10),
        isNull,
      );
      expect(
        ProgressionEngine.calculateOneRepMax(weightKg: 1001, reps: 10),
        isNull,
      );
      expect(
        ProgressionEngine.calculateOneRepMax(weightKg: double.nan, reps: 10),
        isNull,
      );
      expect(
        ProgressionEngine.calculateOneRepMax(
          weightKg: double.infinity,
          reps: 10,
        ),
        isNull,
      );
      expect(
        ProgressionEngine.calculateOneRepMax(weightKg: 100, reps: 0),
        isNull,
      );
      expect(
        ProgressionEngine.calculateOneRepMax(weightKg: 100, reps: -1),
        isNull,
      );
      expect(
        ProgressionEngine.calculateOneRepMax(weightKg: 100, reps: 1001),
        isNull,
      );
    },
  );

  test('calculateOneRepMax: repeatability (same input -> same output)', () {
    final a = ProgressionEngine.calculateOneRepMax(weightKg: 100, reps: 10);
    final b = ProgressionEngine.calculateOneRepMax(weightKg: 100, reps: 10);
    expect(a, b);
    expect(a, 133.33);
  });

  test('detectPersonalRecord: first record (no existing max) is weight PR', () {
    final r = ProgressionEngine.detectPersonalRecord(
      existingMaxWeight: null,
      existingMaxReps: null,
      newWeight: 100,
      newReps: 10,
    );
    expect(r.kind, 'weight');
    expect(r.isWeightPR, isTrue);
    expect(r.isRepsPR, isFalse);
    expect(r.previousMaxWeight, isNull);
    expect(r.previousMaxReps, isNull);
  });

  test('detectPersonalRecord: new record -> weight / reps / both', () {
    expect(
      ProgressionEngine.detectPersonalRecord(
        existingMaxWeight: 100,
        existingMaxReps: 5,
        newWeight: 105,
        newReps: 4,
      ).kind,
      'weight',
    );
    expect(
      ProgressionEngine.detectPersonalRecord(
        existingMaxWeight: 100,
        existingMaxReps: 5,
        newWeight: 100,
        newReps: 6,
      ).kind,
      'reps',
    );
    expect(
      ProgressionEngine.detectPersonalRecord(
        existingMaxWeight: 100,
        existingMaxReps: 5,
        newWeight: 105,
        newReps: 6,
      ).kind,
      'both',
    );
  });

  test('detectPersonalRecord: equal and regression -> none', () {
    expect(
      ProgressionEngine.detectPersonalRecord(
        existingMaxWeight: 100,
        existingMaxReps: 5,
        newWeight: 100,
        newReps: 5,
      ).kind,
      'none',
    );
    expect(
      ProgressionEngine.detectPersonalRecord(
        existingMaxWeight: 100,
        existingMaxReps: 5,
        newWeight: 90,
        newReps: 5,
      ).kind,
      'none',
    );
    expect(
      ProgressionEngine.detectPersonalRecord(
        existingMaxWeight: 100,
        existingMaxReps: 5,
        newWeight: 100,
        newReps: 4,
      ).kind,
      'none',
    );
  });

  test(
    'detectPersonalRecord: replay safety (same input twice -> same result)',
    () {
      final a = ProgressionEngine.detectPersonalRecord(
        existingMaxWeight: 100,
        existingMaxReps: 5,
        newWeight: 105,
        newReps: 6,
      );
      final b = ProgressionEngine.detectPersonalRecord(
        existingMaxWeight: 100,
        existingMaxReps: 5,
        newWeight: 105,
        newReps: 6,
      );
      expect(a, b);
    },
  );

  test('progressionSnapshot: golden table — deterministic output per case', () {
    final base = <String, dynamic>{
      'durationSeconds': 1800,
      'uniqueCategories': 1,
      'currentXP': 0,
      'currentLevel': 1,
    };

    final cases = [
      {
        'name': 'first record',
        'sets': [oneSet(weight: 100, reps: 10)],
        'existingMaxWeight': null,
        'existingMaxReps': null,
        'newWeight': 100.0,
        'newReps': 10,
        'expectedXP': 5,
        'expectedLevel': 1,
        'expectedLeveledUp': false,
        'expected1rm': 133.33,
        'expectedKind': 'weight',
      },
      {
        'name': 'improvement / level up',
        'sets': List.generate(25, (i) => oneSet(weight: 20, reps: 10)),
        'uniqueCategories': 3,
        'existingMaxWeight': 90.0,
        'existingMaxReps': 8,
        'newWeight': 100.0,
        'newReps': 10,
        'expectedXP': 141,
        'expectedLevel': 2,
        'expectedLeveledUp': true,
        'expected1rm': 133.33,
        'expectedKind': 'both',
      },
      {
        'name': 'equal performance',
        'sets': [oneSet(weight: 100, reps: 10)],
        'existingMaxWeight': 100.0,
        'existingMaxReps': 10,
        'newWeight': 100.0,
        'newReps': 10,
        'expectedXP': 5,
        'expectedLevel': 1,
        'expectedLeveledUp': false,
        'expected1rm': 133.33,
        'expectedKind': 'none',
      },
      {
        'name': 'regression',
        'sets': [oneSet(weight: 50, reps: 5)],
        'existingMaxWeight': 100.0,
        'existingMaxReps': 10,
        'newWeight': 50.0,
        'newReps': 5,
        'expectedXP': 5,
        'expectedLevel': 1,
        'expectedLeveledUp': false,
        'expected1rm': 58.33,
        'expectedKind': 'none',
      },
      {
        'name': 'different rep ranges',
        'sets': [oneSet(weight: 100, reps: 5)],
        'existingMaxWeight': 100.0,
        'existingMaxReps': 10,
        'newWeight': 100.0,
        'newReps': 5,
        'expectedXP': 5,
        'expectedLevel': 1,
        'expectedLeveledUp': false,
        'expected1rm': 116.67,
        'expectedKind': 'none',
      },
      {
        'name': 'different load',
        'sets': [oneSet(weight: 150, reps: 3)],
        'existingMaxWeight': 100.0,
        'existingMaxReps': 10,
        'newWeight': 150.0,
        'newReps': 3,
        'expectedXP': 5,
        'expectedLevel': 1,
        'expectedLeveledUp': false,
        'expected1rm': 165.0,
        'expectedKind': 'weight',
      },
      {
        'name': 'bodyweight mode',
        'sets': [oneSet(weight: 0, reps: 15)],
        'existingMaxWeight': null,
        'existingMaxReps': null,
        'newWeight': 0.0,
        'newReps': 15,
        'expectedXP': 5,
        'expectedLevel': 1,
        'expectedLeveledUp': false,
        'expected1rm': null,
        'expectedKind': 'weight',
      },
      {
        'name': 'timed mode',
        'sets': [
          WorkoutSet(
            id: 's',
            workoutExerciseId: 'ex',
            reps: 0,
            weightKg: 0,
            baselineWeightKg: 0,
            durationSeconds: 60,
            isCompleted: true,
          ),
        ],
        'existingMaxWeight': null,
        'existingMaxReps': null,
        'newWeight': 0.0,
        'newReps': 0,
        'expectedXP': 0,
        'expectedLevel': 1,
        'expectedLeveledUp': false,
        'expected1rm': null,
        'expectedKind': 'weight',
      },
      {
        'name': 'cardio mode',
        'sets': [
          WorkoutSet(
            id: 's',
            workoutExerciseId: 'ex',
            reps: 0,
            weightKg: 0,
            baselineWeightKg: 0,
            durationSeconds: 120,
            isCompleted: true,
          ),
        ],
        'existingMaxWeight': null,
        'existingMaxReps': null,
        'newWeight': 0.0,
        'newReps': 0,
        'expectedXP': 0,
        'expectedLevel': 1,
        'expectedLeveledUp': false,
        'expected1rm': null,
        'expectedKind': 'weight',
      },
      {
        'name': 'historical / legacy data',
        'sets': [
          WorkoutSet(
            id: 's',
            workoutExerciseId: 'ex',
            reps: 8,
            weightKg: 60,
            baselineWeightKg: 0,
            createdAt: null,
            isCompleted: true,
          ),
        ],
        'existingMaxWeight': 50.0,
        'existingMaxReps': 10,
        'newWeight': 60.0,
        'newReps': 8,
        'expectedXP': 5,
        'expectedLevel': 1,
        'expectedLeveledUp': false,
        'expected1rm': 76.0,
        'expectedKind': 'weight',
      },
      {
        'name': 'invalid / incomplete sets',
        'sets': [
          WorkoutSet(
            id: 's',
            workoutExerciseId: 'ex',
            reps: 10,
            weightKg: 100,
            baselineWeightKg: 0,
            isCompleted: false,
          ),
        ],
        'existingMaxWeight': null,
        'existingMaxReps': null,
        'newWeight': 100.0,
        'newReps': 10,
        'expectedXP': 0,
        'expectedLevel': 1,
        'expectedLeveledUp': false,
        'expected1rm': 133.33,
        'expectedKind': 'weight',
      },
    ];

    for (final c in cases) {
      final first = ProgressionEngine.progressionSnapshot(
        currentXP: c['currentXP'] ?? base['currentXP'],
        currentLevel: c['currentLevel'] ?? base['currentLevel'],
        durationSeconds: c['durationSeconds'] ?? base['durationSeconds'],
        completedSets: c['sets'] as List<WorkoutSet>,
        uniqueCategories: c['uniqueCategories'] ?? base['uniqueCategories'],
        existingMaxWeight: c['existingMaxWeight'] as double?,
        existingMaxReps: c['existingMaxReps'] as int?,
        newWeight: c['newWeight'] as double?,
        newReps: c['newReps'] as int?,
      );
      final second = ProgressionEngine.progressionSnapshot(
        currentXP: c['currentXP'] ?? base['currentXP'],
        currentLevel: c['currentLevel'] ?? base['currentLevel'],
        durationSeconds: c['durationSeconds'] ?? base['durationSeconds'],
        completedSets: c['sets'] as List<WorkoutSet>,
        uniqueCategories: c['uniqueCategories'] ?? base['uniqueCategories'],
        existingMaxWeight: c['existingMaxWeight'] as double?,
        existingMaxReps: c['existingMaxReps'] as int?,
        newWeight: c['newWeight'] as double?,
        newReps: c['newReps'] as int?,
      );

      expect(
        second,
        first,
        reason:
            '${c['name']} must be deterministic (same input -> same output)',
      );
      expect(first.earnedXP, c['expectedXP'], reason: '${c['name']} earnedXP');
      expect(
        first.newLevel,
        c['expectedLevel'],
        reason: '${c['name']} newLevel',
      );
      expect(
        first.leveledUp,
        c['expectedLeveledUp'],
        reason: '${c['name']} leveledUp',
      );
      expect(
        first.oneRepMax?.estimated1rm,
        c['expected1rm'],
        reason: '${c['name']} oneRepMax',
      );
      expect(
        first.personalRecord?.kind,
        c['expectedKind'],
        reason: '${c['name']} PR kind',
      );
    }
  });
}
