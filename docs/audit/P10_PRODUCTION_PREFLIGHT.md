# P10.1 — Read-only P9 production preflight

**Date:** 2026-11-13

**Source:** `main` `7e21abb7649d108bf9b54ae59e874e816f2b54ff`
**Overall status:** `BLOCKED` for production rollout readiness. Read-only MCP inspection found missing P9 objects, an empty migration ledger, and a completed unrewarded zero-rep workout needing a data policy. Current backup and restore readiness remain unverified. No production write, migration, or Auth login was attempted. See [migration reconciliation](P10_MIGRATION_RECONCILIATION.md).

| Gate | Status | Current-session evidence and limit |
|---|---|---|
| Local migration dependency chain | `PASS` | `cd tools/db-tests; npm test` exited 0: all 28 ordered migrations, seeds/replay, 53 SQL verification units and 365 synthetic ACL assertions passed on isolated PostgreSQL 17.5. This is local schema evidence only. |
| P9 migration inventory | `PASS` | `supabase/migrations` contains 28 SQL files; seven are P9 files, ordered after the M3 offline ledger/mode migrations. No deployment inference follows from local filenames. |
| Remote Auth gateway health | `PASS` | Read-only GET `/auth/v1/health` with the configured publishable key returned HTTP 200. This is health only, not an authenticated user flow. |
| Read-only live database access | `PASS` | Supabase MCP `execute_sql` returned `current_user=supabase_read_only_user` and `transaction_read_only=on`; `list_tables(public)` returned the live table inventory. The MCP connection is project-scoped and configured with `read_only=true`. Previous publishable-key PostgREST GETs remain HTTP 401 and do not test signed-in access. |
| P9 schema/RPC parity | `FAIL` | File-by-file marker inventory found representative P1–P8 objects, but all seven P9 files have absent or conflicting markers. P9.0 catalogue policy is still broad and client exercise DELETE remains allowed; P9.3 client unlock INSERT remains allowed. No custom-exercise or unlock rows currently exist. `complete_workout(uuid,text)` exists with P8 behavior markers and one title-literal drift. See the reconciliation for exact limits. |
| Applied migration versions | `FAIL` | MCP `list_migrations` returned `[]`; read-only `SELECT count(*) FROM supabase_migrations.schema_migrations` returned `0`, although the table exists and the public schema has user data. The live schema cannot be matched to the 28 local files by migration history. Reconcile provenance before proposing migration order. |
| Legacy `workout_exercises.mode IS NULL` data | `FAIL` | Aggregate SQL counted 79/79 workout exercises with `mode=NULL`. Among 106 completed sets attached to them, two `set_type=workout` rows have `reps=0` across two workouts and one user: one cancelled; one completed, unawarded, without another valid completed set. The latter would fail P8/P9 completion validation if retried. No completed set had positive duration. The migrations do not rewrite these rows; do not infer or rewrite a mode, reps, or XP. |
| Live Auth and gateway behavior | `BLOCKED` | Read-only aggregate `SELECT count(*) FROM auth.users` returned 9; the earlier Auth health GET returned HTTP 200. No disposable authenticated test account or non-mutating sign-in/gateway smoke test was available. P9 RPC behavior cannot be exercised because the checked RPCs are absent. |
| Historical backup artifact | `PASS` for existence only | `docs/audit/production_backup_20261109` contains 33 files; `01_schema.sql` and `02_data.json` exist, with 2026-11-09 UTC modification times. Contents and sensitive records were not opened or copied. |
| Current verified production backup | `BLOCKED` | The 2026-11-09 artifact is not proof of a current consistent snapshot or restore readiness at the P9 rollout boundary. A new owner-approved backup and restore rehearsal on a disposable target are required before production migration. |
| Recovery route | `NOT RUN` | Static inspection found P9 comments prescribing stopped RPC use and reviewed additive corrections rather than destructive rollback. No disposable restore/recovery rehearsal was run because current live state and backup are unavailable. |
| Production migration/import | `NOT RUN` | Explicitly outside this read-only task. No `supabase db push`, SQL write, Edge deploy, or catalogue import was performed. |

## Backup/restore feasibility checkpoint — 2026-11-13

**Status:** `BLOCKED` for the current consistent production backup and restore rehearsal. This is a read-only capability inspection, not a backup or restore test.

- Supabase MCP namespace/tool-metadata inspection found no backup list/download, clone, restore, or project-management capability in either available namespace. No write MCP call was made.
- PowerShell `Get-Command` for `supabase`, `pg_dump`, `pg_restore`, `psql`, and `docker` reported all five `ABSENT` on PATH. Process environment name-only inspection for `DATABASE_URL|DB_PASSWORD|PGPASSWORD|PGHOST|SUPABASE_DB` returned `0` matches; credential values were not inspected. This establishes only the available process configuration, not the absence of credentials elsewhere.
- Static inspection of `tools/db-tests/package.json` found existing `embedded-postgres` and `pg` dependencies. They provide a potential isolated local restore target, but no authenticated route for a complete, consistent, current production export is configured. Restore feasibility has not been tested.
- The 2026-11-09 JSON artifact remains historical existence evidence only. A custom SQL export through MCP would expose user row data in tool output and would not establish a complete consistent backup; it is not an acceptable substitute.
- **Unblock condition:** the owner coordinates a private current snapshot with explicit scope and snapshot time, plus an authorized private transfer route. Then confirm a disposable restore target and rehearse restore before full P8-equivalence checks. Do not create a cloud project, incur cloud costs, or write to production under this checkpoint.

**Verification at `main` `7e21abb7649d108bf9b54ae59e874e816f2b54ff`:** `git bundle verify D:\Projects\gymlvl_p10_backup_20261113_151352\head.bundle` → `PASS`, complete history / bundle is okay; `git -C D:\Projects\gymlvl_p10_backup_20261113_151352\bundle_check rev-parse HEAD` → `PASS`, equals current HEAD; Python ZIP/Git-tree path comparison → `PASS`, `841` identical paths. These verify the existing repository preservation backup, not a production database backup. Backup creation, restore, production SQL writes and dependency installation → `NOT RUN`, outside this documentation checkpoint. No new decision or production approval.

## Exact unblock conditions

1. Use [the bounded migration reconciliation](P10_MIGRATION_RECONCILIATION.md) as a starting point; prove full P8 schema/function/ACL parity on a disposable restored copy before any migration-history repair. This read-only task does not mark versions applied or execute DDL.
2. Obtain an owner-approved policy for the completed, unawarded zero-rep workout before declaring live P9 behavior ready. Preserve the cancelled workout and all user-linked rows. These rows are a runtime compatibility issue, not proof that applying DDL would fail.
3. Identify a disposable authenticated test account for a non-mutating Auth/gateway smoke check. Keep production reward/workout calls out of this read-only phase.
4. Confirm a current consistent backup and a disposable restore target. The 2026-11-09 files are historical evidence, not the rollout backup.

After these checks pass, prepare a separate reviewable production migration proposal.

**Owner sequencing decision (2026-11-13, D-061):** The owner uses Supabase Free without managed Project Backups and explicitly directed the team to skip the current backup task and advance. This closes P10.1 as a bounded read-only audit and permits local-only P10.2 work. The current backup/restore gate, full P8 equivalence, migration-history provenance, legacy zero-rep policy and authenticated live behavior remain `BLOCKED` or `NOT RUN` for production rollout. No production write follows from this sequencing decision.
