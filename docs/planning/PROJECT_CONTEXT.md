# GymLvl — Project Context

**Status:** Durable project memory
**Last verified:** 2026-11-05
**Baseline:** branch `main` (sole development branch), `planning_rebase_base_head` `da21eb742aeac1266a3aa1df9d043ec2602a843f` (GymLvl HEAD at P0 audit time; mutable — re-verify with `git rev-parse HEAD` each session)
**Remote:** `origin/main` == local `main` (verified at P0 audit time; re-verify with `git rev-parse origin/main` each session)
**Owner:** GymLvl project

This file answers: what is GymLvl, what is true now, what must not change, and which source wins when documents disagree. It is intentionally model-independent.

---

## 1. Product

GymLvl is a **mobile-first fitness RPG** for Android and iOS. It combines structured workout tracking with an RPG progression layer:

- Six classes (`A`–`F`), primary and secondary class selection, class synergy.
- XP, levels, quests, streaks, achievements.
- Workout logging with exercises, sets, weight, reps, duration, and completion.
- Vietnamese and English UI.

The product direction is to add credible training capabilities — a deeper exercise catalog, weekly plans, offline logging, progression intelligence, analytics, and an approval-based AI personal trainer — **without** losing the RPG identity or the existing user history.

GymLvl should use OpenGym as the comprehensive reference for fitness functionality and data structures, migrate/reimplement as much useful functionality as legally and technically practical into the existing GymLvl Flutter/Supabase architecture, replace OpenGym's visual experience with GymLvl's Candy Neubrutalism design, and deeply integrate GymLvl's RPG systems.

---

## 2. Repository and current baseline

| Item | Value |
|---|---|
| Repository | `https://github.com/Tuandaca/gymlvl` |
| Development branch | `main` (only) |
| `planning_rebase_base_head` | `da21eb742aeac1266a3aa1df9d043ec2602a843f` (mutable; re-verify each session) |
| Remote | `origin/main` == local `main` |
| Tags | None |
| Working tree | **Dirty** — pre-existing M3/M4 work preserved (6 modified tracked files, 10 untracked files); no source/application changes made in P0 |
| `.gitignore` protects | `app/config.local.json` (never committed) |

---

## 3. Technology stack

| Layer | Technology |
|---|---|
| Client | Flutter 3.38.5, Dart 3.10.4 |
| State | Riverpod 3.x (Notifier-based) |
| Routing | GoRouter 17.x |
| Models | Freezed 3 + JSON serialization |
| Backend | Supabase: Auth, PostgreSQL, PostgREST, Edge Functions (Deno) |
| Local persistence | Drift/SQLite store (M3, local/test only; production gate closed) + `shared_preferences` for settings |
| Charts | `fl_chart` |
| UI system | Bold Candy Neubrutalism (custom `Candy*` primitives) |
| Tests | Flutter test, PGlite/PostgreSQL SQL harness, Deno edge tests |

---

## 4. What is implemented (evidence-based)

| Capability | Status | Evidence |
|---|---|---|
| Architecture/Foundation | COMPLETE | `app/lib/`, `supabase/migrations/`, `supabase/functions/` |
| Exercise Catalogue | STRONG PARTIAL | 150 curated exercises, search/filter, detail screen |
| Workout Core | STRONG PARTIAL | Workout logging, active session, sets, rest timer, history, modes, supersets |
| Offline | PARTIAL (local/test only) | Drift store, encrypted payload, sync coordinator — production gate closed |
| Progression | PARTIAL | Epley 1RM, PR detection, RPE/RIR, RPG bridge — server authority preserved |
| RPG | PARTIAL | Classes A–F, XP, levels, quests, streaks |
| Planning | PARTIAL | First-Week plan, newcomer journey |
| Analytics | PARTIAL | Heatmap, weight trend, PR chart, muscle balance |
| Bodyweight | PARTIAL | Weigh-in trend, external-load semantics |
| AI | NOT STARTED | Chat-only proxy, no typed proposals/approval/apply-revert |
| OpenGym parity | NOT STARTED | No catalogue import, no routine/planning parity |
| Production activation | BLOCKED | No production DB access; onboarding 9/9 blocked by production schema/runtime mismatch (read-only inspection showed expected initialization capability such as `initialize_user` and `profiles.timezone` was absent; exact unapplied migration set not yet established) |
| Release readiness | NOT STARTED | No Android/iOS release build, signing keys absent |

**17 tables:** `users`, `profiles`, `exercises`, `workouts`, `workout_exercises`, `workout_sets`, `xp_logs`, `streaks`, `exercise_prs`, `quests`, `quest_instances`, `user_classes`, `class_definitions`, `class_synergies`, `workout_rewards`, `user_achievements`, `coach_daily_usage`.

**10 migrations:** baseline, authoritative_progression, exercise_catalog_metadata, effective_progression_acl, prevent_legacy_double_award, m3_offline_foundation, m3_superset_modes, m4_progression_rpe_rir, m5_analytics_indexes, m5_bodyweight_measurements.

**7 Edge Functions:** ai-coach, calculate-xp, get-user-stats, initialize-user, switch-class, sync-daily-data.

`complete_workout` is the authoritative completion/reward path: transactional, row-locked, idempotent via `workout_rewards`, with suspicious-pace clamping. Clients cannot write XP, levels, streaks, quests, or PRs.

---

## 5. Reference sources and their status

| Source | Pinned revision | License | Permitted use |
|---|---|---|---|
| `DuarteSantos8/openGym` (B) | `e6a95c28a6e3067bdd9b1188d5f37f448d528bd2` | AGPL-3.0 | Behavioral reference only; no code/text/assets |
| `hasaneyldrm/exercises-dataset` (C) | `7455efae41b330c265e7cd4b78dfa848e7ce5ebd` | MIT for text/data; media excluded | Import text/metadata only, with notice; strip media |
| Gym visual media | — | Proprietary | **Not licensed.** Do not use. |

Current OpenGym B catalogue count is **6,554** exercises (not 5,632). It has 17 translation files and 13,109 media files. No media may be imported.

---

## 6. Source precedence

When documents disagree, use this order:

1. **Executed verification at the current commit** (commands and output).
2. `docs/planning/DECISIONS.md` — accepted decisions.
3. `docs/planning/MASTER_PLAN.md` — active roadmap.
4. `docs/planning/PROJECT_CONTEXT.md` — this file.
5. `docs/planning/TASK_BOARD.md` and `SESSION_HANDOFF.md` — current work state.
6. `docs/planning/M0_AUDIT.md` — audit findings.
7. `docs/planning/GymLvl_OpenGym_Migration_Master_Plan.md` — original product vision (preserved, not edited).
8. Other docs — historical/stale; several claims are outdated.

Never resolve a conflict by silently editing the lower-precedence document. Record it in `DECISIONS.md` or the conflict register in `M0_AUDIT.md`.

---

## 7. Hard constraints

- Preserve Flutter/Dart/Riverpod/GoRouter/Supabase/PostgreSQL/Edge Functions.
- Preserve classes A–F, multi-class, synergy, XP, quests, streaks, and all user history.
- Preserve Bold Candy Neubrutalism tokens and primitives.
- Core workouts must work without AI.
- AI never awards XP or mutates completed workouts.
- No third-party exercise media, ever, until a written license is approved.
- No AGPL code, prompts, catalogue text, or assets without a legal decision.
- No commit, push, tag, deploy, or production database change without explicit approval.

---

## 8. Current production restrictions (recorded clearly)

- **Do NOT deploy production migrations.**
- **Do NOT run production `supabase db push`.**
- **Do NOT treat onboarding production failure as a reason to deploy.**
- **Do NOT start release hardening.**
- Production onboarding 9/9 is currently blocked by a production schema/runtime mismatch. Read-only inspection showed that expected initialization capability such as `initialize_user` and `profiles.timezone` was absent. The exact unapplied migration set has not yet been established.
- This is a known production-environment blocker, not the current implementation task. The owner is currently testing UI. Do not deploy migrations or run `supabase db push` unless explicitly requested later.

---

## 9. Where to look

| Need | File |
|---|---|
| Current task and next action | `docs/planning/TASK_BOARD.md`, `docs/planning/SESSION_HANDOFF.md` |
| Active roadmap | `docs/planning/MASTER_PLAN.md` |
| Decisions | `docs/planning/DECISIONS.md` |
| Runtime and target design | `docs/planning/ARCHITECTURE.md` |
| Audit evidence and defects | `docs/planning/M0_AUDIT.md` |
| External source pins | `docs/planning/UPSTREAM_SOURCE_MANIFEST.json` |
| Chronological history | `docs/planning/CHANGELOG_AI.md` |
| Original product plan | `docs/planning/GymLvl_OpenGym_Migration_Master_Plan.md` |
| Existing runtime documentation | `docs/ARCHITECTURE.md` |
| License starter | `docs/planning/GymLvl_License_Ledger_Starter.csv` |
