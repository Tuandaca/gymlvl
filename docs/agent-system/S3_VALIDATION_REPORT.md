# S3 — Multi-Agent Validation Report

**Session:** S3 (validation and optimization, build mode)
**Date:** 2026-10-28
**Baseline:** `main` @ `b4063c6`, carried forward from S1 (discovery) and S2 (Wave 1 install)
**Application:** OpenCode Desktop `2.2.0` (`%LOCALAPPDATA%\Programs\ai.opencode.desktop`)
**Scope:** agent configuration, skills, commands, delegation, permissions, context cost,
documentation, regression. No product code, schema, dependency, CI, or media change.
**Verdict:** `PASS` with three documented limitations (see §10).

---

## 1. Agent validation

Seven agents exist at `.opencode/agents/`. Discovery was exercised at runtime, not inferred from the
filesystem.

| Agent | Mode | Model | Edit policy | Shell policy | Subagent policy | Runtime evidence |
|---|---|---|---|---|---|---|
| `gymlvl-orchestrator` | primary | inherit | deny `*`, allow `docs/planning/*`, `docs/agent-system/*` | deny `*`, 12 read/verify allows | deny `*`, allow the 6 GymLvl agents | Rejected as a subagent: `"Agent gymlvl-orchestrator cannot run as a subagent"` — proves it exists and is primary-only |
| `flutter-specialist` | subagent | inherit | deny `*`, allow `app/lib/*`, `app/test/*` | deny `*`, flutter/dart only | deny `*` | Invoked; read-only assessment returned (§4 TEST C) |
| `supabase-specialist` | subagent | inherit | deny `*`, allow `supabase/migrations/*`, `supabase/functions/*`, `app/supabase/*` | deny `*`, read + flutter test | deny `*` | Invoked; review returned (§4 TEST D) |
| `exercise-catalog` | subagent | inherit | deny `*`, allow `supabase/seed/*`, `docs/catalog/*` | deny `*`, read only | deny `*` | Listed in the runtime subagent catalog |
| `ui-ux-specialist` | subagent | inherit | deny `*`, allow `presentation/*`, `core/theme/*`, `l10n/*` | deny `*`, flutter only | deny `*` | Listed in the runtime subagent catalog |
| `qa-reviewer` | subagent | inherit | **deny `*` only** — read-only | deny `*`, test/analyze/git-read | deny `*` | Invoked twice; returned `FAIL` (§4 TEST A) and executed a failing test (§5) |
| `context-keeper` | subagent | inherit | **deny `*` only** — read-only | deny `*`, git-read | deny `*` | Invoked twice; ran `git rev-parse` and `git status`, wrote nothing (§4 TEST B) |

**Checks performed**

| Check | Result |
|---|---|
| All seven discovered | `PASS` — six subagents invoked or enumerated; primary proven by its rejection as a subagent |
| Primary/subagent roles correct | `PASS` — one `primary`, six `subagent`; no `all` |
| Model assignment | `PASS` — none set; every agent inherits, as designed. No model ID invented |
| Tool permissions least-privilege | `PASS` — every agent has a broad `deny` followed by narrow `allow`; 6 denies each |
| Delegation restricted | `PASS` — `subagent *` denied first, then six named allows on the orchestrator; all other agents deny `subagent *` |
| QA and Context Keeper read-only | `PASS` — `edit` is denied on every path, with no allow rule following |
| No destructive Git permission | `PASS` — no agent allowlist contains `git push`, `git commit`, `reset`, or `rebase`; the global config denies push/reset/clean and asks on commit/tag/rebase/checkout/switch/stash |
| No production database permission | `PASS` — no agent allowlist contains `supabase`, `psql`, or a deploy command |
| No credential material | `PASS` — grep for `service_role`, `SUPABASE_SERVICE`, `eyJhbGciOi`, `sk-…` found nothing |
| No conflicting instructions | `PASS` — one rule per location; §8 lists the only cross-references |

## 2. Skill validation

| Skill | Frontmatter | Description chars | Bytes | Attribution footer | External commands | Dangling refs |
|---|---|---|---|---|---|---|
| `flutter-expert` | valid | 186 | 4,600 | present | none | none |
| `postgres-best-practices` | valid | 172 | 4,882 | present | none | none |
| `postgresql` | valid | 179 | 4,892 | present | none | none |
| `test-driven-development` | valid | 173 | 4,027 | present | none | none |
| `systematic-debugging` | valid | 184 | 4,803 | present | none | none |
| `context-window-management` | valid | 186 | 4,517 | present | none | none |

| Check | Result |
|---|---|
| `SKILL.md` present in each directory | `PASS` — 6/6 |
| `name` and `description` parse | `PASS` — all six; no missing description means all six are advertised |
| Discoverable by the running app | `PASS` — each skill was advertised to the model as it was written (harness announcement at creation time) |
| Loadable | `PASS` — loaded successfully in the S2 verification (`flutter-expert`, `postgres-best-practices`, `test-driven-development`, `systematic-debugging`, `context-window-management` referenced by agents; `postgresql` cited by `supabase-specialist`) |
| Relative reference integrity | `PASS` — no skill references `resources/`, `references/`, `scripts/`, or `sub-skills/`; the six are self-contained |
| Source attribution | `PASS` — each file ends with a provenance footer naming source path, licence, and the adaptation |
| Missing dependencies | `PASS` — none; no skill requires a script, package, or MCP server |
| Incompatible external commands | `PASS` — grep for `npm`, `npx`, `yarn`, `pnpm`, `curl`, `wget`, `docker`, `kubectl`, `terraform` returned nothing |
| Duplicate or conflicting instructions | `PASS` with note — constraints such as "no new dependencies" appear in more than one agent because each agent must enforce it independently; no skill contradicts another |
| Lazy loading | `PASS` — the six are advertised by description only; bodies load on trigger |
| Destructive SQL guidance | `PASS` — the only `DROP`/`TRUNCATE` mentions are prohibitions |

### Commands and configuration

| Item | Result |
|---|---|
| `.opencode/opencode.jsonc` parses | `PASS` — `default_agent=gymlvl-orchestrator`, 11 global rules |
| Six commands present | `PASS` — `plan`, `orchestrate`, `test`, `audit`, `debug`, `mobile` |
| Every command names a resolvable agent | `PASS` — 5 project agents + the built-in `plan` |
| No `!` shell blocks | `PASS` — 0/6; command templates cannot execute shell at expansion time |
| Section numbering in `AGENTS.md` intact | `PASS` — §0–§12 unchanged; the language policy was added as §0.1 to avoid renumbering |

## 3. Language policy

Added as `AGENTS.md` §0.1 (A user-facing Vietnamese, B technical artifacts English, C human action
guides Vietnamese, D enforcement), plus item 8 in §0 and a short `## Language` block in the
orchestrator. It is **not** repeated in any skill or subagent body.

| Verification | Evidence | Status |
|---|---|---|
| Present in the contract | `AGENTS.md` §0.1 | `PASS` |
| Injected into a live session | The harness re-read `AGENTS.md` mid-session and applied the diff to the active instructions | `PASS` |
| Propagated to a subagent | `context-keeper` cited it by section: *"Subagent output, English per §0.1.D."* | `PASS` |
| Applied by a subagent | `supabase-specialist` returned its review in Vietnamese, treating the requester as the user | `DEVIATION` — see §10 L3 |
| Orchestrator instruction | `## Language` block in `.opencode/agents/gymlvl-orchestrator.md` | `PASS` |
| Survives handoff | `SESSION_HANDOFF.md` §0 records the policy and points to `AGENTS.md` §0.1 | `PASS` |
| Not duplicated | grep confirms only `AGENTS.md` holds the full text | `PASS` |

## 4. Delegation execution evidence

All five tests were bounded and read-only. No test wrote a file; no failing test was introduced into
production source.

### TEST A — `qa-reviewer` reviews a deliberately invalid sample → `PASS`

An inline `XpNotifier` fixture (not on disk) that awards +50 XP client-side before calling the
repository. Result, verbatim:

- **Verdict: FAIL**, **Severity: Critical**.
- Finding 1: `state = state + 50` violates *client never persists XP*.
- Finding 2: XP is awarded **before** the network call, so a failed `markComplete` leaves the award
  standing.
- Finding 4: two calls produce +100 — no idempotency.
- Proposed the test that would catch it: call twice, assert XP equals the single server award; make
  the repository throw, assert XP unchanged.

The reviewer labelled the defect correctly, ranked its severity, cited invariant and line, and did not
rewrite the code.

### TEST B — `context-keeper` handoff consistency → `PASS`

- Current task: **S3 — Agent system validation**, status `NEXT`.
- Next action quoted from `SESSION_HANDOFF.md` §0.
- Cross-document agreement: docs agree with each other.
- `git rev-parse --abbrev-ref HEAD` → `main`; `git status --porcelain=v1` → the five modified planning
  files plus the two untracked directories.
- **"Modified files: none."** Confirmed independently by `git status` before and after.
- It also flagged a real defect: `AGENTS.md` still advertised baseline `17ca562` while handoff and
  task board used `b4063c6`. **Fixed** in this session.

### TEST C — `flutter-specialist` module assessment → `PASS`

Target: `app/lib/features/workout/presentation/controllers/active_workout_controller.dart`.

- Pattern: `Notifier<ActiveWorkoutState>` with immutable Freezed state; hand-written
  `NotifierProvider` at `exercise_providers.dart:70-72`; `ref.mounted` guards at L107/129/134/641.
- Riverpod 3.1 + `riverpod_annotation` 4 compatible: **yes** — `ref.mounted` does not exist below 3.0,
  so the file is already on the 3.x surface; hand-written and generated providers coexist.
- Invariants: timers cancelled in `_cleanup` L761-766 and registered via `ref.onDispose` L93; no
  `BuildContext` in the controller; `previewXP` L725-748 is derived only and never written.
- Risk flagged: L207-215 `discardLocalBackup` awaits `cancelWorkout()` from inside `_enqueue`, and
  `cancelWorkout` L691 re-enqueues onto the running `_pending` future → potential deadlock with
  `isLoading` stuck. Also L659-670 dereferences `state.workout!` after an `await` with no re-check.

This is a genuine product finding. **Not fixed** — `app/` is outside S3 scope.

### TEST D — `supabase-specialist` transactional XP review → `PASS`

Target: `public.complete_workout`, `supabase/migrations/20261026000200_authoritative_progression.sql:216`.

- Idempotency is enforced in **two layers**: PK `workout_rewards.workout_id` (L14) with a guard reading
  the prior result (L226-227), and the `w.is_xp_calculated` state check (L229), serialised by
  `FOR UPDATE` on `users` (L223) and `workouts` (L224).
- Double-award with the same id after commit: **not possible** through those two guards.
- Residual risk: L230 still accepts `status='completed'` while `is_xp_calculated=false` (legacy path).
  A legacy row awarded without the flag and without a `workout_rewards` row could award twice;
  **undeterminable from the file alone**.
- Direct-write hole: none found — `REVOKE ALL` (L64), `GRANT SELECT` only (L65), read-only policies
  (L86-89), column-scoped `UPDATE` (L72-74) excluding `total_xp`, `level`, `status`, `is_xp_calculated`.
  Indirect vector: `workout_sets` insert/update is allowed (L75), which can inflate `base_xp` (L235-236),
  bounded only by the 1000 cap (L255) and a heuristic (L239).
- Also identified that XP/level state is written outside `complete_workout` in `initialize_user`
  (L154-155, L142), `sync_daily_data` (L199-212) and `switch_class` (L302-303). These are
  initialisation and recomputation paths, not independent award paths, but the invariant should be
  stated precisely in the architecture document rather than as "only complete_workout writes XP".

The specialist correctly marked its own conclusion `NOT RUN` for runtime verification, because the
migration was not applied in this session.

### TEST E — orchestrator delegation → `PASS` for routing, `NOT RUN` for new-session binding

- Routing exercised: the four tests above were dispatched by domain — review → `qa-reviewer`, state →
  `context-keeper`, Dart → `flutter-specialist`, SQL → `supabase-specialist` — and each returned
  domain-appropriate output.
- `mode: primary` proven: `subagent(gymlvl-orchestrator)` → `"Agent gymlvl-orchestrator cannot run as a
  subagent"`.
- **`NOT RUN`:** that a *new* session binds to `default_agent: gymlvl-orchestrator`. This session
  predates the configuration, and OpenCode does not replace the agent stored on an existing session.
  Verifying it requires starting a new session.

## 5. Deliberate FAIL sanity check

`qa-reviewer` ran `flutter test --plain-name "nonexistent sentinel test for permission validation"`:

```text
RESULT => ALLOWED => exit 1
No tests ran.
No tests match "nonexistent sentinel test for permission validation".
```

The reviewer reported the criterion as `FAIL` and did not attempt to create the test to force a pass.

## 6. Context efficiency

Measurements are byte counts from the filesystem. Token figures are **estimates at 4 characters per
token** and are labelled as such — no tokenizer was run.

| Component | Bytes | Estimated tokens | When it enters context |
|---|---|---|---|
| `AGENTS.md` | 12,738 | ~3,184 | Always (auto-injected) |
| One agent body (average of 7) | 3,730 | ~933 | When that agent runs |
| All seven agent bodies | 26,111 | ~6,528 | Never simultaneously |
| Skill advertisement (6 × id+name+description) | 1,337 chars | ~334 | Every step, metadata only |
| One skill body (average) | 4,620 | ~1,155 | Only when loaded |
| All six skill bodies | 27,721 | ~6,930 | Only if all were loaded — they are not |
| Six command templates | 8,810 | ~2,203 | Only on invocation |

**Findings**

1. **`AGENTS.md` is the dominant always-on cost** at ~3.2k tokens, roughly 3.4× a single agent body.
   It is also the highest-value content. Optimization opportunity for a later session: split the
   rarely-used audit and milestone sections into referenced files, keeping §0–§8 inline. Not done in
   S3 because it would renumber sections that other documents cite.
2. **Skill advertisement is cheap** (~334 tokens for six). Progressive disclosure works as designed:
   the ten-fold larger bodies are not paid until a task needs them.
3. **Per-delegation load is bounded**: one agent body (~933) plus at most two skill bodies (~2,310) ≈
   3.2k tokens of standing instruction. The matrix cap of two modules per task held in every test.
4. **Observed behaviour:** each delegation answered within its word budget (150–250 words). The
   longest was TEST D at ~220 words; none produced a repository scan or a full-file dump.
5. **Redundancy:** the only repeated text is the Git safety floor (configuration, one place) and
   short constraint lines that each agent must enforce itself. No rule text is duplicated across an
   agent, a skill, and a command.
6. **No recursive loops:** no agent can launch a subagent except the orchestrator, and the orchestrator
   launched none of the six from inside a delegation.

## 7. Regression results

| Check | Command | Result | Baseline | Status |
|---|---|---|---|---|
| Flutter analyze | `flutter analyze` | `No issues found!` exit 0 | clean | `PASS` |
| Flutter tests | `flutter test` | `All tests passed!` 126/126 exit 0 | 126 | `PASS` |
| Dart format | `dart format --output=none --set-exit-if-changed lib test` | `Formatted 125 files (0 changed)` exit 0 | clean | `PASS` |
| SQL regression | `npm.cmd test` (tools/db-tests) | `PASS 10 SQL verification units against PostgreSQL 17.5` exit 0 | 10 | `PASS` |
| Edge Functions | `npm.cmd run test:edge` | `ok | 15 passed | 0 failed` exit 0 | 15 | `PASS` |
| Config validation | JSONC parse | valid | valid | `PASS` |

Two additional outputs from the SQL run, both informational: catalog count `150` (target 120–200) and
`0` null/empty metadata fields. The harness also prints a standing limitation: it runs an isolated
single-connection PostgreSQL, so Supabase gateway, Auth, and true concurrent sessions are not covered.

## 8. Configuration issues found and fixed

| # | Issue | Severity | Action |
|---|---|---|---|
| C1 | `AGENTS.md` advertised baseline `17ca562` while handoff and task board used `b4063c6` | Medium | **Fixed** — baseline now names both the checkpoint and the current HEAD, and says to confirm with `git rev-parse main` |
| C2 | `SESSION_HANDOFF.md` §0 said "no tracked file changed", untrue once S3 edited the contract | Low | **Fixed** at the S3 checkpoint |
| C3 | S2 record said the OpenCode version was not obtained | Low | **Fixed** in the S2 record — version 2.2.0 read from the installed application |
| C4 | A subagent shell call was denied when four subagents ran concurrently (`"Permission denied: shell"`, no terminal tool in its catalog); the same agent succeeded when run alone | Medium | **Documented** as an operational rule: run shell-dependent subagents sequentially and retry once if denied. See §10 L1 |
| C5 | `supabase-specialist` answered in Vietnamese instead of English | Low | **Documented**, not "fixed" by instruction — the orchestrator presents all output to the user in Vietnamese regardless, so the practical effect is nil. See §10 L3 |

## 9. Wave 2 recommendations

Do not install wave 2 yet. The Wave 1 set covers every agent's primary domain; adding 14 more indexes
would raise the advertised list from ~334 to ~1.1k estimated tokens and increase selection ambiguity
for no current capability gain.

Recommended order when approved, with the conflict that must be resolved first:

| Order | Skill | Prerequisite |
|---|---|---|
| 1 | `context-management-context-save` | Map its storage model onto the nine memory files; no vector store |
| 2 | `context-management-context-restore` | Same, and must agree with §0.1 on artifact language |
| 3 | `e2e-testing-patterns` | Map Playwright/Cypress to the existing Flutter + Node harness |
| 4 | `code-review-excellence` | Thin upstream content; consider skipping |
| 5 | `architecture-decision-records` | Align with the existing `DECISIONS.md` format rather than adding MADR files |
| 6 | `agent-security-review` | Strip the blockchain module; add RLS and Edge specifics |
| 7 | `data-quality-frameworks` | Only when M2 catalog import starts |
| 8 | `mobile-design`, `ui-ux-pro-max`, `accessibility-*`, `i18n-localization` | Highest conflict risk: dark mode, glassmorphism, palettes, and web ARIA must be excluded before import |
| 9 | `dispatching-parallel-agents`, `subagent-driven-development` | Reconcile with the single-writer rule and the C4 sequential-shell limitation |

## 10. Remaining risks and limitations

| ID | Item | Impact | Owner / next |
|---|---|---|---|
| L1 | Concurrent subagent launches can lose shell access | A parallel review may return `BLOCKED` for a check it could have run | Operational rule recorded; retry sequentially. If it recurs, report it as a harness defect |
| L2 | `default_agent` binding is unverified for new sessions | A new session may still start on `build` | Verify at the start of the next session, before any work |
| L3 | Subagent output language is inconsistent | Cosmetic; the orchestrator translates | Reinforce in the next revision of the orchestrator prompt if it recurs |
| L4 | Potential deadlock in `active_workout_controller.dart` L207-215, and a null dereference at L659-670 | Runtime hang or exception on discard-backup path | **Product defect** — propose as an M1/M3 task; `app/` is out of S3 scope |
| L5 | Legacy `is_xp_calculated=false` path in `complete_workout` L230 could double-award old rows | Data integrity for pre-existing rows | Verify with a targeted SQL test when a live database is available |
| L6 | XP is also initialised in `initialize_user`, `sync_daily_data`, `switch_class` | The stated invariant "only `complete_workout` writes XP" is imprecise | Propose wording change to `ARCHITECTURE.md`; requires approval |
| L7 | Apache-2.0 notice for `context-window-management` (O-10) | Public-release blocker only | Project owner |
| L8 | Authored `.opencode/` content has not been through an independent human review | Normal for a first install | Review the committed diff |

## 11. Conclusion

The seven agents, six skills, six commands, and project configuration are discoverable, loadable, and
correctly restricted. Read-only enforcement is real: `qa-reviewer` and `context-keeper` have no edit
path at all, and both were observed refusing to write. Delegation produced domain-correct output in
all five tests, including two genuine product findings that were documented rather than patched.
Regression matches the recorded baseline exactly: 126 Flutter, 10 SQL, 15 Edge, analyze clean, format
clean.

The system is fit to carry M1 work, subject to L1 (sequential shell-dependent delegation) and L2
(verify the default agent at the next session start).
