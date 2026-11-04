# GymLvl — Session Handoff

## NEW SESSION START HERE

| Field | Value |
|---|---|
| Date | 2026-11-05 |
| Branch | `main` |
| HEAD | `962d8f7eb20e82967306c4c73cf06a516fa2ef5f` (`planning_rebase_base_head` at P0 audit; mutable — re-verify with `git rev-parse HEAD`) |
| Remote | `origin/main` == local `main` |
| Working-tree state | Dirty — pre-existing M3/M4 owner work preserved (6 modified tracked files, 10 untracked files); **do not discard, reset, or overwrite** |
| Product | GymLvl — mobile-first fitness RPG (Flutter + Riverpod + GoRouter + Supabase/PostgreSQL + Edge Functions), Candy Neubrutalism UI, VI/EN |
| Current architecture | Existing GymLvl Flutter/Supabase architecture preserved; OpenGym is behavioral reference only (AGPL, no code reuse) |
| Completed foundation | M1–M5 foundation complete. P1 complete: OpenGym parity matrix populated; legal-safe exercisedb import pipeline (1,324 MIT records) implemented and tested; additive provenance migration (source/external_id/source_revision) verified on PGlite; Flutter Exercise model provenance fields added and tested. |
| Current roadmap phase | P1 — OpenGym Parity Baseline + Legal-Safe Exercise Catalogue: COMPLETE |
| Next implementation phase | P2 — Routine & Planning Parity: NOT STARTED (awaits owner instruction) |
| OpenGym pin | `DuarteSantos8/openGym` @ `e6a95c28a6e3067bdd9b1188d5f37f448d528bd2` (AGPL, reference only) |
| Exercise dataset pin | `hasaneyldrm/exercises-dataset` @ `7455efae41b330c265e7cd4b78dfa848e7ce5ebd` (MIT text/data, media excluded). **Import source: direct from pinned MIT dataset (`data/exercises.json`), NOT from OpenGym catalogue.** Verified 1,324 records. |
| Legal restrictions | No AGPL code/prompts/catalogue-text/assets; no third-party media; MIT text only with notice; media excluded |
| Production restrictions | Do NOT deploy production migrations; do NOT run `supabase db push`; onboarding 9/9 blocked on production DB access; no release hardening |
| Immediate next task | Owner review of P1 deliverables; then P2 — Routine & Planning Parity |
| Do not do | Do not start P2+ automatically; no AI PT (P6); no production deploy/migration; no media; no commit/push without owner approval |
| Read first | `docs/planning/MASTER_PLAN.md`, `docs/planning/PROJECT_CONTEXT.md`, `docs/planning/TASK_BOARD.md`, `docs/planning/DECISIONS.md`, `docs/planning/OPENGYM_PARITY_MATRIX.md` |

---

## Current — Onboarding 9/9 submit failure investigation (2026-11-04) — BLOCKED on production DB access

**Task:** Investigate and fix `initialize_user` RPC failure when user completes onboarding step 9/9. UI shows `Không thể hoàn tất yêu cầu. Vui lòng thử lại.`

**Status:** `BLOCKED` — Root cause identified but fix requires production database access/migration deployment, which requires explicit owner approval.

**Root cause:** Production onboarding 9/9 is blocked by a production schema/runtime mismatch. Read-only inspection showed that expected initialization capability such as `initialize_user` and `profiles.timezone` was absent. The exact unapplied migration set has not yet been established.

**Call chain:** `onboarding_screen.dart:42` → `onboarding_controller.dart:54-101` → `SupabaseClient.rpc('initialize_user', ...)` → PostgREST → PostgreSQL `public.initialize_user(p_profile jsonb)` → INSERT `public.profiles`, `public.user_classes`; UPDATE `public.users`; INSERT `public.streaks`.

**Local verification:** PGlite + all 10 migrations → `initialize_user` PASS (onboarding completes, `onboarding_completed=true`, idempotent retry returns "Onboarding already complete").

**Production verification:** `NOT RUN` — no production Supabase access. Cannot confirm exact production error code.

**Files changed:** None (read-only investigation).

**Blockers:** No production Supabase access; `supabase db push`/remote migration requires explicit owner approval per AGENTS.md §0.3/§8.

**Next action:** Owner to verify production database schema (`public.initialize_user` function, `public.profiles.timezone` column, `public.users` rows) and approve migration deployment if missing.

---

## Historical entries

P0 (Planning Rebase & Context Consolidation) and P1 (OpenGym Parity Baseline + Legal-Safe Exercise Catalogue) are complete. Their details are in `CHANGELOG_AI.md`. Previous M1–M5, M3.x, R2, R3, and audit entries are preserved in `CHANGELOG_AI.md` and root `M*_FINAL_REPORT.md` files, not reproduced here.
