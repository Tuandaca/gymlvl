# GymLvl — Session Handoff

## NEW SESSION START HERE

| Field | Value |
|---|---|
| Date | 2026-11-06 |
| Branch | `main` |
| HEAD | `9b822b62d4e211bb2bd723aa34923231c7c52f73` (P4 baseline; origin/main == local main) |
| Remote | `origin/main` == local `main` |
| Working-tree state | Dirty — **P2 + P3 + M3/M4/M5 changes (implementation + focused tests + SQL test)** + pre-existing owner work preserved (modified tracked files + untracked owner files) + **P4 additions (new files + edits to non-dirty files)**; **do not discard, reset, or overwrite** |
| Product | GymLvl — mobile-first fitness RPG (Flutter + Riverpod + GoRouter + Supabase/PostgreSQL + Edge Functions), Candy Neubrutalism UI, VI/EN |
| Current architecture | Existing GymLvl Flutter/Supabase architecture preserved; OpenGym is behavioral reference only (AGPL, no code reuse) |
| Completed foundation | M1–M5 foundation complete. P1 complete (parity matrix, legal-safe exercisedb import pipeline, provenance migration). P2 complete (Routine & Planning Parity). P3 complete (Workout Core Parity). **P4 complete — all eight frozen CORE gates PASS.** |
| Current roadmap phase | **P4 — Progress / Analytics / Utility Parity: COMPLETE.** P5 — Deep GymLvl Game Integration: NEXT / NOT STARTED (do not start P5). |
| Next implementation phase | P5 — NOT STARTED. |
| OpenGym pin | `DuarteSantos8/openGym` @ `e6a95c28a6e3067bdd9b1188d5f37f448d528bd2` (AGPL, reference only) |
| Exercise dataset pin | `hasaneyldrm/exercises-dataset` @ `7455efae41b330c265e7cd4b78dfa848e7ce5ebd` (MIT text/data, media excluded). **Import source: direct from pinned MIT dataset (`data/exercises.json`), NOT from OpenGym catalogue.** Verified 1,324 records. |
| Legal restrictions | No AGPL code/prompts/catalogue-text/assets; no third-party media; MIT text only with notice; media excluded |
| Production restrictions | Do NOT deploy production migrations; do NOT run `supabase db push`; onboarding 9/9 blocked on production DB access; no release hardening |
| Immediate next task | Owner review of P4 candidate manifest (`git status --short` + `git diff --name-status`); approve commit. P5 NOT STARTED. |
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

## Historical entries

P0 (Planning Rebase & Context Consolidation), P1 (OpenGym Parity Baseline + Legal-Safe Exercise Catalogue), and P2 (Routine & Planning Parity) are complete. Their details are in `CHANGELOG_AI.md`. Previous M1–M5, M3.x, R2, R3, and audit entries are preserved in `CHANGELOG_AI.md` and root `M*_FINAL_REPORT.md` files, not reproduced here.