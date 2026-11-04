# M3.3 Final Report — Synthetic Offline Storage and Sync Foundation

**Date:** 2026-11-03
**Baseline:** `main` @ `bd078c79a25a5b253ce1c1e72300dddc050570fe`
**Overall status:** `PARTIAL` — implementation and local synthetic checks passed; true two-connection PostgreSQL duplicate-delivery verification is `BLOCKED`. Full M3 is not complete.

## Authority and boundary

The owner explicitly approved Drift/SQLite, a transactional outbox, server operation IDs and payload fingerprints, additive local/test migrations, and the nullable superset-group direction in the conversation. The subsequent M3.3 request authorized synthetic sync coordination and verification. D-039 and D-040 record `PARTIALLY_APPROVED` scope. No real user data, production offline write, remote migration, deployment, superset write, or mode activation was authorized or performed. `complete_workout` remains the only reward path.

The pre-edit working tree matched the known M3/M3.1/M3.2 dirty state. Backup `D:\Projects\gymlvl-backups\m3_3-20261103-042224` was verified before edits: bundle clone HEAD matched `bd078c7`, archive count equaled the Git tree (598/598), and 34 dirty files matched SHA-256 copies. The index was empty.

## Implementation

- The disconnected Drift store now has schema version 2 and an additive v1-to-v2 migration. Outbox rows contain owner/workout/operation IDs, kind/version, canonical local payload and SHA-256 fingerprint, creation time, state, attempt count, and retry/lease time. Synthetic projection and intent enqueue in one SQLite transaction. Owner/workout queries, claim, retry, conflict, and ACK are scoped and fenced by attempt count. Canonical lowercase UUIDs are required at every store boundary; malformed legacy v1 data aborts migration without deleting the database.
- `OfflineSyncCoordinator` uses a hard-disabled production gate. Synthetic tests inject a transport and clock. It serializes a workout's operations, claims with a 30-second lease, applies bounded exponential backoff, reuses the same operation after an uncertain response, and quarantines terminal or malformed ACKs. A local SQLite ACK/invariant failure is surfaced and quarantined; it is not classified as a retryable network error. No production transport or existing online controller/repository path was changed.
- The local/test SQL migration retains the private `(user_id, operation_id)` ledger and the authorized `set_create_v1` RPC. It normalizes typed UUID/numeric payload values before computing the SHA-256 fingerprint, compares the exact normalized request body, and keeps the set insert and ledger result in one PostgreSQL transaction. Owner and active-workout checks, completion-compatible lock order, RLS/grants, and the existing reward boundary are retained. The nullable superset UUID column remains guarded against non-null writes. Four mode names remain inactive.

The local and server fingerprint byte strings intentionally differ; the RPC does not receive or trust the local hash. A shared wire canonicalization contract or server-authoritative recalculation must be specified before any production transport uses the local fingerprint as a precondition.

## Multi-agent execution and QA

| Agent | Exclusive work | Outcome |
|---|---|---|
| A — Local Persistence | Drift store, generated code, store/schema tests | v2 migration, durable outbox lifecycle, SQLite two-connection claim; focused checks `PASS` |
| B — Server Idempotency | M3 SQL migration and regression test | Normalized request fingerprint, private ledger, rollback/ownership/reward assertions; SQL suite `PASS` |
| C — Sync Domain | New coordinator and tests | Disabled production gate, lease/retry/ACK recovery; focused checks `PASS` |
| D — Independent QA | Read-only review and focused reruns | Two P2 defects found, fixed by A/C, and re-reviewed; no actionable finding remains |

QA's P2 findings were (1) case-distinct UUID text could create separate local intents for one PostgreSQL UUID, and (2) a broad catch retried local ACK failures as network failures. Both have regression tests and a final independent review. QA verified 21/21 focused Flutter tests and 14 SQL units plus 365 ACL assertions. The SQLite two-connection claim test uses distinct executors on one synthetic file; Drift emits a generic multiple-database debug warning, but the assertion passes. This is not evidence for concurrent PostgreSQL requests.

## Verification at the final local tree

| Command / check | Result |
|---|---|
| `cd app; flutter pub get` | `PASS`, exit 0; direct `crypto` and dev-only `sqlite3` declarations resolved without package upgrades. |
| `cd app; flutter test --no-pub test/offline_workout_store_test.dart test/offline_workout_schema_migration_test.dart test/offline_sync_coordinator_test.dart test/workout_write_identity_test.dart test/workout_snapshot_ownership_test.dart test/workout_controller_test.dart test/workout_widgets_test.dart --reporter compact` | `PASS`, 103/103, exit 0. M3.3 21, M3.1 identity 7, M3 regression 75. |
| `cd tools/db-tests; npm test` | `PASS`, exit 0; 14 SQL verification units and 365 ACL assertions in isolated PGlite/PostgreSQL 17.5. Covers normalized replay/conflict, ledger rollback, owner/anon denial, superset guards, lost ACK, and reward retry. |
| `cd app; flutter analyze --no-pub` | `PASS`, `No issues found!`, exit 0. |
| `cd app; dart format --output=none --set-exit-if-changed lib test` | `PASS`, 146 files/0 changed, exit 0. |
| `cd app; flutter test --no-pub --reporter expanded` | `FAIL`, 359 passed / 1 failed, exit 1. Sole failure: `release_config_test.dart` expected Gradle 8.13; protected local wrapper contains 9.7.1. |
| `git diff --check` | `PASS`, exit 0 (Git reported only existing LF/CRLF warnings). |
| True two-connection PostgreSQL concurrent duplicate delivery | `BLOCKED`: no local `psql`/`pg_ctl`/`postgres`/Docker executable or reachable `127.0.0.1:5432`; PGlite uses one connection. |
| Live Supabase, device, remote CI, production migration | `NOT RUN`: outside approved M3.3 scope. |

## Changed-file manifest

**App dependencies:** `app/pubspec.yaml`, `app/pubspec.lock`.

**Local persistence/sync:** `app/lib/features/workout/data/offline_workout_store.dart`, `app/lib/features/workout/data/offline_workout_store.g.dart`, `app/lib/features/workout/data/offline_sync_coordinator.dart`.

**Flutter tests:** `app/test/offline_workout_store_test.dart`, `app/test/offline_workout_schema_migration_test.dart`, `app/test/offline_sync_coordinator_test.dart`.

**Server local/test:** `supabase/migrations/20261103000100_m3_offline_foundation.sql`, `supabase/tests/m3_offline_foundation.sql`.

**Technical records:** `docs/planning/DECISIONS.md`, `docs/planning/TASK_BOARD.md`, `docs/planning/SESSION_HANDOFF.md`, `docs/planning/CHANGELOG_AI.md`, and this report.

The prior M3 timer/controller and M3.1 identity changes, all protected Android/audit/teamwork paths, and all other pre-existing owner work were preserved. No file was staged; no commit, push, tag, branch change, deployment, remote migration, or production data operation occurred. The remote ref was not checked in this session.

## Remaining gate and next action

M3.3 verification remains `PARTIAL` until the same-operation concurrent duplicate-delivery case runs against an isolated PostgreSQL instance with two independent connections. Before real-user integration, the owner must approve encryption, retention/deletion, logout/account switching, replay conflict and reconciliation policies, superset order/round/rest/edit semantics, and the mode field/unit/transition contracts. O-07 remains open for live Supabase verification. Next action: run the M3.3 two-connection PostgreSQL concurrency regression in an isolated local/test database; do not enable production sync or begin M4.
