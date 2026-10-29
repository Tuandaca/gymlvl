# Master Findings

**Stage:** A7 PARTIAL / IN PROGRESS; B0 complete and R1-01..03 core locally verified. R1-04/07
actual persistence/isolated-stack verification BLOCKED; R1-05/06 source partial/runtime gates BLOCKED.
No B2+ implementation or migration-ready claim; migration readiness remains NOT READY.
**Baseline:** `main@57e4e73e88f7099ec29a9d075964817f4db5470d`; expected source/platform/docs changes preserved.
**Counts:** 35 findings — P0: 0, P1: 3, P2: 24, P3: 6, P4: 2. Confirmed: 16, High: 18, Medium: 1, Low: 0.
**Status:** 3 `Needs Verification`, 22 `Accepted`, 8 `Fixed`, 2 `False Positive`.

SEC002/CONC001/INTG002 become `Fixed` only for repository/local verification; severity/confidence
unchanged. BUG001/BUG002 remain `Accepted`/High: source corrections plus10 release-source tests
do not satisfy required Gradle merged-manifest/signing/runtime acceptance. Exactly these five
records changed; their entire previous objects, including nested history, are exact in JSON
`historical_pre_a7`. All30 other objects/raw spans, including four committed B0 histories, remain
unchanged. Prior closure metadata and B0 `a7_review` are historical; current `a7_b1_review` supersedes
their stage wording. First per-ID tables are current; expandable pre-B1 text is historical.

Implementer: `flutter-specialist ses_e7c46447fffe6xRQuhbJ2twX94`; independent QA:
`ses_e7c4250a1ffeXk30ceIhMb3Jvk`. SEC002 real RED foreign adoption/overwrite led to31 new tests;
independent31/full157/analyze PASS. CONC001 real RED timeouts/stale B clearing led to independent25
focused PASS, including native_remove_ack. INTG002 implementer76 focused/independent18 PASS includes
rendered VI/EN pending/reload and server7-second duration. Parent final batch, from `app` with
process-local TEMP/TMP on D:, reports `flutter analyze --no-pub` ->No issues found!48.5s;
`dart format --output=none --set-exit-if-changed lib test` ->129 files0 changed;
`flutter test --no-pub --concurrency=2 --reporter expanded` ->+200 All tests passed!; all exit0.
This docs-only writer reruns no runtime suites; parent records final batch diff evidence separately.

D-029 approves rewards-only captured-caller/request receipt semantics, not fabricated Workouts;
the receipt is shallow `Map.unmodifiable`, in memory, not durable/deep-immutable. No actual SQL
commit-count or live-account/RLS/device claim. R1-04/07 require actual independent connections and
barrier/commit-lost-ACK/reject/reload/reorder/delete controls; missing local stack blocks these,
not an excuse to substitute PGlite Promise.all or change models from unproven INTG008/009.

D-030/031/032 approve operator-owned signing and B1 verification prerequisites, not W4/new findings.
Existing JBR21 and SHA-verified Gradle8.13 address prior JVM8 and9.7/AGP8.11.1 mismatch. Actual Gradle
attempts stopped before requested tasks: uncached dependencies, online8GiB heap native OOM203.5s,
then offline1GiB/one-worker app_links Kotlin2.1.20/reflection/annotations cache misses. No merged
manifest, missing/partial-input execution proof, APK signature or key read. **Next:** after local
cache/environment readiness, controlled Gradle manifest and no/partial-input checks; no further
online attempt now. Execution reference: `phases/A7_BATCH_EXECUTION.md`; parent owns synchronization.

### Historical A7 B0 register checkpoint (preserved; superseded for current stage by B1 above)

**Stage:** A7 B0 PARTIAL / IN PROGRESS (2026-10-29); B1 not started; no W2-W5 implementation.
**Baseline:** `main@3d9dbb038a3a7e93ee4b3d4c51b10d8e066dbf75`, source changes uncommitted at review.
**Counts:** 35 findings — P0: 0, P1: 3, P2: 24, P3: 6, P4: 2. Confirmed: 16, High: 18, Medium: 1, Low: 0.
**Status:** 3 `Needs Verification`, 25 `Accepted`, 5 `Fixed`, 2 `False Positive`.

R0-01 safety gate PASS and D-025..028 authorize the bounded B0 corrections. Exactly GOV004/SEC001
(R0-02), SEC003 (R0-03) and SEC004 (R0-04) become `Fixed` **for repository-scoped correction only**;
severity/confidence unchanged. The other31 objects/raw JSON spans remain unchanged. Each changed
object retains its complete exact pre-A7 object, including nested history, in `historical_pre_a7`.
All earlier closure metadata remains historical, not an A7 whole-batch closure or deployment claim.
The first per-ID table is current; expandable pre-A7 records below are historical.

Parent reports independent execution: `node --test tools/agent-tests/permission_policy.test.mjs`
32 passed; `node tools/db-tests/run.mjs`11 SQL units plus ACL10 isolated DBs/365 assertions;
cached-only/deny-net Deno full Edge44 tests and six handler checks; all exit0/diff0. Specialist real
RED/green evidence is retained. This docs-only writer does not rerun runtime suites. Execution
reference: `phases/A7_BATCH_EXECUTION.md`; parent owns stale task-ledger synchronization.

Independent QA `ses_e7c4250a1ffeXk30ceIhMb3Jvk` inspected source and found no material code blocker;
requested inherited owner/superuser fixtures subsequently added and passed. QA `npm.ps1` was
execution-policy BLOCKED; source-filter Git permission denied, not retried. **No independent QA
runtime PASS.** Policy results model permissions, not the live scanner/sandbox; saved approvals are
unknown and reviewer permissions remain narrow. SEC003 migration tested only in disposable PGlite,
not deployed; deployment/inventory NOT RUN and migration readiness NOT READY. SEC004 streaming caps
do not prove DoS protection, hosted memory ceilings or real network cancellation. No new IDs.

**A7 docs-validator initial FAIL retained:** inline Node completed the35-object/history/raw-span/
classification checks, then an extra global literal-HTML balance assertion failed `13 !== 11`,
exit1. Baseline already contains9 literal opening details tags and7 closing tokens (including retained
evidence text); current adds exactly4 matched wrappers. Corrected validator compares the opening/
closing delta against baseline rather than rewriting unrelated historical text. Initial output:
`...\Temp\opencode\a7-b0-register-validation-3d9dbb0.log`; initial `git diff --check` exit0.

### Historical A6/A5 register header (preserved; superseded by A7 current header)

**A6 reconciliation (2026-10-29):** all35 finding objects/classifications/history retained; no
promotion, fix or reclassification. Proposed per-ID owners/tasks/priority and distinct-root
relationships are in `REMEDIATION_PLAN.md` and `phases/A6_RECONCILIATION.md`; prior wave fields are
historical, not implementation authorization. A6 scoped acceptance PASS/CLOSED after independent
material/final QA inspection and phase6 artifact validation; not product correctness or a fix.

**Stage:** A5 CLOSED — scoped testing/reliability audit acceptance PASS; explicit failed/blocked/unexecuted gaps retained.
**Baseline:** `main` @ `1763ab55e8da994bc1d854ad8fd2cd2299678b45` (`1763ab5`), A5 product/audit entry. Documentation writer enters `614ee7cb6f99846b00fd71eec43637cb296268be`.
**Counts:** 35 findings — P0: 0, P1: 3, P2: 24, P3: 6, P4: 2. Confirmed: 16, High: 18, Medium: 1, Low: 0.
**Status:** 3 `Needs Verification`, 29 `Accepted`, 1 `Fixed`, 2 `False Positive`.

All30 prior IDs/fields/history survive;24 untouched objects are JSON-deep-equivalent. Six amended objects retain ENTIRE exact previous findings in JSON `historical_pre_a5`, including nested historical_pre_a4 and A2-A4 review metadata wherever present. Five narrow promotions and five new IDs are not remediation; whole-stage scoped acceptance is assessed in A5_TEST_RELIABILITY section9. Current claims are the first per-ID tables; archived pre-A5 prose/tables and earlier closure objects are historical. Golden/coverage percentages remain gaps, not automatic findings.

Independent review: qa-reviewer ses_e7cb5a850ffeEKOCUhDgig3neH independently read product source/full retained probes and supports these bounded claims; no independent runtime rerun claimed. Extra QA source Git command BLOCKED, not retried or bypassed.

### Historical A4 register header and write verification (entire prior header retained)


**Stage:** A4 CLOSED — scoped business-logic audit acceptance PASS; explicit deferred gaps retained.
**Baseline:** `main` @ `c95cb4873455b39f3ab2b6c0f929b43d87f4d8d3` (`c95cb48`).
**Counts:** 30 findings — P0: 0, P1: 3, P2: 20, P3: 5, P4: 2. Confirmed: 9, High: 20, Medium: 1, Low: 0.
**Status:** 3 `Needs Verification`, 24 `Accepted`, 1 `Fixed`, 2 `False Positive`.

Scales, ID scheme and status vocabulary are defined in `README.md` §§4–7. The machine-readable
mirror is `FINDINGS_REGISTER.json`; the two must always agree.

A4 retains all26 earlier IDs and historical evidence. DATA001 becomes P1/Confirmed/Accepted only
for the synthetic prior-credit plus award-log/completed-false-flag/no-reward-row tuple; production
cohort unknown and ordinary replay controls pass. ARCH001 becomes P2/High/False Positive after
checking exact sole-award wording, not Fixed. Add exactly DATA002 and INTG005-007: three P2/Confirmed/
Accepted SQL mechanisms and one P2/High/Needs Verification timed quest integration contract.

Retained runtime evidence: `phases/A4_SQL_EVIDENCE.md`, groups1-8, exact source/output/hash/command;
probe exit0,15 sequential independent in-memory DBs,108 assertions including fixture/source guards,
zero fetch attempts. Primary independently reran the current108 assertions exit0 as reported by the
orchestrator. No runtime rerun in this documentation-only register write. Independent qa-reviewer
`ses_e7d23c0d4ffe9IA6MkbszmpEvl` read source/evidence and supports the bounded classifications and
ARCH001 disproof. Real two-connection scheduling and actual Dart quest journey remain NOT RUN.
No product, governance, schema, permanent-test or permission change occurred.

### A4 register-write verification (documentation only)

Executed an inline PowerShell here-string piped to `node --input-type=module`, comparing both
registers with `git show HEAD:<path>` and parsing current JSON. First validator attempt **FAIL**,
exit1: its extra assertion required byte-identical titles for every old MD/JSON record. The
pre-existing GOV001 MD title contains `` `docs/audit/**` `` while JSON says `docs/audit`; output was
`AssertionError [ERR_ASSERTION]: Expected values to be strictly equal`. No legacy title or product
was repaired. Corrected validator preserves old MD titles, compares current/new titles where changed,
and still checks all30 current classifications, exact history and all required counts/fields.
Corrected run **PASS**, exit0:

```text
A4_REGISTER_CHECK json_parse=PASS json=30 md=30 old_ids_preserved=26 old_classifications_unchanged=24 historical_objects_exact=2 a3_reviews_preserved=2 new_ids=4 new_fields_each=22 md_json_classes_match=30 historical_closures_preserved=true errors=0
A4_COUNTS {"total":30,"by_severity":{"P0":0,"P1":3,"P2":20,"P3":5,"P4":2},"by_confidence":{"Confirmed":9,"High":20,"Medium":1,"Low":0},"by_status":{"Open":0,"Needs Verification":3,"Accepted":24,"Fixed":1,"Deferred":0,"False Positive":2}}
VALIDATOR_EXIT=0
DIFF_CHECK_EXIT=0
```

`git diff --check` exited0 with no whitespace errors, only LF/CRLF warnings. Git status shows the
six original authorized dirty documents plus only these two delegated register paths; HEAD remains
`c95cb4873455b39f3ab2b6c0f929b43d87f4d8d3`. This writer edits no other path. Whole-stage acceptance,
phase-owned A5 reorder/lost-ack transport deferrals and planning/handoff updates remain with the
orchestrator. No new ID is assigned to those unexecuted transport candidates.

### Historical A3/A2/A1 metadata — not current classification or closure claims

A3 entry baseline was `main` @ `f877e40987423f3804fe0d2887c44d19f3423aff`; A3 closed with26 findings,
P1:3/P2:16/P3:5/P4:2, Confirmed5/High19/Medium2 and Accepted21/Needs Verification3/Fixed1/False
Positive1. The A3/A2 closure objects in JSON and the following dated narrative retain history, not
A4 closure claims. Current classifications are the per-ID current records and totals above.

A3 adds SEC003 (Confirmed only for a synthetic pre-existing PUBLIC grant) and SEC004 (High/
Needs Verification for authenticated Edge buffering order). No production vulnerability inferred;
the named authenticated-column grant survival hypothesis was disproved and retained as contrary
evidence. All 24 earlier IDs/classifications remain. DATA001/ARCH001/SEC002 A3 addenda below do not
extend reward semantics or local-cache evidence beyond the checks actually executed.

A2 recovery originally added `FND-SEC-002` without confidence promotion. Final reconciliation adds
`FND-BUG-004…007` and `FND-INTG-002…004`, and accepts narrowly reproduced controller mechanisms in
`FND-CONC-001` / `FND-SEC-002`. Their original classifications are retained as historical records.
`FND-DATA-001` remains P1 / Medium / `Needs Verification`. Remaining leads and deferred assertions
belong to the phase record, not register totals. A2 is now CLOSED under the original seven scoped
audit criteria; this is not remediation or exhaustive runtime acceptance. No finding classification
changes in closure. Lead10 remains an unverified investigation deferred A5 by explicit user instruction:
owner flutter-specialist, independent qa-reviewer; synthetic failed-signin -> recovery must not show
password-update failure before submission, with successful/rejected submission controls and retained
command/output. See A2_FLUTTER sections8.2.10/9. It is not a new Confirmed finding.

Findings inherited from `docs/agent-system/S3_VALIDATION_REPORT.md` §10 keep their origin and are
explicitly **unverified** until a stage re-checks them.

A1 added ten findings (`FND-BUG-001…003`, `FND-TEST-001`, `FND-INTG-001`, `FND-ARCH-002`,
`FND-ARCH-003`, `FND-GOV-004`, `FND-SEC-001`, `FND-GOV-005`) and extended `FND-GOV-002` with the
stale-claim inventory it depends on. All ten are `High`, not `Confirmed`: each is proven by a static
read, and the runtime step that would promote it is recorded as `NOT RUN` with its reason in
`phases/A1_ARCHITECTURE.md` §12.1.

---


## FND-CONC-001 — Discard queue cycle and post-backup-await identity race disrupt active workout state

| Field | Value |
|---|---|
| ID | FND-CONC-001 |
| Severity | **P2** |
| Confidence | **Confirmed** |
| Status | `Fixed` |
| Paths | app/lib/features/workout/presentation/controllers/active_workout_controller.dart; app/test/workout_async_identity_test.dart; app/test/workout_controller_test.dart |
| Actual behavior | Fixed in repository/local scope: active discard completes without nested queue wait; stale completion/cancel cannot erase a replacement identity after acknowledged native removal. Two distinct mechanisms and their controls remain covered. |
| Proposed remediation | Implemented R1-02 private cancel/context revalidation with permanent async/native-removal controls; preserve both mechanisms and same-context behavior. Actual backend persistence remains separately BLOCKED under R1-04/07. |
| Owner / task | flutter-specialist ses_e7c46447fffe6xRQuhbJ2twX94; R1-02; independent QA ses_e7c4250a1ffeXk30ceIhMb3Jvk |

**A7 B1 evidence/limits:** Real RED timeouts and stale-B clearing corrected; independent25 focused
tests pass including native_remove_ack. Two distinct mechanisms remain explicit. Parent final200
Flutter tests/analyze/format pass; no B database mutation, uncaught crash or real-account/device
claim. Full previous object and nested A5 history in JSON `historical_pre_a7`; no runtime rerun here.

<details>
<summary>Historical pre-A7 B1 record — superseded wording/status; nested history remains historical</summary>

| Field | Value |
|---|---|
| ID | FND-CONC-001 |
| Title | Discard queue cycle and post-backup-await identity race disrupt active workout state |
| Category | CONC |
| Component | Active workout controller (client) |
| Paths | app/lib/features/workout/presentation/controllers/active_workout_controller.dart |
| Lines | controller:125-145,207-215,659-682,691-700; workout_screen.dart:295-322; docs/audit/phases/A5_FLUTTER_EVIDENCE.md:G2; retained output669-676 |
| Origin | S3/A2 queue-cycle history retained; A5 actual-controller post-storage-await schedules and independent QA |
| Root cause | Two distinct mechanisms share this ID: discardLocalBackup re-enqueues cancel behind its own serialized action; completion/cancel check generation before backup removal but do not re-check identity/generation after its await before clearing state. |
| Evidence | A2 retained queue-cycle probe (+7, exit0 at7eb40f1) observes active discard pending300ms with direct/no-active controls; full previous finding retained in historical_pre_a5. A5 Flutter G2, product1763ab5, retained18-test run exit0: same-identity completion succeeds; reset-only returns null/no error and remains empty because null-state failure is caught; if B starts while A backup removal waits, A completion returns A result and clears B controller state, and A cancel also clears B. No accepted queue-cycle or SEC002 snapshot-adoption repro was repeated. qa-reviewer ses_e7cb5a850ffeEKOCUhDgig3neH independently read product source/full retained probes and supports these bounded claims; no independent runtime rerun claimed. Extra QA source Git command BLOCKED, not retried or bypassed. |
| Expected behavior | Discard settles; an operation from identity A must not clear identity B workout state after a storage await. |
| Actual behavior | Original bounded queue-cycle stall remains accepted. New synthetic completion and cancel schedules erase B controller state after A backup removal resolves; reset-only null-state failure is caught, not an uncaught crash. |
| Impact | P2 client recovery/state-continuity defect under the reproduced schedules. No uncaught process crash, B database mutation, real-account disclosure, irreversible DB loss or infinitely measured timeout is established. |
| Severity | **P2** |
| Confidence | **Confirmed** |
| Status | `Accepted` |
| Proposed remediation | Owner flutter-specialist with qa-reviewer: after approval remove nested public re-enqueue and revalidate captured workout/identity/generation after storage awaits before state mutation; preserve same-identity, direct-cancel and no-active controls. |
| Regression risk | Discard queue ordering, completion/cancel, local backup removal, signout/reset/new-user start and restored workout state. |
| Related tests | app/test/workout_controller_test.dart; docs/audit/phases/A2_PROBES.md; docs/audit/phases/A5_FLUTTER_EVIDENCE.md G2 |
| Missing tests | After fix approval: active discard settles with one repository cancel and valid direct/no-active controls.; After fix approval: gate backup removal for completion and cancel, reset A or start B before releasing; B state must survive, reset-only stays empty with no uncaught async error. |
| Depends on | Client-only synthetic schedule; no server/RLS/disclosure inference. Separate from SEC002 unchecked snapshot ownership. |
| Wave | W1 |
| Verification method | Retained A2 queue-cycle evidence plus A5 actual notifier/Auth-rebuild and SharedPreferences removal barrier, G2 source/output in docs/audit/phases/A5_FLUTTER_EVIDENCE.md. Independent QA supports distinct mechanisms; no runtime rerun here. After authorized fix invert B-erased observations while retaining controls. |

**A5 review:** product baseline `1763ab55e8da994bc1d854ad8fd2cd2299678b45`; UI evidence/documentation entry `614ee7cb6f99846b00fd71eec43637cb296268be`; qa-reviewer ses_e7cb5a850ffeEKOCUhDgig3neH independently read product source/full retained probes and supports these bounded claims; no independent runtime rerun claimed. Extra QA source Git command BLOCKED, not retried or bypassed. No runtime rerun in this documentation turn.

<details>
<summary>Historical pre-A5 record — superseded current wording/classification, not an additional A5 claim</summary>

#### Archived FND-CONC-001 — Re-entrant discard queue cycle stalls active workout recovery

| Field | Value |
|---|---|
| Category | `CONC` |
| Component | Active workout controller (client) |
| Path | `app/lib/features/workout/presentation/controllers/active_workout_controller.dart` |
| Lines | 125-145, 207-215, 691-700; UI entry `workout_screen.dart:295-322` |
| Origin | S3 L4 — `qa-reviewer`/`flutter-specialist` delegation TEST C (carried, **not re-verified** in A0) |
| Severity | **P2** |
| Confidence | **Confirmed** |
| Status | `Accepted` |
| Wave | W1 |

**Current scope (A2 final reconciliation, 2026-10-28).** This stable ID covers only the nested
discard/cancel queue cycle. The outer `_enqueue` awaits a cancellation queued behind itself. A retained
audit-only probe uses promptly completing fake cancellation; direct cancel and inactive discard finish,
but active discard times out at 300 ms without reaching another repository cancellation. This bounded
observation plus the source cycle supports the mechanism, not independently measured infinite duration.
Expected: discard settles; actual: active discard remains pending and retains active state. P2 reflects
degraded recovery; irreversible workout loss or server corruption was not demonstrated.

**Retained evidence, not rerun in this documentation checkpoint.** Last A2 continuation, baseline
`7eb40f1`, working directory
`C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a2-minimal-20261028\app`:
`flutter test --no-pub --reporter expanded test/a2_retained_probe_test.dart` ->
`+7: All tests passed!`, exit 0; defect-observing output:
`DISCARD direct_cancel=1 inactive_discard=completed active_timeout=true cancel_calls=1 active=true`.
Exact retained harness and limitations: `phases/A2_PROBES.md:50-189,229-266`. Green means reproduction,
not a fix. No product test or application code changed.

**Current remediation / verification.** Avoid re-enqueuing the public cancellation method inside the
serialized action; preserve cancellation order and direct/no-active behavior. After fix authorization,
invert the retained assertion: active discard must settle and reach repository cancellation once.
Regression scope: discard, cancel, restore and session resume; related test:
`app/test/workout_controller_test.dart`. No backend dependency is needed for this client reproduction.

**Separate investigation — DEFERRED A5, owner `flutter-specialist`, no new ID.** Gate local-backup
removal between 659 and 664, reset auth identity, and assert completion neither dereferences cleared
state nor modifies the new identity's state. This post-await race is **NOT RUN**, not part of the
Confirmed mechanism; catch at 678-682 means an uncaught crash is not established.

### Historical S3 / A2 recovery record (superseded classification: P1 / Medium / Needs Verification)

**Suspected mechanism.** `discardLocalBackup` (L207-215) awaits `cancelWorkout()` from inside
`_enqueue`. `cancelWorkout` (L691) itself enqueues onto the same serialized `_pending` future, so the
outer operation awaits a future that cannot complete until the outer operation returns. Separately,
L659-670 dereferences `state.workout!` after an `await` without re-checking that the workout still
exists.

**Expected / actual.** Expected: the discard-backup path finishes and the banner clears. Actual
(hypothesised): the future never resolves, `isLoading` stays true, and the UI hangs; the dereference
can throw if the workout was cancelled or cleared during the await.

**Impact.** A user who discards a local backup while the backend is unreachable can be left with a
hanging screen and an unusable in-progress workout. No server data is corrupted, because the server
remains authoritative.

**Why not `Confirmed`.** No reproduction was attempted: S3 was read-only validation and A0 is
inventory. A2 must reproduce it with a fake repository whose `cancel` never completes, and confirm
the deadlock with a timeout assertion.

**Proposed remediation.** Call the internal cancel operation from `discardLocalBackup` instead of the
public enqueuing method, and capture `state.workout` into a local before the `await`, re-checking it
afterwards.

**Regression risk.** Workout discard, cancel, backup restore, and session-resume paths.

**Tests.** `app/test/workout_controller_test.dart` (260 lines) exercises the controller but no case
covers "discard while a request is pending". Missing coverage is the reason the defect survived.

**Dependencies.** None. A4 re-examines the same file from the business-logic angle; sequence A2 first.

**A2 recovery addendum (history above retained).** Independent QA inspection traced the cycle at
125-145, 207-215, 691-700 and the reachable UI at `workout_screen.dart:295-322`. The repository cancel
need not be slow: it is never reached in the cycle. Prior interrupted A2 output was
`discardResolved=false cancelCalls=0 isLoading=true`, followed by
`completionResolved=false finishCalls=0 isCompleting=true`; no-active control resolved. That temporary
test was deleted before recovery, so these are **carried observations, not a current runtime PASS**.
Keep P1 / Medium / `Needs Verification`; QA proposed P2, while the orchestrator retains the existing
P1 pending reproduction because an active session becomes unusable and the backup is cleared first.
The separate post-await race at 659-664 remains unverified; the catch handles a thrown null assertion,
so an uncaught process crash has not been established. Some interleavings set `isCompleting` early
enough for line 126 to skip the inner enqueue; do not claim every overlap deadlocks.

**Updated verification method.** Retain an audit-only probe outside permanent application tests,
import the real controller, use promptly completing fake cancellation, observe timeout **and** zero
cancel calls, and include direct-cancel/no-active controls. A fake cancel that itself never completes
does not isolate the enqueue bug. Separately change identity while local-backup removal is awaiting
to test the post-await race. See `phases/A2_FLUTTER.md`.

---


</details>

---

</details>

## FND-DATA-001 — Conditional prior-award legacy tuple can receive another workout credit

| Field | Value |
|---|---|
| Category | `DATA` |
| Component | `public.complete_workout` |
| Path | `supabase/migrations/20261026000200_authoritative_progression.sql` |
| Lines | 216 (function), 223-230 (guards), 255 (cap), 264-278 (writes) |
| Origin | S3 L5 — `supabase-specialist` delegation TEST D (carried, **not re-verified** in A0) |
| Severity | **P1** |
| Confidence | **Confirmed** |
| Status | `Accepted` |
| Wave | W1 |

**Current A4 scope.** P1/Confirmed/Accepted only for a synthetic completed false-flag workout with
reliable prior-award evidence: total_xp10 **and one existing workout award log10**, no
`workout_rewards` row. `phases/A4_SQL_EVIDENCE.md` groups1-2 executes the current RPC: earned10
again, total20/logs2/rewards1; identical replay adds no third credit. Ordinary initial/replay,
legitimate completed-unrewarded recovery and true-flag prior-credit controls pass. Source:
`20261026000200_authoritative_progression.sql:223-230,264-281`; baseline:361,367-374. Guard checks
do not classify reliable prior-award provenance before accepting the recovery branch.

**Expected / actual / impact.** At most one award per workout. Actual second global credit/log in
that explicit tuple is reproduced; P1 conditional progression-integrity impact can affect totals
and derived level. No production cohort, ordinary-retry failure, historical class/quest duplication
or independently scheduled concurrency is established. The older broader impact rationale below
is historical, not additional confirmed scope.

**Evidence and review.** Full bounded probe exit0/108 assertions across8 groups; primary reports
independent current108-assertion rerun exit0. Independent QA
`ses_e7d23c0d4ffe9IA6MkbszmpEvl` read source/evidence and supports this conditional promotion.
Former P1/Medium/Needs Verification and A2/A3 evidence are preserved below and in JSON
`historical_pre_a4`/`a3_review`. No runtime rerun in this documentation-write turn.

**Current remediation proposal.** Separately approve an additive migration/classification/backfill
and rollback plan that distinguishes reliable prior-award provenance from legitimate completed-
unrewarded recovery, verifies counts and handles ambiguous history before guard changes. The old
true-flag-only backfill recommendation below does not classify the reproduced false-flag tuple.
Neither blanket rejection of completed false-flag rows nor a nonzero user total alone is safe
evidence of a prior workout award. Preserve original award provenance and replay behavior.

**Regression / remaining verification.** Incorrect classification can deny legitimate recovery or
award ambiguous history twice. Related tests: `supabase/tests/progression_regression.sql` and A4
evidence groups1-2. A5 owner supabase-specialist with independent qa-reviewer: retain all controls;
after separately authorized fix assert proven prior awards receive no new credit/log and genuinely
unrewarded recovery receives exactly one. True two-connection retries/different workouts and any
deployed provenance inventory remain NOT RUN; the latter needs separate explicit authorization.
Client acknowledgement/hydration remains INTG002, not this mechanism.

### Historical pre-A4 record — P1 / Medium / Needs Verification (superseded)

**Suspected mechanism.** Two independent idempotency guards exist: the `workout_rewards` primary key
on `workout_id` (guarded at L226-227) and the `workouts.is_xp_calculated` flag (L229). L230 still
accepts a workout whose `status = 'completed'` while `is_xp_calculated = false`. A legacy row that was
already awarded before the flag existed, and that has no `workout_rewards` row, satisfies both guards
and is awarded a second time.

**Expected / actual.** Expected: at most one award per workout id, ever. Actual: undetermined for
pre-existing rows, because the outcome depends on production data this audit cannot see.

**Impact.** Inflated XP, level, streak and possibly a duplicate quest reward for a specific cohort of
legacy rows. Bounded by the 1,000 XP cap (L255) but not prevented by it.

**Why not `Confirmed`.** The condition depends on data state. The mechanism is readable, the
population is not measurable without the live database.

**Proposed remediation.** Additive migration: backfill `workout_rewards` for every completed workout
that has `is_xp_calculated = true`, then tighten L230 so completion without a rewards row is only
accepted when the workout never produced progression at all. Requires an approved migration under
`AGENTS.md` §4 and a live-data check first.

**Regression risk.** Replaying completion for legitimate legacy rows would start returning an error
if the backfill is incomplete. The backfill must be verified by count before the guard tightens.

**Tests.** `supabase/tests/progression_regression.sql` covers progression arithmetic; whether it
covers the legacy branch is **unverified** — A5 confirms.

**Dependencies.** Needs a live database or a fixture that reproduces the legacy row shape; therefore
it also depends on the harness limitation recorded as G-05.

**A2 client-only addendum.** `active_workout_screen.dart:82` calls controller `completeWorkout`;
controller:622-631 memoizes one completion future; 628-650 waits for pending edits and checks active
state; 655-658 calls `finishWorkout`. `supabase_workout_repository.dart:70-76` sends
`complete_workout(p_workout_id,p_notes)`, then separately fetches detail. Its `calculateXP` wrapper
(84-91) also invokes the award RPC but has no current production caller. No client retry loop or
independent request UUID was observed; explicit retry reuses workout ID. Recovery-session
`flutter test --no-pub --reporter expanded` reports `+126: All tests passed!`, including existing
concurrent-completion coverage. None of this confirms server-side XP duplication or transactional
idempotency. P1 / Medium / `Needs Verification` unchanged; A3/A4 own legacy-row and reward checks.

---

## FND-ARCH-001 — The stated XP write invariant is narrower than the implementation

| Field | Value |
|---|---|
| Category | `ARCH` |
| Component | Architecture contract vs. `20261026000200_authoritative_progression.sql` |
| Paths | `docs/planning/ARCHITECTURE.md` §4, §7; `AGENTS.md` §4, §9; migration L142-155, L199-212, L302-303 |
| Origin | S3 L6 — `supabase-specialist` delegation TEST D (carried, **not re-verified** in A0) |
| Severity | **P2** |
| Confidence | **High** |
| Status | `False Positive` |
| Wave | W1 |

**Current A4 disposition — P2/High/False Positive, not Fixed.** The old finding conflated sole
authoritative **award** ownership with exclusive ownership of every initialization/maintenance
write. Exact source: `AGENTS.md:193-194` says "only authoritative award path";
`docs/planning/ARCHITECTURE.md:255` says "only award path";
`docs/planning/PROJECT_CONTEXT.md:95-96,169` describes the authoritative completion/reward path and
transaction that owns all awards. The historical allegation that these passages forbid every
progression write is unsupported.

`initialize_user` initializes unonboarded state (progression:137-157); `sync_daily_data` maintains
daily state (192-214); `switch_class` recomputes history without granting another completed-workout
award (285-305). Expected and observed responsibilities are compatible with the cited contract.
Provider invocation of server refresh is not a client-owned award. Independent qa-reviewer
`ses_e7d23c0d4ffe9IA6MkbszmpEvl` read source/evidence and independently challenged the old claim.
This is static semantic disproof, not a runtime PASS or certification of unknown deployed functions.

**Current remediation / impact.** None under this ID; no current wording defect established. Do not
rewrite governance/code to repair the unsupported rationale and do not declare Fixed. Preserve the
historical rationale/addenda below and JSON `historical_pre_a4`/`a3_review`. No runtime regression
from reclassification. DATA002 separately records actual class-history loss; DATA001 separately
records conditional duplicate credit. Neither establishes this every-write allegation.

### Historical pre-A4 rationale — P2 / High / Accepted (rejected by current review)

**Mechanism.** `AGENTS.md` §4 and §9 and `ARCHITECTURE.md` state that `complete_workout` is the only
path that writes XP. Reading the migration shows three further writers of progression state:
`initialize_user` (L142, L154-155) seeds `total_xp = 0`, `level = 1` and the streak row;
`sync_daily_data` (L199-212) resets `current_streak` and expires or creates quests; `switch_class`
(L302-303) writes `user_classes.current_xp`, `level`, `is_graduated` from history.

**Why this is a defect and not a nitpick.** The invariant is the one a reviewer will use to accept or
reject a future change. An imprecise invariant lets a real violation pass review, and a migration
built on the wrong assumption can silently create a second award path.

**Expected / actual.** Expected: one sentence that is true of the code. Actual: a sentence that is
false for three functions.

**Proposed remediation.** Restate as: *"`complete_workout` is the only path that **grants** XP for a
completed workout. `initialize_user`, `sync_daily_data` and `switch_class` **initialise or recompute
derived state** and never grant an award."* Update `AGENTS.md` §4/§9, `ARCHITECTURE.md` §4 and §7, and
`PROJECT_CONTEXT.md` where the same claim appears. Documentation change only, requiring approval
because it edits the operating contract.

**Regression risk.** None at runtime. Risk is editorial: other documents quote the old wording.

**Tests.** Not applicable — the guard is review discipline.

**Dependencies.** A4 must confirm no fourth writer exists before the wording is finalized.

**A2 final-reconciliation client evidence (inspection only).**
`app/lib/features/quests/presentation/providers/quest_providers.dart:11-24` invokes `sync_daily_data`
from provider build after checking authenticated identity. This extends the existing contract finding;
an intentional idempotent refresh RPC is not itself client-owned progression or a new award path.
Server writer semantics remain A4 verification.

---

## FND-GOV-001 — No agent can write `docs/audit/**`, so the audit cannot run under its own orchestrator

| Field | Value |
|---|---|
| Category | `GOV` |
| Component | Agent permission configuration |
| Path | `.opencode/agents/*.md` (7 files) |
| Evidence | Every agent's `edit` rule set, read at A0 |
| Severity | **P2** |
| Confidence | **Confirmed** |
| Status | `Fixed` |
| Wave | W0 (prerequisite) |

**Observation.** The orchestrator may edit only `docs/planning/*` and `docs/agent-system/*`
(`gymlvl-orchestrator.md` L7-14). `flutter-specialist` writes `app/**`, `supabase-specialist` writes
`supabase/**`, `exercise-catalog` writes `supabase/seed/**` and `docs/catalog/**`, `ui-ux-specialist`
writes presentation/theme/l10n, and `qa-reviewer` and `context-keeper` write nothing. **No agent has
an `edit` allow rule covering `docs/audit/**`.**

**Effect.** This stage (A0) could create `docs/audit/` only because the active agent is the built-in
build agent, which is not the agent the mission designates. Under the orchestrator profile, every A0
artifact write would be denied. That makes the program's own operating model unexecutable, which is
the definition of a real governance defect rather than a theoretical one.

**Why this is not worked around.** `AGENTS.md` §3 forbids widening permissions to make a check pass,
and the mission forbids expanding agent permissions. The correct move is to record the gap and
propose the configuration change for approval.

**Proposed remediation (approved and applied in A0.1).** Add to `gymlvl-orchestrator.md`:

```yaml
  - action: edit
    resource: "docs/audit/*"
    effect: allow
```

Applied on 2026-10-28 with a comment marking the intent. The optional read-only shell allowance for
`qa-reviewer` was **not** added: it could not be justified by a failing check, and widening a read-only
reviewer's shell surface to verify a documentation permission would violate the minimum-change rule.

**Regression risk.** The orchestrator gains write access to one documentation directory. It cannot
reach code, schema, or configuration. No functional risk.

**Tests.** Verification is a re-run of the A0 artifact writes under the orchestrator profile.

**Resolution (A0.1, 2026-10-28).** Configuration-level fix verified: edit rules are `*` → deny first,
then `docs/planning/*`, `docs/agent-system/*`, `docs/audit/*`; shell (15 rules), subagent (7),
webfetch, websearch and `external_directory` are unchanged; `subagent(gymlvl-orchestrator)` is still
rejected, proving `mode: primary`; the server emitted `agent.updated` at
`2026-10-28T07:06:41.988Z`, one second after the write; `qa-reviewer` independently confirmed the
allowlist shape read-only.

**End-to-end verification — `PASS` (2026-10-28).** Exercising a write as the orchestrator required a
session whose selected agent is `gymlvl-orchestrator`, since `default_agent` is a session-creation
default rather than a live switch (D-023). That was done twice with
`opencode-cli.exe run --agent gymlvl-orchestrator`. The decisive probe used a path the old policy
denied — `app/.perm-probe-2.md` — and the assertion was made from a **different** session:
`Test-Path` → `True`, `Get-Content` → `probe`. The same session also ran `node --version`, previously
denied. D-024 subsequently replaced the narrow `docs/audit/*` rule with full development access plus
approval gates, so the specific allowlist this finding described no longer exists. See
`docs/agent-system/ACCESS_POLICY.md` §§3–5.

**Dependencies.** Needs to land before A1 if A1 is to run under the orchestrator. A1 can still run
under the build agent with the gap recorded.

---

## FND-GOV-002 — The canonical project-memory document is stale on its own baseline

| Field | Value |
|---|---|
| Category | `GOV` |
| Component | Project memory document |
| Path | `docs/planning/PROJECT_CONTEXT.md`, `AGENTS.md`, `docs/planning/DECISIONS.md`, `docs/planning/MASTER_PLAN.md`, `docs/planning/ARCHITECTURE.md`, `docs/ARCHITECTURE.md`, `docs/planning/TASK_BOARD.md`, `docs/planning/SESSION_HANDOFF.md`, `docs/agent-system/AGENT_SKILL_MATRIX.md`, `docs/agent-system/SKILL_SELECTION.md` |
| Lines | `PROJECT_CONTEXT.md` 4-6 (header), 28-40 (`§2 Repository and current baseline`), 170 (glossary); `AGENTS.md` 6-9 (baseline line); `DECISIONS.md` 5, 22-37; `MASTER_PLAN.md` 5; `docs/planning/ARCHITECTURE.md` 38-57; `docs/ARCHITECTURE.md` 43; `TASK_BOARD.md` 4, 89-90; `docs/planning/SESSION_HANDOFF.md` 8, 25-26; `AGENT_SKILL_MATRIX.md` 5; `SKILL_SELECTION.md` 5 |
| Evidence | Measured at A0: `git rev-parse HEAD` and `git ls-files`; re-confirmed by `context-keeper` at A0 close |
| Severity | **P3** |
| Confidence | **Confirmed** |
| Status | `Accepted` |
| Wave | W4 |

**Observation.** `PROJECT_CONTEXT.md` §2 is titled "Repository and current baseline" and states, as
current fact:

- `Consolidation checkpoint 17ca562` as the baseline, with `Last verified: 2026-10-28`.
- `Tracked files at HEAD | 511`.
- `Remote branch | origin/main — pushed and verified at the checkpoint`.
- No mention of `b4063c6`, `59450c0`, or `9c8e142`.

**Measured now.** `git rev-parse --short HEAD` → `9c8e142`; `git rev-list --count 17ca562..HEAD` → `3`;
`git ls-files` → **538** tracked files.

**Impact.** A resuming session that trusts §2 works from a baseline three commits behind and a file
count that is 27 short. This already produced friction: the same class of staleness in `AGENTS.md` was
found and fixed during S3 (`context-keeper`, delegation TEST B). At A0 close, `context-keeper` noted the
same class again in `AGENTS.md` lines 6-9, which still says "current `main` HEAD is `b4063c6`" — the
line is self-mitigating ("confirm with `git rev-parse main`"), but it demonstrates that any fixed SHA
in prose goes stale within one session. No runtime effect; the cost is mis-sequenced work and wasted
re-derivation.

**Second instance (A0.1).** `DECISIONS.md`'s summary table stops at **D-014** while sections
**D-015–D-021** exist below it. A reader who trusts the summary will believe the Wave 1 skill policy,
the read-only agent rule and D-021 do not exist. Found while adding D-022/D-023 in A0.1; deliberately
**not** backfilled, because repairing the table is W4 work, not A0.1 work.

**Third instance (A1, 2026-10-28) — inventory complete.** `phases/A1_ARCHITECTURE.md` §10 is the
stale-claim inventory this finding's remediation depends on. Measured at `e8c7c8e`: HEAD is seven
commits past `17ca562` (not three), `git ls-files | Measure-Object` → **548** tracked files (not 511,
not the 538 measured at A0), and 15 stale claims were located across `AGENTS.md`,
`PROJECT_CONTEXT.md`, `DECISIONS.md`, `MASTER_PLAN.md`, `docs/ARCHITECTURE.md`,
`docs/planning/ARCHITECTURE.md`, `TASK_BOARD.md`, `docs/planning/SESSION_HANDOFF.md` and two
`docs/agent-system/` reference documents. Two further instances were found that are *not* staleness:
`docs/planning/SESSION_HANDOFF.md:26` asserts "force-push stays gated", which the A1 gate probes
disprove (`FND-GOV-004`), and `docs/ARCHITECTURE.md:43` lists two of the three current migrations.
Dated evidence blocks (`PROJECT_CONTEXT.md:66-79`, `docs/planning/ARCHITECTURE.md:4`) and stage
records (`docs/agent-system/S2_*`, `WAVE1_*`, `SOURCE_AUDIT`, `S3_VALIDATION_REPORT`) were checked and
classified as **not** stale, so the W4 pass will not rewrite history that is correctly dated.

**Why P3 and not P4.** It is documentation, but it is the document of record for "what is true now".
A wrong SHA in the document that defines source precedence is an operational defect, not cosmetics.
It is not P2 because no invariant or contract is misstated — compare `FND-ARCH-001`.

**Proposed remediation.** Make the baseline block self-updating in form: name the *rule*
("`main` HEAD is authoritative; confirm with `git rev-parse main`") and the last observed SHA with its
date, rather than presenting a fixed SHA as current. Correct the tracked-file count or remove it, since
it changes on every commit. The inventory is complete (`phases/A1_ARCHITECTURE.md` §10), so the fix is a
single pass over the 15 rows it lists.

**Regression risk.** None. Documentation only.

**Tests.** Not applicable. A durable guard would be a check that fails when the recorded SHA differs
from `git rev-parse HEAD`, which is a possible W4 item but not required.

**Dependencies.** None outstanding: the A1 inventory is complete; W4 applies the fix.

---

## FND-GOV-003 — Shell permission matching inside a chained command is undocumented

| Field | Value |
|---|---|
| Category | `GOV` |
| Component | Permission model, `.opencode/opencode.jsonc` + agent rules |
| Severity | **P3** |
| Confidence | **High** |
| Status | `False Positive` |
| Wave | — |

**Question.** The orchestrator allows the shell prefix `cd *` (`gymlvl-orchestrator.md` L19-20). If
matching were a naive glob against the whole command string, `cd <dir>; <anything>` would be allowed,
and the global Git floor might be bypassable the same way.

**Evidence against the risk (observed at A0, S3 checkpoint).** A command of the form
`cd "D:\Projects\gymlvl"; git push origin main …` was **denied** with `permission.rejected` by the
global rule `git push *`. The deny fired on a sub-command that was not at the start of the string, so
matching is evidently not a naive whole-string prefix.

**Evidence for keeping the question open.** How the matcher splits or scans a command is not
documented in this repository, and `cd *` remains an unbounded allow if any code path evaluates a
single segment at a time in a different order. This is a question about the harness, not about
GymLvl code.

**Verification method.** In a session that is genuinely running as `gymlvl-orchestrator`, run
`cd .; <a harmless command outside the allowlist>` and record whether it is allowed. Two outcomes:
allowed → escalate to P1 and treat every `*` allow as suspect; denied → close as `False Positive`
with the trial attached.

**Impact.** Potentially undermines the D-019 "permissions, not prose" posture for one agent. Not
known to be exploitable.

**Remediation.** Depending on the outcome: replace `cd *` with explicit per-command allows, or
document the matcher's semantics in `docs/agent-system/`.

**Resolution (A0.1, 2026-10-28) — `False Positive`.** The authoritative V2 documentation resolves the
question without needing an orchestrator session. The permissions guide states that a `shell` resource
is a *"scanner-produced command string"* and that *"compound commands may produce **several**"*
resources, with the last matching rule winning per resource. A command of the form
`cd X; <command>` therefore yields at least two resources: the `cd *` allow covers the first, and any
later rule — including the global `git push *` deny — still applies to the second. That is exactly the
observed S3 behaviour, so `cd *` cannot be used to smuggle a denied command. No repository change is
required; the matcher's semantics are documented upstream. Retained here with the disproof attached,
per `README.md` §7.

**Post-D-024 note (2026-10-28).** The `cd *` allow examined above no longer exists: the orchestrator
now inherits the global rule set and carries no shell allowlist of its own. The disproof still stands;
only the rule path recorded in this finding is historical.

---

## FND-BUG-001 — Android release INTERNET source correction awaits merged-manifest verification

| Field | Value |
|---|---|
| ID | FND-BUG-001 |
| Title | Android release INTERNET source correction awaits merged-manifest verification |
| Severity | **P1** |
| Confidence | **High** |
| Status | `Accepted` |
| Paths | app/android/app/src/main/AndroidManifest.xml; app/android/gradle/wrapper/gradle-wrapper.properties; app/test/release_config_test.dart |
| Actual behavior | PARTIAL source remediation exists: main permission is present and source controls pass. R1-05 runtime/merged-manifest gate is BLOCKED before task execution; release networking remains unverified, not proven absent in current code. |
| Proposed remediation | Retain the declared main permission and approved Gradle8.13/SHA pin. Once the local dependency cache/environment is ready, run controlled merged-release-manifest inspection and approved connectivity verification; do not make further online attempts now or mark Fixed from source tests alone. |
| Owner / task | flutter-specialist ses_e7c46447fffe6xRQuhbJ2twX94; R1-05 PARTIAL / runtime gate BLOCKED |

**A7 B1 evidence/limits:** main manifest line2 now declares INTERNET; shared10 source tests pass.
No merged-manifest task ran. JVM/wrapper prerequisites corrected under approvals; dependency/cache
and native-memory blockers remain. Accepted/High unchanged; no false claim of absent permission
in current source, artifact connectivity or new W4 scope. Full original defect retained below/JSON.

<details>
<summary>Historical pre-A7 B1 record — original missing-permission defect, not current source state</summary>

| Field | Value |
|---|---|
| Category | `BUG` |
| Component | Android release configuration |
| Path | `app/android/app/src/main/AndroidManifest.xml` (no `uses-permission`), `app/android/app/src/debug/AndroidManifest.xml:6`, `app/android/app/src/profile/AndroidManifest.xml:6` |
| Lines | `main` 1-45; `debug` 6; `profile` 6 |
| Origin | A1. Already planned as `TASK_BOARD.md` §M1-02 (lines 172-182) but never registered as a finding |
| Severity | **P1** |
| Confidence | **High** |
| Status | `Accepted` |
| Wave | W1 |
| Verification | `flutter build apk --release`, then inspect `app/build/app/intermediates/merged_manifests/release/AndroidManifest.xml` or `aapt dump permissions`. **NOT RUN** in A1 |

**Mechanism.** Flutter's template puts `android.permission.INTERNET` in the `debug` and `profile`
source-set manifests, not in `main`. Android's manifest merger combines `main` with the *selected* build
type, so a release build receives `main` alone. Measured: three manifests exist (`debug`, `main`,
`profile`), no `release` source set exists, and `INTERNET` appears only at `debug:6` and `profile:6`.
`app/pubspec.yaml:47` depends on `supabase_flutter`, and every data path in this app is a network call.

**Expected / actual.** Expected: a release artifact can reach Supabase. Actual: the release manifest
declares no network permission, so every socket call fails at runtime.

**Impact.** A release or internal-testing build is functionally unusable once the user leaves the
first screen. The failure surfaces as a network error, not a crash, so it can be misread as a backend
outage. This is a release blocker for the only artifact class that ships.

**Why not `Confirmed`.** The configuration fact is directly observed, but the *merged* release manifest
was not produced: the Android SDK was not used in this stage and building would write artifacts.

**Proposed remediation.** Add `<uses-permission android:name="android.permission.INTERNET"/>` to
`app/android/app/src/main/AndroidManifest.xml`. After verifying the merged release manifest, delete the
now-redundant copies from `debug`/`profile` so the requirement lives in one place.

**Regression risk.** Minimal — a normal permission cannot break the build. The real risk is recurrence:
a future reader sees `INTERNET` in `debug` and removes it from `main` again.

**Tests.** None. No CI job builds an Android artifact (`FND-TEST-001`). `TASK_BOARD.md` §M1-05 plans a
static config regression test; `TASK_BOARD.md:211` names `app/test/release_config_test.dart`.

**Dependencies.** `FND-TEST-001` — a CI platform build is the durable guard.

---

</details>

## FND-BUG-002 — Fail-closed release signing source correction awaits Gradle gates and artifact proof

| Field | Value |
|---|---|
| ID | FND-BUG-002 |
| Title | Fail-closed release signing source correction awaits Gradle gates and artifact proof |
| Severity | **P2** |
| Confidence | **High** |
| Status | `Accepted` |
| Paths | app/android/app/build.gradle.kts; app/android/gradle/wrapper/gradle-wrapper.properties; app/test/release_config_test.dart |
| Actual behavior | PARTIAL source remediation exists: no debug signing fallback, four operator environment inputs and execution-only missing-input dependency gate. R1-06 runtime gate/signature verification is BLOCKED before requested tasks; no claim that current source still selects the debug key or that release signing has been verified. |
| Proposed remediation | Retain D-030 operator-owned fail-closed signing with no debug fallback. After local cache/environment readiness, run controlled no-input and partial-input Gradle execution checks without real credentials; separately approved signing/artifact verification needs owner key custody, never read keys to make tests pass. No further online attempt now. |
| Owner / task | flutter-specialist ses_e7c46447fffe6xRQuhbJ2twX94; R1-06 PARTIAL / runtime gate BLOCKED |

**A7 B1 evidence/limits:** build.gradle.kts:8-18/45-59/63-86 defines four operator inputs, release
selection without debug fallback and execution-only dependency gate. Shared10 source tests pass,
but no actual missing/partial-input execution, APK/AAB certificate or key read. Approved8.13/SHA
and existing JBR21 prerequisites do not satisfy runtime acceptance. Accepted/High unchanged.

<details>
<summary>Historical pre-A7 B1 record — original debug-fallback defect/proposal, not current source state</summary>

| Field | Value |
|---|---|
| Category | `BUG` |
| Component | Android build configuration |
| Path | `app/android/app/build.gradle.kts` |
| Lines | 34-38 (`buildTypes { release { signingConfig = signingConfigs.getByName("debug") } }`) |
| Origin | A1. Already planned as `TASK_BOARD.md` §M1-02 |
| Severity | **P2** |
| Confidence | **High** |
| Status | `Accepted` |
| Wave | W1 |
| Verification | `flutter build appbundle --release`, then `keytool -printcert -jarfile` on the artifact; the certificate must not read `CN=Android Debug`. **NOT RUN** in A1 |

**Mechanism.** `app/android/app/build.gradle.kts:37` assigns `signingConfigs.getByName("debug")` to the
release build type. This is the Flutter template default, retained unchanged.

**Expected / actual.** Expected: release artifacts are signed with a project-held release key.
Actual: they are signed with the well-known public debug key.

**Impact.** Google Play rejects an artifact signed with the debug key, so the app cannot be distributed.
If it were side-loaded, the signature is reproducible by anyone, which breaks update authenticity and
permits impersonation. Blocks the same release path as `FND-BUG-001`.

**Why not `Confirmed`.** The assignment is read directly; no release artifact was produced or inspected.

**Proposed remediation.** Add a `key.properties`-driven `signingConfigs.create("release")` with a
gitignored keystore path, falling back to the debug config only when the properties file is absent, so
local debug builds keep working. This requires user-held credentials, so the setup steps belong in a
Vietnamese guide (`AGENTS.md` §0.1C).

**Regression risk.** A misconfigured `key.properties` breaks local release builds; the fallback keeps
the failure scoped to release builds.

**Tests.** None. Same gap as `FND-BUG-001`.

**Dependencies.** `FND-TEST-001`.

---

</details>

## FND-BUG-003 — The platform display name is the Flutter template default

| Field | Value |
|---|---|
| Category | `BUG` |
| Component | Android and iOS application metadata |
| Path | `app/android/app/src/main/AndroidManifest.xml`, `app/ios/Runner/Info.plist` |
| Lines | `AndroidManifest.xml:3` (`android:label="app"`); `Info.plist:7-8` (`CFBundleDisplayName` = `App`), `:15-16` (`CFBundleName` = `app`) |
| Origin | A1. Already planned as `TASK_BOARD.md` §M1-02 |
| Severity | **P4** |
| Confidence | **High** |
| Status | `Accepted` |
| Wave | W1 |
| Verification | Install a build and read the launcher label, or assert it in `app/test/release_config_test.dart`. **NOT RUN** in A1 |

**Mechanism.** Both platform manifests still carry the values Flutter's template generates. The in-app
brand is `'GymLevel'` (`app/lib/app.dart:21`, `app/lib/l10n/app_en.arb` `appTitle`), so the launcher
name, the OS settings entry and the product name disagree on both platforms.

**Expected / actual.** Expected: the app appears as GymLevel. Actual: it appears as `app` / `App`.

**Impact.** Cosmetic and branding only. It is listed because it lives in the same two files as the two
release-blocking defects and would otherwise be re-found after they are fixed.

**Why not `Confirmed`.** The values are read directly; no device was inspected.

**Proposed remediation.** Set `android:label="GymLevel"`, `CFBundleDisplayName` = `GymLevel`, and
`CFBundleName` = `gymlvl`. Note the iOS `CFBundleName` limit (15 characters) — `gymlvl` is safe.

**Regression risk.** None.

**Tests.** `app/test/release_config_test.dart` (planned by `TASK_BOARD.md` §M1-05).

**Dependencies.** None; bundle with `FND-BUG-001`/`FND-BUG-002` in one reviewed change.

---

## FND-TEST-001 — CI cannot detect platform, formatting, or generated-code regressions

| Field | Value |
|---|---|
| Category | `TEST` |
| Component | Continuous integration |
| Path | `.github/workflows/verify.yml` |
| Lines | 1-52 |
| Origin | A1 |
| Severity | **P2** |
| Confidence | **High** |
| Status | `Accepted` |
| Wave | W3 |
| Verification | Read the workflow end to end and compare its gates with the defects found in A1; a negative test would be a deliberate platform regression that CI still passes. **NOT RUN** |

**Observation.** The workflow has two jobs and they are good as far as they go: `database-and-edge`
runs `npm ci` → `npm test` → `npm run check:edge` → `npm run test:edge` on Node 22 with npm caching, and
`flutter` runs `flutter pub get` → `flutter analyze` → `flutter test --reporter expanded` →
`flutter build web --release`. `permissions: contents: read` is set correctly.

What is absent:

- No `dart format --output=none --set-exit-if-changed` gate. Formatting is clean today (125 files, 0
  changed) but nothing keeps it clean.
- No coverage measurement (`--coverage`, upload). G-06 stays true.
- No generated-file drift check (no `build_runner` re-run followed by `git diff --exit-code`), so stale
  `*.freezed.dart` / `*.g.dart` would pass.
- No Android or iOS build. `FND-BUG-001` and `FND-BUG-002` are invisible to this pipeline; that is not
  hypothetical, it is why both survived.
- No lock-file assertion: `flutter pub get` may silently rewrite `app/pubspec.lock`.
- Actions pinned to mutable major tags (`actions/checkout@v4`, `actions/setup-node@v4`,
  `subosito/flutter-action@v2`, `actions/upload-artifact@v4`).
- No `concurrency` and no `timeout-minutes`; `on.push` has no branch filter, so every branch consumes
  runners.
- The web build uses placeholder credentials, so it proves compilation, not configuration.

**Expected / actual.** Expected: a gate set that fails when a shippable artifact is broken. Actual: the
gate set passes an app that cannot reach the network in a release build.

**Impact.** Release-blocking defects reach `main` undetected. `docs/planning/ARCHITECTURE.md` §9 records
"No Android APK build in CI today" as fact, but no document records it as a decision, so it reads as an
unexamined default.

**Proposed remediation.** Add, in one reviewed CI change: the format gate; a `build_runner` drift check;
`flutter build apk --debug` (release needs signing); pinned action SHAs; `concurrency` keyed on the ref;
`timeout-minutes`; a `push` branch filter for `main`. `TASK_BOARD.md` §M1-05 already plans the Android
static build and config regression test.

**Regression risk.** A drift check will fail the first time if generated files are currently stale. That
was **NOT MEASURED** in A1 because running `build_runner` writes files; measure it before enabling the
gate.

**Tests.** This finding *is* about tests; it has no test of its own. Exit criterion: a deliberately
broken manifest must fail CI.

**Dependencies.** Land after `FND-BUG-001`/`FND-BUG-002` so the new gate starts green.

---

## FND-INTG-001 — The documented local auth redirect is not in the Auth allowlist

| Field | Value |
|---|---|
| Category | `INTG` |
| Component | Auth configuration contract |
| Path | `supabase/config.toml`, `app/config.example.json`, `app/lib/main.dart`, `app/lib/features/auth/data/supabase_auth_repository.dart` |
| Lines | `config.toml:150-156`; `config.example.json:4`; `main.dart:64`; `supabase_auth_repository.dart:30-34` |
| Origin | A1 |
| Severity | **P3** |
| Confidence | **High** |
| Status | `Accepted` |
| Wave | W4 |
| Verification | `supabase start`, then `POST /auth/v1/recover` with `redirect_to=http://localhost:8080/` and observe the rejection. **NOT RUN** — would start a local stack |

**Mechanism.** `supabase/config.toml:154` sets `site_url = "http://127.0.0.1:3000"` and `:156` sets
`additional_redirect_urls = ["https://127.0.0.1:3000"]`. The app reads `AUTH_REDIRECT_URL` from
`--dart-define` and passes it to `resetPasswordForEmail(redirectTo:)`
(`supabase_auth_repository.dart:30-34`). `app/config.example.json:4` supplies
`"http://localhost:8080/"`, and `app/lib/main.dart:64` documents the matching command
`flutter run -d chrome --web-port 8080 --dart-define-from-file=config.local.json`.

So the app asks for a redirect to `http://localhost:8080/`, which is neither `site_url` nor an entry in
`additional_redirect_urls`. The second allowlisted value (`https://127.0.0.1:3000`) is not a URL the
Flutter dev server serves either — it serves `http` on 8080.

**Expected / actual.** Expected: the password-reset email is sent and its link returns to the running
app. Actual (inferred from GoTrue's documented allowlist check): the recovery request is rejected
because the redirect target is not allowlisted.

**Impact.** Password recovery is broken out of the box for local development and for any environment
that copies `config.example.json` unchanged. No production impact is claimed: a production deployment
would supply its own values, which this audit cannot see.

**Why not `Confirmed`.** The mismatch is directly observed; the runtime rejection is not, because the
local Supabase stack was not started.

**Proposed remediation.** Align the three values. Either set `site_url = "http://localhost:8080"` and
`additional_redirect_urls = ["http://localhost:8080", "http://127.0.0.1:8080"]`, or change
`config.example.json` to the allowlisted origin. Changing `supabase/config.toml` is a configuration
change and needs approval.

**Regression risk.** A wrong `site_url` affects every emailed link, including confirmation; verify the
reset and confirmation flows together.

**Tests.** None. No test exercises a redirect target.

**A2 investigation addendum (lead 12; no new confirmed callback claim).**
`app/lib/features/auth/data/supabase_auth_repository.dart:21-22` omits `emailRedirectTo`, whereas
30-34 supplies the configured recovery redirect. Omission alone is not failure because server defaults
apply. Recovery fragment/hash handling and sign-up confirmation delivery remain **DEFERRED A5**, owner
`flutter-specialist` with auth integration support: approved local callback fixtures must establish the
correct auth event/session and route exactly once. Runtime verification is **NOT RUN**; do not infer
callback failure from the separate allowlist mismatch.

**Dependencies.** None.

---

## FND-ARCH-002 — Two parallel localization mechanisms, and the standard one carries no product text

| Field | Value |
|---|---|
| Category | `ARCH` |
| Component | Localization architecture |
| Path | `app/lib/core/localization/localization_engine.dart`, `app/lib/l10n/*`, `app/l10n.yaml`, `app/lib/app.dart`, `app/pubspec.yaml` |
| Lines | `localization_engine.dart:46-266` (dictionary), `:268-325` (lookup); `app.dart:21`, `:25`, `:28-34`; `pubspec.yaml:70`; `l10n.yaml` 1-3 |
| Origin | A1 |
| Severity | **P3** |
| Confidence | **High** |
| Status | `Accepted` |
| Wave | W4 |
| Verification | Static: census of the dictionary, the ARBs, the generated files, and every `AppLocalizations` reference. Measured, not executed |

**Observation.** The Flutter-standard pipeline is fully wired: `generate: true`
(`pubspec.yaml:70`), a three-line `l10n.yaml`, two ARB files, generated output
(`app_localizations.dart` 4,839 B plus `_en`/`_vi` subclasses, tracked and not gitignored), and the
delegate installed with both supported locales (`app.dart:28-34`).

It carries **one key**. `app_en.arb` is 7 lines holding `appTitle`; `app_vi.arb` holds the same key.

All product text comes from a second mechanism: `const Map<String, Map<String,String>> _dictionary` at
`localization_engine.dart:46-266`, **104 keys** with `vi` and `en` for each (104/104, no asymmetry),
read through `translateText(` / `.tr(ref)` at **209 call sites across 18 files**. Nothing reads
`AppLocalizations.of` — the only occurrences are the generated file's own doc comments. `MaterialApp.title`
is the literal `'GymLevel'` (`app.dart:21`).

**Expected / actual.** Expected: one localization mechanism, so that translators, tooling and the
runtime all see the same source of truth. Actual: two, one of which is maintained but unused.

**Historical A1 impact assessment.** Dictionary parity was exact in the A1 census. The structural cost:
translators and
`flutter gen-l10n` see 1 string of 104; no ARB placeholders, plurals or ICU number/date formatting are
available; adding a locale requires editing Dart source and shipping code; generated-file churn is
unrelated to product text; and a future contributor will reasonably add strings to the ARB and wonder
why nothing changes.

**Why not `Confirmed`.** This is an architecture observation, not a runtime behavior; the census is
static by nature.

**Proposed remediation.** Choose one mechanism, as a decision entry, and do not do both:

1. Migrate `_dictionary` to ARB (104 keys, mechanical) and delete the map. Requires a plural/placeholder
   review and a VI diacritic rendering check.
2. Remove the ARB wiring (`generate: true`, `l10n.yaml`, `app/lib/l10n/`, the delegate) and keep the
   dictionary, documenting it as the chosen mechanism.

**Regression risk.** Option 1 touches 209 call sites and both locales; a missed key becomes a runtime
fallback. Option 2 removes a working delegate that currently localizes Material/Cupertino system
strings — those must stay (`GlobalMaterialLocalizations` etc.), so only the app-level delegate would go.

**Tests.** No test asserts key parity between locales. A parity test over the chosen source would be
cheap and is the natural companion to either option.

**Dependencies.** A2 (C-05) verifies VI/EN rendering and parity; sequence the decision after that.

**A2 final-reconciliation evidence extension (leads 7 and 22; inspection only).** Dictionary parity
does not establish localization of all rendered text. Additional paths:

- `app/lib/core/localization/localization_engine.dart:274,283`: unknown keys render verbatim and
  bilingual mode inserts a newline. Truncation at large text remains **DEFERRED A5**, UI/UX owner;
  assert both language strings remain available without claiming a reproduced layout failure.
- `app/lib/ui/candy/candy_quest_card.dart:116,158,184,199`: fixed Vietnamese product labels bypass
  language selection. `app/lib/features/progression/presentation/widgets/level_up_overlay.dart:70-71,84,134,144`
  always supplies bilingual copy, independently of selected mode.
- `app/lib/features/workout/presentation/widgets/workout_exercise_tile.dart:224,236,248` uses fixed
  English headers; `exercise_card.dart:68-81` renders raw exercise name/category/equipment.
- `app/lib/features/workout/presentation/screens/workout_summary_screen.dart:251-252,367-378` uses
  fixed English fallback/count text and calls `localizedName()` without selected language;
  `workout_screen.dart:137-140` interpolates a raw error. `app/lib/features/workout/workout_copy.dart:138-142`
  renders missing keys verbatim; controller `:203` emits `restore_failed`, absent from that copy map.

These observations extend this ID, not a duplicate architecture finding. Selected-language behavior,
unknown-key coverage, Vietnamese diacritics and screen-reader/device rendering need focused A5 tests;
no device or accessibility execution is claimed here. P3 / High / `Accepted` remains unchanged.

---

## FND-ARCH-003 — The stated timezone invariant is narrower than the per-user implementation

| Field | Value |
|---|---|
| Category | `ARCH` |
| Component | Architecture invariant vs progression functions |
| Path | `docs/planning/ARCHITECTURE.md`, `supabase/migrations/20261026000200_authoritative_progression.sql` |
| Lines | `ARCHITECTURE.md:88` (invariant 7); migration `:3`, `:198`, `:241`, `:310-312` |
| Origin | A1 |
| Severity | **P3** |
| Confidence | **High** |
| Status | `Accepted` |
| Wave | W4 |
| Verification | Read the invariant and every `AT TIME ZONE` expression in the migrations. Static |

**Mechanism.** `docs/planning/ARCHITECTURE.md:88` states: "Time zone. Store UTC; compute
streaks/quests explicitly in `Asia/Ho_Chi_Minh`." The implementation adds
`profiles.timezone text NOT NULL DEFAULT 'Asia/Ho_Chi_Minh'` (`progression:3`) and computes day
boundaries from `coalesce(tz,'Asia/Ho_Chi_Minh')` at `:198` (quests), `:241` (completion day) and
`:310-312` (stats). The zone is per-user with that default, not fixed.

**Expected / actual.** Expected: an invariant sentence that is true of the code. Actual: the code is
more general than the sentence, so the sentence is false for any user whose profile timezone differs.

**Impact.** No runtime defect. The risk is editorial and asymmetric: a reviewer applying the invariant
literally would hardcode `Asia/Ho_Chi_Minh` and silently shift quest and streak day boundaries for every
user outside Vietnam. Same class as `FND-ARCH-001`, smaller blast radius because no award path is
involved.

**Why not `Confirmed`.** Documentation-versus-code comparison; nothing to execute.

**Proposed remediation.** Restate as: "Store UTC. Compute streaks, quests and daily aggregates in the
user's `profiles.timezone`, which defaults to `Asia/Ho_Chi_Minh`." Apply together with `FND-ARCH-001` so
the invariants section is edited once.

**Regression risk.** None at runtime; documentation only.

**Tests.** None applicable. A4 should assert the day-boundary behaviour for a non-default zone.

**Dependencies.** A4 owns quest/streak correctness; sequence the wording after it.

---

## FND-GOV-004 — Git approval gates do not match the operations `AGENTS.md` §8 forbids

| Field | Value |
|---|---|
| ID | FND-GOV-004 |
| Category | GOV |
| Component | Permission configuration |
| Severity | **P2** |
| Confidence | **High** |
| Status | `Fixed` |
| Root cause | Historical allow-all shell fallback left alternate Git spellings ungated. R0-02 fixes the repository policy using owner-approved D-026 default shell ask, without depending on a complete spelling denylist; read-only reviewer permissions remain narrow. |
| Evidence | Real RED/green policy regression and parent independent node --test tools/agent-tests/permission_policy.test.mjs:32 passed, exit0. Alternate/destructive Git and secret-reader spellings are synthetic evaluator inputs, never destructive commands. Original A1 failure is retained in historical_pre_a7. QA source inspection found no material blocker; no QA runtime execution claim. |
| Actual behavior | Fixed in repository scope: unlisted shell spellings resolve to ask under the tested policy model; qa-reviewer/context-keeper retain read-only restrictions and no broad shell allow override. |
| Impact | The reproduced policy-model allow fallback is corrected. High confidence remains unchanged: this is not proof of the live scanner, a sandbox, revocation of saved approvals, or prevention of every destructive operation. |
| Proposed remediation | Implemented R0-02 under D-025/D-026: maintain default shell ask and the permanent32-test policy regression; any live scanner/saved-approval validation requires a separately safe approved check, not destructive probes. |
| Owner / task | gymlvl-orchestrator / permission-policy implementer; R0-02; independent qa-reviewer source inspection |
| Wave | W1 (historical roadmap label; A7 B0 approved scope) |

**A7 review:** Repository-only Fixed, High unchanged; no runtime rerun in this docs turn. Full prior
object in JSON `historical_pre_a7`; evidence/limits in `a7_review` and A7 execution phase.

<details>
<summary>Historical pre-A7 record — superseded wording/status, not a current unfixed claim</summary>

| Field | Value |
|---|---|
| Category | `GOV` |
| Component | Permission configuration |
| Path | `.opencode/opencode.jsonc`, `AGENTS.md` §8, `.opencode/agents/gymlvl-orchestrator.md` |
| Lines | `opencode.jsonc:55-70` (Git gates); `AGENTS.md` §8; `gymlvl-orchestrator.md:54-60` |
| Origin | A1 |
| Severity | **P2** |
| Confidence | **High** |
| Status | `Accepted` |
| Wave | W1 |
| Verification | `node a1-git-gate-probe.mjs` → `RESULT: FAIL (12 probe failures, 0 schema problems)`. A live per-spelling probe is `NOT RUN` and must stay that way |

**Mechanism.** The global rule set is allow-all for `shell` (`opencode.jsonc:17`) followed by a denylist
of specific command strings. Every Git gate is prefix-anchored on the flag position:
`git push --force*`, `git push -f*`, `git push * +*`, `git push --mirror*`, `git push --delete*`,
`git reset --hard*`, `git clean *`, `git filter-branch*`, `git rebase*`, `git commit --amend*`,
`git branch -D*`, `git restore*`, `git checkout -- *`, `git checkout .`, `git stash drop*`,
`git stash clear*`.

18 probes were added to the repository's own evaluator. Twelve resolved to `allow` with match
`[shell:* -> allow]`: `git push origin --force main`, `git push origin --delete feature-x`,
`git push origin :feature-x`, `git push origin --mirror`, `git switch main`, `git checkout main`,
`git checkout HEAD -- app/lib/main.dart`, `git stash`, `git tag -d v1`,
`git -c core.pager=cat push --force origin main`, plus the two secret probes recorded under
`FND-SEC-001`. Six were gated correctly: `git push --force-with-lease`, `git push origin +main:main`,
`git branch -d`, `git clean -fdx`, `rm -rf`, `psql`.

Three distinct causes: (a) a positional argument before the flag defeats a prefix pattern;
(b) `git -c <option>` defeats every Git rule, because no rule starts with `git -c`;
(c) `git switch`, bare `git stash`, `git checkout <ref>`, `git checkout <ref> -- <path>` and
`git tag -d` have no rule at all.

**Expected / actual.** Expected: `AGENTS.md` §8's forbidden operations resolve to `ask`. Actual: six of
eighteen probed forms do. The residual control is model compliance, i.e. prose — which is precisely the
posture D-019 rejected.

**Impact.** Remote branch deletion, history rewrite via flag reordering or `git -c`, working-tree
discard via `git checkout <ref> -- <path>`, and tag deletion are all permitted without a prompt. The
orchestrator's own "Hard refusals" section (`gymlvl-orchestrator.md:54-58`) states the guarantee that
does not hold, and `docs/planning/SESSION_HANDOFF.md:26` asserts "force-push stays gated", which the
probes contradict.

**Why not `Confirmed`.** The evaluator is the repository's own reimplementation of the documented rule
model, not the harness. Promoting to `Confirmed` requires one supervised live probe per spelling, which
means issuing the destructive command; that is not an acceptable audit action.

**Proposed remediation.** Replace position-anchored patterns with segment-scanning ones, e.g.
`git push *--force*`, `git push *--delete*`, `git push *--mirror*`, `git push *:*`, `git * push *--force*`,
`git -c *`, plus explicit `git switch *`, `git checkout *`, `git stash`, `git tag -d*`. Then add the A1
probe set to the validator so a missing gate fails a test instead of waiting for a review to notice.

**Regression risk.** Broader `ask` patterns interrupt legitimate commands (`git checkout -b`, `git stash
list`). Each pattern must be probe-tested before it lands; the validator already supports that.

**Tests.** `gymlvl-perm-check.mjs` is the harness; the 18 A1 probes are the regression set. Both exist
today and the failing set is reproducible.

**Dependencies.** `FND-GOV-003` (matcher semantics) is related and closed as `False Positive`; it
established that compound commands are split into per-command resources, which is why the fix must work
per segment.

---

</details>

## FND-SEC-001 — Shell secret gates cover a short list of command spellings

| Field | Value |
|---|---|
| ID | FND-SEC-001 |
| Category | SEC |
| Component | Permission configuration |
| Severity | **P2** |
| Confidence | **High** |
| Status | `Fixed` |
| Root cause | Historical allow-all shell fallback made the secret-reader spelling denylist incomplete. R0-02 replaces that fallback with owner-approved D-026 default ask and preserves narrow read-only reviewer permissions; no secret-reader allowlist is claimed complete. |
| Evidence | Real RED/green policy regression; parent independent node --test tools/agent-tests/permission_policy.test.mjs ->32 passed, exit0, including synthetic alternate readers and reviewer-permission controls. No actual secret read/copied/exfiltrated. Historical A1 observations retained in historical_pre_a7. Independent QA is source inspection only. |
| Actual behavior | Fixed in repository scope: unlisted shell readers now resolve to ask in the32-test model; qa-reviewer/context-keeper read-only restrictions and sensitive read gates remain preserved. |
| Impact | The tested default-allow policy bypass is corrected; High confidence is unchanged because live scanner enforcement, saved approvals and actual secret isolation were not verified. Pattern matching is not a sandbox. |
| Proposed remediation | Implemented R0-02/D-026 default shell ask with permanent policy tests, without adding broad shell allows; maintain sensitive gates and reviewer restrictions. Separately safe live-harness validation remains NOT RUN, never read secrets to test a gate. |
| Owner / task | gymlvl-orchestrator / permission-policy implementer; R0-02; independent qa-reviewer source inspection |
| Wave | W1 (historical roadmap label; A7 B0 approved scope) |

**A7 review:** Repository-only Fixed; no live scanner/sandbox or saved-approval assurance, no actual
secret-reader test. Full pre-A7 object retained in JSON; runtime suites not rerun in this docs turn.

<details>
<summary>Historical pre-A7 record — superseded wording/status, not a current unfixed claim</summary>

| Field | Value |
|---|---|
| Category | `SEC` |
| Component | Permission configuration |
| Path | `.opencode/opencode.jsonc`, `.opencode/agents/gymlvl-orchestrator.md`, `docs/planning/SESSION_HANDOFF.md` |
| Lines | `opencode.jsonc:25-27` (read gates), `:37-51` (shell gates); `gymlvl-orchestrator.md:57-58`; `SESSION_HANDOFF.md:75-76` |
| Origin | A1 |
| Severity | **P2** |
| Confidence | **High** |
| Status | `Accepted` |
| Wave | W1 |
| Verification | `node a1-git-gate-probe.mjs` → `Select-String -Path .env -Pattern .` and `Copy-Item .env C:/Temp/x.txt` both `got=allow [shell:* -> allow]` |

**Mechanism.** File reads are gated (`*.env` and `*.env.*` → `ask`, `*.env.example` → `allow`). Shell
reads of secrets are gated by an enumeration of four reader spellings only: `Get-Content`, `type`,
`cat`, `more`, each for `*.env` and `*.env.*`. Any other command that can read a file is unmatched by
those rules and falls through to `shell:* -> allow`: `Select-String`, `Copy-Item`, `Get-ChildItem
-Recurse`, `Format-Hex`, `Out-File`, `Set-Content`, `[IO.File]::ReadAllText`, `node -e
"fs.readFileSync('.env')"`, `git show HEAD:.env`.

Two probes were run and both returned `allow`. The remaining spellings are identified by inspection of
the rule list and were **not** individually probed.

**Expected / actual.** Expected: reading a secret file resolves to `ask`, as
`gymlvl-orchestrator.md:57-58` states. Actual: it resolves to `ask` only for four command spellings.

**Impact.** An agent can read and exfiltrate `.env` — or copy it outside the repository — without a
prompt, using an equivalent command. The control is the only thing standing between an autonomous agent
and the project's credentials.

**Prior knowledge.** `docs/planning/SESSION_HANDOFF.md:75-76` already records that the shell gates are
pattern-based and that an obfuscated path such as `Get-Content ("."+"env")` is not matched. This finding
does not re-discover that; it records that the *verb* list is also incomplete, which the existing note
does not say, and it makes the gap measurable.

**Why not `Confirmed`.** Two spellings were demonstrated against the evaluator; the evaluator is not the
harness, and a live probe would mean actually reading a secret file.

**Proposed remediation.** A denylist over an allow-all shell cannot be made complete. Two honest
options, and the choice belongs to the user because D-024 deliberately traded the allowlist away:

1. Enumerate the readers actually used in this environment (PowerShell built-ins, .NET static methods,
   `node`/`deno` file APIs, `git show`), add a gate per spelling, and add a validator probe per spelling
   so the list cannot silently shrink.
2. Reintroduce a per-agent shell allowlist for the read-only and coordination agents, so an unlisted
   command is denied by default.

**Regression risk.** Option 1 stays fragile by construction. Option 2 reintroduces the override hazard
that D-024 removed, so it must not be paired with a broad per-agent allow.

**Tests.** The validator is the harness; the two probes are the regression set.

**Dependencies.** Shares a root cause with `FND-GOV-004` (prefix-anchored denylist); fix them in one
reviewed change.

---

</details>

## FND-GOV-005 — A stale analyzer transcript is tracked as `app/analysis.txt`

| Field | Value |
|---|---|
| Category | `GOV` |
| Component | Repository hygiene |
| Path | `app/analysis.txt` |
| Lines | whole file (84,864 bytes) |
| Origin | A1 |
| Severity | **P4** |
| Confidence | **High** |
| Status | `Accepted` |
| Wave | W4 |
| Verification | `git ls-files app/analysis.txt` → tracked; tail → `221 issues found. (ran in 12.1s)`; current `flutter analyze` → `No issues found!` |

**Observation.** `app/analysis.txt` is a redirected `flutter analyze` run, tracked since `56c1122`
(`git log --oneline -- app/analysis.txt` → `29f2029`). Its last line claims **221 issues found**. The
current analyzer reports none. No document, workflow or script references the file: a grep for
`analysis.txt` across `*.md`, `*.yml` and `*.json` returns no hits.

**Expected / actual.** Expected: analyzer output either is not committed, or is regenerated and
referenced. Actual: a stale 85 KB snapshot is committed, referenced by nothing, and contradicts the
current gate.

**Impact.** A reader who finds it concludes the app has 221 analyzer findings — including
`unused_import` warnings that no longer exist. It also embeds absolute local paths from the machine that
produced it. No runtime effect.

**Why not `Confirmed`.** The file's content and tracking status are directly observed; this is a
hygiene defect with nothing to execute.

**Proposed remediation.** `git rm app/analysis.txt`. If a redirect target is still wanted locally, add
`analysis.txt` to `app/.gitignore`. Deleting a tracked file needs approval.

**Regression risk.** None.

**Tests.** Not applicable.

**Dependencies.** None.

---

## Not findings

Recorded so they are not re-derived, and so their status is explicit.

| Item | Why not a finding |
|---|---|
| S3 L1 (concurrent subagent shell denial) | Operational; closed by D-021 as a rule |
| S3 L2 (`default_agent` unverified for a new session) | Programme item, not a defect. **Root-caused in A0.1:** `default_agent` is a session-creation default, not a live switch (OpenCode V2, *Config → Agent*), so an existing session keeps its selected agent. Resolution requires a new session; tracked in `SESSION_HANDOFF.md` §7. |
| S3 L3 (subagent answered in Vietnamese) | Prompt-quality note; the orchestrator is the translation boundary |
| S3 L7 (Apache-2.0 notice) | Licensing task, not a codebase defect |
| S3 L8 (`.opencode/` not human-reviewed) | Review action |
| `app/test/verify_logic.dart` shim | Intentional; documented comment. Coverage relevance recorded as G-04 |
| Freezed `invalid_annotation_target` suppressions | Required by the generator; no hand-written `// ignore:` exists (G-02) |
| `tools/db-tests/e2e-catalog-test.mjs` hardcodes seed paths and is unreachable from `package.json` | Dead second entry point; no incorrect behaviour. A5 owns harness cleanup (A1 §11 O-1) |
| No migration ledger in the repository | Tooling observation; ordering is enforced by the filename scheme and the harness regex. A3 measures migration-history risk (A1 §11 O-4) |
| `CREATE TABLE IF NOT EXISTS` cannot repair a divergent pre-existing table | Documented at `docs/ARCHITECTURE.md:41`; a release risk, not a defect (A1 §11 O-5) |
| `update_modified_column` defined three times | Harmless redefinition; A3 owns schema review (A1 §11 O-6) |
| `bilingual` language mode maps to `Locale('vi')` | Behaviour question owned by A2/C-05 (A1 §11 O-8) |
| A0 recorded `verify.yml` as 58 lines and the migrations as 1,222 lines | Audit-internal measurement corrections (52 and 1,219 non-blank respectively), fixed in `AUDIT_COVERAGE.md` §2. Not a codebase defect (A1 §11 O-2, O-3) |

---

## FND-SEC-002 — Global workout backup is adopted under a different synthetic controller identity

| Field | Value |
|---|---|
| ID | FND-SEC-002 |
| Severity | **P1** |
| Confidence | **Confirmed** |
| Status | `Fixed` |
| Paths | app/lib/features/workout/presentation/controllers/active_workout_controller.dart; app/test/workout_snapshot_ownership_test.dart |
| Actual behavior | Fixed in repository/local scope: owner-scoped keys and pre-adoption owner checks reject foreign/ownerless snapshots in both paths; remote null/error cannot bypass ownership, same-owner offline recovery survives and save/discard preserve unrelated bytes. |
| Proposed remediation | Implemented R1-01 under separate approved snapshot-ownership gate: retain owner validation before restore/render and conservative preservation, with permanent31-test regression. Live/device/server verification is a separate prerequisite, not implied by local Fixed. |
| Owner / task | flutter-specialist ses_e7c46447fffe6xRQuhbJ2twX94; R1-01; independent QA ses_e7c4250a1ffeXk30ceIhMb3Jvk |

**A7 B1 evidence/limits:** Real RED adoption/overwrite corrected;31 new ownership tests and
independent31/full157/analyze pass; parent final200/analyze/format pass. Both recovery paths retain
same-owner offline recovery, owner-scoped keys and foreign/ownerless preservation with remote
null/error controls. No real-account/RLS/device claim. Full previous object including A3 review
in JSON `historical_pre_a7`; no runtime rerun by this docs writer.

<details>
<summary>Historical pre-A7 B1 record — superseded wording/status, not a current adoption-failure claim</summary>

| Field | Value |
|---|---|
| Category | `SEC` |
| Component | Client workout snapshot recovery and session isolation |
| Paths | `app/lib/features/workout/presentation/controllers/active_workout_controller.dart`; `app/lib/features/workout/presentation/screens/workout_screen.dart` |
| Lines | controller:72,85-94,150-180,184-201,217-249; screen:25-31,278-338 |
| Origin | A2 interrupted Flutter review; independent recovery inspection by `qa-reviewer` (`ses_e7e1bf63bffevgwQCjbB0LURN0`) and orchestrator |
| Severity | **P1** |
| Confidence | **Confirmed** |
| Status | `Accepted` |
| Wave | W1 |

**Current scope (A2 final reconciliation, 2026-10-28).** Confirmed scope is synthetic controller-state
adoption, not real-account disclosure or RLS bypass. The last A2 continuation ran the retained probe
against the real controller in
`C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a2-minimal-20261028\app` at `7eb40f1`:
`flutter test --no-pub --reporter expanded test/a2_retained_probe_test.dart` ->
`+7: All tests passed!`, exit 0. Output includes
`CHECK B backup=A remote=null observed_owner=A expected_owner=null` and
`CHECK B backup=A remote=error observed_owner=A expected_owner=null`; same-owner control:
`CHECK A backup=A remote=null observed_owner=A expected_owner=A`. Both explicit restore and UI-used
`checkForActiveWorkout` are covered. Source and output: `phases/A2_PROBES.md:50-189,229-266`.
This is retained evidence, **not a current documentation-task rerun**; green tests reproduce defects.

**Expected / observed.** Reject owner mismatch before adoption. Under synthetic B identity, A's
snapshot is adopted with remote null/error; same-owner A recovery remains available. Source
`workout_screen.dart:36,47-51,278` consumes this state for rendering, but no real-account UI was tested.
P1 is the assessed potential shared-device disclosure impact, not demonstrated actual disclosure.
Live RLS, backend writes, real-device storage and sign-out cleanup are **NOT RUN**. Build at 85-94
does reset memory and timers; this finding does not assert otherwise.

**Current remediation / verification.** Namespace storage by authenticated owner and validate owner
before adoption. After fix authorization, mismatched snapshots must never enter either recovery path's
state, while same-owner offline recovery still works. Permanent regression coverage remains missing;
the retained audit harness is not a product fix or a permanent regression test.

### Historical recovery record (superseded classification: P1 / High / Needs Verification)

**Root cause.** One `shared_preferences` key survives identity changes. Controller build resets memory
and timers but does not clear or namespace the backup. Both restore paths decode `workout.userId`
without comparing it to current auth identity; `checkForActiveWorkout` adopts local first and keeps it
if remote returns null or throws.

**Evidence (inspection, `7eb40f1`).** Key `gymlvl_active_workout_backup` at 72; save/read at 150-180;
`_adopt(workout,generation)` at 192 and 226 without owner check; remote null clears only when
`backup==null` at 238. QA independently validated this path and rejected the distinct claim that
signout cannot reset memory/timers: 85-94 does reset them. Cross-account runtime reproduction
`NOT RUN`; no assertion about RLS bypass or server-side writes.

**Expected / actual.** An account must not see another account's locally cached workout; owner
validation must precede adoption and rendering. Actual recovery accepts any parseable active snapshot
under the global key even if its `userId` differs from the authenticated user. Display exposure after
account switch is source-supported but not yet exercised.

**Impact.** Potential disclosure of prior user's exercises, logged loads and session data to a
subsequent user on the same install. P1 for plausible cross-account local disclosure, not evidence of
server corruption or authorization bypass.

**Proposed remediation.** After audit authorization, scope storage by authenticated identity and
reject owner mismatch before adoption; preserve same-owner recovery and define logout/cache policy.

**Regression risk.** Offline recovery, shared-device account changes, old unscoped snapshots, and auth
refresh while storage is awaiting.

**Tests.** Related: `app/test/session_isolation_test.dart`, `app/test/workout_controller_test.dart`.
Missing: A snapshot / B identity with remote null and remote error; same-owner offline control.

**Dependencies.** `FND-CONC-001` affects safe discard after recovery; server authorization stays A3/A4.

**Verification method.** Non-production audit probe with mocked preferences containing A's snapshot,
auth stream for B, fake repository returning null/error; assert no adoption of A, with same-owner
control. Retain outside permanent application tests. `NOT RUN` at this recovery checkpoint.

---

</details>

## FND-BUG-004 — Profile identity and edit text resolve white-on-white under Candy light

| Field | Value |
|---|---|
| ID | FND-BUG-004 |
| Title | Profile identity and edit text resolve white-on-white under Candy light |
| Category | BUG |
| Component | Profile light-theme readability; onboarding source-only extension |
| Paths | app/lib/app.dart; app/lib/core/theme/app_theme.dart; app/lib/core/theme/candy_colors.dart; app/lib/features/profile/presentation/screens/profile_screen.dart; app/lib/features/onboarding/presentation/screens/onboarding_screen.dart |
| Lines | app.dart:22-24; app_theme.dart:7-15; candy_colors.dart:8-9; profile_screen.dart:619-622,663-685; onboarding_screen.dart:896-898,915-926 |
| Origin | A2 static profile/onboarding finding; A5 actual ProfileScreen resolved-style fixtures and independent QA |
| Root cause | Legacy explicit white/white54 foregrounds remain after panel tokens map to the white Candy card in forced light mode. |
| Evidence | A5 UI results section2 at614ee7c (unchanged product baseline1763ab5): actual ProfileScreen with fake profile/class/user data at390x844/100%, Candy light, both VI/EN, resolves display-name and first edit TextField white-on-white1.0:1; ink-on-card positive control18.883060964594996:1, errors=[]. Aggregate UI command FAIL(+8 -2): two onboarding tests fail on null chip background; they do not verify chip colors or a whole onboarding journey. Onboarding white/white54 source evidence remains static. qa-reviewer ses_e7cb5a850ffeEKOCUhDgig3neH independently read product source/full retained probes and supports these bounded claims; no independent runtime rerun claimed. Extra QA source Git command BLOCKED, not retried or bypassed. |
| Expected behavior | Actual profile identity/edit text is readable on production light surfaces; onboarding choices require their own resolved paint verification. |
| Actual behavior | Both localized actual profile fixtures resolve the cited identity/edit foreground/background pairs to1.0:1. Onboarding contrast extension is source-only; failed chip extraction cannot establish chip colors. |
| Impact | P2 confirmed unreadable profile identity/edit style mechanism in the bounded VI/EN fixtures; no full profile/onboarding flow, all-state contrast, device or data-integrity certification. |
| Severity | **P2** |
| Confidence | **Confirmed** |
| Status | `Accepted` |
| Proposed remediation | Owner ui-ux-specialist with flutter-specialist and qa-reviewer: after approval use existing Candy ink/charcoal tokens on light panels and preserve selected-state distinction; verify actual profile pairs and independently resolve onboarding composited paints before extending runtime claims. |
| Regression risk | Profile view/edit, selected/disabled states, VI/EN, large text and actual onboarding foreground/background combinations. |
| Related tests | app/test/ui_regression_test.dart; docs/audit/phases/A5_UI_EVIDENCE.md section2 Profile VI/EN results |
| Missing tests | After fix approval: actual profile identity/edit pairs in VI/EN at normal and200% text meet the approved contrast criterion with ink positive control.; Authorized UI follow-up: finish actual unselected/selected onboarding chip paint extraction without null/guessed background; test interaction separately. Existing two fixture tests remain FAIL. |
| Depends on | No palette/dependency change approved; Confirmed scope is actual Profile resolved styles only. |
| Wave | W2 |
| Verification method | Retained docs/audit/phases/A5_UI_EVIDENCE.md section2 and full sources/logs section6: eight cases passed within an aggregate failing run; only Profile pair/control observations support this promotion. QA read evidence; no UI rerun in writer. Onboarding full journey/chip colors NOT verified. |

**A5 review:** product baseline `1763ab55e8da994bc1d854ad8fd2cd2299678b45`; UI evidence/documentation entry `614ee7cb6f99846b00fd71eec43637cb296268be`; qa-reviewer ses_e7cb5a850ffeEKOCUhDgig3neH independently read product source/full retained probes and supports these bounded claims; no independent runtime rerun claimed. Extra QA source Git command BLOCKED, not retried or bypassed. No runtime rerun in this documentation turn.

<details>
<summary>Historical pre-A5 record — superseded current wording/classification, not an additional A5 claim</summary>

#### Archived FND-BUG-004 — Profile and onboarding use white foregrounds on white Candy panels

| Field | Value |
|---|---|
| ID | `FND-BUG-004` |
| Title | Profile and onboarding use white foregrounds on white Candy panels |
| Category | `BUG` |
| Component | Profile/onboarding light-theme readability |
| Paths | `app/lib/app.dart`; `app/lib/core/theme/app_theme.dart`; `app/lib/core/theme/candy_colors.dart`; `app/lib/features/profile/presentation/screens/profile_screen.dart`; `app/lib/features/onboarding/presentation/screens/onboarding_screen.dart` |
| Lines | `app.dart:22-24`; `app_theme.dart:7-15`; `candy_colors.dart:8-9`; `profile_screen.dart:619-622,663-685`; `onboarding_screen.dart:896-898,915-926` |
| Origin | A2 final reconciliation; independent UI/UX review and bounded source reread |
| Root cause | Legacy explicit white/white54 foregrounds remain after panel tokens map to the white Candy card in forced light mode. |
| Evidence | Inspection only: profile header panel uses `AppTheme.panelBackground`, while display name and edit text explicitly use `Colors.white`; unselected onboarding gender icon/label use `Colors.white54` on the same white panel. No rendered contrast/device probe was run. |
| Expected behavior | Profile identity and unselected onboarding choices remain readable on the active Candy surfaces. |
| Actual behavior | Source resolves the cited foregrounds and panel background to white, including translucent white over white for unselected choices. |
| Impact | Users can miss identity text and onboarding options; no data corruption, exploit or P0 impact is asserted. |
| Severity | **P2** |
| Confidence | **High** |
| Status | `Accepted` |
| Proposed remediation | After fix authorization, use existing Candy ink/charcoal tokens for text and icons on light panels; retain selected-state distinction. |
| Regression risk | Profile viewing/editing, gender selection, VI/EN text and disabled/selected states. |
| Related tests | `app/test/ui_regression_test.dart` |
| Missing tests | Render the actual profile header/edit state and unselected onboarding choices under the production light theme; assert readable foreground/background pairings. |
| Depends on | A5 UI/UX rendering/contrast verification; no new palette or dependency. |
| Wave | W2 |
| Verification method | A5 `ui-ux-specialist`: render cited states at normal/large text in VI/EN and measure foreground/background contrast. NOT RUN in this documentation checkpoint; static-only confidence is not Confirmed. |

---


</details>

---

## FND-BUG-005 — Dashboard workout and set KPIs omit their last-three-workout scope

| Field | Value |
|---|---|
| ID | `FND-BUG-005` |
| Title | Dashboard workout and set KPIs omit their last-three-workout scope |
| Category | `BUG` |
| Component | Dashboard KPI data window and labeling |
| Paths | `app/lib/features/dashboard/presentation/screens/dashboard_screen.dart`; `app/lib/features/dashboard/presentation/widgets/kpi_tiles_grid.dart`; `app/lib/features/workout/presentation/controllers/workout_history_controller.dart` |
| Lines | `dashboard_screen.dart:126-140`; `kpi_tiles_grid.dart:41-46,62-75`; `workout_history_controller.dart:12-14,26-29` |
| Origin | A2 final reconciliation; independent UI/UX review and bounded source reread |
| Root cause | Dashboard derives workout count and set count from the recent-workout list limited to three, without qualifying those KPI labels with that window. |
| Evidence | Inspection only: `totalWorkouts = recentWorkouts.length`; sets accumulate from the same list; repository call requests limit 3. Labels are WORKOUTS/BUỔI TẬP and TOTAL SETS/TỔNG SỐ HIỆP, not last-three labels. A separate completed-count provider exists, but intended KPI timeframe is not specified. |
| Expected behavior | State the aggregation window or use the product-approved window consistently. No lifetime-total requirement is invented. |
| Actual behavior | The two cited KPI values are restricted to at most three recent workouts without that qualification in their labels. |
| Impact | Users can misunderstand the scope of dashboard counts; intended semantics require clarification, hence Medium confidence. |
| Severity | **P2** |
| Confidence | **Medium** |
| Status | `Needs Verification` |
| Proposed remediation | Confirm the intended window with the product owner, then label last-three values explicitly or query the approved aggregate. |
| Regression risk | Dashboard counts, empty history, pagination, and VI/EN KPI wording. |
| Related tests | `app/test/ui_regression_test.dart` |
| Missing tests | More than three completed workouts with distinct set counts; verify values and labels against an explicitly approved window. |
| Depends on | Product clarification of KPI window; A5 Flutter fixture test. |
| Wave | W2 |
| Verification method | A5 `flutter-specialist`: supply five completed workouts, inspect the last-three values and visible labels, and assert the agreed window. NOT RUN; intended semantics are unresolved. |

---

## FND-BUG-006 — Quest cards display fixed progress and inconsistent fallback rewards

| Field | Value |
|---|---|
| ID | `FND-BUG-006` |
| Title | Quest cards display fixed progress and inconsistent fallback rewards |
| Category | `BUG` |
| Component | Quest and dashboard quest presentation |
| Paths | `app/lib/features/quests/presentation/widgets/daily_quest_card.dart`; `app/lib/features/dashboard/presentation/screens/dashboard_screen.dart` |
| Lines | `daily_quest_card.dart:50-54,73`; `dashboard_screen.dart:325-328,349-355` |
| Origin | A2 final reconciliation; independent UI/UX review and bounded source reread |
| Root cause | Status-based constants substitute for measured progress, and two views use different constants when earned XP is absent. |
| Evidence | Inspection only: active daily quest displays 0.35 progress and `earnedXp ?? 350`; dashboard displays zero progress until completed and `earnedXp ?? 100` for the same quest shape. |
| Expected behavior | Progress reflects known completion or is explicitly unknown; missing server rewards do not appear as conflicting earned amounts. |
| Actual behavior | An active quest receives fixed 35% in one view and zero in another; null earned XP becomes 350 versus 100. |
| Impact | Misleading progress/reward expectations. These are display-only substitutions, not persisted XP or client award forgery. |
| Severity | **P2** |
| Confidence | **High** |
| Status | `Accepted` |
| Proposed remediation | Render authoritative values when available; otherwise use an explicitly labeled preview/unknown state shared across both views. |
| Regression risk | Active, expired and completed quest cards; null versus zero rewards; VI/EN presentation. |
| Related tests | `app/test/ui_regression_test.dart` |
| Missing tests | Render the same active quest with null earned XP in both views; assert consistent truthful progress/reward copy. |
| Depends on | A4 quest progress/reward contract clarification; FND-ARCH-002 owns localization, not these numerical substitutions. |
| Wave | W2 |
| Verification method | A5 `flutter-specialist`: compare both views using the same active/completed/null-reward fixtures and verify no invented earned amount. NOT RUN; source inspection only. |

---

## FND-BUG-007 — Summary fallback fabricates a completed workout and 500 earned XP

| Field | Value |
|---|---|
| ID | `FND-BUG-007` |
| Title | Summary fallback fabricates a completed workout and 500 earned XP |
| Category | `BUG` |
| Component | Workout summary routing and reward display |
| Paths | `app/lib/core/router/app_router.dart`; `app/lib/features/workout/presentation/screens/workout_summary_screen.dart`; `app/lib/features/workout/presentation/screens/active_workout_screen.dart`; `app/lib/features/workout/presentation/controllers/active_workout_controller.dart` |
| Lines | `app_router.dart:127-174`; `workout_summary_screen.dart:69-74`; `active_workout_screen.dart:82-100`; `active_workout_controller.dart:672-675` |
| Origin | A2 final reconciliation; navigation lead 11 and summary lead 19 merged |
| Root cause | Missing route payload is replaced by a synthetic completed workout, and absent earnedXP is replaced by 500 rather than unknown. |
| Evidence | Inspection only: no-extra summary route returns `summary-default` with completed status; map payload without workout uses `summary-preview`. Summary uses `xpResult?['earnedXP'] ?? 500`. Normal controller completion supplies rewards; the fallback is not proof that normal RPC responses omit earnedXP. |
| Expected behavior | Missing summary context produces an unavailable/redirect state; missing earned XP is not presented as a real reward. |
| Actual behavior | An authenticated, onboarded summary deep link without extra can construct a synthetic completed summary displaying 500 earned XP. |
| Impact | Misleading completion/reward display; no completed-workout database record, persisted XP or award-authority bypass is created by this route. |
| Severity | **P2** |
| Confidence | **High** |
| Status | `Accepted` |
| Proposed remediation | Require validated summary context or redirect to history; display unknown reward data explicitly instead of inventing 500. |
| Regression risk | Successful completion, summary deep links/reloads, null/zero rewards, modal summary dismissal. |
| Related tests | `app/test/navigation_integration_test.dart`; `app/test/workout_widgets_test.dart` |
| Missing tests | Authenticated summary navigation without extra, absent earnedXP, and zero earnedXP; assert no fabricated completion/reward. |
| Depends on | Auth/onboarding gate permits the route only for eligible sessions; unrelated to FND-DATA-001 award idempotency. |
| Wave | W2 |
| Verification method | A5 `flutter-specialist`: navigate to summary under eligible auth with no extra and with missing/zero earnedXP fixtures. NOT RUN; source-supported reachability only. |

---

## FND-INTG-002 — Post-award detail fetch failure is reported as failed workout completion

| Field | Value |
|---|---|
| ID | FND-INTG-002 |
| Severity | **P2** |
| Confidence | **Confirmed** |
| Status | `Fixed` |
| Paths | app/lib/features/workout/domain/workout_repository.dart; app/lib/features/workout/data/supabase_workout_repository.dart; app/lib/features/workout/presentation/controllers/active_workout_controller.dart; app/lib/features/workout/presentation/screens/active_workout_screen.dart; app/lib/features/workout/workout_copy.dart |
| Actual behavior | Fixed in repository/local scope: pending receipt survives detail null/error, blocks edits and exposes detail-only reload; acknowledged reload does not issue a second award RPC. Rejected and uncertain outcomes differ; successful hydration supplies the rendered7-second server duration instead of the120-second local timer. Receipt rewards use shallow Map.unmodifiable in memory, not deep immutability or durable persistence. |
| Proposed remediation | Implemented R1-03/D-029 rewards-only receipt and pending/detail-only reconciliation; preserve captured caller/request ownership, error distinctions and hydrated UI fields. R1-04/07 actual connection/commit-lost-ACK/reject/reload persistence remains BLOCKED, not replaced by synthetic counters. |
| Owner / task | flutter-specialist ses_e7c46447fffe6xRQuhbJ2twX94; R1-03; independent QA ses_e7c4250a1ffeXk30ceIhMb3Jvk |

**A7 B1 evidence/limits:** D-029 approved actual rewards-only SQL response contract; captured
caller/request receipt does not fabricate a Workout. Implementer76 focused and independent18
including rendered VI/EN pending/reload/server7sec controls pass; parent final200/analyze/format
pass. Pending hydration blocks edits; reload is detail-only, not a second completion RPC. Shallow
in-memory rewards map is not durable or deeply immutable. Actual SQL commit count is NOT proved;
R1-04/07 isolated connection/commit-lost-ACK/reject/reload controls remain BLOCKED. Previous whole
object/nested A5/A4 history in JSON `historical_pre_a7`; no runtime rerun here.

<details>
<summary>Historical pre-A7 B1 record — superseded client wording/status; prior A4/A5 history retained</summary>

| Field | Value |
|---|---|
| ID | FND-INTG-002 |
| Title | Post-award detail fetch failure is reported as failed workout completion |
| Category | INTG |
| Component | Workout completion client reconciliation |
| Paths | app/lib/features/workout/data/supabase_workout_repository.dart; app/lib/features/workout/presentation/controllers/active_workout_controller.dart; app/lib/features/workout/presentation/screens/active_workout_screen.dart |
| Lines | supabase_workout_repository.dart:66-76; active_workout_controller.dart:655-682; active_workout_screen.dart:82-83 |
| Origin | A2 completion reconciliation; A4 snapshot observation preserved; A5 real repository/client failure mapping and independent QA |
| Root cause | Repository combines a successful award RPC and a separate detail lookup into one failing Future; controller cannot distinguish a committed completion from failed submission. |
| Evidence | A5 Flutter G5 uses actual SupabaseWorkoutRepository/controller with synthetic HTTP: successful fake completion RPC followed by error or null hydration returns null/completion_failed and retains active local state. Retry hydration succeeds; modeled commitCount1/rpcAttempts2 is supplied by the fixture, not new SQL commit/idempotency proof. Success control observes hydrated duration7 versus summary local elapsed120; that field split is an observation, not a new duration defect absent approved semantics. qa-reviewer ses_e7cb5a850ffeEKOCUhDgig3neH independently read product source/full retained probes and supports these bounded claims; no independent runtime rerun claimed. Extra QA source Git command BLOCKED, not retried or bypassed. |
| Expected behavior | Preserve successful award acknowledgement and represent subsequent detail retrieval as reconciliation, not an unqualified submission failure. |
| Actual behavior | Actual client reports completion_failed/null and retains local active session after the fixture acknowledges completion then fails/nulls detail hydration; successful-hydration/retry controls consume the supplied response. |
| Impact | P2 confirmed client acknowledgement/hydration error conflation under synthetic transport; no newly proven SQL commit, duplicate award, corruption or duration/XP defect. |
| Severity | **P2** |
| Confidence | **Confirmed** |
| Status | `Accepted` |
| Proposed remediation | Owner flutter-specialist with supabase-specialist and qa-reviewer: after approval separate acknowledged completion from subsequent detail hydration, preserve reward acknowledgement/workout ID and expose recoverable reconciliation rather than unqualified submission failure. |
| Regression risk | Pre-award transport rejection, post-ack hydration error/null, replay/retry, pending edits, summary policy and auth reset. |
| Related tests | app/test/workout_controller_test.dart; docs/audit/phases/A5_FLUTTER_EVIDENCE.md G5 |
| Missing tests | After fix approval: fake RPC acknowledgement followed by hydration error/null preserves acknowledgement and a recoverable reconciliation state; compare pre-RPC failure and successful hydration controls.; Approved isolated SQL/gateway: independently verify commit/replay plus lost hydration, exactly one award and coherent local recovery. Confirm summary duration policy before asserting120-versus7 is wrong. |
| Depends on | DATA001 is separately P1/Confirmed/Accepted only for its conditional historical tuple; authoritative SQL retry/idempotency is not established by this fake commit fixture. |
| Wave | W1 |
| Verification method | Retained actual client/repository HTTP G5 source/output, docs/audit/phases/A5_FLUTTER_EVIDENCE.md:140-149,584-601,691-696;18-test observation run exit0. QA supports narrow client promotion; writer did not rerun runtime tests or establish a new SQL commit. |

**A5 review:** product baseline `1763ab55e8da994bc1d854ad8fd2cd2299678b45`; UI evidence/documentation entry `614ee7cb6f99846b00fd71eec43637cb296268be`; qa-reviewer ses_e7cb5a850ffeEKOCUhDgig3neH independently read product source/full retained probes and supports these bounded claims; no independent runtime rerun claimed. Extra QA source Git command BLOCKED, not retried or bypassed. No runtime rerun in this documentation turn.

<details>
<summary>Historical pre-A5 record — superseded current wording/classification, not an additional A5 claim</summary>

#### Archived FND-INTG-002 — Post-award detail fetch failure is reported as failed workout completion

| Field | Value |
|---|---|
| ID | `FND-INTG-002` |
| Title | Post-award detail fetch failure is reported as failed workout completion |
| Category | `INTG` |
| Component | Workout completion client reconciliation |
| Paths | `app/lib/features/workout/data/supabase_workout_repository.dart`; `app/lib/features/workout/presentation/controllers/active_workout_controller.dart`; `app/lib/features/workout/presentation/screens/active_workout_screen.dart` |
| Lines | `supabase_workout_repository.dart:66-76`; `active_workout_controller.dart:655-682`; `active_workout_screen.dart:82-83` |
| Origin | A2 final reconciliation; completion lead 14 separated from legacy award finding |
| Root cause | Repository combines a successful award RPC and a separate detail lookup into one failing Future; controller cannot distinguish a committed completion from failed submission. |
| Evidence | Inspection only: `complete_workout` is awaited before `getWorkoutDetail`; a failed/null detail fetch throws. Controller catch sets `completion_failed` and returns null before clearing active state; screen returns without summary on null. No live RPC or injected failure was run. |
| Expected behavior | Preserve successful award acknowledgement and represent subsequent detail retrieval as reconciliation, not an unqualified submission failure. |
| Actual behavior | If award RPC succeeds and subsequent detail retrieval fails, the caller receives null with completion_failed and retains local active workout state. |
| Impact | False failure/retry confusion after potentially committed server completion. No duplicate award, data corruption or server idempotency defect is established. |
| Severity | **P2** |
| Confidence | **High** |
| Status | `Accepted` |
| Proposed remediation | Separate award acknowledgement from detail hydration; preserve committed results and provide a recoverable reconciliation state using the existing workout ID. |
| Regression risk | Completion success, transport failures before/after award, detail not found, retries and auth changes. |
| Related tests | `app/test/workout_controller_test.dart` |
| Missing tests | Successful award response followed by failing/null detail fetch; distinguish pre-award failure from committed completion pending hydration. |
| Depends on | FND-DATA-001 remains separate P1 / Medium / Needs Verification; A4 owns authoritative idempotency. |
| Wave | W1 |
| Verification method | A5 `flutter-specialist`: use a controlled repository/transport fixture that acknowledges award then fails detail retrieval; assert preserved acknowledgement and recovery behavior. NOT RUN; no backend commit was exercised here. |

**A4 review — classification unchanged P2/High/Accepted.** This ID also owns summary reconciliation,
not another award bug: `active_workout_screen.dart:75-80` captures local duration/exercises/counts
before awaiting completion at82;91-100 passes that snapshot into summary. Controller:655-677
returns authoritative `result.workout`/`result.rewards` plus local fields, and repository:70-76
hydrates detail separately after award. Summary duration/exercises can therefore describe a
pre-await local snapshot beside the awarded result. No divergent rendered summary or injected
transport outcome was executed. A5 flutter-specialist with qa-reviewer: gate pending edits/award/
detail response, assert displayed duration/exercises reconcile with committed workout and acknowledged
rewards, and distinguish pre-award failure from post-award hydration failure. The earlier A2
dependency row's DATA001 Medium/Needs Verification classification is historical; current DATA001
is Confirmed only for its conditional prior-award tuple. No confidence promotion here.

---


</details>

---

</details>

## FND-INTG-003 — Coach accepts answers that its next history request rejects

| Field | Value |
|---|---|
| ID | `FND-INTG-003` |
| Title | Coach accepts answers that its next history request rejects |
| Category | `INTG` |
| Component | Coach answer/history length contract |
| Paths | `app/lib/features/coach/data/coach_repository.dart`; `supabase/functions/ai-coach/service.ts` |
| Lines | `coach_repository.dart:98-109`; `service.ts:37-48,104-112` |
| Origin | A2 final reconciliation; Coach lead 16 |
| Root cause | Server accepts assistant answers up to 12000 characters but history entries only up to 4000; client resubmits accepted answers unchanged. |
| Evidence | Inspection only: controller selects the last eight prior messages and passes their full content; service rejects history content longer than 4000 while returning answer strings through 12000. The upstream max_tokens setting may reduce frequency but does not align the accepted contracts. |
| Expected behavior | Every accepted assistant answer remains valid input to a subsequent supported conversation request. |
| Actual behavior | An accepted answer of 4001-12000 characters is retained and resubmitted, then rejected as invalid_history on the next request (or rejected by the separate body-size cap for larger combined history). |
| Impact | Conversation cannot continue with that retained answer; failed requests preserve previous messages, so retries retain the incompatibility. No live provider response of this size was observed. |
| Severity | **P2** |
| Confidence | **High** |
| Status | `Accepted` |
| Proposed remediation | Align accepted answer and history limits or apply an explicitly defined history compaction policy before resubmission. |
| Regression risk | Multi-turn conversation, multilingual/long answers, eight-message truncation, request body-size limits and typed errors. |
| Related tests | `app/test/session_isolation_test.dart` |
| Missing tests | Accept a synthetic 4001-character answer then send another message with short remaining history; validate continuation without invalid_history. |
| Depends on | A5 Flutter/Edge contract fixtures; no live AI provider or credentials required. |
| Wave | W2 |
| Verification method | A5 `flutter-specialist` with Edge support: fixture a 4001-character successful answer and inspect the next payload against service validation. NOT RUN; static-only, not Confirmed. |

---

## FND-INTG-004 — Timed Add Set method uses hidden positive reps and zero duration

| Field | Value |
|---|---|
| ID | FND-INTG-004 |
| Title | Timed Add Set method uses hidden positive reps and zero duration |
| Category | INTG |
| Component | Timed workout set UI/controller contract |
| Paths | app/lib/features/workout/presentation/screens/active_workout_screen.dart; app/lib/features/workout/presentation/widgets/workout_exercise_tile.dart; app/lib/features/workout/presentation/widgets/set_row_widget.dart; app/lib/features/workout/presentation/controllers/active_workout_controller.dart |
| Lines | active_workout_screen.dart:531,542-550; workout_exercise_tile.dart:60-61,269-294; set_row_widget.dart:180-207,219-222; active_workout_controller.dart:298-318,436-450,474-479 |
| Origin | A2 timed Add Set inspection; A4 distinct SQL finding preserved; A5 actual Dart method/payload observations and QA |
| Root cause | Add Set omits modality-specific defaults and calls controller defaults reps=10/duration=0; timed row hides reps while completion validation accepts either positive reps or duration. |
| Evidence | A5 Flutter G6 actual Dart controller/repository Add Set method used by active-screen531 creates timed set4 with reps10/duration0; marking complete is accepted by the actual client guard and recording transport. Initial timed0/30 and normal rep10/0 controls are distinct. This is a direct method invocation, not an actual UI tap/render or SQL completion. qa-reviewer ses_e7cb5a850ffeEKOCUhDgig3neH independently read product source/full retained probes and supports these bounded claims; no independent runtime rerun claimed. Extra QA source Git command BLOCKED, not retried or bypassed. |
| Expected behavior | Added timed sets follow the duration-based contract; completing a visible zero-duration timed set must not rely on hidden reps. |
| Actual behavior | The actual Add Set method sends hidden reps10 with duration0 for a timed-classified exercise, and client completion marking accepts it. Timed row visibility is source-inspected; no rendered Add Set interaction or server award is claimed. |
| Impact | P2 confirmed Dart default/validation mismatch for added timed sets; potentially misleading visible measurement is source-backed, not a confirmed full UI journey or backend validation/award bypass. |
| Severity | **P2** |
| Confidence | **Confirmed** |
| Status | `Accepted` |
| Proposed remediation | Owner flutter-specialist with exercise-catalog and qa-reviewer: after approval initialize additional sets by supported modality and validate against that measurement contract; retain normal rep defaults and do not bypass INTG005 final validation. |
| Regression risk | Initial versus additional timed/rep sets, zero duration, completed edits, visible fields, restoration and mixed exercise sessions. |
| Related tests | app/test/workout_controller_test.dart; app/test/workout_widgets_test.dart; docs/audit/phases/A5_FLUTTER_EVIDENCE.md G6/AddSet |
| Missing tests | After fix approval: actual rendered training Add Set tap and complete callback use modality-consistent visible defaults; zero visible timed duration cannot pass solely via hidden reps, with rep controls.; Approved isolated backend: verify agreed timed completion contract with INTG005; do not infer it from client completion marking. |
| Depends on | INTG005 retains separate A4 SQL0-rep timed completion rejection; INTG007 owns initial generated-prescription/default mismatch. Neither is newly proved by this direct Add Set method. |
| Wave | W2 |
| Verification method | Retained docs/audit/phases/A5_FLUTTER_EVIDENCE.md G6 source602-635/output697-702: actual method and request payload plus client mark-complete observed,18-test run exit0. No UI tap/render or live SQL/E2E in this promotion; QA inspected full source. |

**A5 review:** product baseline `1763ab55e8da994bc1d854ad8fd2cd2299678b45`; UI evidence/documentation entry `614ee7cb6f99846b00fd71eec43637cb296268be`; qa-reviewer ses_e7cb5a850ffeEKOCUhDgig3neH independently read product source/full retained probes and supports these bounded claims; no independent runtime rerun claimed. Extra QA source Git command BLOCKED, not retried or bypassed. No runtime rerun in this documentation turn.

<details>
<summary>Historical pre-A5 record — superseded current wording/classification, not an additional A5 claim</summary>

#### Archived FND-INTG-004 — Adding a timed set defaults to hidden reps and zero displayed duration

| Field | Value |
|---|---|
| ID | `FND-INTG-004` |
| Title | Adding a timed set defaults to hidden reps and zero displayed duration |
| Category | `INTG` |
| Component | Timed workout set UI/controller contract |
| Paths | `app/lib/features/workout/presentation/screens/active_workout_screen.dart`; `app/lib/features/workout/presentation/widgets/workout_exercise_tile.dart`; `app/lib/features/workout/presentation/widgets/set_row_widget.dart`; `app/lib/features/workout/presentation/controllers/active_workout_controller.dart` |
| Lines | `active_workout_screen.dart:531,542-550`; `workout_exercise_tile.dart:60-61,269-294`; `set_row_widget.dart:180-207,219-222`; `active_workout_controller.dart:298-318,436-450,474-479` |
| Origin | A2 final reconciliation; timed-set lead 18, client-only registered scope |
| Root cause | Add Set omits modality-specific defaults and calls controller defaults reps=10/duration=0; timed row hides reps while completion validation accepts either positive reps or duration. |
| Evidence | Inspection only: initial timed exercise sets use reps=0/duration=30, but training Add Set passes only exercise ID. Timed row renders duration; completion passes only isCompleted, so hidden positive reps satisfy the client guard with visible zero seconds. |
| Expected behavior | Added timed sets follow the duration-based contract; completing a visible zero-duration timed set must not rely on hidden reps. |
| Actual behavior | Added timed set shows zero seconds, carries hidden reps=10, and passes the client's positive-reps-or-duration completion guard. Persistence and final server completion were not executed. |
| Impact | Misleading timed measurements and client completion state; no confirmed backend award or validation bypass is asserted. |
| Severity | **P2** |
| Confidence | **High** |
| Status | `Accepted` |
| Proposed remediation | Initialize additional sets using exercise modality and validate completion against the visible measurement type; retain normal rep-based behavior. |
| Regression risk | Initial/additional timed sets, rep-based sets, zero duration, completed-set edits and restoration. |
| Related tests | `app/test/workout_controller_test.dart`; `app/test/workout_widgets_test.dart` |
| Missing tests | Add a timed set through the actual training callback, assert reps/duration defaults, and reject zero visible duration without hidden-rep completion. |
| Depends on | DEFERRED A4, owner supabase-specialist: inspect/test the distinct SQL duration-versus-reps mismatch at `supabase/migrations/20261026000200_authoritative_progression.sql:238` against `20261027000100_exercise_catalog_metadata.sql:362-366`; assert reps=0/duration>0 valid timed completion is consistently handled. Not part of Confirmed backend evidence. |
| Wave | W2 |
| Verification method | A5 `flutter-specialist`: exercise timed Add Set and complete callbacks using a recording fake repository; compare with rep-based controls. NOT RUN; client source inspection only, SQL hypothesis deferred to A4. |

**A4 review — classification unchanged P2/High/Accepted.** Actual Flutter Add Set/complete callbacks
were not executed. The former A4 SQL dependency above is now resolved separately as INTG005:
`phases/A4_SQL_EVIDENCE.md` group3 accepts persisted0reps/30sec and then rejects final completion
22023 without award/state change. That distinct backend contradiction does not confirm the
hidden-positive-rep/zero-visible-duration client mechanism. INTG007 owns generated timed quest
prescription/default compatibility with High-only integration confidence. A5 flutter-specialist
with qa-reviewer must execute the actual callbacks, assert modality-consistent visible defaults/
completion and retain rep controls. Do not duplicate backend or quest findings here.

## Historical A3 addenda to existing IDs — no classification changes at A3

- **FND-DATA-001:** progression.sql:223-230 locks owned workout before ledger/flag checks. Current
  synthetic A/B foreign completion fails42501, no reward rows created. QA correction: existing
  progression regression already exercises completed-unrewarded recovery and true-flag denial of
  another award; it does not reproduce a previously awarded false-flag/no-ledger cohort. Production
  cohort unknown. P1/Medium/Needs Verification retained; A4 supabase-specialist with qa-reviewer owns
  authoritative legacy reward/arithmetic/replay verification. No duplicate finding.
- **FND-ARCH-001:** effective function inspection confirms auth.uid-scoped initialization/daily
  maintenance/class recomputation; not another confirmed reward bypass. A4 owns fourth-writer and
  semantic verification before editorial remediation. Classification unchanged.
- **FND-SEC-002:** A3_SQL_EVIDENCE fresh-tip real SET ROLE fixtures hide foreign workout/set reads;
  reject foreign begin/pause/cancel/complete/child insert and parent reassignment; hidden-row UPDATE
  affects zero rows, original A data unchanged. This is separate backend evidence, not a repair to
  local cache or proof of all-table/deployed isolation. Existing Confirmed scope remains synthetic
  controller adoption; no server IDOR added. Conditional PUBLIC ACL risk is separately SEC003.

---


</details>

---

## FND-SEC-003 — Pre-existing PUBLIC progression-column grants survive named-role hardening

| Field | Value |
|---|---|
| ID | FND-SEC-003 |
| Category | SEC |
| Component | Legacy database adoption ACL boundary for public.users |
| Paths | supabase/migrations/20261029000100_effective_progression_acl.sql; tools/db-tests/effective-acl-regression.mjs; tools/db-tests/run.mjs |
| Severity | **P2** |
| Confidence | **Confirmed** |
| Status | `Fixed` |
| Root cause | Historical named-role-only revocation left pre-existing PUBLIC progression column grants effective. R0-03 additive migration now repairs protected PUBLIC/named table and column ACLs, restores only canonical safe edits and transactionally rejects incompatible inherited authority without weakening RLS or revoking platform roles broadly. |
| Evidence | Real RED actual authenticated own-XP UPDATE unexpectedly succeeded for injected legacy PUBLIC grant after fresh/named controls passed, exit1. First repair attempt removed safe column grants, retained FAIL; canonical safe-edit regrants corrected it. Final focused node tools/db-tests/effective-acl-regression.mjs ->10 isolated PGlite DBs/365 assertions, exit0, including inherited owner/superuser follow-up. Parent independent node tools/db-tests/run.mjs ->11 SQL units plus ACL10DB/365 assertions, exit0. Independent QA source inspection found no material blocker; QA runtime not executed. Historical A3/A5 evidence is retained in historical_pre_a7. |
| Actual behavior | Fixed in repository scope: fresh/legacy PUBLIC/named/default-materialized ACL controls deny protected own-XP writes while safe profile/notes edits, two-user isolation, anon controls, service grants and authoritative completion/retry survive. Inherited protected-column, NOINHERIT SET-role, owner, superuser and RLS-bypass cases reject adoption and roll back table/column/PUBLIC ACL changes; replay succeeds. |
| Impact | Conditional adoption defect corrected in the repository and tested only with disposable PGlite databases. Migration has not been applied to any deployed database; effective deployed ACLs and prevalence remain unknown. No guarantee against arbitrary future administrator grants. |
| Proposed remediation | Implemented R0-03 under D-025/D-027 as a new additive migration with forward-correction rollback guidance and permanent runner integration. Before any separately authorized deployment, inventory effective deployed ACL/role provenance; incompatible inherited authority must fail closed, never restore progression grants. |
| Owner / task | supabase-specialist; R0-03; independent qa-reviewer source inspection |
| Missing tests | Authorized effective deployed ACL inventory/adoption including inherited roles before release NOT RUN; no remote database/deploy authorized |
| Wave | W1 (historical roadmap label; A7 B0 approved scope) |

**A7 review:** Migration applied only to disposable PGlite, never deployed; repository-scoped Fixed
does not certify deployed ACLs. Owner/superuser cases and transaction rollback pass. Full prior
object in JSON `historical_pre_a7`; this docs turn reruns no SQL suite.

<details>
<summary>Historical pre-A7 record — superseded wording/status, not a current unfixed claim</summary>

| Field | Value |
|---|---|
| ID | `FND-SEC-003` |
| Title | Pre-existing PUBLIC progression-column grants survive named-role hardening |
| Category | `SEC` |
| Component | Legacy database adoption ACL boundary for public.users |
| Paths | `supabase/migrations/20261026000200_authoritative_progression.sql`; `docs/audit/phases/A3_SQL_EVIDENCE.md` |
| Lines | progression:59-79; retained source and all three variant outputs in evidence document |
| Origin | A3 supabase-specialist, challenged by qa-reviewer, current synthetic PGlite tests and orchestrator rerun |
| Root cause | Revocation targets anon/authenticated, not PUBLIC. Prior PUBLIC UPDATE(total_xp) survives and own_users_edit permits own-row update. Named-role column-grant survival was DISPROVED; excluded from finding. |
| Evidence | Exact187-line probe in A3_SQL_EVIDENCE. Original default FAIL/exit1 after fresh boundaries passed: authenticated column grant removed (false!==true). Diagnostic named-column denial PASS/exit0. PUBLIC variant PASS/exit0, 2 DBs/14 assertions: injected pre-existing PUBLIC column grant permits own total_xp=777; foreign user remains hidden. PUBLIC SELECT inheritance does not bypass RLS (anon sees0). Orchestrator independently reran both explicit variants, exits0. Confirmed synthetic condition only, deployed ACL unknown. |
| Expected behavior | Adoption removes effective unauthorized progression writes from supported privilege sources or rejects incompatible legacy ACL state before traffic. |
| Actual behavior | Synthetic PUBLIC column grant persists and permits own-row progression UPDATE. Fresh and named-role controls deny. No cross-user or anonymous RLS bypass reproduced. |
| Impact | Conditional migration-adoption progression-authority violation; P2 with unknown deployed prevalence, not unconditional fresh-install or production vulnerability. |
| Severity | **P2** |
| Confidence | **Confirmed** |
| Status | `Accepted` |
| Proposed remediation | Separately approve effective table/column/PUBLIC/inherited-role ACL reconciliation and fail-closed adoption checks, preserving intended platform/profile/notes grants. No audit migration patch. |
| Regression risk | Legacy roles/default grants, profile/notes edits, catalog reads and platform integrations; blanket revocation can break legitimate roles. |
| Related tests | `supabase/tests/security_regression.sql`; `docs/audit/phases/A3_SQL_EVIDENCE.md` |
| Missing tests | Permanent PUBLIC ACL adoption regression with fresh/named-role controls; separately authorized deployed effective ACL inventory (NOT RUN). |
| Depends on | Deployed PUBLIC condition unknown; no live access authorized; distinct from DATA001 legacy reward-state ambiguity. |
| Wave | W1 |
| Verification method | supabase-specialist with qa-reviewer: retained default intentionally FAIL; --named-column-control denial PASS; --remaining-public-cases conditional reproduction PASS. After approved remediation invert PUBLIC own-write assertion and keep allowed-field controls. Production inventory requires separate authorization. |

---

</details>

## FND-SEC-004 — Authenticated Edge handlers fully buffer counted request and provider bodies before checks

| Field | Value |
|---|---|
| ID | FND-SEC-004 |
| Category | SEC |
| Component | Authenticated Edge request and provider-response resource boundary |
| Paths | supabase/functions/_shared/http.ts; supabase/functions/ai-coach/service.ts; supabase/functions/_shared/bounded_body.ts; supabase/functions/tests/bounded_body_test.ts |
| Severity | **P2** |
| Confidence | **Confirmed** |
| Status | `Fixed` |
| Root cause | Historical req.text()/upstream.json() fully buffered bodies before UTF-16/answer checks. R0-04 replaces those reads with actual streamed UTF-8 byte counting before decoding/retaining an oversize chunk, cancellation on overflow/non-ok provider and reader-lock cleanup. |
| Evidence | Real RED against existing handlers/services, not a missing-helper import:4 passed/17 failed, exit1; multibyte caller overflow returned200 instead of413, oversized provider padding was accepted and cancellation missing. GREEN focused29 tests and parent independent full Edge44 tests plus six handler checks all exit0, cached-only/deny-net with synthetic auth/provider. Caps RPC16384/Coach20000/provider262144 bytes; exact/over/multibyte/chunked/lying headers, zero auth consumption, VI/EN, semantic limits, quota order, sanitized errors, provider429/non-ok and lock/cancel cleanup covered. Independent QA source inspection found no material blocker; no QA runtime claim. Historical A5 evidence retained in historical_pre_a7. |
| Actual behavior | Fixed in repository scope: streamed caller overflow returns413 and provider overflow502; byte count cannot be bypassed by missing/lying Content-Length. Oversize/non-ok provider streams cancel, readers release locks, auth precedes caller reads and original semantic/quota/timeout/malformed-provider mappings remain. A stream may deliver one oversize chunk before rejection; it is not decoded or retained by the helper. |
| Impact | The reproduced local buffering/unit defect is corrected. Confirmed remains scoped to synthetic bounded-stream mechanisms, not DoS prevention, hosted memory/allocation ceilings, real network cancellation, transport behavior or deployed security. |
| Proposed remediation | Implemented R0-04/D-028 bounded_body helper and permanent behavioral regression under approved UTF-8 caps; retain semantic/auth/quota/error controls. Separately authorized hosted gateway/transport verification remains NOT RUN; no new timeout or live-provider scope. |
| Owner / task | supabase-specialist; R0-04; independent qa-reviewer source inspection |
| Wave | W2 (historical provenance only; correction explicitly authorized as A7 B0 R0-04, no W2 implementation) |

**A7 review:** UTF-8 caps are RPC16384/Coach20000/provider262144 bytes, not UTF-16 units.
Full pre-A7 JSON object retains nested A5 history. No DoS/network cancellation or hosted-allocation
proof, provider traffic or deployment; this docs turn reruns no Edge suite.

<details>
<summary>Historical pre-A7 record — superseded wording/status; nested A5 history remains historical</summary>

| Field | Value |
|---|---|
| ID | FND-SEC-004 |
| Title | Authenticated Edge handlers fully buffer counted request and provider bodies before checks |
| Category | SEC |
| Component | Authenticated Edge request and provider-response resource boundary |
| Paths | supabase/functions/_shared/http.ts; supabase/functions/ai-coach/service.ts |
| Lines | http.ts:33-40; service.ts:35-48,66-80,104-106 |
| Origin | A3 bounded Edge review by supabase-specialist, independent qa-reviewer and orchestrator source inspection |
| Root cause | Both paths await req.text() before rejecting excessive JS-string length. Limits are 16384/20000 UTF-16 units, not streaming byte ceilings. Coach quota follows buffering; provider JSON is also fully parsed before answer-length validation. |
| Evidence | A5 backend G3 actual rpcHandler/handleCoachRequest Request streams:32768 bytes consumed before413 with no Content-Length or truthful header; under-limit controls200. Multibyte30029 UTF-8 bytes/10029 UTF-16 units accepted200 by both. Missing/rejected auth401 consumes0 bytes. Injected actual provider Response77053 bytes fully consumed before502 for13000-unit answer;64055-byte padding with short answer accepted200. Stream cancel callbacks0; non-ok provider502 consumes0.12 request+3 provider cases exit0, cached-only/deny-net with synthetic auth/fetch, max fixture256KiB. qa-reviewer ses_e7cb5a850ffeEKOCUhDgig3neH independently read product source/full retained probes and supports these bounded claims; no independent runtime rerun claimed. Extra QA source Git command BLOCKED, not retried or bypassed. |
| Expected behavior | If these limits are intended as resource protection, reject/cancel oversized bodies before full materialization with defined byte semantics and a bounded upstream response policy. |
| Actual behavior | Bounded counted request bodies are fully materialized before application string-length rejection; larger multibyte byte counts pass unit limits, and provider JSON is consumed before answer checking. Synthetic callback counts are not network cancellation observations. |
| Impact | Provisional P2 authenticated resource-pressure risk; Confirmed only for bounded buffering/unit mechanisms. No DoS, memory exhaustion, real transport cancellation, production allocation, gateway ceiling or latency claim; platform limits may mitigate impact. |
| Severity | **P2** |
| Confidence | **Confirmed** |
| Status | `Accepted` |
| Proposed remediation | Owner supabase-specialist with qa-reviewer: after approval define byte-based request/response budgets and bounded streaming reads/cancellation or verify platform-enforced ceilings; preserve auth-before-body, semantic validation, VI/EN and sanitized errors. |
| Regression risk | Multibyte units/bytes, missing/truthful/misleading length headers, malformed JSON, auth rejection, quota/context failure, provider body limits and abort/error mapping. |
| Related tests | supabase/functions/tests/http_handler_test.ts; supabase/functions/ai-coach/service_test.ts; docs/audit/phases/A5_BACKEND_EVIDENCE.md G3/section8 full edge.ts and logs |
| Missing tests | After approved byte-budget fix: counted streams stop/cancel at the agreed bound while under-limit/multibyte/auth-negative controls preserve semantics; provider oversized/padded response reads are bounded.; Approved isolated gateway/transport: verify actual JWT/byte ceilings, request disconnect and slow response-body timeout/cancellation; current callbacks do not prove network abort. No traffic flood or production latency test authorized. |
| Depends on | Gateway/resource impact remains unverified; distinct from INTG003 answer/history schema mismatch. No deployment or material budget decision approved. |
| Wave | W2 |
| Verification method | Retained docs/audit/phases/A5_BACKEND_EVIDENCE.md sections1/4/7/8 G3: real handler/service synthetic counted streams,12+3 cases exit0. QA read full sources; promotion confirms measured mechanisms only, P2 impact stays provisional. No runtime rerun by writer. |

**A5 review:** product baseline `1763ab55e8da994bc1d854ad8fd2cd2299678b45`; UI evidence/documentation entry `614ee7cb6f99846b00fd71eec43637cb296268be`; qa-reviewer ses_e7cb5a850ffeEKOCUhDgig3neH independently read product source/full retained probes and supports these bounded claims; no independent runtime rerun claimed. Extra QA source Git command BLOCKED, not retried or bypassed. No runtime rerun in this documentation turn.

<details>
<summary>Historical pre-A5 record — superseded current wording/classification, not an additional A5 claim</summary>

#### Archived FND-SEC-004 — Edge request-size checks occur after full authenticated body buffering

| Field | Value |
|---|---|
| ID | `FND-SEC-004` |
| Title | Edge request-size checks occur after full authenticated body buffering |
| Category | `SEC` |
| Component | Authenticated Edge request/provider-response resource boundary |
| Paths | `supabase/functions/_shared/http.ts`; `supabase/functions/ai-coach/service.ts` |
| Lines | http:33-40; service:35-48,66-80,104-106 |
| Origin | A3 bounded Supabase/Edge review, independent qa-reviewer and orchestrator source inspection |
| Root cause | req.text() fully buffers before 16384/20000 UTF-16-unit checks; not a streaming byte ceiling. Coach quota follows buffering; provider JSON parses before answer-length validation. |
| Evidence | Inspection only: both handlers authenticate first then materialize body before413. Existing15 stubbed tests pass but do not exercise streamed allocation or gateway limits. Provider json() at104 precedes answer check106. No resource exhaustion or production vulnerability reproduced. |
| Expected behavior | If intended as resource protection, reject/cancel oversized bodies before full materialization, with defined byte semantics and bounded upstream response policy. |
| Actual behavior | Limits constrain accepted parsed content, not bytes buffered before rejection. Gateway ceilings and real allocation exposure unmeasured. |
| Impact | Provisional P2 authenticated resource-pressure risk; platform ceilings may mitigate. High only for buffering order, not demonstrated DoS. |
| Severity | **P2** |
| Confidence | **High** |
| Status | `Needs Verification` |
| Proposed remediation | Separately approve byte-based input/output budgets and bounded streaming cancellation or verified platform ceilings, preserving semantic validation and sanitized errors. |
| Regression risk | Multibyte VI/EN, chunked or missing-length input, malformed JSON, authenticated rejection and provider response handling. |
| Related tests | `supabase/functions/tests/http_handler_test.ts`; `supabase/functions/ai-coach/service_test.ts` |
| Missing tests | Counted synthetic stream early cancellation, multibyte boundary, bounded provider response; approved non-production gateway limit evidence (NOT RUN). |
| Depends on | A5 transport/resource verification; distinct from INTG003 answer/history schema mismatch. |
| Wave | W2 |
| Verification method | A5 supabase-specialist with qa-reviewer: bounded synthetic streams, no traffic flood; assert stop at byte budget, sanitized errors and correct auth/quota order. Separately document gateway limits only with approved non-production access. NOT RUN in A3. |

---


</details>

---

</details>

## FND-DATA-002 — Class switching loses previously awarded synergy XP

| Field | Value |
|---|---|
| ID | `FND-DATA-002` |
| Title | Class switching loses previously awarded synergy XP |
| Category | `DATA` |
| Component | Class award history and switch_class recomputation |
| Paths | `supabase/migrations/20261026000200_authoritative_progression.sql`; `docs/audit/phases/A4_SQL_EVIDENCE.md` |
| Lines | progression:259-265,294-303; A4_SQL_EVIDENCE group4, sections3-4 exact output/source |
| Origin | A4 Supabase source review/SQL group4; orchestrator independent rerun and qa-reviewer `ses_e7d23c0d4ffe9IA6MkbszmpEvl` |
| Root cause | Per-session class awards include synergy, but switching reconstructs global award amounts times focus only. Overwriting the equipped row removes its higher existing total; retained class_xp logs are not used when returning. |
| Evidence | A4 group4: actual B/C Chest completion earns20 global/21 C XP; secondary C->A->C restores20 while the C award log remains21 and global total20. Full probe exit0/108 assertions across8 groups; primary reports independent current rerun exit0; independent QA supports this bounded same-fixture result. No production history read. |
| Expected behavior | Switching away/back preserves previously awarded class progress including synergy without another global award. |
| Actual behavior | Synthetic C progress drops21->20 despite retained21-XP class award log; global XP unchanged. |
| Impact | P2 loss of class progress and potentially level/graduation near a threshold; Confirmed synthetic round trip, not measured deployed population or global duplication. |
| Severity | **P2** |
| Confidence | **Confirmed** |
| Status | `Accepted` |
| Proposed remediation | Separately approve historical class-credit policy and preserve reliable awarded progress including synergy rather than reconstructing solely from global XP. Distinguish previously equipped credit from new-class eligibility; use an approved additive migration if persistence changes. Switching must not award global XP. |
| Regression risk | Both slots, repeated switches, incomplete legacy class ledgers, graduation thresholds, focus changes and graduated classes. |
| Related tests | `supabase/tests/progression_regression.sql`; `docs/audit/phases/A4_SQL_EVIDENCE.md` group4 |
| Missing tests | A5 supabase-specialist with qa-reviewer: retain reproduction; after separately approved fix require C21 after C->A->C, no repeated-switch drift or global/log/reward changes; both-slot, nonsynergy, legacy and graduation controls under approved policy. |
| Depends on | Approved historical-credit policy/additive implementation if required; ARCH001 is rejected wording rationale, not this derived-state defect. |
| Wave | W1 |
| Verification method | Retained A4 group4 full source/command/output reproduces21->20, exit0; primary independently reran108 assertions. Owner supabase-specialist, independent qa-reviewer. No runtime rerun in this register-write turn; A5 adds policy/slot controls without assuming deployment prevalence. |

---

## FND-INTG-005 — Final completion rejects CHECK-valid zero-rep timed sets

| Field | Value |
|---|---|
| ID | `FND-INTG-005` |
| Title | Final completion rejects CHECK-valid zero-rep timed sets |
| Category | `INTG` |
| Component | Workout duration persistence versus authoritative completion validation |
| Paths | `supabase/migrations/20261027000100_exercise_catalog_metadata.sql`; `supabase/migrations/20261026000200_authoritative_progression.sql`; `app/lib/features/workout/domain/workout_set.dart`; `app/lib/features/workout/data/supabase_workout_repository.dart`; `docs/audit/phases/A4_SQL_EVIDENCE.md` |
| Lines | catalog migration:359-367; progression:235-238; workout_set:23,30; repository:136-185,189-208; A4_SQL_EVIDENCE group3, sections3-4 exact output/source |
| Origin | A4 Supabase/Flutter/catalog review and SQL group3; primary independent rerun and qa-reviewer `ses_e7d23c0d4ffe9IA6MkbszmpEvl` |
| Root cause | Final CHECK/client model accept completed positive-duration/zero-rep sets, but complete_workout rejects reps<1 without considering duration_seconds. |
| Evidence | Group3 authenticated Plank0reps/30sec persists, then RPC rejects22023 Invalid workout measurements. Eleven-table snapshot is unchanged, credit/log/reward0. Changing only reps to1 permits5 XP. Full probe exit0/108 assertions; primary reports independent rerun exit0; QA supports this SQL scope, not actual Flutter callback execution. |
| Expected behavior | Approved model/CHECK and final timed completion use a consistent measurement rule without hidden positive reps. |
| Actual behavior | CHECK-valid0reps/30sec blocks final completion without awarding; positive-rep control succeeds. Any such completed set causes entire-workout rejection. |
| Impact | P2 timed completion failure and accepted-but-unfinishable data; no partial award, production cohort or hidden-rep client bypass established. |
| Severity | **P2** |
| Confidence | **Confirmed** |
| Status | `Accepted` |
| Proposed remediation | After approval define per-mode measurement/award rules and align RPC validation through an additive migration/function replacement. Preserve invalid0/0 rejection, catalog validation, atomicity and sole-award boundary; do not hide a schema/RPC mismatch in presentation. |
| Regression risk | Timed/rep/mixed workouts, duration bounds, pace clamp, PR/quest semantics, retries and immutable history. |
| Related tests | `tools/db-tests/run.mjs:64-100`; `supabase/tests/progression_regression.sql`; A4_SQL_EVIDENCE group3 |
| Missing tests | A5 supabase-specialist/qa-reviewer: retain0/30 failure and rep control; after approved fix require consistent timed completion/one retry reward. A5 flutter-specialist: actual timed default/save/finish transport fixture, mixed-mode and invalid0/0 controls; NOT RUN. |
| Depends on | Approved timed award/validation contract; INTG004 is hidden-positive-rep/zero-visible-duration Add Set behavior, INTG007 is quest prescription compatibility. |
| Wave | W1 |
| Verification method | Retained group3 actual SQL insert/RPC22023/no-change snapshot and5-XP rep control, exit0. Owner supabase-specialist with independent qa-reviewer. A5 real Flutter/transport journey and complete timed award policy remain NOT RUN. |

---

## FND-INTG-006 — Full Body category does not match full_body class focus

| Field | Value |
|---|---|
| ID | `FND-INTG-006` |
| Title | Full Body category does not match full_body class focus |
| Category | `INTG` |
| Component | Seeded category keys versus class-focus award matching |
| Paths | `supabase/seed_exercises.sql`; `supabase/migrations/20261026000200_authoritative_progression.sql`; `docs/audit/phases/A4_SQL_EVIDENCE.md` |
| Lines | seed_exercises:1305-1306,1315,1324,1333,1342,1351; progression:42,45-46,235-236,261,298; A4_SQL_EVIDENCE group5, sections3-4 exact output/source |
| Origin | A4 exercise-catalog key review, Supabase source/SQL group5, primary rerun and independent qa-reviewer `ses_e7d23c0d4ffe9IA6MkbszmpEvl` |
| Root cause | Lowercasing Full Body yields full body, not configured full_body in A/D/E focus arrays; award and reconstruction paths use incompatible keys without space/underscore normalization. |
| Evidence | Group5 three independent single-class A/D/E fixtures: seeded Burpee20 global XP gives8 class XP each; same-day matched Jumping Jack(A/D)/Crunch(E) controls give20 global/20 class XP. Focus contains full_body, no pair synergy or quest confound. Probe exit0/108 assertions; primary independent rerun reported exit0, QA supports bounded evidence. |
| Expected behavior | Configured Full Body focus matches catalog Full Body exercises and applies the intended focus-match factor. |
| Actual behavior | Equal20-global-XP sessions credit A/D/E8 versus matched-control20; class reconstruction uses the same incompatible strings. |
| Impact | P2 configured-focus and derived-class under-credit; Confirmed seeded-key defect, no deployed population, historical repair total or global award change claimed. |
| Severity | **P2** |
| Confidence | **Confirmed** |
| Status | `Accepted` |
| Proposed remediation | Separately approve a canonical category/focus mapping in award and reconstruction, preserving exercise UUIDs/curated metadata. Historical-credit correction needs an approved additive reconciliation plan, not a seed rename or speculative credit update. |
| Regression risk | All focus keys, A/D/E/nonfocus classes, global/class XP separation, switching, legacy category strings and stable exercise references. |
| Related tests | `supabase/tests/progression_regression.sql`; A4_SQL_EVIDENCE group5 |
| Missing tests | A5 exercise-catalog/supabase-specialist with qa-reviewer: all-seed key canonicalization/stable UUIDs; after approved fix Full Body and matched controls receive intended factors while nonfocus and switch-history controls remain correct. |
| Depends on | Approved canonical-key/historical-reconciliation policy; DATA002 separately owns synergy loss. |
| Wave | W2 |
| Verification method | Group5 resolves real seed IDs, executes RPCs and observes8-versus20 at equal20 global XP, exit0. Owner supabase-specialist with exercise-catalog and qa-reviewer; A5 expands canonical-key controls when authorized. No seed/product changes in A4. |

---

## FND-INTG-007 — Generated quest JSON initializes timed Dart sets as zero reps against rep targets

| Field | Value |
|---|---|
| ID | FND-INTG-007 |
| Title | Generated quest JSON initializes timed Dart sets as zero reps against rep targets |
| Category | INTG |
| Component | Actual generated prescription JSON versus Dart initialization/payload contract |
| Paths | supabase/migrations/20261026000200_authoritative_progression.sql; app/lib/features/workout/presentation/controllers/active_workout_controller.dart; supabase/seed_exercises.sql; docs/audit/phases/A4_SQL_EVIDENCE.md; docs/audit/phases/A5_FLUTTER_EVIDENCE.md |
| Lines | authoritative_progression.sql:205-212,238,245-251; active_workout_controller.dart:298-317; seed_exercises.sql:1220-1221; docs/audit/phases/A5_FLUTTER_EVIDENCE.md:G6; source602-635/output697-702; A4_SQL_EVIDENCE.md:group6 (historical separate SQL evidence) |
| Origin | A4 generated-quest contract/JS-mirror history; A5 actual seed-generated JSON -> real Dart model/controller/repository and independent QA |
| Root cause | Actual sync_daily_data emits rep prescriptions for selected exercises, while real Dart initialization forces timed-classified targets to0reps/30sec despite prescribed12; there is no duration-prescription field in that Dart target model. |
| Evidence | A5 fresh seeded catalog150 and actual sync_daily_data, deterministically selecting full_body in disposable fixture, emit Ab Wheel Rollout(carry), Arnold Press, Back Extension3x12 with real existing catalog IDs. QuestInstance.fromJson/startQuest execute in Dart; actual timed INSERTs are3x(reps0,duration30), other targets3x12. Former mirrored-Dart gap is closed for this initialization/payload mechanism. All9 can be client-marked complete. Local qualifier count0 versus required12 is only a local predicate, NOT a SQL result. The22023 completion rejection and positive-rep success response are explicit fake transport controls, NOT live SQL/E2E. A4 SQL group6 remains separate retained history. qa-reviewer ses_e7cb5a850ffeEKOCUhDgig3neH independently read product source/full retained probes and supports these bounded claims; no independent runtime rerun claimed. Extra QA source Git command BLOCKED, not retried or bypassed. |
| Expected behavior | Generated prescription JSON and Dart initialization/payloads honor one approved measurement contract per supported exercise; final server eligibility must be verified separately. |
| Actual behavior | Actual generated12-rep target decodes/initializes into actual Dart timed0/30 requests. This confirmed mismatch does not establish independently reached SQL quest eligibility or a rendered end-to-end quest failure. |
| Impact | P2 confirmed generated-JSON/Dart-default incompatibility in the bounded seeded fixture. No full UI/SQL quest journey, live award result or exercise-science validation of seed carry classification is claimed. |
| Severity | **P2** |
| Confidence | **Confirmed** |
| Status | `Accepted` |
| Proposed remediation | Owner flutter-specialist with supabase-specialist, exercise-catalog and qa-reviewer: after approval define mode-aware generation/defaults/matching together or explicitly exclude unsupported modes; preserve stable exercise IDs and complete_workout award ownership, coordinating INTG005 rather than weakening validation. |
| Regression risk | Quest rotation/catalog selection, timed/rep/mixed targets, target decoding, load/duration, Add Set versus initial sets, expiry, restoration and transactional retry awards. |
| Related tests | supabase/tests/security_regression.sql:92-111; app/test/workout_controller_test.dart; docs/audit/phases/A4_SQL_EVIDENCE.md group6; docs/audit/phases/A5_FLUTTER_EVIDENCE.md G6/extractor |
| Missing tests | After approved measurement contract/fix: render actual generated targets and assert mode-compatible Dart initial/save payloads with non-timed controls; preserve existing IDs.; Approved isolated SQL/gateway: exercise same actual Dart payloads through completion/quest matching, assert agreed eligibility and exactly one retry award without bypassing INTG005.; Catalog owner separately validates supported modality; seed carry classification alone is not exercise-science evidence. |
| Depends on | INTG005 currently rejects completed0-rep timed sets; INTG004 is additional-set hidden reps, not initial prescription. Actual-Dart initialization gap closed, full SQL/gateway eligibility remains deferred. |
| Wave | W2 |
| Verification method | Retained docs/audit/phases/A5_FLUTTER_EVIDENCE.md G6 executes actual seeded generator JSON then real Dart model/controller/repository,18-test run exit0. Local qualifier and fake22023 are explicitly not SQL results; A4 SQL evidence stays separate. QA supports only narrowed Confirmed initialization/payload claim. |

**A5 review:** product baseline `1763ab55e8da994bc1d854ad8fd2cd2299678b45`; UI evidence/documentation entry `614ee7cb6f99846b00fd71eec43637cb296268be`; qa-reviewer ses_e7cb5a850ffeEKOCUhDgig3neH independently read product source/full retained probes and supports these bounded claims; no independent runtime rerun claimed. Extra QA source Git command BLOCKED, not retried or bypassed. No runtime rerun in this documentation turn.

<details>
<summary>Historical pre-A5 record — superseded current wording/classification, not an additional A5 claim</summary>

#### Archived FND-INTG-007 — Generated timed quest rep targets conflict with client timed defaults

| Field | Value |
|---|---|
| ID | `FND-INTG-007` |
| Title | Generated timed quest rep targets conflict with client timed defaults |
| Category | `INTG` |
| Component | Daily quest prescription versus timed initialization and matching |
| Paths | `supabase/migrations/20261026000200_authoritative_progression.sql`; `app/lib/features/workout/presentation/controllers/active_workout_controller.dart`; `supabase/seed_exercises.sql`; `docs/audit/phases/A4_SQL_EVIDENCE.md` |
| Lines | progression:205-212,238,245-251; controller:298-317; seed_exercises:1220-1221; A4_SQL_EVIDENCE group6, sections3-4 exact output/source |
| Origin | A4 catalog/Flutter/Supabase contract review/SQL group6; independent qa-reviewer `ses_e7d23c0d4ffe9IA6MkbszmpEvl` requires High-only integration scope |
| Root cause | sync_daily_data prescribes3x12 reps for every selected exercise; matching counts reps. Client forces timed-classified initial sets to0reps/30sec even with rep prescription, and generated config has no duration target. |
| Evidence | Group6 fixture restricts only other seeded quest template types to select full_body deterministically; catalog metadata/RPCs unchanged. Actual generator produces carry-classified Ab Wheel Rollout3x12; source-guarded JS mirror persists timed0/30 and SQL matching gives0/3, other targets3/3. Completion rejects earlier22023 under INTG005. Positive-rep SQL control earns450 quest XP. Probe exit0, primary independent108-assertion rerun reported exit0. Dart/UI and full quest journey did not execute. |
| Expected behavior | Generated prescriptions, initialization and matching use compatible per-exercise measurements, or unsupported timed targets are explicitly excluded. |
| Actual behavior | Actual rep target and mirrored timed defaults disagree with0/3 matching sets. Earlier completion validation prevents independently reached end-to-end quest eligibility; a failed Dart quest journey is not established. |
| Impact | P2 likely incompatible generated timed quest experience/misleading targets. High for the cross-layer contract with bounded SQL evidence, not Confirmed UI failure or independently validated exercise-science classification. |
| Severity | **P2** |
| Confidence | **High** |
| Status | `Needs Verification` |
| Proposed remediation | After approval and real integration verification define mode-aware quest targets/defaults/matching together, or exclude unsupported modes explicitly. Coordinate with INTG005; do not weaken final validation or hide reps. Preserve catalog IDs and transactional award ownership. |
| Regression risk | Quest rotation/catalog selection, timed/rep/mixed prescriptions, duration/load targets, expiry, restoration and quest reward replacement. |
| Related tests | `supabase/tests/security_regression.sql:92-111`; `app/test/workout_controller_test.dart`; A4_SQL_EVIDENCE group6 |
| Missing tests | A5 flutter-specialist/Supabase with independent qa-reviewer: actual generated-quest start/addExercise/save/finish with controlled transport, assert displayed/default measurement and observed eligibility with rep control. Do not bypass INTG005 to claim current eligibility; after separately approved fix test duration matching/one retry award. Catalog owner verifies supported modality separately. |
| Depends on | INTG005 rejects0-rep completion before quest matching; INTG004 is additional-set hidden reps, not initial target contract. A5 Flutter/SQL fixtures, no production/provider/new dependency required. |
| Wave | W2 |
| Verification method | Group6 proves actual SQL generation/persistence/matching counts and positive-rep quest control, not executed Dart. Owner flutter-specialist with supabase-specialist and qa-reviewer, target A5. Actual UI journey and independently reached timed eligibility remain NOT RUN; retain High/Needs Verification. |

</details>

---

## FND-BUG-008 — Stale sign-in error contaminates password recovery before submission

| Field | Value |
|---|---|
| ID | FND-BUG-008 |
| Title | Stale sign-in error contaminates password recovery before submission |
| Category | BUG |
| Component | Operation-scoped AuthController/form state |
| Paths | app/lib/features/auth/presentation/providers/auth_providers.dart; app/lib/features/auth/presentation/screens/reset_password_screen.dart; app/lib/core/router/app_router.dart |
| Lines | auth_providers.dart:65-115; reset_password_screen.dart:29,84-94; docs/audit/phases/A5_FLUTTER_EVIDENCE.md:G1; source470-510/output661-668 |
| Origin | A2 Lead10 deferred assertion; A5 actual forms/controller/router fixture and independent QA |
| Root cause | Shared AuthController AsyncError from failed sign-in remains visible to recovery screen as a password-update error without an update submission. |
| Evidence | A5 Flutter G1 real login rejects synthetic sign-in, synthetic passwordRecovery event drives actual router/reset screen; premature update error=true with updateCalls0. Pristine recovery false/updateCalls0. Actual Save password rejected-submit shows error/keeps recovery; success clears action error/recovery and leaves reset route. Retained18-test run exit0 and strengthened G1 button controls+2 exit0. qa-reviewer ses_e7cb5a850ffeEKOCUhDgig3neH independently read product source/full retained probes and supports these bounded claims; no independent runtime rerun claimed. Extra QA source Git command BLOCKED, not retried or bypassed. |
| Expected behavior | Recovery entry must not report a failed password update before that operation is submitted; preserve valid rejected/successful submit feedback. |
| Actual behavior | Synthetic failed-signin -> recovery renders Could not update your password before any update call; pristine entry and subsequent submit controls distinguish contamination. |
| Impact | P2 confirmed misleading pre-submit recovery feedback in actual Dart/router/form fixture; no live link, callback delivery, credential disclosure or backend auth defect established. |
| Severity | **P2** |
| Confidence | **Confirmed** |
| Status | `Accepted` |
| Proposed remediation | Owner flutter-specialist/Auth with qa-reviewer: after approval scope action errors by operation or reset stale sign-in state at recovery entry, preserving true update failures and successful recovery cleanup. |
| Regression risk | Failed sign-in, recovery navigation, validation, rejected/successful password update, retries and auth events. |
| Related tests | app/test/auth_controller_test.dart; app/test/ui_regression_test.dart; docs/audit/phases/A5_FLUTTER_EVIDENCE.md G1 |
| Missing tests | After fix approval: rejected sign-in then actual recovery route shows no update error before submit; pristine entry, rejected Save and successful Save controls still work.; Approved isolated Auth/callback follow-up: distinguish actual recovery URI/session transitions from synthetic events; no live Auth evidence claimed. |
| Depends on | Distinct from INTG001 callback/allowlist contract; no backend/config change approved. |
| Wave | W2 |
| Verification method | Retained docs/audit/phases/A5_FLUTTER_EVIDENCE.md G1 source/output and commands; actual widgets/router with synthetic repository/Auth event. QA read full probe; no runtime rerun in writer. |

**A5 review:** product baseline `1763ab55e8da994bc1d854ad8fd2cd2299678b45`; UI evidence/documentation entry `614ee7cb6f99846b00fd71eec43637cb296268be`; qa-reviewer ses_e7cb5a850ffeEKOCUhDgig3neH independently read product source/full retained probes and supports these bounded claims; no independent runtime rerun claimed. Extra QA source Git command BLOCKED, not retried or bypassed. No runtime rerun in this documentation turn.

---

## FND-BUG-009 — CandyButton primitive is not keyboard reachable or activatable

| Field | Value |
|---|---|
| ID | FND-BUG-009 |
| Title | CandyButton primitive is not keyboard reachable or activatable |
| Category | BUG |
| Component | Production CandyButton focus/keyboard semantics |
| Paths | app/lib/ui/candy/candy_button.dart; app/lib/core/router/persistent_active_workout_banner.dart; app/lib/features/progression/presentation/widgets/level_up_overlay.dart |
| Lines | candy_button.dart:189-207; persistent_active_workout_banner.dart:147; level_up_overlay.dart:143; docs/audit/phases/A5_UI_EVIDENCE.md:section2 keyboard fixture |
| Origin | A5 actual production CandyButton/SystemButton control fixture and independent QA |
| Root cause | CandyButton wraps pointer GestureDetector/Semantics without a Focus/Actions keyboard activation path. |
| Evidence | A5 UI fixture at614ee7c: candyFocusNodes0; Tab reaches actual SystemButton; Enter and Space increment System1 then2 while CandyKeys0; pointerCandy1. Existing production call sites are source-inspected, not route-traversed. These observations passed within UI aggregate FAIL(+8 -2 onboarding fixture failures). The disabled counter fixture is tautological (null callback); it does not establish comprehensive disabled/loading behavior. qa-reviewer ses_e7cb5a850ffeEKOCUhDgig3neH independently read product source/full retained probes and supports these bounded claims; no independent runtime rerun claimed. Extra QA source Git command BLOCKED, not retried or bypassed. |
| Expected behavior | Enabled Candy action can receive keyboard focus and activate once with Enter/Space with a visible focus state, while pointer behavior remains valid. |
| Actual behavior | Actual enabled CandyButton primitive is skipped in focus traversal and not key-activated; actual SystemButton positive control and Candy pointer activation work. |
| Impact | P2 confirmed keyboard inoperability of the tested primitive. Integrated route impact is source-backed, not executed whole-screen accessibility certification; no blanket claim about all Candy widgets. |
| Severity | **P2** |
| Confidence | **Confirmed** |
| Status | `Accepted` |
| Proposed remediation | Owner ui-ux-specialist with flutter-specialist and qa-reviewer: after approval add keyboard/focus/Actions semantics using existing design-system affordances; preserve pointer and native SystemButton behavior. |
| Regression risk | Focus order/visibility, Enter/Space single activation, pointer press state, disabled/loading/key-repeat behavior and banner/overlay call sites. |
| Related tests | app/test/navigation_integration_test.dart; app/test/ui_regression_test.dart; docs/audit/phases/A5_UI_EVIDENCE.md keyboard fixture |
| Missing tests | After fix approval: Tab reaches real CandyButton with visible focus; Enter/Space fire exactly once, pointer still fires, and enabled SystemButton remains positive control.; Authorized UI follow-up: non-tautological disabled/loading callbacks and key-repeat assertions plus banner/overlay route traversal; do not count current null-callback counter as comprehensive coverage. |
| Depends on | No new theme/dependency approved; distinct from BUG004 contrast and ARCH002 localization. |
| Wave | W2 |
| Verification method | Retained docs/audit/phases/A5_UI_EVIDENCE.md section2/full sources and logs section6; actual primitive versus actual SystemButton and pointer controls. QA supports primitive-only Confirmed; full integrated/device keyboard journey NOT RUN. |

**A5 review:** product baseline `1763ab55e8da994bc1d854ad8fd2cd2299678b45`; UI evidence/documentation entry `614ee7cb6f99846b00fd71eec43637cb296268be`; qa-reviewer ses_e7cb5a850ffeEKOCUhDgig3neH independently read product source/full retained probes and supports these bounded claims; no independent runtime rerun claimed. Extra QA source Git command BLOCKED, not retried or bypassed. No runtime rerun in this documentation turn.

---

## FND-INTG-008 — Lost add-set acknowledgement permits repeated identical insert requests

| Field | Value |
|---|---|
| ID | FND-INTG-008 |
| Title | Lost add-set acknowledgement permits repeated identical insert requests |
| Category | INTG |
| Component | Workout set retry/reconciliation transport contract |
| Paths | app/lib/features/workout/data/supabase_workout_repository.dart; app/lib/features/workout/presentation/controllers/active_workout_controller.dart; supabase/migrations/20261026000100_baseline.sql |
| Lines | repository addSet/controller addSet and retry paths; baseline.sql:210-219; docs/audit/phases/A5_FLUTTER_EVIDENCE.md:G3; source538-558/output677-682 |
| Origin | A5 actual Dart controller/repository HTTP with modeled commit/lost-response fixture; independent QA |
| Root cause | Failed acknowledgement leaves local row/number state unreconciled; retry derives set_number from that stale local state and issues another insert without an acknowledged stable row identity. |
| Evidence | G3 actual repository emits two identical INSERT payloads set_number2. Deliberately permissive fake server commits first then loses response: modeled rows1,2,2/local1,2 and distinct IDs s1,s100,s101/local s1,s101. Rejected-before-commit control rows1,2; reload-before-retry sends3 and reconciles rows1,2,3. Failed first save blocks completion/no finish RPC. SQL constraints absence inspected, not runtime duplicate proof. qa-reviewer ses_e7cb5a850ffeEKOCUhDgig3neH independently read product source/full retained probes and supports these bounded claims; no independent runtime rerun claimed. Extra QA source Git command BLOCKED, not retried or bypassed. |
| Expected behavior | A retry after uncertain write outcome reconciles the committed row or uses stable idempotent identity without duplicating a logical set; rejected-write/reload controls remain valid. |
| Actual behavior | Repeated real client requests are confirmed, but duplicate modeled server rows and local divergence depend on the synthetic commit/lost-ACK fixture; actual gateway/SQL persistence remains unverified. |
| Impact | P2 possible duplicate/missing-local set reconciliation under lost acknowledgement. High/Needs Verification because server commit/duplication is modeled; no authoritative SQL duplicate or XP inflation proved. |
| Severity | **P2** |
| Confidence | **High** |
| Status | `Needs Verification` |
| Proposed remediation | Owner flutter-specialist with supabase-specialist and qa-reviewer: after approved transport contract and isolated verification, reconcile uncertain insert outcomes using stable mutation/row identity before retry; preserve rejected-write and reload semantics. |
| Regression risk | Set numbering/IDs, concurrent edits, uncertain delivery, reload/retry, validation, completion gate and existing history. |
| Related tests | app/test/workout_controller_test.dart; docs/audit/phases/A5_FLUTTER_EVIDENCE.md G3 |
| Missing tests | Approved isolated stack: commit actual add-set insert then lose response, retry same actual client operation, assert one logical set and consistent local/server IDs/numbers.; After fix approval: pre-commit rejection and reload-before-retry controls stay correct; completion stays gated until uncertainty is reconciled. |
| Depends on | Supported isolated SQL/gateway scheduling and separately approved retry identity contract; not DATA001 legacy awards. |
| Wave | W1 |
| Verification method | Retained docs/audit/phases/A5_FLUTTER_EVIDENCE.md G3 actual HTTP payloads with explicit modeled server;18-test run exit0. QA supports High transport candidate only. Independent SQL/gateway lost-ACK assertion deferred; no live/SQL duplication claim. |

**A5 review:** product baseline `1763ab55e8da994bc1d854ad8fd2cd2299678b45`; UI evidence/documentation entry `614ee7cb6f99846b00fd71eec43637cb296268be`; qa-reviewer ses_e7cb5a850ffeEKOCUhDgig3neH independently read product source/full retained probes and supports these bounded claims; no independent runtime rerun claimed. Extra QA source Git command BLOCKED, not retried or bypassed. No runtime rerun in this documentation turn.

---

## FND-INTG-009 — Sequential exercise reorder can leave optimistic and modeled persisted orders divergent

| Field | Value |
|---|---|
| ID | FND-INTG-009 |
| Title | Sequential exercise reorder can leave optimistic and modeled persisted orders divergent |
| Category | INTG |
| Component | Exercise reorder partial-write reconciliation |
| Paths | app/lib/features/workout/data/supabase_workout_repository.dart; app/lib/features/workout/presentation/controllers/active_workout_controller.dart |
| Lines | repository reorderExercises sequential update path/controller optimistic reorder; docs/audit/phases/A5_FLUTTER_EVIDENCE.md:G4; source559-583/output683-690 |
| Origin | A5 actual Dart reorder requests with modeled partial persistence and independent QA |
| Root cause | Optimistic local reorder is followed by sequential independent row updates; later failure does not atomically restore the modeled earlier update or reconcile local ordering. |
| Evidence | G4 move e3 to0 yields optimistic e3,e1,e2. Actual first HTTP update succeeds, second400; modeled persistence e1=0/e2=1/e3=0 while local stays optimistic/save_failed. Reload fixture observes e1,e3,e2, not a guaranteed tie order. All-success control sends3 updates and reload matches intended order. Legitimate absent-row delete204 succeeds;403 retains local row/save_failed, not a bypass finding. qa-reviewer ses_e7cb5a850ffeEKOCUhDgig3neH independently read product source/full retained probes and supports these bounded claims; no independent runtime rerun claimed. Extra QA source Git command BLOCKED, not retried or bypassed. |
| Expected behavior | Failed reorder leaves a coherent acknowledged order or explicit reconciled state; partial transport failure must not silently preserve a divergent optimistic order. |
| Actual behavior | Actual sequential request/error/local-state behavior observed; partial committed server mapping is modeled. Duplicate order indices and observed reload order do not establish guaranteed production tie ordering. |
| Impact | P2 possible persistent/local order divergence and user confusion after partial write. High/Needs Verification for actual SQL/gateway partial persistence; no reward consequence or authorization bypass shown. |
| Severity | **P2** |
| Confidence | **High** |
| Status | `Needs Verification` |
| Proposed remediation | Owner flutter-specialist with supabase-specialist and qa-reviewer: after approval and isolated verification define atomic or explicit reconciliation behavior for multi-row reorder, preserving ownership guards and legitimate idempotent zero-row deletion. |
| Regression risk | Optimistic order, partial failure/reload, ties, concurrent edits, save failure feedback, ownership and absent versus forbidden deletes. |
| Related tests | app/test/workout_controller_test.dart; app/test/workout_widgets_test.dart; docs/audit/phases/A5_FLUTTER_EVIDENCE.md G4 |
| Missing tests | Approved isolated stack: commit first actual reorder update and reject next, then compare acknowledged local and persisted order; no assertion of arbitrary tie order.; After fix approval: all-success3-update control, rollback/reconcile failure control, already-absent owned delete204 and explicit forbidden403 remain distinct; RLS-hidden rows require real role controls. |
| Depends on | Supported isolated SQL/gateway partial-write scheduling and approved reorder contract; no transaction/schema fix authorized in A5. |
| Wave | W1 |
| Verification method | Retained docs/audit/phases/A5_FLUTTER_EVIDENCE.md G4 actual request sequence/controller state plus explicitly modeled persistence,18-test run exit0. QA supports High/NV only; no actual multi-request SQL transaction test or guaranteed tie ordering. |

**A5 review:** product baseline `1763ab55e8da994bc1d854ad8fd2cd2299678b45`; UI evidence/documentation entry `614ee7cb6f99846b00fd71eec43637cb296268be`; qa-reviewer ses_e7cb5a850ffeEKOCUhDgig3neH independently read product source/full retained probes and supports these bounded claims; no independent runtime rerun claimed. Extra QA source Git command BLOCKED, not retried or bypassed. No runtime rerun in this documentation turn.

---

## FND-TEST-002 — Candy specification-replica tests do not protect corresponding production primitives

| Field | Value |
|---|---|
| ID | FND-TEST-002 |
| Title | Candy specification-replica tests do not protect corresponding production primitives |
| Category | TEST |
| Component | Flutter production-component regression coverage |
| Paths | app/test/candy_ui_test.dart; app/lib/ui/candy/candy_button.dart; app/lib/ui/candy/candy_card.dart |
| Lines | candy_ui_test.dart:1-619 (imports/local definitions/expectations); docs/audit/phases/A5_FLUTTER_EVIDENCE.md:section2 test inventory; docs/audit/phases/A5_UI_EVIDENCE.md:section1 test inventory |
| Origin | A5 complete bounded Flutter test inventory and independent UI/QA inspection |
| Root cause | 619-line candy_ui_test.dart imports no production app widgets and defines local palette/TactileCandyButton/CandyCardWidget replicas, then asserts those same local implementations. |
| Evidence | Flutter and UI reviewers independently read all619 lines/imports/local definitions. Contrast, press/loading and320/1.5x assertions exercise reference fixtures, so corresponding production implementation changes are not exercised by those tests. Other test files render actual UI; this is not zero production-widget coverage. No mutation test, golden or coverage percentage was measured. qa-reviewer ses_e7cb5a850ffeEKOCUhDgig3neH independently read product source/full retained probes and supports these bounded claims; no independent runtime rerun claimed. Extra QA source Git command BLOCKED, not retried or bypassed. |
| Expected behavior | Tests presented as production Candy regressions exercise the actual corresponding app primitives; reference-specification fixtures may remain explicitly labeled. |
| Actual behavior | This file protects its own local specification/replicas, not actual CandyButton/Card implementations; real UI coverage in other files remains meaningful. |
| Impact | P3 High test-quality gap: misleading protection can let production primitive regressions escape this suite. It does not itself prove a product defect or invalidate all UI tests. |
| Severity | **P3** |
| Confidence | **High** |
| Status | `Accepted` |
| Proposed remediation | Owner flutter-specialist with ui-ux-specialist and qa-reviewer: after approval add or replace production-component regressions using actual Candy imports, retaining clearly labeled specification tests where useful. |
| Regression risk | Accidentally discarding useful specification behavior, hiding real production import differences, pointer/loading/focus/layout expectations and genuine UI tests elsewhere. |
| Related tests | app/test/candy_ui_test.dart; app/test/ui_regression_test.dart; app/test/navigation_integration_test.dart |
| Missing tests | After test-edit approval: demonstrate the corresponding test renders real CandyButton/Card and a bounded intentional production behavior change fails that regression, then restore it safely; preserve useful specification controls.; Define targeted assertions before adding a coverage/golden gate; missing golden/coverage percentage alone is not a finding. |
| Depends on | Distinct from TEST001 CI/platform/format/codegen gates; no dependency or CI policy change authorized. |
| Wave | W3 |
| Verification method | Static import/definition/assertion trace in docs/audit/phases/A5_FLUTTER_EVIDENCE.md section2 and docs/audit/phases/A5_UI_EVIDENCE.md section1, independently QA-read. High, not runtime mutation-test Confirmed; no production source/test edits in A5. |

**A5 review:** product baseline `1763ab55e8da994bc1d854ad8fd2cd2299678b45`; UI evidence/documentation entry `614ee7cb6f99846b00fd71eec43637cb296268be`; qa-reviewer ses_e7cb5a850ffeEKOCUhDgig3neH independently read product source/full retained probes and supports these bounded claims; no independent runtime rerun claimed. Extra QA source Git command BLOCKED, not retried or bypassed. No runtime rerun in this documentation turn.

---

<!-- A5_WRITER_BEGIN -->
### A5 bounded register reconciliation source (documentation generation only)

This retained deterministic writer reads the two registers at documentation entry `614ee7c` and
generates only these same two owned documents. All runtime evidence is retained phase evidence,
not a new test execution in this write turn. Entire previous objects are copied before amendment.

```javascript
const fs=require('node:fs'),cp=require('node:child_process'),assert=require('node:assert/strict');
const jp='docs/audit/FINDINGS_REGISTER.json',mp='docs/audit/MASTER_FINDINGS.md';
const entry='614ee7cb6f99846b00fd71eec43637cb296268be',product='1763ab55e8da994bc1d854ad8fd2cd2299678b45';
assert.equal(cp.execFileSync('git',['rev-parse','HEAD'],{encoding:'utf8'}).trim(),entry);
const prior=JSON.parse(cp.execFileSync('git',['show',entry+':'+jp],{encoding:'utf8'}));
const oldMD=cp.execFileSync('git',['show',entry+':'+mp],{encoding:'utf8'});
const currentMD=fs.readFileSync(mp,'utf8'),begin='<!-- A5_WRITER_BEGIN -->',end='<!-- A5_WRITER_END -->';
const source=currentMD.slice(currentMD.indexOf(begin),currentMD.lastIndexOf(end)+end.length);
const fr='docs/audit/phases/A5_FLUTTER_EVIDENCE.md',br='docs/audit/phases/A5_BACKEND_EVIDENCE.md',ur='docs/audit/phases/A5_UI_EVIDENCE.md';
const qa='qa-reviewer ses_e7cb5a850ffeEKOCUhDgig3neH independently read product source/full retained probes and supports these bounded claims; no independent runtime rerun claimed. Extra QA source Git command BLOCKED, not retried or bypassed.';
const review=(ref,scope)=>({date:'2026-10-28',product_baseline:product,documentation_entry:entry,evidence_reference:ref,confirmed_or_qualified_scope:scope,independent_qa:qa,runtime_note:'Retained A5 probe evidence, not rerun in this documentation-only writer turn.'});
const updates={
 'FND-CONC-001':{
  title:'Discard queue cycle and post-backup-await identity race disrupt active workout state',
  line_ranges:['controller:125-145,207-215,659-682,691-700','workout_screen.dart:295-322',fr+':G2; retained output669-676'],
  origin:'S3/A2 queue-cycle history retained; A5 actual-controller post-storage-await schedules and independent QA',
  root_cause:'Two distinct mechanisms share this ID: discardLocalBackup re-enqueues cancel behind its own serialized action; completion/cancel check generation before backup removal but do not re-check identity/generation after its await before clearing state.',
  evidence:'A2 retained queue-cycle probe (+7, exit0 at7eb40f1) observes active discard pending300ms with direct/no-active controls; full previous finding retained in historical_pre_a5. A5 Flutter G2, product1763ab5, retained18-test run exit0: same-identity completion succeeds; reset-only returns null/no error and remains empty because null-state failure is caught; if B starts while A backup removal waits, A completion returns A result and clears B controller state, and A cancel also clears B. No accepted queue-cycle or SEC002 snapshot-adoption repro was repeated. '+qa,
  expected_behavior:'Discard settles; an operation from identity A must not clear identity B workout state after a storage await.',
  actual_behavior:'Original bounded queue-cycle stall remains accepted. New synthetic completion and cancel schedules erase B controller state after A backup removal resolves; reset-only null-state failure is caught, not an uncaught crash.',
  impact:'P2 client recovery/state-continuity defect under the reproduced schedules. No uncaught process crash, B database mutation, real-account disclosure, irreversible DB loss or infinitely measured timeout is established.',
  proposed_remediation:'Owner flutter-specialist with qa-reviewer: after approval remove nested public re-enqueue and revalidate captured workout/identity/generation after storage awaits before state mutation; preserve same-identity, direct-cancel and no-active controls.',
  regression_risk:'Discard queue ordering, completion/cancel, local backup removal, signout/reset/new-user start and restored workout state.',
  related_tests:['app/test/workout_controller_test.dart','docs/audit/phases/A2_PROBES.md',fr+' G2'],
  missing_tests:['After fix approval: active discard settles with one repository cancel and valid direct/no-active controls.','After fix approval: gate backup removal for completion and cancel, reset A or start B before releasing; B state must survive, reset-only stays empty with no uncaught async error.'],
  depends_on:['Client-only synthetic schedule; no server/RLS/disclosure inference. Separate from SEC002 unchecked snapshot ownership.'],
  verification_method:'Retained A2 queue-cycle evidence plus A5 actual notifier/Auth-rebuild and SharedPreferences removal barrier, G2 source/output in '+fr+'. Independent QA supports distinct mechanisms; no runtime rerun here. After authorized fix invert B-erased observations while retaining controls.'
 },
 'FND-BUG-004':{
  title:'Profile identity and edit text resolve white-on-white under Candy light',
  component:'Profile light-theme readability; onboarding source-only extension',
  origin:'A2 static profile/onboarding finding; A5 actual ProfileScreen resolved-style fixtures and independent QA',
  evidence:'A5 UI results section2 at614ee7c (unchanged product baseline1763ab5): actual ProfileScreen with fake profile/class/user data at390x844/100%, Candy light, both VI/EN, resolves display-name and first edit TextField white-on-white1.0:1; ink-on-card positive control18.883060964594996:1, errors=[]. Aggregate UI command FAIL(+8 -2): two onboarding tests fail on null chip background; they do not verify chip colors or a whole onboarding journey. Onboarding white/white54 source evidence remains static. '+qa,
  expected_behavior:'Actual profile identity/edit text is readable on production light surfaces; onboarding choices require their own resolved paint verification.',
  actual_behavior:'Both localized actual profile fixtures resolve the cited identity/edit foreground/background pairs to1.0:1. Onboarding contrast extension is source-only; failed chip extraction cannot establish chip colors.',
  impact:'P2 confirmed unreadable profile identity/edit style mechanism in the bounded VI/EN fixtures; no full profile/onboarding flow, all-state contrast, device or data-integrity certification.',
  confidence:'Confirmed',
  proposed_remediation:'Owner ui-ux-specialist with flutter-specialist and qa-reviewer: after approval use existing Candy ink/charcoal tokens on light panels and preserve selected-state distinction; verify actual profile pairs and independently resolve onboarding composited paints before extending runtime claims.',
  regression_risk:'Profile view/edit, selected/disabled states, VI/EN, large text and actual onboarding foreground/background combinations.',
  related_tests:['app/test/ui_regression_test.dart',ur+' section2 Profile VI/EN results'],
  missing_tests:['After fix approval: actual profile identity/edit pairs in VI/EN at normal and200% text meet the approved contrast criterion with ink positive control.','Authorized UI follow-up: finish actual unselected/selected onboarding chip paint extraction without null/guessed background; test interaction separately. Existing two fixture tests remain FAIL.'],
  depends_on:['No palette/dependency change approved; Confirmed scope is actual Profile resolved styles only.'],
  verification_method:'Retained '+ur+' section2 and full sources/logs section6: eight cases passed within an aggregate failing run; only Profile pair/control observations support this promotion. QA read evidence; no UI rerun in writer. Onboarding full journey/chip colors NOT verified.'
 },
 'FND-INTG-002':{
  origin:'A2 completion reconciliation; A4 snapshot observation preserved; A5 real repository/client failure mapping and independent QA',
  evidence:'A5 Flutter G5 uses actual SupabaseWorkoutRepository/controller with synthetic HTTP: successful fake completion RPC followed by error or null hydration returns null/completion_failed and retains active local state. Retry hydration succeeds; modeled commitCount1/rpcAttempts2 is supplied by the fixture, not new SQL commit/idempotency proof. Success control observes hydrated duration7 versus summary local elapsed120; that field split is an observation, not a new duration defect absent approved semantics. '+qa,
  actual_behavior:'Actual client reports completion_failed/null and retains local active session after the fixture acknowledges completion then fails/nulls detail hydration; successful-hydration/retry controls consume the supplied response.',
  impact:'P2 confirmed client acknowledgement/hydration error conflation under synthetic transport; no newly proven SQL commit, duplicate award, corruption or duration/XP defect.',
  confidence:'Confirmed',
  proposed_remediation:'Owner flutter-specialist with supabase-specialist and qa-reviewer: after approval separate acknowledged completion from subsequent detail hydration, preserve reward acknowledgement/workout ID and expose recoverable reconciliation rather than unqualified submission failure.',
  regression_risk:'Pre-award transport rejection, post-ack hydration error/null, replay/retry, pending edits, summary policy and auth reset.',
  related_tests:['app/test/workout_controller_test.dart',fr+' G5'],
  missing_tests:['After fix approval: fake RPC acknowledgement followed by hydration error/null preserves acknowledgement and a recoverable reconciliation state; compare pre-RPC failure and successful hydration controls.','Approved isolated SQL/gateway: independently verify commit/replay plus lost hydration, exactly one award and coherent local recovery. Confirm summary duration policy before asserting120-versus7 is wrong.'],
  depends_on:['DATA001 is separately P1/Confirmed/Accepted only for its conditional historical tuple; authoritative SQL retry/idempotency is not established by this fake commit fixture.'],
  verification_method:'Retained actual client/repository HTTP G5 source/output, '+fr+':140-149,584-601,691-696;18-test observation run exit0. QA supports narrow client promotion; writer did not rerun runtime tests or establish a new SQL commit.'
 },
 'FND-INTG-004':{
  title:'Timed Add Set method uses hidden positive reps and zero duration',
  origin:'A2 timed Add Set inspection; A4 distinct SQL finding preserved; A5 actual Dart method/payload observations and QA',
  evidence:'A5 Flutter G6 actual Dart controller/repository Add Set method used by active-screen531 creates timed set4 with reps10/duration0; marking complete is accepted by the actual client guard and recording transport. Initial timed0/30 and normal rep10/0 controls are distinct. This is a direct method invocation, not an actual UI tap/render or SQL completion. '+qa,
  actual_behavior:'The actual Add Set method sends hidden reps10 with duration0 for a timed-classified exercise, and client completion marking accepts it. Timed row visibility is source-inspected; no rendered Add Set interaction or server award is claimed.',
  impact:'P2 confirmed Dart default/validation mismatch for added timed sets; potentially misleading visible measurement is source-backed, not a confirmed full UI journey or backend validation/award bypass.',
  confidence:'Confirmed',
  proposed_remediation:'Owner flutter-specialist with exercise-catalog and qa-reviewer: after approval initialize additional sets by supported modality and validate against that measurement contract; retain normal rep defaults and do not bypass INTG005 final validation.',
  regression_risk:'Initial versus additional timed/rep sets, zero duration, completed edits, visible fields, restoration and mixed exercise sessions.',
  related_tests:['app/test/workout_controller_test.dart','app/test/workout_widgets_test.dart',fr+' G6/AddSet'],
  missing_tests:['After fix approval: actual rendered training Add Set tap and complete callback use modality-consistent visible defaults; zero visible timed duration cannot pass solely via hidden reps, with rep controls.','Approved isolated backend: verify agreed timed completion contract with INTG005; do not infer it from client completion marking.'],
  depends_on:['INTG005 retains separate A4 SQL0-rep timed completion rejection; INTG007 owns initial generated-prescription/default mismatch. Neither is newly proved by this direct Add Set method.'],
  verification_method:'Retained '+fr+' G6 source602-635/output697-702: actual method and request payload plus client mark-complete observed,18-test run exit0. No UI tap/render or live SQL/E2E in this promotion; QA inspected full source.'
 },
 'FND-INTG-007':{
  title:'Generated quest JSON initializes timed Dart sets as zero reps against rep targets',
  component:'Actual generated prescription JSON versus Dart initialization/payload contract',
  paths:['supabase/migrations/20261026000200_authoritative_progression.sql','app/lib/features/workout/presentation/controllers/active_workout_controller.dart','supabase/seed_exercises.sql','docs/audit/phases/A4_SQL_EVIDENCE.md',fr],
  line_ranges:['authoritative_progression.sql:205-212,238,245-251','active_workout_controller.dart:298-317','seed_exercises.sql:1220-1221',fr+':G6; source602-635/output697-702','A4_SQL_EVIDENCE.md:group6 (historical separate SQL evidence)'],
  origin:'A4 generated-quest contract/JS-mirror history; A5 actual seed-generated JSON -> real Dart model/controller/repository and independent QA',
  evidence:'A5 fresh seeded catalog150 and actual sync_daily_data, deterministically selecting full_body in disposable fixture, emit Ab Wheel Rollout(carry), Arnold Press, Back Extension3x12 with real existing catalog IDs. QuestInstance.fromJson/startQuest execute in Dart; actual timed INSERTs are3x(reps0,duration30), other targets3x12. Former mirrored-Dart gap is closed for this initialization/payload mechanism. All9 can be client-marked complete. Local qualifier count0 versus required12 is only a local predicate, NOT a SQL result. The22023 completion rejection and positive-rep success response are explicit fake transport controls, NOT live SQL/E2E. A4 SQL group6 remains separate retained history. '+qa,
  root_cause:'Actual sync_daily_data emits rep prescriptions for selected exercises, while real Dart initialization forces timed-classified targets to0reps/30sec despite prescribed12; there is no duration-prescription field in that Dart target model.',
  expected_behavior:'Generated prescription JSON and Dart initialization/payloads honor one approved measurement contract per supported exercise; final server eligibility must be verified separately.',
  actual_behavior:'Actual generated12-rep target decodes/initializes into actual Dart timed0/30 requests. This confirmed mismatch does not establish independently reached SQL quest eligibility or a rendered end-to-end quest failure.',
  impact:'P2 confirmed generated-JSON/Dart-default incompatibility in the bounded seeded fixture. No full UI/SQL quest journey, live award result or exercise-science validation of seed carry classification is claimed.',
  confidence:'Confirmed',status:'Accepted',
  proposed_remediation:'Owner flutter-specialist with supabase-specialist, exercise-catalog and qa-reviewer: after approval define mode-aware generation/defaults/matching together or explicitly exclude unsupported modes; preserve stable exercise IDs and complete_workout award ownership, coordinating INTG005 rather than weakening validation.',
  regression_risk:'Quest rotation/catalog selection, timed/rep/mixed targets, target decoding, load/duration, Add Set versus initial sets, expiry, restoration and transactional retry awards.',
  related_tests:['supabase/tests/security_regression.sql:92-111','app/test/workout_controller_test.dart','docs/audit/phases/A4_SQL_EVIDENCE.md group6',fr+' G6/extractor'],
  missing_tests:['After approved measurement contract/fix: render actual generated targets and assert mode-compatible Dart initial/save payloads with non-timed controls; preserve existing IDs.','Approved isolated SQL/gateway: exercise same actual Dart payloads through completion/quest matching, assert agreed eligibility and exactly one retry award without bypassing INTG005.','Catalog owner separately validates supported modality; seed carry classification alone is not exercise-science evidence.'],
  depends_on:['INTG005 currently rejects completed0-rep timed sets; INTG004 is additional-set hidden reps, not initial prescription. Actual-Dart initialization gap closed, full SQL/gateway eligibility remains deferred.'],
  verification_method:'Retained '+fr+' G6 executes actual seeded generator JSON then real Dart model/controller/repository,18-test run exit0. Local qualifier and fake22023 are explicitly not SQL results; A4 SQL evidence stays separate. QA supports only narrowed Confirmed initialization/payload claim.'
 },
 'FND-SEC-004':{
  title:'Authenticated Edge handlers fully buffer counted request and provider bodies before checks',
  evidence:'A5 backend G3 actual rpcHandler/handleCoachRequest Request streams:32768 bytes consumed before413 with no Content-Length or truthful header; under-limit controls200. Multibyte30029 UTF-8 bytes/10029 UTF-16 units accepted200 by both. Missing/rejected auth401 consumes0 bytes. Injected actual provider Response77053 bytes fully consumed before502 for13000-unit answer;64055-byte padding with short answer accepted200. Stream cancel callbacks0; non-ok provider502 consumes0.12 request+3 provider cases exit0, cached-only/deny-net with synthetic auth/fetch, max fixture256KiB. '+qa,
  actual_behavior:'Bounded counted request bodies are fully materialized before application string-length rejection; larger multibyte byte counts pass unit limits, and provider JSON is consumed before answer checking. Synthetic callback counts are not network cancellation observations.',
  impact:'Provisional P2 authenticated resource-pressure risk; Confirmed only for bounded buffering/unit mechanisms. No DoS, memory exhaustion, real transport cancellation, production allocation, gateway ceiling or latency claim; platform limits may mitigate impact.',
  confidence:'Confirmed',status:'Accepted',
  proposed_remediation:'Owner supabase-specialist with qa-reviewer: after approval define byte-based request/response budgets and bounded streaming reads/cancellation or verify platform-enforced ceilings; preserve auth-before-body, semantic validation, VI/EN and sanitized errors.',
  regression_risk:'Multibyte units/bytes, missing/truthful/misleading length headers, malformed JSON, auth rejection, quota/context failure, provider body limits and abort/error mapping.',
  related_tests:['supabase/functions/tests/http_handler_test.ts','supabase/functions/ai-coach/service_test.ts',br+' G3/section8 full edge.ts and logs'],
  missing_tests:['After approved byte-budget fix: counted streams stop/cancel at the agreed bound while under-limit/multibyte/auth-negative controls preserve semantics; provider oversized/padded response reads are bounded.','Approved isolated gateway/transport: verify actual JWT/byte ceilings, request disconnect and slow response-body timeout/cancellation; current callbacks do not prove network abort. No traffic flood or production latency test authorized.'],
  depends_on:['Gateway/resource impact remains unverified; distinct from INTG003 answer/history schema mismatch. No deployment or material budget decision approved.'],
  verification_method:'Retained '+br+' sections1/4/7/8 G3: real handler/service synthetic counted streams,12+3 cases exit0. QA read full sources; promotion confirms measured mechanisms only, P2 impact stays provisional. No runtime rerun by writer.'
 }
};
const additions=[
 {id:'FND-BUG-008',title:'Stale sign-in error contaminates password recovery before submission',category:'BUG',component:'Operation-scoped AuthController/form state',paths:['app/lib/features/auth/presentation/providers/auth_providers.dart','app/lib/features/auth/presentation/screens/reset_password_screen.dart','app/lib/core/router/app_router.dart'],line_ranges:['auth_providers.dart:65-115','reset_password_screen.dart:29,84-94',fr+':G1; source470-510/output661-668'],origin:'A2 Lead10 deferred assertion; A5 actual forms/controller/router fixture and independent QA',root_cause:'Shared AuthController AsyncError from failed sign-in remains visible to recovery screen as a password-update error without an update submission.',evidence:'A5 Flutter G1 real login rejects synthetic sign-in, synthetic passwordRecovery event drives actual router/reset screen; premature update error=true with updateCalls0. Pristine recovery false/updateCalls0. Actual Save password rejected-submit shows error/keeps recovery; success clears action error/recovery and leaves reset route. Retained18-test run exit0 and strengthened G1 button controls+2 exit0. '+qa,expected_behavior:'Recovery entry must not report a failed password update before that operation is submitted; preserve valid rejected/successful submit feedback.',actual_behavior:'Synthetic failed-signin -> recovery renders Could not update your password before any update call; pristine entry and subsequent submit controls distinguish contamination.',impact:'P2 confirmed misleading pre-submit recovery feedback in actual Dart/router/form fixture; no live link, callback delivery, credential disclosure or backend auth defect established.',severity:'P2',confidence:'Confirmed',status:'Accepted',proposed_remediation:'Owner flutter-specialist/Auth with qa-reviewer: after approval scope action errors by operation or reset stale sign-in state at recovery entry, preserving true update failures and successful recovery cleanup.',regression_risk:'Failed sign-in, recovery navigation, validation, rejected/successful password update, retries and auth events.',related_tests:['app/test/auth_controller_test.dart','app/test/ui_regression_test.dart',fr+' G1'],missing_tests:['After fix approval: rejected sign-in then actual recovery route shows no update error before submit; pristine entry, rejected Save and successful Save controls still work.','Approved isolated Auth/callback follow-up: distinguish actual recovery URI/session transitions from synthetic events; no live Auth evidence claimed.'],depends_on:['Distinct from INTG001 callback/allowlist contract; no backend/config change approved.'],wave:'W2',verification_method:'Retained '+fr+' G1 source/output and commands; actual widgets/router with synthetic repository/Auth event. QA read full probe; no runtime rerun in writer.'},
 {id:'FND-BUG-009',title:'CandyButton primitive is not keyboard reachable or activatable',category:'BUG',component:'Production CandyButton focus/keyboard semantics',paths:['app/lib/ui/candy/candy_button.dart','app/lib/core/router/persistent_active_workout_banner.dart','app/lib/features/progression/presentation/widgets/level_up_overlay.dart'],line_ranges:['candy_button.dart:189-207','persistent_active_workout_banner.dart:147','level_up_overlay.dart:143',ur+':section2 keyboard fixture'],origin:'A5 actual production CandyButton/SystemButton control fixture and independent QA',root_cause:'CandyButton wraps pointer GestureDetector/Semantics without a Focus/Actions keyboard activation path.',evidence:'A5 UI fixture at614ee7c: candyFocusNodes0; Tab reaches actual SystemButton; Enter and Space increment System1 then2 while CandyKeys0; pointerCandy1. Existing production call sites are source-inspected, not route-traversed. These observations passed within UI aggregate FAIL(+8 -2 onboarding fixture failures). The disabled counter fixture is tautological (null callback); it does not establish comprehensive disabled/loading behavior. '+qa,expected_behavior:'Enabled Candy action can receive keyboard focus and activate once with Enter/Space with a visible focus state, while pointer behavior remains valid.',actual_behavior:'Actual enabled CandyButton primitive is skipped in focus traversal and not key-activated; actual SystemButton positive control and Candy pointer activation work.',impact:'P2 confirmed keyboard inoperability of the tested primitive. Integrated route impact is source-backed, not executed whole-screen accessibility certification; no blanket claim about all Candy widgets.',severity:'P2',confidence:'Confirmed',status:'Accepted',proposed_remediation:'Owner ui-ux-specialist with flutter-specialist and qa-reviewer: after approval add keyboard/focus/Actions semantics using existing design-system affordances; preserve pointer and native SystemButton behavior.',regression_risk:'Focus order/visibility, Enter/Space single activation, pointer press state, disabled/loading/key-repeat behavior and banner/overlay call sites.',related_tests:['app/test/navigation_integration_test.dart','app/test/ui_regression_test.dart',ur+' keyboard fixture'],missing_tests:['After fix approval: Tab reaches real CandyButton with visible focus; Enter/Space fire exactly once, pointer still fires, and enabled SystemButton remains positive control.','Authorized UI follow-up: non-tautological disabled/loading callbacks and key-repeat assertions plus banner/overlay route traversal; do not count current null-callback counter as comprehensive coverage.'],depends_on:['No new theme/dependency approved; distinct from BUG004 contrast and ARCH002 localization.'],wave:'W2',verification_method:'Retained '+ur+' section2/full sources and logs section6; actual primitive versus actual SystemButton and pointer controls. QA supports primitive-only Confirmed; full integrated/device keyboard journey NOT RUN.'},
 {id:'FND-INTG-008',title:'Lost add-set acknowledgement permits repeated identical insert requests',category:'INTG',component:'Workout set retry/reconciliation transport contract',paths:['app/lib/features/workout/data/supabase_workout_repository.dart','app/lib/features/workout/presentation/controllers/active_workout_controller.dart','supabase/migrations/20261026000100_baseline.sql'],line_ranges:['repository addSet/controller addSet and retry paths', 'baseline.sql:210-219',fr+':G3; source538-558/output677-682'],origin:'A5 actual Dart controller/repository HTTP with modeled commit/lost-response fixture; independent QA',root_cause:'Failed acknowledgement leaves local row/number state unreconciled; retry derives set_number from that stale local state and issues another insert without an acknowledged stable row identity.',evidence:'G3 actual repository emits two identical INSERT payloads set_number2. Deliberately permissive fake server commits first then loses response: modeled rows1,2,2/local1,2 and distinct IDs s1,s100,s101/local s1,s101. Rejected-before-commit control rows1,2; reload-before-retry sends3 and reconciles rows1,2,3. Failed first save blocks completion/no finish RPC. SQL constraints absence inspected, not runtime duplicate proof. '+qa,expected_behavior:'A retry after uncertain write outcome reconciles the committed row or uses stable idempotent identity without duplicating a logical set; rejected-write/reload controls remain valid.',actual_behavior:'Repeated real client requests are confirmed, but duplicate modeled server rows and local divergence depend on the synthetic commit/lost-ACK fixture; actual gateway/SQL persistence remains unverified.',impact:'P2 possible duplicate/missing-local set reconciliation under lost acknowledgement. High/Needs Verification because server commit/duplication is modeled; no authoritative SQL duplicate or XP inflation proved.',severity:'P2',confidence:'High',status:'Needs Verification',proposed_remediation:'Owner flutter-specialist with supabase-specialist and qa-reviewer: after approved transport contract and isolated verification, reconcile uncertain insert outcomes using stable mutation/row identity before retry; preserve rejected-write and reload semantics.',regression_risk:'Set numbering/IDs, concurrent edits, uncertain delivery, reload/retry, validation, completion gate and existing history.',related_tests:['app/test/workout_controller_test.dart',fr+' G3'],missing_tests:['Approved isolated stack: commit actual add-set insert then lose response, retry same actual client operation, assert one logical set and consistent local/server IDs/numbers.','After fix approval: pre-commit rejection and reload-before-retry controls stay correct; completion stays gated until uncertainty is reconciled.'],depends_on:['Supported isolated SQL/gateway scheduling and separately approved retry identity contract; not DATA001 legacy awards.'],wave:'W1',verification_method:'Retained '+fr+' G3 actual HTTP payloads with explicit modeled server;18-test run exit0. QA supports High transport candidate only. Independent SQL/gateway lost-ACK assertion deferred; no live/SQL duplication claim.'},
 {id:'FND-INTG-009',title:'Sequential exercise reorder can leave optimistic and modeled persisted orders divergent',category:'INTG',component:'Exercise reorder partial-write reconciliation',paths:['app/lib/features/workout/data/supabase_workout_repository.dart','app/lib/features/workout/presentation/controllers/active_workout_controller.dart'],line_ranges:['repository reorderExercises sequential update path/controller optimistic reorder',fr+':G4; source559-583/output683-690'],origin:'A5 actual Dart reorder requests with modeled partial persistence and independent QA',root_cause:'Optimistic local reorder is followed by sequential independent row updates; later failure does not atomically restore the modeled earlier update or reconcile local ordering.',evidence:'G4 move e3 to0 yields optimistic e3,e1,e2. Actual first HTTP update succeeds, second400; modeled persistence e1=0/e2=1/e3=0 while local stays optimistic/save_failed. Reload fixture observes e1,e3,e2, not a guaranteed tie order. All-success control sends3 updates and reload matches intended order. Legitimate absent-row delete204 succeeds;403 retains local row/save_failed, not a bypass finding. '+qa,expected_behavior:'Failed reorder leaves a coherent acknowledged order or explicit reconciled state; partial transport failure must not silently preserve a divergent optimistic order.',actual_behavior:'Actual sequential request/error/local-state behavior observed; partial committed server mapping is modeled. Duplicate order indices and observed reload order do not establish guaranteed production tie ordering.',impact:'P2 possible persistent/local order divergence and user confusion after partial write. High/Needs Verification for actual SQL/gateway partial persistence; no reward consequence or authorization bypass shown.',severity:'P2',confidence:'High',status:'Needs Verification',proposed_remediation:'Owner flutter-specialist with supabase-specialist and qa-reviewer: after approval and isolated verification define atomic or explicit reconciliation behavior for multi-row reorder, preserving ownership guards and legitimate idempotent zero-row deletion.',regression_risk:'Optimistic order, partial failure/reload, ties, concurrent edits, save failure feedback, ownership and absent versus forbidden deletes.',related_tests:['app/test/workout_controller_test.dart','app/test/workout_widgets_test.dart',fr+' G4'],missing_tests:['Approved isolated stack: commit first actual reorder update and reject next, then compare acknowledged local and persisted order; no assertion of arbitrary tie order.','After fix approval: all-success3-update control, rollback/reconcile failure control, already-absent owned delete204 and explicit forbidden403 remain distinct; RLS-hidden rows require real role controls.'],depends_on:['Supported isolated SQL/gateway partial-write scheduling and approved reorder contract; no transaction/schema fix authorized in A5.'],wave:'W1',verification_method:'Retained '+fr+' G4 actual request sequence/controller state plus explicitly modeled persistence,18-test run exit0. QA supports High/NV only; no actual multi-request SQL transaction test or guaranteed tie ordering.'},
 {id:'FND-TEST-002',title:'Candy specification-replica tests do not protect corresponding production primitives',category:'TEST',component:'Flutter production-component regression coverage',paths:['app/test/candy_ui_test.dart','app/lib/ui/candy/candy_button.dart','app/lib/ui/candy/candy_card.dart'],line_ranges:['candy_ui_test.dart:1-619 (imports/local definitions/expectations)',fr+':section2 test inventory',ur+':section1 test inventory'],origin:'A5 complete bounded Flutter test inventory and independent UI/QA inspection',root_cause:'619-line candy_ui_test.dart imports no production app widgets and defines local palette/TactileCandyButton/CandyCardWidget replicas, then asserts those same local implementations.',evidence:'Flutter and UI reviewers independently read all619 lines/imports/local definitions. Contrast, press/loading and320/1.5x assertions exercise reference fixtures, so corresponding production implementation changes are not exercised by those tests. Other test files render actual UI; this is not zero production-widget coverage. No mutation test, golden or coverage percentage was measured. '+qa,expected_behavior:'Tests presented as production Candy regressions exercise the actual corresponding app primitives; reference-specification fixtures may remain explicitly labeled.',actual_behavior:'This file protects its own local specification/replicas, not actual CandyButton/Card implementations; real UI coverage in other files remains meaningful.',impact:'P3 High test-quality gap: misleading protection can let production primitive regressions escape this suite. It does not itself prove a product defect or invalidate all UI tests.',severity:'P3',confidence:'High',status:'Accepted',proposed_remediation:'Owner flutter-specialist with ui-ux-specialist and qa-reviewer: after approval add or replace production-component regressions using actual Candy imports, retaining clearly labeled specification tests where useful.',regression_risk:'Accidentally discarding useful specification behavior, hiding real production import differences, pointer/loading/focus/layout expectations and genuine UI tests elsewhere.',related_tests:['app/test/candy_ui_test.dart','app/test/ui_regression_test.dart','app/test/navigation_integration_test.dart'],missing_tests:['After test-edit approval: demonstrate the corresponding test renders real CandyButton/Card and a bounded intentional production behavior change fails that regression, then restore it safely; preserve useful specification controls.','Define targeted assertions before adding a coverage/golden gate; missing golden/coverage percentage alone is not a finding.'],depends_on:['Distinct from TEST001 CI/platform/format/codegen gates; no dependency or CI policy change authorized.'],wave:'W3',verification_method:'Static import/definition/assertion trace in '+fr+' section2 and '+ur+' section1, independently QA-read. High, not runtime mutation-test Confirmed; no production source/test edits in A5.'}
];
const j=structuredClone(prior),touched=Object.keys(updates);assert.equal(touched.length,6);
for(const id of touched){const i=j.findings.findIndex(f=>f.id===id),previous=structuredClone(prior.findings[i]);assert(i>=0);j.findings[i]={...j.findings[i],...updates[id],historical_pre_a5:previous,a5_review:review(id==='FND-BUG-004'?ur:id==='FND-SEC-004'?br:fr,'Current fields are narrowly scoped; all prior fields/reviews and nested historical objects are preserved verbatim in historical_pre_a5. A2-A4 review metadata outside that object is historical, not current scope.')};}
for(const f of additions){assert(!j.findings.some(x=>x.id===f.id));j.findings.push({...f,a5_review:review(f.id==='FND-BUG-009'?ur:f.id==='FND-TEST-002'?fr+'; '+ur:fr,'Evidence/assumptions and remaining assertions are explicit in this record; no remediation or whole-stage closure claim.')});}
j.stage='A5 (IN PROGRESS; bounded registers reconciled after independent evidence review; scoped stage acceptance NOT RUN)';
j.history_note='a4_closure/a4_review, a3_closure and closure retain complete A4/A3/A2 history, not current A5 closure claims. Six amended findings preserve exact entire pre-A5 objects in historical_pre_a5, including older nested histories/reviews. All other24 prior finding objects remain JSON-deep-equivalent; all30 prior IDs survive. Five narrow confidence/status promotions and five new IDs do not imply product fixes or production certification.';
j.historical_baselines=[...prior.historical_baselines,{stage:'A4 entry',...structuredClone(prior.baseline)}];
j.baseline={branch:'main',head:product,head_short:'1763ab5',remote_head:product,working_tree:'Clean and remote-equal at A5 entry as recorded in A5 phase2. This bounded writer enters main614ee7c with only new UI evidence untracked and changes only the two registers; no product changes or closure claim.'};
j.a5_review={date:'2026-10-28',entry_commit:product,documentation_entry:entry,scope:'A5 bounded findings reconciliation only; stage in progress, not closure or remediation',independent_qa:qa,evidence_reference:[fr,br,ur],classification_changes:['BUG004, INTG002, INTG004: P2/High/Accepted -> P2/Confirmed/Accepted for narrowed actual-client/style mechanisms','INTG007, SEC004: P2/High/Needs Verification -> P2/Confirmed/Accepted for narrowed initialization/buffering mechanisms','CONC001 P2/Confirmed/Accepted unchanged; distinct post-storage-await identity race added without replacing queue-cycle history'],new_findings:additions.map(f=>f.id),limits:'No new runtime rerun here; synthetic modeled commits/persistence are not SQL proofs; UI aggregate retains two onboarding fixture failures; no DoS/gateway/device/production latency certification. QA extra source Git command BLOCKED and not retried.'};
const severity={P0:0,P1:0,P2:0,P3:0,P4:0},confidence={Confirmed:0,High:0,Medium:0,Low:0},status={Open:0,'Needs Verification':0,Accepted:0,Fixed:0,Deferred:0,'False Positive':0};
for(const f of j.findings){severity[f.severity]++;confidence[f.confidence]++;status[f.status]++;}
j.counts={total:j.findings.length,by_severity:severity,by_confidence:confidence,by_status:status};
assert.deepEqual(j.counts,{total:35,by_severity:{P0:0,P1:3,P2:24,P3:6,P4:2},by_confidence:{Confirmed:16,High:18,Medium:1,Low:0},by_status:{Open:0,'Needs Verification':3,Accepted:29,Fixed:1,Deferred:0,'False Positive':2}});
const fields=Object.keys(prior.findings[0]);assert.equal(fields.length,22);for(const f of additions)for(const k of fields)assert(Object.hasOwn(f,k),f.id+':'+k);
const labels={id:'ID',title:'Title',category:'Category',component:'Component',paths:'Paths',line_ranges:'Lines',origin:'Origin',root_cause:'Root cause',evidence:'Evidence',expected_behavior:'Expected behavior',actual_behavior:'Actual behavior',impact:'Impact',severity:'Severity',confidence:'Confidence',status:'Status',proposed_remediation:'Proposed remediation',regression_risk:'Regression risk',related_tests:'Related tests',missing_tests:'Missing tests',depends_on:'Depends on',wave:'Wave',verification_method:'Verification method'};
const escape=v=>(Array.isArray(v)?v.join('; '):String(v)).replace(/\|/g,'&#124;').replace(/\r?\n/g,' ');
function render(f){return '## '+f.id+' — '+f.title+'\n\n| Field | Value |\n|---|---|\n'+fields.map(k=>'| '+labels[k]+' | '+(k==='severity'||k==='confidence'?'**'+escape(f[k])+'**':k==='status'?'`'+escape(f[k])+'`':escape(f[k]))+' |').join('\n')+'\n\n**A5 review:** product baseline `'+product+'`; UI evidence/documentation entry `'+entry+'`; '+qa+' No runtime rerun in this documentation turn.\n\n';}
const heads=[...oldMD.matchAll(/^## (FND-[A-Z]+-\d{3})[^\r\n]*$/gm)];assert.equal(heads.length,30);
let md='# Master Findings\n\n**Stage:** A5 IN PROGRESS — bounded registers reconciled; scoped stage acceptance NOT RUN.\n**Baseline:** `main` @ `'+product+'` (`1763ab5`), A5 product/audit entry. Documentation writer enters `'+entry+'`.\n**Counts:** 35 findings — P0: 0, P1: 3, P2: 24, P3: 6, P4: 2. Confirmed: 16, High: 18, Medium: 1, Low: 0.\n**Status:** 3 `Needs Verification`, 29 `Accepted`, 1 `Fixed`, 2 `False Positive`.\n\nAll30 prior IDs/fields/history survive;24 untouched objects are JSON-deep-equivalent. Six amended objects retain ENTIRE exact previous findings in JSON `historical_pre_a5`, including nested historical_pre_a4 and A2-A4 review metadata wherever present. Five narrow promotions and five new IDs do not constitute remediation or A5 closure. Current claims are the first per-ID tables; archived pre-A5 prose/tables and earlier closure objects are historical. Golden/coverage percentages remain gaps, not automatic findings.\n\nIndependent review: '+qa+'\n\n### Historical A4 register header and write verification (entire prior header retained)\n\n'+oldMD.slice(oldMD.indexOf('\n')+1,heads[0].index)+'\n';
for(let n=0;n<heads.length;n++){const id=heads[n][1],section=oldMD.slice(heads[n].index,n+1<heads.length?heads[n+1].index:oldMD.length);if(!touched.includes(id)){md+=section;continue;}const f=j.findings.find(f=>f.id===id);md+=render(f)+'<details>\n<summary>Historical pre-A5 record — superseded current wording/classification, not an additional A5 claim</summary>\n\n'+section.replace(/^## /,'#### Archived ')+'\n</details>\n\n---\n\n';}
for(const f of additions)md+=render(j.findings.find(x=>x.id===f.id))+'---\n\n';
md+=source+'\n\n### A5 register-write validation\n\nPending current-session inline Node preservation/count/classification validation and git diff --check. No runtime/product check is implied by register reconciliation.\n';
fs.writeFileSync(jp,JSON.stringify(j,null,2)+'\n');fs.writeFileSync(mp,md);
console.log('A5_REGISTER_WRITE generated only MASTER_FINDINGS.md/FINDINGS_REGISTER.json; old30/new5/amended6; historical clones taken from exact614ee7c objects; stage IN PROGRESS');
```
<!-- A5_WRITER_END -->

### A5 register-write validation

The retained writer above was executed by an inline Node extraction of its JavaScript block:
`A5_REGISTER_WRITE generated only MASTER_FINDINGS.md/FINDINGS_REGISTER.json; old30/new5/amended6;
historical clones taken from exact614ee7c objects; stage IN PROGRESS`, `A5_REGISTER_WRITE_EXIT=0`.
No runtime/product check is implied by register reconciliation.

First inline validator **FAIL**, exit1: its Unicode heading-delimiter regex captured the em dash as
part of the amended title in the PowerShell-to-Node pipeline. This was a validator parsing failure,
not a finding/title mismatch to repair. Only the validator was corrected to ASCII-safe `\u2014`;
old GOV001 title wording is deliberately not normalized or compared arbitrarily. Full error output:

```text
node:assert:95
  throw new AssertionError(obj);
  ^

AssertionError [ERR_ASSERTION]: Expected values to be strictly equal:
+ actual - expected

+ '— Discard queue cycle and post-backup-await identity race disrupt active workout state'
- 'Discard queue cycle and post-backup-await identity race disrupt active workout state'

    at [stdin]:17:557
    at runScriptInThisContext (node:internal/vm:209:10)
    at node:internal/process/execution:449:12
    at [stdin]-wrapper:6:24
    at runScriptInContext (node:internal/process/execution:447:60)
    at evalFunction (node:internal/process/execution:87:30)
    at evalScript (node:internal/process/execution:99:3)
    at node:internal/main/eval_stdin:53:5
    at Socket.<anonymous> (node:internal/process/execution:200:5)
    at Socket.emit (node:events:530:35) {
  generatedMessage: true,
  code: 'ERR_ASSERTION',
  actual: '— Discard queue cycle and post-backup-await identity race disrupt active workout state',
  expected: 'Discard queue cycle and post-backup-await identity race disrupt active workout state',
  operator: 'strictEqual'
}

Node.js v22.17.1
A5_REGISTER_VALIDATOR_EXIT=1
A5_REGISTER_DIFF_EXIT=0
```

Corrected inline Node validator (PowerShell single-quoted here-string piped to `node`, repository
working directory). Product/evidence files are not changed. Only amended/new titles are compared;
all35 current MD/JSON classifications, all22 required fields and exact preservation are asserted.

```javascript
const fs=require('node:fs'),cp=require('node:child_process'),assert=require('node:assert/strict');
const entry='614ee7cb6f99846b00fd71eec43637cb296268be',product='1763ab55e8da994bc1d854ad8fd2cd2299678b45';
const jp='docs/audit/FINDINGS_REGISTER.json',mp='docs/audit/MASTER_FINDINGS.md';
const old=JSON.parse(cp.execFileSync('git',['show',entry+':'+jp],{encoding:'utf8'})),j=JSON.parse(fs.readFileSync(jp,'utf8')),md=fs.readFileSync(mp,'utf8');
const touched=['FND-CONC-001','FND-BUG-004','FND-INTG-002','FND-INTG-004','FND-INTG-007','FND-SEC-004'];
const promoted=touched.filter(x=>x!=='FND-CONC-001'),added=['FND-BUG-008','FND-BUG-009','FND-INTG-008','FND-INTG-009','FND-TEST-002'];
const fields=Object.keys(old.findings[0]);assert.equal(fields.length,22);assert.equal(old.findings.length,30);assert.equal(j.findings.length,35);
const byId=new Map(j.findings.map(f=>[f.id,f]));assert.equal(byId.size,35);let sameClasses=0,sameObjects=0,histories=0;
for(const previous of old.findings){const now=byId.get(previous.id);assert(now,previous.id);if(['severity','confidence','status'].every(k=>now[k]===previous[k]))sameClasses++;if(touched.includes(previous.id)){assert.deepEqual(now.historical_pre_a5,previous,previous.id+' history');for(const k of Object.keys(previous).filter(k=>!fields.includes(k)))assert.deepEqual(now[k],previous[k],previous.id+' historical metadata '+k);histories++;assert(now.a5_review.independent_qa.includes('ses_e7cb5a850ffeEKOCUhDgig3neH'));assert(now.proposed_remediation.startsWith('Owner '));}else{assert.deepEqual(now,previous,previous.id+' untouched');sameObjects++;}}
assert.equal(sameClasses,25);assert.equal(sameObjects,24);assert.equal(histories,6);for(const id of promoted){const f=byId.get(id);assert.equal(f.severity,'P2');assert.equal(f.confidence,'Confirmed');assert.equal(f.status,'Accepted');}
assert.deepEqual(j.findings.filter(f=>!old.findings.some(x=>x.id===f.id)).map(f=>f.id).sort(),added.slice().sort());
for(const f of j.findings)for(const k of fields)assert(Object.hasOwn(f,k),f.id+':'+k);for(const id of added){const f=byId.get(id);assert(f.proposed_remediation.startsWith('Owner '));assert(f.a5_review.independent_qa.includes('ses_e7cb5a850ffeEKOCUhDgig3neH'));assert(f.missing_tests.length>0);}
const counts={total:35,by_severity:{P0:0,P1:0,P2:0,P3:0,P4:0},by_confidence:{Confirmed:0,High:0,Medium:0,Low:0},by_status:{Open:0,'Needs Verification':0,Accepted:0,Fixed:0,Deferred:0,'False Positive':0}};for(const f of j.findings){counts.by_severity[f.severity]++;counts.by_confidence[f.confidence]++;counts.by_status[f.status]++;}
const expected={total:35,by_severity:{P0:0,P1:3,P2:24,P3:6,P4:2},by_confidence:{Confirmed:16,High:18,Medium:1,Low:0},by_status:{Open:0,'Needs Verification':3,Accepted:29,Fixed:1,Deferred:0,'False Positive':2}};assert.deepEqual(counts,expected);assert.deepEqual(j.counts,expected);
const heads=[...md.matchAll(/^## (FND-[A-Z]+-\d{3}) \u2014 ([^\r\n]+)$/gm)];assert.equal(heads.length,35);assert.equal(new Set(heads.map(x=>x[1])).size,35);
const labels={id:'ID',title:'Title',category:'Category',component:'Component',paths:'Paths',line_ranges:'Lines',origin:'Origin',root_cause:'Root cause',evidence:'Evidence',expected_behavior:'Expected behavior',actual_behavior:'Actual behavior',impact:'Impact',severity:'Severity',confidence:'Confidence',status:'Status',proposed_remediation:'Proposed remediation',regression_risk:'Regression risk',related_tests:'Related tests',missing_tests:'Missing tests',depends_on:'Depends on',wave:'Wave',verification_method:'Verification method'};
for(let n=0;n<heads.length;n++){const h=heads[n],f=byId.get(h[1]);assert(f,h[1]);const s=md.slice(h.index,n+1<heads.length?heads[n+1].index:md.length).split('<details>')[0];const value=label=>{const row=s.split('\n').find(x=>x.startsWith('| '+label+' | '));assert(row,h[1]+':'+label);return row.slice(('| '+label+' | ').length).replace(/ \|$/,'').replace(/\*\*|`/g,'');};assert.equal(value('Severity'),f.severity);assert.equal(value('Confidence'),f.confidence);assert.equal(value('Status'),f.status);if(touched.includes(f.id)||added.includes(f.id)){assert.equal(h[2],f.title);for(const k of fields)value(labels[k]);}}
for(const key of ['a4_closure','a4_review','a3_closure','closure'])assert.deepEqual(j[key],old[key],key);assert.deepEqual(j.historical_baselines.slice(0,old.historical_baselines.length),old.historical_baselines);const a4=j.historical_baselines.find(x=>x.stage==='A4 entry');const {stage,...oldBaseline}=a4;assert.deepEqual(oldBaseline,old.baseline);assert.equal(j.baseline.head,product);assert.equal(j.a5_review.entry_commit,product);assert(j.stage.includes('IN PROGRESS'));
assert(md.includes('**Counts:** 35 findings \u2014 P0: 0, P1: 3, P2: 24, P3: 6, P4: 2. Confirmed: 16, High: 18, Medium: 1, Low: 0.'));assert(md.includes('**Status:** 3 `Needs Verification`, 29 `Accepted`, 1 `Fixed`, 2 `False Positive`.'));
assert.equal(cp.execFileSync('git',['rev-parse','HEAD'],{encoding:'utf8'}).trim(),entry);const changed=cp.execFileSync('git',['diff','--name-only'],{encoding:'utf8'}).trim().split('\n').filter(Boolean).sort();assert.deepEqual(changed,[jp,mp].sort());const status=cp.execFileSync('git',['status','--porcelain=v1'],{encoding:'utf8'}).trimEnd().split('\n');assert.equal(status.length,3);for(const l of status)assert([jp,mp,'docs/audit/phases/A5_UI_EVIDENCE.md'].includes(l.slice(3).trim()),l);
console.log('A5_REGISTER_CHECK json_parse=PASS json=35 md=35 old_ids_preserved=30 old_classifications_unchanged=25 old_objects_unchanged=24 historical_pre_a5_exact=6 nested_reviews_preserved=true new_ids=5 required_fields_each=22 md_json_classes_match=35 historical_closures_preserved=true historical_a4_baseline_exact=true allowed_writer_paths=2 errors=0');console.log('A5_COUNTS '+JSON.stringify(counts));
```

Corrected execution **PASS**, exit0. Command suffix was
`'@ | node; "A5_REGISTER_VALIDATOR_EXIT=$LASTEXITCODE"; git diff --check;
"A5_REGISTER_DIFF_EXIT=$LASTEXITCODE"; git status --porcelain=v1; git rev-parse HEAD`.
Exact substantive output (Git also emitted only LF/CRLF notices for the two owned registers):

```text
A5_REGISTER_CHECK json_parse=PASS json=35 md=35 old_ids_preserved=30 old_classifications_unchanged=25 old_objects_unchanged=24 historical_pre_a5_exact=6 nested_reviews_preserved=true new_ids=5 required_fields_each=22 md_json_classes_match=35 historical_closures_preserved=true historical_a4_baseline_exact=true allowed_writer_paths=2 errors=0
A5_COUNTS {"total":35,"by_severity":{"P0":0,"P1":3,"P2":24,"P3":6,"P4":2},"by_confidence":{"Confirmed":16,"High":18,"Medium":1,"Low":0},"by_status":{"Open":0,"Needs Verification":3,"Accepted":29,"Fixed":1,"Deferred":0,"False Positive":2}}
A5_REGISTER_VALIDATOR_EXIT=0
A5_REGISTER_DIFF_EXIT=0
 M docs/audit/FINDINGS_REGISTER.json
 M docs/audit/MASTER_FINDINGS.md
?? docs/audit/phases/A5_UI_EVIDENCE.md
614ee7cb6f99846b00fd71eec43637cb296268be
```

Only these two registers were edited by this writer; the pre-existing new UI evidence remains
untouched. No evidence/planning/coverage/product/configuration/permanent-test edits or commits.
The stage remains **A5 IN PROGRESS**, not closure. Runtime checks were intentionally **NOT RUN**
in this bounded documentation turn; retained phase results are attributed, not rerun claims.

### A5 formatting-only preservation follow-up

The prior writer pretty-serialized arrays inside24 otherwise unchanged findings. To avoid that
whole-file formatting side effect, this bounded follow-up restores only those24 raw object spans
from `1763ab55e8da994bc1d854ad8fd2cd2299678b45:FINDINGS_REGISTER.json`. It does not reset/restore Git
files or change parsed data. The six amended and five new object spans remain exactly as they were
before this follow-up, as do current metadata/counts. No new finding, runtime probe or commit.

Executed documentation-only scanner/validator (inline Node, repository working directory). It
tracks quoted strings/escapes and balanced object braces, and compares the complete parsed result
against its in-memory pre-follow-up snapshot before and after the write:

```javascript
const fs=require('node:fs'),cp=require('node:child_process'),assert=require('node:assert/strict');
const file='docs/audit/FINDINGS_REGISTER.json',baseline='1763ab55e8da994bc1d854ad8fd2cd2299678b45';
const before=fs.readFileSync(file,'utf8'),beforeData=JSON.parse(before);
const old=cp.execFileSync('git',['show',baseline+':'+file],{encoding:'utf8'}),oldData=JSON.parse(old);
const amended=new Set(['FND-CONC-001','FND-BUG-004','FND-INTG-002','FND-INTG-004','FND-INTG-007','FND-SEC-004']);
function stringEnd(text,start){for(let i=start+1;i<text.length;i++){if(text[i]==='\\'){i++;continue;}if(text[i]==='"')return i+1;}throw Error('Unterminated JSON string');}
function arrayStart(text){let depth=0;for(let i=0;i<text.length;i++){const ch=text[i];if(ch==='"'){const end=stringEnd(text,i);if(depth===1&&JSON.parse(text.slice(i,end))==='findings'){const match=/^\s*:\s*\[/.exec(text.slice(end));if(match)return end+match[0].length;}i=end-1;}else if(ch==='{')depth++;else if(ch==='}')depth--;}throw Error('Top-level findings array missing');}
function spans(text){const result=[];let i=arrayStart(text);for(;;){while(/[\s,]/.test(text[i]??''))i++;if(text[i]===']')return result;assert.equal(text[i],'{');const start=i;let depth=0;for(;i<text.length;i++){if(text[i]==='"'){i=stringEnd(text,i)-1;continue;}if(text[i]==='{')depth++;else if(text[i]==='}'&&--depth===0){i++;break;}}assert.equal(depth,0);const raw=text.slice(start,i),id=JSON.parse(raw).id;assert(id);result.push({id,start,end:i,raw});}}
const oldSpans=spans(old),currentSpans=spans(before);assert.equal(oldSpans.length,30);assert.equal(currentSpans.length,35);
const original=new Map(oldSpans.map(x=>[x.id,x])),current=new Map(currentSpans.map(x=>[x.id,x]));
const unchanged=oldSpans.filter(x=>!amended.has(x.id));assert.equal(unchanged.length,24);
for(const x of unchanged)assert.deepEqual(JSON.parse(current.get(x.id).raw),JSON.parse(x.raw),x.id+' unchanged data');
const replacements=unchanged.map(x=>({target:current.get(x.id),raw:x.raw})).sort((a,b)=>b.target.start-a.target.start);
let restored=before;for(const x of replacements)restored=restored.slice(0,x.target.start)+x.raw+restored.slice(x.target.end);
assert.deepEqual(JSON.parse(restored),beforeData,'complete pre-follow-up parsed data');
const restoredSpans=new Map(spans(restored).map(x=>[x.id,x]));for(const x of unchanged)assert.equal(restoredSpans.get(x.id).raw,x.raw,x.id+' baseline raw span');
for(const x of currentSpans.filter(x=>!original.has(x.id)||amended.has(x.id)))assert.equal(restoredSpans.get(x.id).raw,x.raw,x.id+' amended/new raw span');
fs.writeFileSync(file,restored);const after=fs.readFileSync(file,'utf8'),j=JSON.parse(after);assert.deepEqual(j,beforeData);const afterSpans=new Map(spans(after).map(x=>[x.id,x]));for(const x of unchanged)assert.equal(afterSpans.get(x.id).raw,x.raw,x.id);
for(const id of amended)assert.deepEqual(j.findings.find(x=>x.id===id).historical_pre_a5,oldData.findings.find(x=>x.id===id),id+' entire history');
const counts={total:j.findings.length,by_severity:{P0:0,P1:0,P2:0,P3:0,P4:0},by_confidence:{Confirmed:0,High:0,Medium:0,Low:0},by_status:{Open:0,'Needs Verification':0,Accepted:0,Fixed:0,Deferred:0,'False Positive':0}};
for(const f of j.findings){counts.by_severity[f.severity]++;counts.by_confidence[f.confidence]++;counts.by_status[f.status]++;}assert.deepEqual(counts,j.counts);assert.deepEqual(counts,{total:35,by_severity:{P0:0,P1:3,P2:24,P3:6,P4:2},by_confidence:{Confirmed:16,High:18,Medium:1,Low:0},by_status:{Open:0,'Needs Verification':3,Accepted:29,Fixed:1,Deferred:0,'False Positive':2}});
const fields=Object.keys(oldData.findings[0]);assert.equal(fields.length,22);for(const f of j.findings)for(const key of fields)assert(Object.hasOwn(f,key),f.id+':'+key);
const md=fs.readFileSync('docs/audit/MASTER_FINDINGS.md','utf8'),heads=[...md.matchAll(/^## (FND-[A-Z]+-\d{3}) \u2014 [^\r\n]+$/gm)];assert.equal(heads.length,35);for(let n=0;n<heads.length;n++){const f=j.findings.find(x=>x.id===heads[n][1]),section=md.slice(heads[n].index,n+1<heads.length?heads[n+1].index:md.length).split('<details>')[0];assert(f);for(const [label,key] of [['Severity','severity'],['Confidence','confidence'],['Status','status']]){const row=section.split('\n').find(x=>x.startsWith('| '+label+' | '));assert(row);assert.equal(row.slice(('| '+label+' | ').length).replace(/ \|$/,'').replace(/\*\*|`/g,''),f[key]);}}
console.log('A5_FORMAT_PRESERVATION PASS parsed_data_unchanged=true baseline_raw_objects_exact=24 amended_new_raw_objects_unchanged=11 json=35 md=35 histories_exact=6 required_fields=22 counts_unchanged=true errors=0');
```

Executed command (repository working directory):

```powershell
@'
const fs=require('node:fs');const md=fs.readFileSync('docs/audit/MASTER_FINDINGS.md','utf8');const tail=md.slice(md.indexOf('\nExecuted documentation-only scanner/validator '));const code=tail.match(/```javascript\n([\s\S]*?)\n```/)[1];new Function('require',code)(require);
'@ | node; "A5_FORMAT_VALIDATOR_EXIT=$LASTEXITCODE"; git diff --check; "A5_FORMAT_DIFF_CHECK_EXIT=$LASTEXITCODE"
```

**PASS**, exact substantive output:

```text
A5_FORMAT_PRESERVATION PASS parsed_data_unchanged=true baseline_raw_objects_exact=24 amended_new_raw_objects_unchanged=11 json=35 md=35 histories_exact=6 required_fields=22 counts_unchanged=true errors=0
A5_FORMAT_VALIDATOR_EXIT=0
A5_FORMAT_DIFF_CHECK_EXIT=0
```

The final recorded wrapper uses an anchored paragraph lookup so its own retained command text
cannot become the source locator. The earlier pre-recording invocation used `lastIndexOf` and
produced the same successful result; no failed formatting/validator attempt occurred in this follow-up.
Git emitted only LF/CRLF notices for the two owned registers and the parent's already-dirty
AUDIT_COVERAGE/A5_TEST_RELIABILITY documents. Those parent files and the existing new UI evidence
were not edited. Only register formatting and this preservation record changed in this follow-up;
all parsed finding/metadata/count data remain identical to the pre-follow-up state.
