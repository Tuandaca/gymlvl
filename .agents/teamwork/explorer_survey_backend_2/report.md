# Backend, Progression & Exercise Catalog Survey Report

**Explorer**: Backend & Exercise Content Explorer  
**Date**: 2026-10-27  
**Scope**: `supabase/migrations/**`, `supabase/functions/**`, `supabase/seed.sql`, `tools/db-tests/**`, `app/lib/features/{workout,progression,quests}/**`  
**Target Requirements**: R3 (Authoritative Progression, Quests & Streaks), R4 (Exercise Catalog Expansion), R6 (Automated Verification)

---

## 1. Executive Summary

This investigation conducted a comprehensive code-level audit of the GymLvl backend architecture, PostgreSQL migrations, stored procedures (RPCs), Supabase Edge Functions, exercise datasets, and test verification harnesses.

### Key Audit Findings:
1. **Exercise Catalog Status & R4 Gap**: `supabase/seed_exercises.sql` does not yet exist. Existing seeds in `supabase/seed.sql` provide only **22 exercises** across 6 muscle categories. Crucial R4 columns (`slug`, `name_vi`, `name_en`, `secondary_muscles`, `movement_pattern`, `difficulty`, `form_cues`, `common_mistakes`, `alternative_exercises`) do not exist in the `public.exercises` table. A backward-compatible additive migration and dedicated idempotent seed file are required to expand to 120–200 exercises.
2. **Server-Authoritative Progression & XP**: The `complete_workout` RPC (`20261026000200_authoritative_progression.sql:216-283`) is strictly atomic, running inside an isolated transaction with explicit row-level locks on `users` and `workouts`. Replay protection and idempotency are guaranteed by `public.workout_rewards` keyed by `workout_id`. Anti-cheat pace limit clamping restricts XP to 10 if submission exceeds 4 completed sets/minute.
3. **Daily Quests & Streaks**: `sync_daily_data` (`:192-214`) computes local calendar boundaries using `profiles.timezone` (defaulting to `'Asia/Ho_Chi_Minh'`) and creates idempotent daily instances via unique index `quest_instances_unique_day`. `complete_workout` validates set reps/weight against prescribed quest targets. Streak tracking avoids double-crediting on the same day and resets cleanly after missed days.
4. **Edge Functions Health**: `ai-coach` and 5 proxy RPC functions (`calculate-xp`, `get-user-stats`, `initialize-user`, `switch-class`, `sync-daily-data`) are healthy. All 14 Deno tests pass; typechecking (`check:edge`) passes with zero errors; adversarial coach harness passes 15/15 tests.
5. **Test Harness & Execution**: The test harness in `tools/db-tests/` leverages `@electric-sql/pglite` (embedded PostgreSQL 17.5) and local Deno 2.9.6. All 7 SQL regression units, 32 adversarial anti-cheat units, and 14 Edge unit tests pass 100% cleanly.

---

## 2. Exercise Catalog Audit (Requirement R4)

### 2.1 Current State in `supabase/seed.sql`
The repository currently defines 22 exercises in `supabase/seed.sql:1-38` with an idempotent `INSERT ... SELECT * FROM seed WHERE NOT EXISTS`:
- **Chest (4)**: Bench Press (Barbell), Incline Bench Press (Dumbbell), Chest Fly (Machine), Push-up
- **Back (4)**: Deadlift (Barbell), Pull-up, Lat Pulldown (Cable), Seated Cable Row
- **Legs (4)**: Squat (Barbell), Leg Press, Leg Extension, Lying Leg Curl
- **Shoulders (3)**: Overhead Press (Barbell), Lateral Raise (Dumbbell), Face Pull (Cable)
- **Arms (4)**: Bicep Curl (Barbell), Hammer Curl (Dumbbell), Tricep Pushdown (Cable), Skull Crusher (Barbell)
- **Core (3)**: Plank, Crunch, Leg Raise

### 2.2 Table Definition of `public.exercises`
From `supabase/migrations/20261026000100_baseline.sql:127-138`:
```sql
CREATE TABLE IF NOT EXISTS public.exercises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  category TEXT NOT NULL,         -- 'Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core'
  equipment TEXT NOT NULL,        -- 'Barbell', 'Dumbbell', 'Machine', 'Bodyweight', 'Cables'
  force_type TEXT,                -- 'Push', 'Pull', 'Static'
  mechanic TEXT,                  -- 'Compound', 'Isolation'
  instructions TEXT[] DEFAULT '{}',
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);
```

### 2.3 Gap Analysis against Requirement R4
Requirement R4 mandates:
- **Quantity**: 120–200 high-quality, verified exercises (current deficit: 98 to 178 exercises).
- **Metadata Fields**:
  | Required Field | Current Schema Status | Recommended DB Type & Default |
  |---|---|---|
  | `slug` | Missing | `TEXT UNIQUE NOT NULL` |
  | `name_vi` | Missing (only `name` in VI/EN mix) | `TEXT NOT NULL` |
  | `name_en` | Missing | `TEXT NOT NULL` |
  | `category` / Primary muscle | Present (`category`) | Keep `TEXT NOT NULL` |
  | `secondary_muscles` | Missing | `TEXT[] NOT NULL DEFAULT '{}'` |
  | `equipment` | Present (`equipment`) | Expand allowed values: 'Barbell', 'Dumbbell', 'Cable', 'Machine', 'Bodyweight', 'Band' |
  | `movement_pattern` | Missing (`force_type` exists) | `TEXT CHECK (movement_pattern IN ('push','pull','squat','hinge','carry','lunge'))` |
  | `difficulty` | Missing | `TEXT DEFAULT 'beginner' CHECK (difficulty IN ('beginner','intermediate','advanced'))` |
  | `instructions` | Present (`instructions TEXT[]`) | Dual-language or structured instructions |
  | `form_cues` | Missing | `TEXT[] NOT NULL DEFAULT '{}'` |
  | `common_mistakes` | Missing | `TEXT[] NOT NULL DEFAULT '{}'` |
  | `alternative_exercise_slugs` | Missing | `TEXT[] NOT NULL DEFAULT '{}'` |

### 2.4 Backward Compatibility Guardrails
Critical dependencies on `public.exercises` in existing RPCs:
1. `sync_daily_data()` (`20261026000200_authoritative_progression.sql:205-210`):
   - Filters on `template.category='push' AND lower(ex.force_type)='push' AND lower(ex.category)<>'legs'`
   - Uses `ex.name`, `e.category`, `e.equipment`
2. `complete_workout()` (`:235`):
   - Computes `array_agg(DISTINCT lower(e.category))`
3. `switch_class()` (`:298`):
   - Matches `lower(e.category) = ANY(c.focus_categories)`
4. `get_user_stats()` (`:314-316`):
   - Unnests categories `ARRAY['Chest','Back','Legs','Shoulders','Arms','Core']`
5. `app/lib/features/workout/domain/exercise.dart`:
   - Freezed model maps `id`, `name`, `category`, `equipment`, `force_type`, `mechanic`, `instructions`, `image_url`.

**Recommendation**: Retain existing columns `name`, `category`, `equipment`, `force_type`, `mechanic` for full backwards compatibility while adding the new columns via an additive migration. Populate `name` with `name_vi` (or `name_en` based on locale preference) so legacy queries do not break.

### 2.5 Catalog Distribution Blueprint (~150 Exercises)
To achieve the 120–200 range with balanced coverage:
- **Chest**: 25 exercises (Flat/Incline/Decline Barbell & Dumbbell presses, Dips, Cable crossovers, Flyes, Pushup progressions)
- **Back**: 30 exercises (Deadlift variants, Lat pulldowns, Pullups/Chinups, Cable rows, Bent-over barbell/dumbbell rows, Pullovers, Hyperextensions)
- **Legs**: 35 exercises (Squat variants, Front squats, Hack squats, Leg press, Lunges, Bulgarian split squats, Romanian deadlifts, Hamstring curls, Calf raises)
- **Shoulders**: 25 exercises (Overhead barbell/dumbbell press, Arnold press, Lateral raises, Front raises, Face pulls, Rear delt flyes, Upright rows)
- **Arms**: 25 exercises (Barbell/Dumbbell/Cable curls, Preacher curls, Hammer curls, Skull crushers, Tricep pushdowns, Overhead tricep extensions, Dips)
- **Core**: 15 exercises (Planks, Hanging leg raises, Cable crunches, Ab wheel rollouts, Woodchoppers, Pallof press, Russian twists)

---

## 3. Server-Authoritative Progression & XP (Requirement R3)

### 3.1 Architecture of `complete_workout`
The `complete_workout` stored procedure in `supabase/migrations/20261026000200_authoritative_progression.sql:216-283` is the sole authoritative gatekeeper for awarding XP, incrementing streaks, updating PRs, checking quest completions, and evaluating achievements.

#### 1. Atomicity & Concurrency Control
```sql
SELECT * INTO u FROM public.users WHERE id=uid FOR UPDATE;
SELECT * INTO w FROM public.workouts WHERE id=p_workout_id AND user_id=uid FOR UPDATE;
```
- Acquires an exclusive row-level lock on `public.users` for the calling athlete, serializing any concurrent progression operations (e.g., race conditions between multiple tabs or rapid clicks).
- Acquires an exclusive row-level lock on the specific `public.workouts` row.
- Write operations on child rows (`workout_exercises`, `workout_sets`) are protected by the trigger `guard_workout_child()` (`:107-131`), which locks the parent workout and asserts `parent_status = 'active'`.

#### 2. Idempotency & Duplicate Submission Protection
```sql
SELECT r.result INTO result FROM public.workout_rewards r WHERE r.workout_id=w.id;
IF result IS NOT NULL THEN RETURN result; END IF;

IF w.is_xp_calculated THEN
  RETURN jsonb_build_object('earnedXP', 0, 'totalXP', u.total_xp, ..., 'alreadyAwarded', true);
END IF;
```
- Upon initial completion, the generated outcome JSON is stored permanently in `public.workout_rewards` with primary key `workout_id`.
- If `complete_workout` is invoked again with the same `workout_id`, the function returns the previously cached `result` payload directly. No additional XP, no streak increment, and no duplicate `xp_logs` entries are produced.
- A secondary check on `workouts.is_xp_calculated` provides defensive fallback for legacy rows.

#### 3. Anti-Cheat & Pace Clamping
```sql
suspicious = completed_sets > 3 AND completed_sets * 60.0 / duration > 4;
...
IF suspicious THEN earned = 10;
```
- If a user attempts to log completed sets at a rate exceeding **4 sets per minute** (for sessions with >3 sets), the session is flagged as `suspicious = true`, and total earned XP is clamped to a nominal **10 XP**.
- Sessions with 0 completed sets fail with SQLSTATE `22023`.
- Volume attacks (>300 completed sets or set numbers >100) fail validation with `22023` or CHECK constraint `23514`.

#### 4. XP Calculation Formulation
- **Base Volume XP**:
  $$\text{Base XP} = \sum_{s \in \text{completed sets}} \begin{cases} 5 \times \min\left(3.0, \max\left(0.2, \frac{s.\text{weight\_kg}}{s.\text{baseline\_weight\_kg}}\right)\right) & \text{if } s.\text{baseline\_weight\_kg} > 0 \\ 5 & \text{otherwise} \end{cases}$$
- **Variety Bonus**:
  $$\text{Variety} = \max(0, \text{cardinality}(\text{categories}) - 1) \times 8$$
- **Streak Multiplier**:
  - Non-quest: $\min(1.5, 1 + \max(0, \text{streak} - 1) \times 0.05)$ (up to +50% for 11+ days streak).
  - Quest match: $\min(2.0, 1 + \max(0, \text{streak} - 1) \times 0.05)$ (up to +100% for 21+ days streak).
- **Session XP Cap**: Hard ceiling of **1,000 XP** per workout session.
- **Class XP Distribution**:
  $$\text{Class XP} = \left\lfloor \text{earned} \times \left( \begin{cases} 1.0 & \text{if workout touches class focus categories} \\ 0.4 & \text{otherwise} \end{cases} \right) \times \text{synergy} \right\rfloor$$
  Where `synergy = 1.05` for perfect class synergy pairs (e.g. Shredder + Endurance, Hiper-Growth + Powerlifting).

#### 5. Level Curves & Title Tiers
- **Global Level Threshold**:
  $$\text{XP Required for Level } L = \lfloor 100 \times L^{1.5} \rfloor$$
- **Class Level Threshold** (max Level 20 / Graduation):
  $$\text{Class XP Required for Level } L = \lfloor \text{xp\_base} \times L^{\text{xp\_slope}} \rfloor$$
- **Title Hierarchy**:
  - Lv 1: *Tân Binh*
  - Lv 5: *Tập Sự*
  - Lv 10: *Chiến Binh*
  - Lv 15: *Đấu Sĩ*
  - Lv 20: *Dũng Sĩ*
  - Lv 30: *Anh Hùng*
  - Lv 50: *Huyền Thoại*
  - Lv 75: *Thần Thoại*
  - Lv 100: *Bất Tử*

---

## 4. Daily Quests & Streaks Architecture (Requirement R3)

### 4.1 Timezone-Aware Daily Quest Generation (`sync_daily_data`)
From `20261026000200_authoritative_progression.sql:192-214`:
1. **User Timezone Resolution**:
   ```sql
   SELECT * INTO p FROM public.profiles WHERE id=uid;
   day = (now() AT TIME ZONE p.timezone)::date;
   ```
   Uses `p.timezone` stored on the user profile (default `'Asia/Ho_Chi_Minh'`), ensuring that day boundaries match the athlete's local midnight.
2. **Deterministic Quest Rotation**:
   Rotates through active quest templates using day-of-year:
   `extract(doy FROM day)::integer % count(daily_routines)`
3. **Prescribed Exercise Configuration**:
   Selects 3 exercises matching the quest category (`push`, `pull`, `legs`, `full_body`) and assigns:
   - Sets: 3
   - Reps: 12
   - Weight: 0 kg for bodyweight, or $80\%$ of user's personal record rounded to nearest 0.5 kg (`round(pr.max_weight_kg * 0.8 * 2) / 2`).
4. **Idempotency**:
   Unique partial index `quest_instances_unique_day ON public.quest_instances(user_id, quest_date) WHERE quest_date IS NOT NULL` guarantees that calling `sync_daily_data` repeatedly on the same day returns the existing quest without creating duplicate instances.

### 4.2 Quest Target Verification in `complete_workout`
In `complete_workout` (`:245-252`):
- Checks all targets in `q.prescribed_config`.
- For each target exercise, counts completed sets in the workout where:
  `s.reps >= target.reps AND s.weight_kg >= target.weight_kg`.
- If completed sets $\ge$ `target.sets` (3) for **all** target exercises, `quest_match = true`.
- Upon match, awards quest template base XP (350–450 XP) multiplied by streak bonus, marks `quest_instances.status = 'completed'`, and records the reward in `xp_logs` with `source = 'quest'`.

### 4.3 Streak Tracking Logic
1. **Consecutive Day Evaluation**:
   ```sql
   streak = CASE
     WHEN prev_date = day THEN streak     -- multiple workouts on same day: keep current streak
     WHEN prev_date = day - 1 THEN streak + 1 -- consecutive calendar day: increment
     WHEN prev_date > day THEN streak     -- historical recovery/clock drift safeguard
     ELSE 1                               -- gap >= 2 days: reset to 1
   END;
   ```
2. **Missed Day Cleanup**:
   - `sync_daily_data()` executes:
     `UPDATE public.streaks SET current_streak=0 WHERE user_id=uid AND last_activity_date < day - 1;`
   - `get_user_stats()` dynamically projects:
     `current_streak = CASE WHEN last_activity_date < day - 1 THEN 0 ELSE current_streak END;`
     This ensures that the dashboard immediately displays `0` even if `sync_daily_data` has not yet been triggered today.

---

## 5. Edge Functions Architecture & Health

### 5.1 Function Catalog
Located in `supabase/functions/`:
| Function | Route | Type | Auth / JWT | Purpose |
|---|---|---|---|---|
| `ai-coach` | `/functions/v1/ai-coach` | Custom Proxy | Verified (`client.auth.getUser`) | AI coaching chatbot with rate-limiting, context injection, and error sanitization |
| `calculate-xp` | `/functions/v1/calculate-xp` | RPC Proxy | Verified (`rpcHandler`) | Proxies `complete_workout` RPC with UUID validation |
| `get-user-stats`| `/functions/v1/get-user-stats` | RPC Proxy | Verified (`rpcHandler`) | Proxies `get_user_stats` RPC |
| `initialize-user`| `/functions/v1/initialize-user` | RPC Proxy | Verified (`rpcHandler`) | Proxies `initialize_user` onboarding RPC |
| `switch-class` | `/functions/v1/switch-class` | RPC Proxy | Verified (`rpcHandler`) | Validates `new_class_id` ('A'-'F') and `slot`, proxies `switch_class` RPC |
| `sync-daily-data`| `/functions/v1/sync-daily-data` | RPC Proxy | Verified (`rpcHandler`) | Proxies `sync_daily_data` daily quest/streak sync |

### 5.2 AI Coach Service Deep Dive (`supabase/functions/ai-coach/`)
- **Rate Limiting**: Daily limit of **20 requests/day** per user enforced via atomic database RPC `consume_coach_request()` (`20261026000200_authoritative_progression.sql:340-347`) against table `public.coach_daily_usage`. Exhaustion returns HTTP 429 `{ code: "daily_limit" }`.
- **Graceful 503 Fallback**: If `COACH_API_URL`, `COACH_API_KEY`, or `COACH_MODEL` environment variables are absent, or if the URL protocol is not `https:`, the service returns HTTP 503 `{ code: "coach_unconfigured" }` without crashing or throwing unhandled errors.
- **Request Sanitization**:
  - Rejects empty, whitespace, or missing messages with HTTP 400 `{ code: "invalid_message" }`.
  - Rejects message content > 2,000 characters with HTTP 400.
  - Rejects total payload > 20,000 bytes with HTTP 413 `{ code: "message_too_large" }`.
  - Rejects history > 8 messages, non-string content, content > 4,000 characters, or roles other than `user` and `assistant` (prevents prompt injection of `system` role) with HTTP 400 `{ code: "invalid_history" }`.
- **Context Injection**: Fetches verified user data from Supabase (goals, environment, experience level, and completed workouts within the last 7 days) and injects it into the system prompt.
- **Upstream Resilience & Security**:
  - Timeout: 25-second `AbortSignal.timeout(25000)` mapped to HTTP 504 `{ code: "provider_timeout" }`.
  - Error Sanitization: Upstream 500 or malformed JSON responses are mapped to HTTP 502 `{ code: "provider_unavailable" }` without exposing internal provider error messages or secret stack traces.

### 5.3 Shared Edge Infrastructure (`supabase/functions/_shared/`)
- `http.ts`: Standardized CORS (`Access-Control-Allow-Origin: *`), JSON parsing, 16 KB body size limit (`HttpError(413)`), bearer token authentication, and RPC invocation wrapper.
- `validation.ts`: Sanitizes database error codes (`42501` -> HTTP 403, `22xxx`/`23xxx` -> HTTP 400, other codes -> HTTP 503).

---

## 6. Test Suites & Verification Harness

### 6.1 Isolated Verification Harness (`tools/db-tests/`)
The project utilizes `@electric-sql/pglite` (embedded PostgreSQL 17.5) with `pgcrypto` to execute tests in an isolated, in-memory database without requiring Docker, external ports, or internet access.

| Command | File | Target & Coverage | Result |
|---|---|---|---|
| `npm.cmd test` | `run.mjs` | Replays `bootstrap.sql`, `20261026000100_baseline.sql`, `20261026000200_authoritative_progression.sql`, `seed.sql` (2x for idempotency), `progression_regression.sql`, `security_regression.sql` | **PASS (7/7 SQL units)** |
| `npm.cmd run test:edge` | `edge-tests.mjs` | Deno tests: 6 AI coach service tests, 5 HTTP handler tests, 3 validation tests | **PASS (14/14 Deno tests)** |
| `npm.cmd run check:edge` | `edge-tests.mjs --check` | Deno typechecks all function entrypoints with frozen lockfile `deno.lock` | **PASS (0 type errors)** |
| `node adversarial-anti-cheat.mjs` | `adversarial-anti-cheat.mjs` | 32 adversarial test units testing pace limits, replay protection, privilege boundaries, and coach quota | **PASS (32/32 units)** |
| `node adversarial-coach.mjs` | `adversarial-coach.mjs` | 15 adversarial test units testing AI coach injection, fallback, timeouts, and rate limits | **PASS (15/15 units)** |
| `npm.cmd run test:web` | `browser-smoke.mjs` | Playwright browser smoke test across 320px, 390px, 768px, 1440px in VI & EN | Ready for web build |

### 6.2 SQL Regression Test Verification (`supabase/tests/`)
1. `progression_regression.sql`:
   - Exact XP boundary calculations (Level 1 to Level 2 transition at 100 XP).
   - Non-negative within-level XP.
   - Historical workout recovery preserving timestamps and activity dates.
   - Idempotency: Duplicate completion of already awarded workouts yields 0 duplicate XP.
   - Class switching deduplicating historical logs.
   - Cascade account deletions.
2. `security_regression.sql`:
   - Signup triggers.
   - Anonymous access rejected with `42501`.
   - RLS isolation: User A cannot read or mutate User B's profile, workouts, sets, or progress.
   - Client direct updates to `users.total_xp`, `users.level`, `streaks`, `xp_logs`, `quest_instances`, `workout_rewards` blocked with `42501`.
   - Table constraints `workout_sets_valid_values` (set_number 1-100, reps 0-1000, weight 0-1000).
   - `guard_workout_child()` trigger enforcement.

---

## 7. Recommendations & Implementation Roadmap for Requirements R3, R4, R6

### For Requirement R4 (Exercise Catalog Expansion — Agent D)
1. **Create Additive Migration**:
   - File: `supabase/migrations/20261027000100_exercise_catalog_metadata.sql`
   - Actions:
     ```sql
     ALTER TABLE public.exercises
       ADD COLUMN IF NOT EXISTS slug TEXT,
       ADD COLUMN IF NOT EXISTS name_vi TEXT,
       ADD COLUMN IF NOT EXISTS name_en TEXT,
       ADD COLUMN IF NOT EXISTS secondary_muscles TEXT[] NOT NULL DEFAULT '{}',
       ADD COLUMN IF NOT EXISTS movement_pattern TEXT,
       ADD COLUMN IF NOT EXISTS difficulty TEXT DEFAULT 'beginner',
       ADD COLUMN IF NOT EXISTS form_cues TEXT[] NOT NULL DEFAULT '{}',
       ADD COLUMN IF NOT EXISTS common_mistakes TEXT[] NOT NULL DEFAULT '{}',
       ADD COLUMN IF NOT EXISTS alternative_exercise_slugs TEXT[] NOT NULL DEFAULT '{}';
     CREATE UNIQUE INDEX IF NOT EXISTS idx_exercises_slug ON public.exercises(slug) WHERE slug IS NOT NULL;
     ```
2. **Author `supabase/seed_exercises.sql`**:
   - Create idempotent script using `INSERT INTO public.exercises (...) VALUES (...) ON CONFLICT (slug) DO UPDATE ...` or `WHERE NOT EXISTS`.
   - Backfill existing 22 exercises with slugs, dual names, movement patterns, and form cues.
   - Seed additional 100–130 verified exercises to reach ~150 total exercises across the 6 major muscle categories.
3. **Update `supabase/config.toml`**:
   - Update `sql_paths` in `[db.seed]`:
     ```toml
     sql_paths = ["./seed.sql", "./seed_exercises.sql"]
     ```
   - This automatically enables `run.mjs` (`npm.cmd test`) to test the new seed file twice for replay idempotency.
4. **Update Flutter Domain Model & UI**:
   - Update `Exercise` Freezed model in `app/lib/features/workout/domain/exercise.dart` to include the new fields.
   - Update `ExercisePickerScreen` and `CandyExerciseCard` to display dual Vietnamese/English names, movement patterns, and form cues.

### For Requirement R3 (Progression, Quests & Streaks — Agent C)
1. **Preserve Database RPCs**:
   - The PostgreSQL RPCs (`complete_workout`, `sync_daily_data`, `start_workout`, `begin_workout`, `set_workout_paused`, `cancel_workout`, `switch_class`, `get_user_stats`) are complete, hardened, and thoroughly tested. No schema rewrites are needed.
2. **Batching Workout Mutations (R5 link)**:
   - Client currently calls `_repository.addSet` in sequential loops when starting quests or adding exercises (`active_workout_controller.dart:192-202`).
   - Agent C and Agent B can provide a batch set insertion RPC or multi-row insert query to eliminate N+1 roundtrips.
3. **Start Quest UX**:
   - Verify that `daily_quest_card.dart` successfully launches `/workout/active` with pre-filled prescribed exercises and target weights/reps.

### For Requirement R6 (Automated Verification — Agent E)
1. Run `npm.cmd test` in `tools/db-tests/` as standard pre-commit gate.
2. Run `npm.cmd run test:edge` and `npm.cmd run check:edge` for all edge function changes.
3. Maintain frozen lockfile `supabase/functions/deno.lock`.

---
*End of Backend Survey Report.*
