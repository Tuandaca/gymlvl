# GymLvl — M5 Final Report

**Milestone:** M5 — First-Week Plan, Analytics, Bodyweight & Newcomer Journey
**Status:** `PASS` for implementation and verification (local/test only)
**Branch/commit:** `main` @ `b6b0172871d7d18e9d9c27eca3f883d381f5b206`
**Date:** 2026-11-04
**Git delivery:** Deferred — candidate manifest recorded below, NOT staged, NOT committed, NOT pushed, NOT tagged, NOT deployed. Delivery occurs through a separate authorized `M5-FINAL` task.

---

## Scope resolved (authoritative sources)

- `MASTER_PLAN.md` §3: M5 = "Weekly plans/scheduling, analytics, bodyweight, novice journey", depends on M3, M4.
- `MASTER_PLAN.md` §5 exit gate: "Beginner completes three workouts from a generated plan; charts reconcile."
- `DECISIONS.md` D-044 `RECORDED`: bounded M5 scope (First-Week Plan, Newcomer Journey, Analytics, Bodyweight); local/test verification only; no new reward path; `complete_workout` remains sole PostgreSQL reward authority; no M6 AI work; no AGPL code/media; no third-party media.

M5 themes implemented:
1. **First-Week Plan** — deterministic `FirstWeekPlanEngine` (plain Dart, no freezed/codegen): exactly 3 days × 3 exercises for a beginner with no history, sorted by stable exercise ID, no random/clock, idempotent (retry-safe, no duplicate plan/workout at domain level), returning-user/non-beginner → empty plan (history never overwritten), invalid input throws descriptive `ArgumentError`. Bodyweight exercises mapped to `WorkoutMode.bodyweight` with `starterWeightKg` documented as external/added `weight_kg` load (never body mass); timed/cardio excluded.
2. **Newcomer Journey** — 7-state deterministic machine: `noHistory → planAvailable → planStarted → workoutPartial → workoutComplete → progressionAvailable → returningUser` (terminal). Resumable via `reconstruct(...)`, retry-safe `JourneyOutcome` flags (no duplicate completion/reward), invalid transitions throw `ArgumentError`.
3. **Analytics** — `AnalyticsEngine`: heatmap (workout frequency), weight trend (volume over time), PR chart (from authoritative `exercise_prs`, never recalculated), muscle balance (volume by category). Empty-state-safe, deterministic rounding to 2 dp, configurable timezone offset (default +7 Asia/Ho_Chi_Minh), time-window `[start, end)`, exercise-ID validation. Client-side estimates only; PostgreSQL authoritative; no client-side XP/reward writes.
4. **Bodyweight** — M3 contract confirmed: `workout_sets.weight_kg` is external/additional load only (never body mass), reps-based; body mass from `profiles.weight_kg` (authoritative onboarding source). Additive weigh-in-history table `public.bodyweight_measurements` (migration `20261105000200`, per-user RLS, index) for the bodyweight trend chart; `workout_sets.weight_kg` column untouched. Deterministic validator + trend computation tests.

UI (Candy Neubrutalism): newcomer journey `/plan`, analytics `/analytics`, bodyweight `/bodyweight` screens via GoRouter; VI/EN l10n keys; 320dp narrow width (no horizontal overflow); ≥48dp primary touch targets; Semantics labels; loading/error/empty states; no OpenGym UI styling.

Database (additive only): `20261105000100_m5_analytics_indexes.sql` (4 `CREATE INDEX IF NOT EXISTS`), `20261105000200_m5_bodyweight_measurements.sql` (`CREATE TABLE IF NOT EXISTS` + RLS + index + trigger; rollback documented). No tables/columns dropped/renamed/truncated; RLS not weakened. Migrations `NOT RUN` on any production/linked database (PGlite single-connection local/test only).

---

## Multi-agent sessions

| Agent | Role | Session | Status |
|---|---|---|---|
| Agent A | First-Week Plan / Newcomer Domain (flutter-specialist) | ses_e595e2664ffee37l9J8cGt3iKZ | `PASS` (25 tests: 11 plan + 14 journey) |
| Agent B | Analytics (analytics) | (delegated via tooling) | `PASS` (11 Flutter tests; SQL `m5_analytics.sql` PASS) |
| Agent C | Bodyweight (flutter-specialist) | ses_e594676b5ffe8l4x9fjcopryCv | `PASS` (15 tests) |
| Agent D | Flutter UX (flutter-specialist) | ses_e594676b3ffeMoBa16im0t0R38 | `PASS` (21 widget tests) |
| Agent E | Independent QA (qa-reviewer) | ses_e591eb8f8ffeJ8naaLcAQuLf6c | `PASS` (full suite +555 -1; SQL 22 units + 365 ACL PASS; no P0–P1) |

---

## Verification evidence

| Check | Command | Result |
|---|---|---|
| Focused M5 tests | `flutter test --no-pub test/newcomer_journey_test.dart test/first_week_plan_test.dart test/bodyweight_test.dart test/analytics/analytics_engine_test.dart test/newcomer_journey_screen_test.dart test/analytics_screen_test.dart test/bodyweight/bodyweight_validator_test.dart --reporter compact` | `+84: All tests passed!` (exit 0) |
| Additional M5 tests | `flutter test --no-pub test/bodyweight/bodyweight_measurement_test.dart test/bodyweight/bodyweight_trend_test.dart test/bodyweight/bodyweight_screen_test.dart test/training_plan/first_week_plan_test.dart --reporter compact` | `+31: All tests passed!` (exit 0) |
| Full Flutter suite | `flutter test --no-pub --reporter expanded` | `+555 -1`; sole failure `release_config_test.dart` (protected Gradle Wrapper 9.7.1 vs approved 8.13 — pre-existing owner-file exception, **not** an M5 regression) |
| Static analysis | `flutter analyze --no-pub` | `No issues found!` (exit 0) |
| Formatting | `dart format --output=none --set-exit-if-changed` on changed Dart files | 0 changed (exit 0) |
| SQL + ACL | `cd tools/db-tests; npm test` | `PASS 22 SQL verification units`; `PASS effective ACL regression: 10 isolated databases, 365 assertions`; M5 migrations/regressions PASS |
| `workout.g.dart` / `workout.freezed.dart` | `git diff --stat` | Line-ending only (LF/CRLF warning), **no functional change** |

M3/M4 compatibility: preserved — complete_workout sole reward path, progression/1RM/PR/RPE-RIR/RPG unaffected, workout_sets.weight_kg semantics unchanged, no client-side XP/reward writes, no RLS weakening.

---

## Exact M5 candidate Git manifest (DO NOT STAGE)

Modified tracked files (M5-owned):
- `app/lib/core/localization/localization_engine.dart` (M5 VI/EN keys)
- `app/lib/core/router/app_router.dart` (M5 routes `/plan`, `/analytics`, `/bodyweight`)
- `docs/planning/CHANGELOG_AI.md` (M5 entry)
- `docs/planning/DECISIONS.md` (D-044 bodyweight bullet reconciled)
- `docs/planning/SESSION_HANDOFF.md` (M5 current entry → PASS)
- `docs/planning/TASK_BOARD.md` (M5 section → COMPLETE + work log)

Modified tracked files (line-ending only, no functional change — preserved):
- `app/lib/features/workout/domain/workout.g.dart`
- `app/lib/features/workout/domain/workout.freezed.dart`

New untracked M5 files (41):
- `app/lib/features/analytics/domain/analytics_engine.dart`
- `app/lib/features/analytics/domain/analytics_models.dart`
- `app/lib/features/analytics/domain/analytics_models.freezed.dart`
- `app/lib/features/analytics/presentation/analytics_screen.dart`
- `app/lib/features/analytics/presentation/providers/analytics_providers.dart`
- `app/lib/features/analytics/presentation/widgets/heatmap_chart.dart`
- `app/lib/features/analytics/presentation/widgets/muscle_balance_chart.dart`
- `app/lib/features/analytics/presentation/widgets/pr_chart.dart`
- `app/lib/features/analytics/presentation/widgets/weight_trend_chart.dart`
- `app/lib/features/bodyweight/domain/bodyweight_measurement.dart`
- `app/lib/features/bodyweight/domain/bodyweight_measurement.freezed.dart`
- `app/lib/features/bodyweight/domain/bodyweight_measurement.g.dart`
- `app/lib/features/bodyweight/domain/bodyweight_trend.dart`
- `app/lib/features/bodyweight/domain/bodyweight_validator.dart`
- `app/lib/features/bodyweight/presentation/providers/bodyweight_providers.dart`
- `app/lib/features/bodyweight/presentation/screens/bodyweight_screen.dart`
- `app/lib/features/bodyweight/presentation/widgets/bodyweight_trend_chart.dart`
- `app/lib/features/training_plan/first_week_plan_engine.dart`
- `app/lib/features/training_plan/first_week_plan_models.dart`
- `app/lib/features/training_plan/newcomer_journey.dart`
- `app/lib/features/training_plan/newcomer_journey_models.dart`
- `app/lib/features/training_plan/presentation/newcomer_journey_screen.dart`
- `app/lib/features/training_plan/presentation/providers/training_plan_providers.dart`
- `app/lib/features/training_plan/presentation/screens/first_week_plan_screen.dart`
- `app/lib/features/training_plan/presentation/widgets/plan_day_card.dart`
- `app/test/analytics/analytics_engine_test.dart`
- `app/test/analytics/analytics_screen_test.dart`
- `app/test/analytics_screen_test.dart`
- `app/test/bodyweight/bodyweight_measurement_test.dart`
- `app/test/bodyweight/bodyweight_screen_test.dart`
- `app/test/bodyweight/bodyweight_trend_test.dart`
- `app/test/bodyweight/bodyweight_validator_test.dart`
- `app/test/bodyweight_test.dart`
- `app/test/first_week_plan_test.dart`
- `app/test/newcomer_journey_screen_test.dart`
- `app/test/newcomer_journey_test.dart`
- `app/test/training_plan/first_week_plan_test.dart`
- `supabase/migrations/20261105000100_m5_analytics_indexes.sql`
- `supabase/migrations/20261105000200_m5_bodyweight_measurements.sql`
- `supabase/tests/m5_analytics.sql`
- `supabase/tests/m5_bodyweight.sql`

Pre-existing untracked non-M5 files (NOT part of M5 manifest, preserved):
- `.agents/teamwork/BRIEFING.md`, `handoff.md`, `interviewer/`, `orchestrator/`
- `app/android/run_gradle.bat`, `gradle_check.ps1`, `run_gradle_check.bat`
- `docs/audit/phases/A8_BATCH_EXECUTION.md`
- `docs/planning/M3_1_DECISION_PROPOSAL.md`

Protected owner paths (NOT touched by M5, preserved):
- `app/android/gradle.properties`
- `app/android/gradle/wrapper/gradle-wrapper.properties`
- `app/android/run_gradle.bat`
- `gradle_check.ps1`
- `run_gradle_check.bat`
- `docs/audit/phases/A8_BATCH_EXECUTION.md`
- `docs/audit/phases/A8_Batch_EXECUTION.md`
- `.agents/teamwork/`

---

## Known deferred gates (not M5 defects)

- Production migration / live Supabase / linked database: `NOT RUN` (requires separate owner approval, O-07/O-06).
- Production deployment, commit, push, tag: deferred to `M5-FINAL` (requires explicit owner approval).
- True two-connection PostgreSQL concurrency for M5: not applicable (M5 is additive indexes + isolated table; no new concurrency contract).
- Full-suite `release_config_test.dart` Gradle-wrapper mismatch: pre-existing protected owner-file issue, not an M5 blocker.

---

## M6 readiness

M6 (AI PT v1) is NOT started. M5 does not implement AI intake/proposals/apply/revert/consent. M5 domain (plan engine, journey machine, analytics) is pure Dart and deterministic, providing a clean foundation for M6 without coupling to AI. No M6 scope was touched.

---

## Tree state (pre-delivery)

- Branch: `main`
- Local HEAD: `b6b0172871d7d18e9d9c27eca3f883d381f5b206`
- Working tree: dirty by pre-existing M3+M4 work + M5 new files (preserved); index empty.
- No commit, push, tag, deploy, or remote migration occurred in this session.
