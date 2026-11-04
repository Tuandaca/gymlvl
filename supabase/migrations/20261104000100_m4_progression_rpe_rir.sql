-- M4 progression: RPE/RIR columns on public.workout_sets
-- Additive, local/test only; production activation remains gated.
-- No existing rows modified, no columns dropped/renamed, no grants weakened,
-- no RLS weakened. Backward compatible (nullable).

ALTER TABLE public.workout_sets
  ADD COLUMN IF NOT EXISTS rpe INTEGER;

ALTER TABLE public.workout_sets
  ADD COLUMN IF NOT EXISTS rir INTEGER;

ALTER TABLE public.workout_sets
  ADD CONSTRAINT workout_sets_rpe_range
    CHECK (rpe IS NULL OR rpe BETWEEN 1 AND 10);

ALTER TABLE public.workout_sets
  ADD CONSTRAINT workout_sets_rir_range
    CHECK (rir IS NULL OR rir BETWEEN 0 AND 10);

-- RLS already enabled on workout_sets (baseline). Re-affirming without weakening.
ALTER TABLE public.workout_sets ENABLE ROW LEVEL SECURITY;

COMMENT ON COLUMN public.workout_sets.rpe IS 'Rate of Perceived Exertion, 1-10. Nullable.';
COMMENT ON COLUMN public.workout_sets.rir IS 'Reps In Reserve, 0-10. Nullable.';
