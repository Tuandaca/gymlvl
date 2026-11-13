# P9 Defect Graph — 2026-11-10 checkpoint

**Scope:** Read-only repository-native audit and local baseline at `main` `c68e5773fbb18ba03f32f1b2e33eebdecf7017bc`. The working tree already contained owner modifications; no application or SQL source was changed for this checkpoint. The external backup is `D:\Projects\gymlvl_p9_backup_20261110_125948` (bundle clone HEAD matched; Git archive 803/803 files; untracked archive 46/46 files).

## Planning conflict

`TASK_BOARD.md` and `SESSION_HANDOFF.md` described completed P8 remediation and a pending commit/push. `MASTER_PLAN.md` still described P5 as in progress. The current HEAD includes P8 remediation, and the owner explicitly authorized P9 hardening. D-050 records this scope resolution; no historical document is rewritten.

## Current-session baseline

| Check | Result |
|---|---|
| `cd app; flutter pub get` | PASS — `Got dependencies!` |
| `cd app; dart format --output=none --set-exit-if-changed lib test` | PASS — `Formatted 298 files (0 changed)` |
| `cd app; flutter analyze` | FAIL — `71 issues found` (warnings and infos; no analyzer errors printed) |
| `cd app; flutter test --reporter expanded` | PASS — `+744: All tests passed!` |
| `cd app; flutter build web --release --dart-define=SUPABASE_URL=http://127.0.0.1:54321 --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_local_test` | PASS — `Built build\\web` |
| `cd app; flutter build apk --debug` | PASS — `Built build\\app\\outputs\\flutter-apk\\app-debug.apk` (Kotlin cache warnings observed) |
| `cd tools/db-tests; npm ci; npm test` | PASS — `38 SQL verification units`, `365 assertions`; isolated, single-connection harness |
| `cd tools/db-tests; npm run check:edge; npm run test:edge` | PASS — Edge checks; `55 passed, 0 failed` |
| `node tools/android-verify/manifest-check.test.mjs; node tools/android-verify/invoke.test.mjs; node tools/android-verify/run.mjs` | PASS — 18 unit cases; merged release manifest has `internet=1`, `duplicates=0` |

GitHub Actions run [42659715642](https://github.com/Tuandaca/gymlvl/actions/runs/42659715642) for committed HEAD failed: format found 16 files; Android compile reported missing `Exercise.userId`. The current dirty owner changes contain the model field and formatting, explaining why the local working tree passes those checks. No new CI run exists for the dirty tree.

## Canonical dependency graph

1. **Exercise privacy and identity:** earlier `catalogue_read USING(true)` policy → P7 custom rows → cross-user SELECT exposure; `sync_daily_data()` definer query → independent quest disclosure. The current Dart `Exercise.userId/isArchived` changes are owner work. New custom insert serializes null server timestamps, so creation fails. Hard DELETE plus `ON DELETE CASCADE` can erase workout history. Owners: C (SQL), B (repository), D (catalogue contract), E (regressions).
2. **Workout mode and completion:** inferred timed/cardio → omitted persisted `mode` → server rejects zero-rep completed set; `set_type` JSON mapping defaults warm-ups to working sets; replace and reorder client writes disagree with server guard/atomicity. Owners: B, C, E.
3. **Historical import:** `start_workout` reuses active session → client writes children → direct completion denied by ACL → swallowed failure and false count/fingerprint. Backup omits custom definitions and cannot round-trip them into another account. Owners: C (secure transaction), B (workout contract), D (exercise references), E (fault and ACL tests), Lead (integration).
4. **Progression:** SQL class threshold differs from Dart `RPGBridge`; dashboard subtracts global XP from class threshold; unlocks are read but not awarded. Owners: C, A after semantics, E.
5. **AI and quality gates:** Edge context egress has no recorded consent check; CI omits two-connection concurrency and generated-code drift gates; Flutter analyzer has 71 issues. Owners: C/AI, E, B/Flutter specialist.

## Consolidated findings from static inspection

| ID | Severity | Root cause / evidence | Status |
|---|---|---|---|
| P9-01 | P1 | `authoritative_progression.sql:90-92` leaves permissive `catalogue_read` after P7 adds owner-scoped policy at `p7_exercise_personalization.sql:28-33`; policies OR together. | Confirmed by static inspection; two-user effective RLS test needed. |
| P9-02 | P1 | `sync_daily_data()` definer query at `authoritative_progression.sql:205-210` does not scope private/archived exercises. | Confirmed by static inspection; two-user RPC test needed. |
| P9-03 | P1 | `csv_import_service.dart:306-345` and `backup_import_service.dart:753-879` reuse `start_workout`, swallow denied completion, and can report false success. | Confirmed cross-layer contract mismatch; runtime import test needed. |
| P9-04 | P1 | P7 authenticated custom DELETE plus `workout_exercises.exercise_id ON DELETE CASCADE` permits historical data loss. | Confirmed schema path; regression needed. |
| P9-05 | P1 | `supabase_exercise_repository.dart:73-88` inserts null `created_at`/`updated_at` into NOT NULL columns. | Confirmed serialization/schema mismatch; repository integration test needed. |
| P9-06 | P1 | `workout_set.dart:62-64` lacks `set_type` JSON mapping; server warm-ups deserialize as workout sets. | Confirmed generated parser behavior; round-trip test needed. |
| P9-07 | P1 | `active_workout_controller.dart:505-565` infers timed/cardio while `supabase_workout_repository.dart:203-218` omits `mode`; completion SQL rejects null-mode zero reps. | Confirmed cross-layer mismatch; completion integration test needed. |
| P9-08 | P1 | Exercise replacement updates immutable `exercise_id` against `guard_workout_child`. | Confirmed cross-layer mismatch; transactional replacement contract needed. |
| P9-09 | P2 | SQL class-level threshold and Dart `RPGBridge` differ; view subtracts global XP from class threshold. | Semantics decision and golden boundary tests needed. |
| P9-10 | P2 | CI omitted real concurrency and generated-code drift checks; committed HEAD previously failed format/Android. | Generated-code subfinding locally closed 2026-11-13: isolated full generation gate, 39/39 baseline, external stale-model rejection, Node 7/7. Remote CI remains `NOT RUN`; real concurrency CI gate remains open. |
| P9-11 | P2 | AI Edge egress has no recorded consent gate; dashboard localization, refresh, progress and contrast defects remain. | Static inspection; scope and regression needed. |

**2026-11-13 analyzer-quality checkpoint:** The 60-issue `flutter analyze`
baseline was cleared with source-level fixes, no global suppression and no new
dependency. Final analyzer exited 0 with `No issues found!`; Flutter 820/820,
format 308/0 and isolated generated output 39/39 passed. A RED test confirmed
the generic CSV `workout` column yielded an empty exercise name; the fixed
parser passed the focused 42-case import suite. Remote CI remains `NOT RUN` on
the uncommitted tree.

## P9.0 completed local checkpoint

Agent E wrote RED tests before source changes. SQL RED reported foreign custom SELECT, private/archived quest selection, and referenced custom DELETE failures. A second RED caught cross-owner workout-exercise UUID attachment, which could prevent the victim's account purge. Flutter RED caught both INSERT and UPDATE sending explicit timestamp keys. See the new P9 SQL/Flutter tests for the exact assertions.

Agent C added `20261110000100_p9_exercise_contract.sql`: owner/source-scoped SELECT policy, no authenticated hard DELETE, scoped quest selection, workout-child ownership validation, and a fail-closed preflight for pre-existing cross-owner references. Agent B changed only `supabase_exercise_repository.dart` to omit `created_at` and `updated_at` from custom INSERT/UPDATE payloads. Agent D reviewed catalogue/UUID semantics. Agent E independently tested forged owner/source, anonymous access, archive/history, account purge, and HTTP payloads. No owner-modified `Exercise` source/generated file was edited by P9.

**Lead final-state verification at `main` `c68e577`:** `dart format --output=none --set-exit-if-changed lib test` PASS (299 files, 0 changed); `flutter test --reporter expanded` PASS (746/746); `npm test` PASS (40 SQL units, 365 ACL assertions); `npm run test:concurrency` PASS (6/6 real two-connection scenarios); `npm run check:edge` PASS; `npm run test:edge` PASS (55/55); web release build PASS; Android debug APK PASS. `flutter analyze` FAIL (71 warnings/info issues, no new errors printed). Production P9 migration and gateway validation are NOT RUN, pending separate authorization and preflight of existing cross-owner references.

**Next scoped task:** P9.1 workout mode and completion integrity. Preserve the P9.0 results as the local checkpoint; any later source change requires rerunning affected checks.

## P9.1 completed local checkpoint

Agent E demonstrated RED failures for inferred cardio/static/plank insertions while the mode gate is closed, duration-only legacy `NULL` validation and completion, stale local data blocking a pending receipt, and `set_type='warmup'` decoding as a working set. Agent B changed the workout controller and mode validator to prevent fresh invalid inserts and reward requests while preserving receipt reconciliation. `WorkoutSet` now maps the SQL `set_type` key; generated parts came from build_runner. Gates remain closed. Agent C confirmed the effective local SQL keeps legacy `NULL` reps based, accepts typed timed/cardio measurements, excludes warm-ups from rewards, and awards exactly once.

**Independent QA:** Agent E's focused Flutter suite `PASS` 60/60. Lead final-state commands at `main` `c68e577`: `flutter test --no-pub --reporter expanded` `PASS` 753/753; Dart format `PASS` 299/0; SQL `npm test` `PASS` 40 units/365 ACL assertions; two-connection concurrency `PASS` 6/6; Edge checks/tests `PASS` 55/55; web release build and Android debug APK `PASS`; `flutter analyze` `FAIL` 71 issues. Production validation remains `NOT RUN`. Persisted legacy duration-only `NULL` sets remain unable to complete without user correction or an approved migration/reward decision.

**Generator incident:** Filtered build_runner deleted 37 unrelated tracked generated files despite an exact target filter. Lead restored all 37 from the verified pre-P9 bundle plus working-tree patch and checked SHA-256 against each restored source; deleted tracked count is zero. A complete generated-file hash comparison against that reconstructed baseline differs only in the intended `workout_set` parts. Do not use this filtered generator in the shared tree until its cleanup behavior is understood.

**Next scoped task:** P9.2 historical import and backup integrity. Start with active-workout isolation and false-success RED tests; any import completion or reward change needs an authenticated server contract and explicit decision.

## P9.2 and P9.3 local checkpoints (2026-11-13)

P9.2 replaced the active-workout-reusing import paths with owner-scoped,
per-item idempotent RPCs under D-051. Backup v2 restores supported text and
measurement data for the same account and records the file fingerprint only
after every item succeeds. Agent E's independent Flutter/SQL tests passed;
Lead added a genuine two-connection same-key import scenario (C7) with one
workout/ledger and no progression or unlock effect. P9-03 is locally resolved;
production parity remains unverified.

P9.3 confirmed P9-09 with RED SQL and Flutter tests. D-052 accepts the
D-043 cumulative threshold for future awards while preserving existing stored
levels through a private per-class floor. D-053 accepts verified unlock
backfill and completion-triggered future sync. Local SQL verifies all class
definitions at the level-2 boundary, class A graduation, no downgrade through
a switch, owner-only unlock reads, and no client award rights. Lead results:
Flutter 793/793; SQL 51 units/365 ACL assertions; two-connection 7/7;
analyzer FAIL 69 issues. P9-09 is locally resolved. No P9 migration has been
deployed to production, so live parity and real-data preflight remain open.

P9.4 locally resolves the AI egress and synthetic-context portion of P9-11.
D-054 keeps the existing Edge handler authoritative: explicit per-request
consent precedes quota/context/provider calls; client context is rejected;
server facts are bounded and stripped of internal IDs. PT screens require a
Generate action after VI/EN disclosure and treat the current text-only reply
as advisory, with no Apply or confidence. Independent review found and closed
an incomplete disclosure, first-request locale race, and stale post-response
copy; the expanded chat disclosure was made scrollable after two bilingual
small-viewport failures. Lead final-state Flutter 803/803,
Edge 58/58, format 306/0; analyzer FAIL 60 issues. Production Edge deploy and
live provider validation are NOT RUN. Remaining P9-11 dashboard/quality items
are not covered by this checkpoint.

P9.5 locally resolves the sequential workout reorder and add-with-default-sets
partial-write defects under D-055. RED Flutter fault injection reproduced a
diverged optimistic order and orphaned exercise/set graph; the SQL contract
test failed at the missing RPC. The additive RPC migration now uses one
authenticated transaction per operation and the private write ledger for exact
replay. Flutter fails closed without the atomic capability, freezes retry
payloads, reloads authoritative owner-scoped detail, and keeps unrelated
mutation failures fenced. Agent E's final focused P3/P9 suite passed 24/24;
Lead final-state Flutter 819/819, SQL 53 units/365 ACL, genuine concurrency
8/8 (including C8 same-key add), Edge 58/58, format 307/0, web/APK builds
PASS; analyzer FAIL 60 issues. Independent final static review found no
confirmed defect. Production migration/gateway/live-account validation is
NOT RUN; the M3 ledger and mode schema migration chain needs preflight and
separate authorization.

## P9.6 candidate dispositions (2026-11-13)

| Candidate | Finding | Disposition |
|---|---|---|
| `PlateBreakdown.toString()` | Current type is `PlateCalculationResult`. It printed plate count as denomination and rounded 1.25 kg to one decimal. | Confirmed low-severity diagnostic defect. RED test saw `2x 2.0kg` instead of `2x 20.0kg`; changed to exact denomination text; focused plate suite `PASS` 12/12. No production caller of the calculator was found. |
| Legacy theme/font test harness | Production uses Candy light theme, but two UI regression harnesses defaulted to legacy dark theme and loaded only Inter/Orbitron. | Harnesses now use production Candy light theme and load the currently registered Candy assets. Focused UI tests `PASS` 77/77, plus accessibility 10/10. No production UI or asset changed. |
| Bundled typography | Four files named Archivo/Space Grotesk/Space Mono have identical `glyf` and `hmtx` SHA-256 digests to bundled Inter. Both named mono files have unequal `i` and `W` widths (496 vs 2018). | D-056 `ACCEPTED`: keep current binaries and runtime mapping for P9 with provenance disclosed in `app/assets/fonts/SOURCES.md`; correct typography in a separate task. No asset or mapping changed. |
| Feature flags | The M3/P9 production workout-mode and Superset gates remain deliberately disabled. | No stale gate confirmed; retain closed gates. |
| Misleading comments and compatibility code | Backup header said v1 only although v2 is accepted; legacy `markWorkoutCompleted` comment recommended the old import path; `_sha1` computes FNV-1a and remains needed for legacy fingerprint recognition. | Corrected comments and private helper name; retained legacy fingerprint behavior and historical-import capability. Other compatibility code was not removed without evidence. |
| Legacy Orbitron/theme residue | Orbitron asset has no live `app/lib` consumer; `AppTheme.darkTheme` and the old `ExerciseCard` have no live construction path found. | Left unchanged to avoid cosmetic asset/theme removal; no proven runtime defect in these paths. |
