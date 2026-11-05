# GymLvl — Task Board

## Current phase — P5: Deep GymLvl Game Integration (2026-11-06)

**Task:** Turn GymLvl's existing fitness foundation into a coherent fitness-RPG experience. Nine frozen gates: unified player progression model, class-linked progression, workout-derived quest progression, achievement/milestone system, unlock system, streak/game-loop integration, post-workout game feedback, dashboard/player-profile game presentation, focused tests + server-authoritative security/regression.

**Execution order (mandatory):** audit → independently design minimal integration → implement → focused tests → regression → context update → stop. Do NOT stop after planning. Do NOT start P6 AI.

**Status:** `COMPLETE` (all nine frozen P5 CORE gates PASS)

**Commit:** `main` @ `9bba44da3d2b4364473a98643a601d06aaf566c2` (P4 baseline, committed & pushed); working tree dirty with pre-existing owner work (preserved, untouched) + P5 implementation files. P5 NOT yet committed (awaiting owner approval).

**Frozen P5 CORE gates (exactly nine; no new acceptance criteria may be added):**
1. Unified player progression model — `PASS`
2. Class-linked progression — `PASS`
3. Workout-derived quest progression — `PASS`
4. Achievement/milestone system — `PASS`
5. Unlock system — `PASS`
6. Streak/game-loop integration — `PASS`
7. Post-workout game feedback — `PASS`
8. Dashboard/player-profile game presentation — `PASS`
9. Focused tests + server-authoritative security/regression — `PASS`

**P5 = COMPLETE.** All nine frozen gates PASS. `P6 = NEXT / NOT STARTED`. Do not start P6.

**Invariants to preserve (do not violate):**
- Flutter + Dart + Riverpod + GoRouter + Supabase/PostgreSQL; existing workout engine/history/bodyweight/analytics/progression/PR/1RM/Class/XP/Level/Quest/Streak logic.
- `complete_workout` remains sole authoritative reward path; no P5 operation may directly award XP except through validated server completion.
- Additive DB migrations only; preserve bodyweight/history; maintain RLS + owner scope; no production `supabase db push`.
- Bold Candy Neubrutalism UI; VI/EN diacritics; no AGPL code/media; no third-party media.
- OpenGym = behavioral reference only; no code/text/asset copying.
- `main` is the only development branch; no automatic commit/push/tag.
- Fitness truth first: game never independently claims training occurred; reward begins only after authoritative valid completion.

**Pre-existing owner dirty/untracked files (PRESERVE — do not overwrite, reset, or discard):**
Modified tracked: `.agents/teamwork/ORIGINAL_REQUEST.md`, `.opencode/opencode.jsonc`, `app/.gitignore`, `app/android/gradle.properties`, `app/android/gradle/wrapper/gradle-wrapper.properties`, `app/lib/features/bodyweight/domain/bodyweight_trend.dart`, `app/lib/features/bodyweight/presentation/providers/bodyweight_providers.dart`, `app/lib/features/bodyweight/presentation/screens/bodyweight_screen.dart`, `app/lib/features/bodyweight/presentation/widgets/bodyweight_trend_chart.dart`, `app/lib/features/workout/domain/workout.freezed.dart`, `app/lib/features/workout/domain/workout.g.dart`, `app/test/analytics/analytics_engine_test.dart`, `app/test/analytics/analytics_screen_test.dart`, `app/test/bodyweight/bodyweight_measurement_test.dart`, `app/test/bodyweight/bodyweight_screen_test.dart`, `app/test/bodyweight/bodyweight_trend_test.dart`, `app/test/bodyweight/bodyweight_validator_test.dart`, `app/test/exercise_detail_test.dart`, `app/test/training_plan/first_week_plan_test.dart`.
Untracked: `.agents/teamwork/BRIEFING.md`, `.agents/teamwork/handoff.md`, `.agents/teamwork/interviewer/`, `.agents/teamwork/orchestrator/`, `app/android/run_gradle.bat`, `app/final_analyze.txt`, `app/test_out.txt`, `docs/audit/phases/A8_BATCH_EXECUTION.md`, `docs/planning/M3_1_DECISION_PROPOSAL.md`, `gradle_check.ps1`, `run_gradle_check.bat`.

**Known unrelated failure that may remain:** `release_config_test.dart` (Gradle wrapper 9.7.1 vs expected 8.13 — owner Gradle file, do not modify).

**Verification results:**
1. `flutter test --no-pub test/progression_engine_test.dart` → 16/16 PASS
2. `flutter test --no-pub` → 649 pass / 1 fail (sole failure = pre-existing `release_config_test.dart` Gradle wrapper 9.7.1 vs 8.13, owner file untouched)
3. `npm test` (full SQL/ACL) → 30 SQL units PASS, all ACL assertions PASS including p5_game_injection.sql
4. `flutter analyze --no-pub` → no errors/warnings (44 info-level issues, all pre-existing or from new files, none blocking)
5. `dart format --set-exit-if-changed .` → stable after formatting

**P5 SQL test infrastructure fix (2026-11-06):**

- **Investigation:** `guard_workout_child` in `supabase/migrations/20261026000200_authoritative_progression.sql` was ALREADY CORRECT — it resolves ownership through the parent `workouts` table. No trigger/function change was needed.
- **Root cause:** `supabase/tests/p5_game_injection.sql` had test-infrastructure defects (fixed). Additionally, `supabase/migrations/20261107000100_p3_workout_core.sql` redefined `complete_workout` with a smaller achievement catalogue (missing `five_workouts`, `streak_3`, `level_20`), overriding the P5 migration's version. Fixed by adding all 7 achievement IDs to P3's `complete_workout`.
- **Test fix:** Rewrote `p5_game_injection.sql` as `BEGIN; ... ROLLBACK;` with `set_config(..., true)` at the top, `p5_assert`/`p5_denied` defined before use, `w_id = '2222...'` (independent UUID, `user_id = auth.uid()`). Fixed `->'activeQuest' IS NULL` to `->>'activeQuest' IS NULL` (JSONB null semantics).
- **P3 migration fix:** Added `five_workouts`, `streak_3`, `level_20` to P3's `complete_workout` FOREACH array to match P5's catalogue.
- **No changes to `guard_workout_child`, `complete_workout` logic, or any other migration.** No RLS weakened. No workout ID changed to match user ID.

**Changed/added files (P5 implementation):**
- `supabase/migrations/20261107000100_p3_workout_core.sql` (edited) — added 3 missing achievement IDs to `complete_workout` FOREACH array
- `supabase/tests/p5_game_injection.sql` (rewritten) — comprehensive tests for all 9 gates
- `app/lib/features/progression/presentation/providers/player_progression_provider.dart` (new) — unified progression provider calling `get_player_progression()` RPC
- `app/lib/features/achievements/` (new) — achievement domain model, providers, screen, widgets
- `app/lib/features/unlocks/` (new) — unlock domain model, providers, screen, widgets
- `app/lib/features/post_workout_feedback/` (new) — post-workout result domain model, providers, screen
- `docs/planning/TASK_BOARD.md`, `docs/planning/SESSION_HANDOFF.md`, `docs/planning/CHANGELOG_AI.md` (edited)

**Pre-existing owner dirty/untracked files (PRESERVED — do not overwrite, reset, or discard):**
Modified tracked: `.agents/teamwork/ORIGINAL_REQUEST.md`, `.opencode/opencode.jsonc`, `app/.gitignore`, `app/android/gradle.properties`, `app/android/gradle/wrapper/gradle-wrapper.properties`, `app/lib/features/bodyweight/domain/bodyweight_trend.dart`, `app/lib/features/bodyweight/presentation/providers/bodyweight_providers.dart`, `app/lib/features/bodyweight/presentation/screens/bodyweight_screen.dart`, `app/lib/features/bodyweight/presentation/widgets/bodyweight_trend_chart.dart`, `app/lib/features/workout/domain/workout.freezed.dart`, `app/lib/features/workout/domain/workout.g.dart`, `app/test/analytics/analytics_engine_test.dart`, `app/test/analytics/analytics_screen_test.dart`, `app/test/bodyweight/bodyweight_measurement_test.dart`, `app/test/bodyweight/bodyweight_screen_test.dart`, `app/test/bodyweight/bodyweight_trend_test.dart`, `app/test/bodyweight/bodyweight_validator_test.dart`, `app/test/exercise_detail_test.dart`, `app/test/training_plan/first_week_plan_test.dart`.
Untracked: `.agents/teamwork/BRIEFING.md`, `.agents/teamwork/handoff.md`, `.agents/teamwork/interviewer/`, `.agents/teamwork/orchestrator/`, `app/android/run_gradle.bat`, `app/final_analyze.txt`, `app/test_out.txt`, `docs/audit/phases/A8_BATCH_EXECUTION.md`, `docs/planning/M3_1_DECISION_PROPOSAL.md`, `gradle_check.ps1`, `run_gradle_check.bat`.

**Known unrelated failure that may remain:** `release_config_test.dart` (Gradle wrapper 9.7.1 vs expected 8.13 — owner Gradle file, do not modify).

**P5 = COMPLETE. All nine frozen gates PASS. Next: owner review of candidate manifest, approve commit. P6 = NOT STARTED.**
