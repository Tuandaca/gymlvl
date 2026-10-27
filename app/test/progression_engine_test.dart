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
}
