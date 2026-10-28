# GymLvl — AI Changelog

Dated record of agent sessions and project checkpoints. Newest first.

**Rules:** one entry per session/checkpoint; list exact files, commands, and statuses; never claim a
test that was not run; distinguish prior-session evidence from current-session evidence.

---

## 2026-10-28 — S3 validation, language policy, and first infrastructure checkpoint

**Task:** S3 — Multi-agent validation and optimization.
**Status:** `PASS`
**Baseline:** `main` @ `b4063c6` at start; infrastructure checkpoint `59450c0` pushed to `origin/main`.
**Scope:** Validation, documentation, agent configuration, and an authorized Git checkpoint. No
application code, SQL, Edge Function, CI, dependency, UI, or media change.

### Added

- `docs/agent-system/S3_VALIDATION_REPORT.md` — agent matrix, skill matrix, five delegation tests,
  context measurements, regression results, risks, Wave 2 recommendations.
- `AGENTS.md` §0.1 — permanent language policy (Vietnamese user-facing, English artifacts, Vietnamese
  human action guides), plus item 8 in §0.

### Changed

- `.opencode/agents/gymlvl-orchestrator.md` — `## Language` block referencing §0.1.
- `AGENTS.md` — baseline line now names both `17ca562` and the current HEAD, and says to confirm with
  `git rev-parse main`.
- `docs/planning/DECISIONS.md` — D-020 language policy, D-021 sequential shell-dependent subagents.
- `docs/planning/TASK_BOARD.md` — S3 `DONE`, S4 `PLANNED`; M1 unchanged.
- `docs/planning/SESSION_HANDOFF.md` — current state reset to S3 close.

### Verification

| Command | Result | Status |
|---|---|---|
| `flutter analyze` | `No issues found!` exit 0 | `PASS` |
| `flutter test` | `All tests passed!` 126/126 exit 0 | `PASS` |
| `dart format --set-exit-if-changed lib test` | `125 files (0 changed)` exit 0 | `PASS` |
| `npm.cmd test` (SQL) | `PASS 10 SQL verification units against PostgreSQL 17.5` exit 0 | `PASS` |
| `npm.cmd run test:edge` | `ok | 15 passed | 0 failed` exit 0 | `PASS` |
| Config JSONC parse | valid, 11 global rules | `PASS` |
| Agent discovery | 6 subagents invoked/enumerated; primary rejected as a subagent | `PASS` |
| Read-only enforcement | `qa-reviewer` and `context-keeper` have no edit rule; neither wrote | `PASS` |
| Delegation TEST A | Invalid XP fixture → `FAIL`, severity Critical | `PASS` |
| Delegation TEST B | State restored; git commands ran; no writes | `PASS` |
| Delegation TEST C | Module assessed; Riverpod 3 compatible; 2 risks flagged | `PASS` |
| Delegation TEST D | `complete_workout` idempotency reviewed; legacy path risk flagged | `PASS` |
| Delegation TEST E | Routing exercised | `PASS`; new-session `default_agent` binding `NOT RUN` |
| Deliberate failing test | `No tests ran` → reported `FAIL` | `PASS` |

### Not verified

- `default_agent` binding for a **new** session. This session predates the configuration. `NOT RUN`.
- Runtime application of the reviewed migration. No database change was made. `NOT RUN`.
- Wave 2 skills. Not imported by design. `NOT RUN`.

### Findings recorded, not fixed (out of scope)

- `active_workout_controller.dart` L207-215 potential deadlock; L659-670 null dereference after await.
- `complete_workout` L230 legacy path could double-award a pre-existing row.
- The invariant "only `complete_workout` writes XP" is imprecise: `initialize_user`, `sync_daily_data`,
  and `switch_class` also write progression state.

---

## 2026-10-28 — S2 Wave 1: agent system installed (uncommitted)

**Task:** S2 — Multi-agent configuration and skill integration, Wave 1.
**Status:** `PASS`
**Baseline:** `main` @ `b4063c6`. Source library pinned at `c4a059bb…`.
**Scope:** Tooling configuration only. No application code, SQL, Edge Function, CI, dependency, UI, or
media change. No commit, push, tag, or branch change.

### Created

- `.opencode/opencode.jsonc` — schema, `default_agent: gymlvl-orchestrator`, global Git permission floor.
- `.opencode/agents/` — 7 agents: `gymlvl-orchestrator` (primary), `flutter-specialist`,
  `supabase-specialist`, `exercise-catalog`, `ui-ux-specialist`, `qa-reviewer`, `context-keeper`.
- `.opencode/skills/` — 6 adapted skills: `flutter-expert`, `postgres-best-practices`, `postgresql`,
  `test-driven-development`, `systematic-debugging`, `context-window-management`.
- `.opencode/commands/` — 6 commands: `plan`, `orchestrate`, `test`, `audit`, `debug`, `mobile`.
- `docs/agent-system/THIRD_PARTY_NOTICES.md` — attribution ledger, written before import.
- `docs/agent-system/WAVE1_IMPLEMENTATION.md` — implementation record and rule mapping.

### Changed

- `docs/planning/DECISIONS.md` — D-015 … D-019 accepted; O-10, O-11 added.
- `docs/planning/TASK_BOARD.md` — tooling track added; tree-state claim corrected.
- `docs/planning/SESSION_HANDOFF.md` — current state section added; prior record marked historical.

### Verification (this session)

| Command | Result | Status |
|---|---|---|
| `flutter analyze` | `No issues found!` exit 0 | `PASS` |
| `flutter test` | `All tests passed!` 126/126 exit 0 | `PASS` |
| Structure | 7 agents, 6 skills with `SKILL.md`, 6 commands | `PASS` |
| JSONC parse | valid; `default_agent=gymlvl-orchestrator` | `PASS` |
| Hygiene grep | only the intentional `git push`/`git commit` deny rules matched | `PASS` |
| Reference integrity | every referenced skill ID and command `agent:` target resolves | `PASS` |
| `qa-reviewer` deliberate FAIL | `flutter test --plain-name …` → exit 1, `No tests ran` | `PASS` |
| `context-keeper` restore | read-only state block, no writes | `PASS` |
| `git status --porcelain=v1` | `?? .opencode/`, `?? docs/agent-system/` only | `PASS` |

### Not verified

- OpenCode `--version` command: the `opencode` binary is not on `PATH`. Version was read from the
  installed application instead — Desktop ProductVersion `2.2.0`, `opencode-cli.version` `2.2.0`,
  `opencode-cli.exe` metadata `1.4.4` (inconsistent; noted, not resolved). `NOT RUN` as a command.
- Wave 2 skills: not imported. `NOT RUN` by design.
- Migration/policy execution: no database change was made. `NOT RUN`.

### Decisions

D-015 project-local `.opencode/`; D-016 read-only `qa-reviewer` and `context-keeper`; D-017 skills
rewritten not vendored; D-018 existing `.agent/` and `.agents/teamwork/` preserved; D-019 Git
protection enforced by permissions.

### Backup

`C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-s2-backup-20261028\` — `main.bundle` verified
("records a complete history"), plus the four S1 documents.

---

## 2026-10-28 — Main consolidation and main-only workflow

**Task:** Consolidate `codex/supabase-product-audit` into `main`, commit the nine memory files, and
establish `main` as the only development branch.
**Status:** `PASS`
**Baseline:** `main`; consolidation checkpoint `17ca562`; the workflow-doc commit containing this
entry is the current `main` HEAD.
**Scope:** Git consolidation and documentation only. No application code, SQL migration, Edge
Function, CI config, dependency, UI, or media change.

### Changed

- Committed the nine memory files: `AGENTS.md` and `docs/planning/{MASTER_PLAN,M0_AUDIT,
  PROJECT_CONTEXT,ARCHITECTURE,DECISIONS,TASK_BOARD,SESSION_HANDOFF,CHANGELOG_AI}.md` — `17ca562`,
  9 files, +2,015 lines.
- Fast-forwarded `main` from `e003803` to `17ca562`; no merge commit, no conflicts.
- Pushed `main`: `e003803..17ca562  main -> main` (no force).
- Workflow docs: `AGENTS.md` (baseline + `main`-only rule), `DECISIONS.md` (D-014),
  `SESSION_HANDOFF.md`, `TASK_BOARD.md`, `PROJECT_CONTEXT.md`, `MASTER_PLAN.md`, this entry.
- Retained `codex/supabase-product-audit` at `17ca562`; nothing deleted.

### Backup (pre-consolidation)

`C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-backups\20261028-main-consolidation\`

| Artifact | SHA-256 |
|---|---|
| `gymlvl-pre-consolidation-all-refs.bundle` | `CB9AA6E1C1A91C8178114D53E2375B0ED0788D808DFA0CBA4F8D80FDF4251F00` |
| `gymlvl-pre-consolidation-HEAD.zip` | `CD458094BA1F20176C6080F3DC59F9D5432E6862C6E2B748B2203805FD9444C9` |
| `gymlvl-uncommitted-memory-files.tgz` | `4DFB158D1255F26E029E854C4A91608E0B6058F2DE324A140EBB9BAE5C714D62` |

Verified: bundle clone HEAD = `56c1122`; archive 502 files = Git tree 502; untracked archive 9 files,
all hashes matched.

### Verification (this session, `17ca562`)

| Command | Result |
|---|---|
| `git merge-base --is-ancestor main codex/supabase-product-audit` | `PASS` — fast-forward safe |
| `git merge --ff-only codex/supabase-product-audit` | `PASS` — `e003803..17ca562` |
| `flutter analyze` | `PASS` — 0 issues |
| `flutter test` | `PASS` — 126/126 |
| `dart format --output=none --set-exit-if-changed lib test` | `PASS` — 125 files, 0 changed |
| `npm test` (db-tests) | `PASS` — 10/10, PostgreSQL 17.5/PGlite |
| `npm run test:edge` | `PASS` — 15/15 |
| `git push origin main` | `PASS` — `e003803..17ca562` |
| `git ls-remote origin refs/heads/main` | `PASS` — equal to local `main` |
| Android release build/device smoke | `NOT RUN` |
| iOS build | `NOT RUN` |
| Live Supabase / AI provider | `NOT RUN` |

### Decisions

D-014 (`main` is the sole development branch) accepted by explicit user instruction. D-011's
`56c1122` baseline is historical; `main` @ `17ca562` is current. D-009 (no automatic Git writes)
remains in force; this consolidation was explicitly authorized.

### Blockers

None for the consolidation. M1-01 prerequisites and platform blockers are unchanged.

### Next

**M1-01 — Baseline stabilization and evidence lock.** Documentation/verification only. Requires
explicit user go-ahead.

---

## 2026-10-28 — Persistent context bootstrap

**Task:** Create a durable, model-independent project memory and handoff system.
**Status:** `PASS`
**Baseline:** `codex/supabase-product-audit` @ `56c1122`; baseline tree clean at session start, nine
bootstrap files uncommitted after this session.
**Scope:** documentation only. No application code, SQL, Edge Function, CI, dependency, or UI change.

### Created

- `AGENTS.md`
- `docs/planning/MASTER_PLAN.md`
- `docs/planning/M0_AUDIT.md`
- `docs/planning/PROJECT_CONTEXT.md`
- `docs/planning/ARCHITECTURE.md`
- `docs/planning/DECISIONS.md`
- `docs/planning/TASK_BOARD.md`
- `docs/planning/SESSION_HANDOFF.md`
- `docs/planning/CHANGELOG_AI.md`

### Preserved

- `docs/planning/GymLvl_OpenGym_Migration_Master_Plan.md` — untouched.
- `docs/planning/GymLvl_License_Ledger_Starter.csv` — untouched.
- All existing source, docs, tests, and Git history.

### Backup

- Bundle: `C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-backups\20261028-pre-memory-bootstrap\gymlvl-all-refs.bundle`
  - SHA-256 `C8DAC1F53827A8E43BBC5A0753E66690990BFA51268CF04433B176F05332AB52`
- Archive: `...\gymlvl-HEAD-56c1122.zip`
  - SHA-256 `CD458094BA1F20176C6080F3DC59F9D5432E6862C6E2B748B2203805FD9444C9`
- Verified: bundle clone HEAD = `56c1122`; archive 502 files = Git tree 502 files.

### Verification (this session, `56c1122`)

All nine files were read back; all relative links resolve; the original master plan and license
starter still match their `HEAD:` blob hashes.

| Command | Result |
|---|---|
| `flutter analyze` | `PASS` — 0 issues |
| `flutter test` | `PASS` — 126/126 |
| `dart format --output=none --set-exit-if-changed lib test` | `PASS` — 125 files, 0 changed |
| `npm test` (db-tests) | `PASS` — 10/10, PostgreSQL 17.5/PGlite |
| `npm run test:edge` | `PASS` — 15/15 |
| Android release build/device smoke | `NOT RUN` |
| iOS build | `NOT RUN` |
| Live Supabase / AI provider | `NOT RUN` |

### Findings recorded

- The M0 report was chat-only; no file existed. `M0_AUDIT.md` is a labelled reconstruction.
- The M0 dirty workspace (166 entries at `e003803`) was committed and pushed as `56c1122` outside
  this session; tree is clean. Actor/timing unverified.
- Open defects remain: missing Android `INTERNET`, placeholder app names, chat-only coach,
  network-first logging, 150-exercise catalog, name-only search, missing plans/progression/PRs,
  stale docs, no LICENSE.
- Current OpenGym B catalogue is 6,554 exercises, correcting the original plan's 5,632.
- Original plan's M1 design-system scope is already implemented; M1 re-baselining to stabilization is
  proposed, not approved.

### Decisions

D-010 (canonical memory files), D-012 (documentation-only bootstrap), and D-013 (verified backup)
accepted. D-002 (no AGPL reuse / MIT text only) and D-007 (AI proposal/approval contract) are accepted
for current constraints. D-004 (M1 re-baseline) and D-005 (Drift) remain proposed, not approved.

### Next

**Proposed next: M1-01 — Baseline stabilization and evidence lock.** Documentation/verification only.
Requires explicit user go-ahead. No commit, push, or tag without approval.

---

## 2026-10-27/28 — M0 audit and migration plan

**Task:** Repository audit, reference analysis, migration planning, M1 proposal.
**Status:** `DONE` (reported; planning only)
**Baseline at the time:** `codex/supabase-product-audit` @ `e003803`, 166 dirty entries.
**Scope:** no application, SQL, deployment, or production changes; no commit or push.

### Evidence reported by the prior session

| Command | Result |
|---|---|
| `flutter analyze` | `PASS` — 0 issues (54s) |
| `flutter test` | `PASS` — 126/126 |
| `npm test` (db-tests) | `PASS` — 10/10 SQL units on PostgreSQL 17.5/PGlite |
| `npm run test:edge` | `PASS` — 15/15 Deno tests |
| Android release build/device smoke | `NOT RUN` (blocked/unknown SDK) |
| iOS build | `NOT RUN` (Windows host) |
| Live Supabase / AI provider | `NOT RUN` |

### Reference revisions verified

- `emilfunk/opengym` — `678bf5bf10446e8997a77d43e89c9b2721d8d0fc` — AGPL-3.0.
- `DuarteSantos8/openGym` — `e6a95c28a6e3067bdd9b1188d5f37f448d528bd2` — AGPL-3.0 + non-transferable
  app-store exception.
- `hasaneyldrm/exercises-dataset` — `7455efae41b330c265e7cd4b78dfa848e7ce5ebd` — MIT text/data;
  media excluded.

### Findings

- GymLvl: 17 tables, 150 curated exercises, classes A–F, server-authoritative completion, hardened
  RLS.
- OpenGym A: 1,324-exercise library + file-backed coach; plan/engine separation.
- OpenGym B: 6,554 exercises, 17 translations, 13,109 media files; richer engine and schema-validated
  coach v2.
- Dataset: 1,324 records, 10 languages, complete English text, no difficulty/movement metadata,
  media not MIT.
- Defect register G-01…G-15 created; top risks were the missing Android `INTERNET` permission and
  the 166 uncommitted entries.
- Proposed M1 as release-critical stabilization after the design-system scope was found already
  implemented.

### Artifacts

- The M0 report existed only in the session transcript; no file was written.
- The original plan `GymLvl_OpenGym_Migration_Master_Plan.md` v1.0 remained untouched.
- License starter `GymLvl_License_Ledger_Starter.csv` remained untouched.

### Next

Bootstrap durable memory (completed 2026-10-28), then **M1-01**.

---

## Template for future entries

```markdown
## YYYY-MM-DD — <task ID and title>

**Task:**
**Status:** PASS | FAIL | BLOCKED | NOT RUN
**Baseline:** branch @ short SHA; tree state
**Scope:**

### Changed
- exact paths

### Verification
| Command | Result |
|---|---|

### Decisions
- IDs and approval state

### Blockers
- exact prerequisite

### Next
- one concrete action with task ID
```
