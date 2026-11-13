BEGIN;
CREATE FUNCTION pg_temp.assert_true(ok boolean, label text) RETURNS void
LANGUAGE plpgsql AS $$ BEGIN
  IF ok IS DISTINCT FROM true THEN RAISE EXCEPTION 'FAIL: %', label; END IF;
END $$;

SELECT pg_temp.assert_true(public.class_level_for_xp_v1(0,80,1.40)=1,
  'zero class XP starts at level 1');
SELECT pg_temp.assert_true(public.class_level_for_xp_v1(79,80,1.40)=1
  AND public.class_level_for_xp_v1(80,80,1.40)=1,
  'level-1 base is not the level-2 threshold');
SELECT pg_temp.assert_true(public.class_level_for_xp_v1(210,80,1.40)=1
  AND public.class_level_for_xp_v1(211,80,1.40)=2,
  'class A level-2 golden boundary matches Dart');
SELECT pg_temp.assert_true(public.class_level_for_xp_v1(5302,80,1.40)=19
  AND public.class_level_for_xp_v1(5303,80,1.40)=20,
  'class A graduation golden boundary matches Dart');
SELECT pg_temp.assert_true((SELECT bool_and(
  public.class_level_for_xp_v1(
    floor(xp_base*power(2,xp_slope))::integer-1,xp_base,xp_slope)=1
  AND public.class_level_for_xp_v1(
    floor(xp_base*power(2,xp_slope))::integer,xp_base,xp_slope)=2)
  FROM public.class_definitions),
  'all class definitions agree at the level-2 boundary');
SELECT pg_temp.assert_true(NOT has_function_privilege('authenticated',
  'public.class_level_for_xp_v1(integer,integer,numeric)','EXECUTE'),
  'class threshold helper is server-only');

INSERT INTO auth.users(id,email,raw_user_meta_data)
VALUES ('a9000000-0000-4000-8000-000000000003','p9-progression@example.test','{}');
SELECT set_config('request.jwt.claim.sub','a9000000-0000-4000-8000-000000000003',true);
SELECT set_config('request.jwt.claims','{"sub":"a9000000-0000-4000-8000-000000000003","role":"authenticated"}',true);
SET LOCAL ROLE authenticated;
SELECT public.initialize_user('{"environment":"home","goals":["hypertrophy"],"experience_level":"beginner","age":25,"gender":"other","height_cm":170,"weight_kg":65,"weekly_gym_days":0,"weekly_home_days":3,"preferred_training_days":["mon","wed","fri"],"primary_class_id":"A"}');
RESET ROLE;

-- The D-043 cumulative threshold for class A level 2 is floor(80 * 2^1.4) = 211.
UPDATE public.user_classes SET current_xp=210, level=1
WHERE user_id='a9000000-0000-4000-8000-000000000003' AND class_id='A';
SET LOCAL ROLE authenticated;
SELECT pg_temp.assert_true((public.switch_class('A','primary')->>'level')::integer=1,
  'class A remains level 1 at 210 XP');
RESET ROLE;

-- A future award below the 211-XP boundary must not apply the old SQL threshold.
UPDATE public.user_classes SET current_xp=205, level=1
WHERE user_id='a9000000-0000-4000-8000-000000000003' AND class_id='A';
INSERT INTO public.workouts(id,user_id,status,training_started_at)
VALUES ('a9000000-0000-4000-8000-000000000031',
  'a9000000-0000-4000-8000-000000000003','active',now()-interval '10 minutes');
INSERT INTO public.workout_exercises(id,workout_id,exercise_id,order_index)
SELECT 'a9000000-0000-4000-8000-000000000032',
  'a9000000-0000-4000-8000-000000000031',id,0
FROM public.exercises ORDER BY id LIMIT 1;
INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,is_completed)
VALUES ('a9000000-0000-4000-8000-000000000032',1,10,20,true);
SET LOCAL ROLE authenticated;
SELECT public.complete_workout('a9000000-0000-4000-8000-000000000031');
RESET ROLE;
SELECT pg_temp.assert_true((SELECT current_xp < 211 AND level=1
  FROM public.user_classes WHERE user_id='a9000000-0000-4000-8000-000000000003'
    AND class_id='A'), 'future award below D-043 threshold leaves class at level 1');

UPDATE public.user_classes SET current_xp=211, level=1
WHERE user_id='a9000000-0000-4000-8000-000000000003' AND class_id='A';
SET LOCAL ROLE authenticated;
SELECT pg_temp.assert_true((public.switch_class('A','primary')->>'level')::integer=2,
  'class A reaches level 2 at 211 XP');
RESET ROLE;

-- Existing level is a floor even when its XP is below the corrected threshold.
UPDATE public.user_classes SET current_xp=80, level=2
WHERE user_id='a9000000-0000-4000-8000-000000000003' AND class_id='A';
SET LOCAL ROLE authenticated;
SELECT pg_temp.assert_true((public.switch_class('A','primary')->>'level')::integer=2,
  'corrected rule never downgrades a stored class level');
SELECT public.switch_class('C','primary');
SELECT pg_temp.assert_true((public.switch_class('A','primary')->>'level')::integer=2,
  'grandfathered level survives switching away and back');
RESET ROLE;
SELECT pg_temp.assert_true(NOT has_table_privilege('authenticated',
  'public.class_level_floors','SELECT,INSERT,UPDATE,DELETE'),
  'clients cannot read or mutate server-owned level floors');
ROLLBACK;
