# GymLvl — Session Handoff

**Updated:** 2026-10-28 (D-024 — full development access)
**Last agent:** OpenCode Desktop, agent **`build`** — server record `ses_e7e999dd2ffdO3oGdRJnVFBuY1`
reports `"agent":"build"`. Not the orchestrator.
**Mode:** Agent permission policy, agent prose, and governance documentation, plus one local commit and
a normal push to `origin/main`. No application, SQL, UI, schema, CI, or dependency change.
**Baseline:** branch `main` @ `947da1e` = `origin/main` after the D-024 push. Confirm with
`git rev-parse main` and `git ls-remote origin refs/heads/main` before trusting this line.
**Next task:** **A1 — Architecture, dependencies, configuration and infrastructure** (`READY`, audit
track). The A1 instruction given earlier on 2026-10-28 was withdrawn by the user before any review ran,
so **A1 has not started**. **M1-01** (product) and **S4** (skills) remain unauthorized.

---

## 0. Current state — D-024 access policy applied (newest)

| Item | Value |
|---|---|
| Agent access policy | `PASS` — **D-024**. Orchestrator + 5 development specialists have full repository access; irreversible or sensitive operations resolve to `ask`; `qa-reviewer` and `context-keeper` remain read-only |
| Active agent (this session) | **build**, proven from the server, not from configuration |
| Orchestrator write | `PASS` end-to-end — a throwaway `gymlvl-orchestrator` session wrote `app/.perm-probe-2.md`; confirmed from a second session |
| A1 audit | **`NOT STARTED`** — `docs/audit/phases/A1_ARCHITECTURE.md` does not exist |
| Findings | Unchanged: 6 total — 2×P1, 2×P2, 2×P3; 2 `Needs Verification`, 2 `Accepted`, 1 `Fixed`, 1 `False Positive`. `FND-GOV-001` is now verified end-to-end |
| Git | `947da1e` on `main`; `origin/main` moved `9c8e142` → `947da1e` |
| Push | `PASS` — `git push origin main` → `9c8e142..947da1e  main -> main`, exit 0. The old `git push *` deny is gone; force-push stays gated. |
| Backup | `…\Temp\opencode\gymlvl-s2-backup-20261028\` — bundle verified at S3 |

**Read first on resume:** `AGENTS.md` §0.1, this section, `docs/agent-system/ACCESS_POLICY.md`, then
`docs/audit/SESSION_HANDOFF.md`, then `TASK_BOARD.md`.

### Verification at D-024 close

| Check | Command | Result | Status |
|---|---|---|---|
| Config parses | `node …\gymlvl-perm-check.mjs D:\Projects\gymlvl` | `PARSE .opencode/opencode.jsonc : OK (73 global rules, default_agent=gymlvl-orchestrator)` | `PASS` |
| Effective rules, not file text | same run | `RESULT: PASS (0 probe failures, 0 schema problems)` over 66 probes | `PASS` |
| Agent frontmatter parses | same run | 7 agents: 0 rules × 5, qa-reviewer 41, context-keeper 21 | `PASS` |
| Server reloaded definitions | `agent.updated` events in `~/.local/share/opencode/log/opencode.log` | 8 events, `07:33:43.390Z`–`07:34:31.580Z`, one per file write | `PASS` |
| Active agent | `GET /api/session/ses_e7e999dd2ffdO3oGdRJnVFBuY1` | `"agent":"build"` | `PASS` |
| Orchestrator write, previously denied path | `opencode-cli.exe run --agent gymlvl-orchestrator …` | wrote `app/.perm-probe-2.md`; `Test-Path` → `True`, `Get-Content` → `probe` from a different session | `PASS` |
| Orchestrator shell, previously denied command | same session | `node --version` → `v22.17.0` | `PASS` |
| Reviewer write denial | `subagent(qa-reviewer)` | `Set-Content docs/audit/.qa-write-probe.md` → `permission.rejected`; `Test-Path` → `False` | `PASS` |
| Reviewer Git write denial | same session | `git commit --allow-empty -m "probe"` → `permission.rejected`; HEAD unchanged at `425686c` | `PASS` |
| Reviewer has no write tool | same session | `tools.write` / `tools.edit` → `Unknown tool` | `PASS` |
| Delegation | `subagent(qa-reviewer)` | review completed and returned evidence | `PASS` |
| Secret gate at runtime | no `.env` exists in the workspace | not exercised | `NOT RUN` |
| Product regression (`flutter analyze`, `flutter test`, SQL, Edge) | not rerun — no product or test file changed | — | `NOT RUN` |
| Android/iOS build | not attempted | — | `NOT RUN` |

Runtime evidence detail lives in `docs/agent-system/ACCESS_POLICY.md` §4.

### Operational rules learned

- **Never put a broad allow in an agent file.** OpenCode V2 appends agent rules after the global set and
  the last match wins, so an agent-level `shell "*"` → `allow` silently cancels every global gate. Gates
  belong in exactly one place: `.opencode/opencode.jsonc`.
- **Prove the active agent from the server.** `GET /api/session/<id>` returns the session's `agent`. The
  bundled CLI is at `…\Programs\ai.opencode.desktop\resources\opencode-cli.exe`; it is not on `PATH`.
  `default_agent` remains a session-creation default, not a live switch (D-023).
- **A nested agent's self-report is not evidence.** The first orchestrator probe claimed a file that was
  gone at cleanup time; the repeat was asserted from a different session. Only the second result counts.
- **`opencode-cli.exe` exits 1 after a successful run** because PowerShell raises `NativeCommandError`
  on its stderr banner. Judge by output, not exit code.
- **`ask` is a guardrail, not a sandbox.** Shell runs with the host user's full authority.

### Known open items

- **A1 is not started.** The audit program is otherwise unchanged; `docs/audit/SESSION_HANDOFF.md` §6
  still holds the authoritative A1 prompt.
- `FND-GOV-002`: `PROJECT_CONTEXT.md` §2 is 3 commits behind with a 27-short file count, and the
  `DECISIONS.md` summary table still stops at **D-014** — D-024 was recorded as a section only, not
  added to the table, so the W4 fix remains a single pass.
- Two P1 findings (`FND-CONC-001`, `FND-DATA-001`) are inherited and still unverified.
- Shell secret gates are pattern-based; an obfuscated path such as `Get-Content ("."+"env")` is not
  matched. The `read`-tool gates are stronger than the shell gates.
- Reviewers cannot chain compound commands (`git status; flutter analyze` is denied) because their
  allowlist is per-segment.
- O-10: Apache-2.0 notice for the `context-window-management` adaptation. Release blocker only.
- S4 (Wave 2, 14 skills) is `PLANNED` and requires explicit approval.

### Exact next action

Await an explicit instruction, then run **A1** using the prompt in `docs/audit/SESSION_HANDOFF.md` §6 in
a session that has been confirmed to be the intended agent. Do not start M1-01 or S4. Do not begin
remediation.

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
