# GymLvl — Project Context

**Status:** Durable project memory
**Last verified:** 2026-10-28
**Baseline:** branch `main` (sole development branch), consolidation checkpoint `17ca562`
(full SHA `17ca562f7d382cdd16e17a414460b8266edcf16b`)
**Owner:** GymLvl project

This file answers: what is GymLvl, what is true now, what must not change, and which source wins
when documents disagree. It is intentionally model-independent.

---

## 1. Product

GymLvl is a **mobile-first fitness RPG** for Android and iOS. It combines structured workout
tracking with an RPG progression layer:

- Six classes (`A`–`F`), primary and secondary class selection, class synergy.
- XP, levels, quests, streaks, achievements.
- Workout logging with exercises, sets, weight, reps, duration, and completion.
- Vietnamese and English UI.

The product direction is to add credible training capabilities — a deeper exercise catalog, weekly
plans, offline logging, progression intelligence, analytics, and an approval-based AI personal
trainer — **without** losing the RPG identity or the existing user history.

## 2. Repository and current baseline

| Item | Value |
|---|---|
| Repository | `https://github.com/Tuandaca/gymlvl` |
| Development branch | `main` (only) |
| Consolidation checkpoint | `17ca562f7d382cdd16e17a414460b8266edcf16b` (`17ca562`) |
| Previous `main` | `e0038038300d5bfaf3c4747094cf36a132eb8711` (`e003803`) |
| Remote branch | `origin/main` — pushed and verified at the checkpoint (via `git ls-remote`) |
| Retained branch | `codex/supabase-product-audit` = `17ca562` (read-only provenance) |
| Working tree at baseline | Clean (verified 2026-10-28) |
| Tags | None |
| Tracked files at HEAD | 511 |

**Important:** the M0 audit observed 166 dirty entries on top of `e003803`. Between sessions that
work was committed as `56c1122` ("feat: add core workout features, Supabase backend functions, and
end-to-end testing infrastructure": 381 files, +33,198/−8,080) and pushed to
`origin/codex/supabase-product-audit`. The actor and exact timing of that commit are not verified.
On 2026-10-28 all work was consolidated into `main` at `17ca562` (fast-forward; D-014). All current
work starts from `main`.

## 3. Technology stack

| Layer | Technology |
|---|---|
| Client | Flutter 3.38.5, Dart 3.10.4 |
| State | Riverpod 3.x (Notifier-based) |
| Routing | GoRouter 17.x |
| Models | Freezed 3 + JSON serialization |
| Backend | Supabase: Auth, PostgreSQL, PostgREST, Edge Functions (Deno) |
| Local persistence | `shared_preferences` only (active-workout backup, preferences) |
| Charts | `fl_chart` |
| UI system | Bold Candy Neubrutalism (custom `Candy*` primitives) |
| Tests | Flutter test, PGlite/PostgreSQL SQL harness, Deno edge tests |

There is **no local SQL database**, no sync outbox, and no offline mutation queue today. Offline
behavior is limited to a local active-workout snapshot; set mutations still require the network.

## 4. Verified baseline evidence (2026-10-28, `main` @ `17ca562`)

These checks were re-executed during the consolidation session; the same suites passed at `56c1122`
in the bootstrap session:

| Check | Command | Result |
|---|---|---|
| Static analysis | `cd app; flutter analyze` | `PASS` — 0 issues |
| Formatting | `cd app; dart format --output=none --set-exit-if-changed lib test` | `PASS` — 125 files, 0 changed |
| Flutter tests | `cd app; flutter test` | `PASS` — 126/126 |
| SQL regression | `cd tools/db-tests; npm test` | `PASS` — 10/10 units, PostgreSQL 17.5 via PGlite |
| Edge tests | `cd tools/db-tests; npm run test:edge` | `PASS` — 15/15 Deno tests |
| Exercise catalog | SQL harness assertion | `PASS` — 150 exercises, 0 null/empty metadata |
| Git state | `git status --porcelain=v1` | Clean, 0 entries |

Limitations: the SQL harness is a single-connection PGlite instance, not a full Supabase stack.
Android/iOS release builds, device smoke tests, live Supabase, and live AI providers were **not run**
in this session.

## 5. Backend facts

- 17 tables: `users`, `profiles`, `exercises`, `workouts`, `workout_exercises`, `workout_sets`,
  `xp_logs`, `streaks`, `exercise_prs`, `quests`, `quest_instances`, `user_classes`,
  `class_definitions`, `class_synergies`, `workout_rewards`, `user_achievements`,
  `coach_daily_usage`.
- Migrations:
  - `20261026000100_baseline.sql` (661 lines)
  - `20261026000200_authoritative_progression.sql` (349 lines)
  - `20261027000100_exercise_catalog_metadata.sql` (367 lines)
- `complete_workout` is the authoritative completion/reward path: transactional, row-locked,
  idempotent via `workout_rewards`, with suspicious-pace clamping.
- RLS and grants are hardened. Direct client writes to XP, levels, streaks, quests, and PRs are
  denied.
- The curated catalog contains **150** exercises. Its text provenance is undocumented.
- The AI Coach is currently a **chat-only proxy** (`ai-coach` Edge Function + chat screen). It has
  no typed plan proposal, validation, approval, apply/revert, or consent record.

## 6. Reference sources and their status

| Source | Pinned revision | License | Permitted use |
|---|---|---|---|
| `emilfunk/opengym` (A) | `678bf5bf10446e8997a77d43e89c9b2721d8d0fc` | AGPL-3.0 | Behavioral reference only; no code/text/assets |
| `DuarteSantos8/openGym` (B) | `e6a95c28a6e3067bdd9b1188d5f37f448d528bd2` | AGPL-3.0 + non-transferable app-store exception | Behavioral reference only |
| `hasaneyldrm/exercises-dataset` (C) | `7455efae41b330c265e7cd4b78dfa848e7ce5ebd` | MIT for text/data; media excluded | Import text/metadata only, with notice; strip media |
| Gym visual media | — | Proprietary | **Not licensed.** Do not use. |
| MuscleMap geometry | — | MIT | Optional, with attribution, if used. |

Current OpenGym B catalogue count is **6,554** exercises, not the 5,632 stated in the original master
plan. It has 17 translation files and 13,109 media files. The media count is informational only; no
media may be imported.

## 7. Source precedence

When documents disagree, use this order:

1. **Executed verification at the current commit** (commands and output).
2. `docs/planning/DECISIONS.md` — accepted decisions.
3. `docs/planning/SESSION_HANDOFF.md` and `TASK_BOARD.md` — current work state.
4. `docs/planning/M0_AUDIT.md` — audit findings, with evidence labels.
5. `docs/planning/MASTER_PLAN.md` — milestone index.
6. `docs/planning/GymLvl_OpenGym_Migration_Master_Plan.md` — original product vision (preserved,
   not edited).
7. `PROJECT.md`, `docs/IMPLEMENTATION_STATUS.md`, `TEST_READY.md`, `TEST_INFRA.md` — historical
   status documents; several claims are stale.
8. Any other doc or comment.

Never resolve a conflict by silently editing the lower-precedence document. Record it in
`DECISIONS.md` or the conflict register in `M0_AUDIT.md`.

## 8. Known documentation conflicts

| Conflict | Current truth |
|---|---|
| M0 report says 166 dirty entries / HEAD `e003803` | Work was committed as `56c1122`, consolidated into `main` at `17ca562`; tree is clean. |
| `PROJECT.md` says Orbitron was eliminated | `app/pubspec.yaml` still declares the `Orbitron` family and asset. |
| `TEST_READY.md` says 83 Flutter tests | Actual suite is 126 tests at `56c1122`. |
| `PROJECT.md` milestone table says M2/M5 `IN_PROGRESS` | `docs/IMPLEMENTATION_STATUS.md` says they are complete; the milestone numbering in `PROJECT.md` is a different, older plan. |
| Original master plan says 5,632 OpenGym exercises | Current upstream catalogue is 6,554. |
| M0 report filename `GYMLVL_OPENGYM_MIGRATION_MASTER_PLAN.md` | Actual file is `docs/planning/GymLvl_OpenGym_Migration_Master_Plan.md` (Windows is case-insensitive). |
| Android/iOS display names | Android label is `app`; iOS display name is `App`, bundle name `app`. |
| Android release networking | `android/app/src/main/AndroidManifest.xml` has no `INTERNET` permission; only debug/profile manifests do. |

## 9. Hard constraints

- Preserve Flutter/Dart/Riverpod/GoRouter/Supabase/PostgreSQL/Edge Functions.
- Preserve classes A–F, multi-class, synergy, XP, quests, streaks, and all user history.
- Preserve Bold Candy Neubrutalism: off-white `#FDF9F0`, ink `#111111`, hot pink `#FF3D81`,
  yellow `#FFD23F`, mint `#3DDC97`, lilac `#C8A2FF`, coral `#FF6B5E`; Archivo Black, Space Grotesk,
  Space Mono; 2px ink borders, hard shadows, tactile press states.
- Core workouts must work without AI.
- AI never awards XP or mutates completed workouts.
- No third-party exercise media, ever, until a written license is approved.
- No AGPL code, prompts, catalogue text, or assets without a legal decision.
- No commit, push, tag, deploy, or production database change without explicit approval.

## 10. Glossary

| Term | Meaning |
|---|---|
| M0 | Completed audit/planning milestone (no application changes). |
| M1 | Re-baselined release-critical stabilization milestone; not started. |
| M1-01 | Next proposed task (requires explicit go-ahead): baseline stabilization and evidence lock. |
| Candy | The Bold Candy Neubrutalism design system. |
| Authoritative progression | Server-side `complete_workout` transaction that owns all awards. |
| `main` @ `17ca562` | Current consolidated baseline. `56c1122` is the historical audit-branch checkpoint. |
| AGPL | Copyleft license on both OpenGym repositories; reference-only. |
| MIT text | Exercise metadata/instructions from the dataset; importable with notice. |
| Media | Images/GIFs/videos; all postponed and unlicensed for GymLvl. |

## 11. Where to look

| Need | File |
|---|---|
| Current task and next action | `docs/planning/TASK_BOARD.md`, `docs/planning/SESSION_HANDOFF.md` |
| Audit evidence and defects | `docs/planning/M0_AUDIT.md` |
| Milestones | `docs/planning/MASTER_PLAN.md` |
| Decisions | `docs/planning/DECISIONS.md` |
| Runtime and target design | `docs/planning/ARCHITECTURE.md` |
| Existing runtime documentation | `docs/ARCHITECTURE.md` |
| Implementation status (historical) | `docs/IMPLEMENTATION_STATUS.md` |
| Original product plan | `docs/planning/GymLvl_OpenGym_Migration_Master_Plan.md` |
| License starter | `docs/planning/GymLvl_License_Ledger_Starter.csv` |
