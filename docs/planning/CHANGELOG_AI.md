# GymLvl — AI Changelog

Dated record of agent sessions and project checkpoints. Newest first.

## 2026-11-06 — P7: Remaining OpenGym Parity & Optional Integrations (COMPLETE — all seven frozen gates PASS)

**Task:** Execute P7 — close the seven frozen CORE gates (custom exercises, favourites + aliases, import framework + supported imports, backup restore, health-platform integration boundary, optional media integration boundary, focused tests + regression/security).

**Status:** `COMPLETE` (all seven frozen P7 CORE gates implemented and verified)

**Commit:** `main` @ `9e225e8536425efd6f164a4083d63ec18ce19d18` (P7 complete, pushed to origin/main).

**P7 Gate 4 (Backup Restore) — COMPLETE**
- **File:** `app/lib/features/analytics/data/backup_import_service.dart`
- **Behavior:** Strict validation of gymlvl-backup v1 format (format, version, required sections, dates, IDs, numbers, relationships). Preview before confirmation. Restore via existing repositories. Historical workouts use `markWorkoutCompleted` (NOT `completeWorkout`) → ZERO XP/quest/streak/achievement/unlock. Duplicate restore safe. No secrets/credentials restored.

**P7 Gate 5 (Health Integration Boundary) — COMPLETE**
- **File:** `app/lib/features/analytics/domain/health_data_repository.dart`
- **Behavior:** `HealthDataRepository` abstract class + `FakeHealthDataRepository` for tests. `HealthCapability` enum (available/unsupported/not-connected). `ExternalHealthRecord` explicitly tagged `isExternal=true`. External health data grants ZERO RPG reward. `complete_workout` never called.

**P7 Gate 6 (Media Integration Boundary) — COMPLETE**
- **File:** `app/lib/features/workout/domain/exercise_media.dart`
- **Behavior:** `ExerciseMedia` model with `MediaType`, `MediaSource`, `MediaLicense`. `isSafe` property rejects unknown provenance. `isLegalBlocked` blocks AGPL/proprietary OpenGym media. `FakeExerciseMediaRepository` for tests. No media required — GymLvl works with zero exercise media.

**P7 Gate 7 (Focused Tests + Regression/Security) — COMPLETE**
- **Test files:** `test/p7_backup_import_test.dart` (10 tests), `test/p7_health_media_test.dart` (18 tests), `test/p7_exercise_personalization_test.dart` (18 tests)
- **Total:** 46 focused Dart tests, all PASS
- **SQL/ACL:** `supabase/tests/p7_exercise_personalization.sql` PASS (owner CRUD, archive, favourites, aliases, unique constraints, structural ACL policies)
- **Regression:** `flutter analyze` — no errors (only pre-existing warnings); `flutter test` — all pass except pre-existing `release_config_test.dart` (Gradle 9.7.1 vs 8.13, owner file untouched); `dart format` — stable

**All changed/added P7 files:**
- `app/lib/features/analytics/data/backup_import_service.dart` (new) — P7 Gate 4 backup restore
- `app/lib/features/analytics/domain/health_data_repository.dart` (new) — P7 Gate 5 health boundary
- `app/lib/features/workout/domain/exercise_media.dart` (new) — P7 Gate 6 media boundary
- `app/test/p7_backup_import_test.dart` (new) — P7 Gate 4+7 tests (10 tests)
- `app/test/p7_health_media_test.dart` (new) — P7 Gate 5+6+7 tests (18 tests)
- `app/test/p7_exercise_personalization_test.dart` (new) — P7 Gates 1-3+7 tests (18 tests)
- `app/lib/features/workout/data/supabase_workout_repository.dart` (modified) — added `markWorkoutCompleted` (import-safe path)
- `app/lib/features/workout/domain/workout_repository.dart` (modified) — added `markWorkoutCompleted` abstract method
- `app/test/ai_trainer/pt_application_test.dart` (modified) — added `markWorkoutCompleted` stub to fake repo
- Previously staged P7 Gates 1–3 files (csv_import_service.dart, import_models.dart, exercise_repository.dart, supabase_exercise_repository.dart, exercise_providers.dart, migrations, SQL test, test mocks)

**Gate-by-gate verification:**
- Gate 1 (Custom exercise support): PASS — CRUD, archive, owner isolation, routine/workout compatibility
- Gate 2 (Favourites + aliases): PASS — toggle, owner isolation, alias search, canonical ID/name preserved, cross-user hidden
- Gate 3 (Import framework + supported imports): PASS — GymLvl CSV, generic CSV, invalid schema, unknown exercise, unit conversion, preview before persist, duplicate fingerprint, zero XP
- Gate 4 (Backup restore): PASS — valid v1 backup, invalid JSON, wrong format, unsupported version, relationship preservation, duplicate restore, zero reward, no secrets
- Gate 5 (Health integration boundary): PASS — capability detection, unsupported capability, external tagging, zero reward
- Gate 6 (Media integration boundary): PASS — no-media fallback, approved provenance, unknown provenance rejected, OpenGym proprietary media absent
- Gate 7 (Focused tests + regression/security): PASS — 46 Dart tests, SQL/ACL, flutter analyze, flutter test

**Parity matrix classification:**
- Custom exercises = EXISTING
- Favourites = EXISTING
- Aliases = EXISTING
- GymLvl CSV import = EXISTING
- Generic CSV import = EXISTING
- Backup restore = EXISTING
- Health integration boundary = EXISTING
- Production Health rollout = PLATFORM-BLOCKED / DEFERRED
- Media boundary = EXISTING
- OpenGym proprietary media = LEGAL-BLOCKED

**Next actions:** P7 is complete and committed at `9e225e8`. P8 = NEXT / NOT STARTED. Do NOT start P8 without owner instruction.

---

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
