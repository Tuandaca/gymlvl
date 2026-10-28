# GymLvl — Task Board

**Last updated:** 2026-10-28 (S3 validation and checkpoint)
**Baseline:** branch `main` @ `b4063c6` at the start of S3. `main` is the only development branch.
**Working tree:** clean after the S3 checkpoint commit, which carries the S1/S2/S3 infrastructure.
**Current milestone:** M1 — NOT STARTED (unchanged)
**Next task (tooling track):** **S4 — Wave 2 skill import** (`PLANNED`, requires explicit approval)
**Next product task:** **M1-01 — Baseline stabilization and evidence lock** (`NEXT`, unchanged; not
authorized yet)
**Rule:** Only a task marked `NEXT` may be started, and only after explicit user go-ahead. The two
tracks are independent: S3 does not authorize M1, and M1-01 does not authorize S3. Do not bundle tasks.

## Status legend

| Status | Meaning |
|---|---|
| `DONE` | Acceptance criteria met; evidence recorded in this session. |
| `NEXT` | Proposed next task; ready, but requires explicit user go-ahead to start. |
| `READY` | Prerequisites met, but not authorized until the prior task closes. |
| `PLANNED` | Scoped but not yet ready. |
| `BLOCKED` | Cannot proceed; exact blocker recorded. |
| `NOT AUTHORIZED` | Explicitly out of scope until approval. |

## Milestones

| Milestone | Scope | Status |
|---|---|---|
| M0 | Audit, reference analysis, migration plan, license inventory | `DONE` (reported; planning only) |
| M1 | Release-critical baseline stabilization | `NEXT` — starts with M1-01 |
| M2 | MIT catalog import + schema/provenance + search/cache | `PLANNED` |
| M3 | Offline-first workout core, modes, timers, supersets | `PLANNED` |
| M4 | Progression, 1RM/PR, RPE/RIR, RPG bridge | `PLANNED` |
| M5 | Weekly plans, analytics, bodyweight, novice journey | `PLANNED` |
| M6 | AI PT v1: intake, proposals, apply/revert, audit | `PLANNED` |
| M7 | Licensed media | `NOT AUTHORIZED` |
| M8 | iOS/Android release hardening | `PLANNED` |
| M9 | Optional expansion | `NOT AUTHORIZED` |

## Agent system bootstrap (tooling track, parallel to M1)

Not a product milestone. It configures development tooling only and changes no application code,
schema, dependency, or design. Full record in `docs/agent-system/WAVE1_IMPLEMENTATION.md`.

| ID | Task | Status | Evidence |
|---|---|---|---|
| S1 | Skill library discovery and selection | `DONE` | `SOURCE_AUDIT.md`, `SKILL_SELECTION.md`, `AGENT_SKILL_MATRIX.md`, `S2_IMPLEMENTATION_PLAN.md` |
| S2 | Wave 1 configuration and skill integration | `DONE` | 7 agents, 6 skills, 6 commands, `.opencode/opencode.jsonc`; V1–V8 recorded |
| S3 | Validation and optimization on one real task | `DONE` | `S3_VALIDATION_REPORT.md` — 7 agents, 6 skills validated; 5 delegation tests; regression 126/10/15 |
| S4 | Wave 2 import (remaining 14 skills) | `PLANNED` | Requires approval; ordered list in `S3_VALIDATION_REPORT.md` §9 |

**S3 notes.** Agent discovery, permissions, read-only enforcement, skills, commands and delegation
were verified at runtime. Two product findings were documented, not patched: a potential deadlock in
`active_workout_controller.dart` (L4) and the legacy award path in `complete_workout` (L5). Operational
rule recorded: run shell-dependent subagents sequentially (D-021).

**S4 next action.** Not authorized. When approved, start with `context-management-context-save`, after
mapping its storage model onto the nine memory files.

## M1 task table

| ID | Task | Status | Depends on | Owner |
|---|---|---|---|---|
| M1-01 | Baseline stabilization and evidence lock | **NEXT** | Bootstrap complete | Lead |
| M1-02 | Android/iOS release config | `PLANNED` | M1-01 | Platform |
| M1-03 | Typography cleanup + Vietnamese fallback | `PLANNED` | M1-01 | Design |
| M1-04 | Documentation truth pass | `PLANNED` | M1-01, M1-02, M1-03 | Docs |
| M1-05 | CI Android static build + config regression test | `PLANNED` | M1-02 | QA |
| M1-06 | Rendered baseline screenshots | `PLANNED` | M1-02, M1-03 | QA |

---

## M1-01 — Baseline stabilization and evidence lock

**Status:** `NEXT` — proposed, not started. Requires explicit user go-ahead.
**Goal:** make the baseline reproducible and trustworthy before any release or feature change.
**Type:** documentation and verification only.

### Scope

1. Verify the external backup bundle/archive and record its hashes.
2. Confirm HEAD, branch, and remote refs, and that the working tree is clean on `main`.
3. Create/refresh `docs/planning/UPSTREAM_SOURCE_MANIFEST.json` pinning:
   - GymLvl baseline SHA,
   - `emilfunk/opengym` SHA + AGPL,
   - `DuarteSantos8/openGym` SHA + AGPL,
   - `hasaneyldrm/exercises-dataset` SHA + MIT text-only/media-excluded,
   - the exact retrieval date and source URLs.
4. Create/refresh `docs/planning/LICENSE_LEDGER.csv` based on
   `docs/planning/GymLvl_License_Ledger_Starter.csv`. Include GymLvl's missing LICENSE as an open
   item.
5. Produce `docs/planning/BASELINE_REPORT.md` containing:
   - exact commands and outputs,
   - commit/branch/remote refs,
   - conflict register,
   - test matrix with `PASS`/`FAIL`/`BLOCKED`/`NOT RUN`.
6. Propose a checkpoint tag name (e.g. `checkpoint/m1-01-baseline`) and **wait for approval**.

### Acceptance criteria

- [ ] Backup SHA-256 values match the recorded manifest.
- [ ] A fresh clone from the backup bundle has HEAD equal to the HEAD recorded for that backup
      (the 2026-10-28 pre-consolidation bundle records `56c1122`).
- [ ] Archive file count equals the Git tree count at the backup's recorded HEAD.
- [ ] All nine memory files are mutually consistent.
- [ ] `flutter analyze` → 0 issues.
- [ ] `flutter test` → 126/126.
- [ ] `cd tools/db-tests; npm test` → 10/10.
- [ ] `cd tools/db-tests; npm run test:edge` → 15/15.
- [ ] `dart format --output=none --set-exit-if-changed lib test` → 0 changed.
- [ ] `git status --porcelain=v1` is empty on `main`.
- [ ] Conflict register covers every known documentation contradiction.
- [ ] Tag decision is recorded (approved or deferred).
- [ ] `TASK_BOARD.md`, `SESSION_HANDOFF.md`, `CHANGELOG_AI.md` updated.

### Forbidden

Application code, SQL, Supabase functions, CI, dependencies, catalog import, media, UI changes,
commits, pushes, tags, and deployment.

### Known blockers

None for M1-01 on this host. Android SDK/device availability affects M1-02/M1-05, not M1-01.

---

## M1-02 — Android/iOS release config (planned)

**Goal:** release builds can reach Supabase and present the correct app identity.

- Add `android.permission.INTERNET` to the **main** manifest.
- Set Android `android:label="GymLvl"`.
- Set iOS `CFBundleDisplayName` to `GymLvl` and `CFBundleName` to `GymLvl`.
- Verify the merged release manifest, not just the source file.
- Do not touch `app/lib/**` or `supabase/**`.

**Acceptance:** merged release manifest contains INTERNET; labels are correct; existing tests still
pass. If `flutter build apk` cannot run, report `BLOCKED` with the exact toolchain prerequisite.

## M1-03 — Typography cleanup (planned)

**Goal:** remove the stale Orbitron declaration and make Vietnamese fallback explicit.

- Remove the `Orbitron` family and asset declaration from `app/pubspec.yaml`.
- Remove `OrbitronVariable.ttf` and `Orbitron-OFL.txt` only after confirming no runtime reference.
- Update `SOURCES.md` to match.
- Add an explicit Vietnamese-capable fallback strategy in `candy_theme.dart`.
- Verify `grep -R Orbitron app/lib app/pubspec.yaml` returns nothing.
- Render VI/EN at 320/390/768/1440 and check diacritics/overflow.

## M1-04 — Documentation truth pass (planned)

**Goal:** make status documents match executed evidence.

- Reconcile `PROJECT.md`, `docs/IMPLEMENTATION_STATUS.md`, `TEST_READY.md`, `TEST_INFRA.md`,
  `docs/ARCHITECTURE.md`.
- Replace stale test counts, font claims, and milestone tables with verified facts.
- Link to `docs/planning/` as the canonical process layer.
- Do not rewrite history; mark superseded sections.

## M1-05 — CI Android static build + config regression test (planned)

**Goal:** prevent release-config regressions.

- Add an Android build job or static manifest assertion to `.github/workflows/verify.yml`.
- Add `app/test/release_config_test.dart` asserting INTERNET permission and app labels.
- Keep the existing SQL/Edge/Flutter jobs green.
- Report if the runner lacks the Android SDK; do not fake a build.

## M1-06 — Rendered baseline screenshots (planned)

**Goal:** capture a reviewable visual baseline.

- Add or refresh screenshots under `docs/verification/ui/`.
- Cover dashboard, workout, completion, quests, profile, onboarding at 320/390/768/1440, VI + EN.
- No source changes.

---

## Blocked / not authorized

| Item | Status | Reason |
|---|---|---|
| Android release APK build | `BLOCKED` (unverified) | Android SDK/licences and device availability not confirmed on this host |
| iOS build/archive | `BLOCKED` | Windows host; requires macOS/Xcode |
| Live Supabase verification | `BLOCKED` | No approved live project/credentials used |
| Live AI provider verification | `BLOCKED` | Not in scope; no credentials used |
| Catalog import | `NOT AUTHORIZED` | M2; requires M1 and license ledger |
| Media work | `NOT AUTHORIZED` | Explicitly postponed |
| AGPL reuse | `NOT AUTHORIZED` | Requires legal decision |
| Commit/push/tag without approval | `NOT AUTHORIZED` | Default policy; the 2026-10-28 consolidation was explicitly authorized |
| Production deployment | `NOT AUTHORIZED` | No approval |

## Work log

| Date | Task | Result | Evidence |
|---|---|---|---|
| 2026-10-27/28 | M0 audit | `DONE` (reported) | Chat transcript; reconstructed in `M0_AUDIT.md` |
| 2026-10-28 | Persistent context bootstrap | `DONE` | Nine memory files created; baseline suites re-run at `56c1122` |
| 2026-10-28 | Main consolidation + main-only workflow | `DONE` | Fast-forward `e003803..17ca562`; memory files committed; suites 126/10/15 `PASS`; docs updated |
