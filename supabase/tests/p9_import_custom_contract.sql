-- P9.2 atomic custom-exercise descriptor contract. Fixtures roll back.
BEGIN;

CREATE FUNCTION pg_temp.p92_custom_expect(ok boolean, label text) RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
  IF ok IS DISTINCT FROM true THEN RAISE EXCEPTION 'P9.2 FAIL: %', label; END IF;
END $$;

INSERT INTO auth.users(id, email) VALUES
  ('93000000-0000-4000-8000-000000000001', 'p92-custom-a@example.test'),
  ('93000000-0000-4000-8000-000000000002', 'p92-custom-b@example.test');
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub', '93000000-0000-4000-8000-000000000001', true);
SELECT set_config('request.jwt.claims', '{"sub":"93000000-0000-4000-8000-000000000001","role":"authenticated"}', true);
SELECT public.initialize_user('{"environment":"gym","goals":["hypertrophy"],"experience_level":"beginner","age":25,"gender":"other","height_cm":170,"weight_kg":65,"preferred_training_days":["mon","wed","fri"],"primary_class_id":"B"}'::jsonb);

DO $$
DECLARE
  owner_a uuid := '93000000-0000-4000-8000-000000000001';
  owner_b uuid := '93000000-0000-4000-8000-000000000002';
  custom_id uuid := '93000000-0000-4000-8000-000000000011';
  failed_custom_id uuid := '93000000-0000-4000-8000-000000000012';
  descriptor jsonb;
  payload jsonb;
  result jsonb;
  first_id uuid;
  denied boolean;
BEGIN
  descriptor := jsonb_build_object('id',custom_id,'name','Private P9 Lift',
    'category','Arms','equipment','Dumbbell');
  payload := jsonb_build_object(
    'started_at','2026-11-01T10:00:00Z',
    'completed_at','2026-11-01T11:00:00Z',
    'duration_seconds',3600,
    'exercises',jsonb_build_array(jsonb_build_object(
      'custom_exercise',descriptor,'order_index',0,
      'sets',jsonb_build_array(jsonb_build_object('set_number',1,'reps',10,
        'weight_kg',20,'duration_seconds',0,'set_type','workout'))
    ))
  );

  result := public.import_historical_workout_v1('p92-custom-success',payload);
  first_id := (result->>'workoutId')::uuid;
  PERFORM pg_temp.p92_custom_expect(first_id IS NOT NULL AND
    (result->>'alreadyImported')::boolean = false AND
    result->'createdCustomExerciseIds' = jsonb_build_array(custom_id) AND
    EXISTS (SELECT 1 FROM public.exercises WHERE id=custom_id AND user_id=owner_a
      AND source='user' AND name='Private P9 Lift'
      AND name_vi='' AND name_en='' AND category='Arms'
      AND equipment='Dumbbell' AND image_url IS NULL
      AND external_id IS NULL AND source_revision IS NULL) AND
    EXISTS (SELECT 1 FROM public.workout_exercises WHERE workout_id=first_id
      AND exercise_id=custom_id),
    'custom descriptor and historical workout commit atomically without media');

  result := public.import_historical_workout_v1('p92-custom-success',payload);
  PERFORM pg_temp.p92_custom_expect(
    (result->>'workoutId')::uuid=first_id AND
    (result->>'alreadyImported')::boolean=true AND
    result->'createdCustomExerciseIds'=jsonb_build_array(custom_id) AND
    (SELECT count(*)=1 FROM public.exercises WHERE id=custom_id),
    'exact retry returns stable created custom IDs without duplicate rows');

  denied := false;
  BEGIN
    PERFORM public.import_historical_workout_v1('p92-custom-invalid-workout',
      jsonb_set(jsonb_set(payload,
        '{exercises,0,custom_exercise,id}',to_jsonb(failed_custom_id)),
        '{exercises,0,sets,0,reps}','-1'::jsonb));
  EXCEPTION WHEN SQLSTATE '22023' OR check_violation THEN denied := true;
  END;
  PERFORM pg_temp.p92_custom_expect(denied AND
    NOT EXISTS (SELECT 1 FROM public.exercises WHERE id=failed_custom_id) AND
    (SELECT count(*)=1 FROM public.workouts WHERE user_id=owner_a AND is_imported),
    'invalid workout rolls back its newly created custom exercise');

  denied := false;
  BEGIN
    PERFORM public.import_historical_workout_v1('p92-custom-media',
      jsonb_set(payload,'{exercises,0,custom_exercise,image_url}',
        '"https://example.invalid/image.jpg"'::jsonb));
  EXCEPTION WHEN SQLSTATE '22023' THEN denied := true;
  END;
  PERFORM pg_temp.p92_custom_expect(denied,
    'custom descriptor rejects media and unapproved provenance fields');

  PERFORM set_config('request.jwt.claim.sub',owner_b::text,true);
  PERFORM set_config('request.jwt.claims',
    json_build_object('sub',owner_b::text,'role','authenticated')::text,true);
  PERFORM public.initialize_user('{"environment":"gym","goals":["hypertrophy"],"experience_level":"beginner","age":25,"gender":"other","height_cm":170,"weight_kg":65,"preferred_training_days":["mon","wed","fri"],"primary_class_id":"B"}'::jsonb);
  denied := false;
  BEGIN
    PERFORM public.import_historical_workout_v1('p92-other-owner-collision',payload);
  EXCEPTION WHEN SQLSTATE '22023' OR unique_violation OR insufficient_privilege THEN denied := true;
  END;
  PERFORM pg_temp.p92_custom_expect(denied AND
    NOT EXISTS (SELECT 1 FROM public.workouts WHERE user_id=owner_b AND is_imported),
    'another owner cannot claim existing custom exercise UUID');
END $$;

ROLLBACK;
