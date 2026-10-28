# Audit — Session Handoff

## Current — A3 scoped security audit CLOSED; A4 not started (2026-10-28)

**Recorded A3 checkpoint:** main `c535613fe29cf5a435ead44a6c4c26a16e3074ae` (`c535613`),
nine docs, +1094/-25. `git push origin main` -> `f877e40..c535613  main -> main`, exit0.
`git ls-remote origin refs/heads/main` equals local full checkpoint SHA; status empty after push
(`PASS`). This child outcome record may advance HEAD; confirm actual HEAD/remote on resume.
No force push/history rewrite, product change or A4 execution.

- **Task/status:** A3 C17-C21 only; `PASS` against scoped coverage/evidence/QA/consistency conditions,
  operational CLOSED with explicit deferred work. Not production certification or remediation.
- **Entry:** main `f877e40987423f3804fe0d2887c44d19f3423aff`, clean and remote equal; API metadata
  `gymlvl-orchestrator`. Normal A3 documentation commit/push authorized and completed as above.
- **Changed files:** `docs/audit/phases/A3_SUPABASE_SECURITY.md`,
  `docs/audit/phases/A3_SQL_EVIDENCE.md`, `docs/audit/MASTER_FINDINGS.md`,
  `docs/audit/FINDINGS_REGISTER.json`, `docs/audit/AUDIT_COVERAGE.md`, this handoff,
  `docs/planning/TASK_BOARD.md`, `docs/planning/SESSION_HANDOFF.md`, `docs/planning/CHANGELOG_AI.md`.
  No product/SQL/Edge/config/agent/permanent test/dependency edits.
- **Findings:** 26, P0 0/P1 3/P2 16/P3 5/P4 2; Confirmed5/High19/Medium2; Accepted21/
  NeedsVerification3/Fixed1/FalsePositive1. All previous24 IDs/classifications retained; only
  DATA001/ARCH001/SEC002 get A3 addenda. New SEC003 P2/Confirmed/Accepted is conditional synthetic
  PUBLIC grant inheritance, not deployed vulnerability. SEC004 P2/High/Needs Verification is
  authenticated buffering order with actual resource impact unverified. No new P0/P1 finding.
- **Coverage:**18 Reviewed(static)/5 mixed A2-A4 InReview/3 NotReviewed/1 excluded. C17-C21 static
  review complete; C18 only A3 security/schema scope, reward semantics still A4. C09/C23/C24 remain
  unreviewed for assigned later stages; no whole-row runtime promotion.
- **Current verification (f877e40):** `node tools/db-tests/run.mjs` -> PASS10 units/PostgreSQL17.5,
  catalog150 and duration checks, exit0. Installed Deno direct cached-only/deny-net/synthetic limited
  env ->15 tests passed/0 failed, exit0; cached-only frozen-lock six handler typechecks exit0.
- **Custom evidence:** original default audit-probe.mjs FAIL/exit1 disproves named authenticated
  column-grant survival after hardening. Fresh A/B controls passed first. Independent PUBLIC cases
  PASS/exit0 (14 assertions) show own XP777 only with synthetic pre-existing PUBLIC column grant;
  named-column denial control PASS/exit0 (4 assertions). Orchestrator independently reran variants;
  retained187-line source and per-variant outputs in A3_SQL_EVIDENCE. Never describe whole suite green.
- **Security observations:** effective tip has17 RLS tables and11 pinned-path definers, fixed UID-derived
  RPCs, parent guards, explicit Edge getUser and caller-token DB requests. Synthetic B foreign
  workout/set reads and RPCs/inserts/reparenting denied. This corroborates backend boundaries without
  repairing SEC002 local backup or proving real gateway/all-table/production isolation.
- **QA:** supabase specialist DB/Edge reviews, Flutter client-boundary review and qa-reviewer material
  challenge/follow-up completed sequentially. Initial QA external-directory read BLOCKED, not retried;
  complete synthetic source/output published in normal audit evidence for supported read inspection.
  QA supported narrow conclusions, corrected named-role hypothesis/DATA001 test-gap wording, and
  policy wording17tables/22policies; fixes recorded. Independent runtime rerun not claimed by QA.
- **Current consistency (f877e40):** orchestrator PowerShell here-string -> Node JSON/parser/tally/
  previous-ID/classification/field/coverage/scope/handoff assertions -> `A3_CHECK json=26 md=26
  old_ids_preserved=24 old_classifications_preserved=24 required_fields=22 allowed_paths=9 errors=0`;
  `A3_VALIDATION_EXIT node=0 diff=0`. `git diff --check` exit0, LF/CRLF warnings only (`PASS`).
  QA's final inspection found no substantive security blocker but flagged absent persisted parser
  output (FAIL); this note/phase12/changelog now records it. QA did not run parser or runtime tests.
- **Deferred owners/assertions:** A4 supabase-specialist + Flutter/qa-reviewer: legacy reward/state,
  arithmetic, replay, concurrent writers, timed duration/reps and order/retry/domain contracts.
  A5 Supabase/Flutter/QA: SEC004 counted-stream bounds, real JWT/gateway/Auth transport, full17-table
  operation/ACL matrix, context/timeout/AI destination policy and FK query scaling. Approved environment
  inventory of deployed ACLs/migration history requires separate explicit authorization. Phase9 lists
  concrete assertions. No live accounts/project/secrets used or inspected.
- **Decisions/blockers:** no material project change or waived acceptance. Existing in-memory tests
  initialize only disposable databases; no persistent/local Supabase migration or production mutation.
  No A3 closure blocker after recorded gaps; unavailable gateway/concurrency checks are deferred.
  A2 Temp disposal approval still required; no cleanup or new full-app copy.
- **Next action:** await explicit A4 authorization, then use the exact prompt below. No A4 execution.

## A4 entry prompt — authorization required

> Execute **A4 ONLY — Workout lifecycle, XP, progression and rewards** after explicit user go-ahead.
> Verify primary gymlvl-orchestrator metadata, main/HEAD/tree/remote; preserve user work. Read AGENTS,
> current audit/planning handoffs, scope/coverage/registers, A2 section8.2/9 and A3 phase/evidence.
> Entry was f877e40 plus A3 documentation commits; confirm actual HEAD, never reset.
>
> Review C09 and A4 halves of C10/C12-C15: workout lifecycle/setup/training/pause/resume/cancel/
> completion, client pending mutations and retry/recovery contracts, authoritative progression,
> class XP/synergy, PRs, quest/streak/date boundaries and AI no-write boundary. Inspect complete_workout
> transaction/user/workout/parent locks, ledger/flag replay, trusted inputs and derived results.
> Prioritize DATA001 previously-awarded false-flag/no-ledger hypothesis; existing completed-unrewarded
> recovery and true-flag tests are not that fixture. Do not assume a live legacy cohort exists.
>
> Carry INTG004 timed duration/reps completion and A2 order/addSet lost-response/reparent contracts;
> prove or explicitly defer with owner/stage/assertion. Confirm no second independent award path;
> ARCH001 initialization/daily maintenance/class recomputation must be distinguished from awards.
> SEC003 is conditional pre-existing PUBLIC ACL exposure, not a fresh-install or actual deployed
> vulnerability. SEC002 local controller reproduction is complete; do not repeat it or treat backend
> positives as a local fix. Keep A5 device/widget/resource/gateway investigations in A5.
>
> Delegate bounded server/business logic to supabase-specialist, controller/domain contract to
> flutter-specialist, independent material finding review to qa-reviewer; sequential shell work,
> one artifact writer per file. Use existing installed isolated tests/synthetic fixtures and deny
> live/provider traffic. Single-connection PGlite cannot establish actual concurrent-session behavior;
> record that limitation rather than requiring unavailable production verification to close scope.
>
> Create docs/audit/phases/A4_WORKOUT_PROGRESSION.md; preserve26 findings/stable IDs/history and update
> mirrors, named coverage and current handoffs/three planning records. Record expected/actual,
> exact commands/output, confidence and deferred assertions. Retain repro source in audit docs,
> not permanent product tests. Existing tests may be run; no product/SQL/RLS/Edge/config/agent changes,
> installs, real-user/production/secret access, deployments, destructive probes or remediation.
> Do not create another full-app Temp copy or delete earlier task directories. Git actions require
> actual A4 user authorization, not this prompt alone. Validate counts/classifications/edit scope,
> evaluate scoped closure honestly, give Vietnamese report and exact A5 handoff. Stop after A4.

## Historical A3 start and A2 records (superseded status/next actions below)

## Current — A3 in progress (2026-10-28)

**Task:** A3 Supabase/PostgreSQL/security C17-C21 only. Authorized by current user; no A4/remediation.
**Status:** In progress; whole-stage acceptance `NOT RUN` pending inspection/reconciliation/QA.
**Entry:** main `f877e40987423f3804fe0d2887c44d19f3423aff`, tree clean and remote equal; session API
confirms primary `gymlvl-orchestrator`. Existing 24 findings preserved at entry.
**Owned artifacts:** new `docs/audit/phases/A3_SUPABASE_SECURITY.md` (current user filename replaces
older prompt's A3_SUPABASE.md); findings mirrors, coverage, this handoff and three planning records.
**Safety:** docs-only writes; no live/remote DB/secret access, installs/deploys/config/source changes.
Current authorization allows existing synthetic in-memory SQL and stubbed Edge tests; inspect runner
before execution. All results must be current or explicitly historical.
**Next action:** bounded sequential schema/RLS/RPC review, Auth/Edge client boundary review and QA;
persist results in A3 phase. User authorizes normal A3 docs checkpoint including PARTIAL if interrupted.

## Historical A2 closure and entry prompt (preserved)

## Current — A2 scope CLOSED; A3 awaits authorization (2026-10-28)

**Closure checkpoint:** `a6a57e2546afa8dbd3dd7113bc1096a6e99f5cdf` (`a6a57e2`) on main;
eight documentation files only, +317/-27. `git push origin main` ->
`aa36a4c..a6a57e2  main -> main`, exit0. `git ls-remote origin refs/heads/main` equals local
closure SHA; status empty after push (`PASS`). This follow-up record advances HEAD without changing
A2 acceptance/findings. Verify actual HEAD/remote on resume. No rewrite/force-push.

- **Task:** A2 scope closure and A3 handoff only.
- **Validation:** `PASS` for the seven original scoped audit acceptance criteria; **operational
  status CLOSED** with deferred verification. This does not assert product correctness or fixes.
- **Entry commit:** `main` @ `aa36a4c36e6c46cc7ae1f2fdd3e117f2a8a3a4c5`, clean and equal to remote
  at closure entry. Documentation closure commit/push explicitly authorized and completed above.
  Confirm actual branch/HEAD/tree/remote at the next session.
- **Changed files:** `docs/audit/phases/A2_FLUTTER.md`, `docs/audit/AUDIT_COVERAGE.md`,
  `docs/audit/MASTER_FINDINGS.md`, `docs/audit/FINDINGS_REGISTER.json`, this file, and
  `docs/planning/{TASK_BOARD.md,SESSION_HANDOFF.md,CHANGELOG_AI.md}`. No product/permanent-test edits;
  `A2_PROBES.md` retained unchanged.
- **What closed:** all 22 leads retain dispositions; 24 finding objects and all severity/confidence/
  status values remain unchanged from aa36a4c. Register totals: P0 0/P1 3/P2 14/P3 5/P4 2;
  Confirmed 4/High 18/Medium 2; Accepted 20/Needs Verification 2/Fixed 1/False Positive 1.
- **Lead10:** explicitly Deferred A5 by current user instruction, owner flutter-specialist,
  independent qa-reviewer. Synthetic failed-signin -> recovery must not show password-update failure
  before submission; successful/rejected submission controls must show operation-specific state.
  Retain isolated harness, exact command/output/assertions; `NOT RUN`, not Confirmed, no new ID.
- **Other work:** owners/targets/assertions remain in A2_FLUTTER sections8.2/9.3: post-await identity
  race and UI/auth/lifecycle/contract runtime checks A5; workout/order/retry/reward semantics A4;
  schema/authorization A3. DATA001 remains unverified server-side. CONC001/SEC002 Confirmed scopes
  remain narrow synthetic controller behavior, not live account disclosure or server award proof.
- **Coverage:** 13 Reviewed (static), 5 mixed-stage In Review, 8 Not Reviewed, 1 excluded. Mixed rows
  retain A4 halves. C09 and C17-C21/C23-C24 remain unreviewed for their assigned later stages.
- **Evidence:** retained probe command/source/output and independent QA are in A2_PROBES and phase8.4;
  prior analyzer/format/+126 regression and +7 synthetic results are dated historical evidence.
  Current-session Flutter analyze/test/format/probes `NOT RUN` intentionally (docs-only closure,
  no new investigation). Closure consistency/Git checks are current; do not relabel prior runs.
- **Current closure checks (aa36a4c):** inline Node -> `CLOSURE_CHECK findings=24 unchanged_objects=24
  md=24 fields=22 dispositions=22 lead10=A5 ac_records=7 authorized_paths=8 errors=0`;
  `CLOSURE_EXIT node=0 diff=0`. `git diff --check` -> exit0, conversion warnings only (`PASS`).
  First validator exit1 was Unicode-literal pipe encoding (seven AC labels/one title mismatch);
  ASCII-safe assertions reran successfully without changing findings or product. It is a recorded
  validator failure, not an omitted product test failure.
- **Independent closure review:** context-keeper `ses_e7d8e3512ffe5XRc3csFGsWSyv` confirmed governance;
  qa-reviewer `ses_e7d88939afferY5zT4orKqmM5Z` inspected all seven criteria/Lead10 deferral/A3 prompt,
  found no substantive mandatory blocker and requested these current output notes (now included).
  QA Git scope check passed; its parser/runtime checks NOT RUN. No permissions bypass or new probe.
- **Decisions:** no architecture/schema/dependency/licensing/permission/milestone change. Lead10
  transfer is user-approved audit scheduling; original seven criteria not waived or replaced.
- **Blockers:** none for scoped A2 closure. Deferred tests are future work, not an open A2 loop.
  Probe-directory disposal still requires exact-path review/approval; no secret reads or cleanup.
- **Next action:** await explicit A3 go-ahead, then execute the entry prompt below. **A3 not started.**

## A3 entry prompt — authorization required

> Execute **A3 ONLY — Supabase/PostgreSQL, RLS, Auth and Edge Functions** after explicit user
> authorization. Do not begin A4-A6, remediation, or OpenGym migration.
>
> Restore `AGENTS.md`, planning/current audit handoffs, audit README/scope/coverage, both findings
> mirrors, A1 architecture and A2 sections8-9/probe limitations. Confirm active primary
> gymlvl-orchestrator via session metadata, main branch, actual HEAD, tree and remote; preserve any
> expected user work. Closure entry was aa36a4c plus subsequent documentation commits; never reset.
>
> Review **C17-C21**: `supabase/migrations/*.sql` (three migrations), effective schema/types/FKs/
> constraints/indexes/grants/RLS, SQL function exposure and SECURITY DEFINER ownership/search_path,
> Auth identity boundaries/config, and `supabase/functions/**` handler authentication/authorization,
> validation, response/error contracts. Read existing SQL/Edge tests and local test harness only as
> evidence needed for those paths. Treat repo migration state as distinct from deployed/live state.
>
> Delegate supabase-specialist this bounded schema/RLS/Auth/Edge scope and qa-reviewer independent
> high-severity/security validation, sequentially for shell-dependent work. Orchestrator owns all
> audit/planning artifact writes; name exact file ownership and checks for each delegation. Do not
> have every agent scan the entire repository. Use read-only alternatives when QA shell is denied.
>
> Carry DATA001/ARCH001 as hypotheses/context: inspect relevant schema/authorization, but leave
> reward arithmetic, completion/idempotency, legacy reward reproduction, timed-set completion and
> cross-layer workout semantics authoritative to **A4**. Do not claim XP duplication from client
> evidence or reopen A2 for deferred A5 widget/device verification. Preserve all 24 IDs and history.
>
> Use only existing authorized isolated non-production tests when safe and already provisioned;
> otherwise record BLOCKED/NOT RUN with prerequisite. **No production/live-account or remote DB
> access, secret-file reads, dependency installation, migrations applied, configuration/product/test
> changes, deployments, destructive security probes or remediation.** No third-party exercise media.
> Do not widen permissions or bypass denied commands. Commit/push only if the actual A3 user
> authorization explicitly permits them; drafting this prompt does not grant A3 execution rights.
>
> Produce `docs/audit/phases/A3_SUPABASE.md`; update both findings mirrors with full fields and stable
> IDs, named C17-C21 coverage, audit handoff and the three required planning records. Every conclusion
> separates observation from hypothesis and static from runtime evidence; P0/P1 have independent
> review; no unsupported Confirmed promotion. Record unavailable runtime checks with owner/target/
> assertion. Validate JSON/count/classification consistency and authorized edit scope. Report actual
> commands and results in Vietnamese, exact A4 next prompt, limitations and Git state. Stop after A3.

## Historical A2 partial checkpoints (superseded operational status and next actions)

## Current — A2 reconciled PARTIAL documentation checkpoint (2026-10-28)

**Checkpoint recorded:** `main` @ `199bf00271c8038c04a8f8cbdc1fc35e7538e90f` (`199bf00`),
`docs(audit): checkpoint partial A2 reconciliation and retained evidence`; nine docs only.
`git push origin main` -> `7eb40f1..199bf00  main -> main`, exit 0;
`git ls-remote origin refs/heads/main` -> same full SHA as local; status empty after push (`PASS`).
This follow-up documentation record is a child of that checkpoint, not A2 completion. Verify actual
HEAD/remote on resume; no rewrite or force push used. Tree was clean before this record edit.

- **Task/status:** A2 final reconciliation; **PARTIAL**, not stage PASS. Complete-stage acceptance
  `NOT RUN` pending focused lead10 follow-up and executable A3 handoff. No A3/remediation started.
- **Agent/base:** server API -> `gymlvl-orchestrator`; `main` @
  `7eb40f1d7e553e9f136abb13f632b8bfb189dc3c`, same remote at entry. User-authorized PARTIAL
  documentation commit/normal push completed as recorded above; no history rewrite.
- **Preservation:** all nine original dirty artifacts backed up and hash-verified at
  `C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a2-final-backup-20261028-174845`;
  bundle clone = HEAD, archive/Git counts 549/549. Do not remove backup.
- **Changed files:** `docs/audit/{MASTER_FINDINGS.md,FINDINGS_REGISTER.json,AUDIT_COVERAGE.md,
  SESSION_HANDOFF.md,phases/A2_FLUTTER.md,phases/A2_PROBES.md}` and
  `docs/planning/{TASK_BOARD.md,SESSION_HANDOFF.md,CHANGELOG_AI.md}`. No product/permanent-test edits.
- **Dispositions:** all 22 original leads explicitly dispositioned with subclaims/owners/targets in
  A2_FLUTTER section 8.2. Seven new IDs: BUG004-007 and INTG002-004. Lead10 remains A2 follow-up;
  other deferred assertions target A4/A5, not unrecorded or completed runtime checks.
- **Findings:** 24 total, P0 0/P1 3/P2 14/P3 5/P4 2; Confirmed 4/High 18/Medium 2.
  Accepted 20/Needs Verification 2/Fixed 1/False Positive 1. CONC001 narrowed to queue cycle,
  P2/Confirmed/Accepted; post-await race separately deferred A5, not Confirmed. SEC002
  P1/Confirmed/Accepted only for synthetic cross-owner controller adoption. DATA001 remains
  P1/Medium/Needs Verification; no server XP duplication confirmation. BUG005 is the other
  Needs Verification finding (unlabeled recent-three KPI, intended window still unclear).
- **Coverage:** 13 Reviewed (static), 5 In Review (mixed A2/A4 scope), 8 Not Reviewed, 1 excluded.
  No whole component runtime-verified. UI/keyboard/hit regions/device/live callbacks have explicit
  deferred checks; static reading is not runtime PASS.
- **Current validation at 7eb40f1:** `flutter analyze --no-pub` -> `No issues found! (ran in 8.5s)`;
  `dart format --output=none --set-exit-if-changed lib test` -> `Formatted 125 files (0 changed) in
  1.28 seconds.`; `flutter test --no-pub --reporter expanded` -> `+126: All tests passed!`; all exit 0.
  Retained successful seven controller probes not rerun; source/control evidence independently
  re-read. Prior command/output preserved in A2_PROBES, not a current-session runtime PASS.
- **Checkpoint QA/consistency:** qa-reviewer `ses_e7dca47b2ffeJhwQNOqAQJbgY0` found no blocking
  documentation contradiction by read/grep inspection, confirmed 22 dispositions and classification
  limits; whole-stage `NOT RUN`. Its Git scope/whitespace commands passed, no denied Node retried.
  Orchestrator Node check -> `MD=24 JSON=24 fields=22 old IDs=17 dispositions=22 errors=0`, correct
  13/5/8/1 coverage and nine allowed paths, exit 0; `git diff --check` exit 0 (`PASS`).
- **Temp disposal:** metadata-only inventory: 1,351 files / 1,369,316,592 bytes, zero observed reparse
  points in `C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a2-probe-20261028`. Task attribution
  supported, exclusivity/disposal safety not established. No content read or directory deleted.
  User must review exact directory/inventory and explicitly authorize exact-path removal; no broad
  cleanup. Metadata CSV lives in the verified backup directory. See A2_PROBES disposal section.
- **Decisions:** no architecture, schema, licensing, dependency or permission change. Latest user
  explicitly authorizes a normal PARTIAL documentation commit/push, superseding earlier prohibition.
- **Remaining prerequisite:** retained focused synthetic widget assertion for stale shared auth-action
  error on entry to password recovery (lead10), independent QA of that assertion, then final A2
  completion assessment and exact A3 handoff. This is unfinished work, not an external credential block.

**One next action — A2:** delegate flutter-specialist to retain an isolated synthetic widget probe
for failed sign-in then recovery navigation: password-update failure copy must not appear before
submission. No real account or product edit. QA reviews result via supported read-only capabilities;
then decide stage completion. Do not restart reviewed modules or rerun successful controller probes
without a concrete reason. Do not start A3 or remediation.

## Historical partial handoffs (superseded current-state/authorization lines below)

**Updated:** 2026-10-28 (A2 partial recovery checkpoint)
**Current task:** A2 — Flutter deep audit, **PARTIAL**, not stage PASS.
**Current verification status:** `NOT RUN` for complete A2 acceptance; individual checks below.
**Current commit:** `main` @ `7eb40f1d7e553e9f136abb13f632b8bfb189dc3c`, equal to `origin/main`
at recovery entry; tree clean then, documentation changes now uncommitted.
**Active agent:** API session `ses_e7e81bc84ffeWkbb0tV5jo0jwp` -> `gymlvl-orchestrator`.
**Current next action:** A2 retained controller probes (see recovery section immediately below).

## A2 recovery — authoritative current state

**Continuation, 2026-10-28:** User authorized A2 completion and preservation of eight prior dirty
artifacts. Verified external backup at
`C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a2-backup-20261028-171019`: bundle clone
equals HEAD, archive/Git counts 549/549, eight changed-file hashes match. `A2_PROBES.md` is now an
additional untracked audit artifact (nine authorized paths total).

Current continuation checks at `7eb40f1`: `flutter analyze --no-pub` -> `No issues found! (ran in
5.3s)`; `dart format --output=none --set-exit-if-changed lib test` -> `Formatted 125 files (0 changed)`;
`flutter test --no-pub --reporter expanded` -> `+126: All tests passed!`; inline Node register check
-> `MD=17 JSON=17 mismatches=0`; `git diff --check` -> no whitespace errors. All exit 0 (`PASS`).

Synthetic retained controller probe, independently rerun by orchestrator in minimal temp app:
`flutter test --no-pub --reporter expanded test/a2_retained_probe_test.dart` -> `+7: All tests
passed!`, exit 0. Assertions reproduce bounded active discard timeout with no additional cancel,
and B adopting A's backup for both direct restore and `checkForActiveWorkout` under null/error
remote; direct-cancel, inactive-discard, and same-owner controls pass. Read-only QA independently
reviewed source/probe and supports these narrow observations; real UI/account/RLS and post-await
race remain untested. Finding classifications intentionally unchanged pending full triage.

**Safety:** first temporary test copied entire `app` to
`C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a2-probe-20261028` and may include secret
files. Do not inspect or share its contents; removing that task-created copy requires explicit user
approval. Minimal copy is separate. No real user data was used in the synthetic tests.

**Current next action (A2):** sequentially triage phase section 5's 22 leads, incorporate probe
evidence and narrow confidence updates consistently in both registers, resolve or explicitly defer
each lead, complete named coverage and final QA. Post-await identity race still needs deterministic
probe or explicit deferral. Then run current analyzer/tests/format/synchronization and assess seven
acceptance criteria. Do not begin A3 or remediation.

No A2 artifacts survived on disk from the interruption. Historical reports were recovered, not
restarted. `phases/A2_FLUTTER.md` now preserves reviewer/session provenance, exact newly read workout
paths, 22 untriaged leads, concurrency subclaims, current checks and remaining acceptance gaps.

- **Registered findings:** 17 (P0 0, P1 4, P2 6, P3 5, P4 2; Confirmed 2, High 13, Medium 2).
  Status: Needs Verification 3, Accepted 12, Fixed 1, False Positive 1. Added FND-SEC-002 (unchecked
  cross-owner local backup, independently inspected by QA); CONC-001/DATA-001 evidence appended,
  confidence unchanged. Prior 16-finding table below is A1 history, not current totals.
- **New work:** sequential QA concurrency/isolation review, Flutter workout presentation review,
  context/coverage consistency review; no child task remains in flight.
- **Rejected assumption:** signout does not reset controller memory/timers. Auth-ID watch at
  controller:85-94 resets both. Backup replay is a distinct unchecked-owner path.
- **Concurrency:** historical deleted test reported stuck discard and queued completion, with
  repository cancelCalls=0. No retained probe rerun; keep Medium/Needs Verification. Post-await null
  race is separate and not confirmed; independent QA suggested reconsidering severity after repro.
- **Client completion:** concurrent calls coalesce; retry uses workout ID. Post-RPC detail fetch may
  fail separately. No authoritative XP duplication or server idempotency verification was performed.
- **Coverage:** 3 reviewed / 15 in review / 8 not reviewed / 1 out of scope. All A2-target rows name
  reviewers, but stage closure is pending candidate reconciliation and focused verification.
- **Current verification at 7eb40f1:** `flutter analyze --no-pub` -> `No issues found! (ran in 4.2s)`;
  formatting -> `Formatted 125 files (0 changed) in 0.73 seconds.`; `flutter test --no-pub --reporter
  expanded` -> `+126: All tests passed!`; all exit 0 (`PASS`). These do not prove missing probes.
- **Artifact checks:** orchestrator inline Node JSON/MD validator -> `findings MD=17 JSON=17;
  required fields=22`, zero mismatches, counts 3/15/8/1; `git diff --check` -> no whitespace errors;
  status -> eight authorized docs only (`PASS`). Independent artifact QA's Node command was
  `BLOCKED` by `Permission denied: shell`; no permission change/bypass. Its Git checks ran.
- **Changed files:** `docs/audit/phases/A2_PROBES.md`, `docs/audit/phases/A2_FLUTTER.md`, `docs/audit/MASTER_FINDINGS.md`,
  `docs/audit/FINDINGS_REGISTER.json`, `docs/audit/AUDIT_COVERAGE.md`, this file;
  `docs/planning/TASK_BOARD.md`, `docs/planning/SESSION_HANDOFF.md`, `docs/planning/CHANGELOG_AI.md`.
- **Authorization:** current user supersedes section 6's historical no-commit/no-push clause only
  after A2 completion; no rewrite. No Git checkpoint commit or push made while incomplete.
- **Decisions:** no architecture/schema/dependency/permission decision. Top current A2 state takes
  precedence over historical A1 baseline/next-action blocks retained below.
- **Blockers:** no external blocker established. Unfinished focused reproduction, candidate triage,
  UI runtime gaps, register reconciliation and final independent QA prevent completion. Exact final
  A3 prompt is still outstanding; **do not begin A3**.

**Exact next action (A2):** Sequentially delegate a retained audit-only probe outside permanent app
tests, importing the real controller. Use promptly completing cancellation with call counters to
isolate the discard enqueue cycle; include no-active/direct-cancel controls. Add account-B restoration
of account-A snapshot with remote null/error and same-owner controls. Run with `--no-pub`, quote
results, and preserve harness/instructions. Then reconcile the 22 leads in A2 phase section 5, close
only genuinely covered components, obtain QA, draft exact A3 handoff, check all seven acceptance
criteria, and only then commit/push normally on main. No product change or remediation.

## Historical A1 close (preserved)

**Stage:** A0 `PASS`; A0.1 `PASS`; **A1 `PASS`** (10 new findings, 2 inventory corrections)
**Baseline:** `main` @ `c9cc764` = `origin/main` after the A1 checkpoint push; A1 was measured at
`e8c7c8e`, which is still the parent commit
**Next stage:** **A2 — Flutter app, state management, lifecycle, concurrency, navigation** (`READY`,
not authorized until the instruction in §6 is given)

---

## 1. Where the program is

| Stage | Scope | Status |
|---|---|---|
| A0 | Bootstrap, baseline, inventory, plan | `PASS` — `phases/A0_BOOTSTRAP.md` |
| A0.1 | Governance fix + A0 checkpoint | `PASS` — `phases/A0_1_GOVERNANCE.md` |
| A1 | Architecture, dependencies, configuration, infrastructure, CI | `PASS` — `phases/A1_ARCHITECTURE.md` |
| A2 | Flutter app, state, lifecycle, concurrency, navigation | In progress — partial recovery; see current section above |
| A3 | Supabase, PostgreSQL, RLS, auth, Edge Functions | `PLANNED` |
| A4 | Workout lifecycle, XP, progression, rewards | `PLANNED` |
| A5 | Tests, performance, reliability, observability | `PLANNED` |
| A6 | Reconciliation, verification, triage, remediation plan | `PLANNED` |

No stage auto-advances. Remediation has not started and must not start from this handoff.

## 2. Current finding state

| ID | Title | Sev | Conf | Status | Wave |
|---|---|---|---|---|---|
| `FND-CONC-001` | Re-entrant deadlock + post-await null deref in active workout controller | P1 | Medium | `Needs Verification` | W1 |
| `FND-DATA-001` | Legacy completion path can award twice | P1 | Medium | `Needs Verification` | W1 |
| `FND-BUG-001` | Android release manifest declares no `INTERNET` permission | P1 | High | `Accepted` | W1 |
| `FND-ARCH-001` | XP write invariant narrower than implementation | P2 | High | `Accepted` | W1 |
| `FND-GOV-001` | No agent could write `docs/audit/**` | P2 | Confirmed | **`Fixed`** (A0.1, end-to-end verified) | W0 |
| `FND-BUG-002` | Release build signed with the debug keystore | P2 | High | `Accepted` | W1 |
| `FND-TEST-001` | CI cannot detect platform, formatting, or generated-code regressions | P2 | High | `Accepted` | W3 |
| `FND-GOV-004` | Git approval gates do not match `AGENTS.md` §8 | P2 | High | `Accepted` | W1 |
| `FND-SEC-001` | Shell secret gates cover a short list of command spellings | P2 | High | `Accepted` | W1 |
| `FND-GOV-002` | `PROJECT_CONTEXT.md` is stale on its own baseline | P3 | Confirmed | `Accepted` | W4 |
| `FND-GOV-003` | Shell matcher semantics for chained commands | P3 | High | **`False Positive`** (A0.1) | — |
| `FND-INTG-001` | Documented local auth redirect is not in the Auth allowlist | P3 | High | `Accepted` | W4 |
| `FND-ARCH-002` | Two localization mechanisms; the standard one carries no product text | P3 | High | `Accepted` | W4 |
| `FND-ARCH-003` | Stated timezone invariant is narrower than the per-user implementation | P3 | High | `Accepted` | W4 |
| `FND-BUG-003` | Platform display name is the Flutter template default | P4 | High | `Accepted` | W1 |
| `FND-GOV-005` | Stale analyzer transcript tracked as `app/analysis.txt` | P4 | High | `Accepted` | W4 |

Totals: **16 findings** — 0 `P0`, 3 `P1`, 6 `P2`, 5 `P3`, 2 `P4`. Confidence: 2 `Confirmed`,
12 `High`, 2 `Medium`. Status: 2 `Needs Verification`, 12 `Accepted`, 1 `Fixed`, 1 `False Positive`.
Markdown and JSON agree; verified by a script that compares every ID, severity, confidence and status
pair (`phases/A1_ARCHITECTURE.md` §13).

`FND-CONC-001`, `FND-DATA-001` and `FND-ARCH-001` are inherited from S3 and have **not** been
re-verified. Every A1 finding is `High`, not `Confirmed`: each rests on a static read, and the runtime
step that would promote it is recorded as `NOT RUN` with its reason in `phases/A1_ARCHITECTURE.md`
§12.1.

## 3. Git state

| Item | Value |
|---|---|
| Branch | `main` |
| HEAD at A1 entry | `e8c7c8e7e346790ac1807dc5c8d4e43c2ee880ef` (`e8c7c8e`) |
| `origin/main` at A1 entry | `e8c7c8e` — equal to local |
| Tree at A1 entry | clean, `git status --porcelain=v1` → 0 entries |
| History | linear: `e8c7c8e → 947da1e → 425686c → e400dbc → 9c8e142 → 59450c0 → b4063c6 → 17ca562` |
| A1 checkpoint commit | `c9cc7649f582a7740232fb206d5319bd32c0db99` — `docs(audit): complete A1 architecture, dependencies and infrastructure audit`; 8 files, +1,716/−181 |
| Push | `git push origin main` → `e8c7c8e..c9cc764  main -> main`, exit 0 (normal push, authorized for this task) |
| `origin/main` after push | `c9cc7649f582a7740232fb206d5319bd32c0db99` — `git ls-remote origin refs/heads/main` equals local `git rev-parse HEAD` |
| Tree after commit | clean — `git status --porcelain=v1` empty |
| History operations | no reset, rebase, checkout, stash, clean, or force-push. **One amend:** the first commit (`149fb09`) carried a UTF-8 BOM at the start of its subject line, produced by PowerShell `Out-File -Encoding utf8`; the user approved `git commit --amend` on the still-unpushed commit to remove it, yielding `c9cc764`. Nothing had been pushed before the amend |

## 4. What A1 actually did

Covered every item in the A0.1 §6 prompt; nothing was skipped. Detail and quoted output are in
`phases/A1_ARCHITECTURE.md`.

| Area | Result |
|---|---|
| Baseline and acting agent | `PASS` — branch, HEAD, remote and tree verified; acting agent proven from the server as `gymlvl-orchestrator` |
| Toolchain | `PASS` — local Flutter 3.38.5 / Dart 3.10.4 matches the CI pin and the lock `sdks:` floor |
| `flutter analyze` | `PASS` — `No issues found! (ran in 2.5s)`, exit 0 |
| `dart format --set-exit-if-changed` | `PASS` — `Formatted 125 files (0 changed)`, exit 0 |
| Architecture vs code | Runtime topology matches the docs; the module map is incomplete (`ui/theme`, `ui/widgets`, `l10n` missing); one invariant is narrower than the code (`FND-ARCH-003`) |
| Dependencies | 12 runtime + 7 dev direct deps, all caret ranges; 147 locked packages; 0 git/path deps; no overrides; no dependency-audit gate |
| Lint configuration | `flutter_lints` only — no `analyzer:` section, so "analyze clean" is a baseline-lint result |
| Platform configuration | three release-blocking/template defects found (`FND-BUG-001…003`) |
| Localization | two parallel mechanisms; the ARB pipeline carries 1 of 104 keys (`FND-ARCH-002`) |
| CI | read end to end; 8 gate gaps recorded as `FND-TEST-001` |
| Agent governance | 73 global + 62 agent rules; the evaluator's own probe set `PASS`; 18 added probes → `FAIL (12 probe failures)` → `FND-GOV-004`, `FND-SEC-001` |
| Migrations | scheme `YYYYMMDDHHMMSS_snake_case.sql`, enforced by `tools/db-tests/run.mjs:30`; 17 tables all `IF NOT EXISTS`; 44 policy statements → 22 effective at tip; 11 `SECURITY DEFINER`; 10 triggers; no destructive DDL |
| Config contracts | 5 of 7 hold; the auth redirect contract is broken (`FND-INTG-001`) |
| Documentation currency | 15 stale claims inventoried across nine documents; dated blocks and stage records classified as not stale (`FND-GOV-002` inventory complete) |
| Coverage | C-22 `Reviewed (static)`, C-25 extended, C-26 `Reviewed (static)` |

Two A0 measurement figures were corrected: migrations 1,222 → 1,377 total / 1,219 non-blank, and
`verify.yml` 58 → 52 lines. Both are audit-internal fixes; neither changes a finding.

## 5. Files owned by this program

Created at A0 (8 files):

```text
docs/audit/README.md
docs/audit/AUDIT_SCOPE.md
docs/audit/AUDIT_COVERAGE.md
docs/audit/MASTER_FINDINGS.md
docs/audit/FINDINGS_REGISTER.json
docs/audit/REMEDIATION_PLAN.md
docs/audit/SESSION_HANDOFF.md
docs/audit/phases/A0_BOOTSTRAP.md
```

Created at A0.1: `docs/audit/phases/A0_1_GOVERNANCE.md`.
Created at A1: `docs/audit/phases/A1_ARCHITECTURE.md`.

Planning updates (per `AGENTS.md` §6): `docs/planning/TASK_BOARD.md`,
`docs/planning/SESSION_HANDOFF.md`, `docs/planning/CHANGELOG_AI.md`.

`docs/audit/REMEDIATION_PLAN.md` was deliberately **not** updated: its own update trigger is "stage A6,
then after each wave". A6 populates it from the 16-finding register.

## 6. Exact next action — A2

Run the following as one scoped stage. Do not begin A3 inside it.

> **A2 — Flutter app, state management, lifecycle, concurrency, navigation, UI integration.**
> Read `docs/audit/{AUDIT_SCOPE,AUDIT_COVERAGE,MASTER_FINDINGS}.md`, `docs/audit/SESSION_HANDOFF.md`
> and `docs/audit/phases/A1_ARCHITECTURE.md` first, then perform a read-only review of
> `app/lib/**` and `app/test/**` in this order: bootstrap and dependency injection
> (`main.dart`, `core/config`); router and shell (`core/router/**`, deep links, auth redirect,
> active-workout banner); theme and design tokens (`core/theme/**`, `ui/candy/**`, `ui/theme/**`);
> shared widgets (`ui/widgets/**`); localization behaviour (`core/localization/**` plus the VI/EN
> rendering question left open by `FND-ARCH-002`); then each feature in dependency order — auth,
> onboarding, dashboard, workout (presentation only), quests, progression (display half), profile,
> coach.
> Re-verify the carried candidates `FND-CONC-001` (reproduce the `discardLocalBackup` re-entrancy with
> a fake repository whose `cancel` never completes, and assert with a timeout) and the presentation
> half of `FND-ARCH-001`.
> Deliverables: `docs/audit/phases/A2_FLUTTER.md`; new findings in the register with all required
> fields; coverage updated for C-01…C-05, C-07, C-08, C-16 and the presentation half of
> C-10/C-11/C-12; handoff updated with Git state and the next action.
> Constraints: no code or configuration change, no dependency install, no commit, no push.
> Report to the user in Vietnamese.

### Executor and method for A2

- **Executor:** the acting primary agent coordinates and writes every artifact. Delegate
  `flutter-specialist` for controller/state/lifecycle review, `ui-ux-specialist` for layout, theme,
  accessibility and VI/EN rendering, `qa-reviewer` for an independent read of the concurrency claim,
  and `context-keeper` only if a documentation conflict appears. Run shell-dependent subagents
  **sequentially** (D-021); read-only work may be parallelised, but sequential is safer.
- **Every new finding must carry all fourteen fields** listed in `README.md` §8 plus `wave` and
  `verification_method`, in both `MASTER_FINDINGS.md` and `FINDINGS_REGISTER.json`.
- **Confidence ceiling for A2:** `Confirmed` only where a command was run and its output quoted. A
  reproduction of `FND-CONC-001` via `flutter test` would qualify; a read of the controller would not.
- **Do not re-open `FND-ARCH-002` as a new finding.** It is registered; A2 supplies the rendering
  evidence its remediation depends on.

### Acceptance criteria for A2

1. `docs/audit/phases/A2_FLUTTER.md` exists and covers every item in the prompt above, or states
   explicitly which item was skipped and why.
2. Every new finding is in both the register JSON and the markdown with identical ID, severity,
   confidence and status; the JSON parses; declared counts equal actual counts.
3. `AUDIT_COVERAGE.md` shows an updated status and a named reviewer for C-01…C-05, C-07, C-08, C-16 and
   the presentation half of C-10/C-11/C-12.
4. `FND-CONC-001` is either reproduced with a named command whose output is quoted, or explicitly
   recorded as still unverified with the reason.
5. `SESSION_HANDOFF.md` records Git state, what A2 actually did, open investigations and the exact A3
   prompt.
6. No file outside `docs/audit/**` and the three planning files was modified, verified by
   `git status --porcelain=v1`.
7. The user report is in Vietnamese, with `PASS`/`FAIL`/`BLOCKED`/`NOT RUN` and quoted evidence.

## 7. Open investigations carried into A2

| Item | State after A1 |
|---|---|
| `FND-CONC-001` reproduction | Open. Not attempted in A1 (concurrency is A2/A4 scope). Needs a fake repository whose `cancel` never completes, plus a timeout assertion. |
| Permission-gate enforcement | Open, and deliberately not closed by a live probe. `FND-GOV-004` and `FND-SEC-001` are `High`; promoting them requires user approval to issue one destructive command per spelling. |
| Android merged release manifest | Open. `FND-BUG-001` rests on the merger rule, not on a produced artifact. One `flutter build apk --release` would confirm it. |
| Auth redirect runtime behaviour | Open. `FND-INTG-001` needs `supabase start` and one `POST /auth/v1/recover`. |
| Generated-code drift | Open and **unmeasured**: running `build_runner` writes files, so A1 did not check whether the committed `*.freezed.dart` / `*.g.dart` are current. This must be measured before `FND-TEST-001`'s drift gate is enabled. |
| CI runner behaviour | Open. `FND-TEST-001` is a static read of the workflow; no CI run was observed from this session. |
| Localization rendering | Open. `FND-ARCH-002` records the architecture; VI/EN rendering, diacritics and the `bilingual` mode are A2 (C-05). |
| Migration history on a remote | Open. A1 established the local scheme and its enforcement; which migrations a remote has applied is A3. |
| `FND-ARCH-001` fourth-writer question | Open. A4 owns it; the wording fix must not land before then. |
| A1 artifacts | `docs/audit/phases/A1_ARCHITECTURE.md` exists and is complete. |

## 8. Anything a resuming session must not assume

- That `flutter analyze` clean means the code is strictly typed. `analysis_options.yaml` enables
  nothing beyond `flutter_lints`.
- That the permission layer enforces `AGENTS.md` §8. It gates 6 of 18 probed operations.
- That a release build works. It cannot reach the network, and it would be signed with a debug key.
- That CI would catch either. It builds web only.
- That the ARB files are the product's text. They hold one key of 104.
- That A0's inventory numbers are exact. Two were off; both are corrected in `AUDIT_COVERAGE.md` §2.
- That a previous stage's findings are verified. Only `FND-GOV-001` has a verified fix.
