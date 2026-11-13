# P9.1 Workout mode and completion integrity

**Base:** `main` at `c68e5773fbb18ba03f32f1b2e33eebdecf7017bc` with preserved owner changes and uncommitted P9.0 work.

## Contract

- The production mode and superset gates remain closed. Explicit typed-mode writes are unavailable.
- Legacy `NULL` workout mode remains reps based at authoritative `complete_workout`: a completed set needs at least one rep. Existing SQL reward and PR semantics remain unchanged.
- When the gate is closed, inferred timed or cardio exercises must be rejected before creating a workout exercise or any sets. Reps and bodyweight exercises continue through the legacy path.
- The client must not call the reward RPC for a loaded completed `NULL`-mode set that violates the server's reps requirement; surface a recoverable measurement error instead.
- Supabase `set_type='warmup'` must decode as a warm-up, and serialized sets must use the SQL `set_type` key. Legacy rows without the key remain working sets.
- Do not reinterpret historical `NULL` records, backfill modes, change rewards, or deploy a migration in this slice. A persisted duration-only `NULL` set still needs separate recovery/product approval.

## Steps

1. Agent E adds failing controller and validator regressions under `app/test/**`, exercising the actual controller/repository boundary and both invalid and valid legacy measurements.
2. Agent B changes `workout_mode_contract.dart` and `active_workout_controller.dart` to align the client with the effective SQL rule and reject gated inferred timed/cardio before repository mutation. Fix `workout_set.dart` JSON mapping and regenerate only its own generated parts after Agent E's RED test.
3. Agent E independently challenges the final behavior, including no partial writes, ordinary reps/bodyweight behavior, and completion rejection semantics.
4. Lead reruns affected and full Flutter checks, local SQL contract tests and remaining relevant quality gates; records exact results against the unchanged HEAD and current dirty tree.
5. Lead updates `TASK_BOARD.md`, `SESSION_HANDOFF.md`, `CHANGELOG_AI.md`, and the P9 defect graph at the checkpoint. P9.2 may start only after P9.1 is recorded.

## Scope and limits

Owned code: Agent B, `app/lib/features/workout/domain/workout_mode_contract.dart`, `workout_set.dart` and its generated parts, and `app/lib/features/workout/presentation/controllers/active_workout_controller.dart`. Owned tests: Agent E, `app/test/**`. Lead owns planning documents. The local mode gate is not evidence of deployed production schema. No commit, push, tag, production database change, or deployment is authorized.
