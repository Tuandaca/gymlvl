# S2 Wave 1 — Implementation Record

**Session:** S2 (build) — continued from S1 in the same session
**Date:** 2026-10-28
**Baseline:** `main` @ `b4063c68e8a8f35ae2b31297a02fe2e91750ea1a` (`b4063c6`), tree clean at start
except the four untracked S1 documents
**Source pin:** `c4a059bbf7a8d6b2162071f0fbfe74053faa6d20`
**Status:** Wave 1 installed and locally verified. **Not committed.**

---

## 1. Safety preconditions

| # | Precondition | Result |
|---|---|---|
| P1 | Branch, HEAD, tree state | `main` @ `b4063c6`; only `?? docs/agent-system/` |
| P2 | OpenCode configuration surface confirmed | `.opencode/agents/<name>.md`, `.opencode/skills/<id>/SKILL.md`, `.opencode/commands/<name>.md`, config at `.opencode/opencode.jsonc` — from the V2 documentation, not guessed |
| P3 | Existing `.agent/` decision | Preserve untouched (user-approved) |
| P4 | Import list approval | Six Wave 1 skills only (user-approved) |
| P5 | Verified external backup | `C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-s2-backup-20261028\` — `main.bundle` (3,216,779 bytes) verified "records a complete history", plus the four S1 docs |
| P6 | Flutter baseline | `flutter analyze` → `No issues found!` (exit 0); `flutter test` → `All tests passed!` 126/126 (exit 0) |

The `opencode` CLI is not on `PATH` in this shell, so behaviour was validated through the running
application rather than `opencode --version`. Installed application:
`C:\Users\tuand\AppData\Local\Programs\ai.opencode.desktop`, ProductVersion **2.2.0**, with
`resources\opencode-cli.version` = `2.2.0`. The `opencode-cli.exe` file metadata reports `1.4.4`,
which conflicts with the version file; the version-file value and the Desktop product version agree,
so 2.2.0 is treated as authoritative and the metadata discrepancy is noted, not resolved.

The operative fact is that the running V2 application accepted and loaded this configuration:
skills were advertised as they were written, and the six subagents plus the primary agent were
discovered at runtime.

## 2. Files created

```text
.opencode/
├── opencode.jsonc                       project config, schema, default agent, Git floor
├── agents/
│   ├── gymlvl-orchestrator.md           primary
│   ├── flutter-specialist.md            subagent
│   ├── supabase-specialist.md           subagent
│   ├── exercise-catalog.md              subagent
│   ├── ui-ux-specialist.md              subagent
│   ├── qa-reviewer.md                   read-only subagent
│   └── context-keeper.md                read-only subagent
├── skills/
│   ├── flutter-expert/SKILL.md
│   ├── postgres-best-practices/SKILL.md
│   ├── postgresql/SKILL.md
│   ├── test-driven-development/SKILL.md
│   ├── systematic-debugging/SKILL.md
│   └── context-window-management/SKILL.md
└── commands/
    ├── plan.md
    ├── orchestrate.md
    ├── test.md
    ├── audit.md
    ├── debug.md
    └── mobile.md

docs/agent-system/THIRD_PARTY_NOTICES.md   attribution ledger (written first)
docs/agent-system/WAVE1_IMPLEMENTATION.md  this record
```

Nothing outside `.opencode/` and `docs/` was created or modified. No application code, SQL, schema,
UI, dependency, CI, or media change.

## 3. Configuration decisions

| Decision | Value | Reason |
|---|---|---|
| Config location | `.opencode/opencode.jsonc` | Keeps the agent system in one directory; project-scoped |
| `default_agent` | `gymlvl-orchestrator` | New sessions start routed; existing sessions keep their stored agent |
| Model assignment | **none** — every agent inherits | Avoids inventing a model ID; inherits the parent/session model |
| Global permission floor | deny `git push`, `reset --hard`, `clean -fd[x]`, `filter-branch`; ask `commit`, `tag`, `rebase`, `checkout`, `switch`, `stash` | Encodes `AGENTS.md` §8 for every agent, including the built-in `build` agent |
| Agent permissions | ordered deny-then-allow lists | Last matching rule wins; broad deny first, narrow allow after |
| Skill permission | unrestricted | The inventory is six project skills plus built-ins; a hard deny risked breaking legitimate skill use. Laziness is already enforced by OpenCode's index-then-load design |
| Subagent catalog | orchestrator may launch exactly the six GymLvl agents | Least-privilege delegation; `subagent *` denied first |
| Web access | denied for all seven | External content is untrusted; no agent needs it |
| External directories | denied for all seven | Project is self-contained; prevents reads outside the workspace |

## 4. Agents

| Agent | Mode | Write scope | Shell | Subagents | Web |
|---|---|---|---|---|---|
| `gymlvl-orchestrator` | primary | `docs/planning/*`, `docs/agent-system/*` | git/flutter read + verify | six allowed | denied |
| `flutter-specialist` | subagent | `app/lib/*`, `app/test/*` | flutter/dart only | denied | denied |
| `supabase-specialist` | subagent | `supabase/migrations/*`, `supabase/functions/*`, `app/supabase/*` | read + flutter tests | denied | denied |
| `exercise-catalog` | subagent | `supabase/seed/*`, `docs/catalog/*` | read only | denied | denied |
| `ui-ux-specialist` | subagent | `app/lib/features/*/presentation/*`, `app/lib/core/theme/*`, `app/lib/l10n/*` | flutter only | denied | denied |
| `qa-reviewer` | subagent | **none** (`edit *` denied) | test/analyze/git read | denied | denied |
| `context-keeper` | subagent | **none** (`edit *` denied) | git read only | denied | denied |

`qa-reviewer` and `context-keeper` are read-only by construction: `edit` is denied for every path, so
they cannot write even inside their nominal interest area. This is a deliberate change from
`AGENT_SKILL_MATRIX.md` §4.6/§4.7, which had granted them write scope. The orchestrator now owns all
planning-document writes, and `context-keeper` drafts text for it. See D-016.

## 5. Skills

| Skill ID | Source path | Upstream provenance | Adaptation |
|---|---|---|---|
| `flutter-expert` | `.agent/skills/flutter-expert/` | repository original | Riverpod 3.1 replaces 2.x; Bloc/GetX/MobX/Provider/Stacked removed; web/desktop scope removed |
| `postgres-best-practices` | `.agent/skills/postgres-best-practices/` | repository original | Prisma/JS removed; additive-migration and award-path invariants added |
| `postgresql` | `.agent/skills/postgresql/` | repository original | Condensed to schema design; partitioning, PostGIS, pgvector, TOAST removed |
| `test-driven-development` | `.agent/skills/test-driven-development/` | repository original | "Delete production code" replaced with preserve-user-work; commits removed; mapped to `flutter test` |
| `systematic-debugging` | `.agent/skills/systematic-debugging/` | **`obra/superpowers`** | Upstream is an index; method written out and mapped to Flutter/Supabase layers |
| `context-window-management` | `.agent/skills/context-window-management/` | **`vibeship-spawner-skills` (Apache-2.0)** | Index only; file-based adaptation, no vector store or external memory |

Each file carries an inline provenance footer naming the source path, licence, and what was changed.
Sub-skill trees were not vendored — the six indexes are self-contained, which is the wave-1 context
budget decision.

## 6. Rule mapping

The six selected upstream rules were **not** copied as standalone files: that would duplicate
`AGENTS.md` and add always-on context. Each rule was placed where it is enforced or actionable.

| Upstream rule | Where it landed | What was dropped |
|---|---|---|
| `strict-protocol` | `opencode.jsonc` global permission floor (enforced, not prose) | `GEMINI.md` dependency, `/protocol-reset` |
| `code-quality` | `flutter-specialist` body: `const`, keyed lists, no I/O in `build`, async guards, disposal | JS/TS naming conventions |
| `database` | `supabase-specialist` body + `postgres-best-practices` skill | "always add updated_at", retrofit soft-delete |
| `testing-standard` | `qa-reviewer` body + `test-driven-development` skill | Arbitrary coverage percentages |
| `ui-design` | `ui-ux-specialist` body | Dark-mode mandate, glassmorphism, alternate palettes |
| `security` | `supabase-specialist` (RLS, service-role, `search_path`) + `qa-reviewer` audit dimensions | Pentest/incident-response material |

No rule text is duplicated across an agent body, a skill, and a command. The only repetition is the
short safety floor in `opencode.jsonc`, which is configuration rather than instruction.

## 7. Commands

| Command | Agent | Purpose |
|---|---|---|
| `/plan` | `plan` (built-in) | Plan without editing; approval gate at the end |
| `/orchestrate` | `gymlvl-orchestrator` | Multi-domain routing with a mandatory verification phase |
| `/test` | `qa-reviewer` | Run and report tests with evidence |
| `/audit` | `qa-reviewer` | Ten-dimension compliance audit against `AGENTS.md` |
| `/debug` | `gymlvl-orchestrator` | Four-phase investigation, then route the fix |
| `/mobile` | `ui-ux-specialist` | Mobile-first screen work with locale and width checks |

No command contains a `!` shell block. Arguments use `$ARGUMENTS`.

## 8. Validation evidence

| Gate | Check | Result | Status |
|---|---|---|---|
| V1 | Structure | 7 agent files, 6 skill dirs each with `SKILL.md`, 6 command files | `PASS` |
| V2 | Config validity | JSONC parses; `default_agent=gymlvl-orchestrator`; 11 top-level rules | `PASS` |
| V3 | Content hygiene | Only intentional hits: the `git push *` and `git commit *` permission rules in `opencode.jsonc`. No `npm`/`npx`/`curl`/`GEMINI.md`/`.shared/`/script references | `PASS` |
| V4 | Reference integrity | All skill IDs referenced by agents resolve; all six command `agent:` targets resolve | `PASS` |
| V5a | Non-regression analyze | `flutter analyze` → `No issues found!` exit 0 | `PASS` |
| V5b | Non-regression test | `flutter test` → `All tests passed!` 126/126, exit 0 | `PASS` |
| V6 | Agent discovery | Six subagents enumerable and invocable; skills advertised by the running app as they were written; `subagent(gymlvl-orchestrator)` rejected with "Agent gymlvl-orchestrator cannot run as a subagent", proving it exists with `mode: primary` | `PASS` |
| V7 | Deliberate FAIL | `qa-reviewer` ran `flutter test --plain-name "nonexistent sentinel test…"` → exit 1, `No tests ran. No tests match …`, and labelled the criterion `FAIL` in an earlier run | `PASS` (after one retry, see below) |
| V8 | Git neutrality | `git status --porcelain=v1` → `?? .opencode/`, `?? docs/agent-system/` only. No commits | `PASS` |

### V7 note — a real transient failure

The first `qa-reviewer` invocation was denied at the shell layer
(`{"error":{"type":"permission.rejected","message":"Permission denied: shell"}}`) and reported that no
terminal tool was exposed to it. A diagnostic run immediately afterwards executed `git rev-parse`,
`flutter analyze`, `flutter --version`, and `Get-ChildItem` successfully, and the failing `flutter test`
then ran and returned exit 1 with quoted output. The likely cause is the agent definition being
rewritten moments before the first invocation, with the subagent catalog partially reloaded. It was
not reproducible on retest. Recorded rather than hidden: a first-run denial after config changes is a
known risk and the retest is the evidence.

## 9. Deviations from `S2_IMPLEMENTATION_PLAN.md`

| Plan said | Implemented | Why |
|---|---|---|
| `qa-reviewer` may write `app/test/**` | Fully read-only | User instruction: "qa-reviewer — read-only subagent". Tests are written by implementers and reviewed, not silently rewritten |
| `context-keeper` may write `docs/planning/**` | Read-only; drafts only | User instruction plus single-writer safety: the orchestrator applies all planning writes |
| Rules adapted as standalone files | Placed into agent bodies and skills | Avoids duplicating `AGENTS.md` and adding always-on context |
| Agent templates re-authored | Not imported at all | The seven agents were written from the routing matrix; upstream templates assume another CLI |
| Model IDs configured | Inherited | No verified project model ID; inheritance is the honest default |

## 10. Open items

| # | Item | Owner | Blocks |
|---|---|---|---|
| 1 | Full Apache-2.0 text for the `context-window-management` adaptation, or replace it with an original document | Project owner | Public release only |
| 2 | Wave 2 import of the remaining 14 skills | S3+ | Nothing yet |
| 3 | Behavioural latency/cost measurement per agent | S3 | Tuning the loading budget |
| 4 | `TASK_BOARD.md` previously claimed a clean tree; it now records the two untracked directories | Done in this session | — |

## 11. Next action

Run S3: exercise the system on one real bounded task, measure the context each agent loads, and tune
the routing matrix. Do not begin wave 2 until that is recorded.
