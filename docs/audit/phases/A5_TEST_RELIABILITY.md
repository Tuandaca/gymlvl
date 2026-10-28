# A5 — Testing, reliability, performance and observability audit

**Task:** A5 ONLY; 2026-10-28. **Status:** scoped acceptance NOT RUN, in progress.
**Entry:** main `1763ab55e8da994bc1d854ad8fd2cd2299678b45`, clean and remote-equal.
**Primary:** API metadata session `ses_e7e81bc84ffeWkbb0tV5jo0jwp` ->gymlvl-orchestrator.
No A6, remediation, migration, product/permanent-test/CI/dependency/config changes authorized.

## 1. Scope, finite acceptance and ownership

A5.1 test architecture/regression gaps; A5.2 Flutter lifecycle/widgets/recovery; A5.3 transactions/
retries/concurrency; A5.4 Edge/Auth/errors/resource limits; A5.5 performance/scalability/resources;
A5.6 observability/failure recovery; A5.7 cross-domain reconciliation/independent QA. Review C23/C24.
User's numbered scope is authoritative; the older handoff has the same subject buckets without
numbers. Read mandatory planning context and current audit handoff/coverage/register metadata;
specialists restore only relevant A2/A3/A4 deferred assertions, not duplicate whole-repository scans.

Closure criteria: mandatory scope reviewed; exact source/assumption/evidence per finding; stable30
prior IDs/history; finite unexecuted checks dispositioned with owner/trigger/assertion; independent
material QA; current registers/coverage/handoffs consistent; applicable safe checks honestly reported.
No exhaustive runtime/production verification, remediation or mandatory new infrastructure gate.

Orchestrator owns this phase, findings mirrors, coverage, audit handoff and three planning records.
Bounded sequential specialist exceptions: new A5_FLUTTER_EVIDENCE.md + unused external Flutter probe
directory (flutter-specialist), new A5_BACKEND_EVIDENCE.md + unused external backend probe directory
(supabase-specialist), new A5_UI_EVIDENCE.md + unused external UI probe directory (ui-ux-specialist).
No shared-file concurrent writer. Register write remains orchestrator until explicitly reassigned.
All probes synthetic, installed dependencies only; no real users, secret reads, provider/live DB,
deployment, media, full-app Temp copy, prior-directory deletion or permission widening.

## 2. Entry, backup and actual sequential delegation

`git rev-parse --abbrev-ref HEAD` ->main; `git rev-parse HEAD` ->1763ab55e8da994bc1d854ad8fd2cd2299678b45;
`git status --porcelain=v1` ->empty; `git ls-remote origin refs/heads/main` ->same fullSHA (PASS).
API command ->primary gymlvl-orchestrator. Existing historical PASS is not a current result.

D-013 backup before memory edits: new external `...\Temp\opencode\gymlvl-a5-backup-20261028`;
`git bundle create refs.bundle --all`, `git clone --bare refs.bundle verify.git`, `git archive
--format=zip -o head.zip HEAD` and .NET ZIP-entry versus `git ls-tree` comparison ->
`A5_BACKUP head=1763ab55e8da994bc1d854ad8fd2cd2299678b45 bundle_clone=1763ab55e8da994bc1d854ad8fd2cd2299678b45 archive_files=555 git_tree=555`, `A5_BACKUP_EXIT=0`.
No extracted app or new runnable full-app copy; only bundle, bare verification repo and archive.
SHA256 refs.bundle ADEA37409DFD4E9DBF14C8075E92A1C2723DD2CCBF8F18FA30391227CF2F1C3B;
head.zip17EE20DD708727E204F3ABB1FA295107364969F127B01D8DD5C1FE2C3B78007B.

- **context-keeper / ses_e7cee471effem1IORTQYzbIfD5: completed inspection.** Restored finite
  backlog, all30 IDs/current meanings, exact A6 scope; status empty/HEAD=main entrySHA. No runtime.
  Flagged stale audit-track table A4 NEXT at TASK_BOARD184. Current top/audit handoff outrank the
  preserved older table; reconciled only A4/A5 rows below, no plan or milestone change. New user's
  numbered A5.1-A5.7 scope supplies numbering absent from old audit docs; not a substantive conflict.
- **flutter-specialist / ses_e7ce90fd3ffeeLIHr9GaipquI6: completed.** All14 test files read (2624
  lines currently,13 discovered test files+manual wrapper), targeted controller/Auth/repository paths.
  New A5_FLUTTER_EVIDENCE.md and exact external probe directory only. Actual app Dart/router/
  repositories, synthetic HTTP/storage/Auth:18 tests pass exit0; analyze no issues(2.5s), exit0.
  Initial18 setup failures traced and externally corrected (mock response.request/router scheduling),
  retained in evidence. No product repair. Lead10 and post-await identity state loss observed;
  lost-ACK/reorder modeled persistence limits, INTG002 hydration and actual Dart quest payloads retained.
- **supabase-specialist / ses_e7cd77b48ffeZHLn1kSE9JCIoi: completed.** C23 harness/SQL/Edge tests/
  CI/reliability inspected; new A5_BACKEND_EVIDENCE.md and exact external probe directory only.
  Same-day expiry-only controls, all150 UUID pairs seed replay,12 request/3 provider stream cases,
  SQL10 units, Edge15 tests/six entrypoint checks and100/1000-row synthetic EXPLAIN all exit0.
  Independent sessions BLOCKED: one executable availability check found no Docker/Supabase/Postgres
  target. Auth-before-body controls consume0, full32768bytes before413; multibyte unit/provider
  buffering observations extend SEC004 without proving production DoS. Initial SQL diagnostic alias
  FAIL and three evidence-builder FAILs corrected externally and fully retained; no product change.
- **ui-ux-specialist:** not yet invoked; accessibility/VI-EN/navigation regression coverage only.
- **qa-reviewer:** not yet invoked; independent material evidence and final artifact review.

## 3. Finite inherited assertion matrix

1. Flutter/QA: Lead10 failed-signin->recovery error contamination; success/rejection controls.
   Post-await identity reset while backup removal awaits; completion state and new-user isolation.
   Existing CONC001 subclaim remains unverified; do not rerun accepted queue-cycle/SEC002 probes.
2. Flutter/Supabase/QA: partial reorder, committed-but-lost addSet versus rejected/reloaded controls,
   legitimate zero-row delete versus forbidden/hidden rows, INTG002 post-award hydration/summary.
3. Flutter/QA: actual Dart timed-quest startup/Add Set/save payloads using seeded/generated catalog
   identities; preserve INTG004/005/007 separation and do not claim gateway/SQL E2E from fake repos.
4. Supabase/QA: independent-connection scheduling prerequisites once; if unavailable BLOCKED with
   concrete assertion, never call PGlite Promise.all concurrency. Same/different workout, child-write/
   cancel and lock-wait midnight schedules; one ledger/credit per workout and immutable awarded logs.
5. Supabase/QA: expiry-only same-day controls, invalid/date history policies; full17-table role
   operations/JWT gateway needs actual supported stack; inventory limits without production requirement.
6. Supabase/QA: SEC004 counted streams/cancellation/limits, context/destination/timeout/quota/error
   sanitization; finite synthetic scales/EXPLAIN where feasible, not production latency/DoS claims.
7. UI/Flutter/QA: test architecture14 files, visual/semantics/key/focus/VI-EN/large text coverage;
   actual measured bounded fixtures versus unexecuted device/screen-reader/frame budgets. Missing
   golden/coverage metrics are gaps, not automatically product defects or invented percentages.

Evidence files retain exact full probe source, commands/output, source hashes, initial failed
attempts and limits. Allocate findings only after source/evidence reconciliation and QA; no automatic
promotion from tests passing. Incremental docs checkpoints are explicitly user-authorized.

## 4. First incremental PARTIAL checkpoint

Mandatory Flutter/backend review and finite probes completed; UI/QA/final reconciliation pending.
Whole-stage scoped acceptance remains NOT RUN. Existing30 finding objects/classifications unchanged;
all candidates still need QA/registration. C23/C24 evidence exists but current coverage is not yet
promoted until named review reconciliation. Seven documentation paths only at this checkpoint.
No prior DATA001/CONC001 discard/SEC002/PUBLICACL reproduction repeated. New CONC001 identity-after-
await assertion is distinct from the accepted discard-cycle; fake transport state is not liveSQL.
The inherited INTG007 Dart input gap is exercised, not automatically a full SQL/gateway journey.
Exact commands/source/output/hash boundaries and all failed setup attempts are in the two new
evidence files; later independent material QA will decide bounded finding classifications.
