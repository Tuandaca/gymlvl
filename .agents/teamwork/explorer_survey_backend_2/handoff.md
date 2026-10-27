# Handoff Report: Backend, Progression & Exercise Catalog Survey

**Agent**: Backend & Exercise Content Explorer  
**Working Directory**: `d:\Projects\gymlvl\.agents\teamwork\explorer_survey_backend_2`  
**Report Artifact**: `d:\Projects\gymlvl\.agents\teamwork\explorer_survey_backend_2\report.md`  
**Milestone**: Survey & Audit Phase (Requirements R3, R4, R6)

---

## 1. Observation

1. **Exercise Seed Script & Catalog Gap**:
   - `supabase/seed_exercises.sql` does not exist in the codebase.
   - `supabase/seed.sql:1-38` seeds only 22 exercises:
     ```sql
     WITH seed(name, category, equipment, force_type, mechanic, instructions) AS (VALUES
     ('Bench Press (Barbell)', 'Chest', 'Barbell', 'Push', 'Compound', ...),
     ...
     )
     INSERT INTO public.exercises(name, category, equipment, force_type, mechanic, instructions)
     SELECT * FROM seed WHERE NOT EXISTS (SELECT 1 FROM public.exercises e WHERE e.name=seed.name);
     ```
   - `supabase/migrations/20261026000100_baseline.sql:127-138` defines table `public.exercises` with columns: `id`, `name`, `category`, `equipment`, `force_type`, `mechanic`, `instructions`, `image_url`, `created_at`, `updated_at`.
   - Missing columns required by R4: `slug`, `name_vi`, `name_en`, `secondary_muscles`, `movement_pattern`, `difficulty`, `form_cues`, `common_mistakes`, `alternative_exercise_slugs`.
   - `supabase/config.toml:65` configures seeds as `sql_paths = ["./seed.sql"]`.

2. **Progression & XP RPC Atomicity & Replay Protection**:
   - `supabase/migrations/20261026000200_authoritative_progression.sql:216-283` defines `complete_workout(p_workout_id uuid, p_notes text)`:
     - Row locking on user and workout:
       `SELECT * INTO u FROM public.users WHERE id=uid FOR UPDATE;`
       `SELECT * INTO w FROM public.workouts WHERE id=p_workout_id AND user_id=uid FOR UPDATE;`
     - Replay protection:
       `SELECT r.result INTO result FROM public.workout_rewards r WHERE r.workout_id=w.id;`
       `IF result IS NOT NULL THEN RETURN result; END IF;`
       `IF w.is_xp_calculated THEN RETURN jsonb_build_object('earnedXP',0,...); END IF;`
     - Tamper protection: `guard_workout_child()` trigger (`:107-131`) prevents modifying `workout_exercises` or `workout_sets` unless parent `status = 'active'`.
     - Anti-cheat pace limit clamping:
       `suspicious = completed_sets > 3 AND completed_sets * 60.0 / duration > 4;`
       `IF suspicious THEN earned = 10;`
     - Session XP ceiling: `earned = least(1000, ...)`.

3. **Daily Quests & Streaks Logic**:
   - `supabase/migrations/20261026000200_authoritative_progression.sql:192-214` defines `sync_daily_data()`:
     - Timezone conversion: `day = (now() AT TIME ZONE p.timezone)::date;`
     - Unique partial index: `CREATE UNIQUE INDEX IF NOT EXISTS quest_instances_unique_day ON public.quest_instances(user_id, quest_date) WHERE quest_date IS NOT NULL;`
     - Expiration: `((day + 1)::timestamp AT TIME ZONE p.timezone)`
   - Streak calculation in `complete_workout` (`:244`):
     `streak = CASE WHEN prev_date=day THEN streak WHEN prev_date=day-1 THEN streak+1 WHEN prev_date>day THEN streak ELSE 1 END;`
   - Missed day reset in `sync_daily_data` (`:199`) and `get_user_stats` (`:318`).

4. **Edge Functions Health & Test Coverage**:
   - `supabase/functions/ai-coach/service.ts:1-78` implements token verification, 20 req/day quota check via `consume_coach_request()`, HTTP 503 fallback if `COACH_API_URL`, `COACH_API_KEY`, or `COACH_MODEL` are missing, 20KB payload limits, 8-message history limits, and upstream error sanitization.
   - `supabase/functions/_shared/http.ts:1-48` provides `rpcHandler` with 16KB payload limits, CORS, and error mapping.
   - Proxy functions `calculate-xp`, `get-user-stats`, `initialize-user`, `switch-class`, `sync-daily-data` proxy database RPCs without business logic.

5. **Test Harness Commands and Verbatim Outputs**:
   - `npm.cmd test` in `tools/db-tests`:
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
   - `npm.cmd run test:edge` in `tools/db-tests`:
     ```
     ok | 14 passed | 0 failed (2s)
     ```
   - `npm.cmd run check:edge` in `tools/db-tests`:
     Exited with code 0.
   - `node adversarial-anti-cheat.mjs` in `tools/db-tests`:
     ```
     ALL ADVERSARIAL TESTS PASSED: 32/32 units
     ```
   - `node adversarial-coach.mjs` in `tools/db-tests`:
     ```
     ALL ADVERSARIAL EDGE TESTS PASSED: 15/15 units
     ```

---

## 2. Logic Chain

1. **Exercise Schema & Seeding (Requirement R4)**:
   - Observations show that `public.exercises` contains only 22 exercises and lacks `slug`, `name_vi`, `name_en`, `movement_pattern`, `secondary_muscles`, `difficulty`, `form_cues`, and `common_mistakes`.
   - Because existing stored procedures (`sync_daily_data`, `complete_workout`, `switch_class`, `get_user_stats`) directly query `category`, `equipment`, `force_type`, and `name`, adding columns must be strictly additive.
   - Therefore, Agent D must create an additive migration `20261027000100_exercise_catalog_metadata.sql` and author `supabase/seed_exercises.sql` containing 120–200 exercises with `ON CONFLICT (slug) DO UPDATE`. `supabase/config.toml` must be updated to load both seeds.

2. **Authoritative Progression & XP (Requirement R3)**:
   - Observations show that `complete_workout` locks `public.users` and `public.workouts` for the transaction duration, writes outcomes to `public.workout_rewards`, and re-checks `workout_rewards` at entry.
   - Therefore, race conditions, duplicate submissions, and double-crediting of XP are prevented at the database layer.
   - Observations confirm that anti-cheat pace limit clamping restricts submissions faster than 4 sets/minute to 10 XP.

3. **Daily Quests & Streaks (Requirement R3)**:
   - Observations show that `sync_daily_data` resolves `now() AT TIME ZONE p.timezone` and enforces one unique quest per calendar day via `quest_instances_unique_day`.
   - `complete_workout` checks set reps and weights against `prescribed_config` before marking quests completed.
   - Consecutive days increment streak; same-day workouts preserve streak; missed days reset streak.
   - Therefore, streak and quest progression conform to R3 without server-side defects.

4. **Edge Functions & Security (Requirement R3 & R6)**:
   - Observations show that `ai-coach` enforces a 20 req/day quota via `consume_coach_request()` and returns HTTP 503 `{ code: "coach_unconfigured" }` when unconfigured.
   - All 14 Deno tests pass; all 15 adversarial coach tests pass.
   - Therefore, the Edge Function tier is fully functional, secure, and ready for integration.

---

## 3. Caveats

1. **Test Environment Scope**: Verification tests were run using `@electric-sql/pglite` (embedded PostgreSQL 17.5). True multi-session concurrency, external GoTrue email delivery, and cloud edge runtime require a running local Supabase stack (`supabase start`) or staging project.
2. **Column Naming Continuity**: When adding `name_vi` and `name_en`, the existing `name` column must continue to be populated so existing Flutter repositories and RPC queries that sort by `name` do not fail.
3. **Pluralization of Equipment**: Current `seed.sql` uses `'Cables'`. The R4 prompt mentions `'cable'`. New seed entries and database checks should normalize or accept both forms.

---

## 4. Conclusion

The GymLvl backend architecture is robust, secure, and rigorously tested:
- Progression, streaks, and quest mechanics in PostgreSQL are already authoritative, atomic, and protected against replay and tampering.
- The Edge Functions tier is healthy, tested, and secure.
- The primary implementation gap is **Requirement R4 (Exercise Catalog Expansion)**:
  - Additive migration for exercise metadata fields (`slug`, `name_vi`, `name_en`, `secondary_muscles`, `movement_pattern`, `difficulty`, `form_cues`, `common_mistakes`).
  - Creation of `supabase/seed_exercises.sql` expanding the library from 22 to 120–200 exercises.
  - Adding `seed_exercises.sql` to `supabase/config.toml` so it runs in `npm.cmd test`.
  - Updating the Flutter `Exercise` model and UI widgets to render the enriched metadata.

---

## 5. Verification Method

To independently verify these observations and conclusions, execute the following commands from `d:\Projects\gymlvl\tools\db-tests`:

1. **PostgreSQL Migration, Seed Replay & Progression Regression**:
   ```powershell
   npm.cmd test
   ```
   *Expected outcome*: Passes all 7 SQL units against PostgreSQL 17.5 (`run.mjs`).

2. **Deno Edge Function Unit Tests**:
   ```powershell
   npm.cmd run test:edge
   ```
   *Expected outcome*: Passes all 14 Deno unit tests (`edge-tests.mjs`).

3. **Deno Edge Function Typecheck**:
   ```powershell
   npm.cmd run check:edge
   ```
   *Expected outcome*: Exits with code 0 with zero type errors.

4. **Adversarial Anti-Cheat & Security Harness**:
   ```powershell
   node adversarial-anti-cheat.mjs
   ```
   *Expected outcome*: Passes all 32/32 adversarial security assertions.

5. **Adversarial AI Coach Harness**:
   ```powershell
   node adversarial-coach.mjs
   ```
   *Expected outcome*: Passes all 15/15 adversarial edge security assertions.

### Invalidation Conditions:
- If `npm.cmd test` fails on seed replay or SQL regressions.
- If any direct client `UPDATE public.users SET total_xp = ...` succeeds under the `authenticated` role.
- If repeated calls to `complete_workout` with the same `p_workout_id` produce duplicate XP or extra `xp_logs` entries.
