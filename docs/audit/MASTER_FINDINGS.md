# Master Findings

**Stage:** A2 CLOSED (scoped audit acceptance PASS; deferred work retained; register opened at A0)
**Baseline:** `main` @ `7eb40f1`
**Counts:** 24 findings — P0: 0, P1: 3, P2: 14, P3: 5, P4: 2. Confirmed: 4, High: 18, Medium: 2, Low: 0.
**Status:** 2 `Needs Verification`, 20 `Accepted`, 1 `Fixed`, 1 `False Positive`.

Scales, ID scheme and status vocabulary are defined in `README.md` §§4–7. The machine-readable
mirror is `FINDINGS_REGISTER.json`; the two must always agree.

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

## FND-CONC-001 — Re-entrant discard queue cycle stalls active workout recovery

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

## FND-DATA-001 — Legacy completion path can award a workout twice

| Field | Value |
|---|---|
| Category | `DATA` |
| Component | `public.complete_workout` |
| Path | `supabase/migrations/20261026000200_authoritative_progression.sql` |
| Lines | 216 (function), 223-230 (guards), 255 (cap), 264-278 (writes) |
| Origin | S3 L5 — `supabase-specialist` delegation TEST D (carried, **not re-verified** in A0) |
| Severity | **P1** |
| Confidence | **Medium** |
| Status | `Needs Verification` |
| Wave | W1 |

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
| Status | `Accepted` |
| Wave | W1 |

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

## FND-BUG-001 — The Android release manifest declares no `INTERNET` permission

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

## FND-BUG-002 — The release build is signed with the debug keystore

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

## FND-SEC-001 — Shell secret gates cover a short list of command spellings

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

## FND-BUG-004 — Profile and onboarding use white foregrounds on white Candy panels

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

---

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

## FND-INTG-004 — Adding a timed set defaults to hidden reps and zero displayed duration

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
