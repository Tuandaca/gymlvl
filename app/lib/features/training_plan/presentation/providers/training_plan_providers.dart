/// Riverpod providers for the M5 first-week plan and newcomer journey presentation.
///
/// All providers are pure Dart and depend on repository interfaces that can be
/// overridden in tests. No provider writes progression and none calls
/// `complete_workout`; XP, levels, streaks, quest rewards, PRs and completed
/// workouts remain server-authoritative.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/training_plan/first_week_plan_engine.dart';
import 'package:app/features/training_plan/first_week_plan_models.dart';
import 'package:app/features/training_plan/newcomer_journey.dart';
import 'package:app/features/training_plan/newcomer_journey_models.dart';
import 'package:app/features/workout/presentation/providers/exercise_providers.dart';
import 'package:app/features/auth/presentation/providers/auth_providers.dart';

// ─── Current user id ───

/// Current authenticated user id, empty when not signed in. Overridable in tests.
final currentUserIdProvider = Provider<String>((ref) {
  final auth = ref.watch(authStateStreamProvider);
  return auth.value?.session?.user.id ?? '';
});

// ─── Completed-workout count (server-owned) ───

/// Server-owned count of completed workouts. Read-only; never written by client.
final completedWorkoutCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.getCompletedWorkoutCount();
});

// ─── Beginner profile ───

/// Beginner profile reconstructed from the authenticated user's saved profile
/// and the server-owned completed-workout count. Never infer experience from
/// the absence of history: persisted `experience_level` is the source of truth.
final beginnerProfileProvider = FutureProvider<BeginnerProfile>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final profile = await ref.watch(currentUserProfileProvider.future);
  final count = await ref.watch(completedWorkoutCountProvider.future);
  final rawExperience =
      profile?['experience_level'] ?? profile?['experienceLevel'];
  final experience = rawExperience is String && rawExperience.trim().isNotEmpty
      ? rawExperience.trim().toLowerCase()
      : 'beginner';
  return BeginnerProfile(
    userId: userId,
    experienceLevel: experience,
    completedWorkoutCount: count,
  );
});

/// Existing routine selection is the destination for experienced users. This
/// provider does not invent prescriptions or automatic loads.
enum PlanRoute { firstWeek, routineSelection }

final planRouteProvider = FutureProvider<PlanRoute>((ref) async {
  final profile = await ref.watch(beginnerProfileProvider.future);
  return profile.isBeginner && !profile.isReturningUser
      ? PlanRoute.firstWeek
      : PlanRoute.routineSelection;
});

// ─── First-week plan ───

/// Generated first-week plan (empty for returning users / non-beginners).
/// Deterministic: same profile + catalog always yields the same plan, in the
/// same order, which makes regeneration safe.
final firstWeekPlanProvider = FutureProvider<FirstWeekPlan>((ref) async {
  final profile = await ref.read(beginnerProfileProvider.future);
  final catalog = await ref.read(exerciseListProvider.future);
  return FirstWeekPlanEngine().generate(profile, catalog);
});

// ─── Newcomer journey state ───

/// Reconstructed newcomer journey state from durable (server-owned) inputs.
final newcomerJourneyProvider = FutureProvider<NewcomerJourneyState>((
  ref,
) async {
  final count = await ref.read(completedWorkoutCountProvider.future);
  return NewcomerJourney.reconstruct(
    completedWorkoutCount: count,
    planStarted: false,
    lastCompletedDay: null,
  );
});
