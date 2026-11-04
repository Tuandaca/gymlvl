# GymLvl — Session Handoff

## Current — M5 — First-Week Plan, Analytics, Bodyweight & Newcomer Journey (2026-11-04)

**Task:** M5 — complete M5 milestone: first-week training plan generation/selection, newcomer journey state machine, analytics (heatmap, weight trend, PR chart, muscle balance), bodyweight trend with weight_kg-as-external-load semantics, Candy UI, VI/EN, additive SQL schema, focused tests, independent QA. Per MASTER_PLAN §3 and exit gate "Beginner completes three workouts from a generated plan; charts reconcile."
**Status:** `PASS` — M4 and M3 are CLOSED for development. M5 complete (Agent E independent QA `PASS`; no P0–P1 findings). Production activation remains gated (`complete_workout` stays sole PostgreSQL reward authority; offline gates `false`). No commit, push, tag, deploy, or remote migration.
**Commit:** `main` @ `b6b0172871d7d18e9d9c27eca3f883d381f5b206`; working tree dirty by pre-existing M3 + M4 work (preserved), index empty.
**Subagents:** Agent A (First-Week Plan / Newcomer Domain), Agent B (Analytics), Agent C (Bodyweight), Agent D (Flutter UX), Agent E (Independent QA).
**Dependencies:** M3 (offline, modes, supersets, timer, idempotency), M4 (progression, 1RM, PR, RPE/RIR, RPG bridge, complete_workout authority).
**Exit gate:** Beginner completes three workouts from a generated plan; charts reconcile.
**Agent A status:** `PASS` — First-Week Plan + Newcomer Journey domain implemented (plain immutable Dart, no freezed/codegen) and verified: 25 tests pass (11 first_week_plan + 14 newcomer_journey), analyze clean, format clean. Files: `app/lib/features/training_plan/{first_week_plan_models,first_week_plan_engine,newcomer_journey_models,newcomer_journey}.dart` + `app/test/{first_week_plan_test,newcomer_journey_test}.dart`. Replaced broken untracked `training_plan/domain/` freezed scaffolding (missing `.freezed.dart` parts) that blocked analyze. Files uncommitted; no commit/push/tag performed.
**Agent B status:** `PASS` — M5 analytics domain implemented and verified: 11 Flutter tests PASS, `flutter analyze` no issues, `dart format` clean, SQL `m5_analytics.sql` PASS, `npm test` → 20 SQL units + 365 ACL assertions PASS. Migration `NOT RUN` on any linked/production database (PGlite single-connection only). New files uncommitted.
**Agent C status:** `PASS` — M5 bodyweight domain implemented and verified: 38 Flutter tests PASS (measurement 10, trend 13, validator 15), `flutter analyze` no bodyweight issues, `dart format` applied, SQL `m5_bodyweight.sql` PASS, `npm test` → 22 SQL units + 365 ACL assertions PASS. Migration `NOT RUN` on any linked/production database (PGlite single-connection only). New files uncommitted.
**Agent D status:** `PASS` — M5 Flutter presentation implemented and verified: newcomer journey screen (`/plan`) and analytics screen (`/analytics`) baseline; plus Riverpod providers for plan/analytics/bodyweight, `first_week_plan_screen` + `plan_day_card` widget, extracted analytics chart widgets (`heatmap_chart`, `weight_trend_chart`, `pr_chart`, `muscle_balance_chart`) wired into `analytics_screen`, bodyweight screen + `bodyweight_trend_chart`, `/bodyweight` route, and bodyweight VI/EN localization keys. 66 widget tests PASS (`test/training_plan/first_week_plan_test.dart` 6, `test/analytics/analytics_screen_test.dart` 7, `test/bodyweight/bodyweight_screen_test.dart` 6), plus baseline 15 widget tests PASS, `flutter analyze --no-pub` → `No issues found!` PASS, `dart format --set-exit-if-changed` → 0 changed PASS. Files added: `training_plan/presentation/providers/training_plan_providers.dart`, `training_plan/presentation/screens/first_week_plan_screen.dart`, `training_plan/presentation/widgets/plan_day_card.dart`, `analytics/presentation/providers/analytics_providers.dart`, `analytics/presentation/widgets/{heatmap,weight_trend,pr,muscle_balance}_chart.dart`, `bodyweight/presentation/providers/bodyweight_providers.dart`, `bodyweight/presentation/screens/bodyweight_screen.dart`, `bodyweight/presentation/widgets/bodyweight_trend_chart.dart`, `test/training_plan/first_week_plan_test.dart`, `test/analytics/analytics_screen_test.dart`, `test/bodyweight/bodyweight_screen_test.dart`. Modified: `analytics_screen.dart` (chart extraction + provider fallback), `localization_engine.dart` (bodyweight keys), `app_router.dart` (`/bodyweight` route). New files uncommitted.
**Agent E status:** `PASS` — Independent QA of complete M5 diff: full Flutter suite `+555 -1` (sole failure = pre-existing protected `release_config_test.dart` Gradle 9.7.1 vs approved 8.13, not an M5 regression); 115 focused M5 tests PASS; `flutter analyze --no-pub` → `No issues found!`; `dart format` clean; `cd tools/db-tests; npm test` → 22 SQL units + 365 ACL assertions PASS; M5 migrations/regressions PASS; exact diff reviewed; no debug/unrelated artifacts; no protected owner path modified. No P0–P1 findings.
**Blockers:** production activation remains gated; `complete_workout` stays sole PostgreSQL reward authority; offline gates `false`; remote migration/deploy not executed, requires explicit owner approval (O-07/O-06). Migration is `NOT RUN` on any production/linked database (local/test only). Full-suite Gradle Wrapper mismatch is a protected owner-file issue, not an M5 blocker.
**Next action:** Owner review of M5; create `M5_FINAL_REPORT.md`; approve M5-FINAL Git delivery (commit on `main`) when ready. Do not start M6.

---

## Current — M4 progression, 1RM/PR, RPE/RIR & RPG bridge (2026-11-04) — local/test only

**Task:** M4 — complete M4 milestone: deterministic progression engine, Epley 1RM, PR detection, RPE/RIR columns, RPG/class bridge, Candy progression UI, additive SQL migration, per D-043.
**Status:** `PASS` for all M4 implementation and verification; M4 closed for development. Production activation remains gated (`complete_workout` stays sole PostgreSQL reward authority; offline gates `false`).
**Commit:** `main` @ `f409b1b4e051d5b66ee37b973a71add81234865a`; working tree dirty by pre-existing M3 + M4 work (preserved), index empty. Protected owner paths untouched.
**Changed files:**
- Domain: `app/lib/features/progression/domain/progression_engine.dart` (Epley 1RM, PR detection, progressionSnapshot), `progression_models.dart` (new, value types), `rpg_bridge.dart` (new, class XP/level projection)
- Model: `app/lib/features/workout/domain/workout_set.dart` (+ nullable `rpe`/`rir`), `.freezed.dart` + `.g.dart` (regenerated)
- UI: `app/lib/features/progression/presentation/progression_screen.dart` (new), `class_progress_card.dart` (new), `exercise_progression_card.dart` (new), `rpe_rir_tile.dart` (new)
- Localization: `app/lib/core/localization/localization_engine.dart` (progression VI/EN keys)
- Tests: `app/test/progression_engine_test.dart` (extended, 15 total), `app/test/rpg_bridge_test.dart` (new, 10), `app/test/progression_screen_test.dart` (new, 5)
- SQL: `supabase/migrations/20261104000100_m4_progression_rpe_rir.sql` (new, `rpe`/`rir` + CHECK constraints), `supabase/tests/m4_rpe_rir.sql` (new)
- Records: `docs/planning/DECISIONS.md` (D-043), `TASK_BOARD.md`, `SESSION_HANDOFF.md`, `CHANGELOG_AI.md`
- No `supabase/**` schema weakening, no protected owner paths, no AGENTS.md, no `.agents/teamwork/`.
**Verification:** Flutter focused tests → 30/30 `PASS` (progression_engine 15, rpg_bridge 10, progression_screen 5); `flutter analyze --no-pub` → `No issues found!` `PASS`; `dart format` → clean `PASS`; `cd tools/db-tests; npm test` → `PASS 18 SQL verification units` + `365 ACL assertions` `PASS`. Accessibility QA findings (Semantics + ≥48dp touch targets) fixed in all M4 UI widgets.
**Decisions:** D-043 `ACCEPTED` for additive local/test verification only (recorded in `DECISIONS.md`).
**Blockers:** production activation remains gated; `complete_workout` stays sole PostgreSQL reward authority; offline gates `false`; remote migration/deploy not executed, requires explicit owner approval. Migration is `NOT RUN` on any production/linked database (local/test only). M3.6 Git delivery pending separate owner approval.
**Next action:** owner review of M4; create `M4_FINAL_REPORT.md`; no further M4 work without approval. Do not start M5.

## Current — M3.6 security & concurrency verification (2026-11-04)
**Changed files:**
- Flutter data: `app/lib/features/workout/data/offline_payload_cipher.dart` (new), `offline_secure_key_store.dart` (new), `offline_security_payload.dart`, `offline_security_session.dart`, `offline_sync_coordinator.dart`, `offline_workout_store.dart`, `offline_workout_store.g.dart` (regenerated).
- Flutter tests: `app/test/offline_payload_cipher_test.dart` (new), `app/test/offline_encrypted_queue_test.dart` (new), `app/test/offline_security_lifecycle_test.dart`, `app/test/offline_workout_schema_migration_test.dart`, `app/test/offline_workout_store_test.dart`, `app/test/offline_sync_coordinator_test.dart`.
- Integration runtime: `app/integration_test/offline_secure_storage_runtime_test.dart` (new, runs under `flutter test ... -d windows --dart-define=M36_PHASE=create|recover`).
- Config: `app/pubspec.yaml`, `app/pubspec.lock` (`cryptography ^2.9.0`, `flutter_secure_storage ^11.2.0`, dev `integration_test`).
- Tooling: `tools/db-tests/concurrency/pg-runtime.mjs` (new), `m3-idempotency.mjs` (new), `README.md` (new), `package.json`, `package-lock.json` (`embedded-postgres@17.5.0-beta.15`, `pg@8.16.3`).
- Records: `docs/planning/ARCHITECTURE.md`, `DECISIONS.md` (D-042 added), `TASK_BOARD.md`, this file, `CHANGELOG_AI.md`, new `M3_6_FINAL_REPORT.md`.
**Verification:**
- External backup `D:\Projects\gymlvl-backups\m3_5-execute-20261103-051124` verified before M3 edits; post-edit SHA-256 comparison of protected owner paths unchanged (`PASS`, inherited baseline).
- `cd app; flutter pub get` → `PASS`; `dart run build_runner build --delete-conflicting-outputs` → `PASS`.
- Focused Flutter suite → 52/52 `PASS` (cipher 12, encrypted queue 8, security lifecycle 11, schema migration 2, store 10, coordinator 9).
- `cd app; flutter analyze --no-pub` → `No issues found!` `PASS`; `dart format` on changed Dart files → 0 changed `PASS`.
- Full Flutter suite → 411 pass / 1 fail; sole failure `release_config_test.dart` (protected Gradle Wrapper 9.7.1 vs approved 8.13), protected owner-file issue, **not** an M3.6 regression.
- `cd tools/db-tests; npm test` → `PASS`, 16 SQL units / 365 ACL assertions (existing single-connection suite unaffected).
- `cd tools/db-tests; npm run test:concurrency` → **C1–C6 PASS (6/6)** on isolated disposable PostgreSQL 17.5 (embedded, two independent `pg.Client` connections, monitor sampled `pg_stat_activity` lock waits); data directory removed; no leftover process/listener (`leftover_dirs=0`, `listeners_55432=0`, `postgres_procs=0`).
- Real-runtime platform secure storage (Windows desktop, DPAPI-backed file backend): `create` PASS + `recover` PASS in two separate processes — key survives restart, envelope decrypts after restart, owner B denied, wrong binding rejected (`AuthenticationException`), explicit key delete fails closed; artifact cleaned up, zero residue. No Android emulator/physical device existed and none was installed solely for this gate (`DEVICE_AUTH_LIFECYCLE` covered by unit+lifecycle tests plus Windows real-runtime).
- Independent QA → `NO_DEFECT_FOUND`; no unresolved P0–P2.
**Decisions:** D-041 `PARTIALLY_APPROVED` (unchanged). D-042 `ACCEPTED` for additive local/test verification only (recorded in `DECISIONS.md`). Four production gates remain `false`; `complete_workout` remains the sole server reward authority.
**Blockers:** M3-FINAL Git delivery requires owner approval to commit/push on `main`; `origin/main` not verified as current (no `git ls-remote` relied upon); remote migration/deployment and live Supabase verification (O-07) remain separate owner approvals; full-suite Gradle Wrapper mismatch is a protected owner-file issue, not an M3.6 blocker.
**Next action:** Owner reviews `M3_6_FINAL_REPORT.md` and the exact M3 candidate manifest; approve M3-FINAL Git delivery (commit on `main`) when ready. Do not start M4.

## Current — M3.5 approved server contract slice (2026-11-03)

**Task:** M3.5 — D-041 approval record and local/test server Superset/mode contract.
**Status:** `PASS` for the scoped SQL implementation and regression; `BLOCKED` for genuine two-connection PostgreSQL verification. M3 overall remains `PARTIAL`.
**Commit:** `main` @ `bd078c79a25a5b253ce1c1e72300dddc050570fe`; tree dirty, index empty. Remote ref not checked. No commit, push, tag, deploy, or remote migration.
**Changed files:** `supabase/migrations/20261103000200_m3_superset_modes.sql`, `supabase/tests/m3_superset_modes.sql`, `docs/planning/DECISIONS.md`, `docs/planning/TASK_BOARD.md`, this file, `docs/planning/CHANGELOG_AI.md`.
**Verification:**
- External pre-edit backup `D:\\Projects\\gymlvl-backups\\m3_owner_approved-20261103-045733` → bundle clone matched HEAD; archive 598/598; 39 dirty-file hashes matched (`PASS`).
- `cd tools/db-tests; npm test` → 16 SQL verification units and 365 ACL assertions, exit 0 (`PASS`); isolated single-connection PGlite.
- `git diff --check` → exit 0 (`PASS`); Flutter tests/analyzer `NOT RUN` because this slice changed no app files.
- Genuine two-connection PostgreSQL concurrency → `BLOCKED`: `psql`/PostgreSQL/Docker/Podman/WSL runtime absent. Live Supabase/device verification `NOT RUN`: no production/remote authorization.
**Decisions:** D-041 `PARTIALLY_APPROVED`: contracts accepted for local/test implementation; production offline activation gate remains closed. D-039/D-040 prior synthetic-only limits are historical; no real-user storage is authorized before encryption and security evidence.
**Blockers:** encrypted payload/key lifecycle, authenticated owner-bound local access, logout/account-switch cancellation, user-visible recoverable conflict flow, client Superset round/rest behavior and four-mode UI, idempotent Superset offline replay, and genuine PostgreSQL two-connection gate.
**Next action:** M3.6 — implement encrypted owner-scoped local lifecycle using synthetic fixtures while keeping `productionOfflineSyncEnabled=false`.

## Current — M3.4 concurrency and owner contract gate (2026-11-03)

**Task:** M3.4 — genuine PostgreSQL concurrency check where available; compact owner approval gate for remaining M3 contracts.
**Status:** `PARTIAL`: `POSTGRES_CONCURRENCY_RUNTIME_BLOCKED`; D-041 lifecycle/Superset/mode contracts `PROPOSED`. No application or SQL implementation in this checkpoint.
**Commit:** `main` @ `bd078c79a25a5b253ce1c1e72300dddc050570fe`; tree dirty, index empty. Remote ref not checked. No commit, push, tag, deploy, or production migration.
**Changed files:** `M3_4_FINAL_REPORT.md`, `docs/planning/DECISIONS.md`, `docs/planning/TASK_BOARD.md`, this file, `docs/planning/CHANGELOG_AI.md`.
**Verification:**
- `git branch --show-current` / `git rev-parse HEAD` / `git status --porcelain=v1 -uall` / `git diff --cached --name-only` → `main`, expected SHA, known dirty paths, empty index (`PASS`).
- External backup `D:\Projects\gymlvl-backups\m3_4-20261103-045027` → bundle clone HEAD matched; archive 598/598; 38 dirty-file SHA-256 copies matched (`PASS`).
- Post-edit hash comparison → 34/34 pre-existing dirty files outside the M3.4 document set unchanged; `git diff --check` exit 0 and index remained empty (`PASS`).
- `Get-Command psql,pg_ctl,postgres,docker,podman,wsl`, PostgreSQL service query, TCP 5432 check, `wsl --list --quiet` → no PostgreSQL/Docker/Podman/runtime; WSL not installed (`BLOCKED` for genuine two-connection PostgreSQL verification).
- Static inspection of the latest `complete_workout` and existing workout set/exercise schema → completed `reps=0` sets are rejected; deleting a workout-exercise row cascades to its sets (`PASS` as source inspection, not runtime verification).
- M3.4 Flutter/SQL tests, analyzer, formatter → `NOT RUN`: no app, SQL, or test code changed; M3.3 results remain historical evidence only.
- Six required two-connection PostgreSQL scenarios → `BLOCKED`: no already-available isolated runtime. PGlite single-connection assertions were not relabeled as concurrency evidence.
**Decisions:** D-041 `PROPOSED` only. D-005/D-039/D-040 stay `PARTIALLY_APPROVED`; no owner policy or behavior choice was inferred. Production offline gate remains false.
**Blockers:** existing isolated two-connection PostgreSQL runtime; owner selection of retention A or B (and exact TTL if B), encryption/key lifecycle, account switch/conflict handling, Superset order/round/rest/edit behavior, four-mode field semantics, and timed/cardio server completion design. O-07 remains open for live Supabase verification.
**Next action:** owner reviews the single D-041 approval block in `M3_4_FINAL_REPORT.md`; after approval, run the isolated PostgreSQL concurrency scenarios before production integration.

## Current — M3.3 synthetic sync foundation (2026-11-03)

**Task:** M3.3 — D-039/D-040 approved offline outbox and idempotent sync foundation for local/test only.
**Status:** `PARTIAL` overall: implementation/focused checks `PASS`; true two-connection PostgreSQL duplicate-delivery test `BLOCKED`. Full M3 remains incomplete.
**Commit:** `main` @ `bd078c79a25a5b253ce1c1e72300dddc050570fe`; tree dirty, index empty. Remote ref not checked. No commit, push, tag, deploy, or production migration.
**Changed files:** `app/pubspec.yaml`, `app/pubspec.lock`, `app/lib/features/workout/data/offline_workout_store.dart`, `app/lib/features/workout/data/offline_workout_store.g.dart`, `app/lib/features/workout/data/offline_sync_coordinator.dart`, `app/test/offline_workout_store_test.dart`, `app/test/offline_workout_schema_migration_test.dart`, `app/test/offline_sync_coordinator_test.dart`, `supabase/migrations/20261103000100_m3_offline_foundation.sql`, `supabase/tests/m3_offline_foundation.sql`, `docs/planning/DECISIONS.md`, `docs/planning/TASK_BOARD.md`, this file, `docs/planning/CHANGELOG_AI.md`, and `M3_3_FINAL_REPORT.md`.
**Verification:**
- External pre-edit backup `D:\Projects\gymlvl-backups\m3_3-20261103-042224` → bundle clone HEAD matched `bd078c7`; archive 598/598; 34 dirty files copied with matching SHA-256 (`PASS`).
- `cd app; flutter pub get` → dependency resolution succeeded, exit 0 (`PASS`).
- `cd app; flutter test --no-pub test/offline_workout_store_test.dart test/offline_workout_schema_migration_test.dart test/offline_sync_coordinator_test.dart test/workout_write_identity_test.dart test/workout_snapshot_ownership_test.dart test/workout_controller_test.dart test/workout_widgets_test.dart --reporter compact` → 103/103, exit 0 (`PASS`).
- `cd tools/db-tests; npm test` → 14 SQL units and 365 ACL assertions, exit 0 (`PASS`); single-connection PGlite.
- `cd app; flutter analyze --no-pub` → `No issues found!`, exit 0 (`PASS`).
- `cd app; dart format --output=none --set-exit-if-changed lib test` → 146 files/0 changed, exit 0 (`PASS`).
- `cd app; flutter test --no-pub --reporter expanded` → 359 passed/1 failed, exit 1 (`FAIL`); `release_config_test.dart` expects Gradle 8.13 while protected local wrapper is 9.7.1.
- Independent QA → 21/21 focused Flutter tests and SQL suite `PASS`; two P2 findings fixed and re-reviewed; no actionable finding. `git diff --check` exit 0 (`PASS`).
- True two-connection PostgreSQL concurrency → `BLOCKED` (no local PostgreSQL/Docker/port 5432). Live Supabase, devices, remote CI → `NOT RUN` (outside scope).
**Decisions:** D-040 records owner approval for synthetic sync coordination; D-005/D-039/D-040 remain `PARTIALLY_APPROVED`. Production feature gate is false; no online write path connection.
**Blockers:** isolated two-connection PostgreSQL for concurrency evidence; owner decisions on encryption, retention/deletion, logout/account switching, replay conflict/reconciliation, superset behavior, and mode fields/transitions. O-07 remains open for live verification.
**Next action:** M3.3 verification — run concurrent same-operation duplicate delivery against an isolated two-connection PostgreSQL database before considering real-user integration.

## Current — M3.2 synthetic offline foundation (2026-11-03)

**Task:** M3.2 — D-039 approved offline foundation, local/test only.
**Status:** `PASS` for the bounded foundation; full M3 and real-user replay remain `BLOCKED`.
**Commit:** `main` @ `bd078c79a25a5b253ce1c1e72300dddc050570fe`; tree dirty, index unstaged. Remote ref was not checked in this session. No commit, push, tag, deploy, or production migration.
**Changed files:** `app/pubspec.yaml`, `app/pubspec.lock`, `app/lib/features/workout/data/offline_workout_store.dart`, `app/lib/features/workout/data/offline_workout_store.g.dart`, `app/lib/features/workout/domain/workout_write_identity.dart`, `app/test/offline_workout_store_test.dart`, `supabase/migrations/20261103000100_m3_offline_foundation.sql`, `supabase/tests/m3_offline_foundation.sql`, `docs/planning/DECISIONS.md`, `docs/planning/M3_1_DECISION_PROPOSAL.md`, `docs/planning/ARCHITECTURE.md`, `docs/planning/TASK_BOARD.md`, this file, and `docs/planning/CHANGELOG_AI.md`. Pre-existing M3 timer and owner files remain preserved.
**Verification:**
- Backup outside repo `D:\Projects\gymlvl-backups\m3-offline-20261103-040411`: bundle clone HEAD equals `bd078c7`; archive 598/598 tracked files; 25 pre-existing dirty files SHA-256 verified (`PASS`).
- `cd app; flutter pub get` → dependency resolution succeeded (`PASS`); Drift 2.28.2 / drift_dev 2.28.3 selected to remain compatible with existing `freezed`/`analyzer`.
- `cd app; flutter test --no-pub test/offline_workout_store_test.dart test/workout_write_identity_test.dart --reporter compact` → 11/11 (`PASS`).
- `cd app; flutter analyze --no-pub` → `No issues found!` (`PASS`).
- `cd app; dart format --output=none --set-exit-if-changed lib test` → 143 files, 0 changed (`PASS`).
- `cd tools/db-tests; npm test` → 14 SQL units, including the new migration and regression, and 365 ACL assertions (`PASS`). PGlite is single-connection.
- `cd app; flutter test --no-pub --reporter compact` → 342 passed / 1 failed (`FAIL`). `release_config_test.dart:53` expected Gradle 8.13; protected local wrapper specifies 9.7.1. Focused release test reproduced the mismatch.
- Live Supabase, two-connection conflict test, Android/iOS device, remote CI → `NOT RUN`; no authorized live/project access or deployment in this task.
**Decisions:** D-005/D-039 `PARTIALLY_APPROVED` by owner; synthetic-only technical foundation. Superset non-null writes are guarded; modes inactive.
**Blockers:** encryption, retention/deletion, logout/account switching, replay conflict/reconciliation, superset behavior, and mode data/transition contracts lack approval. O-07 is still required for live verification.
**Next action:** M3.3 — record owner decisions on the real-data policies and contracts before any production write integration.

## Current — M3.1 architecture proposal and isolated identity foundation (2026-11-01)

**Task:** M3.1 — Offline-first Architecture & Superset Foundation.
**Status:** `PARTIAL` for remaining M3 functionality; the M3.1 proposal and isolated Dart foundation are locally verified. Production offline replay, persisted supersets, and active modes remain `BLOCKED` pending approved contracts.
**Commit:** `main` @ `bd078c79a25a5b253ce1c1e72300dddc050570fe`; `origin/main` matched at preflight. Tree remains dirty; index empty. No M3.1 commit, push, tag, migration, or deployment.
**Changed files:** New `docs/planning/M3_1_DECISION_PROPOSAL.md`, `app/lib/features/workout/domain/workout_write_identity.dart`, `app/test/workout_write_identity_test.dart`, and `M3_1_FINAL_REPORT.md`; M3.1 additions to `docs/planning/TASK_BOARD.md`, `docs/planning/SESSION_HANDOFF.md`, and `docs/planning/CHANGELOG_AI.md`. Earlier uncommitted M3 timer files and protected owner paths are preserved.
**Verification:**
- `flutter test --no-pub test/workout_write_identity_test.dart --reporter compact` → 7/7, exit 0 (`PASS`).
- `flutter test --no-pub test/workout_snapshot_ownership_test.dart test/workout_controller_test.dart test/workout_widgets_test.dart --reporter compact` → 75/75, exit 0 (`PASS`).
- `flutter analyze --no-pub` → `No issues found!`, exit 0 (`PASS`).
- `dart format --output=none --set-exit-if-changed lib/features/workout/domain/workout_write_identity.dart test/workout_write_identity_test.dart` → 2 files/0 changed, exit 0 (`PASS`).
- Full Flutter suite → `NOT RUN` for M3.1: isolated code has no production integration; historical M3 result is 331/332 with the protected local Gradle Wrapper mismatch.
**Decisions:** `M3_1_DECISION_PROPOSAL.md` is `PROPOSED`, not approved. D-005/O-03 and existing architecture decisions are unchanged.
**Blockers:** owner choice of transactional local store and server idempotency contract; superset grouping, edit, order, and rest rules; mode-specific fields and transitions. O-07 is needed for live Supabase verification. O-02/O-08 remain open.
**Next action:** owner reviews the M3.1 proposal and records approved decisions before the next M3 implementation task. M4 is not started.

## Current — M3 timer slice implemented locally (2026-11-01)

**Task:** M3 — Offline-first Workout Core, Modes, Timers, Supersets; bounded rest-timer continuity and Candy UI slice.
**Status:** `PARTIAL` overall M3; timer slice `PASS`. Full Flutter suite `FAIL` at 331/332 only on preserved local Gradle Wrapper mismatch; independent QA `PASS` for the timer slice. The full offline/reconnect, mode, and superset exit gate is open.
**Commit:** `main` @ `bd078c79a25a5b253ce1c1e72300dddc050570fe`; `origin/main` matched at preflight. Tree dirty by design; no stage, commit, push, tag, branch, migration, or deployment during M3.
**Changed files:** M3 source `app/lib/features/workout/presentation/controllers/active_workout_controller.dart`, `app/lib/features/workout/presentation/widgets/rest_timer_widget.dart`; tests `app/test/workout_controller_test.dart`, `app/test/workout_snapshot_ownership_test.dart`, `app/test/workout_widgets_test.dart`; records `docs/planning/TASK_BOARD.md`, `docs/planning/SESSION_HANDOFF.md`, `docs/planning/CHANGELOG_AI.md`, `M3_FINAL_REPORT.md` (new). Protected owner paths were preserved.
**Verification:**
- `git -C D:\Projects\opengym-reference remote -v` / `rev-parse HEAD` / `status --porcelain=v1` → expected upstream, pinned `e6a95c28a6e3067bdd9b1188d5f37f448d528bd2`, clean (`PASS`, read-only).
- `flutter test --no-pub test/workout_snapshot_ownership_test.dart test/workout_controller_test.dart test/workout_widgets_test.dart --reporter expanded` → 75/75, exit 0 (`PASS`).
- `flutter analyze --no-pub` → `No issues found! (ran in 4.5s)`, exit 0 (`PASS`).
- `dart format --output=none --set-exit-if-changed lib test` → 138 files/0 changed, exit 0 (`PASS`).
- `flutter test --no-pub --reporter expanded` → `+331 -1: Some tests failed.`, exit 1 (`FAIL`), sole `release_config_test.dart` mismatch (local Gradle Wrapper 9.7.1 versus approved 8.13).
- Independent QA `flutter test --no-pub test/workout_snapshot_ownership_test.dart --reporter expanded` → 49/49, exit 0 (`PASS`); final read-only review found no actionable M3 defect.
- Live Supabase, real device, remote CI → `NOT RUN`; durable offline set-write validation → `BLOCKED` by D-005/O-03.
**Decisions:** none new. D-005 remains proposed; D-038 and O-01/O-02/O-08 remain unchanged.
**Blockers:** approved local-store design for offline write queue (O-03); approved superset grouping contract; existing licensing/provenance limits. No schema/dependency change was made.
**Next action:** prepare the M3 local-store and superset data design for owner approval before implementing remaining M3 exit criteria. M4 is planned but not started.

## Historical — M2 Exercise Detail implementation and verification (2026-11-01)

**Task:** M2 — Exercise Detail Layout & Information Architecture.
**Status:** `PASS` for local M2 functionality; full suite `FAIL` at 308/309 due to the preserved local Gradle Wrapper 9.7.1 versus approved 8.13; independent QA `PASS` for read-only code/test review. O-08 blocks newly displaying curated instructions as approved guidance.
**Commit:** `main` @ `1979dfd5fda7cebf6791c11ece3cc1aa333ce1c3`; tree intentionally dirty, index empty. No new commit, push, tag, branch, migration, or deployment.
**Changed files:** M2 app: `app/lib/core/router/app_router.dart`, `app/lib/features/workout/presentation/providers/exercise_providers.dart`, `app/lib/features/workout/presentation/screens/exercise_picker_screen.dart`, `app/lib/features/workout/presentation/screens/exercise_detail_screen.dart` (new), `app/lib/features/workout/workout_copy.dart`, `app/lib/ui/candy/candy_exercise_card.dart`; M2 test: `app/test/exercise_detail_test.dart` (new); M2 records: `docs/planning/TASK_BOARD.md`, `docs/planning/SESSION_HANDOFF.md`, `docs/planning/CHANGELOG_AI.md`, `M2_FINAL_REPORT.md` (new). The three planning files already contained M1-FINAL edits before M2. Other M1-FINAL planning files remain unchanged by M2.
**Verification:**
- `flutter test --no-pub test/exercise_detail_test.dart --reporter expanded` → 11/11, exit 0 (`PASS`); independent QA reran the same file with compact reporter → 11/11, exit 0 (`PASS`).
- `flutter test --no-pub test/exercise_picker_test.dart --reporter compact` → 67/67, exit 0 (`PASS`).
- `flutter analyze --no-pub` → `No issues found! (5.2s)`, exit 0 (`PASS`).
- `dart format --output=none --set-exit-if-changed` on seven M2 app files → 0 changed, exit 0 (`PASS`).
- `flutter test --no-pub --reporter expanded` → `+308 -1: Some tests failed.`, exit 1 (`FAIL`); sole error is `release_config_test.dart` expecting Gradle 8.13 while protected local wrapper has 9.7.1.
- Live Supabase, real device, and remote CI → `NOT RUN` (outside this local M2 verification scope).
**Decisions:** none new; D-038 remains in force. No schema, licensing, or architecture change.
**Blockers:** O-08 undocumented curated-text provenance and absent instruction-locale field prevent new guidance display. Primary muscle has no model field; raw metadata values lack localized variants. O-01/O-02 and existing release/data gates remain open.
**Next action:** owner reviews the local M2 candidate manifest and O-08 gate in `M2_FINAL_REPORT.md`; M3 Offline-first Workout Core is the next planned milestone and has not started.

## Historical — M1-FINAL verified closeout and M2 handoff (2026-11-01)

**Task:** M1-FINAL — Exercise Catalogue implementation/Git closeout and Exercise Detail M2 handoff.
**Status:** `PASS` for M1 implementation and Git delivery; full Flutter suite `FAIL` (historical
297/298, preserved local Gradle Wrapper 9.7.1 versus approved 8.13); independent QA `BLOCKED`
(`INDEPENDENT_QA_UNAVAILABLE_QUOTA_429`). M1 is not fully QA-approved or production-ready.
**Commit:** `main` @ `1979dfd5fda7cebf6791c11ece3cc1aa333ce1c3`, parent
`9b874111692dee1f69dc686e1dbbc38981529cf5`; `origin/main` matches. The tree remains intentionally
dirty with preserved owner and `.agents/teamwork/` files; this closeout adds only local, uncommitted
planning-document changes.
**Changed files:** `docs/planning/TASK_BOARD.md`, `docs/planning/SESSION_HANDOFF.md`,
`docs/planning/CHANGELOG_AI.md`, `docs/planning/DECISIONS.md`, `docs/planning/MASTER_PLAN.md`, and
`docs/planning/PROJECT_CONTEXT.md` (local documentation reconciliation only).
**Verification:**
- `git show -s --format="%H%n%P%n%s" HEAD` → expected M1.2 SHA, parent, and subject (`PASS`).
- `git diff-tree --no-commit-id --name-only -r HEAD` → exactly 10 approved paths; protected paths excluded (`PASS`).
- `git ls-remote origin refs/heads/main` → `1979dfd5fda7cebf6791c11ece3cc1aa333ce1c3` (`PASS`).
- `git bundle create` + bundle clone and `git archive HEAD` → clone SHA matches HEAD; archive has 595/595 Git-tree files (`PASS`).
- `Get-FileHash -Algorithm SHA256` on 12 preserved dirty paths before/after edits → all hashes match (`PASS`).
- Flutter tests/analyzer/formatter → `NOT RUN` in M1-FINAL; prior M1/M1.1 evidence remains historical.
- Remote CI → `NOT RUN` in M1-FINAL; no remote CI result was observed.
**Decisions:** D-038 `ACCEPTED` by the project owner on 2026-11-01. It assigns product M1 to Exercise
Catalogue and product M2 to Exercise Detail. Historical release-stabilization and bulk-import work
remains open without a new milestone assignment.
**Blockers:** full-suite release-config failure, independent QA quota 429, O-01/O-02 licensing,
O-08 curated-text provenance, and existing data/release/production gates remain unresolved.
**Next action:** M2 — inspect the existing Exercise Detail screen and model, then define focused
acceptance criteria before implementation. M2 has not started.

### M2 scope for the next execution task

Build an Exercise Detail layout using the GymLvl Candy design and existing Riverpod, GoRouter, and
database conventions. Show the exercise name, available metadata, primary/secondary muscles,
equipment, instructions, and supported actions. Handle loading, empty, error, and unavailable-media
states; support VI/EN, accessibility, and responsive layouts. Use only exercise text/metadata with
verified legal provenance. Write focused tests during M2. Do not copy AGPL implementation or
proprietary media. Full Workout Detail redesign, bulk imports, media procurement, remote Supabase
deployment, and Android release/signing are outside M2 scope.

## Historical — M1.1 / M1.1-FIX Exercise Catalogue Hardening & Verification (2026-10-31)

**Task:** M1.1 / M1.1-FIX Exercise Catalogue Test Hardening, Diagnosis & Commit Readiness.
**Status:** `PASS` for M1 scope (67/67 tests); Full suite: `FAIL` (1 fail in `release_config_test.dart` classified as `PRE_EXISTING_OR_OWNER_CONFIGURATION`); QA: `INDEPENDENT_QA_UNAVAILABLE_QUOTA_429`; Commit readiness: `READY_WITH_DOCUMENTED_BASELINE_EXCEPTION`.
**Commit:** branch `main`, HEAD `9b874111692dee1f69dc686e1dbbc38981529cf5`; tree has local uncommitted M1 implementation + M1.1 test file + preserved owner/unrelated files. No commit, push, tag, or deployment performed.
**Changed / Added files:**
- New test: `app/test/exercise_picker_test.dart` (67 tests)
- M1 implementation files (retained): `app/lib/features/workout/presentation/providers/exercise_providers.dart`, `app/lib/features/workout/presentation/screens/exercise_picker_screen.dart`, `app/lib/features/workout/workout_copy.dart`
- Documentation: `M1_1_FINAL_REPORT.md`, `M1_1_FIX_REPORT.md`, `docs/planning/{TASK_BOARD.md,SESSION_HANDOFF.md,CHANGELOG_AI.md}`
**Verification:**
- `flutter test --no-pub test/exercise_picker_test.dart` → `+67: All tests passed!` (exit 0)
- `flutter analyze --no-pub` → `No issues found! (ran in 3.7s)` (exit 0)
- `dart format --output=none --set-exit-if-changed test/exercise_picker_test.dart` → 0 changed (exit 0)
- `flutter test --no-pub test/release_config_test.dart` → 13 passed / 1 failed (fails on local `gradle-9.7.1-bin.zip` in preserved `gradle-wrapper.properties` vs D-031 `gradle-8.13-bin.zip` in HEAD).
**Protected owner files:** all 5 SHA-256 hashes verified identical pre- and post-execution.
**Decisions:** none.
**Blockers:** none for repository code.
**Next action:** owner review; execute M1.2 Controlled Commit & Push for the 10 approved candidate files.

## Historical — M1 Exercise Catalogue Navigation & Filtering (2026-10-31)

**Task:** M1 Exercise Catalogue Navigation & Filtering in `ExercisePickerScreen` + providers/copy.
**Status:** `PASS` — implementation complete; all acceptance criteria met including accessibility fixes.
**Commit:** branch `main`, HEAD `9b874111692dee1f69dc686e1dbbc38981529cf5`; tree has only my 3 source edits plus pre-existing untouched owner files. No commit, push, tag, or deployment performed.
**Changed files:** `app/lib/features/workout/presentation/providers/exercise_providers.dart`, `app/lib/features/workout/presentation/screens/exercise_picker_screen.dart`, `app/lib/features/workout/workout_copy.dart`.
**Verification:** `flutter analyze --no-pub` → `No issues found!` (exit 0); `dart format --output=none --set-exit-if-changed lib test` → 0 changed; `flutter test --no-pub` → `+231: All tests passed!` (231 tests, no regression). Accessibility fixes: Semantics labels on chips/cards/clear-search, 48dp touch targets, WCAG AA banner contrast, line-height headroom for 200% VI scaling.
**Decisions:** none (UI-only change; no architecture/dependency/schema/licensing change).
**Blockers:** none.
**Next action:** owner review; qa-reviewer to add dedicated exercise-picker tests (test files were not touched per scope).

## Current — M0 OpenGym source pinning & migration foundation (2026-10-31)

**Task:** M0 — OpenGym source pinning & migration foundation (one migration slice).
**Status:** `PASS` for the implementation slice; source pin + mapping complete.
**Commit:** branch `main`, HEAD `6badfef29a871a978a09daee304dc1c3f3f69a84`; tree dirty by design (5 owner files preserved + 4 M0 files changed + 1 new manifest). No commit, push, tag, or deployment performed.
**Changed files (source/config/tests):** `app/lib/features/workout/presentation/widgets/rest_timer_widget.dart`, `app/lib/features/workout/presentation/screens/active_workout_screen.dart`, `app/lib/features/workout/workout_copy.dart`, `app/test/workout_widgets_test.dart`, `docs/planning/UPSTREAM_SOURCE_MANIFEST.json` (new).
**Verification:** `flutter analyze --no-pub` → `No issues found!` (exit 0); `dart format --output=none --set-exit-if-changed lib test` → 0 changed; `flutter test --no-pub` → `+231: All tests passed!` (231 tests, no regression).
**Source pin:** `https://github.com/DuarteSantos8/openGym` @ `e6a95c28a6e3067bdd9b1188d5f37f448d528bd2`; clone `D:\Projects\opengym-reference`; remote origin + HEAD verified. AGPL-3.0 = reference only.
**Licensing:** AGPL code/reference only; MIT text (`textSource=exercisedb`) reusable with notice, strip media; media EXCLUDED; GymLvl no LICENSE (O-01 open).
**Subagents used:** flutter-specialist (ses_e721c19f2ffeoi9CYIROH0cOS1), supabase-specialist (ses_e721c19f1ffeVBfgvsHL35Gicn), qa-reviewer (ses_e721c19eeffeqvSIepBiMtpcKk — BLOCKED on sandbox access to `D:\Projects\opengym-reference`, classification produced from project docs).
**Next action:** owner review; proposed next slice: exercise catalogue navigation/filter improvement (ADAPT, P1) or workout detail layout (ADAPT, P1).

## Historical — R2 controlled remediation A-1..A-8 executed locally, pre-commit (2026-10-29)

- **Task:** R2 batch — A-2 Auth redirect allowlist, A-3 Android merged-manifest gate, A-4 canonical
  findings sync, A-7 `GymLvl` branding, A-8 `app/analysis.txt` untracking, conditional A-1
  duplicate-XP guard.
- **Status:** `PASS` for the approved repository scope; final release/live gates `NOT RUN`/`BLOCKED`.
  Register after R2: Fixed 18 · Accepted 12 · Needs Verification 3 · False Positive 2 = 35
  (severity 0/3/24/6/2 and confidence 16/18/1/0 unchanged).
- **Commit:** branch `main`, HEAD `b85d674b27b7eb024b42a8d1b05d5f624a3ee6bc`; tree dirty by design
  (owner work + this batch; `app/analysis.txt` staged as deleted in the index only). No commit, push,
  tag, deployment or production migration was performed.
- **Changed files (source/config/tests):** `supabase/config.toml`, `app/config.example.json`,
  `README.md`, `docs/DEVELOPMENT.md`, `.github/workflows/verify.yml`, `app/.gitignore`,
  `app/lib/app.dart`, `app/lib/main.dart`, `app/lib/core/router/main_shell_screen.dart`,
  `app/lib/features/auth/presentation/screens/auth_form_screen.dart`,
  `app/lib/core/localization/localization_engine.dart`, `app/lib/l10n/{app_en.arb,app_vi.arb,
  app_localizations.dart,app_localizations_en.dart,app_localizations_vi.dart}`,
  `app/test/{widget_test.dart,adversarial_edge_test.dart}`, `supabase/tests/progression_regression.sql`.
  **Added:** `app/test/auth_redirect_config_test.dart`,
  `tools/android-verify/{manifest-check.mjs,run.mjs,manifest-check.test.mjs,package.json}`,
  `tools/audit-sync/sync-findings-r2.mjs`,
  `supabase/migrations/20261029000200_prevent_legacy_double_award.sql`.
  **Records:** `docs/audit/FINDINGS_REGISTER.json`, `docs/audit/MASTER_FINDINGS.md`,
  `docs/audits/codebase-health/{REMEDIATION_EXECUTION.md,FINDINGS_REGISTER.md,CODEBASE_HEALTH_REPORT.md,
  REMEDIATION_PRIORITY.md}`, `docs/planning/{DECISIONS.md,PROJECT_CONTEXT.md,TASK_BOARD.md,
  SESSION_HANDOFF.md,CHANGELOG_AI.md}`.
- **Verification (all executed in this session at `b85d674` + this batch):**
  `flutter analyze --no-pub` → exit 0, `No issues found!`;
  `dart format --output=none --set-exit-if-changed lib test` → 134 files, 0 changed;
  `flutter test --no-pub` → `+221: All tests passed!`;
  `node tools/db-tests/run.mjs` → 12 SQL units + 365 ACL assertions, exit 0;
  `node tools/db-tests/edge-tests.mjs` → 44/44, exit 0;
  `node tools/android-verify/manifest-check.test.mjs` → 8/8;
  `node tools/android-verify/run.mjs` → `PASS merged release manifest: package=com.gymlvl.app
  label=GymLvl internet=1 nested=0 duplicates=0`, exit 0.
  A-1 RED→GREEN: without the migration the new case fails
  (`FAIL: ledger-only legacy workout never earns twice`); with it, the suite passes.
- **Per-finding:** INTG-001 Fixed (config contract 6/6), BUG-001 Fixed (merged manifest),
  BUG-003 Fixed (`GymLvl` everywhere user-facing), GOV-005 Fixed (untracked + ignored, 84,864-byte
  local copy preserved), DATA-001 Fixed in repository scope. BUG-002 and TEST-001 stay Accepted
  (signing keys absent; CI unproven remotely); BUG-004 stays Accepted (partial contrast fix only).
- **Decisions:** D-035 Auth origin/allowlist, D-036 single brand spelling `GymLvl`, D-037 ledger
  evidence as prior-award provenance. D-034 carried.
- **Blockers:** A-1 production portion — live Supabase access (`O-07`), at-risk counts and any
  `workout_rewards` repair need operator approval; release APK/signature (`GYMLVL_RELEASE_*`), iOS
  build (Windows host), hosted Edge, live Auth round trip, remote CI and true two-connection
  concurrency are `NOT RUN`.
- **Finalization (2026-10-29):** `READY_FOR_APPROVAL`. Commit manifest and CI evidence are in
  `REMEDIATION_EXECUTION.md` §9: Commit A = 19 prior A-8 files, Commit B = 39 R2 files, 5 owner or
  ambiguous paths excluded (`app/android/gradle.properties`, `run_gradle.bat`, `gradle_check.ps1`,
  `run_gradle_check.bat`, `docs/audit/phases/A8_BATCH_EXECUTION.md`). Local gates re-run `PASS`
  (analyze 0, format 134/0, 221/221, SQL 12 units + 365 ACL, Edge 44/44, manifest 8/8 + gate exit 0,
  workflow YAML 3 jobs, register 35/18/12/3/2). Remote CI at `b85d674` is **red** in
  `database-and-edge` (`Expected 413, got 503` ×8 — missing hosted `SUPABASE_*` in that job); the
  pending `edge-tests.mjs` change targets exactly that failure but is unobserved remotely. `gh` is
  authenticated (repo scope); nothing was committed or pushed.
- **Next action:** owner approves the §9.4 manifest, then the push that triggers CI; separately
  approves `O-07` read-only counts. No further batch starts automatically.

## Current — R3 release-readiness hardening complete locally (2026-10-29)

- **Task:** CI hardening (FND-TEST-001), Android fail-closed signing (FND-BUG-002), remaining profile/onboarding contrast (FND-BUG-004), dashboard KPI window labeling (FND-BUG-005), Supabase data integrity (FND-DATA-001/D-037), and INTG-008/009 source confirmation. No production migration, deploy, signing-key or OpenGym change.
- **Commit / branch / remote:** `main` @ `aa52aa0a` == `origin/main`; index empty; working tree holds 12 modified tracked files total = **11 R3 edits + 1 owner edit (`app/android/gradle.properties`, excluded)**, plus **3 new R3 files** (`app/test/dashboard_kpi_window_test.dart`, `docs/admin/ANDROID_RELEASE_SIGNING_VI.md`, `tools/db-tests/cohort_validation.mjs`) and **4 other owner files untracked** (`app/android/run_gradle.bat`, `gradle_check.ps1`, `run_gradle_check.bat`, `docs/audit/phases/A8_BATCH_EXECUTION.md`). R3-owned paths = 14 (11 modified + 3 new); owner paths = 5, all preserved.
- **Local verification (status vocabulary AGENTS §5):**
  - `flutter analyze --no-pub` → `No issues found!` (exit 0)
  - `dart format --output=none --set-exit-if-changed lib test` → 135 files, 0 changed (exit 0)
  - `flutter test --no-pub --reporter expanded` → `+231: All tests passed!` (221 R2 baseline + 10 new)
  - `node tools/db-tests/run.mjs` → 12 SQL units + 365 ACL assertions PASS (exit 0)
  - `node tools/db-tests/edge-tests.mjs` → 44 passed / 0 failed (exit 0)
  - `node tools/android-verify/manifest-check.test.mjs` → 8/8; `invoke.test.mjs` → 10/10; gate `run.mjs` → exit 0
  - `package:yaml` parse of `.github/workflows/verify.yml` → 3 jobs
  - `:app:assembleRelease` (no signing inputs) → fails at `:app:validateReleaseSigningInputs`, **no APK/AAB produced**
- **CI changes** (`.github/workflows/verify.yml`): added `invoke.test.mjs` to the manifest-gate step (18 Android tests), `dart format` gate, per-job `timeout-minutes`, `concurrency`+cancel, `push.branches: [main]`, pinned Node-24 action SHAs. Generated-drift gate withheld (build_runner rewrites 12 files at locked versions). **NOT RUN remotely** — no push yet.
- **Supabase verification:** migration `20261029000200` re-validated as additive/idempotent; the two read-only cohort queries are recorded in `REMEDIATION_EXECUTION.md` §11.5 and schema-validated locally (cohort A/B execute on the migrated schema, guard+index present, positive control isolates exactly 1 synthetic at-risk tuple, negative control clears it, `complete_workout` returns `alreadyAwarded:true`). Production counts and two-connection concurrency remain **BLOCKED** (`O-07`, no real PostgreSQL host); PGlite is single-connection and is not concurrency proof.
- **Status:** REPOSITORY: R3 READY_FOR_APPROVAL · CI: R2 VERIFIED, R3 pending remote ✅/❌ · PRODUCTION: NOT VERIFIED · OPENGYM: NOT READY.
- **Next action:** owner reviews the R3 commit manifest (see response) and approves the push; then approve `O-07` read-only cohort counts. Release signing steps are documented for the owner in `docs/admin/ANDROID_RELEASE_SIGNING_VI.md` (no keys created, none committed). Stops at READY_FOR_APPROVAL; no push of code/CI without approval.

## R2 closure — commits, pushes, and remote CI (2026-10-29)

- **Commits:** `7a10031` (A-8, 19 files), `74aaa22` (R2, 39 files), `a018ec2` (CI invocation fix +
  regression tests, 4 files). All three pushed fast-forward to `origin/main`
  (`b85d674..74aaa22`, `74aaa22..a018ec2`); remote `main` = `a018ec2`.
- **First CI run `40832095175`** (https://github.com/Tuandaca/gymlvl/actions/runs/40832095175) at
  `74aaa22`: **failure**. `database-and-edge` **success** (the eight `Expected 413, got 503` failures
  are gone), `flutter` **success**, `android-release-manifest` **failure**.
- **Root cause:** `tools/android-verify/run.mjs` ran the wrapper with `sh`, but the Flutter-generated
  `app/android/gradlew` declares `#!/usr/bin/env bash` and uses bash array syntax at line 154 → `sh`
  (dash) aborts with `Syntax error: "(" unexpected`; the gate exits 2 (fail-closed). Tooling
  invocation defect, not an app or manifest defect.
- **Fix implemented in `a018ec2`:** new `tools/android-verify/gradle-invocation.mjs` spawns `bash` with
  the wrapper as `argv[1]` on POSIX (`shell: false`), keeps `gradlew.bat` through a shell on Windows,
  and reports a missing wrapper / failed merge / missing artifact as `BLOCKED` (exit 2). Ten regression
  tests in `invoke.test.mjs`; both suites wired into `package.json`.
- **Second CI run `40834000928`** (https://github.com/Tuandaca/gymlvl/actions/runs/40834000928) at
  `a018ec2`: **success** in all three jobs. The Android job now logs `BUILD SUCCESSFUL in 44s` and
  `PASS merged release manifest: package=com.gymlvl.app label=GymLvl internet=1 nested=0 duplicates=0`.
- **Status:** REPOSITORY: CLOSED · CI: VERIFIED · PRODUCTION: NOT VERIFIED · OPENGYM MIGRATION: NOT
  READY.
- **Known gap:** the job's `Unit-test the manifest gate` step still runs only `manifest-check.test.mjs`,
  so `invoke.test.mjs` is not enforced remotely yet. Wiring it in needs its own approval.
- **Uncommitted:** only the five excluded owner paths (`app/android/gradle.properties`,
  `app/android/run_gradle.bat`, `gradle_check.ps1`, `run_gradle_check.bat`,
  `docs/audit/phases/A8_BATCH_EXECUTION.md`).
- **Next action:** no R3 work has started. Owner decides between wiring `invoke.test.mjs` into CI,
  the `O-07` read-only counts, and the unchanged release/platform blockers (signing keys, iOS build,
  hosted Supabase/Auth, two-connection concurrency).

## Historical A8 batch — UI/config fixes, platform gates blocked (2026-10-29)

- **Task/status:** verification-first remediation of `docs/audit/FINDINGS_REGISTER.json` (35). 9
  findings fixed or partially fixed with regression tests, 5 re-verified as already fixed, 18 not
  re-verified, 2 reproduced and BLOCKED on approval, 1 checked and still open (GOV005). Overall
  PARTIAL; readiness NOT READY.
- **Commit:** `main` @ b85d674b27b7eb024b42a8d1b05d5f624a3ee6bc, tree dirty (owner work preserved).
  No commit, push, tag, migration, config, permission or deployment in this session.
- **Changed source/test:** app/android/app/src/main/AndroidManifest.xml, app/ios/Runner/Info.plist,
  app/pubspec.yaml, app/lib/core/router/app_router.dart,
  app/lib/features/auth/presentation/screens/reset_password_screen.dart,
  app/lib/features/dashboard/presentation/screens/dashboard_screen.dart,
  app/lib/features/profile/presentation/screens/profile_screen.dart,
  app/lib/features/quests/presentation/widgets/daily_quest_card.dart,
  app/lib/features/workout/presentation/screens/workout_summary_screen.dart,
  app/lib/ui/candy/candy_button.dart, app/lib/ui/candy/candy_quest_card.dart,
  app/test/release_config_test.dart, app/test/ui_regression_test.dart, tools/db-tests/edge-tests.mjs;
  new app/test/summary_truthfulness_test.dart, reset_password_entry_test.dart,
  candy_button_keyboard_test.dart, quest_card_truthfulness_test.dart.
- **Changed records:** docs/audits/codebase-health/{FINDINGS_REGISTER.md,REMEDIATION_EXECUTION.md},
  docs/planning/{PROJECT_CONTEXT.md,DECISIONS.md,TASK_BOARD.md,SESSION_HANDOFF.md,CHANGELOG_AI.md}.
- **Verification:** analyze0issues; format133files0changed; full215/215pass (200 at entry);
  SQL11units+ACL365; Edge44/44 (runner injects synthetic SUPABASE_* when absent). Merged manifest/APK,
  iOS build, hosted Edge, live Supabase Auth/RLS/concurrency NOT RUN.
- **Fixed:** BUG002/003 names+description, BUG004 partial contrast, BUG006 quest fallbacks,
  BUG007 summary deep link/500XP/level defaults, BUG008 recovery error scope, BUG009 keyboard
  CandyButton, TEST001 partial source gate, SEC004 runner env.
- **Still open:** GOV005 — the stale transcript is `app/analysis.txt` and `git ls-files app/analysis.txt`
  still lists it; removal needs A-8. An earlier root-path check was mis-read as a resolution.
- **Reproduced BLOCKED:** DATA001 second award total_xp100->110/level1->2/rewards0->1/ledger1->3;
  INTG001 site_url127.0.0.1:3000 vs app localhost:8080.
- **Decisions:** D-034 derived from D-029 (unknown reward/progress hidden, summary deep link redirects).
- **Blockers/approvals:** A-1 DATA001 migration+backfill, A-2 Auth allowlist config, A-3
  permission-gate hardening, A-4 canonical JSON status sync, A-5 isolated stack + Android device,
  A-6 live Supabase, A-7 brand spelling (launcher `GymLvl` vs in-app `GymLevel`), A-8 removal of the
  tracked `app/analysis.txt`. Details in docs/audits/codebase-health/REMEDIATION_EXECUTION.md §7.
- **Next action:** owner decides A-1..A-4, A-7, A-8; execute A-2 first (config-only), then A-1 with a
  read-only live count before any backfill.

## Historical A8 state (preserved)

## Previous — A8 PARTIAL; shell tool BLOCKED, docs-only fix for R2-06/ARCH-003 (2026-10-29)

- **Task/status:** A7 PARTIAL; completed local R0-01..04/R1-01..03 with independent QA. R1-04/07
  supported-stack verification BLOCKED; R1-05/06 source10checks pass but required Gradle tasks/signature
  not verified, acceptance BLOCKED. No W2-W5, production or migration, readiness NOT READY.
- **Commit:** entry main3d9dbb038a3a7e93ee4b3d4c51b10d8e066dbf75; B0 main57e4e73e88f7099ec29a9d075964817f4db5470d
  committed/pushed normally, local/remote equal/clean after checkpoint. Current expected B1 code/docs
  dirty; primary
  gymlvl-orchestrator verified. External bundle/bare/archive backup verified560files, hashes A7phase2.
- **Changed B1 source/test files:** app/lib/features/workout/data/supabase_workout_repository.dart,
  app/lib/features/workout/domain/workout_repository.dart,
  app/lib/features/workout/presentation/controllers/active_workout_controller.dart,
  app/lib/features/workout/presentation/screens/active_workout_screen.dart,
  app/lib/features/workout/workout_copy.dart, app/test/workout_controller_test.dart,
  app/test/workout_snapshot_ownership_test.dart, app/test/workout_async_identity_test.dart,
  app/test/workout_completion_reconciliation_test.dart; PARTIAL platform:
  app/android/app/src/main/AndroidManifest.xml, app/android/app/build.gradle.kts,
  app/android/gradle/wrapper/gradle-wrapper.properties, app/test/release_config_test.dart.
- **Changed B1 records:** docs/audit/phases/A7_BATCH_EXECUTION.md, docs/audit/FINDINGS_REGISTER.json,
  docs/audit/MASTER_FINDINGS.md, docs/audit/AUDIT_COVERAGE.md, docs/audit/SESSION_HANDOFF.md,
  docs/planning/DECISIONS.md, docs/planning/TASK_BOARD.md, docs/planning/SESSION_HANDOFF.md,
  docs/planning/CHANGELOG_AI.md. B0 exact paths/evidence in A7phase4, already checkpointed.
- **Decisions:** default shell ask; additive ACL fail-closed; byte caps RPC16KiB/Coach20000/provider
 256KiB; owner-match snapshot with conservative preserved legacy/foreign data. No production/deploy.
- **B0 verification:** parent policy32/SQL11+ACL365/Edge44/sixchecks all exit0, diff0; red/green and
  failed corrections A7phase4. QA npm.ps1/extra Git checks blocked, no bypass/runtime QA claim;
  independent code review found no material blocker. At B0 checkpoint GOV004/SEC001/003/004 Fixed,
  full history preserved,35 IDs/Accepted25/NV3/Fixed5/FP2; final B1 counts below supersede those totals.
  No deployed or sandbox/DoS claim; live tool permission/deployed DB/network NOT RUN.
- **B1 progress:** R1-01 independent31snapshot, R1-02 independent25async, R1-03 independent18receipt/
  renderedVIENcallback controls pass; parent analyze0issues/format129unchanged/full200pass on D temp,
  all exit0. No material code blocker. In-memory/shallow receipt only, no durableoutbox guarantee.
  SEC002/CONC001/INTG002 Fixed repo-only; platformBUG001/002 Accepted, not Fixed.35IDs/history kept,
  final statusesAccepted22/NV3/Fixed8/FP2; severity/confidence unchanged. Exact A7phase7.
- **Blockers:** DBstack executables absent; Android Gradle pinned8.13 verifiedSHA underD031, SDK/JBR21
  available, oneonline nativeOOM8Gheap and offline Kotlin2.1.20 cachemiss blocked task execution.
  D032 exact duplicateZIPdelete freed118MB on C, D temp/cache approved; no backup/oldtask cleanup,
  keys or SDK downloads. Actual mergedmanifest/signinggate/signature unverified, no extra networkloop.
- **Next action:** final QA and separate verified-core / explicitly PARTIAL platform checkpoints,
  then resume blocked B1 verification after supported backend/cache/resources/operator key prerequisites.
  No other eligible authorized branch remains; no B2-B4/migration automatically.

## Historical A6 closure (preserved)

## Current — A6 PASS/CLOSED; remediation NOT STARTED (2026-10-29)

**Checkpoint:** payload main4246b12238e4a904f87c0b843e861b637403d00c, nine docs +761/-3;
normal push6d8e89b..4246b12 exit0; local/remote fullSHA equal and status empty,
A6_PAYLOAD_EQUAL_CLEAN=PASS. This four-doc outcome-only child advances documentation HEAD;
verify actual latest main/remote on resume.

- **Task/status:** A6 only; PASS/CLOSED for scoped35-ID reconciliation/roadmap/independent QA,
  not remediation or production certification. A1-A5 closed; migration readiness NOT READY.
- **Commit:** entry main6d8e89bf6eba7b393ef2d0e0d52e9b0d5eb4f2c3 clean/remote equal; payload
  main4246b12 above normally pushed/verified. This outcome child edits only four handoff/planning
  docs. At entry actual
  gymlvl-orchestrator API verified. D-013 external bundle/bare/archive backup verified559files,
  hashes in A6phase2. No product/permanent-test/CI/config/permission/dependency change.
- **Owned files:** docs/audit/phases/A6_RECONCILIATION.md, docs/audit/REMEDIATION_PLAN.md,
  docs/audit/MASTER_FINDINGS.md, docs/audit/FINDINGS_REGISTER.json, docs/audit/AUDIT_COVERAGE.md,
  docs/audit/SESSION_HANDOFF.md, docs/planning/TASK_BOARD.md, docs/planning/SESSION_HANDOFF.md,
  docs/planning/CHANGELOG_AI.md. Nine docs only, one writer per file.
- **Progress:** all six specialists invoked sequentially, sessions in A6phase2. QA flagged R5-01
  missing R0-02 prerequisite; roadmap corrected. Final artifact QA/context found no material blocker.
  Preserve35 findings
  and nested histories. Product naming `GymLevel` versus `GymLvl`
  proposals conflict; defer brand choice to product owner before BUG003 remediation, no silent choice.
- **Decisions/blockers:** no material change; independent sessions/JWT gateway/device gaps retained.
  No production requirement or A6 closure blocker established. A5 UI FAIL remains historical.
- **Verification:** A6phase6 retained validator ->findings35/objects35 unchanged/closures4 unchanged/
  MD35/roadmap35/tasks29/DAG acyclic/oldplan exact/coverage26-0-0-1/paths9/errors0;
  A6_VALIDATION_EXIT node=0 diff=0, PASS. Initial five setup/label failures and corrections retained.
  Roadmap writer checked category29/order29/historyidentical/errors0, exit0. No runtime suite rerun.
- **Next action:** await explicit user approval for R0-01 safety gate followed by separately authorized
  R1-01 SEC002 snapshot ownership, one task at a time. Verify latest main/remote first. Stop before
  any W0/W1/remediation/migration execution.

## Historical A5 closure (preserved)

## Current — A5 PASS/CLOSED; A6 NOT STARTED (2026-10-28)

**Checkpoint outcome (2026-10-29):** closure payload main
ab19e97bd7c143ee7a140a461d774a4ebfea7443, nine-doc delta after PARTIAL614ee7c, aggregate A5 scope11docs.
Normal push614ee7c..ab19e97 exit0; local/remote refs/heads/main equal fullSHA and tree clean after push,
A5_CLOSURE_EQUAL_CLEAN=PASS. This outcome-only four-doc child advances HEAD; verify actual latest
main/remote on resume, not a self-referential commit claim.

- **Task/status:** A5 only, PASS/CLOSED for scoped audit acceptance, not product/production
  certification; mandatory scope reviewed or finite owned gaps dispositioned. A4 closed; A6 not started.
- **Commit:** entry main1763ab55e8da994bc1d854ad8fd2cd2299678b45; PARTIAL614ee7c then closure
  ab19e97 above, normally pushed and verified remote-equal/clean. This outcome child edits only
  audit handoff plus three planning docs; no findings/product/permanent-test/CI/dependency/config change.
- **Files since entry:** docs/audit/phases/A5_TEST_RELIABILITY.md,
  docs/audit/phases/A5_FLUTTER_EVIDENCE.md, docs/audit/phases/A5_BACKEND_EVIDENCE.md,
  docs/audit/phases/A5_UI_EVIDENCE.md, docs/audit/MASTER_FINDINGS.md,
  docs/audit/FINDINGS_REGISTER.json, docs/audit/AUDIT_COVERAGE.md, docs/audit/SESSION_HANDOFF.md,
  docs/planning/TASK_BOARD.md, docs/planning/SESSION_HANDOFF.md, docs/planning/CHANGELOG_AI.md.
- **Findings/coverage:**35 severity0/3/24/6/2, confidence16/18/1, Accepted29/NV3/Fixed1/FP2;
 30 oldIDs/history preserved, six exact pre-A5 objects, five narrow promotions/five newIDs,
 24 unchanged objects. New BUG008/009, INTG008/009, TEST002; transport pair stays High/NV.
  Coverage26static/0InReview/0NotReviewed/1excluded, no blanket runtime claim.
- **Delegation/QA:** all five actually invoked sequentially; material source/evidence inspection
  and final artifact/context reviews completed, no material closure blocker; stale documentary words
  corrected. QA source-diff BLOCKED(permission), keeper exit wrappers rejected, no retry/bypass or QA
  runtime claim; weak disabled counter qualified. Scope-qualified findings phase5, gaps phase6.
- **Verification:** primary analyze0issues(62.9s)/format125unchanged/test126, SQL10/Edge15/sixchecks
  all exit0; specialist Flutter18/streams15/UUID150/expiry-only/plans pass. UI aggregate FAIL8pass2
  nullable-chip fixture fails; external-file analyzer FAIL296 package-context issues, not app defects.
  Full retained commands/source/output/failures; defect-observing green never means a fix.
- **Decisions/blockers:** none material. Independent sessions/fullAuthJWTgateway require supported
  isolated stack (Docker/Supabase/Postgres commands unavailable); device/network/telemetry/performance
  budgets unexecuted, finite owner/wave/trigger assertions retained. No production requirement.
- **Artifact verification:** phase8 retained extraction/Node ->A5_ARTIFACT_CHECK json35/md35/oldIDs30/
  unchangedClasses25/unchangedObjects24/histories6/newIDs5/fields22/coverage26-0-0-1/allowedPaths11/
  unchangedInputs65/errors0, A5_VALIDATION_EXIT node=0 diff=0, PASS. Two primary validator metadata-
  shape FAILs corrected in validator only, retained; no finding change or permission widening.
- **Next action:** await explicit A6 go-ahead, then verify latest main/remote and use exact audit
  handoff **A6 entry prompt**. Stop before A6/remediation/migration automatically.

## Historical A5 start/PARTIAL state (preserved)

## Current — A5 audit in progress (2026-10-28)

- **Task/status:** A5 only, operational PARTIAL; scoped acceptance NOT RUN pending UI/QA/register
  reconciliation. Flutter/backend bounded reviews/probes complete. A4 remains closed.
- **Commit:** main1763ab55e8da994bc1d854ad8fd2cd2299678b45 clean/remote equal at entry; primary
  gymlvl-orchestrator verified. External bundle/bare/archive backup verified(555 files), A5phase2.
- **Files:** docs/audit/phases/A5_TEST_RELIABILITY.md, optional A5_FLUTTER_EVIDENCE.md,
  A5_BACKEND_EVIDENCE.md, A5_UI_EVIDENCE.md; findings mirrors/coverage/audit handoff and three planning
  records only. No product/permanent-test/migration/CI/dependency/config/permission changes.
- **Verification:** real context/Flutter/Supabase sessions in A5phase2. External Flutter18tests pass,
  analyze0issues; backend expiry-only/150UUIDreplay/12request+3providerstreams/SQL10/Edge15/sixchecks/
  EXPLAIN100-1000 exit0. Exact retained sources/outputs/initial failures in two evidence docs.
  UI/QA pending; existing30 finding objects/classifications unchanged, no new ID allocated yet.
- **Decisions/blockers:** no material decision/closure blocker established. Independent sessions
  BLOCKED: local Docker/Supabase/PostgreSQL executables unavailable; no supported isolated server.
  JWT gateway/device/cancellation unverified; no single-connection concurrency claim.
- **Next action:** persist A5 PARTIAL checkpoint then UI review/probes and material QA. Normal
  docs commits/pushes authorized; no A6/remediation/migration/secret/live/cleanup/full-app Temp copy.

## Historical A4 closure (preserved)

## Current — A4 PASS/CLOSED; A5 NOT STARTED (2026-10-28)

**Recorded A4 payload checkpoint:** main84462d0acc27a4c9ea0f99a2c0aa16c0940082fb, nine docs,
normal push `c95cb48..84462d0 main -> main`, exit0. Local/remote refs/heads/main equal full SHA;
status empty after push, A4_CHECKPOINT_EQUAL_CLEAN=PASS. This outcome-only child record advances
documentation HEAD; verify actual HEAD/remote on resume, not a self-referential commit claim.

- **Task/status:** A4 only, PASS/CLOSED for scoped audit acceptance with explicit deferred gaps;
  not product/production certification. A2/A3 remain CLOSED; A5 not started.
- **Commit:** entry main c95cb4873455b39f3ab2b6c0f929b43d87f4d8d3 clean/remote equal; payload
  main84462d0 above committed/pushed normally, clean/remote equal. This outcome record edits only
  four handoff/planning docs; no product/config/schema/permanent-test/agent/dependency changes.
- **Changed files:** docs/audit/phases/A4_WORKOUT_PROGRESSION.md,
  docs/audit/phases/A4_SQL_EVIDENCE.md, docs/audit/MASTER_FINDINGS.md,
  docs/audit/FINDINGS_REGISTER.json, docs/audit/AUDIT_COVERAGE.md, docs/audit/SESSION_HANDOFF.md,
  docs/planning/TASK_BOARD.md, docs/planning/SESSION_HANDOFF.md, docs/planning/CHANGELOG_AI.md.
- **Findings/coverage:**30 (P0 0/P1 3/P2 20/P3 5/P4 2; Confirmed9/High20/Medium1), Accepted24/
  NeedsVerification3/Fixed1/FalsePositive2;24 Reviewed(static)/0 InReview/2 NotReviewed/1 OutOfScope.
  All26 earlier IDs/history retained, only DATA001 and ARCH001 old classifications change. DATA001
  synthetic prior-credit/log falseflag/noledger duplicate global credit Confirmed; prod cohort and
  normal-retry duplication not established. ARCH001 FalsePositive (sole award vs maintenance), not
  Fixed. New DATA002 and INTG005-007; INTG007 timed quest journey remains High/NeedsVerification.
- **Delegation/QA:** all five required agents actually invoked sequentially; sessions/outputs in A4
  phase2. Independent material and final artifact-only inspection completed; context/QA stale wording
  corrections applied. No material closure blocker; no QA runtime rerun. QA scope/status/whitespace
  exit0; extra exclusion-diff command BLOCKED(permission), not retried or bypassed, permissions unchanged.
- **Verification:** node <A4 external path>/probe.mjs ->8groups/15 sequential DBs/108assertions/
  zero fetch/exit0, primary independent rerun also exit0; node tools/db-tests/run.mjs ->PASS10 units/
  PostgreSQL17.5, exit0; app analyze --no-pub ->No issues found(3.0s), format ->125files/0changed,
  tests --no-pub --reporter expanded ->+126 All tests passed, all exit0. Edge NOT RUN (unchanged).
  Initial catalogue-parser/legacy-title-validator FAILs corrected and retained; no product repair.
- **Artifact verification:** phase10 retained extraction/Node command -> A4_ARTIFACT_CHECK json30/
  md30/oldIDs26/unchangedClasses24/exactHistories2/newIDs4/fields22/coverage24-0-2-1/allowedPaths9/
  unchangedProbeInputs7/errors0; A4_VALIDATION_EXIT node=0 diff=0, PASS. Primary validator's three
  setup/overstrictness FAILs corrected in its own source only and retained; final context/QA completed.
- **Decisions/blockers:** no material decision or closure blocker established. Independent concurrency,
  transport-loss/reorder/delete/hydration, actual Dart quest, isolated expiry/device/gateway checks
  explicitly unexecuted with A5 owners/assertions in A4 phase8 and exact audit handoff prompt. No
  production inspection, full-app Temp copy or cleanup; prior A2 disposal still approval-gated.
- **Next action:** await explicit A5 authorization, then verify latest main/remote and use
  docs/audit/SESSION_HANDOFF.md **A5 entry prompt**. Stop; do not start A5/A6/remediation automatically.

## Historical A3 and prior handoffs (preserved)

## Current — A3 scoped audit CLOSED; A4 not started (2026-10-28)

**A3 checkpoint:** main c535613fe29cf5a435ead44a6c4c26a16e3074ae, nine docs, normal push
f877e40..c535613 main -> main, exit0. Remote main equals local full SHA, status empty after push.
This child outcome record advances documentation only; verify actual HEAD/remote on resume.

- **Task/status:** A3 Supabase/PostgreSQL/security C17-C21 PASS/CLOSED with assigned runtime gaps;
  not production certification. Entry main f877e40987423f3804fe0d2887c44d19f3423aff, clean/remote equal,
  API gymlvl-orchestrator. Normal docs commit/push authorized and completed as recorded above.
- **Changed files:** A3_SUPABASE_SECURITY.md, A3_SQL_EVIDENCE.md, audit findings/register/coverage/
  handoff; planning TASK_BOARD/SESSION_HANDOFF/CHANGELOG_AI. Nine docs only, no product/permanent test.
- **Findings:**26; P0 0/P1 3/P2 16/P3 5/P4 2; Confirmed5/High19/Medium2; Accepted21/
  NeedsVerification3/Fixed1/FalsePositive1. All24 prior IDs/classifications preserved; addenda on
  DATA001/ARCH001/SEC002. SEC003 conditional PUBLIC ACL fixture Confirmed, not production exploit;
  SEC004 buffering High/NeedsVerification, not confirmed DoS. No P0/P1 new finding.
- **Coverage:**18 static-reviewed/5 mixed-stage InReview/3 NotReviewed/1 excluded. A3 security halves
  complete, C18 reward semantics A4; C09/C23/C24 still not reviewed; no whole-row runtime claim.
- **Current checks:** SQL runner10 units/PostgreSQL17.5 PASS; Edge deny-net/cached-only/synthetic env
  15passed0failed, six handler checks PASS. Custom default FAIL falsifies named-role grant hypothesis;
  independent PUBLIC14 and named-control4 assertions PASS, exact source/output retained. No concealed
  failure, no live DB/provider traffic/secret reads/installs or persistent migration applied.
- **QA:** material source + repository retained evidence review completed; initial external read
  BLOCKED not bypassed. Fresh B-vs-A controls support limited server boundary, not local cache repair.
- **Current artifact checks:** orchestrator inline Node -> A3_CHECK json=26 md=26 old_ids_preserved=24
  old_classifications_preserved=24 required_fields=22 allowed_paths=9 errors=0; node0/diff0, current
  baseline f877e40. QA Git scope/whitespace pass; final missing durable output note was flagged and
  corrected here/phase12/audit handoff/changelog. Its parser/runtime checks NOT RUN.
- **Decisions/blockers:** no architecture/schema/dependency/permission change. Gateway/concurrency/
  deployed ACL verification unavailable and explicitly deferred; no A3 closure blocker. A2 Temp
  deletion still requires exact-path user approval; no cleanup.
- **Deferred:** A4 Supabase/Flutter/QA reward/legacy/order/retry/timed/domain semantics; A5 Supabase/
  Flutter/UI/QA gateway/Auth/resource/fullrole matrix; separate authorized deployment ACL inventory.
  Exact acceptance assertions in A3 phase9. Existing A2 Lead10 remains A5; A2 not reopened.
- **Next action:** await explicit A4 authorization, then audit handoff **A4 entry prompt**; do not
  begin A4, remediation or migration from this A3 task.

## Historical start/closure records (preserved)

## Current — A3 audit in progress (2026-10-28)

- **Task/status:** A3 C17-C21 only, in progress; acceptance NOT RUN pending inspection/QA.
- **Entry:** main f877e40987423f3804fe0d2887c44d19f3423aff, clean, remote equal; API agent
  gymlvl-orchestrator. A2 PASS/CLOSED preserved; no new A2 or A4 work.
- **Files:** A3_SUPABASE_SECURITY.md, audit findings/register/coverage/handoff and three planning
  records only. Name follows current explicit user instruction; no source/config/schema/test edits.
- **Verification:** Git and active-agent checks executed; SQL/Edge checks pending, no historical PASS reuse.
- **Decisions/blockers:** no new material decision; no external blocker established yet.
- **Next action:** sequential bounded Supabase schema/security review, Flutter Auth/contract review,
  independent QA; current progress retained in A3 phase, no live/production access or remediation.

## Historical A2 closure (preserved)

## Current — A2 CLOSED; A3 not started (2026-10-28)

**Recorded closure commit:** main `a6a57e2546afa8dbd3dd7113bc1096a6e99f5cdf`, eight docs;
normal push `aa36a4c..a6a57e2  main -> main`, exit0; remote verified equal and status empty
after push (`PASS`). This child record may advance HEAD; verify actual HEAD/remote on resume.

- **Task/status:** A2 scope closure, `PASS` against seven original audit acceptance criteria;
  operational **CLOSED** with owned A4/A5 deferred work. Not full runtime/product correctness.
- **Commit:** closure entry main `aa36a4c36e6c46cc7ae1f2fdd3e117f2a8a3a4c5`, clean, remote equal;
  documentation commit/normal push authorized. Confirm actual HEAD/remote on resume.
- **Changed files:** audit phase A2_FLUTTER, coverage, both registers, audit handoff; planning
  TASK_BOARD/SESSION_HANDOFF/CHANGELOG_AI. Eight docs only; A2_PROBES unchanged.
- **Preservation:** all 24 finding objects/classifications and 22 lead dispositions retained;
  counts P0 0/P1 3/P2 14/P3 5/P4 2; Confirmed 4/High 18/Medium 2; Accepted20/NeedsVerification2/
  Fixed1/FalsePositive1. Coverage remains13 static/5 mixed-stage in review/8 not reviewed/1 excluded.
- **Deferred:** Lead10 -> **A5**, explicit user instruction; flutter-specialist with independent
  qa-reviewer. Synthetic failed-signin -> recovery must not display password-update failure before
  submit; successful/rejected submit controls, retained isolated harness/command/output. NOT RUN,
  no promotion. Other A4/A5 owners and exact assertions in A2_FLUTTER sections8.2/9.3. No open A2 loop.
- **Verification:** current consistency/preservation/Git checks recorded in audit handoff/changelog.
  Existing +126 regression/+7 controller, analyzer and format outputs are historical; current Flutter
  runs NOT RUN intentionally for docs-only scope. Prior QA recorded; closure QA reviews artifacts only.
- **Current result:** inline Node closure check -> findings24/unchanged_objects24/MD24/fields22/
  dispositions22/Lead10A5/ACrecords7/authorized_paths8/errors0; node0/diff0. First attempt failed
  Unicode literal assertions through PowerShell; ASCII-safe rerun passed, no findings/product edits.
  Closure QA/context inspection supports the original scoped criteria and full deferral/A3 records;
  QA did not execute runtime tests. Final Vietnamese communication states PASS versus NOT RUN scope.
- **Decisions/blockers:** no material project decision or waived AC. No A2 closure blocker; future
  live/device checks stay unverified. Probe Temp removal still needs explicit exact-path approval.
- **Next action:** wait for explicit A3 authorization, then execute `docs/audit/SESSION_HANDOFF.md`
  **A3 entry prompt — authorization required**. No A3 or remediation execution in closure.

## Historical A2 partial handoffs (superseded current task/status/next action)

## Current — A2 reconciled PARTIAL checkpoint (2026-10-28)

**Git checkpoint:** `199bf00271c8038c04a8f8cbdc1fc35e7538e90f` on main, docs-only PARTIAL;
`git push origin main` -> `7eb40f1..199bf00  main -> main`, exit 0; `git ls-remote origin
refs/heads/main` equals checkpoint local SHA; tree empty after push (`PASS`). This SHA records the
audit checkpoint; this follow-up record may advance HEAD. Confirm actual HEAD/remote on resume.

- **Task/status:** A2 only, PARTIAL. Whole-stage acceptance `NOT RUN`; A3/remediation not started.
- **Commit/base:** `main` @ `7eb40f1d7e553e9f136abb13f632b8bfb189dc3c`; remote same at entry.
  Latest user authorizes normal PARTIAL documentation commit/push after consistency review; no rewrite.
- **Changed files:** audit findings/register/coverage/handoff, phases A2_FLUTTER/A2_PROBES; planning
  TASK_BOARD/SESSION_HANDOFF/CHANGELOG_AI (nine paths). Original dirty work backed up with nine
  SHA256 matches, bundle clone HEAD and archive 549/549 at
  `C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a2-final-backup-20261028-174845`.
- **State:** 22/22 leads dispositioned in phase section 8.2; seven new IDs. 24 findings:
  P0 0/P1 3/P2 14/P3 5/P4 2; Confirmed 4/High 18/Medium 2; Needs Verification 2/Accepted 20/
  Fixed 1/False Positive 1. CONC001 scope narrowed; post-await hypothesis deferred A5. SEC002
  controller-only synthetic adoption, not real account disclosure. DATA001 server claim unverified.
- **Coverage:** 13 static-reviewed, 5 mixed-stage in review, 8 not reviewed, 1 excluded. No whole-row
  runtime promotion. Deferred A4/A5 tests carry owners and exact assertions.
- **Current verification:** analyzer `No issues found! (ran in 8.5s)`; format `125 files (0 changed)`;
  Flutter `+126: All tests passed!`; all exit 0 at base 7eb40f1. Successful retained probes not rerun.
- **Consistency/QA:** orchestrator Node -> `MD=24 JSON=24 fields=22 old IDs=17 dispositions=22
  errors=0`, coverage13/5/8/1, nine allowed paths; exit 0, diff whitespace exit 0. Read-only QA found
  no documentation blocker, no omitted disposition or missing new field; whole-stage `NOT RUN`.
- **Temp:** full-copy inventory 1,351 files / 1,369,316,592 bytes, no reparse points. Exclusivity and
  disposal safety not proved; contents not read, nothing removed. User review and explicit exact-path
  approval required for `C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a2-probe-20261028`.
- **Decisions:** none affecting product/architecture/permissions/dependencies. Git authorization only.
- **Remaining work:** A2 lead10 focused synthetic recovery-widget assertion and independent QA;
  exact executable A3 handoff follows only after A2 closure. No external blocker claimed.
- **Next action (A2):** retain isolated widget probe: failed sign-in followed by recovery navigation
  must not show password-update failure before submission. Do not repeat whole-module reviews.

## Historical checkpoint records (superseded current-state statements)

## Current recovery checkpoint — A2 incomplete (2026-10-28)

**Continuation:** Retained synthetic probes in `docs/audit/phases/A2_PROBES.md` rerun by orchestrator:
`flutter test --no-pub --reporter expanded test/a2_retained_probe_test.dart` -> `+7: All tests passed!`,
exit 0. Defect-observing tests show active-discard timeout and cross-owner local state adoption with
fake null/error remote; controls pass. QA independently inspected narrow scope. Post-await race,
real-user UI/RLS and 22-lead triage remain unverified. Additional changed file: `A2_PROBES.md`.
Current continuation checks: analyzer `No issues found! (ran in 5.3s)`; formatting `125 files (0
changed)`; Flutter `+126: All tests passed!`; Node register `MD=17 JSON=17 mismatches=0`; each exit 0.
The first temporary copy of the entire app could contain secret files; do not inspect or share it and
ask user before cleanup: `C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a2-probe-20261028`.
External backup of the original eight dirty artifacts was verified (bundle SHA, 549/549 archive count,
eight matching file hashes) at `C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a2-backup-20261028-171019`.
Next: reconcile 22 A2 leads, update both registers/coverage and obtain final QA; no A3.

- **Task/status:** A2 Flutter deep audit, PARTIAL. Complete-stage acceptance `NOT RUN`.
- **Commit:** `main` @ `7eb40f1d7e553e9f136abb13f632b8bfb189dc3c`; remote equal at recovery entry;
  tree clean then, eight authorized documentation files pending now. No A2 commit/push yet.
- **Agent:** server session `ses_e7e81bc84ffeWkbb0tV5jo0jwp` reports `gymlvl-orchestrator`.
- **Progress:** recovered three historical specialist reports; sequential QA, workout-presentation
  and context reviews now complete. No active child tasks. Phase artifact preserves all leads.
- **Findings:** 17; P0 0/P1 4/P2 6/P3 5/P4 2. New FND-SEC-002 is P1/High/Needs Verification.
  CONC-001/DATA-001 addenda preserve confidence/history. Controller does reset memory/timers on auth
  identity change; unchecked backup owner is a separate issue. No server-side XP duplication confirmed.
- **Changed files:** `docs/audit/{MASTER_FINDINGS.md,FINDINGS_REGISTER.json,AUDIT_COVERAGE.md,
  SESSION_HANDOFF.md,phases/A2_FLUTTER.md}` and
  `docs/planning/{TASK_BOARD.md,SESSION_HANDOFF.md,CHANGELOG_AI.md}`.
- **Verification (7eb40f1):** `flutter analyze --no-pub` -> `No issues found! (ran in 4.2s)`;
  `dart format --output=none --set-exit-if-changed lib test` -> `Formatted 125 files (0 changed)`;
  `flutter test --no-pub --reporter expanded` -> `+126: All tests passed!`; each exit 0 (`PASS`).
- **NOT RUN:** retained focused controller/account-switch probes, rendered contrast/keyboard checks,
  complete candidate reconciliation and final A2 QA. Historical temporary test was deleted; do not
  turn its carried output into current PASS.
- **Artifact verification:** orchestrator Node check -> MD 17 / JSON 17, 22 required fields,
  classifications/counts synchronized; `git diff --check` -> no whitespace errors, status only eight
  authorized docs (`PASS`). Independent artifact QA Node check `BLOCKED` by shell permission denial;
  no permissions changed. It independently verified Git scope/HEAD/whitespace.
- **Decisions:** none. Current user allows A2 normal commit/push after complete, superseding the old
  audit prompt's prohibition; no rewrite. Lower A1 baseline/"run A1" entries are historical/stale,
  not executable next actions.
- **Blockers:** no external prerequisite missing; unfinished verification/triage prevents closure.
- **Next action:** A2 retained audit-only real-controller probe for discard enqueue cycle and
  cross-owner snapshot adoption (completing-cancel and same-owner controls), then reconcile phase
  section 5 leads. Do not begin A3 or remediation; final A3 execution prompt is not drafted yet.

## Historical A1 handoff (preserved; not current A2 status)

**Updated:** 2026-10-28 (A1 audit complete — 16 findings)
**Last agent:** **`gymlvl-orchestrator`** — proven from the server, not from configuration: session
`ses_e7e81bc84ffeWkbb0tV5jo0jwp` reports `"agent":"gymlvl-orchestrator"` via
`opencode-cli.exe api get /api/session/<id>`.
**Mode:** Read-only audit of architecture, dependencies, configuration, infrastructure and CI, plus the
A1 checkpoint commit and a normal push to `origin/main`. No application, SQL, UI, schema, CI, or
dependency change.
**Baseline:** branch `main` @ `c9cc764` = `origin/main` after the A1 checkpoint push. A1 was measured
at `e8c7c8e`, the parent of that commit. Confirm with `git rev-parse main` and
`git ls-remote origin refs/heads/main` before trusting this line.
**Next task:** **A2 — Flutter app, state, lifecycle, concurrency, navigation** (`READY`, audit track;
prompt in `docs/audit/SESSION_HANDOFF.md` §6). **M1-01** (product) and **S4** (skills) remain
unauthorized.

---

## 0. Current state — A1 complete (newest)

| Item | Value |
|---|---|
| Agent access policy | `PASS` — **D-024**. Orchestrator + 5 development specialists have full repository access; irreversible or sensitive operations resolve to `ask`; `qa-reviewer` and `context-keeper` remain read-only |
| Active agent (this session) | **`gymlvl-orchestrator`**, proven from the server, not from configuration |
| Orchestrator write | `PASS` end-to-end — A1 wrote every `docs/audit/**` artifact while running as the orchestrator |
| A1 audit | **`PASS`** — `docs/audit/phases/A1_ARCHITECTURE.md` |
| Findings | **16 total** — 0 `P0`, 3 `P1`, 6 `P2`, 5 `P3`, 2 `P4`; 2 `Needs Verification`, 12 `Accepted`, 1 `Fixed`, 1 `False Positive`. Ten added by A1 |
| Coverage | C-22, C-25, C-26 `Reviewed (static)`; 3 of 27 reviewed, 1 `In Review`, 22 `Not Reviewed` |
| Git | `c9cc764` on `main`; `origin/main` moved `e8c7c8e` → `c9cc764`. A1 measurements were taken at `e8c7c8e` |
| Push | `PASS` — `git push origin main` → `e8c7c8e..c9cc764  main -> main`, exit 0; `git ls-remote origin refs/heads/main` equals local HEAD. One approved `--amend` removed a UTF-8 BOM from the unpushed subject line |
| Backup | `…\Temp\opencode\gymlvl-s2-backup-20261028\` — bundle verified at S3 |

**Read first on resume:** `AGENTS.md` §0.1, this section, `docs/agent-system/ACCESS_POLICY.md`, then
`docs/audit/SESSION_HANDOFF.md`, then `TASK_BOARD.md`.

### Verification at A1 close (2026-10-28, `main` @ `e8c7c8e`)

| Check | Command | Result | Status |
|---|---|---|---|
| Branch / HEAD | `git rev-parse --abbrev-ref HEAD` / `git rev-parse HEAD` | `main` / `e8c7c8e7e346790ac1807dc5c8d4e43c2ee880ef` | `PASS` |
| Remote equality | `git ls-remote origin refs/heads/main` | `e8c7c8e7e346790ac1807dc5c8d4e43c2ee880ef` — equal to local | `PASS` |
| Tree | `git status --porcelain=v1` | `CLEAN (0 entries)` at A1 entry | `PASS` |
| Active agent | `opencode-cli.exe api get /api/session/ses_e7e81bc84ffeWkbb0tV5jo0jwp` | `"agent":"gymlvl-orchestrator"` | `PASS` |
| Toolchain | `flutter --version` | `Flutter 3.38.5 • channel stable`, `Tools • Dart 3.10.4` | `PASS` |
| Static analysis | `cd app; flutter analyze` | `No issues found! (ran in 2.5s)`, exit 0 | `PASS` |
| Formatting | `cd app; dart format --output=none --set-exit-if-changed lib test` | `Formatted 125 files (0 changed) in 0.71 seconds.`, exit 0 | `PASS` |
| Rule model, documented probes | `node gymlvl-perm-check.mjs` | `RULES VALIDATED: 73 global + 62 agent` / `RESULT: PASS (0 probe failures, 0 schema problems)` | `PASS` |
| Rule model, 18 destructive-operation probes | `node a1-git-gate-probe.mjs` | `RESULT: FAIL (12 probe failures, 0 schema problems)` — `FND-GOV-004`, `FND-SEC-001` | `FAIL` — the failures are the finding |
| Register sync | `node a1-sync-check.mjs` | `md findings: 16 json findings: 16`, `mismatches: 0` | `PASS` |
| Migrations census | `node a1-lines2.mjs` + policy/trigger/function census | 661/349/367 lines (1,377 total, 1,219 non-blank); 17 tables; 44 policy statements → 22 effective; 11 `SECURITY DEFINER`; 10 triggers | `PASS` |
| Product regression (`flutter test`, SQL, Edge) | not rerun — A1 changed no product, SQL, or test file | — | `NOT RUN` |
| Android/iOS build | not attempted; would write artifacts and needs an SDK host | — | `NOT RUN` |
| Live permission probe | not attempted; would require issuing a destructive or secret-reading command | — | `NOT RUN` |

Detail and quoted output: `docs/audit/phases/A1_ARCHITECTURE.md` §12.

### Verification at D-024 close

| Check | Command | Result | Status |
|---|---|---|---|
| Config parses | `node …\gymlvl-perm-check.mjs D:\Projects\gymlvl` | `PARSE .opencode/opencode.jsonc : OK (73 global rules, default_agent=gymlvl-orchestrator)` | `PASS` |
| Effective rules, not file text | same run | `RESULT: PASS (0 probe failures, 0 schema problems)` over 66 probes | `PASS` |
| Agent frontmatter parses | same run | 7 agents: 0 rules × 5, qa-reviewer 41, context-keeper 21 | `PASS` |
| Server reloaded definitions | `agent.updated` events in `~/.local/share/opencode/log/opencode.log` | 8 events, `07:33:43.390Z`–`07:34:31.580Z`, one per file write | `PASS` |
| Active agent | `GET /api/session/ses_e7e999dd2ffdO3oGdRJnVFBuY1` | `"agent":"build"` | `PASS` |
| Orchestrator write, previously denied path | `opencode-cli.exe run --agent gymlvl-orchestrator …` | wrote `app/.perm-probe-2.md`; `Test-Path` → `True`, `Get-Content` → `probe` from a different session | `PASS` |
| Orchestrator shell, previously denied command | same session | `node --version` → `v22.17.0` | `PASS` |
| Reviewer write denial | `subagent(qa-reviewer)` | `Set-Content docs/audit/.qa-write-probe.md` → `permission.rejected`; `Test-Path` → `False` | `PASS` |
| Reviewer Git write denial | same session | `git commit --allow-empty -m "probe"` → `permission.rejected`; HEAD unchanged at `425686c` | `PASS` |
| Reviewer has no write tool | same session | `tools.write` / `tools.edit` → `Unknown tool` | `PASS` |
| Delegation | `subagent(qa-reviewer)` | review completed and returned evidence | `PASS` |
| Secret gate at runtime | no `.env` exists in the workspace | not exercised | `NOT RUN` |
| Product regression (`flutter analyze`, `flutter test`, SQL, Edge) | not rerun — no product or test file changed | — | `NOT RUN` |
| Android/iOS build | not attempted | — | `NOT RUN` |

Runtime evidence detail lives in `docs/agent-system/ACCESS_POLICY.md` §4.

### Operational rules learned

- **Never put a broad allow in an agent file.** OpenCode V2 appends agent rules after the global set and
  the last match wins, so an agent-level `shell "*"` → `allow` silently cancels every global gate. Gates
  belong in exactly one place: `.opencode/opencode.jsonc`.
- **Prove the active agent from the server.** `GET /api/session/<id>` returns the session's `agent`. The
  bundled CLI is at `…\Programs\ai.opencode.desktop\resources\opencode-cli.exe`; it is not on `PATH`.
  `default_agent` remains a session-creation default, not a live switch (D-023).
- **A nested agent's self-report is not evidence.** The first orchestrator probe claimed a file that was
  gone at cleanup time; the repeat was asserted from a different session. Only the second result counts.
- **`opencode-cli.exe` exits 1 after a successful run** because PowerShell raises `NativeCommandError`
  on its stderr banner. Judge by output, not exit code.
- **`ask` is a guardrail, not a sandbox.** Shell runs with the host user's full authority.

### Known open items

- **A2 is not started.** `docs/audit/SESSION_HANDOFF.md` §6 holds the authoritative A2 prompt and its
  seven acceptance criteria. A1 is complete: `docs/audit/phases/A1_ARCHITECTURE.md`.
- `FND-GOV-002`: the stale-claim inventory is **complete** (A1, `phases/A1_ARCHITECTURE.md` §10 — 15
  claims across nine documents). `PROJECT_CONTEXT.md` §2 is now 7 commits behind with a 37-short file
  count, and the `DECISIONS.md` summary table still stops at **D-014** while D-015…D-024 have sections.
  The W4 fix is a single pass.
- Three release-blocking or template defects in the Android/iOS configuration were registered by A1
  (`FND-BUG-001` P1, `FND-BUG-002` P2, `FND-BUG-003` P4). `TASK_BOARD` §M1-02 already planned the fixes;
  the register now has IDs to close.
- `FND-GOV-004` and `FND-SEC-001` (P2 each) record that the permission layer gates 6 of 18 probed
  destructive/secret operations. They are `High`, not `Confirmed`, because a live probe would require
  issuing the destructive command. Closing them is a configuration change needing approval.
- Two P1 findings (`FND-CONC-001`, `FND-DATA-001`) are inherited and still unverified.
- Shell secret gates are pattern-based; an obfuscated path such as `Get-Content ("."+"env")` is not
  matched. The `read`-tool gates are stronger than the shell gates.
- Reviewers cannot chain compound commands (`git status; flutter analyze` is denied) because their
  allowlist is per-segment.
- O-10: Apache-2.0 notice for the `context-window-management` adaptation. Release blocker only.
- S4 (Wave 2, 14 skills) is `PLANNED` and requires explicit approval.

### Exact next action

Await an explicit instruction, then run **A1** using the prompt in `docs/audit/SESSION_HANDOFF.md` §6 in
a session that has been confirmed to be the intended agent. Do not start M1-01 or S4. Do not begin
remediation.

---

> Sections 1–9 below are the **prior** consolidation-session record, preserved as evidence at
> `17ca562`. They describe history, not the current state.

## 1. What this session did

Consolidated all existing work into `main` and made `main` the only development branch. No feature
work was started. No application code, SQL migration, Edge Function, CI config, dependency, UI, or
media was changed.

| Step | Result |
|---|---|
| Pre-change backup (tracked HEAD + uncommitted files) | Created and verified — §3 |
| Committed the nine memory files | `17ca562` — 9 files, +2,015 lines |
| Integrated into `main` | Fast-forward `e003803..17ca562`; no merge commit, no conflicts |
| Pushed `main` | `e003803..17ca562  main -> main` (no force) |
| Regression suites at `17ca562` | Flutter 126/126, SQL 10/10, Edge 15/15 — §4 |
| Workflow documentation | `AGENTS.md`, `DECISIONS.md` D-014, this file, `TASK_BOARD.md`, `CHANGELOG_AI.md`, `PROJECT_CONTEXT.md`, `MASTER_PLAN.md` |

The old branch `codex/supabase-product-audit` was **not** deleted. It is retained at `17ca562` for
provenance and is no longer a development target.

## 2. Git state

| Item | Value |
|---|---|
| Development branch | `main` (only) |
| Consolidation checkpoint | `17ca562f7d382cdd16e17a414460b8266edcf16b` (`17ca562`) |
| Previous `main` | `e0038038300d5bfaf3c4747094cf36a132eb8711` (`e003803`) |
| Integration method | `git merge --ff-only` — fast-forward, both histories preserved |
| `origin/main` | Pushed and verified equal to local `main` at the checkpoint |
| `codex/supabase-product-audit` | Retained at `17ca562` (read-only provenance) |
| Working tree | Clean at the checkpoint; test-generated plugin files matched HEAD byte-for-byte |
| Tags | None created |
| Force push / reset / rebase / branch deletion | None used |

After the workflow-doc commit, `main` and `origin/main` must again match; that equality is verified in
the consolidation report for the final HEAD.

**History note:** `56c1122` (381 files, +33,198/−8,080) remains a valid historical checkpoint on the
audit branch. It was created outside the M0/audit sessions; the actor and timing are unverified.

## 3. Backup evidence

**Location:**
`C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-backups\20261028-main-consolidation\`

| Artifact | Size | SHA-256 |
|---|---|---|
| `gymlvl-pre-consolidation-all-refs.bundle` | 3,163,282 bytes | `CB9AA6E1C1A91C8178114D53E2375B0ED0788D808DFA0CBA4F8D80FDF4251F00` |
| `gymlvl-pre-consolidation-HEAD.zip` | 4,969,624 bytes | `CD458094BA1F20176C6080F3DC59F9D5432E6862C6E2B748B2203805FD9444C9` |
| `gymlvl-uncommitted-memory-files.tgz` | 35,827 bytes | `4DFB158D1255F26E029E854C4A91608E0B6058F2DE324A140EBB9BAE5C714D62` |

Verification performed:

- `git bundle verify` → "The bundle records a complete history", "is okay".
- Fresh `git clone --bare` from the bundle → HEAD
  `56c112213e43c8c11c620b9cd1258475fb2e9935`, equal to the pre-consolidation repository HEAD.
- `git archive` ZIP extracted → 502 files, equal to `git ls-tree -r --name-only HEAD` = 502.
- Uncommitted archive → 9 files; every extracted file hash matched the working-tree source.
- Bundle contains 6 refs: local and remote `main`, local and remote audit branch, `origin/HEAD`, HEAD.

The backup preserves the pre-consolidation state: audit branch `56c1122`, `main` `e003803`, and the
nine uncommitted memory files. It remains outside the repository working tree.

## 4. Verification run in this session

All runtime results below were obtained at consolidation checkpoint `17ca562`; the working tree was
identical to that commit except for the workflow docs added afterwards.

| Command | Result | Status |
|---|---|---|
| `git status --porcelain=v1` (before commit) | Only the nine expected memory files | `PASS` |
| `git fetch origin --prune` | No new remote commits; audit branch remote still `56c1122` | `PASS` |
| `git merge-base --is-ancestor main codex/supabase-product-audit` | True — fast-forward safe | `PASS` |
| `git merge --ff-only codex/supabase-product-audit` | `e003803..17ca562`, fast-forward | `PASS` |
| `cd app; flutter analyze` | No issues found | `PASS` |
| `cd app; flutter test` | 126 passed | `PASS` |
| `cd app; dart format --output=none --set-exit-if-changed lib test` | 125 files, 0 changed | `PASS` |
| `cd tools/db-tests; npm test` | 10/10 SQL units; 150 catalog exercises; PostgreSQL 17.5/PGlite | `PASS` |
| `cd tools/db-tests; npm run test:edge` | 15 passed, 0 failed | `PASS` |
| `git push origin main` | `e003803..17ca562  main -> main` | `PASS` |
| `git ls-remote origin refs/heads/main` | `17ca562f7d382cdd16e17a414460b8266edcf16b` — equal to local `main` | `PASS` |
| Android release build/device smoke | Not attempted | `NOT RUN` |
| iOS build | Not possible on Windows | `NOT RUN` |
| Live Supabase / AI provider | Not attempted | `NOT RUN` |

**Limitation:** the SQL harness is single-connection PGlite, not a full Supabase gateway/Auth/Edge
runtime. It does not prove production behavior.

**Test artifact note:** Flutter regenerated five platform plugin registrant files. Their bytes matched
`HEAD` exactly (`git hash-object` equal to the `HEAD:` blob); only the index stat cache was stale.
They were refreshed with `git add` and produced no staged diff. The tree is clean.

## 5. M0 provenance

The M0 report was delivered **only in the prior session's chat transcript**. No M0 report file
existed. `docs/planning/M0_AUDIT.md` is a structured reconstruction with explicit evidence labels,
not a verbatim copy. M0 was planning-only and made no application/DB/deployment changes.

Key M0 findings still open: missing Android `INTERNET` permission, placeholder app names, chat-only
coach, network-first set logging, 150-exercise catalog, name-only search, no plans/progression/PR
features, stale docs, and no LICENSE.

## 6. Decisions and unresolved blockers

### Decisions recorded

- D-001 platform preservation — accepted.
- D-002 AGPL reference-only, MIT text only — accepted for current milestones; long-term license
  posture open.
- D-003 media postponed — accepted.
- D-004 M1 re-baselined to stabilization — proposed, needs approval before M1-02.
- D-005 Drift — proposed, not approved.
- D-006 import all 1,324 MIT text records — proposed.
- D-007 AI proposal/approval architecture — accepted product contract; implementation pending M6.
- D-008 server-authoritative XP — accepted invariant.
- D-009 no automatic Git writes — accepted; the consolidation was covered by explicit user approval.
- D-010 canonical memory files — accepted.
- D-011 baseline `56c1122` — recorded; superseded by D-014 as the current baseline.
- D-012 documentation-only bootstrap — accepted.
- D-013 verified external backup — accepted.
- **D-014 `main` is the sole development branch — accepted (explicit user instruction).**

### Open blockers

| Blocker | Affects | Exact prerequisite |
|---|---|---|
| Android SDK/licences/device unknown | M1-02, M1-05, M8 | Confirm `flutter doctor`, Android SDK, and a device/emulator |
| iOS build impossible on Windows | M1-02, M8 | macOS + Xcode machine |
| No approved live Supabase project | M2+ verification | Project owner provides credentials/approval |
| No live AI provider verification | M6 | Provider choice, key policy, cost approval |
| No GymLvl LICENSE / contributor rights | Distribution, M8 | Legal decision |
| 150 curated text provenance undocumented | Catalog trust, M2 | Provenance audit |
| No checkpoint tag | M1-01 | Approval of tag name/creation |

## 7. Exact next action

**Proposed next action — M1-01 — Baseline stabilization and evidence lock.**
This task is proposed, not pre-authorized. Wait for the user's go-ahead before starting.

First concrete step:

1. Re-run `git status --porcelain=v1`, `git branch --show-current`, `git rev-parse HEAD`, and
   `git ls-remote origin refs/heads/main`; confirm `main` and `origin/main` still match.
2. Verify the backup hashes in §3 still match.
3. Create `docs/planning/UPSTREAM_SOURCE_MANIFEST.json` and
   `docs/planning/LICENSE_LEDGER.csv`.
4. Produce `docs/planning/BASELINE_REPORT.md` with the command matrix and conflict register.
5. Update `TASK_BOARD.md`, this handoff, and `CHANGELOG_AI.md`.
6. Propose the checkpoint tag and stop for approval.

Do **not** start M1-02, catalog import, schema changes, UI refactors, or media work. Do not create a
branch; all work belongs on `main`.

## 8. Next-session prompt (copy-paste)

```text
You are continuing GymLvl in BUILD mode. Read AGENTS.md first, then
docs/planning/SESSION_HANDOFF.md, TASK_BOARD.md, PROJECT_CONTEXT.md,
ARCHITECTURE.md, DECISIONS.md, M0_AUDIT.md, and MASTER_PLAN.md.

Baseline: branch main only, consolidation checkpoint 17ca562. The nine memory
files are committed; the tree is expected to be clean and equal to origin/main.
The next proposed task is M1-01 — Baseline stabilization and evidence lock.
Wait for explicit user go-ahead before starting it.
Scope: documentation and verification only. Do not touch app code, SQL, CI,
dependencies, catalog, media, or UI. Do not commit, push, or tag without approval.

Verify the baseline and backup first, then create UPSTREAM_SOURCE_MANIFEST.json,
LICENSE_LEDGER.csv, and BASELINE_REPORT.md, update the task board/handoff/changelog,
and propose a checkpoint tag. Stop after M1-01 and report PASS/FAIL/BLOCKED/NOT RUN
with exact commands and evidence.
```

## 9. Guardrails

- **Use `main` only.** Do not create or switch branches without explicit user authorization.
- Never invent verification. A prior session's result is not a current `PASS`.
- Preserve user work and the 150 exercise UUIDs.
- No AGPL code/text reuse; no third-party media.
- Keep PostgreSQL authoritative for XP/rewards.
- Keep Candy UI and VI/EN support.
- No destructive Git or database operations; never force push.
- Update `TASK_BOARD.md`, `SESSION_HANDOFF.md`, and `CHANGELOG_AI.md` at every checkpoint.
