# Empirical Adversarial Challenge Report: Backend Anti-Cheat, Replay & Security Boundaries

- **Target Agent**: `challenger_anti_cheat_2` (Backend Anti-Cheat Challenger)
- **Evaluation Timestamp**: 2026-10-26T14:58:30Z
- **Verdict**: **`APPROVE`**
- **Overall Risk Assessment**: **LOW**

---

## 1. Executive Summary

As an empirical challenger, I subjected the GymLevel backend (PostgreSQL 17.5 migrations, security triggers, stored procedures, RLS policies, and Deno Edge functions) to automated adversarial probes across four critical security surfaces:
1. Anti-Cheat Pace Limit Clamping (>4 sets/min).
2. Replay Protection & Idempotency via `workout_rewards`.
3. Privilege Escalation & SQL Tampering Boundaries (SQLSTATE 42501).
4. AI Coach Daily Quota Enforcements (20 req/day) and Unconfigured / Insecure Fallbacks (HTTP 503).

All canonical test suites (`npm.cmd test`, `npm.cmd run test:edge`) and newly crafted empirical adversarial stress harnesses (`tools/db-tests/adversarial-anti-cheat.mjs` with 32 units and `tools/db-tests/adversarial-coach.mjs` with 15 units) passed with 100% success rate. Zero security bypasses, zero permission leaks, and zero state corruption bugs were observed.

---

## 2. Adversarial Challenges & Empirical Probe Results

### Challenge 1: Rapid Workout Submission Pace Limit Clamp (>4 sets/min)
- **Assumption Challenged**: An attacker or scripted bot can spam fast workout submissions to rapidly farm XP and level up.
- **Attack Scenarios Probed**:
  - *Bot Attack Rapid Submission*: 5 completed sets in 30 seconds (10 sets/min rate).
  - *Boundary Edge Pace Above Limit*: 4 completed sets in 50 seconds (4.8 sets/min > 4 sets/min).
  - *Boundary Edge Pace Below Limit*: 4 completed sets in 70 seconds (3.43 sets/min <= 4 sets/min).
  - *Extreme Volume Flood*: 320 sets submitted across 4 exercises.
  - *Tampering with Timestamps*: Client attempting to forge `workouts.started_at` or `training_started_at`.
- **Observed Behavior**:
  - In `public.complete_workout`: `suspicious = completed_sets > 3 AND completed_sets * 60.0 / duration > 4;`.
  - When `suspicious` is true, earned XP is clamped to strictly `10` XP flat, regardless of exercise volume or streak multipliers.
  - Rapid submissions at 10 sets/min and 4.8 sets/min both returned `isSuspicious: true` and `earnedXP: 10`.
  - Normal pace at 3.43 sets/min and 0.5 sets/min returned `isSuspicious: false` and awarded legitimate calculated XP (20 XP and 25 XP).
  - Extreme volume (>300 sets) was immediately aborted with PostgreSQL exception `22023` ("Invalid workout measurements").
  - Direct client updates to `started_at` or `training_started_at` were denied with `42501`.
- **Assessment**: **PASS** (Zero bypass found; mathematical clamping operates reliably).

---

### Challenge 2: Replay Protection & Idempotency via `workout_rewards`
- **Assumption Challenged**: Submitting duplicate completion network requests for the same workout ID might duplicate XP gains, increment streaks repeatedly, or cause race conditions.
- **Attack Scenarios Probed**:
  - Repeatedly calling `public.complete_workout(workout_id)` 10 consecutive times on an active workout.
  - Post-completion tampering with set weights (e.g. updating `weight_kg` from 60kg to 999kg after completion).
  - Invoking completion on legacy pre-existing sessions (`is_xp_calculated = true`).
- **Observed Behavior**:
  - On first completion, atomic transaction writes the computed reward JSON into `public.workout_rewards(workout_id, user_id, result)` and sets `workouts.is_xp_calculated = true`.
  - On all 10 subsequent replays, `complete_workout` checks `SELECT r.result INTO result FROM public.workout_rewards WHERE workout_id = w.id;` and returns the cached JSON without re-executing progression logic.
  - User `total_xp` remained strictly identical before and after all 10 replays.
  - User `current_streak` remained strictly identical (no duplicate streak increment).
  - `public.xp_logs` maintained exactly 1 row for the workout.
  - `public.workout_rewards` maintained exactly 1 row for the workout.
  - Trigger `guard_workout_child()` on `workout_sets` rejected post-completion weight updates, keeping weights preserved at 60kg.
  - Legacy awarded sessions returned `earnedXP: 0` and `alreadyAwarded: true`.
- **Assessment**: **PASS** (Full replay idempotency and post-completion immutability confirmed).

---

### Challenge 3: Privilege Escalation & SQL Direct Mutation (SQLSTATE 42501)
- **Assumption Challenged**: Authenticated clients with Supabase JWT access might bypass stored procedures and directly modify sensitive columns in PostgreSQL tables via PostgREST/SQL.
- **Attack Scenarios Probed**:
  - `UPDATE public.users SET total_xp = 999999`
  - `UPDATE public.users SET level = 99`
  - `UPDATE public.users SET current_level_xp = 500`
  - `UPDATE public.users SET onboarding_completed = true`
  - `INSERT INTO public.users(id, email, total_xp) VALUES (...)`
  - `DELETE FROM public.users WHERE id = ...`
  - `UPDATE public.user_classes SET current_xp = 99999`
  - `UPDATE public.user_classes SET level = 20`
  - `INSERT INTO public.user_classes (...)`
  - `UPDATE public.quest_instances SET status = 'completed', earned_xp = 500`
  - `INSERT INTO public.quest_instances (...)`
  - `INSERT INTO public.xp_logs(user_id, amount, source) VALUES (...)`
  - `UPDATE public.streaks SET current_streak = 50`
  - `INSERT INTO public.workout_rewards (...)`
  - `UPDATE public.coach_daily_usage SET request_count = 0`
  - `INSERT INTO public.user_achievements (...)`
  - `UPDATE public.workouts SET started_at = now() - interval '1 hour'`
  - `UPDATE public.workouts SET is_xp_calculated = false, status = 'completed'`
- **Observed Behavior**:
  - `REVOKE ALL` is applied across all public tables from `anon` and `authenticated`.
  - Column-level UPDATE privileges are strictly confined to safe profile fields:
    - `GRANT UPDATE(display_name, avatar_url, locale) ON public.users TO authenticated;`
    - `GRANT UPDATE(environment, goals, experience_level, age, gender, height_cm, weight_kg, weekly_gym_days, weekly_home_days, preferred_training_days) ON public.profiles TO authenticated;`
    - `GRANT UPDATE(notes) ON public.workouts TO authenticated;`
  - All 18 unauthorized write statements were rejected by PostgreSQL with error code **`42501`** (insufficient_privilege).
  - Legitimate updates to safe fields (`display_name`, `height_cm`) succeeded normally.
- **Assessment**: **PASS** (Principle of least privilege strictly enforced at the schema level).

---

### Challenge 4: AI Coach Rate Limiting (20 req/day) & Graceful Fallback (503)
- **Assumption Challenged**: An attacker could flood the AI Coach Edge function, exhaust API quotas, bypass daily limits, or leak server secrets on unconfigured upstream providers.
- **Attack Scenarios Probed**:
  - Calling `consume_coach_request()` as an anonymous user (`anon`).
  - Calling `consume_coach_request()` 20 consecutive times, followed by a 21st attempt.
  - Tampering with `coach_daily_usage.request_count` directly in the database.
  - Sending coach requests when `COACH_API_KEY` is undefined.
  - Sending coach requests when `COACH_API_URL` is undefined or non-HTTPS (`http://insecure-llm.com`).
  - Sending coach requests when `COACH_MODEL` is undefined.
  - Sending prompt injection payloads attempting to override system behavior (e.g. system role in history).
  - Sending oversized payloads (>20,000 bytes) or oversized messages (>2,000 chars).
  - Inducing upstream provider timeouts (AbortError) and 500 internal errors with sensitive stack traces.
- **Observed Behavior**:
  - Anonymous invocation of `consume_coach_request()` was blocked with `42501`.
  - Database RPC `consume_coach_request()` returned `true` for requests 1-20, and `false` for request 21.
  - Table constraint `CHECK(request_count BETWEEN 0 AND 20)` blocked DB tampering with error `23514`.
  - Missing provider credentials or non-HTTPS URLs returned HTTP 503 `{ code: "coach_unconfigured" }`.
  - Rate limit exhaustion returned HTTP 429 `{ code: "daily_limit" }`.
  - System role in conversation history returned HTTP 400 `{ code: "invalid_history" }`.
  - Oversized payloads returned HTTP 413 `{ code: "message_too_large" }` and HTTP 400 `{ code: "invalid_message" }`.
  - Upstream timeout returned HTTP 504 `{ code: "provider_timeout" }`.
  - Upstream 500 error was completely sanitized to HTTP 502 `{ code: "provider_unavailable" }` without leaking error details or credentials.
- **Assessment**: **PASS** (Zero credential leak, fails closed on unconfigured/insecure upstream, quota enforced).

---

## 3. Stress Test Results Matrix

| # | Test Scenario | Expected Behavior | Actual Behavior | Result |
|---|---------------|-------------------|-----------------|--------|
| 1 | Normal pace workout (0.5 sets/min) | Not flagged (`isSuspicious: false`), earns >10 XP | `isSuspicious: false`, earned 25 XP | **PASS** |
| 2 | Bot attack rapid pace (10 sets/min) | Clamped to 10 XP flat, `isSuspicious: true` | `isSuspicious: true`, earned 10 XP | **PASS** |
| 3 | Boundary pace above limit (4.8 sets/min) | Clamped to 10 XP flat, `isSuspicious: true` | `isSuspicious: true`, earned 10 XP | **PASS** |
| 4 | Boundary pace below limit (3.43 sets/min) | Not flagged, earns >10 XP | `isSuspicious: false`, earned 20 XP | **PASS** |
| 5 | Excessive sets flood (>300 sets) | Aborted with error 22023 | Rejected with SQLSTATE 22023 | **PASS** |
| 6 | Invalid set metrics (reps=0, weight<0) | Blocked by CHECK constraint 23514 | Rejected with SQLSTATE 23514 | **PASS** |
| 7 | Workout replay (10x repeat completion) | Idempotent, identical cached JSON, 0 added XP | Identical cached JSON, 0 duplicate XP, 1 reward row | **PASS** |
| 8 | Tampering with completed sets | Blocked by trigger `guard_workout_child` | Updates blocked, weight retained at 60kg | **PASS** |
| 9 | Legacy completed session completion | Earns 0 XP, marked alreadyAwarded | `earnedXP: 0`, `alreadyAwarded: true` | **PASS** |
| 10 | Direct SQL UPDATE on `users.total_xp` | Blocked with SQLSTATE 42501 | Rejected with SQLSTATE 42501 | **PASS** |
| 11 | Direct SQL UPDATE on `users.level` | Blocked with SQLSTATE 42501 | Rejected with SQLSTATE 42501 | **PASS** |
| 12 | Direct SQL UPDATE on `user_classes.xp` | Blocked with SQLSTATE 42501 | Rejected with SQLSTATE 42501 | **PASS** |
| 13 | Direct SQL UPDATE on `quest_instances` | Blocked with SQLSTATE 42501 | Rejected with SQLSTATE 42501 | **PASS** |
| 14 | Direct SQL INSERT on `xp_logs` | Blocked with SQLSTATE 42501 | Rejected with SQLSTATE 42501 | **PASS** |
| 15 | Direct SQL UPDATE on `streaks` | Blocked with SQLSTATE 42501 | Rejected with SQLSTATE 42501 | **PASS** |
| 16 | Direct SQL UPDATE on `workouts.started_at`| Blocked with SQLSTATE 42501 | Rejected with SQLSTATE 42501 | **PASS** |
| 17 | Permitted update on safe profile fields | Succeeds normally | `display_name` and `height_cm` updated | **PASS** |
| 18 | Anon calling `consume_coach_request()` | Blocked with SQLSTATE 42501 | Rejected with SQLSTATE 42501 | **PASS** |
| 19 | Coach 20 req/day quota consumption | Exactly 20 pass, 21st returns false | 20 calls returned true, 21st returned false | **PASS** |
| 20 | Coach table tampering (`request_count=21`) | Blocked by CHECK constraint 23514 | Rejected with SQLSTATE 23514 | **PASS** |
| 21 | Coach missing credentials | HTTP 503 `coach_unconfigured` | HTTP 503 `coach_unconfigured` | **PASS** |
| 22 | Coach non-HTTPS provider URL | HTTP 503 `coach_unconfigured` | HTTP 503 `coach_unconfigured` | **PASS** |
| 23 | Coach quota exhausted on Edge | HTTP 429 `daily_limit` | HTTP 429 `daily_limit` | **PASS** |
| 24 | Coach unauthenticated / invalid token | HTTP 401 `unauthorized` | HTTP 401 `unauthorized` | **PASS** |
| 25 | Coach system role in conversation history | HTTP 400 `invalid_history` | HTTP 400 `invalid_history` | **PASS** |
| 26 | Coach oversized payload (>20KB) | HTTP 413 `message_too_large` | HTTP 413 `message_too_large` | **PASS** |
| 27 | Coach upstream provider timeout | HTTP 504 `provider_timeout` | HTTP 504 `provider_timeout` | **PASS** |
| 28 | Coach upstream 500 stack leak test | HTTP 502 `provider_unavailable`, 0 leak | HTTP 502, zero sensitive string leak | **PASS** |

---

## 4. Test Suite Execution Logs

### Canonical Test Harnesses:
1. `npm.cmd test` (PostgreSQL 17.5 Isolation Runner):
   ```
   PASS isolated auth/role bootstrap
   PASS migration 20261026000100_baseline.sql
   PASS migration 20261026000200_authoritative_progression.sql
   PASS seed ./seed.sql
   PASS seed replay ./seed.sql
   PASS SQL regression progression_regression.sql
   PASS SQL regression security_regression.sql
   PASS 7 SQL verification units against PostgreSQL 17.5
   ```
2. `npm.cmd run test:edge` (Deno Function Runner):
   ```
   running 6 tests from ./supabase/functions/ai-coach/service_test.ts ... ok
   running 5 tests from ./supabase/functions/tests/http_handler_test.ts ... ok
   running 3 tests from ./supabase/functions/tests/request_validation_test.ts ... ok
   ok | 14 passed | 0 failed (269ms)
   ```

### Custom Empirical Adversarial Suites:
1. `node adversarial-anti-cheat.mjs` (PGlite 17.5 Adversarial Runner):
   ```
   ALL ADVERSARIAL TESTS PASSED: 32/32 units
   ```
2. `node adversarial-coach.mjs` (Deno 2.9.6 Adversarial Runner):
   ```
   ALL ADVERSARIAL EDGE TESTS PASSED: 15/15 units
   ```

---

## 5. Unchallenged Areas

- **Distributed Connection-Pool Exhaustion**: The isolated PostgreSQL test harness executes within an in-process `@electric-sql/pglite` engine. Verification of multi-node PgBouncer connection saturation under DDoS traffic requires a live Supabase distributed cluster.

---

## 6. Final Adversarial Verdict

### **VERDICT: `APPROVE`**

The backend anti-cheat pace limits, replay protection guards, privilege revocation boundaries, and AI Coach degradation architectures exhibit defense-in-depth design and robust empirical resilience against adversarial inputs.
