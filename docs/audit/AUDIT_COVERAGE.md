# Audit Coverage

**A7 execution overlay:** attention counts below remain26static-reviewed+1excluded, not runtime
certification. Local W0 policy/ACL/stream and W1 snapshot/async/receipt fixes have permanent focused
and batch tests in A7_BATCH_EXECUTION.md (fullFlutter200, source-platform10 included). R1-04/07 actual
DB sessions and R1-05/06 merged/signing/artifact checks remain BLOCKED; source checks do not promote
whole components. A6 audit matrix/history below is retained, current implementation status in A7 ledger.

**Stage:** A6 CLOSED (scoped reconciliation/roadmap PASS; explicit A5 failed/blocked/unexecuted gaps retained)
**Baseline:** `main` @ `1763ab5` for A5; PARTIAL614ee7c advances docs only; earlier inventory retains provenance.
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
| C-02 | Router & shell | `core/router/**` | A2, A5 | `Reviewed (static)` | flutter-specialist, qa-reviewer | A2 source review plus A5 actual router/Auth Lead10 fixture, BUG008 | Live callback/device back-stack and route-wide keyboard traversal unexecuted; Flutter/QA W2/W4 |
| C-03 | Theme & design tokens | `core/theme/**`, `ui/candy/**` | A2, A5 | `Reviewed (static)` | ui-ux-specialist, qa-reviewer | A5 real Candy keyboard vs System positive control BUG009; narrow hit/text fixtures; A2 retained | Primitive fixtures not all variants/screens/device; disabled counter weak, no loading claim; UI/QA W2 |
| C-04 | Shared widgets | `ui/widgets/**` | A2, A5 | `Reviewed (static)` | ui-ux-specialist | A2 four widgets; A5 SystemButton keyboard control and StatusPanel320dp/200% VI/EN | Not all interaction/semantics/focus paths executed; UI/QA W2 |
| C-05 | Localization | `core/localization/**`, `app/lib/l10n/**`, `app/l10n.yaml` | A2, A5 | `Reviewed (static)` | ui-ux-specialist, flutter-specialist | A5 actual dictionary/provider/delegates/fonts VI/EN component fixtures, ARCH002 retained | Raster sample not physical/screen-reader/all translations; bilingual and complete-flow clipping unexecuted, UI/QA W2/W4 |
| C-06 | Auth feature | `features/auth/**` | A2, A5 | `Reviewed (static)` | flutter-specialist, supabase-specialist, qa-reviewer | Lead10 actual controller/forms/router synthetic failed-signin/recovery plus update controls, BUG008 | Real token issuer/refresh/recovery/gateway not run; supported isolated Auth stack required, Flutter/Supabase/QA W4 |
| C-07 | Onboarding | `features/onboarding/**` | A2, A5 | `Reviewed (static)` | ui-ux-specialist | A2 static BUG004; A5 actual fixture reaches gender assertion but two whole tests FAIL on nullable chip-paint sampling | Selected/day-chip contrast NOT RUN to completion; no whole-test PASS; finite UI/QA W2 composited-paint/320dp200% assertion |
| C-08 | Dashboard | `features/dashboard/**` | A2 | `Reviewed (static)` | ui-ux-specialist, supabase-specialist (A2) | Unlabeled recent-three KPI BUG005 and quest BUG006 | KPI intended time-window still Needs Verification; domain stats math not executed |
| C-09 | Workout domain | `features/workout/domain/**` | A4, A5 | `Reviewed (static)` | flutter-specialist, exercise-catalog | A4 seven domain files; A5 actual QuestInstance/controller seeded generated JSON and HTTP defaults INTG007 | Fake completion22023/local predicate are not SQL/gateway E2E; full timed-row UI/gateway assertion remains Flutter/Supabase/QA W2 |
| C-10 | Workout controllers | `features/workout/presentation/controllers/**` | A2, A4, A5 | `Reviewed (static)` | flutter-specialist, qa-reviewer | A5 post-await identity/completion/cancel CONC001 addendum; lost-ACK/reorder/hydration/Dart-mode fixtures | B controller state loss not B DB mutation; persistence mocked; real gateway/transport schedules W1 Flutter/Supabase/QA |
| C-11 | Workout screens/widgets | `features/workout/presentation/{screens,widgets}/**` | A2, A5 contract | `Reviewed (static)` | flutter-specialist, ui-ux-specialist | A2 manifest/lead dispositions retained; A5 actual Add Set method used by screen INTG004, not rendered row tap | Real timed-row tap/hidden-field/keyboard/numeric/background flow not executed; UI/Flutter/QA W2 |
| C-12 | Repositories (client data layer) | `features/*/data/**` | A2, A4, A5 | `Reviewed (static)` | flutter-specialist, supabase-specialist | Real repository HTTP sequence with injected transport; INTG002, INTG008/009, legitimate204/forbidden403 delete controls | Modeled server commits not PostgreSQL/gateway duplicate or authorization proof; W1 isolated-stack controls |
| C-13 | Quests | `features/quests/**` | A2, A4, A5 | `Reviewed (static)` | supabase-specialist, flutter-specialist, qa-reviewer | A5 generated SQL JSON->actual Dart mismatch closes mirrored-client gap; isolated same-day expiry-only controls pass | No rendered quest-to-realSQL award journey; lock-wait/timezone-history policy and concurrency need approved isolated stack, W1/W2 |
| C-14 | Progression engine | `features/progression/**` | A2, A4, A5 tests | `Reviewed (static)` | flutter-specialist, supabase-specialist, qa-reviewer | A4 bounded reward evidence retained; A5 test meaning and fake commit/replay limitations reviewed | Single connection not independent concurrency; no production cohort or full preview parity, W1 Supabase/QA |
| C-15 | Coach (AI client) | `features/coach/**` | A2, A4, A5 reliability | `Reviewed (static)` | flutter-specialist, supabase-specialist | Optional chat-only boundary retained; A5 counted streams/provider/error/timeout/context review SEC004 | INTG003 actual4001-character continuation NOT RUN; real provider/network/timeouts/gateway unexecuted, W2/W4 |
| C-16 | Profile | `features/profile/**` | A2, A5 | `Reviewed (static)` | ui-ux-specialist, qa-reviewer | Actual ProfileScreen display/edit foreground1:1 under light theme, VI/EN390dp100%, BUG004 | Not full profile/modal/device320dp200%/screen-reader coverage; UI/QA W2 |
| C-17 | SQL: baseline schema | `20261026000100_baseline.sql` | A3, A5 harness | `Reviewed (static)` | supabase-specialist; orchestrator critical-path re-read | A3 full baseline/security review; A5 FK19/15leading-index census and bounded EXPLAIN | Fresh in-memory schema not deployed/adopted; four FK index absences not proof of slowdown; W1/W3 policy/scale follow-up |
| C-18 | SQL: progression | `20261026000200_authoritative_progression.sql` | A3, A4 | `Reviewed (static)` | supabase-specialist, qa-reviewer, orchestrator | A3 security plus A4 award/maintenance/class/quest/date business review; A4_SQL_EVIDENCE8groups/108assertions and existing SQL suite | Conditional prior-award fixture not production cohort; single-connection replay/rollback not independent scheduling or transport recovery |
| C-19 | SQL: catalog metadata | `20261027000100_exercise_catalog_metadata.sql` | A3, A4, A5 | `Reviewed (static)` | supabase-specialist, exercise-catalog, flutter-specialist | A4 timed CHECK/completion INTG005; A5 all150slug/UUID pairs preserved on seed replay and actual generated JSON->Dart defaults | Deployed NOT VALID legacy rows and complete timed SQL/gateway journey not certified; W1/W2, no media |
| C-20 | RLS policies (44 statements, 22 effective at tip) | all migrations | A3, A5 harness | `Reviewed (static)` | supabase-specialist, qa-reviewer | A3 role subset retained; A5 maps original assertions versus full17-table operations and GUC/JWT limitations | Complete role/JWT/gateway matrix BLOCKED without approved isolated stack; no live/deployed bypass inferred, W1/W4 |
| C-21 | Edge Functions | `supabase/functions/**` | A3, A5 | `Reviewed (static)` | supabase-specialist, qa-reviewer, orchestrator | A5 current15tests/sixchecks plus12request/3provider counted streams; auth before buffering and SEC004 bounded mechanism | No hostedJWT/networkcancel/DoS/memory/actual15s enforcement/telemetry proof; W2/W4 Supabase/QA |
| C-22 | CI workflow | `.github/workflows/verify.yml` | A1 | `Reviewed (static)` | `qa-reviewer` (A1) + orchestrator re-read | A1 §6: 52-line workflow read end to end, both jobs, every gate named; gaps recorded as `FND-TEST-001` | Gate list verified statically; runner behaviour, action-pinning supply chain, and a failing run were `NOT RUN` |
| C-23 | Test harness | `tools/db-tests/**` | A5 | `Reviewed (static)` | supabase-specialist, qa-reviewer, orchestrator | All16 tracked harness text/code files plus SQL/Edge fixtures/CI inspected;10 unit meaning/mocks/role inventory/optional live-script limits; A5_BACKEND_EVIDENCE | Single-connection not concurrency; optional live/private/browser scripts intentionally NOT RUN; no production/coverage certification |
| C-24 | Flutter tests | `app/test/**` | A5 | `Reviewed (static)` | flutter-specialist, ui-ux-specialist, qa-reviewer, orchestrator | All14files/2624lines,13discovered+wrapper; real/reference fixture distinction TEST002; current126regressions and bounded probes | No coverage percentage/golden/device/frame budget; targeted UI aggregate FAIL8pass2fixturefail, not126suite failure; explicit wave-owned gaps |
| C-25 | Agent configuration | `.opencode/**` | A1, A6 | `Reviewed (static)` | build (A0), qa-reviewer (A0.1), orchestrator (A1) | A0 grep/read; A0.1 parsed every rule in all 7 agents + negative primary test; A1 parsed 73 global + 62 agent rules and ran 18 destructive-operation probes → 12 ungated (`FND-GOV-004`, `FND-SEC-001`) | Evaluator is a reimplementation of the rule model, not the harness; live per-spelling probe `NOT RUN` |
| C-26 | Planning documents | `docs/planning/**`, `docs/ARCHITECTURE.md`, `docs/agent-system/*.md` (reference docs only) | A1 | `Reviewed (static)` | build (A0), `context-keeper` (A1) + orchestrator re-check | A1 §10: 15 stale claims across nine documents; dated evidence blocks and stage records explicitly classified as not stale; `FND-GOV-002` evidence extended | Inventory complete, fixes not applied (W4) |
| C-27 | Legacy Java work | `.agent/`, `.agents/teamwork/` | — | `Out of Scope` | — | — | Preserved user work (D-018) |

## 4. Known coverage gaps recorded at A0

These are historical A0 observations. A5 dispositions below distinguish actual findings, positive
evidence and finite gaps; an absent test style is not automatically a product defect.

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
1 out of scope. A2 closed at13 reviewed/5 in review/8 not reviewed/1 out; A3 at18/5/3/1; A4 at24/0/2/1.
**26 `Reviewed (static)`, 0 `In Review`, 0 `Not Reviewed`, 1 `Out of Scope`** at A5 reconciliation. No whole component is promoted to runtime-verified merely
because existing widget tests passed. **No component may be described as "audited" until its stage closes.**

Stage-by-stage target: A1 closed C-22, C-25 and C-26; A2 closes C-01…C-05, C-07, C-08, C-16 and the
presentation half of C-10/C-11/C-12; A3 closes C-17…C-21; A4 closes C-09, C-13…C-15 and re-verifies
the inherited candidates; A5 closes C-23, C-24 and the G-series gaps; A6 reconciles.

A1 added no new G-series gap: the missing CI gates it found are recorded as `FND-TEST-001` instead,
because they are a defect in an existing gate rather than an unmeasured area.

**Historical A2 closeout context (superseded A3 entry and mixed-stage status, preserved):**
A2 scoped audit is CLOSED after the seven original acceptance criteria are evaluated in A2_FLUTTER
section9. Lead10 runtime verification explicitly belongs to A5, not a continuing A2 gate. Mixed
A2/A4 rows retain the unreviewed domain half. Exact A3 entry is in the current audit handoff and
requires separate authorization. All deferred investigations have owners, stages and assertions in
phase8.2/9.3; no device/runtime coverage percentage or product correctness guarantee is claimed.

A3/A4 inspection/evidence remains historical. A5 completes C23/C24 read coverage, inherited finite
runtime assertions or explicit dispositions, not exhaustive formal verification. Remaining transport/
gateway/concurrency/adoption/device checks have owners, triggers and assertions in A5 phase6 and
specialist evidence; A6 triages them into approval-gated owner waves, not automatic runtime work.
Positive synthetic controls do not assert every resource/role/deployed environment is verified.

**A5 dispositions for A0 G-series:** G01 no goldens ->W3 Flutter/UI visual regression policy, no
automatic finding. G02 generated/Freezed suppressions ->positive retained fact, not a defect. G03 no
direct quest/stats tests ->W3 regression gap; A5 actual model/default fixtures and SQL stats controls
are audit evidence, not added permanent coverage. G04 wrapper ->harmless manual entrypoint, not
another discovered suite (actual4lines). G05 single connection ->BLOCKED actual sessions/full gateway,
role subset exists and is not cryptographic JWT proof. G06 no coverage metric ->NOT RUN intentionally,
no percentage or threshold invented; W3 owner proposes meaningful coverage goals after approval.
Additional production-versus-replica coverage weakness is TEST002, not a duplicate of TEST001 CI gaps.
