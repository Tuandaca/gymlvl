-- P2 Migration: Routine & Planning Foundation
-- Milestone P2: OpenGym Parity - Routine & Planning
-- Safe, additive migration preserving all existing user records and history.

-- ==============================================================================
-- 1. ROUTINES (Templates)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.routines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  emoji TEXT,
  is_archived BOOLEAN NOT NULL DEFAULT FALSE,
  version INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==============================================================================
-- 2. ROUTINE EXERCISES (Template configuration per exercise slot)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.routine_exercises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  routine_id UUID NOT NULL REFERENCES public.routines(id) ON DELETE CASCADE,
  exercise_id UUID NOT NULL REFERENCES public.exercises(id) ON DELETE RESTRICT,
  order_index INTEGER NOT NULL DEFAULT 0,
  sets INTEGER NOT NULL DEFAULT 3,
  reps INTEGER NOT NULL DEFAULT 10,
  reps_min INTEGER,
  weight_kg DECIMAL NOT NULL DEFAULT 0,
  duration_seconds INTEGER,
  rest_seconds INTEGER,
  rpe_target INTEGER CHECK (rpe_target IS NULL OR (rpe_target BETWEEN 1 AND 10)),
  rir_target INTEGER CHECK (rir_target IS NULL OR (rir_target BETWEEN 0 AND 10)),
  warmup_sets INTEGER,
  mode TEXT NOT NULL CHECK (mode IN ('reps-weight', 'bodyweight', 'timed', 'cardio')),
  superset_group_id UUID,
  superset_position INTEGER,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (routine_id, id)
);

-- ==============================================================================
-- 3. ROUTINE SUPERSET GROUPS
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.routine_superset_groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  routine_id UUID NOT NULL REFERENCES public.routines(id) ON DELETE CASCADE,
  position INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (routine_id, position)
);

-- Add superset_group_id foreign key
ALTER TABLE public.routine_exercises
  ADD CONSTRAINT fk_routine_exercises_superset_group
  FOREIGN KEY (superset_group_id)
  REFERENCES public.routine_superset_groups(id) ON DELETE SET NULL;

-- Superset position constraints
ALTER TABLE public.routine_exercises
  ADD CONSTRAINT routine_exercises_superset_position_pair
    CHECK ((superset_group_id IS NULL) = (superset_position IS NULL)),
  ADD CONSTRAINT routine_exercises_superset_position_nonnegative
    CHECK (superset_position IS NULL OR superset_position >= 0);

-- Unique index for superset position within group
CREATE UNIQUE INDEX IF NOT EXISTS routine_exercises_superset_position_unique
  ON public.routine_exercises(routine_id, superset_group_id, superset_position)
  WHERE superset_group_id IS NOT NULL;

-- ==============================================================================
-- 4. ROUTINE SCHEDULES (Weekly planning & Rotation)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.routine_schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  routine_id UUID NOT NULL REFERENCES public.routines(id) ON DELETE CASCADE,
  schedule_mode TEXT NOT NULL CHECK (schedule_mode IN ('fixed_week', 'rotation')),
  weekday INTEGER CHECK (weekday BETWEEN 1 AND 7), -- 1=Monday ... 7=Sunday
  rotation_position INTEGER, -- For rotation mode
  superset_group_id UUID, -- For superset groups in rotation
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (routine_id, schedule_mode, weekday, rotation_position)
);

-- ==============================================================================
-- 5. PLANNED WORKOUTS (Concrete scheduled occurrences)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.planned_workouts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  routine_id UUID NOT NULL REFERENCES public.routines(id) ON DELETE RESTRICT,
  routine_name TEXT NOT NULL,
  routine_snapshot JSONB NOT NULL, -- Immutable snapshot of routine at scheduling time
  scheduled_date DATE NOT NULL, -- Local date (user timezone)
  status TEXT NOT NULL DEFAULT 'planned' CHECK (status IN ('planned', 'started', 'completed', 'cancelled')),
  workout_id UUID REFERENCES public.workouts(id) ON DELETE SET NULL, -- Link to actual workout when started
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, scheduled_date, routine_id)
);

-- ==============================================================================
-- 6. RLS POLICIES
-- ==============================================================================

-- Routines
ALTER TABLE public.routines ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own routines" ON public.routines;
CREATE POLICY "Users can view own routines" ON public.routines FOR SELECT
USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can insert own routines" ON public.routines;
CREATE POLICY "Users can insert own routines" ON public.routines FOR INSERT
WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can update own routines" ON public.routines;
CREATE POLICY "Users can update own routines" ON public.routines FOR UPDATE
USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can delete own routines" ON public.routines;
CREATE POLICY "Users can delete own routines" ON public.routines FOR DELETE
USING (auth.uid() = user_id);

-- Routine Exercises
ALTER TABLE public.routine_exercises ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own routine_exercises" ON public.routine_exercises;
CREATE POLICY "Users can view own routine_exercises" ON public.routine_exercises FOR SELECT
USING (EXISTS (SELECT 1 FROM public.routines r WHERE r.id = routine_id AND r.user_id = auth.uid()));
DROP POLICY IF EXISTS "Users can insert own routine_exercises" ON public.routine_exercises;
CREATE POLICY "Users can insert own routine_exercises" ON public.routine_exercises FOR INSERT
WITH CHECK (EXISTS (SELECT 1 FROM public.routines r WHERE r.id = routine_id AND r.user_id = auth.uid()));
DROP POLICY IF EXISTS "Users can update own routine_exercises" ON public.routine_exercises;
CREATE POLICY "Users can update own routine_exercises" ON public.routine_exercises FOR UPDATE
USING (EXISTS (SELECT 1 FROM public.routines r WHERE r.id = routine_id AND r.user_id = auth.uid()));
DROP POLICY IF EXISTS "Users can delete own routine_exercises" ON public.routine_exercises;
CREATE POLICY "Users can delete own routine_exercises" ON public.routine_exercises FOR DELETE
USING (EXISTS (SELECT 1 FROM public.routines r WHERE r.id = routine_id AND r.user_id = auth.uid()));

-- Routine Superset Groups
ALTER TABLE public.routine_superset_groups ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own routine_superset_groups" ON public.routine_superset_groups;
CREATE POLICY "Users can view own routine_superset_groups" ON public.routine_superset_groups FOR SELECT
USING (EXISTS (SELECT 1 FROM public.routines r WHERE r.id = routine_id AND r.user_id = auth.uid()));
DROP POLICY IF EXISTS "Users can insert own routine_superset_groups" ON public.routine_superset_groups;
CREATE POLICY "Users can insert own routine_superset_groups" ON public.routine_superset_groups FOR INSERT
WITH CHECK (EXISTS (SELECT 1 FROM public.routines r WHERE r.id = routine_id AND r.user_id = auth.uid()));
DROP POLICY IF EXISTS "Users can update own routine_superset_groups" ON public.routine_superset_groups;
CREATE POLICY "Users can update own routine_superset_groups" ON public.routine_superset_groups FOR UPDATE
USING (EXISTS (SELECT 1 FROM public.routines r WHERE r.id = routine_id AND r.user_id = auth.uid()));
DROP POLICY IF EXISTS "Users can delete own routine_superset_groups" ON public.routine_superset_groups;
CREATE POLICY "Users can delete own routine_superset_groups" ON public.routine_superset_groups FOR DELETE
USING (EXISTS (SELECT 1 FROM public.routines r WHERE r.id = routine_id AND r.user_id = auth.uid()));

-- Routine Schedules
ALTER TABLE public.routine_schedules ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own routine_schedules" ON public.routine_schedules;
CREATE POLICY "Users can view own routine_schedules" ON public.routine_schedules FOR SELECT
USING (EXISTS (SELECT 1 FROM public.routines r WHERE r.id = routine_id AND r.user_id = auth.uid()));
DROP POLICY IF EXISTS "Users can insert own routine_schedules" ON public.routine_schedules;
CREATE POLICY "Users can insert own routine_schedules" ON public.routine_schedules FOR INSERT
WITH CHECK (EXISTS (SELECT 1 FROM public.routines r WHERE r.id = routine_id AND r.user_id = auth.uid()));
DROP POLICY IF EXISTS "Users can update own routine_schedules" ON public.routine_schedules;
CREATE POLICY "Users can update own routine_schedules" ON public.routine_schedules FOR UPDATE
USING (EXISTS (SELECT 1 FROM public.routines r WHERE r.id = routine_id AND r.user_id = auth.uid()));
DROP POLICY IF EXISTS "Users can delete own routine_schedules" ON public.routine_schedules;
CREATE POLICY "Users can delete own routine_schedules" ON public.routine_schedules FOR DELETE
USING (EXISTS (SELECT 1 FROM public.routines r WHERE r.id = routine_id AND r.user_id = auth.uid()));

-- Planned Workouts
ALTER TABLE public.planned_workouts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own planned_workouts" ON public.planned_workouts;
CREATE POLICY "Users can view own planned_workouts" ON public.planned_workouts FOR SELECT
USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can insert own planned_workouts" ON public.planned_workouts;
CREATE POLICY "Users can insert own planned_workouts" ON public.planned_workouts FOR INSERT
WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can update own planned_workouts" ON public.planned_workouts;
CREATE POLICY "Users can update own planned_workouts" ON public.planned_workouts FOR UPDATE
USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can delete own planned_workouts" ON public.planned_workouts;
CREATE POLICY "Users can delete own planned_workouts" ON public.planned_workouts FOR DELETE
USING (auth.uid() = user_id);

-- ==============================================================================
-- 7. INDEXES
-- ==============================================================================

CREATE INDEX IF NOT EXISTS idx_routines_user_id ON public.routines(user_id);
CREATE INDEX IF NOT EXISTS idx_routine_exercises_routine_id ON public.routine_exercises(routine_id);
CREATE INDEX IF NOT EXISTS idx_routine_superset_groups_routine_id ON public.routine_superset_groups(routine_id);
CREATE INDEX IF NOT EXISTS idx_routine_schedules_routine_id ON public.routine_schedules(routine_id);
CREATE INDEX IF NOT EXISTS idx_planned_workouts_user_date ON public.planned_workouts(user_id, scheduled_date);
CREATE INDEX IF NOT EXISTS idx_planned_workouts_routine_id ON public.planned_workouts(routine_id);
CREATE INDEX IF NOT EXISTS idx_planned_workouts_scheduled_date ON public.planned_workouts(scheduled_date);

-- ==============================================================================
-- 8. UPDATED_AT TRIGGERS
-- ==============================================================================

DROP TRIGGER IF EXISTS update_routines_modtime ON public.routines;
CREATE TRIGGER update_routines_modtime
BEFORE UPDATE ON public.routines
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

DROP TRIGGER IF EXISTS update_routine_exercises_modtime ON public.routine_exercises;
CREATE TRIGGER update_routine_exercises_modtime
BEFORE UPDATE ON public.routine_exercises
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

DROP TRIGGER IF EXISTS update_routine_superset_groups_modtime ON public.routine_superset_groups;
CREATE TRIGGER update_routine_superset_groups_modtime
BEFORE UPDATE ON public.routine_superset_groups
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

DROP TRIGGER IF EXISTS update_planned_workouts_modtime ON public.planned_workouts;
CREATE TRIGGER update_planned_workouts_modtime
BEFORE UPDATE ON public.planned_workouts
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ==============================================================================
-- 9. RPC FUNCTIONS
-- ==============================================================================

-- Create routine with exercises
CREATE OR REPLACE FUNCTION public.create_routine(
  p_user_id uuid,
  p_name text,
  p_emoji text,
  p_exercises jsonb
) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
  v_user_id uuid := auth.uid();
  v_routine_id uuid;
  v_exercise jsonb;
  v_position integer := 0;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;

  -- Ownership is always derived from the authenticated session. A client
  -- supplied id is accepted only when it matches that session.
  IF p_user_id IS NOT NULL AND p_user_id <> v_user_id THEN
    RAISE EXCEPTION 'Cannot create routine for another user' USING ERRCODE = '42501';
  END IF;

  INSERT INTO public.routines (user_id, name, emoji)
  VALUES (v_user_id, p_name, p_emoji)
  RETURNING id INTO v_routine_id;

  IF p_exercises IS NOT NULL AND jsonb_typeof(p_exercises) = 'array' THEN
    FOR v_exercise IN SELECT * FROM jsonb_array_elements(p_exercises) LOOP
      INSERT INTO public.routine_exercises (
        routine_id, exercise_id, order_index, sets, reps, weight_kg,
        duration_seconds, rest_seconds, mode, notes
      ) VALUES (
        v_routine_id,
        (v_exercise->>'exercise_id')::uuid,
        v_position,
        COALESCE((v_exercise->>'sets')::int, 3),
        (v_exercise->>'reps')::int,
        COALESCE((v_exercise->>'weight_kg')::numeric, 0),
        (v_exercise->>'duration_seconds')::int,
        COALESCE((v_exercise->>'rest_seconds')::int, 90),
        COALESCE(v_exercise->>'mode', 'reps-weight'),
        v_exercise->>'notes'
      );
      v_position := v_position + 1;
    END LOOP;
  END IF;

  RETURN v_routine_id;
END;
$$;

REVOKE ALL ON FUNCTION public.create_routine(uuid, text, text, jsonb)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.create_routine(uuid, text, text, jsonb)
  TO authenticated;

-- Duplicate routine
CREATE OR REPLACE FUNCTION public.duplicate_routine(
  p_routine_id uuid,
  p_new_name text,
  p_emoji text DEFAULT NULL
) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
  v_user_id uuid := auth.uid();
  v_new_routine_id uuid;
  v_group record;
  v_new_group_id uuid;
  v_group_map jsonb := '{}'::jsonb;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;

  -- Verify ownership
  IF NOT EXISTS (SELECT 1 FROM public.routines WHERE id = p_routine_id AND user_id = v_user_id) THEN
    RAISE EXCEPTION 'Routine not found' USING ERRCODE = '42501';
  END IF;

  -- Copy routine
  INSERT INTO public.routines (user_id, name, emoji)
  SELECT user_id, p_new_name, COALESCE(p_emoji, emoji)
  FROM public.routines WHERE id = p_routine_id
  RETURNING id INTO v_new_routine_id;

  -- Recreate superset groups so the duplicate owns independent group ids.
  FOR v_group IN
    SELECT id, position FROM public.routine_superset_groups
    WHERE routine_id = p_routine_id ORDER BY position
  LOOP
    INSERT INTO public.routine_superset_groups (routine_id, position)
    VALUES (v_new_routine_id, v_group.position)
    RETURNING id INTO v_new_group_id;
    v_group_map := v_group_map || jsonb_build_object(v_group.id::text, v_new_group_id::text);
  END LOOP;

  -- Copy exercises with remapped superset group ids.
  INSERT INTO public.routine_exercises (
    routine_id, exercise_id, order_index, sets, reps, weight_kg,
    duration_seconds, rest_seconds, mode, notes, superset_group_id, superset_position
  )
  SELECT v_new_routine_id, exercise_id, order_index, sets, reps, weight_kg,
         duration_seconds, rest_seconds, mode, notes,
         CASE
           WHEN superset_group_id IS NULL THEN NULL
           ELSE (v_group_map->>superset_group_id::text)::uuid
         END,
         superset_position
  FROM public.routine_exercises WHERE routine_id = p_routine_id;

  RETURN v_new_routine_id;
END;
$$;

REVOKE ALL ON FUNCTION public.duplicate_routine(uuid, text, text)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.duplicate_routine(uuid, text, text)
  TO authenticated;

-- Replace exercise in routine
CREATE OR REPLACE FUNCTION public.replace_routine_exercise(
  p_routine_id uuid,
  p_routine_exercise_id uuid,
  p_new_exercise_id uuid,
  p_config jsonb DEFAULT '{}'
) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
  v_user_id uuid := auth.uid();
  v_old_exercise record;
  v_new_config jsonb;
  v_mode text;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;

  -- Verify ownership
  IF NOT EXISTS (SELECT 1 FROM public.routines WHERE id = p_routine_id AND user_id = v_user_id) THEN
    RAISE EXCEPTION 'Routine not found' USING ERRCODE = '42501';
  END IF;

  -- Get old exercise
  SELECT * INTO v_old_exercise
  FROM public.routine_exercises
  WHERE id = p_routine_exercise_id AND routine_id = p_routine_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Exercise not found in routine' USING ERRCODE = '42501';
  END IF;

  -- Get new exercise mode for compatibility check
  SELECT mode INTO v_mode FROM public.exercises WHERE id = p_new_exercise_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Exercise not found' USING ERRCODE = '42501';
  END IF;

  -- Build new config preserving compatible fields
  v_new_config := jsonb_build_object(
    'exercise_id', p_new_exercise_id,
    'mode', COALESCE(p_config->>'mode', v_old_exercise.mode),
    'sets', COALESCE((p_config->>'sets')::int, 3),
    'reps', (p_config->>'reps')::int,
    'reps_min', (p_config->>'reps_min')::int,
    'weight_kg', COALESCE((p_config->>'weight_kg')::numeric, 0),
    'duration_seconds', (p_config->>'duration_seconds')::int,
    'rest_seconds', COALESCE((p_config->>'rest_seconds')::int, 90),
    'mode', COALESCE(p_config->>'mode', v_mode),
    'notes', v_old_exercise.notes
  );

  -- Reset incompatible fields based on mode change
  IF v_old_exercise.mode IS DISTINCT FROM v_mode THEN
    IF v_mode IN ('timed', 'cardio') THEN
      v_new_config := v_new_config - 'weight_kg' - 'reps' - 'reps_min';
      v_new_config := v_new_config || jsonb_build_object('weight_kg', 0, 'reps', 0);
    ELSIF v_mode IN ('reps-weight', 'bodyweight') AND v_old_exercise.mode IN ('timed', 'cardio') THEN
      v_new_config := v_new_config - 'duration_seconds';
      v_new_config := v_new_config || jsonb_build_object('duration_seconds', 0);
    END IF;

    -- Bodyweight vs reps-weight weight handling
    IF v_mode = 'bodyweight' THEN
      v_new_config := v_new_config || jsonb_build_object('weight_kg', 0);
    END IF;
  END IF;

  -- Apply the update
  UPDATE public.routine_exercises
  SET
    exercise_id = p_new_exercise_id,
    sets = COALESCE((v_new_config->>'sets')::int, 3),
    reps = (v_new_config->>'reps')::int,
    reps_min = (v_new_config->>'reps_min')::int,
    weight_kg = COALESCE((v_new_config->>'weight_kg')::numeric, 0),
    duration_seconds = (v_new_config->>'duration_seconds')::int,
    rest_seconds = (v_new_config->>'rest_seconds')::int,
    mode = COALESCE(p_config->>'mode', v_mode),
    notes = v_old_exercise.notes,
    updated_at = now()
  WHERE id = p_routine_exercise_id AND routine_id = p_routine_id;
END;
$$;

REVOKE ALL ON FUNCTION public.replace_routine_exercise(uuid, uuid, uuid, jsonb)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.replace_routine_exercise(uuid, uuid, uuid, jsonb)
  TO authenticated;

-- Reorder routine exercises
CREATE OR REPLACE FUNCTION public.reorder_routine_exercises(
  p_routine_id uuid,
  p_exercise_ids uuid[]
) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
  v_user_id uuid := auth.uid();
  v_idx integer;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM public.routines WHERE id = p_routine_id AND user_id = v_user_id) THEN
    RAISE EXCEPTION 'Routine not found' USING ERRCODE = '42501';
  END IF;

  FOR v_idx IN 0..array_upper(p_exercise_ids, 1) LOOP
    UPDATE public.routine_exercises
    SET order_index = v_idx, updated_at = now()
    WHERE id = p_exercise_ids[v_idx + 1] AND routine_id = p_routine_id;
  END LOOP;
END;
$$;

REVOKE ALL ON FUNCTION public.reorder_routine_exercises(uuid, uuid[])
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.reorder_routine_exercises(uuid, uuid[])
  TO authenticated;

-- Schedule routine (fixed week or rotation)
CREATE OR REPLACE FUNCTION public.schedule_routine(
  p_routine_id uuid,
  p_schedule_mode text,
  p_weekday integer DEFAULT NULL,
  p_rotation_position integer DEFAULT NULL,
  p_superset_group_id uuid DEFAULT NULL
) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
  v_user_id uuid := auth.uid();
  v_schedule_id uuid;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM public.routines WHERE id = p_routine_id AND user_id = v_user_id) THEN
    RAISE EXCEPTION 'Routine not found' USING ERRCODE = '42501';
  END IF;

  IF p_schedule_mode = 'fixed_week' THEN
    IF p_weekday IS NULL OR p_weekday < 1 OR p_weekday > 7 THEN
      RAISE EXCEPTION 'weekday must be 1-7 for fixed_week mode' USING ERRCODE = '22023';
    END IF;
    INSERT INTO public.routine_schedules (routine_id, schedule_mode, weekday)
    VALUES (p_routine_id, 'fixed_week', p_weekday)
    RETURNING id INTO v_schedule_id;
  ELSIF p_schedule_mode = 'rotation' THEN
    IF p_rotation_position IS NULL OR p_rotation_position < 0 THEN
      RAISE EXCEPTION 'rotation_position must be >= 0 for rotation mode' USING ERRCODE = '22023';
    END IF;
    INSERT INTO public.routine_schedules (routine_id, schedule_mode, rotation_position, superset_group_id)
    VALUES (p_routine_id, 'rotation', p_rotation_position, p_superset_group_id)
    RETURNING id INTO v_schedule_id;
  ELSE
    RAISE EXCEPTION 'schedule_mode must be fixed_week or rotation' USING ERRCODE = '22023';
  END IF;

  RETURN v_schedule_id;
END;
$$;

REVOKE ALL ON FUNCTION public.schedule_routine(uuid, text, integer, integer, uuid)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.schedule_routine(uuid, text, integer, integer, uuid)
  TO authenticated;

-- Create planned workout from routine (with immutable snapshot)
CREATE OR REPLACE FUNCTION public.create_planned_workout(
  p_routine_id uuid,
  p_scheduled_date date
) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
  v_user_id uuid := auth.uid();
  v_planned_id uuid;
  v_routine record;
  v_snapshot jsonb;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_routine FROM public.routines WHERE id = p_routine_id AND user_id = v_user_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Routine not found' USING ERRCODE = '42501';
  END IF;

  -- Build immutable snapshot of routine at scheduling time
  SELECT jsonb_build_object(
    'routine', jsonb_build_object(
      'id', r.id, 'name', r.name, 'emoji', r.emoji,
      'exercises', (
        SELECT jsonb_agg(jsonb_build_object(
          'exercise_id', re.exercise_id, 'order_index', re.order_index,
          'sets', re.sets, 'reps', re.reps, 'reps_min', re.reps_min,
          'weight_kg', re.weight_kg, 'duration_seconds', re.duration_seconds,
          'rest_seconds', re.rest_seconds, 'mode', re.mode, 'notes', re.notes,
          'superset_group_id', re.superset_group_id, 'superset_position', re.superset_position
        ) ORDER BY re.order_index)
        FROM public.routine_exercises re WHERE re.routine_id = r.id
      )
    )
  ) INTO v_snapshot
  FROM public.routines r WHERE r.id = p_routine_id;

  INSERT INTO public.planned_workouts (user_id, routine_id, routine_name, routine_snapshot, scheduled_date)
  VALUES (v_routine.user_id, p_routine_id, v_routine.name, v_snapshot, p_scheduled_date)
  RETURNING id INTO v_planned_id;

  RETURN v_planned_id;
END;
$$;

REVOKE ALL ON FUNCTION public.create_planned_workout(uuid, date)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.create_planned_workout(uuid, date)
  TO authenticated;

-- Start planned workout (creates actual workout from snapshot)
CREATE OR REPLACE FUNCTION public.start_planned_workout(
  p_planned_workout_id uuid
) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
  v_user_id uuid := auth.uid();
  v_planned record;
  v_workout_id uuid;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_planned
  FROM public.planned_workouts
  WHERE id = p_planned_workout_id AND user_id = v_user_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Planned workout not found' USING ERRCODE = '42501';
  END IF;

  IF v_planned.status <> 'planned' THEN
    RAISE EXCEPTION 'Planned workout already started or completed' USING ERRCODE = '22023';
  END IF;

  -- Start actual workout
  INSERT INTO public.workouts (user_id, status, notes)
  VALUES (v_user_id, 'active', 'Started from planned workout')
  RETURNING id INTO v_workout_id;

  -- Create workout_exercises from the immutable snapshot only.
  INSERT INTO public.workout_exercises (
    workout_id, exercise_id, order_index, mode, notes,
    superset_group_id, superset_position
  )
  SELECT v_workout_id,
    (e->>'exercise_id')::uuid,
    COALESCE((e->>'order_index')::int, 0),
    e->>'mode',
    e->>'notes',
    NULLIF(e->>'superset_group_id', '')::uuid,
    NULLIF(e->>'superset_position', '')::int
  FROM jsonb_array_elements(v_planned.routine_snapshot->'routine'->'exercises') AS e;

  -- Update planned workout
  UPDATE public.planned_workouts
  SET status = 'started', workout_id = v_workout_id
  WHERE id = p_planned_workout_id AND user_id = v_user_id;

  RETURN v_workout_id;
END;
$$;

REVOKE ALL ON FUNCTION public.start_planned_workout(uuid)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.start_planned_workout(uuid)
  TO authenticated;

-- Complete planned workout (mark as completed, link to workout)
CREATE OR REPLACE FUNCTION public.complete_planned_workout(
  p_planned_workout_id uuid,
  p_workout_id uuid
) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
  v_user_id uuid := auth.uid();
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.workouts WHERE id = p_workout_id AND user_id = v_user_id
  ) THEN
    RAISE EXCEPTION 'Workout not found' USING ERRCODE = '42501';
  END IF;

  UPDATE public.planned_workouts
  SET status = 'completed', workout_id = p_workout_id
  WHERE id = p_planned_workout_id AND user_id = v_user_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Planned workout not found' USING ERRCODE = '42501';
  END IF;
END;
$$;

REVOKE ALL ON FUNCTION public.complete_planned_workout(uuid, uuid)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.complete_planned_workout(uuid, uuid)
  TO authenticated;

-- Repeat completed workout
CREATE OR REPLACE FUNCTION public.repeat_workout(
  p_completed_workout_id uuid
) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
  v_user_id uuid := auth.uid();
  v_completed record;
  v_routine_id uuid;
  v_planned_id uuid;
  v_exercises jsonb;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;

  -- A repeat is only valid for the caller's own completed history.
  SELECT w.id, w.user_id, w.notes
  INTO v_completed
  FROM public.workouts w
  WHERE w.id = p_completed_workout_id
    AND w.user_id = v_user_id
    AND w.status = 'completed';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Completed workout not found' USING ERRCODE = '42501';
  END IF;

  SELECT jsonb_agg(jsonb_build_object(
    'exercise_id', we.exercise_id,
    'sets', 3,
    'reps', 10,
    'weight_kg', 0,
    'mode', COALESCE(we.mode, 'reps-weight')
  ) ORDER BY we.order_index, we.created_at)
  INTO v_exercises
  FROM public.workout_exercises we
  WHERE we.workout_id = p_completed_workout_id;

  IF v_exercises IS NULL THEN
    RAISE EXCEPTION 'Completed workout has no exercises' USING ERRCODE = '22023';
  END IF;

  -- Create a new routine owned by the caller. The completed workout and its
  -- exercises are never modified.
  v_routine_id := public.create_routine(
    v_user_id,
    COALESCE(v_completed.notes, 'Workout') || ' (Repeat)',
    '🔁',
    v_exercises
  );

  -- Create a new dated occurrence for today. Repeating is explicit: it never
  -- silently schedules tomorrow or mutates the completed workout.
  v_planned_id := public.create_planned_workout(v_routine_id, CURRENT_DATE);

  RETURN v_planned_id;
END;
$$;

REVOKE ALL ON FUNCTION public.repeat_workout(uuid)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.repeat_workout(uuid)
  TO authenticated;

-- Get planned workouts for date range
CREATE OR REPLACE FUNCTION public.get_planned_workouts(
  p_user_id uuid,
  p_start_date date,
  p_end_date date
) RETURNS SETOF public.planned_workouts LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
  v_user_id uuid := auth.uid();
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;
  IF p_user_id IS NOT NULL AND p_user_id <> v_user_id THEN
    RAISE EXCEPTION 'Cannot read another user''s planned workouts' USING ERRCODE = '42501';
  END IF;

  RETURN QUERY
  SELECT * FROM public.planned_workouts
  WHERE user_id = v_user_id
    AND scheduled_date BETWEEN p_start_date AND p_end_date
  ORDER BY scheduled_date, created_at;
END;
$$;

REVOKE ALL ON FUNCTION public.get_planned_workouts(uuid, date, date)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_planned_workouts(uuid, date, date)
  TO authenticated;

-- Get next upcoming workout
CREATE OR REPLACE FUNCTION public.get_next_planned_workout(
  p_user_id uuid
) RETURNS public.planned_workouts LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
  v_user_id uuid := auth.uid();
  v_planned public.planned_workouts;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;
  IF p_user_id IS NOT NULL AND p_user_id <> v_user_id THEN
    RAISE EXCEPTION 'Cannot read another user''s planned workouts' USING ERRCODE = '42501';
  END IF;

  SELECT * INTO v_planned
  FROM public.planned_workouts
  WHERE user_id = v_user_id
    AND status = 'planned'
    AND scheduled_date >= CURRENT_DATE
  ORDER BY scheduled_date, created_at
  LIMIT 1;

  RETURN v_planned;
END;
$$;

REVOKE ALL ON FUNCTION public.get_next_planned_workout(uuid)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_next_planned_workout(uuid)
  TO authenticated;

-- Grant usage on sequences
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;