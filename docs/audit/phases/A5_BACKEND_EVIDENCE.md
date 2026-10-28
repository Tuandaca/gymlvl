# A5 backend — bounded audit and synthetic evidence

**Task:** A5 only, 2026-10-28. **Entry:** main
`1763ab55e8da994bc1d854ad8fd2cd2299678b45`. Backend evidence is complete for the five finite groups
below; this is not production certification or whole-A5 acceptance. No remediation was performed.

**Owned paths:** this NEW document and the initially absent external directory
`C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-backend-20261028` only. The six expected
dirty documents were preserved: audit SESSION_HANDOFF, planning CHANGELOG_AI/SESSION_HANDOFF/TASK_BOARD,
A5_FLUTTER_EVIDENCE and A5_TEST_RELIABILITY. The parent owns shared records and registers; this
specialist did not edit them. The parent's verified A5 bundle/bare/archive backup is recorded in
A5_TEST_RELIABILITY section 2. No app copy, install, secret/env-file read, remote DB/provider call,
deployment, migration file, permanent test, CI/config/permission/dependency edit, deletion or commit.

## 1. Current execution, with honest dispositions

- **Group 1 — BLOCKED:** independent-connection PostgreSQL/local Supabase schedules. One prerequisite
  inventory found `docker`, `supabase`, `psql`, `postgres`, `pg_ctl` unavailable on PATH. Consequently
  `docker info` was not applicable; no server scan, credential read, install, remote connection or
  start/reset was attempted. Installed Node was `C:\Program Files\nodejs\node.exe`. Deno was absent
  on PATH, but the known existing `tools/db-tests/node_modules/deno/deno.exe`, PGlite distribution and
  `tmp/deno-cache` all existed. This does not prove no PostgreSQL exists anywhere on the host; no
  supported isolated independent-session target was available to this bounded task.
- **Group 2 — PASS after one retained setup correction:** fresh PGlite seed replay preserved all150
  `(slug,id)` pairs. Two different synthetic users, same fixed historical finished timestamp and same
  quest date, differing only by expiry one second before/after finish, yielded `isQuest=false/true`.
  No day rollover was combined with expiry; no full A4 arithmetic or DATA001 repro was repeated.
- **Group 3 — PASS (defect-observing):** 12 real-Request counted-stream cases through actual
  `rpcHandler`/`handleCoachRequest`, plus three injected provider-response cases. Oversize32768-byte
  bodies were fully read before413, both with and without truthful Content-Length. Under-limit
  controls200; missing/rejected-auth controls401 consumed zero body bytes. Multibyte input30029 UTF-8
  bytes/10029 UTF-16 units was accepted200 by both. Provider77053 bytes were fully read before502
  for a13000-unit answer; padding64055 bytes with a short answer was accepted200. Non-ok provider502
  read zero bytes and invoked no stream cancellation. No fixture exceeded256KiB; no exhaustion test.
- **Group 4 — PASS:** original `node tools/db-tests/run.mjs` ran ONCE: `PASS 10 SQL verification units
  against PostgreSQL 17.5`; original Edge suite `15 passed | 0 failed`; six original entrypoints
  typechecked exit0. Installed Deno used cached-only/frozen/deny-net and an explicit synthetic public
  environment, not the npm wrapper's allow-net/inherited provider environment. No source rewrites.
- **Group 5 — PASS for feasibility/inspection:**100 then1000 synthetic completed histories, one
  existing-catalog exercise and one set each, EXPLAIN JSON (cost only), plus functional stats controls
  returning seven days. FK census19 constraints/15 leading indexes/four without. This is not a load
  test, actual PostgREST embedding plan, EXPLAIN ANALYZE, disk/buffer test, or device/production latency.

Initial `run.cjs` exited1 because SQL probe's diagnostic SELECT used unquoted alias `day` without AS
(`42601 syntax error at or near "day"`). Seed replay had passed; expiry comparison/G5 had not reached
their final assertions. Edge probe in the same invocation independently exited0 and was NOT rerun.
External-only correction changed that alias to `as quest_day` and two associated JS property reads;
no assertion expectation or product SQL changed. Direct corrected SQL command exited0. The original
failed source/output and corrected source/output are retained losslessly in section 8, not erased.

Migrations were applied only to fresh disposable in-memory PGlite databases (failed attempt1 DB,
corrected probe2 DBs, original runner1 DB). **NOT RUN: no persistent/local-stack/remote migration was
applied anywhere.** No claim of live Supabase Auth/JWT/gateway acceptance is made.

## 2. C23 read coverage and what the existing assertions actually mean

Read all16 tracked `tools/db-tests` text/code files, excluding package/lock dependency noise and
node_modules: README.md, bootstrap.sql, run.mjs, edge-tests.mjs, adversarial-anti-cheat.mjs,
adversarial-coach.mjs, e2e-catalog-test.mjs, legacy-adoption.mjs, live-e2e.mjs, browser-smoke.mjs,
inspect-user-ui.mjs, run-complete-e2e-user-test.mjs, test-all-screens-thoroughly.mjs,
test-login-flow.mjs, test-reload.mjs, test-semantics.mjs. Both SQL regressions, all three Edge test
files, shared HTTP/validation, coach service/adapter and remaining five endpoint handlers were read.
Also inspected verify.yml, config.toml, relevant table/policy/RPC/index definitions and history query.
Input hashes in the retained capsule identify the exact reviewed/probed source versions; excluded
dependency noise was not treated as substantive review. No A3 security audit was reopened.

- `run.mjs` creates one memory-only PGlite DB with pgcrypto, applies actual sorted migrations, reads
  configured seed paths, runs each seed twice and each SQL regression. Its10 units are bootstrap1 +
  migrations3 + seed executions4 + SQL files2, NOT ten individual assertions or17-table coverage.
  Metadata/count/duration assertions are additional checks, not counted units. SQL files BEGIN/ROLLBACK
  fixtures; outer runner closes DB in finally. New UUID comparison fills the narrower gap that seed
  rerun success/count alone does not explicitly assert preservation of every existing catalog ID.
- Bootstrap has NOLOGIN anon/authenticated and BYPASSRLS service_role, simplified auth.users, auth.uid/
  jwt/role reading session GUCs, broad default grants later narrowed by migrations. Test owner supplies
  fixtures and manipulates historical clocks. SET LOCAL ROLE/GUCs model trusted request context, not
  cryptographic signature, GoTrue session refresh/expiry, JWT gateway or pooler behaviour. A service_role
  definition is not an executed service_role operation matrix.
- `security_regression.sql` exercises authenticated owner paths and a second synthetic user, expected
  SQLSTATE denial, zero-row RLS visibility, invalid-completion rollback, sequential replay/one reward/
  one ledger, completed-set immutability, quest/calendar/streak and quota controls. `denied` requires
  the exact expected SQLSTATE, while zero-row UPDATE is not an exception and needs a state assertion;
  the completed weight20 check supplies one. Sequential RPC retries are not independent transactions.
- `progression_regression.sql` supplies historical owner-only fixtures and verifies recovery boundary,
  deduplicated class history/replay, activity dates, class threshold and privileged account cascade.
  It does not establish legacy production cohorts, concurrent commit order or DATA001 false-flag safety.
- `adversarial-anti-cheat.mjs` is an optional fresh-DB scenario harness: pace/measurement limits,
  sequential tenfold replay, selected progression grants, safe display/profile updates, quota. Its
  output labels do not make it a concurrency/penetration/load test. NOT RUN here, to avoid A4 repetition.
- `e2e-catalog-test.mjs` is owner-connection SQL/catalog/duration verification, despite its E2E title.
  It sets claims but does not SET ROLE for its set insert; it is not an authenticated RLS proof.
- `legacy-adoption.mjs` requires a private backup; contents stay memory-only and diagnostics avoid
  private values. NOT RUN: private data is out of scope. It is not a durable backup/restore rehearsal.
- `live-e2e.mjs` has explicit host/environment gate, admin-created identities, actual HTTP refresh,
  two-user access checks and HTTP Promise.all completion, plus cleanup. NOT RUN: would access a live
  target, credentials and writes/deletes forbidden here. Its existence is not executed gateway evidence.
- `edge-tests.mjs` invokes installed Deno with allow-env/allow-net and inherited process.env. The
  audit's narrower direct invocation is retained, not a wrapper/config repair. `adversarial-coach.mjs`
  is optional eval with synthetic dependencies but allow-net; NOT RUN, existing tests/probes sufficient.
- Browser-smoke is public-login/register VI/EN multi-width rendering, semantics, overflow and console
  checks on an existing build. Other browser scripts depend on loopback mock/set-onboarded, selectors,
  sleeps and screenshots. `test-semantics` logs inventories; login/reload scripts mostly log/screenshoot;
  `test-reload` never calls page.reload. “All real-user features tested” log text is not an assertion of
  persisted real-user behaviour. None executed by this backend task. Browser/UI owner covers C24.
- verify.yml runs npm SQL/Edge and Flutter analyze/tests/web build. It does not invoke the optional
  adversarial/live/legacy/browser suites, independent PostgreSQL sessions or the new disposable probes.
  No coverage percentage, threshold, duration budget or successful current CI run is inferred.

## 3. Inventory versus full17-table role-operation coverage

All17 tables have inspected guard patterns, as already covered statically in A3. The current original
runner does NOT execute every SELECT/INSERT/UPDATE/DELETE with anon/A/B/service_role on all17.

- users: owner-only visibility plus denied XP/onboarding UPDATE and INSERT; anon SELECT denied.
- profiles: initialize_user flow, no explicit second-user direct SELECT/UPDATE control in default SQL.
- exercises: authenticated SELECT for real catalog IDs; no full client write/anon matrix.
- workouts: own start/begin/pause/completion, B hidden SELECT/B completion denied, blocked protected
  updates, invalid completion rollback, completed cancellation rejection.
- workout_exercises: own INSERT used; indirect parent checks. No explicit direct B SELECT/DELETE matrix.
- workout_sets: own INSERT/baseline UPDATE; B SELECT hidden/INSERT denied; completed UPDATE preserves
  values/INSERT denied; measurement constraints. No full own/other zero-row DELETE matrix.
- xp_logs: own SELECT/count, INSERT denied. streaks: own SELECT/update denied and RPC state changes.
- exercise_prs: own SELECT after award; no explicit cross-user direct write matrix.
- quests: used by definer quest generation; no independent catalog-role write matrix.
- quest_instances: own SELECT/update denied, generated daily assignment/replay/completion.
- user_classes: own SELECT/update denied, initialized/switched through RPC.
- class_definitions/class_synergies: read inside definer/RPC logic, not a complete direct role matrix.
- workout_rewards: own SELECT/count/replay; no direct denied write assertion in default SQL.
- user_achievements: own SELECT and direct INSERT denied. coach_daily_usage: RPC quota20/21 and direct
  UPDATE denied; no direct cross-user SELECT assertion.

Six functions have `verify_jwt=true` in config. Existing Edge tests call exported helpers/services
directly with fake getUser/provider fetch, and never traverse a deployed JWT gateway. Invalid-token401
tests assert controlled HTTP handling/sanitization, not actual issuer/signature/audience/expired-JWT
validation. The fuller role/gateway matrix is **BLOCKED** on an approved isolated stack with actual
Auth/gateway; no unbounded matrix expansion was attempted.

## 4. Resource/timeout/quota/destination/observability inspection

Actual product anchors: `_shared/http.ts:19-45`, `ai-coach/service.ts:30-128`,
`ai-coach/index.ts:5-55`, authoritative migration:340-349.

- Auth precedes `req.text()`. Both limits compare JS string length (UTF-16 units), not UTF-8 bytes,
  and neither checks Content-Length nor caps bytes during reads. Counted streams use highWaterMark0
  and1024-byte chunks, so “zero consumption” is not hidden stream prefetch. “Canceled0” is invocation
  of the supplied synthetic stream's cancel callback only; it is not a network disconnect observation.
- Coach auth/body/schema/provider-config/HTTPS validation precede quota; quota precedes context/fetch.
  Thus invalid input/config uses no quota, but context/provider failure after quota has no refund path.
  Default SQL quota uses an atomic upsert and UTC date, max20; concurrent quota requests NOT RUN.
- Provider URL is deployment environment supplied, HTTPS-only, no host allowlist in service; request
  does not select its destination. This does not establish attacker-controlled destination/SSRF.
  Context selects allowlisted profile fields and up to7 completed workouts in7days, with nested
  exercise/set arrays; the7 parent-row limit is not a byte or child-row budget. max_tokens650 is an
  outgoing provider request hint, not a response streaming cap. `upstream.json()` precedes answer12000
  validation; no Content-Length/whole-response byte limit or explicit upstream non-ok body cancellation.
- AbortSignal.timeout15000 is attached to provider fetch only. Existing timeout test throws a synthetic
  TimeoutError immediately: it proves mapping504, NOT15-second enforcement, transport abort, hanging
  context/Auth/RPC deadlines or slow response-body behaviour. Request disconnect/cancellation is not
  propagated explicitly to context/RPC or provider signal. No retry loop/backoff is present in handlers.
- Error mapping sanitizes SQL22/23->400,42501->403, others503; provider failure502/429, timeout504,
  malformed result502 and unexpected errors503. Current tests assert selected statuses and internal
  message suppression. They do not measure hosted trace retention, network failures or diagnostics.
- Narrow grep `console\.|log\(|capture|trace|timeout|retry|Abort|COACH_DISABLED|request.?id|metric`
  in function TS found only provider timeout and test capture references. Inspected handlers contain
  no app-level structured event/correlation/latency/provider-token-cost recording or kill-switch branch.
  `analytics.enabled=true`/postgres in config is not evidence of functioning dashboards/alerts. No
  hosted logging was accessed; no claim that platform telemetry is absent. Sanitized errors protect
  callers but currently offer little app-level distinction for operators. This is an owned review gap,
  not automatically a new production defect without an agreed observability contract.

## 5. Synthetic plans: meaning and limits

New probe uses actual migrations/seeds and validates catalog existence, auth role for history root
query, owner connection for aggregate query shape (matching definer ownership). Setup writes historical
fixture rows directly as test owner, not through an alternate award path. Stats RPC is also called as
authenticated user. No client/server award function was added; no product behaviour was changed.

-100 rows offset0: `workout_history_user_completed` Index Scan, Limit cost0.18..4.31.
-100 rows offset80: Seq Scan/Sort, Limit9.06..9.11.
-1000 rows offset0: same partial history index, Limit0.31..3.01.
-1000 rows offset980: Seq Scan/Sort, Limit105.31..105.36.
-7-day aggregate at100: total cost13.26, workouts Seq Scan; at1000 cost46.67, history index on
  user/completed_at. Both plans scan workout_exercises and probe sets FK index. Both stats controls
  returned7 dates. Costs are planner units with synthetic distributions, not milliseconds or SLA.
-19 FK constraints,15 leading-index controls. Four without a leading referencing-column index:
  class_synergies.secondary_class_id, exercise_prs.exercise_id, quest_instances.quest_id,
  workout_exercises.exercise_id. Composite leftmost user keys do not index exercise_id alone. No
  deletion/cascade scan or repair was executed. Catalog parents are small/read-only; this census alone
  is not proof of a user-visible slowdown or justification for a migration in this audit.

Root history shape corresponds to `supabase_workout_repository.dart:254-265` (default20, OFFSET range);
the real `_detail` embedded child payload/serialization/PostgREST cost is NOT reproduced. No multi-user
skew, large child count, cold/warm disk, IO, memory, p95, mobile frame, WAN or hosted load claim.

## 6. Finite deferred assertions and recommendation to parent

**Owner supabase-specialist + independent qa-reviewer; trigger: separately authorized supported
isolated PostgreSQL/local Supabase environment, no production requirement invented for A5 closure.**

1. Same workout, two independent sessions with barriers before/after user/workout lock: identical
   replay result, exactly one reward/global ledger/class/PR/quest transition; verify fresh read after
   both commits and rollback on injected failure. PGlite Promise.all must never substitute.
2. Different workouts for the same user: deliberately alternate first lock/commit order; per-workout
   one credit, user total equals summed unique awards, monotonic activity/streak/history. Check actual
   deadlock/timeout and retry outcome, not merely final successful function returns.
3. Child INSERT/UPDATE/DELETE or cancel versus completion at parent-lock barrier: child-before-finish
   either commits and is included, or after-finish rejects/does not mutate; cancel/complete has a
   coherent terminal state and no partial ledger. Bound lock_timeout/statement_timeout and assert
   rollback state via independent session. Do not call zero affected rows a database error.
4. Lock wait spanning user-local midnight: complete_workout captures `finished=clock_timestamp()` at
   function entry before waiting for user lock; sync uses transaction `now()`. Establish authoritative
   policy for event/call/lock-acquisition/commit day before asserting one desired outcome. Then schedule
   an actual midnight barrier and compare quest expiry/day/streak/date to that approved policy.
5. Invalid timezone/history/malformed quest config: timezone checked at initialize_user, not an editable
   timezone profile grant; fallback is HCM. Existing unvalidated historical rows/JSON casts can error.
   No invented requirement says malformed historical config must be silently repaired. Approve
   rejection/quarantine/fallback policy and add rollback/isolation/valid-control assertions in its owner
   wave; no malformed-data mutation or material policy decision was made here.
6. Gateway JWT/stream ceilings, real Auth refresh/recovery, request abort and slow provider-body timing
   need approved non-production gateway/transport evidence. Body pressure/DoS/exhaustion and production
   latency remain NOT RUN; bounded counted consumption cannot promote those claims.

**Finding recommendation:** append measured mechanism/control evidence to **existing FND-SEC-004**,
not a duplicate resource finding. Keep severity **P2** provisionally (unchanged); confidence can be
**Confirmed for the bounded synthetic buffering/unit/cancel mechanism only**, independently of severity.
Production impact/gateway ceilings remain **Needs Verification**, not confirmed DoS. Parent/QA decides
whether to narrow the registered claim/status; this specialist did not edit the register. Do not
promote INTG007 from expiry controls; Dart/client timed-quest semantics remain distinct.

**Proposed owner wave only, not approval:** W2 Supabase + QA define byte budgets and bounded read/cancel
regressions preserving auth-first/sanitized errors and VI/EN. W2 transport owner tests abort/timeout/
quota-failure controls. W4 observability owner proposes sanitized correlation/outcome metrics without
tokens/provider bodies; agree acceptance before implementation. Supabase performance owner reviews
missing FK indexes against real safe workload/EXPLAIN and current additive-only rules. No material
architecture/schema/permission decision or fix is approved by this evidence.

## 7. Exact setup and executed commands

Repository working directory for every command: `D:\Projects\gymlvl`.
Entry command (exit0):

```powershell
git status --porcelain=v1; git branch --show-current; git rev-parse HEAD; git rev-parse main
if (Test-Path 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-backend-20261028') { throw 'STOP: external evidence directory exists' }
```

Output: six expected dirty docs listed at top; main; entry SHA twice. Then one prerequisite command:

```powershell
git ls-files tools/db-tests supabase/tests supabase/functions .github/workflows/verify.yml
New-Item -ItemType Directory -Path 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-backend-20261028' | Out-Null
$names = 'node','deno','docker','supabase','psql','postgres','pg_ctl'
foreach ($n in $names) { $c=Get-Command $n -ErrorAction SilentlyContinue; if ($c) { "$n=$($c.Source)" } else { "$n=UNAVAILABLE" } }
if (Get-Command docker -ErrorAction SilentlyContinue) { docker info --format '{{.ServerVersion}}'; "DOCKER_INFO_EXIT=$LASTEXITCODE" }
```

Exit0; node path found, all six other names UNAVAILABLE. `Test-Path` installed Deno/PGlite/cache ->
True/True/True, exit0. External probe files created with patch; no copied app or dependency sources.

Executed runtime commands, exactly:

```powershell
node 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-backend-20261028\run.cjs'; "A5_SYNTHETIC_EXIT=$LASTEXITCODE"
# A5_SYNTHETIC_EXIT=1; SQL exit1/42601; Edge exit0/12+3 cases.
Copy-Item 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-backend-20261028\sql-probe.txt' 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-backend-20261028\sql-probe-failed-1.txt'
Copy-Item 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-backend-20261028\sql.mjs' 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-backend-20261028\sql-failed-1.mjs'
# Two backup copies exit0; then external sql.mjs alias-only patch described in section1.
node 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-backend-20261028\sql.mjs' 2>&1 | Tee-Object -FilePath 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-backend-20261028\sql-probe-corrected.txt'; "A5_SQL_CORRECTED_EXIT=$LASTEXITCODE"
# A5_SQL_CORRECTED_EXIT=0.
node 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-backend-20261028\run.cjs' existing; "A5_EXISTING_EXIT=$LASTEXITCODE"
# A5_EXISTING_EXIT=0; original SQL/Edge/typechecks each exit0.
```

`run.cjs` source below preserves exact child arguments, env whitelist, timeout120000ms and output
capture. Original Edge check stdout/stderr were empty (cached check), exit0, not six invented Check
lines. SQL correction's direct Node invocation inherited the OS process environment, but probe source
does not read credentials/environment or load env files and fetch was replaced with throwing counter
(zero calls). Deno child environment is explicitly whitelisted and synthetic; no provider keys inherited.

No reruns of earlier A3/A4 results are silently claimed: their 15/10/108 and optional adversarial
numbers remain historical, distinct from the current original-suite15/10 and new finite probes.

## 8. Full retained probe source, setup, commands, outputs and input hashes

The generated appendix is **part of this repository document**, not an external-path link. All
executed probe sources are plain text; logs use lossless JSON string encoding so raw ANSI escapes
and the failed minified PGlite stack echo remain exact without executing/displaying control codes.
Each entry includes the original byte encoding/SHA256. Parsing a log's `text` field returns its full
original output (re-encode with its `encoding` for byte equality). `inputs.json` supplies all38 source-input hashes. No QA external-directory access,
download or execution of probe contents is needed for inspection.

The external retention builder was authored with patch and executed as a deterministic evidence
generation step. It reads only the listed synthetic artifact files and writes only this owned new
document at its marker. Its complete source is also retained. Command:

```powershell
node 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-backend-20261028\retain.cjs'
```

For rerun, extract only run.cjs/sql.mjs/edge.ts to a NEW approved external directory, using section7
environment/setup and installed dependencies. Do not replace repository tests or execute retained
source during read-only QA unless authorized. Absolute source imports preserve this machine's exact
evidence; relocation must be explicit. The first failed source differs by the alias/property changes
recorded in section1; both full versions are included, not a reconstructed snippet.

The first evidence-builder execution exited1 before writing the document: it correctly rejected a
non-round-trippable UTF-8 read of the PowerShell Tee log. A BOM-only inspection found255,254
(UTF-16LE); no secret/environment file was read. Original builder source was copied to
retain-failed-1.cjs, then external builder corrected to preserve/round-trip each file's actual
encoding. This changes no probe result or output bytes. Full failure output:

```text
node:assert:95
  throw new AssertionError(obj);
  ^

AssertionError [ERR_ASSERTION]: Expected values to be strictly equal:
+ actual - expected

+ '784eec001e39a7190d66c68d33b67ed00549da3474177b6bf3c4ad25259a3377'
- 'c2d9b9c4b3268ff3fcd3f13c46cb0d7c8f768602889212bfc233efa16549f40b'

    at C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-backend-20261028\retain.cjs:5:108
    at Array.map (<anonymous>)
    at Object.<anonymous> (C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-backend-20261028\retain.cjs:5:21)
    at Module._compile (node:internal/modules/cjs/loader:1730:14)
    at Object..js (node:internal/modules/cjs/loader:1895:10)
    at Module.load (node:internal/modules/cjs/loader:1465:32)
    at Function._load (node:internal/modules/cjs/loader:1282:12)
    at TracingChannel.traceSync (node:diagnostics_channel:322:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:235:24)
    at Function.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:171:5) {
  generatedMessage: true,
  code: 'ERR_ASSERTION',
  actual: '784eec001e39a7190d66c68d33b67ed00549da3474177b6bf3c4ad25259a3377',
  expected: 'c2d9b9c4b3268ff3fcd3f13c46cb0d7c8f768602889212bfc233efa16549f40b',
  operator: 'strictEqual'
}

Node.js v22.17.1
A5_RETENTION_EXIT=1
```

Second evidence-builder execution decoded UTF-16LE correctly, wrote its generated section, then
its own extraction/hash check caught JavaScript replacement-string interpolation of `$$` to `$`
inside the failed PGlite minified output. Diagnostic comparison found original25557 versus25556 bytes,
first difference index4624 (`...=>[\`$${s+1}\`...` versus `...=>[\`${s+1}\`...`). Probe outputs on disk
were unchanged. The generated draft and builder were preserved externally as
evidence-before-generator3.md/retain-failed-2.cjs, then the builder used a callback replacement,
regenerating only its owned appendix with original bytes. No product/tests were changed. Full error:

```text
node:assert:95
  throw new AssertionError(obj);
  ^

AssertionError [ERR_ASSERTION]: sql-probe-failed-1.txt
+ actual - expected

+ '6eb2134d04dd5209e525b42248edef336222e2d09cc74ab8389c437b8a5289b5'
- 'ac2e1d6e7c27f457222316e992aefdc8f9b923c402c1d4db1b9311e874afce93'

    at Object.<anonymous> (C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-backend-20261028\retain.cjs:9:354)
    at Module._compile (node:internal/modules/cjs/loader:1730:14)
    at Object..js (node:internal/modules/cjs/loader:1895:10)
    at Module.load (node:internal/modules/cjs/loader:1465:32)
    at Function._load (node:internal/modules/cjs/loader:1282:12)
    at TracingChannel.traceSync (node:diagnostics_channel:322:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:235:24)
    at Function.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:171:5)
    at node:internal/main/run_main_module:36:49 {
  generatedMessage: false,
  code: 'ERR_ASSERTION',
  actual: '6eb2134d04dd5209e525b42248edef336222e2d09cc74ab8389c437b8a5289b5',
  expected: 'ac2e1d6e7c27f457222316e992aefdc8f9b923c402c1d4db1b9311e874afce93',
  operator: 'strictEqual'
}

Node.js v22.17.1
A5_RETENTION_EXIT=1
```


Third evidence-builder execution stopped before writing (`3 !== 2`) because the recovery check
mistook marker text quoted in its retained source for the actual placeholder. Source preserved as
retain-failed-3.cjs; correction uses the bounded generated-section start/end and newline-delimited
placeholder only. No runtime probe rerun or output change. Full error:

```text
node:assert:95
  throw new AssertionError(obj);
  ^

AssertionError [ERR_ASSERTION]: Expected values to be strictly equal:

3 !== 2

    at Object.<anonymous> (C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a5-backend-20261028\retain.cjs:8:109)
    at Module._compile (node:internal/modules/cjs/loader:1730:14)
    at Object..js (node:internal/modules/cjs/loader:1895:10)
    at Module.load (node:internal/modules/cjs/loader:1465:32)
    at Function._load (node:internal/modules/cjs/loader:1282:12)
    at TracingChannel.traceSync (node:diagnostics_channel:322:14)
    at wrapModuleLoad (node:internal/modules/cjs/loader:235:24)
    at Function.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:171:5)
    at node:internal/main/run_main_module:36:49 {
  generatedMessage: true,
  code: 'ERR_ASSERTION',
  actual: 3,
  expected: 2,
  operator: 'strictEqual'
}

Node.js v22.17.1
A5_RETENTION_EXIT=1
```


### Retained run.cjs

Encoding utf8; SHA256 `6b815e94f672df466d8588a218b4538acf42f4ad4ea85540c9b665099a89695e`.

<!-- A5_ENTRY_BEGIN run.cjs -->
```javascript
const {spawnSync}=require('node:child_process'),fs=require('node:fs'),path=require('node:path');
const root=process.cwd(),out=__dirname,dir=path.join(root,'supabase/functions');
const env={SystemRoot:process.env.SystemRoot,USERPROFILE:process.env.USERPROFILE,PATH:process.env.PATH,TEMP:process.env.TEMP,TMP:process.env.TMP,DENO_DIR:path.join(root,'tmp/deno-cache'),SUPABASE_URL:'https://backend.example.test',SUPABASE_ANON_KEY:'synthetic-public-key'};
const deno=path.join(root,'tools/db-tests/node_modules/deno/deno.exe'),lock=['--frozen','--lock',path.join(dir,'deno.lock')];
const targets=fs.readdirSync(dir,{withFileTypes:true}).filter(x=>x.isDirectory()&&!x.name.startsWith('_')&&x.name!=='tests').map(x=>path.join(dir,x.name,'index.ts'));
const runs=process.argv.includes('existing')?[
 ['sql-existing',process.execPath,['tools/db-tests/run.mjs']],
 ['edge-existing',deno,['test','--cached-only','--deny-net','--allow-env=SUPABASE_URL,SUPABASE_ANON_KEY,SUPABASE_PUBLISHABLE_KEY',...lock,dir]],
 ['edge-check',deno,['check','--cached-only',...lock,...targets]],
]:[
 ['sql-probe',process.execPath,[path.join(out,'sql.mjs')]],
 ['edge-probe',deno,['run','--cached-only','--deny-net','--allow-env=SUPABASE_URL,SUPABASE_ANON_KEY,SUPABASE_PUBLISHABLE_KEY',...lock,path.join(out,'edge.ts')]],
];
for(const [name,binary,args]of runs){console.log('COMMAND '+JSON.stringify({binary,args,env:'OS path variables plus explicit synthetic Supabase public values only'}));const r=spawnSync(binary,args,{cwd:root,env,encoding:'utf8',timeout:120000,maxBuffer:4*1024*1024});const text=(r.stdout??'')+(r.stderr??'')+(r.error?'\nERROR '+r.error.message:'')+'\nEXIT='+r.status+'\n';fs.writeFileSync(path.join(out,name+'.txt'),text);console.log(text);if(r.status!==0)process.exitCode=1;}

```
<!-- A5_ENTRY_END run.cjs -->

### Retained sql.mjs

Encoding utf8; SHA256 `016b6227e590309919a77176ad20c7c3f6aba1a1805442af15149af528ee9226`.

<!-- A5_ENTRY_BEGIN sql.mjs -->
```javascript
import assert from 'node:assert/strict';
import {readFile,readdir} from 'node:fs/promises';
import {createRequire} from 'node:module';
import {pathToFileURL} from 'node:url';
import path from 'node:path';
const root=process.cwd(), require=createRequire(path.join(root,'tools/db-tests/package.json'));
const {PGlite}=await import(pathToFileURL(require.resolve('@electric-sql/pglite')));
const {pgcrypto}=await import(pathToFileURL(require.resolve('@electric-sql/pglite/contrib/pgcrypto')));
let fetches=0; globalThis.fetch=()=>{fetches++;throw Error('NETWORK FORBIDDEN');};
const load=p=>readFile(path.join(root,p),'utf8');
const seeds=['supabase/seed.sql','supabase/seed_exercises.sql'];
async function fresh(){const db=new PGlite({extensions:{pgcrypto}});await db.exec(await load('tools/db-tests/bootstrap.sql'));for(const f of (await readdir(path.join(root,'supabase/migrations'))).filter(x=>x.endsWith('.sql')).sort())await db.exec(await load('supabase/migrations/'+f));for(const f of seeds)await db.exec(await load(f));return db;}
async function role(db,uid,fn){await db.query("select set_config('request.jwt.claim.sub',$1,false),set_config('request.jwt.claims',$2,false)",[uid,JSON.stringify({sub:uid,role:'authenticated'})]);await db.exec('set role authenticated');try{return await fn();}finally{await db.exec('reset role');}}
async function user(db,uid){await db.query('insert into auth.users(id,email) values($1,$2)',[uid,'synthetic-'+uid+'@example.test']);await role(db,uid,()=>db.query('select public.initialize_user($1::jsonb)',[JSON.stringify({environment:'gym',goals:['hypertrophy'],experience_level:'beginner',age:25,gender:'other',height_cm:170,weight_kg:70,weekly_gym_days:3,weekly_home_days:0,preferred_training_days:['Mon'],primary_class_id:'B',timezone:'Asia/Ho_Chi_Minh'})]));}
// Group 2: isolated expiry-only comparison. Historical finished time is fixed in both cases.
{
 const db=await fresh();try{
  const before=(await db.query('select slug,id from public.exercises order by slug')).rows;
  for(const f of seeds)await db.exec(await load(f));
  const after=(await db.query('select slug,id from public.exercises order by slug')).rows;
  assert.equal(before.length,150);assert.deepEqual(after,before);
  console.log('G2 seed replay PASS: 150 existing slug/UUID pairs identical; no invented exercise IDs');
  for(const [index,seconds,expected] of [[1,-1,false],[2,1,true]]){
   const uid=`a5000000-0000-4000-8000-${String(index).padStart(12,'0')}`;await user(db,uid);
   const eid=(await db.query('select id from public.exercises order by slug limit 1')).rows[0].id;
   assert.equal((await db.query('select count(*)::int n from public.exercises where id=$1',[eid])).rows[0].n,1);
   const wid=(await db.query("insert into public.workouts(user_id,started_at,training_started_at) values($1,'2026-10-20T11:30:00Z','2026-10-20T11:30:00Z') returning id",[uid])).rows[0].id;
   const we=(await db.query('insert into public.workout_exercises(workout_id,exercise_id) values($1,$2) returning id',[wid,eid])).rows[0].id;
   await db.query('insert into public.workout_sets(workout_exercise_id,reps,weight_kg,is_completed) values($1,12,0,true)',[we]);
   await db.query("update public.workouts set status='completed',completed_at='2026-10-20T12:00:00Z' where id=$1",[wid]);
   await db.query("insert into public.quest_instances(user_id,quest_id,quest_date,expires_at,prescribed_config) select $1,id,'2026-10-20','2026-10-20T12:00:00Z'::timestamptz+$2*interval '1 second',$3::jsonb from public.quests where type='daily_routine' order by id limit 1",[uid,seconds,JSON.stringify([{exercise_id:eid,sets:1,reps:12,weight_kg:0}])]);
   const result=await role(db,uid,async()=> (await db.query('select public.complete_workout($1) r',[wid])).rows[0].r);
   assert.equal(result.isQuest,expected);
   const state=(await db.query("select q.quest_date::text as quest_day,(w.completed_at at time zone 'Asia/Ho_Chi_Minh')::date::text finish_day,q.expires_at>w.completed_at unexpired,q.status from public.quest_instances q join public.workouts w on w.user_id=q.user_id where w.id=$1",[wid])).rows[0];
   assert.equal(state.quest_day,'2026-10-20');assert.equal(state.finish_day,state.quest_day);assert.equal(state.unexpired,expected);assert.equal(state.status,expected?'completed':'active');
   console.log('G2 expiry PASS '+JSON.stringify({seconds,isQuest:result.isQuest,...state}));
  }
 }finally{await db.close();}
}
// Group 5: two finite synthetic cardinalities. EXPLAIN only, no physical latency claims.
{
 const db=await fresh();try{
  const uid='a5000000-0000-4000-8000-000000000003';await user(db,uid);
  const fk=(await db.query("select c.conrelid::regclass::text child,c.conname,pg_get_constraintdef(c.oid) definition,exists(select 1 from pg_index i where i.indrelid=c.conrelid and i.indisvalid and (i.indkey::smallint[])[0]=c.conkey[1]) leading_index from pg_constraint c join pg_namespace n on n.oid=c.connamespace where c.contype='f' and n.nspname='public' order by child,c.conname")).rows;
  console.log('G5 FK inventory '+JSON.stringify(fk));
  for(const [lo,hi] of [[1,100],[101,1000]]){
   await db.query("insert into public.workouts(user_id,started_at,training_started_at,notes) select $1,now()-n*interval '1 day'-interval '30 minutes',now()-n*interval '1 day'-interval '30 minutes','a5-scale-'||n from generate_series($2::int,$3::int) n",[uid,lo,hi]);
   await db.query("insert into public.workout_exercises(workout_id,exercise_id) select w.id,(select id from public.exercises order by slug limit 1) from public.workouts w where w.user_id=$1 and w.status='active'",[uid]);
   await db.query("insert into public.workout_sets(workout_exercise_id,reps,weight_kg,is_completed) select we.id,10,20,true from public.workout_exercises we join public.workouts w on w.id=we.workout_id where w.user_id=$1 and w.status='active'",[uid]);
   await db.query("update public.workouts set status='completed',completed_at=training_started_at+interval '30 minutes' where user_id=$1 and status='active'",[uid]);
   await db.exec('analyze public.workouts;analyze public.workout_exercises;analyze public.workout_sets;');
   assert.equal((await db.query('select count(*)::int n from public.workouts where user_id=$1',[uid])).rows[0].n,hi);
   for(const offset of [0,hi-20])await role(db,uid,async()=>{const p=await db.query("explain (format json) select id,completed_at from public.workouts where user_id=$1 and status='completed' order by completed_at desc limit 20 offset $2",[uid,offset]);console.log(`G5 history count=${hi} offset=${offset} role=authenticated `+JSON.stringify(p.rows));});
   const p=await db.query("explain (format json) select (w.completed_at at time zone 'Asia/Ho_Chi_Minh')::date workout_day,sum(s.reps*s.weight_kg) volume from public.workouts w join public.workout_exercises we on we.workout_id=w.id join public.workout_sets s on s.workout_exercise_id=we.id and s.is_completed where w.user_id=$1 and w.status='completed' and w.completed_at>=(((now() at time zone 'Asia/Ho_Chi_Minh')::date-6)::timestamp at time zone 'Asia/Ho_Chi_Minh') group by workout_day",[uid]);
   console.log(`G5 aggregate count=${hi} role=owner (RPC definer query shape) `+JSON.stringify(p.rows));
   const stats=await role(db,uid,async()=> (await db.query('select public.get_user_stats() r')).rows[0].r);assert.equal(stats.volume_trend.length,7);console.log(`G5 aggregate functional control count=${hi} days=7 PASS`);
  }
 }finally{await db.close();}
}
assert.equal(fetches,0);console.log('A5_SQL_PROBE PASS; fresh DBs=2; network fetches=0; independent concurrency NOT RUN');

```
<!-- A5_ENTRY_END sql.mjs -->

### Retained sql-failed-1.mjs

Encoding utf8; SHA256 `80fbc67b80e38a15debe007e07383c7170be57d5cd597d501639738748746f54`.

<!-- A5_ENTRY_BEGIN sql-failed-1.mjs -->
```javascript
import assert from 'node:assert/strict';
import {readFile,readdir} from 'node:fs/promises';
import {createRequire} from 'node:module';
import {pathToFileURL} from 'node:url';
import path from 'node:path';
const root=process.cwd(), require=createRequire(path.join(root,'tools/db-tests/package.json'));
const {PGlite}=await import(pathToFileURL(require.resolve('@electric-sql/pglite')));
const {pgcrypto}=await import(pathToFileURL(require.resolve('@electric-sql/pglite/contrib/pgcrypto')));
let fetches=0; globalThis.fetch=()=>{fetches++;throw Error('NETWORK FORBIDDEN');};
const load=p=>readFile(path.join(root,p),'utf8');
const seeds=['supabase/seed.sql','supabase/seed_exercises.sql'];
async function fresh(){const db=new PGlite({extensions:{pgcrypto}});await db.exec(await load('tools/db-tests/bootstrap.sql'));for(const f of (await readdir(path.join(root,'supabase/migrations'))).filter(x=>x.endsWith('.sql')).sort())await db.exec(await load('supabase/migrations/'+f));for(const f of seeds)await db.exec(await load(f));return db;}
async function role(db,uid,fn){await db.query("select set_config('request.jwt.claim.sub',$1,false),set_config('request.jwt.claims',$2,false)",[uid,JSON.stringify({sub:uid,role:'authenticated'})]);await db.exec('set role authenticated');try{return await fn();}finally{await db.exec('reset role');}}
async function user(db,uid){await db.query('insert into auth.users(id,email) values($1,$2)',[uid,'synthetic-'+uid+'@example.test']);await role(db,uid,()=>db.query('select public.initialize_user($1::jsonb)',[JSON.stringify({environment:'gym',goals:['hypertrophy'],experience_level:'beginner',age:25,gender:'other',height_cm:170,weight_kg:70,weekly_gym_days:3,weekly_home_days:0,preferred_training_days:['Mon'],primary_class_id:'B',timezone:'Asia/Ho_Chi_Minh'})]));}
// Group 2: isolated expiry-only comparison. Historical finished time is fixed in both cases.
{
 const db=await fresh();try{
  const before=(await db.query('select slug,id from public.exercises order by slug')).rows;
  for(const f of seeds)await db.exec(await load(f));
  const after=(await db.query('select slug,id from public.exercises order by slug')).rows;
  assert.equal(before.length,150);assert.deepEqual(after,before);
  console.log('G2 seed replay PASS: 150 existing slug/UUID pairs identical; no invented exercise IDs');
  for(const [index,seconds,expected] of [[1,-1,false],[2,1,true]]){
   const uid=`a5000000-0000-4000-8000-${String(index).padStart(12,'0')}`;await user(db,uid);
   const eid=(await db.query('select id from public.exercises order by slug limit 1')).rows[0].id;
   assert.equal((await db.query('select count(*)::int n from public.exercises where id=$1',[eid])).rows[0].n,1);
   const wid=(await db.query("insert into public.workouts(user_id,started_at,training_started_at) values($1,'2026-10-20T11:30:00Z','2026-10-20T11:30:00Z') returning id",[uid])).rows[0].id;
   const we=(await db.query('insert into public.workout_exercises(workout_id,exercise_id) values($1,$2) returning id',[wid,eid])).rows[0].id;
   await db.query('insert into public.workout_sets(workout_exercise_id,reps,weight_kg,is_completed) values($1,12,0,true)',[we]);
   await db.query("update public.workouts set status='completed',completed_at='2026-10-20T12:00:00Z' where id=$1",[wid]);
   await db.query("insert into public.quest_instances(user_id,quest_id,quest_date,expires_at,prescribed_config) select $1,id,'2026-10-20','2026-10-20T12:00:00Z'::timestamptz+$2*interval '1 second',$3::jsonb from public.quests where type='daily_routine' order by id limit 1",[uid,seconds,JSON.stringify([{exercise_id:eid,sets:1,reps:12,weight_kg:0}])]);
   const result=await role(db,uid,async()=> (await db.query('select public.complete_workout($1) r',[wid])).rows[0].r);
   assert.equal(result.isQuest,expected);
   const state=(await db.query("select q.quest_date::text day,(w.completed_at at time zone 'Asia/Ho_Chi_Minh')::date::text finish_day,q.expires_at>w.completed_at unexpired,q.status from public.quest_instances q join public.workouts w on w.user_id=q.user_id where w.id=$1",[wid])).rows[0];
   assert.equal(state.day,'2026-10-20');assert.equal(state.finish_day,state.day);assert.equal(state.unexpired,expected);assert.equal(state.status,expected?'completed':'active');
   console.log('G2 expiry PASS '+JSON.stringify({seconds,isQuest:result.isQuest,...state}));
  }
 }finally{await db.close();}
}
// Group 5: two finite synthetic cardinalities. EXPLAIN only, no physical latency claims.
{
 const db=await fresh();try{
  const uid='a5000000-0000-4000-8000-000000000003';await user(db,uid);
  const fk=(await db.query("select c.conrelid::regclass::text child,c.conname,pg_get_constraintdef(c.oid) definition,exists(select 1 from pg_index i where i.indrelid=c.conrelid and i.indisvalid and (i.indkey::smallint[])[0]=c.conkey[1]) leading_index from pg_constraint c join pg_namespace n on n.oid=c.connamespace where c.contype='f' and n.nspname='public' order by child,c.conname")).rows;
  console.log('G5 FK inventory '+JSON.stringify(fk));
  for(const [lo,hi] of [[1,100],[101,1000]]){
   await db.query("insert into public.workouts(user_id,started_at,training_started_at,notes) select $1,now()-n*interval '1 day'-interval '30 minutes',now()-n*interval '1 day'-interval '30 minutes','a5-scale-'||n from generate_series($2::int,$3::int) n",[uid,lo,hi]);
   await db.query("insert into public.workout_exercises(workout_id,exercise_id) select w.id,(select id from public.exercises order by slug limit 1) from public.workouts w where w.user_id=$1 and w.status='active'",[uid]);
   await db.query("insert into public.workout_sets(workout_exercise_id,reps,weight_kg,is_completed) select we.id,10,20,true from public.workout_exercises we join public.workouts w on w.id=we.workout_id where w.user_id=$1 and w.status='active'",[uid]);
   await db.query("update public.workouts set status='completed',completed_at=training_started_at+interval '30 minutes' where user_id=$1 and status='active'",[uid]);
   await db.exec('analyze public.workouts;analyze public.workout_exercises;analyze public.workout_sets;');
   assert.equal((await db.query('select count(*)::int n from public.workouts where user_id=$1',[uid])).rows[0].n,hi);
   for(const offset of [0,hi-20])await role(db,uid,async()=>{const p=await db.query("explain (format json) select id,completed_at from public.workouts where user_id=$1 and status='completed' order by completed_at desc limit 20 offset $2",[uid,offset]);console.log(`G5 history count=${hi} offset=${offset} role=authenticated `+JSON.stringify(p.rows));});
   const p=await db.query("explain (format json) select (w.completed_at at time zone 'Asia/Ho_Chi_Minh')::date workout_day,sum(s.reps*s.weight_kg) volume from public.workouts w join public.workout_exercises we on we.workout_id=w.id join public.workout_sets s on s.workout_exercise_id=we.id and s.is_completed where w.user_id=$1 and w.status='completed' and w.completed_at>=(((now() at time zone 'Asia/Ho_Chi_Minh')::date-6)::timestamp at time zone 'Asia/Ho_Chi_Minh') group by workout_day",[uid]);
   console.log(`G5 aggregate count=${hi} role=owner (RPC definer query shape) `+JSON.stringify(p.rows));
   const stats=await role(db,uid,async()=> (await db.query('select public.get_user_stats() r')).rows[0].r);assert.equal(stats.volume_trend.length,7);console.log(`G5 aggregate functional control count=${hi} days=7 PASS`);
  }
 }finally{await db.close();}
}
assert.equal(fetches,0);console.log('A5_SQL_PROBE PASS; fresh DBs=2; network fetches=0; independent concurrency NOT RUN');

```
<!-- A5_ENTRY_END sql-failed-1.mjs -->

### Retained edge.ts

Encoding utf8; SHA256 `a65a461103268c13efa512e1cf393ad1c89ff3f33716b1bcfb96c5eafcebf1c4`.

<!-- A5_ENTRY_BEGIN edge.ts -->
```javascript
import {rpcHandler} from 'file:///D:/Projects/gymlvl/supabase/functions/_shared/http.ts';
import {handleCoachRequest,type CoachDependencies} from 'file:///D:/Projects/gymlvl/supabase/functions/ai-coach/service.ts';
function eq(a:unknown,b:unknown){if(a!==b)throw Error(`Expected ${b}, got ${a}`);}
const events:string[]=[];let rpcCalls=0,authCalls=0,fetchCalls=0,accept=true;
globalThis.fetch=((input:RequestInfo|URL)=>{fetchCalls++;const url=input instanceof Request?input.url:String(input);if(url.endsWith('/auth/v1/user')){authCalls++;events.push('auth');return Promise.resolve(accept?Response.json({id:'a5000000-0000-4000-8000-000000000001',aud:'authenticated',role:'authenticated'}):Response.json({message:'synthetic rejected'},{status:401}));}if(url.endsWith('/rest/v1/rpc/get_user_stats')){rpcCalls++;events.push('rpc');return Promise.resolve(Response.json({ok:true}));}throw Error('Unexpected synthetic fetch route');}) as typeof fetch;
// highWaterMark=0 prevents prefetch: counters measure actual stream pulls during handler consumption.
function counted(text:string){const bytes=new TextEncoder().encode(text);eq(bytes.length<=256*1024,true);let offset=0,pulls=0,consumed=0,canceled=0;const stream=new ReadableStream<Uint8Array>({pull(c){pulls++;events.push('body');if(offset===bytes.length){c.close();return;}const chunk=bytes.subarray(offset,Math.min(offset+1024,bytes.length));offset+=chunk.length;consumed+=chunk.length;c.enqueue(chunk);},cancel(){canceled++;}},{highWaterMark:0});return{stream,stats:()=>({bytes:bytes.length,units:text.length,consumed,pulls,canceled})};}
function req(x:ReturnType<typeof counted>,length?:number,token=true){return new Request('https://functions.example.test/a5',{method:'POST',headers:{...(token?{Authorization:'Bearer synthetic'}:{}),...(length===undefined?{}:{'Content-Length':String(length)})},body:x.stream});}
const coach:CoachDependencies={authenticate:async()=>{events.push('auth');return accept;},consumeQuota:async()=>true,context:async()=>({}),providerUrl:'https://provider.invalid/chat',providerKey:'synthetic-only',model:'synthetic',fetcher:async()=>Response.json({choices:[{message:{content:'Synthetic answer'}}]})};
// Group 3, finite request matrix: both real handlers, no length vs declared length vs control.
for(const kind of ['rpc','coach']){
 const run=(r:Request)=>kind==='rpc'?rpcHandler('get_user_stats')(r):handleCoachRequest(r,coach);
 for(const scenario of ['oversize-no-length','oversize-header','under','multibyte','missing-auth','rejected-auth']){
  events.length=0;accept=scenario!=='rejected-auth';const r0=rpcCalls;
  const text=scenario.startsWith('oversize')?'x'.repeat(32768):scenario==='multibyte'?JSON.stringify({message:'hi',padding:'\u1ebf'.repeat(10000)}):JSON.stringify({message:'hi'});
  const x=counted(text), response=await run(req(x,scenario==='oversize-header'?text.length:undefined,scenario!=='missing-auth'));
  const badAuth=scenario==='missing-auth'||scenario==='rejected-auth',big=scenario.startsWith('oversize');
  eq(response.status,badAuth?401:big?413:200);eq(x.stats().consumed,badAuth?0:x.stats().bytes);eq(x.stats().canceled,0);
  if(!badAuth)eq(events[0],'auth');if(kind==='rpc')eq(rpcCalls-r0,badAuth||big?0:1);
  console.log('G3 request PASS '+JSON.stringify({kind,scenario,status:response.status,...x.stats(),firstEvent:events[0]??null,rpcDelta:rpcCalls-r0}));
 }
}
// Actual service dependency injection: oversized answer rejected AFTER complete bounded response read;
// large ignored padding plus short answer accepted. Provider non-ok branch does not read/cancel.
accept=true;
for(const scenario of ['long-answer','padding','non-ok']){
 const payload=JSON.stringify({choices:[{message:{content:scenario==='long-answer'?'a'.repeat(13000):'ok'}}],padding:'x'.repeat(64000)}),x=counted(payload);
 const response=await handleCoachRequest(new Request('https://functions.example.test/a5',{method:'POST',headers:{Authorization:'Bearer synthetic'},body:'{"message":"hi"}'}),{...coach,fetcher:async(_u,init)=>{eq(init?.signal instanceof AbortSignal,true);return new Response(x.stream,{status:scenario==='non-ok'?500:200});}});
 eq(response.status,scenario==='padding'?200:502);eq(x.stats().consumed,scenario==='non-ok'?0:x.stats().bytes);eq(x.stats().canceled,0);
 console.log('G3 provider PASS '+JSON.stringify({scenario,status:response.status,...x.stats()}));
}
console.log('A5_EDGE_PROBE PASS; request cases=12; provider cases=3; all fetches synthetic; '+JSON.stringify({authCalls,rpcCalls,fetchCalls}));

```
<!-- A5_ENTRY_END edge.ts -->

### Retained sql-probe-failed-1.txt

Encoding utf8; SHA256 `ac2e1d6e7c27f457222316e992aefdc8f9b923c402c1d4db1b9311e874afce93`.

<!-- A5_ENTRY_BEGIN sql-probe-failed-1.txt -->
```json
{"name":"sql-probe-failed-1.txt","encoding":"utf8","sha256":"ac2e1d6e7c27f457222316e992aefdc8f9b923c402c1d4db1b9311e874afce93","text":"G2 seed replay PASS: 150 existing slug/UUID pairs identical; no invented exercise IDs\nD:\\Projects\\gymlvl\\tools\\db-tests\\node_modules\\@electric-sql\\pglite\\dist\\index.cjs:4\r\n${a}`),s=p(this,Y).getSize();return p(this,Y).write(o,{at:s}),p(this,Se).add(p(this,Y)),s},ye=function(r){return r.split(\"/\").filter(Boolean)},$=function(r,a){let o=v(this,C,ye).call(this,r),s=a||this.state.root;for(let n of o){if(s.type!==\"directory\")throw new B(\"ENOTDIR\",\"Not a directory\");if(!Object.prototype.hasOwnProperty.call(s.children,n))throw new B(\"ENOENT\",\"No such file or directory\");s=s.children[n]}return s},er=function(r){let a=p(this,Le).get(r);if(!a)throw new B(\"EBADF\",\"Bad file descriptor\");return a},Jo=function(){let r=++je(this,ar)._;for(;p(this,Le).has(r);)je(this,ar)._++;return r},Ia=async function(r,a){let o=v(this,C,ye).call(this,r),s=a?.from||p(this,tr);for(let n of o)s=await s.getDirectoryHandle(n,{create:a?.create});return s};B=class extends Error{constructor(t,r){super(r),typeof t==\"number\"?this.code=t:typeof t==\"string\"&&(this.code=Jt[t])}}});var _i={};Ge(_i,{IdbFs:()=>ct,MemoryFS:()=>mt,Mutex:()=>Fe,PGlite:()=>Ra,formatQuery:()=>vs,messages:()=>Gt,parse:()=>Jr,protocol:()=>ca,types:()=>$r});module.exports=Fs(_i);S();S();S();var di=new Error(\"timeout while waiting for mutex to become available\"),ui=new Error(\"mutex already locked\"),Ts=new Error(\"request for lock canceled\"),Ps=function(e,t,r,a){function o(s){return s instanceof r?s:new r(function(n){n(s)})}return new(r||(r=Promise))(function(s,n){function _(u){try{d(a.next(u))}catch(m){n(m)}}function l(u){try{d(a.throw(u))}catch(m){n(m)}}function d(u){u.done?s(u.value):o(u.value).then(_,l)}d((a=a.apply(e,t||[])).next())})},Br=class{constructor(t,r=Ts){this._value=t,this._cancelError=r,this._weightedQueues=[],this._weightedWaiters=[]}acquire(t=1){if(t<=0)throw new Error(`invalid weight ${t}: must be positive`);return new Promise((r,a)=>{this._weightedQueues[t-1]||(this._weightedQueues[t-1]=[]),this._weightedQueues[t-1].push({resolve:r,reject:a}),this._dispatch()})}runExclusive(t,r=1){return Ps(this,void 0,void 0,function*(){let[a,o]=yield this.acquire(r);try{return yield t(a)}finally{o()}})}waitForUnlock(t=1){if(t<=0)throw new Error(`invalid weight ${t}: must be positive`);return new Promise(r=>{this._weightedWaiters[t-1]||(this._weightedWaiters[t-1]=[]),this._weightedWaiters[t-1].push(r),this._dispatch()})}isLocked(){return this._value<=0}getValue(){return this._value}setValue(t){this._value=t,this._dispatch()}release(t=1){if(t<=0)throw new Error(`invalid weight ${t}: must be positive`);this._value+=t,this._dispatch()}cancel(){this._weightedQueues.forEach(t=>t.forEach(r=>r.reject(this._cancelError))),this._weightedQueues=[]}_dispatch(){var t;for(let r=this._value;r>0;r--){let a=(t=this._weightedQueues[r-1])===null||t===void 0?void 0:t.shift();if(!a)continue;let o=this._value,s=r;this._value-=r,r=this._value+1,a.resolve([o,this._newReleaser(s)])}this._drainUnlockWaiters()}_newReleaser(t){let r=!1;return()=>{r||(r=!0,this.release(t))}}_drainUnlockWaiters(){for(let t=this._value;t>0;t--)this._weightedWaiters[t-1]&&(this._weightedWaiters[t-1].forEach(r=>r()),this._weightedWaiters[t-1]=[])}},As=function(e,t,r,a){function o(s){return s instanceof r?s:new r(function(n){n(s)})}return new(r||(r=Promise))(function(s,n){function _(u){try{d(a.next(u))}catch(m){n(m)}}function l(u){try{d(a.throw(u))}catch(m){n(m)}}function d(u){u.done?s(u.value):o(u.value).then(_,l)}d((a=a.apply(e,t||[])).next())})},Fe=class{constructor(t){this._semaphore=new Br(1,t)}acquire(){return As(this,void 0,void 0,function*(){let[,t]=yield this._semaphore.acquire();return t})}runExclusive(t){return this._semaphore.runExclusive(()=>t())}isLocked(){return this._semaphore.isLocked()}waitForUnlock(){return this._semaphore.waitForUnlock()}release(){this._semaphore.isLocked()&&this._semaphore.release()}cancel(){return this._semaphore.cancel()}};S();S();var Oa={part:\"part\",container:\"container\"};function ir(e,t,...r){let a=e.length-1,o=r.length-1;if(o!==-1){if(o===0){e[a]=e[a]+r[0]+t;return}e[a]=e[a]+r[0],e.push(...r.slice(1,o)),e.push(r[o]+t)}}function Cs(e,...t){let r=[e[0]];r.raw=[e.raw[0]];let a=[];for(let o=0;o<t.length;o++){let s=t[o],n=o+1;if(s?._templateType===Oa.part){ir(r,e[n],s.str),ir(r.raw,e.raw[n],s.str);continue}if(s?._templateType===Oa.container){ir(r,e[n],...s.strings),ir(r.raw,e.raw[n],...s.strings.raw),a.push(...s.values);continue}r.push(e[n]),r.raw.push(e.raw[n]),a.push(s)}return{_templateType:\"container\",strings:r,values:a}}function Ur(e,...t){let{strings:r,values:a}=Cs(e,...t);return{query:[r[0],...a.flatMap((o,s)=>[`$${s+1}`,r[s+1]])].join(\"\"),params:a}}var Jr={};Ge(Jr,{parseDescribeStatementResults:()=>Ft,parseResults:()=>ur});S();var $r={};Ge($r,{ABSTIME:()=>Ws,ACLITEM:()=>Js,BIT:()=>an,BOOL:()=>Gr,BPCHAR:()=>Ha,BYTEA:()=>jr,CHAR:()=>Ds,CID:()=>Ls,CIDR:()=>js,CIRCLE:()=>Xs,DATE:()=>ja,FLOAT4:()=>Ba,FLOAT8:()=>Ua,GTSVECTOR:()=>Mn,INET:()=>$s,INT2:()=>qa,INT4:()=>La,INT8:()=>Wr,INTERVAL:()=>tn,JSON:()=>Zr,JSONB:()=>Za,MACADDR:()=>Qs,MACADDR8:()=>Ys,MONEY:()=>Ks,NUMERIC:()=>sn,OID:()=>za,PATH:()=>Hs,PG_DEPENDENCIES:()=>hn,PG_LSN:()=>gn,PG_NDISTINCT:()=>fn,PG_NODE_TREE:()=>Bs,POLYGON:()=>Gs,REFCURSOR:()=>nn,REGCLASS:()=>un,REGCONFIG:()=>wn,REGDICTIONARY:()=>yn,REGNAMESPACE:()=>Sn,REGOPER:()=>ln,REGOPERATOR:()=>dn,REGPROC:()=>Ns,REGPROCEDURE:()=>_n,REGROLE:()=>xn,REGTYPE:()=>pn,RELTIME:()=>Zs,SMGR:()=>Us,TEXT:()=>bt,TID:()=>Os,TIME:()=>en,TIMESTAMP:()=>Wa,TIMESTAMPTZ:()=>Vr,TIMETZ:()=>rn,TINTERVAL:()=>Vs,TSQUERY:()=>En,TSVECTOR:()=>vn,TXID_SNAPSHOT:()=>mn,UUID:()=>cn,VARBIT:()=>on,VARCHAR:()=>Ga,XID:()=>qs,XML:()=>zs,arrayParser:()=>Qr,arraySerializer:()=>dr,parseType:()=>lr,parsers:()=>Yr,serializers:()=>Kr,types:()=>Va});S();var Is=globalThis.JSON.parse,Rs=globalThis.JSON.stringify,Gr=16,jr=17,Ds=18,Wr=20,qa=21,La=23,Ns=24,bt=25,za=26,Os=27,qs=28,Ls=29,Zr=114,zs=142,Bs=194,Us=210,Hs=602,Gs=604,js=650,Ba=700,Ua=701,Ws=702,Zs=703,Vs=704,Xs=718,Ys=774,Ks=790,Qs=829,$s=869,Js=1033,Ha=1042,Ga=1043,ja=1082,en=1083,Wa=1114,Vr=1184,tn=1186,rn=1266,an=1560,on=1562,sn=1700,nn=1790,_n=2202,ln=2203,dn=2204,un=2205,pn=2206,cn=2950,mn=2970,gn=3220,fn=3361,hn=3402,vn=3614,En=3615,Mn=3642,wn=3734,yn=3769,Za=3802,Sn=4089,xn=4096,Va={string:{to:bt,from:[bt,Ga,Ha],serialize:e=>{if(typeof e==\"string\")return e;if(typeof e==\"number\")return e.toString();throw new Error(\"Invalid input for string type\")},parse:e=>e},number:{to:0,from:[qa,La,za,Ba,Ua],serialize:e=>e.toString(),parse:e=>+e},bigint:{to:Wr,from:[Wr],serialize:e=>e.toString(),parse:e=>{let t=BigInt(e);return t<Number.MIN_SAFE_INTEGER||t>Number.MAX_SAFE_INTEGER?t:Number(t)}},json:{to:Zr,from:[Zr,Za],serialize:e=>typeof e==\"string\"?e:Rs(e),parse:e=>Is(e)},boolean:{to:Gr,from:[Gr],serialize:e=>{if(typeof e!=\"boolean\")throw new Error(\"Invalid input for boolean type\");return e?\"t\":\"f\"},parse:e=>e===\"t\"},date:{to:Vr,from:[ja,Wa,Vr],serialize:e=>{if(typeof e==\"string\")return e;if(typeof e==\"number\")return new Date(e).toISOString();if(e instanceof Date)return e.toISOString();throw new Error(\"Invalid input for date type\")},parse:e=>new Date(e)},bytea:{to:jr,from:[jr],serialize:e=>{if(!(e instanceof Uint8Array))throw new Error(\"Invalid input for bytea type\");return\"\\\\x\"+Array.from(e).map(t=>t.toString(16).padStart(2,\"0\")).join(\"\")},parse:e=>{let t=e.slice(2);return Uint8Array.from({length:t.length/2},(r,a)=>parseInt(t.substring(a*2,(a+1)*2),16))}}},Xr=bn(Va),Yr=Xr.parsers,Kr=Xr.serializers;function lr(e,t,r){if(e===null)return null;let a=r?.[t]??Xr.parsers[t];return a?a(e,t):e}function bn(e){return Object.keys(e).reduce(({parsers:t,serializers:r},a)=>{let{to:o,from:s,serialize:n,parse:_}=e[a];return r[o]=n,r[a]=n,t[a]=_,Array.isArray(s)?s.forEach(l=>{t[l]=_,r[l]=n}):(t[s]=_,r[s]=n),{parsers:t,serializers:r}},{parsers:{},serializers:{}})}var Fn=/\\\\/g,kn=/\"/g;function Tn(e){return e.replace(Fn,\"\\\\\\\\\").replace(kn,'\\\\\"')}function dr(e,t,r){if(Array.isArray(e)===!1)return e;if(!e.length)return\"{}\";let a=e[0],o=r===1020?\";\":\",\";return Array.isArray(a)?`{${e.map(s=>dr(s,t,r)).join(o)}}`:`{${e.map(s=>(s===void 0&&(s=null),s===null?\"null\":'\"'+Tn(t?t(s):s.toString())+'\"')).join(o)}}`}var Hr={i:0,char:null,str:\"\",quoted:!1,last:0,p:null};function Qr(e,t,r){return Hr.i=Hr.last=0,Xa(Hr,e,t,r)[0]}function Xa(e,t,r,a){let o=[],s=a===1020?\";\":\",\";for(;e.i<t.length;e.i++){if(e.char=t[e.i],e.quoted)e.char===\"\\\\\"?e.str+=t[++e.i]:e.char==='\"'?(o.push(r?r(e.str):e.str),e.str=\"\",e.quoted=t[e.i+1]==='\"',e.last=e.i+2):e.str+=e.char;else if(e.char==='\"')e.quoted=!0;else if(e.char===\"{\")e.last=++e.i,o.push(Xa(e,t,r,a));else if(e.char===\"}\"){if(e.last<e.i){let n=t.slice(e.last,e.i);n===\"NULL\"&&!e.quoted?o.push(null):o.push(r?r(n):n)}e.quoted=!1,e.last=e.i+1;break}else if(e.char===s&&e.p!==\"}\"&&e.p!=='\"'){let n=t.slice(e.last,e.i);n===\"NULL\"&&!e.quoted?o.push(null):o.push(r?r(n):n),e.last=e.i+1}e.p=e.char}return e.last<e.i&&o.push(r?r(t.slice(e.last,e.i+1)):t.slice(e.last,e.i+1)),o}function ur(e,t,r,a){let o=[],s={rows:[],fields:[]},n=0,_={...t,...r?.parsers};return e.forEach(l=>{switch(l.name){case\"rowDescription\":{let d=l;s.fields=d.fields.map(u=>({name:u.name,dataTypeID:u.dataTypeID}));break}case\"dataRow\":{if(!s)break;let d=l;r?.rowMode===\"array\"?s.rows.push(d.fields.map((u,m)=>lr(u,s.fields[m].dataTypeID,_))):s.rows.push(Object.fromEntries(d.fields.map((u,m)=>[s.fields[m].name,lr(u,s.fields[m].dataTypeID,_)])));break}case\"commandComplete\":{n+=Pn(l),o.push({...s,affectedRows:n,...a?{blob:a}:{}}),s={rows:[],fields:[]};break}}}),o.length===0&&o.push({affectedRows:0,rows:[],fields:[]}),o}function Pn(e){let t=e.text.split(\" \");switch(t[0]){case\"INSERT\":return parseInt(t[2],10);case\"UPDATE\":case\"DELETE\":case\"COPY\":case\"MERGE\":return parseInt(t[1],10);default:return 0}}function Ft(e){let t=e.find(r=>r.name===\"parameterDescription\");return t?t.dataTypeIDs:[]}var ca={};Ge(ca,{Parser:()=>Ie,messages:()=>Gt,serialize:()=>U});S();S();S();S();function st(e){let t=e.length;for(let r=e.length-1;r>=0;r--){let a=e.charCodeAt(r);a>127&&a<=2047?t++:a>2047&&a<=65535&&(t+=2),a>=56320&&a<=57343&&r--}return t}var Z,V,_t,cr,it,re,pr,nt,Ya,We=class{constructor(t=256){this.size=t;b(this,re);b(this,Z);b(this,V,5);b(this,_t,!1);b(this,cr,new TextEncoder);b(this,it,0);M(this,Z,v(this,re,pr).call(this,t))}addInt32(t){return v(this,re,nt).call(this,4),p(this,Z).setInt32(p(this,V),t,p(this,_t)),M(this,V,p(this,V)+4),this}addInt16(t){return v(this,re,nt).call(this,2),p(this,Z).setInt16(p(this,V),t,p(this,_t)),M(this,V,p(this,V)+2),this}addCString(t){return t&&this.addString(t),v(this,re,nt).call(this,1),p(this,Z).setUint8(p(this,V),0),je(this,V)._++,this}addString(t=\"\"){let r=st(t);return v(this,re,nt).call(this,r),p(this,cr).encodeInto(t,new Uint8Array(p(this,Z).buffer,p(this,V))),M(this,V,p(this,V)+r),this}add(t){return v(this,re,nt).call(this,t.byteLength),new Uint8Array(p(this,Z).buffer).set(new Uint8Array(t),p(this,V)),M(this,V,p(this,V)+t.byteLength),this}flush(t){let r=v(this,re,Ya).call(this,t);return M(this,V,5),M(this,Z,v(this,re,pr).call(this,this.size)),new Uint8Array(r)}};Z=new WeakMap,V=new WeakMap,_t=new WeakMap,cr=new WeakMap,it=new WeakMap,re=new WeakSet,pr=function(t){return new DataView(new ArrayBuffer(t))},nt=function(t){if(p(this,Z).byteLength-p(this,V)<t){let a=p(this,Z).buffer,o=a.byteLength+(a.byteLength>>1)+t;M(this,Z,v(this,re,pr).call(this,o)),new Uint8Array(p(this,Z).buffer).set(new Uint8Array(a))}},Ya=function(t){if(t){p(this,Z).setUint8(p(this,it),t);let r=p(this,V)-(p(this,it)+1);p(this,Z).setInt32(p(this,it)+1,r,p(this,_t))}return p(this,Z).buffer.slice(t?0:5,p(this,V))};var q=new We,An=e=>{q.addInt16(3).addInt16(0);for(let a of Object.keys(e))q.addCString(a).addCString(e[a]);q.addCString(\"client_encoding\").addCString(\"UTF8\");let t=q.addCString(\"\").flush(),r=t.byteLength+4;return new We().addInt32(r).add(t).flush()},Cn=()=>{let e=new DataView(new ArrayBuffer(8));return e.setInt32(0,8,!1),e.setInt32(4,80877103,!1),new Uint8Array(e.buffer)},In=e=>q.addCString(e).flush(112),Rn=(e,t)=>(q.addCString(e).addInt32(st(t)).addString(t),q.flush(112)),Dn=e=>q.addString(e).flush(112),Nn=e=>q.addCString(e).flush(81),On=[],qn=e=>{let t=e.name??\"\";t.length>63&&(console.error(\"Warning! Postgres only supports 63 characters for query names.\"),console.error(\"You supplied %s (%s)\",t,t.length),console.error(\"This can cause conflicts and silent errors executing queries\"));let r=q.addCString(t).addCString(e.text).addInt16(e.types?.length??0);return e.types?.forEach(a=>r.addInt32(a)),q.flush(80)},lt=new We;var Ln=(e,t)=>{for(let r=0;r<e.length;r++){let a=t?t(e[r],r):e[r];if(a===null)q.addInt16(0),lt.addInt32(-1);else if(a instanceof ArrayBuffer||ArrayBuffer.isView(a)){let o=ArrayBuffer.isView(a)?a.buffer.slice(a.byteOffset,a.byteOffset+a.byteLength):a;q.addInt16(1),lt.addInt32(o.byteLength),lt.add(o)}else q.addInt16(0),lt.addInt32(st(a)),lt.addString(a)}},zn=(e={})=>{let t=e.portal??\"\",r=e.statement??\"\",a=e.binary??!1,o=e.values??On,s=o.length;return q.addCString(t).addCString(r),q.addInt16(s),Ln(o,e.valueMapper),q.addInt16(s),q.add(lt.flush()),q.addInt16(a?1:0),q.flush(66)},Bn=new Uint8Array([69,0,0,0,9,0,0,0,0,0]),Un=e=>{if(!e||!e.portal&&!e.rows)return Bn;let t=e.portal??\"\",r=e.rows??0,a=st(t),o=4+a+1+4,s=new DataView(new ArrayBuffer(1+o));return s.setUint8(0,69),s.setInt32(1,o,!1),new TextEncoder().encodeInto(t,new Uint8Array(s.buffer,5)),s.setUint8(a+5,0),s.setUint32(s.byteLength-4,r,!1),new Uint8Array(s.buffer)},Hn=(e,t)=>{let r=new DataView(new ArrayBuffer(16));return r.setInt32(0,16,!1),r.setInt16(4,1234,!1),r.setInt16(6,5678,!1),r.setInt32(8,e,!1),r.setInt32(12,t,!1),new Uint8Array(r.buffer)},ea=(e,t)=>{let r=new We;return r.addCString(t),r.flush(e)},Gn=q.addCString(\"P\").flush(68),jn=q.addCString(\"S\").flush(68),Wn=e=>e.name?ea(68,`${e.type}${e.name??\"\"}`):e.type===\"P\"?Gn:jn,Zn=e=>{let t=`${e.type}${e.name??\"\"}`;return ea(67,t)},Vn=e=>q.add(e).flush(100),Xn=e=>ea(102,e),mr=e=>new Uint8Array([e,0,0,0,4]),Yn=mr(72),Kn=mr(83),Qn=mr(88),$n=mr(99),U={startup:An,password:In,requestSsl:Cn,sendSASLInitialResponseMessage:Rn,sendSCRAMClientFinalMessage:Dn,query:Nn,parse:qn,bind:zn,execute:Un,describe:Wn,close:Zn,flush:()=>Yn,sync:()=>Kn,end:()=>Qn,copyData:Vn,copyDone:()=>$n,copyFail:Xn,cancel:Hn};S();var Gt={};Ge(Gt,{AuthenticationCleartextPassword:()=>Tt,AuthenticationMD5Password:()=>Pt,AuthenticationOk:()=>kt,AuthenticationSASL:()=>At,AuthenticationSASLContinue:()=>Ct,AuthenticationSASLFinal:()=>It,BackendKeyDataMessage:()=>zt,CommandCompleteMessage:()=>Ut,CopyDataMessage:()=>Rt,CopyResponse:()=>Dt,DataRowMessage:()=>Ht,DatabaseError:()=>me,Field:()=>Nt,NoticeMessage:()=>Ve,NotificationResponseMessage:()=>Ze,ParameterDescriptionMessage:()=>qt,ParameterStatusMessage:()=>Lt,ReadyForQueryMessage:()=>Bt,RowDescriptionMessage:()=>Ot,bindComplete:()=>ra,closeComplete:()=>aa,copyDone:()=>ia,emptyQuery:()=>_a,noData:()=>oa,parseComplete:()=>ta,portalSuspended:()=>sa,replicationStart:()=>na});S();var ta={name:\"parseComplete\",length:5},ra={name:\"bindComplete\",length:5},aa={name:\"closeComplete\",length:5},oa={name:\"noData\",length:5},sa={name:\"portalSuspended\",length:5},na={name:\"replicationStart\",length:4},_a={name:\"emptyQuery\",length:4},ia={name:\"copyDone\",length:4},kt=class{constructor(t){this.length=t;this.name=\"authenticationOk\"}},Tt=class{constructor(t){this.length=t;this.name=\"authenticationCleartextPassword\"}},Pt=class{constructor(t,r){this.length=t;this.salt=r;this.name=\"authenticationMD5Password\"}},At=class{constructor(t,r){this.length=t;this.mechanisms=r;this.name=\"authenticationSASL\"}},Ct=class{constructor(t,r){this.length=t;this.data=r;this.name=\"authenticationSASLContinue\"}},It=class{constructor(t,r){this.length=t;this.data=r;this.name=\"authenticationSASLFinal\"}},me=class extends Error{constructor(r,a,o){super(r);this.length=a;this.name=o}},Rt=class{constructor(t,r){this.length=t;this.chunk=r;this.name=\"copyData\"}},Dt=class{constructor(t,r,a,o){this.length=t;this.name=r;this.binary=a;this.columnTypes=new Array(o)}},Nt=class{constructor(t,r,a,o,s,n,_){this.name=t;this.tableID=r;this.columnID=a;this.dataTypeID=o;this.dataTypeSize=s;this.dataTypeModifier=n;this.format=_}},Ot=class{constructor(t,r){this.length=t;this.fieldCount=r;this.name=\"rowDescription\";this.fields=new Array(this.fieldCount)}},qt=class{constructor(t,r){this.length=t;this.parameterCount=r;this.name=\"parameterDescription\";this.dataTypeIDs=new Array(this.parameterCount)}},Lt=class{constructor(t,r,a){this.length=t;this.parameterName=r;this.parameterValue=a;this.name=\"parameterStatus\"}},zt=class{constructor(t,r,a){this.length=t;this.processID=r;this.secretKey=a;this.name=\"backendKeyData\"}},Ze=class{constructor(t,r,a,o){this.length=t;this.processId=r;this.channel=a;this.payload=o;this.name=\"notification\"}},Bt=class{constructor(t,r){this.length=t;this.status=r;this.name=\"readyForQuery\"}},Ut=class{constructor(t,r){this.length=t;this.text=r;this.name=\"commandComplete\"}},Ht=class{constructor(t,r){this.length=t;this.fields=r;this.name=\"dataRow\";this.fieldCount=r.length}},Ve=class{constructor(t,r){this.length=t;this.message=r;this.name=\"notice\"}};S();var la={text:0,binary:1};S();var Jn=new ArrayBuffer(0),ke,Q,fr,hr,jt,gr=class{constructor(t=0){b(this,ke,new DataView(Jn));b(this,Q);b(this,fr,\"utf-8\");b(this,hr,new TextDecoder(p(this,fr)));b(this,jt,!1);M(this,Q,t)}setBuffer(t,r){M(this,Q,t),M(this,ke,new DataView(r))}int16(){let t=p(this,ke).getInt16(p(this,Q),p(this,jt));return M(this,Q,p(this,Q)+2),t}byte(){let t=p(this,ke).getUint8(p(this,Q));return je(this,Q)._++,t}int32(){let t=p(this,ke).getInt32(p(this,Q),p(this,jt));return M(this,Q,p(this,Q)+4),t}string(t){return p(this,hr).decode(this.bytes(t))}cstring(){let t=p(this,Q),r=t;for(;p(this,ke).getUint8(r++)!==0;);let a=this.string(r-t-1);return M(this,Q,r),a}bytes(t){let r=p(this,ke).buffer.slice(p(this,Q),p(this,Q)+t);return M(this,Q,p(this,Q)+t),new Uint8Array(r)}};ke=new WeakMap,Q=new WeakMap,fr=new WeakMap,hr=new WeakMap,jt=new WeakMap;var da=1,e_=4,Ka=da+e_,Qa=new ArrayBuffer(0);var ee,ie,le,I,R,$a,Ja,eo,to,ro,ao,oo,ua,so,no,_o,io,lo,uo,po,co,pa,Ie=class{constructor(){b(this,R);b(this,ee,new DataView(Qa));b(this,ie,0);b(this,le,0);b(this,I,new gr)}parse(t,r){v(this,R,$a).call(this,ArrayBuffer.isView(t)?t.buffer.slice(t.byteOffset,t.byteOffset+t.byteLength):t);let a=p(this,le)+p(this,ie),o=p(this,le);for(;o+Ka<=a;){let s=p(this,ee).getUint8(o),n=p(this,ee).getUint32(o+da,!1),_=da+n;if(_+o<=a&&n>0){let l=v(this,R,Ja).call(this,o+Ka,s,n,p(this,ee).buffer);r(l),o+=_}else break}o===a?(M(this,ee,new DataView(Qa)),M(this,ie,0),M(this,le,0)):(M(this,ie,a-o),M(this,le,o))}};ee=new WeakMap,ie=new WeakMap,le=new WeakMap,I=new WeakMap,R=new WeakSet,$a=function(t){if(p(this,ie)>0){let r=p(this,ie)+t.byteLength;if(r+p(this,le)>p(this,ee).byteLength){let o;if(r<=p(this,ee).byteLength&&p(this,le)>=p(this,ie))o=p(this,ee).buffer;else{let s=p(this,ee).byteLength*2;for(;r>=s;)s*=2;o=new ArrayBuffer(s)}new Uint8Array(o).set(new Uint8Array(p(this,ee).buffer,p(this,le),p(this,ie))),M(this,ee,new DataView(o)),M(this,le,0)}new Uint8Array(p(this,ee).buffer).set(new Uint8Array(t),p(this,le)+p(this,ie)),M(this,ie,r)}else M(this,ee,new DataView(t)),M(this,le,0),M(this,ie,t.byteLength)},Ja=function(t,r,a,o){switch(r){case 50:return ra;case 49:return ta;case 51:return aa;case 110:return oa;case 115:return sa;case 99:return ia;case 87:return na;case 73:return _a;case 68:return v(this,R,lo).call(this,t,a,o);case 67:return v(this,R,to).call(this,t,a,o);case 90:return v(this,R,eo).call(this,t,a,o);case 65:return v(this,R,so).call(this,t,a,o);case 82:return v(this,R,co).call(this,t,a,o);case 83:return v(this,R,uo).call(this,t,a,o);case 75:return v(this,R,po).call(this,t,a,o);case 69:return v(this,R,pa).call(this,t,a,o,\"error\");case 78:return v(this,R,pa).call(this,t,a,o,\"notice\");case 84:return v(this,R,no).call(this,t,a,o);case 116:return v(this,R,io).call(this,t,a,o);case 71:return v(this,R,ao).call(this,t,a,o);case 72:return v(this,R,oo).call(this,t,a,o);case 100:return v(this,R,ro).call(this,t,a,o);default:return new me(\"received invalid response: \"+r.toString(16),a,\"error\")}},eo=function(t,r,a){p(this,I).setBuffer(t,a);let o=p(this,I).string(1);return new Bt(r,o)},to=function(t,r,a){p(this,I).setBuffer(t,a);let o=p(this,I).cstring();return new Ut(r,o)},ro=function(t,r,a){let o=a.slice(t,t+(r-4));return new Rt(r,new Uint8Array(o))},ao=function(t,r,a){return v(this,R,ua).call(this,t,r,a,\"copyInResponse\")},oo=function(t,r,a){return v(this,R,ua).call(this,t,r,a,\"copyOutResponse\")},ua=function(t,r,a,o){p(this,I).setBuffer(t,a);let s=p(this,I).byte()!==0,n=p(this,I).int16(),_=new Dt(r,o,s,n);for(let l=0;l<n;l++)_.columnTypes[l]=p(this,I).int16();return _},so=function(t,r,a){p(this,I).setBuffer(t,a);let o=p(this,I).int32(),s=p(this,I).cstring(),n=p(this,I).cstring();return new Ze(r,o,s,n)},no=function(t,r,a){p(this,I).setBuffer(t,a);let o=p(this,I).int16(),s=new Ot(r,o);for(let n=0;n<o;n++)s.fields[n]=v(this,R,_o).call(this);return s},_o=function(){let t=p(this,I).cstring(),r=p(this,I).int32(),a=p(this,I).int16(),o=p(this,I).int32(),s=p(this,I).int16(),n=p(this,I).int32(),_=p(this,I).int16()===0?la.text:la.binary;return new Nt(t,r,a,o,s,n,_)},io=function(t,r,a){p(this,I).setBuffer(t,a);let o=p(this,I).int16(),s=new qt(r,o);for(let n=0;n<o;n++)s.dataTypeIDs[n]=p(this,I).int32();return s},lo=function(t,r,a){p(this,I).setBuffer(t,a);let o=p(this,I).int16(),s=new Array(o);for(let n=0;n<o;n++){let _=p(this,I).int32();s[n]=_===-1?null:p(this,I).string(_)}return new Ht(r,s)},uo=function(t,r,a){p(this,I).setBuffer(t,a);let o=p(this,I).cstring(),s=p(this,I).cstring();return new Lt(r,o,s)},po=function(t,r,a){p(this,I).setBuffer(t,a);let o=p(this,I).int32(),s=p(this,I).int32();return new zt(r,o,s)},co=function(t,r,a){p(this,I).setBuffer(t,a);let o=p(this,I).int32();switch(o){case 0:return new kt(r);case 3:return new Tt(r);case 5:return new Pt(r,p(this,I).bytes(4));case 10:{let s=[];for(;;){let n=p(this,I).cstring();if(n.length===0)return new At(r,s);s.push(n)}}case 11:return new Ct(r,p(this,I).string(r-8));case 12:return new It(r,p(this,I).string(r-8));default:throw new Error(\"Unknown authenticationOk message type \"+o)}},pa=function(t,r,a,o){p(this,I).setBuffer(t,a);let s={},n=p(this,I).string(1);for(;n!==\"\\0\";)s[n]=p(this,I).cstring(),n=p(this,I).string(1);let _=s.M,l=o===\"notice\"?new Ve(r,_):new me(_,r,o);return l.severity=s.S,l.code=s.C,l.detail=s.D,l.hint=s.H,l.position=s.P,l.internalPosition=s.p,l.internalQuery=s.q,l.where=s.W,l.schema=s.s,l.table=s.t,l.column=s.c,l.dataType=s.d,l.constraint=s.n,l.file=s.F,l.line=s.L,l.routine=s.R,l};S();function vr(e){let t=e.e;return t.query=e.query,t.params=e.params,t.queryOptions=e.options,t}var Wt,Re,N,ge,Er,Xe,ma,Mr=class{constructor(){b(this,N);this.serializers={...Kr};this.parsers={...Yr};b(this,Wt,!1);b(this,Re,!1)}async _initArrayTypes({force:t=!1}={}){if(p(this,Wt)&&!t)return;M(this,Wt,!0);let r=await this.query(`\r\n                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            \r\n\r\nerror: syntax error at or near \"day\"\r\n    at Ie.pa (D:\\Projects\\gymlvl\\tools\\db-tests\\node_modules\\@electric-sql\\pglite\\dist\\index.cjs:4:22223)\r\n    at Ie.Ja (D:\\Projects\\gymlvl\\tools\\db-tests\\node_modules\\@electric-sql\\pglite\\dist\\index.cjs:4:19593)\r\n    at Ie.parse (D:\\Projects\\gymlvl\\tools\\db-tests\\node_modules\\@electric-sql\\pglite\\dist\\index.cjs:4:18315)\r\n    at D:\\Projects\\gymlvl\\tools\\db-tests\\node_modules\\@electric-sql\\pglite\\dist\\index.cjs:14:1485\r\n    at wasm://wasm/025aee86:wasm-function[10511]:0x57c3d2\r\n    at wasm://wasm/025aee86:wasm-function[3431]:0x26bd2c\r\n    at wasm://wasm/025aee86:wasm-function[3473]:0x27324f\r\n    at wasm://wasm/025aee86:wasm-function[3483]:0x2734ab\r\n    at wasm://wasm/025aee86:wasm-function[9532]:0x528b49\r\n    at wasm://wasm/025aee86:wasm-function[5541]:0x3cd5b7 {\r\n  length: 92,\r\n  severity: 'ERROR',\r\n  code: '42601',\r\n  detail: undefined,\r\n  hint: undefined,\r\n  position: '27',\r\n  internalPosition: undefined,\r\n  internalQuery: undefined,\r\n  where: undefined,\r\n  schema: undefined,\r\n  table: undefined,\r\n  column: undefined,\r\n  dataType: undefined,\r\n  constraint: undefined,\r\n  file: 'scan.l',\r\n  line: '1248',\r\n  routine: 'scanner_yyerror',\r\n  query: \"select q.quest_date::text day,(w.completed_at at time zone 'Asia/Ho_Chi_Minh')::date::text finish_day,q.expires_at>w.completed_at unexpired,q.status from public.quest_instances q join public.workouts w on w.user_id=q.user_id where w.id=$1\",\r\n  params: [ '936767df-0b9d-4ed2-bfa6-cdc0dc045295' ],\r\n  queryOptions: undefined\r\n}\r\n\r\nNode.js v22.17.1\r\n\nEXIT=1\n"}
```
<!-- A5_ENTRY_END sql-probe-failed-1.txt -->

### Retained sql-probe-corrected.txt

Encoding utf16le; SHA256 `c2d9b9c4b3268ff3fcd3f13c46cb0d7c8f768602889212bfc233efa16549f40b`.

<!-- A5_ENTRY_BEGIN sql-probe-corrected.txt -->
```json
{"name":"sql-probe-corrected.txt","encoding":"utf16le","sha256":"c2d9b9c4b3268ff3fcd3f13c46cb0d7c8f768602889212bfc233efa16549f40b","text":"﻿G2 seed replay PASS: 150 existing slug/UUID pairs identical; no invented exercise IDs\r\nG2 expiry PASS {\"seconds\":-1,\"isQuest\":false,\"quest_day\":\"2026-10-20\",\"finish_day\":\"2026-10-20\",\"unexpired\":false,\"status\":\"active\"}\r\nG2 expiry PASS {\"seconds\":1,\"isQuest\":true,\"quest_day\":\"2026-10-20\",\"finish_day\":\"2026-10-20\",\"unexpired\":true,\"status\":\"completed\"}\r\nG5 FK inventory [{\"child\":\"class_synergies\",\"conname\":\"class_synergies_primary_class_id_fkey\",\"definition\":\"FOREIGN KEY (primary_class_id) REFERENCES class_definitions(class_id)\",\"leading_index\":true},{\"child\":\"class_synergies\",\"conname\":\"class_synergies_secondary_class_id_fkey\",\"definition\":\"FOREIGN KEY (secondary_class_id) REFERENCES class_definitions(class_id)\",\"leading_index\":false},{\"child\":\"coach_daily_usage\",\"conname\":\"coach_daily_usage_user_id_fkey\",\"definition\":\"FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE\",\"leading_index\":true},{\"child\":\"exercise_prs\",\"conname\":\"exercise_prs_exercise_id_fkey\",\"definition\":\"FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE\",\"leading_index\":false},{\"child\":\"exercise_prs\",\"conname\":\"exercise_prs_user_id_fkey\",\"definition\":\"FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE\",\"leading_index\":true},{\"child\":\"profiles\",\"conname\":\"profiles_id_fkey\",\"definition\":\"FOREIGN KEY (id) REFERENCES users(id) ON DELETE CASCADE\",\"leading_index\":true},{\"child\":\"quest_instances\",\"conname\":\"quest_instances_quest_id_fkey\",\"definition\":\"FOREIGN KEY (quest_id) REFERENCES quests(id) ON DELETE CASCADE\",\"leading_index\":false},{\"child\":\"quest_instances\",\"conname\":\"quest_instances_user_id_fkey\",\"definition\":\"FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE\",\"leading_index\":true},{\"child\":\"streaks\",\"conname\":\"streaks_user_id_fkey\",\"definition\":\"FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE\",\"leading_index\":true},{\"child\":\"user_achievements\",\"conname\":\"user_achievements_user_id_fkey\",\"definition\":\"FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE\",\"leading_index\":true},{\"child\":\"user_classes\",\"conname\":\"user_classes_user_id_fkey\",\"definition\":\"FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE\",\"leading_index\":true},{\"child\":\"users\",\"conname\":\"users_id_fkey\",\"definition\":\"FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE\",\"leading_index\":true},{\"child\":\"workout_exercises\",\"conname\":\"workout_exercises_exercise_id_fkey\",\"definition\":\"FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE\",\"leading_index\":false},{\"child\":\"workout_exercises\",\"conname\":\"workout_exercises_workout_id_fkey\",\"definition\":\"FOREIGN KEY (workout_id) REFERENCES workouts(id) ON DELETE CASCADE\",\"leading_index\":true},{\"child\":\"workout_rewards\",\"conname\":\"workout_rewards_user_id_fkey\",\"definition\":\"FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE\",\"leading_index\":true},{\"child\":\"workout_rewards\",\"conname\":\"workout_rewards_workout_id_fkey\",\"definition\":\"FOREIGN KEY (workout_id) REFERENCES workouts(id) ON DELETE CASCADE\",\"leading_index\":true},{\"child\":\"workout_sets\",\"conname\":\"workout_sets_workout_exercise_id_fkey\",\"definition\":\"FOREIGN KEY (workout_exercise_id) REFERENCES workout_exercises(id) ON DELETE CASCADE\",\"leading_index\":true},{\"child\":\"workouts\",\"conname\":\"workouts_user_id_fkey\",\"definition\":\"FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE\",\"leading_index\":true},{\"child\":\"xp_logs\",\"conname\":\"xp_logs_user_id_fkey\",\"definition\":\"FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE\",\"leading_index\":true}]\r\nG5 history count=100 offset=0 role=authenticated [{\"QUERY PLAN\":[{\"Plan\":{\"Node Type\":\"Limit\",\"Parallel Aware\":false,\"Async Capable\":false,\"Startup Cost\":0.18,\"Total Cost\":4.31,\"Plan Rows\":20,\"Plan Width\":24,\"Plans\":[{\"Node Type\":\"Result\",\"Parent Relationship\":\"InitPlan\",\"Subplan Name\":\"InitPlan 1\",\"Parallel Aware\":false,\"Async Capable\":false,\"Startup Cost\":0,\"Total Cost\":0.03,\"Plan Rows\":1,\"Plan Width\":16},{\"Node Type\":\"Result\",\"Parent Relationship\":\"Outer\",\"Parallel Aware\":false,\"Async Capable\":false,\"Startup Cost\":0.14,\"Total Cost\":20.83,\"Plan Rows\":100,\"Plan Width\":24,\"One-Time Filter\":\"((InitPlan 1).col1 = 'a5000000-0000-4000-8000-000000000003'::uuid)\",\"Plans\":[{\"Node Type\":\"Index Scan\",\"Parent Relationship\":\"Outer\",\"Parallel Aware\":false,\"Async Capable\":false,\"Scan Direction\":\"Forward\",\"Index Name\":\"workout_history_user_completed\",\"Relation Name\":\"workouts\",\"Alias\":\"workouts\",\"Startup Cost\":0.14,\"Total Cost\":20.83,\"Plan Rows\":100,\"Plan Width\":24,\"Index Cond\":\"(user_id = 'a5000000-0000-4000-8000-000000000003'::uuid)\"}]}]}}]}]\r\nG5 history count=100 offset=80 role=authenticated [{\"QUERY PLAN\":[{\"Plan\":{\"Node Type\":\"Limit\",\"Parallel Aware\":false,\"Async Capable\":false,\"Startup Cost\":9.06,\"Total Cost\":9.11,\"Plan Rows\":20,\"Plan Width\":24,\"Plans\":[{\"Node Type\":\"Result\",\"Parent Relationship\":\"InitPlan\",\"Subplan Name\":\"InitPlan 1\",\"Parallel Aware\":false,\"Async Capable\":false,\"Startup Cost\":0,\"Total Cost\":0.03,\"Plan Rows\":1,\"Plan Width\":16},{\"Node Type\":\"Sort\",\"Parent Relationship\":\"Outer\",\"Parallel Aware\":false,\"Async Capable\":false,\"Startup Cost\":8.82,\"Total Cost\":9.07,\"Plan Rows\":100,\"Plan Width\":24,\"Sort Key\":[\"workouts.completed_at DESC\"],\"Plans\":[{\"Node Type\":\"Result\",\"Parent Relationship\":\"Outer\",\"Parallel Aware\":false,\"Async Capable\":false,\"Startup Cost\":0,\"Total Cost\":5.5,\"Plan Rows\":100,\"Plan Width\":24,\"One-Time Filter\":\"((InitPlan 1).col1 = 'a5000000-0000-4000-8000-000000000003'::uuid)\",\"Plans\":[{\"Node Type\":\"Seq Scan\",\"Parent Relationship\":\"Outer\",\"Parallel Aware\":false,\"Async Capable\":false,\"Relation Name\":\"workouts\",\"Alias\":\"workouts\",\"Startup Cost\":0,\"Total Cost\":5.5,\"Plan Rows\":100,\"Plan Width\":24,\"Filter\":\"((user_id = 'a5000000-0000-4000-8000-000000000003'::uuid) AND (status = 'completed'::text))\"}]}]}]}}]}]\r\nG5 aggregate count=100 role=owner (RPC definer query shape) [{\"QUERY PLAN\":[{\"Plan\":{\"Node Type\":\"Aggregate\",\"Strategy\":\"Sorted\",\"Partial Mode\":\"Simple\",\"Parallel Aware\":false,\"Async Capable\":false,\"Startup Cost\":13.05,\"Total Cost\":13.26,\"Plan Rows\":7,\"Plan Width\":36,\"Group Key\":[\"(((w.completed_at AT TIME ZONE 'Asia/Ho_Chi_Minh'::text))::date)\"],\"Plans\":[{\"Node Type\":\"Sort\",\"Parent Relationship\":\"Outer\",\"Parallel Aware\":false,\"Async Capable\":false,\"Startup Cost\":13.05,\"Total Cost\":13.07,\"Plan Rows\":7,\"Plan Width\":13,\"Sort Key\":[\"(((w.completed_at AT TIME ZONE 'Asia/Ho_Chi_Minh'::text))::date)\"],\"Plans\":[{\"Node Type\":\"Nested Loop\",\"Parent Relationship\":\"Outer\",\"Parallel Aware\":false,\"Async Capable\":false,\"Join Type\":\"Inner\",\"Startup Cost\":7.48,\"Total Cost\":12.96,\"Plan Rows\":7,\"Plan Width\":13,\"Inner Unique\":false,\"Plans\":[{\"Node Type\":\"Hash Join\",\"Parent Relationship\":\"Outer\",\"Parallel Aware\":false,\"Async Capable\":false,\"Join Type\":\"Inner\",\"Startup Cost\":7.34,\"Total Cost\":10.61,\"Plan Rows\":7,\"Plan Width\":24,\"Inner Unique\":true,\"Hash Cond\":\"(we.workout_id = w.id)\",\"Plans\":[{\"Node Type\":\"Seq Scan\",\"Parent Relationship\":\"Outer\",\"Parallel Aware\":false,\"Async Capable\":false,\"Relation Name\":\"workout_exercises\",\"Alias\":\"we\",\"Startup Cost\":0,\"Total Cost\":3,\"Plan Rows\":100,\"Plan Width\":32},{\"Node Type\":\"Hash\",\"Parent Relationship\":\"Inner\",\"Parallel Aware\":false,\"Async Capable\":false,\"Startup Cost\":7.25,\"Total Cost\":7.25,\"Plan Rows\":7,\"Plan Width\":24,\"Plans\":[{\"Node Type\":\"Seq Scan\",\"Parent Relationship\":\"Outer\",\"Parallel Aware\":false,\"Async Capable\":false,\"Relation Name\":\"workouts\",\"Alias\":\"w\",\"Startup Cost\":0,\"Total Cost\":7.25,\"Plan Rows\":7,\"Plan Width\":24,\"Filter\":\"((user_id = 'a5000000-0000-4000-8000-000000000003'::uuid) AND (status = 'completed'::text) AND (completed_at >= (((((now() AT TIME ZONE 'Asia/Ho_Chi_Minh'::text))::date - 6))::timestamp without time zone AT TIME ZONE 'Asia/Ho_Chi_Minh'::text)))\"}]}]},{\"Node Type\":\"Index Scan\",\"Parent Relationship\":\"Inner\",\"Parallel Aware\":false,\"Async Capable\":false,\"Scan Direction\":\"Forward\",\"Index Name\":\"idx_workout_sets_workout_exercise_id\",\"Relation Name\":\"workout_sets\",\"Alias\":\"s\",\"Startup Cost\":0.14,\"Total Cost\":0.32,\"Plan Rows\":1,\"Plan Width\":25,\"Index Cond\":\"(workout_exercise_id = we.id)\",\"Filter\":\"is_completed\"}]}]}]}}]}]\r\nG5 aggregate functional control count=100 days=7 PASS\r\nG5 history count=1000 offset=0 role=authenticated [{\"QUERY PLAN\":[{\"Plan\":{\"Node Type\":\"Limit\",\"Parallel Aware\":false,\"Async Capable\":false,\"Startup Cost\":0.31,\"Total Cost\":3.01,\"Plan Rows\":20,\"Plan Width\":24,\"Plans\":[{\"Node Type\":\"Result\",\"Parent Relationship\":\"InitPlan\",\"Subplan Name\":\"InitPlan 1\",\"Parallel Aware\":false,\"Async Capable\":false,\"Startup Cost\":0,\"Total Cost\":0.03,\"Plan Rows\":1,\"Plan Width\":16},{\"Node Type\":\"Result\",\"Parent Relationship\":\"Outer\",\"Parallel Aware\":false,\"Async Capable\":false,\"Startup Cost\":0.28,\"Total Cost\":135.34,\"Plan Rows\":1000,\"Plan Width\":24,\"One-Time Filter\":\"((InitPlan 1).col1 = 'a5000000-0000-4000-8000-000000000003'::uuid)\",\"Plans\":[{\"Node Type\":\"Index Scan\",\"Parent Relationship\":\"Outer\",\"Parallel Aware\":false,\"Async Capable\":false,\"Scan Direction\":\"Forward\",\"Index Name\":\"workout_history_user_completed\",\"Relation Name\":\"workouts\",\"Alias\":\"workouts\",\"Startup Cost\":0.28,\"Total Cost\":135.34,\"Plan Rows\":1000,\"Plan Width\":24,\"Index Cond\":\"(user_id = 'a5000000-0000-4000-8000-000000000003'::uuid)\"}]}]}}]}]\r\nG5 history count=1000 offset=980 role=authenticated [{\"QUERY PLAN\":[{\"Plan\":{\"Node Type\":\"Limit\",\"Parallel Aware\":false,\"Async Capable\":false,\"Startup Cost\":105.31,\"Total Cost\":105.36,\"Plan Rows\":20,\"Plan Width\":24,\"Plans\":[{\"Node Type\":\"Result\",\"Parent Relationship\":\"InitPlan\",\"Subplan Name\":\"InitPlan 1\",\"Parallel Aware\":false,\"Async Capable\":false,\"Startup Cost\":0,\"Total Cost\":0.03,\"Plan Rows\":1,\"Plan Width\":16},{\"Node Type\":\"Sort\",\"Parent Relationship\":\"Outer\",\"Parallel Aware\":false,\"Async Capable\":false,\"Startup Cost\":102.83,\"Total Cost\":105.33,\"Plan Rows\":1000,\"Plan Width\":24,\"Sort Key\":[\"workouts.completed_at DESC\"],\"Plans\":[{\"Node Type\":\"Result\",\"Parent Relationship\":\"Outer\",\"Parallel Aware\":false,\"Async Capable\":false,\"Startup Cost\":0,\"Total Cost\":53,\"Plan Rows\":1000,\"Plan Width\":24,\"One-Time Filter\":\"((InitPlan 1).col1 = 'a5000000-0000-4000-8000-000000000003'::uuid)\",\"Plans\":[{\"Node Type\":\"Seq Scan\",\"Parent Relationship\":\"Outer\",\"Parallel Aware\":false,\"Async Capable\":false,\"Relation Name\":\"workouts\",\"Alias\":\"workouts\",\"Startup Cost\":0,\"Total Cost\":53,\"Plan Rows\":1000,\"Plan Width\":24,\"Filter\":\"((user_id = 'a5000000-0000-4000-8000-000000000003'::uuid) AND (status = 'completed'::text))\"}]}]}]}}]}]\r\nG5 aggregate count=1000 role=owner (RPC definer query shape) [{\"QUERY PLAN\":[{\"Plan\":{\"Node Type\":\"Aggregate\",\"Strategy\":\"Sorted\",\"Partial Mode\":\"Simple\",\"Parallel Aware\":false,\"Async Capable\":false,\"Startup Cost\":46.46,\"Total Cost\":46.67,\"Plan Rows\":7,\"Plan Width\":36,\"Group Key\":[\"(((w.completed_at AT TIME ZONE 'Asia/Ho_Chi_Minh'::text))::date)\"],\"Plans\":[{\"Node Type\":\"Sort\",\"Parent Relationship\":\"Outer\",\"Parallel Aware\":false,\"Async Capable\":false,\"Startup Cost\":46.46,\"Total Cost\":46.48,\"Plan Rows\":7,\"Plan Width\":13,\"Sort Key\":[\"(((w.completed_at AT TIME ZONE 'Asia/Ho_Chi_Minh'::text))::date)\"],\"Plans\":[{\"Node Type\":\"Nested Loop\",\"Parent Relationship\":\"Outer\",\"Parallel Aware\":false,\"Async Capable\":false,\"Join Type\":\"Inner\",\"Startup Cost\":19.29,\"Total Cost\":46.37,\"Plan Rows\":7,\"Plan Width\":13,\"Inner Unique\":false,\"Plans\":[{\"Node Type\":\"Hash Join\",\"Parent Relationship\":\"Outer\",\"Parallel Aware\":false,\"Async Capable\":false,\"Join Type\":\"Inner\",\"Startup Cost\":19.02,\"Total Cost\":43.65,\"Plan Rows\":7,\"Plan Width\":24,\"Inner Unique\":true,\"Hash Cond\":\"(we.workout_id = w.id)\",\"Plans\":[{\"Node Type\":\"Seq Scan\",\"Parent Relationship\":\"Outer\",\"Parallel Aware\":false,\"Async Capable\":false,\"Relation Name\":\"workout_exercises\",\"Alias\":\"we\",\"Startup Cost\":0,\"Total Cost\":22,\"Plan Rows\":1000,\"Plan Width\":32},{\"Node Type\":\"Hash\",\"Parent Relationship\":\"Inner\",\"Parallel Aware\":false,\"Async Capable\":false,\"Startup Cost\":18.93,\"Total Cost\":18.93,\"Plan Rows\":7,\"Plan Width\":24,\"Plans\":[{\"Node Type\":\"Index Scan\",\"Parent Relationship\":\"Outer\",\"Parallel Aware\":false,\"Async Capable\":false,\"Scan Direction\":\"Forward\",\"Index Name\":\"workout_history_user_completed\",\"Relation Name\":\"workouts\",\"Alias\":\"w\",\"Startup Cost\":0.29,\"Total Cost\":18.93,\"Plan Rows\":7,\"Plan Width\":24,\"Index Cond\":\"((user_id = 'a5000000-0000-4000-8000-000000000003'::uuid) AND (completed_at >= (((((now() AT TIME ZONE 'Asia/Ho_Chi_Minh'::text))::date - 6))::timestamp without time zone AT TIME ZONE 'Asia/Ho_Chi_Minh'::text)))\"}]}]},{\"Node Type\":\"Index Scan\",\"Parent Relationship\":\"Inner\",\"Parallel Aware\":false,\"Async Capable\":false,\"Scan Direction\":\"Forward\",\"Index Name\":\"idx_workout_sets_workout_exercise_id\",\"Relation Name\":\"workout_sets\",\"Alias\":\"s\",\"Startup Cost\":0.28,\"Total Cost\":0.37,\"Plan Rows\":1,\"Plan Width\":25,\"Index Cond\":\"(workout_exercise_id = we.id)\",\"Filter\":\"is_completed\"}]}]}]}}]}]\r\nG5 aggregate functional control count=1000 days=7 PASS\r\nA5_SQL_PROBE PASS; fresh DBs=2; network fetches=0; independent concurrency NOT RUN\r\n"}
```
<!-- A5_ENTRY_END sql-probe-corrected.txt -->

### Retained edge-probe.txt

Encoding utf8; SHA256 `f96d6d6bd7d9f3a88ce8dd757c14e1c576e37788a434569425b8a143a84c5c4d`.

<!-- A5_ENTRY_BEGIN edge-probe.txt -->
```json
{"name":"edge-probe.txt","encoding":"utf8","sha256":"f96d6d6bd7d9f3a88ce8dd757c14e1c576e37788a434569425b8a143a84c5c4d","text":"G3 request PASS {\"kind\":\"rpc\",\"scenario\":\"oversize-no-length\",\"status\":413,\"bytes\":32768,\"units\":32768,\"consumed\":32768,\"pulls\":33,\"canceled\":0,\"firstEvent\":\"auth\",\"rpcDelta\":0}\nG3 request PASS {\"kind\":\"rpc\",\"scenario\":\"oversize-header\",\"status\":413,\"bytes\":32768,\"units\":32768,\"consumed\":32768,\"pulls\":33,\"canceled\":0,\"firstEvent\":\"auth\",\"rpcDelta\":0}\nG3 request PASS {\"kind\":\"rpc\",\"scenario\":\"under\",\"status\":200,\"bytes\":16,\"units\":16,\"consumed\":16,\"pulls\":2,\"canceled\":0,\"firstEvent\":\"auth\",\"rpcDelta\":1}\nG3 request PASS {\"kind\":\"rpc\",\"scenario\":\"multibyte\",\"status\":200,\"bytes\":30029,\"units\":10029,\"consumed\":30029,\"pulls\":31,\"canceled\":0,\"firstEvent\":\"auth\",\"rpcDelta\":1}\nG3 request PASS {\"kind\":\"rpc\",\"scenario\":\"missing-auth\",\"status\":401,\"bytes\":16,\"units\":16,\"consumed\":0,\"pulls\":0,\"canceled\":0,\"firstEvent\":null,\"rpcDelta\":0}\nG3 request PASS {\"kind\":\"rpc\",\"scenario\":\"rejected-auth\",\"status\":401,\"bytes\":16,\"units\":16,\"consumed\":0,\"pulls\":0,\"canceled\":0,\"firstEvent\":\"auth\",\"rpcDelta\":0}\nG3 request PASS {\"kind\":\"coach\",\"scenario\":\"oversize-no-length\",\"status\":413,\"bytes\":32768,\"units\":32768,\"consumed\":32768,\"pulls\":33,\"canceled\":0,\"firstEvent\":\"auth\",\"rpcDelta\":0}\nG3 request PASS {\"kind\":\"coach\",\"scenario\":\"oversize-header\",\"status\":413,\"bytes\":32768,\"units\":32768,\"consumed\":32768,\"pulls\":33,\"canceled\":0,\"firstEvent\":\"auth\",\"rpcDelta\":0}\nG3 request PASS {\"kind\":\"coach\",\"scenario\":\"under\",\"status\":200,\"bytes\":16,\"units\":16,\"consumed\":16,\"pulls\":2,\"canceled\":0,\"firstEvent\":\"auth\",\"rpcDelta\":0}\nG3 request PASS {\"kind\":\"coach\",\"scenario\":\"multibyte\",\"status\":200,\"bytes\":30029,\"units\":10029,\"consumed\":30029,\"pulls\":31,\"canceled\":0,\"firstEvent\":\"auth\",\"rpcDelta\":0}\nG3 request PASS {\"kind\":\"coach\",\"scenario\":\"missing-auth\",\"status\":401,\"bytes\":16,\"units\":16,\"consumed\":0,\"pulls\":0,\"canceled\":0,\"firstEvent\":null,\"rpcDelta\":0}\nG3 request PASS {\"kind\":\"coach\",\"scenario\":\"rejected-auth\",\"status\":401,\"bytes\":16,\"units\":16,\"consumed\":0,\"pulls\":0,\"canceled\":0,\"firstEvent\":\"auth\",\"rpcDelta\":0}\nG3 provider PASS {\"scenario\":\"long-answer\",\"status\":502,\"bytes\":77053,\"units\":77053,\"consumed\":77053,\"pulls\":77,\"canceled\":0}\nG3 provider PASS {\"scenario\":\"padding\",\"status\":200,\"bytes\":64055,\"units\":64055,\"consumed\":64055,\"pulls\":64,\"canceled\":0}\nG3 provider PASS {\"scenario\":\"non-ok\",\"status\":502,\"bytes\":64055,\"units\":64055,\"consumed\":0,\"pulls\":0,\"canceled\":0}\nA5_EDGE_PROBE PASS; request cases=12; provider cases=3; all fetches synthetic; {\"authCalls\":5,\"rpcCalls\":2,\"fetchCalls\":7}\n\nEXIT=0\n"}
```
<!-- A5_ENTRY_END edge-probe.txt -->

### Retained sql-existing.txt

Encoding utf8; SHA256 `92e529bf8f7d1356c47daa06dddaefd99e6cd378b57fc129fe24045ab0803153`.

<!-- A5_ENTRY_BEGIN sql-existing.txt -->
```json
{"name":"sql-existing.txt","encoding":"utf8","sha256":"92e529bf8f7d1356c47daa06dddaefd99e6cd378b57fc129fe24045ab0803153","text":"PASS isolated auth/role bootstrap\nPASS migration 20261026000100_baseline.sql\nPASS migration 20261026000200_authoritative_progression.sql\nPASS migration 20261027000100_exercise_catalog_metadata.sql\nPASS seed ./seed.sql\nPASS seed replay ./seed.sql\nPASS seed ./seed_exercises.sql\nPASS seed replay ./seed_exercises.sql\nPASS SQL regression progression_regression.sql\nPASS SQL regression security_regression.sql\nVERIFIED exercise catalog count: 150 exercises (target 120-200)\nVERIFIED exercise catalog metadata integrity (0 null/empty fields)\nVERIFIED workout_sets duration_seconds column exists\nVERIFIED static hold / duration_seconds check constraint behavior\nPASS 10 SQL verification units against PostgreSQL 17.5\nLIMITATION: isolated single-connection PostgreSQL; Supabase gateway/Auth/Edge runtime and true concurrent sessions require the local stack.\n\nEXIT=0\n"}
```
<!-- A5_ENTRY_END sql-existing.txt -->

### Retained edge-existing.txt

Encoding utf8; SHA256 `606d56ace6515bef86320a2032abf1ab98dedd4e39ae61b48821e3f2d0397b70`.

<!-- A5_ENTRY_BEGIN edge-existing.txt -->
```json
{"name":"edge-existing.txt","encoding":"utf8","sha256":"606d56ace6515bef86320a2032abf1ab98dedd4e39ae61b48821e3f2d0397b70","text":"\u001b[0m\u001b[38;5;245mrunning 7 tests from ./supabase/functions/ai-coach/service_test.ts\u001b[0m\ncoach requires a valid user token ... \u001b[0m\u001b[32mok\u001b[0m \u001b[0m\u001b[38;5;245m(22ms)\u001b[0m\ncoach validates input before consuming quota ... \u001b[0m\u001b[32mok\u001b[0m \u001b[0m\u001b[38;5;245m(814µs)\u001b[0m\ncoach unavailable when no provider is selected ... \u001b[0m\u001b[32mok\u001b[0m \u001b[0m\u001b[38;5;245m(370µs)\u001b[0m\ncoach enforces daily quota ... \u001b[0m\u001b[32mok\u001b[0m \u001b[0m\u001b[38;5;245m(352µs)\u001b[0m\ncoach returns only generated answer and sanitized provider errors ... \u001b[0m\u001b[32mok\u001b[0m \u001b[0m\u001b[38;5;245m(1ms)\u001b[0m\ncoach handles timeout and malformed provider result ... \u001b[0m\u001b[32mok\u001b[0m \u001b[0m\u001b[38;5;245m(831µs)\u001b[0m\ncoach sanitizes prompt against control chars and injection delimiters ... \u001b[0m\u001b[32mok\u001b[0m \u001b[0m\u001b[38;5;245m(611µs)\u001b[0m\n\u001b[0m\u001b[38;5;245mrunning 5 tests from ./supabase/functions/tests/http_handler_test.ts\u001b[0m\nRPC handler rejects unauthenticated requests before database access ... \u001b[0m\u001b[32mok\u001b[0m \u001b[0m\u001b[38;5;245m(10ms)\u001b[0m\nRPC handler rejects expired or invalid tokens with a sanitized 401 ... \u001b[0m\u001b[32mok\u001b[0m \u001b[0m\u001b[38;5;245m(5ms)\u001b[0m\nRPC handler verifies user and forwards the same access token to PostgreSQL ... \u001b[0m\u001b[32mok\u001b[0m \u001b[0m\u001b[38;5;245m(3ms)\u001b[0m\nRPC handler validates JSON shape and size before calling the database ... \u001b[0m\u001b[32mok\u001b[0m \u001b[0m\u001b[38;5;245m(2ms)\u001b[0m\nRPC handler sanitizes database errors without leaking internal messages ... \u001b[0m\u001b[32mok\u001b[0m \u001b[0m\u001b[38;5;245m(1ms)\u001b[0m\n\u001b[0m\u001b[38;5;245mrunning 3 tests from ./supabase/functions/tests/request_validation_test.ts\u001b[0m\nOnly a nonempty Bearer credential is accepted ... \u001b[0m\u001b[32mok\u001b[0m \u001b[0m\u001b[38;5;245m(777µs)\u001b[0m\nWorkout identifiers are validated before database access ... \u001b[0m\u001b[32mok\u001b[0m \u001b[0m\u001b[38;5;245m(264µs)\u001b[0m\nDatabase failures expose stable sanitized errors ... \u001b[0m\u001b[32mok\u001b[0m \u001b[0m\u001b[38;5;245m(155µs)\u001b[0m\n\n\u001b[0m\u001b[32mok\u001b[0m | 15 passed | 0 failed \u001b[0m\u001b[38;5;245m(254ms)\u001b[0m\n\n\nEXIT=0\n"}
```
<!-- A5_ENTRY_END edge-existing.txt -->

### Retained edge-check.txt

Encoding utf8; SHA256 `0e606818852cc6d4e60902e87575d34ac32240a5d6906a692c9213d2c43e035c`.

<!-- A5_ENTRY_BEGIN edge-check.txt -->
```json
{"name":"edge-check.txt","encoding":"utf8","sha256":"0e606818852cc6d4e60902e87575d34ac32240a5d6906a692c9213d2c43e035c","text":"\nEXIT=0\n"}
```
<!-- A5_ENTRY_END edge-check.txt -->

### Retained inputs.json

Encoding utf8; SHA256 `5e9f3c18ff32a43082667984d58857f5462f1566bbdb057489505e0492eccb42`.

<!-- A5_ENTRY_BEGIN inputs.json -->
```json
[
  {
    "path": ".github/workflows/verify.yml",
    "sha256": "8018f554ba146571883678bf115de37f89ccbea2b71472b1fe8135371a4ed55e"
  },
  {
    "path": "app/lib/features/workout/data/supabase_workout_repository.dart",
    "sha256": "2649199ecfafa65d4b7dc5069b834c975d2a2a45ae3bc69c09a8a209c79bbb78"
  },
  {
    "path": "supabase/config.toml",
    "sha256": "527943b131f36ca73f4f52babc5785d3e5c4b8950e82eee3cb53a162ce2ae443"
  },
  {
    "path": "supabase/functions/_shared/http.ts",
    "sha256": "0840213ae512b242d2a1bc5a4dd087f504d3c5111202b14f8023fdba2369b890"
  },
  {
    "path": "supabase/functions/_shared/validation.ts",
    "sha256": "ca7c6611d031336e6c4801a1542cc3e5f8a9b266ab431dea4d078653a9e18673"
  },
  {
    "path": "supabase/functions/ai-coach/index.ts",
    "sha256": "b359b3d98637d01e9df1894d9f2904b984994da72cf0b925b580f5cd0dd2d6bb"
  },
  {
    "path": "supabase/functions/ai-coach/service.ts",
    "sha256": "a90a004a9601a6112903054ae8d89751e55304c35be31432531691b0543f1da7"
  },
  {
    "path": "supabase/functions/ai-coach/service_test.ts",
    "sha256": "6c9551947a6a1efca8ccb9503bc203635effa44772cf6df697a724e7677c7cd2"
  },
  {
    "path": "supabase/functions/calculate-xp/index.ts",
    "sha256": "b7a982c3af0f919d932e5357abf6efbcde3a77e12991d135d7460e930d173b94"
  },
  {
    "path": "supabase/functions/get-user-stats/index.ts",
    "sha256": "90228953adcd1be28ac1bc52a9a6c68cc3d15bf6be3291c1ec783fda534be091"
  },
  {
    "path": "supabase/functions/initialize-user/index.ts",
    "sha256": "18bf29b47756fedeebec1c4ceaa8bae5a39aab3eccde5822a6f0bccfed950489"
  },
  {
    "path": "supabase/functions/switch-class/index.ts",
    "sha256": "0db1e1672c55fa978c135a8a72ea2920b2a596aeb4fea6231e9801390a5da886"
  },
  {
    "path": "supabase/functions/sync-daily-data/index.ts",
    "sha256": "e1f5c43dc6843ae0d0358693114413c1cf5954e1ca99bdb7eee8a4ffd226258c"
  },
  {
    "path": "supabase/functions/tests/http_handler_test.ts",
    "sha256": "38198111e44727df0c635acd7740c86883ee3512ffd8265d9439e71b58e58be6"
  },
  {
    "path": "supabase/functions/tests/request_validation_test.ts",
    "sha256": "db724e6131963854d9018ce214f3ddd03795024f077e3c4ea3bc40a97924e8b1"
  },
  {
    "path": "supabase/migrations/20261026000100_baseline.sql",
    "sha256": "e4e56bd1a1bb770fb28fec09ee5590302b89554d33f255b559499d1d8c21fc44"
  },
  {
    "path": "supabase/migrations/20261026000200_authoritative_progression.sql",
    "sha256": "4b5f5682a25da4abbba8ca0aa3c4b6ed22ab92bc30021a9cef8b5f750b2dfc62"
  },
  {
    "path": "supabase/migrations/20261027000100_exercise_catalog_metadata.sql",
    "sha256": "143b69653bb9b178fbc8b3fda6380ee1021be958a39d32f7bfac4f53727fbefb"
  },
  {
    "path": "supabase/seed.sql",
    "sha256": "a96d9f5830b8cab1b99501725d1a9ff31fedb8a18900a463240ac246db392c68"
  },
  {
    "path": "supabase/seed_exercises.sql",
    "sha256": "9af8382923d798fee30ccbe32986873440f5fd25588a0cea00acf408ad00c748"
  },
  {
    "path": "supabase/tests/progression_regression.sql",
    "sha256": "be70310339b2f5bbd41a437d20f4b3fdecdc1145dfb7a348a67ce5a6ac383f76"
  },
  {
    "path": "supabase/tests/security_regression.sql",
    "sha256": "088cf49d459de1e855a70c3f4957ae6801c756ad92577a6731fca93285ff4453"
  },
  {
    "path": "tools/db-tests/README.md",
    "sha256": "adaeae889a3c1e9a7b97aed22e286e03d935860394c4dea10e053948f2b5676e"
  },
  {
    "path": "tools/db-tests/adversarial-anti-cheat.mjs",
    "sha256": "230550f68e0bb1721f6808a67dffa828d8848683531387d70dc527bd86017889"
  },
  {
    "path": "tools/db-tests/adversarial-coach.mjs",
    "sha256": "01c4a62db5f3200066ba1f6294a2671af6fa4234d8213e119cd538a10ca2fc12"
  },
  {
    "path": "tools/db-tests/bootstrap.sql",
    "sha256": "fbfdd130ab2a2db10f9c5f850589fee746bee1b327e366c41179ca5931a7f250"
  },
  {
    "path": "tools/db-tests/browser-smoke.mjs",
    "sha256": "389b8263c5bfb88e1577a7fe0d7d1293f955a1027f2dca03c7ccac2b173710cb"
  },
  {
    "path": "tools/db-tests/e2e-catalog-test.mjs",
    "sha256": "2fcd57cfd0bb28f6d52cc89991379d1cbe299f8d703fb6daed5744f4fb9fc88f"
  },
  {
    "path": "tools/db-tests/edge-tests.mjs",
    "sha256": "77e2217661c528ff4286daf84bb4e4d8807b0cc13a1e34cde018520f7c92c922"
  },
  {
    "path": "tools/db-tests/inspect-user-ui.mjs",
    "sha256": "3dede976be9ad2c4b2a98f24c0564704575c249aa967bb41dd3ba7973e92e593"
  },
  {
    "path": "tools/db-tests/legacy-adoption.mjs",
    "sha256": "3055a608fc2d1664cfd6f8c6b2f814f728032f17ce091f5172c15f465afa7038"
  },
  {
    "path": "tools/db-tests/live-e2e.mjs",
    "sha256": "a809634a5ea89059b359758833c49fce09a4f41a13f62650eb00dc5b127a044c"
  },
  {
    "path": "tools/db-tests/run-complete-e2e-user-test.mjs",
    "sha256": "bac5a31ad94442609cf91073ca051a8d9c18c8bbeacb4f0be07a25d4ec669ab5"
  },
  {
    "path": "tools/db-tests/run.mjs",
    "sha256": "7a147790aece00d88b04fc3bc449fbb945840a4400851599408bf5ca8d260853"
  },
  {
    "path": "tools/db-tests/test-all-screens-thoroughly.mjs",
    "sha256": "be40a91982df92d8f03bffafb2ceaa1d23daaec10b1c8012865cff5bbdbb5e49"
  },
  {
    "path": "tools/db-tests/test-login-flow.mjs",
    "sha256": "94aa39b7548e217bd252f20e3de185098a66a42c1af929dfc637c82d6e64dac7"
  },
  {
    "path": "tools/db-tests/test-reload.mjs",
    "sha256": "5ae6a78aa36edb93af8a94446c196fdbbfef32aa88bef7644617defaf77f0cd4"
  },
  {
    "path": "tools/db-tests/test-semantics.mjs",
    "sha256": "1d99570b7de8d1b9ad1a40de068fec2dfbe92de2f3476b57481b82869bd5ba65"
  }
]

```
<!-- A5_ENTRY_END inputs.json -->

### Retained retain-failed-1.cjs

Encoding utf8; SHA256 `6c00794fc23365c2193612687777decd2ce971be73ab28450384a081e334c923`.

<!-- A5_ENTRY_BEGIN retain-failed-1.cjs -->
```javascript
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const file=path.join(process.cwd(),'docs/audit/phases/A5_BACKEND_EVIDENCE.md'),out=__dirname;
const names=['run.cjs','sql.mjs','sql-failed-1.mjs','edge.ts','sql-probe-failed-1.txt','sql-probe-corrected.txt','edge-probe.txt','sql-existing.txt','edge-existing.txt','edge-check.txt','inputs.json','retain.cjs'];
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const entries=names.map(name=>{const b=fs.readFileSync(path.join(out,name)),text=b.toString('utf8');assert.equal(hash(Buffer.from(text,'utf8')),hash(b));return{name,sha256:hash(b),text};});
const md=fs.readFileSync(file,'utf8'),marker='<!-- A5_RETAINED_PENDING -->';assert.equal(md.split(marker).length,2);
const appendix=entries.map(e=>{const log=e.name.endsWith('.txt');return '\n### Retained '+e.name+'\n\nSHA256 `'+e.sha256+'`.\n\n<!-- A5_ENTRY_BEGIN '+e.name+' -->\n```'+(log?'json':e.name.endsWith('.json')?'json':'javascript')+'\n'+(log?JSON.stringify(e):e.text)+'\n```\n<!-- A5_ENTRY_END '+e.name+' -->\n';}).join('');
fs.writeFileSync(file,md.replace(marker,appendix));
const retained=fs.readFileSync(file,'utf8');for(const e of entries){const start='<!-- A5_ENTRY_BEGIN '+e.name+' -->\n',end='<!-- A5_ENTRY_END '+e.name+' -->';const section=retained.split(start)[1].split(end)[0],body=section.slice(section.indexOf('\n')+1,section.lastIndexOf('\n```'));const text=e.name.endsWith('.txt')?JSON.parse(body).text:body;assert.equal(hash(Buffer.from(text,'utf8')),e.sha256,e.name);}
console.log('A5_RETENTION PASS: 12 full source/log/manifest entries extracted from repository MD match original SHA256; input hashes='+JSON.parse(entries.find(e=>e.name==='inputs.json').text).length);

```
<!-- A5_ENTRY_END retain-failed-1.cjs -->

### Retained retain-failed-2.cjs

Encoding utf8; SHA256 `03a45188bd145a89a913d4c2aba1a2f4c569489f1e19f692117fc81eb8c2b895`.

<!-- A5_ENTRY_BEGIN retain-failed-2.cjs -->
```javascript
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const file=path.join(process.cwd(),'docs/audit/phases/A5_BACKEND_EVIDENCE.md'),out=__dirname;
const names=['run.cjs','sql.mjs','sql-failed-1.mjs','edge.ts','sql-probe-failed-1.txt','sql-probe-corrected.txt','edge-probe.txt','sql-existing.txt','edge-existing.txt','edge-check.txt','inputs.json','retain-failed-1.cjs','retain.cjs'];
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const entries=names.map(name=>{const b=fs.readFileSync(path.join(out,name)),encoding=b[0]===255&&b[1]===254?'utf16le':'utf8',text=b.toString(encoding);assert.equal(hash(Buffer.from(text,encoding)),hash(b));return{name,encoding,sha256:hash(b),text};});
const md=fs.readFileSync(file,'utf8'),marker='<!-- A5_RETAINED_PENDING -->';assert.equal(md.split(marker).length,2);
const appendix=entries.map(e=>{const log=e.name.endsWith('.txt');return '\n### Retained '+e.name+'\n\nEncoding '+e.encoding+'; SHA256 `'+e.sha256+'`.\n\n<!-- A5_ENTRY_BEGIN '+e.name+' -->\n```'+(log?'json':e.name.endsWith('.json')?'json':'javascript')+'\n'+(log?JSON.stringify(e):e.text)+'\n```\n<!-- A5_ENTRY_END '+e.name+' -->\n';}).join('');
fs.writeFileSync(file,md.replace(marker,appendix));
const retained=fs.readFileSync(file,'utf8');for(const e of entries){const start='<!-- A5_ENTRY_BEGIN '+e.name+' -->\n',end='<!-- A5_ENTRY_END '+e.name+' -->';const section=retained.split(start)[1].split(end)[0],body=section.slice(section.indexOf('\n')+1,section.lastIndexOf('\n```'));const text=e.name.endsWith('.txt')?JSON.parse(body).text:body;assert.equal(hash(Buffer.from(text,e.encoding)),e.sha256,e.name);}
console.log('A5_RETENTION PASS: 13 full source/log/manifest entries extracted from repository MD match original SHA256; input hashes='+JSON.parse(entries.find(e=>e.name==='inputs.json').text).length);

```
<!-- A5_ENTRY_END retain-failed-2.cjs -->

### Retained retain-failed-3.cjs

Encoding utf8; SHA256 `15e7da7d961ffd819d338e2968c25c0c13078f7c3430bf19d062fc721f147927`.

<!-- A5_ENTRY_BEGIN retain-failed-3.cjs -->
```javascript
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const file=path.join(process.cwd(),'docs/audit/phases/A5_BACKEND_EVIDENCE.md'),out=__dirname;
const names=['run.cjs','sql.mjs','sql-failed-1.mjs','edge.ts','sql-probe-failed-1.txt','sql-probe-corrected.txt','edge-probe.txt','sql-existing.txt','edge-existing.txt','edge-check.txt','inputs.json','retain-failed-1.cjs','retain-failed-2.cjs','retain.cjs'];
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const entries=names.map(name=>{const b=fs.readFileSync(path.join(out,name)),encoding=b[0]===255&&b[1]===254?'utf16le':'utf8',text=b.toString(encoding);assert.equal(hash(Buffer.from(text,encoding)),hash(b));return{name,encoding,sha256:hash(b),text};});
const current=fs.readFileSync(file,'utf8'),marker='<!-- A5_RETAINED_PENDING -->';
const begin=current.indexOf('\n### Retained run.cjs\n'),end=current.lastIndexOf('\n## 9. Final scope/whitespace verification');
const md=current.includes(marker)?current:current.slice(0,begin)+'\n'+marker+'\n'+current.slice(end);assert.equal(md.split(marker).length,2);if(!current.includes(marker))assert(begin>0&&end>begin);
const appendix=entries.map(e=>{const log=e.name.endsWith('.txt');return '\n### Retained '+e.name+'\n\nEncoding '+e.encoding+'; SHA256 `'+e.sha256+'`.\n\n<!-- A5_ENTRY_BEGIN '+e.name+' -->\n```'+(log?'json':e.name.endsWith('.json')?'json':'javascript')+'\n'+(log?JSON.stringify(e):e.text)+'\n```\n<!-- A5_ENTRY_END '+e.name+' -->\n';}).join('');
fs.writeFileSync(file,md.replace(marker,()=>appendix));
const retained=fs.readFileSync(file,'utf8');for(const e of entries){const start='<!-- A5_ENTRY_BEGIN '+e.name+' -->\n',end='<!-- A5_ENTRY_END '+e.name+' -->';const section=retained.split(start)[1].split(end)[0],body=section.slice(section.indexOf('\n')+1,section.lastIndexOf('\n```'));const text=e.name.endsWith('.txt')?JSON.parse(body).text:body;assert.equal(hash(Buffer.from(text,e.encoding)),e.sha256,e.name);}
console.log('A5_RETENTION PASS: 14 full source/log/manifest entries extracted from repository MD match original SHA256; input hashes='+JSON.parse(entries.find(e=>e.name==='inputs.json').text).length);

```
<!-- A5_ENTRY_END retain-failed-3.cjs -->

### Retained retain.cjs

Encoding utf8; SHA256 `d3befa31d67de2c55544be9591d64cca7eb9dd78f9ad63ba38838eec510d59a6`.

<!-- A5_ENTRY_BEGIN retain.cjs -->
```javascript
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const file=path.join(process.cwd(),'docs/audit/phases/A5_BACKEND_EVIDENCE.md'),out=__dirname;
const names=['run.cjs','sql.mjs','sql-failed-1.mjs','edge.ts','sql-probe-failed-1.txt','sql-probe-corrected.txt','edge-probe.txt','sql-existing.txt','edge-existing.txt','edge-check.txt','inputs.json','retain-failed-1.cjs','retain-failed-2.cjs','retain-failed-3.cjs','retain.cjs'];
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const entries=names.map(name=>{const b=fs.readFileSync(path.join(out,name)),encoding=b[0]===255&&b[1]===254?'utf16le':'utf8',text=b.toString(encoding);assert.equal(hash(Buffer.from(text,encoding)),hash(b));return{name,encoding,sha256:hash(b),text};});
const current=fs.readFileSync(file,'utf8'),marker='<!-- A5_RETAINED_PENDING -->';
const begin=current.indexOf('\n### Retained run.cjs\n'),end=current.lastIndexOf('\n## 9. Final scope/whitespace verification');
if(begin>=0)assert(begin>0&&end>begin);const token='\n'+marker+'\n';
const md=begin<0?current:current.slice(0,begin)+token+current.slice(end);assert.equal(md.split(token).length,2);
const appendix=entries.map(e=>{const log=e.name.endsWith('.txt');return '\n### Retained '+e.name+'\n\nEncoding '+e.encoding+'; SHA256 `'+e.sha256+'`.\n\n<!-- A5_ENTRY_BEGIN '+e.name+' -->\n```'+(log?'json':e.name.endsWith('.json')?'json':'javascript')+'\n'+(log?JSON.stringify(e):e.text)+'\n```\n<!-- A5_ENTRY_END '+e.name+' -->\n';}).join('');
fs.writeFileSync(file,md.replace(token,()=>'\n'+appendix+'\n'));
const retained=fs.readFileSync(file,'utf8');for(const e of entries){const start='<!-- A5_ENTRY_BEGIN '+e.name+' -->\n',end='<!-- A5_ENTRY_END '+e.name+' -->';const section=retained.split(start)[1].split(end)[0],body=section.slice(section.indexOf('\n')+1,section.lastIndexOf('\n```'));const text=e.name.endsWith('.txt')?JSON.parse(body).text:body;assert.equal(hash(Buffer.from(text,e.encoding)),e.sha256,e.name);}
console.log('A5_RETENTION PASS: 15 full source/log/manifest entries extracted from repository MD match original SHA256; input hashes='+JSON.parse(entries.find(e=>e.name==='inputs.json').text).length);

```
<!-- A5_ENTRY_END retain.cjs -->


## 9. Final scope/whitespace verification

Current successful evidence-builder output: `A5_RETENTION PASS: 15 full source/log/manifest entries
extracted from repository MD match original SHA256; input hashes=38`, `A5_RETENTION_EXIT=0`.
Initial serialization drafts capsule.b64/capsule-utf8.b64 remain unused externally; they are not
canonical evidence, contain no additional probe execution and were not deleted. Canonical full logs
and sources above supersede those unused encoding drafts. No commit/push was made by this specialist.

`git status --porcelain=v1` showed exactly the six expected parent docs plus this NEW evidence doc;
`git rev-parse HEAD` remained entry SHA. `git diff --check` exited0 (only LF/CRLF notices on parent
docs). An extra `git diff --no-index --check -- NUL docs/audit/phases/A5_BACKEND_EVIDENCE.md` exited1
with only LF/CRLF notice: no-index reports a new-file difference, not a claimed successful check.
The explicit read-only verifier below additionally checks this untracked document's whitespace.

Final read-only verifier, PowerShell here-string piped to `node` from repo root; it reads ONLY repo
files/Git metadata, never external artifact paths or retained executable content:

```javascript
const fs=require('node:fs'),crypto=require('node:crypto'),cp=require('node:child_process'),assert=require('node:assert/strict');
const p='docs/audit/phases/A5_BACKEND_EVIDENCE.md',md=fs.readFileSync(p,'utf8');
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const entries=[];
const re=/^<!-- A5_ENTRY_BEGIN ([a-z0-9.-]+) -->\r?\n```\w+\r?\n([\s\S]*?)\r?\n```\r?\n<!-- A5_ENTRY_END \1 -->/gm;
for(const m of md.matchAll(re)){const name=m[1],heading=md.slice(md.lastIndexOf('### Retained '+name,m.index),m.index),meta=heading.match(/Encoding (\w+); SHA256 `([a-f0-9]{64})`/);assert(meta,name);const text=name.endsWith('.txt')?JSON.parse(m[2]).text:m[2];assert.equal(hash(Buffer.from(text,meta[1])),meta[2],name);entries.push({name,text});}
assert.equal(entries.length,15);const inputs=JSON.parse(entries.find(e=>e.name==='inputs.json').text);assert.equal(inputs.length,38);for(const e of inputs)assert.equal(hash(fs.readFileSync(e.path)),e.sha256,e.path);
assert(!/[\t ]+$/m.test(md),'trailing whitespace');assert(!md.includes('<!-- A5_RETAINED_PENDING -->\n\n## 9.'),'unfilled appendix');
const git=(...args)=>cp.execFileSync('git',args,{encoding:'utf8'}).trim();assert.equal(git('rev-parse','HEAD'),'1763ab55e8da994bc1d854ad8fd2cd2299678b45');assert.equal(git('diff','--name-only','--','app','supabase','tools','.github','.opencode','AGENTS.md'),'');
const allowed=['docs/audit/SESSION_HANDOFF.md','docs/planning/CHANGELOG_AI.md','docs/planning/SESSION_HANDOFF.md','docs/planning/TASK_BOARD.md','docs/audit/phases/A5_BACKEND_EVIDENCE.md','docs/audit/phases/A5_FLUTTER_EVIDENCE.md','docs/audit/phases/A5_TEST_RELIABILITY.md'];
const status=cp.execFileSync('git',['status','--porcelain=v1'],{encoding:'utf8'}).trimEnd().split('\n');assert.equal(status.length,7);for(const line of status)assert(allowed.includes(line.slice(3).trim()),line);
console.log('A5_BACKEND_ARTIFACT PASS: entries15/inputHashes38/allowedDocs7/noProductChanges/HEADunchanged/whitespaceClean');
```

Executed current-session result, exit0:

```text
A5_BACKEND_ARTIFACT PASS: entries15/inputHashes38/allowedDocs7/noProductChanges/HEADunchanged/whitespaceClean
A5_BACKEND_ARTIFACT_EXIT=0
A5_FINAL_DIFF_EXIT=0
 M docs/audit/SESSION_HANDOFF.md
 M docs/planning/CHANGELOG_AI.md
 M docs/planning/SESSION_HANDOFF.md
 M docs/planning/TASK_BOARD.md
?? docs/audit/phases/A5_BACKEND_EVIDENCE.md
?? docs/audit/phases/A5_FLUTTER_EVIDENCE.md
?? docs/audit/phases/A5_TEST_RELIABILITY.md
1763ab55e8da994bc1d854ad8fd2cd2299678b45
```

Git emitted only notices that LF will be replaced by CRLF when it next touches the four tracked
parent documents; no whitespace diagnostic. These are current commands at entry commit plus the
authorized dirty docs, not claims about a future commit or another session. Parent records shared
A5 acceptance/planning updates and independent QA; this document does not close A5 itself.
