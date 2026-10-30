# GymLvl — Session Handoff

## Current — M0 OpenGym source pinning & migration foundation (2026-10-31)

**Task:** M0 — OpenGym source pinning & migration foundation (one migration slice).
**Status:** `PASS` for the implementation slice; source pin + mapping complete.
**Commit:** branch `main`, HEAD `6badfef29a871a978a09daee304dc1c3f3f69a84`; tree dirty by design (5 owner files preserved + 4 M0 files changed + 1 new manifest). No commit, push, tag, or deployment performed.
**Changed files (source/config/tests):** `app/lib/features/workout/presentation/widgets/rest_timer_widget.dart`, `app/lib/features/workout/presentation/screens/active_workout_screen.dart`, `app/lib/features/workout/workout_copy.dart`, `app/test/workout_widgets_test.dart`, `docs/planning/UPSTREAM_SOURCE_MANIFEST.json` (new).
**Verification:** `flutter analyze --no-pub` → `No issues found!` (exit 0); `dart format --output=none --set-exit-if-changed lib test` → 0 changed; `flutter test --no-pub` → `+231: All tests passed!` (231 tests, no regression).
**Source pin:** `https://github.com/DuarteSantos8/openGym` @ `e6a95c28a6e3067bdd9b1188d5f37f448d528bd2`; clone `D:\Projects\opengym-reference`; remote origin + HEAD verified. AGPL-3.0 = reference only.
**Licensing:** AGPL code/reference only; MIT text (`textSource=exercisedb`) reusable with notice, strip media; media EXCLUDED; GymLvl no LICENSE (O-01 open).
**Subagents used:** flutter-specialist (ses_e721c19f2ffeoi9CYIROH0cOS1), supabase-specialist (ses_e721c19f1ffeVBfgvsHL35Gicn), qa-reviewer (ses_e721c19eeffeqvSIepBiMtpcKk — BLOCKED on sandbox access to `D:\Projects\opengym-reference`, classification produced from project docs).
**Next action:** owner review; proposed next slice: exercise catalogue navigation/filter improvement (ADAPT, P1) or workout detail layout (ADAPT, P1).

## Historical — R2 controlled remediation A-1..A-8 executed locally, pre-commit (2026-10-29)

- **Task:** R2 batch — A-2 Auth redirect allowlist, A-3 Android merged-manifest gate, A-4 canonical
  findings sync, A-7 `GymLvl` branding, A-8 `app/analysis.txt` untracking, conditional A-1
  duplicate-XP guard.
- **Status:** `PASS` for the approved repository scope; final release/live gates `NOT RUN`/`BLOCKED`.
  Register after R2: Fixed 18 · Accepted 12 · Needs Verification 3 · False Positive 2 = 35
  (severity 0/3/24/6/2 and confidence 16/18/1/0 unchanged).
- **Commit:** branch `main`, HEAD `b85d674b27b7eb024b42a8d1b05d5f624a3ee6bc`; tree dirty by design
  (owner work + this batch; `app/analysis.txt` staged as deleted in the index only). No commit, push,
  tag, deployment or production migration was performed.
- **Changed files (source/config/tests):** `supabase/config.toml`, `app/config.example.json`,
  `README.md`, `docs/DEVELOPMENT.md`, `.github/workflows/verify.yml`, `app/.gitignore`,
  `app/lib/app.dart`, `app/lib/main.dart`, `app/lib/core/router/main_shell_screen.dart`,
  `app/lib/features/auth/presentation/screens/auth_form_screen.dart`,
  `app/lib/core/localization/localization_engine.dart`, `app/lib/l10n/{app_en.arb,app_vi.arb,
  app_localizations.dart,app_localizations_en.dart,app_localizations_vi.dart}`,
  `app/test/{widget_test.dart,adversarial_edge_test.dart}`, `supabase/tests/progression_regression.sql`.
  **Added:** `app/test/auth_redirect_config_test.dart`,
  `tools/android-verify/{manifest-check.mjs,run.mjs,manifest-check.test.mjs,package.json}`,
  `tools/audit-sync/sync-findings-r2.mjs`,
  `supabase/migrations/20261029000200_prevent_legacy_double_award.sql`.
  **Records:** `docs/audit/FINDINGS_REGISTER.json`, `docs/audit/MASTER_FINDINGS.md`,
  `docs/audits/codebase-health/{REMEDIATION_EXECUTION.md,FINDINGS_REGISTER.md,CODEBASE_HEALTH_REPORT.md,
  REMEDIATION_PRIORITY.md}`, `docs/planning/{DECISIONS.md,PROJECT_CONTEXT.md,TASK_BOARD.md,
  SESSION_HANDOFF.md,CHANGELOG_AI.md}`.
- **Verification (all executed in this session at `b85d674` + this batch):**
  `flutter analyze --no-pub` → exit 0, `No issues found!`;
  `dart format --output=none --set-exit-if-changed lib test` → 134 files, 0 changed;
  `flutter test --no-pub` → `+221: All tests passed!`;
  `node tools/db-tests/run.mjs` → 12 SQL units + 365 ACL assertions, exit 0;
  `node tools/db-tests/edge-tests.mjs` → 44/44, exit 0;
  `node tools/android-verify/manifest-check.test.mjs` → 8/8;
  `node tools/android-verify/run.mjs` → `PASS merged release manifest: package=com.gymlvl.app
  label=GymLvl internet=1 nested=0 duplicates=0`, exit 0.
  A-1 RED→GREEN: without the migration the new case fails
  (`FAIL: ledger-only legacy workout never earns twice`); with it, the suite passes.
- **Per-finding:** INTG-001 Fixed (config contract 6/6), BUG-001 Fixed (merged manifest),
  BUG-003 Fixed (`GymLvl` everywhere user-facing), GOV-005 Fixed (untracked + ignored, 84,864-byte
  local copy preserved), DATA-001 Fixed in repository scope. BUG-002 and TEST-001 stay Accepted
  (signing keys absent; CI unproven remotely); BUG-004 stays Accepted (partial contrast fix only).
- **Decisions:** D-035 Auth origin/allowlist, D-036 single brand spelling `GymLvl`, D-037 ledger
  evidence as prior-award provenance. D-034 carried.
- **Blockers:** A-1 production portion — live Supabase access (`O-07`), at-risk counts and any
  `workout_rewards` repair need operator approval; release APK/signature (`GYMLVL_RELEASE_*`), iOS
  build (Windows host), hosted Edge, live Auth round trip, remote CI and true two-connection
  concurrency are `NOT RUN`.
- **Finalization (2026-10-29):** `READY_FOR_APPROVAL`. Commit manifest and CI evidence are in
  `REMEDIATION_EXECUTION.md` §9: Commit A = 19 prior A-8 files, Commit B = 39 R2 files, 5 owner or
  ambiguous paths excluded (`app/android/gradle.properties`, `run_gradle.bat`, `gradle_check.ps1`,
  `run_gradle_check.bat`, `docs/audit/phases/A8_BATCH_EXECUTION.md`). Local gates re-run `PASS`
  (analyze 0, format 134/0, 221/221, SQL 12 units + 365 ACL, Edge 44/44, manifest 8/8 + gate exit 0,
  workflow YAML 3 jobs, register 35/18/12/3/2). Remote CI at `b85d674` is **red** in
  `database-and-edge` (`Expected 413, got 503` ×8 — missing hosted `SUPABASE_*` in that job); the
  pending `edge-tests.mjs` change targets exactly that failure but is unobserved remotely. `gh` is
  authenticated (repo scope); nothing was committed or pushed.
- **Next action:** owner approves the §9.4 manifest, then the push that triggers CI; separately
  approves `O-07` read-only counts. No further batch starts automatically.

## Current — R3 release-readiness hardening complete locally (2026-10-29)

- **Task:** CI hardening (FND-TEST-001), Android fail-closed signing (FND-BUG-002), remaining profile/onboarding contrast (FND-BUG-004), dashboard KPI window labeling (FND-BUG-005), Supabase data integrity (FND-DATA-001/D-037), and INTG-008/009 source confirmation. No production migration, deploy, signing-key or OpenGym change.
- **Commit / branch / remote:** `main` @ `aa52aa0a` == `origin/main`; index empty; working tree holds 12 modified tracked files total = **11 R3 edits + 1 owner edit (`app/android/gradle.properties`, excluded)**, plus **3 new R3 files** (`app/test/dashboard_kpi_window_test.dart`, `docs/admin/ANDROID_RELEASE_SIGNING_VI.md`, `tools/db-tests/cohort_validation.mjs`) and **4 other owner files untracked** (`app/android/run_gradle.bat`, `gradle_check.ps1`, `run_gradle_check.bat`, `docs/audit/phases/A8_BATCH_EXECUTION.md`). R3-owned paths = 14 (11 modified + 3 new); owner paths = 5, all preserved.
- **Local verification (status vocabulary AGENTS §5):**
  - `flutter analyze --no-pub` → `No issues found!` (exit 0)
  - `dart format --output=none --set-exit-if-changed lib test` → 135 files, 0 changed (exit 0)
  - `flutter test --no-pub --reporter expanded` → `+231: All tests passed!` (221 R2 baseline + 10 new)
  - `node tools/db-tests/run.mjs` → 12 SQL units + 365 ACL assertions PASS (exit 0)
  - `node tools/db-tests/edge-tests.mjs` → 44 passed / 0 failed (exit 0)
  - `node tools/android-verify/manifest-check.test.mjs` → 8/8; `invoke.test.mjs` → 10/10; gate `run.mjs` → exit 0
  - `package:yaml` parse of `.github/workflows/verify.yml` → 3 jobs
  - `:app:assembleRelease` (no signing inputs) → fails at `:app:validateReleaseSigningInputs`, **no APK/AAB produced**
- **CI changes** (`.github/workflows/verify.yml`): added `invoke.test.mjs` to the manifest-gate step (18 Android tests), `dart format` gate, per-job `timeout-minutes`, `concurrency`+cancel, `push.branches: [main]`, pinned Node-24 action SHAs. Generated-drift gate withheld (build_runner rewrites 12 files at locked versions). **NOT RUN remotely** — no push yet.
- **Supabase verification:** migration `20261029000200` re-validated as additive/idempotent; the two read-only cohort queries are recorded in `REMEDIATION_EXECUTION.md` §11.5 and schema-validated locally (cohort A/B execute on the migrated schema, guard+index present, positive control isolates exactly 1 synthetic at-risk tuple, negative control clears it, `complete_workout` returns `alreadyAwarded:true`). Production counts and two-connection concurrency remain **BLOCKED** (`O-07`, no real PostgreSQL host); PGlite is single-connection and is not concurrency proof.
- **Status:** REPOSITORY: R3 READY_FOR_APPROVAL · CI: R2 VERIFIED, R3 pending remote ✅/❌ · PRODUCTION: NOT VERIFIED · OPENGYM: NOT READY.
- **Next action:** owner reviews the R3 commit manifest (see response) and approves the push; then approve `O-07` read-only cohort counts. Release signing steps are documented for the owner in `docs/admin/ANDROID_RELEASE_SIGNING_VI.md` (no keys created, none committed). Stops at READY_FOR_APPROVAL; no push of code/CI without approval.

## R2 closure — commits, pushes, and remote CI (2026-10-29)

- **Commits:** `7a10031` (A-8, 19 files), `74aaa22` (R2, 39 files), `a018ec2` (CI invocation fix +
  regression tests, 4 files). All three pushed fast-forward to `origin/main`
  (`b85d674..74aaa22`, `74aaa22..a018ec2`); remote `main` = `a018ec2`.
- **First CI run `40832095175`** (https://github.com/Tuandaca/gymlvl/actions/runs/40832095175) at
  `74aaa22`: **failure**. `database-and-edge` **success** (the eight `Expected 413, got 503` failures
  are gone), `flutter` **success**, `android-release-manifest` **failure**.
- **Root cause:** `tools/android-verify/run.mjs` ran the wrapper with `sh`, but the Flutter-generated
  `app/android/gradlew` declares `#!/usr/bin/env bash` and uses bash array syntax at line 154 → `sh`
  (dash) aborts with `Syntax error: "(" unexpected`; the gate exits 2 (fail-closed). Tooling
  invocation defect, not an app or manifest defect.
- **Fix implemented in `a018ec2`:** new `tools/android-verify/gradle-invocation.mjs` spawns `bash` with
  the wrapper as `argv[1]` on POSIX (`shell: false`), keeps `gradlew.bat` through a shell on Windows,
  and reports a missing wrapper / failed merge / missing artifact as `BLOCKED` (exit 2). Ten regression
  tests in `invoke.test.mjs`; both suites wired into `package.json`.
- **Second CI run `40834000928`** (https://github.com/Tuandaca/gymlvl/actions/runs/40834000928) at
  `a018ec2`: **success** in all three jobs. The Android job now logs `BUILD SUCCESSFUL in 44s` and
  `PASS merged release manifest: package=com.gymlvl.app label=GymLvl internet=1 nested=0 duplicates=0`.
- **Status:** REPOSITORY: CLOSED · CI: VERIFIED · PRODUCTION: NOT VERIFIED · OPENGYM MIGRATION: NOT
  READY.
- **Known gap:** the job's `Unit-test the manifest gate` step still runs only `manifest-check.test.mjs`,
  so `invoke.test.mjs` is not enforced remotely yet. Wiring it in needs its own approval.
- **Uncommitted:** only the five excluded owner paths (`app/android/gradle.properties`,
  `app/android/run_gradle.bat`, `gradle_check.ps1`, `run_gradle_check.bat`,
  `docs/audit/phases/A8_BATCH_EXECUTION.md`).
- **Next action:** no R3 work has started. Owner decides between wiring `invoke.test.mjs` into CI,
  the `O-07` read-only counts, and the unchanged release/platform blockers (signing keys, iOS build,
  hosted Supabase/Auth, two-connection concurrency).

## Historical A8 batch — UI/config fixes, platform gates blocked (2026-10-29)

- **Task/status:** verification-first remediation of `docs/audit/FINDINGS_REGISTER.json` (35). 9
  findings fixed or partially fixed with regression tests, 5 re-verified as already fixed, 18 not
  re-verified, 2 reproduced and BLOCKED on approval, 1 checked and still open (GOV005). Overall
  PARTIAL; readiness NOT READY.
- **Commit:** `main` @ b85d674b27b7eb024b42a8d1b05d5f624a3ee6bc, tree dirty (owner work preserved).
  No commit, push, tag, migration, config, permission or deployment in this session.
- **Changed source/test:** app/android/app/src/main/AndroidManifest.xml, app/ios/Runner/Info.plist,
  app/pubspec.yaml, app/lib/core/router/app_router.dart,
  app/lib/features/auth/presentation/screens/reset_password_screen.dart,
  app/lib/features/dashboard/presentation/screens/dashboard_screen.dart,
  app/lib/features/profile/presentation/screens/profile_screen.dart,
  app/lib/features/quests/presentation/widgets/daily_quest_card.dart,
  app/lib/features/workout/presentation/screens/workout_summary_screen.dart,
  app/lib/ui/candy/candy_button.dart, app/lib/ui/candy/candy_quest_card.dart,
  app/test/release_config_test.dart, app/test/ui_regression_test.dart, tools/db-tests/edge-tests.mjs;
  new app/test/summary_truthfulness_test.dart, reset_password_entry_test.dart,
  candy_button_keyboard_test.dart, quest_card_truthfulness_test.dart.
- **Changed records:** docs/audits/codebase-health/{FINDINGS_REGISTER.md,REMEDIATION_EXECUTION.md},
  docs/planning/{PROJECT_CONTEXT.md,DECISIONS.md,TASK_BOARD.md,SESSION_HANDOFF.md,CHANGELOG_AI.md}.
- **Verification:** analyze0issues; format133files0changed; full215/215pass (200 at entry);
  SQL11units+ACL365; Edge44/44 (runner injects synthetic SUPABASE_* when absent). Merged manifest/APK,
  iOS build, hosted Edge, live Supabase Auth/RLS/concurrency NOT RUN.
- **Fixed:** BUG002/003 names+description, BUG004 partial contrast, BUG006 quest fallbacks,
  BUG007 summary deep link/500XP/level defaults, BUG008 recovery error scope, BUG009 keyboard
  CandyButton, TEST001 partial source gate, SEC004 runner env.
- **Still open:** GOV005 — the stale transcript is `app/analysis.txt` and `git ls-files app/analysis.txt`
  still lists it; removal needs A-8. An earlier root-path check was mis-read as a resolution.
- **Reproduced BLOCKED:** DATA001 second award total_xp100->110/level1->2/rewards0->1/ledger1->3;
  INTG001 site_url127.0.0.1:3000 vs app localhost:8080.
- **Decisions:** D-034 derived from D-029 (unknown reward/progress hidden, summary deep link redirects).
- **Blockers/approvals:** A-1 DATA001 migration+backfill, A-2 Auth allowlist config, A-3
  permission-gate hardening, A-4 canonical JSON status sync, A-5 isolated stack + Android device,
  A-6 live Supabase, A-7 brand spelling (launcher `GymLvl` vs in-app `GymLevel`), A-8 removal of the
  tracked `app/analysis.txt`. Details in docs/audits/codebase-health/REMEDIATION_EXECUTION.md §7.
- **Next action:** owner decides A-1..A-4, A-7, A-8; execute A-2 first (config-only), then A-1 with a
  read-only live count before any backfill.

## Historical A8 state (preserved)

## Previous — A8 PARTIAL; shell tool BLOCKED, docs-only fix for R2-06/ARCH-003 (2026-10-29)

- **Task/status:** A7 PARTIAL; completed local R0-01..04/R1-01..03 with independent QA. R1-04/07
  supported-stack verification BLOCKED; R1-05/06 source10checks pass but required Gradle tasks/signature
  not verified, acceptance BLOCKED. No W2-W5, production or migration, readiness NOT READY.
- **Commit:** entry main3d9dbb038a3a7e93ee4b3d4c51b10d8e066dbf75; B0 main57e4e73e88f7099ec29a9d075964817f4db5470d
  committed/pushed normally, local/remote equal/clean after checkpoint. Current expected B1 code/docs
  dirty; primary
  gymlvl-orchestrator verified. External bundle/bare/archive backup verified560files, hashes A7phase2.
- **Changed B1 source/test files:** app/lib/features/workout/data/supabase_workout_repository.dart,
  app/lib/features/workout/domain/workout_repository.dart,
  app/lib/features/workout/presentation/controllers/active_workout_controller.dart,
  app/lib/features/workout/presentation/screens/active_workout_screen.dart,
  app/lib/features/workout/workout_copy.dart, app/test/workout_controller_test.dart,
  app/test/workout_snapshot_ownership_test.dart, app/test/workout_async_identity_test.dart,
  app/test/workout_completion_reconciliation_test.dart; PARTIAL platform:
  app/android/app/src/main/AndroidManifest.xml, app/android/app/build.gradle.kts,
  app/android/gradle/wrapper/gradle-wrapper.properties, app/test/release_config_test.dart.
- **Changed B1 records:** docs/audit/phases/A7_BATCH_EXECUTION.md, docs/audit/FINDINGS_REGISTER.json,
  docs/audit/MASTER_FINDINGS.md, docs/audit/AUDIT_COVERAGE.md, docs/audit/SESSION_HANDOFF.md,
  docs/planning/DECISIONS.md, docs/planning/TASK_BOARD.md, docs/planning/SESSION_HANDOFF.md,
  docs/planning/CHANGELOG_AI.md. B0 exact paths/evidence in A7phase4, already checkpointed.
- **Decisions:** default shell ask; additive ACL fail-closed; byte caps RPC16KiB/Coach20000/provider
 256KiB; owner-match snapshot with conservative preserved legacy/foreign data. No production/deploy.
- **B0 verification:** parent policy32/SQL11+ACL365/Edge44/sixchecks all exit0, diff0; red/green and
  failed corrections A7phase4. QA npm.ps1/extra Git checks blocked, no bypass/runtime QA claim;
  independent code review found no material blocker. At B0 checkpoint GOV004/SEC001/003/004 Fixed,
  full history preserved,35 IDs/Accepted25/NV3/Fixed5/FP2; final B1 counts below supersede those totals.
  No deployed or sandbox/DoS claim; live tool permission/deployed DB/network NOT RUN.
- **B1 progress:** R1-01 independent31snapshot, R1-02 independent25async, R1-03 independent18receipt/
  renderedVIENcallback controls pass; parent analyze0issues/format129unchanged/full200pass on D temp,
  all exit0. No material code blocker. In-memory/shallow receipt only, no durableoutbox guarantee.
  SEC002/CONC001/INTG002 Fixed repo-only; platformBUG001/002 Accepted, not Fixed.35IDs/history kept,
  final statusesAccepted22/NV3/Fixed8/FP2; severity/confidence unchanged. Exact A7phase7.
- **Blockers:** DBstack executables absent; Android Gradle pinned8.13 verifiedSHA underD031, SDK/JBR21
  available, oneonline nativeOOM8Gheap and offline Kotlin2.1.20 cachemiss blocked task execution.
  D032 exact duplicateZIPdelete freed118MB on C, D temp/cache approved; no backup/oldtask cleanup,
  keys or SDK downloads. Actual mergedmanifest/signinggate/signature unverified, no extra networkloop.
- **Next action:** final QA and separate verified-core / explicitly PARTIAL platform checkpoints,
  then resume blocked B1 verification after supported backend/cache/resources/operator key prerequisites.
  No other eligible authorized branch remains; no B2-B4/migration automatically.

## Historical A6 closure (preserved)

## Current — A6 PASS/CLOSED; remediation NOT STARTED (2026-10-29)

**Checkpoint:** payload main4246b12238e4a904f87c0b843e861b637403d00c, nine docs +761/-3;
normal push6d8e89b..4246b12 exit0; local/remote fullSHA equal and status empty,
A6_PAYLOAD_EQUAL_CLEAN=PASS. This four-doc outcome-only child advances documentation HEAD;
verify actual latest main/remote on resume.

- **Task/status:** A6 only; PASS/CLOSED for scoped35-ID reconciliation/roadmap/independent QA,
  not remediation or production certification. A1-A5 closed; migration readiness NOT READY.
- **Commit:** entry main6d8e89bf6eba7b393ef2d0e0d52e9b0d5eb4f2c3 clean/remote equal; payload
  main4246b12 above normally pushed/verified. This outcome child edits only four handoff/planning
  docs. At entry actual
  gymlvl-orchestrator API verified. D-013 external bundle/bare/archive backup verified559files,
  hashes in A6phase2. No product/permanent-test/CI/config/permission/dependency change.
- **Owned files:** docs/audit/phases/A6_RECONCILIATION.md, docs/audit/REMEDIATION_PLAN.md,
  docs/audit/MASTER_FINDINGS.md, docs/audit/FINDINGS_REGISTER.json, docs/audit/AUDIT_COVERAGE.md,
  docs/audit/SESSION_HANDOFF.md, docs/planning/TASK_BOARD.md, docs/planning/SESSION_HANDOFF.md,
  docs/planning/CHANGELOG_AI.md. Nine docs only, one writer per file.
- **Progress:** all six specialists invoked sequentially, sessions in A6phase2. QA flagged R5-01
  missing R0-02 prerequisite; roadmap corrected. Final artifact QA/context found no material blocker.
  Preserve35 findings
  and nested histories. Product naming `GymLevel` versus `GymLvl`
  proposals conflict; defer brand choice to product owner before BUG003 remediation, no silent choice.
- **Decisions/blockers:** no material change; independent sessions/JWT gateway/device gaps retained.
  No production requirement or A6 closure blocker established. A5 UI FAIL remains historical.
- **Verification:** A6phase6 retained validator ->findings35/objects35 unchanged/closures4 unchanged/
  MD35/roadmap35/tasks29/DAG acyclic/oldplan exact/coverage26-0-0-1/paths9/errors0;
  A6_VALIDATION_EXIT node=0 diff=0, PASS. Initial five setup/label failures and corrections retained.
  Roadmap writer checked category29/order29/historyidentical/errors0, exit0. No runtime suite rerun.
- **Next action:** await explicit user approval for R0-01 safety gate followed by separately authorized
  R1-01 SEC002 snapshot ownership, one task at a time. Verify latest main/remote first. Stop before
  any W0/W1/remediation/migration execution.

## Historical A5 closure (preserved)

## Current — A5 PASS/CLOSED; A6 NOT STARTED (2026-10-28)

**Checkpoint outcome (2026-10-29):** closure payload main
ab19e97bd7c143ee7a140a461d774a4ebfea7443, nine-doc delta after PARTIAL614ee7c, aggregate A5 scope11docs.
Normal push614ee7c..ab19e97 exit0; local/remote refs/heads/main equal fullSHA and tree clean after push,
A5_CLOSURE_EQUAL_CLEAN=PASS. This outcome-only four-doc child advances HEAD; verify actual latest
main/remote on resume, not a self-referential commit claim.

- **Task/status:** A5 only, PASS/CLOSED for scoped audit acceptance, not product/production
  certification; mandatory scope reviewed or finite owned gaps dispositioned. A4 closed; A6 not started.
- **Commit:** entry main1763ab55e8da994bc1d854ad8fd2cd2299678b45; PARTIAL614ee7c then closure
  ab19e97 above, normally pushed and verified remote-equal/clean. This outcome child edits only
  audit handoff plus three planning docs; no findings/product/permanent-test/CI/dependency/config change.
- **Files since entry:** docs/audit/phases/A5_TEST_RELIABILITY.md,
  docs/audit/phases/A5_FLUTTER_EVIDENCE.md, docs/audit/phases/A5_BACKEND_EVIDENCE.md,
  docs/audit/phases/A5_UI_EVIDENCE.md, docs/audit/MASTER_FINDINGS.md,
  docs/audit/FINDINGS_REGISTER.json, docs/audit/AUDIT_COVERAGE.md, docs/audit/SESSION_HANDOFF.md,
  docs/planning/TASK_BOARD.md, docs/planning/SESSION_HANDOFF.md, docs/planning/CHANGELOG_AI.md.
- **Findings/coverage:**35 severity0/3/24/6/2, confidence16/18/1, Accepted29/NV3/Fixed1/FP2;
 30 oldIDs/history preserved, six exact pre-A5 objects, five narrow promotions/five newIDs,
 24 unchanged objects. New BUG008/009, INTG008/009, TEST002; transport pair stays High/NV.
  Coverage26static/0InReview/0NotReviewed/1excluded, no blanket runtime claim.
- **Delegation/QA:** all five actually invoked sequentially; material source/evidence inspection
  and final artifact/context reviews completed, no material closure blocker; stale documentary words
  corrected. QA source-diff BLOCKED(permission), keeper exit wrappers rejected, no retry/bypass or QA
  runtime claim; weak disabled counter qualified. Scope-qualified findings phase5, gaps phase6.
- **Verification:** primary analyze0issues(62.9s)/format125unchanged/test126, SQL10/Edge15/sixchecks
  all exit0; specialist Flutter18/streams15/UUID150/expiry-only/plans pass. UI aggregate FAIL8pass2
  nullable-chip fixture fails; external-file analyzer FAIL296 package-context issues, not app defects.
  Full retained commands/source/output/failures; defect-observing green never means a fix.
- **Decisions/blockers:** none material. Independent sessions/fullAuthJWTgateway require supported
  isolated stack (Docker/Supabase/Postgres commands unavailable); device/network/telemetry/performance
  budgets unexecuted, finite owner/wave/trigger assertions retained. No production requirement.
- **Artifact verification:** phase8 retained extraction/Node ->A5_ARTIFACT_CHECK json35/md35/oldIDs30/
  unchangedClasses25/unchangedObjects24/histories6/newIDs5/fields22/coverage26-0-0-1/allowedPaths11/
  unchangedInputs65/errors0, A5_VALIDATION_EXIT node=0 diff=0, PASS. Two primary validator metadata-
  shape FAILs corrected in validator only, retained; no finding change or permission widening.
- **Next action:** await explicit A6 go-ahead, then verify latest main/remote and use exact audit
  handoff **A6 entry prompt**. Stop before A6/remediation/migration automatically.

## Historical A5 start/PARTIAL state (preserved)

## Current — A5 audit in progress (2026-10-28)

- **Task/status:** A5 only, operational PARTIAL; scoped acceptance NOT RUN pending UI/QA/register
  reconciliation. Flutter/backend bounded reviews/probes complete. A4 remains closed.
- **Commit:** main1763ab55e8da994bc1d854ad8fd2cd2299678b45 clean/remote equal at entry; primary
  gymlvl-orchestrator verified. External bundle/bare/archive backup verified(555 files), A5phase2.
- **Files:** docs/audit/phases/A5_TEST_RELIABILITY.md, optional A5_FLUTTER_EVIDENCE.md,
  A5_BACKEND_EVIDENCE.md, A5_UI_EVIDENCE.md; findings mirrors/coverage/audit handoff and three planning
  records only. No product/permanent-test/migration/CI/dependency/config/permission changes.
- **Verification:** real context/Flutter/Supabase sessions in A5phase2. External Flutter18tests pass,
  analyze0issues; backend expiry-only/150UUIDreplay/12request+3providerstreams/SQL10/Edge15/sixchecks/
  EXPLAIN100-1000 exit0. Exact retained sources/outputs/initial failures in two evidence docs.
  UI/QA pending; existing30 finding objects/classifications unchanged, no new ID allocated yet.
- **Decisions/blockers:** no material decision/closure blocker established. Independent sessions
  BLOCKED: local Docker/Supabase/PostgreSQL executables unavailable; no supported isolated server.
  JWT gateway/device/cancellation unverified; no single-connection concurrency claim.
- **Next action:** persist A5 PARTIAL checkpoint then UI review/probes and material QA. Normal
  docs commits/pushes authorized; no A6/remediation/migration/secret/live/cleanup/full-app Temp copy.

## Historical A4 closure (preserved)

## Current — A4 PASS/CLOSED; A5 NOT STARTED (2026-10-28)

**Recorded A4 payload checkpoint:** main84462d0acc27a4c9ea0f99a2c0aa16c0940082fb, nine docs,
normal push `c95cb48..84462d0 main -> main`, exit0. Local/remote refs/heads/main equal full SHA;
status empty after push, A4_CHECKPOINT_EQUAL_CLEAN=PASS. This outcome-only child record advances
documentation HEAD; verify actual HEAD/remote on resume, not a self-referential commit claim.

- **Task/status:** A4 only, PASS/CLOSED for scoped audit acceptance with explicit deferred gaps;
  not product/production certification. A2/A3 remain CLOSED; A5 not started.
- **Commit:** entry main c95cb4873455b39f3ab2b6c0f929b43d87f4d8d3 clean/remote equal; payload
  main84462d0 above committed/pushed normally, clean/remote equal. This outcome record edits only
  four handoff/planning docs; no product/config/schema/permanent-test/agent/dependency changes.
- **Changed files:** docs/audit/phases/A4_WORKOUT_PROGRESSION.md,
  docs/audit/phases/A4_SQL_EVIDENCE.md, docs/audit/MASTER_FINDINGS.md,
  docs/audit/FINDINGS_REGISTER.json, docs/audit/AUDIT_COVERAGE.md, docs/audit/SESSION_HANDOFF.md,
  docs/planning/TASK_BOARD.md, docs/planning/SESSION_HANDOFF.md, docs/planning/CHANGELOG_AI.md.
- **Findings/coverage:**30 (P0 0/P1 3/P2 20/P3 5/P4 2; Confirmed9/High20/Medium1), Accepted24/
  NeedsVerification3/Fixed1/FalsePositive2;24 Reviewed(static)/0 InReview/2 NotReviewed/1 OutOfScope.
  All26 earlier IDs/history retained, only DATA001 and ARCH001 old classifications change. DATA001
  synthetic prior-credit/log falseflag/noledger duplicate global credit Confirmed; prod cohort and
  normal-retry duplication not established. ARCH001 FalsePositive (sole award vs maintenance), not
  Fixed. New DATA002 and INTG005-007; INTG007 timed quest journey remains High/NeedsVerification.
- **Delegation/QA:** all five required agents actually invoked sequentially; sessions/outputs in A4
  phase2. Independent material and final artifact-only inspection completed; context/QA stale wording
  corrections applied. No material closure blocker; no QA runtime rerun. QA scope/status/whitespace
  exit0; extra exclusion-diff command BLOCKED(permission), not retried or bypassed, permissions unchanged.
- **Verification:** node <A4 external path>/probe.mjs ->8groups/15 sequential DBs/108assertions/
  zero fetch/exit0, primary independent rerun also exit0; node tools/db-tests/run.mjs ->PASS10 units/
  PostgreSQL17.5, exit0; app analyze --no-pub ->No issues found(3.0s), format ->125files/0changed,
  tests --no-pub --reporter expanded ->+126 All tests passed, all exit0. Edge NOT RUN (unchanged).
  Initial catalogue-parser/legacy-title-validator FAILs corrected and retained; no product repair.
- **Artifact verification:** phase10 retained extraction/Node command -> A4_ARTIFACT_CHECK json30/
  md30/oldIDs26/unchangedClasses24/exactHistories2/newIDs4/fields22/coverage24-0-2-1/allowedPaths9/
  unchangedProbeInputs7/errors0; A4_VALIDATION_EXIT node=0 diff=0, PASS. Primary validator's three
  setup/overstrictness FAILs corrected in its own source only and retained; final context/QA completed.
- **Decisions/blockers:** no material decision or closure blocker established. Independent concurrency,
  transport-loss/reorder/delete/hydration, actual Dart quest, isolated expiry/device/gateway checks
  explicitly unexecuted with A5 owners/assertions in A4 phase8 and exact audit handoff prompt. No
  production inspection, full-app Temp copy or cleanup; prior A2 disposal still approval-gated.
- **Next action:** await explicit A5 authorization, then verify latest main/remote and use
  docs/audit/SESSION_HANDOFF.md **A5 entry prompt**. Stop; do not start A5/A6/remediation automatically.

## Historical A3 and prior handoffs (preserved)

## Current — A3 scoped audit CLOSED; A4 not started (2026-10-28)

**A3 checkpoint:** main c535613fe29cf5a435ead44a6c4c26a16e3074ae, nine docs, normal push
f877e40..c535613 main -> main, exit0. Remote main equals local full SHA, status empty after push.
This child outcome record advances documentation only; verify actual HEAD/remote on resume.

- **Task/status:** A3 Supabase/PostgreSQL/security C17-C21 PASS/CLOSED with assigned runtime gaps;
  not production certification. Entry main f877e40987423f3804fe0d2887c44d19f3423aff, clean/remote equal,
  API gymlvl-orchestrator. Normal docs commit/push authorized and completed as recorded above.
- **Changed files:** A3_SUPABASE_SECURITY.md, A3_SQL_EVIDENCE.md, audit findings/register/coverage/
  handoff; planning TASK_BOARD/SESSION_HANDOFF/CHANGELOG_AI. Nine docs only, no product/permanent test.
- **Findings:**26; P0 0/P1 3/P2 16/P3 5/P4 2; Confirmed5/High19/Medium2; Accepted21/
  NeedsVerification3/Fixed1/FalsePositive1. All24 prior IDs/classifications preserved; addenda on
  DATA001/ARCH001/SEC002. SEC003 conditional PUBLIC ACL fixture Confirmed, not production exploit;
  SEC004 buffering High/NeedsVerification, not confirmed DoS. No P0/P1 new finding.
- **Coverage:**18 static-reviewed/5 mixed-stage InReview/3 NotReviewed/1 excluded. A3 security halves
  complete, C18 reward semantics A4; C09/C23/C24 still not reviewed; no whole-row runtime claim.
- **Current checks:** SQL runner10 units/PostgreSQL17.5 PASS; Edge deny-net/cached-only/synthetic env
  15passed0failed, six handler checks PASS. Custom default FAIL falsifies named-role grant hypothesis;
  independent PUBLIC14 and named-control4 assertions PASS, exact source/output retained. No concealed
  failure, no live DB/provider traffic/secret reads/installs or persistent migration applied.
- **QA:** material source + repository retained evidence review completed; initial external read
  BLOCKED not bypassed. Fresh B-vs-A controls support limited server boundary, not local cache repair.
- **Current artifact checks:** orchestrator inline Node -> A3_CHECK json=26 md=26 old_ids_preserved=24
  old_classifications_preserved=24 required_fields=22 allowed_paths=9 errors=0; node0/diff0, current
  baseline f877e40. QA Git scope/whitespace pass; final missing durable output note was flagged and
  corrected here/phase12/audit handoff/changelog. Its parser/runtime checks NOT RUN.
- **Decisions/blockers:** no architecture/schema/dependency/permission change. Gateway/concurrency/
  deployed ACL verification unavailable and explicitly deferred; no A3 closure blocker. A2 Temp
  deletion still requires exact-path user approval; no cleanup.
- **Deferred:** A4 Supabase/Flutter/QA reward/legacy/order/retry/timed/domain semantics; A5 Supabase/
  Flutter/UI/QA gateway/Auth/resource/fullrole matrix; separate authorized deployment ACL inventory.
  Exact acceptance assertions in A3 phase9. Existing A2 Lead10 remains A5; A2 not reopened.
- **Next action:** await explicit A4 authorization, then audit handoff **A4 entry prompt**; do not
  begin A4, remediation or migration from this A3 task.

## Historical start/closure records (preserved)

## Current — A3 audit in progress (2026-10-28)

- **Task/status:** A3 C17-C21 only, in progress; acceptance NOT RUN pending inspection/QA.
- **Entry:** main f877e40987423f3804fe0d2887c44d19f3423aff, clean, remote equal; API agent
  gymlvl-orchestrator. A2 PASS/CLOSED preserved; no new A2 or A4 work.
- **Files:** A3_SUPABASE_SECURITY.md, audit findings/register/coverage/handoff and three planning
  records only. Name follows current explicit user instruction; no source/config/schema/test edits.
- **Verification:** Git and active-agent checks executed; SQL/Edge checks pending, no historical PASS reuse.
- **Decisions/blockers:** no new material decision; no external blocker established yet.
- **Next action:** sequential bounded Supabase schema/security review, Flutter Auth/contract review,
  independent QA; current progress retained in A3 phase, no live/production access or remediation.

## Historical A2 closure (preserved)

## Current — A2 CLOSED; A3 not started (2026-10-28)

**Recorded closure commit:** main `a6a57e2546afa8dbd3dd7113bc1096a6e99f5cdf`, eight docs;
normal push `aa36a4c..a6a57e2  main -> main`, exit0; remote verified equal and status empty
after push (`PASS`). This child record may advance HEAD; verify actual HEAD/remote on resume.

- **Task/status:** A2 scope closure, `PASS` against seven original audit acceptance criteria;
  operational **CLOSED** with owned A4/A5 deferred work. Not full runtime/product correctness.
- **Commit:** closure entry main `aa36a4c36e6c46cc7ae1f2fdd3e117f2a8a3a4c5`, clean, remote equal;
  documentation commit/normal push authorized. Confirm actual HEAD/remote on resume.
- **Changed files:** audit phase A2_FLUTTER, coverage, both registers, audit handoff; planning
  TASK_BOARD/SESSION_HANDOFF/CHANGELOG_AI. Eight docs only; A2_PROBES unchanged.
- **Preservation:** all 24 finding objects/classifications and 22 lead dispositions retained;
  counts P0 0/P1 3/P2 14/P3 5/P4 2; Confirmed 4/High 18/Medium 2; Accepted20/NeedsVerification2/
  Fixed1/FalsePositive1. Coverage remains13 static/5 mixed-stage in review/8 not reviewed/1 excluded.
- **Deferred:** Lead10 -> **A5**, explicit user instruction; flutter-specialist with independent
  qa-reviewer. Synthetic failed-signin -> recovery must not display password-update failure before
  submit; successful/rejected submit controls, retained isolated harness/command/output. NOT RUN,
  no promotion. Other A4/A5 owners and exact assertions in A2_FLUTTER sections8.2/9.3. No open A2 loop.
- **Verification:** current consistency/preservation/Git checks recorded in audit handoff/changelog.
  Existing +126 regression/+7 controller, analyzer and format outputs are historical; current Flutter
  runs NOT RUN intentionally for docs-only scope. Prior QA recorded; closure QA reviews artifacts only.
- **Current result:** inline Node closure check -> findings24/unchanged_objects24/MD24/fields22/
  dispositions22/Lead10A5/ACrecords7/authorized_paths8/errors0; node0/diff0. First attempt failed
  Unicode literal assertions through PowerShell; ASCII-safe rerun passed, no findings/product edits.
  Closure QA/context inspection supports the original scoped criteria and full deferral/A3 records;
  QA did not execute runtime tests. Final Vietnamese communication states PASS versus NOT RUN scope.
- **Decisions/blockers:** no material project decision or waived AC. No A2 closure blocker; future
  live/device checks stay unverified. Probe Temp removal still needs explicit exact-path approval.
- **Next action:** wait for explicit A3 authorization, then execute `docs/audit/SESSION_HANDOFF.md`
  **A3 entry prompt — authorization required**. No A3 or remediation execution in closure.

## Historical A2 partial handoffs (superseded current task/status/next action)

## Current — A2 reconciled PARTIAL checkpoint (2026-10-28)

**Git checkpoint:** `199bf00271c8038c04a8f8cbdc1fc35e7538e90f` on main, docs-only PARTIAL;
`git push origin main` -> `7eb40f1..199bf00  main -> main`, exit 0; `git ls-remote origin
refs/heads/main` equals checkpoint local SHA; tree empty after push (`PASS`). This SHA records the
audit checkpoint; this follow-up record may advance HEAD. Confirm actual HEAD/remote on resume.

- **Task/status:** A2 only, PARTIAL. Whole-stage acceptance `NOT RUN`; A3/remediation not started.
- **Commit/base:** `main` @ `7eb40f1d7e553e9f136abb13f632b8bfb189dc3c`; remote same at entry.
  Latest user authorizes normal PARTIAL documentation commit/push after consistency review; no rewrite.
- **Changed files:** audit findings/register/coverage/handoff, phases A2_FLUTTER/A2_PROBES; planning
  TASK_BOARD/SESSION_HANDOFF/CHANGELOG_AI (nine paths). Original dirty work backed up with nine
  SHA256 matches, bundle clone HEAD and archive 549/549 at
  `C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a2-final-backup-20261028-174845`.
- **State:** 22/22 leads dispositioned in phase section 8.2; seven new IDs. 24 findings:
  P0 0/P1 3/P2 14/P3 5/P4 2; Confirmed 4/High 18/Medium 2; Needs Verification 2/Accepted 20/
  Fixed 1/False Positive 1. CONC001 scope narrowed; post-await hypothesis deferred A5. SEC002
  controller-only synthetic adoption, not real account disclosure. DATA001 server claim unverified.
- **Coverage:** 13 static-reviewed, 5 mixed-stage in review, 8 not reviewed, 1 excluded. No whole-row
  runtime promotion. Deferred A4/A5 tests carry owners and exact assertions.
- **Current verification:** analyzer `No issues found! (ran in 8.5s)`; format `125 files (0 changed)`;
  Flutter `+126: All tests passed!`; all exit 0 at base 7eb40f1. Successful retained probes not rerun.
- **Consistency/QA:** orchestrator Node -> `MD=24 JSON=24 fields=22 old IDs=17 dispositions=22
  errors=0`, coverage13/5/8/1, nine allowed paths; exit 0, diff whitespace exit 0. Read-only QA found
  no documentation blocker, no omitted disposition or missing new field; whole-stage `NOT RUN`.
- **Temp:** full-copy inventory 1,351 files / 1,369,316,592 bytes, no reparse points. Exclusivity and
  disposal safety not proved; contents not read, nothing removed. User review and explicit exact-path
  approval required for `C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a2-probe-20261028`.
- **Decisions:** none affecting product/architecture/permissions/dependencies. Git authorization only.
- **Remaining work:** A2 lead10 focused synthetic recovery-widget assertion and independent QA;
  exact executable A3 handoff follows only after A2 closure. No external blocker claimed.
- **Next action (A2):** retain isolated widget probe: failed sign-in followed by recovery navigation
  must not show password-update failure before submission. Do not repeat whole-module reviews.

## Historical checkpoint records (superseded current-state statements)

## Current recovery checkpoint — A2 incomplete (2026-10-28)

**Continuation:** Retained synthetic probes in `docs/audit/phases/A2_PROBES.md` rerun by orchestrator:
`flutter test --no-pub --reporter expanded test/a2_retained_probe_test.dart` -> `+7: All tests passed!`,
exit 0. Defect-observing tests show active-discard timeout and cross-owner local state adoption with
fake null/error remote; controls pass. QA independently inspected narrow scope. Post-await race,
real-user UI/RLS and 22-lead triage remain unverified. Additional changed file: `A2_PROBES.md`.
Current continuation checks: analyzer `No issues found! (ran in 5.3s)`; formatting `125 files (0
changed)`; Flutter `+126: All tests passed!`; Node register `MD=17 JSON=17 mismatches=0`; each exit 0.
The first temporary copy of the entire app could contain secret files; do not inspect or share it and
ask user before cleanup: `C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a2-probe-20261028`.
External backup of the original eight dirty artifacts was verified (bundle SHA, 549/549 archive count,
eight matching file hashes) at `C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a2-backup-20261028-171019`.
Next: reconcile 22 A2 leads, update both registers/coverage and obtain final QA; no A3.

- **Task/status:** A2 Flutter deep audit, PARTIAL. Complete-stage acceptance `NOT RUN`.
- **Commit:** `main` @ `7eb40f1d7e553e9f136abb13f632b8bfb189dc3c`; remote equal at recovery entry;
  tree clean then, eight authorized documentation files pending now. No A2 commit/push yet.
- **Agent:** server session `ses_e7e81bc84ffeWkbb0tV5jo0jwp` reports `gymlvl-orchestrator`.
- **Progress:** recovered three historical specialist reports; sequential QA, workout-presentation
  and context reviews now complete. No active child tasks. Phase artifact preserves all leads.
- **Findings:** 17; P0 0/P1 4/P2 6/P3 5/P4 2. New FND-SEC-002 is P1/High/Needs Verification.
  CONC-001/DATA-001 addenda preserve confidence/history. Controller does reset memory/timers on auth
  identity change; unchecked backup owner is a separate issue. No server-side XP duplication confirmed.
- **Changed files:** `docs/audit/{MASTER_FINDINGS.md,FINDINGS_REGISTER.json,AUDIT_COVERAGE.md,
  SESSION_HANDOFF.md,phases/A2_FLUTTER.md}` and
  `docs/planning/{TASK_BOARD.md,SESSION_HANDOFF.md,CHANGELOG_AI.md}`.
- **Verification (7eb40f1):** `flutter analyze --no-pub` -> `No issues found! (ran in 4.2s)`;
  `dart format --output=none --set-exit-if-changed lib test` -> `Formatted 125 files (0 changed)`;
  `flutter test --no-pub --reporter expanded` -> `+126: All tests passed!`; each exit 0 (`PASS`).
- **NOT RUN:** retained focused controller/account-switch probes, rendered contrast/keyboard checks,
  complete candidate reconciliation and final A2 QA. Historical temporary test was deleted; do not
  turn its carried output into current PASS.
- **Artifact verification:** orchestrator Node check -> MD 17 / JSON 17, 22 required fields,
  classifications/counts synchronized; `git diff --check` -> no whitespace errors, status only eight
  authorized docs (`PASS`). Independent artifact QA Node check `BLOCKED` by shell permission denial;
  no permissions changed. It independently verified Git scope/HEAD/whitespace.
- **Decisions:** none. Current user allows A2 normal commit/push after complete, superseding the old
  audit prompt's prohibition; no rewrite. Lower A1 baseline/"run A1" entries are historical/stale,
  not executable next actions.
- **Blockers:** no external prerequisite missing; unfinished verification/triage prevents closure.
- **Next action:** A2 retained audit-only real-controller probe for discard enqueue cycle and
  cross-owner snapshot adoption (completing-cancel and same-owner controls), then reconcile phase
  section 5 leads. Do not begin A3 or remediation; final A3 execution prompt is not drafted yet.

## Historical A1 handoff (preserved; not current A2 status)

**Updated:** 2026-10-28 (A1 audit complete — 16 findings)
**Last agent:** **`gymlvl-orchestrator`** — proven from the server, not from configuration: session
`ses_e7e81bc84ffeWkbb0tV5jo0jwp` reports `"agent":"gymlvl-orchestrator"` via
`opencode-cli.exe api get /api/session/<id>`.
**Mode:** Read-only audit of architecture, dependencies, configuration, infrastructure and CI, plus the
A1 checkpoint commit and a normal push to `origin/main`. No application, SQL, UI, schema, CI, or
dependency change.
**Baseline:** branch `main` @ `c9cc764` = `origin/main` after the A1 checkpoint push. A1 was measured
at `e8c7c8e`, the parent of that commit. Confirm with `git rev-parse main` and
`git ls-remote origin refs/heads/main` before trusting this line.
**Next task:** **A2 — Flutter app, state, lifecycle, concurrency, navigation** (`READY`, audit track;
prompt in `docs/audit/SESSION_HANDOFF.md` §6). **M1-01** (product) and **S4** (skills) remain
unauthorized.

---

## 0. Current state — A1 complete (newest)

| Item | Value |
|---|---|
| Agent access policy | `PASS` — **D-024**. Orchestrator + 5 development specialists have full repository access; irreversible or sensitive operations resolve to `ask`; `qa-reviewer` and `context-keeper` remain read-only |
| Active agent (this session) | **`gymlvl-orchestrator`**, proven from the server, not from configuration |
| Orchestrator write | `PASS` end-to-end — A1 wrote every `docs/audit/**` artifact while running as the orchestrator |
| A1 audit | **`PASS`** — `docs/audit/phases/A1_ARCHITECTURE.md` |
| Findings | **16 total** — 0 `P0`, 3 `P1`, 6 `P2`, 5 `P3`, 2 `P4`; 2 `Needs Verification`, 12 `Accepted`, 1 `Fixed`, 1 `False Positive`. Ten added by A1 |
| Coverage | C-22, C-25, C-26 `Reviewed (static)`; 3 of 27 reviewed, 1 `In Review`, 22 `Not Reviewed` |
| Git | `c9cc764` on `main`; `origin/main` moved `e8c7c8e` → `c9cc764`. A1 measurements were taken at `e8c7c8e` |
| Push | `PASS` — `git push origin main` → `e8c7c8e..c9cc764  main -> main`, exit 0; `git ls-remote origin refs/heads/main` equals local HEAD. One approved `--amend` removed a UTF-8 BOM from the unpushed subject line |
| Backup | `…\Temp\opencode\gymlvl-s2-backup-20261028\` — bundle verified at S3 |

**Read first on resume:** `AGENTS.md` §0.1, this section, `docs/agent-system/ACCESS_POLICY.md`, then
`docs/audit/SESSION_HANDOFF.md`, then `TASK_BOARD.md`.

### Verification at A1 close (2026-10-28, `main` @ `e8c7c8e`)

| Check | Command | Result | Status |
|---|---|---|---|
| Branch / HEAD | `git rev-parse --abbrev-ref HEAD` / `git rev-parse HEAD` | `main` / `e8c7c8e7e346790ac1807dc5c8d4e43c2ee880ef` | `PASS` |
| Remote equality | `git ls-remote origin refs/heads/main` | `e8c7c8e7e346790ac1807dc5c8d4e43c2ee880ef` — equal to local | `PASS` |
| Tree | `git status --porcelain=v1` | `CLEAN (0 entries)` at A1 entry | `PASS` |
| Active agent | `opencode-cli.exe api get /api/session/ses_e7e81bc84ffeWkbb0tV5jo0jwp` | `"agent":"gymlvl-orchestrator"` | `PASS` |
| Toolchain | `flutter --version` | `Flutter 3.38.5 • channel stable`, `Tools • Dart 3.10.4` | `PASS` |
| Static analysis | `cd app; flutter analyze` | `No issues found! (ran in 2.5s)`, exit 0 | `PASS` |
| Formatting | `cd app; dart format --output=none --set-exit-if-changed lib test` | `Formatted 125 files (0 changed) in 0.71 seconds.`, exit 0 | `PASS` |
| Rule model, documented probes | `node gymlvl-perm-check.mjs` | `RULES VALIDATED: 73 global + 62 agent` / `RESULT: PASS (0 probe failures, 0 schema problems)` | `PASS` |
| Rule model, 18 destructive-operation probes | `node a1-git-gate-probe.mjs` | `RESULT: FAIL (12 probe failures, 0 schema problems)` — `FND-GOV-004`, `FND-SEC-001` | `FAIL` — the failures are the finding |
| Register sync | `node a1-sync-check.mjs` | `md findings: 16 json findings: 16`, `mismatches: 0` | `PASS` |
| Migrations census | `node a1-lines2.mjs` + policy/trigger/function census | 661/349/367 lines (1,377 total, 1,219 non-blank); 17 tables; 44 policy statements → 22 effective; 11 `SECURITY DEFINER`; 10 triggers | `PASS` |
| Product regression (`flutter test`, SQL, Edge) | not rerun — A1 changed no product, SQL, or test file | — | `NOT RUN` |
| Android/iOS build | not attempted; would write artifacts and needs an SDK host | — | `NOT RUN` |
| Live permission probe | not attempted; would require issuing a destructive or secret-reading command | — | `NOT RUN` |

Detail and quoted output: `docs/audit/phases/A1_ARCHITECTURE.md` §12.

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

- **A2 is not started.** `docs/audit/SESSION_HANDOFF.md` §6 holds the authoritative A2 prompt and its
  seven acceptance criteria. A1 is complete: `docs/audit/phases/A1_ARCHITECTURE.md`.
- `FND-GOV-002`: the stale-claim inventory is **complete** (A1, `phases/A1_ARCHITECTURE.md` §10 — 15
  claims across nine documents). `PROJECT_CONTEXT.md` §2 is now 7 commits behind with a 37-short file
  count, and the `DECISIONS.md` summary table still stops at **D-014** while D-015…D-024 have sections.
  The W4 fix is a single pass.
- Three release-blocking or template defects in the Android/iOS configuration were registered by A1
  (`FND-BUG-001` P1, `FND-BUG-002` P2, `FND-BUG-003` P4). `TASK_BOARD` §M1-02 already planned the fixes;
  the register now has IDs to close.
- `FND-GOV-004` and `FND-SEC-001` (P2 each) record that the permission layer gates 6 of 18 probed
  destructive/secret operations. They are `High`, not `Confirmed`, because a live probe would require
  issuing the destructive command. Closing them is a configuration change needing approval.
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
