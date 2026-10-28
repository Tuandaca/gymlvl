# Master Findings

**Stage:** A1 (register opened at A0)
**Baseline:** `main` @ `e8c7c8e`
**Counts:** 16 findings — P0: 0, P1: 3, P2: 6, P3: 5, P4: 2. Confirmed: 2, High: 12, Medium: 2, Low: 0.
**Status:** 2 `Needs Verification`, 12 `Accepted`, 1 `Fixed`, 1 `False Positive`.

Scales, ID scheme and status vocabulary are defined in `README.md` §§4–7. The machine-readable
mirror is `FINDINGS_REGISTER.json`; the two must always agree.

Findings inherited from `docs/agent-system/S3_VALIDATION_REPORT.md` §10 keep their origin and are
explicitly **unverified** until a stage re-checks them.

A1 added ten findings (`FND-BUG-001…003`, `FND-TEST-001`, `FND-INTG-001`, `FND-ARCH-002`,
`FND-ARCH-003`, `FND-GOV-004`, `FND-SEC-001`, `FND-GOV-005`) and extended `FND-GOV-002` with the
stale-claim inventory it depends on. All ten are `High`, not `Confirmed`: each is proven by a static
read, and the runtime step that would promote it is recorded as `NOT RUN` with its reason in
`phases/A1_ARCHITECTURE.md` §12.1.

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

**Impact.** No user-visible defect today — parity is exact. The cost is structural: translators and
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
