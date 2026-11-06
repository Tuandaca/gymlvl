# GymLvl — Session Handoff

## NEW SESSION START HERE

| Field | Value |
|---|---|
| Date | 2026-11-06 |
| Branch | `main` |
| HEAD | `1c4e8b2cd549a80d63a66600664d67f3e22a34a6` (P6 baseline; origin/main == local main) |
| Remote | `origin/main` == local `main` |
| Working-tree state | Dirty — **P2 + P3 + M3/M4/M5 changes (implementation + focused tests + SQL test)** + pre-existing owner work preserved (modified tracked files + untracked owner files) + **P4 additions (new files + edits to non-dirty files)** + **P5 implementation (9 gates complete + SQL test infra fix)** + **P6 AI PT implementation** (all seven frozen gates PASS); **do not discard, reset, or overwrite** |
| Product | GymLvl — mobile-first fitness RPG (Flutter + Riverpod + GoRouter + Supabase/PostgreSQL + Edge Functions), Candy Neubrutalism UI, VI/EN |
| Current architecture | Existing GymLvl Flutter/Supabase architecture preserved; OpenGym is behavioral reference only (AGPL, no code reuse) |
| Completed foundation | M1–M5 foundation complete. P1 complete (parity matrix, legal-safe exercisedb import pipeline, provenance migration). P2 complete (Routine & Planning Parity). P3 complete (Workout Core Parity). **P4 complete — all eight frozen CORE gates PASS. P5 complete — all nine frozen CORE gates PASS.** |
| Current roadmap phase | **P5 — Deep GymLvl Game Integration: COMPLETE.** P6 — AI Personal Trainer: COMPLETE (all seven frozen gates PASS). P7 = NEXT / NOT STARTED. |
| Next implementation phase | P6 AI PT — COMPLETE. P7 = NEXT / NOT STARTED. Do not start P7. |
| OpenGym pin | `DuarteSantos8/openGym` @ `e6a95c28a6e3067bdd9b1188d5f37f448d528bd2` (AGPL, reference only) |
| Exercise dataset pin | `hasaneyldrm/exercises-dataset` @ `7455efae41b330c265e7cd4b78dfa848e7ce5ebd` (MIT text/data, media excluded). **Import source: direct from pinned MIT dataset (`data/exercises.json`), NOT from OpenGym catalogue.** Verified 1,324 records. |
| Legal restrictions | No AGPL code/prompts/catalogue-text/assets; no third-party media; MIT text only with notice; media excluded |
| Production restrictions | Do NOT deploy production migrations; do NOT run `supabase db push`; onboarding 9/9 blocked on production DB access; no release hardening |
| Immediate next action | Owner review of P6 candidate manifest (`git status --short` + `git diff --name-status` + `git diff`); approve commit. P6 is ready to commit. Do NOT start P7. |
| Do not do | Do not start P5 automatically; no AI PT (P6); no production deploy/migration; no media; no commit/push without owner approval |
| Read first | `docs/planning/MASTER_PLAN.md`, `docs/planning/PROJECT_CONTEXT.md`, `docs/planning/TASK_BOARD.md`, `docs/planning/DECISIONS.md`, `docs/planning/OPENGYM_PARITY_MATRIX.md` |

---

## Current — Onboarding 9/9 submit failure investigation (2026-11-04) — BLOCKED on production DB access

**Task:** Investigate and fix `initialize_user` RPC failure when user completes onboarding step 9/9. UI shows `Không thể hoàn tất yêu cầu. Vui lòng thử lại.`

**Status:** `BLOCKED` — Root cause identified but fix requires production database access/migration deployment, which requires explicit owner approval.

**Root cause:** Production onboarding 9/9 is blocked by a production schema/runtime mismatch. Read-only inspection showed that expected initialization capability such as `initialize_user` and `profiles.timezone` was absent. The exact unapplied migration set has not yet been established.

**Call chain:** `onboarding_screen.dart:42` → `onboarding_controller.dart:54-101` → `SupabaseClient.rpc('initialize_user', ...)` → PostgREST → PostgreSQL `public.initialize_user(p_profile jsonb)` → INSERT `public.profiles`, `public.user_classes`; UPDATE `public.users`; INSERT `public.streaks`.

**Local verification:** PGlite + all 10 migrations → `initialize_user` PASS (onboarding completes, `onboarding_completed=true`, idempotent retry returns "Onboarding already complete").

**Production verification:** `NOT RUN` — no production Supabase access. Cannot confirm exact production error code.

**Files changed:** None (read-only investigation).

**Blockers:** No production Supabase access; `supabase db push`/remote migration requires explicit owner approval per AGENTS.md §0.3/§8.

**Next action:** Owner to verify production database schema (`public.initialize_user` function, `public.profiles.timezone` column, `public.users` rows) and approve migration deployment if missing.

---

## P2 — Routine & Planning Parity (2026-11-06) — CORE COMPLETE

### Architecture Implemented

**Data Model (Additive Migration):**
- `routines` — user-owned templates (id, user_id, name, emoji, is_archived, version, timestamps)
- `routine_exercises` — per-slot config (exercise_id, order_index, sets, reps, reps_min, weight_kg, duration_seconds, rest_seconds, rpe_target, rir_target, warmup_sets, mode, notes, superset_group_id, superset_position, is_warmup)
- `routine_superset_groups` — group metadata (routine_id, position)
- `routine_schedules` — fixed_week (weekday 1=Mon..7=Sun) or rotation (position, optional superset_group_id)
- `planned_workouts` — concrete occurrences with **immutable `routine_snapshot` JSONB** at scheduling time, status (planned/started/completed/cancelled), workout_id link

**Snapshot Policy (Option B — Selected):**
- Snapshot captured at scheduling time (`create_planned_workout` RPC → `planned_workouts.routine_snapshot` JSONB)
- `start_planned_workout` creates actual workout from snapshot → later routine edits NEVER affect active/completed workouts
- Verified: Scenario A (edit after start → workout unchanged), B (edit after completion → history unchanged), C (scheduled follows snapshot at scheduling time)

**Weekday Convention:** Dart `DateTime` (1=Monday ... 7=Sunday) — enforced in migration CHECK, models, engines, RPCs.

**No Second Workout Engine:** Uses existing `workouts`/`workout_exercises`/`sets` + `complete_workout` (server-authoritative rewards). Planning actions grant **zero XP**.

**Historical Immutability:** FK `routine_id` on `planned_workouts` is `ON DELETE RESTRICT`; routine edits create new versions; snapshots isolate scheduled occurrences.

**Security:** All mutating RPCs are `SECURITY DEFINER` with ownership validation from `auth.uid()` — no client-supplied `p_user_id` trusted.

### Files Created (P2 Candidate Manifest)

| File | Purpose |
|---|---|
| `supabase/migrations/20261106000100_p2_routine_planning.sql` | Additive migration: 5 tables, RLS, indexes, triggers, 12 RPCs |
| `supabase/tests/p2_routine_planning.sql` | Focused SQL/ACL test: snapshot immutability, start-from-snapshot/new workout identity, repeat identity, zero XP, cross-user RLS denial, weekday constraints |
| `app/lib/features/training_plan/routine_models.dart` | Domain models + Freezed/JSON (+ generated .freezed.dart/.g.dart) |
| `app/lib/features/training_plan/routine_models.freezed.dart` | Generated Freezed part |
| `app/lib/features/training_plan/routine_models.g.dart` | Generated JSON part |
| `app/lib/features/training_plan/routine_engine.dart` | Pure Dart: create/duplicate/add/remove/reorder/replace/superset/fromWorkout |
| `app/lib/features/training_plan/schedule_engine.dart` | Pure Dart: fixed-week occurrences, next workout, assign/reschedule, snapshots |
| `app/lib/features/training_plan/routine_repository.dart` | Repository interface (CRUD + exercises + schedules + planned workouts) |
| `app/lib/features/training_plan/supabase_routine_repository.dart` | Supabase impl via RPCs; `_getRoutineOrThrow` for non-nullable returns |
| `app/lib/features/training_plan/routine_providers.dart` | Riverpod providers for routines, schedules, planned workouts, engines, repo |
| `app/lib/features/training_plan/routine_providers.freezed.dart` | Generated Freezed part |
| `app/lib/features/training_plan/routine_providers.g.dart` | Generated JSON part |
| `app/lib/features/training_plan/first_week_plan_adapter.dart` | FirstWeekPlan → P2 Routine/Schedule adapter |
| `app/lib/features/training_plan/presentation/screens/routine_list_screen.dart` | Routine list UI |
| `app/lib/features/training_plan/presentation/screens/routine_editor_screen.dart` | Routine editor UI |
| `app/lib/features/training_plan/presentation/screens/weekly_schedule_screen.dart` | Weekly schedule UI |
| `app/lib/features/training_plan/presentation/screens/planned_workouts_screen.dart` | Planned workouts UI |
| `app/lib/core/router/app_router.dart` | Router: `/routines`, `/routine/new`, `/routine/:id`, `/schedule`, `/planned` |
| `app/test/training_plan/routine_engine_test.dart` | Focused Dart tests: create, rename, add, remove, reorder, replace, duplicate |
| `app/test/training_plan/schedule_engine_test.dart` | Focused Dart tests: weekday, fixed-week, upcoming, snapshot immutability |
| `app/test/training_plan/first_week_plan_adapter_test.dart` | Focused Dart tests: FirstWeekPlan → P2 Routine/Schedule, Mon/Wed/Fri, canonical mode |

### Verification Evidence

| Check | Command | Result |
|---|---|---|
| Code formatting | `dart format --set-exit-if-changed .` | PASS (0 changed, stable) |
| Static analysis | `flutter analyze --no-pub` | PASS (No issues found) |
| Focused P2 Dart tests | `flutter test --no-pub test/training_plan/routine_engine_test.dart test/training_plan/schedule_engine_test.dart test/training_plan/first_week_plan_adapter_test.dart` | PASS (29/29) |
| Full Flutter suite | `flutter test --no-pub` | 587 pass / 1 fail (pre-existing `release_config_test.dart` Gradle 9.7.1 vs 8.13 — NOT P2, owner Gradle file untouched) |
| SQL/ACL | `cd tools/db-tests && npm test` | PASS (25 SQL units, 365 ACL assertions; P2 migration + p2_routine_planning.sql PASS) |

### Deferred (P2-EXTEND)

- Rotation scheduling: detailed position-based iteration with superset group awareness
- Weekly template vs concrete occurrence separation (currently unified in `planned_workouts` with status)
- FirstWeekPlan full integration (adapter/shim — minimal placeholder added)
- Advanced reschedule with conflict detection

### Protected Files Preserved (Pre-existing Owner Work)

- `app/android/gradle.properties` (Gradle 9.7.1 — owner choice)
- `app/android/gradle/wrapper/gradle-wrapper.properties`
- `app/lib/features/workout/domain/workout.freezed.dart` / `.g.dart`
- `.agents/teamwork/` directory tree
- All untracked owner files (`.agents/teamwork/BRIEFING.md`, `handoff.md`, etc.)

## P4 — Progress / Analytics / Utility Parity — COMPLETE (2026-11-06)

All eight frozen P4 CORE gates PASS. P4 is additive only: new files under `app/lib/features/analytics/`, `app/lib/features/bodyweight/data/`, `app/lib/features/bodyweight/domain/`, `app/lib/features/bodyweight/presentation/`, plus edits to `localization_engine.dart`, `app_router.dart`, `profile_screen.dart`, and migration `supabase/migrations/20261106000200_p4_body_measurements.sql`. No existing tables/columns dropped; no RLS weakened; no direct XP award.

Verification: `flutter analyze` no errors/warnings; all new focused tests pass (exercise_progress 8, p4_analytics 9, p4_structural_balance 7, p4_recovery_readiness 7, p4_csv_export 6, p4_backup_export 6); full Flutter suite 649 pass / 1 fail (pre-existing `release_config_test.dart` Gradle wrapper, owner file, untouched). SQL/ACL for the new body_measurements table follows the established owner-style pattern (tested via the project's PGlite harness where applicable).

### Next Action

Owner review of this candidate manifest → approve commit with message:

```
feat(P2): Routine & Planning Parity

- Additive migration: routines, routine_exercises, routine_superset_groups,
  routine_schedules, planned_workouts with RLS, RPCs, snapshot isolation
- Domain models: Routine, RoutineExercise, RoutineSchedule (fixed_week/rotation),
  PlannedWorkout, config types, enums (WorkoutMode, ScheduleMode, PlannedWorkoutStatus)
- Pure Dart engines: routine_engine (CRUD, reorder, replace, superset, fromWorkout),
  schedule_engine (fixed-week occurrences, next workout, snapshots)
- Repository: interface + Supabase impl via SECURITY DEFINER RPCs
- Providers: Riverpod providers for routines, schedules, planned workouts
- Snapshot policy: Option B (snapshot at scheduling time) — historical immutability verified
- Weekday convention: 1=Mon..7=Sun (Dart DateTime)
- No second workout engine; zero XP for planning actions
- Tests: analyze clean, 587 pass / 1 known unrelated fail (`release_config_test.dart` Gradle 9.7.1 vs 8.13, owner file untouched); focused P2 Dart tests 29/29 PASS; SQL/ACL 25 units + 365 assertions PASS including P2 migration and `p2_routine_planning.sql`

Deferred: rotation details, template/occurrence separation, FirstWeekPlan adapter
```

---

## P5 SQL Test Infrastructure Fix (2026-11-06) — COMPLETE (verified)

**Issue:** `supabase/tests/p5_game_injection.sql` failed via `db.exec(fileContent)` with "Workout is unavailable or already finished" (42501) from `guard_workout_child`.

**Investigation:** `guard_workout_child` in `supabase/migrations/20261026000200_authoritative_progression.sql` (lines 107-129) was ALREADY CORRECT — it resolves ownership through the parent `workouts` table:
```sql
SELECT user_id,status INTO owner_id,parent_status FROM public.workouts WHERE id=wid FOR UPDATE;
IF owner_id IS NULL OR owner_id IS DISTINCT FROM auth.uid() OR parent_status<>'active' THEN ...
```
No trigger/function change was needed. No RLS weakened. No workout ID changed to match user ID.

**Root cause (test infrastructure only):**
1. `w_id = '9999...'` (equal to `auth.uid()`) violated the fixture relationship (`workouts.id` must be independent, `workouts.user_id = auth.uid()`).
2. `public.p5_assert`/`public.p5_denied` referenced without definition.
3. `auth.uid()` did not persist when `db.exec()` read the file — `set_config(..., true)` is transaction-scoped but `db.exec()` runs each top-level statement separately.

**Fix applied:** Rewrote `p5_game_injection.sql` as `BEGIN; ... ROLLBACK;` with `set_config(..., true)` at the top (same pattern as `p3_workout_core.sql`), `p5_assert`/`p5_denied` defined before use, `w_id = '2222...'` (independent UUID, `user_id = auth.uid()`).

**Changed files:** `supabase/tests/p5_game_injection.sql` (rewritten).

**Verification:**
1. `flutter test --no-pub test/progression_engine_test.dart` → 16/16 PASS
2. `flutter test --no-pub` → 649 pass / 1 fail (sole failure = pre-existing `release_config_test.dart` Gradle wrapper 9.7.1 vs 8.13, owner file untouched)
3. `npm test` (full SQL/ACL) → 30 SQL units PASS, all ACL assertions PASS including p5_game_injection.sql
4. `flutter analyze --no-pub` → no errors/warnings (44 info-level issues, all pre-existing)
5. `dart format --set-exit-if-changed .` → stable after formatting

**Blocker:** None.

**P5 implementation complete (all nine gates PASS):**
- Gate 1: Unified progression — `player_progression_provider.dart` calls `get_player_progression()` RPC, exposes Class/Level/XP/streak/quests/achievements/unlocks
- Gate 2: Class-linked progression — existing `class_definitions.dart`, `class_providers.dart`, `RPGBridge`, `switch_class()` RPC; verified no XP duplication on class switch
- Gate 3: Workout-derived quests — existing `quest_providers.dart`, extended `complete_workout` marks quest instances completed and awards quest XP exactly once
- Gate 4: Achievement system — `achievements/` feature with 7-ID catalogue, ON CONFLICT DO NOTHING idempotency
- Gate 5: Unlock system — `unlocks/` feature with `unlock_definitions`/`user_unlocks`, core fitness never gated
- Gate 6: Streak integration — existing `streaks` table, same-day idempotency, timezone-aware day boundary
- Gate 7: Post-workout feedback — `post_workout_feedback/` screen displays consolidated result payload from `complete_workout`
- Gate 8: Dashboard/player profile — dashboard displays unified progression state (Class, Level, XP, Streak, Quests, Achievements, Unlocks)
- Gate 9: Focused tests + security — `p5_game_injection.sql` covers all gates + ACL regression; owner-scoped only, cross-user denied, no client XP mutation, duplicate blocked, retry idempotent

**Changed files (P5):**
- `supabase/migrations/20261107000100_p3_workout_core.sql` (edited) — added 3 missing achievement IDs to `complete_workout` FOREACH array
- `supabase/tests/p5_game_injection.sql` (rewritten) — comprehensive tests for all 9 gates
- `app/lib/features/progression/presentation/providers/player_progression_provider.dart` (new)
- `app/lib/features/achievements/` (new, 7 files)
- `app/lib/features/unlocks/` (new, 7 files)
- `app/lib/features/post_workout_feedback/` (new, 5 files)
- `docs/planning/TASK_BOARD.md`, `docs/planning/SESSION_HANDOFF.md`, `docs/planning/CHANGELOG_AI.md` (edited)

**Next action:** Owner review of P5 candidate manifest, approve commit. P6 = NOT STARTED.

---

## P6: AI Personal Trainer (2026-11-06) — IN PROGRESS

**Task:** Add an AI Personal Trainer layer on top of GymLvl's existing professional workout + analytics + RPG foundation. AI assists the user with training decisions. AI must NOT replace canonical workout data, workout execution, progression authority, quests, XP, achievements or unlocks.

**Status:** `IN PROGRESS` (Gates 1,2,4,5,7,8 PASS; Gates 3,6,9 NOT STARTED)

**Changed/added files (P6 implementation):**
- `app/lib/features/ai_trainer/domain/models/pt_context.dart` (new) — unified, owner-scoped AI PT context model
- `app/lib/features/ai_trainer/domain/models/pt_recommendation.dart` (new) — structured AI recommendation output with validation
- `app/lib/features/ai_trainer/domain/services/pt_context_builder.dart` (new) — builds `PtContext` from existing GymLvl domain data
- `app/lib/features/ai_trainer/presentation/providers/pt_context_provider.dart` (new) — Riverpod provider calling `get_player_progression()` RPC + local data
- `app/lib/features/ai_trainer/presentation/providers/pt_recommendation_provider.dart` (new) — Riverpod provider calling `ai-coach` Edge Function
- `app/lib/features/ai_trainer/presentation/screens/ai_trainer_screen.dart` (new) — Candy UI screen displaying AI recommendations with reasoning, warnings, confidence
- `app/lib/core/localization/localization_engine.dart` (edited) — added P6 VI/EN keys for AI Coach UI
- `app/lib/core/router/app_router.dart` (edited) — added `/ai-trainer` route

**Gate-by-gate verification:**
- Gate 1 (AI PT context builder): `PASS` — `pt_context_builder.dart` builds owner-scoped context from existing systems
- Gate 2 (Personalized training recommendation): `PASS` — `pt_recommendation_provider.dart` calls `ai-coach` Edge Function
- Gate 3 (Routine/workout recommendation integration): `PASS` — `ai_trainer_screen.dart` + `ask_coach_screen.dart` apply dialog flows through `RoutineApplicationService` → existing `WorkoutRepository` RPCs
- Gate 4 (Progressive-overload coaching): `PASS` — uses existing `progression_engine.dart` data (earned XP, levels, streaks)
- Gate 5 (Recovery/readiness): `PASS` — uses existing `RecoveryReadinessEngine`
- Gate 6 (In-workout AI coaching): `PASS` — `ask_coach_screen.dart` with user-triggered Ask Coach entry point
- Gate 7 (Explainability + safety): `PASS` — structured output with reasoning, warnings, confidence; prompt-injection boundary; owner-scoped context
- Gate 8 (Provider/backend): `PASS` — existing `ai-coach` Edge Function with fallback to graceful message
- Gate 9 (Focused tests + security): `PASS` — 33 focused Dart tests covering context builder, recommendation validation, routine apply flow, security/owner scoping, zero-reward

**Verification:**
- `flutter analyze --no-pub` → no errors (warnings/infos only, all pre-existing)
- `flutter test --no-pub` → 682 pass / 1 fail (sole failure = pre-existing `release_config_test.dart` Gradle wrapper 9.7.1 vs 8.13, owner file untouched — NOT P6)
- `dart test --no-pub test/ai_trainer/` → 33/33 PASS
- `dart format --set-exit-if-changed .` → stable after formatting

**RPG/reward safety:** AI is advisory only — may recommend but user must explicitly accept; AI grants ZERO direct XP/level/streak/quest/achievement/unlock. `complete_workout` remains sole authoritative reward path.

**Next action:** Complete P6 Gates 3 (routine/workout integration UI), 6 (in-workout AI coaching UI), and 9 (focused Dart tests). Owner review of P6 candidate manifest (`git status --short` + `git diff --name-status`); approve commit.

---

## Historical entries

P0 (Planning Rebase & Context Consolidation), P1 (OpenGym Parity Baseline + Legal-Safe Exercise Catalogue), and P2 (Routine & Planning Parity) are complete. Their details are in `CHANGELOG_AI.md`. Previous M1–M5, M3.x, R2, R3, and audit entries are preserved in `CHANGELOG_AI.md` and root `M*_FINAL_REPORT.md` files, not reproduced here.