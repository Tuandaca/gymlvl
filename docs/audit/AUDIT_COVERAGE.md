# Audit Coverage

**Stage:** A0
**Baseline:** `main` @ `9c8e142`
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

## 2. Inventory (measured at A0)

| Area | Files | Lines | Notes |
|---|---|---|---|
| `app/lib/**` Dart | 111 | 18,673 | 17 generated (`*.freezed.dart`, `*.g.dart`) |
| `app/test/**` Dart | 14 | 2,453 | 126 tests reported by `flutter test` (S3) |
| `supabase/migrations/*.sql` | 3 | 1,222 | 17 tables, 44 policies, 11 `SECURITY DEFINER` functions, 15 distinct functions (18 definitions), 10 triggers |
| `supabase/tests/*.sql` | 2 | 170 | progression + security regression |
| `supabase/functions/**` `.ts` | 12 | 443 | 6 deployed handlers + 2 shared modules + 3 test files |
| `tools/**` (excl. `node_modules`) | 16 | 2,018 | SQL harness, Edge runner, browser smoke, E2E scripts |
| `.github/workflows` | 1 | 58 | `verify.yml`, 2 jobs |
| `.opencode/**` | 20 | — | 7 agents, 6 skills, 6 commands, 1 config |
| `docs/**` | 60+ | — | Planning memory, audit, verification screenshots |

`app/lib` by layer (non-generated 94 files): `core` 9, `data` 4, `domain` 13, `presentation` 37,
`ui` 23, other 8.

Feature inventory: `workout` 33, `dashboard` 15, `auth` 8, `quests` 7, `onboarding` 6, `coach` 2,
`progression` 2, `profile` 1.

## 3. Coverage matrix

| ID | Component | Paths | Stage | Status | Reviewer | Evidence source | Known limitation |
|---|---|---|---|---|---|---|---|
| C-01 | App bootstrap & DI | `app/lib/main.dart`, `core/config` | A2 | `In Review` | build (A0) | A0 read `core/config/supabase_config.dart` only; `main.dart` not read | Not executed on device |
| C-02 | Router & shell | `core/router/**` | A2 | `Not Reviewed` | — | — | Deep-link behaviour unverified |
| C-03 | Theme & design tokens | `core/theme/**`, `ui/candy/**` | A2 | `Not Reviewed` | — | — | Visual fidelity needs screenshots |
| C-04 | Shared widgets | `ui/widgets/**` | A2 | `Not Reviewed` | — | — | — |
| C-05 | Localization | `core/localization/**`, `app/lib/l10n/**`, `app/l10n.yaml` | A2 | `Not Reviewed` | — | — | VI/EN parity not machine-checked |
| C-06 | Auth feature | `features/auth/**` | A2 | `Not Reviewed` | — | — | No live Auth server |
| C-07 | Onboarding | `features/onboarding/**` | A2 | `Not Reviewed` | — | — | 1,284-line screen, splits needed |
| C-08 | Dashboard | `features/dashboard/**` | A2 | `Not Reviewed` | — | — | Stats math duplicated server-side |
| C-09 | Workout domain | `features/workout/domain/**` | A4 | `Not Reviewed` | — | — | — |
| C-10 | Workout controllers | `features/workout/presentation/controllers/**` | A2, A4 | `Not Reviewed` | — | S3 TEST C read | S3 flags carried: `FND-CONC-001` |
| C-11 | Workout screens/widgets | `features/workout/presentation/{screens,widgets}/**` | A2 | `Not Reviewed` | — | — | — |
| C-12 | Repositories (client data layer) | `features/*/data/**` | A2, A4 | `Not Reviewed` | — | — | RPC contract verified only statically |
| C-13 | Quests | `features/quests/**` | A4 | `Not Reviewed` | — | — | Day-boundary logic untested |
| C-14 | Progression engine | `features/progression/**` | A4 | `Not Reviewed` | — | S3 baseline tests exist | Client preview vs server truth |
| C-15 | Coach (AI client) | `features/coach/**` | A4 | `Not Reviewed` | — | — | No provider configured |
| C-16 | Profile | `features/profile/**` | A2 | `Not Reviewed` | — | — | 1,201-line screen |
| C-17 | SQL: baseline schema | `20261026000100_baseline.sql` | A3 | `Not Reviewed` | — | — | Legacy schema; additive-only |
| C-18 | SQL: progression | `20261026000200_authoritative_progression.sql` | A3, A4 | `Not Reviewed` | — | S3 TEST D read | `FND-DATA-001`, `FND-ARCH-001` carried |
| C-19 | SQL: catalog metadata | `20261027000100_exercise_catalog_metadata.sql` | A3 | `Not Reviewed` | — | — | 150 curated rows |
| C-20 | RLS policies (44) | all migrations | A3 | `Not Reviewed` | — | — | Cannot exercise policies without live DB |
| C-21 | Edge Functions | `supabase/functions/**` | A3 | `Not Reviewed` | — | 15 unit tests exist | Gateway/auth path untested |
| C-22 | CI workflow | `.github/workflows/verify.yml` | A1 | `Not Reviewed` | — | — | — |
| C-23 | Test harness | `tools/db-tests/**` | A5 | `Not Reviewed` | — | S3 ran it | Single-connection PostgreSQL |
| C-24 | Flutter tests | `app/test/**` | A5 | `Not Reviewed` | — | — | No golden tests |
| C-25 | Agent configuration | `.opencode/**` | A1, A6 | `Reviewed (static)` | build (A0), qa-reviewer (A0.1) | A0 grep/read; A0.1 parsed every rule in all 7 agents + negative primary test | Runtime binding unverified in a new session |
| C-26 | Planning documents | `docs/planning/**` | A1 | `In Review` | build (A0) | A0 measured `PROJECT_CONTEXT.md` §2 as stale (`FND-GOV-002`) | Remaining stale claims not yet inventoried |
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

All 27 components are inventoried. At A0, 1 is `Reviewed (static)`, 2 are `In Review`, 23 are
`Not Reviewed`, 1 is `Out of Scope`. **No component may be described as "audited" until its stage
closes.**

Stage-by-stage target: A1 closes C-22, C-25, C-26; A2 closes C-01…C-05, C-07, C-08, C-16 and the
presentation half of C-10/C-11/C-12; A3 closes C-17…C-21; A4 closes C-09, C-13…C-15 and re-verifies
the inherited candidates; A5 closes C-23, C-24 and the G-series gaps; A6 reconciles.
