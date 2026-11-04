# M3 Checkpoint Report — Offline-first Workout Core, Modes, Timers, Supersets

**Date:** 2026-11-01
**Baseline:** `main` @ `bd078c79a25a5b253ce1c1e72300dddc050570fe`, matching `origin/main` at preflight
**Overall status:** `PARTIAL`. The bounded rest-timer migration slice is implemented and locally verified; the full M3 exit gate remains open.

## Scope and authority

`docs/planning/MASTER_PLAN.md` §3 names M3 **Offline-first workout core, modes, timers, supersets** and §5 requires offline/reconnect scenarios with no lost sets plus verified modes, timers, and supersets. D-005 remains `PROPOSED`, and O-03 blocks choosing Drift or another new durable local store. The approved M3 execution request authorized implementation without approving that dependency. This checkpoint therefore adapts the existing timer and owner-scoped workout backup; it does not claim the full offline write queue, workout modes, or persisted supersets. M4 progression remains the next planned milestone after M3 is complete, not an action started here.

## Pinned reference and capability mapping

Read-only checks on `D:\Projects\opengym-reference`: `git remote -v` identified `https://github.com/DuarteSantos8/openGym`; `git rev-parse HEAD` returned `e6a95c28a6e3067bdd9b1188d5f37f448d528bd2`; `git status --porcelain=v1` was empty. Only relevant upstream README behavior and timer/workout test names were inspected. No upstream implementation or assets were copied, translated, or ported.

- **KEEP:** GymLvl already logs active workout sets and has a pause/resume/skip/adjust rest timer; those existing contracts remain authoritative.
- **ADAPT:** Continue the existing rest timer across owner-scoped local workout recovery, and present its controls in GymLvl Candy UI with responsive and accessible targets.
- **INDEPENDENT_REIMPLEMENT:** None from upstream source in this slice. Timer behavior was specified from GymLvl state and recovery requirements.
- **BLOCKED:** Durable offline set-write queue needs an approved local-store design (D-005/O-03). Persisted superset grouping needs an approved additive data contract. AGPL source reuse needs O-02; exercise prose needs O-08 provenance.
- **DEFER:** Other workout modes, advanced set types, catalogue import, media, progression, and later milestones.

## Implementation and data compatibility

- `ActiveWorkoutController` now includes optional `rest_timer` metadata in its existing authenticated-owner backup. The snapshot is bound to the workout ID and records remaining/total seconds, pause state, and exact deadline. Running recovery uses the original deadline; paused recovery holds time fixed. Expired, malformed, mismatched, foreign-owner, absent-remote, and completed-remote states do not revive a timer. Backup writes serialize; completion/cancellation wait for them before clearing the backup. An injectable clock supports deterministic tests.
- `RestTimerWidget` and the existing duration wheel use Candy tokens/components. Skip and adjustment controls retain their callbacks, use at least 48dp touch targets, and wrap at 320dp with 2x text. VI/EN labels and countdown semantics are present.
- Existing workout, set, reward, and repository contracts remain unchanged. No new dependency, database migration, RLS change, production access, third-party data, AGPL code, or media was introduced. The existing owner-scoped backup is not a replacement for the unapproved offline storage design.

## Verification at `bd078c79` plus the five local M3 app/test edits

- `flutter test --no-pub test/workout_snapshot_ownership_test.dart test/workout_controller_test.dart test/workout_widgets_test.dart --reporter expanded` (`app/`) → `+75: All tests passed!`, exit 0 (`PASS`). Tests cover running/paused/expired restore, exact deadline across repeated restore, workout/owner mismatch, remote completion cleanup, serialized backup, timer controls, VI/EN, and 320dp/2x layout.
- `flutter analyze --no-pub` (`app/`) → `No issues found! (ran in 4.5s)`, exit 0 (`PASS`).
- `dart format --output=none --set-exit-if-changed lib test` (`app/`) → `Formatted 138 files (0 changed)`, exit 0 (`PASS`).
- `flutter test --no-pub --reporter expanded` (`app/`) → `+331 -1: Some tests failed.`, exit 1 (`FAIL`). The only failure is `release_config_test.dart` expecting Gradle Wrapper 8.13 while the protected local wrapper points to 9.7.1; no M3 test failed.
- `git diff --check` on the five M3 app/test files → exit 0 (`PASS`). Protected-file hash comparison against the verified pre-edit backup → six owner/Gradle files and 125 `.agents/teamwork/` files unchanged (`PASS`).
- Independent QA reviewed the five-file diff and reran `flutter test --no-pub test/workout_snapshot_ownership_test.dart --reporter expanded` → 49/49, exit 0 (`PASS`). QA found two recovery defects (rounded deadline extension and stale backup after completed remote); both were fixed with deterministic regression tests, and QA's final review found no actionable defect.
- Live Supabase, real-device testing, and remote CI → `NOT RUN` in this local slice. Durable offline set-write verification → `BLOCKED` by the unapproved local-store design (D-005/O-03); no production readiness is claimed.

## File manifest and next action

**M3 implementation:** `app/lib/features/workout/presentation/controllers/active_workout_controller.dart`, `app/lib/features/workout/presentation/widgets/rest_timer_widget.dart`.
**M3 tests:** `app/test/workout_controller_test.dart`, `app/test/workout_snapshot_ownership_test.dart`, `app/test/workout_widgets_test.dart`.
**M3 records:** `docs/planning/TASK_BOARD.md`, `docs/planning/SESSION_HANDOFF.md`, `docs/planning/CHANGELOG_AI.md`, and this new report. These nine paths are the candidate commit allowlist for owner review; none is staged.

Protected/unrelated paths remain excluded: `app/android/gradle.properties`, `app/android/run_gradle.bat`, `docs/audit/phases/A8_BATCH_EXECUTION.md`, `gradle_check.ps1`, `run_gradle_check.bat`, `app/android/gradle/wrapper/gradle-wrapper.properties`, and `.agents/teamwork/`. No commit, push, tag, branch change, migration, or deployment occurred.

**Next action:** obtain an approved M3 local-store and superset data design, then implement and verify durable offline set writes and the remaining M3 modes/superset exit criteria. M4 is planned in `MASTER_PLAN.md` but has not started.
