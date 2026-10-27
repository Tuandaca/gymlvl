# GymLvl — AI Changelog

Dated record of agent sessions and project checkpoints. Newest first.

**Rules:** one entry per session/checkpoint; list exact files, commands, and statuses; never claim a
test that was not run; distinguish prior-session evidence from current-session evidence.

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
