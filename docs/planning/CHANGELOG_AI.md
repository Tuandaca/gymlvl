# GymLvl — AI Changelog

Dated record of agent sessions and project checkpoints. Newest first.

## 2026-11-06 — P3: Workout Core Parity (COMPLETE — all ten frozen gates PASS)

**Task:** Improve the active workout experience using useful OpenGym behavior while preserving GymLvl's existing workout engine, offline architecture, progression and RPG reward authority.

**Status:** `COMPLETE` (all ten frozen P3 CORE gates PASS)

**Changed/added sources:**
- `app/lib/features/workout/domain/workout_set.dart` + `.freezed.dart` + `.g.dart` — `WorkoutSetType` (`workout`/`warmup`) + `setType` field (default `workout`); `isWarmup` getter; backward compatible (legacy NULL → `workout`).
- `app/lib/features/workout/domain/plate_calculator.dart` (new) — pure Dart deterministic plate calculator with validation; no service, no state mutation.
- `app/lib/features/workout/presentation/controllers/active_workout_controller.dart` — `replaceExercise(...)` (preserves identity/position/superset; refuses if old exercise has completed sets), `updateWorkoutNotes(...)`, `updateSet(...)` accepts `setType`.
- `app/lib/features/workout/data/supabase_workout_repository.dart` — `replaceExercise(...)`, `updateWorkoutNotes(...)`, `updateSet` persists `set_type`.
- `app/lib/features/workout/presentation/widgets/{set_row_widget,workout_exercise_tile,previous_performance_hint}.dart` — warm-up chip, replace action, previous-performance hint UI.
- `app/lib/features/workout/presentation/screens/active_workout_screen.dart` — replace-exercise picker flow, edit-notes dialog.
- `app/lib/features/progression/domain/progression_engine.dart` — `calculateXP` excludes warm-up sets.
- `app/test/plate_calculator_test.dart` (new, 11 tests), `app/test/p3_workout_core_test.dart` (new, 8 tests) — focused tests.
- `supabase/migrations/20261107000100_p3_workout_core.sql` (new) — additive `workout_sets.set_type` (text, DEFAULT 'workout', CHECK workout/warmup, legacy backfill); `complete_workout` excludes warm-up sets from completed-set count, base XP, PR (`exercise_prs`), quest targets. Production NOT applied.
- `supabase/tests/p3_workout_core.sql` (new) — verifies set_type column/constraint/default/warm-up insert.
- `docs/planning/OPENGYM_PARITY_MATRIX.md` — P3 rows truthfully updated (Warmups, Exercise swap, Ordering, Previous-performance hints, Session editing, Plate calculator).
- `docs/planning/DECISIONS.md` — D-044 recorded.

**Verification:** `flutter analyze` → `No issues found!`; `dart format --set-exit-if-changed .` → stable (0 changed); focused P3 Dart tests pass (plate calculator 11/11, p3_workout_core 8/8); full Flutter suite passes except pre-existing unrelated `release_config_test.dart` (owner Gradle file untouched); `cd tools/db-tests && npm test` → all SQL/ACL units pass including p3 migration and `p3_workout_core.sql`.

**Schema (additive only, production NOT applied):** `workout_sets.set_type` column + CHECK constraint + legacy backfill; `complete_workout` updated to exclude warm-up sets from PR/XP/quests. No existing tables/columns dropped or renamed; no RLS/grants weakened; no production migration deployed.

**No second workout engine:** all P3 behavior extends the existing active-workout flow; `complete_workout` remains sole authoritative reward path; warm-up sets award no XP/PR/quests; no direct XP award from editing/reorder/replace/notes/plate calculator.

**P4:** NOT STARTED.

**Pre-existing owner files preserved:** `app/android/gradle.properties`, `app/android/gradle/wrapper/gradle-wrapper.properties`, `app/lib/features/workout/domain/workout.freezed.dart`/`.g.dart`, `.agents/teamwork/` tree, all untracked owner files — untouched.

**No commit/push** without owner approval.

---

## 2026-11-06 — P2 Routine & Planning Parity (COMPLETE — Gate 2 closed)

- **Task:** Close the only remaining frozen P2 gate — Gate 2 focused automated P2 tests — by adding the minimum focused test suite, fixing only real bugs those tests expose, running full verification, updating canonical status, and returning an exact Git-derived commit candidate.
- **Focused P2 test files added:**
  - `app/test/training_plan/routine_engine_test.dart` — create, rename, add, remove, reorder, replace (compatible config preserved / incompatible mode-specific config reset), duplicate independence
  - `app/test/training_plan/schedule_engine_test.dart` — weekday convention (1=Mon..7=Sun), fixed-week assignment, upcoming workout, reschedule, snapshot immutability (existing occurrence unchanged after routine edit), independent snapshots across occurrences
  - `app/test/training_plan/first_week_plan_adapter_test.dart` — existing FirstWeekPlan → P2 Routine + Schedule, exercise order preserved, Mon/Wed/Fri ([1,3,5]) mapping, canonical WorkoutMode, unique IDs
  - `supabase/tests/p2_routine_planning.sql` — create/schedule/snapshot immutability/start-from-snapshot/new workout identity/repeat identity/zero-XP/cross-user RLS denial/weekday constraints/duplicate-occurrence constraint
- **Migration fix:** removed duplicate `rest_seconds` column in `routine_exercises`; added `updated_at` + modtime triggers on `routine_superset_groups` and `planned_workouts`; fixed `get_next_planned_workout` to return a single record (was `RETURN QUERY` in a non-SETOF function).
- **Real bug fixed:** `get_next_planned_workout` used `RETURN QUERY` in a function declared `RETURNS public.planned_workouts` (non-SETOF), causing migration load failure `42804`; fixed by `SELECT ... INTO v_planned` then `RETURN v_planned`.
- **Verification:** Focused P2 Dart tests 29/29 PASS; `dart format --set-exit-if-changed .` stable (0 changed); `flutter analyze --no-pub` → `No issues found!`; `flutter test --no-pub` → 587 pass / 1 fail (pre-existing unrelated `release_config_test.dart` Gradle 9.7.1 vs 8.13, owner Gradle file untouched); `cd tools/db-tests && npm test` → 25 SQL units PASS, 365 ACL assertions PASS, including P2 migration and `p2_routine_planning.sql` PASS.
- **Snapshot isolation (Option B):** confirmed — immutable routine snapshot captured at scheduling time; `start_planned_workout` builds workout from snapshot; later routine edits never rewrite existing occurrences.
- **Weekday convention:** Dart `DateTime` (1=Monday ... 7=Sunday) enforced in migration CHECK, models, engines, RPCs.
- **No second workout engine:** `complete_workout` remains sole authoritative award path; planning actions grant zero XP.
- **P2 = COMPLETE; P3 = NEXT / NOT STARTED.** No additional P2 acceptance gates.
- **Protected files preserved:** owner Gradle files (`gradle.properties`, `gradle-wrapper.properties`), `workout.freezed.dart`/`.g.dart`, `.agents/teamwork/` tree, all untracked owner files — untouched.
- **No production migration/deployment. No commit/push without owner approval.**

## 2026-11-05 — P1 OpenGym Parity Baseline + Legal-Safe Exercise Catalogue (COMPLETE)

- **Task:** Build a detailed OpenGym → GymLvl feature parity baseline AND implement the legal-safe exercise catalogue foundation using the pinned MIT dataset (1,324 ExerciseDB records from `hasaneyldrm/exercises-dataset` @ `7455efae41b330c265e7cd4b78dfa848e7ce5ebd`).
- **Parity matrix:** `docs/planning/OPENGYM_PARITY_MATRIX.md` fully populated — Catalogue, Routine/Planning, Workout, Progression, Utilities, Analytics, Device/Platform, Account/Security, Coach/AI, Other capability families classified (EXISTING/PARTIAL/MISSING/DEFERRED/EXCLUDED_LICENSE/NOT_APPLICABLE) and mapped to P2–P7.
- **Import pipeline:** `tools/catalogue-import/{package.json,import.mjs,import.test.mjs}` — reads **directly from the pinned MIT dataset** (`hasaneyldrm/exercises-dataset` @ `7455efae41b330c265e7cd4b78dfa848e7ce5ebd`, `data/exercises.json`), NOT from OpenGym catalogue. Selects all 1,324 MIT records, strips all media fields, maps to GymLvl schema with provenance (source/external_id/source_revision), unique slugs with duplicate disambiguation, generates idempotent `INSERT ... ON CONFLICT (source, external_id) DO NOTHING` SQL. 11/11 pipeline tests PASS.
- **Migration:** `supabase/migrations/20261105000300_p1_exercise_provenance.sql` — additive: `source`/`external_id`/`source_revision` columns, `UNIQUE (source, external_id)`, backfills 150 curated rows as `gymlvl_curated`. Verified on PGlite: `PASS migration 20261105000300_p1_exercise_provenance.sql`, 23/23 SQL units + 365 ACL assertions PASS, RLS not weakened, existing data preserved.
- **Flutter model:** `app/lib/features/workout/domain/exercise.dart` (+ `.freezed.dart`/`.g.dart` regenerated) — provenance fields `source`/`externalId`/`sourceRevision`. `app/test/exercise_detail_test.dart` — 3 new provenance round-trip tests (14/14 PASS).
- **Verification:** `flutter analyze --no-pub` → `No issues found!`; `dart format` clean; full Flutter suite 558 pass / 1 fail (sole failure = pre-existing protected `release_config_test.dart` Gradle 9.7.1 vs 8.13, NOT a P1 regression).
- **No MCP changes. No production database changes. No migration deployed. No commit/push of credentials.**
- **Next action:** Owner review of P1 deliverables; then P2 — Routine & Planning Parity.

## 2026-11-05 — P0 Planning Rebase & Context Consolidation (COMPLETE)

- **Task:** Reconcile accumulated planning documents against the actual repository and rewrite the canonical planning/control layer so a new OpenCode session can understand the project without relying on chat history. No product implementation.
- **Roadmap:** Rebased active roadmap from legacy M0–M9 to P0–P8. P1 (OpenGym Parity Baseline + Legal-Safe Exercise Catalogue) is the next implementation phase. Old M6/AI PT is NOT the immediate next stage.
- **Files rewritten:**
  - `docs/planning/MASTER_PLAN.md` — P0–P8 roadmap, product destination, non-negotiable decisions, corrections register
  - `docs/planning/PROJECT_CONTEXT.md` — current truth (`planning_rebase_base_head` `da21eb7` at P0 audit, mutable; M3 offline store exists, 10 migrations, production restrictions)
  - `docs/planning/TASK_BOARD.md` — current execution state only; Onboarding 9/9 BLOCKED; P1 NOT STARTED
  - `docs/planning/SESSION_HANDOFF.md` — NEW SESSION START HERE block; historical entries trimmed to CHANGELOG/reports
  - `docs/planning/CHANGELOG_AI.md` — this entry
  - `docs/planning/DECISIONS.md` — P0/P1 decisions added; legacy milestone decisions marked SUPERSEDED
  - `docs/planning/UPSTREAM_SOURCE_MANIFEST.json` — `planning_rebase_base_head` recorded as `da21eb7` at P0 audit (mutable)
- **Files created:**
  - `docs/planning/OPENGYM_PARITY_MATRIX.md` — empty/initial tracking framework for P1 (no detailed parity audit yet)
- **Verification:** All canonical Markdown links valid; JSON manifest valid; no canonical document contradicts another; no active document says old M6 AI is the next task; P1 consistently identified as next implementation phase; historical reports remain accessible; no source/application behavior changed; no migrations changed; no dependency changed.
- **No MCP changes. No database changes. No migration. No commit/push of credentials.**
- **Next action:** Owner review of P0 deliverables; then P1.

## 2026-11-05 — Flutter runtime configuration resolved; app launches into MainApp on Chrome

- **Task:** Resolve `SupabaseConfig.isConfigured == false` causing `ConfigurationApp` to display instead of `MainApp`.
- **Root cause:** `app/config.local.json` existed but `SUPABASE_PUBLISHABLE_KEY` was still the placeholder value `"REPLACE_WITH_YOUR_PUBLISHABLE_OR_ANON_KEY"`. `SupabaseConfig.isPublicClientKey()` returned `false` (key does not start with `sb_publishable_` and is not a valid anon JWT), so `isConfigured` evaluated to `false` and `main.dart` ran `ConfigurationApp`.
- **Files changed:**
  - `app/config.local.json` — updated `SUPABASE_URL` to `https://shulhhxdebsfbsxcborq.supabase.co` and `SUPABASE_PUBLISHABLE_KEY` to `sb_publishable_zgemxQoj9adnol-7qTIRfQ_wiqC9QR-` (public client values only; no secret/service_role). File already listed in `app/.gitignore` line 51.
  - `app/.vscode/launch.json` — created launch configuration `GymLvl Chrome (config.local.json)` with `--web-port 8080 --dart-define-from-file=config.local.json` so future runs do not forget the flag.
- **Command run:** `flutter run -d chrome --web-port 8080 --dart-define-from-file=config.local.json` from `app/`.
- **Verification:**
  - `SupabaseConfig.isConfigured`: `PASS` (app proceeded past the configuration check).
  - `Supabase.initialize()`: `PASS` — log `supabase.supabase_flutter: INFO: ***** Supabase init completed *****`.
  - `ConfigurationApp`: did not appear.
  - `MainApp`: `PASS` — app launched successfully on Chrome (web-port 8080).
- **No MCP changes. No database changes. No migration. No commit/push of credentials.**
- **Next action:** None for this task. Onboarding 9/9 investigation remains BLOCKED on production DB access.

## 2026-11-04 — Onboarding 9/9 submit failure investigation (BLOCKED — production DB state)

- **Task:** Investigate and fix `initialize_user` RPC failure when user completes onboarding step 9/9. UI shows `Không thể hoàn tất yêu cầu. Vui lòng thử lại.`
- **Call chain:** UI `onboarding_screen.dart:42` → Controller `onboarding_controller.dart:54-101` → `SupabaseClient.rpc('initialize_user', params: {'p_profile': {...}})` → PostgREST `POST /rest/v1/rpc/initialize_user` → PostgreSQL function `public.initialize_user(p_profile jsonb)` → INSERT `public.profiles`, `public.user_classes`; UPDATE `public.users`; INSERT `public.streaks`.
- **Local reproduction (PGlite + all 10 migrations):** `PASS`. `initialize_user` completes onboarding, sets `onboarding_completed=true`, inserts profile/class/streak rows. Idempotent retry returns "Onboarding already complete" with no duplicate data. Code (Dart + SQL) is correct when database is fully migrated.
- **Root cause:** Production onboarding 9/9 is blocked by a production schema/runtime mismatch. Read-only inspection showed that expected initialization capability such as `initialize_user` and `profiles.timezone` was absent. The exact unapplied migration set has not yet been established.
- **Files changed:** None (read-only investigation; no code fix possible at application layer — root cause is database state).
- **DB/RLS changes:** None applied. This is a known production-environment blocker, not the current implementation task. The owner is currently testing UI. Do not deploy migrations or run `supabase db push` unless explicitly requested later.
- **Verification:** Local PGlite test `PASS`. Production runtime verification `NOT RUN` (no production database access).
- **Blocker:** No production Supabase access; `supabase db push`/remote migration requires explicit owner approval. Cannot confirm exact production error code without database access.
- **Next action:** Owner to verify production database schema (especially `public.initialize_user` function, `public.profiles.timezone` column, `public.users` rows) and approve migration deployment if missing.

## 2026-11-04 — M5 complete: First-Week Plan, Analytics, Bodyweight & Newcomer Journey — local/test only (orchestrator summary)

- **Status:** `PASS` for M5 (Agent E independent QA `PASS`; no P0–P1 findings). Branch `main` @ `b6b0172871d7d18e9d9c27eca3f883d381f5b206`. D-044 `RECORDED`. M5 is local/test verification only. No commit, push, tag, deploy, remote migration, or production write. Git delivery deferred to a separate `M5-FINAL` task; exact candidate manifest in `M5_FINAL_REPORT.md`.
- **Scope (per `MASTER_PLAN.md` §3/§5 exit gate "Beginner completes three workouts from a generated plan; charts reconcile" and D-044):** First-Week Plan (deterministic 3-day × 3-exercise beginner plan), Newcomer Journey (7-state retry-safe machine), Analytics (heatmap/volume-trend/PR-chart/muscle-balance; client estimates only, PostgreSQL authoritative), Bodyweight (M3 contract: `workout_sets.weight_kg` = external/added load never body mass; additive weigh-in-history table; `profiles.weight_kg` authoritative body mass). No M6, no OpenGym UI styling, no AGPL code/media, no third-party media.
- **Verification:** `flutter analyze --no-pub` → `No issues found!`; full Flutter suite `+555 -1` (sole failure = pre-existing protected `release_config_test.dart` Gradle 9.7.1 vs approved 8.13, not an M5 regression); 115 focused M5 tests PASS; `cd tools/db-tests; npm test` → 22 SQL units + 365 ACL assertions PASS; M5 migrations/regressions PASS; `dart format` clean on changed Dart files. Protected owner paths untouched. No SQL migration run on production/linked database.
- **Records updated:** `TASK_BOARD.md` (M5 section + complete), `SESSION_HANDOFF.md` (M5 current entry), `DECISIONS.md` (D-044 bodyweight bullet reconciled).

## 2026-11-04 — M5 Agent D: Flutter UX implementation (providers, first-week plan, chart widgets, bodyweight screen)

- **Authority/status:** Agent D implemented the M5 Flutter presentation layer on top of Agent A/B/C domain models. Pure Dart providers (Riverpod 3), Candy Neubrutalism UI, VI/EN, 320dp narrow layout, ≥48dp touch targets, Semantics, GoRouter integration. `complete_workout` remains sole PostgreSQL reward authority; client never persists progression or calls the server. No new dependencies (`fl_chart` already declared). Working tree dirty by pre-existing M3+M4 work (preserved); new files uncommitted.
- **Files added:** `lib/features/training_plan/presentation/providers/training_plan_providers.dart`, `lib/features/training_plan/presentation/screens/first_week_plan_screen.dart`, `lib/features/training_plan/presentation/widgets/plan_day_card.dart`; `lib/features/analytics/presentation/providers/analytics_providers.dart`, `lib/features/analytics/presentation/widgets/{heatmap_chart,weight_trend_chart,pr_chart,muscle_balance_chart}.dart`; `lib/features/bodyweight/presentation/providers/bodyweight_providers.dart`, `lib/features/bodyweight/presentation/screens/bodyweight_screen.dart`, `lib/features/bodyweight/presentation/widgets/bodyweight_trend_chart.dart`; `test/training_plan/first_week_plan_test.dart`, `test/analytics/analytics_screen_test.dart`, `test/bodyweight/bodyweight_screen_test.dart`.
- **Files modified:** `lib/features/analytics/presentation/analytics_screen.dart` (extracted inline charts into the four widget widgets, wired to `analyticsProvider`); `lib/core/localization/localization_engine.dart` (added bodyweight VI/EN keys only); `lib/core/router/app_router.dart` (added `/bodyweight` route; `/plan` + `/analytics` routes pre-existing).
- **Verification:** `flutter test --no-pub test/training_plan/ test/analytics/ test/bodyweight/ --reporter compact` → `+66: All tests passed!` PASS; baseline widget tests (`test/newcomer_journey_screen_test.dart` 9, `test/analytics_screen_test.dart` 6) → PASS; `flutter analyze --no-pub` → `No issues found!` PASS; `dart format --set-exit-if-changed` → 0 changed PASS.
- **Next action:** Agent D done; handoff to orchestrator. Awaiting Agent E (Independent QA) review or owner approval.

## 2026-11-04 — M5 Agent D: Flutter UX (newcomer journey + analytics presentation)

- **Authority/status:** Agent D implemented M5 Flutter presentation: newcomer journey screen (`/plan`) and analytics screen (`/analytics`), Candy Neubrutalism UI, VI/EN, 320dp narrow layout, ≥48dp touch targets, Semantics, GoRouter integration. Widget-testable with mocked domain data; no server calls in UI; no AGPL styling/media; no redesign of existing app. `complete_workout` remains sole PostgreSQL reward authority; client never persists progression. No new dependencies (`fl_chart` already declared). Working tree dirty by pre-existing M3+M4 work (preserved); new files uncommitted.
- **Implementation (Agent D — presentation):**
  - `app/lib/features/training_plan/presentation/newcomer_journey_screen.dart` (new) — `ConsumerWidget` showing the journey state (`noHistory`/`planAvailable`/`planStarted`/`workoutPartial`/`workoutComplete`/`progressionAvailable`/`returningUser`) and, when a `FirstWeekPlan` exists, the 3 days x 3 exercises as Candy cards (name, category, mode, sets x reps, starter weight). Bodyweight exercises render `starterWeightKg` as added load ("Tạ thêm / Added load") — never body mass — plus a static bodyweight-reference note (VI/EN). Loading/error/empty states modeled; retry-safe start/continue gated behind `JourneyOutcome.workoutCreated`; side effects delegated to caller callbacks. Semantics labels; ≥48dp primary buttons; 320dp-compatible.
  - `app/lib/features/analytics/presentation/analytics_screen.dart` (new) — `ConsumerWidget` showing `AnalyticsResult` metrics: heatmap grid, volume trend (`LineChart`), PR chart (`BarChart`), muscle balance (`CandyStatTile`). Empty state ("no data recorded") when all lists empty. VI/EN, 320dp, Semantics. Uses `fl_chart` (already a dependency); no new dependencies.
  - `app/lib/core/router/app_router.dart` (modified) — added `GoRoute('/plan')` → `NewcomerJourneyScreen` and `GoRoute('/analytics')` → `AnalyticsScreen`; existing routes unchanged.
  - `app/lib/core/localization/localization_engine.dart` (modified) — added M5 VI/EN keys only: plan title, day labels, added load, bodyweight note, journey states, analytics titles, empty/no-data, retry, start/continue, mode labels, sets, workouts.
- **Tests:**
  - `app/test/newcomer_journey_screen_test.dart` (new) — 9 tests: VI rendering of 3 days x 3 exercises, bodyweight added-load + note, start/continue gated by journey outcome, ≥48dp touch targets, semantics label, empty/error/loading states, 320dp narrow width.
  - `app/test/analytics_screen_test.dart` (new) — 6 tests: four sections in VI, heatmap counts, empty state, error+retry, loading, 320dp narrow width.
- **Verification:** `flutter test --no-pub test/newcomer_journey_screen_test.dart test/analytics_screen_test.dart --reporter compact` → `+15: All tests passed!` PASS; `flutter analyze --no-pub` → `No issues found!` PASS; `dart format --output=none --set-exit-if-changed` on the 6 changed files → 0 changed PASS.
- **Constraints honored:** Candy Bold Neubrutalism tokens only; no hardcoded colors/palette; every user-facing string via `.tr(ref)` with VI/EN diacritics; ≥48dp primary touch targets; Semantics on buttons/cards; no horizontal overflow at 320dp; light mode only; client never writes progression/rewards; no server calls in UI.
- **Next action:** Agent D done; handoff to orchestrator. Awaiting Agent E (Independent QA) review or owner approval.

## 2026-11-04 — M5 Agent C: Bodyweight (local/test only)

- **Authority/status:** Agent C implemented M5 bodyweight domain (weigh-in history/trend chart, external-load validation) per the Agent C file scope. Pure Dart deterministic domain; client previews only, PostgreSQL authoritative; body mass comes exclusively from `profiles.weight_kg`; `workout_sets.weight_kg` is external/additional load only and is never derived as body mass. No UI, no database writes, no server calls, no AGPL code, no media. No new dependencies. No commit, push, tag, deploy, remote migration, or production write. Migration and SQL tests run only against isolated PGlite via `npm test` (`NOT RUN` on any linked/production database). Working tree dirty by pre-existing M3+M4 work (preserved); new files uncommitted.
- **Implementation (Agent C — domain + SQL):**
  - `app/lib/features/bodyweight/domain/bodyweight_measurement.dart` (new) — `@freezed` value type `BodyweightMeasurement` (id, userId, weight_kg, measured_at, source, notes, created_at) with `fromProfile(...)` factory reading `profiles.weight_kg` as the only legitimate profile→measurement path; `BodyweightSource` enum (`profileBaseline`, `manualWeighIn`, `scale`); `isBaseline` getter; JSON round-trip via `bodyweight_measurement.g.dart`/`.freezed.dart`.
  - `app/lib/features/bodyweight/domain/bodyweight_trend.dart` (new) — plain Dart `BodyweightTrend` computation over a history of measurements: `points`, `first`/`last`, `totalChangeKg`, `averageWeightKg`, `minWeightKg`/`maxWeightKg`, `changeInLastDays(days)`, `direction` (up/down/stable with `kTrendStableThresholdKg = 0.5`), `toChartPoints()`. Input sorted by `measuredAt`, never mutated.
  - `app/lib/features/bodyweight/domain/bodyweight_validator.dart` (new) — `BodyweightValidator` validates `WorkoutSet.weightKg` strictly as external load (finite, 0–1000 kg, matching `validateWorkoutSetForMode`); never reads, writes, or derives `profiles.weight_kg`; `isExternalLoadOnly` always true. Reuses `WorkoutSet` and `validateWorkoutSetForMode` read-only.
  - `app/test/bodyweight/bodyweight_measurement_test.dart` (new) — 10 tests: fromProfile body mass only, isBaseline, equality/hashCode, json round-trip, weightKg is body mass never external set load.
  - `app/test/bodyweight/bodyweight_trend_test.dart` (new) — 13 tests: empty/single/multiple measurements, unsorted input sorted ascending, total change/average/min/max, direction up/down/stable, changeInLastDays window, toChartPoints.
  - `app/test/bodyweight/bodyweight_validator_test.dart` (new) — 15 tests: external-load range (0/positive/1000 boundary), negative/NaN/Infinity/-Infinity/>1000 invalid, validateSet accept/reject, legacy null-mode compatibility, bodyweight/timed mode cross-validation with `validateWorkoutSetForMode`, weight_kg is external load never body mass.
  - `supabase/migrations/20261105000200_m5_bodyweight_measurements.sql` (new) — additive `CREATE TABLE IF NOT EXISTS public.bodyweight_measurements` (id, user_id FK users, weight_kg CHECK >0 AND <=500, measured_at, source CHECK, notes, created_at, updated_at) with RLS (owner-only), `updated_at` trigger, and index on `(user_id, measured_at)`. No existing tables/columns touched; `workout_sets.weight_kg` and `profiles.weight_kg` unchanged.
  - `supabase/tests/m5_bodyweight.sql` (new) — regression test: columns + CHECK constraint exist; `profiles.weight_kg` stays NOT NULL; `workout_sets.weight_kg` unchanged; owner insert/read; RLS isolation (other user denied 42501, insert denied 42501); trend ordering by measured_at; CHECK rejects 0 weight; `profiles.weight_kg` untouched by inserts.
- **Verification:** `flutter test --no-pub test/bodyweight/ --reporter compact` → `+38: All tests passed!` PASS; `flutter analyze --no-pub` → no bodyweight issues (302 pre-existing issues are Agent A's training_plan presentation, untouched by Agent C); `dart format --output=none --set-exit-if-changed lib/features/bodyweight/ test/bodyweight/` → applied PASS; `cd tools/db-tests; npm test` → m5_bodyweight.sql PASS, 22 SQL units + 365 ACL assertions PASS.
- **Constraints honored:** additive-only schema; no RLS/grant weakening; no new reward path; client never writes progression; weight_kg in workout sets = external/additional load only, never body mass; deterministic fixtures; NOT RUN on linked/production database (PGlite single-connection only).
- **Next action:** Agent C done; handoff to orchestrator. Agent D (Flutter presentation) is next per plan.

## 2026-11-04 — M5 Agent B: Analytics (local/test only)

- **Authority/status:** Agent B implemented M5 analytics domain (heatmap, weight trend, PR chart, muscle balance) per the Agent B file scope. Pure Dart deterministic engine over existing workout/progression data; client-side estimates only, PostgreSQL authoritative; no new reward path (`complete_workout` remains sole authority); no new tables, only additive indexes. No UI, no database writes, no server calls, no AGPL code, no media. No commit, push, tag, deploy, remote migration, or production write. Migration and SQL tests run only against isolated PGlite via `npm test` (`NOT RUN` on any linked/production database). Working tree dirty by pre-existing M3+M4 work (preserved); new files uncommitted.
- **Implementation (Agent B — domain + SQL):**
  - `app/lib/features/analytics/domain/analytics_models.dart` (new) — `@freezed` value types: `HeatmapPoint`, `WeightTrendPoint`, `PRChartPoint`, `MuscleBalancePoint`, `AnalyticsResult`; plus plain-Dart `PrRecord` (authoritative `exercise_prs` row, never recalculated).
  - `app/lib/features/analytics/domain/analytics_engine.dart` (new) — `AnalyticsEngine` with `heatmap`, `weightTrend`, `prChart`, `muscleBalance`, `aggregate`. Local-day bucketing via configurable timezone offset (default +7 Asia/Ho_Chi_Minh), UTC [start, end) window, deterministic rounding to 2 dp, exercise-ID validation (unknown IDs skipped), empty-state-safe (empty lists when no data). No clock/locale/random beyond explicit offset/window.
  - `app/test/analytics/analytics_engine_test.dart` (new) — 11 tests: empty history, single workout, multiple workouts/day, deterministic identical-output, time-window exclusion, timezone boundary (UTC→local), legacy/null-mode + uncompleted + timed sets, unknown exercise-ID exclusion, PR chart from authoritative source (not recalculated) with unknown-ID skip.
  - `supabase/migrations/20261105000100_m5_analytics_indexes.sql` (new) — additive `CREATE INDEX IF NOT EXISTS` on `workouts(user_id, completed_at)`, `workout_sets(workout_exercise_id)` WHERE completed, `workout_exercises(exercise_id)`, `exercise_prs(user_id, updated_at DESC)`. No drops/renames, no RLS/grant changes. Rollback = `DROP INDEX IF EXISTS`.
  - `supabase/tests/m5_analytics.sql` (new) — regression test mirroring engine semantics: indexes exist, heatmap by local day, weight trend volume/reps/sets, muscle balance by category + percent, [start,end) window, uncompleted-set exclusion, RLS isolation (owner sees own, other user denied 42501).
- **Verification:** `flutter test --no-pub test/analytics/ --reporter compact` → `+11: All tests passed!` PASS; `flutter analyze --no-pub` → `No issues found!` PASS; `dart format --output=none --set-exit-if-changed lib/features/analytics/ test/analytics/` → 0 changed PASS; `cd tools/db-tests; npm test` → m5_analytics.sql PASS, 20 SQL units + 365 ACL assertions PASS.
- **Constraints honored:** additive-only schema; no RLS/grant weakening; no new reward path; client never writes progression; deterministic fixtures; empty/legacy edge cases handled; `NOT RUN` on linked/production database (PGlite single-connection only).
- **Next action:** Agent B done; handoff to orchestrator. Agent D (Flutter presentation) is next per plan.

## 2026-11-04 — M5 Agent A: First-Week Plan / Newcomer Domain (local/test only)

- **Authority/status:** Agent A implemented M5 first-week training plan domain logic and newcomer journey state machine per the Agent A file scope (plain immutable Dart, no freezed/codegen). Pure Dart, deterministic, fully unit-testable. No UI, no database, no server calls, no AGPL code, no media. No commit, push, tag, deploy, remote migration, or production write. Working tree dirty by pre-existing M3+M4 work (preserved); new files uncommitted.
- **Implementation (Agent A — domain):**
  - `app/lib/features/training_plan/first_week_plan_models.dart` (new) — plain immutable value types: `BeginnerProfile` (userId, experienceLevel, completedWorkoutCount), `PlannedExercise` (exerciseId, exerciseName, category, mode, sets, reps, starterWeightKg, orderIndex), `PlanDay` (dayNumber, dayName, exercises), `FirstWeekPlan` (userId, days, version). All with const constructors, copyWith, `==`/`hashCode`. `starterWeightKg` documented: for `WorkoutMode.bodyweight` it is EXTERNAL/ADDED load (weight_kg), never body mass.
  - `app/lib/features/training_plan/first_week_plan_engine.dart` (new) — `FirstWeekPlanEngine.generate(BeginnerProfile?, List<Exercise>)` pure deterministic engine. Reuses existing `Exercise` and `WorkoutMode` (read-only). Rules: exactly 3 days x 3 exercises for a beginner with no history; deterministic selection sorted by stable exercise id (no Random, no DateTime, no clock); beginner-appropriate (3 sets, 10 reps in 8-12 range, light 5.0 kg starter); bodyweight → `bodyweight` mode with starterWeightKg 0.0 (external load, not body mass); reps-weight → `reps-weight` mode with 5.0 kg; timed/cardio excluded; returning users (completedWorkoutCount > 0) and non-beginners get an empty plan (history never overwritten); null profile / empty catalog / insufficient candidates throw descriptive `ArgumentError`; idempotent (generate twice == identical result, no duplicate plan/workout creation at domain level).
  - `app/lib/features/training_plan/newcomer_journey_models.dart` (new) — `JourneyEvent` enum; `JourneyOutcome` (workoutCreated/completionAwarded/progressionUnlocked, static `none`); `NewcomerJourneyContext` (completedWorkoutCount, planStarted, lastCompletedDay); `NewcomerJourneyResult` (state + outcome); sealed `NewcomerJourneyState` with 7 states: `noHistory`, `planAvailable`, `planStarted`, `workoutPartial`, `workoutComplete`, `progressionAvailable`, `returningUser` (terminal).
  - `app/lib/features/training_plan/newcomer_journey.dart` (new) — `NewcomerJourney.transition(current, event, context)` pure deterministic state machine: noHistory→planAvailable→planStarted→workoutPartial→workoutComplete→progressionAvailable→returningUser; returningUser stable terminal; workoutComplete→progressionAvailable only when completedWorkoutCount >= 3 (3rd workout); retry-safe (re-completion before 3rd returns same state with `JourneyOutcome.none`, no duplicate award); invalid transitions throw `ArgumentError`; static `reconstruct(...)`, `isTerminal`, `isWorkoutInProgress`, `hasCompletedWorkout`.
  - `app/test/first_week_plan_test.dart` (new) — 11 tests: deterministic identical output, 3 days x 3 exercises, sorted/stable-id selection no duplicates, bodyweight external-load semantics, returning-user empty plan, non-beginner empty plan, null profile ArgumentError, empty catalog ArgumentError, insufficient candidates ArgumentError, retry idempotency, timed/cardio exclusion.
  - `app/test/newcomer_journey_test.dart` (new) — 14 tests: first entry (noHistory→planAvailable), resume (planAvailable→planStarted), partial workout (planStarted→workoutPartial), completion (workoutPartial→workoutComplete), 3rd workout → progressionAvailable, returning user terminal, re-enter returningUser, retry-before-3rd no duplicate award, invalid transition throws ArgumentError, deterministic same-input same result, reconstruct from inputs, query helpers.
- **Verification:** `flutter test --no-pub test/first_week_plan_test.dart test/newcomer_journey_test.dart --reporter compact` → `+25: All tests passed!` PASS; `flutter analyze --no-pub` → `No issues found!` PASS; `dart format --output=none --set-exit-if-changed lib/features/training_plan test/first_week_plan_test.dart test/newcomer_journey_test.dart` → 0 changed PASS.
- **Constraints honored:** no freezed/codegen; no schema/dependency/UI/database changes; reuses existing `WorkoutMode`, `Exercise`, `WorkoutSet` read-only; client never persists progression (preview only); deterministic/stable IDs; bodyweight `weight_kg` = external load not body mass; returning-user history preserved; retry/idempotent safe. Replaced broken untracked `training_plan/domain/` freezed scaffolding (missing `.freezed.dart`/`.g.dart` parts, caused 87 analyze errors) with the specified plain-Dart files.
- **Next action:** Agent D — implement training plan presentation/UI layer using Agent A's domain models.

## 2026-11-04 — M4 progression, 1RM/PR, RPE/RIR & RPG bridge — local/test only

- **Authority/status:** D-043 `ACCEPTED` for additive local/test verification only. M4 closed for development. Production activation remains gated (offline gates `false`; `complete_workout` stays sole PostgreSQL reward authority). No commit, push, tag, deploy, remote migration, or production write.
- **Implementation (Agent A — domain):** `progression_engine.dart` extended with Epley 1RM (`weight_kg * (1 + reps / 30)`, rounded to 2 decimals, clamped inputs, null on invalid), `detectPersonalRecord()` (weight/reps/both/none, replay-safe), `progressionSnapshot()` golden-table type. `progression_models.dart` new (immutable value types). `workout_set.dart` + `.freezed.dart` + `.g.dart` — added nullable `rpe` (1-10) and `rir` (0-10). `progression_engine_test.dart` extended: 15 tests total (existing 10 + 5 new: golden progression, 1RM boundary/rounding/repeatability, PR detection/replay-safe).
- **Implementation (Agent B — SQL):** `supabase/migrations/20261104000100_m4_progression_rpe_rir.sql` — additive `rpe`/`rir` columns on `public.workout_sets` with named CHECK constraints (`workout_sets_rpe_range` 1-10, `workout_sets_rir_range` 0-10, both `IS NULL OR`), RLS re-affirmed (no weakening). `supabase/tests/m4_rpe_rir.sql` — regression test for constraints, backward compatibility, RLS isolation. `npm test` → 18 units / 365 ACL assertions PASS.
- **Implementation (Agent C — bridge + UI):** `rpg_bridge.dart` — `classXPForLevel` = `(xpBase * level^xpSlope).floor()`, `levelForXP` (capped at 20), `projectClass()` deterministic projection. Candy UI: `ProgressionScreen`, `ClassProgressCard`, `ExerciseProgressionCard`, `RpeRirTile`; VI/EN l10n; 320dp; Semantics; ≥48dp touch targets. `localization_engine.dart` — progression keys added. QA accessibility findings (Semantics + 48dp) fixed in all M4 UI widgets.
- **Verification:** Flutter focused tests → 30/30 `PASS`; `flutter analyze --no-pub` → `No issues found!` `PASS`; `dart format` → clean `PASS`; `npm test` → 18 SQL units / 365 ACL assertions `PASS`.
- **Safety/next:** Local/test verification only; nothing staged or committed. Production activation and remote migration remain gated (owner approval required). All math deterministic (same inputs → same outputs, no clock/locale/random).

## 2026-11-04 — M3.6 security & concurrency verification

- **Authority/status:** D-042 `ACCEPTED` for additive local/test verification only. All executable M3.6 gates `PASS`; M3 technically ready for M3-FINAL Git delivery subject to owner approval. Four production gates remain false. No stage/commit/push/tag, remote migration, deploy, production offline write, or M4 work.
- **Implementation:** `OfflinePayloadCipher` (AES-256-GCM, fresh 96-bit nonce per seal, 128-bit tag, length-prefixed AAD binding owner/operation/workout/contract-version/mutation-kind), typed fail-closed exceptions, key-version promotion for forward rotation. Store schema v3 on `offline_write_intents` and `offline_set_projections` with plaintext/ciphertext mutual exclusion; legacy v2 rows preserved; `encryptLegacyRowsForOwner` converts legacy plaintext rows. Narrow `OfflinePayloadKeyStore` (`readKey`/`createKey`, no enumeration/bulk delete); deterministic in-memory store for tests; `PlatformSecureOfflinePayloadKeyStore` via `flutter_secure_storage` (base64 32-byte key, DPAPI-protected file backend on Windows). `OfflineAuthenticatedSession.logout()` clears owner/generation and stops sync before ACK without discarding rows; discard requires explicit `ownerConfirmed`; only the matching owner may claim/sync/discard. Dependencies: `cryptography ^2.9.0`, `flutter_secure_storage ^11.2.0`, dev `integration_test` (all BSD-3, non-AGPL, no media).
- **Multi-agent/QA:** Agent A encryption/secure storage/lifecycle (exclusive app files); Agent B genuine two-connection PostgreSQL concurrency (exclusive tooling); Agent C independent QA (read-only review) → `NO_DEFECT_FOUND`; no unresolved P0–P2.
- **Verification:** focused Flutter 52/52 `PASS` (cipher 12, encrypted queue 8, security lifecycle 11, schema migration 2, store 10, coordinator 9); `flutter analyze` no issues `PASS`; format changed Dart files 0 `PASS`; full Flutter 411 pass / 1 fail solely at protected Gradle Wrapper 9.7.1 vs approved 8.13 (pre-existing protected owner-file issue, not an M3.6 regression); SQL `npm test` 16 units / 365 ACL assertions `PASS`; `npm run test:concurrency` → C1–C6 `PASS` (6/6) on isolated disposable PostgreSQL 17.5 with two independent `pg.Client` connections; lock-wait evidence via `pg_stat_activity` monitor; data directory removed, no leftover process/listener; real-runtime Windows integration test `create` + `recover` (two separate processes) → key survives restart, envelope decrypts after restart, owner B denied, wrong binding rejected, delete fails closed, zero residue.
- **Safety/next:** Verified external backup baseline and protected owner paths unchanged before/after edits. Exact M3 candidate manifest prepared but not staged in `M3_6_FINAL_REPORT.md`. Real-user offline storage blocked pending owner approval to commit/push and separate remote migration/deployment approval (O-07/O-06). Do not start M4.

## 2026-11-03 — M3.5 integrated local/test implementation

- **Authority/status:** Owner approved D-041 contracts for Superset, four modes, and offline security foundations. M3.5 local/test implementation and independent QA `PASS`; M3 overall remains `PARTIAL`. Four production gates remain false. No Git stage/commit/push/tag, remote migration, deploy, production offline write, or M4 work.
- **Implementation:** Additive Superset/mode fields, private durable group/mode locks, transactional grouping and safe ungroup, grouped set-number validation after workout lock, round/rest semantics, VI/EN and narrow-screen UI, explicit nullable mode and draft validation, mode-aware `complete_workout` with no new reward path, and owner-scoped synthetic offline facade with account-switch cancellation/retention/conflict/discard. The live online path retains its existing schema-compatible write.
- **Multi-agent/QA:** Superset, modes, and offline agents held exclusive files; read-only UI review found presentation/timer issues. Independent QA found four material P2 defects (completion order/rest, duplicate grouped set numbers before lock, draft cross-mode values, and mutable history locks) plus UI lock-state mismatch. Owners fixed them; independent final review found no unresolved P0–P2.
- **Verification:** integrated focused Flutter 144/144 `PASS` before final fixes; independent final-tree 64/64 Flutter, SQL 16 units/365 ACL, analyzer and diff check `PASS`. Root final-tree analyzer no issues `PASS`, format 154 files/0 changed `PASS`; full Flutter 386/387 `FAIL` solely because protected local Gradle Wrapper is 9.7.1 while release test expects 8.13. True two-connection PostgreSQL `BLOCKED` due absent runtime; live/device/remote `NOT RUN`.
- **Safety/next:** Verified external bundle/archive/41 dirty-file copies before edits. Exact 31-path candidate manifest and safe reversal in `M3_5_FINAL_REPORT.md`. Real-user offline storage blocked pending encryption/platform keys, production auth/device lifecycle, PostgreSQL concurrency, and separate deployment approval. Do not start M4.

## 2026-11-03 — M3.5 approved server contracts

- **Decision:** Owner accepted D-041: retain pending writes until sync or explicit discard, encrypted owner-scoped local data and secure-storage keys before real-user activation, strict account-switch isolation, hard operation-content conflict, Superset v1, and four explicit persisted modes. Production activation, remote migration, deploy, commit, and push remain unapproved.
- **SQL implementation:** Added nullable Superset position and mode with constraints; owner-checked transactional layout RPC with minimum-two/contiguous positions, a private append-only lock that survives set uncompletion/deletion, and safe ungroup; typed set validation; `complete_workout` accepts duration-only typed sets without a second reward path and without zero-valued strength PRs. Legacy NULL modes remain unchanged. Existing online client paths were not connected.
- **Verification:** `cd tools/db-tests; npm test` → 16 units and 365 ACL assertions `PASS`, including owner access, direct-write denial, atomic layout changes, frozen history, four-mode measurements, and one-reward retries. `git diff --check` exit 0 `PASS`. PGlite is single-connection; genuine PostgreSQL two-connection verification remains `BLOCKED` by the absent runtime. Flutter checks `NOT RUN` because this slice changed no app code.
- **Safety/next:** Verified external backup before edits; protected owner paths untouched. No commit, push, tag, deployment, remote migration, or production write. M3.6 should implement encrypted owner-scoped local lifecycle with synthetic fixtures; production gate remains closed.

## 2026-11-03 — M3.4 concurrency availability and owner contract gate

- **Scope/status:** Performed one bounded check for an already-available two-session PostgreSQL runtime. `psql`, `pg_ctl`, `postgres`, Docker, and Podman were absent; no PostgreSQL service or port 5432 listener existed; WSL was not installed. Six genuine concurrency scenarios are `POSTGRES_CONCURRENCY_RUNTIME_BLOCKED`. No runtime was installed or downloaded; PGlite was not used as race evidence. Overall M3.4 `PARTIAL`.
- **Contract review:** One read-only Codex subagent checked Superset and four-mode recommendations against actual SQL/Dart models. Source inspection found `complete_workout` rejects completed sets with `reps=0` despite the duration-friendly check; deleting a workout-exercise row cascades to its sets. D-041 and `M3_4_FINAL_REPORT.md` present proposed lifecycle, retention, conflict, Superset, and mode decisions without marking them approved.
- **Verification/safety:** `main` @ `bd078c7`, index empty; external bundle clone, 598/598 archive, and 38 dirty-file hashes verified before edits. M3.3 test/analyzer/QA results remain historical; M3.4 code tests `NOT RUN` because no app/SQL/test code changed. Protected owner paths preserved. No stage, commit, push, tag, deployment, remote migration, credential use, or production write.
- **Next:** owner responds to the single D-041 approval block; genuine isolated PostgreSQL concurrency verification remains required before real-user integration. M3 incomplete; M4 not started.

## 2026-11-03 — M3.3 synthetic offline sync foundation

- **Authority/status:** Owner's M3.3 request authorized synthetic-only local database lifecycle, outbox transitions, retry/ACK reconciliation, and local server hardening. D-040 records `PARTIALLY_APPROVED` scope. Overall M3.3 is `PARTIAL`: local implementation/checks pass, true two-connection PostgreSQL concurrency is `BLOCKED` by the absent local server/Docker.
- **Implementation:** Drift v2 additive migration, durable state/retry metadata, canonical lowercase UUID validation, SHA-256 local fingerprint, atomic owner/workout-scoped fenced claim/ACK; test-only sync coordinator with disabled production gate; normalized server request fingerprint, private ledger, atomic set-create RPC, and guarded nullable superset group field. No real-user storage, online path replacement, mode activation, or remote migration.
- **Multi-agent/QA:** Three implementation agents owned distinct local, SQL, and sync files; a fourth independently reviewed integration. QA found two P2 issues (case-distinct local UUIDs; local ACK errors retried as transport failures). Both were fixed and re-reviewed with regression tests; no actionable finding remains. Local/server fingerprint byte encodings remain separate and require a production wire decision.
- **Verification:** focused M3/M3.1/M3.3 Flutter tests 103/103 `PASS`; SQL suite 14 units plus 365 ACL assertions `PASS`; analyzer no issues `PASS`; format 146 files/0 changed `PASS`; full Flutter suite 359/360 `FAIL` solely on the preserved Gradle Wrapper 9.7.1 versus approved 8.13 assertion. SQLite two-connection claim test passes; real PostgreSQL concurrent duplicate delivery `BLOCKED`; live/device/remote checks `NOT RUN`.
- **Safety:** Verified external backup (bundle HEAD, archive 598/598, 34 dirty-file SHA-256 copies) before edits. Protected and pre-existing owner work preserved. No stage, commit, push, tag, deploy, credential use, or production data write. Full M3 remains open; next M3.3 action is isolated two-connection PostgreSQL verification.

## 2026-11-03 — M3.2 approved synthetic offline foundation

- **Decision:** Recorded owner approval as D-005/D-039 `PARTIALLY_APPROVED`. Drift + SQLite, transactional outbox, operation ID, versioned fingerprint ledger, additive local/test migrations, nullable superset group UUID, and four inactive mode names are approved. Real-user storage, production migration/replay, and missing policies remain blocked.
- **Implementation:** Added a disconnected Drift store that atomically saves a synthetic set projection and immutable write intent, plus a local/test PostgreSQL RPC and private operation ledger. The server compares SHA-256 fingerprints and exact request bodies, locks owner/workout in completion-compatible order, and returns one result for duplicate delivery. A trigger rejects non-null superset group writes until grouping behavior is approved. No UI/controller/repository integration or mode activation.
- **Verification:** `flutter pub get` `PASS`; focused Dart tests 11/11 `PASS`; analyzer no issues `PASS`; format 143 files/0 changed `PASS`; SQL suite 14 units and 365 ACL assertions `PASS`. Full Flutter suite 342/343 `FAIL` at the preserved Gradle Wrapper 9.7.1 versus approved 8.13 assertion. Live Supabase, device, remote CI, and two-connection concurrency `NOT RUN`.
- **Safety/Git:** Verified external backup bundle, archive 598/598, and 25 dirty-file hashes before editing. Existing owner changes retained. No commit, push, tag, deploy, production data, or credential use.

## 2026-11-01 — M3.1 offline architecture proposal and isolated foundation

- **Scope/status:** Proposed a transactional offline write contract, superset alternatives, and four approved mode names in `M3_1_DECISION_PROPOSAL.md`; all new architecture remains `PROPOSED`. M3 remains `PARTIAL` until owner decisions permit production integration.
- **Implementation:** Added an immutable, owner/workout/operation-bound Dart identity with strict deterministic JSON and collision-safe local comparison key, plus seven deterministic unit tests. It is disconnected from repositories, providers, and production writes. No dependency, schema, AGPL source, or media was introduced.
- **Verification:** M3.1 identity tests 7/7 (`PASS`); existing M3 timer/controller/widget tests 75/75 (`PASS`); Flutter analyzer no issues (`PASS`); format two files/0 changed (`PASS`). Full suite `NOT RUN` in M3.1; the earlier M3 331/332 Gradle Wrapper exception is historical. Independent QA status and protected-file verification are recorded in `M3_1_FINAL_REPORT.md`.
- **Git/next:** M3.1 files remain local and unstaged beside preserved M3 timer work and owner-controlled paths. Obtain owner approval for D-005/O-03, server idempotency, superset behavior, and mode data before the next M3 implementation task. M4 not started.

## 2026-11-01 — M3 rest-timer continuity and Candy UI checkpoint

- **Scope/status:** Implemented a bounded timer slice of official M3 (Offline-first Workout Core, Modes, Timers, Supersets). Full M3 remains `PARTIAL` because durable offline set writes, remaining modes, and persisted supersets are not complete; D-005/O-03 remains unapproved.
- **Reference:** read-only `D:\Projects\opengym-reference` remote and HEAD matched `DuarteSantos8/openGym` @ `e6a95c28a6e3067bdd9b1188d5f37f448d528bd2`; working tree clean. Relevant README behavior and timer/workout test names informed capability mapping only. No AGPL implementation or media reuse.
- **Changes:** owner/workout-bound rest snapshot in the existing local workout backup; exact running deadline recovery, paused/expired validation, remote-completion cleanup, serialized writes; Candy rest timer and wheel paint, responsive 48dp controls, VI/EN semantics. Five app/test files changed, plus three planning records and `M3_FINAL_REPORT.md`. No schema, dependency, production, or Git write.
- **Verification:** focused timer/controller/UI tests 75/75 (`PASS`); analyzer no issues (`PASS`); format 138 files/0 changed (`PASS`); full Flutter suite 331/332 (`FAIL`) only at `release_config_test.dart` due protected local Gradle Wrapper 9.7.1 versus approved 8.13. Independent QA found and verified fixes for deadline extension and stale backup after completed remote; final ownership rerun 49/49 (`PASS`) and no actionable M3 defect. Live Supabase/device/remote CI `NOT RUN`.
- **Protection/next:** protected owner files and 125 `.agents/teamwork/` files matched pre-edit hashes; no stage/commit/push/tag/deploy. Prepare approved M3 local-store and superset data design before remaining M3 work; M4 not started.

## 2026-11-01 — M2 Exercise Detail local implementation

- **Task/status:** M2 Exercise Detail Layout & Information Architecture `PASS` for local functionality; no commit, push, tag, migration, deployment, or M3 work. Baseline remains `main` @ `1979dfd5fda7cebf6791c11ece3cc1aa333ce1c3`.
- **Implementation:** stable UUID route, Riverpod catalogue lookup, picker detail entry preserving single/multi selection, Candy detail cards, VI/EN labels and states, accessible media placeholder, narrow/2x scrolling, and unavailable states for missing primary muscle and unverified instructions. No `imageUrl` use, third-party media, or AGPL code. A measured picker 320dp overflow was fixed by wrapping card badges.
- **Verification:** M2 focused test 11/11 (`PASS`), M1 picker test 67/67 (`PASS`), analyzer no issues (`PASS`), formatter seven files/0 changed (`PASS`). Full Flutter suite 308/309 (`FAIL`): one `release_config_test.dart` Gradle 8.13 assertion against protected local wrapper 9.7.1. Independent read-only QA reran M2 11/11 and found no actionable defect. Live Supabase, device, and remote CI `NOT RUN`.
- **Content limits:** O-08 provenance of the curated exercise prose is open; instructions/form cues/common mistakes are not newly displayed. Model lacks primary-muscle and instruction-locale fields; metadata values lack localized variants. O-01/O-02 and release/data blockers remain open.
- **Manifest:** six M2 app files, one new M2 test, additions to the three planning files, and new `M2_FINAL_REPORT.md`. Prior six-file M1-FINAL planning baseline and protected owner/unrelated paths were preserved. Candidate manifest is in the report; nothing staged.

## 2026-11-01 — M1-FINAL verified closeout and M2 handoff

- **Task:** reconcile the existing M1.2 Git delivery and close Exercise Catalogue M1 for implementation and Git delivery; prepare Exercise Detail M2 handoff without starting implementation.
- **Git verification at `main` `1979dfd5fda7cebf6791c11ece3cc1aa333ce1c3`:** `git show -s --format="%H%n%P%n%s" HEAD` confirmed parent `9b874111692dee1f69dc686e1dbbc38981529cf5` and approved subject; `git diff-tree --no-commit-id --name-only -r HEAD` listed exactly 10 approved files; `git ls-remote origin refs/heads/main` returned the same SHA. No new commit, push, tag, branch, or deployment was performed.
- **Historical M1 verification retained:** 67/67 focused tests, analyzer, and formatter `PASS`; full Flutter suite `FAIL` at 297/298 due to preserved local Gradle Wrapper 9.7.1 versus approved 8.13; independent QA `BLOCKED` by quota 429. Flutter checks were `NOT RUN` in this closeout. Remote CI was not observed.
- **Decision:** D-038 `ACCEPTED` with owner confirmation; product M1 is Exercise Catalogue and product M2 is Exercise Detail. Former release-stabilization and bulk-import work, O-01/O-02 and other blockers remain open. M1 is not fully QA-approved or production-ready.
- **Local files changed:** `docs/planning/TASK_BOARD.md`, `docs/planning/SESSION_HANDOFF.md`, `docs/planning/CHANGELOG_AI.md`, `docs/planning/DECISIONS.md`, `docs/planning/MASTER_PLAN.md`, `docs/planning/PROJECT_CONTEXT.md`. Protected owner, Gradle Wrapper, and `.agents/teamwork/` files were preserved.

## 2026-10-31 — M1.1 Exercise Catalogue Test Hardening & Independent QA (tests, no commit)

- **Task:** M1.1 Exercise Catalogue Test Hardening & Independent QA.
- **Scope:** created comprehensive deterministic automated tests in `app/test/exercise_picker_test.dart` for the M1 Exercise Catalogue implementation. Covered 6 core test areas:
  1. Pure unit & Riverpod tests for Vietnamese diacritic-insensitive & case-insensitive search normalization (`normalizeSearchText` and `filteredExercisesProvider`), handling complex vowel families, `đ`/`d`, whitespace, mixed language, and immutability.
  2. Debounce timing behavior in `SearchQueryNotifier`: immediate apply on clear, 300ms window, latest keystroke precedence, and safe disposal.
  3. Catalogue filtering: category, equipment, secondary muscle groups, multi-filter AND combinations, search + filter combinations, independent clearing, and clear-all.
  4. Derived filter providers: distinct, sorted lists from actual exercise catalogue fixtures.
  5. Widget states: loading indicator, error state with retry callback, empty state, active filter badges, clear-all action, list/grid view toggle.
  6. Navigation & selection: single-select pop, multi-select toggle, finish button in AppBar, Semantics labels, 48dp minimum touch targets, 320dp narrow layout, and 2.0x large text scale.
- **Verification:**
  - `flutter test --no-pub test/exercise_picker_test.dart` → `+67: All tests passed!` (67 passed, 0 failed, 0 skipped, exit 0).
  - `flutter analyze --no-pub` → `No issues found! (ran in 3.7s)` (exit 0).
  - `dart format --output=none --set-exit-if-changed test/exercise_picker_test.dart` → 0 changed (exit 0).
  - `flutter test --no-pub` → 297/298 passed (1 pre-existing fail in `release_config_test.dart` due to local uncommitted Gradle 9.7.1 wrapper edit; zero regressions on core code).
  - 5 protected owner files verified identical via SHA-256 pre- and post-execution.
- **Files added/updated:** `app/test/exercise_picker_test.dart` (new, 67 tests), `M1_1_FINAL_REPORT.md` (new), `M1_1_FIX_REPORT.md` (new), `docs/planning/TASK_BOARD.md`, `docs/planning/SESSION_HANDOFF.md`, `docs/planning/CHANGELOG_AI.md`.
- **Status:** PASS. No commits, pushes, tags, merges, or deployments executed.

## 2026-10-31 — M1 Exercise Catalogue Navigation & Filtering (implementation, no commit)

- **Task:** M1 Exercise Catalogue Navigation & Filtering in `ExercisePickerScreen` + supporting providers/copy.
- **Scope:** search debouncing (~300 ms, immediate on clear), Vietnamese/English accent-insensitive search, clear-search suffix button, dynamic filter chips (category/equipment/muscle) derived from actual exercise data, active-filter badges, clear-all filters, grid/list toggle, Candy design migration (CandyExerciseCard, CandyEmptyState, CandyErrorState, CandyTextField), VI/EN l10n keys. Accessibility fixes: Semantics labels on chips/cards/clear-search, 48dp touch targets, WCAG AA contrast on info banner, line-height headroom for 200% VI scaling. No AGPL code copy, no media, no dependency changes, no schema migration needed (all filter columns already exist).
- **Files changed:**
  - `app/lib/features/workout/presentation/providers/exercise_providers.dart` — added `normalizeSearchText()`, debounced `SearchQueryNotifier`, `selectedEquipmentProvider`/`selectedMuscleProvider`, derived `exerciseCategoriesProvider`/`exerciseEquipmentsProvider`/`exerciseMusclesProvider`, accent-insensitive multi-filter `filteredExercisesProvider`.
  - `app/lib/features/workout/presentation/screens/exercise_picker_screen.dart` — Candy UI rewrite + accessibility fixes: `Semantics` on active filter chips, filter option chips, exercise cards, clear-search button; `ConstrainedBox(minHeight/Width: 48)` touch targets; `CandyColors.ink` banner contrast; `height: 1.35` line-height on filter headers and banner text; dynamic filter values rendered directly instead of `workoutText` lookup fallback.
  - `app/lib/features/workout/workout_copy.dart` — added VI/EN keys: clear_search, clear_all, view_grid, view_list, category, equipment, muscle_group, empty_state_title/message, error_state_title/message.
- **Verification:** `flutter analyze` → No issues found (exit 0); `dart format --set-exit-if-changed` → 0 changed; `flutter test` → +231 All tests passed (no regression).
- **Status:** Implementation complete, PASS. No commit/push/tag (per task). Route `/exercise-picker` unchanged; multi/single-select preserved.
- **Next action:** owner review; qa-reviewer to add dedicated exercise-picker tests (test files were not touched).

## 2026-10-31 — M0 OpenGym source pinning & migration foundation

- **Source pinned:** `DuarteSantos8/openGym` @ `e6a95c28a6e3067bdd9b1188d5f37f448d528bd2` (AGPL-3.0, behavioral reference only), cloned to `D:\Projects\opengym-reference`; remote origin verified (`fetch` + `push`), HEAD matches selected SHA. Not nested in GymLvl git tree, not a submodule, not committed into GymLvl.
- **Manifest created:** `docs/planning/UPSTREAM_SOURCE_MANIFEST.json` pins GymLvl baseline (`6badfef2...` @ `main`), OpenGym B SHA, ExerciseDB dataset SHA, licenses, acquisition date, permitted use.
- **Licensing assessment:** OpenGym code = AGPL (reference only, no copy); MIT text (`textSource=exercisedb`) reusable with notice, strip media; media = Gym visual proprietary (EXCLUDED); GymLvl has no LICENSE file (O-01 open).
- **Subagents delegated:** flutter-specialist (UI mapping), supabase-specialist (data mapping), qa-reviewer (licensing QA — BLOCKED on sandbox access to opengym-reference, but classification produced from project docs).
- **Workstream B (feature architecture mapping):** gap analysis produced for catalog, workout sets, progression, 1RM, rest timer; no OpenGUL code copied.
- **Migration slice implemented:** Rest Timer Duration Wheel — replaced quick-select chips (30/60/90/120s) with a minute/second wheel picker in CandyBottomSheet; VI/EN l10n keys added; narrow-screen safe (Wrap layout).
- **Files changed:** `app/lib/features/workout/presentation/widgets/rest_timer_widget.dart`, `app/lib/features/workout/presentation/screens/active_workout_screen.dart`, `app/lib/features/workout/workout_copy.dart`, `app/test/workout_widgets_test.dart`, `docs/planning/UPSTREAM_SOURCE_MANIFEST.json` (new).
- **Verification:** `flutter analyze` 0 issues; `dart format` 0 changed; `flutter test` +231 All tests passed (no regression).
- **Status:** M0 implementation slice PASS; no commit/push/tag (READY_FOR_APPROVAL).

## 2026-10-29 — R3 release-readiness hardening (local pass; remote CI pending approval)

- **CI hardening (FND-TEST-001):** `.github/workflows/verify.yml` now runs `invoke.test.mjs` in the
  manifest-gate step (18 Android tests), adds `dart format --set-exit-if-changed`, per-job
  `timeout-minutes` (15/25/30), workflow `concurrency`+cancel, restricts push to `main`, and pins
  `checkout`/`setup-node`/`setup-java`/`upload-artifact` to Node-24 commit SHAs (`subosito/flutter-action@v2`
  kept). YAML parses to 3 jobs. Generated-file drift gate **withheld** — regenerating at the locked
  generator versions rewrites 12 tracked files (measured: 846+/1303 lines), so the gate would fail
  immediately. All gates **PASS locally**; remote CI **NOT RUN** (pending owner approval to push).
- **Android fail-closed signing (FND-BUG-002):** verified locally **without credentials** —
  `gradlew :app:validateReleaseSigningInputs` exits 1 listing all four `GYMLVL_RELEASE_*`; a placeholder
  `STORE_FILE` still lists 3 missing; `:app:assembleRelease` fails at the gate and produces no APK/AAB.
  Keystore absent → signature verification **NOT RUN**. AGP 8.11.1 / Gradle 8.13 / Kotlin 2.2.20 /
  JDK 21 compatible (`java -version` local is 1.8 but gradlew uses `JAVA_HOME` = Android Studio JBR).
- **FND-BUG-004 contrast:** 7 profile text nodes + onboarding chip paints resolved; 7 new UI tests + a
  negative-control run (8 failures on pre-fix colours) prove the assertions regress-detect. **Fixed.**
- **FND-BUG-005 KPI window:** labels now state the real windows (7-day volume, last-3 workouts/sets); 3
  tests added. **Fixed.**
- **Findings:** register 35 — Fixed 20 · Accepted 11 · Needs Verification 2 · False Positive 2.
  INTG-008/009 source-confirmed remain Needs Verification (bare retryable insert / non-transactional
  reorder); real fix needs an isolated two-connection PostgreSQL stack.
- **Supabase (FND-DATA-001/D-037):** migration `20261029000200` re-validated as additive/idempotent; SQL
  suite 12 units + 365 ACL PASS. The two read-only cohort queries are now recorded in
  `REMEDIATION_EXECUTION.md` §11.5 and were schema-validated locally against every versioned migration
  (cohort A/B execute, guard+index present, positive control isolates exactly one synthetic at-risk tuple,
  negative control clears it, `complete_workout` returns `alreadyAwarded:true` on that tuple). Live run
  **BLOCKED** on `O-07`. PGlite is single-connection → concurrency **BLOCKED**; no production count claimed.
- **Validation (local):** analyze 0, format 135 files 0 changed, `flutter test` 231/231, SQL 12 units +
  365 ACL PASS, Edge 44/44, manifest gate exit 0, invoke 10/10, manifest-check 8/8, YAML 3 jobs.
- **Docs:** `REMEDIATION_EXECUTION.md` §11 records the R3 evidence (§11.1–§11.4 work/commands,
  §11.5 cohort queries + local controls, §11.6 Android readiness matrix, §11.7 owner actions); operator
  signing guide added at `docs/admin/ANDROID_RELEASE_SIGNING_VI.md` (Vietnamese, no secrets).
- **Commit:** no commit/push/tag yet — this batch stops at `READY_FOR_APPROVAL`. Five owner files
  preserved. Closure so far: REPOSITORY: CLOSED (R2) · CI: VERIFIED (R2) · PRODUCTION: NOT VERIFIED ·
  OPENGYM: NOT READY.

## 2026-10-29 — R2 controlled remediation: A-2, A-3, A-4, A-7, A-8 done; A-1 guard done, data repair blocked

- Entry `main` @ `b85d674` with a dirty tree preserved (owner work + A8 batch). No commit, push, tag,
  deployment or production migration.
- **A-2 / FND-INTG-001 → Fixed:** `supabase/config.toml` `site_url=http://localhost:8080` and an
  allowlist covering `localhost`, `127.0.0.1`, `[::1]` on 8080 (exact + `/**`) with the legacy `:3000`
  entries kept; `app/config.example.json` `AUTH_REDIRECT_URL`; README/DEVELOPMENT use
  `--web-port 8080`. New `app/test/auth_redirect_config_test.dart` 6/6 PASS. Live recovery NOT RUN.
- **A-3 / FND-BUG-001 → Fixed:** real `gradlew :app:processReleaseMainManifest` →
  `BUILD SUCCESSFUL`; merged manifest has `package=com.gymlvl.app`, `label=GymLvl`, one direct
  `INTERNET`. New `tools/android-verify` gate (8/8 fixture tests, exit 0) plus an
  `android-release-manifest` CI job (NOT RUN remotely). No APK, no signature, no device check.
- **A-4:** `tools/audit-sync/sync-findings-r2.mjs` surgically synced `docs/audit/FINDINGS_REGISTER.json`:
  12 findings gained an `r2_review`, 35 IDs and all history preserved, counts recomputed to
  Fixed 18 · Accepted 12 · NV 3 · FP 2.
- **A-7 / FND-BUG-003 → Fixed:** `GymLvl`/`GYMLVL` in app title, wordmarks, l10n `appTitle`, onboarding
  copy, docs headings and CI workflow name; technical identifiers unchanged. Tests 31/31 PASS.
- **A-8 / FND-GOV-005 → Fixed:** `git rm --cached app/analysis.txt` + `app/.gitignore:48`; the
  84,864-byte local file is preserved and no source/CI references it.
- **A-1 / FND-DATA-001 → Fixed (repository scope):** additive migration
  `20261029000200_prevent_legacy_double_award.sql` adds one evidence-based guard (3 added lines, rest
  byte-identical) plus `idx_xp_logs_user_source`; an existing `xp_logs` award row now yields
  `alreadyAwarded` with no writes. Regression added to `supabase/tests/progression_regression.sql`;
  RED without the migration → GREEN with it. No backfill, no row mutation.
- Final gates: analyze exit 0; format 134 files / 0 changed; Flutter 221/221; SQL 12 units + 365 ACL
  assertions; Edge 44/44; Android manifest gate exit 0.
- Final consistency check caught a broken line in `.github/workflows/verify.yml` (the flutter job's
  `steps:` key had been joined with its first entry by the rename), fixed it and re-validated the YAML
  by parsing it (3 jobs, 7/6/6 steps). No permanent YAML gate added — still part of FND-TEST-001.
- **Blocked:** production counts/backfill (`O-07` + operator approval), release signing, iOS build,
  hosted Edge, live Auth, remote CI, true two-connection concurrency — all NOT RUN.
- Docs updated: `REMEDIATION_EXECUTION.md` §3.1/§4/§7/§8, `FINDINGS_REGISTER.md`,
  `CODEBASE_HEALTH_REPORT.md`, `REMEDIATION_PRIORITY.md`, `MASTER_FINDINGS.md`, `PROJECT_CONTEXT.md`
  §4.1, `DECISIONS.md` (D-035–D-037), `TASK_BOARD.md`, this handoff and changelog.
- Finalization pass (§9): repository safety, re-run gates, YAML parse, register integrity, and the
  read-only cohort queries syntax-checked locally. Commit manifest prepared (Commit A 19 files,
  Commit B 39 files, 5 owner/ambiguous paths excluded) — **not committed**. Remote CI at `b85d674`
  observed **red** in `database-and-edge` (`Expected 413, got 503` ×8); fixing change is pending.

## 2026-10-29 — R2 committed, pushed, CI fixed by `a018ec2`, remote CI green (runs 40832095175 → 40834000928)

- Commits created from the approved §9.4 manifest and pushed fast-forward (`b85d674..74aaa22`):
  `7a10031` (19 files, A-8 batch) and `74aaa22` (39 files, R2 batch). Five excluded owner paths
  untouched; `app/analysis.txt` untracked, on disk, ignored.
- First CI run `40832095175` overall **failure**: `database-and-edge` **success** (the eight
  `Expected 413, got 503` failures from `40798076003` are gone — the SEC-004 runner fix works),
  `flutter` **success** (analyze, 221 tests, web build, artifact), `android-release-manifest`
  **failure** at `Merge and verify the release manifest` with
  `app/android/gradlew: 154: Syntax error: "(" unexpected`.
- Root cause: `tools/android-verify/run.mjs` invoked the wrapper with `sh` on POSIX; the
  Flutter-generated `gradlew` declares `#!/usr/bin/env bash` and uses bash arrays at line 154, so dash
  aborted before Gradle started and the gate exited 2 (fail-closed by design). Tooling defect, not an
  app or manifest defect.
- Fix in `a018ec2` (4 paths, +243/−33): new `tools/android-verify/gradle-invocation.mjs` runs `bash`
  with the wrapper as `argv[1]` on POSIX (`shell: false`, spaces safe), keeps `gradlew.bat` through a
  shell on Windows, and treats a missing wrapper, a failed merge or a missing merged artifact as
  `BLOCKED` (exit 2). Ten regression cases in `invoke.test.mjs`; `package.json` runs both suites.
  Local: `node --check` ×3 exit 0, `invoke.test.mjs` 10/10, `manifest-check.test.mjs` 8/8, real gate
  exit 0 with `PASS merged release manifest: package=com.gymlvl.app label=GymLvl internet=1 nested=0
  duplicates=0`. The Linux branch is `NOT RUN` locally (no `bash` on the Windows host).
- Second CI run `40834000928` at `a018ec2`: **success** in all three jobs; the Android job logs
  `BUILD SUCCESSFUL in 44s` and the merged-manifest `PASS` line, closing the invocation defect.
- `REMEDIATION_EXECUTION.md` §10 records both runs and the fix, and the same three planning files were
  updated. Closure: REPOSITORY: CLOSED · CI: VERIFIED · PRODUCTION: NOT VERIFIED · OPENGYM MIGRATION:
  NOT READY. Known gap: the CI step still runs only `manifest-check.test.mjs`, so `invoke.test.mjs` is
  not enforced remotely.

## 2026-10-29 — A8 audit remediation batch: 9 findings fixed/partial, 2 blocked on approval

- Verification-first pass over the 35-finding canonical register at main b85d674 (dirty tree
  preserved). Entry analyze0/format129-0/full200pass, SQL11+ACL365, Edge36/44. Count reconciliation
  written into FINDINGS_REGISTER.md: 35 findings, not 37 (37 = bounded-body Edge tests); the earlier
  draft enumerated 23 IDs and summed confidence+status to 70. FND-INTG-001 re-scoped to the Auth
  redirect allowlist, not `/coach`.
- Fixed with tests: BUG002 Android label/iOS names, BUG003 pubspec description, BUG004 partial profile
  contrast, BUG006 fabricated quest progress+350/100XP, BUG007 summary deep link/synthetic workout
  +500XP/level defaults, BUG008 recovery error scoping, BUG009 keyboard-focusable CandyButton; TEST001
  partial source gate; SEC004 edge-runner synthetic env. New tests: summary5, reset1, keyboard2,
  quest3, +3 release, +1 200%-text contrast.
- Reproduced and BLOCKED: DATA001 second award (total_xp100->110, level1->2, rewards0->1, ledger1->3)
  needs additive migration+live count approval; INTG001 site_url127.0.0.1:3000 vs app localhost:8080
  needs config approval. GOV005 is still open: the stale transcript is app/analysis.txt and
  `git ls-files app/analysis.txt` lists it; a root-path check had been mis-read as a resolution.
  18 findings not re-verified.
- Final: analyze0, format133-0, full215/215, SQL11+ACL365, Edge44/44. D-034 recorded (derived from
  D-029). No commit/push/tag/migration/config/deploy. Merged manifest, iOS build, hosted Edge, live
  Supabase NOT RUN; approval items A-1..A-4, A-7, A-8 in REMEDIATION_EXECUTION.md §7.

## 2026-10-29 — A7 B1 regression PASS; platform tasks remain PARTIAL/BLOCKED

- Parent D process TEMP/TMP final analyze0issues48.5s/format129files0changed/fullFlutter200pass
  concurrency2, all0; independentcore31snapshot/25async/18receipt pass and no material code blocker.
- R1-05 permission/source and R1-06 fail-closed signing/source implemented,10sourcechecks pass;
  D031officialSHA Gradle8.13 pin verified. D032exactduplicateZIP rehashed/deleted136983045bytes,
  no other cleanup; Dtemp/cache/process environment approved. SDK/JBR21 available, no key reads.
- Oneonline Gradle203.5s native8Gheap mmap failure; oneoffline1G1worker112.4s reachedappconfig then
  Kotlin2.1.20/reflection/annotations cachemiss. No actual mergedmanifest/signinggate/signature PASS,
  no second online attempt/SDK license/dependencyversion/CI change. Logs/crash artifact preserved.
- Registry5B1objects updated with exactpre-A7 histories,30others unchanged fromB0; SEC002/CONC001/
  INTG002Fixed repository/local, platformBUG001/002Accepted pendingruntime.35IDs, Accepted22/NV3/
  Fixed8/FP2; severity0/3/24/6/2 confidence16/18/1 unchanged. No new persistence/production claim.
- OverallPARTIAL: seven scoped tasks complete, four requiredverification gates BLOCKED. Final artifact
  QA/logical verifiedcore and explicitlyPARTIAL platform checkpoints next; next execution blocked B1
  environment gates, no B2-B4/migration automatically. No independent eligible task silently skipped.

## 2026-10-29 — A7 B1 completion reconciliation and environment disposition

- Independent R1-02 QA25async/controller tests pass. R1-03 initial preflight correctly stopped when
  SQL rewards-only contract contradicted assumed workout receipt; D029 clarified no localfabrication.
- R1-03 implemented validated captured-identity rewards receipt, pending detail reconciliation/edit
  block/detail-only retry and uncertain-vs-rejected response handling; actual finish uses completed
  serverdetail/duration. RED1pass13fail ->focused76pass/analyze/format, independent18pass no blocker.
  Harness timeouts/setup and analyzer corrections retained in A7phase5; no database commit proof.
- Receipt is shallow/in-memory, not durableoutbox. Fresh R1-04/R1-07 inventory found no supported
  local PostgreSQL/Supabase/Docker target, BLOCKED; no modelled-persistence finding promoted.
- Continue independent platform/network/signing tasks then batch regression/QA; no B2+ execution.

## 2026-10-29 — A7 B0 checkpoint and B1 snapshot/async progress

- B0 main57e4e73e88f7099ec29a9d075964817f4db5470d,20paths+1216/-75 committed/pushed3d9dbb0..
  57e4e73 normally; remote equal/tree clean, A7_B0_CHECKPOINT=PASS, four exact pre-A7 histories verified.
- R1-01 privacy fix after actual REDwrongadoption/overwrite ->43focusedpass, independentQA31snapshot/
  analyze/full157pass; foreign/ownerless data preserved, owner-scoped keys, same-owner offline retained.
- R1-02 queue/post-storage-await fix RED18pass3fail ->focused58pass/analyze/format pass; native
  remove-ack race controls added, QA pending. No backend/timed/business scope expansion.
- User approved D029 authoritative RPC ack vs hydration/duration and D030 fail-closed operator
  signing. No keys read/created; no artifact signature claim. Continue eligible B1, not stop at B0.

## 2026-10-29 — A7 B0 implemented and verified, B1 continues

- R0-02 default shell ask/reviewer gate correction +32 permanent policy tests; R0-03 additive
  effective-ACL migration +10isolatedDB/365assertions integrated SQLrunner11units; R0-04 streaming
  UTF8 byte bounds +29focused/44fullEdge/sixchecks. Parent batch commands all exit0/diff0.
- Actual specialists/independent QA and exact owned paths in A7phase4. Initial red tests observed
  original defects; intermediate grant/validator failures and corrections retained. Extra owner/
  superuser rollback fixtures added after review. No material implementation blocker by inspection.
- QA runtime npm.ps1 blocked by OS policy and source-filter Git denied, not retried/bypassed; stale
  execution ledger FAIL corrected here. Parent used independently planned explicit Node/Deno gates.
- GOV004/SEC001/SEC003/SEC004 Fixed in repository scope, full pre-A7 objects/nested history preserved,
 31others unchanged;35IDs and severity/confidence unchanged, statusAccepted25/NV3/Fixed5/FP2.
- Live permission scanner/saved approvals, deployed ACLs, network cancellation/DoS not certified.
  No production/secret/deploy/CI/dependency changes. B0 checkpoint next, then continue approved B1.

## 2026-10-29 — A7 W0/W1 execution authorization and R0-01

- Entry main3d9dbb0 clean/remote equal; actual gymlvl-orchestrator verified; external bundle/bare/
  archive560/tree560 backup valid, hashes in A7 execution record. No product edit before approval.
- User explicitly approved all W0/W1, separate R1-01, normal verified commits/pushes; chose shell
  default ask, additive effective-ACL fail-closed and bounded UTF-8 requests/provider JSON. D-025..028
  recorded before material changes. No W2-W5/production/destructive/migration/media authorization.
- R0-01 synthetic checklist6 assertions exit0: missing approval/material/owner/unsafe tree denied,
  approved B0/B1 allowed, B2 denied. Not a security sandbox; per-task QA and actual tests still required.
- Next bounded specialist writes and internal task checkpoints; preserve35 findings/history.

## 2026-10-29 — A6 payload checkpoint committed and synchronized

- Payload main4246b12238e4a904f87c0b843e861b637403d00c, `docs(audit): reconcile A6 remediation
  roadmap`, nine audit/planning docs +761/-3. Normal `git push origin main` ->6d8e89b..4246b12,
  exit0. `git ls-remote origin refs/heads/main` equals local fullSHA; status empty, `A6_PAYLOAD_EQUAL_CLEAN=PASS`.
- This outcome-only child edits audit handoff and three planning records; HEAD advances when committed,
  so verify actual latest main/remote on resume. No findings/evidence/classifications or decisions change.
- A6 PASS/CLOSED, migration NOT READY. Await user approval for R0-01 safety checklist, then separate
  R1-01 SEC002 snapshot ownership task; no automatic remediation, W0/W1 or migration execution.

## 2026-10-29 — A6 scoped audit PASS/CLOSED

- Final independent QA/context inspections found no material blocker after R0-02 readiness dependency
  correction; stale A6 NEXT audit-track row reconciled. QA/keeper did not independently rerun Node
  or runtime tests; inspections are not runtime PASS. Exact sessions/results in A6phase2/7.
- 35 finding objects/classifications and all nested history unchanged; roadmap29 tasks, acyclic DAG,
  historical plan retained exactly; primary A6phase6 validator node0/diff0. Coverage26static/0/0/1.
- Migration NOT READY; safety/privacy/award/provenance/affected-migration verification gates and
  explicit unresolved naming conflict retained. No material decision, product/config/schema/test edit,
  production/secret access, remediation or migration. A5 UI FAIL and blocked runtime gaps retained.
- Authorized docs checkpoint/remote verification follows. Recommend user separately authorize R0-01
  safety checklist and then R1-01 SEC002 snapshot ownership, one scoped task at a time; no automatic fix.

## 2026-10-29 — A6 roadmap and material QA

- Sequential exclusive roadmap writer mapped35 unchanged findings to29 task IDs, W0-W5 with owners,
  concrete acceptance/dependencies/recovery, migration readiness NOT READY and exact proposed order.
  A0 plan retained verbatim as historical appendix. No classification or product change.
- Independent qa-reviewer material inspection found R5-01 omitted R0-02 security-policy dependency;
  corrected, no permission bypass. All six actual agent sessions recorded in A6phase2.
- Retained primary Node validator ->A6_ARTIFACT_CHECK findings35/unchangedObjects35/closures4/
  md35/roadmapRows35/unique35/tasks29/DAGacyclic/oldplanExact/coverage26-0-0-1/paths9/errors0;
  A6_VALIDATION_EXIT node=0 diff=0. Five initial setup/label validator FAILs corrected and retained;
  one found generic path labels, writer made exact task file targets explicit, no code changes.
- Specialist roadmap category/order validator ->29/29/historyidentical/errors0 exit0; previous regex,
  Recovery-label and repeated-category-token failures retained in phase6. A1-A5 tests are historical,
  not rerun or claimed current PASS. Final context/QA and authorized docs checkpoint remain.

## 2026-10-29 — A6 authorized reconciliation start

- A6 only; main6d8e89bf6eba7b393ef2d0e0d52e9b0d5eb4f2c3 clean and origin/main equal; OpenCode API
  metadata confirms gymlvl-orchestrator. D-013 bundle/bare/archive backup verified559files/tree559,
  clone equals entrySHA, hashes in A6 phase2. No product/config/agent/dependency/permanent-test edit.
- Context/Flutter/Supabase/catalogue/UI actual bounded read-only delegations invoked sequentially;
  session IDs/results in A6 phase2. QA and roadmap pending; all35 findings/history unchanged.
- Recorded BUG003 `GymLevel`/`gymlvl` versus M1-02 `GymLvl` naming conflict without choosing brand;
  product decision required before remediation. Prior A0 roadmap skeleton contains superseded proposals.
- Next A6 roadmap, independent QA, validator and authorized docs-only checkpoint. No W0/W1, fixes,
  migration, secrets/production, media, installs, full-app Temp copy or prior-directory cleanup.

## 2026-10-29 — A5 closure checkpoint committed/pushed/synchronized

- Closure payload mainab19e97bd7c143ee7a140a461d774a4ebfea7443, `docs(audit): close A5 testing
  and reliability audit`, nine-doc delta +2428/-143 after PARTIAL614ee7c; aggregate A5 scope11docs.
- `git push origin main` ->614ee7c..ab19e97 main -> main, exit0. `git rev-parse HEAD` and
  `git ls-remote origin refs/heads/main` ->same full payload SHA; `git status --porcelain=v1`
  ->empty, A5_CLOSURE_EQUAL_CLEAN=PASS. No force push/history rewrite or product/permanent tests.
- This outcome-only child changes audit handoff and three planning records; its commit advances
  documentation HEAD, so resume must verify actual latest main/remote. No new findings/evidence,
  decisions, tests or investigation. A5 stays PASS/CLOSED, with failed/blocked/unexecuted gaps intact.
- Await explicit A6 authorization and exact handoff prompt; no A6/remediation/migration automatically.

## 2026-10-29 — A5 final precommit gate

- Continued only the already-authorized A5 checkpoint; main614ee7c, nine expected dirty docs.
- Retained phase8 validator rerun after final closure metadata/QA wording ->same35records/30oldIDs/
  25unchangedClasses/24unchangedObjects/sixHistories/fiveNew/22fields/26-0-0-1/11allowedDocs/
  65unchangedInputs/errors0; A5_VALIDATION_EXIT node=0 diff=0, PASS. No new product/runtime work.
- Normal documentation commit/push and final remote synchronization next; stop before A6.
- Explicit authorized-path staging ->nine changed docs; git diff --cached --check ->
  A5_STAGED_DIFF_CHECK_EXIT=0, PASS including new UI evidence. No product/permanent-test/config paths.

## 2026-10-28 — A5 scoped audit PASS/CLOSED; A6 not started

- A5.1-A5.7/C23/C24 reviewed with finite evidence/gap dispositions; closure against audit-only
  criteria, not remediation/production or exhaustive runtime proof. Final context and QA artifact
  inspections found no material blocker; stale coverage/pending-output wording corrected only.
- Actual five-agent sequential ledger and register-only followups retained.35 mirrored findings,
  severity0/3/24/6/2 confidence16/18/1 status29/3/1/2; old30 IDs, six complete histories and24 unchanged
  objects preserved. Coverage26static/0/0/1, no blanket runtime promotion. No material decision.
- Primary current126regressions/analyze/format/SQL10/Edge15/six checks PASS; Flutter18 and finite
  backend assertions PASS. UI aggregate FAIL8pass2fixturefail and external analyzer FAILpackagecontext
  remain explicit. True sessions/JWT stack BLOCKED; device/network/host telemetry/profile budgets
  NOT RUN. Green observation tests are not fixes. Exact commands/output in phase7/8 and evidence.
- QA extra source-diff BLOCKED and keeper exit wrappers rejected, not retried/bypassed; independent
  runtime validation NOT RUN by reviewers. Primary full artifact validator output retained before
  review; final precommit rerun/staged whitespace gate follows, normal docs checkpoint authorized.
- Exact A6 reconciliation/verification/triage/remediation-plan prompt persisted, new go-ahead needed.
  No A6/remediation/migration/product/permanent-test/CI/config/dependency/permission changes or cleanup.

## 2026-10-28 — A5 material QA and register/coverage reconciliation

- PARTIAL payload614ee7cb6f99846b00fd71eec43637cb296268be committed/pushed1763ab5..614ee7c exit0;
  local/remote equal and tree clean after push. Subsequent UI/QA/register-only delegations sequential.
- All five required configured agents invoked; full sessions/scopes/results in A5phase2. QA supports
  five newIDs and narrow five promotions; CONC001 identity-await addendum distinct from queuecycle.
  Exact six pre-A5 objects/nested histories retained,24 others unchanged; formatting-only followup
  restores those24 raw object spans. Counts35, severity0/3/24/6/2 confidence16/18/1, status29/3/1/2.
- New BUG008 recovery contamination, BUG009 keyboard primitive, INTG008 lostACK/INTG009 reorder
  High/NV modeled persistence, TEST002 local-replica regression target. No duplicates or fixes.
- C23/C24 fully read; coverage26static/0InReview/0NotReviewed/1excluded. Scoped remaining assertions
  assigned owners/triggers/waves; no numeric coverage or whole-device/production claim.
- Primary Flutter analyze0issues(62.9s), format125/0changed, test126 all exit0. Original SQL10,
  Edge15 and six entrypoint checks independently rerun deny-net/cached/frozen/synthetic env, all exit0.
- UI final aggregate FAIL8pass2nullable-chip fixture fails and external analyzer FAIL296package-
  context issues retained; not production defects or all-green evidence. QA corrected weak disabled
  counter qualification; extra source-diff BLOCKED(permission), not retried/bypassed. No QA runtime.
- Exact A6 reconciliation/triage/remediation-planning prompt persisted; final artifact/context/QA
  gate and closure checkpoint next. No A6 execution/remediation or unauthorized product/config edits.
- Primary phase8 retained executable extraction/Node ->A5_ARTIFACT_CHECK json35/md35/oldIDs30/
  unchangedClasses25/unchangedObjects24/exactHistories6/newIDs5/fields22/coverage26-0-0-1/allowedPaths11/
  unchangedInputs65/errors0; A5_VALIDATION_EXIT node=0 diff=0, PASS before final reviewers. Two initial
  metadata-shape validator FAILs corrected only in validator (supplemental a5_review object), no
  finding data/allowlist/permission change; full failed results and corrected output retained.

## 2026-10-28 — A5 first PARTIAL evidence checkpoint

- Real Flutter and Supabase sequential delegations completed; source/output/setup failures/hashes
  retained in A5_FLUTTER_EVIDENCE.md and A5_BACKEND_EVIDENCE.md. Actual sessions in A5phase2.
- Flutter18 external audit tests pass and analyze0issues; backend expiry-only controls/150UUIDpairs
  replay/12request+3providerstreamcases/SQL10units/Edge15tests/sixchecks/EXPLAIN100-1000 exit0.
- Lead10/post-await identity loss and buffering mechanisms observed; transportlostACK/reorder use
  modeled persistence, not realSQL. Candidates not registered/promoted before material QA. All30
  existing objects/classifications unchanged. Setup/diagnostic/evidence-builder FAILs retained.
- True independent sessions BLOCKED: one tool check found no Docker/Supabase/PostgreSQL executable
  target. No PGlite Promise.all concurrency or production-impact claim. No implementation fixes.
- Seven documentation paths only; scoped acceptance NOT RUN pending UI/QA/consistency. Authorized
  incremental PARTIAL commit/push next, then UI/accessibility and independent QA. No A6/remediation.

## 2026-10-28 — A5 authorized start and context checkpoint

- main1763ab55e8da994bc1d854ad8fd2cd2299678b45 clean/remote equal; active gymlvl-orchestrator
  verified via API. Existing30 finding IDs/history preserved. A5 only, acceptance NOT RUN pending.
- D-013 external bundle/bare/archive backup verified: clone HEAD equals entrySHA, ZIP555/tree555;
  full hashes/commands in A5phase2. No extracted/runnable full-app copy or prior-directory cleanup.
- context-keeper actually invoked(ses_e7cee471effem1IORTQYzbIfD5), finite backlog restored. Corrected
  stale A4 NEXT/A5 PLANNED audit-track table to match authoritative current state; no plan change.
- Created A5_TEST_RELIABILITY.md scoped acceptance/ownership/finite inherited assertions and ledger.
  Other four sequential delegations next. No product/permanent-test/CI/dependency/config changes.
- Normal docs-only/partial commits/pushes authorized for A5; no A6/remediation/migration/live/secrets.

## 2026-10-28 — A4 checkpoint committed, pushed and synchronized

- Payload main84462d0acc27a4c9ea0f99a2c0aa16c0940082fb, `docs(audit): close A4 workout and
  progression audit`, nine documentation files +1652/-65. `git push origin main` ->
  `c95cb48..84462d0 main -> main`, exit0; no force push/history rewrite or product/permanent tests.
- `git rev-parse HEAD` and `git ls-remote origin refs/heads/main` ->same full84462d0 SHA;
  `git status --porcelain=v1` ->empty, `A4_CHECKPOINT_EQUAL_CLEAN=PASS` after push.
- This outcome-only child record changes audit handoff plus three required planning docs; current
  HEAD advances when it is committed, so verify actual latest main/remote rather than treating the
  payload SHA as the final child SHA. No findings/evidence/classifications or decisions change.
- A4 stays PASS/CLOSED; exact A5 prompt persisted, A5 not started and needs explicit go-ahead.
  No A5/A6/remediation/migration/production action, secret access, full-app Temp copy or cleanup.

## 2026-10-28 — A4 scoped audit PASS/CLOSED; A5 not started

- A4 acceptance assessed against review/evidence/owned gaps/material QA/consistency criteria, not
  remediation or exhaustive runtime/production proof. Real final context-keeper and qa-reviewer
  follow-ups completed; sessions/commands/results/corrections recorded in A4 phase11. No material
  closure blocker; corrected stale ownership/header/coverage words, last A2 paragraph historical.
- QA HEAD/main/status/diff checks exit0, nine docs only; additional exclusion-diff command BLOCKED
  by shell permission, no retry/bypass or permission change. QA Node/probe/regressions NOT RUN.
  Pre-existing primary validator source/output retained before review; final cheap gate before commit.
- 30 findings and24/0/2/1 coverage unchanged from reconciliation; two explicit old reclassifications,
  four new IDs, exact histories preserved. DATA001 conditional synthetic only; INTG007 still High/NV;
  no real concurrency, production cohort, crash-recovery or isolated-expiry proof invented.
- All required current tests and exact primary artifact-validator output remain in phase9/10 and
  handoffs. Final post-QA validator rerun ->identical errors0/node0/diff0; explicitly staged nine
  docs and `git diff --cached --check` ->A4_STAGED_DIFF_CHECK_EXIT=0, including new phase/evidence.
  No material decision/source/schema/permanent-test/permission/dependency change. Normal
  nine-doc A4 commit/push authorized and pending; record actual checkpoint outcome after execution.
- Exact bounded A5 prompt persisted in audit handoff, separate authorization required. No A5/A6,
  remediation, OpenGym migration, full-app Temp copy or prior-directory cleanup.

## 2026-10-28 — A4 review/evidence reconciliation; final gate pending

- main c95cb4873455b39f3ab2b6c0f929b43d87f4d8d3; nine authorized documentation paths dirty,
  remote rechecked equal. No product/SQL/Edge/config/permanent-test/permission/dependency changes.
- All five required configured agents actually invoked sequentially (phase2 ledger). Independent
  QA inspected material source/full retained probe evidence; supports conditional P1 DATA001,
  three new synthetic P2 mechanisms and ARCH001 sole-award wording disproof. No QA runtime claim.
- Register30: P0 0/P1 3/P2 20/P3 5/P4 2; Confirmed9/High20/Medium1; Accepted24/NV3/Fixed1/FP2.
  All26 earlier IDs retained,24 old classifications unchanged, exact DATA001/ARCH001 objects retained.
  New DATA002/INTG005-007; INTG007 stays High/NV because actual Dart quest journey not run.
- Coverage24 static-reviewed/0 InReview/2 NotReviewed(C23/C24)/1 excluded; no blanket runtime claim.
- Current node <A4 probe>/probe.mjs ->8groups/15 sequential DBs/108assertions/zero fetch/exit0;
  specialist plus justified independent primary rerun. Existing SQL runner ->PASS10 PostgreSQL17.5,
  app analyze ->No issues(3.0s), format ->125files/0changed, tests ->+126 All tests passed, all exit0.
  Edge NOT RUN (unchanged A3 scope); expected22023/P0001 errors are asserted defect/rollback evidence.
- Corrected initial catalogue-parser regex FAIL and unnecessary legacy-title-validator FAIL are
  preserved, no product repair. Falseflag prior-award synthetic duplicate is not production cohort
  or ordinary-retry duplication. Rollback is after savepoint helper rollback; day/expiry joint check
  is not isolated expiry proof; independent connections and actual Dart journey remain unexecuted.
- Primary phase10 retained PowerShell/Node artifact validator -> A4_ARTIFACT_CHECK json30/md30/
  oldIDs26/unchangedClasses24/exactHistories2/newIDs4/fields22/coverage24-0-2-1/allowedPaths9/
  unchangedProbeInputs7/errors0; A4_VALIDATION_EXIT node=0 diff=0, PASS. Three primary validator
  attempts FAIL (Unicode native pipe regex, optional empty test array, trimmed porcelain prefix),
  corrected in validator only, no finding data change/allowlist expansion; all retained in phase10.
- Final context/QA artifact gate pending. Exact bounded A5 prompt now
  in audit handoff; no A5/A6/remediation/migration or Temp copy/cleanup. No material new decision.

## 2026-10-28 — A4 start and actual delegation checkpoint

- A4 only authorized; main/remote c95cb4873455b39f3ab2b6c0f929b43d87f4d8d3 clean at entry,
  API confirms gymlvl-orchestrator. Existing26 findings retained.
- Created A4_WORKOUT_PROGRESSION.md with scoped acceptance, exact artifact ownership/safety and
  actual delegation ledger. context-keeper invoked (ses_e7d46f8ddffeDvA7AjR9bdw4go), restored
  authoritative scope/deferred work; no source scan or runtime PASS. Other four invocations pending.
- No source/SQL/Edge/config/test/agent/dependency edits. Next: bounded sequential business reviews,
  synthetic DATA001/control evidence, independent QA; no A5 or remediation.

## 2026-10-28 — A3 Supabase/PostgreSQL/security scoped closure

- **Git outcome:** c535613fe29cf5a435ead44a6c4c26a16e3074ae on main, nine docs +1094/-25;
  normal git push origin main -> f877e40..c535613 main -> main, exit0. git ls-remote origin
  refs/heads/main equals local checkpoint SHA; status empty after push. This follow-up records the
  outcome, not another audit; no force push/rewrite/product change or A4 start.

- **Task/status:** A3 only, scoped PASS/CLOSED with deferred verification. Entry main/remote
  f877e40987423f3804fe0d2887c44d19f3423aff, clean; API primary gymlvl-orchestrator. A4 not started.
- **Changed:** A3_SUPABASE_SECURITY.md and A3_SQL_EVIDENCE.md new; audit findings/register/coverage/
  handoff and three planning records updated. Nine docs only, no application/SQL/Edge/test/config/
  lock/dependency/agent change. Current artifact filename explicitly follows user request.
- **Review:** sequential Supabase schema/grants/RLS/functions/Edge and Flutter client/Auth boundaries,
  independent QA material challenge and retained evidence inspection. All C17-C21 read; fresh role
  controls corroborate no tested B-vs-A bypass, not proof for every table/deployment.
- **New findings:** SEC003 P2/Confirmed/Accepted only for injected pre-existing PUBLIC UPDATE(total_xp)
  surviving named-role hardening, own XP777; SEC004 P2/High/NeedsVerification for post-buffer body size
  checks, resource impact not reproduced. No unconditional production vulnerability asserted.
- **Counts:**26, P0 0/P1 3/P2 16/P3 5/P4 2; Confirmed5/High19/Medium2; Accepted21/
  NeedsVerification3/Fixed1/FalsePositive1. Original24 classes retained with three A3 addenda.
  Coverage18 reviewed-static/5 inreview/3 not reviewed/1 excluded; no whole-row runtime promotion.
- **Current tests:** node tools/db-tests/run.mjs -> PASS10 units/PostgreSQL17.5,150 catalog rows,
  metadata/duration checks, exit0. Installed frozen/cached-only Deno deny-net synthetic limited env ->
  15passed0failed; six handler check targets pass, exit0. No dependencies fetched or live requests.
- **Contrary evidence:** original custom probe FAIL/exit1 falsifies explicit authenticated column
  grant survival. Fresh controls passed before failure; assertion retained. PUBLIC continuation
  PASS14 assertions and diagnostic named denial PASS4 assertions, independent orchestrator rerun.
  Exact187-line source normalized hash matched external executed variant version; all outputs
  retained. No product repair or hidden failed test. No A4 reward-arithmetic/legacy-cohort test.
- **QA:** original external evidence read BLOCKED, not retried; supported in-repo evidence read
  completed. Corrected named-role hypothesis, DATA001 existing-test description and17tables/22policies
  wording; narrow synthetic and static confidence scopes retained. QA does not claim its own runtime run.
- **Deferred/next:** A4 Supabase/Flutter/QA authoritative reward/legacy/retry/timed/concurrency semantics;
  A5 gateway/resource/fullrole matrix/performance policy checks; deployed ACL/history needs separate
  authorization. Exact A4 entry prompt recorded; wait for go-ahead. No remediation/migration/cleanup.
- **Current consistency at f877e40:** PowerShell here-string -> Node JSON parse/tally/mirror/prior-ID/
  field/coverage/scope assertions -> A3_CHECK json=26 md=26 old_ids_preserved=24
  old_classifications_preserved=24 required_fields=22 allowed_paths=9 errors=0; A3_VALIDATION_EXIT
  node=0 diff=0. Counts26 and18/5/3/1 coverage match, nine authorized docs only, product unchanged.
  git diff --check exit0 with conversion warnings only. Final QA found no substantive security
  blocker, but FAIL flagged missing persisted current parser output; now recorded durably in phase12,
  audit/planning handoffs and this log. Earlier17tables/22policies wording correction retained.

## 2026-10-28 — A3 start checkpoint

- A3 only authorized; current baseline main/remote f877e40987423f3804fe0d2887c44d19f3423aff, tree clean,
  primary API agent gymlvl-orchestrator. A2 remains closed and its 24 findings are carried unchanged.
- Created A3_SUPABASE_SECURITY.md using current user artifact name; recorded scope/acceptance,
  safe test boundary and pending sequential reviews. Updated audit/planning handoffs/task board.
- Git/metadata checks executed; SQL/Edge verification pending, no old PASS copied. No product,
  configuration, permission, migration or dependency edits. No live stack/production/secret access.
- Next A3 action: bounded schema/RLS/RPC review, client/Auth/Edge review and QA; no A4/remediation.

## 2026-10-28 — A2 scope closure and exact A3 handoff

- **Checkpoint:** a6a57e2546afa8dbd3dd7113bc1096a6e99f5cdf on main, eight docs, +317/-27;
  normal git push origin main -> aa36a4c..a6a57e2 main -> main, exit0. Remote main equals local
  closure SHA via git ls-remote; status empty after push. This child record retains the outcome;
  no rewrite/force-push and no A3 execution.

- **Task:** close scoped A2 only; validation PASS against the original seven audit acceptance
  criteria, operational CLOSED with deferred work. No new investigation or A3 execution.
- **Entry:** main aa36a4c36e6c46cc7ae1f2fdd3e117f2a8a3a4c5, clean and remote equal; server metadata
  gymlvl-orchestrator. Normal documentation commit/push explicitly authorized.
- **Changed:** A2_FLUTTER, AUDIT_COVERAGE, MASTER_FINDINGS, FINDINGS_REGISTER, audit SESSION_HANDOFF;
  planning TASK_BOARD/SESSION_HANDOFF/this log (eight docs). A2_PROBES and product code unchanged.
- **Scope:** move Lead10 runtime hypothesis to A5 per explicit user instruction, flutter-specialist
  with qa-reviewer, synthetic failed-signin/recovery plus successful/rejected submit controls, retained
  harness/command/output. NOT RUN; no Confirmed promotion. This extra checkpoint gate was not an
  original mandatory AC. Context-keeper independently inspected governance and confirmed that fact.
- **Preserved:** all24 finding objects/classifications and22 dispositions; no count changes. Severity
  P0 0/P1 3/P2 14/P3 5/P4 2; confidence4 Confirmed/18 High/2 Medium; status20 Accepted/2 Needs
  Verification/1 Fixed/1 False Positive. Coverage13 static/5 mixed-stage in review/8 not reviewed/1 out.
- **Handoff:** exact bounded A3 schema/RLS/Auth/Edge C17-C21 prompt, no automatic execution; A4 owns
  reward/idempotency semantics, A5 device/widget/contract checks. Deferred owners/assertions retained.
- **Verification boundary:** prior analyzer/format/+126 regression and +7 controller evidence stays
  dated, not current runtime PASS. Current Flutter analyze/test/format/probes NOT RUN for docs-only
  closure, intentionally no further runtime investigation. Current artifact/Git checks recorded below.
- **Decisions:** no material architecture/schema/dependency/permission/milestone change or waived AC.
  No Temp cleanup; exact-path user disposal approval still required. Next action: await A3 go-ahead.
- **Current closure validation at aa36a4c:** inline Node -> CLOSURE_CHECK findings=24
  unchanged_objects=24 md=24 fields=22 dispositions=22 lead10=A5 ac_records=7 authorized_paths=8
  errors=0; CLOSURE_EXIT node=0 diff=0. All24 finding objects equal entry commit; scope eight docs.
  git diff --check exit0, LF/CRLF warnings only. Initial validator FAIL/exit1 was pipe-encoding of
  Unicode literals (seven AC labels/one title); ASCII-safe assertions reran PASS, no product/finding
  repairs. Both results recorded, not masked.
- **QA:** context-keeper ses_e7d8e3512ffe5XRc3csFGsWSyv confirmed no Lead10-runtime requirement in
  original AC. qa-reviewer ses_e7d88939afferY5zT4orKqmM5Z independently inspected scope/records and
  found no substantive mandatory blocker, requested current output notes now added; Git scope PASS,
  its parser/runtime checks NOT RUN. Vietnamese commentary quotes current errors0 and runtime NOT RUN.

## 2026-10-28 — A2 final reconciliation / PARTIAL documentation checkpoint

- **Checkpoint outcome:** `199bf00271c8038c04a8f8cbdc1fc35e7538e90f`, nine docs, +1724/-69;
  normal `git push origin main` -> `7eb40f1..199bf00  main -> main`, exit 0. `git ls-remote origin
  refs/heads/main` equals local full SHA; status empty after push. This follow-up records the result;
  no history rewrite or force push. A2 remains PARTIAL.

- **Task/status:** A2 PARTIAL; no A3 or remediation. User explicitly authorizes normal commit/push
  of an internally consistent partial documentation checkpoint, not a claim of completion.
- **Baseline:** main/remote 7eb40f1; API metadata confirms gymlvl-orchestrator. Nine expected dirty
  artifacts backed up externally with matching hashes, bundle clone HEAD and 549/549 archive count.
- **Changed:** nine pre-existing audit/planning artifacts only. Sequential UI and Flutter bounded
  inspections disposition all 22 leads, with owner/target/assertions for deferrals. Seven full-field
  new IDs BUG004-007/INTG002-004; preserve original 17 IDs and histories. CONC001 narrowed to
  reproduced queue cycle P2/Confirmed/Accepted; post-await race deferred A5. SEC002 narrowed to
  synthetic controller adoption P1/Confirmed/Accepted. DATA001 stays unverified server-side.
- **Counts:** 24; severity P0 0/P1 3/P2 14/P3 5/P4 2; confidence Confirmed 4/High 18/Medium 2;
  status Needs Verification 2/Accepted 20/Fixed 1/False Positive 1. Coverage 13/5/8/1.
- **Current checks:** flutter analyze --no-pub -> No issues found! (8.5s); format validation ->
  Formatted 125 files (0 changed) (1.28s); flutter test --no-pub --reporter expanded -> +126 All
  tests passed!; all exit 0. Successful retained controller probes not rerun, dated evidence retained.
- **Consistency/QA:** current orchestrator Node -> MD=24 JSON=24 fields=22 old IDs=17 dispositions=22
  errors=0; coverage13/5/8/1 and nine allowed paths, exit 0. git diff --check exit 0. Independent QA
  read/grep inspection found no blocking docs contradiction/missing lead/field; Git scope passed.
  Whole-stage NOT RUN; denied Node command not retried or bypassed by QA.
- **Temp review:** metadata/inventory only, 1,351 files/1,369,316,592 bytes; no observed reparse
  points. Creation attribution supports A2, exclusivity cannot be proved; no content read or deletion.
  Exact-directory user review/approval required before disposal. External metadata CSV retained.
- **Remaining A2:** focused synthetic widget assertion for lead10 (stale auth error on recovery),
  QA and final completion assessment/A3 handoff. No product/dependency/permission changes.

## 2026-10-28 — A2 retained probe continuation (partial)

- A2 remains incomplete. Before touching the eight authorized dirty artifacts, external backup
  `C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a2-backup-20261028-171019` was verified:
  bundle clone = HEAD, archive/Git tree 549/549, SHA256 match for each of eight changes.
- New `docs/audit/phases/A2_PROBES.md` retains synthetic test source and procedure. Orchestrator
  reran `flutter test --no-pub --reporter expanded test/a2_retained_probe_test.dart` in the minimal
  isolated copy -> `+7: All tests passed!`, exit 0. Tests intentionally assert buggy behavior;
  bounded discard timeout and cross-owner controller-state adoption were observed with controls.
- QA independently reviewed probe/source without shell; real-account UI/RLS and post-await race
  remain `NOT RUN`. Findings classifications remain unchanged until reconciliation.
- Continuation checks on `7eb40f1`: analyzer `No issues found! (ran in 5.3s)`; formatter `125 files
  (0 changed)`; `flutter test --no-pub --reporter expanded` `+126: All tests passed!`; Node register
  comparison `MD=17 JSON=17 mismatches=0`; all exit 0. `git diff --check` exit 0.
- Safety: first temporary app copy may contain secret files; not read or shared. Explicit user
  approval required before removing the task-created temp copy. No product code or permanent tests
  changed; no commit/push. Next A2 action: triage 22 leads, reconcile register and final QA.

## 2026-10-28 — A2 recovery checkpoint (incomplete)

- **Task:** A2 only, recovered after model-usage interruption. Completion PARTIAL; stage acceptance
  `NOT RUN`. No product code/config/dependency/migration edits; no remediation or A3.
- **Baseline:** main `7eb40f1d7e553e9f136abb13f632b8bfb189dc3c`, remote equal, clean at recovery entry.
  API metadata confirms primary `gymlvl-orchestrator` for session `ses_e7e81bc84ffeWkbb0tV5jo0jwp`.
- **Changed:** new `docs/audit/phases/A2_FLUTTER.md`; updated audit findings/register/coverage/handoff
  and planning task board/handoff/this log. Eight authorized documentation paths only.
- **Recovered:** three historical read-only specialist reports and deleted temporary-probe output;
  labelled carried, not current runtime PASS. No unfinished background agent remains.
- **Resumed:** sequential QA concurrency/session-isolation challenge, Flutter workout screens/widgets
  inspection, context consistency review. Signout memory/timer-leak claim rejected; identity watch
  resets them. Registered independent source-supported FND-SEC-002 (P1/High/Needs Verification) for
  unchecked global snapshot owner. Appended CONC-001/DATA-001 evidence, preserved IDs/history/confidence.
- **Counts:** 17 findings: P0 0/P1 4/P2 6/P3 5/P4 2; Confirmed 2/High 13/Medium 2;
  Needs Verification 3/Accepted 12/Fixed 1/False Positive 1. Coverage 3 reviewed/15 in review/8 not
  reviewed/1 excluded. 22 untriaged leads persisted separately; no inflated finding total.
- **Current checks:** `flutter analyze --no-pub` -> `No issues found! (ran in 4.2s)`, exit 0;
  formatting validation -> `Formatted 125 files (0 changed) in 0.73 seconds.`, exit 0;
  `flutter test --no-pub --reporter expanded` -> `+126: All tests passed!`, exit 0. Each `PASS`.
- **NOT RUN:** retained focused probes, device/rendered accessibility checks, final A2 acceptance.
- **Artifact checks:** orchestrator inline Node -> `findings MD=17 JSON=17; required fields=22`,
  zero mismatches; coverage 3/15/8/1. `git diff --check` -> no whitespace errors; status only eight
  authorized docs. Independent artifact QA verified Git scope/HEAD/whitespace, but its Node check
  `BLOCKED` (`Permission denied: shell`). No gate was widened or denial bypass attempted.
- **Git:** no commit/push while incomplete; current authorization permits normal A2 checkpoint only
  after closure. No new architecture/dependency/permission decision.
- **Next:** retained real-controller discard/account-switch probe, then lead reconciliation, final QA
  and exact A3 prompt. Remain inside A2.

**Rules:** one entry per session/checkpoint; list exact files, commands, and statuses; never claim a
test that was not run; distinguish prior-session evidence from current-session evidence.

---

## 2026-10-28 — A1: architecture, dependencies, configuration and infrastructure audit

**Task:** A1 of the full codebase audit program — read-only review of architecture, dependency
manifests, Flutter/Dart analyzer and build configuration, localization, CI/CD, OpenCode agent
governance, migration ordering, and cross-component configuration contracts.
**Status:** `PASS` (10 new findings; 2 A0 inventory figures corrected; 4 checks `NOT RUN` with reasons).
**Baseline:** `main` @ `e8c7c8e` = `origin/main` at entry; tree clean.
**Authoring agent:** **`gymlvl-orchestrator`**, proven from the server — `GET /api/session/
ses_e7e81bc84ffeWkbb0tV5jo0jwp` → `"agent":"gymlvl-orchestrator"`, `"location":{"directory":
"D:\\Projects\\gymlvl"}`. Every audit artifact in this entry was written while running as that agent,
which is the end-to-end confirmation `FND-GOV-001` needed.
**Scope:** audit artifacts and planning memory only. No application code, SQL, CI, dependency, or
configuration file was modified. No dependency was installed, no build artifact produced, no database
started.

### Changed

- `docs/audit/phases/A1_ARCHITECTURE.md` — **new**, 546 lines: baseline and acting-agent verification,
  architecture and module map, dependency and toolchain analysis, platform/build/localization
  configuration, CI gate review, agent-rule gate probes, migration ordering and structural census,
  configuration contracts, the stale-claim inventory, observations not promoted to findings, the
  verification log, and what a resuming session must not assume.
- `docs/audit/MASTER_FINDINGS.md` — header moved to A1/`e8c7c8e`/16 findings; `FND-GOV-002` extended
  with the completed inventory (15 stale claims, nine documents) and a wider path list; ten new
  findings added with every required field; eight observations added to "Not findings".
- `docs/audit/FINDINGS_REGISTER.json` — ten findings appended, counts recomputed, `FND-GOV-002` paths,
  line ranges, evidence, remediation and dependencies updated. Verified by script: 16 findings,
  declared counts equal actual counts, all 22 fields present on every entry, Markdown and JSON agree on
  every ID/severity/confidence/status.
- `docs/audit/AUDIT_COVERAGE.md` — C-22 and C-26 moved to `Reviewed (static)` with named reviewers,
  C-25 extended with the A1 probe evidence, C-20 annotated (44 statements, 22 effective), inventory
  corrected (migrations 1,377 total / 1,219 non-blank; `verify.yml` 52 lines), remaining-work counts
  updated to 3 reviewed / 1 in review / 22 not reviewed / 1 out of scope.
- `docs/audit/SESSION_HANDOFF.md` — rewritten: A1 `PASS`, 16-finding table, Git state, what A1 did,
  the exact A2 prompt with executor guidance and seven acceptance criteria, and nine open
  investigations.
- `docs/planning/TASK_BOARD.md`, `docs/planning/SESSION_HANDOFF.md`, this file — A1 recorded.

### Findings added

| ID | Title | Sev | Conf | Wave |
|---|---|---|---|---|
| `FND-BUG-001` | Android release manifest declares no `INTERNET` permission | P1 | High | W1 |
| `FND-BUG-002` | Release build is signed with the debug keystore | P2 | High | W1 |
| `FND-BUG-003` | Platform display name is the Flutter template default | P4 | High | W1 |
| `FND-TEST-001` | CI cannot detect platform, formatting, or generated-code regressions | P2 | High | W3 |
| `FND-INTG-001` | Documented local auth redirect is not in the Auth allowlist | P3 | High | W4 |
| `FND-ARCH-002` | Two localization mechanisms; the standard one carries no product text | P3 | High | W4 |
| `FND-ARCH-003` | Stated timezone invariant is narrower than the per-user implementation | P3 | High | W4 |
| `FND-GOV-004` | Git approval gates do not match the operations `AGENTS.md` §8 forbids | P2 | High | W1 |
| `FND-SEC-001` | Shell secret gates cover a short list of command spellings | P2 | High | W1 |
| `FND-GOV-005` | Stale analyzer transcript tracked as `app/analysis.txt` | P4 | High | W4 |

### Verification (this session, `e8c7c8e`)

| Check | Command | Result | Status |
|---|---|---|---|
| Branch / HEAD / remote | `git rev-parse --abbrev-ref HEAD`, `git rev-parse HEAD`, `git ls-remote origin refs/heads/main` | `main`, `e8c7c8e7e346790ac1807dc5c8d4e43c2ee880ef`, remote identical | `PASS` |
| Tree | `git status --porcelain=v1` | `CLEAN (0 entries)` at entry | `PASS` |
| Active agent | `opencode-cli.exe api get /api/session/ses_e7e81bc84ffeWkbb0tV5jo0jwp` | `"agent":"gymlvl-orchestrator"` | `PASS` |
| Toolchain | `flutter --version` | `Flutter 3.38.5 • channel stable`, `Tools • Dart 3.10.4` | `PASS` |
| Static analysis | `cd app; flutter analyze` | `No issues found! (ran in 2.5s)`, exit 0 | `PASS` |
| Formatting | `cd app; dart format --output=none --set-exit-if-changed lib test` | `Formatted 125 files (0 changed)`, exit 0 | `PASS` |
| Rule model, documented probes | `node gymlvl-perm-check.mjs` | `RULES VALIDATED: 73 global + 62 agent`; `RESULT: PASS (0 probe failures, 0 schema problems)` | `PASS` |
| Rule model, 18 destructive/secret probes | `node a1-git-gate-probe.mjs` | `RESULT: FAIL (12 probe failures, 0 schema problems)` | `FAIL` — recorded as `FND-GOV-004`/`FND-SEC-001` |
| Register sync | `node a1-sync-check.mjs` | `md findings: 16 json findings: 16`; `mismatches: 0` | `PASS` |
| Migration census | `node a1-lines2.mjs` + policy/trigger/function census | 661/349/367 lines (1,377 total, 1,219 non-blank); 17 tables; 44 policy statements → 22 effective; 11 `SECURITY DEFINER`; 10 triggers | `PASS` |
| Localization census | `node a1-l10n.mjs` | `outer keys: 104`; `'vi' entries: 104`; `'en' entries: 104` | `PASS` |
| Product regression (`flutter test`, SQL harness, Edge tests) | not rerun — no product or test file changed | — | `NOT RUN` |
| `flutter build web` / `apk` / iOS | not attempted — writes artifacts, needs an SDK host | — | `NOT RUN` |
| `supabase start` + auth recover | not attempted — starts a local stack and mutates local state | — | `NOT RUN` |

### Notes

- A1's four specialist reviews were read-only and sequential (D-021). Every claim that reached a
  finding was re-derived by the orchestrator with a quoted command; no subagent `PASS` was accepted as
  evidence.
- `FND-BUG-001`/`002`/`003` and `FND-TEST-001` overlap `TASK_BOARD` §M1-02/§M1-05, which planned those
  fixes but never registered them. The register now carries IDs so the fixes can be closed with
  evidence.
- The Android release defects are invisible to the current CI because it builds web only; that is the
  substance of `FND-TEST-001`, not a separate claim.

### Checkpoint

| Item | Value |
|---|---|
| Commit | `c9cc764` — `docs(audit): complete A1 architecture, dependencies and infrastructure audit`; 8 files, +1,716/−181 |
| Push | `git push origin main` → `e8c7c8e..c9cc764  main -> main`, exit 0 (normal push, authorized for this task) |
| Remote | `git ls-remote origin refs/heads/main` → `c9cc7649f582a7740232fb206d5319bd32c0db99`, equal to local `main` |
| Force push | not used, not requested |
| Amend | one approved `--amend` on the unpushed commit `149fb09`, to strip a UTF-8 BOM that PowerShell `Out-File -Encoding utf8` had prepended to the subject line. Nothing had been pushed before the amend |
| Tree after commit | clean — `git status --porcelain=v1` empty |

---


**Task:** S5 — reconfigure the seven-agent system for full development autonomy (decision D-024).
**Status:** `PASS`.
**Baseline:** `main` @ `425686c`; `origin/main` at `9c8e142` before this session's push.
**Authoring agent:** **`build`**, not `gymlvl-orchestrator` — server record
`ses_e7e999dd2ffdO3oGdRJnVFBuY1` reports `"agent":"build"`. The orchestrator was exercised in separate
throwaway sessions via `opencode-cli.exe run --agent gymlvl-orchestrator`.
**Scope:** agent permission policy, agent prose, governance documentation, `.gitignore`-free temporary
probe files, one local commit and one normal push. No application code, SQL, Edge Function, CI,
dependency, UI, or media change.

### Changed

- `.opencode/opencode.jsonc` — rewritten as a single ordered rule list. `permissions: []` (empty
  before) → **73 rules**: broad `allow` for `read`, `edit`, `glob`, `grep`, `shell`, `webfetch`,
  `websearch`, `external_directory`, `question`, `skill`; then `ask` gates for Git history rewriting
  (force-push in five forms, `--mirror`, `--delete`, `reset --hard`, `rebase`, `filter-branch`,
  `commit --amend`, `branch -D`, `restore`, `checkout --`, `clean`, `stash drop|clear`), bulk deletion
  (`Remove-Item -Recurse`, `rm -rf`, `rm -r`, `rmdir /s`), production Supabase and deploy (`db push`,
  `db reset --linked`, `db remote`, `link`, `unlink`, `functions deploy`, `projects`, `secrets`,
  `psql`), and secret reads by both the `read` tool and the shell forms (`Get-Content`, `type`, `cat`,
  `more`). `subagent *` → `deny`, the six named GymLvl specialists → `allow`,
  `gymlvl-orchestrator` → explicit `deny` (`mode: primary`).
- `.opencode/agents/gymlvl-orchestrator.md` — the 27-rule allowlist block deleted; prose updated
  ("Hard refusals" now describes the `ask` gates and permits normal Git work).
- `.opencode/agents/flutter-specialist.md`, `supabase-specialist.md`, `exercise-catalog.md`,
  `ui-ux-specialist.md` — `permissions` block deleted; scope prose widened (dependencies, remote DB
  gating, web research for provenance, presentation ownership).
- `.opencode/agents/qa-reviewer.md` — 35 → 41 rules, still read-only: `edit *` → `deny`, shell `deny`
  fallback over a widened inspection/test allowlist, plus secret shell gates repeating after the broad
  `Get-Content *` allow. `webfetch`/`websearch`/`subagent` remain `deny`.
- `.opencode/agents/context-keeper.md` — 17 → 21 rules, same read-only shape.
- `docs/planning/DECISIONS.md` — **D-024** added (supersedes D-022, changes the mechanism of D-019).
  The summary table still stops at D-014; not backfilled, that stays W4 / `FND-GOV-002`.
- `docs/audit/SESSION_HANDOFF.md`, `docs/audit/MASTER_FINDINGS.md`,
  `docs/audit/FINDINGS_REGISTER.json` — `FND-GOV-001` now verified end-to-end; `FND-GOV-003` carries a
  post-D-024 note; A1 marked `NOT STARTED`.
- `docs/planning/SESSION_HANDOFF.md`, `docs/planning/TASK_BOARD.md` — D-024 state, verification table,
  S5 `DONE`, A1 unchanged.

### Added

- `docs/agent-system/ACCESS_POLICY.md` — what the configuration actually enforces, the 66-probe
  effective-permission simulation, the runtime probe table, the two fixed gaps, and known limitations.

### Verification

| Check | Result | Status |
|---|---|---|
| `.opencode/opencode.jsonc` parses | `OK (73 global rules, default_agent=gymlvl-orchestrator)` | `PASS` |
| Effective permissions (not file text) | `RESULT: PASS (0 probe failures, 0 schema problems)` over 66 probes, 73 global + 62 agent rules | `PASS` |
| Secrets gate covers shell, not just `read` | probe #1 found the gap; rules added; `Get-Content .env` → `ask` | `PASS` (after fix) |
| `*.env.production` matched | probe #2 found the gap; `*.env.*` rules added; `Get-Content app/.env.production` → `ask` | `PASS` (after fix) |
| Server reloaded the definitions | 8 `agent.updated` events, `07:33:43.390Z`–`07:34:31.580Z`, one per file write | `PASS` |
| Active agent of this session | `GET /api/session/ses_e7e999dd2ffdO3oGdRJnVFBuY1` → `"agent":"build"` | `PASS` |
| Shell access | `node --version` → `v22.17.1`; `Get-ChildItem`/`Select-String`/`Remove-Item` all executed | `PASS` |
| Git read access | `git status --porcelain=v1`, `git log --oneline -8`, `git ls-remote origin refs/heads/main` → `9c8e142…` | `PASS` |
| Web access | `webfetch https://opencode.ai/v2/docs/permissions` → full page | `PASS` |
| Orchestrator write, previously denied path | `app/.perm-probe-2.md` written; `Test-Path` → `True`, `Get-Content` → `probe` from a different session | `PASS` |
| Orchestrator shell, previously denied command | same session: `node --version` → `v22.17.0` | `PASS` |
| Subagent delegation | `subagent(qa-reviewer)` completed and returned evidence | `PASS` |
| Reviewer write denial | `Set-Content docs/audit/.qa-write-probe.md` → `{"error":{"type":"permission.rejected",...}}`; `Test-Path` → `False` | `PASS` (denied) |
| Reviewer Git write denial | `git commit --allow-empty -m "probe"` → `permission.rejected`; HEAD unchanged | `PASS` (denied) |
| Reviewer tool surface | `tools.write` / `tools.edit` → `Unknown tool` | `PASS` (absent) |
| Reviewer compound command | `git status; flutter analyze` → `permission.rejected` (per-segment allowlist) | `PASS` (denied) |
| Secret gate at runtime | no `.env`, `.pem`, or key file exists in the workspace | `NOT RUN` |
| Product regression (`flutter analyze`/`test`, SQL, Edge) | not rerun — no product or test file changed; A0 baseline stands as carried-forward evidence | `NOT RUN` |
| `FINDINGS_REGISTER.json` | parses; 6 findings; `P1:2, P2:2, P3:2` matches declared counts | `PASS` |

### Git

| Item | Value |
|---|---|
| Branch | `main` |
| Commit | `947da1e` — `feat(agents): grant full development access with approval gates (D-024)`; 16 files, +677/−429 |
| Push | `git push origin main` → `9c8e142..947da1e  main -> main`, exit 0 (normal push, authorized for this task) |
| Remote | `git ls-remote origin refs/heads/main` → `947da1ef5128f8a19ca6c9dbafd3c7253ed2576c`, equal to local `main` |
| Force push | not used, not requested |
| Tree after commit | clean — `git status --porcelain=v1` empty |

### Not done, deliberately

- **A1 was not started.** The earlier A1 instruction was withdrawn before any review ran;
  `docs/audit/phases/A1_ARCHITECTURE.md` does not exist. A stub created during a permission probe was
  deleted.
- **`DECISIONS.md` summary table was not backfilled** (D-015…D-024). That is the existing `FND-GOV-002`
  / W4 scope, not this task.
- **`deny` became `ask`, never `allow`.** No formerly forbidden operation was silently permitted.
- **Product regression was not rerun**: `git status --porcelain=v1` before staging showed only
  `.opencode/**` and `docs/**`.
- **The first orchestrator probe was discarded as evidence**: it reported a write of
  `app/.perm-probe-orchestrator.md` that was absent at cleanup, cause not established. Only the repeat,
  asserted from a second session, is relied on.

---

## 2026-10-28 — Audit A0.1: governance fix and A0 checkpoint

**Task:** A0.1 — Multi-agent governance fix (`FND-GOV-001`) and durable Git checkpoint.
**Status:** `PASS` for the configuration fix; Git push `BLOCKED` by the project deny rule.
**Baseline:** `main` @ `9c8e142` = `origin/main`, tree carrying the uncommitted A0 artifacts.
**Scope:** one agent permission rule, audit documents, planning records, one local commit. No
application code, SQL, Edge Function, CI, dependency, UI, or media change.

### Root cause recorded

`default_agent` is a **session-creation** default, not a live switch (OpenCode V2, *Config → Agent*).
The session was created before the setting existed, so it kept the built-in build agent. The server
**did** reload the edited agent definition — `agent.updated` at `2026-10-28T07:06:41.988Z`, one second
after the write — which rules out "the config is ignored". Recorded as D-023. Confirming the binding
requires a new session or explicit agent selection; it is **`NOT RUN`** here.

### Changed

- `.opencode/agents/gymlvl-orchestrator.md` (+5 lines): one rule
  `{ action: edit, resource: "docs/audit/*", effect: allow }` plus a two-line comment. No other rule
  added, removed, or reordered. Global Git floor untouched.
- `docs/planning/DECISIONS.md` — D-022 (audit write grant) and D-023 (`default_agent` semantics).
- `docs/audit/MASTER_FINDINGS.md`, `docs/audit/FINDINGS_REGISTER.json` — `FND-GOV-001` → `Fixed`,
  `FND-GOV-003` → `False Positive` (confidence `High`, wave `—`), counts corrected.
- `docs/audit/AUDIT_COVERAGE.md`, `docs/audit/REMEDIATION_PLAN.md`, `docs/audit/SESSION_HANDOFF.md` —
  coverage note for C-25, W0 status, A0.1 handoff with the A1 brief and acceptance criteria.
- `docs/planning/SESSION_HANDOFF.md`, `docs/planning/TASK_BOARD.md` — A0.1 state and the A0.1 row.

### Added

- `docs/audit/phases/A0_1_GOVERNANCE.md` — root-cause matrix, the change, 9-row verification matrix,
  finding resolutions, the reviewer error note, remaining gaps, Git section.

### Verification

| Check | Result | Status |
|---|---|---|
| Parse all 7 agent frontmatters | orchestrator edit: `*` deny, then `docs/planning/*`, `docs/agent-system/*`, `docs/audit/*` | `PASS` |
| Escalation scan | shell 15 (1 deny/14 allow), subagent 7 (1 deny/6 allow), webfetch/websearch/external_directory unchanged | `PASS` |
| Read-only agents | `qa-reviewer`, `context-keeper`: exactly one `edit` rule, `*` → deny | `PASS` |
| Primary mode | `subagent(gymlvl-orchestrator)` → `"Agent gymlvl-orchestrator cannot run as a subagent"` | `PASS` |
| Global Git floor | deny `push`, `reset --hard`, `clean -fd`, `clean -fdx`, `filter-branch`; ask commit/tag/rebase/checkout/switch/stash | `PASS` |
| `FINDINGS_REGISTER.json` | parses; 6 findings; declared counts equal actual counts | `PASS` |
| Independent reviewer | `qa-reviewer` read-only inspection, 6/6 checks | `PASS` |
| Product regression | **not rerun** — no application or test configuration changed; A0 baseline stands as carried-forward evidence | `NOT RUN` |
| End-to-end orchestrator write | needs a session whose selected agent is the orchestrator | `NOT RUN` |
| `git push origin main` | `permission.rejected` — the global `git push *` deny rule fired | `BLOCKED` |

### Git

| Item | Value |
|---|---|
| Branch | `main` |
| Commit | `e400dbc` — `chore(audit): allow orchestrator audit writes and checkpoint A0/A0.1` |
| Contents | 14 files, +1622/−38: 9 audit documents, 4 planning records, 1 agent configuration file |
| Push | `permission.rejected` — `{"error":{"type":"permission.rejected","message":"Permission denied: shell"}}` on `git push origin main`; not worked around (A0.1 forbids weakening the rule) |
| `origin/main` | unchanged at `9c8e142` — the checkpoint is local until pushed manually |

### Not done, deliberately

- The deny rule was **not** temporarily relaxed to allow the push (A0.1 forbids it; `AGENTS.md` §8
  forbids bypassing a protected Git operation). The commit is local and the manual push steps are in
  `docs/audit/SESSION_HANDOFF.md` §9.
- No security finding was invented to justify widening permissions. `qa-reviewer`'s claim that
  `git push *` fails to match bare `git push` was checked against the V2 docs and is wrong; it was not
  registered.
- Product regression was **not** rerun: no file under `app/`, `supabase/`, `tools/` or `.github/`
  changed, verified by `git status --porcelain=v1` before staging.

---

## 2026-10-28 — Audit A0: bootstrap, inventory, and execution plan

**Task:** A0 — Full codebase audit bootstrap, scope inventory, execution planning.
**Status:** `PASS` (with `FND-GOV-001` recorded as a governance gap)
**Baseline:** `main` @ `9c8e142` = `origin/main`, clean at entry.
**Scope:** Read-only inventory and audit documentation. No application code, schema, migration, Edge
Function, CI, dependency, or media change. No commit, no push.

### Added

- `docs/audit/README.md` — program definition, ID scheme, severity/confidence/status vocabulary.
- `docs/audit/AUDIT_SCOPE.md` — in/out of scope, constraints, inherited S3 candidates, limitations.
- `docs/audit/AUDIT_COVERAGE.md` — 27-component matrix, inventory counts, 6 recorded coverage gaps.
- `docs/audit/MASTER_FINDINGS.md` — 6 findings with full evidence blocks.
- `docs/audit/FINDINGS_REGISTER.json` — machine-readable mirror (`schema_version` 1.0.0).
- `docs/audit/REMEDIATION_PLAN.md` — W0–W5 framework, dependencies, non-goals.
- `docs/audit/SESSION_HANDOFF.md` — stage state, Git state, exact A1 prompt.
- `docs/audit/phases/A0_BOOTSTRAP.md` — baseline evidence, inventory, 10 high-risk targets.

### Changed

- `docs/planning/SESSION_HANDOFF.md` — current state reset to A0 close.
- `docs/planning/TASK_BOARD.md` — audit track A0–A6 added; M1 unchanged.

### Findings

| ID | Sev | Conf | Status |
|---|---|---|---|
| `FND-CONC-001` | P1 | Medium | `Needs Verification` — inherited from S3 L4 |
| `FND-DATA-001` | P1 | Medium | `Needs Verification` — inherited from S3 L5 |
| `FND-ARCH-001` | P2 | High | `Accepted` — inherited from S3 L6 |
| `FND-GOV-001` | P2 | Confirmed | `Accepted` — no agent can write `docs/audit/**` |
| `FND-GOV-002` | P3 | Confirmed | `Accepted` — `PROJECT_CONTEXT.md` stale on its own baseline |
| `FND-GOV-003` | P3 | Low | `Needs Verification` — shell matcher semantics |

### Verification

| Command | Result | Status |
|---|---|---|
| `git rev-parse HEAD` | `9c8e142a2bda18d031874438164c37c577dcc057` | `PASS` |
| `git status --porcelain=v1` | empty at A0 entry | `PASS` |
| `git ls-remote origin refs/heads/main` | `9c8e142…` — equal | `PASS` |
| `flutter analyze` | `No issues found!` exit 0 | `PASS` |
| `flutter test` | `All tests passed!` 126/126 exit 0 | `PASS` |
| `npm.cmd test` (SQL) | `PASS 10 SQL verification units` exit 0 | `PASS` |
| `npm.cmd run test:edge` | `15 passed | 0 failed` exit 0 | `PASS` |

### Not verified

- No runtime reproduction of any finding. All findings are static reads or imports from S3. `NOT RUN`.
- No live Supabase stack, no device build, no coverage measurement. `NOT RUN`.

### Governance observation

The active agent was the built-in build agent, not `gymlvl-orchestrator`. Proven by successful writes
outside the orchestrator's allowlist (`.opencode/` edit, external temp file, `docs/audit/` write). This
is consistent with S3 L2 and is the reason `FND-GOV-001` matters: the designated agent cannot write the
audit directory at all.

---

## 2026-10-28 — S3 validation, language policy, and first infrastructure checkpoint

**Task:** S3 — Multi-agent validation and optimization.
**Status:** `PASS`
**Baseline:** `main` @ `b4063c6` at start; infrastructure checkpoint `59450c0` pushed to `origin/main`.
**Scope:** Validation, documentation, agent configuration, and an authorized Git checkpoint. No
application code, SQL, Edge Function, CI, dependency, UI, or media change.

### Added

- `docs/agent-system/S3_VALIDATION_REPORT.md` — agent matrix, skill matrix, five delegation tests,
  context measurements, regression results, risks, Wave 2 recommendations.
- `AGENTS.md` §0.1 — permanent language policy (Vietnamese user-facing, English artifacts, Vietnamese
  human action guides), plus item 8 in §0.

### Changed

- `.opencode/agents/gymlvl-orchestrator.md` — `## Language` block referencing §0.1.
- `AGENTS.md` — baseline line now names both `17ca562` and the current HEAD, and says to confirm with
  `git rev-parse main`.
- `docs/planning/DECISIONS.md` — D-020 language policy, D-021 sequential shell-dependent subagents.
- `docs/planning/TASK_BOARD.md` — S3 `DONE`, S4 `PLANNED`; M1 unchanged.
- `docs/planning/SESSION_HANDOFF.md` — current state reset to S3 close.

### Verification

| Command | Result | Status |
|---|---|---|
| `flutter analyze` | `No issues found!` exit 0 | `PASS` |
| `flutter test` | `All tests passed!` 126/126 exit 0 | `PASS` |
| `dart format --set-exit-if-changed lib test` | `125 files (0 changed)` exit 0 | `PASS` |
| `npm.cmd test` (SQL) | `PASS 10 SQL verification units against PostgreSQL 17.5` exit 0 | `PASS` |
| `npm.cmd run test:edge` | `ok | 15 passed | 0 failed` exit 0 | `PASS` |
| Config JSONC parse | valid, 11 global rules | `PASS` |
| Agent discovery | 6 subagents invoked/enumerated; primary rejected as a subagent | `PASS` |
| Read-only enforcement | `qa-reviewer` and `context-keeper` have no edit rule; neither wrote | `PASS` |
| Delegation TEST A | Invalid XP fixture → `FAIL`, severity Critical | `PASS` |
| Delegation TEST B | State restored; git commands ran; no writes | `PASS` |
| Delegation TEST C | Module assessed; Riverpod 3 compatible; 2 risks flagged | `PASS` |
| Delegation TEST D | `complete_workout` idempotency reviewed; legacy path risk flagged | `PASS` |
| Delegation TEST E | Routing exercised | `PASS`; new-session `default_agent` binding `NOT RUN` |
| Deliberate failing test | `No tests ran` → reported `FAIL` | `PASS` |

### Not verified

- `default_agent` binding for a **new** session. This session predates the configuration. `NOT RUN`.
- Runtime application of the reviewed migration. No database change was made. `NOT RUN`.
- Wave 2 skills. Not imported by design. `NOT RUN`.

### Findings recorded, not fixed (out of scope)

- `active_workout_controller.dart` L207-215 potential deadlock; L659-670 null dereference after await.
- `complete_workout` L230 legacy path could double-award a pre-existing row.
- The invariant "only `complete_workout` writes XP" is imprecise: `initialize_user`, `sync_daily_data`,
  and `switch_class` also write progression state.

---

## 2026-10-28 — S2 Wave 1: agent system installed (uncommitted)

**Task:** S2 — Multi-agent configuration and skill integration, Wave 1.
**Status:** `PASS`
**Baseline:** `main` @ `b4063c6`. Source library pinned at `c4a059bb…`.
**Scope:** Tooling configuration only. No application code, SQL, Edge Function, CI, dependency, UI, or
media change. No commit, push, tag, or branch change.

### Created

- `.opencode/opencode.jsonc` — schema, `default_agent: gymlvl-orchestrator`, global Git permission floor.
- `.opencode/agents/` — 7 agents: `gymlvl-orchestrator` (primary), `flutter-specialist`,
  `supabase-specialist`, `exercise-catalog`, `ui-ux-specialist`, `qa-reviewer`, `context-keeper`.
- `.opencode/skills/` — 6 adapted skills: `flutter-expert`, `postgres-best-practices`, `postgresql`,
  `test-driven-development`, `systematic-debugging`, `context-window-management`.
- `.opencode/commands/` — 6 commands: `plan`, `orchestrate`, `test`, `audit`, `debug`, `mobile`.
- `docs/agent-system/THIRD_PARTY_NOTICES.md` — attribution ledger, written before import.
- `docs/agent-system/WAVE1_IMPLEMENTATION.md` — implementation record and rule mapping.

### Changed

- `docs/planning/DECISIONS.md` — D-015 … D-019 accepted; O-10, O-11 added.
- `docs/planning/TASK_BOARD.md` — tooling track added; tree-state claim corrected.
- `docs/planning/SESSION_HANDOFF.md` — current state section added; prior record marked historical.

### Verification (this session)

| Command | Result | Status |
|---|---|---|
| `flutter analyze` | `No issues found!` exit 0 | `PASS` |
| `flutter test` | `All tests passed!` 126/126 exit 0 | `PASS` |
| Structure | 7 agents, 6 skills with `SKILL.md`, 6 commands | `PASS` |
| JSONC parse | valid; `default_agent=gymlvl-orchestrator` | `PASS` |
| Hygiene grep | only the intentional `git push`/`git commit` deny rules matched | `PASS` |
| Reference integrity | every referenced skill ID and command `agent:` target resolves | `PASS` |
| `qa-reviewer` deliberate FAIL | `flutter test --plain-name …` → exit 1, `No tests ran` | `PASS` |
| `context-keeper` restore | read-only state block, no writes | `PASS` |
| `git status --porcelain=v1` | `?? .opencode/`, `?? docs/agent-system/` only | `PASS` |

### Not verified

- OpenCode `--version` command: the `opencode` binary is not on `PATH`. Version was read from the
  installed application instead — Desktop ProductVersion `2.2.0`, `opencode-cli.version` `2.2.0`,
  `opencode-cli.exe` metadata `1.4.4` (inconsistent; noted, not resolved). `NOT RUN` as a command.
- Wave 2 skills: not imported. `NOT RUN` by design.
- Migration/policy execution: no database change was made. `NOT RUN`.

### Decisions

D-015 project-local `.opencode/`; D-016 read-only `qa-reviewer` and `context-keeper`; D-017 skills
rewritten not vendored; D-018 existing `.agent/` and `.agents/teamwork/` preserved; D-019 Git
protection enforced by permissions.

### Backup

`C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-s2-backup-20261028\` — `main.bundle` verified
("records a complete history"), plus the four S1 documents.

---

## 2026-10-28 — Main consolidation and main-only workflow

**Task:** Consolidate `codex/supabase-product-audit` into `main`, commit the nine memory files, and
establish `main` as the only development branch.
**Status:** `PASS`
**Baseline:** `main`; consolidation checkpoint `17ca562`; the workflow-doc commit containing this
entry is the current `main` HEAD.
**Scope:** Git consolidation and documentation only. No application code, SQL migration, Edge
Function, CI config, dependency, UI, or media change.

### Changed

- Committed the nine memory files: `AGENTS.md` and `docs/planning/{MASTER_PLAN,M0_AUDIT,
  PROJECT_CONTEXT,ARCHITECTURE,DECISIONS,TASK_BOARD,SESSION_HANDOFF,CHANGELOG_AI}.md` — `17ca562`,
  9 files, +2,015 lines.
- Fast-forwarded `main` from `e003803` to `17ca562`; no merge commit, no conflicts.
- Pushed `main`: `e003803..17ca562  main -> main` (no force).
- Workflow docs: `AGENTS.md` (baseline + `main`-only rule), `DECISIONS.md` (D-014),
  `SESSION_HANDOFF.md`, `TASK_BOARD.md`, `PROJECT_CONTEXT.md`, `MASTER_PLAN.md`, this entry.
- Retained `codex/supabase-product-audit` at `17ca562`; nothing deleted.

### Backup (pre-consolidation)

`C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-backups\20261028-main-consolidation\`

| Artifact | SHA-256 |
|---|---|
| `gymlvl-pre-consolidation-all-refs.bundle` | `CB9AA6E1C1A91C8178114D53E2375B0ED0788D808DFA0CBA4F8D80FDF4251F00` |
| `gymlvl-pre-consolidation-HEAD.zip` | `CD458094BA1F20176C6080F3DC59F9D5432E6862C6E2B748B2203805FD9444C9` |
| `gymlvl-uncommitted-memory-files.tgz` | `4DFB158D1255F26E029E854C4A91608E0B6058F2DE324A140EBB9BAE5C714D62` |

Verified: bundle clone HEAD = `56c1122`; archive 502 files = Git tree 502; untracked archive 9 files,
all hashes matched.

### Verification (this session, `17ca562`)

| Command | Result |
|---|---|
| `git merge-base --is-ancestor main codex/supabase-product-audit` | `PASS` — fast-forward safe |
| `git merge --ff-only codex/supabase-product-audit` | `PASS` — `e003803..17ca562` |
| `flutter analyze` | `PASS` — 0 issues |
| `flutter test` | `PASS` — 126/126 |
| `dart format --output=none --set-exit-if-changed lib test` | `PASS` — 125 files, 0 changed |
| `npm test` (db-tests) | `PASS` — 10/10, PostgreSQL 17.5/PGlite |
| `npm run test:edge` | `PASS` — 15/15 |
| `git push origin main` | `PASS` — `e003803..17ca562` |
| `git ls-remote origin refs/heads/main` | `PASS` — equal to local `main` |
| Android release build/device smoke | `NOT RUN` |
| iOS build | `NOT RUN` |
| Live Supabase / AI provider | `NOT RUN` |

### Decisions

D-014 (`main` is the sole development branch) accepted by explicit user instruction. D-011's
`56c1122` baseline is historical; `main` @ `17ca562` is current. D-009 (no automatic Git writes)
remains in force; this consolidation was explicitly authorized.

### Blockers

None for the consolidation. M1-01 prerequisites and platform blockers are unchanged.

### Next

**M1-01 — Baseline stabilization and evidence lock.** Documentation/verification only. Requires
explicit user go-ahead.

---

## 2026-10-28 — Persistent context bootstrap

**Task:** Create a durable, model-independent project memory and handoff system.
**Status:** `PASS`
**Baseline:** `codex/supabase-product-audit` @ `56c1122`; baseline tree clean at session start, nine
bootstrap files uncommitted after this session.
**Scope:** documentation only. No application code, SQL, Edge Function, CI, dependency, or UI change.

### Created

- `AGENTS.md`
- `docs/planning/MASTER_PLAN.md`
- `docs/planning/M0_AUDIT.md`
- `docs/planning/PROJECT_CONTEXT.md`
- `docs/planning/ARCHITECTURE.md`
- `docs/planning/DECISIONS.md`
- `docs/planning/TASK_BOARD.md`
- `docs/planning/SESSION_HANDOFF.md`
- `docs/planning/CHANGELOG_AI.md`

### Preserved

- `docs/planning/GymLvl_OpenGym_Migration_Master_Plan.md` — untouched.
- `docs/planning/GymLvl_License_Ledger_Starter.csv` — untouched.
- All existing source, docs, tests, and Git history.

### Backup

- Bundle: `C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-backups\20261028-pre-memory-bootstrap\gymlvl-all-refs.bundle`
  - SHA-256 `C8DAC1F53827A8E43BBC5A0753E66690990BFA51268CF04433B176F05332AB52`
- Archive: `...\gymlvl-HEAD-56c1122.zip`
  - SHA-256 `CD458094BA1F20176C6080F3DC59F9D5432E6862C6E2B748B2203805FD9444C9`
- Verified: bundle clone HEAD = `56c1122`; archive 502 files = Git tree 502 files.

### Verification (this session, `56c1122`)

All nine files were read back; all relative links resolve; the original master plan and license
starter still match their `HEAD:` blob hashes.

| Command | Result |
|---|---|
| `flutter analyze` | `PASS` — 0 issues |
| `flutter test` | `PASS` — 126/126 |
| `dart format --output=none --set-exit-if-changed lib test` | `PASS` — 125 files, 0 changed |
| `npm test` (db-tests) | `PASS` — 10/10, PostgreSQL 17.5/PGlite |
| `npm run test:edge` | `PASS` — 15/15 |
| Android release build/device smoke | `NOT RUN` |
| iOS build | `NOT RUN` |
| Live Supabase / AI provider | `NOT RUN` |

### Findings recorded

- The M0 report was chat-only; no file existed. `M0_AUDIT.md` is a labelled reconstruction.
- The M0 dirty workspace (166 entries at `e003803`) was committed and pushed as `56c1122` outside
  this session; tree is clean. Actor/timing unverified.
- Open defects remain: missing Android `INTERNET`, placeholder app names, chat-only coach,
  network-first logging, 150-exercise catalog, name-only search, missing plans/progression/PRs,
  stale docs, no LICENSE.
- Current OpenGym B catalogue is 6,554 exercises, correcting the original plan's 5,632.
- Original plan's M1 design-system scope is already implemented; M1 re-baselining to stabilization is
  proposed, not approved.

### Decisions

D-010 (canonical memory files), D-012 (documentation-only bootstrap), and D-013 (verified backup)
accepted. D-002 (no AGPL reuse / MIT text only) and D-007 (AI proposal/approval contract) are accepted
for current constraints. D-004 (M1 re-baseline) and D-005 (Drift) remain proposed, not approved.

### Next

**Proposed next: M1-01 — Baseline stabilization and evidence lock.** Documentation/verification only.
Requires explicit user go-ahead. No commit, push, or tag without approval.

---

## 2026-10-27/28 — M0 audit and migration plan

**Task:** Repository audit, reference analysis, migration planning, M1 proposal.
**Status:** `DONE` (reported; planning only)
**Baseline at the time:** `codex/supabase-product-audit` @ `e003803`, 166 dirty entries.
**Scope:** no application, SQL, deployment, or production changes; no commit or push.

### Evidence reported by the prior session

| Command | Result |
|---|---|
| `flutter analyze` | `PASS` — 0 issues (54s) |
| `flutter test` | `PASS` — 126/126 |
| `npm test` (db-tests) | `PASS` — 10/10 SQL units on PostgreSQL 17.5/PGlite |
| `npm run test:edge` | `PASS` — 15/15 Deno tests |
| Android release build/device smoke | `NOT RUN` (blocked/unknown SDK) |
| iOS build | `NOT RUN` (Windows host) |
| Live Supabase / AI provider | `NOT RUN` |

### Reference revisions verified

- `emilfunk/opengym` — `678bf5bf10446e8997a77d43e89c9b2721d8d0fc` — AGPL-3.0.
- `DuarteSantos8/openGym` — `e6a95c28a6e3067bdd9b1188d5f37f448d528bd2` — AGPL-3.0 + non-transferable
  app-store exception.
- `hasaneyldrm/exercises-dataset` — `7455efae41b330c265e7cd4b78dfa848e7ce5ebd` — MIT text/data;
  media excluded.

### Findings

- GymLvl: 17 tables, 150 curated exercises, classes A–F, server-authoritative completion, hardened
  RLS.
- OpenGym A: 1,324-exercise library + file-backed coach; plan/engine separation.
- OpenGym B: 6,554 exercises, 17 translations, 13,109 media files; richer engine and schema-validated
  coach v2.
- Dataset: 1,324 records, 10 languages, complete English text, no difficulty/movement metadata,
  media not MIT.
- Defect register G-01…G-15 created; top risks were the missing Android `INTERNET` permission and
  the 166 uncommitted entries.
- Proposed M1 as release-critical stabilization after the design-system scope was found already
  implemented.

### Artifacts

- The M0 report existed only in the session transcript; no file was written.
- The original plan `GymLvl_OpenGym_Migration_Master_Plan.md` v1.0 remained untouched.
- License starter `GymLvl_License_Ledger_Starter.csv` remained untouched.

### Next

Bootstrap durable memory (completed 2026-10-28), then **M1-01**.

---

## Template for future entries

```markdown
## YYYY-MM-DD — <task ID and title>

**Task:**
**Status:** PASS | FAIL | BLOCKED | NOT RUN
**Baseline:** branch @ short SHA; tree state
**Scope:**

### Changed
- exact paths

### Verification
| Command | Result |
|---|---|

### Decisions
- IDs and approval state

### Blockers
- exact prerequisite

### Next
- one concrete action with task ID
```
