-- Additive Database Migration: Exercise Catalogue Provenance (P1)
-- Milestone P1: OpenGym Parity Baseline + Legal-Safe Exercise Catalogue
-- Safe, additive migration preserving all existing user records and history.
--
-- Adds provenance columns (source, external_id, source_revision) to
-- public.exercises so the legal-safe exercisedb import can be traced to its
-- source and revision. Existing curated GymLvl exercises are classified as
-- source = 'gymlvl_curated' with external_id = NULL. Imported exercisedb
-- exercises use source = 'exercisedb', external_id = OpenGym exercise id.
--
-- No existing columns are dropped, renamed, or truncated. No existing UUIDs
-- or workout-history references are affected. No RLS is weakened.
-- Production is NOT applied by this migration; it is locally testable only.

-- 1. Add provenance columns (additive, nullable-safe defaults)
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS source text NOT NULL DEFAULT 'gymlvl_curated';
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS external_id text;
ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS source_revision text;

-- 2. Unique constraint on (source, external_id) for imported exercises.
--    PostgreSQL treats NULL as distinct in unique constraints, so curated
--    exercises (all external_id NULL) coexist without conflict. Imported
--    exercisedb rows (external_id set) are unique per (source, external_id),
--    which makes the import idempotent via ON CONFLICT.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'exercises_source_external_id_key'
  ) THEN
    ALTER TABLE public.exercises
      ADD CONSTRAINT exercises_source_external_id_key UNIQUE (source, external_id);
  END IF;
END $$;

-- 3. Backfill existing curated records with explicit provenance.
UPDATE public.exercises
SET source = 'gymlvl_curated',
    source_revision = NULL
WHERE source IS NULL OR source = '';

-- 4. Index to support provenance lookups and import dedup queries.
CREATE INDEX IF NOT EXISTS idx_exercises_source ON public.exercises (source);
CREATE INDEX IF NOT EXISTS idx_exercises_external_id ON public.exercises (external_id) WHERE external_id IS NOT NULL;

-- 5. Comment documenting the provenance contract.
COMMENT ON COLUMN public.exercises.source IS 'Origin of the exercise record: gymlvl_curated (existing curated) or exercisedb (MIT dataset import).';
COMMENT ON COLUMN public.exercises.external_id IS 'Stable identity in the source system. OpenGym exercise id for exercisedb imports; NULL for curated GymLvl exercises.';
COMMENT ON COLUMN public.exercises.source_revision IS 'Pinned source revision SHA (e.g. OpenGym catalogue SHA) from which the record was imported. NULL for curated records.';
