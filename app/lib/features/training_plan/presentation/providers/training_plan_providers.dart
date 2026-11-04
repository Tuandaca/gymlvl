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

/// Beginner profile reconstructed from the authenticated user and the
/// server-owned completed-workout count. Experience level is 'beginner' for the
/// first-week flow; non-beginners and returning users receive an empty plan at
/// the engine level, so existing history is never overwritten.
final beginnerProfileProvider = FutureProvider<BeginnerProfile>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final count = await ref.read(completedWorkoutCountProvider.future);
  return BeginnerProfile(
    userId: userId,
    experienceLevel: 'beginner',
    completedWorkoutCount: count,
  );
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
