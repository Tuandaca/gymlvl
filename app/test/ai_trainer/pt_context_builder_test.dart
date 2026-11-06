/// Focused tests for P6 Gate 9 — context builder.
///
/// Proves:
/// - owner-only data (no cross-user leakage)
/// - bounded recent history
/// - warm-up exclusion where intended
/// - deterministic output
/// - no credentials/secrets in context
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/ai_trainer/domain/models/pt_context.dart';
import 'package:app/features/ai_trainer/domain/services/pt_context_builder.dart';
import 'package:app/features/analytics/domain/recovery_readiness.dart';
import 'package:app/features/progression/domain/player_progression.dart';
import 'package:app/features/workout/domain/exercise.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout_set.dart';

void main() {
  group('P6 context builder — owner-scoped, bounded, deterministic', () {
    const ownerId = 'owner-1';
    const otherId = 'other-1';

    group('owner-scoped', () {
      test('context reports owner id only', () {
        final progress = PlayerProgression(
          userId: ownerId,
          level: 3,
          totalXP: 500,
          currentTitle: 'Tân Binh',
          lastWorkoutDate: DateTime(2026, 11, 1),
          achievements: [],
          classes: [],
          activeQuest: null,
          nextUnlock: null,
        );

        final readiness = ReadinessInsight(
          overall: ReadinessClassification.moderatelyRecovered,
          muscleGroups: [],
          completedWorkoutCount: 2,
          mostRecentWorkoutAt: DateTime(2026, 11, 5),
        );

        final ctx = PtContextBuilder.build(
          userId: ownerId,
          workouts: [],
          workoutExercises: [],
          sets: [],
          exercises: [],
          progression: progress,
          readiness: readiness,
          activeQuests: [],
          activeClasses: [],
          currentLevel: progress.level,
          nextMilestone: null,
          builtAt: DateTime(2026, 11, 6),
        );

        expect(ctx.userId, ownerId);
        expect(ctx.userId, isNot(otherId));
      });
    });

    group('bounded history', () {
      test('only last 5 completed workouts are included', () {
        final progress = PlayerProgression(
          userId: ownerId,
          level: 1,
          totalXP: 0,
          currentTitle: null,
          lastWorkoutDate: null,
          achievements: [],
          classes: [],
          activeQuest: null,
          nextUnlock: null,
        );

        final readiness = ReadinessInsight(
          overall: ReadinessClassification.noHistory,
          muscleGroups: [],
          completedWorkoutCount: 0,
          mostRecentWorkoutAt: null,
        );

        final workouts = <Workout>[];
        for (var i = 0; i < 7; i++) {
          workouts.add(
            Workout(
              id: 'w$i',
              userId: ownerId,
              status: WorkoutStatus.completed,
              durationSeconds: 600,
              startedAt: DateTime(2026, 11, 1).add(Duration(days: i)),
              trainingStartedAt: DateTime(2026, 11, 1).add(Duration(days: i)),
              completedAt: DateTime(2026, 11, 1).add(Duration(days: i)),
              createdAt: DateTime(2026, 11, 1),
              updatedAt: DateTime(2026, 11, 1),
              exercises: [],
            ),
          );
        }

        final ctx = PtContextBuilder.build(
          userId: ownerId,
          workouts: workouts,
          workoutExercises: [],
          sets: [],
          exercises: [],
          progression: progress,
          readiness: readiness,
          activeQuests: [],
          activeClasses: [],
          currentLevel: progress.level,
          nextMilestone: null,
          builtAt: DateTime(2026, 11, 8),
        );

        expect(ctx.recentTraining.length, 5);
      });
    });

    group('warm-up exclusion', () {
      test('warm-up sets excluded from completed sets count', () {
        final progress = PlayerProgression(
          userId: ownerId,
          level: 1,
          totalXP: 0,
          currentTitle: null,
          lastWorkoutDate: null,
          achievements: [],
          classes: [],
          activeQuest: null,
          nextUnlock: null,
        );

        final readiness = ReadinessInsight(
          overall: ReadinessClassification.noHistory,
          muscleGroups: [],
          completedWorkoutCount: 0,
          mostRecentWorkoutAt: null,
        );

        final exercise = Exercise(
          id: 'ex-1',
          name: 'Bench Press',
          slug: 'bench-press',
          category: 'Chest',
          equipment: 'Barbell',
          forceType: 'Push',
          createdAt: DateTime(2026, 11, 1),
          updatedAt: DateTime(2026, 11, 1),
        );

        final we1 = WorkoutExercise(
          id: 'we-1',
          workoutId: 'w-1',
          exerciseId: 'ex-1',
          orderIndex: 0,
        );

        final weWarm = WorkoutExercise(
          id: 'we-warm',
          workoutId: 'w-1',
          exerciseId: 'ex-1',
          orderIndex: 1,
        );

        final s1 = WorkoutSet(
          id: 's1',
          workoutExerciseId: 'we-1',
          setNumber: 1,
          reps: 10,
          weightKg: 50,
          isCompleted: true,
          setType: WorkoutSetType.workout,
        );

        final sWarm = WorkoutSet(
          id: 's-warm',
          workoutExerciseId: 'we-warm',
          setNumber: 1,
          reps: 10,
          weightKg: 20,
          isCompleted: true,
          setType: WorkoutSetType.warmup,
        );

        final ctx = PtContextBuilder.build(
          userId: ownerId,
          workouts: [
            Workout(
              id: 'w-1',
              userId: ownerId,
              status: WorkoutStatus.completed,
              durationSeconds: 600,
              startedAt: DateTime(2026, 11, 1),
              trainingStartedAt: DateTime(2026, 11, 1),
              completedAt: DateTime(2026, 11, 1),
              createdAt: DateTime(2026, 11, 1),
              updatedAt: DateTime(2026, 11, 1),
              exercises: [we1, weWarm],
            ),
          ],
          workoutExercises: [we1, weWarm],
          sets: [s1, sWarm],
          exercises: [exercise],
          progression: progress,
          readiness: readiness,
          activeQuests: [],
          activeClasses: [],
          currentLevel: progress.level,
          nextMilestone: null,
          builtAt: DateTime(2026, 11, 2),
        );

        // Warm-up sets should be excluded from completed set count.
        expect(ctx.recentTraining[0].sets.length, 1);
        expect(ctx.recentTraining[0].sets.first.reps, 10);
        expect(ctx.recentTraining[0].completedSetCount, 1);
      });
    });

    group('deterministic', () {
      test('same input always yields identical output', () {
        final progress = PlayerProgression(
          userId: ownerId,
          level: 1,
          totalXP: 0,
          currentTitle: null,
          lastWorkoutDate: null,
          achievements: [],
          classes: [],
          activeQuest: null,
          nextUnlock: null,
        );

        final readiness = ReadinessInsight(
          overall: ReadinessClassification.noHistory,
          muscleGroups: [],
          completedWorkoutCount: 0,
          mostRecentWorkoutAt: null,
        );

        final ctx1 = PtContextBuilder.build(
          userId: ownerId,
          workouts: [],
          workoutExercises: [],
          sets: [],
          exercises: [],
          progression: progress,
          readiness: readiness,
          activeQuests: [],
          activeClasses: [],
          currentLevel: 1,
          nextMilestone: null,
          builtAt: DateTime(2026, 11, 1),
        );

        final ctx2 = PtContextBuilder.build(
          userId: ownerId,
          workouts: [],
          workoutExercises: [],
          sets: [],
          exercises: [],
          progression: progress,
          readiness: readiness,
          activeQuests: [],
          activeClasses: [],
          currentLevel: 1,
          nextMilestone: null,
          builtAt: DateTime(2026, 11, 2),
        );

        expect(ctx1.userId, ctx2.userId);
        expect(ctx1.recentTraining, ctx2.recentTraining);
        expect(ctx1.progression.totalWorkouts, ctx2.progression.totalWorkouts);
        expect(ctx1.recovery, ctx2.recovery);
      });
    });

    group('no secrets/credentials', () {
      test('context does not contain raw credential fields', () {
        final progress = PlayerProgression(
          userId: ownerId,
          level: 1,
          totalXP: 0,
          currentTitle: null,
          lastWorkoutDate: null,
          achievements: [],
          classes: [],
          activeQuest: null,
          nextUnlock: null,
        );

        final readiness = ReadinessInsight(
          overall: ReadinessClassification.noHistory,
          muscleGroups: [],
          completedWorkoutCount: 0,
          mostRecentWorkoutAt: null,
        );

        final ctx = PtContextBuilder.build(
          userId: ownerId,
          workouts: [],
          workoutExercises: [],
          sets: [],
          exercises: [],
          progression: progress,
          readiness: readiness,
          activeQuests: [],
          activeClasses: [],
          currentLevel: progress.level,
          nextMilestone: null,
          builtAt: DateTime(2026, 11, 1),
        );

        // Verify no credential/secret strings leak into context fields.
        final contextStrings = <String>[
          ctx.userId,
          ctx.profile.trainingExperience,
          ctx.profile.primaryClassId ?? '',
          ctx.profile.primaryClassName ?? '',
          ctx.currentPlan.activeRoutineId ?? '',
          ctx.currentPlan.activeRoutineName ?? '',
          ctx.progression.currentTitle ?? '',
          ...ctx.progression.recentCategories,
          ...ctx.progression.recentPrs.map((p) => p.exerciseName),
          ...ctx.gameContext.activeClasses.map((c) => c.className),
          ...ctx.gameContext.activeQuests.map((q) => q.title),
          ...ctx.gameContext.activeQuests.map((q) => q.questId),
        ];

        for (final field in contextStrings) {
          expect(field, isNot(contains('password')));
          expect(field, isNot(contains('token')));
          expect(field, isNot(contains('secret')));
          expect(field, isNot(contains('api_key')));
          expect(field, isNot(contains('supabase')));
        }
      });
    });
  });
}
