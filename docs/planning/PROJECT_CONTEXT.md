# GymLvl — Project Context

**Status:** Durable project memory
**Last verified:** 2026-11-13, before the post-P9 documentation/CI edit, at `main` `13c2744121aa4267f689526081813eb87351e5a0`
**Historical P0 baseline:** `planning_rebase_base_head` `da21eb742aeac1266a3aa1df9d043ec2602a843f`; this is not current HEAD.
**Remote:** `git ls-remote origin refs/heads/main` matched local `main` at `13c2744121aa4267f689526081813eb87351e5a0` before this task.
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

## 2. Repository and current state

| Item | Value |
|---|---|
| Repository | `https://github.com/Tuandaca/gymlvl` |
| Development branch | `main` (only) |
| Pre-task HEAD | `13c2744121aa4267f689526081813eb87351e5a0` on `main`; run `git rev-parse HEAD` for the current value |
| Remote at pre-task check | `origin/main` matched `13c2744121aa4267f689526081813eb87351e5a0` via `git ls-remote` |
| Tags | None |
| Working tree at pre-task check | **Dirty** — 46 collapsed status paths / 79 individual files of preserved owner work. Verified external backup: `D:\Projects\gymlvl_postp9_truth_backup_20261113`. This is a snapshot, not a live count. |
| `.gitignore` protects | `app/config.local.json` (never committed) |

**Implementation state:** P0–P8 are complete in committed history. P9.0–P9.6 were published in `db4bb6a61641c5010da4c4da27fa49f9bfdb6ef8`; the documentation follow-up is `13c2744121aa4267f689526081813eb87351e5a0`. Both commits passed remote CI. P9 production migrations and live Auth/gateway/schema validation have not run. Earlier P8 production remediation was performed; its result must not be conflated with P9 production parity. See `MASTER_PLAN.md` and `TASK_BOARD.md` for the current gate.

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
| Exercise Catalogue | IMPLEMENTED, bounded | 150 curated exercises, search/filter/detail and owner-scoped custom definitions; the 1,324-record MIT import pipeline exists but its dataset assertion gate remains open and the bulk import has not been applied to production |
| Workout Core | IMPLEMENTED locally; P9 live parity gated | Workout logging, active session, sets, timer and history; P9 atomic mutations and import contracts are published but their new RPCs are not deployed to production |
| Offline | PARTIAL (local/test only) | Drift store, encrypted payload, sync coordinator — production gate closed |
| Progression / RPG | IMPLEMENTED in P0–P9 track | Epley 1RM, PR, RPE/RIR, classes A–F, XP, quests, streaks and P9 class/unlock corrections; PostgreSQL remains reward authority, with P9 live validation pending |
| Planning / analytics / bodyweight | IMPLEMENTED in P0–P9 track | Routines, plans, trends and import/export paths have local/CI verification; production parity for new P9 paths is unverified |
| AI Coach | IMPLEMENTED as advisory text | P6/P9 server-owned context, explicit per-request consent and bounded egress; no validated structured apply/revert or live provider verification is claimed |
| OpenGym parity | BOUNDED IMPLEMENTATION COMPLETE | P1–P7 scope is recorded in `MASTER_PLAN.md`; third-party media remains excluded and the bulk dataset import is still gated |
| Production | P8 REMEDIATED; P9 NOT DEPLOYED | Earlier P8 production remediation was performed. P9 migrations, new RPCs and live Auth/gateway/schema parity need a separately authorized preflight and validation |
| Release readiness | NOT VERIFIED | P8 release hardening, Android debug build and manifest CI exist; signed release, iOS/device smoke and legal owner inputs remain separate gates |

The older 17-table / 10-migration / 7-function counts were a P0 snapshot, not the post-P9 inventory. The versioned files under `supabase/migrations/` and `supabase/functions/` own the current source inventory; deployed production state must be checked separately.

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

## 8. Current production boundary

- P8 production remediation was performed before P9; the older missing-`initialize_user`/`profiles.timezone` onboarding diagnosis is historical, not a current production claim.
- P9 migrations and live parity checks are **NOT RUN**. Do not run `supabase db push`, deploy Edge Functions, or infer live P9 behavior from local/CI tests without separate authorization and preflight.
- Production offline sync, Superset and workout-mode gates remain closed. The next gated task is P9 production preflight/live-parity validation, not automatic P10 implementation.

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
