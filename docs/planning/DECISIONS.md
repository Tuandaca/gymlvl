# GymLvl — Decision Log

**Status:** Active
**Established:** 2026-10-28
**Baseline:** `main` @ `17ca562` (consolidated 2026-10-28)
**Rule:** Every material change to architecture, schema strategy, licensing, dependency policy, or
milestone scope needs an entry here. Do not silently change a decision.

Status values:

- **ACCEPTED** — approved and in force.
- **PROPOSED** — recommended, not approved; implementation is blocked until accepted.
- **SUPERSEDED** — replaced by a later entry; keep for history.
- **RECORDED** — a fact or constraint, not a choice.

---

## Summary

| ID | Decision | Status | Date |
|---|---|---|---|
| D-001 | Preserve Flutter/Supabase/RPG/Candy architecture | ACCEPTED | 2026-10-27 |
| D-002 | No AGPL code reuse; MIT text only | ACCEPTED for current milestones; long-term posture OPEN | 2026-10-27 |
| D-003 | Third-party exercise media postponed | ACCEPTED | 2026-10-27 |
| D-004 | Re-baseline M1 to release-critical stabilization | PROPOSED | 2026-10-28 |
| D-005 | Drift as the local offline store | PROPOSED | 2026-10-27 |
| D-006 | Import all 1,324 MIT text records | PROPOSED | 2026-10-27 |
| D-007 | AI proposes; user approves; server applies | ACCEPTED (product contract); implementation pending | 2026-10-27 |
| D-008 | PostgreSQL remains authoritative for XP/rewards | ACCEPTED | Existing invariant |
| D-009 | No automatic commits, pushes, or tags | ACCEPTED | 2026-10-28 |
| D-010 | Memory files are the canonical process layer | ACCEPTED | 2026-10-28 |
| D-011 | Baseline is clean `56c1122`; M0's dirty snapshot is historical | RECORDED | 2026-10-28 |
| D-012 | Documentation-only bootstrap; no feature work | ACCEPTED | 2026-10-28 |
| D-013 | External backup required before memory edits | ACCEPTED | 2026-10-28 |
| D-014 | `main` is the sole development branch | ACCEPTED | 2026-10-28 |
| D-022 | Orchestrator may write `docs/audit/**` (nothing wider) | ACCEPTED | 2026-10-28 |
| D-023 | `default_agent` is a session-creation default, not a live switch | RECORDED | 2026-10-28 |

> Rows D-015–D-021 are missing from this summary; their sections exist below. The gap is recorded as
> evidence for `FND-GOV-002` in `docs/audit/MASTER_FINDINGS.md` and is repaired in W4, not here.

---

## D-001 — Preserve the existing platform

**Status:** ACCEPTED
**Context:** GymLvl is a working Flutter + Supabase fitness RPG. OpenGym is a React/Capacitor
application with a different backend.
**Decision:** Keep Flutter, Dart, Riverpod, GoRouter, Supabase/PostgreSQL/Edge Functions, the RPG
class system, and the Candy Neubrutalism design system. Do not migrate the client stack or adopt
OpenGym UI.
**Consequences:** OpenGym capabilities must be reimplemented natively in Dart/SQL or integrated as
data only. No code porting.

## D-002 — Licensing posture: reference-only AGPL, MIT text only

**Status:** ACCEPTED for current milestones (explicit user constraint). The long-term GymLvl license
posture remains OPEN (O-01, O-02).
**Context:** Both OpenGym repositories are AGPL-3.0. OpenGym B's app-store exception is not
transferable. The exercise dataset is MIT for text/data but excludes Gym visual media. GymLvl has no
LICENSE file.
**Decision:** Treat OpenGym code, prompts, catalogue text, and assets as reference-only. Import only
MIT text/metadata with attribution and notice. Do not import media. Do not copy AGPL code without an
approved compliance strategy.
**Consequences:** All OpenGym-derived behavior must be specified and independently implemented. A
clean-room process is required. GymLvl's own license/provenance remains unresolved.

## D-003 — Media postponed

**Status:** ACCEPTED (explicit user instruction)
**Context:** Exercise images/GIFs are proprietary Gym visual media; licensing is unresolved.
**Decision:** No download, hotlink, copy, generation, processing, or integration of third-party
exercise media. No licensing outreach in current milestones.
**Consequences:** The catalog is text/metadata only. `exercise_media` defaults to `unavailable`. Any
media milestone requires explicit authorization and written rights evidence.

## D-004 — Re-baseline M1

**Status:** PROPOSED — M1-01 is the proposed next task; the full six-task M1 scope requires approval
before M1-02.
**Context:** The original M1 (Candy foundation, theme cleanup, shell/auth routing) is already
implemented and verified. The actual blockers are release configuration and stale documentation.
**Decision:** Redefine M1 as release-critical stabilization: baseline evidence (M1-01), platform
config (M1-02), typography cleanup (M1-03), docs truth (M1-04), CI config regression (M1-05), and
rendered baseline screenshots (M1-06).
**Consequences:** No duplicate design-system work. The original plan is preserved; this is recorded
as a scope correction in `MASTER_PLAN.md` §6.

## D-005 — Local storage: Drift

**Status:** PROPOSED — not approved; do not add the dependency yet.
**Context:** GymLvl has no local database. Offline logging, catalog cache, and drafts need durable
local storage. Candidates: Drift, Isar, sqflite, raw SQLite.
**Decision:** Use Drift as the single local store if approved.
**Rationale:** Mature SQLite, typed queries, migrations, testability, good fit for cache + outbox +
drafts. `shared_preferences` remains for lightweight settings.
**Consequences:** Adds a dependency, code generation, and a local schema to maintain. Web/WASM is not
a release requirement. Requires an approved M3 design before implementation.

## D-006 — Catalog import scope

**Status:** PROPOSED
**Context:** The dataset has 1,324 MIT text records; GymLvl has 150 curated exercises. OpenGym B's
6,554-record catalogue is AGPL and cannot be imported.
**Decision:** Import all 1,324 MIT text/metadata records in M2, behind a reviewable ETL, preserving
existing UUIDs and adding source-keyed rows.
**Consequences:** Requires provenance columns, idempotency, search/pagination, and a duplicate-merge
strategy. A curated 300–500 subset remains an acceptable fallback if review capacity is limited.

## D-007 — AI Coach is proposal-based

**Status:** ACCEPTED as a product contract (explicit user requirement). Implementation is pending M6;
no code is authorized yet.
**Context:** The current coach is a chat proxy with no typed output, validation, or approval. The
product requires safe beginner programming.
**Decision:** Build an intake → proposal → validation → user approval → transactional apply/revert
architecture. The AI never writes progression or completed workouts; the deterministic engine owns
load math.
**Consequences:** Requires new coach tables, an Edge gateway, a validator, consent records, audit
logs, and kill switches. Core training remains independent of AI.

## D-008 — Server-authoritative progression

**Status:** ACCEPTED (existing invariant)
**Context:** XP, levels, streaks, quests, PRs, and achievements are progression data.
**Decision:** `complete_workout` is the only award path. Clients may display estimates only. No
client or AI write access to progression tables.
**Consequences:** Any new mode or reward must be validated and awarded server-side. RLS/grants must
not be weakened.

## D-009 — No automatic Git writes

**Status:** ACCEPTED
**Context:** The workspace previously contained 166 uncommitted entries; losing them was the top
risk.
**Decision:** Agents never commit, push, tag, rebase, reset, clean, checkout, switch, or stash
without explicit approval. Checkpoints are recorded as branch/SHA/remote refs; tags require
approval.
**Consequences:** Work may remain uncommitted between sessions. The handoff must state the exact
tree state and preserve a verified external backup when needed.

## D-010 — Canonical memory files

**Status:** ACCEPTED (this bootstrap)
**Context:** M0 produced a report only in a chat transcript; a new session could not find it. The
project needs model-independent continuity.
**Decision:** Maintain the nine files listed in `AGENTS.md` §12 as the canonical process layer:
master index, audit record, project context, architecture, decisions, task board, handoff, and
changelog.
**Consequences:** Every task updates the board, handoff, and changelog. The original master plan is
preserved untouched and referenced, never overwritten.

## D-011 — Bootstrap baseline was `56c1122`

**Status:** RECORDED
**Context:** M0 observed HEAD `e003803` with 166 dirty entries. Between sessions the work was
committed as `56c1122` (381 files, +33,198/−8,080) and pushed to
`origin/codex/supabase-product-audit`.
**Decision:** Treat `56c1122` as the clean baseline. The M0 dirty-state finding is historical, not
current.
**Consequences:** G-02 in the defect register is resolved. The actor/timing of the commit is
unverified. Future audits must record the commit they ran against.
**Superseded by:** D-014 — the current baseline is `main` @ `17ca562`. `56c1122` remains a valid
historical checkpoint.

## D-012 — Documentation-only bootstrap

**Status:** ACCEPTED (explicit user instruction)
**Context:** The user authorized only the persistent memory/handoff system in this session.
**Decision:** Create/update the nine memory files only. Do not start M1 implementation, catalog
import, schema changes, UI refactors, or feature work.
**Consequences:** No application code, SQL, CI, or dependency changes. The next session starts at
M1-01 with explicit approval.

## D-013 — Verified external backup before edits

**Status:** ACCEPTED
**Context:** The user required preservation of the workspace before changes.
**Decision:** Create a Git bundle of all refs and a `git archive` of HEAD outside the working tree,
then verify: bundle clone HEAD == repository HEAD; archive file count == Git tree file count; record
SHA-256 hashes.
**Consequences:** Backup evidence is recorded in `SESSION_HANDOFF.md`. The backup is not a substitute
for an approved commit; it is a recovery artifact.

## D-014 — `main` is the sole development branch

**Status:** ACCEPTED (explicit user instruction, 2026-10-28)
**Context:** Work was split between `main` (`e003803`) and `codex/supabase-product-audit` (`56c1122`),
while the nine memory files were uncommitted on the audit branch. Two active lines risk divergent
baselines and ambiguous handoffs.
**Decision:** Consolidate every commit into `main` and use `main` exclusively for all future
development. The audit branch fast-forwarded into `main` (no merge commit, no rewrite); the nine
memory files were committed as `17ca562` and are now on `main`. `codex/supabase-product-audit` is
retained unchanged for provenance and is not a development target.
**Consequences:** All commits, pushes, and future tasks target `main`; any new branch requires
explicit user authorization. No force push, reset, rebase, or branch deletion was used. `origin/main`
is the canonical remote ref, and local and remote `main` must match after every authorized push.
**Evidence:** `git merge --ff-only` → `e003803..17ca562`; regression suites re-run at `17ca562`
(Flutter 126/126, SQL 10/10, Edge 15/15, analyze clean, format clean); `origin/main` verified at the
pushed commit. Full record in `SESSION_HANDOFF.md`.

## D-015 — Project-local OpenCode agent system in `.opencode/`

**Status:** ACCEPTED (explicit user instruction, 2026-10-28, S2)
**Context:** S1 selected 20 skills and designed seven agents, but the repository had no
`opencode.json` and no `.opencode/` directory. The configuration surface had to be confirmed against
the running OpenCode V2 application rather than assumed.
**Decision:** Install the agent system project-locally at `.opencode/`: `agents/<name>.md`,
`skills/<id>/SKILL.md`, `commands/<name>.md`, and `opencode.jsonc` (`$schema`, `default_agent:
gymlvl-orchestrator`, global permission floor). Agents specify no `model` and inherit the session
model. Wave 1 installs six skills only.
**Consequences:** New sessions default to `gymlvl-orchestrator`; existing sessions keep their stored
agent. The system is versioned with the repository and visible for review. No dependency, CI, or
application change is implied.
**Evidence:** `.opencode/` files; V1–V8 in `docs/agent-system/WAVE1_IMPLEMENTATION.md`.

## D-016 — `qa-reviewer` and `context-keeper` are read-only

**Status:** ACCEPTED (explicit user instruction, 2026-10-28, S2)
**Context:** `AGENT_SKILL_MATRIX.md` gave `qa-reviewer` write access to `app/test/**` and
`context-keeper` write access to `docs/planning/**`. The S2 instruction classified both as read-only.
Two agents able to write tests and the task board creates a self-approval path and a multi-writer risk.
**Decision:** Deny the `edit` action on every path for both agents. `qa-reviewer` may run tests and
read anything but changes nothing. `context-keeper` drafts handoff text and the orchestrator writes it.
`gymlvl-orchestrator` is the sole writer of `docs/planning/**` and `docs/agent-system/**`.
**Consequences:** Tests are authored by implementers and verified by an agent that cannot alter them,
which makes the gate meaningful. Handoff content has one author. The orchestrator's write scope grows.
**Evidence:** Agent permission blocks; `qa-reviewer` reported no write capability.

## D-017 — Wave 1 skills are rewritten, not vendored

**Status:** ACCEPTED (explicit user instruction, 2026-10-28, S2)
**Context:** The upstream library is MIT at repository level but records mixed per-skill provenance
(`obra/superpowers`, `vibeship-spawner-skills` Apache-2.0, `affaan-m`), and several skills assume a
different stack. Verbatim copying would import wrong-stack instructions, script invocations, and
attribution gaps.
**Decision:** Each imported skill is a project-native document that keeps the upstream method, removes
inapplicable stack assumptions and every executable instruction, and credits source path and
provenance in a footer. `docs/agent-system/THIRD_PARTY_NOTICES.md` is the ledger and is written before
import. Sub-skill trees are not vendored.
**Consequences:** Skill text diverges from upstream and must be maintained here. Provenance is
traceable per file. The Apache-2.0 item remains an open release blocker (O-10).
**Evidence:** Six `SKILL.md` files; `THIRD_PARTY_NOTICES.md` §3.

## D-018 — Existing `.agent/` and `.agents/teamwork/` are preserved untouched

**Status:** ACCEPTED (explicit user instruction, 2026-10-28, S2)
**Context:** A gitignored `.agent/` directory (1,043 files, an older edition of the same library) and
the tracked `.agents/teamwork/` (120 files) already existed. Installing a third copy silently would
leave three competing instruction sets.
**Decision:** Leave both untouched. Do not modify, delete, migrate, or re-import from them. The active
system lives only in `.opencode/`. `.agent/` stays gitignored.
**Consequences:** No destructive action on user work. Dead instruction sets remain on disk and must not
be consulted; `.opencode/` is authoritative.
**Evidence:** No `.agent/` or `.agents/` file appears in `git status`.

## D-019 — Git write protection is configuration, not prose

**Status:** ACCEPTED (2026-10-28, S2)
**Context:** `AGENTS.md` §8 forbids automatic commits, pushes, resets, and rebases, but the rule was
only an instruction to the model.
**Decision:** Encode it in `opencode.jsonc` as a global permission floor applying to every agent,
including built-in ones: `deny` for `git push`, `git reset --hard`, `git clean -fd[x]`, and
`git filter-branch`; `ask` for `git commit`, `git tag`, `git rebase`, `git checkout`, `git switch`, and
`git stash`.
**Consequences:** A push cannot be issued by any agent. A commit requires an explicit approval
decision, which is the "explicit approval" the contract requires. A human who wants to commit directly
from a shell is unaffected; an agent that needs a history operation must ask.
**Evidence:** `opencode.jsonc` top-level `permissions`; V2 and V3.

## D-020 — Permanent language policy

**Status:** ACCEPTED (explicit user instruction, 2026-10-28, S3)
**Context:** The project is Vietnamese-owned but its code, schemas, and planning memory are English.
Mixing the two per session caused inconsistent reports and risked translating technical records.
**Decision:** `AGENTS.md` §0.1 is binding and permanent. User-facing communication, progress reports,
blockers and next steps are Vietnamese. Code, identifiers, configuration, agent definitions, skills,
workflows, architecture, task board, changelog, decisions and handoff are English. A document whose
purpose is a manual human operation is Vietnamese, with commands and identifiers unchanged. The full
policy lives only in `AGENTS.md`; agents reference it instead of restating it.
**Consequences:** The orchestrator is the translation boundary; subagents return technical English.
Existing English documents are not retranslated. Changing this policy requires a new decision.
**Evidence:** `AGENTS.md` §0.1; `.opencode/agents/gymlvl-orchestrator.md` `## Language`; a subagent
cited "§0.1.D" in S3.

## D-021 — Shell-dependent subagents run sequentially

**Status:** ACCEPTED (2026-10-28, S3)
**Context:** During S3, four subagents were launched concurrently; the one that needed a shell was
denied (`"Permission denied: shell"`, its catalog exposed no terminal tool). The same agent, invoked
alone, executed `git rev-parse` and `git status` successfully. A similar one-off denial occurred in S2
immediately after an agent file was rewritten.
**Decision:** Launch shell-dependent subagents one at a time, and retry once sequentially if a
permission denial appears. Parallelism is reserved for read-only delegations that do not need a shell.
**Consequences:** Some latency is traded for reliable verification. A recurring denial should be
reported as a harness defect rather than worked around by widening permissions.
**Evidence:** `docs/agent-system/S3_VALIDATION_REPORT.md` §4 TEST B and §10 L1.

## D-022 — The orchestrator may write `docs/audit/**`, and nothing wider

**Status:** ACCEPTED (2026-10-28, A0.1)
**Context:** A0 discovered that no agent profile could write `docs/audit/**` (`FND-GOV-001`). The
orchestrator's edit allowlist covered `docs/planning/*` and `docs/agent-system/*` only, so the audit
program designated an agent that could not persist its own state. A0 artifacts were written by the
built-in build agent instead.
**Decision:** Add exactly one rule, `{ action: edit, resource: "docs/audit/*", effect: allow }`, to
`.opencode/agents/gymlvl-orchestrator.md`, after the existing edit allows. In OpenCode V2 `*` matches
across `/`, so one rule covers `docs/audit/phases/` as well.
**Not granted:** repository-wide write, deployment, database mutation, any additional Git operation, or
access to secret and credential files. No other agent's rules changed. The global Git floor in
`.opencode/opencode.jsonc` is untouched, including `git push *` → `deny`.
**Consequences:** The orchestrator can now author and maintain audit documentation. It still cannot
reach `app/`, `supabase/`, `.github/`, `.opencode/` or `.env`. Read-only agents (`qa-reviewer`,
`context-keeper`) remain read-only. End-to-end verification under the orchestrator profile is pending
and requires a session whose selected agent is the orchestrator.
**Evidence:** `.opencode/agents/gymlvl-orchestrator.md`; `docs/audit/phases/A0_1_GOVERNANCE.md` §3–§4;
OpenCode V2 permissions guide (wildcard and last-match-wins semantics).

## D-023 — `default_agent` is a session-creation default, not a live switch

**Status:** RECORDED (2026-10-28, A0.1)
**Context:** `.opencode/opencode.jsonc` sets `default_agent: gymlvl-orchestrator`, yet the A0/A0.1
session ran as the built-in build agent. The obvious readings — "the config is ignored" and "the
setting applies immediately" — were both tested and rejected.
**Fact:** OpenCode V2 documents `default_agent` as the primary agent used *when a session does not
select one explicitly*. It is read at session creation. Reloading configuration updates the agent
*definition* (the server logged `agent.updated` one second after the file was written) but does not
re-bind an existing session's selected agent.
**Consequences:** A setting-only change can never make a running session switch agents. Confirming the
binding requires a new session, or the user explicitly selecting `gymlvl-orchestrator`. Any report that
claims the orchestrator is active must be backed by an observed permission outcome, not by the config
value. A primary agent is also not reachable through `subagent(...)`; that path is reserved for
subagents.
**Evidence:** `~/.local/share/opencode/log/opencode.log` (`agent.updated` events); OpenCode V2
*Config → Agent*; `subagent(gymlvl-orchestrator)` → `"Agent gymlvl-orchestrator cannot run as a
subagent"`; `docs/audit/phases/A0_1_GOVERNANCE.md` §1.

---

## Open decisions

These remain unresolved and block later milestones:

| ID | Question | Blocks | Owner |
|---|---|---|---|
| O-01 | GymLvl's own license and contributor rights | M8 / distribution | Project owner + legal |
| O-02 | AGPL posture (stay proprietary vs adopt AGPL) | Any OpenGym-derived reuse | Project owner + legal |
| O-03 | Approval of Drift | M3 | Project owner |
| O-04 | Approval of full 1,324 import vs curated subset | M2 | Project owner |
| O-05 | AI provider and cost policy | M6 | Project owner |
| O-06 | Android SDK/device availability | M1-02, M1-05, M8 | Project owner |
| O-07 | Live Supabase project and credential ownership | M2+ verification | Project owner |
| O-08 | Provenance of the 150 curated exercise texts | Catalog trust / M2 | Project owner |
| O-09 | Checkpoint tag name and creation approval | M1-01 | Project owner |
| O-10 | Full Apache-2.0 notice text for the `context-window-management` adaptation, or replacement with an original document | Public release | Project owner |
| O-11 | Whether `.opencode/` and `docs/agent-system/` are committed together or separately | Next authorized commit | Project owner |
