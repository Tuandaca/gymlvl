/// Unified, owner-scoped AI Personal Trainer context.
///
/// All fields are derived from the authenticated user's own records only.
/// No secrets, credentials, or other users' records are ever included.
/// Context is intentionally bounded to avoid oversized prompts.
library;

import 'package:app/features/analytics/domain/recovery_readiness.dart';

/// Canonical AI PT context: one canonical snapshot of the authenticated
/// user's fitness state, used to build the system prompt for the AI coach.
///
/// All fields are read-only snapshots from GymLvl's existing systems.
/// Nothing here is writable by the AI; the AI only proposes, the user
/// approves, and GymLvl's authoritative server applies.
class PtContext {
  /// Authenticated user ID (from auth.uid(), never from client input).
  final String userId;

  /// Trainer-facing profile summary.
  final PtProfile profile;

  /// Current routines and planned workouts.
  final PtCurrentPlan currentPlan;

  /// Recent completed training (bounded: last N completed workouts).
  final List<PtWorkoutSummary> recentTraining;

  /// Progression facts derived deterministically before AI call.
  final PtProgression progression;

  /// Recovery / readiness facts computed deterministically.
  final ReadinessInsight recovery;

  /// Active quest / RPG context for framing.
  final PtGameContext gameContext;

  /// ISO-8601 timestamp when this context was built (server / build time).
  final DateTime builtAt;

  const PtContext({
    required this.userId,
    required this.profile,
    required this.currentPlan,
    required this.recentTraining,
    required this.progression,
    required this.recovery,
    required this.gameContext,
    required this.builtAt,
  });

  /// Returns true when there is no meaningful training history to report.
  bool get isEmpty => recentTraining.isEmpty && progression.totalWorkouts == 0;

  /// Number of distinct facts available for the AI to reason over.
  int get factCount {
    int count = 0;
    count += profile.trainingExperience.isNotEmpty ? 1 : 0;
    count += currentPlan.activeRoutineId != null ? 1 : 0;
    count += currentPlan.upcomingWorkout != null ? 1 : 0;
    count += recentTraining.length;
    count += progression.recentPrs.length;
    count += progression.recentCategories.length;
    count += recovery.muscleGroups.length;
    count += gameContext.activeQuests.length;
    return count;
  }
}

/// Lightweight profile facts visible to the AI.
class PtProfile {
  /// User-facing training experience level.
  final String trainingExperience;

  /// Primary equipped class ID (e.g. 'A'..'F').
  final String? primaryClassId;

  /// Primary class display name.
  final String? primaryClassName;

  /// Preferred weekly gym days (from profile).
  final int weeklyGymDays;

  /// Preferred weekly home days (from profile).
  final int weeklyHomeDays;

  const PtProfile({
    required this.trainingExperience,
    this.primaryClassId,
    this.primaryClassName,
    required this.weeklyGymDays,
    required this.weeklyHomeDays,
  });
}

/// Current routine / schedule facts visible to the AI.
class PtCurrentPlan {
  /// Active routine ID, or null when none.
  final String? activeRoutineId;

  /// Active routine name, or null.
  final String? activeRoutineName;

  /// Upcoming planned workout summary, or null.
  final PtWorkoutSummary? upcomingWorkout;

  /// Number of planned (not yet completed) workouts this week.
  final int plannedThisWeek;

  const PtCurrentPlan({
    this.activeRoutineId,
    this.activeRoutineName,
    this.upcomingWorkout,
    required this.plannedThisWeek,
  });
}

/// Summary of a completed workout for AI context.
class PtWorkoutSummary {
  final String workoutId;
  final String startedAt;
  final String completedAt;
  final int durationSeconds;
  final int completedSetCount;
  final List<PtSetSummary> sets;

  const PtWorkoutSummary({
    required this.workoutId,
    required this.startedAt,
    required this.completedAt,
    required this.durationSeconds,
    required this.completedSetCount,
    required this.sets,
  });
}

/// Summary of a single completed set for AI context.
class PtSetSummary {
  final String exerciseId;
  final String exerciseName;
  final String category;
  final int setNumber;
  final int reps;
  final double weightKg;
  final bool isCompleted;
  final bool isWarmup;

  const PtSetSummary({
    required this.exerciseId,
    required this.exerciseName,
    required this.category,
    required this.setNumber,
    required this.reps,
    required this.weightKg,
    required this.isCompleted,
    required this.isWarmup,
  });
}

/// Deterministic progression facts computed before the AI call.
class PtProgression {
  final int totalWorkouts;
  final int currentLevel;
  final int totalXP;
  final int xpToNextLevel;
  final List<String> recentCategories;
  final List<PtPrSummary> recentPrs;
  final String? currentTitle;
  final DateTime? lastWorkoutDate;

  const PtProgression({
    required this.totalWorkouts,
    required this.currentLevel,
    required this.totalXP,
    required this.xpToNextLevel,
    required this.recentCategories,
    required this.recentPrs,
    this.currentTitle,
    this.lastWorkoutDate,
  });
}

/// Personal record summary for AI context.
class PtPrSummary {
  final String exerciseId;
  final String exerciseName;
  final double maxWeightKg;
  final int maxReps;
  final double estimated1rm;
  final DateTime updatedAt;

  const PtPrSummary({
    required this.exerciseId,
    required this.exerciseName,
    required this.maxWeightKg,
    required this.maxReps,
    required this.estimated1rm,
    required this.updatedAt,
  });
}

/// Game context visible to the AI (class, quests, milestones).
class PtGameContext {
  final List<PtClassSummary> activeClasses;
  final List<PtQuestSummary> activeQuests;
  final int? currentLevel;
  final String? nextMilestone;

  const PtGameContext({
    required this.activeClasses,
    required this.activeQuests,
    this.currentLevel,
    this.nextMilestone,
  });
}

/// Equipped class summary.
class PtClassSummary {
  final String classId;
  final String className;
  final String slot; // 'primary' | 'secondary'
  final int currentXP;
  final int level;
  final bool isGraduated;

  const PtClassSummary({
    required this.classId,
    required this.className,
    required this.slot,
    required this.currentXP,
    required this.level,
    required this.isGraduated,
  });
}

/// Active quest summary.
class PtQuestSummary {
  final String questId;
  final String title;
  final String status;
  final DateTime expiresAt;

  const PtQuestSummary({
    required this.questId,
    required this.title,
    required this.status,
    required this.expiresAt,
  });
}
