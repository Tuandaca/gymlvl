# A7 — W0/W1 batch remediation execution

**Entry/task:** main `3d9dbb038a3a7e93ee4b3d4c51b10d8e066dbf75`, 2026-10-29, clean/remote equal.
**Status:** IN PROGRESS; task checks use PASS/FAIL/BLOCKED/NOT RUN, external verification is a gap
description rather than an invented verification status. Migration readiness remains NOT READY.
**Primary:** OpenCode API metadata confirms gymlvl-orchestrator. Orchestrator delegates application
and permanent-test writes to specialists; no application code written by orchestrator.

## 1. Scope, approvals and internal dependency checkpoints

User explicitly approved all R0-01..R0-04 and R1-01..R1-07, separately R1-01 snapshot ownership,
local non-destructive source/tests, logical commits and push to origin/main. D-025 records scope;
D-026 default shell ask, D-027 additive ACL/fail-closed policy, D-028 byte budgets approved separately.
No B2-B4/W2-W5, production/deploy, destructive data/history, secret exposure, OpenGym or media.

Actual grouping: R0-01 first; B0 permission/ACL/resource tasks independently depend on it. B1 R1-01
then R1-02 then R1-03/R1-04; R1-05/R1-06/R1-07 independent of that chain after R0-01. Separate file
writers run sequentially. R1-04 verification-first and R1-07 real sessions require an actual supported
isolated target; never substitute single-connection Promise.all. R1-06 key custody/strategy/artifact
checks remain subject to governance, never read keys to make a build pass. No estimates or whole-repo
rescan. Ownership is delegated with exact paths and recorded per task; orchestrator owns planning/
register/execution documentation only. Tests accompany fixes; broader regression at batch boundaries.

## 2. R0-01 safety checkpoint

Entry commands: branch main, HEAD full SHA above, status empty, origin/main fullSHA equal; API primary
gymlvl-orchestrator. D-013 backup `...\Temp\opencode\gymlvl-a7-backup-20261029`: bundle all refs,
bare clone equals HEAD, archive560/tree560 files; `A7_BACKUP_EXIT=0`. Bundle SHA256
66DA9D0EA3C047CB41BC3E6EE836E1BBF3C49FC581FCD6EFBEC9B2324C1A30B7; ZIP SHA256
16141BBD4E1E6E66B134FC9D630606024604963F02426D85091F38324FA38038.
No extracted runnable app copy or old-directory deletion. All35 finding IDs/history retained.

Executed inline Node safety-check model (assert/strict): allowed iff B0/B1 scope, task and material
approvals, clean/backed tree, explicit owner, tests and rollback all true. Six assertions ->
`R0_01_CHECK missing_approval=denied approved_scoped_task=allowed B2=denied missing_policy=denied missing_owner=denied unsafe_tree=denied assertions=6 errors=0`, exit0.
This is checklist logic, not a sandbox or product test. Actual owner approvals were then collected
with question tool and recorded in D-025..028 before implementation. Independent QA checkpoint pending.

## 3. Task ledger

- R0-01: PASS; six safety assertions, explicit owner approval/backup/scope, independent QA inspection
  found no material prerequisite contradiction. This checklist is reapplied at each task boundary.
- R0-02: PASS repository-scoped policy correction and32 permanent synthetic policy tests; live
  scanner/saved-approval enforcement NOT RUN, no sandbox guarantee.
- R0-03: PASS repository additive migration and10isolatedDB/365assertions; deployment/fullgateway
  NOT RUN, no deployed ACL/future-admin-grant guarantee.
- R0-04: PASS bounded-body implementation/focused29/fullEdge44/six typechecks; actual network
  cancellation, hosted DoS/resource measurements and deployment NOT RUN.
- R1-01: separately approved; policy owner-match before restore/render, remote null/error no bypass,
  foreign/ownerless snapshot preserved and not exposed/reassigned; same-owner offline recovery retained.
- R1-02/R1-03: eligible only after dependency gates, not started.
- R1-04/R1-07: approved verification-first; current environment prerequisite check pending.
- R1-05: approved independent release-connectivity task, not started.
- R1-06: approved scope; signing strategy/key-custody gate to inspect, no secret reads or artifact claim.

Next: bounded specialist implementation with red/green and independent review; update each ledger row
after actual commands. Old A5/A6 results remain historical, never current remediation PASS.

## 4. B0 implementation checkpoint and actual delegation

All writes sequential, ownership returned between turns:
- supabase-specialist `ses_e7c5368acffenax9uG1LWQNT2g`: R0-03 owns new
  `supabase/migrations/20261029000100_effective_progression_acl.sql`, new
  `tools/db-tests/effective-acl-regression.mjs`, `tools/db-tests/run.mjs`. No original migration edit.
  RED `node tools/db-tests/effective-acl-regression.mjs` ->exit1, prior PUBLIC column own-XP update
  unexpectedly succeeded instead of42501. Initial repair FAIL removed safe column grants through
  table revoke; restored only canonical allowed edits. GREEN initially8DB/357 assertions, then QA-
  requested inherited-owner/superuser controls ->`PASS effective ACL regression: 10 isolated databases,
  365 assertions`, exit0. Transaction rollback, RLS, named/PUBLIC/default-materialized/inherited
  authority, safe edits/two users/anon/service and completion/replay controls included.
- Same backend session R0-04, separate turn: owns new `_shared/bounded_body.ts`, `_shared/http.ts`,
  `ai-coach/service.ts`, new `tests/bounded_body_test.ts` under `supabase/functions`. RED actual
  original handlers:4pass17fail/exit1 (413 expected vs200, provider accepted, missing cancellation);
  GREEN focused29/fullEdge44/six entrypoint checks exit0. UTF8 caps16384/20000/262144, auth-before-
  body, cancel/release locks, quota/semantics/error contracts retained; malformed upstream JSON503
  unchanged. A delivered chunk may already exceed retained byte budget; no transport/DoS claim.
- flutter-specialist `ses_e7c46447fffe6xRQuhbJ2twX94`: R0-02 owns
  `.opencode/opencode.jsonc`, `.opencode/agents/qa-reviewer.md`,
  `.opencode/agents/context-keeper.md`, new `tools/agent-tests/permission_policy.test.mjs`.
  RED `node --test tools/agent-tests/permission_policy.test.mjs` ->7pass/15fail, expanded cases
  ->7pass25fail; GREEN32pass0fail. Global fallback ask, no broad interpreter exception; removed
  reviewer broad Get-Content/Select-String allows and narrowed git-branch inspection forms so they
  cannot override secret/deletion gates. Reviewer edit/shell/network/delegation restrictions retained.
  Test model covers all seven appended policies, not live scanner or current saved approvals.
- qa-reviewer `ses_e7c4250a1ffeXk30ceIhMb3Jvk`: independent B0 source/test inspection, no material
  code blocker; owner/superuser fixtures requested and added. R0-01 actual recorded gate ready.
  Flagged missing durable implementation evidence in this ledger (FAIL), corrected here before Fixed.
  `npm test` could not start because npm.ps1 disabled by OS execution policy; exact source-filter Git
  command denied. Neither retried/bypassed; no runtime QA PASS claimed. Parent's independently planned
  explicit Node runner and Deno commands below provide current execution, no OS/config policy bypass.
  Nested QA attempt by backend hit depth limit; actual independent parent invocation above succeeded.

Parent batch-boundary verification, current task/source at main3d9dbb0 plus authorized changes:
- `node --test tools/agent-tests/permission_policy.test.mjs` ->tests32/pass32/fail0, exit0.
- `node tools/db-tests/run.mjs` ->11 SQL units/PostgreSQL17.5 +10DB/365 ACL assertions, exit0.
- Installed Deno direct `test --cached-only --deny-net --allow-env=SUPABASE_URL,SUPABASE_ANON_KEY,
  SUPABASE_PUBLISHABLE_KEY --frozen --lock supabase/functions/deno.lock supabase/functions` using
  explicit synthetic public env ->44passed0failed, exit0; six handlers cached/frozen check exit0.
- `git diff --check` ->0; `A7_B0_REGRESSION policy=0 sql=0 edge=0 diff=0`.
No full Flutter run for a non-Dart B0 boundary; scheduled once at meaningful B1 boundary.

Logs retained under approved Temp path: `gymlvl-r0-03-{acl-red,acl-green,acl-green2,acl-final,sql-runner}-3d9dbb0.log`,
`r0-03-owner-superuser-followup-3d9dbb0.log`, `r0-04-{red,green,focused-final2,edge-full2,six-checks2}-3d9dbb0.log`.
Permanent tests retain executable reproduction/control logic; red errors above explicitly recorded.

B0 register-only backend turn changed exactly GOV004/SEC001/SEC003/SEC004 to Fixed in repository
scope, kept confidence/severity and full historical_pre_a7 objects,31 other objects unchanged.35 total;
Accepted25/NV3/Fixed5/FP2, severity0/3/24/6/2 confidence16/18/1 unchanged. Validator exit0:
`json=35 histories_exact=4 old_objects_unchanged=31 raw_spans_unchanged=31 md=35 md_classes_match=35 prior_metadata=preserved new_ids=0 errors=0`.
Initial register validator FAIL due pre-existing HTML imbalance; corrected to check four new wrappers,
no historical text repaired. Runtime/deployed uncertainty is not silently marked verified.

Next: verified B0 checkpoint, then authorized R1-01 (same-owner/foreign/ownerless policy D025), R1-02,
R1-03; independent R1-05 and environment/signing checks remain eligible. Do not stop at this checkpoint.
