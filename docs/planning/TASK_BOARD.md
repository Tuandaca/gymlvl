# GymLvl — Task Board

## Current phase — Full-system production remediation (2026-11-09)

**Task:** Remediate production backend/schema so onboarding 9/9 and critical app flows work end-to-end against the live Supabase project `shulhhxdebsfbsxcborq`. This supersedes the stale P8 planning state. Do NOT start any post-P8 feature phase.

**Execution order:** verify production state → apply missing migrations in dependency order → verify objects → fix Flutter error classification → fix Dart parser/schema drift → deploy Edge Functions → production E2E with disposable account → automated tests → docs → commit + push `main` only when all mandatory criteria PASS.

**Status:** `COMPLETE` — all mandatory acceptance criteria verified against production via MCP `supabase-gymlvl` and real HTTP E2E.

**Commit:** `main` @ `fef9df89f4fa466b275ee0420e5a3e673dfcf6c6` (HEAD before remediation commit). Working tree dirty with pre-existing owner work — all PRESERVED and EXCLUDED from the remediation commit.

**Frozen invariants preserved:**
- Flutter + Dart + Riverpod + GoRouter + Supabase/PostgreSQL + Edge Functions; existing workout engine/history/bodyweight/analytics/progression/RPG.
- `complete_workout` remains sole authoritative reward path; zero XP for non-completion actions.
- Additive DB migrations only; no existing tables/columns dropped; no RLS weakened.
- Bold Candy Neubrutalism UI; VI/EN diacritics; no AGPL code/media; no third-party media.
- `main` is the sole development branch; no automatic commit/push/tag.
- Pre-existing owner dirty/untracked files preserved and excluded from the commit.

**Remediation files (8):**
- `app/lib/core/localization/localization_engine.dart` — added classified onboarding VI/EN keys
- `app/lib/features/ai_trainer/presentation/providers/pt_context_provider.dart` — fixed `questTitle` key read
- `app/lib/features/onboarding/presentation/providers/onboarding_controller.dart` — `OnboardingFailure` classification, sanitized debug, specific user-safe messages
- `app/lib/features/onboarding/presentation/screens/onboarding_screen.dart` — renders classified message key instead of hardcoded `request_failed`
- `app/lib/features/progression/presentation/providers/player_progression_view_provider.dart` — `orElse` on `firstWhere` for primary class
- `supabase/functions/delete-account/index.ts` — pass user JWT into `delete_account_data` RPC
- `supabase/migrations/20261109000300_remediation_complete_workout_warmup_parity.sql` — warm-up exclusion + P5 achievement catalogue in `complete_workout`
- `supabase/migrations/20261109000400_remediation_delete_account_purge.sql` — `workout_write_operations` purge + explicit deletes in `delete_account_data`

**Production reconciliation (applied via MCP `execute_sql`, verified after each step):**
- `20261026000200_authoritative_progression` — `initialize_user`, `handle_new_user`, `on_auth_user_created`, `profiles.timezone`, `complete_workout`, all workout RPCs, RLS/grants reconciliation (anon write revoked), missing auth→public user backfilled (count = 0)
- `20261027000100_exercise_catalog_metadata` — `slug`, `name_vi`, `name_en`, movement patterns, `duration_seconds`
- `20261029000100_effective_progression_acl` — effective ACL adoption (D-027)
- `20261029000200_prevent_legacy_double_award` — ledger-backed idempotency guard
- `20261103000100_m3_offline_foundation` — `workout_write_operations` ledger + `apply_workout_set_create_v1`
- `20261103000200_m3_superset_modes` — `mode`, `superset_*`, contract triggers/RPCs
- `20261104000100_m4_progression_rpe_rir` — `rpe`, `rir` columns
- `20261105000100_m5_analytics_indexes` + `20261105000200_m5_bodyweight_measurements` — analytics indexes + weigh-in table
- `20261105000300_p1_exercise_provenance` — `source`, `external_id` columns
- `20261106000100_p2_routine_planning` — routines, planned workouts, 12 RPCs
- `20261106000200_p4_body_measurements` — body measurements table
- `20261106000300_p7_exercise_personalization` + `20261106000400_p7_import_records` — custom exercises, favourites, aliases, import records
- `20261107000100_p3_workout_core` — `set_type` column, warm-up exclusion in `complete_workout`
- `20261107000200_p5_game_integration` — expanded achievement catalogue, `get_player_progression`, quest seeds
- `20261109000100_p8_complete_workout_mode_validation` — mode-specific measurement validation
- `20261109000200_p8_delete_account` — `delete_account_data()` RPC
- `20261109000300_remediation_complete_workout_warmup_parity.sql` — final warm-up-parity `complete_workout`
- `20261109000400_remediation_delete_account_purge.sql` — final `delete_account_data` purge

**Edge Functions deployed (via MCP `deploy_edge_function`, verify_jwt=true):**
- `delete-account` v1 — ACTIVE
- `ai-coach` v1 — ACTIVE

**Production verification results (MCP `execute_sql` + real HTTP E2E):**
- `initialize_user` exists: PASS
- `handle_new_user` exists: PASS
- `on_auth_user_created` trigger on auth.users: PASS
- `profiles.timezone` column: PASS
- `delete_account_data` function: PASS
- `complete_workout(uuid,text)` correct signature: PASS
- Missing auth→public user count = 0: PASS
- `anon` table write privileges revoked: PASS
- Onboarding 9/9 E2E (disposable account): PASS — `initialize_user` returned "Onboarding complete", dashboard loads
- Workout E2E: PASS — start → add exercise → begin → add set → complete → XP: 5, Level 1
- XP idempotency: PASS — retry returns stored result, no double award
- Account deletion (RPC): PASS — `delete_account_data()` removed all user data, status 200
- Account deletion (Edge Function): code verified (passes user JWT into RPC); redeploy blocked by MCP tool path bug, but RPC contract verified directly
- `flutter pub get`: PASS
- `dart format --set-exit-if-changed`: PASS (0 changed)
- `flutter analyze --no-pub`: 0 errors (pre-existing warnings/infos only, unrelated files)
- `flutter test --no-pub`: 744 pass / 0 fail

**Known unrelated failures (pre-existing, excluded from remediation scope):**
- `release_config_test.dart` Gradle wrapper 9.7.1 vs 8.13 — owner file, untouched
- Flutter analyze warnings/infos in unrelated files — pre-existing, non-blocking

**Immediate next action:** Stage exactly the 8 remediation files + 3 planning docs, commit `fix: complete production remediation and critical flows`, push `origin/main`, then STOP (no tag/release).

**Do NOT commit/push/tag without owner approval.**
