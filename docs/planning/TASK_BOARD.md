# GymLvl — Task Board

## Current — R3 hardening locally verified; release/signing & data gates still open (2026-10-29)

**Scope:** CI hardening (FND-TEST-001), Android fail-closed signing (FND-BUG-002), remaining contrast
(FND-BUG-004), KPI labeling (FND-BUG-005), Supabase data integrity (FND-DATA-001 / D-037). One batch at
a time; smallest safe change; regression test per fix. No production migration, deploy, signing-key
change, or OpenGym migration.
**Baseline:** `main` @ `aa52aa0ad185a2bc8ce99f1959543d7d4cfd49a5` (remote == local); five owner files
preserved (`app/android/gradle.properties`, `app/android/run_gradle.bat`, `gradle_check.ps1`,
`run_gradle_check.bat`, `docs/audit/phases/A8_BATCH_EXECUTION.md`); tree clean otherwise.
**Fixed/verified this batch:**
- FND-TEST-001 CI hardened: `verify.yml` adds `invoke.test.mjs` to the manifest-gate step (18 Android
  tests), a `dart format` gate, per-job `timeout-minutes`, workflow `concurrency`+cancel, `push.branches:
  [main]`, and `checkout`/`setup-node`/`setup-java`/`upload-artifact` pinned to Node-24 commit SHAs
  (`subosito/flutter-action@v2` kept). `dart format` gate 0 changed; YAML parses to 3 jobs.
  Generated-code drift gate **withheld** — regeneration rewrites 12 tracked files (measured).
- FND-BUG-002 fail-closed signing verified locally **without credentials**:
  `:app:validateReleaseSigningInputs` exit 1 (lists all 4 missing `GYMLVL_RELEASE_*`); partial-input
  placeholder still exit 1 (lists 3 missing); `:app:assembleRelease` fails at the gate producing no
  APK/AAB. Keystore absent → artifact/signature verification NOT RUN.
- FND-BUG-004 contrast **Fixed**: 7 profile text nodes + onboarding chip icon/label/checkmark paints
  resolved from the live tree; `ui_regression_test.dart` 7 new tests + a negative-control run proving
  8 failures on pre-fix colours.
- FND-BUG-005 KPI **Fixed**: volume tile names its 7-day window, workouts/sets tiles name the last-3
  window (`dashboard_kpi_window_test.dart`, 3 tests). Product-intended window is unchanged (decision).
- FND-INTG-008/009 source-confirmed remains Needs Verification (bare retryable insert, no unique
  constraint; sequential reorder without transaction); real fix needs an isolated two-connection stack.
- FND-DATA-001/D-037: migration re-validated additive/idempotent; the two read-only cohort queries are
  recorded in `REMEDIATION_EXECUTION.md` §11.5 and schema-validated locally (positive/negative controls
  pass); production counts BLOCKED on `O-07`, concurrency BLOCKED (PGlite is single-connection).
- Release signing operator steps documented in `docs/admin/ANDROID_RELEASE_SIGNING_VI.md` (no keys created).
**Final gates (session, local):** analyze 0; format 135 files 0 changed; full 231/231; SQL 12 units +
365 ACL PASS; Edge 44/44; Android manifest gate exit 0; invoke 10/10, manifest-check 8/8; YAML 3 jobs.
**Still blocked:** production counts/backfill for FND-DATA-001 (`O-07`); release signing keys; iOS
(Windows); hosted Edge/live Auth; remote CI for the R3 changes (pending owner approval to push).
**Open findings of record:** FND-BUG-002 Accepted; FND-TEST-001 Accepted; FND-INTG-008/009 (2× NV);
FND-DATA-002 / INTG-003/004/005/006/007 / TEST-002 Accepted; GOV-002 (stale doc) Accepted; 2 FP.
Counts: Fixed 20 · Accepted 11 · Needs Verification 2 · False Positive 2 = 35.**
**Next action:** owner reviews the R3 commit manifest below and approves the push that triggers remote CI. (a) `invoke.test.mjs` is already wired into the R3 `verify.yml` manifest-gate step — no separate wiring needed; (b) approve `O-07` read-only at-risk counts for FND-DATA-001 (queries prepared, BLOCKED on live Supabase); (c) the unchanged release/platform blockers (signing keys, iOS, hosted Edge/Auth). R3 stops at READY_FOR_APPROVAL: no push of code/test/CI changes without approval; docs-only update may follow the approved green run. R2 remote CI run `40834000928` at `a018ec2` passed all three jobs (REPOSITORY: CLOSED · CI: VERIFIED · PRODUCTION: NOT VERIFIED · OPENGYM MIGRATION: NOT READY).

## Current — M0 OpenGym source pinning & migration foundation (2026-10-31)

**Scope:** Pin official OpenGym reference, licensing review, UI/feature/data mapping, one safe migration slice. No production DB change, no media, no AGPL code copy, no commit/push/tag.
**Baseline:** `main` @ `6badfef29a871a978a09daee304dc1c3f3f69a84`; 5 owner files preserved.
**Source pinned:** `https://github.com/DuarteSantos8/openGym` @ `e6a95c28a6e3067bdd9b1188d5f37f448d528bd2` (AGPL-3.0, reference only), clone at `D:\Projects\opengym-reference`; remote origin + HEAD verified.
**Manifest:** `docs/planning/UPSTREAM_SOURCE_MANIFEST.json` created.
**Licensing:** AGPL reference-only; MIT text (`textSource=exercisedb`) reusable with notice, strip media; media EXCLUDED; GymLvl no LICENSE file (O-01 open).
**Mapping:** UI mapping (flutter-specialist), data mapping (supabase-specialist), licensing QA (qa-reviewer) completed; feature architecture mapping synthesized from subagent evidence.
**Migration slice:** Rest Timer Duration Wheel — quick-select chips (30/60/90/120s) → minute/second wheel picker in CandyBottomSheet; VI/EN l10n keys; narrow-screen safe (Wrap layout).
**Changed files:** `app/lib/features/workout/presentation/widgets/rest_timer_widget.dart`, `app/lib/features/workout/presentation/screens/active_workout_screen.dart`, `app/lib/features/workout/workout_copy.dart`, `app/test/workout_widgets_test.dart`, `docs/planning/UPSTREAM_SOURCE_MANIFEST.json` (new).
**Verification:** `flutter analyze` 0 issues; `dart format` 0 changed; `flutter test` +231 All tests passed.
**Status:** M0 implementation slice PASS (READY_FOR_APPROVAL); no commit/push/tag.
**Next action:** owner review; proposed next slice: exercise catalogue navigation/filter improvement (ADAPT, P1) or workout detail layout (ADAPT, P1).

## Historical A8 — remediation batch executed; platform gates blocked (2026-10-29)

**Scope:** owner-requested verification-first remediation of the 35-finding register; one group at a
time, smallest safe change, regression test per fix. No migration, config, permission, commit or push.
**Baseline:** main b85d674b27b7eb024b42a8d1b05d5f624a3ee6bc, tree dirty with preserved owner work.
**Entry:** analyze0, format129/0 changed, full200pass; SQL11+ACL365; Edge36/44 (8x503 = missing
SUPABASE_* env, handler fail-closed, not a product defect).
**Fixed this session:** BUG002 Android/iOS names, BUG003 pubspec, BUG004 partial profile contrast,
BUG006 quest fallbacks/progress, BUG007 summary deep link +500XP +level defaults, BUG008 recovery
error scope, BUG009 CandyButton keyboard, TEST001 partial source gate, SEC004 edge-runner env. New
tests summary5/reset1/keyboard2/quest3, +3 release config, +1 200%-text contrast.
**Re-verified already fixed:** BUG001 source INTERNET, SEC002/CONC001/INTG002 61 focused tests,
SEC003 SQL+ACL (5 findings).
**Still open:** GOV005 — `app/analysis.txt` is tracked (`git ls-files app/analysis.txt`), needs A-8.
**Final:** analyze0, format133/0 changed, full215/215pass, SQL11+ACL365, Edge44/44.
**Reproduced, BLOCKED on approval:** DATA001 second award total_xp100->110/level1->2/rewards0->1/
ledger1->3; INTG001 site_url 127.0.0.1:3000 vs app localhost:8080.
**Not re-verified:** 18 findings keep canonical status. Merged manifest/APK, iOS build, live Supabase,
hosted Edge runtime, concurrency stack NOT RUN.
**Next action:** decide A-1..A-4, A-7 (brand spelling), A-8 (`app/analysis.txt`) in
docs/audits/codebase-health/REMEDIATION_EXECUTION.md §7; A-2 (config-only) first. No commit, migration
or deployment without approval.

## Historical A7 state (preserved)

## A7 — PARTIAL; verified core and blocked B1 verification (2026-10-29)

**Scope:** owner explicitly approved R0-01..04 and R1-01..07, including separate SEC002/R1-01 gate,
source/permanent tests/local verification and verified normal Git commits/pushes. D-025..028.
**Entry:** main3d9dbb038a3a7e93ee4b3d4c51b10d8e066dbf75 clean/remote equal; backup560files verified.
**R0-01:** safety model six assertions PASS; approval/file ownership/tests/rollback gate before each
task; QA inspected readiness. B0 R0-02..04 implemented and locally verified; policy32/SQL11+ACL365/
Edge44/sixchecks pass, no material code review blocker. Four repo-only Fixed,35finding history kept.
Execution ledger docs/audit/phases/A7_BATCH_EXECUTION.md, not A6 historical matrix status.
**B0 checkpoint:** main57e4e73e88f7099ec29a9d075964817f4db5470d pushed/clean/remote equal.
**B1:** R1-01 independent31/R1-02 independent25/R1-03 independent18 PASS; parent analyze/format129/
full200tests PASS. R1-04/R1-07 BLOCKED localstack; R1-05/R1-06 partialsource10checks PASS but actual
Gradle merged/signing/artifact gates BLOCKED (resource8Gheap/nativeOOM; offlineKotlin cache).
**Findings:**35, Accepted22/NV3/Fixed8/FP2; fullnineedited histories preserved, platformpair notFixed.
D029..032approved; Dprocess temp/cache, exactduplicateZIPcleanup done, no keys/backupdeletion.
**Next action:** final QA and verifiedcore/PARTIALplatform logical checkpoints; next execution
resumes blocked B1 gates only after environment prerequisites. No W2-W5, migration or deployment.

## Historical A6 state (preserved)

## Current — A6 DONE/CLOSED; remediation NOT STARTED (2026-10-29)

**Checkpoint:** payload main4246b12238e4a904f87c0b843e861b637403d00c, nine docs +761/-3;
normal push6d8e89b..4246b12 exit0; local/remote equal and clean, A6_PAYLOAD_EQUAL_CLEAN=PASS.
This four-doc outcome child advances HEAD; verify actual latest main/remote on resume.

**Task/status:** A6 ONLY; scoped reconciliation/roadmap acceptance PASS/CLOSED, independent final QA
and consistency checks complete. A1-A5 remain closed, no remediation begun; migration NOT READY.
**Entry:** main6d8e89bf6eba7b393ef2d0e0d52e9b0d5eb4f2c3 clean/remote equal, primary API verified;
external bundle/bare/archive backup verified559files, A6phase2. Nine authorized docs only.
**Progress:** all six named agents actually invoked sequentially; material QA flagged missing R0-02
dependency, corrected.35 findings unchanged; roadmap29 tasks. Brand naming requires product decision.
**Artifact gate:** A6phase6 retained primary validator ->35 unchanged objects/4 historical closures/
35 matched MD and roadmap rows/29 tasks/DAG acyclic/old plan exact/coverage26-0-0-1/9paths/errors0;
A6_VALIDATION_EXIT node=0 diff=0, PASS. Earlier validator failures/corrections retained honestly.
**Next action:** await explicit R0-01 safety gate approval and subsequent separate R1-01 SEC002
snapshot ownership authorization; verify latest main/remote first. One task at a time; no automatic work.

## Historical A5 state (preserved)

## Current — A5 DONE/CLOSED; A6 NEXT / NOT STARTED (2026-10-28)

**Checkpoint (2026-10-29):** closure payload mainab19e97bd7c143ee7a140a461d774a4ebfea7443,
nine-doc delta after PARTIAL614ee7c, aggregate11docs. Normal push614ee7c..ab19e97 exit0,
local/remote fullSHA equal/tree clean after push, A5_CLOSURE_EQUAL_CLEAN=PASS. Four-doc outcome
child advances HEAD; verify actual latest main on resume.

**Task/status:** A5 PASS/CLOSED for scoped audit acceptance; reviews/probes/material/final QA/context
complete, no material closure blocker; primary artifact validator PASS. main614ee7cb6f99846b00fd71eec43637cb296268be PARTIAL checkpoint pushed normally,
remote equal/clean after push; entry1763ab5. Eleven expected docs since entry, no implementation.
**Findings:**35, severity0/3/24/6/2 confidence16/18/1 Accepted29/NV3/Fixed1/FP2; all30oldIDs,
six exact histories,24 unchanged objects. NewBUG008/009, INTG008/009, TEST002; transport pair High/NV.
**Coverage:**26Reviewed(static)/0InReview/0NotReviewed/1OutOfScope; no runtime blanket promotion.
**Evidence:** actual five-agent sequential ledger; Flutter18probe/126regressions/analyze/format,
SQL10/Edge15/sixchecks pass; backend15streamcases/150UUIDpairs/expiry-only pass. Targeted UI FAIL
8pass2fixturefail, external analyzer FAIL(package-context), not hidden by green regression suite.
**Blockers:** independent sessions/fullJWTgateway stack unavailable; finite device/network/telemetry/
policy assertions owner/wave/trigger in phase6. No material decision or exhaustive production gate.
**Artifact check:** phase8 retained extraction/Node ->json35/md35/oldIDs30/unchangedClasses25/
unchangedObjects24/histories6/newIDs5/fields22/coverage26-0-0-1/allowedPaths11/inputHashes65/errors0,
A5_VALIDATION_EXIT node=0 diff=0, PASS. Two initial validator-only corrections retained, no data change.
**Next action:** await explicit A6, then verify latest main/remote and use audit handoff exact prompt.
No A6/remediation/migration automatically.

## Historical A5 progress (preserved)

## Current — A5 authorized / in progress (2026-10-28)

**Task/status:** A5 ONLY, scoped acceptance NOT RUN pending tests/reliability/performance/observability
reviews, evidence, explicit gap dispositions and independent QA. C23/C24 targeted; A4 remains closed.
**Entry:** main1763ab55e8da994bc1d854ad8fd2cd2299678b45 clean/remote equal, primary verified;
bundle/bare/archive backup verified(555 files), A5phase2. Preserve all30 findings/history.
**Progress:** operational PARTIAL checkpoint; actual context/Flutter/Supabase invocations complete.
Flutter18probe/analyze, backend expiry-only/150UUIDreplay/15streamcases/SQL10/Edge15/sixchecks/
syntheticEXPLAIN exit0, full evidence retained. Existing30 findings unchanged pending QA/reconciliation.
Independent sessions BLOCKED(local Docker/Supabase/Postgres executables unavailable), no fake claim.
**Next action:** persist A5 PARTIAL checkpoint, then UI/QA bounded work. Current ledger/scope in phase.
Normal docs-only/partial commit/push authorized; no product/tests/CI/config edits or A6/remediation.

## Historical A4 state (preserved)

## Current — A4 DONE/CLOSED; A5 NEXT / NOT STARTED (2026-10-28)

**Checkpoint:** payload main84462d0acc27a4c9ea0f99a2c0aa16c0940082fb, nine docs +1652/-65;
normal push c95cb48..84462d0 exit0. Local/remote full SHA equal and tree clean after push,
A4_CHECKPOINT_EQUAL_CLEAN=PASS. This four-doc outcome child advances HEAD; verify actual main.

**Task/status:** A4 PASS/CLOSED for scoped audit criteria, owned deferred gaps retained, not production
certification. Reviews/probes/material/final QA complete. Entry main c95cb4873455b39f3ab2b6c0f929b43d87f4d8d3 clean/remote
equal, active primary verified. Nine authorized docs only; normal commit/push completed as above.
**Findings:**30; P0 0/P1 3/P2 20/P3 5/P4 2; Confirmed9/High20/Medium1; Accepted24/NV3/Fixed1/FP2.
All26 old IDs/history preserved; only DATA001 conditional synthetic confirmation and ARCH001
sole-award wording disproof change classifications. New DATA002/INTG005-007; INTG007 stays High/NV.
**Coverage:**24 Reviewed(static)/0 InReview/2 NotReviewed(C23/C24)/1 OutOfScope. No runtime blanket.
**Evidence:** real sequential five-agent ledger in A4 phase2; SQL probe108 assertions/15 sequential
DBs, existing SQL10 units, Flutter analyze/format125unchanged/test126 all exit0. Edge NOT RUN.
**Current artifact gate:** phase10 retained PowerShell/Node -> A4_ARTIFACT_CHECK json30/md30/oldIDs26/
unchangedClasses24/exactHistories2/newIDs4/fields22/coverage24-0-2-1/allowedPaths9/sourceHashes7/errors0;
A4_VALIDATION_EXIT node=0 diff=0, PASS. Corrected primary validator FAILs retained, no product changes.
**Blockers:** no scoped closure blocker established; exact A5 deferred owners/assertions in phase8.
Final context/QA documentary corrections applied, last coverage A2 mixed-stage paragraph historical;
QA additional exclusion-diff BLOCKED(permission), no bypass; no QA runtime or exhaustive gate claimed.
**Next action:** await explicit A5 go-ahead, then verify latest main/remote and use audit handoff
exact A5 prompt. No A5/A6/remediation/migration/production/cleanup execution.

## Historical task states (preserved)

## Current — A3 DONE/CLOSED; A4 NEXT (2026-10-28)

**Checkpoint result:** c535613 on main (nine docs), normal push exit0; full local/remote SHA
c535613fe29cf5a435ead44a6c4c26a16e3074ae equal, tree clean after push. This child record
documents outcome only; A4 remains NEXT and not started.

**Validation:** scoped A3 audit PASS/CLOSED, not production/runtime certification. C17-C21 reviewed
with named limitations; 26 findings (P1 3/P2 16/P3 5/P4 2, Confirmed5/High19/Medium2), previous24
IDs/classifications unchanged; new SEC003 conditional PUBLIC ACL and SEC004 buffering order.
**Coverage:**18 reviewed-static/5 mixed-stage InReview/3 NotReviewed/1 excluded; A4 halves remain pending.
**Evidence:** SQL10 units, Edge15 tests, six handler checks PASS; custom named-role hypothesis FAIL
retained and disproved, PUBLIC14/named-control4 assertions PASS. No source/config/dependency changes.
**Entry:** main f877e40 clean/remote equal, agent verified; normal A3 docs checkpoint authorized.
**Next task:** A4 NEXT, separate user authorization required; exact prompt in audit handoff. No
automatic A4/remediation/migration. Deferred A4/A5 owners/assertions in A3 phase9; A2 stays closed.

## Historical task states (superseded current/next status below)

## Current — A3 authorized / in progress (2026-10-28)

**Task:** A3 Supabase/PostgreSQL/security C17-C21 only. A2 stays PASS/CLOSED.
**Entry:** main f877e40987423f3804fe0d2887c44d19f3423aff, clean and remote equal, agent verified.
**Acceptance:** component coverage/gaps, traceable findings, assigned deferred assertions, independent
QA, synchronized artifacts, current safe SQL/Edge evidence and exact A4 handoff; see A3 phase section1.
**Next action:** bounded sequential security reviews; whole-stage acceptance NOT RUN until reconciliation.
**Constraints:** documents only, no product/schema/config/permission change, production/secret access,
deployment or A4/remediation. Normal/partial A3 docs checkpoint explicitly authorized by user.

## Historical A2 closure and prior task states (preserved)

## Current — A2 scoped audit DONE/CLOSED (2026-10-28)

**Recorded closure checkpoint:** `a6a57e2` on main, normal push exit0; local/remote full SHA
`a6a57e2546afa8dbd3dd7113bc1096a6e99f5cdf` equal, tree clean after push. This child record
documents the result; A3 remains NEXT, not started.

**Validation:** `PASS` for seven original scoped audit criteria; not product runtime certification.
**A2:** DONE/CLOSED; 24 findings and22 dispositions retained. Lead10 verification belongs to A5,
owner flutter-specialist, independent qa-reviewer, exact synthetic recovery acceptance in phase9.3.
Other deferred assertions remain A4/A5; no indefinite A2 reopening and no findings promoted here.
**Coverage:** 13 static-reviewed /5 mixed-stage in review /8 not reviewed /1 excluded; unchanged.
**Commit/base:** main aa36a4c at closure entry, clean and remote equal. Docs-only closure commit/push
authorized; no rewrite, product change or cleanup. Prior regression results remain dated evidence.
**Next audit task:** **A3 — NEXT**, requires explicit go-ahead; exact entry prompt in audit handoff.
Do not start A3/A4-A6, remediation or migration from this closure task.

## Historical checkpoint records (superseded status lines below)

## Current A2 reconciliation checkpoint — PARTIAL (2026-10-28)

**Recorded Git checkpoint:** `199bf00` on main (nine docs only), normal push exit 0;
remote `199bf00271c8038c04a8f8cbdc1fc35e7538e90f` verified equal, tree clean after push.
This recording change follows that checkpoint; A2 remains PARTIAL, not DONE.

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
| A2 | Flutter app, state, lifecycle, concurrency, navigation | `DONE` | Scoped audit PASS/CLOSED; original seven AC reconciled in A2_FLUTTER section9; Lead10 deferred A5 by explicit user instruction; 24 findings/22 dispositions retained |
| A3 | Supabase, PostgreSQL, RLS, auth, Edge Functions | `DONE` | Scoped PASS/CLOSED; C17-C21 reviewed with deferred gaps; A3_SUPABASE_SECURITY/A3_SQL_EVIDENCE; 26 findings total, no production certification |
| A4 | Workout lifecycle, XP, progression, rewards | `DONE` | Scoped PASS/CLOSED; A4_WORKOUT_PROGRESSION/A4_SQL_EVIDENCE;30 findings, explicit gaps; payload84462d0/outcome1763ab5 |
| A5 | Tests, performance, reliability, observability | `DONE` | Scoped PASS/CLOSED from1763ab5; PARTIAL614ee7c, final phase/evidence/35 findings and26static+1excluded; no remediation |
| A6 | Reconciliation, verification, triage, remediation plan | `DONE` | Scoped PASS/CLOSED; 35 preserved findings, 29 proposed tasks, independent QA; remediation/migration not started |

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
