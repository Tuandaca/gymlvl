# A3 — Supabase, PostgreSQL and security audit

**Task:** A3 only, 2026-10-28.
**Entry commit:** main `f877e40987423f3804fe0d2887c44d19f3423aff`, clean, remote equal.
**Primary agent:** session API `ses_e7e81bc84ffeWkbb0tV5jo0jwp` -> `gymlvl-orchestrator`.
**Validation:** `PASS` for scoped A3 audit acceptance; operational **CLOSED** with explicit deferred work.
**Current state:** final reconciliation in sections10-11 supersedes early progress checkpoints.
All C17-C21 reviewed for A3 scope; SEC003/SEC004 registered and independently inspected. Safe test
results below are current-session evidence, not copied from A1/A2. PASS is not production certification.
**Artifact name:** current user explicitly requests `A3_SUPABASE_SECURITY.md`, superseding the
older handoff's `A3_SUPABASE.md`. No duplicate phase file is created.

## 1. Scope and acceptance boundary

Review C17-C21: all three versioned migrations, effective schema/FKs/constraints/indexes/triggers,
grants/RLS/ownership, SECURITY DEFINER and callable RPC exposure, Auth/config and all Edge handlers,
shared HTTP validation/error paths. Existing SQL/Edge tests are evidence, not a complete A5 harness
audit. DATA001 server ownership/schema context is included, authoritative reward arithmetic/replay
and legacy-data reproduction remain A4. SEC002 backend ownership is reviewed without repeating the
completed Flutter snapshot probes. No production vulnerability is inferred solely from a synthetic test.

Handoff requirements/current user closure conditions, mapped without inventing exhaustive runtime gates:
1. Required components reviewed or explicit gaps/reasons recorded with named coverage.
2. Existing stable findings preserved; new/changed findings traceable with full fields and honest confidence.
3. Deferred runtime work has owner, target stage and concrete assertion.
4. Independent QA reviews material/security conclusions, especially P0/P1 candidates.
5. JSON/Markdown counts/classifications, coverage and current handoffs consistent.
6. Applicable existing isolated SQL/Edge checks executed or BLOCKED/NOT RUN with exact reason;
   authorized edit scope and Git diff verified; no source/config/dependency/schema change.
7. Vietnamese report and exact A4 entry prompt; stop A3, no automatic A4/remediation/migration.

## 2. Safety and verification provenance

Repository entry clean; no backup required for unrelated dirty work. Preserve all A2 evidence and
24 findings. No secret file reads, live/remote database access, accounts, deployment, security-gate
probes, permission changes or dependency installation. The current user permits synthetic isolated
tests: existing PGlite harness may initialize its own in-memory DB from repository migration text;
that is not applying a migration to a persistent/local Supabase or production environment. No real
Supabase stack is started. Test runner source is inspected before execution.

Delegation is bounded and sequential; subagents review without owning artifact writes. Orchestrator
owns this phase, register mirrors, coverage, audit handoff and three planning records. Findings and
test results will be persisted incrementally. Tests not yet executed must not inherit earlier PASS.

## 3. Progress checkpoint

- Entry Git branch/HEAD/status and remote equality verified by current commands.
- Session API metadata verified current primary agent, not merely configuration.
- Existing `tools/db-tests/run.mjs` read: PGlite instantiated without a dataDir; uses checked-in
  bootstrap/migrations/seeds/tests, seed replay, synthetic duration fixture and close().
- `tools/db-tests/edge-tests.mjs` read: uses already-installed Deno, frozen lock and repo cache;
  tests allow env/net, so inspect actual test imports and stubs before running. No installs permitted.
- Component inspections and material findings QA: pending; no component falsely marked reviewed.

**Current next action:** bounded supabase-specialist schema/RLS/RPC/trigger review, then Flutter-side
Auth/Edge boundary review, then independent QA. No A4 semantics investigation.

## 4. Completed review/test checkpoint (before final reconciliation)

- Database review: supabase-specialist `ses_e7d761fbdffe2edaLfVTRRtRfK` read all three migrations,
  config, bootstrap and existing SQL regressions. Effective tip, not baseline alone: 17 RLS tables,
  11 pinned-search-path definers, owner-derived RPCs. Conditional legacy column/PUBLIC ACL inheritance
  needs an isolated synthetic fixture; fresh install not shown vulnerable. Missing FK indexes and
  weak legacy constraints are observations, not cross-user exploit claims.
- Flutter boundary review: `ses_e7d71b2fcffeIug3pXW4BuL2Rv` read config, Auth repository/providers,
  workout and Coach repositories only. No independent security finding: caller sends parent IDs/
  measurements, not authoritative owner/reward values; foreign-ID safety depends on backend RLS/RPC.
- Edge review: supabase-specialist same session read all16 tracked functions/config-support files,
  six handlers and test stubs. Explicit getUser plus caller-token forwarding, no service-role client.
  Body size checked only after buffering req.text() is a resource-boundary candidate; gateway limits
  and deployed JWT behavior unverified. Existing INTG003 reused for Coach history mismatch.
- `node tools/db-tests/run.mjs` -> `PASS 10 SQL verification units against PostgreSQL 17.5`, exit0;
  `VERIFIED exercise catalog count: 150`; static hold/duration CHECK behavior verified. LIMITATION:
  synthetic Auth/bootstrap, single connection, not gateway/Auth/production or multiwriter semantics.
- Installed Deno invoked directly with least-privilege child environment and frozen lock, not wrapper's
  unrestricted net/env flags: `test --cached-only --deny-net
  --allow-env=SUPABASE_URL,SUPABASE_ANON_KEY,SUPABASE_PUBLISHABLE_KEY --frozen --lock
  supabase/functions/deno.lock supabase/functions` -> `15 passed | 0 failed`, exit0. Only OS process
  paths and synthetic SUPABASE_URL/public key were passed; no inherited provider/secret env read.
  Existing tests stub auth/backend/provider transport, real gateway deployment not exercised.
- Same installed Deno: `check --cached-only --frozen --lock supabase/functions/deno.lock` with six
  explicit handler index paths -> six `Check` lines, exit0. No dependencies fetched/installed.
- Current Git status remains five expected audit/planning paths, no product/test/config/lock edits.

**Next A3 action:** retain narrowly scoped in-memory ownership/ACL probes with synthetic A/B roles,
then independent QA; persist complete findings/coverage and A4 handoff. No new A4 reward fixture.

## 5. Effective database tip — C17-C20 reviewed statically

Baseline alone is not the effective security posture. Progression:61-93 enables/replaces policies
and revokes named-role broad table grants, then adds column-specific editing and active-child CRUD.
Catalog migration later changes workout_sets duration CHECK and adds a trigger helper. Review read
all1377 migration lines, bootstrap and both SQL regressions, not only CREATE POLICY grep hits.
All17 tables have RLS; 44 textual policy statements reduce to22 effective policies at tip (A1 census).

Table/ownership/grant/index review (B/P/C = chronological baseline/progression/catalog migration):
- users: Auth-linked id PK, own SELECT, only display_name/avatar_url/locale UPDATE (B6-19, P72,76-77).
- profiles: users-linked id PK, own SELECT, allowlisted measurements/preferences UPDATE; NOT VALID
  measurement CHECK enforces new/changed rows but does not certify legacy rows (B70-82, P34-37,73,78-79).
- exercises: authenticated read-only catalog, UUID PK, unique nullable slug and metadata CHECKs (C6-35).
- workouts: required user FK, user/status/history indexes, status/pause checks; owner read, active notes
  edit only; no direct client INSERT/DELETE (B181-191,347-349; P4-9,26,33,74,80-81).
- workout_exercises: required workout/catalog FKs; active-owned CRUD; trigger rejects parent/exercise
  identity replacement (B197-204,350; P82-83,107-131). Exercise-only FK index absent.
- workout_sets: required indexed parent FK; active-owned CRUD; parent immutable and baseline overwritten
  server-side; final duration CHECK C359-367 supersedes P29-32. Optional numeric NULLs remain possible.
- xp_logs: indexed required user FK, own read-only; source_id text is not a workout FK (B367-385; P87-89).
- streaks: required unique user FK, own read-only; some counters nullable/weakly range constrained.
- exercise_prs: required user/exercise FKs, unique(user,exercise), own read-only; no exercise-leading index.
- quests: read-only catalog; type/reward fields weakly constrained, no demonstrated client mutation.
- quest_instances: required user/quest FKs, user/status and partial user/day unique index, own read-only;
  quest-leading FK index absent, config/status weakly constrained (B437-453,480; P10-12,87-89).
- user_classes: required user FK/index, unique user/slot and user/class, slot/difficulty CHECKs;
  class_id has index but no FK; own read-only (B503-521,642-643; P87-89).
- class_definitions: text PK, difficulty CHECK, authenticated read-only (B538-548; P40-49,90-92).
- class_synergies: composite PK/FKs, secondary-leading FK index absent, authenticated read-only.
- workout_rewards: workout PK/FK and indexed user FK, result NOT NULL, own read-only; trusted writer
  establishes user/workout alignment, no composite ownership constraint (P13-18,25,87-89,280).
- user_achievements: user/achievement PK/FK and achievement allowlist, own read-only (P19-24,87-89).
- coach_daily_usage: user/date PK/FK, request_count0-20 CHECK, own SELECT, server-only counter (P330-349).

Missing FK indexes, NOT VALID legacy checks and server-managed non-FK values are recorded improvement/
integrity observations, not automatically vulnerabilities. A4 owns domain-coherence tests; A5 owns
query/cascade EXPLAIN measurements. No index or constraint remediation in A3.

## 6. Functions, triggers, migrations and Auth/config

All11 SECURITY DEFINER functions pin search_path='' and qualify application relations. Function
execution ACL changes at P325-326 revoke default PUBLIC/anon/helper exposure and selectively grant
authenticated RPCs. No client-chosen SQL/RPC name or reward/owner parameter is trusted in reviewed paths.

- handle_new_user P96-103: trigger only, revoked callable execution, NEW Auth identity and truncated
  display metadata, not user-supplied progression.
- initialize_user P137-157: auth.uid required, locks caller user, validates profile/class/timezone,
  completed onboarding short-circuits; derived initialization is existing ARCH001, not extra award.
- start_workout P159-167: locks own user, requires onboarding, reuses owned active workout.
- begin_workout/set_workout_paused/cancel_workout P168-190: supplied UUID plus user_id=auth.uid,
  row locks, active/completed-state guards, server timestamps. Foreign UUID probes reject42501.
- sync_daily_data P192-214: own user/profile/streak/quest, selected exercise IDs come from catalog.
- complete_workout P216-238: owned workout/user locks before ledger/flag/replay checks. Foreign
  completion denied. Legacy award-state hypothesis DATA001 stays unverified for A4; arithmetic not audited.
- switch_class P285-305: allowed A-F/slot, caller-scoped derived history; no supplied class XP authority.
- get_user_stats P307-321: no user parameter, uid predicates on private data.
- consume_coach_request P340-349: uid-derived atomic upsert count, direct calls consume own quota only.

Invoker helpers update_modified_column, guard_workout_child and workout_json have empty search_path
and client execution revoked (P95,107,133-135,325). Trigger execution is not a public RPC bypass.
Child trigger locks parent, checks auth owner/status, blocks parent/exercise identity change and
freezes/derives baseline. Administrative DELETE exception requires null uid and named privileged
current_user; not reachable merely by omitting a client user ID (P111-125).
Later set_exercise_slug_default (C38-78) is invoker/trigger-only, lacks pinned search_path/explicit ACL
cleanup but uses NEW/built-ins and client catalog INSERT is denied: hygiene drift, no demonstrated
definer escalation. Do not mislabel it an elevated callable data writer.

Migration ordering: three14-digit version names sorted by harness regex, no destructive table/column
DDL, intended policy replacement. Fresh harness validates application and seed replay, **not migration
idempotence or reconciliation of every pre-existing database**. PUBLIC ACL counterexample SEC003
and explicit header warnings show why adopted/deployed catalogs require separate approved inventory.

Config reviewed as dev repository contract, not deployed posture: API public/graphql schemas,
max_rows1000 (not write quota), Auth refresh rotation, no anonymous signin/manual linking,
configured rate limits, six verify_jwt=true functions (config398-422). Password minimum6, disabled
email confirmations/secure password change/MFA are local settings, not proof production disables
them. Redirect mismatch stays INTG001. No secret files/values inspected; env names only.

## 7. Edge HTTP and trust boundaries — C21 reviewed statically

Read all16 tracked files: six index.ts (ai-coach/calculate-xp/get-user-stats/initialize-user/
switch-class/sync-daily-data), shared http.ts/validation.ts, Coach service.ts/service_test.ts,
tests/http_handler_test.ts/request_validation_test.ts, import_map.json/deno.lock,
switch-class/deno.json/.npmrc. Lock version mix not assumed a vulnerability.

Configured gateway JWT is paired with explicit getUser on caller Bearer token (http19-27,
ai-coach/index14-28). Database client uses public key plus same token, not service_role. Wrappers
choose fixed RPC names, UUID/class/slot validators and selected parameters; calculate-xp merely
forwards complete_workout, not client XP. initialize-user passes nested/flat profile for SQL validation.
Coach quota/context scoped to verified uid, last7days and7 parent workouts, text output only; no AI
workout/reward tools. No source-supported request-controlled upstream URL/owner/privileged key.

POST/OPTIONS/CORS, object-shaped JSON, stable400/401/403/413/503 mapping and sanitized SQL/provider
errors are implemented. Wildcard CORS without credential cookies is not Bearer auth bypass. Coach
validates roles/history/message, HTTPS config, quota before provider, 15s fetch abort; provider URL
is config-only, no demonstrated user SSRF. Host/private-IP/redirect policy, nested context size,
whole-operation timeouts and attempt-vs-success quota are bounded deferred policy/tests, not asserted
exploits. Prompt filtering is defense-in-depth, not proof prompt injection impossible.

Both HTTP paths authenticate before req.text, but size checks follow full buffering and count UTF-16
units, not streamed bytes (http33-40; service35-48). Coach quota is later. SEC004 records this source
order with gateway/resource effects still unverified. Upstream JSON also parses before answer cap.
The 4000-history versus12000-answer mismatch remains INTG003, not a duplicate new finding.

## 8. Material findings and rejected hypotheses

- **SEC003 P2/Confirmed/Accepted:** conditional PUBLIC UPDATE(total_xp) grant survives role-specific
  hardening and permits own authenticated XP=777 in synthetic DB. Not installed by these migrations;
  fresh control denies. Unknown deployed prevalence prevents a production-vulnerability claim.
- **Rejected subclaim:** explicit authenticated column-grant survival was false. Default retained
  probe FAIL/exit1 (false!==true); original assertion retained, diagnostic denial exits0. Never conceal
  this by calling the entire custom suite green. PUBLIC cases independently PASS, exit0/14 assertions;
  named control PASS, exit0/4 assertions. Exact source and all per-variant assertions in A3_SQL_EVIDENCE.
- **SEC004 P2/High/Needs Verification:** authenticated buffering order source-proven; synthetic stream/
  deployed gateway resource effects NOT RUN. P2 provisional, not a confirmed denial-of-service exploit.
- **SEC002 backend addendum:** fresh synthetic B cannot read/operate A workout/children, including
  foreign begin/pause/cancel/complete, insertion and reassignment; no A mutation/award. Does not repair
  local snapshot adoption or prove all-table/gateway/production isolation.
- **DATA001:** locks/guards inspected. Existing regression already covers completed-unrewarded recovery
  and true-flag denial; not previously-awarded false-flag/no-ledger cohort. P1/Medium/Needs Verification
  unchanged; full legacy/cohort/reward verification A4, no live population assumption.

Independent material QA `ses_e7d65e214ffe7eUtkCJwn4XCxl` supports narrow classifications by source
inspection, challenged inaccurate assumptions and corrected DATA001 test-gap wording. External
probe read was BLOCKED by external_directory permission, not retried/bypassed. Complete synthetic
source/output now retained as ordinary audit documentation so QA can review the required evidence
using supported read tools; original external block remains recorded, no permissions widened.

## 9. Deferred checks, owners and acceptance

1. **A4 / supabase-specialist + qa-reviewer:** DATA001 legacy-shaped prior award/no-ledger/false-flag
   fixtures, arithmetic/replay/exactly-once progression. Demonstrate one authoritative award and true
   concurrent-session outcomes in approved isolated stack; do not infer legacy population exists.
2. **A4 / Supabase + Flutter:** A2 reorder/addSet lost response, timed duration/reps completion, quest/
   streak day boundaries, class assignment and composite ownership integrity. Existing referenced
   source/test conditions retained; no automatic remediation.
3. **A5 / supabase-specialist + qa-reviewer:** SEC004 counted synthetic input/provider streams,
   byte-vs-code-unit semantics, cancel-before-excess-buffer, sanitized errors; no live flood.
4. **A5 / Supabase/Flutter + QA:** gateway/SDK/Auth valid/expired/invalid token fixtures, refresh/logout
   isolation, actual bearer propagation, confirmed auth callback route, deployment verify_jwt behavior.
   Only approved non-production access; current stub tests cannot establish this.
5. **A5 / supabase-specialist:** full17-table operation/role matrix, every function/column effective ACL,
   completed/cancelled child immutability, rejected non-catalog UUIDs; role assertions and unchanged
   target data, not superuser-only success. Existing subset is not exhaustive.
6. **Future approved environment inventory / supabase-specialist with user authorization:** deployed
   migration history, PUBLIC/inherited-role/default ACLs and applied function configuration before
   release. Current A3 cannot inspect live project; SEC003 records the specific acceptance predicate:
   unauthorized progression UPDATE must be ineffective while legitimate edits remain allowed.
7. **A5 / supabase-specialist:** FK-leading missing-index query/cascade EXPLAIN on representative
   synthetic scale; whole-operation timeout, nested context byte budget, configured AI destination/
   redirect and attempt-based quota policy verification. No measured regression or user SSRF claim.
8. **Manual cleanup:** A2 full-copy Temp directory remains approval-gated and untouched. A3 external
   directory contains only synthetic script/log; not deleted, no broad Temp cleanup authorized.

## 10. Acceptance reconciliation / A4 boundary

All five required components are read end to end for A3 scope, with explicit gaps above. Final
coverage rows may be marked Reviewed (static), not whole-row runtime-verified. Two new findings
retain full schema/evidence and all24 earlier IDs/classifications; only three existing IDs receive
addenda. Independent review is complete; current consistency/Git output is recorded with the checkpoint.
Missing live/production/gateway/concurrency tests are honest deferrals, not mandatory invented gates.
No A4 investigation begins here: exact A4 entry prompt is a handoff artifact only.

Seven mapped scope/acceptance requirements from section1:
1. C17-C21 coverage reviewed, named reviewers and known limitations recorded: satisfied.
2. Prior24 IDs/classifications retained, two new full-field IDs, traceable source/runtime distinction:
   satisfied, subject to current parser/count preservation check quoted in handoff.
3. Missing runtime assertions have owners/A4-A5 targets/required approvals in section9: satisfied.
4. Independent material QA completed; initial external read BLOCKED, supported repository evidence
   reviewed without retry/bypass. No new P0/P1 findings, existing material boundaries reviewed.
5. Registers/coverage/current handoffs and future A4 prompt synchronized; current document check
   must run before checkpoint, not inferred from earlier sessions.
6. Existing SQL10 units, Edge15 tests, six handler checks PASS. Custom default FAIL disproved original
   named-column hypothesis; PUBLIC14 assertions and named denial4 assertions separately PASS. Safe
   isolated scope/source untouched; this audit-stage PASS does not relabel the failed test as PASS.
7. Vietnamese report and exact A4 entry prompt recorded; no A4/remediation/migration executed.

Final QA follow-up read A3_SQL_EVIDENCE in-repo: no substantive replication/classification blocker
by inspection, conditional PUBLIC/no-production scope supported. It caught wording "all17 policies"
versus22 effective policies: corrected to "policies on all17 tables reviewed". External original
permission failure remains BLOCKED; QA performed no independent runtime rerun or forbidden Node check.
This is scoped artifact acceptance with specific known risks, not exhaustive formal verification.

## 11. Reproducible Edge invocation and source preservation

The direct invocations below replace only permissive wrapper flags, not its source/config. No denied
command was bypassed: orchestrator used an already installed Deno with **less** privilege. Dependency
resolution restricted to the existing cache; no network/module download or provider-key inheritance.
Run from repository root; Node inline script uses OS path variables only and explicit synthetic public
values. Original product/test sources remain unchanged.

```javascript
const {spawnSync} = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');
const root = process.cwd();
const dir = path.join(root, 'supabase/functions');
const env = {
  SystemRoot: process.env.SystemRoot, USERPROFILE: process.env.USERPROFILE,
  PATH: process.env.PATH, TEMP: process.env.TEMP, TMP: process.env.TMP,
  DENO_DIR: path.join(root, 'tmp/deno-cache'),
  SUPABASE_URL: 'https://backend.example.test', SUPABASE_ANON_KEY: 'synthetic-public-key',
};
const binary = path.join(root, 'tools/db-tests/node_modules/deno/deno.exe');
const lock = ['--frozen', '--lock', path.join(dir, 'deno.lock')];
const targets = fs.readdirSync(dir, {withFileTypes:true})
  .filter(x => x.isDirectory() && !x.name.startsWith('_') && x.name !== 'tests')
  .map(x => path.join(dir, x.name, 'index.ts'));
const runs = [
  ['test', '--cached-only', '--deny-net',
   '--allow-env=SUPABASE_URL,SUPABASE_ANON_KEY,SUPABASE_PUBLISHABLE_KEY', ...lock, dir],
  ['check', '--cached-only', ...lock, ...targets],
];
for (const args of runs) {
  const result = spawnSync(binary, args, {cwd:root, env, stdio:'inherit'});
  if (result.error) throw result.error;
  if (result.status !== 0) process.exit(result.status ?? 1);
}
```

Procedure: pipe this JavaScript as a PowerShell here-string to `node` from repository root, or save
it only into an unused external audit directory and run Node with repository-root working directory.
Current original separate invocations produced `A3_EDGE_EXIT=0` (`15 passed | 0 failed`) and
`A3_EDGE_CHECK_EXIT=0` with six `Check` lines. Frozen/cached-only failure would be BLOCKED; do not
install/fetch to hide missing prerequisites. Existing SQL runner command is `node tools/db-tests/run.mjs`.

## 12. Current artifact verification and final QA record

At f877e40, orchestrator ran an inline PowerShell here-string piped to `node` (fs/child_process only):
JSON.parse both current register and `git show f877e40:docs/audit/FINDINGS_REGISTER.json`; assert26
unique current MD/JSON IDs,22 required fields, all declared tallies, all prior24 finding objects equal
after excluding only optional a3_review addenda, first/current Markdown classification fields,
18/5/3/1 coverage and named C17-C21 reviewers; assert nine-path whitelist, no app/supabase/tools/
.opencode/AGENTS changes and an exact A4 handoff. Output, exit0:

```text
by_severity={"P0":0,"P1":3,"P2":16,"P3":5,"P4":2}
by_confidence={"Confirmed":5,"High":19,"Medium":2,"Low":0}
by_status={"Open":0,"Needs Verification":3,"Accepted":21,"Fixed":1,"Deferred":0,"False Positive":1}
A3_CHECK json=26 md=26 old_ids_preserved=24 old_classifications_preserved=24 required_fields=22 allowed_paths=9 errors=0
COVERAGE {"Reviewed (static)":18,"Not Reviewed":3,"In Review":5,"Out of Scope":1}
PASS: A3 registers/counts/history/coverage/scope/handoff consistent; product unchanged
A3_VALIDATION_EXIT node=0 diff=0
```

`git diff --check` exit0 (only LF/CRLF warnings); QA current `git status --porcelain=v1` also shows
exactly nine authorized documentation paths. These are current document/scope checks, not production
or exhaustive runtime assertions. Final QA read/grep review found no remaining substantive security
correction, supported scoped coverage/deferrals/A4 prompt; it reported FAIL for missing persisted
current A3_CHECK output (now added here and current handoff/changelog). Earlier coverage wording
FAIL was also corrected. Neither denial nor QA/runtime limitation was hidden or converted to PASS.
Final Vietnamese report names the actual PASS/FAIL/BLOCKED/NOT RUN boundaries; do not begin A4.
