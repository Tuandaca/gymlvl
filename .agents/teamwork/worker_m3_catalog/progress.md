# Progress — Worker M3 Catalog

Last visited: 2026-10-27T09:25:00Z
Status: Completed

## Completed Work
1. **Additive Database Migration**:
   - Created `supabase/migrations/20261027000100_exercise_catalog_metadata.sql`:
     - Added metadata columns to `public.exercises`: `slug UNIQUE`, `name_vi`, `name_en`, `secondary_muscles`, `movement_pattern`, `difficulty`, `form_cues`, `common_mistakes`, `alternative_exercise_slugs`.
     - Added validation checks on `movement_pattern` (`push`, `pull`, `squat`, `hinge`, `carry`, `lunge`, `isolation`) and `difficulty` (`beginner`, `intermediate`, `advanced`).
     - Added trigger `trigger_set_exercise_slug` to auto-assign slugs and `name_en` for any legacy/unslotted inserts.
     - Backfilled existing 22 exercises with accurate Vietnamese names, slugs, movement patterns, secondary muscles, and cues.
     - Added `duration_seconds integer DEFAULT 0` to `public.workout_sets`.
     - Updated check constraint `workout_sets_valid_values` on `public.workout_sets` to allow static holds / duration exercises: `(NOT is_completed OR reps > 0 OR duration_seconds > 0)`.
2. **Curated Exercise Catalog Expansion (150 Exercises)**:
   - Authored `supabase/seed_exercises.sql` containing 150 high-quality exercises:
     - 24 Chest, 26 Back, 28 Legs, 22 Shoulders, 24 Arms, 14 Core, 6 Full Body, 6 Cardio.
     - Complete dual Vietnamese/English naming, movement patterns, equipment, difficulty, form cues, common mistakes, and alternative slugs.
     - Fully idempotent upsert using `ON CONFLICT (slug) DO UPDATE SET ...`.
3. **Configuration & Test Runner Integration**:
   - Updated `supabase/config.toml` `sql_paths = ["./seed.sql", "./seed_exercises.sql"]`.
   - Updated `tools/db-tests/run.mjs` to verify:
     - Exercise count is between 120 and 200 (verified: exactly 150).
     - Exercise catalog metadata integrity (0 null/empty fields).
     - `workout_sets.duration_seconds` column presence.
     - Static hold (`reps = 0, duration_seconds = 60, is_completed = true`) acceptance and invalid rejection.
4. **Verification**:
   - `npm.cmd test` in `tools/db-tests/` passes 10/10 SQL units against PostgreSQL 17.5.
   - `node adversarial-anti-cheat.mjs` passes 32/32 units.
   - `npm.cmd run test:edge` passes 14/14 units.
