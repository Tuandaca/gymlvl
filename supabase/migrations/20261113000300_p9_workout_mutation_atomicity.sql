-- P9.5: one authenticated transaction for workout reorder or adding an
-- exercise with its default sets. Both paths reuse the private M3 write ledger.
-- Recovery: stop using these RPCs and ship a reviewed additive correction;
-- committed workout rows and operation receipts must remain intact.

CREATE OR REPLACE FUNCTION public.reorder_workout_exercises_v1(
  p_operation_id uuid,
  p_workout_id uuid,
  p_exercise_ids uuid[]
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
  uid uuid := auth.uid();
  existing public.workout_write_operations;
  request_body jsonb;
  fingerprint text;
  exercise_count integer;
  distinct_count integer;
  updated_count integer;
  response jsonb;
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;
  IF p_operation_id IS NULL OR p_workout_id IS NULL OR p_exercise_ids IS NULL
     OR cardinality(p_exercise_ids) > 1000
     OR array_position(p_exercise_ids, NULL) IS NOT NULL THEN
    RAISE EXCEPTION 'Invalid workout reorder request' USING ERRCODE = '22023';
  END IF;

  request_body := jsonb_build_object(
    'version', 1, 'kind', 'reorder_workout_exercises_v1',
    'workout_id', p_workout_id, 'exercise_ids', to_jsonb(p_exercise_ids)
  );
  fingerprint := encode(sha256(convert_to(request_body::text, 'UTF8')), 'hex');

  -- Match complete_workout and the existing write RPC: account, then workout.
  PERFORM 1 FROM public.users WHERE id = uid FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Account unavailable' USING ERRCODE = '42501';
  END IF;
  SELECT * INTO existing FROM public.workout_write_operations
    WHERE user_id = uid AND operation_id = p_operation_id;
  IF FOUND THEN
    IF existing.request_fingerprint <> fingerprint
       OR existing.request_body <> request_body THEN
      RAISE EXCEPTION 'Operation ID reused with different content'
        USING ERRCODE = '23505';
    END IF;
    RETURN existing.result;
  END IF;

  PERFORM 1 FROM public.workouts
    WHERE id = p_workout_id AND user_id = uid AND status = 'active' FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Workout unavailable or already finished'
      USING ERRCODE = '42501';
  END IF;
  PERFORM 1 FROM public.workout_exercises
    WHERE workout_id = p_workout_id ORDER BY id FOR UPDATE;
  SELECT count(*)::integer INTO exercise_count FROM public.workout_exercises
    WHERE workout_id = p_workout_id;
  SELECT count(DISTINCT requested.id)::integer INTO distinct_count
    FROM unnest(p_exercise_ids) AS requested(id);
  IF cardinality(p_exercise_ids) <> exercise_count
     OR distinct_count <> exercise_count
     OR EXISTS (
       SELECT 1 FROM unnest(p_exercise_ids) AS requested(id)
       WHERE NOT EXISTS (
         SELECT 1 FROM public.workout_exercises we
         WHERE we.id = requested.id AND we.workout_id = p_workout_id
       )
     ) THEN
    RAISE EXCEPTION 'Exercise order must contain the complete workout'
      USING ERRCODE = '22023';
  END IF;

  -- order_index has no unique constraint. superset_position is independent;
  -- this preserves the existing ability to reorder grouped exercises.
  UPDATE public.workout_exercises we
    SET order_index = requested.ordinality::integer - 1
    FROM unnest(p_exercise_ids) WITH ORDINALITY AS requested(id, ordinality)
    WHERE we.id = requested.id AND we.workout_id = p_workout_id;
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  IF updated_count <> exercise_count THEN
    RAISE EXCEPTION 'Workout order changed during reorder' USING ERRCODE = '40001';
  END IF;

  response := jsonb_build_object(
    'operation_id', p_operation_id, 'workout_id', p_workout_id,
    'exercise_count', exercise_count
  );
  INSERT INTO public.workout_write_operations (
    user_id, operation_id, workout_id, contract_version, mutation_kind,
    request_body, request_fingerprint, result
  ) VALUES (
    uid, p_operation_id, p_workout_id, 1, 'reorder_exercises_v1',
    request_body, fingerprint, response
  );
  RETURN response;
END;
$$;

REVOKE ALL ON FUNCTION public.reorder_workout_exercises_v1(uuid, uuid, uuid[])
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.reorder_workout_exercises_v1(uuid, uuid, uuid[])
  TO authenticated;

CREATE OR REPLACE FUNCTION public.add_workout_exercise_with_sets_v1(
  p_operation_id uuid,
  p_workout_id uuid,
  p_exercise_id uuid,
  p_mode text,
  p_sets jsonb
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
  uid uuid := auth.uid();
  existing public.workout_write_operations;
  set_spec jsonb;
  normalized_set jsonb;
  normalized_sets jsonb := '[]'::jsonb;
  request_body jsonb;
  fingerprint text;
  set_reps integer;
  set_weight numeric;
  set_duration integer;
  append_order bigint;
  new_exercise_id uuid;
  new_set_id uuid;
  set_ids uuid[] := ARRAY[]::uuid[];
  set_number integer := 0;
  response jsonb;
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;
  IF p_operation_id IS NULL OR p_workout_id IS NULL OR p_exercise_id IS NULL
     OR (p_mode IS NOT NULL AND p_mode NOT IN
       ('reps-weight', 'bodyweight', 'timed', 'cardio'))
     OR jsonb_typeof(p_sets) IS DISTINCT FROM 'array' THEN
    RAISE EXCEPTION 'Invalid exercise-and-sets request' USING ERRCODE = '22023';
  END IF;
  IF jsonb_array_length(p_sets) NOT BETWEEN 1 AND 100
     OR octet_length(p_sets::text) > 12000 THEN
    RAISE EXCEPTION 'Invalid exercise-and-sets request' USING ERRCODE = '22023';
  END IF;

  FOR set_spec IN SELECT value FROM jsonb_array_elements(p_sets) LOOP
    IF jsonb_typeof(set_spec) IS DISTINCT FROM 'object' THEN
      RAISE EXCEPTION 'Invalid default set fields' USING ERRCODE = '22023';
    END IF;
    IF (SELECT count(*) FROM jsonb_object_keys(set_spec)) <> 3
       OR NOT set_spec ?& ARRAY['reps', 'weight_kg', 'duration_seconds']
       OR jsonb_typeof(set_spec->'reps') IS DISTINCT FROM 'number'
       OR jsonb_typeof(set_spec->'weight_kg') IS DISTINCT FROM 'number'
       OR jsonb_typeof(set_spec->'duration_seconds') IS DISTINCT FROM 'number'
       OR (set_spec->>'reps') !~ '^[0-9]{1,4}$'
       OR (set_spec->>'duration_seconds') !~ '^[0-9]{1,4}$' THEN
      RAISE EXCEPTION 'Invalid default set fields' USING ERRCODE = '22023';
    END IF;
    set_reps := (set_spec->>'reps')::integer;
    set_weight := (set_spec->>'weight_kg')::numeric;
    set_duration := (set_spec->>'duration_seconds')::integer;
    IF set_reps > 1000 OR set_weight NOT BETWEEN 0 AND 1000
       OR set_duration > 7200
       OR (p_mode IN ('timed', 'cardio')
           AND (set_reps <> 0 OR set_weight <> 0 OR set_duration = 0))
       OR (p_mode IS NULL OR p_mode IN ('reps-weight', 'bodyweight'))
           AND (set_reps = 0 OR set_duration <> 0) THEN
      RAISE EXCEPTION 'Invalid default set measurements' USING ERRCODE = '22023';
    END IF;
    normalized_set := jsonb_build_object(
      'reps', set_reps, 'weight_kg', trim_scale(set_weight),
      'duration_seconds', set_duration
    );
    normalized_sets := normalized_sets || jsonb_build_array(normalized_set);
  END LOOP;

  request_body := jsonb_build_object(
    'version', 1, 'kind', 'add_workout_exercise_with_sets_v1',
    'workout_id', p_workout_id, 'exercise_id', p_exercise_id,
    'mode', p_mode, 'sets', normalized_sets
  );
  fingerprint := encode(sha256(convert_to(request_body::text, 'UTF8')), 'hex');

  PERFORM 1 FROM public.users WHERE id = uid FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Account unavailable' USING ERRCODE = '42501';
  END IF;
  SELECT * INTO existing FROM public.workout_write_operations
    WHERE user_id = uid AND operation_id = p_operation_id;
  IF FOUND THEN
    IF existing.request_fingerprint <> fingerprint
       OR existing.request_body <> request_body THEN
      RAISE EXCEPTION 'Operation ID reused with different content'
        USING ERRCODE = '23505';
    END IF;
    RETURN existing.result;
  END IF;

  PERFORM 1 FROM public.workouts
    WHERE id = p_workout_id AND user_id = uid AND status = 'active' FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Workout unavailable or already finished'
      USING ERRCODE = '42501';
  END IF;
  PERFORM 1 FROM public.exercises e
    WHERE e.id = p_exercise_id
      AND ((e.user_id IS NULL AND e.source <> 'user')
        OR (e.user_id = uid AND e.source = 'user' AND NOT e.is_archived));
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Exercise unavailable for this workout'
      USING ERRCODE = '42501';
  END IF;
  IF EXISTS (
    SELECT 1 FROM public.workout_exercises we
    WHERE we.workout_id = p_workout_id AND we.exercise_id = p_exercise_id
  ) THEN
    RAISE EXCEPTION 'Exercise already exists in workout' USING ERRCODE = '23505';
  END IF;
  SELECT greatest(coalesce(max(order_index)::bigint, -1), -1) + 1 INTO append_order
    FROM public.workout_exercises WHERE workout_id = p_workout_id;
  IF append_order > 2147483647 THEN
    RAISE EXCEPTION 'Workout exercise order exhausted' USING ERRCODE = '22023';
  END IF;

  INSERT INTO public.workout_exercises(workout_id, exercise_id, order_index, mode)
    VALUES (p_workout_id, p_exercise_id, append_order::integer, p_mode)
    RETURNING id INTO new_exercise_id;
  FOR normalized_set IN SELECT value FROM jsonb_array_elements(normalized_sets) LOOP
    set_number := set_number + 1;
    INSERT INTO public.workout_sets(
      workout_exercise_id, set_number, reps, weight_kg, duration_seconds,
      rest_seconds, is_completed, set_type
    ) VALUES (
      new_exercise_id, set_number, (normalized_set->>'reps')::integer,
      (normalized_set->>'weight_kg')::numeric,
      (normalized_set->>'duration_seconds')::integer, 0, false, 'workout'
    ) RETURNING id INTO new_set_id;
    set_ids := array_append(set_ids, new_set_id);
  END LOOP;

  response := jsonb_build_object(
    'operation_id', p_operation_id, 'workout_id', p_workout_id,
    'workout_exercise_id', new_exercise_id, 'set_ids', to_jsonb(set_ids)
  );
  INSERT INTO public.workout_write_operations (
    user_id, operation_id, workout_id, contract_version, mutation_kind,
    request_body, request_fingerprint, result
  ) VALUES (
    uid, p_operation_id, p_workout_id, 1, 'add_exercise_with_sets_v1',
    request_body, fingerprint, response
  );
  RETURN response;
END;
$$;

REVOKE ALL ON FUNCTION public.add_workout_exercise_with_sets_v1(
  uuid, uuid, uuid, text, jsonb) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.add_workout_exercise_with_sets_v1(
  uuid, uuid, uuid, text, jsonb) TO authenticated;
