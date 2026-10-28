# Audit — Session Handoff

**Updated:** 2026-10-28 (A1 complete)
**Stage:** A0 `PASS`; A0.1 `PASS`; **A1 `PASS`** (10 new findings, 2 inventory corrections)
**Baseline:** `main` @ `e8c7c8e` = `origin/main` at A1 entry, tree clean
**Next stage:** **A2 — Flutter app, state management, lifecycle, concurrency, navigation** (`READY`,
not authorized until the instruction in §6 is given)

---

## 1. Where the program is

| Stage | Scope | Status |
|---|---|---|
| A0 | Bootstrap, baseline, inventory, plan | `PASS` — `phases/A0_BOOTSTRAP.md` |
| A0.1 | Governance fix + A0 checkpoint | `PASS` — `phases/A0_1_GOVERNANCE.md` |
| A1 | Architecture, dependencies, configuration, infrastructure, CI | `PASS` — `phases/A1_ARCHITECTURE.md` |
| A2 | Flutter app, state, lifecycle, concurrency, navigation | `READY` — not started |
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
| `FND-BUG-001` | Android release manifest declares no `INTERNET` permission | P1 | High | `Accepted` | W1 |
| `FND-ARCH-001` | XP write invariant narrower than implementation | P2 | High | `Accepted` | W1 |
| `FND-GOV-001` | No agent could write `docs/audit/**` | P2 | Confirmed | **`Fixed`** (A0.1, end-to-end verified) | W0 |
| `FND-BUG-002` | Release build signed with the debug keystore | P2 | High | `Accepted` | W1 |
| `FND-TEST-001` | CI cannot detect platform, formatting, or generated-code regressions | P2 | High | `Accepted` | W3 |
| `FND-GOV-004` | Git approval gates do not match `AGENTS.md` §8 | P2 | High | `Accepted` | W1 |
| `FND-SEC-001` | Shell secret gates cover a short list of command spellings | P2 | High | `Accepted` | W1 |
| `FND-GOV-002` | `PROJECT_CONTEXT.md` is stale on its own baseline | P3 | Confirmed | `Accepted` | W4 |
| `FND-GOV-003` | Shell matcher semantics for chained commands | P3 | High | **`False Positive`** (A0.1) | — |
| `FND-INTG-001` | Documented local auth redirect is not in the Auth allowlist | P3 | High | `Accepted` | W4 |
| `FND-ARCH-002` | Two localization mechanisms; the standard one carries no product text | P3 | High | `Accepted` | W4 |
| `FND-ARCH-003` | Stated timezone invariant is narrower than the per-user implementation | P3 | High | `Accepted` | W4 |
| `FND-BUG-003` | Platform display name is the Flutter template default | P4 | High | `Accepted` | W1 |
| `FND-GOV-005` | Stale analyzer transcript tracked as `app/analysis.txt` | P4 | High | `Accepted` | W4 |

Totals: **16 findings** — 0 `P0`, 3 `P1`, 6 `P2`, 5 `P3`, 2 `P4`. Confidence: 2 `Confirmed`,
12 `High`, 2 `Medium`. Status: 2 `Needs Verification`, 12 `Accepted`, 1 `Fixed`, 1 `False Positive`.
Markdown and JSON agree; verified by a script that compares every ID, severity, confidence and status
pair (`phases/A1_ARCHITECTURE.md` §13).

`FND-CONC-001`, `FND-DATA-001` and `FND-ARCH-001` are inherited from S3 and have **not** been
re-verified. Every A1 finding is `High`, not `Confirmed`: each rests on a static read, and the runtime
step that would promote it is recorded as `NOT RUN` with its reason in `phases/A1_ARCHITECTURE.md`
§12.1.

## 3. Git state

| Item | Value |
|---|---|
| Branch | `main` |
| HEAD at A1 entry | `e8c7c8e7e346790ac1807dc5c8d4e43c2ee880ef` (`e8c7c8e`) |
| `origin/main` at A1 entry | `e8c7c8e` — equal to local |
| Tree at A1 entry | clean, `git status --porcelain=v1` → 0 entries |
| History | linear: `e8c7c8e → 947da1e → 425686c → e400dbc → 9c8e142 → 59450c0 → b4063c6 → 17ca562` |
| A1 checkpoint commit | This file is committed as the A1 checkpoint. A commit cannot contain its own SHA, so the SHA and the push outcome are recorded by the one-line record commit that immediately follows, which is the same convention `e8c7c8e` used for the D-024 checkpoint |
| Push | Normal `git push origin main`, authorized for this task. Verification: `git ls-remote origin refs/heads/main` must equal local `git rev-parse HEAD` |
| History operations | none — no reset, rebase, amend, checkout, stash, clean, or force-push |

## 4. What A1 actually did

Covered every item in the A0.1 §6 prompt; nothing was skipped. Detail and quoted output are in
`phases/A1_ARCHITECTURE.md`.

| Area | Result |
|---|---|
| Baseline and acting agent | `PASS` — branch, HEAD, remote and tree verified; acting agent proven from the server as `gymlvl-orchestrator` |
| Toolchain | `PASS` — local Flutter 3.38.5 / Dart 3.10.4 matches the CI pin and the lock `sdks:` floor |
| `flutter analyze` | `PASS` — `No issues found! (ran in 2.5s)`, exit 0 |
| `dart format --set-exit-if-changed` | `PASS` — `Formatted 125 files (0 changed)`, exit 0 |
| Architecture vs code | Runtime topology matches the docs; the module map is incomplete (`ui/theme`, `ui/widgets`, `l10n` missing); one invariant is narrower than the code (`FND-ARCH-003`) |
| Dependencies | 12 runtime + 7 dev direct deps, all caret ranges; 147 locked packages; 0 git/path deps; no overrides; no dependency-audit gate |
| Lint configuration | `flutter_lints` only — no `analyzer:` section, so "analyze clean" is a baseline-lint result |
| Platform configuration | three release-blocking/template defects found (`FND-BUG-001…003`) |
| Localization | two parallel mechanisms; the ARB pipeline carries 1 of 104 keys (`FND-ARCH-002`) |
| CI | read end to end; 8 gate gaps recorded as `FND-TEST-001` |
| Agent governance | 73 global + 62 agent rules; the evaluator's own probe set `PASS`; 18 added probes → `FAIL (12 probe failures)` → `FND-GOV-004`, `FND-SEC-001` |
| Migrations | scheme `YYYYMMDDHHMMSS_snake_case.sql`, enforced by `tools/db-tests/run.mjs:30`; 17 tables all `IF NOT EXISTS`; 44 policy statements → 22 effective at tip; 11 `SECURITY DEFINER`; 10 triggers; no destructive DDL |
| Config contracts | 5 of 7 hold; the auth redirect contract is broken (`FND-INTG-001`) |
| Documentation currency | 15 stale claims inventoried across nine documents; dated blocks and stage records classified as not stale (`FND-GOV-002` inventory complete) |
| Coverage | C-22 `Reviewed (static)`, C-25 extended, C-26 `Reviewed (static)` |

Two A0 measurement figures were corrected: migrations 1,222 → 1,377 total / 1,219 non-blank, and
`verify.yml` 58 → 52 lines. Both are audit-internal fixes; neither changes a finding.

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
Created at A1: `docs/audit/phases/A1_ARCHITECTURE.md`.

Planning updates (per `AGENTS.md` §6): `docs/planning/TASK_BOARD.md`,
`docs/planning/SESSION_HANDOFF.md`, `docs/planning/CHANGELOG_AI.md`.

`docs/audit/REMEDIATION_PLAN.md` was deliberately **not** updated: its own update trigger is "stage A6,
then after each wave". A6 populates it from the 16-finding register.

## 6. Exact next action — A2

Run the following as one scoped stage. Do not begin A3 inside it.

> **A2 — Flutter app, state management, lifecycle, concurrency, navigation, UI integration.**
> Read `docs/audit/{AUDIT_SCOPE,AUDIT_COVERAGE,MASTER_FINDINGS}.md`, `docs/audit/SESSION_HANDOFF.md`
> and `docs/audit/phases/A1_ARCHITECTURE.md` first, then perform a read-only review of
> `app/lib/**` and `app/test/**` in this order: bootstrap and dependency injection
> (`main.dart`, `core/config`); router and shell (`core/router/**`, deep links, auth redirect,
> active-workout banner); theme and design tokens (`core/theme/**`, `ui/candy/**`, `ui/theme/**`);
> shared widgets (`ui/widgets/**`); localization behaviour (`core/localization/**` plus the VI/EN
> rendering question left open by `FND-ARCH-002`); then each feature in dependency order — auth,
> onboarding, dashboard, workout (presentation only), quests, progression (display half), profile,
> coach.
> Re-verify the carried candidates `FND-CONC-001` (reproduce the `discardLocalBackup` re-entrancy with
> a fake repository whose `cancel` never completes, and assert with a timeout) and the presentation
> half of `FND-ARCH-001`.
> Deliverables: `docs/audit/phases/A2_FLUTTER.md`; new findings in the register with all required
> fields; coverage updated for C-01…C-05, C-07, C-08, C-16 and the presentation half of
> C-10/C-11/C-12; handoff updated with Git state and the next action.
> Constraints: no code or configuration change, no dependency install, no commit, no push.
> Report to the user in Vietnamese.

### Executor and method for A2

- **Executor:** the acting primary agent coordinates and writes every artifact. Delegate
  `flutter-specialist` for controller/state/lifecycle review, `ui-ux-specialist` for layout, theme,
  accessibility and VI/EN rendering, `qa-reviewer` for an independent read of the concurrency claim,
  and `context-keeper` only if a documentation conflict appears. Run shell-dependent subagents
  **sequentially** (D-021); read-only work may be parallelised, but sequential is safer.
- **Every new finding must carry all fourteen fields** listed in `README.md` §8 plus `wave` and
  `verification_method`, in both `MASTER_FINDINGS.md` and `FINDINGS_REGISTER.json`.
- **Confidence ceiling for A2:** `Confirmed` only where a command was run and its output quoted. A
  reproduction of `FND-CONC-001` via `flutter test` would qualify; a read of the controller would not.
- **Do not re-open `FND-ARCH-002` as a new finding.** It is registered; A2 supplies the rendering
  evidence its remediation depends on.

### Acceptance criteria for A2

1. `docs/audit/phases/A2_FLUTTER.md` exists and covers every item in the prompt above, or states
   explicitly which item was skipped and why.
2. Every new finding is in both the register JSON and the markdown with identical ID, severity,
   confidence and status; the JSON parses; declared counts equal actual counts.
3. `AUDIT_COVERAGE.md` shows an updated status and a named reviewer for C-01…C-05, C-07, C-08, C-16 and
   the presentation half of C-10/C-11/C-12.
4. `FND-CONC-001` is either reproduced with a named command whose output is quoted, or explicitly
   recorded as still unverified with the reason.
5. `SESSION_HANDOFF.md` records Git state, what A2 actually did, open investigations and the exact A3
   prompt.
6. No file outside `docs/audit/**` and the three planning files was modified, verified by
   `git status --porcelain=v1`.
7. The user report is in Vietnamese, with `PASS`/`FAIL`/`BLOCKED`/`NOT RUN` and quoted evidence.

## 7. Open investigations carried into A2

| Item | State after A1 |
|---|---|
| `FND-CONC-001` reproduction | Open. Not attempted in A1 (concurrency is A2/A4 scope). Needs a fake repository whose `cancel` never completes, plus a timeout assertion. |
| Permission-gate enforcement | Open, and deliberately not closed by a live probe. `FND-GOV-004` and `FND-SEC-001` are `High`; promoting them requires user approval to issue one destructive command per spelling. |
| Android merged release manifest | Open. `FND-BUG-001` rests on the merger rule, not on a produced artifact. One `flutter build apk --release` would confirm it. |
| Auth redirect runtime behaviour | Open. `FND-INTG-001` needs `supabase start` and one `POST /auth/v1/recover`. |
| Generated-code drift | Open and **unmeasured**: running `build_runner` writes files, so A1 did not check whether the committed `*.freezed.dart` / `*.g.dart` are current. This must be measured before `FND-TEST-001`'s drift gate is enabled. |
| CI runner behaviour | Open. `FND-TEST-001` is a static read of the workflow; no CI run was observed from this session. |
| Localization rendering | Open. `FND-ARCH-002` records the architecture; VI/EN rendering, diacritics and the `bilingual` mode are A2 (C-05). |
| Migration history on a remote | Open. A1 established the local scheme and its enforcement; which migrations a remote has applied is A3. |
| `FND-ARCH-001` fourth-writer question | Open. A4 owns it; the wording fix must not land before then. |
| A1 artifacts | `docs/audit/phases/A1_ARCHITECTURE.md` exists and is complete. |

## 8. Anything a resuming session must not assume

- That `flutter analyze` clean means the code is strictly typed. `analysis_options.yaml` enables
  nothing beyond `flutter_lints`.
- That the permission layer enforces `AGENTS.md` §8. It gates 6 of 18 probed operations.
- That a release build works. It cannot reach the network, and it would be signed with a debug key.
- That CI would catch either. It builds web only.
- That the ARB files are the product's text. They hold one key of 104.
- That A0's inventory numbers are exact. Two were off; both are corrected in `AUDIT_COVERAGE.md` §2.
- That a previous stage's findings are verified. Only `FND-GOV-001` has a verified fix.
