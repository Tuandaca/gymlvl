-- P4 Gate 2: General body measurements (additive).
-- Adds a normalized body_measurements table supporting several coherent
-- body metrics (body weight, body fat percentage, chest, waist, hips,
-- upper arm, thigh) with explicit units and owner-scoped RLS.
--
-- Additive only: CREATE TABLE IF NOT EXISTS. No existing tables/columns
-- dropped, renamed, or truncated. The existing public.bodyweight_measurements
-- table (M5) and public.profiles.weight_kg are left untouched, preserving
-- bodyweight data/API compatibility. No RLS or grant changes beyond the new
-- table's own owner-only policies.
--
-- Rollback path: DROP TABLE IF EXISTS public.body_measurements (and its
-- trigger/index). Dropping the table does not touch user data in other tables.

-- 1. Normalized body measurements: one row per measurement.
CREATE TABLE IF NOT EXISTS public.body_measurements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  measurement_type TEXT NOT NULL
    CHECK (measurement_type IN (
      'body_weight', 'body_fat_percentage', 'chest', 'waist', 'hips',
      'upper_arm', 'thigh'
    )),
  value DECIMAL NOT NULL CHECK (value > 0 AND value <= 1000),
  unit TEXT NOT NULL CHECK (unit IN ('kg', 'cm', 'percent')),
  measured_at TIMESTAMP WITH TIME ZONE NOT NULL,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. RLS: each user only sees and manages their own measurements.
ALTER TABLE public.body_measurements ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own body measurements"
  ON public.body_measurements;
CREATE POLICY "Users can view own body measurements"
  ON public.body_measurements FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own body measurements"
  ON public.body_measurements;
CREATE POLICY "Users can insert own body measurements"
  ON public.body_measurements FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own body measurements"
  ON public.body_measurements;
CREATE POLICY "Users can update own body measurements"
  ON public.body_measurements FOR UPDATE
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own body measurements"
  ON public.body_measurements;
CREATE POLICY "Users can delete own body measurements"
  ON public.body_measurements FOR DELETE
  USING (auth.uid() = user_id);

-- 3. Trigger to keep updated_at current.
DROP TRIGGER IF EXISTS update_body_measurements_modtime
  ON public.body_measurements;
CREATE TRIGGER update_body_measurements_modtime
BEFORE UPDATE ON public.body_measurements
FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

-- 4. Index for measurement trends by user over time.
CREATE INDEX IF NOT EXISTS idx_body_measurements_user_type_measured
  ON public.body_measurements(user_id, measurement_type, measured_at);

COMMENT ON TABLE public.body_measurements IS
  'P4 general body measurements. Normalized records: measurement_type + value + unit. '
  'Existing bodyweight (profiles.weight_kg / bodyweight_measurements) is unchanged.';
COMMENT ON COLUMN public.body_measurements.measurement_type IS
  'Canonical body metric: body_weight, body_fat_percentage, chest, waist, hips, upper_arm, thigh.';
COMMENT ON COLUMN public.body_measurements.value IS
  'Numeric value in [unit]. Never silently converted; unit stored explicitly.';
COMMENT ON COLUMN public.body_measurements.unit IS
  'Explicit unit: kg, cm, or percent. Matches measurement_type canonically.';
