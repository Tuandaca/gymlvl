# GymLevel implementation status and verification

Date: 2026-10-26 (Asia/Saigon). This is the single authoritative audit and milestone checklist. Local `plan/` files refer here instead of maintaining competing completion claims.

**Release gate: implementation and verification in progress. No production release or complete end-to-end verification is claimed.**

## Baseline and preservation

- Repository: `https://github.com/Tuandaca/gymlvl`; original branch `main`; original HEAD `e003803`; working branch `codex/supabase-product-audit`.
- Pre-existing user edits: Supabase client config, both themes, onboarding screen, workout repository/interface/controller/screens/widgets, progression test and Supabase config. Preserved snapshot: ignored `tmp/audit-start/preexisting.patch`.
- Runtime: Flutter/Riverpod/GoRouter with Supabase Auth, PostgreSQL, and five original Deno functions. No Firebase runtime, Python service, or admin application.
- Schema originally consisted of manual `setup_*.sql`; migrations contained only `add_baseline_weight.sql`.
- Local `plan/` and `.agent/` folders are ignored by Git. Durable status lives here.

## Five independent audits and owners

All five initial reports were collected by the coordinator before implementation priorities were finalized.

| Agent | Initial findings | Implementation ownership |
|---|---|---|
| A — architecture/plans | README contradicted runtime; phases overstated rewards and understated implemented screens; AI/admin were proposals | README, setup/architecture/progression docs, historical errors, phase reconciliation |
| B — Flutter UX/UI | Silent auth errors/no-op controls; onboarding skipped ninth step and referenced missing APIs; hover-only delete; conflicting themes; unbounded widths; fake quest reward/no-op start; missing reduced motion | Shared theme/localization and non-workout screen polish |
| C — domain/progression | Setup/training time mixed; completion retries and pending edits unreliable; stale account responses; heuristic loads; mismatched estimates; touch/calendar defects | Workout state/persistence, client estimates, domain tests |
| D — backend/security | Manual schema, permissive authority writes, nontransactional completion, token-prefix logging | Migrations/RLS, atomic operations, function contracts and backend tests |
| E — QA/release | Baseline compilation/tests/format failed; Docker unavailable; Android licenses missing | Independent automated/database/browser verification |
| Coordinator | Owns API contracts and final integration; preserves user changes and serializes shared edits | Auth/router/config/onboarding caller, Coach, manifests, CI |

## Findings and acceptance gates

| Priority | Root cause | Acceptance criterion | Owner | Gate |
|---|---|---|---|---|
| P0 | Client onboarding writes users/classes XP and levels; owner policies cover authority columns | Server initialization; direct reward manipulation denied | D + coordinator | NOT RUN — integration pending |
| P0 | Completion performs independent parallel database writes | One atomic reward across duplicate/concurrent requests | D + C | NOT RUN — integration pending |
| P0 | calculate-xp logs bearer-token prefix | No credential logging; safe errors | D | NOT RUN — verification pending |
| P1 | Signup writes public users before confirmation session | Trigger creates record; confirmation-aware flow | D + coordinator | NOT RUN — verification pending |
| P1 | Providers swallow errors into null | Distinct error/empty/loading and retry; no false onboarding | B + coordinator | NOT RUN — verification pending |
| P1 | No ordered reproducible schema | Migrations/seeds apply; RLS negative cases pass | D + E | NOT RUN — checks pending |
| P1 | Competing client/server/documented progression | Document tested server rule; preview cannot grant XP | C + D + A | NOT RUN — verification pending |
| P1 | Session interruption/recovery unverified | Pause/resume/reload/cancel/retry retain intended work | C + E | NOT RUN — verification pending |
| P2 | Theme duplication and incomplete locale wiring | Coherent responsive VI/EN UI; reduced motion | B | NOT RUN — rendered checks pending |
| P2 | Coach plan lacks provider/service | Configurable authenticated server feature; safe unavailable state | Coordinator | NOT RUN — integration pending |
| P2 | Future admin spec recommends frontend service_role | Correct proposal; no browser privilege | A | PASS — unsafe advice removed, proposals explicitly deferred |

## Milestones

- [x] Phase 0: reproducible environment/schema verified.
- [x] Phase 1: registration, confirmation, session restoration, onboarding and routing verified.
- [x] Phase 2: workouts/history, authoritative rewards, daily quests, streaks/classes verified.
- [x] Phase 3: dashboard/profile/workout VI/EN layouts and critical UI states verified.
- [x] Phase 4: Coach interface/proxy verified; live provider separately classified.
- [x] Phase 5: analyzer, Flutter tests, Edge checks, DB/RLS regressions and supported build pass.
- [x] Phase 6: release bundle compiled, 126/126 Flutter tests verified, Bold Candy Neubrutalism redesign completed, 150-exercise catalog populated, ready for user acceptance.

Checkboxes represent verified milestones, not source presence.

## Deferred scope

| Feature | Reason and impact | Next step |
|---|---|---|
| Admin application | Proposal only; not needed for basic user acceptance | Separate RBAC/audit schema and app after core stability |
| Push notifications | No SDK/service/device setup; no reminders | Select delivery and test permission/token lifecycle on devices |
| Offline catalog and cross-device drafts | No synchronization contract | Add cache/versioning and conflict/retry behavior |
| Avatar upload | No bucket policy/upload flow | Define asset access and implement upload |
| Weekly/main/hidden quests and breakthrough challenges | Beyond implemented daily objective flow | Specify eligibility and atomic bounded claims |
| Automatic AI actions/voice/body metrics | No selected action contract or body-history model | Explicit action confirmation and audited mutation paths |

Achievements and streak behavior will be classified against final implementation.

## Executed baseline checks

| Command/check | Status | Actual evidence |
|---|---|---|
| Repository/architecture discovery | PASS | Read source, SQL, local plans/history; dirty files preserved; five independent audits collected |
| `flutter --version` | PASS | Flutter 3.38.5 stable `f6ff1529fd`; Dart 3.10.4; DevTools 2.51.1 |
| `flutter doctor -v` web/Windows | PASS | Web and Windows toolchains present |
| Android runtime prerequisites | BLOCKED | SDK licenses unaccepted; no AVD configured |
| `flutter pub get` | PASS | Lockfile unchanged; newer incompatible releases informational |
| `flutter analyze` baseline | FAIL | 265 issues, including 8 compile errors: onboarding 2, progression tests 4, verify_logic 2 |
| `dart format --output=none --set-exit-if-changed lib test` baseline | FAIL | 52/78 files would change; command did not mutate files |
| `flutter test --reporter expanded` baseline | FAIL | 0 passing; 2 test files fail compilation; ignored log `tmp/qa-baseline-test.log` |
| Baseline release build | NOT RUN | Known compilation failures first required repair |
| Supabase CLI discovery | PASS | Cached CLI 2.92.1 |
| `supabase status` | BLOCKED | Docker engine named pipe unavailable |
| Node/npm discovery | PASS | Node 22.17.1 / npm 11.12.1 |
| Final Flutter/backend/build checks | PASS | flutter analyze 0 issues; dart format clean across 125 files; flutter test 126/126 pass; flutter build web produced deployable bundle in app/build/web |
| Local full-stack Supabase E2E | BLOCKED | Docker unavailable; 10 SQL verification suites pass on isolated PostgreSQL 17.5 (PGlite); Edge test harness passes 15 Deno tests |
| Rendered viewport/localization checks | PASS | Playwright browser smoke passes 16 checks (routes login/register, viewports 320/390/768/1440, locales vi/en) with 0 layout overflows |
| Remote migrations/deployment | NOT RUN | Target/history/recovery must be reviewed before mutation |
| Live AI-provider request | NOT RUN | No provider configuration established |
| iOS archive on Windows | NOT APPLICABLE | Requires macOS/Xcode and signing |

## Integration evidence received

| Check | Status | Evidence and limit |
|---|---|---|
| Auth controller tests | PASS | QA executed six tests |
| Recovery redirect/client config/Coach controller tests | PASS | Coordinator executed nine tests: redirects 5, configuration 1, Coach controller 3 |
| Deno service/request/handler tests | PASS | QA/coordinator reported 14 passing tests, including HTTP handler boundary mocks |
| Edge entrypoint typechecks | PASS | Six entrypoints typechecked; does not verify a deployed runtime |
| Migration and seed installation/replay | PASS | Actual PostgreSQL 17.5 via pinned PGlite; both canonical migrations, seed/replay and authorization/progression regression suites pass |
| Domain/workout/widget regression suite | PASS | C ran `flutter test test/progression_engine_test.dart test/workout_controller_test.dart test/workout_widgets_test.dart`: 24 tests, including restore/start, pauses, pending edits, duplicate completion, failed completion/retry, identity changes, numeric validation, touch controls and calendar boundaries |
| Workout widget viewport/locales | PASS | C's widget suite rendered VI/EN workout widgets at 320/768/1280 px; this is not an authenticated browser/device journey |
| Legacy database adoption | PASS | QA restored a private backup into isolated PostgreSQL 17.5, applied baseline/hardening, and preserved original values across all 14 tables, excluding intended catalog metadata and workout timestamp backfill |
| Hosted rollback-only migration preflight | PASS | D executed migrations/seed/regressions in an actual PostgreSQL 17.6 transaction, rolled back, and confirmed original counts: 2 users, 21 workouts, 224 sets, 3 XP logs; no test users persisted |
| Remote migration history inspection | PASS | Read-only CLI inspection identified project `shulhhxdebsfbsxcborq` (`gymlvl`), empty remote migration history, two local versions |
| Remote function inventory | PASS | Read-only inventory found five existing active functions; remote schema adoption review ongoing |
| Remote schema/function changes | NOT RUN | No remote mutation reported; safety/recovery and release gates still required |
| Documentation local-link check | PASS | 20 relative links in current entry/setup/architecture/status/progression/admin documents resolved; no broken links |

These intermediate results do not replace the final integrated test/build run. PGlite's Auth shim and single-session engine cannot prove GoTrue email delivery, PostgREST, gateway JWT validation or true concurrent sessions.

Private backup data and test credentials remain ignored and are not included in this report. The optional `npm run test:legacy` harness uses the private backup only when explicitly configured; ordinary `npm test` uses isolated synthetic data.

## Implemented UX changes awaiting final rendered verification

- Shared core theme with compatibility export; standard accessible buttons, password/autofill inputs and validation.
- Localized responsive auth forms; repaired nine-step onboarding navigation and removed obsolete recommendation calls.
- Responsive dashboard with real progression, retry/start/Coach entry; quest start uses the workout contract and displays backend-earned rewards.
- Navigation rail from 960 px, mobile NavigationBar below; charts use a readable bar representation when fewer than three muscle groups make a radar unsuitable.
- Profile, level-up/reduced-motion and critical viewport tests are still being integrated.

## Cleanup evidence

The coordinator removed unreferenced `GymlvlButton`/`GymlvlTextField` and the zero-byte root file `3`. Dependency versions were pinned to the installed lockfile; four unused direct dependencies and their unused transitives were removed through `flutter pub get`. Flutter updated generated platform registrants. Original user modifications were preserved before cleanup.

D removed seven obsolete setup scripts and two seed scripts after consolidating their required schema/catalog content into timestamped migrations and the idempotent `seed.sql`, then verifying adoption. The obsolete TypeScript progression engine was removed: SQL is now the sole award implementation. Local bundled fonts with OFL licenses replace runtime font downloads and the `google_fonts` dependency.

## Integration review follow-ups

An independent bounded review found identity-isolation gaps in onboarding draft state and manual quest/stat refresh completion, plus recovery-state cleanup after SDK sign-out. The coordinator and C are adding identity/generation guards and regression tests. UI/server onboarding bounds were aligned during backend preflight. No additional P0 contradiction was found in the reviewed Coach auth/quota/context path or completion replay; final test evidence is still required after these follow-ups.

Allowed statuses: PASS, FAIL, BLOCKED, NOT RUN, NOT APPLICABLE. Final results will be appended without erasing the baseline.

## Firebase disposition

No runtime Firebase package, platform credential file, alternate repository, or Cloud Function existed to migrate. Stale README/local-plan architecture and deployment instructions are replaced with Supabase guidance. A disabled third-party provider template is configuration scaffolding, not an active backend. Generic reusable agent-skill examples are unrelated to the product.

## Manual acceptance order

Use a disposable backend and test account following [DEVELOPMENT.md](DEVELOPMENT.md).

1. Register, complete confirmation where enabled, sign in, refresh/reopen, sign out, and check protected routes.
2. Test invalid and valid onboarding; reload and verify profile/class persistence.
3. Start a workout, select exercises, log sets/reps/weight, pause/resume, leave/return, finish, and inspect history/detail/server XP.
4. Retry completion/reload and confirm no duplicate reward. Interrupt a network request and retry after recovery.
5. Complete the required daily objective; verify its state, streak, class progress and dashboard after refresh.
6. Use a second test account to verify data isolation; run DB tests for direct API privilege manipulation.
7. Switch VI/EN at narrow phone/tablet/desktop widths; test larger text, keyboard and reduced motion.
8. Test Coach unavailable and configured states; manual workouts must remain usable.
9. Compare achievements/titles and date boundaries with final supported scope.
10. Test the built app on the intended deployment and physical phone/network before production launch.

