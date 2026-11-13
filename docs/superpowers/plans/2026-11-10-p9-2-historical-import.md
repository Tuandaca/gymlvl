# P9.2 Historical import and backup integrity

**Base:** `main` at `c68e5773fbb18ba03f32f1b2e33eebdecf7017bc`, with preserved owner work and uncommitted P9.0/P9.1. No production or Git write is authorized.

## Confirmed defects

1. `start_workout()` resumes an active workout. Both CSV and backup import call it and can mutate the interactive session.
2. Client `markWorkoutCompleted()` updates fields outside authenticated UPDATE grants. Both imports swallow that failure and count incomplete or partial writes as successes; CSV starts set numbering at zero.
3. Backup export omits custom definitions and mode; restore loses completion, warm-up, rest, timestamps, measurements, and preferences. It ignores owner and graph-reference checks.
4. Optional/client-controlled fingerprints do not prove exactly-once import. The `_sha1` helpers implement 32-bit FNV-1a, and backup's raw JSON digest includes changing export metadata.
5. Imported completed workouts can affect later live-workout achievement counts unless explicitly excluded.

## Accepted local design under D-051

- Implement a new authenticated, server-owned, per-workout transaction; never call `start_workout()` or direct client status UPDATE for history. Derive target owner from `auth.uid()`. Reject cross-owner source backup in this version; account transfer remains a separate product decision.
- Validate a bounded, versioned payload and the entire exercise/set graph before writes. Create a new completed imported workout with its source timestamps and sets, preserving supported semantics. Mark it explicitly imported; do not call `complete_workout` or touch reward, PR, class XP, quest, achievement, or streak ledgers. Exclude imported rows from subsequent live reward milestone counts.
- Use a server-owned unique `(user_id, import_key)` ledger and canonical request digest. Same key/payload returns the original result; same key/different payload fails. Each workout commits or rolls back atomically. File-level result reports each committed or failed workout honestly and may resume after interruption.
- Add a versioned backup format that includes owner custom exercise text/metadata without media, and preserve legacy version 1 with explicit validation/limitations. Rebind owner fields to the current authenticated user; never overwrite curated catalogue IDs. Preserve archived custom references through a narrowly scoped trusted restore path without relaxing interactive guards.
- Normalize fingerprints to content including all supported data; retain a distinct legacy FNV-1a compatibility path, with explicit naming. Only record file completion after all expected records are verified. Do not claim success for skipped measurements or unsupported fields.
- The owner selected per-workout transactions and same-account restore on 2026-11-10. Backup custom definitions and measurements use idempotent owner-scoped operations around those workout transactions; a file may resume, but may only report full success when every supported item has an acknowledged persisted result. Do not replace this with one whole-file transaction.

## Sequence and exclusive writes

1. Agent E writes failing client tests for active-workout isolation and false success, plus SQL transaction/security tests once the RPC signature is fixed.
2. Agent C owns one additive SQL migration and SQL contract. Agent D reviews catalogue/archived custom behavior and UUID preservation. Agent E runs independent SQL adversarial tests.
3. Agent B owns the workout repository interface/adapter and analytics CSV/backup import/export implementation. Do not edit existing generated files. Agent E owns new and updated tests under `app/test/**`.
4. Lead integrates, reviews cross-layer contracts, runs focused/full Flutter, SQL, concurrency, Edge, web and Android checks as affected, and records the checkpoint in task board, handoff, changelog, audit graph, and decision log.

## Gates

No broad table UPDATE/DELETE grants, no direct XP write, no production migration/deploy, and no commit/push/tag. A versioned backup cannot report full restore if any supported item was skipped. If the local SQL schema cannot preserve a field safely, fail validation with an explicit unsupported-field error before writing rather than silently dropping it.
