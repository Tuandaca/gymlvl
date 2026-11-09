# GymLvl — Task Board

## Current phase — P8: Release Hardening & Quality Audit (2026-11-09)

**Task:** Execute P8 — release-hardening and quality audit across eight frozen CORE gates (release baseline/blocker inventory, Android release hardening, iOS release readiness, security/privacy/permissions/user-data lifecycle, reliability/migrations/backup/recovery, accessibility/runtime/performance, UX/Candy/legal/store-readiness, full regression/release evidence/handoff). Do NOT start any post-P8 feature phase.

**Execution order:** audit → baseline blocker register → implement smallest safe fixes → focused tests → regression → docs → evidence report → stop. Do NOT commit/push/tag (owner approval required).

**Status:** `GAP CLOSURE COMPLETE — REPOSITORY-CONTROLLED VERIFICATION CLEAN` (all repository-controlled P0/P1 resolved; environment/owner-dependent items BLOCKED/NOT RUN)

**Commit:** `main` @ `1ee11e316775d4dbb9a304fabb31c0df5b08425b` (P7 complete + docs sync, pushed to origin/main). Working tree is dirty with pre-existing owner work + P8 gap-closure changes — all PRESERVED. No commit/push/tag performed.

**Frozen P8 CORE gates (exactly eight; no new acceptance criteria may be added):**
1. Release baseline and blocker inventory — **PASS** (evidence-backed baseline + blocker register)
2. Android release hardening — **PASS** (`release_config_test.dart` 13/13; APK built 60.3MB with ephemeral test signing, v2 verified; AAB built 47.0MB; production signing BLOCKED)
3. iOS release readiness — **BLOCKED** (macOS/Xcode unavailable on Windows); static iOS config audits PASS; entitlements NOT REQUIRED
4. Security, privacy, permissions, user-data lifecycle — **PASS** (account deletion implemented: backend RPC + Edge Function + UI + tests; RLS/ACL locally tested; secret scan zero tracked secrets)
5. Reliability, migrations, backup, recovery, operational readiness — **PASS** (36/36 SQL verification units PASS including `m3_superset_modes.sql`, `p2_routine_planning.sql`, `progression_regression.sql`, `security_regression.sql`, `p8_delete_account.sql`; 365 ACL assertions PASS; P7 backup/restore reused; runbook references in report)
6. Accessibility, runtime behavior, performance — **PASS** (widget/regression tests cover text scale/overflow/safe areas/VI-EN); DEVICE PERFORMANCE PROFILING = NOT RUN
7. UX, Candy design, legal, store-readiness — **PASS** (static audit; Candy tokens verified; account deletion UI uses Candy design; brand `GymLvl` preserved; legal/store owner-input items recorded)
8. Full regression, release evidence, P8 handoff — **PASS** (flutter analyze 0 errors on P8 files; flutter test 744 pass / 0 fail; dart format stable (0 changed); release_config_test 13/13; SQL/ACL all PASS; Edge check+test 55/55 PASS including 11 delete-account tests; Web release build PASS; P7 invariants preserved)

**Invariants to preserve (do not violate):**
- Flutter + Dart + Riverpod + GoRouter + Supabase/PostgreSQL + Edge Functions; existing workout engine/history/bodyweight/analytics/progression/RPG.
- `complete_workout` remains sole authoritative reward path; P8 actions grant ZERO XP; imported/restored historical workouts = no retroactive RPG rewards.
- Additive DB migrations only; no existing tables/columns dropped; no RLS weakened; no production `supabase db push`.
- Bold Candy Neubrutalism UI; VI/EN diacritics; no AGPL code/media; no third-party media.
- OpenGym = behavioral reference only; no code/text/asset copying.
- `main` is the sole development branch; no automatic commit/push/tag.
- Pre-existing owner dirty/untracked files preserved (see SESSION_HANDOFF.md and P8 report §2).

**P8 gap-closure files (P8-FINAL-HYGIENE):**
- `supabase/migrations/20261109000100_p8_complete_workout_mode_validation.sql` (new) — restored mode validation in complete_workout
- `supabase/migrations/20261109000200_p8_delete_account.sql` (new) — delete_account_data() RPC
- `supabase/functions/delete-account/index.ts` (new) — delete-account Edge Function
- `supabase/functions/delete-account/delete-account_test.ts` (new) — Edge tests (11 tests, confirmed at .ts path)
- `supabase/config.toml` (edited) — added `[functions.delete-account]` section
- `supabase/tests/p8_delete_account.sql` (new) — SQL/ACL tests for account deletion
- `supabase/tests/p2_routine_planning.sql` (edited) — deterministic date (`CURRENT_DATE + 1` / `CURRENT_DATE + 8`)
- `app/lib/features/profile/presentation/screens/profile_screen.dart` (edited) — added delete account UI
- `app/lib/core/localization/localization_engine.dart` (edited) — added VI/EN deletion keys
- `app/lib/core/router/app_router.dart` (edited) — added `/account/delete` route + `/auth-recovery` route
- `app/lib/features/auth/data/supabase_auth_repository.dart` (edited) — platform-aware reset password redirect
- `app/test/auth_redirect_config_test.dart` (edited) — mobile scheme + localhost classification tests
- `app/lib/features/account_deletion/account_deletion_notifier.dart` (new) — AsyncNotifier with debounce guard
- `app/lib/features/account_deletion/account_deletion_service.dart` (new) — typed AccountDeletionOutcome (success/deferred/failed)
- `app/lib/features/account_deletion/presentation/screens/account_deletion_screen.dart` (new) — web /account/delete screen
- `app/test/features/account_deletion/account_deletion_screen_test.dart` (new) — 13/13 focused Flutter tests PASS
- `docs/audit/P8_RELEASE_HARDENING_REPORT.md` (new/updated) — canonical P8 evidence report
- `docs/planning/ARCHITECTURE.md` (edited) — Edge Function inventory
- `docs/planning/DECISIONS.md` (edited) — added D-049 account-deletion boundary
- `docs/planning/TASK_BOARD.md` (edited) — this document
- `docs/planning/SESSION_HANDOFF.md` (edited) — session state
- `docs/planning/CHANGELOG_AI.md` (edited) — activity log

**P8-EXISTING files (from first P8 run):**
- `docs/audit/P8_RELEASE_HARDENING_REPORT.md` (new) — canonical P8 evidence report (updated)
- `test/ai_trainer/pt_application_test.dart` (formatting-only, reverted to baseline — no content change)

**Reverted / removed accidental P8 diffs:**
- `supabase/migrations/20261107000200_p5_game_integration.sql` — quest `base_xp 150 → 300` edit REVERTED to committed HEAD (P8 must not rewrite historical migration for game balancing)
- `test/ai_trainer/pt_application_test.dart` — formatting-only change REVERTED to baseline (no semantic P8 change)

**Known unrelated failures that may remain:**
- Pre-existing flutter analyze warnings/infos (all unrelated to P8; P8 files have zero analyzer issues)

**Verification results (current session):**
- `dart format --set-exit-if-changed lib test`: PASS (0 changed, stable)
- `flutter analyze --no-pub`: 0 errors on P8 files; pre-existing warnings/infos in unrelated files
- `flutter test --no-pub`: 744 pass / 0 fail (fresh full-suite execution)
- `flutter test --no-pub test/features/account_deletion/account_deletion_screen_test.dart`: 13 pass / 0 fail
- `flutter test --no-pub test/release_config_test.dart`: 13 pass / 0 fail
- `cd tools/db-tests && npm test`: 36 SQL verification units PASS; 365 ACL assertions PASS
- `cd tools/db-tests && npm run check:edge`: PASS (`deno check` on all Edge Functions)
- `cd tools/db-tests && npm run test:edge`: 55 pass / 0 fail (11 delete-account tests confirmed)
- `flutter build web --release`: PASS (`√ Built build\web`)

**P8 blocker register (severity P0–P3):** see `docs/audit/P8_RELEASE_HARDENING_REPORT.md` §2. Key resolved items: P8-B01 (Gradle 8.13), P8-B02 (JBR 21), P8-B08 (account deletion), P8-B09 (release_config_test), P8-B10 (SQL regression). Remaining external: P8-B03 (production signing key), P8-B04 (macOS/Xcode), P8-B05 (Android device), P8-B08 (public deletion URL = OWNER INPUT REQUIRED).

**Immediate next action:** Owner review of P8 report (`docs/audit/P8_RELEASE_HARDENING_REPORT.md`) and candidate commit manifest; decide on commit/push authorization.

**Do NOT commit/push/tag without owner approval.**
