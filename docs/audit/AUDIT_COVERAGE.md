# Audit Coverage

**Stage:** A2 (reconciled documentation-only PARTIAL checkpoint; matrix opened at A0)
**Baseline:** `main` @ `7eb40f1`
**Rule:** a component is `Reviewed (static)` only when a named reviewer read the code path. Listing a
directory is `Not Reviewed`. Coverage measures attention, not correctness.

## 1. Status vocabulary

| Status | Meaning |
|---|---|
| `Not Reviewed` | Inventoried only. No code path read. |
| `In Review` | Review started; findings incomplete. |
| `Reviewed (static)` | Read end to end by a named reviewer; findings recorded. Not executed. |
| `Verified (runtime)` | Read **and** exercised by a named command whose output is quoted. |
| `Deferred` | Deliberately postponed, with the reason recorded. |
| `Out of Scope` | Excluded by `AUDIT_SCOPE.md` §3. |

## 2. Inventory (measured at A0, remeasured at A1)

| Area | Files | Lines | Notes |
|---|---|---|---|
| `app/lib/**` Dart | 111 | 18,673 | 17 generated (`*.freezed.dart`, `*.g.dart`) |
| `app/test/**` Dart | 14 | 2,453 | 126 tests reported by `flutter test` (S3) |
| `supabase/migrations/*.sql` | 3 | 1,377 (1,219 non-blank) | 17 tables, 44 `CREATE POLICY` statements, 22 policies effective at tip, 11 `SECURITY DEFINER` functions, 15 distinct functions (18 definitions), 10 triggers |
| `supabase/tests/*.sql` | 2 | 170 | progression + security regression |
| `supabase/functions/**` `.ts` | 12 | 443 | 6 deployed handlers + 2 shared modules + 3 test files |
| `tools/**` (excl. `node_modules`) | 16 | 2,018 | SQL harness, Edge runner, browser smoke, E2E scripts |
| `.github/workflows` | 1 | 52 (48 non-blank) | `verify.yml`, 2 jobs |
| `.opencode/**` | 20 | — | 7 agents, 6 skills, 6 commands, 1 config |
| `docs/**` | 60+ | — | Planning memory, audit, verification screenshots |

`app/lib` by layer (non-generated 94 files): `core` 9, `data` 4, `domain` 13, `presentation` 37,
`ui` 23, other 8.

Feature inventory: `workout` 33, `dashboard` 15, `auth` 8, `quests` 7, `onboarding` 6, `coach` 2,
`progression` 2, `profile` 1.

**Corrections applied at A1** (`phases/A1_ARCHITECTURE.md` §12, O-2/O-3):

- Migrations: A0 recorded 1,222 lines. Remeasured at `e8c7c8e`: **1,377 total, 1,219 non-blank**
  (661/349/367 total; 550/335/334 non-blank). `PROJECT_CONTEXT.md:92-94`'s 661/349/367 are total lines
  and are correct.
- `verify.yml`: A0 recorded 58 lines. It is **52 (48 non-blank)** and has been unchanged since
  `56c1122`.
- Policies: 44 is the count of `CREATE POLICY` **statements**; the baseline set is dropped and replaced
  by `progression:61-70`, so **22** policies are effective at the migration tip. C-20's "44" is
  therefore a textual count, not a live count.
- `SECURITY DEFINER` (11) and triggers (10) are confirmed after excluding one commented-out occurrence
  of each in `baseline:47` and `baseline:48`.

## 3. Coverage matrix

| ID | Component | Paths | Stage | Status | Reviewer | Evidence source | Known limitation |
|---|---|---|---|---|---|---|---|
| C-01 | App bootstrap & DI | `app/lib/main.dart`, `core/config` | A2 | `Reviewed (static)` | flutter-specialist (A2 original + reconciliation) | A2 sections 2.1,8.2 lead13: initialization failure gate inspected | No device bootstrap execution; absence of retry alone not defect |
| C-02 | Router & shell | `core/router/**` | A2 | `Reviewed (static)` | flutter-specialist (A2 reconciliation) | Four files; A2 section 8.2 leads8,11-13; summary BUG007 | Live auth callbacks/lifecycle/performance deferred A5; lead10 recovery widget probe remains A2 |
| C-03 | Theme & design tokens | `core/theme/**`, `ui/candy/**` | A2 | `Reviewed (static)` | ui-ux-specialist (A2 original + reconciliation) | A2 section 8.2 leads1,2,5,6; BUG004 | Keyboard, hit regions, text-scale/device checks deferred A5 |
| C-04 | Shared widgets | `ui/widgets/**` | A2 | `Reviewed (static)` | ui-ux-specialist (A2 original + reconciliation) | Four system/status widgets inspected; phase 2.1/8.2 | Not all interaction/semantics paths executed |
| C-05 | Localization | `core/localization/**`, `app/lib/l10n/**`, `app/l10n.yaml` | A2 | `Reviewed (static)` | ui-ux-specialist, flutter-specialist (A2) | ARCH002 extended; phase 8.2 leads7,22 | Bilingual clipping/device diacritics and screen-reader behavior deferred A5 |
| C-06 | Auth feature | `features/auth/**` | A2 | `Reviewed (static)` | flutter-specialist, supabase-specialist; qa-reviewer (A2) | Auth forms/providers/repository inspected; phase 8.2 leads9,10,12,13 | Lead10 remains A2 runtime follow-up; no live Auth server |
| C-07 | Onboarding | `features/onboarding/**` | A2 | `Reviewed (static)` | ui-ux-specialist (A2 original + reconciliation) | Screen/controller inspected; unselected gender label BUG004 | Runtime chip background/large text deferred A5; domain semantics not claimed |
| C-08 | Dashboard | `features/dashboard/**` | A2 | `Reviewed (static)` | ui-ux-specialist, supabase-specialist (A2) | Unlabeled recent-three KPI BUG005 and quest BUG006 | KPI intended time-window still Needs Verification; domain stats math not executed |
| C-09 | Workout domain | `features/workout/domain/**` | A4 | `Not Reviewed` | — | — | — |
| C-10 | Workout controllers | `features/workout/presentation/controllers/**` | A2, A4 | `In Review` | qa-reviewer, flutter-specialist, orchestrator (A2) | A2 client half read; retained seven synthetic probes in A2_PROBES; CONC001/SEC002 narrowed Confirmed | Mixed-stage row: A4 semantics pending, post-await race deferred A5; no whole-row runtime claim |
| C-11 | Workout screens/widgets | `features/workout/presentation/{screens,widgets}/**` | A2 | `Reviewed (static)` | flutter-specialist (A2 recovery + reconciliation) | Exact manifest phase 2.2, all leads dispositioned in 8.2; INTG004/BUG007 | Timed backend semantics A4, numeric/locale/lifecycle UI runtime A5 |
| C-12 | Repositories (client data layer) | `features/*/data/**` | A2, A4 | `In Review` | supabase-specialist, flutter-specialist (A2) | A2 client contracts read; INTG002/003/004; phase 8.2 | Live RPC/RLS and A4 semantics not verified; partial reorder/add retry deferred A4 |
| C-13 | Quests | `features/quests/**` | A2 presentation, A4 domain | `In Review` | ui-ux-specialist, supabase-specialist (A2) | Presentation/provider static review complete; BUG006, ARCH001 client evidence | Domain/day-boundary logic remains A4 |
| C-14 | Progression engine | `features/progression/**` | A2 display, A4 domain | `In Review` | ui-ux-specialist (A2) | Display half read; ARCH002 copy evidence extended | Engine/reward authority remains A4 |
| C-15 | Coach (AI client) | `features/coach/**` | A2 client, A4 semantics | `In Review` | ui-ux-specialist, supabase-specialist, flutter-specialist (A2) | Screen/repository static review; INTG003; blanket error-flattening rejected | A4 semantics pending; 4001-character continuation contract test A5 |
| C-16 | Profile | `features/profile/**` | A2 | `Reviewed (static)` | ui-ux-specialist (A2 original + reconciliation) | Explicit white-on-white BUG004; whole screen previously read | Device rendering/large text and screen-reader behavior A5 |
| C-17 | SQL: baseline schema | `20261026000100_baseline.sql` | A3 | `Not Reviewed` | — | — | Legacy schema; additive-only |
| C-18 | SQL: progression | `20261026000200_authoritative_progression.sql` | A3, A4 | `Not Reviewed` | — | S3 TEST D read | `FND-DATA-001`, `FND-ARCH-001` carried |
| C-19 | SQL: catalog metadata | `20261027000100_exercise_catalog_metadata.sql` | A3 | `Not Reviewed` | — | — | 150 curated rows |
| C-20 | RLS policies (44 statements, 22 effective at tip) | all migrations | A3 | `Not Reviewed` | — | — | Cannot exercise policies without live DB |
| C-21 | Edge Functions | `supabase/functions/**` | A3 | `Not Reviewed` | — | 15 unit tests exist | Gateway/auth path untested |
| C-22 | CI workflow | `.github/workflows/verify.yml` | A1 | `Reviewed (static)` | `qa-reviewer` (A1) + orchestrator re-read | A1 §6: 52-line workflow read end to end, both jobs, every gate named; gaps recorded as `FND-TEST-001` | Gate list verified statically; runner behaviour, action-pinning supply chain, and a failing run were `NOT RUN` |
| C-23 | Test harness | `tools/db-tests/**` | A5 | `Not Reviewed` | — | S3 ran it | Single-connection PostgreSQL |
| C-24 | Flutter tests | `app/test/**` | A5 | `Not Reviewed` | — | — | No golden tests |
| C-25 | Agent configuration | `.opencode/**` | A1, A6 | `Reviewed (static)` | build (A0), qa-reviewer (A0.1), orchestrator (A1) | A0 grep/read; A0.1 parsed every rule in all 7 agents + negative primary test; A1 parsed 73 global + 62 agent rules and ran 18 destructive-operation probes → 12 ungated (`FND-GOV-004`, `FND-SEC-001`) | Evaluator is a reimplementation of the rule model, not the harness; live per-spelling probe `NOT RUN` |
| C-26 | Planning documents | `docs/planning/**`, `docs/ARCHITECTURE.md`, `docs/agent-system/*.md` (reference docs only) | A1 | `Reviewed (static)` | build (A0), `context-keeper` (A1) + orchestrator re-check | A1 §10: 15 stale claims across nine documents; dated evidence blocks and stage records explicitly classified as not stale; `FND-GOV-002` evidence extended | Inventory complete, fixes not applied (W4) |
| C-27 | Legacy Java work | `.agent/`, `.agents/teamwork/` | — | `Out of Scope` | — | — | Preserved user work (D-018) |

## 4. Known coverage gaps recorded at A0

These are **observations about test infrastructure**, not yet findings. A5 formalizes them.

| # | Observation | Why it matters |
|---|---|---|
| G-01 | No golden-file tests (`matchesGoldenFile` count = 0). UI verification relies on widget assertions plus committed screenshots under `docs/verification/ui/`. | Visual regressions are caught by humans, not CI. |
| G-02 | Measured at A0: 158 suppression lines exist, of which 152 are in generated files (`*.freezed.dart`, `*.g.dart`, `app_localizations*.dart`) and 6 are `// ignore_for_file: invalid_annotation_target` on the hand-written Freezed models. **No ad-hoc inline `// ignore:` exists in hand-written code.** | Recorded as a positive result, not a gap. A2 re-checks after any model change. |
| G-03 | No test file imports `features/quests/**` or `features/dashboard/domain/dashboard_stats.dart` directly. | Those domains may be exercised only indirectly, if at all. |
| G-04 | `app/test/verify_logic.dart` is a 3-line shim delegating to `progression_engine_test.dart`. | Harmless, but it inflates the test-file count and could hide an empty suite. |
| G-05 | SQL harness runs an isolated single-connection PostgreSQL 17.5 (stated by the harness itself). | Concurrency, RLS enforcement under real roles, and Supabase gateway behaviour are unverified. |
| G-06 | No coverage measurement exists (`flutter test --coverage` never run in CI). | Coverage percentages must not be claimed anywhere in this audit. |

## 5. Remaining work

All 27 components are inventoried. Historical A1 close: 3 reviewed, 1 in review, 22 not reviewed,
1 out of scope. At this reconciled PARTIAL A2 checkpoint: **13 `Reviewed (static)`, 5 `In Review`,
8 `Not Reviewed`, 1 `Out of Scope`**. No whole component is promoted to runtime-verified merely
because existing widget tests passed. **No component may be described as "audited" until its stage closes.**

Stage-by-stage target: A1 closed C-22, C-25 and C-26; A2 closes C-01…C-05, C-07, C-08, C-16 and the
presentation half of C-10/C-11/C-12; A3 closes C-17…C-21; A4 closes C-09, C-13…C-15 and re-verifies
the inherited candidates; A5 closes C-23, C-24 and the G-series gaps; A6 reconciles.

A1 added no new G-series gap: the missing CI gates it found are recorded as `FND-TEST-001` instead,
because they are a defect in an existing gate rather than an unmeasured area.

A2 remains PARTIAL despite completed static reconciliation: lead10's focused auth/recovery widget
assertion remains in A2, and a final executable A3 handoff has not been issued. Mixed A2/A4 rows
explicitly retain the unreviewed domain half. All deferred runtime investigations have owners and
target stages in A2_FLUTTER section 8.2; no device/runtime coverage percentage is claimed.
