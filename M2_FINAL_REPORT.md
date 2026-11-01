# M2 Final Report — Exercise Detail Layout & Information Architecture

**Date:** 2026-11-01
**Baseline:** `main` @ `1979dfd5fda7cebf6791c11ece3cc1aa333ce1c3`
**Status:** `PASS` for the implemented, legally permitted M2 functionality. All M2 changes remain local and uncommitted.

## Delivered

- A canonical `/exercise/:id` GoRouter screen resolves the stable exercise UUID from the existing Riverpod catalogue. Picker navigation passes an already loaded exercise as an optimization; mismatched route data falls back to the ID lookup. Loading, error/retry, missing ID, and unavailable-exercise states are explicit.
- The Candy detail layout shows localized exercise names and available category, equipment, secondary muscles, movement pattern, and difficulty. It marks primary muscle unavailable because the current model has no primary-muscle field. A media placeholder is used without reading `imageUrl`.
- The picker exposes a 48dp detail action. Returning without selection preserves picker state; selecting from detail preserves the existing single-select `Exercise` and multi-select `List<Exercise>` result contracts. The exercise card badges wrap on narrow screens.
- VI/EN labels, fallback-name notice, actions, loading/error/empty states, and accessibility descriptions are localized. The detail layout scrolls at 320dp and 2x text scale. Raw catalogue metadata values have no separate localized variants.

## Content and data boundaries

O-08 remains open: the provenance of the 150 curated exercise texts is undocumented, and the model has no per-row provenance or instruction locale. The screen therefore does **not** newly display `instructions`, `formCues`, or `commonMistakes` as approved guidance, even when those fields are populated; it shows a localized unavailable state. Existing localized names are reused for exercise identification without asserting verified provenance. No external text, AGPL code, or media was imported. No schema, RLS, or repository contract changed. Live Supabase behavior was not checked.

## Verification at the working tree above `1979dfd5`

- `flutter test --no-pub test/exercise_detail_test.dart --reporter expanded` (`app/`) → `+11: All tests passed!`, exit 0 (`PASS`). Independent QA reran the focused file with `--reporter compact` → 11/11, exit 0 (`PASS`).
- `flutter test --no-pub test/exercise_picker_test.dart --reporter compact` (`app/`) → 67/67, exit 0 (`PASS`). An initial 320dp overflow of 0.5px after adding the detail action was fixed by wrapping exercise-card badges; the final picker run passed.
- `flutter analyze --no-pub` (`app/`) → `No issues found! (5.2s)`, exit 0 (`PASS`).
- `dart format --output=none --set-exit-if-changed` on the seven M2 app files → 0 changed, exit 0 (`PASS`).
- `flutter test --no-pub --reporter expanded` (`app/`) → `+308 -1: Some tests failed.`, exit 1 (`FAIL`). The sole failing test was `release_config_test.dart: wrapper pins the approved Gradle 8.13 binary distribution`; the preserved local Gradle Wrapper points to 9.7.1. No M2 test failed.
- Independent read-only QA reviewed the final seven-file app diff and found no actionable M2 defect. It verified focused tests separately. Real-device behavior, remote CI, and live Supabase verification are `NOT RUN` in this local M2 milestone.

## Candidate commit manifest — not staged

**Prior uncommitted M1-FINAL planning baseline, preserved:** `docs/planning/TASK_BOARD.md`, `docs/planning/SESSION_HANDOFF.md`, `docs/planning/CHANGELOG_AI.md`, `docs/planning/DECISIONS.md`, `docs/planning/MASTER_PLAN.md`, `docs/planning/PROJECT_CONTEXT.md`. M2 appended only to the first three.

**M2 production changes:** `app/lib/core/router/app_router.dart`, `app/lib/features/workout/presentation/providers/exercise_providers.dart`, `app/lib/features/workout/presentation/screens/exercise_picker_screen.dart`, `app/lib/features/workout/presentation/screens/exercise_detail_screen.dart` (new), `app/lib/features/workout/workout_copy.dart`, `app/lib/ui/candy/candy_exercise_card.dart`.

**M2 tests:** `app/test/exercise_detail_test.dart` (new).

**M2 documentation:** additions to `docs/planning/TASK_BOARD.md`, `docs/planning/SESSION_HANDOFF.md`, and `docs/planning/CHANGELOG_AI.md`; this report (new).

**Excluded owner/unrelated work:** `app/android/gradle.properties`, `app/android/run_gradle.bat`, `docs/audit/phases/A8_BATCH_EXECUTION.md`, `gradle_check.ps1`, `run_gradle_check.bat`, `app/android/gradle/wrapper/gradle-wrapper.properties`, and `.agents/teamwork/`. No staging, commit, push, tag, branch change, deployment, or migration occurred.

**Next action:** owner review of the local M2 candidate manifest and the O-08 provenance gate. The current plan lists M3 as Offline-first Workout Core; it has not started and needs separate authorization.
