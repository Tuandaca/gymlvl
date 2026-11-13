-- P9.2 historical import contract. Disposable database; all fixtures roll back.
BEGIN;

CREATE FUNCTION pg_temp.p92_expect(ok boolean, label text) RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
  IF ok IS DISTINCT FROM true THEN RAISE EXCEPTION 'P9.2 FAIL: %', label; END IF;
END $$;

SELECT pg_temp.p92_expect(
  to_regprocedure('public.import_historical_workout_v1(text,jsonb)') IS NOT NULL,
  'transactional historical import RPC exists'
);

INSERT INTO auth.users(id, email) VALUES
  ('92000000-0000-4000-8000-000000000001', 'p92-owner-a@example.test'),
  ('92000000-0000-4000-8000-000000000002', 'p92-owner-b@example.test');

SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub', '92000000-0000-4000-8000-000000000001', true);
SELECT set_config('request.jwt.claims', '{"sub":"92000000-0000-4000-8000-000000000001","role":"authenticated"}', true);
SELECT public.initialize_user('{"environment":"gym","goals":["hypertrophy"],"experience_level":"beginner","age":25,"gender":"other","height_cm":170,"weight_kg":65,"preferred_training_days":["mon","wed","fri"],"primary_class_id":"B"}'::jsonb);

DO $$
DECLARE
  owner_a uuid := '92000000-0000-4000-8000-000000000001';
  owner_b uuid := '92000000-0000-4000-8000-000000000002';
  exercise_id uuid;
  second_exercise_id uuid;
  active_id uuid;
  imported_id uuid;
  v2_id uuid;
  retry_result jsonb;
  payload jsonb;
  v2_payload jsonb;
  first_result jsonb;
  denied boolean;
  accepted boolean;
  remapped_group_id uuid;
  second_group_id uuid;
  other_owner_source_id uuid;
  catalogue_source text;
  catalogue_external_id text;
  catalogue_revision text;
BEGIN
  SELECT id INTO exercise_id FROM public.exercises WHERE source <> 'user' ORDER BY id LIMIT 1;
  PERFORM pg_temp.p92_expect(exercise_id IS NOT NULL, 'catalogue fixture exists');
  SELECT id INTO second_exercise_id FROM public.exercises
    WHERE source <> 'user' AND id <> exercise_id ORDER BY id LIMIT 1;
  PERFORM pg_temp.p92_expect(second_exercise_id IS NOT NULL, 'second catalogue fixture exists');
  SELECT source, external_id, source_revision
    INTO catalogue_source, catalogue_external_id, catalogue_revision
    FROM public.exercises WHERE id = exercise_id;
  active_id := (public.start_workout()->>'id')::uuid;

  payload := jsonb_build_object(
    'started_at', '2026-11-01T10:00:00Z',
    'completed_at', '2026-11-01T11:00:00Z',
    'duration_seconds', 3600,
    'notes', 'imported history',
    'exercises', jsonb_build_array(jsonb_build_object(
      'exercise_id', exercise_id,
      'order_index', 0,
      'sets', jsonb_build_array(
        jsonb_build_object('set_number', 1, 'reps', 5, 'weight_kg', 20, 'duration_seconds', 0, 'set_type', 'warmup'),
        jsonb_build_object('set_number', 2, 'reps', 10, 'weight_kg', 40, 'duration_seconds', 0, 'set_type', 'workout')
      )
    ))
  );

  first_result := public.import_historical_workout_v1('p92-source-key', payload);
  imported_id := (first_result->>'workoutId')::uuid;
  PERFORM pg_temp.p92_expect(imported_id IS NOT NULL AND (first_result->>'alreadyImported')::boolean = false,
    'first import returns new workout receipt');
  PERFORM pg_temp.p92_expect(imported_id <> active_id AND
    EXISTS (SELECT 1 FROM public.workouts WHERE id = active_id AND user_id = owner_a AND status = 'active') AND
    NOT EXISTS (SELECT 1 FROM public.workout_exercises WHERE workout_id = active_id),
    'import never merges into existing active workout');
  PERFORM pg_temp.p92_expect(
    EXISTS (SELECT 1 FROM public.workouts WHERE id = imported_id AND user_id = owner_a
      AND status = 'completed' AND completed_at IS NOT NULL AND is_imported = true) AND
    (SELECT count(*) = 2 FROM public.workout_sets s
      JOIN public.workout_exercises we ON we.id = s.workout_exercise_id
      WHERE we.workout_id = imported_id AND s.is_completed) AND
    EXISTS (SELECT 1 FROM public.workout_sets s
      JOIN public.workout_exercises we ON we.id = s.workout_exercise_id
      WHERE we.workout_id = imported_id AND s.set_type = 'warmup'),
    'import commits completed history and warmup without progression');
  PERFORM pg_temp.p92_expect(
    NOT EXISTS (SELECT 1 FROM public.workout_rewards WHERE workout_id = imported_id) AND
    NOT EXISTS (SELECT 1 FROM public.xp_logs WHERE user_id = owner_a AND source_id = imported_id::text) AND
    (SELECT total_xp = 0 FROM public.users WHERE id = owner_a),
    'historical import grants no XP or reward');

  denied := false;
  BEGIN
    UPDATE public.workouts SET is_imported = false WHERE id = imported_id;
  EXCEPTION WHEN insufficient_privilege THEN denied := true;
  END;
  PERFORM pg_temp.p92_expect(denied AND
    (SELECT is_imported FROM public.workouts WHERE id = imported_id),
    'authenticated client cannot clear imported marker');

  denied := false;
  BEGIN
    INSERT INTO public.workouts(id, user_id, status, is_imported)
    VALUES ('92000000-0000-4000-8000-000000000091', owner_a, 'completed', true);
  EXCEPTION WHEN insufficient_privilege THEN denied := true;
  END;
  PERFORM pg_temp.p92_expect(denied AND NOT EXISTS
    (SELECT 1 FROM public.workouts WHERE id = '92000000-0000-4000-8000-000000000091'),
    'authenticated client cannot forge imported marker');

  -- A caller cannot later turn imported history into a rewarded completion.
  BEGIN
    PERFORM public.complete_workout(imported_id);
  EXCEPTION WHEN SQLSTATE '22023' OR insufficient_privilege THEN NULL;
  END;
  PERFORM pg_temp.p92_expect(
    NOT EXISTS (SELECT 1 FROM public.workout_rewards WHERE workout_id = imported_id) AND
    NOT EXISTS (SELECT 1 FROM public.xp_logs WHERE user_id = owner_a AND source_id = imported_id::text) AND
    (SELECT total_xp = 0 FROM public.users WHERE id = owner_a),
    'complete_workout cannot award imported history later');

  retry_result := public.import_historical_workout_v1('p92-source-key', payload);
  PERFORM pg_temp.p92_expect(
    (retry_result->>'workoutId')::uuid = imported_id AND
    (retry_result->>'alreadyImported')::boolean = true AND
    (SELECT count(*) = 1 FROM public.workouts WHERE user_id = owner_a AND status = 'completed'),
    'same owner/key/payload is idempotent');

  denied := false;
  BEGIN
    PERFORM public.import_historical_workout_v1('p92-source-key',
      jsonb_set(payload, '{notes}', '"conflicting content"'::jsonb));
  EXCEPTION WHEN SQLSTATE '22023' THEN denied := true;
  END;
  PERFORM pg_temp.p92_expect(denied, 'same owner/key with changed payload is rejected');

  denied := false;
  BEGIN
    PERFORM public.import_historical_workout_v1('p92-invalid-key',
      jsonb_set(payload, '{exercises,0,exercise_id}',
        '"92000000-0000-4000-8000-000000000099"'::jsonb));
  EXCEPTION WHEN SQLSTATE '22023' OR foreign_key_violation OR insufficient_privilege THEN denied := true;
  END;
  PERFORM pg_temp.p92_expect(denied AND
    (SELECT count(*) = 1 FROM public.workouts WHERE user_id = owner_a AND status = 'completed'),
    'invalid exercise rolls back whole import');

  denied := false;
  BEGIN
    PERFORM public.import_historical_workout_v1('p92-existing-source-workout',
      jsonb_set(payload,'{source_workout_id}',to_jsonb(active_id)));
  EXCEPTION WHEN SQLSTATE '22023' THEN denied := true;
  END;
  PERFORM pg_temp.p92_expect(denied AND
    (SELECT count(*)=1 FROM public.workouts WHERE user_id=owner_a AND is_imported),
    'existing same-owner source workout UUID cannot be cloned by import RPC');
  accepted := false;
  BEGIN
    retry_result := public.import_historical_workout_v1('p92-new-source-workout',
      jsonb_set(payload,'{source_workout_id}',
        '"92000000-0000-4000-8000-000000000088"'::jsonb));
    accepted := (retry_result->>'workoutId') IS NOT NULL;
    RAISE EXCEPTION 'rollback accepted source fixture' USING ERRCODE='P0002';
  EXCEPTION WHEN SQLSTATE 'P0002' THEN NULL;
  END;
  PERFORM pg_temp.p92_expect(accepted AND
    (SELECT count(*)=1 FROM public.workouts WHERE user_id=owner_a AND is_imported),
    'new source workout UUID is accepted and does not alter existing history');

  -- V2 fields must round-trip as one atomic historical workout.
  v2_payload := jsonb_build_object(
    'started_at','2026-11-02T10:00:00Z',
    'training_started_at','2026-11-02T10:05:00Z',
    'completed_at','2026-11-02T11:00:00Z',
    'paused_at',NULL,
    'paused_seconds',60,
    'duration_seconds',3240,
    'exercises',jsonb_build_array(
      jsonb_build_object('exercise_id',exercise_id,'order_index',0,
        'exercise_source',catalogue_source,
        'exercise_external_id',catalogue_external_id,
        'exercise_source_revision',catalogue_revision,
        'mode','reps-weight',
        'superset_group_id','92000000-0000-4000-8000-000000000050',
        'superset_position',0,'superset_locked',true,
        'sets',jsonb_build_array(jsonb_build_object('set_number',1,'reps',5,
          'weight_kg',20,'duration_seconds',0,'rest_seconds',45,
          'is_completed',true,'set_type','warmup',
          'baseline_weight_kg',10,'rpe',5,'rir',3))),
      jsonb_build_object('exercise_id',second_exercise_id,'order_index',1,
        'mode','reps-weight',
        'superset_group_id','92000000-0000-4000-8000-000000000050',
        'superset_position',1,'superset_locked',true,
        'sets',jsonb_build_array(jsonb_build_object('set_number',1,'reps',10,
          'weight_kg',40,'duration_seconds',0,'rest_seconds',90,
          'is_completed',true,'set_type','workout',
          'baseline_weight_kg',20,'rpe',8,'rir',2)))
      ,jsonb_build_object('exercise_id',exercise_id,'order_index',2,
        'mode','reps-weight','sets',jsonb_build_array())
    )
  );
  retry_result := public.import_historical_workout_v1('p92-v2-fields',v2_payload);
  v2_id := (retry_result->>'workoutId')::uuid;
  PERFORM pg_temp.p92_expect(
    EXISTS (SELECT 1 FROM public.workouts WHERE id=v2_id AND user_id=owner_a
      AND training_started_at='2026-11-02T10:05:00Z'::timestamptz
      AND completed_at='2026-11-02T11:00:00Z'::timestamptz
      AND paused_at IS NULL AND paused_seconds=60 AND duration_seconds=3240) AND
    (SELECT count(*)=2 FROM public.workout_exercises
      WHERE workout_id=v2_id AND superset_group_id IS NOT NULL
        AND superset_locked AND mode='reps-weight') AND
    EXISTS (SELECT 1 FROM public.workout_sets s
      JOIN public.workout_exercises we ON we.id=s.workout_exercise_id
      WHERE we.workout_id=v2_id AND we.superset_position=0
        AND s.set_type='warmup' AND s.is_completed AND s.rest_seconds=45
        AND s.baseline_weight_kg=10 AND s.rpe=5 AND s.rir=3) AND
    EXISTS (SELECT 1 FROM public.workout_sets s
      JOIN public.workout_exercises we ON we.id=s.workout_exercise_id
      WHERE we.workout_id=v2_id AND we.superset_position=1
        AND s.set_type='workout' AND s.is_completed AND s.rest_seconds=90
        AND s.baseline_weight_kg=20 AND s.rpe=8 AND s.rir=2),
    'v2 workout chronology superset warmup and set metrics round-trip');
  SELECT DISTINCT we.superset_group_id INTO remapped_group_id
    FROM public.workout_exercises we
    WHERE we.workout_id=v2_id AND we.superset_group_id IS NOT NULL;
  PERFORM pg_temp.p92_expect(remapped_group_id IS NOT NULL AND
    remapped_group_id <> '92000000-0000-4000-8000-000000000050'::uuid,
    'import remaps source superset group UUID while preserving group members');
  accepted := false;
  BEGIN
    retry_result := public.import_historical_workout_v1('p92-v2-same-source-group',v2_payload);
    SELECT DISTINCT we.superset_group_id INTO second_group_id
      FROM public.workout_exercises we
      WHERE we.workout_id=(retry_result->>'workoutId')::uuid
        AND we.superset_group_id IS NOT NULL;
    accepted := second_group_id IS NOT NULL AND second_group_id <> remapped_group_id
      AND second_group_id <> '92000000-0000-4000-8000-000000000050'::uuid;
    RAISE EXCEPTION 'rollback second group fixture' USING ERRCODE='P0002';
  EXCEPTION WHEN SQLSTATE 'P0002' THEN NULL;
  END;
  PERFORM pg_temp.p92_expect(accepted,
    'two imported workouts may share a source group UUID but persist distinct groups');
  PERFORM pg_temp.p92_expect(
    EXISTS (SELECT 1 FROM public.workout_exercises we
      WHERE we.workout_id=v2_id AND we.order_index=2
        AND we.exercise_id=(v2_payload #>> '{exercises,2,exercise_id}')::uuid
        AND NOT EXISTS (SELECT 1 FROM public.workout_sets s WHERE s.workout_exercise_id=we.id)),
    'v2 preserves workout exercise with zero sets');

  denied := false;
  BEGIN
    PERFORM public.import_historical_workout_v1('p92-mismatch-source',
      jsonb_set(v2_payload,'{exercises,0,exercise_source}','"foreign-source"'::jsonb));
  EXCEPTION WHEN SQLSTATE '22023' THEN denied := true;
  END;
  PERFORM pg_temp.p92_expect(denied AND
    (SELECT count(*)=2 FROM public.workouts WHERE user_id=owner_a AND is_imported),
    'mismatched exercise source manifest rolls back whole workout');

  denied := false;
  BEGIN
    PERFORM public.import_historical_workout_v1('p92-mismatch-revision',
      jsonb_set(v2_payload,'{exercises,0,exercise_source_revision}','"wrong-revision"'::jsonb));
  EXCEPTION WHEN SQLSTATE '22023' THEN denied := true;
  END;
  PERFORM pg_temp.p92_expect(denied AND
    (SELECT count(*)=2 FROM public.workouts WHERE user_id=owner_a AND is_imported),
    'mismatched exercise revision manifest rolls back whole workout');

  denied := false;
  BEGIN
    PERFORM public.import_historical_workout_v1('p92-invalid-layout',
      jsonb_set(v2_payload,'{exercises,1,superset_position}','0'::jsonb));
  EXCEPTION WHEN SQLSTATE '22023' OR unique_violation OR check_violation THEN denied := true;
  END;
  PERFORM pg_temp.p92_expect(denied AND
    (SELECT count(*)=2 FROM public.workouts WHERE user_id=owner_a AND is_imported),
    'invalid superset layout rolls back whole workout');

  denied := false;
  BEGIN
    PERFORM public.import_historical_workout_v1('p92-invalid-paused-at',
      jsonb_set(v2_payload,'{paused_at}','"2026-11-02T10:30:00Z"'::jsonb));
  EXCEPTION WHEN SQLSTATE '22023' THEN denied := true;
  END;
  PERFORM pg_temp.p92_expect(denied,
    'completed historical workout rejects non-null paused_at');

  PERFORM set_config('request.jwt.claim.sub', owner_b::text, true);
  PERFORM set_config('request.jwt.claims',
    json_build_object('sub', owner_b::text, 'role', 'authenticated')::text, true);
  PERFORM public.initialize_user('{"environment":"gym","goals":["hypertrophy"],"experience_level":"beginner","age":25,"gender":"other","height_cm":170,"weight_kg":65,"preferred_training_days":["mon","wed","fri"],"primary_class_id":"B"}'::jsonb);
  retry_result := public.import_historical_workout_v1('p92-source-key', payload);
  PERFORM pg_temp.p92_expect(
    (retry_result->>'workoutId')::uuid <> imported_id AND
    (retry_result->>'alreadyImported')::boolean = false AND
    EXISTS (SELECT 1 FROM public.workouts WHERE id = (retry_result->>'workoutId')::uuid AND user_id = owner_b),
    'same import key is scoped to authenticated owner');
  other_owner_source_id := (public.start_workout()->>'id')::uuid;
  PERFORM set_config('request.jwt.claim.sub',owner_a::text,true);
  PERFORM set_config('request.jwt.claims',
    json_build_object('sub',owner_a::text,'role','authenticated')::text,true);
  accepted := false;
  BEGIN
    retry_result := public.import_historical_workout_v1('p92-other-owner-source-opaque',
      jsonb_set(payload,'{source_workout_id}',to_jsonb(other_owner_source_id)));
    accepted := (retry_result->>'workoutId') IS NOT NULL;
    RAISE EXCEPTION 'rollback cross-owner source fixture' USING ERRCODE='P0002';
  EXCEPTION WHEN SQLSTATE 'P0002' THEN NULL;
  END;
  PERFORM pg_temp.p92_expect(accepted,
    'another owner source UUID behaves like an absent same-owner source UUID');
END $$;

ROLLBACK;
