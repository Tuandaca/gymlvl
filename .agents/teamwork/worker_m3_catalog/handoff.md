# Handoff Report: Milestone M3 — Exercise Catalog Schema & Seed Data Expansion

**Agent**: Agent D & C (Exercise Catalog & Schema Specialist)  
**Working Directory**: `d:\Projects\gymlvl\.agents\teamwork\worker_m3_catalog`  
**Milestone**: M3 — Exercise Catalog Schema & Seed Data Expansion (Requirements R3, R4, R6)  
**Date**: 2026-10-27  

---

## 1. Observation

1. **Schema & Migration Extensions**:
   - Created additive migration `supabase/migrations/20261027000100_exercise_catalog_metadata.sql`:
     - Added metadata columns to `public.exercises`:
       - `slug text UNIQUE`
       - `name_vi text NOT NULL DEFAULT ''`
       - `name_en text NOT NULL DEFAULT ''`
       - `secondary_muscles text[] DEFAULT '{}'`
       - `movement_pattern text CHECK (movement_pattern IS NULL OR movement_pattern IN ('push','pull','squat','hinge','carry','lunge','isolation'))`
       - `difficulty text CHECK (difficulty IS NULL OR difficulty IN ('beginner','intermediate','advanced'))`
       - `form_cues text[] DEFAULT '{}'`
       - `common_mistakes text[] DEFAULT '{}'`
       - `alternative_exercise_slugs text[] DEFAULT '{}'`
     - Added trigger `trigger_set_exercise_slug` executing `public.set_exercise_slug_default()` to auto-populate `slug` and `name_en` for any legacy/unslotted inserts.
     - Backfilled all 22 existing exercises with slugs (e.g. `'barbell-bench-press'`, `'incline-dumbbell-bench-press'`), accurate Vietnamese names (`name_vi`), English names (`name_en`), movement patterns, secondary muscles, form cues, common mistakes, and alternative slugs.
     - Added `duration_seconds integer DEFAULT 0` to `public.workout_sets`.
     - Updated check constraint `workout_sets_valid_values` on `public.workout_sets` to allow static holds / duration exercises:
       `CHECK (set_number BETWEEN 1 AND 100 AND reps BETWEEN 0 AND 1000 AND weight_kg BETWEEN 0 AND 1000 AND rest_seconds BETWEEN 0 AND 7200 AND baseline_weight_kg BETWEEN 0 AND 1000 AND (duration_seconds IS NULL OR duration_seconds BETWEEN 0 AND 7200) AND (NOT is_completed OR reps > 0 OR duration_seconds > 0))`

2. **Curated Exercise Seed Data Expansion**:
   - Authored `supabase/seed_exercises.sql` containing **150** high-quality exercises:
     - **Chest**: 24 exercises (Barbell/Dumbbell flat/incline/decline, Cable flyes, Dips, Push-up variations, Machine presses)
     - **Back**: 26 exercises (Deadlift variants, Lat pulldowns, Pull-ups/Chin-ups, Rows, Hyperextensions, Shrugs)
     - **Legs**: 28 exercises (Squats, Front squats, Hack squats, Leg press, Lunges, Bulgarian split squats, RDLs, Leg curls, Calves, Hip thrusts)
     - **Shoulders**: 22 exercises (Overhead presses, Arnold press, Lateral raises, Face pulls, Front raises, Rear delt flyes, Upright rows)
     - **Arms**: 24 exercises (12 Biceps: Barbell/Dumbbell/Cable/Preacher/Spider curls; 12 Triceps: Skull crushers, Pushdowns, Dips, Kickbacks)
     - **Core**: 14 exercises (Plank, Crunches, Leg raises, Ab wheel rollouts, Side planks, Pallof press, Hollow body hold)
     - **Full Body**: 6 exercises (Burpee, Kettlebell swing, Clean & Press, Snatch, Thruster, Farmer's Walk)
     - **Cardio**: 6 exercises (Jumping jack, Treadmill running, Stationary bike, Rowing machine, Jump rope, Battle ropes)
   - Equipment distribution: Barbell, Dumbbell, Cable, Machine, Bodyweight, Resistance Band.
   - Movement pattern distribution: Push, Pull, Squat, Hinge, Carry, Lunge, Isolation.
   - Every single entry is seeded via idempotent `INSERT INTO public.exercises (...) VALUES (...) ON CONFLICT (slug) DO UPDATE SET ...`

3. **Supabase CLI Configuration & Test Harness**:
   - Updated `supabase/config.toml:65`:
     ```toml
     [db.seed]
     enabled = true
     sql_paths = ["./seed.sql", "./seed_exercises.sql"]
     ```
   - Updated `tools/db-tests/run.mjs` to dynamically execute migrations, replay both seeds, run SQL regressions, and verify:
     - Exact exercise catalog count is between 120 and 200:
       `SELECT count(*)::integer as total FROM public.exercises;`
     - Metadata integrity: 0 rows with NULL/empty `slug`, `name_vi`, `name_en`, or `movement_pattern`.
     - Existence of `workout_sets.duration_seconds`.
     - Static hold support: completed set with `reps = 0, duration_seconds = 60, is_completed = true` succeeds; completed set with `reps = 0, duration_seconds = 0, is_completed = true` is rejected by check constraint `workout_sets_valid_values`.

4. **Verbatim Verification Outputs**:
   - Command: `npm.cmd test` in `tools/db-tests`:
     ```
     > test
     > node run.mjs

     PASS isolated auth/role bootstrap
     PASS migration 20261026000100_baseline.sql
     PASS migration 20261026000200_authoritative_progression.sql
     PASS migration 20261027000100_exercise_catalog_metadata.sql
     PASS seed ./seed.sql
     PASS seed replay ./seed.sql
     PASS seed ./seed_exercises.sql
     PASS seed replay ./seed_exercises.sql
     PASS SQL regression progression_regression.sql
     PASS SQL regression security_regression.sql
     VERIFIED exercise catalog count: 150 exercises (target 120-200)
     VERIFIED exercise catalog metadata integrity (0 null/empty fields)
     VERIFIED workout_sets duration_seconds column exists
     VERIFIED static hold / duration_seconds check constraint behavior
     PASS 10 SQL verification units against PostgreSQL 17.5
     LIMITATION: isolated single-connection PostgreSQL; Supabase gateway/Auth/Edge runtime and true concurrent sessions require the local stack.
     ```
   - Command: `node adversarial-anti-cheat.mjs` in `tools/db-tests`:
     ```
     ALL ADVERSARIAL TESTS PASSED: 32/32 units
     ```
   - Command: `npm.cmd run test:edge` in `tools/db-tests`:
     ```
     ok | 14 passed | 0 failed (512ms)
     ```

---

## 2. Logic Chain

1. **Additive Schema & Backwards Compatibility**:
   - Observation 1 shows that `20261027000100_exercise_catalog_metadata.sql` uses `ADD COLUMN IF NOT EXISTS`, preserving all existing tables, foreign keys, and records.
   - Observation 1 shows that `name` remains fully populated and aligned with English titles, so legacy queries (e.g. `ORDER BY name`) and RPCs (`sync_daily_data`, `complete_workout`) continue to function without schema drift or broken references.
   - The trigger `trigger_set_exercise_slug` guarantees that if any legacy code or ad-hoc test inserts an exercise without a slug or `name_en`, it will automatically receive a valid URL-safe slug and `name_en = name`.

2. **Idempotent Curated Catalog (150 Exercises)**:
   - Observation 2 demonstrates that all 150 exercises have unique slugs and are upserted via `ON CONFLICT (slug) DO UPDATE`.
   - Observation 1 and 2 show that the 22 exercises from `seed.sql` have explicit slug mappings in both the migration backfill and `seed_exercises.sql` pre-update, guaranteeing that no duplicate rows are created when `seed.sql` and `seed_exercises.sql` run in sequence or replay.
   - Observation 4 confirms that `seed replay ./seed_exercises.sql` passes and total count remains exactly 150.

3. **Duration Exercises & Static Holds Support**:
   - Observation 1 shows `duration_seconds integer DEFAULT 0` added to `workout_sets`.
   - Observation 1 and 4 prove that the updated check constraint `(NOT is_completed OR reps > 0 OR duration_seconds > 0)` permits completed static holds (e.g. Plank with 0 reps and 60 seconds) while strictly disallowing invalid completed sets with 0 reps and 0 duration.

4. **Integration with Test Harness**:
   - Observation 3 and 4 confirm that `config.toml` includes both seeds and `run.mjs` executes all migrations, seeds, SQL regression suites, and 4 new automated verification checks.
   - All 10 SQL units, 32 adversarial anti-cheat units, and 14 Edge function unit tests pass with zero errors.

---

## 3. Caveats

1. **Client Model Adoption (Milestone M4)**: The Flutter `Exercise` and `WorkoutSet` models in `app/lib/features/workout/` will be updated in Milestone M4 by Agent B to expose `name_vi`, `name_en`, `secondary_muscles`, `movement_pattern`, `difficulty`, `form_cues`, `common_mistakes`, and `duration_seconds` in the UI and state controllers.
2. **Local PostgreSQL Runner**: Tests are verified in isolated PostgreSQL 17.5 via `@electric-sql/pglite`. Production Supabase deployments will apply the migration cleanly via `supabase db push` or `supabase migration up`.

---

## 4. Conclusion

Milestone M3 (Exercise Catalog Schema & Seed Data Expansion) is 100% complete and fully verified:
- `supabase/migrations/20261027000100_exercise_catalog_metadata.sql` successfully extends `public.exercises` with bilingual metadata and adds `duration_seconds` to `public.workout_sets` with updated validation constraints.
- `supabase/seed_exercises.sql` provides 150 comprehensive, high-quality, idempotent exercises covering all 8 major muscle groups, 6 equipment types, and 7 movement patterns.
- `supabase/config.toml` and `tools/db-tests/run.mjs` are integrated and fully verified against PostgreSQL 17.5 with 0 errors.

---

## 5. Verification Method

To independently reproduce and verify this work:

1. **Run the Database Test Harness**:
   ```powershell
   cd d:\Projects\gymlvl\tools\db-tests
   npm.cmd test
   ```
   *Expected result*:
   - Passes all 10 SQL units against PostgreSQL 17.5.
   - Prints:
     - `VERIFIED exercise catalog count: 150 exercises (target 120-200)`
     - `VERIFIED exercise catalog metadata integrity (0 null/empty fields)`
     - `VERIFIED workout_sets duration_seconds column exists`
     - `VERIFIED static hold / duration_seconds check constraint behavior`

2. **Run Adversarial Anti-Cheat & Security Suites**:
   ```powershell
   node adversarial-anti-cheat.mjs
   ```
   *Expected result*: `ALL ADVERSARIAL TESTS PASSED: 32/32 units`.

3. **Run Deno Edge Function Unit Tests**:
   ```powershell
   npm.cmd run test:edge
   ```
   *Expected result*: `ok | 14 passed | 0 failed`.

### Invalidation Conditions:
- If `npm.cmd test` fails on migration replay or SQL regressions.
- If `SELECT count(*) FROM public.exercises;` is less than 120 or greater than 200.
- If any exercise contains NULL in `slug`, `name_vi`, `name_en`, or `movement_pattern`.
- If inserting a completed set with `reps = 0, duration_seconds = 60, is_completed = true` fails.
