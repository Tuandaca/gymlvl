-- P9.5 active-workout mutation atomicity. Disposable database; fixtures roll back.
BEGIN;

CREATE FUNCTION pg_temp.p95_expect(ok boolean, label text) RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
  IF ok IS DISTINCT FROM true THEN RAISE EXCEPTION 'P9.5 FAIL: %', label; END IF;
END $$;

CREATE FUNCTION pg_temp.p95_ledger_count(p_owner uuid, p_operation uuid)
RETURNS integer LANGUAGE sql SECURITY DEFINER SET search_path = '' AS $$
  SELECT count(*)::integer FROM public.workout_write_operations
  WHERE user_id = p_owner AND operation_id = p_operation
$$;

CREATE TEMP SEQUENCE p95_reorder_attempts;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE p95_reorder_attempts TO authenticated;

CREATE FUNCTION pg_temp.p95_reorder_fault() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF current_setting('p95.fail_reorder', true) = 'on' THEN
    IF nextval('pg_temp.p95_reorder_attempts') = 2 THEN
      RAISE EXCEPTION 'injected second reorder write' USING ERRCODE = 'P0001';
    END IF;
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER p95_reorder_fault AFTER UPDATE OF order_index
  ON public.workout_exercises FOR EACH ROW
  EXECUTE FUNCTION pg_temp.p95_reorder_fault();

CREATE FUNCTION pg_temp.p95_set_fault() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF current_setting('p95.fail_set', true) = NEW.set_number::text THEN
    RAISE EXCEPTION 'injected set write %', NEW.set_number USING ERRCODE = 'P0001';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER p95_set_fault AFTER INSERT ON public.workout_sets
  FOR EACH ROW EXECUTE FUNCTION pg_temp.p95_set_fault();

SELECT pg_temp.p95_expect(
  to_regprocedure('public.reorder_workout_exercises_v1(uuid,uuid,uuid[])') IS NOT NULL,
  'atomic reorder RPC exists'
);
SELECT pg_temp.p95_expect(
  to_regprocedure('public.add_workout_exercise_with_sets_v1(uuid,uuid,uuid,text,jsonb)') IS NOT NULL,
  'atomic add-exercise-and-sets RPC exists'
);
SELECT pg_temp.p95_expect(
  NOT has_function_privilege('anon',
    'public.reorder_workout_exercises_v1(uuid,uuid,uuid[])', 'EXECUTE')
  AND NOT has_function_privilege('anon',
    'public.add_workout_exercise_with_sets_v1(uuid,uuid,uuid,text,jsonb)', 'EXECUTE'),
  'anonymous clients cannot invoke workout mutation RPCs'
);
SELECT pg_temp.p95_expect(
  NOT has_table_privilege('authenticated', 'public.workout_write_operations', 'INSERT'),
  'client cannot forge workout mutation receipts'
);

INSERT INTO auth.users(id, email) VALUES
  ('95000000-0000-4000-8000-000000000001', 'p95-owner-a@example.test'),
  ('95000000-0000-4000-8000-000000000002', 'p95-owner-b@example.test');

SET LOCAL ROLE authenticated;
DO $$
DECLARE
  owner_a uuid := '95000000-0000-4000-8000-000000000001';
  owner_b uuid := '95000000-0000-4000-8000-000000000002';
  workout_a uuid;
  workout_b uuid;
  catalog uuid[];
  we_a uuid := '95000000-0000-4000-8000-000000000011';
  we_b uuid := '95000000-0000-4000-8000-000000000012';
  we_c uuid := '95000000-0000-4000-8000-000000000013';
  we_foreign uuid := '95000000-0000-4000-8000-000000000014';
  reorder_key uuid := '95000000-0000-4000-8000-000000000021';
  fault_key uuid := '95000000-0000-4000-8000-000000000022';
  add_key uuid := '95000000-0000-4000-8000-000000000031';
  invalid_key uuid := '95000000-0000-4000-8000-000000000032';
  fault_add_key uuid;
  add_result jsonb;
  replay_result jsonb;
  reorder_result jsonb;
  set_payload jsonb := '[{"reps":10,"weight_kg":20,"duration_seconds":0},{"reps":9,"weight_kg":22,"duration_seconds":0},{"reps":8,"weight_kg":24,"duration_seconds":0}]'::jsonb;
  denied boolean;
  failing_set integer;
  xp_after_completion integer;
BEGIN
  SELECT array_agg(id ORDER BY id) INTO catalog
  FROM (SELECT id FROM public.exercises WHERE source <> 'user' ORDER BY id LIMIT 10) AS available;
  PERFORM pg_temp.p95_expect(array_length(catalog, 1) = 10,
    'ten catalog exercises available for independent fault fixtures');

  PERFORM set_config('request.jwt.claim.sub', owner_a::text, true);
  PERFORM set_config('request.jwt.claims',
    jsonb_build_object('sub', owner_a, 'role', 'authenticated')::text, true);
  PERFORM public.initialize_user('{"environment":"gym","goals":["hypertrophy"],"experience_level":"beginner","age":25,"gender":"other","height_cm":170,"weight_kg":65,"preferred_training_days":["mon","wed","fri"],"primary_class_id":"B"}'::jsonb);
  workout_a := (public.start_workout()->>'id')::uuid;
  INSERT INTO public.workout_exercises(id, workout_id, exercise_id, order_index) VALUES
    (we_a, workout_a, catalog[1], 0),
    (we_b, workout_a, catalog[2], 1),
    (we_c, workout_a, catalog[3], 2);

  PERFORM set_config('request.jwt.claim.sub', owner_b::text, true);
  PERFORM set_config('request.jwt.claims',
    jsonb_build_object('sub', owner_b, 'role', 'authenticated')::text, true);
  PERFORM public.initialize_user('{"environment":"gym","goals":["hypertrophy"],"experience_level":"beginner","age":25,"gender":"other","height_cm":170,"weight_kg":65,"preferred_training_days":["mon","wed","fri"],"primary_class_id":"B"}'::jsonb);
  workout_b := (public.start_workout()->>'id')::uuid;
  INSERT INTO public.workout_exercises(id, workout_id, exercise_id, order_index)
    VALUES (we_foreign, workout_b, catalog[4], 0);

  PERFORM set_config('request.jwt.claim.sub', owner_a::text, true);
  PERFORM set_config('request.jwt.claims',
    jsonb_build_object('sub', owner_a, 'role', 'authenticated')::text, true);

  reorder_result := public.reorder_workout_exercises_v1(
    reorder_key, workout_a, ARRAY[we_c, we_a, we_b]);
  PERFORM pg_temp.p95_expect(
    (reorder_result->>'operation_id')::uuid = reorder_key
    AND (SELECT order_index = 0 FROM public.workout_exercises WHERE id = we_c)
    AND (SELECT order_index = 1 FROM public.workout_exercises WHERE id = we_a)
    AND (SELECT order_index = 2 FROM public.workout_exercises WHERE id = we_b)
    AND pg_temp.p95_ledger_count(owner_a, reorder_key) = 1,
    'reorder commits the complete permutation and one receipt');
  PERFORM pg_temp.p95_expect(
    public.reorder_workout_exercises_v1(reorder_key, workout_a, ARRAY[we_c, we_a, we_b]) = reorder_result,
    'same reorder key and body replays exact receipt');

  denied := false;
  BEGIN
    PERFORM public.reorder_workout_exercises_v1(reorder_key, workout_a, ARRAY[we_a, we_b, we_c]);
  EXCEPTION WHEN unique_violation THEN denied := true;
  END;
  PERFORM pg_temp.p95_expect(denied, 'changed reorder payload with same key is rejected');

  FOREACH fault_add_key IN ARRAY ARRAY[
    '95000000-0000-4000-8000-000000000023'::uuid,
    '95000000-0000-4000-8000-000000000024'::uuid,
    '95000000-0000-4000-8000-000000000025'::uuid
  ] LOOP
    denied := false;
    BEGIN
      IF fault_add_key = '95000000-0000-4000-8000-000000000023'::uuid THEN
        PERFORM public.reorder_workout_exercises_v1(fault_add_key, workout_a, ARRAY[we_c, we_a]);
      ELSIF fault_add_key = '95000000-0000-4000-8000-000000000024'::uuid THEN
        PERFORM public.reorder_workout_exercises_v1(fault_add_key, workout_a, ARRAY[we_c, we_a, we_a]);
      ELSE
        PERFORM public.reorder_workout_exercises_v1(fault_add_key, workout_a, ARRAY[we_c, we_a, we_foreign]);
      END IF;
    EXCEPTION WHEN SQLSTATE '22023' OR insufficient_privilege THEN denied := true;
    END;
    PERFORM pg_temp.p95_expect(denied
      AND pg_temp.p95_ledger_count(owner_a, fault_add_key) = 0
      AND (SELECT order_index = 0 FROM public.workout_exercises WHERE id = we_c)
      AND (SELECT order_index = 1 FROM public.workout_exercises WHERE id = we_a)
      AND (SELECT order_index = 2 FROM public.workout_exercises WHERE id = we_b),
      'invalid permutation is rejected without mutation or receipt');
  END LOOP;

  denied := false;
  BEGIN
    PERFORM public.reorder_workout_exercises_v1(
      '95000000-0000-4000-8000-000000000026', workout_b, ARRAY[we_foreign]);
  EXCEPTION WHEN SQLSTATE '22023' OR insufficient_privilege THEN denied := true;
  END;
  PERFORM pg_temp.p95_expect(denied,
    'another owner cannot reorder a foreign workout');

  PERFORM setval('pg_temp.p95_reorder_attempts', 1, false);
  PERFORM set_config('p95.fail_reorder', 'on', true);
  denied := false;
  BEGIN
    PERFORM public.reorder_workout_exercises_v1(
      fault_key, workout_a, ARRAY[we_a, we_b, we_c]);
  EXCEPTION WHEN SQLSTATE 'P0001' THEN denied := true;
  END;
  PERFORM set_config('p95.fail_reorder', 'off', true);
  PERFORM pg_temp.p95_expect(denied,
    'second UPDATE trigger raises inside reorder RPC');
  PERFORM pg_temp.p95_expect(
    (SELECT last_value = 2 FROM pg_temp.p95_reorder_attempts),
    'reorder trigger reached the second row');
  PERFORM pg_temp.p95_expect(
    (SELECT order_index = 0 FROM public.workout_exercises WHERE id = we_c)
    AND (SELECT order_index = 1 FROM public.workout_exercises WHERE id = we_a)
    AND (SELECT order_index = 2 FROM public.workout_exercises WHERE id = we_b),
    'second UPDATE failure rolls back all order indexes');
  PERFORM pg_temp.p95_expect(
    pg_temp.p95_ledger_count(owner_a, fault_key) = 0,
    'second UPDATE failure leaves no operation receipt');
  PERFORM public.reorder_workout_exercises_v1(
    fault_key, workout_a, ARRAY[we_a, we_b, we_c]);
  PERFORM pg_temp.p95_expect(pg_temp.p95_ledger_count(owner_a, fault_key) = 1,
    'same reorder key can retry after transaction failure');

  add_result := public.add_workout_exercise_with_sets_v1(
    add_key, workout_a, catalog[5], NULL, set_payload);
  PERFORM pg_temp.p95_expect(
    (add_result->>'operation_id')::uuid = add_key
    AND (add_result->>'workout_id')::uuid = workout_a
    AND (add_result->>'workout_exercise_id')::uuid IS NOT NULL
    AND jsonb_array_length(add_result->'set_ids') = 3
    AND (SELECT order_index = 3 FROM public.workout_exercises
      WHERE id = (add_result->>'workout_exercise_id')::uuid)
    AND (SELECT count(*) = 3 FROM public.workout_sets
      WHERE workout_exercise_id = (add_result->>'workout_exercise_id')::uuid)
    AND pg_temp.p95_ledger_count(owner_a, add_key) = 1
    AND NOT EXISTS (SELECT 1 FROM public.workout_rewards WHERE workout_id = workout_a)
    AND (SELECT total_xp = 0 FROM public.users WHERE id = owner_a),
    'add commits one exercise with all three sets and one receipt');
  replay_result := public.add_workout_exercise_with_sets_v1(
    add_key, workout_a, catalog[5], NULL, set_payload);
  PERFORM pg_temp.p95_expect(replay_result = add_result
    AND (SELECT count(*) = 1 FROM public.workout_exercises
      WHERE workout_id = workout_a AND exercise_id = catalog[5]),
    'same add key and body replays exact receipt without duplicate exercise');
  replay_result := public.add_workout_exercise_with_sets_v1(
    add_key, workout_a, catalog[5], NULL,
    jsonb_set(set_payload, '{0,weight_kg}', '20.0'::jsonb));
  PERFORM pg_temp.p95_expect(replay_result = add_result
    AND pg_temp.p95_ledger_count(owner_a, add_key) = 1,
    'equivalent numeric weight replays the same normalized operation');
  denied := false;
  BEGIN
    PERFORM public.add_workout_exercise_with_sets_v1(
      add_key, workout_a, catalog[5], NULL,
      '[{"reps":11,"weight_kg":20,"duration_seconds":0}]'::jsonb);
  EXCEPTION WHEN unique_violation THEN denied := true;
  END;
  PERFORM pg_temp.p95_expect(denied,
    'changed add payload with same key is rejected');

  denied := false;
  BEGIN
    PERFORM public.add_workout_exercise_with_sets_v1(
      invalid_key, workout_a, catalog[6], NULL,
      '[{"reps":10,"weight_kg":20,"duration_seconds":0},{"reps":-1,"weight_kg":20,"duration_seconds":0}]'::jsonb);
  EXCEPTION WHEN SQLSTATE '22023' THEN denied := true;
  END;
  PERFORM pg_temp.p95_expect(denied
    AND NOT EXISTS (SELECT 1 FROM public.workout_exercises
      WHERE workout_id = workout_a AND exercise_id = catalog[6])
    AND pg_temp.p95_ledger_count(owner_a, invalid_key) = 0,
    'invalid later set cannot leave parent or receipt');

  FOR failing_set IN 1..3 LOOP
    fault_add_key := ('95000000-0000-4000-8000-00000000004' || failing_set)::uuid;
    PERFORM set_config('p95.fail_set', failing_set::text, true);
    denied := false;
    BEGIN
      PERFORM public.add_workout_exercise_with_sets_v1(
        fault_add_key, workout_a, catalog[6 + failing_set], NULL, set_payload);
    EXCEPTION WHEN SQLSTATE 'P0001' THEN denied := true;
    END;
    PERFORM set_config('p95.fail_set', '', true);
    PERFORM pg_temp.p95_expect(denied
      AND NOT EXISTS (SELECT 1 FROM public.workout_exercises
        WHERE workout_id = workout_a AND exercise_id = catalog[6 + failing_set])
      AND pg_temp.p95_ledger_count(owner_a, fault_add_key) = 0,
      'injected set stage rolls back parent, children and receipt');
    PERFORM public.add_workout_exercise_with_sets_v1(
      fault_add_key, workout_a, catalog[6 + failing_set], NULL, set_payload);
    PERFORM pg_temp.p95_expect(pg_temp.p95_ledger_count(owner_a, fault_add_key) = 1,
      'same add key retries after injected failure');
  END LOOP;

  denied := false;
  BEGIN
    PERFORM public.add_workout_exercise_with_sets_v1(
      '95000000-0000-4000-8000-000000000050', workout_b, catalog[10], NULL, set_payload);
  EXCEPTION WHEN SQLSTATE '22023' OR insufficient_privilege THEN denied := true;
  END;
  PERFORM pg_temp.p95_expect(denied,
    'another owner cannot add to a foreign workout');

  PERFORM public.begin_workout(workout_a);
  UPDATE public.workout_sets SET is_completed = true
    WHERE id = (add_result->'set_ids'->>0)::uuid;
  PERFORM public.complete_workout(workout_a);
  SELECT total_xp INTO xp_after_completion FROM public.users WHERE id = owner_a;
  PERFORM pg_temp.p95_expect(
    (SELECT status = 'completed' FROM public.workouts WHERE id = workout_a)
    AND (SELECT count(*) = 1 FROM public.workout_rewards WHERE workout_id = workout_a),
    'fixture reaches completed state through authoritative award path');
  PERFORM pg_temp.p95_expect(
    public.reorder_workout_exercises_v1(
      reorder_key, workout_a, ARRAY[we_c, we_a, we_b]) = reorder_result
    AND public.add_workout_exercise_with_sets_v1(
      add_key, workout_a, catalog[5], NULL, set_payload) = add_result
    AND (SELECT total_xp = xp_after_completion FROM public.users WHERE id = owner_a),
    'committed operation keys replay after completion without a new award');

  denied := false;
  BEGIN
    PERFORM public.reorder_workout_exercises_v1(
      '95000000-0000-4000-8000-000000000051', workout_a,
      ARRAY[we_a, we_b, we_c]);
  EXCEPTION WHEN insufficient_privilege THEN denied := true;
  END;
  PERFORM pg_temp.p95_expect(denied
    AND pg_temp.p95_ledger_count(owner_a,
      '95000000-0000-4000-8000-000000000051') = 0,
    'new reorder key cannot mutate completed workout');

  denied := false;
  BEGIN
    PERFORM public.add_workout_exercise_with_sets_v1(
      '95000000-0000-4000-8000-000000000052', workout_a,
      catalog[10], NULL, set_payload);
  EXCEPTION WHEN insufficient_privilege THEN denied := true;
  END;
  PERFORM pg_temp.p95_expect(denied
    AND pg_temp.p95_ledger_count(owner_a,
      '95000000-0000-4000-8000-000000000052') = 0
    AND (SELECT total_xp = xp_after_completion FROM public.users WHERE id = owner_a),
    'new add key cannot mutate completed workout or rewards');
END $$;

ROLLBACK;
