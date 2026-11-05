# GymLvl — Task Board

## Current phase — P4: Progress / Analytics / Utility Parity (2026-11-06)

**Task:** Deepen GymLvl's progress tracking, analytics and practical user-data utilities using pinned OpenGym behavior as reference. Build on the existing GymLvl analytics/bodyweight/progression implementation. Do NOT create parallel analytics or measurement systems.

**Execution order (mandatory):** audit → independently design minimal integration → implement → focused tests → regression → context update → stop. Do NOT stop after planning. Do NOT start P5.

**Status:** `COMPLETE` (all eight frozen P4 CORE gates PASS)

**Commit:** `main` @ `9b822b62d4e211bb2bd723aa34923231c7c52f73` (baseline); working tree dirty with pre-existing owner P2/P3/M3/M4 work (preserved, untouched). P4 changes are additive new files + edits to non-dirty files only. P4 NOT yet committed (awaiting owner approval).

**Frozen P4 CORE gates (exactly eight; no new acceptance criteria may be added):**
1. Exercise-level progress/history — `PASS` (engine + provider + screen + route + 8 focused tests)
2. General body measurements — `PASS` (additive migration + model + repository + provider + screen + route + SQL/ACL test)
3. Advanced strength/volume analytics — `PASS` (engine extended + provider + route + 9 focused tests)
4. Muscle / structural-balance analytics — `PASS` (engine + 7 focused tests)
5. Deterministic recovery/readiness insight — `PASS` (engine + 7 focused tests)
6. CSV data export — `PASS` (service + provider + screen + route + 6 focused tests)
7. Portable user-data backup export — `PASS` (service + provider + screen + route + 6 focused tests)
8. Focused tests + regression + security — `PASS` (all focused tests + analyze + full suite; sole failure = pre-existing release_config_test.dart)

**P4 = COMPLETE.** `P5 = NEXT / NOT STARTED`. Do not start P5.

**Invariants to preserve (do not violate):**
- Flutter + Dart + Riverpod + GoRouter + Supabase/PostgreSQL; existing workout engine/history/bodyweight/analytics/progression/PR/1RM/Class/XP/Level/Quest/Streak logic.
- `complete_workout` remains sole authoritative reward path; no P4 operation may directly award XP.
- Additive DB migrations only; preserve bodyweight/history; maintain RLS + owner scope; no production `supabase db push`.
- Bold Candy Neubrutalism UI; VI/EN diacritics; no AGPL code/media; no third-party media.
- OpenGym = behavioral reference only; no code/text/asset copying.
- `main` is the only development branch; no automatic commit/push/tag.

**Pre-existing owner dirty/untracked files (PRESERVE — do not overwrite, reset, or discard):**
Modified tracked: `.agents/teamwork/ORIGINAL_REQUEST.md`, `.opencode/opencode.jsonc`, `app/.gitignore`, `app/android/gradle.properties`, `app/android/gradle/wrapper/gradle-wrapper.properties`, `app/lib/features/analytics/domain/analytics_models.dart`, `app/lib/features/bodyweight/domain/bodyweight_trend.dart`, `app/lib/features/bodyweight/presentation/providers/bodyweight_providers.dart`, `app/lib/features/bodyweight/presentation/screens/bodyweight_screen.dart`, `app/lib/features/bodyweight/presentation/widgets/bodyweight_trend_chart.dart`, `app/lib/features/workout/domain/workout.freezed.dart`, `app/lib/features/workout/domain/workout.g.dart`, `app/test/analytics/analytics_engine_test.dart`, `app/test/analytics/analytics_screen_test.dart`, `app/test/bodyweight/bodyweight_measurement_test.dart`, `app/test/bodyweight/bodyweight_screen_test.dart`, `app/test/bodyweight/bodyweight_trend_test.dart`, `app/test/bodyweight/bodyweight_validator_test.dart`, `app/test/exercise_detail_test.dart`, `app/test/training_plan/first_week_plan_test.dart`.
Untracked: `.agents/teamwork/BRIEFING.md`, `.agents/teamwork/handoff.md`, `.agents/teamwork/interviewer/`, `.agents/teamwork/orchestrator/`, `app/android/run_gradle.bat`, `docs/audit/phases/A8_BATCH_EXECUTION.md`, `docs/planning/M3_1_DECISION_PROPOSAL.md`, `gradle_check.ps1`, `run_gradle_check.bat`.

**Known unrelated failure that may remain:** `release_config_test.dart` (Gradle wrapper 9.7.1 vs expected 8.13 — owner Gradle file, do not modify).

**Next action:** All eight P4 frozen gates PASS. P4 is complete; await owner approval to commit the P4 candidate changes (see `git status --short` / `git diff --name-status`). Do not start P5.
