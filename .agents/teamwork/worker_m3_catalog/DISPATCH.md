## 2026-10-27T09:08:01Z
You are Agent D & C (Exercise Catalog & Schema Specialist) for GymLvl.
Your working directory is: d:\Projects\gymlvl\.agents\teamwork\worker_m3_catalog
Project root is: d:\Projects\gymlvl

MANDATORY FIRST STEP:
Read the authoritative request file: d:\Projects\gymlvl\.agents\teamwork\ORIGINAL_REQUEST.md (under section `## 2026-10-27T08:45:05Z`).
Read PROJECT.md at project root: d:\Projects\gymlvl\PROJECT.md
Read the survey explorer handoff: d:\Projects\gymlvl\.agents\teamwork\explorer_survey_backend_2\handoff.md
Read the survey explorer report: d:\Projects\gymlvl\.agents\teamwork\explorer_survey_backend_2\report.md
Recommended domain skill: d:\Projects\gymlvl\.agent\skills\database-migration\SKILL.md

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

EXCLUSIVE WRITE SCOPE:
- `supabase/migrations/20261027000100_exercise_catalog_metadata.sql`
- `supabase/seed_exercises.sql`
- `supabase/config.toml`
- `tools/db-tests/run.mjs`
DO NOT write outside these files.

Mission (Milestone M3 — Exercise Catalog Schema & Seed Data Expansion):
1. Additive Database Migration:
   - Create `supabase/migrations/20261027000100_exercise_catalog_metadata.sql`:
     - Add columns to `public.exercises`:
       - `slug text UNIQUE`
       - `name_vi text NOT NULL DEFAULT ''`
       - `name_en text NOT NULL DEFAULT ''`
       - `secondary_muscles text[] DEFAULT '{}'`
       - `movement_pattern text` (e.g. `push`, `pull`, `squat`, `hinge`, `carry`, `lunge`, `isolation`)
       - `difficulty text` (`beginner`, `intermediate`, `advanced`)
       - `form_cues text[] DEFAULT '{}'`
       - `common_mistakes text[] DEFAULT '{}'`
       - `alternative_exercise_slugs text[] DEFAULT '{}'`
     - Backfill existing 22 exercises with slugs, Vietnamese names, and movement patterns so no NULLs or broken references remain.
     - Add `duration_seconds integer DEFAULT 0` to `public.workout_sets`.
     - Update check constraint on `public.workout_sets` to allow static holds / duration exercises:
       `(NOT is_completed OR reps > 0 OR duration_seconds > 0)`.
     - Ensure existing columns (`name`, `category`, `equipment`, `force_type`, `mechanic`) remain fully populated and functional.
2. Curated Exercise Catalog Expansion (120–200 Exercises):
   - Author `supabase/seed_exercises.sql`:
     - Expand exercise catalog to between 120 and 200 high-quality exercises (e.g. 150 exercises).
     - Cover major muscle groups: Chest, Back, Legs, Shoulders, Arms, Core, Full Body, Cardio.
     - Cover equipment types: Barbell, Dumbbell, Cable, Machine, Bodyweight, Resistance Band.
     - Cover movement patterns: Push, Pull, Squat, Hinge, Carry, Lunge, Isolation.
     - Each exercise MUST have:
       - `slug` (unique string, e.g. `incline-dumbbell-bench-press`)
       - `name` (English name for backwards compatibility)
       - `name_vi` (Accurate Vietnamese name, e.g. `Đẩy Ngực Trên Với Tạ Đơn`)
       - `name_en` (Accurate English name)
       - `category`, `equipment`, `force_type`, `mechanic`, `difficulty`
       - `secondary_muscles` (e.g. `['Triceps', 'Anterior Deltoids']`)
       - `form_cues` (practical setup & execution cues)
       - `common_mistakes` (common pitfalls to avoid)
       - `alternative_exercise_slugs`
     - Use idempotent SQL: `INSERT INTO public.exercises (...) VALUES (...) ON CONFLICT (slug) DO UPDATE SET ...;`
3. Configuration & Test Runner Integration:
   - Update `supabase/config.toml` `sql_paths` to include `./seed_exercises.sql`.
   - Update `tools/db-tests/run.mjs` to execute `20261027000100_exercise_catalog_metadata.sql` and `seed_exercises.sql` in the PostgreSQL 17 test harness.
4. Verification:
   - Run `npm.cmd test` in `tools/db-tests/`.
   - Ensure all 7 SQL units + new migration and seed replay pass with 0 errors.
   - Verify exercise count is between 120 and 200 with `SELECT count(*) FROM public.exercises;`.
   - Document exact count, verification commands, and test outputs in `handoff.md`.

Deliverables:
- Write progress updates to: `d:\Projects\gymlvl\.agents\teamwork\worker_m3_catalog\progress.md`
- Write completion handoff to: `d:\Projects\gymlvl\.agents\teamwork\worker_m3_catalog\handoff.md`
- Notify orchestrator via send_message when complete.
