-- M3 local/test foundation only. Do not deploy or enable client replay before
-- encryption, retention, account-switching, and conflict policies are approved.
ALTER TABLE public.workout_exercises
  ADD COLUMN IF NOT EXISTS superset_group_id uuid;

-- The grouping behavior is not approved. Keep the new field unwritable even
-- if this test migration is accidentally applied before that decision.
CREATE OR REPLACE FUNCTION public.reject_unapproved_superset_group()
RETURNS trigger LANGUAGE plpgsql SET search_path = '' AS $$
BEGIN
  IF NEW.superset_group_id IS NOT NULL THEN
    RAISE EXCEPTION 'Superset writes are not approved'
      USING ERRCODE = '42501';
  END IF;
  RETURN NEW;
END;
$$;
CREATE TRIGGER reject_unapproved_superset_group
  BEFORE INSERT OR UPDATE OF superset_group_id
  ON public.workout_exercises
  FOR EACH ROW EXECUTE FUNCTION public.reject_unapproved_superset_group();
REVOKE ALL ON FUNCTION public.reject_unapproved_superset_group()
  FROM PUBLIC, anon, authenticated;

-- No client table grants or RLS policies: only the function below may use this
-- ledger. Its request JSON is retained to detect even a fingerprint collision.
CREATE TABLE IF NOT EXISTS public.workout_write_operations (
  user_id uuid NOT NULL,
  operation_id uuid NOT NULL,
  workout_id uuid NOT NULL,
  contract_version integer NOT NULL,
  mutation_kind text NOT NULL,
  request_body jsonb NOT NULL,
  request_fingerprint text NOT NULL,
  result jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, operation_id)
);
ALTER TABLE public.workout_write_operations ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.workout_write_operations FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.apply_workout_set_create_v1(
  p_operation_id uuid,
  p_workout_id uuid,
  p_payload jsonb
) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
  uid uuid := auth.uid();
  existing public.workout_write_operations;
  normalized_payload jsonb;
  request_body jsonb;
  fingerprint text;
  workout_owner uuid;
  workout_status text;
  target_exercise_id uuid;
  new_set_id uuid;
  response jsonb;
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;
  IF p_operation_id IS NULL OR p_workout_id IS NULL OR p_payload IS NULL
     OR jsonb_typeof(p_payload) <> 'object'
     OR (SELECT count(*) FROM jsonb_object_keys(p_payload)) <> 7
     OR NOT p_payload ?& ARRAY[
       'workout_exercise_id', 'set_number', 'reps', 'weight_kg',
       'duration_seconds', 'rest_seconds', 'is_completed'
     ] THEN
    RAISE EXCEPTION 'Invalid set create request' USING ERRCODE = '22023';
  END IF;
  IF jsonb_typeof(p_payload->'workout_exercise_id') <> 'string'
     OR jsonb_typeof(p_payload->'set_number') <> 'number'
     OR jsonb_typeof(p_payload->'reps') <> 'number'
     OR jsonb_typeof(p_payload->'weight_kg') <> 'number'
     OR jsonb_typeof(p_payload->'duration_seconds') <> 'number'
     OR jsonb_typeof(p_payload->'rest_seconds') <> 'number'
     OR jsonb_typeof(p_payload->'is_completed') <> 'boolean' THEN
    RAISE EXCEPTION 'Invalid set create field types' USING ERRCODE = '22023';
  END IF;
  -- Normalize values before fingerprinting. jsonb preserves numeric scale in
  -- text output (20 versus 20.0), so hashing the raw input would incorrectly
  -- reject a semantically identical retry. UUID, integers, and numeric values
  -- are reduced to their validated canonical server representations here.
  normalized_payload := jsonb_build_object(
    'workout_exercise_id', (p_payload->>'workout_exercise_id')::uuid,
    'set_number', (p_payload->>'set_number')::integer,
    'reps', (p_payload->>'reps')::integer,
    'weight_kg', trim_scale((p_payload->>'weight_kg')::numeric),
    'duration_seconds', (p_payload->>'duration_seconds')::integer,
    'rest_seconds', (p_payload->>'rest_seconds')::integer,
    'is_completed', (p_payload->>'is_completed')::boolean
  );
  request_body := jsonb_build_object(
    'version', 1, 'kind', 'set_create_v1',
    'workout_id', p_workout_id, 'payload', normalized_payload
  );
  fingerprint := encode(sha256(convert_to(request_body::text, 'UTF8')), 'hex');

  -- Match complete_workout's lock order. This also serializes operation IDs
  -- used across two workouts owned by the same account.
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

  SELECT user_id, status INTO workout_owner, workout_status
    FROM public.workouts WHERE id = p_workout_id FOR UPDATE;
  IF workout_owner IS DISTINCT FROM uid OR workout_status <> 'active' THEN
    RAISE EXCEPTION 'Workout unavailable or already finished'
      USING ERRCODE = '42501';
  END IF;
  target_exercise_id := (normalized_payload->>'workout_exercise_id')::uuid;
  IF NOT EXISTS (
    SELECT 1 FROM public.workout_exercises
    WHERE id = target_exercise_id AND workout_id = p_workout_id
  ) THEN
    RAISE EXCEPTION 'Exercise does not belong to workout'
      USING ERRCODE = '42501';
  END IF;
  INSERT INTO public.workout_sets (
    workout_exercise_id, set_number, reps, weight_kg,
    duration_seconds, rest_seconds, is_completed
  ) VALUES (
    target_exercise_id, (normalized_payload->>'set_number')::integer,
    (normalized_payload->>'reps')::integer,
    (normalized_payload->>'weight_kg')::numeric,
    (normalized_payload->>'duration_seconds')::integer,
    (normalized_payload->>'rest_seconds')::integer,
    (normalized_payload->>'is_completed')::boolean
  ) RETURNING id INTO new_set_id;
  response := jsonb_build_object('set_id', new_set_id,
    'operation_id', p_operation_id, 'workout_id', p_workout_id);
  INSERT INTO public.workout_write_operations (
    user_id, operation_id, workout_id, contract_version, mutation_kind,
    request_body, request_fingerprint, result
  ) VALUES (
    uid, p_operation_id, p_workout_id, 1, 'set_create_v1',
    request_body, fingerprint, response
  );
  RETURN response;
END;
$$;

REVOKE ALL ON FUNCTION public.apply_workout_set_create_v1(uuid, uuid, jsonb)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.apply_workout_set_create_v1(uuid, uuid, jsonb)
  TO authenticated;
