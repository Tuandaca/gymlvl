# P9.0 Exercise Contract Hardening Implementation Plan

> **For agentic workers:** Use the repository-native Lead and Agents A–E. Apply test-driven development and independent Agent E review. No Git commit or production deploy is authorized.

**Goal:** Restore a trustworthy local exercise ownership and creation contract without losing catalogue UUIDs or workout history.

**Architecture:** Keep the existing `public.exercises` table and `Exercise` model. Add one local SQL migration to tighten effective RLS/grants and scope the definer quest query. Change only the Supabase exercise repository payload needed to omit server-managed fields. Tests use the effective migration sequence, authenticated roles, and the real repository request shape.

**Tech Stack:** PostgreSQL/PGlite SQL harness, Flutter/Dart, Supabase/PostgREST.

**Spec:** Owner's P9 request attached to this session; `docs/audit/P9_DEFECT_GRAPH.md`; `AGENTS.md`.

## Global Constraints

- Preserve the dirty owner changes, especially `Exercise` source/generated files and `.agents/teamwork/**`.
- Preserve the 150 curated exercise UUIDs and all workout history.
- Additive migration only; do not weaken RLS or progression ACL.
- No AGPL code or third-party media.
- No production migration, deploy, commit, push, or tag.
- Use `PASS`, `FAIL`, `BLOCKED`, `NOT RUN` with current-session commands and output.

## Review Focus

- Owner A must not read owner B's custom exercise even while the older permissive policy exists.
- A quest generated for owner B must not contain owner A's custom or archived exercise.
- Client DELETE must not cascade an exercise referenced by another user's workout.
- New custom insert must let SQL supply non-null timestamps.
- An archived custom must remain referencable by workout history.

## Task 1: SQL RED regressions (Agent E)

**Files:** Create `supabase/tests/p9_exercise_contract.sql`.

**Interfaces:** Exercises retain `user_id`, `source`, `is_archived`; `sync_daily_data()` retains its zero-argument `jsonb` signature.

- [ ] Write two-user RLS SELECT and `sync_daily_data()` privacy assertions in a transaction that rolls back.
- [ ] Write a referenced-custom DELETE assertion that checks workout and set rows survive.
- [ ] Run `cd tools/db-tests; npm test` and capture the expected behavioral failure before a migration exists.

## Task 2: Additive SQL correction (Agent C)

**Files:** Create `supabase/migrations/20261110000100_p9_exercise_contract.sql`.

**Interfaces:** No table rename, no RPC signature change, no new reward path. `sync_daily_data()` remains owner-authenticated and returns the same JSON shape.

- [ ] Remove the effective broad exercises SELECT policy while keeping catalogue rows visible and custom rows owner-scoped.
- [ ] Remove authenticated hard DELETE permission/policy; archive remains the client deletion behavior. Preserve privileged account purge.
- [ ] Scope the definer quest exercise query to public, non-archived catalogue rows (or an explicitly owner-scoped equivalent) without changing quest reward logic.
- [ ] Run `cd tools/db-tests; npm test`; confirm the new regression and existing ACL suite pass.

## Task 3: Flutter RED and repository payload (Agent E then Agent B)

**Files:** Create `app/test/p9_custom_exercise_repository_test.dart` if a real request-shape test is feasible; modify `app/lib/features/workout/data/supabase_exercise_repository.dart` only after RED.

**Interfaces:** `createCustomExercise(Exercise)` and `updateCustomExercise(Exercise)` retain signatures and return `Exercise` decoded from server rows.

- [ ] Agent E demonstrates a failing new-custom insert contract against a request-capturing or database-backed repository test; avoid a fake that merely records a Boolean.
- [ ] Agent B omits server-managed timestamps and immutable owner/source fields from the appropriate write payload while retaining explicit owner validation.
- [ ] Run the focused Flutter test, `flutter analyze`, `flutter test --reporter expanded`, and the format gate. Report any still-existing analyzer issues without suppressing them.

## Task 4: Independent integration review (Agent D, Agent E, Lead)

**Files:** Update `docs/audit/P9_DEFECT_GRAPH.md`, `docs/planning/TASK_BOARD.md`, `docs/planning/SESSION_HANDOFF.md`, and `docs/planning/CHANGELOG_AI.md` after the checkpoint.

- [ ] Agent D checks curated UUID/provenance and catalogue/custom semantics.
- [ ] Agent E attempts cross-user, archive, referenced-delete, and malformed insert paths independently.
- [ ] Lead reruns critical SQL/Flutter commands on the final working-tree state and checks `git status --porcelain=v1` for unrelated changes.
- [ ] Record the next single scoped P9 action and exact remaining blockers. No Git write.
