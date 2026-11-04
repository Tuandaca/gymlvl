# GymLvl — Task Board

## Current phase — P0: Planning Rebase & Context Consolidation (2026-11-05)

**Task:** Reconcile accumulated planning documents against the actual repository and rewrite the canonical planning/control layer so a new OpenCode session can understand the project without relying on chat history. No product implementation.

**Status:** `COMPLETE` — `MASTER_PLAN.md`, `PROJECT_CONTEXT.md`, `TASK_BOARD.md`, `SESSION_HANDOFF.md`, `CHANGELOG_AI.md`, `DECISIONS.md`, `UPSTREAM_SOURCE_MANIFEST.json` rewritten; `OPENGYM_PARITY_MATRIX.md` created as initial tracking framework.

**Commit:** `main` @ `da21eb7` (`planning_rebase_base_head` at P0 audit; mutable — re-verify with `git rev-parse HEAD`; local only; push pending owner approval)

**Changed files in P0:**
- `docs/planning/MASTER_PLAN.md` (rewritten — P0–P8 roadmap)
- `docs/planning/PROJECT_CONTEXT.md` (rewritten — current truth)
- `docs/planning/TASK_BOARD.md` (rewritten — this file)
- `docs/planning/SESSION_HANDOFF.md` (rewritten — NEW SESSION START HERE block)
- `docs/planning/CHANGELOG_AI.md` (entry added)
- `docs/planning/DECISIONS.md` (P0/P1 decisions added; old milestone decisions marked SUPERSEDED)
- `docs/planning/UPSTREAM_SOURCE_MANIFEST.json` (`planning_rebase_base_head` recorded as `da21eb7` at P0 audit; mutable — re-verify each session)
- `docs/planning/OPENGYM_PARITY_MATRIX.md` (new — empty/initial tracking framework)

**Blockers:** None for P0.

**Next action:** Owner review of P0 deliverables; then start P1.

---

## Current product blocker — Onboarding 9/9 submit failure (2026-11-04)

**Task:** Investigate and fix `initialize_user` RPC failure when user completes onboarding step 9/9. UI shows `Không thể hoàn tất yêu cầu. Vui lòng thử lại.`

**Status:** `BLOCKED` — Root cause identified but fix requires production database access/migration deployment, which requires explicit owner approval.

**Root cause:** Production onboarding 9/9 is blocked by a production schema/runtime mismatch. Read-only inspection showed that expected initialization capability such as `initialize_user` and `profiles.timezone` was absent. The exact unapplied migration set has not yet been established.

**Local verification:** PGlite + all 10 migrations → `initialize_user` PASS (onboarding completes, idempotent retry returns "Onboarding already complete").

**Production verification:** `NOT RUN` — no production Supabase access.

**Blockers:** No production Supabase access; `supabase db push`/remote migration requires explicit owner approval per AGENTS.md §0.3/§8.

**Next action:** Owner to verify production database schema and approve migration deployment if missing.

---

## Next implementation phase — P1: OpenGym Parity Baseline + Legal-Safe Exercise Catalogue

**Status:** `NOT STARTED`

**Scope:**
- Full OpenGym feature parity inventory; classify GymLvl capability: existing / partial / missing / deferred / license-excluded
- Build/import the legal-safe ExerciseDB-derived exercise catalogue (~1,324 MIT-covered source exercises)
- Preserve current GymLvl exercise UUID/history; provenance; idempotent import; no proprietary media
- Integrate larger catalogue with current GymLvl search/filter/detail

**Constraints:**
- No AGPL code/catalogue-text/media reuse without legal decision
- No commit/push/tag/deploy without explicit owner approval
- No production database migration

**Do NOT start:** M6/AI PT, P2–P8, production migration, release hardening.

---

## Do not do (constraints)

- Do not continue automatically to old M6 merely because previous documents say M6 is next.
- AI PT is not the immediate next implementation stage.
- No product implementation in P0.
- No production deployment, database migration, or remote Supabase changes.
- No third-party exercise media.
