# SDD ledger — plan: docs/superpowers/plans/2026-11-13-p10-3b-placement.md

**Task:** P10.3b local placement implementation.
**Base:** `main` / `7e21abb7649d108bf9b54ae59e874e816f2b54ff`; expected dirty owner/P10 tree.
**Backup:** `D:\Projects\gymlvl_p10_3b_impl_backup_20261113_200409`; 100 dirty SHA-256 hashes, 841 archive paths, complete bundle and clone HEAD verified.
**Approval:** D-062 accepted by explicit owner answer, local/test only. No commit/push/deploy.

## Preflight

| Tasks / interface | Check and ruling |
|---|---|
| 0 → 1 | Consumer inventory and exact schema reviewed; D-062 now accepted. |
| 1 SQL ↔ Dart policy | Same v0.1 rows/caps/median and canonical UUID validation; compare golden examples and boundary cases. |
| 1 → 2 (same migration) | Sequential SQL edits; one backend owner; review policy/storage before adding confirmation. |
| 2 → 3 (evidence → progress RPC) | New reward insert owns both paths; never use class-switch reconstructed XP. |
| 3 → 4 (RPC → Flutter) | Explicit readiness fields and immutable operation request; production provider disabled. |
| 4 → 5 (UI → concurrency) | UI does not grant progression; real PostgreSQL tests prove transaction ordering separately. |
| 1 internal | Tests cover thresholds, missing/invalid input and owner ACL before implementation. |
| 2 internal | Tests exercise lost-response replay, distinct-day pair selection and actual account deletion. |
| 3 internal | Readiness progress uses threshold differences and new immutable receipts only. |
| 4 internal | Existing beginner experience bug fixed without inventing new load prescriptions. |
| 5 internal | Aggregate report is privileged and suppresses subgroups below 20; runtime/live limits explicit. |

Ruling: Work in existing `main` rather than a new worktree/branch — owner AGENTS.md mandates main-only and preserves dirty work; backup verified. Tasks have exclusive file owners and no automatic Git operations.

Ruling: Task 4 may minimally edit `app/lib/core/router/app_router.dart`, the workout controller's progress invalidation and the class provider's successful-switch invalidation — actual `/plan` currently points at a default empty presentation widget, and readiness needs refresh after those server actions. These edits implement the approved routing/refresh contract; no new plan generator or reward behavior is introduced.

## Progress

- Task 0: PASS, source/design checkpoint from preceding session; current approval recorded.
- Task 1: PASS — Dart policy72/72, SQL56 units/365 ACL, independent scoped re-review PASS.
- Task 2: PASS for scoped single-connection enrollment/evidence/confirmation contract; `npm test` PASS57/365. Task5 still owns true two-connection concurrency verification.
- Task 3: PASS — readiness projection, receipt progress trigger and consumer/security tests; final scoped re-review PASS.
- Task 4: PASS — onboarding, plan routing, dashboard readiness lane and full Flutter regression.
- Task 5: PASS for isolated local/test concurrency and synthetic pilot-report fixture; standalone `psql` report execution, production pilot and live Supabase remain NOT RUN.

### Task 1 checkpoint

- Parent `flutter test test/p10_placement_policy_test.dart` → PASS 42/42; parent `npm test` → PASS 56 SQL units / 365 ACL assertions. Implementer RED: missing SQL scorer42883 and Dart golden expectations failed before implementation.
- Independent Task1 review: FAIL, inclusive barbell preview boundary (24 kg × 6 / 72 kg should score2) suffers floating division rounding; explicit invalid body mass is handled inconsistently in bodyweight preview.
- Fix round1/5 dispatched to original Dart implementer. Ruling: compare serialized decimal inputs exactly against rational thresholds, no epsilon; explicitly invalid supplied body mass rejects for all classes, absent mass remains allowed for bodyweight preview. Existing profile constraint is20–400, not the review's stated500.
- Task2 remains NOT RUN until Task1 review gate passes. No earned progression or production state changed.

- Fix round1/5 complete: both findings addressed. Exact serialized-decimal `BigInt` comparison fixes boundary without epsilon; malformed supplied mass rejects. Independent reviewer ran `flutter test test/p10_placement_policy_test.dart` → PASS72/72; no remaining Task1 blocking findings. SQL remained unchanged at parent PASS56/365. Task1 gate closed before dispatching Task2.

- Task2 implementation resumed after a RED syntax checkpoint. Fixed full `initialize_user` override and removed literal-newline/PLpgSQL errors. Parent `npm test` → `PASS`, 57 SQL verification units / 365 ACL assertions. Task2 review pending; runtime confirmation evidence is not yet independently accepted.
- Task2 confirmation fixture expansion initially failed because a contradictory temporal guard rejected every workout; after removing it and qualifying the evidence column, `npm test` → `PASS`, 57 units/365 ACL. Scoped re-review pending before Task3.
- Task2 closure: explicit supersede assertion now passes for the prior insufficient assessment; latest assessment selection is locked and ordered newest-first. `npm test` → `PASS`, 57/365. Concurrency races remain Task5, not a Task2 acceptance blocker.

- Task 3 implementation checkpoint: SQL projection, receipt progress trigger, owner-only state RPC and consumer/security tests are present. `tools/db-tests npm test` → `PASS`, 59 SQL units/365 ACL assertions. Dart readiness tests → `PASS`, 3/3; targeted analyze → `PASS`, no issues. Final review fixes corrected class XP-to-next threshold arithmetic and confirmed status serialization. Task 4 remains unopened pending final review.

- Task 3 closure: final scoped SQL re-review → `PASS`; class readiness `nextc` is zero when the assessed class is no longer primary, and confirmed status serializes as the literal `confirmed`. `tools/db-tests npm test` → `PASS`, 59 SQL units/365 ACL assertions. Runtime/live projection remains limited to isolated local tests.

- Task 4 closure: onboarding now records an explicit never-trained/experienced placement choice without fabricating performance anchors; `/plan` consumes `planRouteProvider` and routes beginners without history to `NewcomerJourneyScreen` while experienced/returning users enter `RoutineListScreen`; dashboard mounts `PlacementReadinessCard` in a separate readiness lane and preserves earned progression widgets. Focused Flutter placement/onboarding/plan/navigation tests → `PASS`, 29 tests; full `flutter test --reporter compact` → `PASS`, 907 tests; targeted `dart analyze` for dashboard, plan entry/router and placement → `PASS`, no issues. Device/live UX and Supabase runtime checks → `NOT RUN`. Task 5 remains.

- Task 5 local checkpoint: standalone read-only `tools/db-tests/placement_pilot_report.sql` and rollback-scoped synthetic `supabase/tests/p10_placement_pilot_report.sql` cover completed-onboarding denominators, separate attempt counts, route/missingness and `<20` suppression. `tools/db-tests npm test` → `PASS`, 60 SQL units/365 ACL assertions. `npm run test:concurrency:p10` → `PASS`, two real PostgreSQL connections: duplicate submission replay, retry immutability, class-switch guard, invalid-evidence no-op, forced transaction rollback, and two concurrent reward receipts yielding two evidence rows and one confirmation. The first race reproduced a deadlock; changing evidence serialization from `users FOR UPDATE` to the primary `user_classes` row resolved it. Existing `npm run test:concurrency` → `PASS`, 8/8. Standalone pilot report execution via `psql` → `NOT RUN` because `psql` is unavailable; fixture verification is covered by the SQL runner. Production pilot/live Supabase → `NOT RUN`.
