# GymLvl — Master Plan Index

**Document status:** Active control document
**Established:** 2026-10-28
**Baseline:** `56c1122` (`codex/supabase-product-audit`)
**Original product plan:** [`GymLvl_OpenGym_Migration_Master_Plan.md`](GymLvl_OpenGym_Migration_Master_Plan.md)
(version 1.0, 27/10/2026, 31,935 bytes) — **preserved verbatim, do not overwrite.**

## 1. How to read this file

The original master plan remains the authoritative statement of **product vision, scope, and
non-negotiable decisions**. It is preserved unchanged.

This file is the **execution index**:

- It records the current milestone order and status.
- It resolves stale facts identified by the M0 audit (see §6).
- It defines the next proposed task at a granularity the original plan does not.

If this index and the original plan disagree on **vision**, the original wins. If they disagree on
**current facts or execution order**, this file plus `DECISIONS.md` win, and the difference must be
listed in §6.

## 2. Non-negotiable product decisions

These are inherited from the original plan and remain fixed:

1. **Mobile-first** Android and iOS.
2. **Flutter + Dart + Riverpod + GoRouter + Supabase/PostgreSQL/Edge Functions.**
3. Preserve **RPG classes A–F, multi-class, synergy, XP, levels, quests, streaks**, and all existing
   user data and workout history.
4. Preserve **Bold Candy Neubrutalism**: off-white `#FDF9F0`, ink `#111111`, hot pink `#FF3D81`,
   yellow `#FFD23F`, mint `#3DDC97`, lilac `#C8A2FF`, coral `#FF6B5E`; Archivo Black, Space Grotesk,
   Space Mono.
5. **Do not adopt OpenGym UI styling.**
6. **No third-party exercise media** — no images, GIFs, animations, video, or media licensing work.
7. **No AGPL code reuse.** OpenGym is a behavioral reference only.
8. **Core workouts work without AI.** AI proposes; the user approves; the server applies.
9. **PostgreSQL is authoritative for XP and rewards.** The client may preview only.
10. **No commit, push, tag, deploy, or production DB change without explicit approval.**

## 3. Current milestone status

| Milestone | Scope | Depends on | Status |
|---|---|---|---|
| **M0** | Repository audit, reference analysis, migration plan, license inventory | — | **COMPLETE (reported)** — planning only; no app/DB changes |
| **M1** | Release-critical baseline stabilization | M0 | **NOT STARTED** |
| **M2** | MIT exercise catalog import + schema/provenance + search/cache | M1 | Planned |
| **M3** | Offline-first workout core, modes, timers, supersets | M2 | Planned |
| **M4** | Progression, 1RM/PR, RPE/RIR, RPG bridge | M3 | Planned |
| **M5** | Weekly plans/scheduling, analytics, bodyweight, novice journey | M3, M4 | Planned |
| **M6** | AI PT v1: intake, create/review, proposals, apply/revert, audit | M2, M4, M5 | Planned |
| **M7** | Licensed media — **only if explicitly authorized** | Legal approval | Postponed |
| **M8** | iOS/Android release hardening | M1–M6 | Planned |
| **M9** | Optional expansion (imports, Health, watch, larger catalog) | M8 | Not authorized |

**Critical path:** M1 → M2 → M3 → M4 → M5 → M6 → M8.
M7 must never block M8.

## 4. Milestone M1 — re-baselined

The original plan's M1 (Candy foundation, theme cleanup, shell navigation, auth redirect) is already
implemented and verified. Repeating it would waste a milestone. M1 is therefore re-scoped to close
the **release-critical and truth-telling gaps** that block a credible mobile baseline.

**M1 is not one giant task.** It is six independently verifiable tasks. Only **M1-01** is proposed
next; it requires explicit user go-ahead before starting.

| ID | Task | Primary owner | Exclusive files | Status |
|---|---|---|---|---|
| **M1-01** | Baseline stabilization and evidence lock | Lead | `docs/planning/**` only | **NEXT — ready** |
| M1-02 | Android/iOS release config | Platform | `app/android/app/src/main/AndroidManifest.xml`, `app/ios/Runner/Info.plist` | Planned |
| M1-03 | Typography cleanup + Vietnamese fallback | Design | `app/pubspec.yaml`, `app/assets/fonts/Orbitron*`, `app/assets/fonts/SOURCES.md`, `app/lib/core/theme/candy_theme.dart` | Planned |
| M1-04 | Documentation truth pass | Docs | `PROJECT.md`, `docs/IMPLEMENTATION_STATUS.md`, `TEST_READY.md`, `TEST_INFRA.md`, `docs/ARCHITECTURE.md` | Planned |
| M1-05 | CI Android static build + config regression test | QA | `.github/workflows/verify.yml`, `app/test/release_config_test.dart` | Planned |
| M1-06 | Rendered baseline screenshots | QA | `docs/verification/ui/**` | Planned |

### M1-01 — the only proposed next task

**Goal:** make the baseline reproducible and trustworthy before any release or feature change.

**Scope (documentation and verification only):**

1. Verify the external backup bundle/archive and record hashes.
2. Confirm HEAD, branch, and remote refs, and that the only uncommitted files are the expected
   bootstrap planning files.
3. Create/refresh `docs/planning/UPSTREAM_SOURCE_MANIFEST.json` pinning reference SHAs and licenses.
4. Create/refresh `docs/planning/LICENSE_LEDGER.csv` based on the existing starter.
5. Produce `docs/planning/BASELINE_REPORT.md` with commands, results, and a conflict register.
6. Propose a checkpoint tag name and wait for approval. **Do not create the tag automatically.**

**Forbidden:** application code, SQL, Supabase, CI, dependency changes, catalog import, media, UI.

**Acceptance:**

- Backup hashes match the recorded manifest; a clone from the bundle equals HEAD.
- All nine memory files are mutually consistent.
- `flutter analyze` 0 issues; `flutter test` 126/126; `npm test` 10/10; `npm run test:edge` 15/15;
  `dart format` clean.
- Conflict register lists every known contradiction with an owner.
- `git status` shows only the expected planning files.
- The tag decision is recorded (approved or deferred).

**Blockers:** none for M1-01 on this host. Android SDK/device availability is an M1-02/M1-05
blocker, not an M1-01 blocker.

## 5. Milestone exit gates

| Milestone | Exit gate |
|---|---|
| M1 | Release APK manifest has `INTERNET`; app name is GymLvl on both platforms; no Orbitron declaration; docs match evidence; CI builds Android; no media or schema change |
| M2 | 1,324 MIT text records imported; idempotent source-keyed ETL; zero media; existing 150 UUIDs preserved |
| M3 | Offline/reconnect scenarios pass; no lost sets; modes/timers/supersets verified |
| M4 | Golden progression tables; one reward per retried workout; class math reproducible |
| M5 | Beginner completes three workouts from a generated plan; charts reconcile |
| M6 | Invalid IDs/ranges rejected; consent withdrawal blocks egress; AI failure never blocks a workout |
| M7 | Written media rights evidence; release scan clean — **not authorized** |
| M8 | Device matrix, signed artifacts, RLS penetration checks |

## 6. Corrections to the original plan

| Original claim | Current verified fact | Handling |
|---|---|---|
| OpenGym B catalogue is 5,632 exercises | 6,554 exercises at `e6a95c28`; 17 translations, 13,109 media files | Use 6,554 in planning; media remains prohibited |
| M0 is "baseline, protect Antigravity work, legal inventory" | M0 was executed as an audit/planning milestone; no application changes | Recorded in `M0_AUDIT.md` |
| M1 is design-system foundation | Already implemented and verified | M1 re-baselined to stabilization |
| Workspace may be dirty and unpushed | Committed and pushed as `56c1122`; tree clean | Use `56c1122` as baseline |
| `GYMLVL_OPENGYM_MIGRATION_MASTER_PLAN.md` | Actual file is `GymLvl_OpenGym_Migration_Master_Plan.md` | Path corrected here |

## 7. Out of scope until separately authorized

- Exercise images, GIFs, animations, video, thumbnails, or any media licensing/procurement.
- AGPL adoption or code/catalogue-text reuse.
- Camera form analysis, autonomous load changes, social PvP, wearables, HealthKit/Health Connect,
  nutrition diagnosis.
- Production deployment, database migration, or remote Supabase changes.
- Commits, pushes, or tags without approval.

## 8. Change control

- Milestone scope changes require an entry in `DECISIONS.md` and user approval.
- Task status changes require an update to `TASK_BOARD.md`.
- Every checkpoint requires an update to `SESSION_HANDOFF.md` and `CHANGELOG_AI.md`.
- The original plan is never edited. If it becomes obsolete, mark it superseded here and preserve the
  file.
