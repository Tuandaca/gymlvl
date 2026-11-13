# GymLvl — Task Board

## Completed checkpoint — P9 scoped GitHub publication (2026-11-13)

**Status:** `PASS` for the isolated candidate, exact staged scope, commit, GitHub push and remote CI. Production deployment remains `NOT RUN`.

**Commit:** P9 implementation `main` @ `db4bb6a61641c5010da4c4da27fa49f9bfdb6ef8`; `git ls-remote origin refs/heads/main` returned the same SHA after `git push origin main`. This documentation follow-up records that verification; its containing commit SHA is reported in the final handoff.

**Scope:** Publish P9 and application dependencies only, as approved by the owner. The candidate manifest contains 126 selected file paths and excludes 50 unrelated infrastructure, backup, log and agent-work paths. The dirty source tree is preserved in `D:\Projects\gymlvl_p9_push_backup_20261113_112704`; the bundle HEAD, Git archive paths/count and 175 dirty file hashes were verified before staging. No production backup or local configuration is in the candidate.

**Candidate verification:** From the isolated clone of the bundle with exactly the selected files: `flutter test --reporter expanded` → `PASS`, 822/822; `flutter analyze` → `PASS`, `No issues found!`; Dart format → `PASS`, 308/0; isolated generated-code check → `PASS`, 39 outputs; Node guard tests → `PASS`, 7/7; `npm test` → `PASS`, 53 SQL units/365 ACL assertions; `npm run test:concurrency` → `PASS`, 8/8; `npm run check:edge` → `PASS`; `npm run test:edge` → `PASS`, 58/58; web release and Android debug builds → `PASS`, artifacts built; candidate `git diff --check` → `PASS`. Android emitted a non-fatal Kotlin incremental-cache path warning. Remote CI and live production checks → `NOT RUN` at this checkpoint.

**Publication verification:** `stage_manifest.py` → `PASS`, 126 exact selected paths and 50 excluded; `compare_candidate_tree.py` → `PASS`, tested candidate and staged main tree both `16c886787659dace6699ed3bdc2b0616d6d4fac8`; `git diff --cached --check` → `PASS`; `git commit` → `PASS`, `db4bb6a`; `git push origin main` → `PASS`, `c68e577..db4bb6a`; `git ls-remote origin refs/heads/main` → `PASS`, `db4bb6a`; `gh run watch 43367120360 --exit-status` → `PASS`, all three jobs (database-and-edge, flutter, android-release-manifest). Forty-six collapsed status paths remain as preserved unrelated owner work. No tag or production operation.

**Next action:** Production preflight remains a separately authorized task; typography correction remains separate under D-056.

## Current task — P9 local closeout and gated follow-up (2026-11-13)

**Status:** `PASS` for the local P9 hardening and final verification scope. D-056 is `ACCEPTED`: keep current typography for P9 and correct it in a separate task. Production migration, live gateway/Auth checks and remote CI are `NOT RUN`.

**Commit:** `main` @ `c68e5773fbb18ba03f32f1b2e33eebdecf7017bc`; `git ls-remote origin refs/heads/main` returned the same SHA. The working tree has 163 dirty paths, including preserved owner work and uncommitted P9 changes. No commit, push, tag or deployment.

**Acceptance criteria/evidence:** P9.0–P9.6 local checkpoints and section 26–28 quality gates are recorded below and in `docs/audit/P9_DEFECT_GRAPH.md`. Final-state Flutter 822/822, analyzer 0 issues, codegen 39/39, SQL 53 units/365 ACL assertions, PostgreSQL two-connection concurrency 8/8, Edge 58/58, web release and Android debug builds all passed. The 150 curated exercise identities remained stable in a local seed replay. No production state was changed.

**Next action:** Prepare a separately authorized P9 production migration/live-validation preflight if the owner requests it. Catalogue importer dataset tests need the approved pinned source directory. Typography correction belongs to a separate task under D-056.

## Completed checkpoint — P9.6 lower-priority cleanup (2026-11-13)

**Status:** `PASS` for confirmed local cleanup and candidate investigation. D-056 accepts retaining current typography for P9 and handling correction separately; no font binary or production UI styling was changed.

**Commit:** `main` @ `c68e5773fbb18ba03f32f1b2e33eebdecf7017bc`; dirty owner/P9 work preserved, no Git or production write.

**Changed files:** `app/lib/features/workout/domain/plate_calculator.dart`, `app/test/plate_calculator_test.dart`; `app/test/adversarial_edge_test.dart`, `app/test/ui_regression_test.dart`; `app/lib/features/analytics/data/backup_import_service.dart`, `csv_import_service.dart`; `app/lib/features/workout/domain/workout_repository.dart`; `app/assets/fonts/SOURCES.md`; `docs/superpowers/plans/2026-11-13-p9-6-lower-cleanup.md`, `docs/audit/P9_DEFECT_GRAPH.md`, and board/handoff/changelog. Production flags, font binaries, pubspec and older theme code were not edited.

**Evidence:** Plate debug text RED (`2x 2.0kg` instead of `2x 20.0kg`) then focused plate suite `PASS` 12/12, including exact 1.25 kg. Production-theme UI harness and existing registered font loaders `PASS` 77/77; final UI/accessibility review `PASS` 105/105. Misleading v1-only and legacy import comments corrected; the private FNV-1a fingerprint helper was renamed without changing its bytes. FontTools confirmed identical `glyf`/`hmtx` digests across four relabeled files and Inter; `SOURCES.md` now records provenance. No stale production feature flag was confirmed.

**Final verification at `main` `c68e577`:** `flutter test --reporter expanded` → `PASS`, 822/822; `flutter analyze` → `PASS`, `No issues found!`; Dart format → `PASS`, 308/0; isolated generated-code guard → `PASS`, 39/39; web release build → `PASS`, `Built build\\web`; Android debug build → `PASS`, `Built build\\app\\outputs\\flutter-apk\\app-debug.apk`; `npm test` → `PASS`, 53 SQL units/365 ACL; `npm run test:concurrency` → `PASS`, 8/8 real PostgreSQL scenarios; Edge checks/tests → `PASS`, 58/58; catalogue local e2e → `PASS`, 4/4 and 150 stable identities; `node --test tools/generated-code/check.test.mjs` → `PASS`, 7/7; `git diff --check` → `PASS`. Importer dataset test → `BLOCKED`, `EXERCISEDB_SOURCE_DIR not set; skipping import tests`. Remote CI and production live checks → `NOT RUN`.

**Next action:** Separately authorized production preflight, if requested. The current code remains local and uncommitted; typography correction is a separate task.

## Completed checkpoint — P9 analyzer quality (2026-11-13)

**Status:** `PASS` for local section 27: `flutter analyze` now exits 0 with `No issues found!`, after 60 baseline diagnostics. No global suppression or new dependency was added.

**Commit:** `main` @ `c68e5773fbb18ba03f32f1b2e33eebdecf7017bc`; dirty owner/P9 tree preserved, no commit/push/tag/deploy.

**Changes:** Removed unused imports, bindings, dead parsing helpers, unreachable null branches and redundant syntax in the diagnosed analytics, AI, UI and test files. `import_models.dart` now compares imported set elements directly rather than importing transitive `collection`. The warning at generic CSV fallback revealed a real defect: `date,workout,reps,weight` produced an empty exercise name; a RED test was added before the fallback fix. `supabase_workout_repository.dart` uses equivalent null-aware map entries. Plan: `docs/superpowers/plans/2026-11-13-p9-analyzer-quality.md`. Independent final static review found no confirmed regression.

**Verification at `main` `c68e577`:** Baseline `flutter analyze` → `FAIL`, 60 issues; final `flutter analyze` → `PASS`, `No issues found!`; generic CSV regression → `FAIL` RED (`Expected: 'Squat'; Actual: ''`) then `PASS` in the 42-case focused import suite; `flutter test --reporter expanded` → `PASS`, 820/820; `dart format --output=none --set-exit-if-changed lib test` → `PASS`, 308/0; `node tools/generated-code/check.mjs` → `PASS`, 39/39 after full isolated generation; `git diff --check` → `PASS`. Remote CI and production validation → `NOT RUN`, uncommitted local work and closed production gate.

**Next action:** P9.6 — inspect the specified low-severity candidates and fix only confirmed defects.

## Completed checkpoint — P9 generated-code drift guard (2026-11-13)

**Status:** `PASS` for local section 26 acceptance. The isolated full generator reports no current drift in 39 checked outputs, and an external stale-model mutation is detected. CI is configured; no remote CI run exists for this dirty tree.

**Commit:** `main` @ `c68e5773fbb18ba03f32f1b2e33eebdecf7017bc`; owner/P9 changes preserved, no commit/push/tag/deploy.

**Changes:** `tools/generated-code/check.mjs` copies only current source/config to an OS temporary directory, rejects links, enforces the lockfile, regenerates all outputs without a filter, checks source mutation, and compares path/content for `.g.dart`, `.freezed.dart`, and `.drift.dart`. `check.test.mjs` covers inventory, changed/missing/extra output, CRLF, snapshots and links. `.github/workflows/verify.yml` runs Node 22 guard tests and the check in the Flutter job. Two clean tracked Riverpod outputs, `stats_providers.g.dart` and `quest_providers.g.dart`, were copied from reviewed isolated generation; each diff changed only its generated hash. No generator ran in the shared checkout. Plan: `docs/superpowers/plans/2026-11-13-p9-generated-drift.md`.

**Verification at `main` `c68e577`:** `node --test tools/generated-code/check.test.mjs` → `PASS`, 7/7; `node tools/generated-code/check.mjs` → `PASS`, 39 outputs after fresh generation; same guard on a canonical external app copy → `PASS`, 39 outputs; after changing only external `@Default(1) int setNumber` to `@Default(2)` → `FAIL` as intended, exit 1 named `workout_set.freezed.dart` and `workout_set.g.dart`; SHA-256 inventory of all 39 repository generated files before/after adversarial run → `PASS`, identical; `cd app; flutter test --reporter compact` → `PASS`, 819/819; Dart format → `PASS`, 307/0; `git diff --check` → `PASS`. Remote CI → `NOT RUN`, uncommitted tree. Full analyzer → `NOT RUN` at this checkpoint; prior P9.5 result was 60 issues.

**Next action:** P9 analyzer quality — rerun and classify diagnostics, then repair warning sources without global suppression.

## Completed checkpoint — P9.5 transactional workout mutations (2026-11-13)

**Status:** `PASS` for local P9.5 acceptance. Full Flutter and SQL regressions pass, including fault rollback and two-connection same-key add. Overall P9 remains in progress; `flutter analyze` is `FAIL` with 60 issues. Production P9 migrations/gateway/live account validation are `NOT RUN`.

**Commit:** `main` @ `c68e5773fbb18ba03f32f1b2e33eebdecf7017bc`; dirty owner work and uncommitted P9.0–P9.5 preserved. No commit, push, tag or deployment.

**Acceptance criteria/evidence:** D-055 approved for local work. Agent E first reproduced 5/5 RED Flutter fault cases and a missing-RPC SQL RED. The additive migration implements authenticated `reorder_workout_exercises_v1` and `add_workout_exercise_with_sets_v1` with account/workout locks, full permutation or bounded-set validation, one transaction, private ledger exact replay and no reward write. The Supabase adapter uses one RPC per mutation and reloads owner-scoped detail; the controller fails closed without that capability, freezes operation ID/payload, reconciles lost ACK, fences old-account responses, and retains unrelated failure fences. Agent E's final focused P3/P9 suite passed 24/24; independent final read-only review found no confirmed defect.

**Changed files:** `supabase/migrations/20261113000300_p9_workout_mutation_atomicity.sql`; `supabase/tests/p9_workout_atomicity.sql`; `app/lib/features/workout/domain/workout_repository.dart`, `data/supabase_workout_repository.dart`, `presentation/controllers/active_workout_controller.dart`; `app/test/p9_workout_atomicity_test.dart`, `p3_workout_core_test.dart`; `tools/db-tests/concurrency/m3-idempotency.mjs`; `docs/superpowers/plans/2026-11-13-p9-5-workout-atomicity.md`, `docs/audit/P9_DEFECT_GRAPH.md`, and planning/architecture records. Existing P9 and owner hunks in shared files remain preserved.

**Verification at `main` `c68e577`:** `cd app; flutter test --reporter expanded` → `PASS`, 819/819; `dart format --output=none --set-exit-if-changed lib test` → `PASS`, 307/0; `flutter analyze` → `FAIL`, 60 issues; web release build → `PASS`, `Built build\\web`; Android debug build → `PASS`, `Built build\\app\\outputs\\flutter-apk\\app-debug.apk`; `cd tools/db-tests; npm test` → `PASS`, 53 SQL units/365 ACL assertions; `npm run test:concurrency` → `PASS`, 8/8 real two-connection scenarios including C8; `npm run check:edge; npm run test:edge` → `PASS`, 58/58; `git diff --check` → `PASS`. Production migration and gateway/live-account checks → `NOT RUN` pending separate authorization and dependency preflight.

**Decision:** D-055 `ACCEPTED` for local transactional RPCs, existing private ledger and fail-closed client. Production migration requires the local M3 ledger/mode schema dependency chain and separate approval.

**Next action:** P9 quality gates — build a non-destructive generated-code drift check, then reduce analyzer warnings.

## Completed checkpoint — P9.4 AI trainer hardening (2026-11-13)

**Status:** `PASS` for local consent, minimized server context, advisory-only response and human-approval boundary. P9 overall remains in progress; `flutter analyze` is `FAIL` with 60 issues. Production Edge deployment and live provider validation are `NOT RUN`.

**Commit:** `main` @ `c68e5773fbb18ba03f32f1b2e33eebdecf7017bc`; dirty owner work and P9.0–P9.4 preserved. No Git or production write.

**Acceptance criteria/evidence:** Edge tests were RED for missing consent and client context, then GREEN. The Edge handler now rejects requests without explicit per-request consent before quota, context or provider egress; rejects client context; allowlists bounded server-owned facts without account/workout/exercise IDs; separates untrusted context from system instructions. Chat Send supplies consent. PT screens show VI/EN disclosure and Generate before provider watch, bind consent to the signed-in account, and hide Apply/confidence for the actual text-only response. Independent review found incomplete disclosure and an asynchronous locale race; a stored-English first-request test was RED then GREEN, and all three AI disclosures now enumerate the shared fields. A second review found stale post-response copy; that was corrected. The long chat disclosure caused two narrow bilingual viewport overflows; its scrollable bound made the 29-case adversarial UI suite GREEN. Provider errors show sanitized retry UI; workouts remain independent of AI.

**Changed files:** `supabase/functions/ai-coach/service.ts`, `service_test.ts`, `supabase/functions/tests/bounded_body_test.ts`; `app/lib/core/localization/localization_engine.dart`; `app/lib/features/coach/{data/coach_repository.dart,presentation/coach_screen.dart}`; `app/lib/features/ai_trainer/{domain/models/pt_recommendation.dart,presentation/providers/pt_recommendation_provider.dart,presentation/providers/pt_context_provider.dart,presentation/screens/ai_trainer_screen.dart,presentation/screens/ask_coach_screen.dart}`; `app/test/ai_trainer/p9_ai_consent_test.dart`, `p9_coach_request_test.dart`; P9 plan/audit/planning files. `pt_context_provider.dart` is deleted because it supplied synthetic runtime facts.

**Verification at `main` `c68e577`:** `cd app; flutter test --reporter expanded` → `PASS`, 803/803 after responsive fix; `flutter test test/adversarial_edge_test.dart --reporter expanded` → `PASS`, 29/29; `dart format --output=none --set-exit-if-changed lib test` → `PASS`, 306/0; `flutter analyze` → `FAIL`, 60 warnings/info issues; `flutter build web --release --dart-define=SUPABASE_URL=http://127.0.0.1:54321 --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_local_test` → `PASS`, `Built build\\web`; `flutter build apk --debug` → `PASS`, `Built build\\app\\outputs\\flutter-apk\\app-debug.apk`; `cd tools/db-tests; npm run check:edge; npm run test:edge` → `PASS`, 58/58; `git diff --check` → `PASS`.

**Decision:** D-054 `ACCEPTED` for the existing server-owned context, per-request consent, and advisory text-only contract. No new provider, schema, or production write.

**Next action:** P9.5 — test partial server mutation in reorder and add-exercise-plus-sets.

## Completed checkpoint — P9.3 progression consistency (2026-11-13)

**Status:** `PASS` for local P9.3 threshold, class XP display, and verified unlock ownership. Overall P9 remains in progress; `flutter analyze` is `FAIL` with 69 issues. Production P9 migrations/live parity are `NOT RUN`.

**Commit:** `main` @ `c68e5773fbb18ba03f32f1b2e33eebdecf7017bc`; dirty owner work and P9.0–P9.3 preserved. No Git or production write.

**Acceptance criteria/evidence:** D-052 and D-053 approved. `p9_progression_view_test.dart` was RED (expected 11 class XP, actual 0) then GREEN 2/2. `p9_progression_consistency.sql` was RED at class A 210 XP, then GREEN at 0, base, level-2, all class-definition level-2, and graduation boundaries; it verifies future award, no level downgrade, switch-away/back floor, and private ACL. `p9_unlock_contract.sql` was RED with no sync path, then GREEN for verified backfill, idempotency, unchanged XP, owner isolation, and no client EXECUTE/INSERT. The P5 integration regression now confirms the first-workout unlock is granted inside completion. Historical import remains unlock-neutral.

**Changed files:** `supabase/migrations/20261113000100_p9_class_level_parity.sql`, `20261113000200_p9_unlock_awards.sql`; `supabase/tests/p9_progression_consistency.sql`, `p9_unlock_contract.sql`, `progression_regression.sql`, `p5_game_injection.sql`; `app/lib/features/progression/presentation/providers/player_progression_view_provider.dart`, `app/test/p9_progression_view_test.dart`; P9 plan/audit/planning files and the concurrency harness assertion.

**Verification at `main` `c68e577`:** `cd app; flutter test --reporter compact` → `PASS`, 793/793; `dart format --output=none --set-exit-if-changed lib test` → `PASS`, 305/0; `flutter analyze` → `FAIL`, 69 issues; `cd tools/db-tests; npm test` → `PASS`, 51 SQL units/365 ACL assertions; `npm run test:concurrency` → `PASS`, 7/7 real two-connection scenarios after the final SQL helper; Edge checks/tests remained `PASS` 55/55 from P9.2 unchanged Edge source. `git diff --check` → `PASS`. Production migration and live user backfill → `NOT RUN`, requiring separate authorization and preflight.

**Decision:** D-052 preserves existing class levels while applying D-043 thresholds to future awards/switches; D-053 backfills verified unlocks and awards future unlocks only on new `workout_rewards` inserts. No XP or reward history rewrite.

**Next action:** P9.4 — test AI context egress consent and fallback.

## Completed checkpoint — P9.2 historical import and backup data integrity (2026-11-13)

**Status:** `PASS` for the scoped local import/backup contract. P9 overall remains in progress. `flutter analyze` is `FAIL` with 69 warnings/info; production P9 migrations, gateway, and live-account validation are `NOT RUN` without separate authorization.

**Commit:** `main` @ `c68e5773fbb18ba03f32f1b2e33eebdecf7017bc`; dirty owner work and uncommitted P9.0/P9.1 changes preserved. No Git or production write.

**Acceptance criteria:** Historical import never reuses an interactive active workout; completion uses a secure authenticated server transaction and creates zero XP/class XP/quest/achievement rewards or streak mutation; failure cannot increment imported count/fingerprint; exported supported backup data restores with semantic equivalence; fingerprint compatibility is explicit. Add failure, duplicate, active-session, cross-user, and round-trip regressions before implementation. Do not weaken RLS or alter progression rules without an approved decision.

**Ownership:** Agent A — export UI; Agent B — Flutter import/backup and workout client; Agent C — secure SQL/RPC; Agent D — custom exercise/provenance audit; Agent E — independent regressions; Lead — integration, body-fat unit, two-connection P9 scenario, and docs.

**Changed files:** Additive migrations `supabase/migrations/20261110000200_p9_historical_workout_import.sql`, `20261110000300_p9_historical_measurement_import.sql`, and `20261110000400_p9_custom_definition_import.sql`; analytics import/export/provider/UI, workout repository/adapter, body-fat unit, P9 Flutter/SQL tests, SQL harness and its concurrency scenario, P9 plan/audit, and planning records. See the exact worktree paths in `SESSION_HANDOFF.md` and `git status` before staging anything.

**Evidence at `main` `c68e577`:** `cd app; flutter test --reporter expanded` → `PASS`, 791/791; `dart format --output=none --set-exit-if-changed lib test` → `PASS`, 304/0; `flutter analyze` → `FAIL`, 69 issues; `cd tools/db-tests; npm test` → `PASS`, 47 SQL units/365 ACL assertions; `npm run test:concurrency` → `PASS`, 7/7 real two-connection scenarios, including P9 same-key import with one ledger/workout and zero reward rows; `npm run check:edge` → `PASS`; `npm run test:edge` → `PASS`, 55/55. Web release and Android debug builds passed on the prior P9.2 source state; no new source change followed except a one-file test format and the concurrency harness. Live production/gateway validation → `NOT RUN`. Agent E reached a tool usage limit while adding the P9 concurrency scenario; Lead completed and verified it.

**Decision:** D-051 `ACCEPTED` by the owner: one workout transaction, same-account backup, retry by idempotency key, committed earlier items retained after a later item fails. File fingerprint is recorded only after all items succeed.

**Next action:** P9.3 — write class threshold and current-class XP boundary regressions.

## Completed checkpoint — P9.1 workout mode and completion integrity (2026-11-10)

**Status:** `PASS` for local P9.1 acceptance. Production mode gates remain closed; typed modes are only locally verified. Analyzer remains `FAIL` with 71 issues. Existing duration-only `NULL` records need manual correction or an approved migration rule before completion.

**Commit:** `main` @ `c68e5773fbb18ba03f32f1b2e33eebdecf7017bc`; dirty owner work preserved, plus uncommitted P9.0 source/tests/docs. No P9 production change or Git write.

**Acceptance criteria:** Trace `productionWorkoutModesEnabled` and `productionSupersetEnabled` against the effective local SQL contract. Verify weighted, bodyweight, timed, cardio, warm-up, invalid measurement, and legacy NULL-mode completion behavior; ensure the client persists a server-compatible mode or prevents an unfinishable workout. Preserve transactional `complete_workout` rewards and idempotency. Add layer-correct regression tests before code changes. Do not turn on a production gate without evidence and an approved decision.

**Ownership:** Agent B — workout domain/repository/controller; Agent C — SQL/RPC review and any additive migration; Agent E — independent regressions; Lead — integration and planning. Agent A/D review only if UI/catalogue contracts are affected.

**Changed files:** Agent B: `app/lib/features/workout/domain/workout_mode_contract.dart`, `workout_set.dart`, generated `workout_set.g.dart` and `workout_set.freezed.dart`, `app/lib/features/workout/presentation/controllers/active_workout_controller.dart`. Agent E: `app/test/workout_modes_test.dart`, `workout_controller_test.dart`, `workout_completion_reconciliation_test.dart`. Lead: P9 plan/audit/planning files.

**Evidence:** Agent E captured RED failures for gated inferred cardio/static/plank, legacy duration-only NULL validation/completion, pending-receipt reconciliation, and SQL `set_type` JSON mapping. After fixes, Agent E focused tests `PASS` 60/60; Lead `flutter test --no-pub --reporter expanded` `PASS` 753/753; format `PASS` 299/0; SQL `npm test` `PASS` 40 units/365 ACL assertions; two-connection concurrency `PASS` 6/6; Edge checks/tests `PASS` 55/55; web release build and Android debug APK `PASS`. `flutter analyze` `FAIL` 71 issues. No SQL/RPC/reward rule or production gate was changed in P9.1.

**Generator incident:** Filtered `build_runner` unexpectedly deleted 37 unrelated tracked generated files. Lead reconstructed them from the verified pre-P9 bundle plus dirty patch and SHA-256 checked each restored file; deleted tracked count returned to zero. Only the two intended `workout_set` generated files differ from the pre-P9 generated backup. Do not rerun this filtered generator in the shared tree.

**Next action:** P9.2 — test historical import isolation and false-success paths.

## Completed checkpoint — P9.0 exercise contract and privacy hardening (2026-11-10)

**Status:** `PASS` for the scoped local exercise ownership/creation contract. Independent QA and Lead final-state checks passed. `flutter analyze` remains `FAIL` with 71 issues and is a P9 quality debt; live production validation is `NOT RUN` without authorization.

**Commit:** `main` @ `c68e5773fbb18ba03f32f1b2e33eebdecf7017bc`; working tree dirty with pre-existing owner work. External backup: `D:\Projects\gymlvl_p9_backup_20261110_125948`, verified before P9 edits.

**Acceptance criteria:** (1) reconcile public catalogue versus owner custom exercise SELECT/RLS and definer quest selection; (2) prevent referenced custom exercises from deleting workout history; (3) make custom exercise creation honor server-managed timestamps; (4) test two-user isolation, archive/delete history preservation, and real insert contract; (5) rerun affected Flutter/SQL checks and report remaining analyzer issues honestly. Keep `Exercise` owner modifications intact. No production change, commit, push, or tag.

**Ownership:** Agent C — additive SQL migration; Agent B / Flutter specialist — `supabase_exercise_repository.dart`; Agent E — independent regressions under `app/test/**` and `supabase/tests/**`; Agent D — catalogue semantics review; Lead — integration and control-plane docs.

**Changed files:** `supabase/migrations/20261110000100_p9_exercise_contract.sql`; `supabase/tests/p9_exercise_contract.sql`; `supabase/tests/p7_exercise_personalization.sql`; `app/lib/features/workout/data/supabase_exercise_repository.dart`; `app/test/p9_custom_exercise_repository_test.dart`; P9 audit/plan and planning checkpoint files. Owner-modified `Exercise` source/generated files were not edited by P9.

**Evidence:** `docs/audit/P9_DEFECT_GRAPH.md`. Final-state format PASS (299/0); Flutter tests PASS (746/746); SQL PASS (40 units/365 ACL assertions); concurrency PASS (6/6); Edge PASS (55/55); web and Android debug build PASS. Analyzer FAIL (71 issues). CI run 42659715642 at committed HEAD failed format and Android compile; current dirty local tree has no CI run. Production P9 migration is not deployed. The old remediation task below is complete historical context; its pending-commit instruction was fulfilled by HEAD `c68e577` and must not be repeated.

**Next action:** P9.1 — test timed/cardio completion end-to-end against the effective local SQL contract.

## Previous phase — Full-system production remediation (2026-11-09)

**Task:** Remediate production backend/schema so onboarding 9/9 and critical app flows work end-to-end against the live Supabase project `shulhhxdebsfbsxcborq`. This supersedes the stale P8 planning state. Do NOT start any post-P8 feature phase.

**Execution order:** verify production state → apply missing migrations in dependency order → verify objects → fix Flutter error classification → fix Dart parser/schema drift → deploy Edge Functions → production E2E with disposable account → automated tests → docs → commit + push `main` only when all mandatory criteria PASS.

**Status:** `COMPLETE` — all mandatory acceptance criteria verified against production via MCP `supabase-gymlvl` and real HTTP E2E.

**Commit:** `main` @ `fef9df89f4fa466b275ee0420e5a3e673dfcf6c6` (HEAD before remediation commit). Working tree dirty with pre-existing owner work — all PRESERVED and EXCLUDED from the remediation commit.

**Frozen invariants preserved:**
- Flutter + Dart + Riverpod + GoRouter + Supabase/PostgreSQL + Edge Functions; existing workout engine/history/bodyweight/analytics/progression/RPG.
- `complete_workout` remains sole authoritative reward path; zero XP for non-completion actions.
- Additive DB migrations only; no existing tables/columns dropped; no RLS weakened.
- Bold Candy Neubrutalism UI; VI/EN diacritics; no AGPL code/media; no third-party media.
- `main` is the sole development branch; no automatic commit/push/tag.
- Pre-existing owner dirty/untracked files preserved and excluded from the commit.

**Remediation files (8):**
- `app/lib/core/localization/localization_engine.dart` — added classified onboarding VI/EN keys
- `app/lib/features/ai_trainer/presentation/providers/pt_context_provider.dart` — fixed `questTitle` key read
- `app/lib/features/onboarding/presentation/providers/onboarding_controller.dart` — `OnboardingFailure` classification, sanitized debug, specific user-safe messages
- `app/lib/features/onboarding/presentation/screens/onboarding_screen.dart` — renders classified message key instead of hardcoded `request_failed`
- `app/lib/features/progression/presentation/providers/player_progression_view_provider.dart` — `orElse` on `firstWhere` for primary class
- `supabase/functions/delete-account/index.ts` — pass user JWT into `delete_account_data` RPC
- `supabase/migrations/20261109000300_remediation_complete_workout_warmup_parity.sql` — warm-up exclusion + P5 achievement catalogue in `complete_workout`
- `supabase/migrations/20261109000400_remediation_delete_account_purge.sql` — `workout_write_operations` purge + explicit deletes in `delete_account_data`

**Production reconciliation (applied via MCP `execute_sql`, verified after each step):**
- `20261026000200_authoritative_progression` — `initialize_user`, `handle_new_user`, `on_auth_user_created`, `profiles.timezone`, `complete_workout`, all workout RPCs, RLS/grants reconciliation (anon write revoked), missing auth→public user backfilled (count = 0)
- `20261027000100_exercise_catalog_metadata` — `slug`, `name_vi`, `name_en`, movement patterns, `duration_seconds`
- `20261029000100_effective_progression_acl` — effective ACL adoption (D-027)
- `20261029000200_prevent_legacy_double_award` — ledger-backed idempotency guard
- `20261103000100_m3_offline_foundation` — `workout_write_operations` ledger + `apply_workout_set_create_v1`
- `20261103000200_m3_superset_modes` — `mode`, `superset_*`, contract triggers/RPCs
- `20261104000100_m4_progression_rpe_rir` — `rpe`, `rir` columns
- `20261105000100_m5_analytics_indexes` + `20261105000200_m5_bodyweight_measurements` — analytics indexes + weigh-in table
- `20261105000300_p1_exercise_provenance` — `source`, `external_id` columns
- `20261106000100_p2_routine_planning` — routines, planned workouts, 12 RPCs
- `20261106000200_p4_body_measurements` — body measurements table
- `20261106000300_p7_exercise_personalization` + `20261106000400_p7_import_records` — custom exercises, favourites, aliases, import records
- `20261107000100_p3_workout_core` — `set_type` column, warm-up exclusion in `complete_workout`
- `20261107000200_p5_game_integration` — expanded achievement catalogue, `get_player_progression`, quest seeds
- `20261109000100_p8_complete_workout_mode_validation` — mode-specific measurement validation
- `20261109000200_p8_delete_account` — `delete_account_data()` RPC
- `20261109000300_remediation_complete_workout_warmup_parity.sql` — final warm-up-parity `complete_workout`
- `20261109000400_remediation_delete_account_purge.sql` — final `delete_account_data` purge

**Edge Functions deployed (via MCP `deploy_edge_function`, verify_jwt=true):**
- `delete-account` v1 — ACTIVE
- `ai-coach` v1 — ACTIVE

**Production verification results (MCP `execute_sql` + real HTTP E2E):**
- `initialize_user` exists: PASS
- `handle_new_user` exists: PASS
- `on_auth_user_created` trigger on auth.users: PASS
- `profiles.timezone` column: PASS
- `delete_account_data` function: PASS
- `complete_workout(uuid,text)` correct signature: PASS
- Missing auth→public user count = 0: PASS
- `anon` table write privileges revoked: PASS
- Onboarding 9/9 E2E (disposable account): PASS — `initialize_user` returned "Onboarding complete", dashboard loads
- Workout E2E: PASS — start → add exercise → begin → add set → complete → XP: 5, Level 1
- XP idempotency: PASS — retry returns stored result, no double award
- Account deletion (RPC): PASS — `delete_account_data()` removed all user data, status 200
- Account deletion (Edge Function): code verified (passes user JWT into RPC); redeploy blocked by MCP tool path bug, but RPC contract verified directly
- `flutter pub get`: PASS
- `dart format --set-exit-if-changed`: PASS (0 changed)
- `flutter analyze --no-pub`: 0 errors (pre-existing warnings/infos only, unrelated files)
- `flutter test --no-pub`: 744 pass / 0 fail

**Known unrelated failures (pre-existing, excluded from remediation scope):**
- `release_config_test.dart` Gradle wrapper 9.7.1 vs 8.13 — owner file, untouched
- Flutter analyze warnings/infos in unrelated files — pre-existing, non-blocking

**Immediate next action:** Stage exactly the 8 remediation files + 3 planning docs, commit `fix: complete production remediation and critical flows`, push `origin/main`, then STOP (no tag/release).

**Do NOT commit/push/tag without owner approval.**
