# GymLvl — Session Handoff

## NEW SESSION START HERE

| Field | Value |
|---|---|
| Date | 2026-11-09 |
| Branch | `main` |
| HEAD before remediation commit | `fef9df89f4fa466b275ee0420e5a3e673dfcf6c6` (origin/main == local main) |
| Remote | `origin/main` == local `main` |
| Working-tree state | Dirty — pre-existing owner work preserved (modified tracked + untracked owner files) + remediation changes (8 files) + 3 planning docs updated. **Do not discard, reset, or overwrite owner files.** |
| Product | GymLvl — mobile-first fitness RPG (Flutter + Riverpod + GoRouter + Supabase/PostgreSQL + Edge Functions), Candy Neubrutalism UI, VI/EN |
| Current architecture | Existing GymLvl Flutter/Supabase architecture preserved; OpenGym is behavioral reference only (AGPL, no code reuse) |
| Completed foundation | M1–M5 foundation complete. P1–P8 complete per prior sessions. **Full-system production remediation COMPLETE** — production backend/schema reconciled against live project `shulhhxdebsfbsxcborq`. |
| Production MCP | `supabase-gymlvl` — available. Project URL: `https://shulhhxdebsfbsxcborq.supabase.co`. 21 migrations applied (1 baseline pre-existing + 20 applied this session). Edge Functions `delete-account` v1 and `ai-coach` v1 deployed (verify_jwt=true, ACTIVE). |
| Production schema state | 32 tables (was 14). All onboarding-critical objects present: `initialize_user`, `handle_new_user`, `on_auth_user_created`, `profiles.timezone`, `complete_workout`, `delete_account_data`, `get_player_progression`. `anon` write privileges revoked. Missing auth→public user count = 0. |
| Onboarding state | Root cause fixed: `initialize_user` missing from production → now deployed. Error classification added (`OnboardingFailure`) with sanitized debug and specific user-safe VI/EN messages. |
| Test results (this session) | Production E2E with disposable account: SIGNUP PASS, ONBOARDING 9/9 PASS, DASHBOARD PASS, WORKOUT COMPLETE PASS (XP: 5, Level 1), XP IDEMPOTENCY PASS (no double award), ACCOUNT DELETION (RPC) PASS. Flutter: `pub get` PASS, `format` PASS, `analyze` 0 errors, `test` 744 pass / 0 fail. |
| Remediation changed files (8) | `app/lib/core/localization/localization_engine.dart`; `app/lib/features/ai_trainer/presentation/providers/pt_context_provider.dart`; `app/lib/features/onboarding/presentation/providers/onboarding_controller.dart`; `app/lib/features/onboarding/presentation/screens/onboarding_screen.dart`; `app/lib/features/progression/presentation/providers/player_progression_view_provider.dart`; `supabase/functions/delete-account/index.ts`; `supabase/migrations/20261109000300_remediation_complete_workout_warmup_parity.sql`; `supabase/migrations/20261109000400_remediation_delete_account_purge.sql` |
| Planning docs updated (3) | `docs/planning/TASK_BOARD.md`, `docs/planning/SESSION_HANDOFF.md`, `docs/planning/CHANGELOG_AI.md` |
| Owner files preserved | All pre-existing owner modified/untracked files (`.agents/teamwork/**`, `.opencode/opencode.jsonc`, `app/android/gradle*.properties`, `app/lib/features/analytics/**`, `app/lib/features/bodyweight/**`, `app/lib/features/workout/domain/exercise*.dart`, etc.) EXCLUDED from remediation commit. |
| Open decisions (DECISIONS.md) | O-01..O-11 unresolved (license, AGPL, Drift production gate, import scope, AI provider, Android SDK, Supabase credentials, provenance, tag name, Apache-2.0 notice, .opencode commit split). These block later milestones, not this remediation. |
| Milestone status | `COMPLETE` — full-system production remediation. All mandatory acceptance criteria verified against production. |
| Next action | Stage exactly the 8 remediation files + 3 planning docs, commit `fix: complete production remediation and critical flows`, push `origin/main`, then STOP (no tag/release/deploy). Owner approval required for commit/push. |

## Do not do

- Do not start post-P8 features.
- No production deploy/migration beyond the remediation migrations already applied via MCP.
- No media, no AGPL code, no third-party media.
- No commit/push/tag without owner approval.
- Do not overwrite owner dirty files (esp. `app/android/gradle/wrapper/gradle-wrapper.properties`, `app/android/gradle.properties`).
