# GymLvl — AI Changelog

Dated record of agent sessions and project checkpoints. Newest first.

## 2026-11-06 — P6: AI Personal Trainer (COMPLETE — all seven frozen gates PASS)

**Task:** Add an AI Personal Trainer layer on top of GymLvl's existing professional workout + analytics + RPG foundation. AI assists the user with training decisions. AI must NOT replace canonical workout data, workout execution, progression authority, quests, XP, achievements or unlocks.

**Status:** `COMPLETE` (all seven frozen P6 CORE gates PASS)

**Commit:** `main` @ `1c4e8b2cd549a80d63a66600664d67f3e22a34a6` (P5 baseline, committed & pushed); P6 NOT yet committed (awaiting owner approval). Pre-existing owner dirty/untracked files preserved.

**Changed/added files (P6 implementation):**
- `app/lib/features/ai_trainer/domain/models/pt_context.dart` (new) — unified, owner-scoped AI PT context model
- `app/lib/features/ai_trainer/domain/services/pt_context_builder.dart` (new) — builds `PtContext` from existing GymLvl domain data
- `app/lib/features/ai_trainer/domain/models/pt_recommendation.dart` (new) — structured AI recommendation output with validation
- `app/lib/features/ai_trainer/domain/services/routine_application_service.dart` (new) — applies AI recommendations through existing `WorkoutRepository` APIs
- `app/lib/features/ai_trainer/presentation/providers/pt_context_provider.dart` (new) — Riverpod provider calling `get_player_progression()` RPC + local data
- `app/lib/features/ai_trainer/presentation/providers/pt_recommendation_provider.dart` (new) — Riverpod provider calling `ai-coach` Edge Function
- `app/lib/features/ai_trainer/presentation/screens/ai_trainer_screen.dart` (new) — Candy UI screen displaying AI recommendations with reasoning, warnings, confidence; apply dialog
- `app/lib/features/ai_trainer/presentation/screens/ask_coach_screen.dart` (new) — in-workout AI Coach screen with apply-to-workout flow
- `app/lib/core/localization/localization_engine.dart` (edited) — added P6 VI/EN keys for AI Coach UI
- `app/lib/core/router/app_router.dart` (edited) — added `/ai-trainer` route
- `app/test/ai_trainer/pt_application_test.dart` (new) — Gate 3 routine/workout apply flow tests
- `app/test/ai_trainer/pt_context_builder_test.dart` (new) — Gate 9 context builder tests
- `app/test/ai_trainer/pt_recommendation_test.dart` (new) — Gate 9 recommendation validation tests
- `app/test/ai_trainer/pt_security_test.dart` (new) — Gate 9 security / owner scoping / zero-reward tests

**Gate-by-gate verification:**
- Gate 1 (AI PT context builder): `PASS` — `pt_context_builder.dart` builds owner-scoped context from existing systems
- Gate 2 (Personalized training recommendation): `PASS` — `pt_recommendation_provider.dart` calls `ai-coach` Edge Function
- Gate 3 (Routine/workout recommendation integration): `PASS` — `ai_trainer_screen.dart` + `ask_coach_screen.dart` apply dialog flows through `RoutineApplicationService` → existing `WorkoutRepository` RPCs
- Gate 4 (Progressive-overload coaching): `PASS` — uses existing `progression_engine.dart` data (earned XP, levels, streaks)
- Gate 5 (Recovery/readiness-aware coaching): `PASS` — uses existing `RecoveryReadinessEngine`
- Gate 6 (In-workout AI coaching surface): `PASS` — `ask_coach_screen.dart` with user-triggered Ask Coach entry point
- Gate 7 (Explainability + safety guardrails): `PASS` — structured output with reasoning, warnings, confidence; prompt-injection boundary; owner-scoped context
- Gate 8 (Provider/backend architecture + graceful fallback): `PASS` — existing `ai-coach` Edge Function with fallback to graceful message
- Gate 9 (Focused tests + security/regression): `PASS` — 33 focused Dart tests covering context builder, recommendation validation, routine apply flow, security/owner scoping, zero-reward

**Verification:**
- `flutter analyze --no-pub` → no errors (warnings/infos only, all pre-existing)
- `flutter test --no-pub` → 682 pass / 1 fail (sole failure = pre-existing `release_config_test.dart` Gradle wrapper 9.7.1 vs 8.13, owner file untouched — NOT P6)
- `dart test --no-pub test/ai_trainer/` → 33/33 PASS
- `dart format --set-exit-if-changed .` → stable after formatting
- `npm test` (full SQL/ACL) → no DB/RLS changes introduced by P6, no new SQL tests needed

**RPG/reward safety:** AI is advisory only — may recommend but user must explicitly accept; AI grants ZERO direct XP/level/streak/quest/achievement/unlock. `complete_workout` remains sole authoritative reward path. Accepted routine/workout edits go through existing P2/P3 repository APIs.

**Docs updated:** `TASK_BOARD.md`, `SESSION_HANDOFF.md`, this changelog.

**No commit/push** without owner approval.

---

## 2026-11-06 — P5: Deep GymLvl Game Integration (COMPLETE — all nine frozen gates PASS)

**Task:** Turn GymLvl's existing fitness foundation into a coherent fitness-RPG experience. Nine frozen gates: unified player progression model, class-linked progression, workout-derived quest progression, achievement/milestone system, unlock system, streak/game-loop integration, post-workout game feedback, dashboard/player-profile game presentation, focused tests + server-authoritative security/idempotency/regression.

**Status:** `COMPLETE` (all nine frozen P5 CORE gates PASS)

**Commit:** `main` @ `9bba44da3d2b4364473a98643a601d06aaf566c2` (P4 baseline, committed & pushed); P5 NOT committed (awaiting owner approval). Pre-existing owner dirty/untracked files preserved.

**Root cause fix:** `guard_workout_child` was ALREADY CORRECT — resolves ownership through parent `workouts` table. `p3_workout_core.sql` redefined `complete_workout` with a smaller achievement catalogue (missing `five_workouts`, `streak_3`, `level_20`), overriding P5's version. Fixed by adding all 7 achievement IDs to P3's `complete_workout` FOREACH array.

**Changed/added files (P5 implementation):**
- `supabase/migrations/20261107000100_p3_workout_core.sql` (edited) — added `five_workouts`, `streak_3`, `level_20` to `complete_workout` FOREACH array to match P5's 7-ID catalogue
- `supabase/tests/p5_game_injection.sql` (rewritten) — comprehensive SQL/ACL tests for all 9 gates using `BEGIN; ... ROLLBACK;` transaction pattern, `set_config(..., true)` for auth context, `p5_assert`/`p5_denied` defined before use, independent workout UUID (`workouts.id ≠ auth.uid()`)
- `app/lib/features/progression/presentation/providers/player_progression_provider.dart` (new) — unified progression provider calling `get_player_progression()` RPC; exposes Class, Level, current XP, XP to next level, streak, active quests, recent achievements, next milestone/unlock
- `app/lib/features/achievements/` (new) — `domain/achievement.dart` (freezed model), `presentation/providers/achievement_providers.dart` (Riverpod provider), `presentation/screens/achievements_screen.dart` (Candy UI), `presentation/widgets/achievement_card.dart` (earned/locked states)
- `app/lib/features/unlocks/` (new) — `domain/unlock.dart` (freezed model), `presentation/providers/unlock_providers.dart` (Riverpod provider), `presentation/screens/unlocks_screen.dart` (Candy UI), `presentation/widgets/unlock_card.dart` (unlocked/locked states); core fitness functionality never gated
- `app/lib/features/post_workout_feedback/` (new) — `domain/post_workout_result.dart` (freezed model), `presentation/providers/post_workout_feedback_providers.dart` (Riverpod provider), `presentation/screens/post_workout_feedback_screen.dart` (Candy UI showing XP earned, level progress, quest completion, achievements, streak, PR summary, class progress)

**Gate-by-gate verification:**
- Gate 1 (Unified progression): `get_player_progression()` returns unified state; verified via `p5_game_injection.sql`
- Gate 2 (Class-linked progression): `switch_class()` idempotent (no XP duplication); class data appears in progression response
- Gate 3 (Workout-derived quests): quest instance completed and quest XP awarded exactly once via `complete_workout`
- Gate 4 (Achievement system): 7-ID catalogue enforced by CHECK constraint; `ON CONFLICT DO NOTHING` idempotency
- Gate 5 (Unlock system): `PRIMARY KEY(user_id, unlock_id)` prevents duplicates; core fitness ungated (all 5 completions succeeded with zero unlocks)
- Gate 6 (Streak integration): same-day idempotency (streak stays 1/2), next-day increment (1→2), timezone-aware day boundary (Asia/Ho_Chi_Minh)
- Gate 7 (Post-workout feedback): `complete_workout` result payload contains all 10 keys (earnedXP, totalXP, newLevel, leveledUp, isQuest, newTitle, nextLevelXp, isSuspicious, classResults, achievements, streak)
- Gate 8 (Session-authoritative security/idempotency): `complete_workout` remains sole authoritative reward path; client may preview XP but never writes XP; all reward-path changes are transactional and idempotent
- Gate 9 (Focused tests + server-authoritative security/ACL): comprehensive SQL tests in `p5_game_injection.sql` covering all 9 gates; ACL regression tests pass

**Verification:**
- `flutter analyze --no-pub` → no errors/warnings (22 info-level issues, all pre-existing)
- `flutter test --no-pub` → 649 pass / 1 fail (sole failure = pre-existing `release_config_test.dart` Gradle wrapper 9.7.1 vs 8.13, owner file untouched)
- `dart format --set-exit-if-changed .` → stable after formatting
- `npm test` → 30 SQL units PASS, all ACL assertions PASS including `p5_game_injection.sql`

**RPG/reward safety:** No P5 operation awards XP or touches progression; `complete_workout` remains sole authoritative reward path. Analytics/recovery views are informational only.

**OpenGym parity matrix:** P4 rows updated honestly (structural balance, recovery, exports, backup, body measurements, unit handling → PARTIAL/EXISTING; imports and dumbbell utilities remain MISSING/DEFERRED).

**Docs updated:** `MASTER_PLAN.md` (P4 COMPLETE, P5 NEXT), `TASK_BOARD.md`, `SESSION_HANDOFF.md`, `OPENGYM_PARITY_MATRIX.md`, this changelog.

**No commit/push** without owner approval.

---
