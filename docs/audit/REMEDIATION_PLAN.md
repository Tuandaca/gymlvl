# Remediation Plan

**Stage:** A0 (framework only)
**Baseline:** `main` @ `9c8e142`
**Status:** Skeleton. Populated at A6; wave contents below are provisional and marked as such.

## 1. Rules

1. **No remediation during A0–A6.** Audit stages produce findings; remediation is a separate,
   authorized activity.
2. **One wave at a time.** A wave starts only after the previous wave's exit criteria are met and the
   user authorizes it.
3. **Every fix carries a test that fails before it and passes after.** A fix without a failing-first
   test is not accepted, except for pure documentation findings.
4. **No fix may weaken RLS, grants, or the server-authoritative XP boundary.**
5. **Additive migrations only** (`AGENTS.md` §4). No drop, rename, or truncate of user-linked objects.
6. **A finding is closed only with named evidence** — a command, a test, or a quoted output — not with
   an assertion that it "should be fine".

## 2. Waves

| Wave | Purpose | Trigger | Exit criteria |
|---|---|---|---|
| **W0** | Make the audit program executable under its intended agent | User approval of FND-GOV-001 | Orchestrator can write `docs/audit/**`; verified by an actual write |
| **W1** | Release-critical correctness: the defects already known before A1–A6 complete | A6 triage **or** explicit early authorization if a P0/P1 is confirmed | Every P0 fixed; every P1 fixed or explicitly deferred with a written rationale |
| **W2** | Correctness and integrity cluster surfaced by A2–A4 | A6 triage | All `Accepted` P1/P2 in those domains closed or deferred |
| **W3** | Test-gap closure (A5), so regressions cannot silently return | A5 complete | Each closed gap has a test in CI; no code path declared "covered" without a test |
| **W4** | Architecture and documentation truth pass (A1, A6) | A6 triage | Invariants, ADRs, and README claims match the code |
| **W5** | Performance and maintainability debt | After W1–W4 | Deferred by default; schedule only if measurable |

## 3. Provisional content

Assigned by the audit, not by preference. Only findings with a mechanism understood well enough to
plan against are listed.

### W0

| Finding | Action | Owner | Blocker |
|---|---|---|---|
| `FND-GOV-001` | Add `edit docs/audit/* allow` to the orchestrator | Project owner approval | **Applied in A0.1** (D-022). Configuration verified; one end-to-end write under the orchestrator profile still `NOT RUN` |

### W1

| Finding | Sev | Action | Blocker |
|---|---|---|---|
| `FND-CONC-001` | Reproduce with a fake repository, then remove the re-entrant enqueue and the post-await dereference | Flutter | Reproduction must come first; a fix without a failing test is rejected |
| `FND-DATA-001` | Backfill `workout_rewards`, verify counts, then tighten the legacy branch | Supabase | Needs a live database or a faithful legacy fixture |
| `FND-ARCH-001` | Restate the invariant in `AGENTS.md`, `ARCHITECTURE.md`, `PROJECT_CONTEXT.md` | Lead | Documentation approval; A4 confirms there is no fourth writer |
| `FND-GOV-003` | Closed as `False Positive` in A0.1 — the V2 docs define shell resources as per-command scanner output, so `cd X; <denied>` cannot inherit the `cd *` allow | Tooling | None; no change required |

### W4

| Finding | Action | Owner | Blocker |
|---|---|---|---|
| `FND-GOV-002` | Restate the baseline block as a rule plus a dated last-observed SHA; drop or date the file count | Docs | A1's stale-claim inventory |

## 4. Dependencies and ordering

- `FND-DATA-001` depends on a data-state measurement; it cannot be planned to a date until that
  measurement exists. Do not schedule it as if it were a code-only fix.
- `FND-ARCH-001` is documentation-only but must be sequenced **after** A4's writer inventory, or the
  corrected wording can itself be wrong.
- `FND-CONC-001` and the A4 workout-lifecycle findings touch the same file
  (`active_workout_controller.dart`). One writer at a time; sequence A2's concurrency fix before any
  A4 refactor, or combine them deliberately in one reviewed change.
- `FND-GOV-001` is **closed at configuration level** (A0.1, D-022). The remaining risk is behavioural: no
  stage has yet written an artifact while running as the orchestrator. The first A1 write is the
  end-to-end test; if it is denied, reopen the finding rather than widening the allowlist again.

## 5. Non-goals

Explicitly **not** part of remediation:

- OpenGym feature parity or any migration work.
- Exercise media procurement (D-003).
- Dependency upgrades beyond a security-critical fix, and only with approval.
- Re-architecture of the app into the target architecture in `ARCHITECTURE.md` §5.
- Test coverage percentage targets. Coverage is not measured (G-06) and no number may be claimed.
- Refactoring for style. A finding must state a behavioral or integrity consequence to earn a slot.

## 6. Change record

| Date | Change | Reason |
|---|---|---|
| 2026-10-28 | Framework created at A0 | Program start |
