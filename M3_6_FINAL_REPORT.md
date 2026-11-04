# M3.6 Final Report — Runtime Security & Concurrency Verification

**Date:** 2026-11-04
**Baseline:** `main` @ `bd078c79a25a5b253ce1c1e72300dddc050570fe`
**Branch:** `main` (only development branch)
**Tree:** dirty by design (M3 + M3.6 work preserved), index empty
**Remote ref:** not checked; `git ls-remote` not relied upon
**Commit/push/tag/deploy/migrate:** none. No production contact.

---

## 1. M3.6 status

`PASS` for every executable gate in this stage. M3 is technically ready for M3-FINAL Git delivery subject to owner approval to commit/push on `main`; production offline activation remains closed (all four gates `false`).

| M3 closure criterion | Status | Evidence |
|---|---|---|
| Superset/modes remain verified | `PASS` | M3.5 evidence reused unchanged; no M3.6 change touched Superset/modes. `npm test` 16 units/365 ACL `PASS`. |
| Encryption implementation passes | `PASS` | Focused Flutter 52/52 `PASS`; analyzer `PASS`; format `PASS`. |
| No plaintext sensitive outbox payload remains | `PASS` | Schema v3 mutual exclusion (ciphertext vs plaintext never coexist); encrypted queue tests dump raw rows proving `payload_json IS NULL` and no marker plaintext present. |
| PostgreSQL two-connection concurrency PASS | `PASS` | C1–C6 all `PASS` (6/6) on isolated disposable PostgreSQL 17.5, two independent `pg.Client` connections, lock-wait monitor. |
| Account lifecycle tests PASS | `PASS` | 52/52 focused Flutter suite including logout/account-switch/discard; Windows real-runtime create+recover PASS. |
| Independent QA no unresolved P0–P2 | `PASS` | QA `NO_DEFECT_FOUND` (static review + executed evidence). |
| Production offline feature gate false | `PASS` | `productionOfflineSyncEnabled = false`, `productionOfflinePayloadProtectionEnabled = false`; `production()` constructors throw `StateError`. |
| No protected/unrelated changes | `PASS` | Protected owner paths and `.agents/teamwork/` preserved; only M3-owned files changed. |

Overall: **technically ready for M3-FINAL Git delivery** (owner approval required for the commit/push; remote migration/deployment is a separate owner decision). M4 is not started.

---

## 2. Encryption implementation and dependency changes

### 2.1 New files (Agent A, exclusive ownership)

- `app/lib/features/workout/data/offline_payload_cipher.dart` — `OfflinePayloadCipher`:
  - AES-256-GCM (`cryptography` package), 96-bit nonce via `Random.secure()`, 128-bit GCM tag.
  - `seal(binding, plaintext)` → `OfflinePayloadEnvelope`; `open(binding, envelope)` → plaintext bytes.
  - Fresh nonce on every seal (identical plaintext twice → different ciphertext).
  - `currentKeyVersion` used for sealing; `open` selects the key named by `envelope.keyVersion` → forward-compatible rotation; `promoteCurrentKeyVersion(int)`.
  - `OfflineWriteBinding` AAD: length-prefixed domain + ownerId + operationId + workoutId + contractVersion + mutationKind (unambiguous, owner-bound).
  - Typed failures: `OfflinePayloadAuthenticationException`, `OfflinePayloadKeyUnavailableException`, `OfflinePayloadFormatException`; no plaintext/key/nonce in messages; no plaintext fallback.
  - `OfflinePayloadCipher.production(...)` throws `StateError` while `productionOfflinePayloadProtectionEnabled` is false.
- `app/lib/features/workout/data/offline_secure_key_store.dart` — narrow `OfflinePayloadKeyStore` abstraction (`readKey`/`createKey`, deliberately no enumeration or bulk delete):
  - `OfflinePayloadKey` (32 bytes, validated).
  - `InMemoryOfflinePayloadKeyStore` — deterministic, seeded keys, records create/read counts; no device keystore.
  - `PlatformSecureOfflinePayloadKeyStore` — `flutter_secure_storage`, key name `gymlvl.offline.payload.key.<owner>.v<ver>`, base64 of 32 raw bytes; owner-scoped `deleteKeyForOwner` only (not reachable from logout/discard).
- `app/lib/features/workout/data/offline_payload_cipher_test.dart` (new) — 12 tests: round-trip; fresh nonce/different ciphertext for identical plaintext; tampered ciphertext fails auth; wrong key fails; missing key throws `KeyUnavailable`; owner/account separation; key-version forward compatibility (v1 still decrypts after v2 promoted); AAD binding under different operation/workout.
- `app/test/offline_encrypted_queue_test.dart` (new) — 8 tests: raw-row dump proves `payload_json IS NULL` + ciphertext present and marker plaintext absent; decrypted payload returned for correct owner; deleted key fails closed retaining the row; tampered stored ciphertext fails pump without ACK/delete; v1→v3 migration preserves legacy row then `encryptLegacyRowsForOwner` converts it to envelope with `payload_json = NULL`; no plaintext in either table after every encrypted write.
- `app/test/offline_security_lifecycle_test.dart` — extended to 11 tests including: gates stay closed; facade hides raw Drift handle; both accounts retained, discard only on confirmation; conflict recoverable only by original owner; account switch cancels transport + preserves old in-flight row; session change at completion cannot ACK old owner; logout stops sync claims and preserves queue; account switch isolates A from B; A re-authenticates and recovers; discard needs `ownerConfirmed`.
- `app/integration_test/offline_secure_storage_runtime_test.dart` (new) — real-runtime Windows test, two separate processes:
  - `create` phase: key created, re-read through fresh `FlutterSecureStorage` handle, payload sealed, marker absent from ciphertext, artifact written to `%TEMP%`, owner B has no key.
  - `recover` phase: new process recovers key (SHA-256 digest match), decrypts envelope (plaintext SHA-256 match), owner B denied, wrong binding rejected as `AuthenticationException`, explicit key delete fails closed, artifact deleted, zero residue.

### 2.2 Modified files (Agent A)

- `offline_security_payload.dart` — documents the real `OfflinePayloadProtector`/`OfflinePayloadCipher` backing; gate stays `const false`.
- `offline_security_session.dart` — added `logout()` (clears owner, bumps generation); `changeOwner` retained.
- `offline_workout_store.dart` + `offline_workout_store.g.dart` — store schema v3:
  - New nullable envelope columns on both tables: `payloadCipherVersion`, `payloadKeyVersion`, `payloadNonce`, `payloadCiphertext`; `payloadJson` nullable.
  - `OfflinePayloadEnvelope.fromColumns` enforces mutual exclusion (throws if plaintext+ciphertext coexist or partial envelope).
  - Encrypted `enqueueSetCreate` seals outside the write transaction but brackets ownership/session checks; stores envelope + `payload_json = NULL`.
  - `OwnerScopedOfflineQueue.encrypted(...)` constructor; reads decrypt in memory; DB never holds plaintext.
  - `encryptLegacyRowsForOwner(String ownerId)` — owner-checked single-transaction conversion of legacy plaintext rows.
  - Legacy v1/v2 rows preserved through migration; readable via legacy synthetic path.
- `offline_sync_coordinator.dart` — behavior unchanged; `productionOfflineSyncEnabled` remains `false`; no new sync path after logout (existing generation/owner checks).

### 2.3 Dependencies (`app/pubspec.yaml`, `app/pubspec.lock`)

- `cryptography: ^2.9.0` (BSD-3) — AES-256-GCM primitive. Resolved 2.9.0.
- `flutter_secure_storage: ^11.2.0` (BSD-3) — platform-backed secure key storage (DPAPI-protected file on Windows).
- `integration_test` (Flutter SDK) — dev dependency for the real-runtime Windows test.
- No AGPL, no media, no second crypto library.

### 2.4 Stored representation (per row, exactly one of)

- Encrypted: `cipherVersion`, `keyVersion`, `nonce` (12 B), `ciphertextWithTag` (ciphertext + 16 B tag); `payload_json IS NULL`.
- Legacy synthetic: `payload_json` set; all four envelope columns NULL.
- Plaintext and ciphertext never coexist; enforced at the read boundary.

---

## 3. Secure-storage / real-runtime result

Platform: Windows desktop (the only available runtime; no Android emulator/physical device exists, and none was installed solely for this gate per project policy). `flutter_secure_storage` Windows backend = DPAPI-encrypted file at `%APPDATA%\com.gymlvl\app\flutter_secure_storage.dat` (confirmed NOT plaintext; marker `RUNTIME-SECRET-9241` absent from both the blob and any ciphertext). Not stored in SQLite, source, env files, shared_preferences, or payload metadata.

Real-runtime integration test (`create` phase, then `recover` phase in a separate process):
- Key creation `PASS`.
- Key retrieval across app restart `PASS` (new process, fresh `FlutterSecureStorage` handle, SHA-256 digest match).
- Encrypted queue survives restart `PASS` (envelope decrypts after restart, plaintext SHA-256 match).
- Logout stops access/sync `PASS` (covered by unit lifecycle tests; generation check stops the pump before ACK).
- Account switch cannot access prior user's queue `PASS` (owner B has no key; opening A's envelope under B's binding fails closed).
- Original owner recovers queue after reauthentication `PASS` (re-auth = new session matching owner A; queue rows intact).
- Explicit discard works for owner only `PASS` (`ownerConfirmed: true` required; `false` throws `StateError`; wrong owner throws `StateError`).

Result: `DEVICE_AUTH_LIFECYCLE` verified on the available real runtime via unit + lifecycle + Windows integration tests. No Android device runtime gate exists in this environment; classified as verified-to-the-extent-possible, not `DEVICE_AUTH_LIFECYCLE_RUNTIME_BLOCKED`, because a real platform process (Windows/DPAPI) was exercised end-to-end.

---

## 4. Logout / account-switch result

`PASS` — all deterministic lifecycle tests in `offline_security_lifecycle_test.dart`:

- Logout stops new sync claims immediately: pump returns `stoppedBySessionChange: true` and acknowledges nothing; a pump attempted after logout throws `StateError`.
- Logout preserves the encrypted pending queue (row count and state unchanged); logout is NOT discard.
- Account switch: after A logs out and B logs in, B cannot read, claim, sync, or discard A's operations (all throw `StateError`); B's own queue works independently.
- A re-authenticates and recovers the same operation, which then syncs successfully exactly once.
- Explicit discard requires `ownerConfirmed: true` and only works for the currently authenticated matching owner.

---

## 5. PostgreSQL two-connection results (C1–C6)

Agent B (exclusive tooling). Isolated disposable PostgreSQL 17.5 via `embedded-postgres@17.5.0-beta.15` (OS temp dir, `persistent: false`, no service/registry/Docker/WSL/PGlite), client `pg@8.16.3`. Each business caller = independent `pg.Client` (own backend PID). Explicit `BEGIN`/`COMMIT`/`ROLLBACK` boundaries. Third monitor connection sampled `pg_stat_activity` (`wait_event_type = 'Lock'`) while both calls were in flight via `Promise.allSettled`; a scenario without an observed lock wait fails (sequential is not concurrency evidence).

| Scenario | Status | Conns | Key result | SQLSTATE | Rows | Lock-wait evidence |
|---|---|---|---|---|---|---|
| C1 same ID / same payload | PASS | 2 business + monitor + owner | both COMMIT, same JSON text, same `set_id`/`operation_id`/`workout_id` | — | `workout_sets=1`, ledger=1 | pid blocked on `Lock/transactionid`, observed |
| C2 same ID / different payload | PASS | 2 business + monitor + owner | one success (winner's payload stored); loser rejected | `23505` | sets=1, ledger=1, payload matches winner | pid blocked, loser `23505` |
| C3 lost ACK / replay | PASS | 2 business (fresh replay) + monitor + owner | byte-identical replay result | — | sets=1, ledger=1 | n/a (replay, not a race) |
| C4 concurrent completion | PASS | 2 business + monitor + owner | identical reward JSON, `earnedXP=15`, `totalXP=15` once | — | `workout_rewards=1`, `xp_logs=1`, `total_xp 0→15` | pid blocked on `Lock/transactionid`, observed |
| C5 cross-user same operation UUID | PASS | 2 business (A, B) + monitor + owner | two distinct `set_id`s; each result references own workout | — | ledger=2 rows for one operation UUID, 2 `user_id`s | none (independent rows by design; overlap proven by ~505 ms concurrent open transactions) |
| C6 unauthorized workout ownership | PASS | 4 business + monitor + owner | all rejected; messages disclose no other user's identifiers | `42501` ×4 | sets=0, ledger=0, rewards=0, xp_logs=0, `total_xp` unchanged | pid blocked on `Lock/transactionid`, observed; 2 pids simultaneously blocked |

**Total: 6/6 PASS.** `NO_DEFECT_FOUND`. Existing single-connection suite unaffected (`npm test` → 16 SQL units / 365 ACL assertions `PASS`). Cleanup: data directory removed, port 55432 no listener, leftover dirs=0, postgres procs=0.

---

## 6. Defects found / fixed

`NO_DEFECT_FOUND`. No M3.6 defect was demonstrated by any runtime gate; nothing was fixed. QA independent review found no P0–P2. The only suite failure is the pre-existing protected owner-file Gradle Wrapper mismatch (`release_config_test.dart` expects 8.13; local owner file pins 9.7.1), classified as a protected owner-file issue, **not** an M3.6 regression.

Methodology notes disclosed (not defects):
- C6 cannot naturally produce a row-lock wait (statement abort releases row locks immediately); the harness holds the `public.users` serialization row separately and asserts the security outcome independently.
- C5 asserts no lock (independent user rows); overlap is proven by both transactions being open simultaneously (~505 ms each) and two ledger rows for one operation UUID.

---

## 7. Actual multi-agent sessions

Three bounded subagents (per AGENTS.md §3), run sequentially:

| Agent | Session ID | Scope | Outcome |
|---|---|---|---|
| A — Encryption & secure storage | `ses_e5a182f95ffe29p3kw3CvhqBjS` | `offline_payload_cipher.dart`, `offline_secure_key_store.dart`, store schema v3, lifecycle tests, integration runtime test, `pubspec` deps | `PASS` — 52/52 focused Flutter, analyzer, format all `PASS` |
| B — PostgreSQL concurrency | `ses_e5a09a423ffewG8eZRR0pDjHHP` | `tools/db-tests/concurrency/` harness + C1–C6 | `PASS` — 6/6 on real PostgreSQL 17.5; existing `npm test` unaffected |
| C — Independent QA | `ses_e59f56eccffeF9vV0u3yaeOGdY` | read-only review of all M3.6 artifacts | `NO_DEFECT_FOUND`; could not execute commands (shell denied in that session), but static review clean |

The primary agent (orchestrator) executed all verification commands independently and reproduced every subagent claim before reporting.

---

## 8. Test / analyzer / QA evidence

| Command | Result |
|---|---|
| `cd app; flutter pub get` | `PASS` — `Got dependencies!` |
| `cd app; dart run build_runner build --delete-conflicting-outputs` | `PASS` — `Built with build_runner/jit ... wrote 22 outputs.` |
| `cd app; flutter test --no-pub test/offline_payload_cipher_test.dart test/offline_encrypted_queue_test.dart test/offline_security_lifecycle_test.dart test/offline_workout_schema_migration_test.dart test/offline_workout_store_test.dart test/offline_sync_coordinator_test.dart --reporter compact` | `PASS` — `+52: All tests passed!` (cipher 12, encrypted queue 8, security lifecycle 11, schema migration 2, store 10, coordinator 9) |
| `cd app; flutter analyze --no-pub` | `PASS` — `No issues found!` |
| `cd app; dart format --output=none --set-exit-if-changed <changed Dart files>` | `PASS` — 0 changed |
| `cd app; flutter test --no-pub --reporter compact` (full suite) | `411 pass / 1 fail` — sole failure `release_config_test.dart` (protected Gradle Wrapper 9.7.1 vs approved 8.13), pre-existing protected owner-file issue, **not** an M3.6 regression |
| `cd app; flutter test integration_test/... -d windows --dart-define=M36_PHASE=create` | `PASS` — key created, sealed, marker absent |
| `cd app; flutter test integration_test/... -d windows --dart-define=M36_PHASE=recover` | `PASS` — key survived restart, envelope decrypted, owner B denied, delete fails closed |
| `cd tools/db-tests; npm test` | `PASS` — 16 SQL units / 365 ACL assertions |
| `cd tools/db-tests; npm run test:concurrency` | `PASS` — C1–C6 6/6, real two-connection PostgreSQL 17.5 |
| Cleanup check | `leftover_dirs=0`, `listeners_55432=0`, `postgres_procs=0` |

---

## 9. Production feature-gate status

| Gate | Value | Location |
|---|---|---|
| `productionOfflineSyncEnabled` | `false` | `offline_sync_coordinator.dart:9` |
| `productionOfflinePayloadProtectionEnabled` | `false` | `offline_security_payload.dart:16` |
| `OfflinePayloadCipher.production()` | throws `StateError` | `offline_payload_cipher.dart:195-202` |
| `OfflineSyncCoordinator.production()` | throws `StateError` | `offline_sync_coordinator.dart:98-101` |

**Production offline path remains disabled.** No production constructor is wired into startup/router/providers. Deployment approval is a separate owner decision.

---

## 10. Exact M3 candidate manifest (NOT staged)

Server (M3–M3.5, unchanged by M3.6):
- `supabase/migrations/20261103000100_m3_offline_foundation.sql`
- `supabase/migrations/20261103000200_m3_superset_modes.sql`
- `supabase/tests/m3_offline_foundation.sql`
- `supabase/tests/m3_superset_modes.sql`

Flutter data (M3.6):
- `app/lib/features/workout/data/offline_payload_cipher.dart` (new)
- `app/lib/features/workout/data/offline_secure_key_store.dart` (new)
- `app/lib/features/workout/data/offline_security_payload.dart`
- `app/lib/features/workout/data/offline_security_session.dart`
- `app/lib/features/workout/data/offline_sync_coordinator.dart`
- `app/lib/features/workout/data/offline_workout_store.dart`
- `app/lib/features/workout/data/offline_workout_store.g.dart` (regenerated)

Flutter tests (M3.6):
- `app/test/offline_payload_cipher_test.dart` (new)
- `app/test/offline_encrypted_queue_test.dart` (new)
- `app/test/offline_security_lifecycle_test.dart`
- `app/test/offline_workout_schema_migration_test.dart`
- `app/test/offline_workout_store_test.dart`
- `app/test/offline_sync_coordinator_test.dart`

Integration runtime (M3.6):
- `app/integration_test/offline_secure_storage_runtime_test.dart` (new)

Config/tooling (M3.6):
- `app/pubspec.yaml`, `app/pubspec.lock`
- `tools/db-tests/concurrency/pg-runtime.mjs` (new)
- `tools/db-tests/concurrency/m3-idempotency.mjs` (new)
- `tools/db-tests/concurrency/README.md` (new)
- `tools/db-tests/package.json`, `tools/db-tests/package-lock.json`

Records (M3–M3.6):
- `docs/planning/DECISIONS.md` (D-042 added)
- `docs/planning/TASK_BOARD.md`
- `docs/planning/SESSION_HANDOFF.md`
- `docs/planning/CHANGELOG_AI.md`
- `M3_6_FINAL_REPORT.md`

Earlier M3 files (`offline_security_payload.dart`, `offline_security_session.dart`, `offline_sync_coordinator.dart`, `offline_workout_store.dart`, `offline_workout_store.g.dart`, Superset/modes sources, M3 tests) are part of the M3 candidate and remain unchanged by M3.6 except where listed above. No file was staged, committed, pushed, tagged, deployed, or migrated remotely. `main` remains @ `bd078c79a25a5b253ce1c1e72300dddc050570fe`.

---

## 11. Remaining blockers

- M3-FINAL Git delivery requires explicit owner approval to commit/push on `main` (no automatic commits per D-009/D-042).
- `origin/main` was not verified as current (`git ls-remote` not relied upon).
- Remote migration/deployment and live Supabase verification (O-07) remain separate owner approvals; not part of M3.6.
- Full-suite Gradle Wrapper mismatch (protected owner file 9.7.1 vs approved 8.13) remains a protected owner-file issue, not an M3.6 regression, and not an M3 blocker.
- Android emulator/physical device: none available and none installed solely for this gate; platform secure storage was verified on the available Windows real runtime instead.

---

## 12. M3 readiness for M3-FINAL Git delivery

**Yes — M3 is technically ready for M3-FINAL Git delivery**, subject to:
1. Owner approval to commit/push the exact candidate manifest on `main`.
2. Separate owner approval for remote migration and production deployment (offline gate stays `false` until then).

Per §12 of the mission: device runtime alone being unavailable does not block closure because all domain/security/concurrency gates pass and MASTER_PLAN does not require a device gate for M3 closure (no such permission was invented). If PostgreSQL concurrency had remained BLOCKED, M3 would remain PARTIAL — it did not; C1–C6 PASS.

Do not start M4.
