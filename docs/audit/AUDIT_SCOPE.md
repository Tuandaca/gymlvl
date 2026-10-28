# Audit Scope

**Stage:** A0
**Baseline:** `main` @ `9c8e142`
**Status:** Frozen for A0; changes require an entry in §7.

## 1. Objective

Produce a defensible inventory of defects in the **current** GymLvl implementation — the code that
exists at `9c8e142` — so that (a) the upcoming OpenGym migration does not inherit known defects, and
(b) release-critical problems are known before feature work resumes.

## 2. In scope

| Area | Paths | Stage |
|---|---|---|
| Flutter application | `app/lib/**` (111 files, 18,673 lines) | A2 |
| Flutter tests | `app/test/**` (14 files, 2,453 lines) | A5 |
| Flutter build config | `app/pubspec.yaml`, `app/analysis_options.yaml`, `app/android/**`, `app/ios/**`, `app/web/**` | A1, A2 |
| Database migrations | `supabase/migrations/*.sql` (3 files, 1,222 lines) | A3 |
| Database tests | `supabase/tests/*.sql` (2 files, 170 lines) | A5 |
| Edge Functions | `supabase/functions/**` (12 files, 443 lines) | A3 |
| Test tooling | `tools/**` excluding `node_modules` (16 scripts, 2,018 lines) | A5 |
| CI | `.github/workflows/verify.yml` | A1 |
| Agent/tooling configuration | `.opencode/**` | A1 (static), A6 (process) |
| Client\(\leftrightarrow\)server contract | Dart repositories + RPCs + Edge handlers | A4 |
| Cross-cutting business logic | XP, levels, streaks, quests, rewards, workout lifecycle | A4 |

## 3. Out of scope — do not audit, do not change

| Excluded | Reason |
|---|---|
| OpenGym repositories and the 575 external skills | Reference-only per `AGENTS.md` §0 non-negotiables 6–7; already covered by S1 (see `docs/agent-system/SOURCE_AUDIT.md`) |
| Exercise media, image/GIF/video assets | None exist; media is out of scope per D-003 |
| Production Java/Antigravity work under `.agent/`, `.agents/teamwork/` | Preserved user work (D-018); read-only and not part of this codebase's runtime |
| `app/build/**`, `.dart_tool/**`, `tools/db-tests/node_modules/**` | Generated or vendored |
| Live/production Supabase project, credentials, deployments | No access authorized; no destructive database operation permitted |
| Migration to OpenGym feature parity | A separate, later program; explicitly not started |
| Historical planning phases under `docs/planning/phase*/` | Historical record, not current behavior. Read only where they explain a current design choice |

## 4. Audit constraints

1. **No behavior change.** A0–A6 produce documents only. Any code change requires a separate,
   authorized remediation task.
2. **No destructive operation.** No migration applied, no table altered, no deploy, no dependency
   install.
3. **Runtime verification is limited** to what the repository can execute locally: `flutter analyze`,
   `flutter test`, `dart format --set-exit-if-changed`, the SQL harness (`tools/db-tests`, an isolated
   PostgreSQL 17.5), and the Edge unit tests. A live Supabase stack (gateway, Auth, Realtime,
   concurrent sessions) is **not available**; any finding that depends on it is capped at confidence
   `Medium` unless the mechanism is provable from SQL alone.
4. **One writer per file.** Subagents review; the orchestrator (or the acting primary agent) writes
   the audit artifacts.
5. **Sequential delegation** for anything that needs a shell (D-021).

## 5. Inherited candidates from S3

`docs/agent-system/S3_VALIDATION_REPORT.md` §10 recorded three product-level risks. They are imported
here as **unverified candidates** — not re-verified, not duplicated under new reasoning:

| S3 ID | Imported as | Note |
|---|---|---|
| L4 | `FND-CONC-001` | Potential deadlock `active_workout_controller.dart` L207-215; null deref L659-670 |
| L5 | `FND-DATA-001` | Legacy `is_xp_calculated = false` path in `complete_workout` L230 may double-award |
| L6 | `FND-ARCH-001` | "Only `complete_workout` writes XP" is imprecise: `initialize_user`, `sync_daily_data`, `switch_class` also write progression state |

S3 risks L1–L3 and L7–L8 are **program/tooling** items, not codebase defects. L1 is operationally
closed by D-021, L2 is a session-start check, L7 is a licensing task, L8 is a review action. They are
tracked in `docs/planning/TASK_BOARD.md`, not duplicated here. L3 is a prompt-quality note.

## 6. Known limitations of this audit

1. **No live environment.** RLS correctness, auth flows, Realtime, and concurrent-writer behavior
   cannot be exercised. Review is static plus unit-level.
2. **No device or platform run.** Android/iOS build, offline behavior, and background timers are
   unverified.
3. **Derived-code blindness by design.** `*.freezed.dart` and `*.g.dart` are generated; they are
   reviewed only for shape (fields that leak to the client), not audited line by line.
4. **Agents are not exhaustive.** A subagent returns what its prompt scoped. Absence of a finding in a
   domain is not proof of absence of defects; `AUDIT_COVERAGE.md` records coverage, not correctness.
5. **S3 findings are inherited unverified.** They were produced in a different session and are
   re-checked in A2/A3/A4 before being promoted.
6. **Severity is judgment.** The scale in `README.md` §5 is applied consistently, but a borderline
   P1/P2 call is recorded with its rationale rather than asserted.

## 7. Change record

| Date | Change | Reason |
|---|---|---|
| 2026-10-28 | Initial scope frozen at A0 | Program start |
