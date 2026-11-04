# GymLvl — Master Plan Index

**Document status:** Active control document
**Established:** 2026-10-28
**Baseline:** branch `main` (sole development branch), `planning_rebase_base_head` `da21eb7` (2026-11-05; mutable GymLvl SHA — re-verify with `git rev-parse HEAD` each session)
**Original product plan:** [`GymLvl_OpenGym_Migration_Master_Plan.md`](GymLvl_OpenGym_Migration_Master_Plan.md) (version 1.0, 27/10/2026) — preserved verbatim, do not overwrite.

## 1. How to read this file

The original master plan remains the authoritative statement of **product vision, scope, and non-negotiable decisions**. It is preserved unchanged.

This file is the **execution index**:

- It records the current phase order and status.
- It resolves stale facts identified by the M0 audit (see §6).
- It defines the next proposed task at a granularity the original plan does not.

If this index and the original plan disagree on **vision**, the original wins. If they disagree on **current facts or execution order**, this file plus `DECISIONS.md` win, and the difference must be listed in §6.

## 2. Non-negotiable product decisions

These are inherited from the original plan and remain fixed:

1. **Mobile-first** Android and iOS.
2. **Flutter + Dart + Riverpod + GoRouter + Supabase/PostgreSQL/Edge Functions.**
3. Preserve **RPG classes A–F, multi-class, synergy, XP, levels, quests, streaks**, and all existing user data and workout history.
4. Preserve **Bold Candy Neubrutalism**: off-white `#FDF9F0`, ink `#111111`, hot pink `#FF3D81`, yellow `#FFD23F`, mint `#3DDC97`, lilac `#C8A2FF`, coral `#FF6B5E`; Archivo Black, Space Grotesk, Space Mono.
5. **Do not adopt OpenGym UI styling.**
6. **No third-party exercise media** — no images, GIFs, animations, video, or media licensing work.
7. **No AGPL code reuse.** OpenGym is a behavioral reference only.
8. **Core workouts work without AI.** AI proposes; the user approves; the server applies.
9. **PostgreSQL is authoritative for XP and rewards.** The client may preview only.
10. **No commit, push, tag, deploy, or production DB change without explicit approval.**

## 3. Product destination

The real GymLvl product direction is:

> GymLvl should use OpenGym as the comprehensive reference for fitness functionality and data structures, migrate/reimplement as much useful functionality as legally and technically practical into the existing GymLvl Flutter/Supabase architecture, replace OpenGym's visual experience with GymLvl's Candy Neubrutalism design, and deeply integrate GymLvl's RPG systems so training feels like both a serious workout app and an engaging game.

GymLvl is NOT intended to evolve as an unrelated custom fitness tracker where isolated features are invented one milestone at a time.

The target is conceptually:

`OpenGym fitness capability`
+
`GymLvl architecture`
+
`GymLvl Candy UI`
+
`GymLvl RPG / progression / quests / levels`
+
`AI PT later`

## 4. Current phase and status

| Phase | Scope | Status |
|---|---|---|
| **P0** | Planning Rebase & Context Consolidation (this task) | **COMPLETE** — accurate truth established, contradictions removed, one canonical roadmap |
| **P1** | OpenGym Parity Baseline + Legal-Safe Exercise Catalogue | **NEXT** — not started |
| **P2** | Routine & Planning Parity | Planned |
| **P3** | Workout Core Parity | Planned |
| **P4** | Progress / Analytics / Utility Parity | Planned |
| **P5** | Deep GymLvl Game Integration | Planned |
| **P6** | AI Personal Trainer | Planned (after P1–P5) |
| **P7** | Media, Optional Integrations & Expansion | Deferred (legal authorization required) |
| **P8** | Release Hardening | Planned (after product core complete) |

**Critical path:** P0 → P1 → P2 → P3 → P4 → P5 → P6 → P8.
P7 must never block P8.

**Do NOT continue automatically to old M6 merely because previous documents say M6 is next. AI PT is not the immediate next implementation stage.**

## 5. Foundation work already completed (pre-parity)

M1–M5 work implemented before the OpenGym parity migration track must NOT be discarded. It is considered **foundation work already completed**. Summary by capability (see `PROJECT_CONTEXT.md` §4 for evidence):

| Capability | Status | Evidence |
|---|---|---|
| Architecture/Foundation | COMPLETE | Flutter 3.38.5, Riverpod, GoRouter, Supabase, Edge Functions, Candy UI |
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

## 6. Corrections to the original plan

| Original claim | Current verified fact | Handling |
|---|---|---|
| OpenGym B catalogue is 5,632 exercises | 6,554 exercises at `e6a95c28`; 17 translations, 13,109 media files | Use 6,554 in planning; media remains prohibited |
| M0 is "baseline, protect Antigravity work, legal inventory" | M0 was executed as an audit/planning milestone; no application changes | Recorded in `M0_AUDIT.md` |
| M1 is design-system foundation | Already implemented and verified | M1 re-baselined to Exercise Catalogue under D-038 |
| Workspace may be dirty and unpushed | Consolidated into `main`; `planning_rebase_base_head` `da21eb7` at P0 audit (mutable; re-verify each session) | Use `main` as sole branch |
| Next milestone is M6 (AI PT) | Foundation M1–M5 complete; parity gap remains | Next is P1 (OpenGym parity baseline), not M6 |
| `GYMLVL_OPENGYM_MIGRATION_MASTER_PLAN.md` | Actual file is `GymLvl_OpenGym_Migration_Master_Plan.md` | Path corrected here |

## 7. Out of scope until separately authorized

- Exercise images, GIFs, animations, video, thumbnails, or any media licensing/procurement.
- AGPL adoption or code/catalogue-text reuse.
- Camera form analysis, autonomous load changes, social PvP, wearables, HealthKit/Health Connect, nutrition diagnosis.
- Production deployment, database migration, or remote Supabase changes.
- Commits, pushes, or tags without approval.

## 8. Change control

- Phase/scope changes require an entry in `DECISIONS.md` and user approval.
- Task status changes require an update to `TASK_BOARD.md`.
- Every checkpoint requires an update to `SESSION_HANDOFF.md` and `CHANGELOG_AI.md`.
- The original plan is never edited. If it becomes obsolete, mark it superseded here and preserve the file.

## 9. Canonical documents

| File | Purpose |
|---|---|
| `docs/planning/MASTER_PLAN.md` | This file — one authoritative active roadmap |
| `docs/planning/PROJECT_CONTEXT.md` | Durable project memory for a new session |
| `docs/planning/TASK_BOARD.md` | Current execution state only |
| `docs/planning/SESSION_HANDOFF.md` | Fast restart context for the next session |
| `docs/planning/CHANGELOG_AI.md` | Chronological history |
| `docs/planning/DECISIONS.md` | Durable architecture/product/license decisions |
| `docs/planning/UPSTREAM_SOURCE_MANIFEST.json` | Immutable external source pins and licenses |
| `docs/planning/OPENGYM_PARITY_MATRIX.md` | Empty/initial tracking framework for P1 (no detailed audit yet) |

## 10. Historical milestone reports (preserved)

Root reports `M0_FINAL_REPORT.md` through `M5_FINAL_REPORT.md` and detailed M3.x reports are historical evidence. They explain what foundation work was already built. Do not delete them. Their old "next milestone" instructions are no longer current authority — this `MASTER_PLAN.md` and `DECISIONS.md` govern.
