# Master Findings

**Stage:** A0
**Baseline:** `main` @ `9c8e142`
**Counts:** 6 findings — P0: 0, P1: 2, P2: 2, P3: 2. Confirmed: 2, High: 2, Medium: 2, Low: 0.
**Status:** 2 `Needs Verification`, 2 `Accepted`, 1 `Fixed`, 1 `False Positive`.

Scales, ID scheme and status vocabulary are defined in `README.md` §§4–7. The machine-readable
mirror is `FINDINGS_REGISTER.json`; the two must always agree.

Findings inherited from `docs/agent-system/S3_VALIDATION_REPORT.md` §10 keep their origin and are
explicitly **unverified** until a stage re-checks them.

---

## FND-CONC-001 — Potential re-entrant deadlock and post-await null dereference in the active workout controller

| Field | Value |
|---|---|
| Category | `CONC` |
| Component | Active workout controller (client) |
| Path | `app/lib/features/workout/presentation/controllers/active_workout_controller.dart` |
| Lines | 207-215, 659-670, 691 |
| Origin | S3 L4 — `qa-reviewer`/`flutter-specialist` delegation TEST C (carried, **not re-verified** in A0) |
| Severity | **P1** |
| Confidence | **Medium** |
| Status | `Needs Verification` |
| Wave | W1 |

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
| Path | `docs/planning/PROJECT_CONTEXT.md`, `AGENTS.md` |
| Lines | `PROJECT_CONTEXT.md` 4-6 (header), 28-40 (`§2 Repository and current baseline`); `AGENTS.md` 6-9 (baseline line) |
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

**Why P3 and not P4.** It is documentation, but it is the document of record for "what is true now".
A wrong SHA in the document that defines source precedence is an operational defect, not cosmetics.
It is not P2 because no invariant or contract is misstated — compare `FND-ARCH-001`.

**Proposed remediation.** Make the baseline block self-updating in form: name the *rule*
("`main` HEAD is authoritative; confirm with `git rev-parse main`") and the last observed SHA with its
date, rather than presenting a fixed SHA as current. Correct the tracked-file count or remove it, since
it changes on every commit. A1 finishes the inventory of stale claims so the fix is a single pass.

**Regression risk.** None. Documentation only.

**Tests.** Not applicable. A durable guard would be a check that fails when the recorded SHA differs
from `git rev-parse HEAD`, which is a possible W4 item but not required.

**Dependencies.** A1 completes the stale-claim inventory; W4 applies the fix.

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
