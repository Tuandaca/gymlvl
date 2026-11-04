# M3.6 two-connection concurrency harness

Proves idempotency and authorization under **real PostgreSQL row-lock contention**,
not a sequential replay. Two independent `pg.Client` TCP connections call the real
`apply_workout_set_create_v1` and `complete_workout` inside explicit transactions
while a third monitoring connection samples `pg_stat_activity` for
`wait_event_type = 'Lock'`. A scenario without an observed lock wait fails.

## Run

```powershell
cd tools/db-tests
npm install --no-audit --no-fund
npm run test:concurrency
```

The runner starts a disposable PostgreSQL 17.5 cluster from
`embedded-postgres@17.5.0-beta.15` in the OS temp directory on the first free port
from 55432 upward, creates a scratch database, applies `bootstrap.sql`, every
`supabase/migrations/*.sql` in filename order, and the seeds declared in
`supabase/config.toml` twice (idempotent replay). The discovery rules mirror
`run.mjs`; that file remains the single-connection PGlite regression suite and is
not replaced by this harness.

## What it proves

| Scenario | Claim |
|---|---|
| C1 | Same operation ID and payload from two connections: one stored set, one ledger row, identical response for both callers. |
| C2 | Same operation ID with different payloads: exactly one business effect; the loser gets SQLSTATE `23505` ("Operation ID reused with different content"); the stored payload matches the winner. |
| C3 | A lost acknowledgement replayed on a fresh connection returns byte-identical JSON and writes nothing. |
| C4 | Concurrent `complete_workout`: one `workout_rewards` row, one `xp_logs` row, `total_xp` increases once, both callers receive the same reward JSON. |
| C5 | Two users may reuse the same operation UUID; both succeed with distinct `set_id`s and two ledger rows scoped by `user_id`. |
| C6 | Cross-user workout access and unauthenticated calls fail with `42501`, write nothing, and leak no owner identifiers. |

Every call prints its backend PID, transaction boundary, duration, outcome,
SQLSTATE/error text, and the resulting row counts.

## Cleanup

Teardown runs in a `finally` block: it closes every client, stops the postmaster,
deletes the data directory, and then re-checks that the directory is gone and the
port has no listener. Nothing is installed as a service and no registry entry is
created. The final `CLEANUP` lines are the evidence; a leftover directory or
listener fails the run. If a run is killed abruptly, delete any remaining
`%TEMP%\gymlvl-m36-pg-*` directory by hand.

## Boundaries

Local and disposable only. The harness never connects to a remote or production
project and never modifies `supabase/**`. A failing scenario is reported with its
exact reproduction; the SQL is not patched here.
