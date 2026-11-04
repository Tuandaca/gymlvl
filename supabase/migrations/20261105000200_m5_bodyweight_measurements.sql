-- M5 bodyweight: additive weigh-in history table for the bodyweight trend chart.
-- Additive only: CREATE TABLE IF NOT EXISTS. No existing tables/columns
-- dropped, renamed, or truncated. workout_sets.weight_kg remains external /
-- additional load only; profiles.weight_kg remains the authoritative body-mass
-- source. No RLS or grant changes beyond the new table's own policies.
-- Backward compatible with M3/M4 and all existing workout modes.
--
-- Rollback path: DROP TABLE IF EXISTS public.bodyweight_measurements (and its
-- trigger/index). Dropping the table does not touch user data in other tables.

-- 1. Weigh-in history: one row per body-mass measurement.
CREATE TABLE IF NOT EXISTS public.bodyweight_measurements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  weight_kg DECIMAL NOT NULL CHECK (weight_kg > 0 AND weight_kg <= 500),
  measured_at TIMESTAMP WITH TIME ZONE NOT NULL,
  source TEXT NOT NULL DEFAULT 'manual_weigh_in'
    CHECK (source IN ('profile_baseline', 'manual_weigh_in', 'scale')),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. RLS: each user only sees and manages their own measurements.
ALTER TABLE public.bodyweight_measurements ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own bodyweight measurements"
  ON public.bodyweight_measurements;
CREATE POLICY "Users can view own bodyweight measurements"
  ON public.bodyweight_measurements FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own bodyweight measurements"
  ON public.bodyweight_measurements;
CREATE POLICY "Users can insert own bodyweight measurements"
  ON public.bodyweight_measurements FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own bodyweight measurements"
  ON public.bodyweight_measurements;
CREATE POLICY "Users can update own bodyweight measurements"
  ON public.bodyweight_measurements FOR UPDATE
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own bodyweight measurements"
  ON public.bodyweight_measurements;
CREATE POLICY "Users can delete own bodyweight measurements"
  ON public.bodyweight_measurements FOR DELETE
  USING (auth.uid() = user_id);

-- 3. Trigger to keep updated_at current.
DROP TRIGGER IF EXISTS update_bodyweight_measurements_modtime
  ON public.bodyweight_measurements;
CREATE TRIGGER update_bodyweight_measurements_modtime
BEFORE UPDATE ON public.bodyweight_measurements
FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

-- 4. Index for trend queries by user over time.
CREATE INDEX IF NOT EXISTS idx_bodyweight_measurements_user_measured
  ON public.bodyweight_measurements(user_id, measured_at);

COMMENT ON TABLE public.bodyweight_measurements IS
  'M5 bodyweight weigh-in history. Body mass source is profiles.weight_kg (baseline); workout_sets.weight_kg is external/additional load only.';
COMMENT ON COLUMN public.bodyweight_measurements.weight_kg IS
  'Body mass in kg at measured_at. Never workout set load.';
