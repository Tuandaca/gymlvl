# Test & Specification Mining Survey Report

**Agent**: `spec_miner_survey_3` (Test & Spec Miner)  
**Date**: 2026-10-26  
**Working Directory**: `d:\Projects\gymlvl\.agents\teamwork\spec_miner_survey_3`  
**Reference Specification**: `d:\Projects\gymlvl\.agents\teamwork\ORIGINAL_REQUEST.md`  

---

## 1. Executive Summary & Verification Dashboard

All 6 automated acceptance criteria defined in `ORIGINAL_REQUEST.md` were probed, executed, and independently verified in the repository. The test suites, CI workflow, and isolation harnesses are fully operational.

| # | Acceptance Criterion | Verification Command | Working Directory | Observed Result | Status |
|---|---|---|---|---|---|
| 1 | Flutter Analyzer | `flutter analyze` | `app/` | 0 errors, 0 warnings (3.8s) | **PASS** |
| 2 | Dart Formatter | `dart format --output=none --set-exit-if-changed lib test` | `app/` | 92 files checked, 0 changed (0.74s) | **PASS** |
| 3 | Flutter Unit & Widget Tests | `flutter test` | `app/` | 83 tests run, 83 passed, 0 failed (10s) | **PASS** |
| 4 | Isolated PostgreSQL 17 Harness | `npm.cmd test` | `tools/db-tests/` | 7 SQL verification suites passed on PostgreSQL 17.5 | **PASS** |
| 5 | Edge Functions Deno Harness | `npm.cmd run test:edge` | `tools/db-tests/` | 14 Deno tests passed (318ms); `check:edge` clean | **PASS** |
| 6 | Web Release Build & Smoke Test | `flutter build web --release` & `npm.cmd run test:web` | `app/` & `tools/db-tests/` | Web release bundle built (92s); 16 Playwright smoke checks passed | **PASS** |

---

## Features Discovered

| # | Category | Feature | Description | Inputs | Outputs | Error Behavior | Discovered Via |
|---|---|---|---|---|---|---|---|
| 1 | Flutter Static Analysis | `flutter analyze` | Dart and Flutter static analysis checking for type safety, deprecations, and lint violations | Source code under `app/lib` and `app/test` | Analysis diagnostics; exit code 0 on clean | Non-zero exit code if issues found | `.github/workflows/verify.yml`, `app/analysis_options.yaml` |
| 2 | Code Formatting Check | `dart format` | Strict formatting validation ensuring no uncommitted code style drift | `app/lib`, `app/test` | Formatted file count; exit code 0 | Exits with code 1 if any file needs reformatting | Acceptance Criteria, `docs/DEVELOPMENT.md` |
| 3 | Auth Controller & Flow | `auth_controller_test.dart` | Authentication state machine testing signin, signup, signout, password recovery, debounce, and error handling | Mock credentials, auth exceptions | AuthState transitions, loading flags, error codes | Exposes localized error messages; retains recovery flag on update failure | `app/test/auth_controller_test.dart` |
| 4 | Auth Route Guards | `auth_redirect_test.dart` | GoRouter redirection logic gating deep links, onboarding, and dashboard routes | User auth status, profile loading, onboarding status, recovery flag | Target redirect URI or `null` | Unauthenticated users redirected to `/login`; recovering users forced to `/reset-password` | `app/test/auth_redirect_test.dart` |
| 5 | Public Client Key Guard | `client_config_test.dart` | Validates that the Flutter client only accepts publishable or anon keys, rejecting secret/service_role keys | Key string or JWT token | Boolean validity | Throws/returns false on empty string, service_role token, or secret key | `app/test/client_config_test.dart` |
| 6 | AI Coach Controller | `coach_controller_test.dart` | Client controller for AI coach interaction, in-flight debounce, message history truncation (max 8) | User message text, mock repository | `CoachState` with message list, loading status | Exposes `coach_unconfigured` error code without losing user prompt | `app/test/coach_controller_test.dart` |
| 7 | Client Progression Engine | `progression_engine_test.dart` | Client-side XP estimation and level boundary formulas matching server specifications | Completed sets, duration, category count, user streak | Calculated XP, suspicious pace flag, level threshold | Caps total XP at 1000; returns 0 XP for invalid sets | `app/test/progression_engine_test.dart` |
| 8 | Multi-User Session Isolation | `session_isolation_test.dart` | Ensures client profile drafts and recovery flags do not leak across token refresh or user sign-in | Auth state change events, different user UUIDs | `OnboardingDraft` cleared/retained | Clears biometric draft and recovery flag upon new identity sign-in | `app/test/session_isolation_test.dart` |
| 9 | Multi-Viewport UI Regression | `ui_regression_test.dart` | Exhaustive layout & overflow regression across 4 viewports (320px, 390px, 768px, 1440px) and 2 languages (VI, EN) | Screen widgets, viewport physical size, locale | Render tree, semantics, optional PNG capture | Fails test if RenderFlex overflow or exception caught | `app/test/ui_regression_test.dart` |
| 10 | 9-Step Onboarding Navigation | `ui_regression_test.dart` | Verifies full traversal from Step 1/9 to Step 9/9 at 320px mobile viewport | User profile draft, forward taps | Screen text 'Step X/9', 'Begin your journey' button | Fails if any step is skipped or overflows | `app/test/ui_regression_test.dart` |
| 11 | Workout Active Controller | `workout_controller_test.dart` | Workout session lifecycle: start, begin training, pause, resume, update sets, finish with authoritative XP | Workout actions, set reps/weight, mock repository | Updated Workout model, completion result | Blocks completion if pending edits fail; rejects invalid numeric inputs | `app/test/workout_controller_test.dart` |
| 12 | Workout Widget Responsiveness | `workout_widgets_test.dart` | Interactive workout tiles, delete set button tooltip (VI/EN), rest timer selector, calendar day comparisons | Screen width (320, 768, 1280), language mode | Rendered tile, delete callback, OutlinedButton count | Fails if layout overflows or localized tooltip missing | `app/test/workout_widgets_test.dart` |
| 13 | Isolated PostgreSQL 17 Harness | `run.mjs` | In-memory disposable PostgreSQL 17.5 engine via PGlite applying migrations and executing SQL test suites | SQL migration files, seed scripts, SQL regression files | Query results, assertion logs | Throws and halts runner on any assertion failure or invalid migration name | `tools/db-tests/run.mjs` |
| 14 | Versioned Migrations Replay | `run.mjs` | Enforces versioning format (`YYYYMMDDHHMMSS_name.sql`) and applies baseline + progression migrations | `supabase/migrations/*.sql` | Applied schema tables, triggers, RPC functions | Assertion error if unversioned migration found | `tools/db-tests/run.mjs` |
| 15 | SQL Seed Replay Idempotency | `run.mjs` | Tests executing `supabase/seed.sql` twice to guarantee idempotent catalog initialization | `supabase/seed.sql` | Populated exercises, classes, quests, achievements | Fails if duplicate key or constraint violation occurs | `tools/db-tests/run.mjs` |
| 16 | PostgreSQL RLS & Security Regression | `security_regression.sql` | Tests RLS policies, privilege barriers, direct table mutation denial, and transactional RPCs | Anonymous & authenticated JWT claims, malicious SQL | Execution success, assertion verification | Raises exception with SQLSTATE 42501/22023/23514 on security violation | `supabase/tests/security_regression.sql` |
| 17 | PostgreSQL Progression Regression | `progression_regression.sql` | Tests exact level transitions (100 XP -> level 2), streak tracking, legacy award protection, cascading deletes | Test user UUID, historical workout records | Updated users level/total_xp, streaks, workout_rewards | Fails assertion if XP arithmetic or streak diverges | `supabase/tests/progression_regression.sql` |
| 18 | Deno Edge Function Runner | `edge-tests.mjs` | Spawns bundled Deno binary to typecheck and execute unit tests for all Edge Functions | Deno test targets, `supabase/functions/deno.lock` | Deno test runner stdout/stderr, exit code | Returns non-zero exit code if any Deno test or type error occurs | `tools/db-tests/edge-tests.mjs` |
| 19 | AI Coach Server Proxy & Quota | `ai-coach/service_test.ts` | Edge Function proxy enforcing Bearer auth, input sanitization, 20 req/day quota, timeout, and provider error masking | Mock HTTP requests, stubbed provider fetcher | JSON response `{ generated: true, ... }` | Returns 401 (auth), 400 (validation), 429 (quota), 502/504 (provider failure), 503 (unconfigured) | `supabase/functions/ai-coach/service_test.ts` |
| 20 | Generic RPC HTTP Handler | `http_handler_test.ts` | Shared Edge Function HTTP handler verifying Bearer auth, CORS headers, token forwarding to PostgreSQL | Mock HTTP requests with various tokens and payloads | JSON RPC responses, CORS headers | Returns 401 for invalid/expired tokens, 405 for GET, sanitized database errors | `supabase/functions/tests/http_handler_test.ts` |
| 21 | Request Validation & Error Sanitizer | `request_validation_test.ts` | Pure validation utilities for Bearer tokens, UUIDs, and PostgreSQL error code translation | Raw headers, UUID strings, error objects | Extracted token, valid UUID, HTTP status code | Throws `HttpError` 400/401/403/503 | `supabase/functions/tests/request_validation_test.ts` |
| 22 | Headless Browser Smoke Runner | `browser-smoke.mjs` | Local HTTP server serving `app/build/web` and running Playwright Chromium headless across 16 combinations | Web build directory, viewport matrix, locales | Full-page PNG screenshots, semantics text files, `report.json` | Asserts no RenderFlex overflow, no ErrorWidget, and no horizontal scrollbar | `tools/db-tests/browser-smoke.mjs` |
| 23 | Legacy Database Adoption Rehearsal | `legacy-adoption.mjs` | Restores private JSON backup into disposable PGlite, applies baseline and hardening migrations, checks data retention | `GYMLVL_LEGACY_BACKUP` JSON file path | Row count diffs and field equality verification | Asserts no legacy records disappear and counts match across 14 tables | `tools/db-tests/legacy-adoption.mjs` |
| 24 | Live Multi-User E2E Suite | `live-e2e.mjs` | Comprehensive end-to-end integration test against live/local Supabase stack using two temporary admin accounts | Supabase URL, public key, service role key, expected host | Console PASS logs for 20+ live API/RPC assertions | Fails on any status code mismatch, cleans up created test accounts | `tools/db-tests/live-e2e.mjs` |

---

## Edge Cases

| # | Feature | Input | Observed Behavior |
|---|---|---|---|
| 1 | `client_config_test.dart` | JWT token with payload `{"role": "service_role"}` | Rejected (`SupabaseConfig.isPublicClientKey` returns `false`). Prevents accidental embedding of service keys. |
| 2 | `auth_controller_test.dart` | Simultaneous double click on sign-in button | Handled via in-flight completer; only 1 network request dispatched, second call debounced. |
| 3 | `auth_controller_test.dart` | Sign-in failure followed by correct credentials | First attempt exposes error state; state cleared and retry succeeds cleanly with 2 total repository calls. |
| 4 | `auth_controller_test.dart` | Failed password update | `passwordRecoveryProvider` remains `true` until a password update call succeeds on the server. |
| 5 | `session_isolation_test.dart` | Token refreshed for user A, then user B signs in | User A's biometric draft is preserved on token refresh; completely wiped when User B signs in. |
| 6 | `coach_controller_test.dart` | Blank whitespace message or second message while pending | Blank string returns `false` without network call; duplicate pending submission ignored. |
| 7 | `coach_controller_test.dart` | 6 rapid messages sent to coach | Context window is strictly bounded to the 8 most recent messages, discarding older history. |
| 8 | `progression_engine_test.dart` | Workout with 100 sets, 200kg, 6 categories | XP is strictly bounded and clamped to the maximum cap of 1000 XP. |
| 9 | `progression_engine_test.dart` | 0 valid completed sets | Returns exactly 0 XP regardless of workout duration or suspicious pace estimation. |
| 10 | `progression_engine_test.dart` | 5 completed sets logged in 60 seconds | Flagged as suspicious pace (`checkSuspiciousPace(5, 60) == true`), reducing XP estimation. |
| 11 | `workout_controller_test.dart` | Concurrent calls to `startWorkout()` | De-duplicated: only 1 start request dispatched, both callers receive the same active session. |
| 12 | `workout_controller_test.dart` | Double completion of workout | Only 1 completion request dispatched; both promises resolve with the same authoritative reward. |
| 13 | `workout_controller_test.dart` | Completion with only uncompleted sets | Completion aborted; returns `null`, 0 repository finish calls made. |
| 14 | `workout_controller_test.dart` | Negative reps or NaN weight | Throws `ArgumentError` on client before dispatching persistence call. |
| 15 | `workout_controller_test.dart` | Disposed controller identity receives network completion | Controller state is not repopulated; session discarded safely. |
| 16 | `ui_regression_test.dart` | 320px mobile viewport with 1.5x text scaling | Level-up dialog and dashboard badges remain fully scrollable without any RenderFlex overflow. |
| 17 | `ui_regression_test.dart` | Backend failure loading active quest | Screen displays sanitized localized message ("Could not load your data..."), hiding private stack traces, with functional Retry button. |
| 18 | `security_regression.sql` | Anonymous user queries `public.users` or calls `start_workout()` | PostgreSQL raises SQLSTATE 42501 (insufficient privilege) via RLS and grant restrictions. |
| 19 | `security_regression.sql` | Authenticated user tries to `UPDATE public.users SET total_xp = 999999` | Denied with SQLSTATE 42501; users table columns `total_xp`, `level`, `onboarding_completed` are immutable by client. |
| 20 | `security_regression.sql` | Authenticated user attempts to set `baseline_weight_kg = 0.00001` on workout sets | Server trigger ignores client-supplied value, resetting it to 0 or true historical PR baseline. |
| 21 | `security_regression.sql` | User B attempts to view or complete User A's workout | Query returns 0 rows; RPC call denied. |
| 22 | `security_regression.sql` | Same workout completed multiple times | Idempotent: `workout_rewards` ledger ensures exactly 1 reward record; replaying returns original result without awarding duplicate XP. |
| 23 | `security_regression.sql` | Consecutive workouts on the same calendar day | Streak does not double-increment; remains 1 until the next local calendar day. |
| 24 | `security_regression.sql` | 21st call to `consume_coach_request()` in a single calendar day | Returns `false`; daily rate limit (20 req/day) enforced. Direct reset of `coach_daily_usage` denied. |
| 25 | `progression_regression.sql` | Exact 100 global XP boundary | User transitions from level 1 to level 2 with `current_level_xp = 0` (nonnegative within-level XP). |
| 26 | `progression_regression.sql` | Account deletion in `auth.users` | Cascades cleanly to `public.users`, `public.workouts`, and `public.workout_rewards` without orphan records. |
| 27 | `ai-coach/service_test.ts` | Request missing `providerKey` | Edge Function immediately returns HTTP 503 with sanitized status without calling provider. |
| 28 | `ai-coach/service_test.ts` | Provider returns HTTP 500 with internal stack | Edge Function returns HTTP 502 with `{ code: "provider_unavailable" }`, suppressing the raw provider error. |
| 29 | `ai-coach/service_test.ts` | Provider fetch times out | Edge Function catches `TimeoutError` and returns HTTP 504 Gateway Timeout. |
| 30 | `http_handler_test.ts` | Client sends GET request to RPC Edge Function | Returns HTTP 405 Method Not Allowed; OPTIONS returns HTTP 200 with CORS headers. |

---

## 2. Test Harness Inventory & Architecture

### 2.1 Flutter Test Suite (`app/test/`)
- **Framework**: `flutter_test` with `flutter_riverpod` (`ProviderContainer`, `ProviderScope`) and mocked repositories.
- **Entry Points**:
  - `widget_test.dart` (2 tests): Configuration error UI and fallback screens at 320x568.
  - `client_config_test.dart` (1 test): Public client key / JWT role validation.
  - `auth_redirect_test.dart` (5 tests): GoRouter navigation redirect state machine.
  - `auth_controller_test.dart` (6 tests): Auth provider lifecycle and retry behavior.
  - `workout_controller_test.dart` (10 tests): Active workout state machine, serialization, pause/resume, and validation.
  - `coach_controller_test.dart` (3 tests): AI coach debounce, history framing, and error code exposure.
  - `progression_engine_test.dart` (7 tests): Math formulas for XP calculation, caps, pace limits, and level thresholds.
  - `session_isolation_test.dart` (2 tests): Multi-user draft state isolation and recovery cleanup.
  - `workout_widgets_test.dart` (8 tests): Interactive UI rendering at 320, 768, 1280px in VI/EN, rest timer quick select, and calendar day math.
  - `ui_regression_test.dart` (39 tests): Full responsive screen matrix (Dashboard, Quests, Profile, Onboarding) across 4 viewports (320, 390, 768, 1440px) and 2 locales (VI, EN), 9-step onboarding walkthrough, level-up overlay, quest states, and login/register input validation.
  - `verify_logic.dart`: Delegator entrypoint pointing to `progression_engine_test.dart`.
- **Total Tests**: 83 tests. Execution time: ~10s.

### 2.2 PostgreSQL 17 Isolation Harness (`tools/db-tests/run.mjs`)
- **Technology**: Node.js ESM with `@electric-sql/pglite` (v0.4.6, embedding official PostgreSQL 17.5).
- **Execution Mechanism**: Creates disposable, in-memory PostgreSQL instance with `pgcrypto` extension.
- **Suite Execution Order (7 Units)**:
  1. `tools/db-tests/bootstrap.sql`: Creates mock `auth.users`, `auth.uid()`, and Supabase role grants (`authenticated`, `anon`).
  2. `supabase/migrations/20261026000100_baseline.sql`: Core schema, enum types, table definitions, RLS policies, and triggers.
  3. `supabase/migrations/20261026000200_authoritative_progression.sql`: Hardened RPC functions (`start_workout`, `begin_workout`, `complete_workout`, `initialize_user`, `switch_class`, `sync_daily_data`, `consume_coach_request`), rewards ledger table, and strict column privileges.
  4. `supabase/seed.sql` (Initial run): Exercises catalog, class definitions, synergies, achievements, and quest templates.
  5. `supabase/seed.sql` (Replay run): Verifies that applying seed data repeatedly causes no constraint violations.
  6. `supabase/tests/progression_regression.sql`: Verifies level boundaries, streak incrementing, legacy deduplication, and account deletion cascades.
  7. `supabase/tests/security_regression.sql`: Comprehensive security verification of RLS barriers, privilege restrictions, workout concurrency, quest completion, coach quota, and streak reset.
- **Total Suites**: 7 units. Execution time: ~5s.

### 2.3 Edge Functions Deno Harness (`tools/db-tests/edge-tests.mjs`)
- **Technology**: Node.js runner spawning bundled Deno binary (v2.9.6) located in `tools/db-tests/node_modules/deno/deno.exe`.
- **Configuration**: Uses `--frozen` lockfile `supabase/functions/deno.lock` with cache in `tmp/deno-cache`.
- **Test Suites (14 Tests)**:
  - `supabase/functions/ai-coach/service_test.ts` (6 tests): Token requirement, input validation, quota consumption, unconfigured 503 fallback, provider error sanitization, timeout handling.
  - `supabase/functions/tests/http_handler_test.ts` (5 tests): Rejection of unauthenticated requests, sanitized 401 on expired tokens, user verification and token forwarding, JSON shape validation, database error sanitization.
  - `supabase/functions/tests/request_validation_test.ts` (3 tests): Nonempty Bearer credential enforcement, UUID format validation, and PostgreSQL error code mapping.
- **Typecheck**: `npm.cmd run check:edge` runs `deno check` on all non-test Edge Function entrypoints (`ai-coach`, `calculate-xp`, `get-user-stats`, `initialize-user`, `switch-class`, `sync-daily-data`).
- **Total Tests**: 14 tests. Execution time: ~318ms.

### 2.4 Browser Smoke Test Harness (`tools/db-tests/browser-smoke.mjs`)
- **Technology**: Playwright Chromium headless (v1.64.1) with Node.js built-in HTTP server.
- **Execution Mechanism**: Serves production web build from `app/build/web` on a dynamic loopback port.
- **Permutation Matrix (16 Tests)**:
  - 2 Routes: `#/login`, `#/register`
  - 2 Languages: `vi`, `en` (injected via `localStorage.setItem('flutter.lang_mode')` and browser locale)
  - 4 Viewports:
    - 320 x 720 (Minimum narrow mobile)
    - 390 x 844 (Standard mobile / iPhone 13)
    - 768 x 1024 (Tablet portrait)
    - 1440 x 1000 (Desktop widescreen)
- **Assertions**:
  - Flutter semantics text and DOM contain no `RenderFlex overflowed`, `EXCEPTION CAUGHT`, or `ErrorWidget`.
  - Document element horizontal scroll width does not exceed window inner width (`scrollWidth <= innerWidth`).
- **Artifacts Generated**: Full-page PNG screenshots and semantics text saved to `tmp/qa-browser/` along with `report.json`.

### 2.5 Supplementary Live & Legacy Rehearsal Harnesses
- **Live E2E (`tools/db-tests/live-e2e.mjs`)**: Automated multi-user E2E script designed for execution against a live or local Supabase stack (`supabase start`). Validates actual GoTrue authentication, JWT verification, PostgreSQL PostgREST RPC, workout concurrency, and automatic test user teardown.
- **Legacy Schema Adoption (`tools/db-tests/legacy-adoption.mjs`)**: Safety rehearsal runner that restores a private pre-audit JSON database backup into disposable PGlite and applies migrations to verify zero data loss across all 14 database tables.

---

## 3. Acceptance Criteria & Requirements Traceability Matrix

### 3.1 Acceptance Criteria Mapping

| Criterion | Requirement Reference | Primary Verification Harness | Secondary / E2E Harness | Test Coverage Details | Verified Status |
|---|---|---|---|---|---|
| `flutter analyze` passes with 0 errors and 0 warnings in `app/` | R1 | CLI command in `app/` | GitHub Actions CI (`verify.yml`) | Scans all Dart code in `lib/` and `test/` against `analysis_options.yaml` | **PASS** (0 issues) |
| `dart format --output=none --set-exit-if-changed lib test` passes without changes in `app/` | R1 | CLI command in `app/` | GitHub Actions CI (`verify.yml`) | Enforces standard Dart formatting on 92 files without changes | **PASS** (0 changed) |
| All Flutter unit, widget, and UI regression tests pass (`flutter test`) | R1, R4 | `flutter test` in `app/` | GitHub Actions CI (`verify.yml`) | 83 tests covering auth, router, config, coach, workout controller, widgets, and multi-viewport regression | **PASS** (83/83 passed) |
| Isolated PostgreSQL 17 test harness passes all 7 SQL verification suites (`npm.cmd test` in `tools/db-tests`) | R2, R4 | `npm.cmd test` in `tools/db-tests/` | GitHub Actions CI (`verify.yml`) | Applies migrations, seeds, and executes `progression_regression.sql` & `security_regression.sql` on PGlite PostgreSQL 17.5 | **PASS** (7/7 passed) |
| Edge functions test harness passes all 14 Deno tests (`npm.cmd run test:edge` in `tools/db-tests`) | R3, R4 | `npm.cmd run test:edge` in `tools/db-tests/` | `npm.cmd run check:edge`, CI | Tests Bearer validation, RPC handler isolation, and AI Coach quota/sanitization | **PASS** (14/14 passed) |
| Web production build compiles successfully (`flutter build web`) and passes browser smoke verification (`npm.cmd run test:web`) | R1, R4 | `flutter build web --release` & `browser-smoke.mjs` | GitHub Actions CI (`verify.yml`) | Production release compilation + 16 Playwright browser tests across 4 viewports in VI/EN | **PASS** (16/16 passed) |

### 3.2 Core User Journeys Mapping

| User Journey | Acceptance Expectation | Verification Mechanisms | Test Files | Coverage Status & Limitations |
|---|---|---|---|---|
| **Journey 1: Authentication & Persistence** | Authenticate, recover password, persist auth state across relaunches | Unit: `auth_controller_test.dart`, `auth_redirect_test.dart`, `session_isolation_test.dart`<br>Widget: `ui_regression_test.dart`<br>Browser: `browser-smoke.mjs`<br>Live: `live-e2e.mjs` | `app/test/auth_controller_test.dart`<br>`app/test/auth_redirect_test.dart`<br>`app/test/session_isolation_test.dart`<br>`tools/db-tests/browser-smoke.mjs`<br>`tools/db-tests/live-e2e.mjs` | **FULL (Automated + Live Harness)**.<br>Local tests use mock repository and AuthState streams; `live-e2e.mjs` verifies actual GoTrue token refresh and password grant against Supabase Auth. Real email inbox delivery requires manual device verification. |
| **Journey 2: 9-Step Onboarding** | Complete all 9 onboarding steps without layout overflow at 320px mobile or desktop | Widget: `ui_regression_test.dart`<br>SQL: `security_regression.sql`<br>Live: `live-e2e.mjs` | `app/test/ui_regression_test.dart`<br>`supabase/tests/security_regression.sql`<br>`tools/db-tests/live-e2e.mjs` | **FULL (Automated)**.<br>`ui_regression_test.dart` explicitly walks Step 1/9 through Step 9/9 at 320px viewport without overflow, verifying draft persistence. `security_regression.sql` verifies `initialize_user` RPC validation (rejects invalid days/goals, enforces level 1). |
| **Journey 3: Workout Session & XP** | Start, pause, resume, log sets/weight/reps, complete with authoritative XP and duplicate prevention | Unit/Widget: `workout_controller_test.dart`, `workout_widgets_test.dart`<br>SQL: `security_regression.sql`, `progression_regression.sql`<br>Live: `live-e2e.mjs` | `app/test/workout_controller_test.dart`<br>`app/test/workout_widgets_test.dart`<br>`supabase/tests/security_regression.sql`<br>`supabase/tests/progression_regression.sql`<br>`tools/db-tests/live-e2e.mjs` | **FULL (Automated)**.<br>Controller verifies pause/resume math, in-flight debounce, pending edit ordering. Server tests verify SQL transactional completion, `workout_rewards` ledger deduplication, RLS isolation, PR logging, and streak increment. |
| **Journey 4: Dashboard & Progression** | Accurate stats, level progression, RPG class attributes in VI and EN | Unit: `progression_engine_test.dart`<br>Widget: `ui_regression_test.dart`<br>SQL: `security_regression.sql`<br>Live: `live-e2e.mjs` | `app/test/progression_engine_test.dart`<br>`app/test/ui_regression_test.dart`<br>`supabase/tests/security_regression.sql`<br>`tools/db-tests/live-e2e.mjs` | **FULL (Automated)**.<br>`ui_regression_test.dart` renders DashboardScreen at 320, 390, 768, 1440px in VI and EN, plus 1.5x text scale. `progression_engine_test.dart` tests XP thresholds. `security_regression.sql` tests `get_user_stats` volume trend, achievements, and class switching. |
| **Journey 5: AI Coach Graceful Fallback** | Display offline/unconfigured notice when server endpoint is unconfigured | Unit: `coach_controller_test.dart`<br>Deno: `ai-coach/service_test.ts`<br>Live: `live-e2e.mjs` | `app/test/coach_controller_test.dart`<br>`supabase/functions/ai-coach/service_test.ts`<br>`tools/db-tests/live-e2e.mjs` | **FULL (Automated)**.<br>Deno test verifies Edge Function returns 503 when `providerKey` is undefined. Flutter controller verifies code `coach_unconfigured` is displayed, preserves user question, and allows retry without affecting workout logging. |
| **Journey 6: Release Package & Testing Guide** | Runnable package and instructions prepared for user acceptance | Build: `flutter build web --release`<br>Docs: `README.md`, `docs/DEVELOPMENT.md`, `docs/IMPLEMENTATION_STATUS.md` | `app/build/web/`<br>`docs/DEVELOPMENT.md`<br>`docs/IMPLEMENTATION_STATUS.md` | **READY**.<br>Web bundle compiled cleanly to `app/build/web`. Complete setup, run, and manual 10-step verification instructions are documented in `docs/DEVELOPMENT.md` and `docs/IMPLEMENTATION_STATUS.md`. |

---

## 4. Verification Coverage Gap Analysis & Limitations

While all automated tests pass with 100% success rate, the following environmental boundaries and scope distinctions were identified during the survey:

1. **In-Memory PostgreSQL vs. Live Stack**:
   - `npm.cmd test` executes against an in-memory single-connection PostgreSQL instance (`@electric-sql/pglite`).
   - *Limitation*: PGlite cannot test GoTrue email dispatch, PostgREST HTTP layer serialization, or true multi-client network concurrency.
   - *Mitigation*: `tools/db-tests/live-e2e.mjs` is provided to run the identical verification against a live Supabase stack (`supabase start`).
2. **Browser Smoke vs. Authenticated Web E2E**:
   - `browser-smoke.mjs` verifies the built web bundle at runtime on Chromium for the public routes (`#/login`, `#/register`) across 4 viewports and 2 locales.
   - *Limitation*: It does not execute an end-to-end authenticated workout flow inside the browser DOM due to lack of a running backend during static builds.
   - *Mitigation*: Authenticated workout flows and 9-step onboarding are exhaustively verified in Flutter widget integration tests (`ui_regression_test.dart`) and API-level live E2E (`live-e2e.mjs`).
3. **AI Coach Provider Integration**:
   - The AI Coach is thoroughly verified for authentication, request sanitization, 20 req/day quota, timeout handling, and unconfigured 503 fallback.
   - *Limitation*: A live LLM provider (OpenAI / Gemini / Anthropic) is not called in automated CI to prevent test flakiness and credential leakage.
4. **Mobile Native Builds (Android / iOS)**:
   - Web is the primary release bundle compiled and tested in the Windows dev environment.
   - *Limitation*: Android build requires accepted Android SDK licenses and configured emulator; iOS build requires macOS and Xcode.
   - *Mitigation*: Platform-agnostic Dart code, localization, responsive layouts, and database contracts are verified across viewports down to 320px.

---

## 5. Conclusion & Recommendations

1. **Test Integrity**: The repository possesses a mature, multi-layered verification system with zero failing tests, zero analyzer warnings, and zero format violations.
2. **Acceptance Criteria**: All 6 acceptance criteria specified in `ORIGINAL_REQUEST.md` have been fully validated through direct tool execution.
3. **Readiness**: The codebase is stable, secure, and ready for phase progression to end-user acceptance testing.
