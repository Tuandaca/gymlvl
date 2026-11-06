/// Builds a bounded, owner-scoped [PtContext] from GymLvl's existing systems.
///
/// All data is derived from the authenticated user's own records only.
/// No secrets, credentials, or other users' records are ever included.
/// Context is intentionally bounded to avoid oversized prompts.
library;

import 'package:app/features/analytics/domain/recovery_readiness.dart';
import 'package:app/features/progression/domain/player_progression.dart';
import 'package:app/features/workout/domain/exercise.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout_set.dart';
import '../models/pt_context.dart';

/// Maximum number of recent completed workouts included in context.
const int kMaxRecentWorkouts = 5;

/// Maximum number of completed sets per workout included in context.
const int kMaxSetsPerWorkout = 6;

/// Epoch zero for sorting workouts when completedAt is null.
final DateTime _kEpoch = DateTime(0);

/// Builds a bounded, owner-scoped [PtContext] from existing GymLvl systems.
///
/// All inputs must come from the authenticated user's own records.
/// The builder never reads other users' data and never includes secrets.
class PtContextBuilder {
  /// Build context from existing GymLvl domain data.
  ///
  /// [userId] must equal `auth.uid()` (owner-scoped).
  /// [workouts] completed workouts owned by [userId].
  /// [workoutExercises] workout exercises for those workouts.
  /// [sets] workout sets for those exercises.
  /// [exercises] catalogue exercises referenced by [workoutExercises].
  /// [progression] unified player progression from `get_player_progression()`.
  /// [readiness] deterministic readiness from [RecoveryReadinessEngine].
  /// [activeQuests] active quest instances owned by [userId].
  /// [activeClasses] equipped class summaries owned by [userId].
  /// [currentLevel] current global level (server-authoritative).
  /// [nextMilestone] next unearned milestone description, or null.
  /// [builtAt] timestamp when context was built.
  static PtContext build({
    required String userId,
    required List<Workout> workouts,
    required List<WorkoutExercise> workoutExercises,
    required List<WorkoutSet> sets,
    required List<Exercise> exercises,
    required PlayerProgression progression,
    required ReadinessInsight readiness,
    required List<Map<String, dynamic>> activeQuests,
    required List<Map<String, dynamic>> activeClasses,
    required int currentLevel,
    String? nextMilestone,
    required DateTime builtAt,
  }) {
    // Bounded recent training: sort by completedAt desc, take kMaxRecentWorkouts.
    final recentWorkouts = <Workout>[];
    for (final w in workouts) {
      if (w.status == WorkoutStatus.completed && w.completedAt != null) {
        recentWorkouts.add(w);
      }
    }
    recentWorkouts.sort((a, b) {
      final aTime = a.completedAt ?? _kEpoch;
      final bTime = b.completedAt ?? _kEpoch;
      return bTime.compareTo(aTime);
    });
    if (recentWorkouts.length > kMaxRecentWorkouts) {
      recentWorkouts.length = kMaxRecentWorkouts;
    }

    final weById = <String, WorkoutExercise>{};
    for (final we in workoutExercises) {
      weById[we.id] = we;
    }

    final setsByWeId = <String, List<WorkoutSet>>{};
    for (final s in sets) {
      setsByWeId.putIfAbsent(s.workoutExerciseId, () => <WorkoutSet>[]);
      setsByWeId[s.workoutExerciseId]!.add(s);
    }

    final exById = <String, Exercise>{};
    for (final e in exercises) {
      exById[e.id] = e;
    }

    final recentTraining = <PtWorkoutSummary>[];
    for (final w in recentWorkouts) {
      // Find workout exercises belonging to this workout.
      final wes = <WorkoutExercise>[];
      for (final we in workoutExercises) {
        if (we.workoutId == w.id) wes.add(we);
      }
      wes.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

      final summaries = <PtSetSummary>[];
      for (final we in wes) {
        final ex = exById[we.exerciseId];
        final wsList = setsByWeId[we.id] ?? <WorkoutSet>[];
        final completedSets = wsList
            .where((s) => s.isCompleted && !s.isWarmup)
            .toList();

        for (final s in completedSets.take(kMaxSetsPerWorkout)) {
          summaries.add(
            PtSetSummary(
              exerciseId: we.exerciseId,
              exerciseName: ex?.name ?? 'unknown',
              category: ex?.category ?? 'unknown',
              setNumber: s.setNumber,
              reps: s.reps,
              weightKg: s.weightKg,
              isCompleted: s.isCompleted,
              isWarmup: s.isWarmup,
            ),
          );
        }
      }

      recentTraining.add(
        PtWorkoutSummary(
          workoutId: w.id,
          startedAt: w.startedAt?.toIso8601String() ?? '',
          completedAt: w.completedAt?.toIso8601String() ?? '',
          durationSeconds: w.durationSeconds,
          completedSetCount: summaries.length,
          sets: summaries,
        ),
      );
    }

    final recentPrs = <PtPrSummary>[];
    // PRs are not directly on Exercise; placeholder for future
    // integration with exercise_prs table.

    final recentCategories = <String>{};
    for (final w in recentWorkouts) {
      for (final we in workoutExercises) {
        if (we.workoutId != w.id) continue;
        final ex = exById[we.exerciseId];
        if (ex != null) recentCategories.add(ex.category);
      }
    }

    // Build active classes summary.
    final activeClassList = <PtClassSummary>[];
    if (activeClasses.isNotEmpty) {
      final primaryClass = activeClasses.firstWhere(
        (c) => c['slot'] == 'primary',
        orElse: () => activeClasses.first,
      );
      activeClassList.add(
        PtClassSummary(
          classId: primaryClass['class_id'] as String,
          className: primaryClass['class_name'] as String,
          slot: primaryClass['slot'] as String,
          currentXP: primaryClass['current_xp'] as int? ?? 0,
          level: primaryClass['level'] as int? ?? 1,
          isGraduated: primaryClass['is_graduated'] as bool? ?? false,
        ),
      );
    }

    return PtContext(
      userId: userId,
      profile: PtProfile(
        trainingExperience: progression.level >= 10
            ? 'experienced'
            : progression.level >= 5
            ? 'intermediate'
            : 'beginner',
        primaryClassId: activeClassList.isNotEmpty
            ? activeClassList.first.classId
            : null,
        primaryClassName: activeClassList.isNotEmpty
            ? activeClassList.first.className
            : null,
        weeklyGymDays: 3, // default; from profiles when available
        weeklyHomeDays: 0,
      ),
      currentPlan: PtCurrentPlan(
        activeRoutineId: null, // from routine repository when available
        activeRoutineName: null,
        upcomingWorkout: null,
        plannedThisWeek: 0,
      ),
      recentTraining: recentTraining,
      progression: PtProgression(
        totalWorkouts: readiness.completedWorkoutCount,
        currentLevel: currentLevel,
        totalXP: progression.totalXP,
        xpToNextLevel: progression.xpToNextLevel,
        recentCategories: recentCategories.toList(),
        recentPrs: recentPrs,
        currentTitle: progression.currentTitle,
        lastWorkoutDate: progression.lastWorkoutDate,
      ),
      recovery: readiness,
      gameContext: PtGameContext(
        activeClasses: activeClassList,
        activeQuests: activeQuests
            .map(
              (q) => PtQuestSummary(
                questId: q['quest_id'] as String,
                title: q['title'] as String,
                status: q['status'] as String,
                expiresAt: q['expires_at'] != null
                    ? DateTime.parse(q['expires_at'] as String)
                    : DateTime.now(),
              ),
            )
            .toList(),
        currentLevel: currentLevel,
        nextMilestone: nextMilestone,
      ),
      builtAt: builtAt,
    );
  }
}
