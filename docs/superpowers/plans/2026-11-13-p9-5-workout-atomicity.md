# P9.5 workout mutation atomicity implementation plan

> **For agentic workers:** Use subagent-driven development task by task. This
> repository forbids automatic commits, branches, pushes and deployments.

**Goal:** Make exercise reorder and add-exercise-with-default-sets single
authenticated server transactions, with truthful client state after failures.

**Architecture:** Two additive PostgreSQL RPCs own the mutations and reuse the
private `workout_write_operations` ledger for operation-ID retries. Flutter
submits a complete desired order or complete default-set batch, then updates
local state only after an acknowledged result. A failed read or uncertain
response reloads the authoritative workout.

**Tech Stack:** Flutter/Dart/Riverpod, Supabase/PostgREST, PostgreSQL/PLpgSQL,
PGlite regression harness.

**Spec:** The attached P9 request, section 24 (`P9.5 — ATOMICITY`), and
`docs/planning/TASK_BOARD.md` current P9.5 acceptance criteria.

## Global constraints

- `main` only; preserve the dirty owner work and verified external backup.
- Additive SQL only; no reward, completion, RLS weakening, media or production
  write. `complete_workout` remains the sole award path.
- D-055 was approved on 2026-11-13 for local implementation only.
- No commit, push, tag or deployment without separate approval.

## Review focus

- Failure after the first or second row update leaves the old server order.
- Failure at any default-set insert leaves zero new exercise/set rows and zero
  ledger rows.
- A repeated operation ID with the same payload returns the same result;
  changed payload is rejected without mutation.
- Foreign workout/exercise IDs, duplicate or incomplete order lists, invalid
  set payloads, and completed workouts are denied without mutation.
- Account switch or lost response cannot display a partially saved exercise
  or retain an optimistic order; retry uses the same operation ID.

## File ownership

- Agent C: create `supabase/migrations/20261113000300_p9_workout_mutation_atomicity.sql`.
- Agent B: modify `app/lib/features/workout/domain/workout_repository.dart`,
  `app/lib/features/workout/data/supabase_workout_repository.dart`, and
  `app/lib/features/workout/presentation/controllers/active_workout_controller.dart`.
- Agent E: create `supabase/tests/p9_workout_atomicity.sql` and
  `app/test/p9_workout_atomicity_test.dart`; review the final implementation.
- Lead: `docs/planning/{DECISIONS,TASK_BOARD,SESSION_HANDOFF,CHANGELOG_AI,ARCHITECTURE}.md`,
  `docs/audit/P9_DEFECT_GRAPH.md`, this plan and integration verification.

### Task 1: RED fault injection and contract tests

- [x] Write a Flutter test that injects a second reorder write failure and
  requires local state to reconcile with the server snapshot.
- [x] Write Flutter tests that inject set 1/2/3 failure plus failed cleanup
  and require no partial exercise to be reported as saved.
- [x] Run focused Flutter tests and record the current failures (5/5 RED).
- [x] Write SQL tests for a row-trigger failure in reorder and each set insert;
  assert transaction rollback, unchanged ledger, owner isolation, exact replay,
  payload mismatch and invalid permutations.
- [x] Run the SQL test before the migration and record the missing RPC failure.

### Task 2: Transactional SQL RPCs (after D-055 approval)

**Interfaces:**

- `reorder_workout_exercises_v1(p_operation_id uuid, p_workout_id uuid,
  p_exercise_ids uuid[]) RETURNS jsonb`.
- `add_workout_exercise_with_sets_v1(p_operation_id uuid, p_workout_id uuid,
  p_exercise_id uuid, p_mode text, p_sets jsonb) RETURNS jsonb`.
- The add RPC derives append order under the owner/workout lock. `p_sets`
  contains 1–100 exact objects with integer `reps`, numeric
  `weight_kg`, and integer `duration_seconds`; the server numbers sets 1..N.
  Current mode gate sends NULL, with reps > 0 and duration 0.
- Add returns `{operation_id,workout_id,workout_exercise_id,set_ids}`;
  reorder returns `{operation_id,workout_id,exercise_count}`. Flutter reloads
  authoritative detail after add acknowledgement or replay.

- [x] Validate authenticated owner, active workout, catalog exercise,
  bounded payload and complete permutation before mutation.
- [x] Lock account then workout; check the private operation ledger for exact
  replay or key/content mismatch before active-state rejection.
- [x] Reorder in one SQL UPDATE using input ordinality; preserve existing
  superset behavior and leave reward tables untouched.
- [x] Insert exercise, all default sets and one ledger receipt in one function
  call; reject an exercise already present in the same workout, matching the
  controller's duplicate no-op. Use existing guards/constraints for mode,
  custom catalog and set data.
- [x] Revoke public/anon function access and grant only authenticated EXECUTE;
  run Agent E SQL regressions and the full local SQL/ACL suite.

### Task 3: Flutter integration and truthful failure state

- [x] Add a narrow optional `AtomicWorkoutMutationRepository` capability with
  a stable operation ID. The controller fails closed when the capability is
  unavailable; it never falls back to the sequential add path. The Supabase
  adapter uses one RPC per mutation and decodes the acknowledged exercise
  with its sets; no sequential table writes or cleanup DELETE.
- [x] Move last-set suggestion lookup and set defaults before the add RPC;
  validate before sending. Freeze both operation ID and validated payload for
  an ambiguous retry; clear them only after acknowledged success or
  account/workout reset.
- [x] Reorder state and backup only after the RPC succeeds; on failure reload
  the authoritative workout before showing `save_failed`.
- [x] Keep generation checks across async reads/RPCs so an old account response
  cannot mutate the new account's state.
- [x] Run focused Flutter fault-injection/adapter tests, full Flutter suite,
  format, analyzer, web and Android builds. Report any quality debt exactly.

### Task 4: Integration and checkpoint

- [x] Have Agent E independently challenge duplicate RPC, mid-write trigger,
  network interruption, stale client state, cross-user IDs and completed
  workout behavior. Add a true two-connection scenario if the existing harness
  can exercise the new ledger without production access.
- [x] Run final SQL/ACL, concurrency, Flutter, Edge, format and build checks
  relevant to changed code, then `git diff --check`.
- [x] Record results, D-055 approval and production gate in the board, handoff,
  changelog, architecture and defect graph. No Git or production write.
