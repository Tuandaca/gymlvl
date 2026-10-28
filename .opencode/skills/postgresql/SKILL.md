---
name: PostgreSQL Schema Design
description: Type, constraint, and index-selection rules for PostgreSQL tables. Use when choosing a column type, adding a constraint, or reviewing a table definition for correctness and scale.
---

# PostgreSQL Schema Design

## When to use

- Choosing between `TEXT`, `VARCHAR`, `NUMERIC`, `BIGINT`, or `UUID`.
- Deciding how to enforce an invariant (constraint vs trigger vs application check).
- Reviewing whether a table will stay healthy as rows grow.
- Explaining why a value or ID behaved unexpectedly.

## When not to use

- RLS policy design or Supabase-specific access control → `postgres-best-practices`.
- Query tuning alone, with no schema change.

## Type selection

| Need | Choose | Avoid |
|---|---|---|
| Primary key, user-facing entity | `UUID` (project convention, stable) | Auto-increment `INT` |
| Primary key, internal append-only table | `BIGINT GENERATED ALWAYS AS IDENTITY` | `SERIAL` |
| String | `TEXT` | `VARCHAR(n)` unless a hard bound is required |
| Bounded string | `TEXT` + `CHECK (length(col) <= n)` | Silent truncation assumptions |
| Money / exact decimal | `NUMERIC(p,s)` | `FLOAT`, `REAL`, `DOUBLE PRECISION` |
| Timestamp | `TIMESTAMPTZ` | `TIMESTAMP` |
| Date only | `DATE` | A timestamp truncated to midnight |
| Duration | `INTERVAL` | Integer seconds in an untyped column |
| Boolean | `BOOLEAN NOT NULL DEFAULT …` | Nullable boolean for a two-state fact |
| Small stable set (class A–F) | `CREATE TYPE … AS ENUM` | Free-text with no constraint |
| Evolving set (status) | `TEXT` + `CHECK` or lookup table | Enum you will have to `ALTER` repeatedly |
| Semi-structured extras | `JSONB` + `GIN` when queried | `JSON` (loses key semantics) |
| Ordered multi-value tags | `TEXT[]` + `GIN` for containment | Array used as a relation |

## Constraint rules

- A `PRIMARY KEY` on every reference table. Event/log tables may use a composite key instead.
- `NOT NULL` everywhere it is semantically true. A nullable column is a modelling decision, not a
  default.
- `CHECK` for invariants the database can prove: positive counts, valid ranges, non-empty strings.
- `UNIQUE` where duplicates are a bug. Remember: `UNIQUE` permits multiple `NULL`s. Use
  `UNIQUE NULLS NOT DISTINCT` (PG15+) when at most one `NULL` is allowed.
- `FOREIGN KEY` for every real relationship, with an explicit `ON DELETE` behaviour chosen
  deliberately (`restrict` by default; `cascade` only for owned child rows).

## Index rules

- PostgreSQL creates an index for `PRIMARY KEY` and `UNIQUE` — and **not** for foreign keys.
- Index every FK column used in a join or a cascade check.
- Composite index column order follows the query: equality columns first, then the range/sort column.
- Partial index (`WHERE deleted_at IS NULL`) when only a slice is queried.
- Expression index (`lower(email)`) for case-insensitive lookups instead of `citext`.
- `GIN` for `JSONB` containment, arrays, and full-text; `GiST` for ranges.
- Every index is write cost. Justify it with a query that uses it.

## Behaviour worth knowing

- Unquoted identifiers fold to lower case. Use `snake_case` and never quote a mixed-case name.
- Numeric overflow **errors**, it does not truncate. `NUMERIC(2,0)` rejects `999`.
- Identity sequences have gaps after rollback or crash. Gaps are normal; do not "repair" them.
- There is no clustered primary key. Row order is insertion order; `CLUSTER` is a one-off rewrite.
- `UPDATE` leaves a dead tuple. Wide rows updated constantly bloat the heap — split hot columns out.
- `now()` is transaction start time; `clock_timestamp()` is wall clock. Choose deliberately in
  triggers and defaults.

## Safe evolution for this project

- **Additive only.** Add a nullable column, backfill, then add the constraint — in separate
  migrations.
- Never rewrite a live table to change a type. Add a new column, dual-write through a migration, then
  switch reads.
- Pre-release means you may take a brief lock, but you may still not drop user data.
- Idempotent backfills: `UPDATE … WHERE new_col IS NULL` in bounded batches.

## Review checklist

- [ ] Primary key present and appropriate.
- [ ] Every FK constrained **and** indexed.
- [ ] `NOT NULL` and `DEFAULT` reflect reality.
- [ ] Timestamps are `TIMESTAMPTZ`.
- [ ] Exact values are `NUMERIC`, not floating point.
- [ ] Enums only for genuinely stable sets.
- [ ] JSONB used only where a column or table would be worse.
- [ ] Every index traces to a query.
- [ ] Migration is additive and has a stated rollback.

---

*Adapted for GymLvl from `Dokhacgiakhoa/Agent-Skills-4-Vibe-Coding-CLI` @ `c4a059bb`, path
`.agent/skills/postgresql/`. MIT, © 2026 Dokhacgiakhoa. Condensed: partitioning, PostGIS, pgvector,
TOAST, collation, and time-series material removed; "safe evolution" restricted to additive changes.
See `docs/agent-system/THIRD_PARTY_NOTICES.md`.*
