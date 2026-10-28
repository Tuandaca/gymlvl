# S1 → S2 Implementation Plan

**Inputs:** `SOURCE_AUDIT.md`, `SKILL_SELECTION.md`, `AGENT_SKILL_MATRIX.md`
**Baseline at planning time:** `main` @ `b4063c68e8a8f35ae2b31297a02fe2e91750ea1a`, clean tree
**Source pin:** `c4a059bbf7a8d6b2162071f0fbfe74053faa6d20`
**Status:** plan only. Nothing below has been executed.

---

## 1. Preconditions S2 must satisfy before writing anything

| # | Precondition | Why | If unmet |
|---|---|---|---|
| P1 | Confirm `main`, HEAD, and `git status --porcelain=v1` | `AGENTS.md` §2 | Stop; report dirty paths |
| P2 | Confirm the exact OpenCode project-level agent/skill directory and config format for the installed Desktop version | The repo has no `opencode.json` and no `.opencode/` | Stop and ask; do not invent a path |
| P3 | Human decision on the existing gitignored `.agent/` (1,043 files) | Avoid a silent third copy | Stop; `BLOCKED` |
| P4 | Human approval of the import list | `AGENTS.md` §0.3 | Stop |
| P5 | A backup of the working tree outside the repo | `AGENTS.md` §8 | Stop |
| P6 | `flutter --version`, `flutter analyze` baseline captured | Needed to detect regressions | Report `BLOCKED` |

P2 is the most likely blocker: OpenCode Desktop's project-level skill location must be confirmed from
the installed version's documentation or CLI, not assumed from the library's own layout.

## 2. Decisions S2 must record first

Add to `docs/planning/DECISIONS.md` as proposed ADRs (MADR-lite, adapted from `architecture-decision-records`):

| ID | Decision | Options | Recommended |
|---|---|---|---|
| D-A | Fate of existing `.agent/` | (a) leave untracked and ignore, (b) delete, (c) adopt as base and upgrade | **(a) ignore; build the system in the OpenCode-native location** |
| D-B | Where adapted skills live | (a) `.opencode/skills/`, (b) `docs/agent-system/skills/`, (c) global config | depends on P2; prefer project-local |
| D-C | Skill format | (a) verbatim upstream `SKILL.md`, (b) adapted with provenance header, (c) rewritten short form | **(b)** |
| D-D | Memory model | (a) file-based only, (b) add MCP vector memory | **(a)** |
| D-E | Agent write permissions | per matrix §8 | as proposed |
| D-F | Whether to track `.agent/` in Git | keep ignored, or track a curated subset | keep ignored |

No ADR is accepted without human approval. Proposals are written, not applied.

## 3. Implementation phases

Each phase ends with a verification gate. Do not start the next phase until the gate passes.

### Phase 0 — Safety and baseline (no content changes)

1. `git rev-parse --abbrev-ref HEAD`, `git rev-parse HEAD`, `git status --porcelain=v1`.
2. Backup the tree outside the repository; verify the backup (bundle clone equals HEAD, archive file
   count equals the Git tree).
3. Capture baselines: `flutter --version`, `flutter analyze`, `flutter test` (record exit codes and the
   summary line).
4. Confirm P2 by locating the installed OpenCode skill/agent directory.

**Gate:** tree state documented, backup verified, baselines recorded, OpenCode paths confirmed.

### Phase 1 — Attribution ledger first

Create `docs/agent-system/THIRD_PARTY_NOTICES.md` **before** importing anything. It must contain, per
module: source URL, pinned SHA, original path, license, upstream provenance (where recorded), and a
statement of adaptation.

Also copy the MIT notice text into the ledger.

**Gate:** every module about to be imported has a complete ledger row. Any module with unknown
provenance is dropped from the import list.

### Phase 2 — Core skill import (wave 1, six skills)

Import adapted, provenance-headered versions of:

| Order | Skill | Adaptation summary |
|---|---|---|
| 1 | `flutter-expert` | Replace Riverpod 2.x with project Riverpod 3 usage; drop Bloc/GetX/MobX recommendations; remove `resources/` dependency |
| 2 | `postgres-best-practices` | Keep RLS/JSONB/index rules; remove Prisma/JS examples |
| 3 | `postgresql` | Keep schema/types/constraints; overridden by additive-only migrations |
| 4 | `test-driven-development` | Remove per-task commits and "delete code" absolutism; map to `flutter test` |
| 5 | `systematic-debugging` | Keep 4-phase method; record `obra/superpowers` provenance |
| 6 | `context-window-management` | Keep tiering/serial-position guidance; verify Apache-2.0 notice compatibility first |

Keep each file short: index plus trigger text, with a provenance header. Do not vendor sub-skill trees
in wave 1.

**Gate:** all six files exist, are readable, carry a provenance header, and contain no script
invocations, Git write commands, or MCP instructions. `grep` for `commit`, `push`, `npm `, `npx `,
`curl`, `http` returns only intentional matches.

### Phase 3 — Agent configuration

Create the seven agents per `AGENT_SKILL_MATRIX.md` §4, in this order:

1. `context-keeper` (needed to record everything else)
2. `gymlvl-orchestrator`
3. `qa-reviewer`
4. `flutter-specialist`
5. `supabase-specialist`
6. `ui-ux-specialist`
7. `exercise-catalog`

Each agent: name, description, mode, and the permission table from matrix §8. Reference skills by ID,
not by pasted content.

**Gate:** seven agent definitions exist; each names only skills that exist after Phase 2 or 3; no agent
has Git write or network permission; the orchestrator is the only primary agent.

### Phase 4 — Rules and workflow adaptation

Adapt the six selected rules into project-owned instruction text (not the upstream file format):

- strict-protocol → keep "no Git writes without approval", drop `GEMINI.md` and `/protocol-reset`.
- code-quality → Dart conventions, not JS/TS.
- database → additive-only, FK indexes; no retrofitted `updated_at`/soft-delete.
- testing-standard → behaviour-first; no arbitrary coverage gate.
- ui-design → Bold Candy only; **dark mode and glassmorphism excluded**.
- security → RLS, Edge secrets, injection; no generic pentest content.

Convert the six workflows into documented procedures or OpenCode commands: `plan`, `orchestrate`,
`test`, `audit`, `debug`, `mobile`. Strip every runtime command from them.

**Gate:** no adapted file references `GEMINI.md`, `walkthrough.md`, `task.md`, `npm start manager`,
`npx`, `.shared/`, `ORCHESTRATION_PROTOCOL.md`, or any script name.

### Phase 5 — Wave 2 import (deferred)

Only after wave 1 survives one real task: import the remaining 14 skills, two at a time, re-running the
Phase 2 gate each time.

## 4. Validation strategy

| Level | Check | Command | Success criterion |
|---|---|---|---|
| V1 | Structure | `Get-ChildItem` on the skill/agent directories | Expected file counts; no stray files |
| V2 | Content hygiene | `grep -RniE 'commit\|push\|npm \|npx \|curl\|GEMINI\|\.shared/' <new dirs>` | Only allowed provenance mentions |
| V3 | Reference integrity | Every path mentioned inside a new skill resolves | 0 broken references |
| V4 | Non-regression | `flutter analyze` | Same or fewer issues than baseline |
| V5 | Non-regression | `flutter test` | Same pass count as baseline |
| V6 | Agent assembly | Invoke each agent with a trivial read-only prompt | Agent loads, cites its skill IDs, does not write |
| V7 | Scope guard | Invoke `qa-reviewer` on a knowingly failing check | Returns `FAIL` with the quoted output |
| V8 | Git neutrality | `git status --porcelain=v1` after the whole phase | Only intended new files; no commits |

V6–V7 are behavioural checks; they must be run, not asserted. If a subagent cannot be invoked in S2's
environment, mark `BLOCKED` and say why.

## 5. Rollback strategy

| Scenario | Rollback |
|---|---|
| Skill content is wrong or unsafe | Delete the single adapted file; it has no dependants in wave 1 |
| Agent definition misbehaves | Revert that one agent file; others are independent |
| `flutter analyze`/`test` regress | Restore the verified external backup; report the diff |
| OpenCode path was wrong | Remove the files from the wrong location and stop; re-confirm P2 |
| Unrelated files modified | Stop immediately; restore from backup; report |

Because nothing is committed, rollback is file-level deletion plus the external backup. That is a
deliberate reason to avoid committing during S2: the recovery path stays simple.

## 6. Risks specific to S2

| ID | Risk | Mitigation |
|---|---|---|
| S2-R1 | Writing to the wrong OpenCode path | P2 gate before any write |
| S2-R2 | Creating a third duplicate skill library | D-A decision before Phase 2 |
| S2-R3 | Importing a module with unknown provenance | Ledger-first phase; drop on doubt |
| S2-R4 | Agent prompts overriding `AGENTS.md` | Adapted agents cite the contract; no imperative "must" from upstream |
| S2-R5 | Context bloat from vendored sub-skills | Wave 1 indexes only; two-module cap |
| S2-R6 | Accidentally tracking `.agent/` | Explicit `.gitignore` check in V8 |
| S2-R7 | Silent regression in Flutter tests | V4/V5 against a recorded baseline |

## 7. S2 exit criteria

- [ ] P1–P6 satisfied and evidenced.
- [ ] `DECISIONS.md` has the approved ADRs.
- [ ] `THIRD_PARTY_NOTICES.md` exists and covers every imported module.
- [ ] Six wave-1 skills exist, adapted, provenance-headered.
- [ ] Seven agents exist with the permission model applied.
- [ ] Six rules and six workflows adapted with no upstream runtime references.
- [ ] V1–V5 pass; V6–V8 executed or explicitly `BLOCKED`.
- [ ] `TASK_BOARD.md`, `SESSION_HANDOFF.md`, `CHANGELOG_AI.md` updated.
- [ ] No commit, push, tag, or deployment performed.
- [ ] Working tree contains only the intended new files.

## 8. Explicit non-goals for S2

- Not starting M1 or M2.
- Not importing exercise data or media.
- Not touching Flutter app code, SQL, UI, or dependencies.
- Not installing MCP servers or running library scripts.
- Not deleting or modifying the existing `.agent/` or `.agents/teamwork/` directories.

---

## 9. Exact next-session prompt (S2)

```text
GYMLVL — S2: MULTI-AGENT CONFIGURATION & SKILL INTEGRATION

You are implementing the agent system designed in S1.

READ FIRST, IN THIS ORDER
1. docs/agent-system/SOURCE_AUDIT.md
2. docs/agent-system/SKILL_SELECTION.md
3. docs/agent-system/AGENT_SKILL_MATRIX.md
4. docs/agent-system/S2_IMPLEMENTATION_PLAN.md
5. AGENTS.md
6. docs/planning/SESSION_HANDOFF.md
7. docs/planning/TASK_BOARD.md
8. docs/planning/DECISIONS.md

BASELINE
main @ b4063c6 (re-verify; do not assume).
Source library pinned at c4a059bbf7a8d6b2162071f0fbfe74053faa6d20.

PRECONDITIONS — STOP AND REPORT IF ANY FAIL
- Confirm branch, HEAD, and clean tree. Stop on unexpected changes.
- Confirm the exact project-level OpenCode skill and agent directory for the
  installed OpenCode Desktop version. Do not guess a path.
- Ask for a decision on the existing gitignored .agent/ directory before
  creating anything: leave-and-ignore (recommended), delete, or adopt.
- Obtain approval for the import list below.
- Create and VERIFY a backup of the working tree outside the repository.

IMPLEMENT IN THIS ORDER
Phase 0  Safety: tree state, backup, flutter analyze + test baselines, path confirmation.
Phase 1  docs/agent-system/THIRD_PARTY_NOTICES.md — attribution ledger FIRST.
Phase 2  Wave 1 skills, adapted, provenance-headered:
         flutter-expert, postgres-best-practices, postgresql,
         test-driven-development, systematic-debugging, context-window-management.
Phase 3  Agents, in order: context-keeper, gymlvl-orchestrator, qa-reviewer,
         flutter-specialist, supabase-specialist, ui-ux-specialist, exercise-catalog.
Phase 4  Adapt 6 rules and 6 workflows per SKILL_SELECTION.md §4-5.
Phase 5  STOP. Do not import wave 2.

MANDATORY ADAPTATIONS
- flutter-expert: Riverpod 3 project usage, not the skill's Riverpod 2.x.
- test-driven-development: remove per-task commits and "delete code" absolutism.
- subagent-driven-development: remove commits and superpowers:* dependencies.
- ui-ux-pro-max / ui-design rule: exclude dark mode, glassmorphism, and any palette.
- database rules: additive migrations only; no down migrations on live data.
- All content: strip scripts, npm/npx commands, MCP installs, GEMINI.md and
  .shared/ references, and every instruction to commit, push, or tag.

VALIDATION — RUN AND QUOTE
- Structure: expected file counts.
- Hygiene: grep for commit|push|npm |npx |curl|GEMINI|.shared/ in new files.
- References: every path mentioned inside a new skill resolves.
- Non-regression: flutter analyze and flutter test vs recorded baseline.
- Behaviour: invoke each agent read-only; confirm it loads and does not write.
- Scope guard: qa-reviewer on a failing check returns FAIL with quoted output.
- Git neutrality: git status shows only intended new files; no commits.

HARD RESTRICTIONS
- No commits, pushes, tags, rebases, or deployments.
- No changes to Flutter app code, SQL, UI, or dependencies.
- No media import. No exercise data import.
- No MCP installation. No execution of external library scripts.
- Do not modify or delete .agent/ or .agents/teamwork/.
- Do not start M1 or M2.

REPORT
Task, status (PASS/FAIL/BLOCKED/NOT RUN), commit, changed files, verification
command -> result, decisions, blockers, and one concrete next action for S3.
```

---

## 10. Handoff to S3

S3 receives: the seven agent definitions, six adapted skills, the notices ledger, the six rules and six
workflows, a recorded baseline, and the V1–V8 evidence. S3 then measures context cost per agent,
tests a real multi-agent task end to end, and tunes the loading budget in matrix §7.
