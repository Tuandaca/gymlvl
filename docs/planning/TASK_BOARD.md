# GymLvl — Task Board

## Current A2 reconciliation checkpoint — PARTIAL (2026-10-28)

**Current task:** A2 only; all 22 leads now have dispositions in A2_FLUTTER section 8.2.
**Findings:** 24 total, P1 3/P2 14/P3 5/P4 2; Confirmed 4/High 18/Medium 2. Seven new IDs,
narrowed CONC001 and SEC002 confirmed scopes; DATA001 still unverified server-side.
**Coverage:** 13 static-reviewed / 5 in review / 8 not reviewed / 1 excluded.
**Evidence:** current analyzer clean, format 125 unchanged, Flutter +126 pass at 7eb40f1.
**Git:** latest user authorizes clearly labeled PARTIAL docs-only normal commit/push. Preserve all
nine artifacts; verified backup ...gymlvl-a2-final-backup-20261028-174845. No history rewrite.
**Remaining task / next action:** A2 lead10 synthetic auth/recovery widget probe, QA, final closure
assessment and exact A3 handoff. A3-A6 and remediation remain unauthorized to start.

## Historical task-board checkpoint records (superseded status lines below)

**Last updated:** 2026-10-28 (A2 partial recovery)
**Current task:** A2 — Flutter deep audit, incomplete/PARTIAL; full acceptance `NOT RUN`.
**Continuation:** retained synthetic controller probes reproduced bounded discard timeout and
cross-owner backup adoption in direct and UI-used controller paths; `+7: All tests passed!`, exit 0,
independently rerun by orchestrator. QA inspected the probe read-only. See `docs/audit/phases/A2_PROBES.md`;
post-await race, 22-lead triage and final QA remain open. Current next action is lead reconciliation,
not starting A3. There are now nine authorized audit/planning paths including the new probe document.
**Current commit:** `main` @ `7eb40f1d7e553e9f136abb13f632b8bfb189dc3c` = `origin/main` at
recovery entry. Tree clean at entry; eight authorized audit/planning files now pending, no commit/push.
**Next action:** A2 retained real-controller probes for discard cycle and cross-owner recovery,
then candidate reconciliation and final QA. See `docs/audit/phases/A2_FLUTTER.md` sections 5-7.
**Evidence:** analyzer `No issues found!`; format `125 files (0 changed)`; Flutter `+126: All tests
passed!`, all exit 0 in recovery. 17 registered findings; new FND-SEC-002 is High/Needs Verification.
**Blockers:** unfinished verification/triage, no external blocker. A3-A6 and remediation not started.

The following A1 baseline lines are historical; the current recovery state above takes precedence.
**Baseline:** branch `main` @ `c9cc764` = `origin/main` after the A1 checkpoint push. A1 was measured
at `e8c7c8e`, the parent of that commit. `main` is the only development branch. Confirm with
`git rev-parse main`; the SHA moves.
**Working tree:** clean after the A1 checkpoint commit (`c9cc764`); evidence in
`docs/audit/SESSION_HANDOFF.md` §3.
**Current milestone:** M1 — NOT STARTED (unchanged)
**Next task (audit track):** **A2 — Flutter app, state, lifecycle, concurrency, navigation**
(`READY`; prompt in `docs/audit/SESSION_HANDOFF.md` §6; requires explicit go-ahead)
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
| S5 | Full development access policy (**D-024**) | `DONE` | `.opencode/opencode.jsonc` (73 global rules), 7 agent files, `docs/agent-system/ACCESS_POLICY.md`; validator 66/66 probes `PASS`; orchestrator write and reviewer read-only verified at runtime |

**S3 notes.** Agent discovery, permissions, read-only enforcement, skills, commands and delegation
were verified at runtime. Two product findings were documented, not patched: a potential deadlock in
`active_workout_controller.dart` (L4) and the legacy award path in `complete_workout` (L5). Operational
rule recorded: run shell-dependent subagents sequentially (D-021).

**S4 next action.** Not authorized. When approved, start with `context-management-context-save`, after
mapping its storage model onto the nine memory files.

## Full codebase audit (audit track, precedes migration)

Pre-migration evidence program. Read-only against product code. Authoritative state lives in
`docs/audit/`, not in this board.

| ID | Stage | Status | Evidence |
|---|---|---|---|
| A0 | Bootstrap, baseline, inventory, execution plan | `DONE` | `docs/audit/phases/A0_BOOTSTRAP.md`; 6 findings; coverage matrix for 27 components |
| A0.1 | Governance fix (`FND-GOV-001`) + A0 checkpoint | `DONE` — push `BLOCKED` | `docs/audit/phases/A0_1_GOVERNANCE.md`; 1 permission rule; commit local, push denied by `git push *` |
| A1 | Architecture, dependencies, configuration, infrastructure, CI | `DONE` | `docs/audit/phases/A1_ARCHITECTURE.md`; 10 new findings (16 total); coverage C-22/C-25/C-26 closed; 2 A0 inventory figures corrected |
| A2 | Flutter app, state, lifecycle, concurrency, navigation | In progress (partial) | Authorized; recovered inspections, current checks, pending retained probes/triage/QA; current handoff recovery section |
| A3 | Supabase, PostgreSQL, RLS, auth, Edge Functions | `PLANNED` | — |
| A4 | Workout lifecycle, XP, progression, rewards | `PLANNED` | — |
| A5 | Tests, performance, reliability, observability | `PLANNED` | — |
| A6 | Reconciliation, verification, triage, remediation plan | `PLANNED` | — |

**A0 notes.** Baseline re-verified at `9c8e142`: analyze clean, 126/126 Flutter, 10/10 SQL, 15/15 Edge.
Six findings recorded — `FND-CONC-001` (P1), `FND-DATA-001` (P1), `FND-ARCH-001` (P2),
`FND-GOV-001` (P2), `FND-GOV-002` (P3), `FND-GOV-003` (P3). The first three are inherited from S3 and
remain unverified.
The active agent at A0 was the built-in build agent, not `gymlvl-orchestrator`; no agent profile could
write `docs/audit/**`, which was recorded as a W0 prerequisite, not worked around.

**A0.1 notes.** `FND-GOV-001` fixed at configuration level by adding one edit allow (`docs/audit/*`) to
`.opencode/agents/gymlvl-orchestrator.md` (D-022); `FND-GOV-003` closed as `False Positive` on the
authoritative V2 permission semantics. Root cause of the agent-binding symptom recorded as D-023:
`default_agent` applies at session creation only. A0 + A0.1 were committed on `main` as `e400dbc`; the
push was **denied** by the global `git push *` rule and was not worked around, so `origin/main` is still
at `9c8e142`. End-to-end orchestrator write remains `NOT RUN`. Product regression was **not** rerun — no
application or test configuration changed.

**D-024 notes (2026-10-28, S5).** The user directed full development autonomy. The seven-agent
architecture, agent names, skills, commands and routing are unchanged; what changed is the permission
layer. `.opencode/opencode.jsonc` now holds one ordered rule set: broad allows first, then `ask` gates
for force-push and other history rewrites, bulk deletion, production database/deploy commands, and
secret reads (including shell forms). The orchestrator and the five development specialists carry **no**
`permissions` block, because an agent rule is appended after the global rules and the last match wins —
a per-agent broad allow would cancel every gate. `qa-reviewer` and `context-keeper` keep `edit` → `deny`
with a widened read-only shell allowlist. `git push` is no longer denied, so the A0.1 push blocker is
retired. Validation: 66/66 effective-permission probes `PASS`; the orchestrator wrote a previously
denied path in a live session; the reviewer was denied a write and a commit at runtime. Record:
`docs/agent-system/ACCESS_POLICY.md`. A1 was **not** started.

**A1 notes (2026-10-28).** Executed read-only against product code at `e8c7c8e`; the acting agent was
proven from the server as `gymlvl-orchestrator` (`GET /api/session/...` → `"agent":"gymlvl-orchestrator"`),
not inferred from configuration. `flutter analyze` → `No issues found!`, `dart format
--set-exit-if-changed` → `Formatted 125 files (0 changed)`. Ten findings added — `FND-BUG-001` (P1,
Android release manifest has no `INTERNET`), `FND-BUG-002` (P2, debug keystore), `FND-TEST-001` (P2, CI
gate gaps), `FND-GOV-004` (P2, Git gates miss destructive spellings), `FND-SEC-001` (P2, secret gates
cover four reader spellings), `FND-INTG-001` (P3, auth redirect not allowlisted), `FND-ARCH-002` (P3,
two localization mechanisms), `FND-ARCH-003` (P3, timezone invariant), `FND-BUG-003` (P4, template
display name), `FND-GOV-005` (P4, tracked stale `analysis.txt`) — bringing the register to **16**
findings. `FND-GOV-002`'s stale-claim inventory is complete (15 claims, nine documents). Two A0
measurement figures corrected (migrations 1,222 → 1,377 total / 1,219 non-blank; `verify.yml` 58 → 52).
`FND-BUG-001/002/003` and `FND-TEST-001` overlap `TASK_BOARD` §M1-02/§M1-05, which already planned the
fixes but never registered them. No application, SQL, CI, dependency, or configuration file was
modified; no build artifact was produced; no database was started. Product regression was **not** rerun.

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
