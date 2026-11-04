# M3.5 Final Report — Superset, Modes, and Offline Security Foundation

**Date:** 2026-11-03
**Baseline:** `main` @ `bd078c79a25a5b253ce1c1e72300dddc050570fe`
**M3.5 status:** `PASS` for the approved local/test implementation and focused QA.
**M3 status:** `PARTIAL`; production offline activation and final M3 closure remain blocked.

## Authority and safety

D-041 records the owner's approved retention, encryption/ownership, Superset v1, and four-mode contracts. This work uses synthetic/local data only. No remote migration, deployment, production offline write, Git stage/commit/push/tag, or M4 work occurred. The existing online workout-write path remains compatible with the deployed schema. Four compile-time gates remain `false`: production offline sync, production payload protection, production workout modes, and production Superset.

Pre-edit backup `D:\Projects\gymlvl-backups\m3_5-execute-20261103-051124` was verified: bundle clone matched HEAD; Git archive held 598/598 tree files; 41/41 pre-existing dirty-file copies matched SHA-256. Protected owner files were not edited. The index remained empty.
Post-edit SHA-256 comparison found 12/12 protected owner/teamwork paths unchanged, and 28 pre-existing dirty paths outside the M3.5 manifest unchanged.

## Implemented contracts

### Superset v1

The additive local/test SQL migration persists nullable group UUID, nullable contiguous position, and an authoritative lock mirror on `workout_exercises`. A private append-only lock preserves the first-completed-set boundary even if that set is later uncompleted or deleted. An owner-checked transactional RPC creates, reorders, moves, and ungroups members without deleting their exercise rows or reassigning their sets; a one-member remainder dissolves. Direct client grouping and grouped-row deletion are rejected. Grouped duplicate `set_number` is rejected, including when grouping pre-existing sets. The duplicate check runs after the existing workout-row lock to serialize writes.

The Flutter round helper uses each member's set number N, skips missing members, preserves historical numbering, and schedules automatic rest only when the last outstanding participating member completes. Completion order need not match position order. Existing manual timer controls remain. The local/test UI has grouping and locked-state presentation, VI/EN copy, and 320dp/2x coverage. Superset controls remain hidden behind a disabled production gate because the RPC is not deployed remotely.

### Four workout modes and completion

`workout_exercises.mode` persists only `reps-weight`, `bodyweight`, `timed`, or `cardio`; legacy `NULL` remains `NULL` and is not inferred from nullable measurements or catalogue metadata. A durable private first-set lock prevents mode changes after an exercise has ever had a set, including after all sets are deleted. Typed draft rows cannot mix measurement fields. Completed reps-based sets require reps 1–1000 and weight 0–1000 kg; bodyweight kilograms mean external load. Completed timed/cardio sets require duration 1–7200 seconds, reps=0, and weight=0; cardio v1 stores no distance or speed.

Flutter models, repository/controller contracts, validation, input widgets, and VI/EN labels support the explicit modes in local/test. The live add path still omits `mode` because the remote column is not deployed. The SQL migration changes the existing `complete_workout` only for mode-aware completed-set validation and strength-PR filtering. It remains the sole PostgreSQL completion/XP/reward authority; retries return the existing reward result. Timed/cardio never create a zero-valued strength PR.

### Offline ownership and retention

An owner-scoped synthetic queue facade checks the authenticated owner and session generation before and after reads and transactional mutations, without exposing raw Drift queries to the authenticated coordinator. The coordinator cancels an in-flight transport on logout/account switch, stops before ACK or further queue work, and leaves uncertain intents for the same owner's retry. Pending/conflict rows remain until successful sync or explicit, owner-confirmed discard; there is no TTL. Same operation ID with different content remains a hard conflict and is recoverable by the original owner only.

The raw Drift store is retained for disposable synthetic fixtures and unavailable in product builds. `OfflinePayloadProtector` is an interface only. No real-user payload enters the new SQLite store: encrypted payload implementation, platform-backed key storage outside SQLite, production Supabase Auth adapter, and device/account-switch verification are still required. The offline sync and payload-protection production gates remain `false`.

## Actual multi-agent work and QA

| Agent | Exclusive scope | Evidence |
|---|---|---|
| Superset Domain & Persistence | SQL migration/regression, round helper, Superset screen/tile and widget tests | SQL 16 units/365 ACL; focused Flutter 10/10; analyzer `PASS` |
| Workout Modes | Explicit mode model/repository/controller/input/copy and tests | Focused Flutter 55/55; analyzer `PASS` |
| Completion & Offline Security | Owner-scoped facade, session/cancellation, conflict/discard and tests; completion SQL was coordinated with Superset owner | Focused Flutter 27/27; production gates closed |
| UI/UX Review | Read-only VI/EN, narrow/large-text, timer and accessibility review | Found metadata inference, auto-rest, labels and narrow-screen gaps; implementation owners addressed them |
| Independent QA | Read-only review plus independent focused reruns | 64/64 Flutter, SQL 16 units/365 ACL, analyzer and diff check `PASS`; no unresolved P0–P2 |

Independent QA found and verified fixes for out-of-order rest, duplicate grouped set numbers before the workout lock, typed draft cross-field validation, durable mode and group locks, and UI lock-state parity. Its read-only source comparison confirmed no additional XP/reward path. QA did not perform a remote or true two-connection PostgreSQL test.

## Verification at the final local tree

| Command/check | Status and result |
|---|---|
| `cd app; flutter test --no-pub test/offline_security_lifecycle_test.dart test/offline_workout_store_test.dart test/offline_workout_schema_migration_test.dart test/offline_sync_coordinator_test.dart test/workout_write_identity_test.dart test/superset_rounds_test.dart test/superset_widgets_test.dart test/workout_modes_test.dart test/workout_snapshot_ownership_test.dart test/workout_controller_test.dart test/workout_widgets_test.dart test/workout_completion_reconciliation_test.dart --reporter compact` | `PASS`, 144/144 before the final QA fixes; later independent focused 64/64 and full suite cover the final tree. |
| `cd tools/db-tests; npm test` | `PASS`, 16 SQL verification units and 365 ACL assertions in single-connection PGlite/PostgreSQL 17.5; independent QA repeated it after fixes. |
| `cd app; flutter analyze --no-pub` | `PASS`, `No issues found!` after integration. |
| `cd app; dart format --output=none --set-exit-if-changed lib test` | `PASS`, 154 files, 0 changed. |
| `cd app; flutter test --no-pub --reporter expanded` | `FAIL`, 386 passed / 1 failed. Sole failure: `release_config_test.dart` expects protected Gradle Wrapper 8.13; local owner file contains 9.7.1. |
| `git diff --check`; `git diff --cached --name-only` | `PASS`, exit 0 with line-ending warnings only; index empty. |
| Genuine two-connection PostgreSQL idempotency/concurrency scenarios | `BLOCKED`: no `psql`/PostgreSQL/Docker/Podman executable, service, or local port 5432 listener. PGlite is not race evidence. |
| Live Supabase, real device, production migration/deploy | `NOT RUN`: unavailable or outside authorization. |

## Activation gates, reversal, and next action

The local/test implementation is reviewable, but M3 cannot close or serve real offline data. Required next evidence: genuine two-connection PostgreSQL idempotency/race tests; encrypted payloads with platform-backed secure keys; production-only owner-scoped queue construction and Supabase Auth adapter; device logout/account-switch and conflict-resolution checks; and separate remote migration/deployment authorization. The full Flutter release-config failure is a separate protected owner-file issue. O-07 remains open for live Supabase verification.

Safe reversal at this checkpoint is to leave all production gates `false` and retain pending intents. This migration was applied only to disposable local/test databases; a test database can be recreated from migrations and seed. If the schema is ever deployed after separate approval, correct it with a forward additive migration rather than dropping user-linked rows, locks, or historical sets. Never discard an owner's unresolved queue except by that owner's explicit action.

**Next action:** M3 final verification/security gate — provide an isolated two-connection PostgreSQL runtime, implement and test platform-backed encryption and production auth/device lifecycle behind the closed gates, then seek separate remote migration/deployment approval. Do not start M4.

## Exact M3.5 candidate Git manifest (not staged)

**Server:** `supabase/migrations/20261103000200_m3_superset_modes.sql`, `supabase/tests/m3_superset_modes.sql`.

**Flutter data:** `app/lib/features/workout/data/offline_security_payload.dart`, `app/lib/features/workout/data/offline_security_session.dart`, `app/lib/features/workout/data/offline_sync_coordinator.dart`, `app/lib/features/workout/data/offline_workout_store.dart`, `app/lib/features/workout/data/supabase_workout_repository.dart`.

**Flutter domain:** `app/lib/features/workout/domain/superset_rounds.dart`, `app/lib/features/workout/domain/workout_exercise.dart`, `app/lib/features/workout/domain/workout_exercise.freezed.dart`, `app/lib/features/workout/domain/workout_exercise.g.dart`, `app/lib/features/workout/domain/workout_mode_contract.dart`, `app/lib/features/workout/domain/workout_repository.dart`.

**Flutter presentation:** `app/lib/features/workout/presentation/controllers/active_workout_controller.dart`, `app/lib/features/workout/presentation/screens/active_workout_screen.dart`, `app/lib/features/workout/presentation/widgets/set_row_widget.dart`, `app/lib/features/workout/presentation/widgets/workout_exercise_tile.dart`, `app/lib/features/workout/workout_copy.dart`.

**Flutter tests:** `app/test/offline_security_lifecycle_test.dart`, `app/test/offline_sync_coordinator_test.dart`, `app/test/offline_workout_schema_migration_test.dart`, `app/test/offline_workout_store_test.dart`, `app/test/superset_rounds_test.dart`, `app/test/superset_widgets_test.dart`, `app/test/workout_modes_test.dart`.

**Technical records:** `docs/planning/ARCHITECTURE.md`, `docs/planning/DECISIONS.md`, `docs/planning/TASK_BOARD.md`, `docs/planning/SESSION_HANDOFF.md`, `docs/planning/CHANGELOG_AI.md`, `M3_5_FINAL_REPORT.md`.

Pre-existing M3/M3.1/M3.3/M3.4 files not listed above remain outside this checkpoint manifest. No file was staged, committed, pushed, tagged, deployed, or migrated remotely.
