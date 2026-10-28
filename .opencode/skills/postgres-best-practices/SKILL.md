---
name: PostgreSQL Best Practices (Supabase)
description: Schema, RLS, index, and JSONB rules for the GymLvl Supabase database. Use when adding a table, policy, index, RPC, or query path, or when reviewing database access control.
---

# PostgreSQL Best Practices — Supabase

## When to use

- Adding or altering a table, column, constraint, or index.
- Writing or reviewing an RLS policy.
- Designing an RPC or a query that must stay fast as rows grow.
- Deciding whether data belongs in a column or in `JSONB`.

## When not to use

- Pure type-selection questions with no access-control angle → `postgresql`.
- Client-side Flutter data flow → `flutter-expert`.

## Non-negotiable project rules

1. **Additive migrations only.** No `DROP TABLE`, `DROP COLUMN`, `RENAME`, or `TRUNCATE` on
   user-linked objects. Add a new column or table and migrate reads.
2. **Never weaken RLS.** A new policy must not be broader than the existing pattern for that table.
   Do not disable RLS "temporarily".
3. **`complete_workout` stays the only award path.** XP, streaks, quest rewards, and PRs are written
   inside that transactional RPC. No other function or client writes them.
4. **The service-role key never reaches the client.** It exists only in Edge Function environment.
5. **Preserve exercise UUIDs.** Catalog rows are referenced by ID across user history.
6. **Every FK gets an index.** PostgreSQL does not create one automatically.

## Schema design

- `snake_case`, plural table names, explicit `PRIMARY KEY`.
- `UUID` primary keys are the project convention for user-facing entities; keep them stable.
- `TIMESTAMPTZ` for every timestamp. Never `TIMESTAMP` without time zone.
- `NUMERIC` for any exact value (XP totals if stored, measurements). Never `FLOAT` for those.
- `TEXT` with a `CHECK (length(col) <= n)` when a bound is needed, rather than `VARCHAR(n)`.
- `NOT NULL` plus a `DEFAULT` wherever the value is semantically required.
- Enums for small, stable sets (class A–F); `TEXT` + `CHECK` for values expected to evolve
  (workout status, quest state).

### JSONB decision

| Use JSONB for | Use a column or table for |
|---|---|
| Provider payloads and raw import metadata | Anything joined or aggregated |
| Optional per-row attributes that vary widely | Anything needing a foreign key |
| Snapshots kept for audit | Values filtered in a hot query path |

Index JSONB with `GIN` only when a real query filters on it. An unused GIN index costs writes.

## RLS patterns

```sql
-- user-private rows
alter table public.workouts enable row level security;

create policy workouts_select_own on public.workouts
  for select using (auth.uid() = user_id);

create policy workouts_insert_own on public.workouts
  for insert with check (auth.uid() = user_id);

create policy workouts_update_own on public.workouts
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
```

- Write a policy per operation; a missing `UPDATE` policy is a bug, not a default.
- `with check` is required on `INSERT`/`UPDATE`, otherwise a user can write another user's `user_id`.
- Catalog tables that are publicly readable still need an explicit `SELECT` policy for `anon` and
  `authenticated`; do not rely on a disabled-RLS table.
- Test a policy by acting as a second user, not as the owner.

## Indexing

- Index the columns you actually filter and sort by, in the order the query uses them
  (equality first, then range).
- Composite index for `(user_id, created_at desc)` style history reads.
- `GIN` for `JSONB` containment and full-text; `GiST` only for genuine range/geo needs.
- Confirm with `EXPLAIN (ANALYZE, BUFFERS)` before and after. An index that is never chosen is cost.

## Migration safety

- One logical change per migration; a readable name.
- State the rollback in the migration header as a comment, even though rollback is additive.
- Backfill in a separate, idempotent statement; never mix a backfill into a DDL transaction that locks
  a large table.
- Pre-release: you do **not** need zero-downtime choreography. You **do** need the change to be
  reversible by adding, not by dropping.

## Anti-patterns

| Anti-pattern | Consequence |
|---|---|
| `security definer` without a pinned `search_path` | Privilege escalation |
| RLS enabled with no policy | Silent empty results, misdiagnosed as a client bug |
| `select *` in a hot path | Breaks when a column is added; transfers JSONB blobs |
| Client-supplied `user_id` trusted | Cross-tenant write |
| Storing XP in a client-writable table | Breaks the authoritative award path |

---

*Adapted for GymLvl from `Dokhacgiakhoa/Agent-Skills-4-Vibe-Coding-CLI` @ `c4a059bb`, path
`.agent/skills/postgres-best-practices/`. MIT, © 2026 Dokhacgiakhoa. Rewritten: Prisma/JS guidance
removed, additive-migration and award-path invariants added. See
`docs/agent-system/THIRD_PARTY_NOTICES.md`.*
