-- P3 — Workout Core Parity: warm-up set support verification.
-- Runs on PGlite against all migrations (additive only; production not applied).
BEGIN;
CREATE FUNCTION pg_temp.p3_assert_true(ok boolean,label text) RETURNS void LANGUAGE plpgsql AS $$ BEGIN IF ok IS DISTINCT FROM true THEN RAISE EXCEPTION 'FAIL: %',label; END IF; END $$;

-- set_type column exists on workout_sets
SELECT pg_temp.p3_assert_true(
  EXISTS(SELECT 1 FROM information_schema.columns
         WHERE table_schema='public' AND table_name='workout_sets' AND column_name='set_type'),
  'workout_sets.set_type column exists'
);

-- validity constraint exists
SELECT pg_temp.p3_assert_true(
  EXISTS(SELECT 1 FROM pg_constraint WHERE conname='workout_sets_set_type_valid'),
  'workout_sets_set_type_valid constraint exists'
);

-- default is 'workout' (legacy rows keep working-set semantics)
SELECT pg_temp.p3_assert_true(
  (SELECT column_default FROM information_schema.columns
   WHERE table_schema='public' AND table_name='workout_sets' AND column_name='set_type')
  LIKE '%workout%',
  'workout_sets.set_type default is workout'
);

-- Owner-scoped insert of warm-up and working sets
INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES('11111111-1111-1111-1111-111111111111','qa-p3@example.test','{}');
SELECT set_config('request.jwt.claim.sub','11111111-1111-1111-1111-111111111111',true);
SELECT set_config('request.jwt.claims','{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}',true);
INSERT INTO public.workouts(id,user_id,status,training_started_at)
  VALUES('22222222-2222-2222-2222-222222222222','11111111-1111-1111-1111-111111111111','active',now());
INSERT INTO public.workout_exercises(id,workout_id,exercise_id)
  SELECT '33333333-3333-3333-3333-333333333333','22222222-2222-2222-2222-222222222222',id FROM public.exercises LIMIT 1;

INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,is_completed,set_type)
  VALUES('33333333-3333-3333-3333-333333333333',1,10,20,true,'workout');
INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,is_completed,set_type)
  VALUES('33333333-3333-3333-3333-333333333333',2,10,60,true,'warmup');

SELECT pg_temp.p3_assert_true(
  (SELECT set_type FROM public.workout_sets WHERE workout_exercise_id='33333333-3333-3333-3333-333333333333' AND set_number=1)='workout',
  'working set stores set_type workout'
);
SELECT pg_temp.p3_assert_true(
  (SELECT set_type FROM public.workout_sets WHERE workout_exercise_id='33333333-3333-3333-3333-333333333333' AND set_number=2)='warmup',
  'warm-up set stores set_type warmup'
);
SELECT pg_temp.p3_assert_true(
  (SELECT count(*) FROM public.workout_sets WHERE set_type NOT IN ('workout','warmup'))=0,
  'no invalid set_type values stored'
);
SELECT set_config('request.jwt.claim.sub','',true);
SELECT set_config('request.jwt.claims','{}',true);
ROLLBACK;
