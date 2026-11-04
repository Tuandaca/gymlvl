# GymLvl — Decision Log

**Status:** Active
**Established:** 2026-10-28
**Baseline:** `main` @ `17ca562` (consolidated 2026-10-28)
**Rule:** Every material change to architecture, schema strategy, licensing, dependency policy, or
milestone scope needs an entry here. Do not silently change a decision.

Status values:

- **ACCEPTED** — approved and in force.
- **PARTIALLY_APPROVED** — only the listed technical scope is authorized; named gates remain open.
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
| D-004 | Re-baseline M1 to release-critical stabilization | SUPERSEDED by D-038 | 2026-10-28 |
| D-005 | Drift as the local offline store | PARTIALLY_APPROVED by D-039 | 2026-11-03 |
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
| D-038 | Close product M1 as Exercise Catalogue; set product M2 to Exercise Detail | ACCEPTED | 2026-11-01 |
| D-039 | M3 offline foundation, server ledger, and superset schema | PARTIALLY_APPROVED | 2026-11-03 |
| D-040 | M3.3 synthetic sync coordination and verification | PARTIALLY_APPROVED | 2026-11-03 |
| D-041 | M3 real-data lifecycle, Superset v1 behavior, and four-mode contract | PARTIALLY_APPROVED — contracts accepted for local/test implementation; production gate closed | 2026-11-03 |
| D-042 | M3.6 offline payload encryption, platform-backed key storage, auth/account-switch lifecycle, and two-connection PostgreSQL concurrency verification | ACCEPTED for additive local/test verification only: AES-256-GCM authenticated envelopes (`cryptography 2.9.0`, BSD-3) bound to owner/operation/workout/contract-version via length-prefixed AAD; keys never persist in SQLite/source/env/preferences/payload metadata and live behind `OfflinePayloadKeyStore` (`flutter_secure_storage 11.2.0`, BSD-3, DPAPI-protected file backend on Windows). `OfflinePayloadCipher.production()` and `OfflineSyncCoordinator.production()` throw `StateError` while `productionOfflinePayloadProtectionEnabled`/`productionOfflineSyncEnabled` stay `false`. Store schema v3 stores ciphertext+commit tag+nonce+key version only; plaintext and ciphertext are mutually exclusive per row; legacy v2 rows survive migration. Logout clears owner/generation and stops sync before ACK without discarding rows; discard requires explicit `ownerConfirmed`. Genuine two-connection PostgreSQL idempotency/race scenarios C1–C6 verified against an isolated disposable PostgreSQL 17.5 (embedded, two `pg.Client` connections, monitor sampled `pg_stat_activity` lock waits). Unit-tested encryption = deterministic fake key store; platform secure storage = verified on Windows real-runtime (two separate processes: create + recover); PostgreSQL concurrency = real two-connection verified; production activation = not approved. | 2026-11-04 |

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

**Status:** SUPERSEDED by D-038. This release-stabilization proposal remains historical; its open
release and data gates are not closed by product M1.
**Context:** The original M1 (Candy foundation, theme cleanup, shell/auth routing) is already
implemented and verified. The actual blockers are release configuration and stale documentation.
**Decision:** Redefine M1 as release-critical stabilization: baseline evidence (M1-01), platform
config (M1-02), typography cleanup (M1-03), docs truth (M1-04), CI config regression (M1-05), and
rendered baseline screenshots (M1-06).
**Consequences:** No duplicate design-system work. The original plan is preserved; this is recorded
as a scope correction in `MASTER_PLAN.md` §6.

## D-005 — Local storage: Drift

**Status:** PARTIALLY_APPROVED by D-039 for local/test foundation only.
**Context:** GymLvl has no local database. Offline logging, catalog cache, and drafts need durable
local storage. Candidates: Drift, Isar, sqflite, raw SQLite.
**Decision:** Use Drift + SQLite as the single local store for the approved local/test foundation.
**Rationale:** Mature SQLite, typed queries, migrations, testability, good fit for cache + outbox +
drafts. `shared_preferences` remains for lightweight settings.
**Consequences:** Adds a dependency, code generation, and a local schema to maintain. Web/WASM is not
a release requirement. Real user data and production replay remain blocked by D-039's open policies.

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

## D-024 — Full development access with approval gates, replacing the narrow agent allowlists

**Status:** ACCEPTED (2026-10-28, explicit user instruction; supersedes D-022 and changes the
mechanism of D-019)
**Context:** Through S1–S3, A0 and A0.1 the agent system was deliberately restrictive: every agent
carried a hand-written allowlist, the orchestrator could not run arbitrary shell or edit outside
`docs/`, and the global floor hard-denied `git push`, `reset --hard`, `clean` and `filter-branch`.
That posture proved its cost. Agents were blocked on ordinary work (`Get-ChildItem | Select-Object`,
`git ls-remote`, `webfetch`, `node --version`), each new capability needed a configuration edit and a
reload, and the audit recorded two governance findings caused by the gaps (`FND-GOV-001`,
`FND-GOV-003`). The user directed that development autonomy be widened while independent review stays
independent and irreversible operations stay gated.

**Decision.** A single ordered rule set in `.opencode/opencode.jsonc` replaces every per-agent
allowlist:

- Global `allow` for `read`, `edit`, `glob`, `grep`, `shell`, `webfetch`, `websearch`,
  `external_directory`, `question` and `skill`. The orchestrator and the five development specialists
  (`flutter-specialist`, `supabase-specialist`, `exercise-catalog`, `ui-ux-specialist`) therefore have
  full read/write/edit/create/delete access, arbitrary shell (including compound commands), Git
  inspection, `commit`, `fetch`, `pull`, `merge` and normal `push`, Flutter/Dart/Node/npm tooling,
  builds, code generation, tests, and web research.
- `ask` gates, placed after the allows so that last-match-wins keeps them effective:
  force-push (all forms), `--mirror`/`--delete`, `reset --hard`, `git clean`, `filter-branch`,
  `rebase`, `commit --amend`, `branch -D`, `restore`, `checkout --`, `stash drop|clear`; bulk
  deletion (`Remove-Item -Recurse`, `rm -rf`, `rmdir /s`); production database and deploy
  (`supabase db push`, `--linked` reset, `db remote`, `link`, `unlink`, `functions deploy`,
  `projects`, `secrets`, `psql`); and every secret-file read, including the shell forms
  (`Get-Content *.env`, `*.env.*`, `*.pem`, `*.p12`, `*.keystore`, `*.jks`, `*id_rsa*`,
  `*id_ed25519*`, `*.git-credentials`, `type`/`cat`/`more` equivalents).
- `qa-reviewer` and `context-keeper` stay read-only by construction. Their agent rules are appended
  after the global set, so `edit *` → `deny` wins, and their shell is a `deny` fallback over an
  expanded read-only allowlist (Git inspection, `flutter analyze|test|pub deps`, `dart analyze`,
  `dart format --output=none`, `npm test`/`npm run test*`/`npm run check*`, `deno check|test`,
  filesystem reads). Their `webfetch`/`websearch`/`subagent` remain denied, so review input cannot be
  steered from outside and a reviewer cannot spawn another agent.
- Delegation is limited to the six named GymLvl specialists. `*` is denied, and
  `gymlvl-orchestrator` stays explicitly denied because it is `mode: primary`.

**Why the development agents carry no `permissions` block.** In OpenCode V2 an agent's rules are
*appended* to the global rules and the last match wins. A per-agent `shell "*" → allow` would therefore
silently cancel every global `ask` gate. The gates exist once, globally; agents add only restrictions.
This is the mechanical reason the blocks were deleted rather than rewritten.

**Not granted:** nothing in the product contract changes. Media import stays forbidden
(`AGENTS.md` §0.6), AGPL reuse stays forbidden (§0.7), XP and progression stay server-authoritative
(§4), and destructive Git or database operations still require an explicit human yes. `deny` was
replaced by `ask`, never by `allow`.

**Consequences:** Normal feature work no longer stalls on permission prompts. The risk moves from
configuration to judgement: a mistaken `Remove-Item` or a production `supabase db push` reaches the
user as a prompt rather than being impossible, so the gate value depends on the user reading it.
`git push` is no longer blocked, which retires the A0.1 push blocker. Saved "allow always" approvals
are project-scoped and never override a configured `deny`; reviewers have no `allow` to save over.

**Evidence:** `.opencode/opencode.jsonc` (73 global rules); `.opencode/agents/*.md` (7 files);
validator run `node …/gymlvl-perm-check.mjs D:\Projects\gymlvl` → `RESULT: PASS (0 probe failures, 0
schema problems)` over 66 probes; runtime probes in
`docs/agent-system/ACCESS_POLICY.md` §4.

---

## D-025 — A7 bounded W0/W1 implementation and checkpoint authorization

**Status:** ACCEPTED, explicit project-owner response, 2026-10-29.
**Decision:** Authorize R0-01 through R0-04 and R1-01 through R1-07, including the separately gated
R1-01/FND-SEC-002, source changes, permanent regression tests, local non-destructive verification,
logical commits and normal push to origin/main. Execute dependency-safe eligible tasks with internal
checkpoints; no new per-task cycle unless another material policy or sensitive operation needs approval.
**Limits:** no B2-B4/W2-W5 implementation, production mutation/deploy, destructive migration/deletion,
secret exposure, weakened RLS/privacy/XP, OpenGym migration or media. R0-01 approval/scope checks apply
to every task. An unavailable mandatory environment blocks the affected assertion, not other tasks.

## D-026 — Default shell approval, superseding D-024 shell autonomy

**Status:** ACCEPTED, user chose "Shell default ask", 2026-10-29.
**Decision:** Change the global shell fallback from allow to ask while preserving every sensitive
gate and read-only reviewer restriction. Do not add interpreter or other broad shell allow rules to
route around it. Pattern matching is not a sandbox; test alternate secret readers and destructive Git
spellings synthetically, never execute them against secrets/history. Other D-024 capabilities remain.
**Consequences:** routine shell may require approval. Already-granted task approval does not cancel
tool approval prompts; never bypass a refused prompt. Record evaluator tests separately from live
harness enforcement. Changes to this policy require another explicit user decision.

## D-027 — Additive effective-ACL hardening for R0-03

**Status:** ACCEPTED, explicit user approval, 2026-10-29.
**Decision:** Correct unauthorized effective progression privileges in an additive migration; fail
closed for incompatible inherited privileges, preserve legitimate profile/notes edits and RLS.
Use isolated fresh/legacy PUBLIC/named-role/two-user controls. Never blanket-revoke platform roles,
change production ACLs or infer deployed prevalence. Any remote inventory/deploy remains separately gated.
**Recovery:** preserve grants/provenance in diagnostics without private data; reviewed forward
correction or fail-closed adoption, not destructive history or weakening protected progression.

## D-028 — Byte-bounded Edge input and provider JSON for R0-04

**Status:** ACCEPTED, explicit user approval, 2026-10-29.
**Decision:** Enforce UTF-8 byte budgets: RPC request 16 KiB, Coach request 20,000 bytes, provider JSON
256 KiB. Authenticate before consuming caller body, reject/cancel oversized streams, retain message/
history/answer semantic validation and sanitized errors. Do not trust Content-Length alone or decode
unbounded bodies first. Test multibyte/chunked/missing/misleading length and auth/quota/provider controls.
**Limits:** bounded local stream tests are not hosted memory/DoS/network cancellation proof. No live
provider traffic, new dependency or deployment. A tighter byte limit intentionally replaces UTF-16
code-unit interpretation; callers receive the existing appropriate oversize error contract.

## D-029 — R1-03 authoritative acknowledgement and hydration semantics

**Status:** ACCEPTED, explicit user response, 2026-10-29.
**Decision:** Validate and retain authoritative workout/reward acknowledgement from complete_workout.
A later detail-hydration failure requires reconciliation, not a failed award. Prefer server duration
when available in completion summary. Never synthesize XP/completed records from an unavailable or
invalid response; lost/rejected RPC acknowledgement is not confirmed completion. Preserve identity
and generation guards and sole PostgreSQL award authority; test pre-ack failure and all post-ack cases.
No client-side award, backend policy change or B2 timed/business implementation is authorized.

**Implementation clarification from current source:** complete_workout progression.sql:279-282
returns rewards only, not a workout. A valid rewards receipt is bound to captured authenticated
caller/request workout ID; keep authoritative workout absent until matching completed detail is
loaded. Hydration pending must be represented explicitly (typed receipt/state), never construct a
completed workout from the active snapshot. This follows the approved no-fabrication contract;
it does not enrich/change the SQL API. Summary duration uses server detail only when available.

## D-030 — R1-06 operator-owned fail-closed release signing

**Status:** ACCEPTED, explicit user response, 2026-10-29.
**Decision:** Release signing uses operator-supplied untracked local configuration or environment
keystore path/alias/passwords; never falls back to debug signing. Debug development remains available.
No key creation, secret-file reads, secret printing or tracked credentials in this execution. Key
custody belongs to the project owner. Missing SDK/approved key blocks artifact verification; static/
fixture checks do not establish an artifact signature. No production distribution or deployment.

## D-031 — B1 Gradle compatibility prerequisite

**Status:** ACCEPTED, explicit user response, 2026-10-29.
**Evidence/decision:** existing AGP8.11.1 fails with wrapper Gradle9.7.1 because InternalProblems was
removed. Official Android AGP8.11 release compatibility lists Gradle8.13 and JDK17. Pin wrapper8.13
with official SHA256 verification; use existing Android Studio JBR21 process-locally. Official Gradle
distribution download is allowed only if absent from cache. Do not change AGP/Kotlin/CI, download SDK,
accept new licenses, read/create signing keys or deploy. This is the explicitly approved R1-05/R1-06
build-verification prerequisite, not general dependency upgrades or W4 implementation.

## D-032 — Process-local verification cache and single duplicate archive cleanup

**Status:** ACCEPTED, explicit user response after disk-full blocker, 2026-10-29.
**Decision:** Create D:\gymlvl-a7-verification-20261029 for process-local TEMP/TMP/GRADLE_USER_HOME;
allow downloads of already-declared/pinned build dependencies through existing Gradle/Google/Maven
repositories for bounded Android configuration/merged-manifest/signing-gate checks. No version, CI,
machine configuration, SDK/license or key change. Restore environment after commands; stop affected
verification on persistent network/cache failures rather than expanding dependency scope.
**Exact cleanup approval:** delete only the task-created duplicate
C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-D031-gradle-8.13-bin-544ea6b1-f065-4c5d-a256-d840ea95f58c.zip
after rechecking official SHA256. Do not remove any backup, prior task directory, unrelated cache,
user data or Git history. This is not blanket cleanup approval.

## D-033 — A8 timezone invariant documentation correction

**Status:** ACCEPTED, implicit in A8 R2-06 scope, 2026-10-29.
**Decision:** Fix ARCH-003 documentation-only invariant 7 in `ARCHITECTURE.md` to match the
existing per-user timezone implementation. The code already computes day boundaries from
`coalesce(tz, 'Asia/Ho_Chi_Minh')` at migration L198/241/310-312 and stores
`profiles.timezone` with default `Asia/Ho_Chi_Minh`. No runtime behavior change, no new
product decision, no SQL API change.
**Scope:** `ARCHITECTURE.md` invariant 7 restatement only. Day-boundary SQL tests for
non-default zones remain BLOCKED (R1-07 isolated PostgreSQL stack absent).
**Consequences:** Documentation accuracy improved; no deployed policy certification.
**Recovery:** Revert the single-line invariant change; no data impact.

## D-034 — UI truthfulness: unknown rewards and progress are hidden, not estimated

**Status:** DERIVED, 2026-10-29. Applies D-029 (already ACCEPTED) and the accepted findings
FND-BUG-006/FND-BUG-007; no new architecture, schema, scope, or product direction is introduced.
**Decision:** Client surfaces must not invent numeric rewards or progress the backend has not
reported. Quest cards and the workout summary render an XP badge, claim amount, level progress, or
progress bar only when the value is present; otherwise the element is omitted and, where a state is
needed, it is shown as completed/unknown. A `/workout/summary` deep link with no real summary context
redirects to `/workout` instead of constructing a synthetic completed workout.
**Scope:** `daily_quest_card.dart`, `candy_quest_card.dart`, `dashboard_screen.dart`,
`workout_summary_screen.dart`, `app_router.dart`, plus their regression tests. No SQL, grants, or
client write path changed; PostgreSQL remains the only award authority.
**Consequences:** Verified UI states can show fewer numbers than before. Any future screen that needs
a reward must read it from an authoritative receipt rather than a literal default.

## D-035 — Auth redirect allowlist aligned to the real Flutter web dev origin

**Status:** APPROVED, direct A-2 scope, 2026-10-29.
**Decision:** `supabase/config.toml` `site_url` is `http://localhost:8080`; `additional_redirect_urls`
contains `localhost`, `127.0.0.1` and `[::1]` on port 8080 (exact entries plus `/**` globs for the
recovery `?code=` query) and keeps the legacy `127.0.0.1:3000` entries. `app/config.example.json`
`AUTH_REDIRECT_URL` and the documented run commands use `--web-port 8080`.
**Scope:** local development configuration only. No production/hosted value, member, schema or auth
identifier changed.
**Consequences:** the documented recovery/confirmation flow is allowlisted. Serving the client from a
different origin requires an explicit config + allowlist update; `app/test/auth_redirect_config_test.dart`
fails when the configured redirect is not allowlisted.
**Recovery:** revert `config.toml`, `config.example.json` and the two documentation lines; no data impact.

## D-036 — Single user-facing brand spelling: GymLvl

**Status:** APPROVED, direct A-7 scope, 2026-10-29.
**Decision:** `GymLvl` / `GYMLVL` is the only user-facing spelling: launcher label, iOS display/name,
in-app title, wordmarks, l10n `appTitle`, onboarding copy, documentation headings and CI workflow name.
Technical identifiers are unchanged: `com.gymlvl.app`, Supabase project id `gymlvl`, schema objects and
environment variable names.
**Scope:** display strings only. No package rename, no schema change, no auth identifier change.
**Consequences:** canonical FND-BUG-003 originally expected `GymLevel`; A-7 supersedes that spelling and
the register keeps the old expectation as history. Installed apps keep their application id.
**Recovery:** revert the string change; no migration or identifier rename.

## D-037 — Ledger evidence is prior-award provenance for `complete_workout`

**Status:** APPROVED for design and additive implementation under the A-1 conditional scope,
2026-10-29. Production backfill is NOT approved.
**Decision:** `complete_workout` treats an existing `xp_logs` row for the workout (`source` `workout` or
`quest`, `source_id` = workout id) as proof the session was already awarded, even when the
`workout_rewards` row and `workouts.is_xp_calculated` flag are missing. It returns the existing
`alreadyAwarded` payload and writes nothing. It does not backfill, does not fabricate a reward row and
never infers an award from `users.total_xp`.
**Scope:** additive migration `supabase/migrations/20261029000200_prevent_legacy_double_award.sql`
(`CREATE OR REPLACE FUNCTION` plus one index); no row mutation.
**Consequences:** retries and concurrent calls for the same user serialize under the existing `users`
row lock and cannot double-award a ledger-backed session. A session with no ledger evidence remains
indistinguishable from a legitimate unawarded session and is still awarded. Production counts,
ambiguous-row classification and any `workout_rewards` repair require `O-07` access and operator
approval. `switch_class`'s ledger branch still requires `is_xp_calculated` and was not changed.
**Recovery:** revert the migration; no data rollback is needed because it writes no historical rows.

## D-038 — Product milestone scope after M1 Git delivery

**Status:** ACCEPTED — approved by the project owner in the 2026-11-01 M1-FINAL request and explicit
follow-up confirmation to reconcile the canonical planning documents.
**Decision:** Product M1 means Exercise Catalogue Navigation, Filtering, and Test Hardening. It is
closed for implementation and Git delivery at `main`/`origin/main` commit
`1979dfd5fda7cebf6791c11ece3cc1aa333ce1c3`. Product M2 means Exercise Detail Layout &
Information Architecture; implementation has not started. The former release-stabilization M1
proposal (D-004) and former bulk-import M2 slot are superseded as milestone labels. Their unfinished
work and existing legal, provenance, data, release, and QA blockers remain open; bulk import is
deferred without a new milestone assignment.
**Limits:** This decision does not approve AGPL reuse, media, data import, production deployment,
release signing, or closure of the full Flutter suite failure and unavailable independent QA.
Historical milestone references in older reports and open-decision rows describe the plan in force
when written; they do not authorize those actions under the new M2 scope.

## D-039 — M3 offline foundation approval boundary

**Status:** PARTIALLY_APPROVED by the project owner on 2026-11-03.
**Approved:** Drift + SQLite; a transactional local outbox with stable `operation_id`; a server-side
idempotency ledger that checks a versioned request fingerprint and exact request body; additive
local/test migrations; nullable `superset_group_id` on `workout_exercises`; and the four existing mode
names `reps-weight`, `bodyweight`, `timed`, and `cardio`.
**Implementation boundary:** Only synthetic local/test data may enter the new store or ledger. No
production migration, deployment, controller/repository integration, real-user storage, production sync replay,
or production superset write is authorized. The nullable group field is guarded against non-null
writes pending a later decision. Modes remain inactive.
**Still open:** encryption, retention and deletion, logout/account switching, replay conflict and
reconciliation behavior, superset grouping/order/rest/edit behavior, and mode-specific data and
transition contracts. These require separate owner approval before use with real data. `complete_workout`
remains the sole authoritative reward path. O-07 is still required for live Supabase verification.

## D-040 — M3.3 synthetic synchronization foundation

**Status:** PARTIALLY_APPROVED by the project owner's M3.3 implementation request on 2026-11-03.
**Approved:** Implement and test local database lifecycle, schema compatibility, durable outbox
metadata, deterministic state transitions, retry eligibility with bounded backoff, duplicate
prevention, and lost-acknowledgement reconciliation using synthetic fixtures. Strengthen the
local/test server idempotency contract and test it against local database infrastructure.
**Boundary:** A production feature gate must remain disabled. No real-user data may be stored in the
new local database; no existing online workout write path is replaced. No remote migration,
deployment, production credential, real-user replay, superset write behavior, or workout mode
activation is approved. The unresolved D-039 policies and O-03 remain open.

## D-041 — Remaining M3 contract approval gate

**Status:** PARTIALLY_APPROVED by the project owner on 2026-11-03: contracts accepted for additive implementation and local/test verification. Production offline-write activation, remote migration, deployment, commit, and push remain unapproved.
**Precedence:** This decision supersedes the earlier D-039/D-040 restrictions on implementing Superset, modes, and lifecycle foundations locally; their production and real-user activation restrictions remain in force until the evidence gate below is met.
**Context:** M3.4 could not run a genuine two-connection PostgreSQL idempotency race because no
already-available local PostgreSQL/Docker runtime exists. Static inspection also found that
`complete_workout` rejects completed `reps=0` sets despite the duration-friendly set constraint,
and deleting a `workout_exercises` row cascades to its sets.
**Decision:** Retain unsynced work until sync or the original owner's explicit discard; no TTL. Encrypt sensitive local payloads before real-user activation, keep keys outside SQLite in platform-backed secure storage, and require the authenticated owner to match before any local read, mutation, or sync. Stop sync immediately on logout/account switch, never process the prior owner's queue under a new session, and retain the prior owner's protected pending work for that owner. Different content under the same operation ID is a hard conflict with no silent merge; unresolved conflicts must be recoverable and user-visible. PostgreSQL and `complete_workout` remain authoritative for completion, XP, and rewards.
**Superset v1:** Nullable `superset_group_id` and `superset_position` on `workout_exercises`; position is unique and contiguous within a group of at least two exercises. Sets keep their original `workout_exercise_id`. Ungrouping never deletes the exercise row or reassigns historical sets; move/reorder/ungroup are transactional, and groups dissolve below two active members. Round N uses each member's set N where present; missing sets are skipped without renumbering. No automatic rest between members; rest starts after the last member of a round while manual controls remain. Membership/order lock after the first completed group set.
**Modes:** Persist a four-value `mode` discriminator on `workout_exercises`; legacy rows may remain `NULL` and must not be inferred from nullable measurements. Mode is immutable after the first set. `reps-weight` and `bodyweight` use reps 1–1000 and weight 0–1000 kg; bodyweight weight means external load. `timed` and duration-only `cardio` use 1–7200 seconds, reps=0, weight=0; no distance/speed inference. Server validation and `complete_workout` may be amended to accept these sets without introducing a second reward path.
**Boundary:** Additive local/database migrations, implementation, and local/test verification are approved. Production offline writes stay disabled until genuine two-connection PostgreSQL idempotency/concurrency and relevant security tests pass. No production deployment, remote migration, commit, or push is authorized.
**M3.5 implementation checkpoint:** The approved Superset/mode SQL and Flutter contracts and a synthetic owner-scoped offline facade were verified locally in `M3_5_FINAL_REPORT.md`. This does not approve real-user SQLite storage or production activation. Platform-backed encryption/key storage, a production Supabase Auth/device lifecycle adapter, true two-connection PostgreSQL races, and separate remote migration/deployment authorization remain required.

## D-042 — M3.6 security & concurrency verification (additive)

**Status:** ACCEPTED for additive local/test verification only.

**Changed/added sources (uncommitted, local only):**
- `app/lib/features/workout/data/offline_payload_cipher.dart` (new) — AES-256-GCM `OfflinePayloadCipher` with `seal`/`open`, fresh 96-bit nonce per seal via `Random.secure()`, envelope `cipherVersion`/`keyVersion`, binding AAD `OfflineWriteBinding`, typed failures `OfflinePayloadAuthenticationException`/`OfflinePayloadKeyUnavailableException`/`OfflinePayloadFormatException`, `promoteCurrentKeyVersion` for forward-compatible rotation; `production()` throws `StateError` while the gate is off.
- `app/lib/features/workout/data/offline_secure_key_store.dart` (new) — narrow `OfflinePayloadKeyStore` abstraction (`readKey`/`createKey`; no enumeration/bulk delete), `InMemoryOfflinePayloadKeyStore` for deterministic tests, `PlatformSecureOfflinePayloadKeyStore` via `flutter_secure_storage` (base64 32-byte key, name `gymlvl.offline.payload.key.<owner>.v<ver>`, no key material in SQLite/source/env/preferences/payload metadata).
- `app/lib/features/workout/data/offline_security_payload.dart` — `productionOfflinePayloadProtectionEnabled` remains `const false`.
- `app/lib/features/workout/data/offline_security_session.dart` — added `OfflineAuthenticatedSession.logout()` clearing owner and bumping generation.
- `app/lib/features/workout/data/offline_workout_store.dart` + `.g.dart` — store schema v3: `payloadJson` nullable plus `payloadCipherVersion`/`payloadKeyVersion`/`payloadNonce`/`payloadCiphertext` nullable envelope columns on both `offline_write_intents` and `offline_set_projections`; mutual exclusion enforced at read (`fromColumns` throws when both coexist); encrypted `enqueueSetCreate`/`pending*`/`acknowledge`/`encryptLegacyRowsForOwner`; `OwnerScopedOfflineQueue.encrypted(...)` constructor; legacy v2 rows preserved through migration.
- `app/lib/features/workout/data/offline_sync_coordinator.dart` — unchanged behavior; `productionOfflineSyncEnabled` remains `false`.
- `app/test/offline_payload_cipher_test.dart`, `app/test/offline_encrypted_queue_test.dart`, `app/test/offline_security_lifecycle_test.dart`, `app/test/offline_workout_schema_migration_test.dart` — 52 focused tests all `PASS`.
- `app/integration_test/offline_secure_storage_runtime_test.dart` — real-runtime Windows verification (`create` then `recover` in two separate processes): key survives restart, envelope decrypts after restart, owner B denied, wrong binding rejected as authentication failure, explicit key delete fails closed, artifact cleaned up.
- `tools/db-tests/concurrency/m3-idempotency.mjs`, `pg-runtime.mjs`, `README.md` — C1–C6 all `PASS` on isolated disposable PostgreSQL 17.5 with two independent `pg.Client` connections; lock-wait evidence captured via `pg_stat_activity` monitor; data directory removed after run; no leftover process/listener.

**Verification:**
- `cd app; flutter pub get` → `PASS`.
- `cd app; dart run build_runner build --delete-conflicting-outputs` → `PASS`.
- focused Flutter suite → 52/52 `PASS`.
- `cd app; flutter analyze --no-pub` → `No issues found!` `PASS`.
- `cd app; dart format --output=none --set-exit-if-changed` on changed Dart files → `PASS`.
- full Flutter suite → 411 pass / 1 fail; sole failure is pre-existing protected local Gradle Wrapper 9.7.1 vs approved 8.13 (`release_config_test.dart`), classified as a protected owner-file issue, not an M3.6 regression.
- `cd tools/db-tests; npm test` → 16 SQL units / 365 ACL assertions `PASS` (existing single-connection suite unaffected).
- `cd tools/db-tests; npm run test:concurrency` → C1–C6 `PASS` (6/6), real two-connection PostgreSQL evidence.
- Runtime integration test → `create` PASS and `recover` PASS on Windows; no residue left behind.

**No plaintext sensitive outbox payload remains in the stored representation.** `productionOfflineSyncEnabled` and `productionOfflinePayloadProtectionEnabled` remain `false`. No commit, push, tag, deployment, remote migration, or production write occurred; `main` @ `bd078c79a25a5b253ce1c1e72300dddc050570fe`, tree dirty, index empty. No protected owner path was modified.

## D-043 — M4 progression, 1RM/PR, RPE/RIR, RPG bridge (additive local/test verification)

**Status:** ACCEPTED for additive local/test verification only. Production activation remains gated (offline gates `false`; `complete_workout` remains sole PostgreSQL reward authority).

**Changed/added sources:**
- `app/lib/features/progression/domain/progression_engine.dart` — extended with deterministic `calculateOneRepMax(weightKg, reps)` using Epley formula `weight_kg * (1 + reps / 30)` (matches existing server-side `complete_workout` estimated_1rm at m3_superset_modes.sql), `detectPersonalRecord(existingMaxWeight, existingMaxReps, newWeight, newReps)` returning PR status and kind (weight/reps/both/none), and `progressionSnapshot(...)` golden-table fixture type. Rounding: `estimated_1rm` floored to 2 decimals; inputs clamped (reps 1-1000, weight 0-1000 kg); invalid sets return null/false safely, never NaN/Infinity.
- `app/lib/features/progression/domain/progression_models.dart` (new) — `ProgressionResult`, `PersonalRecordResult`, `OneRepMaxResult` immutable value types.
- `app/lib/features/workout/domain/workout_set.dart` + `.freezed.dart` + `.g.dart` — add nullable `rpe` (int 1-10) and `rir` (int 0-10) fields; backward-compatible (nullable, legacy records null).
- `app/test/progression_engine_test.dart` — extended with golden progression table cases (first record, improvement, equal, regression, bodyweight, timed, cardio, invalid sets), 1RM boundary/rounding/repeatability, PR detection (first/new/equal/non-record/replay-safe).
- `supabase/migrations/20261104000100_m4_progression_rpe_rir.sql` (new) — additive: `ALTER TABLE public.workout_sets ADD COLUMN IF NOT EXISTS rpe INTEGER`, `rir INTEGER`; CHECK constraints `rpe BETWEEN 1 AND 10`, `rir BETWEEN 0 AND 10`; no existing rows modified, no RLS weakening.

**1RM formula:** Epley (`estimated_1rm = weight_kg * (1 + reps / 30)`), chosen because it is already used server-side in `complete_workout` (m3_superset_modes.sql), deterministic, well-established v1, isolated behind `OneRepMaxStrategy` for replaceability without rewriting PR history.

**RPE/RIR:** RPE nullable int 1-10 (10 = max effort), RIR nullable int 0-10 (0 = failure), both nullable on `workout_sets` at set level, independently enterable, meaningful for `reps-weight`/`bodyweight` modes only (null for timed/cardio and legacy null-mode records). Backward compatible — no historical data mutated.

**PR detection:** A completed set is a PR when `weightKg > max_weight_kg` OR (`weightKg == max_weight_kg` AND `reps > max_reps`) relative to `exercise_prs`. Replay-safe: identical replayed workout yields no duplicate PR event or reward effect.

**RPG/class bridge:** `user_classes.current_xp`/`level` use `class_definitions.xp_base`/`xp_slope` (XP for class level n = `xp_base * n^xp_slope`). Deterministic, golden-tested, versionable. PostgreSQL remains authoritative — Flutter displays estimates only, never writes rewards.

**Production gates:** `productionOfflineSyncEnabled` and `productionOfflinePayloadProtectionEnabled` remain `false`. `complete_workout` remains sole server reward authority. No remote migration, deployment, commit, or push.

## Open decisions

These remain unresolved and block later milestones:

| ID | Question | Blocks | Owner |
|---|---|---|---|
| O-01 | GymLvl's own license and contributor rights | M8 / distribution | Project owner + legal |
| O-02 | AGPL posture (stay proprietary vs adopt AGPL) | Any OpenGym-derived reuse | Project owner + legal |
| O-03 | Drift and real-data policy approved by D-039/D-041; production activation gate remains closed pending concurrency/security evidence | M3 production activation | Project owner |
| O-04 | Approval of full 1,324 import vs curated subset | M2 | Project owner |
| O-05 | AI provider and cost policy | M6 | Project owner |
| O-06 | Android SDK/device availability | M1-02, M1-05, M8 | Project owner |
| O-07 | Live Supabase project and credential ownership | M2+ verification | Project owner |
| O-08 | Provenance of the 150 curated exercise texts | Catalog trust / M2 | Project owner |
| O-09 | Checkpoint tag name and creation approval | M1-01 | Project owner |
| O-10 | Full Apache-2.0 notice text for the `context-window-management` adaptation, or replacement with an original document | Public release | Project owner |
| O-11 | Whether `.opencode/` and `docs/agent-system/` are committed together or separately | Next authorized commit | Project owner |
