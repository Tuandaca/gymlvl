# A0 — Bootstrap, Scope Inventory and Execution Planning

**Date:** 2026-10-28
**Baseline:** `main` @ `9c8e142` (= `origin/main`), working tree clean at entry
**Acting agent:** built-in build agent (`gymlvl-orchestrator` was **not** active — see §5)
**Status:** `PASS` with one governance gap recorded (`FND-GOV-001`)
**Writes:** `docs/audit/**` only, plus the planning files named in `AGENTS.md` §6

---

## 1. Baseline verification

| Check | Command | Result | Status |
|---|---|---|---|
| Branch | `git rev-parse --abbrev-ref HEAD` | `main` | `PASS` |
| HEAD | `git rev-parse HEAD` | `9c8e142a2bda18d031874438164c37c577dcc057` | `PASS` |
| Expected S3 checkpoint | compare to `9c8e142` | match — HEAD has not advanced | `PASS` |
| Working tree | `git status --porcelain=v1` | empty | `PASS` |
| Remote | `git ls-remote origin refs/heads/main` | `9c8e142…` — identical | `PASS` |
| Recent history | `git log --oneline -5` | `9c8e142`, `59450c0`, `b4063c6`, `17ca562`, `56c1122` | `PASS` |

Nothing was reset, stashed, or checked out. No user change was present, so the "preserve unexpected
work" branch of the rule did not trigger.

## 2. Agent and tooling status

| Item | Observed | Status |
|---|---|---|
| Agents present | 7 files under `.opencode/agents/` | `PASS` — inspection |
| Skills present | 6 directories under `.opencode/skills/` | `PASS` — inspection |
| Commands present | 6: `plan`, `orchestrate`, `test`, `audit`, `debug`, `mobile` | `PASS` — inspection |
| Config | `.opencode/opencode.jsonc` parses; `default_agent = gymlvl-orchestrator`; 11 global rules | `PASS` — inspection |
| `gymlvl-orchestrator` active | **No** — see §5 | `FAIL` against intent |
| Delegation available | `subagent` tool present; six GymLvl subagents addressable | `PASS` — inspection |

These are file-level facts. Agent **discovery** was proven in S3 at runtime and is not re-proven here;
a new session's binding is checked in §5.

## 3. Inventory (measured, not estimated)

| Area | Files | Lines |
|---|---|---|
| `app/lib/**` Dart | 111 | 18,673 |
| `app/test/**` Dart | 14 | 2,453 |
| `supabase/migrations/*.sql` | 3 | 1,222 |
| `supabase/tests/*.sql` | 2 | 170 |
| `supabase/functions/**` TypeScript | 12 | 443 |
| `tools/**` (excl. `node_modules`) | 16 | 2,018 |
| `.github/workflows/verify.yml` | 1 | 58 |

`app/lib` composition (111 files, 17 of them generated): `presentation` 37, `ui` 23, `domain` 13,
`core` 9, `data` 4, other 8.

Database: 17 tables, 44 RLS policies, 11 `SECURITY DEFINER` functions, 15 distinct functions across
18 definitions, 10 triggers.

Edge Functions are thin: `calculate-xp` 4 lines, `get-user-stats` / `initialize-user` /
`sync-daily-data` 2 lines each, `switch-class` 5 lines. All behaviour lives in `_shared/http.ts` (46
lines) and the RPC it invokes, so `_shared/http.ts` is the single point of failure for all six.

Largest hand-written files:

| Lines | File |
|---|---|
| 1,284 | `app/lib/features/onboarding/presentation/screens/onboarding_screen.dart` |
| 1,201 | `app/lib/features/profile/presentation/screens/profile_screen.dart` |
| 700 | `app/lib/features/workout/presentation/controllers/active_workout_controller.dart` |
| 534 | `app/lib/features/dashboard/presentation/screens/dashboard_screen.dart` |
| 519 | `app/lib/features/workout/presentation/screens/active_workout_screen.dart` |
| 459 | `app/lib/features/workout/presentation/screens/workout_summary_screen.dart` |

## 4. High-risk audit targets

Ranked by blast radius × reachability, not by size alone. Each becomes a named work item in A1–A5.

| # | Target | Why it is high risk | Stage |
|---|---|---|---|
| H1 | `public.complete_workout` + the 44 RLS policies + 11 `SECURITY DEFINER` functions | Single award path for XP, level, streak, quests and PRs; a mistake here forges progression. `SECURITY DEFINER` bypasses RLS by design, so `search_path` and grant hygiene matter. | A3, A4 |
| H2 | `active_workout_controller.dart` | 700 lines owning the serialized request queue, two timers, a `shared_preferences` backup, and pill/banner state. One confirmed candidate already (`FND-CONC-001`). Loss of an in-progress workout is the most user-visible failure in the product. | A2, A4 |
| H3 | `_shared/http.ts` | Every Edge Function is a two-line wrapper. Auth forwarding, token validation, JSON shape and error sanitisation are implemented once, so one defect is six defects. | A3 |
| H4 | Client\(\leftrightarrow\)server contract (`features/*/data/**` → RPC) | The client computes `previewXP`; the server computes the authoritative award. Any divergence between the two produces a lie in the UI even when the database is correct. RPC parameter names are positional in Edge wrappers and can drift silently. | A4 |
| H5 | Quest day boundary (`quest_date`, `timezone` default `Asia/Ho_Chi_Minh`, unique index on `(user_id, quest_date)`) | Timezone and DST defects produce missed or duplicated daily quests, and a partial unique index allows legacy duplicates by design. | A4 |
| H6 | `onboarding_screen.dart` (1,284) and `profile_screen.dart` (1,201) | Very large stateful screens: widget-held state, validation, and localization all in one file. Highest concentration of untested UI logic. | A2 |
| H7 | Local backup path (`shared_preferences` snapshot, restore, discard) | The only client-side durability mechanism. Silent staleness or a failed restore is data loss from the user's point of view. | A2 |
| H8 | Test infrastructure (no golden tests, no coverage measurement, single-connection PostgreSQL) | The baseline is 126 tests, but their coverage is unknown. This is what allows H1–H7 defects to persist. | A5 |
| H9 | CI `verify.yml` | Runs the suite and a web build with placeholder Supabase variables. No Android build, no iOS build, no live-stack test. Green CI therefore says less than it appears to. | A1 |
| H10 | Catalog seed + metadata migration | 150 curated rows with a slug trigger; provenance is a licensing risk as well as a data risk. | A3 |

## 5. Active agent — observed, and why it matters

**Observation.** The active agent is the built-in **build** agent, not `gymlvl-orchestrator`.

**Evidence.** Under the orchestrator profile, `edit` is denied on `*` with allows only for
`docs/planning/*` and `docs/agent-system/*` (`gymlvl-orchestrator.md` L7-14), and `external_directory`
is denied on `*` (L87-89). In this session the following succeeded: editing `.opencode/opencode.jsonc`
twice at the S3 checkpoint, writing to
`C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-s3-commit-msg.txt`, and writing
`docs/audit/README.md` now. Each of those is denied for the orchestrator. Conclusion: the orchestrator
profile is not in effect. Confidence `High`.

**Consistency with prior records.** This matches S3 L2 (`default_agent` binding unverified for a new
session). The session was created before `default_agent` was configured, and OpenCode does not
retro-apply an agent to an existing session. A0 therefore adds a *new datapoint* rather than a new
finding: the binding has still not been observed to apply.

**Consequences for this audit.**

1. The mission's instruction to "use `gymlvl-orchestrator` as the coordinating agent" cannot be
   followed literally in this session. The acting agent performed the coordination itself and
   delegated to the six specialists, which is the same routing table the orchestrator would apply.
2. Artifact writes succeeded, but through an agent the program did not designate. This is recorded as
   `FND-GOV-001`, because the *designated* agent has no write path to `docs/audit/**` at all.
3. The next session must start by checking the active agent. If it is still `build`, the choice is
   between proposing the W0 configuration change and continuing with the gap documented.

## 6. Baseline regression re-run (A0)

Run at `9c8e142`, before any audit write:

| Command | Result | Status |
|---|---|---|
| `flutter analyze` | `No issues found!` exit 0 | `PASS` |
| `flutter test` | `All tests passed!` 126/126 exit 0 | `PASS` |
| `npm.cmd test` (`tools/db-tests`) | `PASS 10 SQL verification units against PostgreSQL 17.5` exit 0 | `PASS` |
| `npm.cmd run test:edge` | `ok | 15 passed | 0 failed` exit 0 | `PASS` |

These reproduce the S3 baseline exactly. The harness limitation is quoted by the harness itself:
`isolated single-connection PostgreSQL; Supabase gateway/Auth/Edge runtime and true concurrent
sessions require the local stack`.

## 7. Findings created at A0

| ID | Title | Sev | Conf | Status |
|---|---|---|---|---|
| `FND-CONC-001` | Re-entrant deadlock + post-await null deref in active workout controller | P1 | Medium | `Needs Verification` |
| `FND-DATA-001` | Legacy completion path can award twice | P1 | Medium | `Needs Verification` |
| `FND-ARCH-001` | XP write invariant narrower than implementation | P2 | High | `Accepted` |
| `FND-GOV-001` | No agent can write `docs/audit/**` | P2 | Confirmed | `Accepted` |
| `FND-GOV-002` | `PROJECT_CONTEXT.md` stale on its own baseline | P3 | Confirmed | `Accepted` |
| `FND-GOV-003` | Shell matcher semantics for chained commands | P3 | Low | `Needs Verification` |

Three of these are imported from S3 (L4, L5, L6) and explicitly remain unverified.

## 8. Method for the next stages

- One stage per instruction. No auto-advance.
- One writer per file; subagents review, the coordinating agent writes.
- Shell-dependent subagents run **sequentially** (D-021).
- Every stage updates `FINDINGS_REGISTER.json`, `MASTER_FINDINGS.md`, `AUDIT_COVERAGE.md`, and
  `SESSION_HANDOFF.md` before it is considered closed.
- Reads are scoped: a stage opens only the files its findings require, not the whole tree.

## 9. Exact next action

Stage **A1 — Architecture, dependencies, configuration and infrastructure**, under the prompt given in
`SESSION_HANDOFF.md` §6. Do not begin A1 without that instruction.
