# M3.1 Final Report — Offline Architecture and Safe Foundation

**Date:** 2026-11-01
**Baseline:** `main` at `bd078c79a25a5b253ce1c1e72300dddc050570fe`; `origin/main` matched at preflight.
**Overall:** `PARTIAL` for the remaining M3 capability. The decision proposal and disconnected foundation are complete; production offline writes, persisted supersets, and active workout modes await owner decisions.

## Scope and execution

Four actual child sessions participated: `m31_offline_arch` (read-only offline write review), `m31_superset_modes` (read-only mode/group review), `m31_flutter_discovery` (two-file implementation and focused tests), and `m31_independent_qa` (read-only independent review and test rerun). The primary agent integrated the proposal, records, verification, and safety checks. There was no AGPL source or media reuse.

`docs/planning/M3_1_DECISION_PROPOSAL.md` is **PROPOSED**, not an approved change to D-005/O-03. It compares Drift/SQLite, raw SQLite, Isar, and the existing snapshot store; recommends a transactional local outbox and an additive server operation ledger/RPC. Stable operation IDs need owner/workout binding, a canonical request fingerprint, owner and active-workout checks, deterministic reconciliation after uncertain acknowledgements, bounded retry, explicit conflict handling, and account isolation. The independent QA finding about reusing an operation ID with different request content was incorporated into the proposal. No server path exists yet.

The proposal compares a nullable group UUID on `workout_exercises` with a dedicated superset group table. Existing set ownership remains by `workout_exercise_id`; legacy rows remain ungrouped. The four mode names from the preserved plan are `reps-weight`, `bodyweight`, `timed`, and `cardio`. Group ordering/rest/edit semantics and mode-specific units/transitions remain unapproved. No group or mode schema, UI, or runtime behavior was introduced.

The sole code foundation is `WorkoutWriteIdentity`: immutable externally supplied owner, workout, and operation IDs; strict deterministic JSON round-trip; exact owner/workout check; structural equality and a collision-safe local comparison key. It does not generate IDs, persist operations, prevent server duplicates, replay writes, or change workout flows.

## Verification at the baseline above

| Check | Result |
|---|---|
| `flutter test --no-pub test/workout_write_identity_test.dart --reporter compact` | `PASS`, 7/7, exit 0. Independent QA also ran the focused file with expanded reporter: `PASS`, 7/7. |
| `flutter test --no-pub test/workout_snapshot_ownership_test.dart test/workout_controller_test.dart test/workout_widgets_test.dart --reporter compact` | `PASS`, 75/75, exit 0; the preserved M3 timer slice has no observed focused regression. |
| `flutter analyze --no-pub` | `PASS`, `No issues found!`, exit 0. |
| `dart format --output=none --set-exit-if-changed lib/features/workout/domain/workout_write_identity.dart test/workout_write_identity_test.dart` | `PASS`, 2 files, 0 changed, exit 0. |
| Full Flutter suite | `NOT RUN` in M3.1: the new pure model is disconnected from production. The prior M3 session's 331/332 result remains historical `FAIL`, solely on `release_config_test.dart` comparing the protected local Gradle Wrapper 9.7.1 with approved 8.13. |
| Live offline sync, isolated server idempotency, device, remote CI | `BLOCKED` or `NOT RUN`: no approved persistence/server contract, O-07 live access, or production integration. No such validation is claimed. |

## Change manifest and safety

**New M3.1 production foundation:** `app/lib/features/workout/domain/workout_write_identity.dart`.

**New M3.1 test:** `app/test/workout_write_identity_test.dart`.

**New M3.1 records:** `docs/planning/M3_1_DECISION_PROPOSAL.md`, `M3_1_FINAL_REPORT.md`.

**M3.1 additions to existing records:** `docs/planning/TASK_BOARD.md`, `docs/planning/SESSION_HANDOFF.md`, `docs/planning/CHANGELOG_AI.md`.

**Earlier uncommitted M3 work preserved without modification:** `app/lib/features/workout/presentation/controllers/active_workout_controller.dart`, `app/lib/features/workout/presentation/widgets/rest_timer_widget.dart`, `app/test/workout_controller_test.dart`, `app/test/workout_snapshot_ownership_test.dart`, `app/test/workout_widgets_test.dart`, `M3_FINAL_REPORT.md`. Their SHA-256 values match the verified pre-M3.1 backup at `D:\Projects\gymlvl-backups\M3_1_20261101_bd078c7`; the three planning records were appended only.

**Protected/unrelated paths:** `app/android/gradle.properties`, `app/android/run_gradle.bat`, `app/android/gradle/wrapper/gradle-wrapper.properties`, `docs/audit/phases/A8_BATCH_EXECUTION.md`, `gradle_check.ps1`, `run_gradle_check.bat` match the pre-M3.1 backup by SHA-256. The six pre-existing dirty/untracked `.agents/teamwork/` files also match their backup copies; the remaining team files have no new tracked Git diff. These files are excluded from any future M3 commit manifest.

The workspace was backed up before M3.1 writes: bundle clone matched HEAD, archive contained 598/598 Git-tree files, and 21 dirty paths matched their backup hashes. The index remains empty. No commit, push, tag, branch, reset, schema migration, deployment, or production data write occurred.

## Approval gate and continuation

Owner approval is required for D-005/O-03 local-store selection; additive server idempotency and fingerprint contract; conflict, encryption, and retention policy; superset group identity/order/rest/edit semantics; and mode-specific data and transitions. Record approved decisions in `DECISIONS.md` before implementation. Preserve existing RLS, IDs, history, and `complete_workout` as the only authoritative reward path. O-02 AGPL reuse and O-08 exercise-text provenance remain open, and O-07 is needed for live database checks.

**Next M3 action:** after owner approval, implement and test the chosen transactional local outbox plus idempotent server write path in an isolated environment, then address superset/mode persistence under the approved contracts. M4 was not started.
