# P10.1 — Live schema to local migration reconciliation

**Date:** 2026-11-13
**Repository:** `main` at `7e21abb7649d108bf9b54ae59e874e816f2b54ff`
**Status:** `PASS` for the bounded read-only inventory below; production rollout remains `BLOCKED`.
**Boundary:** The project-scoped Supabase MCP connection reported `current_user=supabase_read_only_user` and `transaction_read_only=on`. Only catalog reads, aggregate data reads, and local tests ran. No SQL write, migration repair, deploy, import, Auth login, or Git write ran.

## Key result

`supabase_migrations.schema_migrations` exists but contains **zero rows**; MCP `list_migrations` also returned `[]`. The live database contains substantial schema and user data. Therefore a present object is evidence of current shape, **not proof that its local migration file ran**. The 21 pre-P9 files have representative live markers, with the qualifications below. All seven P9 files have missing or contradictory markers. A normal remote `db push` would see the local files as pending according to Supabase migration tracking and is not a safe next step. Supabase documents `migration repair` as a history-only write for cases where actual schema state is known to match; marker checks alone do not justify it. See [Supabase migration guidance](https://supabase.com/docs/guides/deployment/database-migrations).

## File-by-file markers

`Present` means only that the named live marker was observed. Function, policy, grant, data, trigger, and constraint equivalence was not established for every file. `Absent` means the checked P9 marker is missing. These are observations, not applied-version claims.

| Local migration | Live marker observation | Assessment |
|---|---|---|
| `20261026000100_baseline` | `users`, `profiles`, `workouts`, `exercises` exist | Present; exact baseline unproven |
| `20261026000200_authoritative_progression` | `workout_rewards`, `profiles.timezone`, `workouts.reward_result` exist | Present; exact function body unproven |
| `20261027000100_exercise_catalog_metadata` | `exercises.slug`, `name_vi`, `name_en`, `form_cues` exist | Present |
| `20261029000100_effective_progression_acl` | All 17 sampled core tables have RLS; authenticated cannot update `users.total_xp`/`level` or insert `xp_logs`/`workout_rewards` | Critical ACL spot checks pass; full effective-grant equivalence unproven |
| `20261029000200_prevent_legacy_double_award` | `idx_xp_logs_user_source` exists; `complete_workout` contains the workout/quest XP-ledger guard | Present; exact historical version unproven |
| `20261103000100_m3_offline_foundation` | `workout_write_operations`, `apply_workout_set_create_v1` exist | Present |
| `20261103000200_m3_superset_modes` | `workout_exercises.mode`, Superset/mode lock tables exist | Present |
| `20261104000100_m4_progression_rpe_rir` | `workout_sets.rpe`, `rir` exist | Present |
| `20261105000100_m5_analytics_indexes` | Four named analytics indexes exist | Present |
| `20261105000200_m5_bodyweight_measurements` | Table and update trigger exist | Present |
| `20261105000300_p1_exercise_provenance` | `exercises.source`, `external_id` and source indexes exist | Present |
| `20261106000100_p2_routine_planning` | Routine, schedule, and planned-workout tables exist | Present |
| `20261106000200_p4_body_measurements` | Table and update trigger exist | Present |
| `20261106000300_p7_exercise_personalization` | `exercises.user_id`, `is_archived`, favourites and aliases exist | Present; current broad policy needs P9.0 correction |
| `20261106000400_p7_import_records` | `import_records` and user index exist | Present |
| `20261107000100_p3_workout_core` | `workout_sets.set_type` exists | Present; `complete_workout` was later replaced |
| `20261107000200_p5_game_integration` | `unlock_definitions`, `user_unlocks`, `get_player_progression` exist | Present; client unlock insert remains allowed pending P9.3 |
| `20261109000100_p8_complete_workout_mode_validation` | Live `complete_workout` contains timed/cardio validation | Behavior marker present |
| `20261109000200_p8_delete_account` | `delete_account_data` exists | Present |
| `20261109000300_remediation_complete_workout_warmup_parity` | Live body contains warm-up exclusion; comment/whitespace-insensitive token comparison to local body found one different title literal: live `Chiến Bình`, local `Chiến Binh` | Behavior marker present; exact body parity fails |
| `20261109000400_remediation_delete_account_purge` | Live body purges write ledger, schedules, aliases; comment/whitespace-insensitive token comparison to local body found no differences | Strong body-level match; history still unproven |
| `20261110000100_p9_exercise_contract` | `catalogue_read` still has `USING (true)`; authenticated can DELETE exercises; P9 guard/quest markers absent | Absent / conflicting |
| `20261110000200_p9_historical_workout_import` | `workouts.is_imported`, receipt table and RPC absent | Absent |
| `20261110000300_p9_historical_measurement_import` | Receipt table and RPC absent | Absent |
| `20261110000400_p9_custom_definition_import` | Receipt table and RPC absent | Absent |
| `20261113000100_p9_class_level_parity` | `class_level_floors` and threshold RPC absent | Absent |
| `20261113000200_p9_unlock_awards` | Unlock sync functions/trigger absent; authenticated can still INSERT `user_unlocks` | Absent / conflicting |
| `20261113000300_p9_workout_mutation_atomicity` | Reorder and add-exercise-with-sets RPCs absent | Absent |

## Live data and security preconditions

- The P9.0 cross-owner custom-exercise reference aggregate is `0`. There are currently `22` exercise rows and `0` user-owned/custom rows. The broad `catalogue_read` policy is therefore a latent exposure for future custom rows, not an observed current disclosure. Authenticated exercise DELETE remains allowed and could affect history if exercised.
- All `79` workout-exercise rows have `mode=NULL`. Among `106` completed sets attached to them, two workout sets have `reps=0`; one belongs to a cancelled workout and one to a completed workout with `is_xp_calculated=false`. The latter has no reward receipt, no workout/quest XP ledger, and no other valid completed set. It would fail the P8/P9 `complete_workout` measurement validation if retried. The migration files do not rewrite these rows; this is a behavior/data-policy question, not evidence that DDL itself will fail.
- `user_unlocks` currently has `0` rows, while authenticated still has INSERT permission and the owner-insert policy. P9.3 removes this client grant and backfills only verified unlocks. No existing fake unlock was observed by this aggregate.
- A read-only Auth aggregate counted `9` Auth users. Auth health HTTP 200 is prior-session evidence; signed-in gateway behavior remains untested because there is no disposable test account in this task.

## Proposed non-destructive rollout preparation

1. Obtain a **current consistent backup** and verify restore into a disposable database. The 2026-11-09 artifact is historical only. This step needs owner coordination and must not be inferred from local files.
2. On the restored copy, compare complete schema, policies, effective grants, triggers, constraints, function bodies, seeds, and relevant aggregate data against a fresh local P8 state. Resolve the live `complete_workout` title drift and any other differences explicitly. Do not classify all 21 pre-P9 files as applied from marker presence.
3. Establish an exact migration-history repair plan on the disposable copy only after the P8 state is proven. Test the proposed `migration repair` sequence there, then apply the seven P9 migrations in order and run SQL/RLS/concurrency plus authenticated gateway smoke checks against the copy. Keep the production ledger untouched.
4. Obtain an owner-approved policy for the completed, unrewarded zero-rep workout. Preserve the cancelled workout and all history. Do not infer reps, mode, or XP from nullable/invalid data. Prioritize the P9.0 catalogue privacy and P9.3 unlock-authority fixes before allowing custom-exercise or unlock user testing.
5. Present the exact production commands, backup/restore evidence, data-policy decision, expected schema diff, test-account route, and recovery steps for separate approval. Only then consider a production history repair or migration. No production write is approved by this report.

## Verification

| Check | Status | Evidence |
|---|---|---|
| Repository safety | `PASS` | `git rev-parse HEAD` returned `7e21abb`; external bundle verified against HEAD, bundle clone matched, and the archive contained 841 files matching the Git tree. Existing dirty owner files were left intact. |
| Local migration chain | `PASS` | `cd tools/db-tests; npm test` exited 0: 28 migrations, seeds/replay, 53 SQL verification units and 365 synthetic ACL assertions on isolated PostgreSQL 17.5. |
| Live read-only inventory | `PASS` | MCP `execute_sql` reported read-only role/transaction; `list_migrations` returned `[]`; catalog/aggregate SQL produced the observations above without user IDs or row contents. |
| Full P8 equivalence and current backup/restore | `BLOCKED` | Marker and two-function comparisons do not prove all schema/data/grants match. No current verified backup or disposable restored copy is available. |
| Production migration and migration-history repair | `NOT RUN` | Requires the above gates and separate owner approval. |
