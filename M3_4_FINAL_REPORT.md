# M3.4 Final Report — Concurrency Gate and Remaining M3 Contracts

**Date:** 2026-11-03
**Baseline:** `main` @ `bd078c79a25a5b253ce1c1e72300dddc050570fe`
**Status:** `PARTIAL` — PostgreSQL concurrency runtime is unavailable; all real-data, superset, and mode contracts below remain owner decisions. No product code or migration changed.

## Scope and evidence

The owner authorized a bounded M3.4 check of genuine two-connection PostgreSQL idempotency and a compact approval gate. Production offline writes, remote migrations, Superset behavior, workout modes, and M4 remain unauthorized. The working tree matched the known dirty M3/M3.1/M3.3 state; the index was empty. Before documentation edits, `D:\Projects\gymlvl-backups\m3_4-20261103-045027` was verified: bundle clone HEAD matched `bd078c7`, archive count matched the Git tree (598/598), and 38 dirty-file copies matched SHA-256.

The one bounded runtime check found `psql`, `pg_ctl`, `postgres`, Docker, and Podman absent from `PATH`; no PostgreSQL service or listener at `127.0.0.1:5432`; `wsl --list --quiet` exited 1 because WSL is not installed. No already-available two-session PostgreSQL runtime was found. **Result: `POSTGRES_CONCURRENCY_RUNTIME_BLOCKED`.** No runtime was installed, downloaded, started, or contacted remotely.

| Required concurrent scenario | M3.4 status | Evidence limit |
|---|---|---|
| Same operation/payload, two connections, one mutation and equal outcomes | `BLOCKED` | No two-session PostgreSQL runtime |
| Same operation/different fingerprint, one outcome and explicit conflict | `BLOCKED` | No two-session PostgreSQL runtime |
| Lost ACK/replay, no duplicate mutation or reward | `BLOCKED` for concurrency | Prior M3.3 sequential SQL/synthetic evidence is historical |
| Concurrent `complete_workout`, at most one reward | `BLOCKED` | No two-session PostgreSQL runtime |
| Same operation UUID across different users | `BLOCKED` for concurrency | Prior owner-isolation SQL evidence is single-connection |
| Unauthorized owner/workout relationship during a race | `BLOCKED` | No two-session PostgreSQL runtime |

M3.3's 103/103 focused Flutter tests, 14 SQL verification units, 365 ACL assertions, analyzer, and independent QA remain evidence from that session. They were `NOT RUN` in M3.4 because no application, SQL, or test code changed. PGlite's single connection and the synthetic SQLite two-connection claim test are not substituted for PostgreSQL race evidence. No idempotency defect was demonstrated in M3.4; no idempotency code was changed.

## Data-lifecycle contract for owner decision

| Topic | Recommendation | Approval state |
|---|---|---|
| At-rest protection | Encrypt sensitive offline payloads before real-user use; keep keys outside SQLite in platform-backed secure storage; retain only fields needed for replay and reconciliation. Choose the concrete platform key lifecycle before integration. | `PROPOSED` |
| Owner isolation | Require active authenticated user ID to match every stored owner before read, mutation, or sync; never process another owner's queue. | `PROPOSED` for production integration |
| Logout/account switch | Stop sync immediately, revoke in-memory access, and never submit prior-owner operations under the new session. Preserve unresolved encrypted data only for the original owner under the selected retention rule. | `PROPOSED` |
| Retention | Choose **A** `RETAIN_UNTIL_SYNC_OR_EXPLICIT_DISCARD`, or **B** `TTL_RETENTION` with an owner-specified duration and behavior for unsynced work at expiry. No TTL is assumed. | `OWNER_CHOICE` |
| Conflict/reconciliation | Server remains authoritative; same operation ID with different canonical content is a hard conflict; no silent merge; expose a recoverable state and user-visible resolution where safety cannot be proven. | `PROPOSED` |
| Fingerprint boundary | The local hash and server hash currently use different byte encodings and are not compared. Before production transport uses a client hash, approve a shared canonical wire format or explicitly keep server-authoritative recalculation. | `PROPOSED` |

No encryption dependency, account policy, retention timer, or real-user data path was implemented in M3.4.

## Superset v1 contract for owner decision

| Topic | Recommended v1 rule | Current fact / required change |
|---|---|---|
| Group and position | Keep nullable `superset_group_id`; add nullable `superset_position` integer, `>=0`, contiguous and unique within `(workout_id, group_id)` for active grouped rows. Minimum active group size is 2. | Group UUID exists but non-null writes are guarded; position requires approved additive schema and transactional validation. Legacy rows remain `NULL`. |
| Set ownership | Sets always remain linked to their original `workout_exercise_id`; ungrouping never reassigns sets. | Existing FK has `ON DELETE CASCADE`: deleting the exercise row would delete its sets. Member removal must ungroup the row, not delete it. |
| Rounds | Propose round N as each member's existing set with `set_number=N`. Reject duplicate set numbers within a grouped member. If a member lacks N, skip that member; do not create a placeholder or renumber history. A round ends when every present set numbered N is completed. | `set_number` is currently per exercise with no grouped uniqueness/round enforcement; this is a proposed server contract, not an inference applied to old rows. |
| Rest timer | Default no automatic rest between members in one round; start normal rest after the last participating member; allow explicit override and existing manual controls. Timer state does not define round progression. | Recommendation only; current timer remains unchanged. |
| Editing | Membership moves and reorders use one transactional server path. Ungroup a removed member without deleting its row; dissolve the group when fewer than 2 members remain. Freeze membership and order after any member has a completed grouped set in the active workout. | Current per-row reorder calls cannot guarantee atomic group edits. Dissolution and the proposed active-edit freeze require owner approval. |

No Superset UI, write path, or schema extension was added. The existing non-null write guard remains in force.

## Four-mode data contract for owner decision

Recommend one nullable `mode` text discriminator on `workout_exercises`, restricted for **new** rows to exactly `reps-weight`, `bodyweight`, `timed`, or `cardio`. `NULL` means legacy, with existing fields displayed without retrospectively assigning a mode. The discriminator becomes immutable after the first set; a mode change requires a new exercise entry rather than reinterpreting old sets. This is a proposed additive schema and server-validation change, not an active mode.

| Mode / field | Type, unit, nullability, valid range for new completed sets | Owner | Existing-data compatibility / schema gate |
|---|---|---|---|
| All: `mode` | Text enum above; non-null for new mode-aware entries, `NULL` for legacy | `workout_exercises` | New nullable column and immutability validation required; legacy rows stay `NULL`. |
| `reps-weight`: `reps` | Integer, count, non-null, 1–1000 | `workout_sets` | Existing field; old rows keep raw interpretation. |
| `reps-weight`: `weight_kg` | Numeric, kg, non-null, 0–1000 | `workout_sets` | Existing field. |
| `bodyweight`: `reps` | Integer, count, non-null, 1–1000 | `workout_sets` | Existing field. |
| `bodyweight`: `weight_kg` | Numeric, kg of **external load only**, non-null, 0–1000; 0 means unweighted | `workout_sets` | Existing field/UI can display bodyweight at 0 and accept custom load; never infer body mass. Semantics need owner approval. |
| `timed`: `duration_seconds` | Integer, seconds, required for completed sets, 1–7200; `reps=0`, `weight_kg=0` | `workout_sets` | Existing duration field/constraint permits this, but current `complete_workout` rejects completed `reps<1`; separate approved server validation/reward change is required. |
| `cardio`: `duration_seconds` | Integer, seconds, required for completed time-only v1, 1–7200; `reps=0`, `weight_kg=0` | `workout_sets` | Existing duration field; same completion blocker. No distance is inferred or recorded in time-only v1. Distance support needs a separately approved field, unit, range, and migration. |

The latest `complete_workout` in `supabase/migrations/20261029000200_prevent_legacy_double_award.sql` rejects any completed set with `reps<1`, while `workout_sets_valid_values` permits duration-only sets. The constraint is `NOT VALID` for historical rows. Timed/cardio activation must remain blocked until an approved, tested server completion/reward contract resolves this mismatch. No sentinel rep value is proposed.

## Single owner approval gate

The owner may approve or revise these as one decision response; **none is approved by this report**:

1. **Data lifecycle:** encrypted minimal payloads, platform-backed key storage outside SQLite, active-auth owner match, stop/revoke on logout or switch, hard conflict with user-visible resolution, and server-authoritative fingerprint handling. Select retention **A** `RETAIN_UNTIL_SYNC_OR_EXPLICIT_DISCARD` or **B** `TTL_RETENTION` and supply the exact TTL plus unsynced-expiry behavior.
2. **Superset v1:** group UUID scoped to one workout; nullable contiguous `superset_position`; minimum 2 members; ungroup without deleting set owners; automatic dissolution below 2; transactional membership/order; round N from each present member's unique `set_number=N` with absent members skipped and no historical renumbering; no automatic rest between members unless manually overridden; freeze membership/order after the first completed grouped set.
3. **Modes:** approve nullable legacy-preserving four-value discriminator, immutability after first set, bodyweight `weight_kg` as external load, and duration-only cardio v1 **or** specify distance field/unit/range. Separately approve a `complete_workout` validation/reward design for reps-zero timed/cardio before activation.

## Subagent, verification, and change manifest

One read-only Codex subagent reviewed Superset and mode contracts against current SQL and Dart models. It identified the completion predicate mismatch and the `ON DELETE CASCADE` history risk. Its review was static inspection; tests were `NOT RUN`. No PostgreSQL concurrency subagent was spawned because no runtime exists, and no independent code QA agent was needed because M3.4 changed no code/test files.

**M3.4 changed files:** `M3_4_FINAL_REPORT.md`, `docs/planning/DECISIONS.md`, `docs/planning/TASK_BOARD.md`, `docs/planning/SESSION_HANDOFF.md`, `docs/planning/CHANGELOG_AI.md`. No app, SQL migration, test, Android, audit, or agent-teamwork file was changed. No stage, commit, push, tag, deploy, remote migration, production credential, or production data operation occurred. The remote ref was not checked in this session.

Post-edit verification found all 34 pre-existing dirty files outside the M3.4 document set unchanged by SHA-256; `git diff --check` exited 0 and the index remained empty.

**Next action:** obtain the three owner decisions above, then run the six blocked M3.4 concurrency scenarios when an isolated two-connection PostgreSQL runtime becomes available. Production integration remains gated; M4 has not started.
