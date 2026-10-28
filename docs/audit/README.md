# GymLvl — Audit Program

**Status:** Active
**Established:** 2026-10-28 (stage A0)
**Baseline:** `main` @ `9c8e142`
**Owner:** GymLvl orchestrator (coordination) + six specialists (domain review)
**Contract:** `AGENTS.md` outranks every document here.

This directory is the authoritative, persistent state of the audit. Conversation history is
disposable; these files are not. Any session may resume from
[`SESSION_HANDOFF.md`](SESSION_HANDOFF.md) without reading prior transcripts.

## 1. Purpose

Establish an evidence-driven audit of the existing GymLvl codebase **before** the OpenGym migration
begins, so that known defects are not reproduced in the migration and so that remediation can be
sequenced on evidence rather than intuition.

The audit identifies and classifies defects. It does **not** fix them. Remediation is a separate,
authorized activity governed by [`REMEDIATION_PLAN.md`](REMEDIATION_PLAN.md).

## 2. Document map

| File | Contents | Update trigger |
|---|---|---|
| `README.md` | Program definition, ID scheme, severity/confidence scales, status vocabulary | Changing the audit method |
| `AUDIT_SCOPE.md` | In-scope and out-of-scope areas, constraints, inherited context | Scope change |
| `AUDIT_COVERAGE.md` | Component inventory and per-component review status | End of every stage |
| `MASTER_FINDINGS.md` | Human-readable finding register, ordered by ID | Every new or changed finding |
| `FINDINGS_REGISTER.json` | Machine-readable mirror of the register | Same time as `MASTER_FINDINGS.md` |
| `REMEDIATION_PLAN.md` | Waves, entry/exit criteria, dependencies, non-goals | Stage A6, then after each wave |
| `SESSION_HANDOFF.md` | Current stage, Git state, next action, open investigations | End of every stage |
| `phases/A<n>_*.md` | Per-stage scope, method, evidence, and results | During and after that stage |

Precedence inside this directory: `SESSION_HANDOFF.md` (current state) → `MASTER_FINDINGS.md` /
`FINDINGS_REGISTER.json` (findings) → `AUDIT_COVERAGE.md` (coverage) → `REMEDIATION_PLAN.md` (plan)
→ phase files (evidence detail).

## 3. Stages

| Stage | Scope | Output |
|---|---|---|
| A0 | Bootstrap, baseline verification, inventory, execution plan | This directory initialized |
| A1 | Architecture, dependencies, configuration, infrastructure, CI | `phases/A1_*.md` |
| A2 | Flutter app, state management, lifecycle, concurrency, navigation, UI integration | `phases/A2_*.md` |
| A3 | Supabase/PostgreSQL, RLS, authn/authz, Edge Functions, data integrity | `phases/A3_*.md` |
| A4 | Workout lifecycle, XP, progression, rewards, cross-layer business logic | `phases/A4_*.md` |
| A5 | Tests, performance, reliability, observability, error handling | `phases/A5_*.md` |
| A6 | Cross-domain reconciliation, independent verification, triage, remediation planning | `phases/A6_*.md` |

Rules:

- A stage ends with a checkpoint commit candidate and a handoff update, not with remediation.
- A stage never auto-advances. Each stage requires an explicit instruction naming it.
- A stage may be split by module if its context budget would otherwise be exceeded.

## 4. Finding ID scheme

`FND-<CAT>-<NNN>`, for example `FND-DATA-001`.

IDs are allocated once and never reused. A finding that is closed keeps its ID; a finding that is
superseded keeps its ID and gains `superseded_by`. Numbers are per-category and monotonic.

| Category | Meaning |
|---|---|
| `SEC` | Security: authentication, authorization, RLS, secret handling, injection, privilege escalation |
| `BUG` | Functional defect: wrong behavior against a stated requirement or reasonable expectation |
| `CONC` | Concurrency, lifecycle, async ordering, timers, cancellation, race conditions |
| `ARCH` | Architecture: coupling, boundary violations, layering, undocumented ownership |
| `DATA` | Data integrity: constraints, idempotency, duplicate awards, migration safety, provenance |
| `PERF` | Performance: query shape, N+1, rebuild cost, payload size, startup |
| `TEST` | Test gaps, false confidence, harness limitations, non-determinism |
| `INTG` | Integration: client\(\leftrightarrow\)server contract, routing, serialization, error mapping |
| `GOV` | Governance and tooling: permissions, configuration, agent policy, documentation accuracy |

## 5. Severity scale

| Level | Definition | Exit criterion |
|---|---|---|
| **P0** | Exploitable now, or destroys/corrupts user data on a normal path. XP forgery, privilege escalation, unrecoverable data loss. | Blocks any release. Fix before any deploy. |
| **P1** | Serious integrity or security defect reachable by a real user on a plausible path, or a hang/crash that loses a workout. | Must fix before public release; may ship to internal testers. |
| **P2** | Incorrect behavior in a plausible edge case, degraded reliability, or a governance gap with a real operational effect. | Fix in the current milestone; document if deferred. |
| **P3** | Maintainability, performance, or coverage debt with no direct user-visible incorrectness. | Schedule; may be deferred indefinitely. |
| **P4** | Cosmetic, documentation-only, or naming issue. | Opportunistic. |

## 6. Confidence scale

| Level | Definition |
|---|---|
| **Confirmed** | Reproduced in this repository with a command or test, and the output is quoted in the evidence. |
| **High** | Read the exact code path end to end; mechanism is unambiguous; not executed. |
| **Medium** | Strong inference from partial code reading, or a mechanism that depends on runtime behavior not observed here. |
| **Low** | Hypothesis. Recorded so it is not lost; must be promoted or retired in a later stage. |

A finding's confidence describes *the finding*, not the severity of the bug. "High confidence, P3" and
"Low confidence, P0" are both valid and both must be honest.

Static reading alone never produces `Confirmed`.

## 7. Status vocabulary

| Status | Meaning |
|---|---|
| `Open` | Recorded, not yet investigated. |
| `Needs Verification` | Plausible mechanism identified; requires a runtime check, a test, or a second reviewer. |
| `Accepted` | Verified as a real defect; not yet fixed. |
| `Fixed` | Remediated, and the fix is verified by a named command or test. |
| `Deferred` | Real, accepted, and deliberately postponed. Requires a named trigger to revisit. |
| `False Positive` | Investigated and disproved. Kept, not deleted, with the reason. |

A finding is never deleted. A mistaken finding is moved to `False Positive` with its disproof attached.

## 8. Evidence rules

Every finding carries: ID, category, title, component, file paths and line ranges, root cause or
suspected mechanism, evidence, expected vs actual, security/data impact, severity, confidence,
proposed remediation, regression risk, related or missing tests, dependencies on other findings,
suggested remediation wave, and status.

Additionally:

- **Observed** facts and **hypotheses** are labelled distinctly. A hypothesis is never phrased as an
  observation.
- No test result, line number, file path, or coverage number may be invented. If a value was not
  measured, it is `NOT MEASURED` with the reason.
- A prior session's result is evidence from that session. It is re-verified before being reused as a
  current state, or it is explicitly marked as carried forward and unverified.
- Findings imported from another record (for example the S3 validation report) keep their origin,
  and are not duplicated under a second ID.

## 9. Safety rules during the audit

- No production code, migration, or data change.
- No deployment, no destructive SQL, no dependency installation.
- No credential exposure; no secret is copied into an audit artifact.
- No agent permission is widened to make a check pass.
- No automatic fix. A finding with an obvious one-line fix is still only a finding.
- Write access is limited to `docs/audit/**` and the planning files named in `AGENTS.md` §6.

## 10. Language

Per `AGENTS.md` §0.1: these artifacts are **English**. Reports to the user are **Vietnamese**. A
manual-action guide for the user, if one becomes necessary, is Vietnamese with identifiers intact.
