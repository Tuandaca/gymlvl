# GymLvl — Task Board

## Current phase — P2: Routine & Planning Parity (2026-11-06)

**Task:** Implement routine management, weekly planning, exercise scheduling, and integration with existing workout system, following OpenGym parity reference.

**Status:** `COMPLETE` (P2 implementation complete; Gate 2 focused automated tests added and passing; all analyzer errors fixed; full Flutter suite passes except pre-existing unrelated `release_config_test.dart` Gradle mismatch)

**Commit:** `main` @ `8f59d96` (P1 base); P2 changes in working tree (uncommitted, awaiting owner approval)

**Deliverables — COMPLETE:**
1. **Additive migration:** `supabase/migrations/20261106000100_p2_routine_planning.sql` — creates `routines`, `routine_exercises`, `routine_superset_groups`, `routine_schedules`, `planned_workouts` with RLS policies, indexes, triggers, and 12 RPC functions (create/duplicate/replace/reorder/schedule/start/complete/repeat). Preserves all existing data; no DROP/RENAME/TRUNCATE.
2. **Domain models:** `app/lib/features/training_plan/routine_models.dart` (+ `.freezed.dart`/`.g.dart`) — `Routine`, `RoutineExercise`, `RoutineSupersetGroup`, `RoutineSchedule` (fixed_week/rotation), `PlannedWorkout`, config types (`RoutineExerciseConfig`, `ScheduleRoutineConfig`, `CreatePlannedWorkoutConfig`, `ReplaceExerciseConfig`, `DuplicateRoutineConfig`, `RepeatWorkoutConfig`, `DateRange`), enums (`WorkoutMode`, `ScheduleMode`, `PlannedWorkoutStatus`). Uses canonical `WorkoutMode` from `workout_mode_contract.dart`.
3. **Pure Dart engines:** `routine_engine.dart` (create, duplicate, add/remove/reorder/replace exercises, superset groups, from workout session) and `schedule_engine.dart` (fixed-week occurrences, next workout, assign/reschedule, snapshot builder).
4. **Repository interface:** `routine_repository.dart` — full CRUD + exercise management + scheduling + planned workout operations.
5. **Supabase implementation:** `supabase_routine_repository.dart` — all operations via SECURITY DEFINER RPCs with ownership validation from `auth.uid()`; `_getRoutineOrThrow` for non-nullable returns.
6. **Riverpod providers:** `routine_providers.dart` — `routinesProvider`, `routineProvider`, `routineSchedulesProvider`, `plannedWorkoutsProvider`, `nextPlannedWorkoutProvider`, `upcomingPlannedWorkoutsProvider`, engine/repo providers.
7. **Snapshot isolation (Option B):** Immutable routine snapshot stored in `planned_workouts.routine_snapshot` at scheduling time; `start_planned_workout` creates workout from snapshot — later routine edits never affect active/completed workouts.
8. **Weekday convention:** Dart `DateTime` convention (1=Monday ... 7=Sunday) used throughout migration, models, engines, and RPCs.
9. **Historical immutability verified:** Scenario A (edit after start), B (edit after completion), C (scheduled occurrence follows snapshot policy) — all enforced by DB design.
10. **No second workout engine:** Uses existing `workouts`/`workout_exercises`/`sets` + `complete_workout` RPC for rewards. Planning actions grant **zero XP**.
11. **UI Screens:** Routine list, editor, weekly schedule, planned workouts — all using `translateText` localization and Candy components (AppBar, CandyButton variants: secondary/danger, isFullWidth, CandyDialog API).
12. **FirstWeekPlan Adapter:** `first_week_plan_adapter.dart` — converts M5 FirstWeekPlan to P2 Routine/Schedule representation.
13. **Routing:** GoRouter integration for `/routines`, `/routine/new`, `/routine/:id`, `/schedule`, `/planned`.
14. **Tests:** Focused P2 automated tests added:
      - `app/test/training_plan/routine_engine_test.dart` — create, rename, add, remove, reorder, replace (compatible config preserved / incompatible mode config reset), duplicate independence
      - `app/test/training_plan/schedule_engine_test.dart` — weekday convention (1=Mon..7=Sun), fixed-week assignment, upcoming workout, reschedule, snapshot immutability (edit after schedule), independent snapshots across occurrences
      - `app/test/training_plan/first_week_plan_adapter_test.dart` — existing FirstWeekPlan → P2 Routine + Schedule, exercise order preserved, Mon/Wed/Fri ([1,3,5]) mapping, canonical WorkoutMode, unique IDs
      - `supabase/tests/p2_routine_planning.sql` — create/schedule/snapshot/start/repeat/zero-XP/cross-user RLS/weekday constraints/duplicate occurrence
    `flutter analyze --no-pub` = `No issues found!`. `dart format --set-exit-if-changed .` = stable (0 changed).
    `flutter test --no-pub` = 587 pass / 1 fail (pre-existing `release_config_test.dart` Gradle 9.7.1 vs 8.13, NOT P2, owner Gradle files untouched).
    `cd tools/db-tests && npm test` = 25 SQL units PASS, 365 ACL assertions PASS, including `migration 20261106000100_p2_routine_planning.sql` PASS and `SQL regression p2_routine_planning.sql` PASS.

**Blockers:** None for P2 core.

**Deferred (P2-EXTEND):** Rotation scheduling details, advanced week template vs occurrence separation, FirstWeekPlan full integration (adapter pattern — minimal shim added).

**Do NOT do:** Production migration/deployment; commit/push without owner approval; modify protected Gradle files; overwrite pre-existing M3/M4 owner work.

**Next action:** Owner review of P2 candidate manifest (`git status --short` + `git diff --name-status`); approve commit. P3 — Workout Core Parity is NOT STARTED.

---

## Current product blocker — Onboarding 9/9 submit failure (2026-11-04) — BLOCKED

**Status:** `BLOCKED` — production schema/runtime mismatch; requires explicit owner approval to verify/deploy. Not the current task. Do not deploy migrations.

**Root cause:** Production onboarding 9/9 is blocked by a production schema/runtime mismatch. Read-only inspection showed that expected initialization capability such as `initialize_user` and `profiles.timezone` was absent. The exact unapplied migration set has not yet been established.

**Call chain:** `onboarding_screen.dart:42` → `onboarding_controller.dart:54-101` → `SupabaseClient.rpc('initialize_user', ...)` → PostgREST → PostgreSQL `public.initialize_user(p_profile jsonb)` → INSERT `public.profiles`, `public.user_classes`; UPDATE `public.users`; INSERT `public.streaks`.

**Local verification:** PGlite + all 10 migrations → `initialize_user` PASS (onboarding completes, `onboarding_completed=true`, idempotent retry returns "Onboarding already complete").

**Production verification:** `NOT RUN` — no production Supabase access. Cannot confirm exact production error code.

**Files changed:** None (read-only investigation).

**Blockers:** No production Supabase access; `supabase db push`/remote migration requires explicit owner approval per AGENTS.md §0.3/§8.

**Next action:** Owner to verify production database schema (`public.initialize_user` function, `public.profiles.timezone` column, `public.users` rows) and approve migration deployment if missing.

---

## Do not do (constraints)

- Do not start P3+ automatically.
- AI PT is not the immediate next implementation stage (P6).
- No production deployment, database migration, or remote Supabase changes.
- No third-party exercise media.
- Do not commit/push without explicit owner approval.
- Do not overwrite pre-existing M3/M4 owner work (6 modified tracked files, 10 untracked files preserved).