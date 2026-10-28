# A5 — Testing, reliability, performance and observability audit

**Task:** A5 ONLY; 2026-10-28. **Status:** PASS / CLOSED for scoped audit acceptance, explicit gaps retained.
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
- **ui-ux-specialist / ses_e7cc4912dffeja3uQv741D1Hbm: completed bounded review.** New
  A5_UI_EVIDENCE.md and unused external directory only, after PARTIAL checkpoint614ee7c clean.
  Final targeted harness FAIL:8 pass/2 unresolved fixture failures sampling nullable chip paint;
  external-file analyzer FAIL296 package-context issues, not296 production defects. Positive
  production SystemButton versus real CandyButton keyboard, Profile1:1 VI/EN contrast and320dp/200%
  component observations retained. Full source/output and first failed setup preserved; stopped at
  finite diagnostic budget. No full-screen/device/whole-accessibility PASS claimed.
- **qa-reviewer / ses_e7cb5a850ffeEKOCUhDgig3neH: completed material inspection.** Read current
  source and retained full probe controls; supports narrow six-object updates/five promotions/five
  new IDs below. Corrects UI disabled counter's tautological zero claim; orchestrator added explicit
  qualification without changing raw source/results. Git status only UI untracked/HEAD614ee7c/
  tracked diff check no output. Extra source-only diff command BLOCKED(permission), not retried or
  routed around; no independent QA runtime, live backend or exhaustive verification claimed.

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

Executed PARTIAL Git checkpoint: `git diff --cached --check` ->0, allowed_paths7; commit
`614ee7cb6f99846b00fd71eec43637cb296268be`, seven docs +1993/-2; normal push
`1763ab5..614ee7c main -> main`, exit0. Local/remote fullSHA equal, status empty,
`A5_PARTIAL_EQUAL_CLEAN=PASS`. UI review started only after this checkpoint. No history rewrite.

## 5. Reconciled test/reliability findings and independent material QA

New stable IDs after real independent QA:
- **BUG008 P2/Confirmed/Accepted, Flutter/Auth W2:** failed signin AsyncError appears as failed
  password update on synthetic actual-router recovery entry before any update call; pristine,
  rejected Save and successful Save controls. Not an Auth gateway/allowlist exploit.
- **BUG009 P2/Confirmed/Accepted, UI/Flutter W2:** actual CandyButton skipped by Tab/no keyboard
  activation; real SystemButton handles Enter/Space, pointer Candy works. Primitive finding, not
  whole-route accessibility proof. Disabled counter weak/tautological, loading not verified.
- **INTG008 P2/High/Needs Verification, Flutter/Supabase W1:** real repeated INSERT bodies on modeled
  commit/lost ACK create modeled numbers1/2/2; rejection and reload controls distinguish cases.
  SQL/PostgREST duplicate persistence and XP effects are not confirmed.
- **INTG009 P2/High/Needs Verification, Flutter/Supabase W1:** nontransactional actual reorder
  sequence plus modeled second-write failure leaves local optimistic and server partial orders;
  no guaranteed tie order, production prevalence or XP consequence inferred.
- **TEST002 P3/High/Accepted, Flutter/UI W3:**619-line Candy test uses local replicas, not production
  primitives; useful specifications but wrong regression target. Other tests do cover actual UI.

Six updated old objects preserved exactly in historical_pre_a5, including all nested history:
CONC001 same classification, separate post-backup-await completion/cancel clears B controller state;
not an uncaught crash, B database mutation or SEC002 repeat. Five narrow confidence promotions:
BUG004 actual Profile1:1 contrast only (onboarding source-supported/fixture gaps); INTG002 actual
client error mapping after fake RPC success/hydration failure (not SQL commit proof); INTG004
actual Dart Add Set10reps/0duration (not row tap/render); INTG007 actual generated JSON->Dart timed
default mismatch, replacing former mirrored-client uncertainty (local predicate/fake22023 not SQL
E2E); SEC004 counted buffering/UTF16-vs-byte mechanism (not DoS/memory/host latency). No fixes.

Current totals35: P0 0/P1 3/P2 24/P3 6/P4 2; Confirmed16/High18/Medium1; Accepted29/
NeedsVerification3/Fixed1/FalsePositive2. All30 old IDs preserved,25 old classifications unchanged,
24 entirely unchanged old objects, six exact pre-A5 objects and five full22-field new records.
Every new/updated remediation proposal states owner and wave; no new schema/architecture decision.
Supabase specialist's separately delegated register-only write completed, ownership returned;
orchestrator did not touch either mirror concurrently. Its initial validator Unicode-delimiter FAIL
and correction are retained in MASTER_FINDINGS, corrected counts/history validator exit0.

## 6. Review coverage and finite remaining dispositions

A5.1: C23 all16 tracked harness text/code files, two SQL fixtures/three Edge tests/CI; C24 all14
Dart test files/2624lines,13 default suites+manual wrapper. The old A0 inventory2453lines remains
dated, not a fresh measurement. No golden or line/branch percentage measured; no numeric coverage
claim. C23/C24 now Reviewed(static); all26 in-scope components read, not all runtime certified.
A5.2/A5.3: actual async/router/HTTP/storage fixtures above; expiry-only and UUID controls pass,
independent transactions unavailable. A5.4: actual bounded streams plus helper/handler tests,
not real JWT. A5.5:100/1000-row planner-cost/history/stat feasibility, not latency/frame/load SLO.
A5.6: sanitized error paths inspected, optional live/private scripts not run; no functioning alert/
correlation/host telemetry claim. A5.7: real independent material QA and current mirror reconciliation.

Remaining work is not silently pushed into mandatory A6 execution. A6 is reconciliation/triage/
remediation planning only; it assigns these approval-gated owner waves and carries exact limits:
1. **W1 Supabase/QA, trigger supported authorized isolated PostgreSQL/Supabase:** independent same/
   different workout, child-write/cancel/completion, deadlock/timeout and midnight-lock schedules;
   assert one ledger/unique credit/coherent immutable terminal state. BLOCKED because docker,
   supabase, psql, postgres, pg_ctl unavailable on PATH in one bounded check; not a host-wide scan.
2. **W1 Flutter/Supabase/QA, trigger authorized isolated gateway/transport fixtures:** actual committed-
   lost ACK versus rejected write/reload, partial reorder and ties, hidden-row DELETE vs legitimate
   absence, completion hydration and summary policy. Keep INTG008/009 High/NV until persistence proof.
3. **W2 Flutter/UI/Supabase/QA, trigger authorized regression/remediation:** rendered timed-row Add Set/
   visible inputs plus actual generated-quest Dart->SQL/gateway path; preserve005/004/007 mechanisms.
   Mode-spec/preset partial lookup remain specification gaps, not invented exercise IDs or fixes.
4. **W1/W2 Supabase/product/QA, trigger approved date/history policy:** expiry-only gap closed here;
   timezone/history/malformed JSON/generation timing/lock-wait day require explicit event-day and
   reject/quarantine/fallback policy before expected results. Valid controls/rollback assertions then.
5. **W2/W4 Supabase/Flutter/QA, trigger approved local Auth/gateway:** full17-table anon/A/B/service
   operation/function/column matrix, real valid/expired/invalid JWT, refresh/logout/recovery callbacks,
   actual body ceilings/abort/slow body/whole-operation deadlines and quota-after-failure. Supported
   stack prerequisite BLOCKED; live/provider/production NOT RUN intentionally. No secret guide needed.
6. **W2 UI/Flutter/QA, trigger authorized widget/device harness:** correct unresolved nullable chip
   composited-color fixture (two tests FAIL), full onboarding/profile320dp200% flows, active row numeric/
   locale/backstack, dialog/close/error text/semantics and real loading/disabled/focus controls. Generic
   unused components are not live-flow defects. TalkBack/VoiceOver/device glyphs and low-end frame/1Hz
   rebuild/storage budgets NOT RUN; require actual device/profile harness and chosen budget, not guesses.
7. **W3 Flutter/UI + Supabase/QA, trigger approved test/performance hardening:** replace reference-only
   production regression targets(TEST002), direct quest/stats tests, meaningful golden/coverage policy,
   CI platform/format/codegen(TEST001), embedded child-payload/multi-user/large-offset plans and chosen
   performance SLO. Four unindexed-of19 FK references alone do not justify a migration or slowdown claim.
8. **W4 Supabase/Flutter/QA/product, trigger approved observability contract:** sanitized correlation/
   outcome/latency/cost/timeout/quota signals and synthetic alert/failure recovery drill; no tokens,
   private bodies or platform-telemetry absence asserted. Backup here protects audit docs; no DB
   disaster recovery restore rehearsal. Existing Coach4001 continuation and provider-disposal cases
   NOT RUN deliberately after finite priority matrix; owners W2 Flutter/Supabase/QA preserve assertions.
9. **Separately authorized environment inventory, Supabase+user:** production legacy cohort/deployed
   ACL/migration prevalence remains unknown. DATA001 synthetic confirmation and SEC003 conditional
   PUBLIC grant evidence remain unchanged; no production inventory is required to close A5.

## 7. Current regression commands and execution results

Orchestrator independently ran cheap/current regression gates after specialist evidence, not a
duplicate of old DATA001/queue/SEC002/PUBLICACL probes. Product inputs unchanged against1763ab5.
- `cd app; flutter analyze --no-pub` ->`No issues found! (ran in 62.9s)`, exit0.
- `cd app; dart format --output=none --set-exit-if-changed lib test` ->
  `Formatted 125 files (0 changed) in 0.73 seconds.`, exit0.
- `cd app; flutter test --no-pub --reporter expanded` ->`+126: All tests passed!`, exit0;
  wrapper `A5_FLUTTER_REGRESSION_EXIT analyze=0 format=0 tests=0`.
- Original Node SQL runner ->`PASS 10 SQL verification units against PostgreSQL 17.5`, exit0.
- Existing Deno tests ->`15 passed | 0 failed`; six entrypoints check exit0. Exact safe invocation
  below uses only OS paths + explicit synthetic public env, frozen cached modules, deny-net, no
  inherited provider secrets/allow-net wrapper, no external log overwrite or product source rewrite.
- Specialist-only external Flutter18 test probe PASS; UI aggregate FAIL8pass2fixturefail, external
  analyzer FAIL296 package-context issues. These are not erased by green126 permanent regressions.
- Backend12request/3provider cases,150UUIDpairs, same-day +/-1second expiry and SQL synthetic plans
  pass their exact assertions; defect-observing green is not a fix or concurrency proof.

Primary backend regression command: PowerShell here-string containing this JS piped to `node`:

```javascript
const {spawnSync}=require('node:child_process'),fs=require('node:fs'),path=require('node:path');
const root=process.cwd(),dir=path.join(root,'supabase/functions');
const env={SystemRoot:process.env.SystemRoot,USERPROFILE:process.env.USERPROFILE,PATH:process.env.PATH,TEMP:process.env.TEMP,TMP:process.env.TMP,DENO_DIR:path.join(root,'tmp/deno-cache'),SUPABASE_URL:'https://backend.example.test',SUPABASE_ANON_KEY:'synthetic-public-key'};
const deno=path.join(root,'tools/db-tests/node_modules/deno/deno.exe'),lock=['--frozen','--lock',path.join(dir,'deno.lock')];
const targets=fs.readdirSync(dir,{withFileTypes:true}).filter(x=>x.isDirectory()&&!x.name.startsWith('_')&&x.name!=='tests').map(x=>path.join(dir,x.name,'index.ts'));
for(const [label,binary,args] of [['sql',process.execPath,['tools/db-tests/run.mjs']],['edge',deno,['test','--cached-only','--deny-net','--allow-env=SUPABASE_URL,SUPABASE_ANON_KEY,SUPABASE_PUBLISHABLE_KEY',...lock,dir]],['entrypoints',deno,['check','--cached-only',...lock,...targets]]]) {
 console.log('A5_REGRESSION_COMMAND '+JSON.stringify({label,binary,args}));
 const r=spawnSync(binary,args,{cwd:root,env,encoding:'utf8',timeout:120000,maxBuffer:4*1024*1024});
 console.log(r.stdout||'');console.log(r.stderr||'');console.log('A5_REGRESSION_EXIT '+label+'='+r.status); if(r.error) console.log(r.error.message); if(r.status!==0) process.exitCode=1;
}
```

Current exact wrapper lines: `A5_REGRESSION_EXIT sql=0`, `A5_REGRESSION_EXIT edge=0`,
`A5_REGRESSION_EXIT entrypoints=0`. Full standard suite assertions also retained in backend capsule.

## 8. Orchestrator artifact validator — retained executable source

This is artifact/history/coverage/scope verification, not a runtime test or a retry of QA's blocked
source-only Git command. Full allowed-path validation was planned at A5 entry; reviewer permissions
remain unchanged. Run from repository root in PowerShell:

```powershell
$text=Get-Content -Raw 'docs/audit/phases/A5_TEST_RELIABILITY.md'
$source=[regex]::Match($text,'(?s)```javascript\r?\n(// A5_ARTIFACT_VALIDATOR.*?)(?:\r?\n)```').Groups[1].Value
if (-not $source) { throw 'Missing retained A5 validator' }
$source | node
$v=$LASTEXITCODE
git diff --check
$d=$LASTEXITCODE
Write-Output "A5_VALIDATION_EXIT node=$v diff=$d"
if ($v -ne 0 -or $d -ne 0) { exit 1 }
```

```javascript
// A5_ARTIFACT_VALIDATOR
const assert=require('node:assert/strict'),fs=require('node:fs'),cp=require('node:child_process'),crypto=require('node:crypto');
const git=(...args)=>cp.execFileSync('git',args,{encoding:'utf8'}).trimEnd();
const read=p=>fs.readFileSync(p,'utf8'),base='1763ab55e8da994bc1d854ad8fd2cd2299678b45';
const reg='docs/audit/FINDINGS_REGISTER.json',r=JSON.parse(read(reg)),old=JSON.parse(git('show',base+':'+reg));
const byId=new Map(r.findings.map(f=>[f.id,f]));
const amended=['FND-CONC-001','FND-BUG-004','FND-INTG-002','FND-INTG-004','FND-INTG-007','FND-SEC-004'];
const promoted=amended.filter(id=>id!=='FND-CONC-001');
const added=['FND-BUG-008','FND-BUG-009','FND-INTG-008','FND-INTG-009','FND-TEST-002'];
const fields='id title category component paths line_ranges origin root_cause evidence expected_behavior actual_behavior impact severity confidence status proposed_remediation regression_risk related_tests missing_tests depends_on wave verification_method'.split(' ');
assert.equal(r.findings.length,35);assert.equal(byId.size,35);assert.equal(old.findings.length,30);
assert.equal(git('branch','--show-current'),'main');assert.equal(r.baseline.head,base);
for(const f of old.findings){
 const n=byId.get(f.id);assert.ok(n,f.id);
 if(amended.includes(f.id))assert.deepEqual(n.historical_pre_a5,f,f.id+':history');else assert.deepEqual(n,f,f.id+':unchanged');
 if(promoted.includes(f.id)){assert.equal(n.confidence,'Confirmed');assert.equal(n.status,'Accepted');assert.equal(n.severity,f.severity);}
 else for(const k of ['severity','confidence','status'])assert.equal(n[k],f[k],f.id+':'+k);
}
for(const f of r.findings)for(const k of fields)assert.ok(Object.hasOwn(f,k),f.id+':'+k);
assert.deepEqual(r.findings.filter(f=>!old.findings.some(o=>o.id===f.id)).map(f=>f.id).sort(),[...added].sort());
for(const id of added){const {a5_review,...core}=byId.get(id);assert.deepEqual(Object.keys(core).sort(),[...fields].sort());assert.ok(a5_review&&typeof a5_review==='object');assert.equal(a5_review.product_baseline,base);assert.match(a5_review.independent_qa,/ses_e7cb5a850ffeEKOCUhDgig3neH/);assert.ok(a5_review.evidence_reference);}
for(const id of [...amended,...added]){assert.match(byId.get(id).proposed_remediation,/owner/i);assert.ok(byId.get(id).wave);}
for(const key of ['a4_closure','a4_review','a3_closure','closure'])assert.deepEqual(r[key],old[key],key);
const {stage,...oldBaseline}=r.historical_baselines.find(b=>b.stage==='A4 entry');assert.deepEqual(oldBaseline,old.baseline);
const expected={total:35,by_severity:{P0:0,P1:3,P2:24,P3:6,P4:2},by_confidence:{Confirmed:16,High:18,Medium:1,Low:0},by_status:{Open:0,'Needs Verification':3,Accepted:29,Fixed:1,Deferred:0,'False Positive':2}};
assert.deepEqual(r.counts,expected);
for(const [field,key]of [['severity','by_severity'],['confidence','by_confidence'],['status','by_status']]){
 const counts=Object.fromEntries(Object.keys(expected[key]).map(k=>[k,0]));
 for(const f of r.findings){assert.ok(Object.hasOwn(counts,f[field]));counts[f[field]]++;}assert.deepEqual(counts,expected[key]);
}
const md=read('docs/audit/MASTER_FINDINGS.md');
const sections=[...md.matchAll(/^## (FND-[A-Z]+-\d{3}) \u2014[^\n]*\n([\s\S]*?)(?=^## FND-|$(?![\s\S]))/gm)];assert.equal(sections.length,35);
for(const [,id,body]of sections)for(const k of ['severity','confidence','status']){
 const label=k[0].toUpperCase()+k.slice(1),m=body.match(new RegExp('^\\| '+label+' \\| ([^\\n]+)\\|$','m'));
 assert.ok(m,id+':'+k);assert.equal(m[1].replace(/[*`]/g,'').trim(),byId.get(id)[k]);
}
const rows=read('docs/audit/AUDIT_COVERAGE.md').split(/\r?\n/).filter(l=>/^\| C-\d{2} \|/.test(l));assert.equal(rows.length,27);
for(const [s,n]of [['Reviewed (static)',26],['In Review',0],['Not Reviewed',0],['Out of Scope',1]])assert.equal(rows.filter(l=>l.includes('`'+s+'`')).length,n,s);
for(const id of ['C-23','C-24'])assert.ok(rows.find(l=>l.startsWith('| '+id+' |')).includes('`Reviewed (static)`'));
const allowed=['docs/audit/phases/A5_TEST_RELIABILITY.md','docs/audit/phases/A5_FLUTTER_EVIDENCE.md','docs/audit/phases/A5_BACKEND_EVIDENCE.md','docs/audit/phases/A5_UI_EVIDENCE.md','docs/audit/MASTER_FINDINGS.md',reg,'docs/audit/AUDIT_COVERAGE.md','docs/audit/SESSION_HANDOFF.md','docs/planning/TASK_BOARD.md','docs/planning/SESSION_HANDOFF.md','docs/planning/CHANGELOG_AI.md'];
const status=git('status','--porcelain=v1','-uall'),paths=new Set([...git('diff','--name-only',base,'--').split(/\r?\n/),...status.split(/\r?\n/).filter(l=>l.startsWith('?? ')).map(l=>l.slice(3))].filter(Boolean));
assert.deepEqual([...paths].sort(),[...allowed].sort());for(const line of status.split(/\r?\n/).filter(Boolean))assert.ok(allowed.includes(line.slice(3)),line);
const hashes=new Map();
const flutter=[...read('docs/audit/phases/A5_FLUTTER_EVIDENCE.md').matchAll(/^SOURCE (\S+) ([a-f0-9]{64})$/gm)];assert.equal(flutter.length,35);
const backend=[...read('docs/audit/phases/A5_BACKEND_EVIDENCE.md').matchAll(/"path":\s*"([^"]+)",\s*"sha256":\s*"([a-f0-9]{64})"/g)];assert.equal(backend.length,38);
for(const [,p,h]of [...flutter,...backend]){
 assert.match(p,/^(app|supabase|tools|\.github)\//);assert.ok(!/(^|\/)\.env/.test(p));
 if(hashes.has(p))assert.equal(hashes.get(p),h,p);hashes.set(p,h);
 assert.equal(crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex'),h,p);
}
for(const p of ['docs/audit/SESSION_HANDOFF.md','docs/planning/SESSION_HANDOFF.md','docs/planning/TASK_BOARD.md']){
 const top=read(p).split(/## Historical/)[0];for(const token of ['A5','A6','35','26','INTG008'])assert.ok(top.includes(token),p+':'+token);
}
assert.ok(read('docs/audit/SESSION_HANDOFF.md').includes('## A6 entry prompt'));
console.log('A5_ARTIFACT_CHECK json=35 md=35 old_ids=30 old_classes_unchanged=25 old_objects_unchanged=24 exact_histories=6 new_ids=5 required_fields=22 md_json_classes=35 coverage=26/0/0/1 allowed_paths=11 unchanged_inputs='+hashes.size+' errors=0');
console.log('A5_COUNTS '+JSON.stringify(r.counts));
```

Initial primary validator **FAIL**, `A5_VALIDATION_EXIT node=1 diff=0`: the exact-key assertion
rejected the supplemental `a5_review` metadata on new objects, although all22 required schema fields
are present. Corrected only the validator to permit that named review field while still rejecting
other unknown new-object fields and checking all22 required fields. No finding was changed to make
the validator pass. Second attempt **FAIL**, `A5_VALIDATION_EXIT node=1 diff=0`: the supplemental
review metadata is an object, not the validator's assumed string (`'object' !== 'string'`). Read-only
Node inspection printed all five actual metadata objects; corrected the validator to check their
product baseline, independent QA session and evidence reference explicitly. No register data changed.
Corrected output is retained below; it was persisted before final context/QA artifact-only review.

Corrected primary run **PASS** at main614ee7c with expected A5 docs dirty, exact output:

```text
A5_ARTIFACT_CHECK json=35 md=35 old_ids=30 old_classes_unchanged=25 old_objects_unchanged=24 exact_histories=6 new_ids=5 required_fields=22 md_json_classes=35 coverage=26/0/0/1 allowed_paths=11 unchanged_inputs=65 errors=0
A5_COUNTS {"total":35,"by_severity":{"P0":0,"P1":3,"P2":24,"P3":6,"P4":2},"by_confidence":{"Confirmed":16,"High":18,"Medium":1,"Low":0},"by_status":{"Open":0,"Needs Verification":3,"Accepted":29,"Fixed":1,"Deferred":0,"False Positive":2}}
A5_VALIDATION_EXIT node=0 diff=0
```

Git emitted only LF/CRLF conversion notices. Full source/output exists before final context/QA
review; no finding data or allowlist change was made to hide the two primary validator FAILs.

## 9. Acceptance assessment before final checkpoint

All A5.1-A5.7 mandatory paths are mapped in section6 and specialist read manifests; no directory-only
claim. Findings/evidence are persisted, stable IDs/history preserved, remaining verification has
owner/trigger/wave/assertion, independent material QA completed. Applicable tests/limitations are
explicit, including UI FAIL and blocked independent sessions. Primary artifact validation PASS;
final context/QA consistency, normal authorized docs checkpoint and remote equality remain pending.
No new mandatory production gate, silent plan change, A6 execution or remediation.

Final context-keeper follow-up in the same actual session completed: no material blocker, correct
counts/history/limits/owner-wave gaps and exact A6 scope. Orchestrator corrected only a dangling
coverage phrase `At A4 reconciliation` and pending-validator wording (the primary validator already
passed). Agent observed same HEAD/main614ee7c and expected nine dirty docs, diff check only LF/CRLF
warnings. Its numeric-exit wrappers were permission.rejected; not retried or bypassed, no separate
runtime PASS accepted. Final QA artifact inspection follows, without repeating source/probe audit.

Final qa-reviewer follow-up in the same real session completed: no material closure blocker;
current counts/history/claims/coverage/A6 boundary agree on inspection. Plain git status/HEAD/diff
check observed expected nine docs/main614ee7c/only LF-CRLF notices. Independent Node/probe/regression
execution NOT RUN by assignment, not claimed PASS. Last minor stale sentence saying output would
be persisted later was corrected to say it is retained above; no finding or test expectation changed.
No previously denied source-filter command, context exit wrapper or alternate permission bypass.

**Final scoped acceptance: PASS / CLOSED.** Executed section8 validator and current regression gates,
all mandatory read/disposition mapping, retained synthetic evidence, independent material/acceptance
inspections and explicit owner-wave gaps satisfy the audit closure policy. Failed external UI setup/
chip probes remain FAIL; independent sessions/JWT stack BLOCKED and device/network/hosted telemetry
checks NOT RUN. These do not imply fixes or require exhaustive production proof to close an audit.
All35 findings/30priorIDs/sixhistories/fivepromotions are scoped, no material decision or scope waiver.
Normal docs-only checkpoint/remote equality follows; await explicit A6 go-ahead and do not execute it.

**Final precommit check (2026-10-29):** after final QA wording/closure metadata edits, reran the
exact section8 command ->same `A5_ARTIFACT_CHECK ... unchanged_inputs=65 errors=0`, same A5_COUNTS,
`A5_VALIDATION_EXIT node=0 diff=0` (PASS). Current branch/main614ee7c, eight modified docs plus new
UI evidence, all expected; aggregate since1763ab5 exactly11 authorized documentation paths. Explicit
staging/whitespace and normal commit/push outcomes are recorded in audit/planning handoffs after
execution; no new runtime investigation, code/test change or A6 execution.

Explicit `git add -- <eleven authorized paths>` staged nine changed docs (the other two evidence
docs were already in PARTIAL614ee7c); `git diff --cached --check` ->
`A5_STAGED_DIFF_CHECK_EXIT=0` (PASS), including previously untracked UI evidence. Staged name list
contains only the nine expected documentation paths; no product/permanent-test/CI/config change.
