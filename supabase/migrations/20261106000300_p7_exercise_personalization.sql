-- Additive Database Migration: P7 Exercise Personalization
-- Milestone P7: Remaining OpenGym Parity & Optional Integrations
-- Safe, additive migration preserving all existing user records and history.
--
-- Adds:
--   * public.exercises.user_id / is_archived  — user-owned custom exercises live in
--     the same table as the catalogue (source = 'user'), so the existing
--     workout_exercises.exercise_id FK keeps working and history is preserved.
--   * public.exercise_favourites              — owner-scoped favourite toggle.
--   * public.exercise_aliases                 — owner-scoped alias -> canonical exercise.
--
-- No existing columns are dropped, renamed, or truncated. No existing UUIDs or
-- workout-history references are affected. No RLS is weakened.
-- Production is NOT applied by this migration; it is locally testable only.

-- 1. exercises: owner + soft-delete for custom exercises (additive, nullable-safe)
ALTER TABLE public.exercises
  ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS is_archived BOOLEAN NOT NULL DEFAULT FALSE;

-- Backfill: curated / imported rows have no owner and are not archived.
UPDATE public.exercises SET is_archived = FALSE WHERE is_archived IS NULL;

-- Indexes for owner-scoped lookups and archive filtering.
CREATE INDEX IF NOT EXISTS idx_exercises_user_id ON public.exercises(user_id);
CREATE INDEX IF NOT EXISTS idx_exercises_user_archived ON public.exercises(user_id, is_archived);

-- 2. Refresh exercises RLS:
--    Authenticated users see every catalogue row (user_id IS NULL) plus their own
--    custom exercises. Other users' custom exercises are NOT visible (owner isolation).
DROP POLICY IF EXISTS "Anyone can view exercises" ON public.exercises;
CREATE POLICY "Anyone can view exercises" ON public.exercises FOR SELECT
  USING (user_id IS NULL OR user_id = auth.uid());

-- Owner may insert only their own custom exercises (source = 'user').
DROP POLICY IF EXISTS "Users can insert own custom exercises" ON public.exercises;
CREATE POLICY "Users can insert own custom exercises" ON public.exercises FOR INSERT
  WITH CHECK (user_id = auth.uid() AND source = 'user');

-- Owner may update only their own custom exercises; cannot retarget ownership/source.
DROP POLICY IF EXISTS "Users can update own custom exercises" ON public.exercises;
CREATE POLICY "Users can update own custom exercises" ON public.exercises FOR UPDATE
  USING (user_id = auth.uid() AND source = 'user')
  WITH CHECK (user_id = auth.uid() AND source = 'user');

-- Owner may delete only their own custom exercises. The app prefers archive
-- (soft-delete) when history exists; hard delete only for history-free customs.
DROP POLICY IF EXISTS "Users can delete own custom exercises" ON public.exercises;
CREATE POLICY "Users can delete own custom exercises" ON public.exercises FOR DELETE
  USING (user_id = auth.uid() AND source = 'user');

-- 3. exercise_favourites — owner-scoped favourite toggle (does not modify catalogue rows).
CREATE TABLE IF NOT EXISTS public.exercise_favourites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  exercise_id UUID REFERENCES public.exercises(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE (user_id, exercise_id)
);

ALTER TABLE public.exercise_favourites ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own exercise favourites" ON public.exercise_favourites;
CREATE POLICY "Users can view own exercise favourites" ON public.exercise_favourites FOR SELECT
  USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can insert own exercise favourites" ON public.exercise_favourites;
CREATE POLICY "Users can insert own exercise favourites" ON public.exercise_favourites FOR INSERT
  WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can delete own exercise favourites" ON public.exercise_favourites;
CREATE POLICY "Users can delete own exercise favourites" ON public.exercise_favourites FOR DELETE
  USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_exercise_favourites_user_id ON public.exercise_favourites(user_id);
CREATE INDEX IF NOT EXISTS idx_exercise_favourites_exercise_id ON public.exercise_favourites(exercise_id);

-- 4. exercise_aliases — owner-scoped alias -> canonical exercise (unique alias per user).
CREATE TABLE IF NOT EXISTS public.exercise_aliases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  exercise_id UUID REFERENCES public.exercises(id) ON DELETE CASCADE NOT NULL,
  alias TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE (user_id, alias)
);

ALTER TABLE public.exercise_aliases ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own exercise aliases" ON public.exercise_aliases;
CREATE POLICY "Users can view own exercise aliases" ON public.exercise_aliases FOR SELECT
  USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can insert own exercise aliases" ON public.exercise_aliases;
CREATE POLICY "Users can insert own exercise aliases" ON public.exercise_aliases FOR INSERT
  WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can update own exercise aliases" ON public.exercise_aliases;
CREATE POLICY "Users can update own exercise aliases" ON public.exercise_aliases FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can delete own exercise aliases" ON public.exercise_aliases;
CREATE POLICY "Users can delete own exercise aliases" ON public.exercise_aliases FOR DELETE
  USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_exercise_aliases_user_id ON public.exercise_aliases(user_id);
CREATE INDEX IF NOT EXISTS idx_exercise_aliases_exercise_id ON public.exercise_aliases(exercise_id);

-- 5. Grants for the authenticated (client) role, gated by the owner-scoped RLS
--    policies above. Catalogue rows stay read-only for clients; only a user's own
--    custom exercises (source = 'user') can be inserted/updated/deleted.
GRANT SELECT, INSERT, UPDATE, DELETE ON public.exercises TO authenticated;
GRANT SELECT, INSERT, DELETE ON public.exercise_favourites TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.exercise_aliases TO authenticated;

-- 6. Comments documenting the ownership / provenance contract.
COMMENT ON COLUMN public.exercises.user_id IS
  'Owner of a user-created custom exercise (source = user). NULL for curated / imported catalogue exercises.';
COMMENT ON COLUMN public.exercises.is_archived IS
  'Soft-delete flag for custom exercises. Historical workout_exercises references remain valid; archive instead of hard delete.';
COMMENT ON TABLE public.exercise_favourites IS
  'Owner-scoped exercise favourites. Does not modify public.exercises catalogue rows.';
COMMENT ON TABLE public.exercise_aliases IS
  'Owner-scoped alias -> canonical exercise mapping. Canonical exercise identity and history are preserved.';
