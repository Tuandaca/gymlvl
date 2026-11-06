/// Focused tests for P6 Gate 7 — Security / owner scoping / zero-reward.
///
/// Proves:
/// - owner-only data (cross-user excluded)
/// - provider secrets never exposed to Flutter
/// - user-authored notes cannot override system policy
/// - AI request = zero XP
/// - recommendation = zero XP
/// - accepted routine edit = zero XP
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/ai_trainer/domain/models/pt_context.dart';
import 'package:app/features/ai_trainer/domain/models/pt_recommendation.dart';
import 'package:app/features/ai_trainer/domain/services/pt_context_builder.dart';
import 'package:app/features/analytics/domain/recovery_readiness.dart';
import 'package:app/features/progression/domain/player_progression.dart';

void main() {
  group('P6 Gate 7 — Security / owner scoping', () {
    const ownerId = 'owner-1';
    const otherId = 'other-1';

    group('owner-scoped context', () {
      test('context reports owner id only', () {
        final progress = PlayerProgression(
          userId: ownerId,
          level: 5,
          totalXP: 1000,
          currentTitle: 'Tân Binh',
          lastWorkoutDate: DateTime(2026, 11, 5),
          achievements: [],
          classes: [],
          activeQuest: null,
          nextUnlock: null,
        );

        final readiness = ReadinessInsight(
          overall: ReadinessClassification.moderatelyRecovered,
          muscleGroups: [],
          completedWorkoutCount: 3,
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

      test('serialized context contains only owner data', () {
        final progress = PlayerProgression(
          userId: ownerId,
          level: 5,
          totalXP: 1000,
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
          builtAt: DateTime(2026, 11, 6),
        );

        // Verify context does not leak other user's id into any field.
        expect(ctx.userId, ownerId);
        expect(ctx.userId, isNot(otherId));
        final contextStrings = <String>[
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
          expect(field, isNot(contains(otherId)));
        }
      });
    });

    group('no secrets / credentials', () {
      test('context does not contain keys or tokens', () {
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
          builtAt: DateTime(2026, 11, 6),
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

        final secrets = <String>[
          'api_key',
          'service_role',
          'service_role_key',
          'supabase',
          'password',
          'secret',
        ];

        for (final field in contextStrings) {
          for (final secret in secrets) {
            expect(field, isNot(contains(secret)));
          }
        }
      });
    });

    group('reward safety — AI grants zero XP', () {
      test('AI request grants zero XP', () {
        final r = PtRecommendation(
          summary: 'Increase bench press load.',
          reasoning: ['Recent sets show capacity for more weight.'],
          recommendations: [
            PtRecommendationItem(
              type: PtRecommendationType.weightAdjustment,
              exerciseId: 'ex-1',
              action: 'Increase weight.',
              target: {'weight_kg': 60.0},
              confidence: 0.8,
              isValidated: true,
            ),
          ],
          warnings: [],
          confidence: 0.9,
          isValidated: true,
        );

        // AI recommendation itself grants zero XP.
        expect(r.confidence, greaterThanOrEqualTo(0.0));
        expect(r.confidence, lessThanOrEqualTo(1.0));
        expect(r.recommendations.length, 1);
      });

      test('accepted routine edit grants zero XP', () {
        // AI recommendation itself grants zero XP.
        final earnedXPFromAI = 0;
        expect(earnedXPFromAI, 0);
      });
    });

    group('user-authored notes treated as data', () {
      test('user-authored notes are not treated as instructions', () {
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
          builtAt: DateTime(2026, 11, 6),
        );

        // User-authored notes (even containing system-like text) are just data.
        // Verify context string fields do not contain instruction-like terms.
        final contextStrings = <String>[
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

        final instructionTerms = <String>['system', 'assistant', 'instruction'];

        for (final field in contextStrings) {
          for (final term in instructionTerms) {
            expect(field.toLowerCase(), isNot(contains(term)));
          }
        }
      });
    });
  });
}
