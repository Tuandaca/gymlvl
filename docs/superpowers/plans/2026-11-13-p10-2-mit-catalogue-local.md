# P10.2 MIT Catalogue Local Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Produce and rehearse an idempotent, media-free 1,324-row MIT catalogue import without changing the 150 curated exercises or production.

**Architecture:** Read the pinned MIT checkout directly, validate its revision and fields, generate SQL for the existing `public.exercises` schema, and apply it twice to an isolated PostgreSQL database with the normal migrations and seed. Keep the generated SQL as a review artifact outside the repository until its data and UI contracts pass.

**Tech Stack:** Node.js, PostgreSQL/PGlite, Flutter, Supabase SQL.

**Spec:** `docs/audit/P10_CAPABILITY_REBASELINE.md` P10.2; `docs/planning/DECISIONS.md` D-059.

## Global Constraints

- Import only `hasaneyldrm/exercises-dataset` at `7455efae41b330c265e7cd4b78dfa848e7ce5ebd`, exactly 1,324 text/metadata rows.
- Preserve all 150 curated UUIDs and existing workout references.
- Use `(source, external_id)` for idempotency and retain the MIT notice; no media, links or AGPL content.
- Do not commit, push, deploy or write production.

## Review Focus

- Windows CLI invocation must create its requested output file or fail visibly.
- SQL must encode `text[]` columns as arrays, retaining individual instruction steps and muscle names.
- Imported slugs must not collide with curated slugs or with each other.
- A second import must add zero rows and preserve curated IDs/history.
- English fallback must remain legible in VI/EN UI when `name_vi` is empty.

---

### Task 1: Fix and test import generation

**Files:** Modify `tools/catalogue-import/import.mjs`, `import.test.mjs`.

**Interfaces:** `loadExercisedbExercises(sourceDir)` returns `{rows,totalRecords}`; `emitSql(rows)` returns SQL; CLI `--source DIR --output FILE` writes that SQL.

- [x] Add failing tests for Windows-safe direct invocation, `text[]` SQL, source-key uniqueness and media/link absence.
- [x] Run `npm test` with `EXERCISEDB_SOURCE_DIR` set to the pinned checkout and record the failures.
- [x] Fix only the importer and tests, then rerun the focused suite.

### Task 2: Isolated database and UI rehearsal

**Files:** Add a focused rehearsal under `tools/db-tests/` and its package script; modify `app/lib/features/workout/data/supabase_exercise_repository.dart` and a focused Flutter test for the confirmed 1,000-row API cap.

**Interfaces:** Apply the normal ordered migrations and seed, record the 150 curated IDs and workout references, apply generated SQL twice, and query imported counts, provenance, arrays, slugs, search and filters.

- [x] Add a failing isolated database test that imports twice and asserts 1,474 total rows, 1,324 source rows, 150 stable curated UUIDs, zero media, unique `(source, external_id)` and stable history.
- [x] Add a failing repository test for a 1,474-row catalogue. Supabase's default response cap is 1,000, so `getExercises()` must request bounded pages with a stable order until the final short page.
- [x] Run the tests and fix only confirmed data or UI defects.
- [x] Run the importer, isolated SQL test and focused Flutter catalogue tests; record exact results and limits.

### Task 3: Record the checkpoint

**Files:** Update `docs/planning/TASK_BOARD.md`, `SESSION_HANDOFF.md`, `CHANGELOG_AI.md`, `DECISIONS.md`, and `docs/audit/P10_PRODUCTION_PREFLIGHT.md` only as needed for the owner's backup waiver and actual P10.2 evidence.

- [x] Record P10.1 read-only preflight as a completed audit with rollout still `BLOCKED`; record the owner's choice to defer production backup and advance local P10.2.
- [x] Record P10.2 evidence, next task and production import gate.
- [x] Run `git diff --check` and inspect changed paths; do not create a Git ref.
