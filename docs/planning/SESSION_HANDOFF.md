# GymLvl — Session Handoff

**Updated:** 2026-10-28 (S3 validation and checkpoint)
**Last agent:** OpenCode S3 validation (same session as S1 and S2)
**Mode:** Validation, optimization, documentation, and an authorized Git checkpoint. No application,
SQL, UI, schema, dependency, CI, or media change.
**Baseline:** branch `main`. S3 started at `b4063c6`; the infrastructure checkpoint is `59450c0`,
pushed to `origin/main`. Confirm with `git rev-parse main` before trusting this line.
**Next task:** **S4 — Wave 2 skill import** (`PLANNED`, requires approval). **M1-01** remains the next
product task and is still not authorized.

---

## 0. Current state — agent system complete through S3 (newest)

| Item | Value |
|---|---|
| S1 discovery | `DONE` — four planning documents under `docs/agent-system/` |
| S2 Wave 1 install | `DONE` — `.opencode/` with 7 agents, 6 skills, 6 commands, config |
| S3 validation | `DONE` — `docs/agent-system/S3_VALIDATION_REPORT.md` |
| Language policy | `AGENTS.md` §0.1, permanent (D-020) |
| Git | `59450c0` on `main` = `origin/main`; working tree clean |
| Backup | `…\Temp\opencode\gymlvl-s2-backup-20261028\` — bundle verified |

**Read first on resume:** `AGENTS.md` §0.1, this section, then `TASK_BOARD.md`.

### Verification at S3 close

| Command | Result | Status |
|---|---|---|
| `flutter analyze` | `No issues found!` (exit 0) | `PASS` |
| `flutter test` | `All tests passed!` 126/126 (exit 0) | `PASS` |
| `dart format --set-exit-if-changed` | `125 files (0 changed)` (exit 0) | `PASS` |
| SQL regression (`npm.cmd test`) | `PASS 10 SQL verification units` (exit 0) | `PASS` |
| Edge tests (`npm.cmd run test:edge`) | `15 passed | 0 failed` (exit 0) | `PASS` |
| Agent discovery and permissions | 7 agents; QA and context-keeper read-only | `PASS` |
| Delegation tests A–D | Domain-correct output; no file written | `PASS` |
| Deliberate FAIL | `No tests ran` → reported `FAIL` | `PASS` |

### Operational rules learned

- **Run shell-dependent subagents sequentially** (D-021). Concurrent launches can lose shell access.
- Do not trust the S2 note that a new session binds to `gymlvl-orchestrator`; that was **not verified**.
  Check the active agent at the start of the next session.
- `context-keeper` and `qa-reviewer` cannot write. The orchestrator applies all planning-document edits.

### Known open items

- L4: potential deadlock in `active_workout_controller.dart` L207-215 and a null dereference at
  L659-670. Product defect, proposed for an M1/M3 task.
- L5: legacy `is_xp_calculated=false` path in `complete_workout` L230 may double-award old rows.
- L6: the invariant "only `complete_workout` writes XP" is imprecise — `initialize_user`,
  `sync_daily_data`, and `switch_class` also write progression state.
- O-10: Apache-2.0 notice for the `context-window-management` adaptation. Release blocker only.
- S4 (Wave 2, 14 skills) is `PLANNED` and requires explicit approval.

### Exact next action

Resume at the next session start by confirming the active agent and a clean tree, then take **M1-01 —
Baseline stabilization and evidence lock** if the product track is authorized, or **S4** if skill
import is authorized. Do not start either without explicit go-ahead.

---

> Sections 1–9 below are the **prior** consolidation-session record, preserved as evidence at
> `17ca562`. They describe history, not the current state.

## 1. What this session did

Consolidated all existing work into `main` and made `main` the only development branch. No feature
work was started. No application code, SQL migration, Edge Function, CI config, dependency, UI, or
media was changed.

| Step | Result |
|---|---|
| Pre-change backup (tracked HEAD + uncommitted files) | Created and verified — §3 |
| Committed the nine memory files | `17ca562` — 9 files, +2,015 lines |
| Integrated into `main` | Fast-forward `e003803..17ca562`; no merge commit, no conflicts |
| Pushed `main` | `e003803..17ca562  main -> main` (no force) |
| Regression suites at `17ca562` | Flutter 126/126, SQL 10/10, Edge 15/15 — §4 |
| Workflow documentation | `AGENTS.md`, `DECISIONS.md` D-014, this file, `TASK_BOARD.md`, `CHANGELOG_AI.md`, `PROJECT_CONTEXT.md`, `MASTER_PLAN.md` |

The old branch `codex/supabase-product-audit` was **not** deleted. It is retained at `17ca562` for
provenance and is no longer a development target.

## 2. Git state

| Item | Value |
|---|---|
| Development branch | `main` (only) |
| Consolidation checkpoint | `17ca562f7d382cdd16e17a414460b8266edcf16b` (`17ca562`) |
| Previous `main` | `e0038038300d5bfaf3c4747094cf36a132eb8711` (`e003803`) |
| Integration method | `git merge --ff-only` — fast-forward, both histories preserved |
| `origin/main` | Pushed and verified equal to local `main` at the checkpoint |
| `codex/supabase-product-audit` | Retained at `17ca562` (read-only provenance) |
| Working tree | Clean at the checkpoint; test-generated plugin files matched HEAD byte-for-byte |
| Tags | None created |
| Force push / reset / rebase / branch deletion | None used |

After the workflow-doc commit, `main` and `origin/main` must again match; that equality is verified in
the consolidation report for the final HEAD.

**History note:** `56c1122` (381 files, +33,198/−8,080) remains a valid historical checkpoint on the
audit branch. It was created outside the M0/audit sessions; the actor and timing are unverified.

## 3. Backup evidence

**Location:**
`C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-backups\20261028-main-consolidation\`

| Artifact | Size | SHA-256 |
|---|---|---|
| `gymlvl-pre-consolidation-all-refs.bundle` | 3,163,282 bytes | `CB9AA6E1C1A91C8178114D53E2375B0ED0788D808DFA0CBA4F8D80FDF4251F00` |
| `gymlvl-pre-consolidation-HEAD.zip` | 4,969,624 bytes | `CD458094BA1F20176C6080F3DC59F9D5432E6862C6E2B748B2203805FD9444C9` |
| `gymlvl-uncommitted-memory-files.tgz` | 35,827 bytes | `4DFB158D1255F26E029E854C4A91608E0B6058F2DE324A140EBB9BAE5C714D62` |

Verification performed:

- `git bundle verify` → "The bundle records a complete history", "is okay".
- Fresh `git clone --bare` from the bundle → HEAD
  `56c112213e43c8c11c620b9cd1258475fb2e9935`, equal to the pre-consolidation repository HEAD.
- `git archive` ZIP extracted → 502 files, equal to `git ls-tree -r --name-only HEAD` = 502.
- Uncommitted archive → 9 files; every extracted file hash matched the working-tree source.
- Bundle contains 6 refs: local and remote `main`, local and remote audit branch, `origin/HEAD`, HEAD.

The backup preserves the pre-consolidation state: audit branch `56c1122`, `main` `e003803`, and the
nine uncommitted memory files. It remains outside the repository working tree.

## 4. Verification run in this session

All runtime results below were obtained at consolidation checkpoint `17ca562`; the working tree was
identical to that commit except for the workflow docs added afterwards.

| Command | Result | Status |
|---|---|---|
| `git status --porcelain=v1` (before commit) | Only the nine expected memory files | `PASS` |
| `git fetch origin --prune` | No new remote commits; audit branch remote still `56c1122` | `PASS` |
| `git merge-base --is-ancestor main codex/supabase-product-audit` | True — fast-forward safe | `PASS` |
| `git merge --ff-only codex/supabase-product-audit` | `e003803..17ca562`, fast-forward | `PASS` |
| `cd app; flutter analyze` | No issues found | `PASS` |
| `cd app; flutter test` | 126 passed | `PASS` |
| `cd app; dart format --output=none --set-exit-if-changed lib test` | 125 files, 0 changed | `PASS` |
| `cd tools/db-tests; npm test` | 10/10 SQL units; 150 catalog exercises; PostgreSQL 17.5/PGlite | `PASS` |
| `cd tools/db-tests; npm run test:edge` | 15 passed, 0 failed | `PASS` |
| `git push origin main` | `e003803..17ca562  main -> main` | `PASS` |
| `git ls-remote origin refs/heads/main` | `17ca562f7d382cdd16e17a414460b8266edcf16b` — equal to local `main` | `PASS` |
| Android release build/device smoke | Not attempted | `NOT RUN` |
| iOS build | Not possible on Windows | `NOT RUN` |
| Live Supabase / AI provider | Not attempted | `NOT RUN` |

**Limitation:** the SQL harness is single-connection PGlite, not a full Supabase gateway/Auth/Edge
runtime. It does not prove production behavior.

**Test artifact note:** Flutter regenerated five platform plugin registrant files. Their bytes matched
`HEAD` exactly (`git hash-object` equal to the `HEAD:` blob); only the index stat cache was stale.
They were refreshed with `git add` and produced no staged diff. The tree is clean.

## 5. M0 provenance

The M0 report was delivered **only in the prior session's chat transcript**. No M0 report file
existed. `docs/planning/M0_AUDIT.md` is a structured reconstruction with explicit evidence labels,
not a verbatim copy. M0 was planning-only and made no application/DB/deployment changes.

Key M0 findings still open: missing Android `INTERNET` permission, placeholder app names, chat-only
coach, network-first set logging, 150-exercise catalog, name-only search, no plans/progression/PR
features, stale docs, and no LICENSE.

## 6. Decisions and unresolved blockers

### Decisions recorded

- D-001 platform preservation — accepted.
- D-002 AGPL reference-only, MIT text only — accepted for current milestones; long-term license
  posture open.
- D-003 media postponed — accepted.
- D-004 M1 re-baselined to stabilization — proposed, needs approval before M1-02.
- D-005 Drift — proposed, not approved.
- D-006 import all 1,324 MIT text records — proposed.
- D-007 AI proposal/approval architecture — accepted product contract; implementation pending M6.
- D-008 server-authoritative XP — accepted invariant.
- D-009 no automatic Git writes — accepted; the consolidation was covered by explicit user approval.
- D-010 canonical memory files — accepted.
- D-011 baseline `56c1122` — recorded; superseded by D-014 as the current baseline.
- D-012 documentation-only bootstrap — accepted.
- D-013 verified external backup — accepted.
- **D-014 `main` is the sole development branch — accepted (explicit user instruction).**

### Open blockers

| Blocker | Affects | Exact prerequisite |
|---|---|---|
| Android SDK/licences/device unknown | M1-02, M1-05, M8 | Confirm `flutter doctor`, Android SDK, and a device/emulator |
| iOS build impossible on Windows | M1-02, M8 | macOS + Xcode machine |
| No approved live Supabase project | M2+ verification | Project owner provides credentials/approval |
| No live AI provider verification | M6 | Provider choice, key policy, cost approval |
| No GymLvl LICENSE / contributor rights | Distribution, M8 | Legal decision |
| 150 curated text provenance undocumented | Catalog trust, M2 | Provenance audit |
| No checkpoint tag | M1-01 | Approval of tag name/creation |

## 7. Exact next action

**Proposed next action — M1-01 — Baseline stabilization and evidence lock.**
This task is proposed, not pre-authorized. Wait for the user's go-ahead before starting.

First concrete step:

1. Re-run `git status --porcelain=v1`, `git branch --show-current`, `git rev-parse HEAD`, and
   `git ls-remote origin refs/heads/main`; confirm `main` and `origin/main` still match.
2. Verify the backup hashes in §3 still match.
3. Create `docs/planning/UPSTREAM_SOURCE_MANIFEST.json` and
   `docs/planning/LICENSE_LEDGER.csv`.
4. Produce `docs/planning/BASELINE_REPORT.md` with the command matrix and conflict register.
5. Update `TASK_BOARD.md`, this handoff, and `CHANGELOG_AI.md`.
6. Propose the checkpoint tag and stop for approval.

Do **not** start M1-02, catalog import, schema changes, UI refactors, or media work. Do not create a
branch; all work belongs on `main`.

## 8. Next-session prompt (copy-paste)

```text
You are continuing GymLvl in BUILD mode. Read AGENTS.md first, then
docs/planning/SESSION_HANDOFF.md, TASK_BOARD.md, PROJECT_CONTEXT.md,
ARCHITECTURE.md, DECISIONS.md, M0_AUDIT.md, and MASTER_PLAN.md.

Baseline: branch main only, consolidation checkpoint 17ca562. The nine memory
files are committed; the tree is expected to be clean and equal to origin/main.
The next proposed task is M1-01 — Baseline stabilization and evidence lock.
Wait for explicit user go-ahead before starting it.
Scope: documentation and verification only. Do not touch app code, SQL, CI,
dependencies, catalog, media, or UI. Do not commit, push, or tag without approval.

Verify the baseline and backup first, then create UPSTREAM_SOURCE_MANIFEST.json,
LICENSE_LEDGER.csv, and BASELINE_REPORT.md, update the task board/handoff/changelog,
and propose a checkpoint tag. Stop after M1-01 and report PASS/FAIL/BLOCKED/NOT RUN
with exact commands and evidence.
```

## 9. Guardrails

- **Use `main` only.** Do not create or switch branches without explicit user authorization.
- Never invent verification. A prior session's result is not a current `PASS`.
- Preserve user work and the 150 exercise UUIDs.
- No AGPL code/text reuse; no third-party media.
- Keep PostgreSQL authoritative for XP/rewards.
- Keep Candy UI and VI/EN support.
- No destructive Git or database operations; never force push.
- Update `TASK_BOARD.md`, `SESSION_HANDOFF.md`, and `CHANGELOG_AI.md` at every checkpoint.
