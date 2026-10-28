# Audit — Session Handoff

**Updated:** 2026-10-28 (D-024 access policy; A1 still not started)
**Stage:** A0 `PASS`; A0.1 `PASS` for the configuration fix, push `BLOCKED` at the time and now
unblocked by D-024; **A1 `NOT STARTED`**
**Baseline:** `main` @ `425686c`; `origin/main` still at `9c8e142` until the D-024 commit is pushed
**Next stage:** **A1 — Architecture, dependencies, configuration and infrastructure** (`READY`, not
authorized until the instruction in §6 is given again)

---

## 1. Where the program is

| Stage | Scope | Status |
|---|---|---|
| A0 | Bootstrap, baseline, inventory, plan | `PASS` — `phases/A0_BOOTSTRAP.md` |
| A0.1 | Governance fix + A0 checkpoint | `PASS` (config), push `BLOCKED` — `phases/A0_1_GOVERNANCE.md` |
| A1 | Architecture, dependencies, configuration, infrastructure, CI | `READY` — not started |
| A2 | Flutter app, state, lifecycle, concurrency, navigation | `PLANNED` |
| A3 | Supabase, PostgreSQL, RLS, auth, Edge Functions | `PLANNED` |
| A4 | Workout lifecycle, XP, progression, rewards | `PLANNED` |
| A5 | Tests, performance, reliability, observability | `PLANNED` |
| A6 | Reconciliation, verification, triage, remediation plan | `PLANNED` |

No stage auto-advances. Remediation has not started and must not start from this handoff.

## 2. Current finding state

| ID | Title | Sev | Conf | Status | Wave |
|---|---|---|---|---|---|
| `FND-CONC-001` | Re-entrant deadlock + post-await null deref in active workout controller | P1 | Medium | `Needs Verification` | W1 |
| `FND-DATA-001` | Legacy completion path can award twice | P1 | Medium | `Needs Verification` | W1 |
| `FND-ARCH-001` | XP write invariant narrower than implementation | P2 | High | `Accepted` | W1 |
| `FND-GOV-001` | No agent could write `docs/audit/**` | P2 | Confirmed | **`Fixed`** (A0.1 config, end-to-end verified 2026-10-28) | W0 |
| `FND-GOV-002` | `PROJECT_CONTEXT.md` is stale on its own baseline (3 commits, 27 files) | P3 | Confirmed | `Accepted` | W4 |
| `FND-GOV-003` | Shell matcher semantics for chained commands | P3 | High | **`False Positive`** (A0.1) | — |

Totals: 6 findings — 0 `P0`, 2 `P1`, 2 `P2`, 2 `P3`. Status: 2 `Needs Verification`, 2 `Accepted`,
1 `Fixed`, 1 `False Positive`. `FND-CONC-001`, `FND-DATA-001` and `FND-ARCH-001` are inherited from S3
and have **not** been re-verified.

`FND-GOV-001` is `Fixed` and now **verified end-to-end**. D-024 (2026-10-28) replaced the narrow
orchestrator allowlist with full development access plus approval gates; a live `gymlvl-orchestrator`
session wrote `app/.perm-probe-2.md` and the write was confirmed from a second session. The audit's
"one writer per file" rule is now a convention enforced by delegation discipline, not by permissions.
See `docs/agent-system/ACCESS_POLICY.md`.

## 3. Git state

| Item | Value |
|---|---|
| Branch | `main` |
| HEAD at A0.1 entry | `9c8e142` |
| Tree at A0.1 entry | 3 planning files `M`, `docs/audit/` untracked |
| Commit at A0.1 | `e400dbc` — `chore(audit): allow orchestrator audit writes and checkpoint A0/A0.1` (14 files, +1622/−38) |
| Tree after commit | clean, verified with `git status --porcelain=v1` |
| Remote | `origin/main` still at `9c8e142`; **not** advanced by A0.1 |
| Push | attempted once; **denied**. The tool call was rejected outright with `{"error":{"type":"permission.rejected","message":"Permission denied: shell"}}` — the global `git push *` → `deny` rule matched the command string, so the whole call was refused, not executed. |

The push denial is expected and was not worked around. `AGENTS.md` §8 forbids bypassing a protected Git
operation, and A0.1 was explicitly instructed not to weaken the deny rule. Manual push instructions for
the user are in §9.

## 4. Operating constraints in force

1. Audit only. No application, migration, or data change.
2. No deployment, no destructive SQL, no dependency install.
3. Write access: **repository-wide** for the orchestrator and the five development specialists since
   D-024. The audit's own scope discipline (one writer per file, audit-only changes) is now enforced by
   delegation rules and evidence review, not by the permission layer. `qa-reviewer` and
   `context-keeper` remain read-only, so independent verification is unchanged.
4. Shell-dependent subagents run sequentially (D-021).
5. The active agent of the session that wrote this handoff was the **build** agent: server session
   record `ses_e7e999dd2ffdO3oGdRJnVFBuY1` reports `"agent":"build"`. A live `gymlvl-orchestrator`
   session must still be selected deliberately; `default_agent` is not a live switch (D-023).

## 5. Files owned by this program

Created at A0 (8 files):

```text
docs/audit/README.md
docs/audit/AUDIT_SCOPE.md
docs/audit/AUDIT_COVERAGE.md
docs/audit/MASTER_FINDINGS.md
docs/audit/FINDINGS_REGISTER.json
docs/audit/REMEDIATION_PLAN.md
docs/audit/SESSION_HANDOFF.md
docs/audit/phases/A0_BOOTSTRAP.md
```

Created at A0.1: `docs/audit/phases/A0_1_GOVERNANCE.md`.

Planning updates (per `AGENTS.md` §6): `docs/planning/TASK_BOARD.md`,
`docs/planning/SESSION_HANDOFF.md`, `docs/planning/CHANGELOG_AI.md`, `docs/planning/DECISIONS.md`.

Configuration change at A0.1: `.opencode/agents/gymlvl-orchestrator.md` (+5 lines: 2 comments and one
`edit` allow for `docs/audit/*`).

## 6. Exact next action — A1

Run the following as one scoped stage. Do not begin A2 inside it.

> **A1 — Architecture, dependencies, configuration and infrastructure.**
> Read `docs/audit/{AUDIT_SCOPE,AUDIT_COVERAGE,MASTER_FINDINGS}.md` and
> `docs/audit/SESSION_HANDOFF.md` first, then perform a read-only review of:
> `.github/workflows/verify.yml`; `app/pubspec.yaml`, `app/analysis_options.yaml`, `app/l10n.yaml`;
> `docs/planning/ARCHITECTURE.md` §§1–4 and 7–9 versus the code; `docs/planning/PROJECT_CONTEXT.md`
> §§3–5 and 8; `.opencode/**` configuration against the observed agent behaviour; and the migration
> ordering and versioning scheme across the three SQL files.
> Deliverables: `docs/audit/phases/A1_ARCHITECTURE.md`; new findings in the register with the required
> fields; coverage updated for C-22, C-25, C-26; handoff updated with Git state and the next action.
> Constraints: no code or configuration change, no dependency install, no commit, no push.
> Report to the user in Vietnamese.

### Executor and method for A1

- **Executor:** the acting primary agent coordinates. Delegate `flutter-specialist` for
  `pubspec`/`analysis_options` dependency and lint review, `ui-ux-specialist` for the localization
  pipeline (`l10n.yaml` → generated `app_localizations*.dart`), and `qa-reviewer` for an independent
  read of the CI workflow. Run them **sequentially** (D-021); each is read-only, so sequencing is for
  shell reliability, not write safety. The coordinator writes every artifact under the
  `docs/audit/*` allow added in A0.1 — provided the session is actually running as the orchestrator.
- **Every new finding must carry all fourteen fields** listed in `README.md` §8 plus `wave` and
  `verification_method`, in both `MASTER_FINDINGS.md` and `FINDINGS_REGISTER.json`. A finding missing a
  field is not accepted into the register.
- **Confidence ceiling for A1:** `Confirmed` only where a command was run and its output quoted.
  Configuration and dependency review is mostly static, so most A1 findings should be `High` at best.

### Acceptance criteria for A1

A1 is `PASS` only when all of the following hold:

1. `docs/audit/phases/A1_ARCHITECTURE.md` exists and covers every item named in the prompt above, or
   states explicitly which item was skipped and why.
2. Every new finding is in both the register JSON and the markdown, with identical ID, severity,
   confidence, and status; the JSON parses; declared counts equal actual counts.
3. `AUDIT_COVERAGE.md` shows updated status and a named reviewer for C-22, C-25 and C-26.
4. The stale-claim inventory is complete enough to fix `FND-GOV-002` in one pass, or it says which
   documents remain unchecked.
5. `SESSION_HANDOFF.md` records Git state, what A1 actually did, open investigations, and the exact A2
   prompt.
6. No file outside `docs/audit/**` and the three planning files was modified, verified by
   `git status --porcelain=v1`.
7. The user report is in Vietnamese, with `PASS`/`FAIL`/`BLOCKED`/`NOT RUN` and quoted evidence.

## 7. Open investigations carried into A1

| Item | State after 2026-10-28 |
|---|---|
| `FND-GOV-001` end-to-end | **Resolved.** D-024 broadened the orchestrator; a live orchestrator session wrote `app/.perm-probe-2.md`, independently confirmed with `Test-Path` → `True` and `Get-Content` → `probe` from another session. |
| Orchestrator binding | **Resolved as a method.** `GET /api/session/<id>` returns the session's `agent` field; the authoring session is `build`. Use that endpoint rather than inferring from configuration. |
| CI gap | Open. `verify.yml` builds web only with placeholder Supabase variables and never builds Android or iOS. Not yet established whether that is a documented decision or an unrecorded gap (`ARCHITECTURE.md` §9 asserts "No Android APK build in CI today", so it is documented but unevidenced as a decision). |
| Migration scheme | Open. The three migrations are dated but there is no version ledger; ordering enforcement is unestablished. |
| Documentation currency | `FND-GOV-002` confirmed: `PROJECT_CONTEXT.md` §2 is 3 commits behind and its tracked-file count is 27 short. A1 must inventory the remaining stale claims in `§§2–5` so W4 fixes them in one pass, and must not treat a dated evidence block as stale merely because it names an older SHA. |
| A1 artifacts | `docs/audit/phases/A1_ARCHITECTURE.md` **does not exist**. A stub was created during the 2026-10-28 permission probe and deleted when the session was redirected; no A1 review was performed. |

## 8. Anything a resuming session must not assume

- That the previous stage's findings are correct. `FND-CONC-001`, `FND-DATA-001` and `FND-ARCH-001`
  are inherited and unverified.
- That a directory read means the component is audited. See the coverage matrix for the real state.
- That `flutter test` passing means the feature works. It means 126 named tests pass; coverage is
  unmeasured.
- That the orchestrator is running. Check it first. `FND-GOV-001` is `Fixed` as a configuration fault,
  not as an observed capability.

## 9. Manual push (user action, Vietnamese)

The local commit exists; only the push is blocked by the project's own deny rule. To publish it:

```powershell
cd D:\Projects\gymlvl
git log --oneline -2
git status --porcelain=v1     # phải rỗng
git push origin main
```

Nếu vẫn bị chặn, kiểm tra rule `git push *` trong `.opencode/opencode.jsonc`. Chỉ thay đổi rule đó khi
bạn chủ động quyết định; KHÔNG dùng `--force`, `git reset`, hay `git rebase`. Sau khi push xong, xác
nhận bằng `git ls-remote origin refs/heads/main` và cập nhật lại §3 ở trên.
