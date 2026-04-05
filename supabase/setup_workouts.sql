-- ==============================================================================
-- PHASE 2.2: WORKOUT LOGGING SCHEMA
-- ==============================================================================

-- ==============================================================================
-- 1. TẠO BẢNG PUBLIC.WORKOUTS (Buổi tập của User)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.workouts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),
  duration_seconds INTEGER DEFAULT 0,
  notes TEXT,
  started_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ==============================================================================
-- 2. TẠO BẢNG PUBLIC.WORKOUT_EXERCISES (Bài tập trong buổi tập)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.workout_exercises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workout_id UUID REFERENCES public.workouts(id) ON DELETE CASCADE NOT NULL,
  exercise_id UUID REFERENCES public.exercises(id) ON DELETE CASCADE NOT NULL,
  order_index INTEGER NOT NULL DEFAULT 0,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ==============================================================================
-- 3. TẠO BẢNG PUBLIC.WORKOUT_SETS (Sets trong một bài tập)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.workout_sets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workout_exercise_id UUID REFERENCES public.workout_exercises(id) ON DELETE CASCADE NOT NULL,
  set_number INTEGER NOT NULL DEFAULT 1,
  reps INTEGER NOT NULL DEFAULT 0,
  weight_kg DECIMAL NOT NULL DEFAULT 0,
  is_completed BOOLEAN NOT NULL DEFAULT false,
  rest_seconds INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ==============================================================================
-- 4. ROW LEVEL SECURITY (RLS) — WORKOUTS
-- ==============================================================================

ALTER TABLE public.workouts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own workouts"
ON public.workouts FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own workouts"
ON public.workouts FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own workouts"
ON public.workouts FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own workouts"
ON public.workouts FOR DELETE
USING (auth.uid() = user_id);

-- ==============================================================================
-- 5. ROW LEVEL SECURITY (RLS) — WORKOUT_EXERCISES
-- ==============================================================================

ALTER TABLE public.workout_exercises ENABLE ROW LEVEL SECURITY;

-- User chỉ thao tác được với exercises thuộc workout của chính mình
CREATE POLICY "Users can view own workout_exercises"
ON public.workout_exercises FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.workouts w
    WHERE w.id = workout_id AND w.user_id = auth.uid()
  )
);

CREATE POLICY "Users can insert own workout_exercises"
ON public.workout_exercises FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.workouts w
    WHERE w.id = workout_id AND w.user_id = auth.uid()
  )
);

CREATE POLICY "Users can update own workout_exercises"
ON public.workout_exercises FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.workouts w
    WHERE w.id = workout_id AND w.user_id = auth.uid()
  )
);

CREATE POLICY "Users can delete own workout_exercises"
ON public.workout_exercises FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM public.workouts w
    WHERE w.id = workout_id AND w.user_id = auth.uid()
  )
);

-- ==============================================================================
-- 6. ROW LEVEL SECURITY (RLS) — WORKOUT_SETS
-- ==============================================================================

ALTER TABLE public.workout_sets ENABLE ROW LEVEL SECURITY;

-- User chỉ thao tác được với sets thuộc workout_exercise → workout của chính mình
CREATE POLICY "Users can view own workout_sets"
ON public.workout_sets FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.workout_exercises we
    JOIN public.workouts w ON w.id = we.workout_id
    WHERE we.id = workout_exercise_id AND w.user_id = auth.uid()
  )
);

CREATE POLICY "Users can insert own workout_sets"
ON public.workout_sets FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.workout_exercises we
    JOIN public.workouts w ON w.id = we.workout_id
    WHERE we.id = workout_exercise_id AND w.user_id = auth.uid()
  )
);

CREATE POLICY "Users can update own workout_sets"
ON public.workout_sets FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.workout_exercises we
    JOIN public.workouts w ON w.id = we.workout_id
    WHERE we.id = workout_exercise_id AND w.user_id = auth.uid()
  )
);

CREATE POLICY "Users can delete own workout_sets"
ON public.workout_sets FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM public.workout_exercises we
    JOIN public.workouts w ON w.id = we.workout_id
    WHERE we.id = workout_exercise_id AND w.user_id = auth.uid()
  )
);

-- ==============================================================================
-- 7. TRIGGER CẬP NHẬT UPDATED_AT CHO WORKOUTS
-- ==============================================================================

DROP TRIGGER IF EXISTS update_workouts_modtime ON public.workouts;
CREATE TRIGGER update_workouts_modtime
BEFORE UPDATE ON public.workouts
FOR EACH ROW EXECUTE PROCEDURE update_modified_column();

-- ==============================================================================
-- 8. INDEXES CHO PERFORMANCE
-- ==============================================================================

CREATE INDEX IF NOT EXISTS idx_workouts_user_id ON public.workouts(user_id);
CREATE INDEX IF NOT EXISTS idx_workouts_status ON public.workouts(status);
CREATE INDEX IF NOT EXISTS idx_workouts_user_status ON public.workouts(user_id, status);
CREATE INDEX IF NOT EXISTS idx_workout_exercises_workout_id ON public.workout_exercises(workout_id);
CREATE INDEX IF NOT EXISTS idx_workout_sets_workout_exercise_id ON public.workout_sets(workout_exercise_id);

-- Hoàn tất Phase 2.2 Schema!
