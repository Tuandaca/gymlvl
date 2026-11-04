-- Disposable local/test contract verification; no production database writes.
BEGIN;
CREATE FUNCTION pg_temp.assert_m3(ok boolean, label text) RETURNS void
LANGUAGE plpgsql AS $$ BEGIN
  IF ok IS DISTINCT FROM true THEN RAISE EXCEPTION 'FAIL: %', label; END IF;
END $$;
CREATE FUNCTION pg_temp.expect_m3_error(statement text, expected text) RETURNS void
LANGUAGE plpgsql AS $$ BEGIN
  BEGIN
    EXECUTE statement;
  EXCEPTION WHEN OTHERS THEN
    IF SQLSTATE = expected THEN RETURN; END IF;
    RAISE;
  END;
  RAISE EXCEPTION 'FAIL: expected %', expected;
END $$;

INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES
  ('15151515-1515-1515-1515-151515151515','m3-contract-owner@example.test','{}'),
  ('16161616-1616-1616-1616-161616161616','m3-contract-other@example.test','{}');
SELECT set_config('request.jwt.claim.sub','15151515-1515-1515-1515-151515151515',true);
SELECT set_config('request.jwt.claims',
  '{"sub":"15151515-1515-1515-1515-151515151515","role":"authenticated"}',true);
INSERT INTO public.workouts(id,user_id,status,training_started_at) VALUES
  ('17171717-1717-1717-1717-171717171717',
   '15151515-1515-1515-1515-151515151515','active',now()-interval '10 minutes'),
  ('18181818-1818-1818-1818-181818181818',
   '15151515-1515-1515-1515-151515151515','active',now()-interval '10 minutes');
INSERT INTO public.workout_exercises(id,workout_id,exercise_id,mode)
  SELECT v.id::uuid,'17171717-1717-1717-1717-171717171717'::uuid,e.id,v.mode
  FROM (VALUES
    ('19191919-1919-1919-1919-191919191919','reps-weight',1),
    ('20202020-2020-2020-2020-202020202020','bodyweight',2),
    ('21212121-2121-2121-2121-212121212121','timed',3)
  ) v(id,mode,n)
  JOIN (SELECT id,row_number() OVER (ORDER BY id) n FROM public.exercises) e ON e.n=v.n;
INSERT INTO public.workout_exercises(id,workout_id,exercise_id,mode)
  SELECT '22222222-2222-2222-2222-222222222222',
    '18181818-1818-1818-1818-181818181818',id,'cardio'
  FROM public.exercises ORDER BY id LIMIT 1;
SELECT pg_temp.assert_m3(
  (SELECT string_agg(tgname,',' ORDER BY tgname)
   FROM pg_catalog.pg_trigger
   WHERE tgrelid='public.workout_sets'::pg_catalog.regclass
     AND tgname IN ('guard_set_write','guard_set_write_group_number'))
  = 'guard_set_write,guard_set_write_group_number',
  'duplicate check trigger sorts after workout-lock trigger');

SET LOCAL ROLE authenticated;
SELECT pg_temp.expect_m3_error(
  $q$UPDATE public.workout_exercises SET superset_group_id='23232323-2323-2323-2323-232323232323',superset_position=0 WHERE id='19191919-1919-1919-1919-191919191919'$q$,
  '42501');
SELECT pg_temp.expect_m3_error(
  $q$INSERT INTO public.workout_exercises(id,workout_id,exercise_id,superset_locked) SELECT '28282828-2828-2828-2828-282828282828','17171717-1717-1717-1717-171717171717',exercise_id,true FROM public.workout_exercises WHERE id='19191919-1919-1919-1919-191919191919'$q$,
  '42501');
SELECT pg_temp.assert_m3(
  public.set_superset_layout_v1('17171717-1717-1717-1717-171717171717',
    '[{"group_id":"23232323-2323-2323-2323-232323232323","exercise_ids":["19191919-1919-1919-1919-191919191919"]}]')
    ->>'group_count'='0',
  'one-member layout dissolves without persisting an invalid group');
SELECT public.set_superset_layout_v1(
  '17171717-1717-1717-1717-171717171717',
  '[{"group_id":"23232323-2323-2323-2323-232323232323","exercise_ids":["19191919-1919-1919-1919-191919191919","20202020-2020-2020-2020-202020202020"]}]');
SELECT pg_temp.assert_m3(
  (SELECT count(*)=2 AND min(superset_position)=0 AND max(superset_position)=1
   FROM public.workout_exercises
   WHERE superset_group_id='23232323-2323-2323-2323-232323232323'),
  'positions are unique and contiguous');
SELECT pg_temp.expect_m3_error(
  $q$SELECT public.set_superset_layout_v1('17171717-1717-1717-1717-171717171717','[{"group_id":"23232323-2323-2323-2323-232323232323","exercise_ids":["19191919-1919-1919-1919-191919191919","19191919-1919-1919-1919-191919191919"]}]')$q$,
  '22023');
SELECT pg_temp.assert_m3(
  (SELECT count(*)=2 FROM public.workout_exercises
   WHERE superset_group_id='23232323-2323-2323-2323-232323232323'),
  'invalid layout rolls back');
INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,is_completed)
  VALUES('19191919-1919-1919-1919-191919191919',1,10,20,false);
SELECT public.set_superset_layout_v1(
  '17171717-1717-1717-1717-171717171717','[]');
SELECT pg_temp.assert_m3(
  (SELECT count(*)=3 AND count(superset_group_id)=0
   FROM public.workout_exercises
   WHERE workout_id='17171717-1717-1717-1717-171717171717')
  AND (SELECT count(*)=1 FROM public.workout_sets
       WHERE workout_exercise_id='19191919-1919-1919-1919-191919191919'),
  'ungroup preserves workout exercises and historical draft sets');
INSERT INTO public.workout_sets(id,workout_exercise_id,set_number,reps,weight_kg,is_completed)
  VALUES('26262626-2626-2626-2626-262626262626',
    '19191919-1919-1919-1919-191919191919',1,10,20,false);
SELECT pg_temp.expect_m3_error(
  $q$SELECT public.set_superset_layout_v1('17171717-1717-1717-1717-171717171717','[{"group_id":"23232323-2323-2323-2323-232323232323","exercise_ids":["19191919-1919-1919-1919-191919191919","20202020-2020-2020-2020-202020202020"]}]')$q$,
  '23505');
DELETE FROM public.workout_sets WHERE id='26262626-2626-2626-2626-262626262626';
SELECT public.set_superset_layout_v1(
  '17171717-1717-1717-1717-171717171717',
  '[{"group_id":"24242424-2424-2424-2424-242424242424","exercise_ids":["20202020-2020-2020-2020-202020202020","21212121-2121-2121-2121-212121212121"]}]');
SELECT pg_temp.assert_m3(
  (SELECT count(*)=2 AND min(superset_position)=0 AND max(superset_position)=1
   FROM public.workout_exercises
   WHERE superset_group_id='24242424-2424-2424-2424-242424242424'),
  'member move to a new group is contiguous');
SELECT public.set_superset_layout_v1(
  '17171717-1717-1717-1717-171717171717',
  '[{"group_id":"23232323-2323-2323-2323-232323232323","exercise_ids":["20202020-2020-2020-2020-202020202020","19191919-1919-1919-1919-191919191919"]}]');
SELECT pg_temp.assert_m3(
  (SELECT superset_group_id IS NULL FROM public.workout_exercises
   WHERE id='21212121-2121-2121-2121-212121212121')
  AND (SELECT count(*)=0 FROM public.workout_exercises
       WHERE superset_group_id='24242424-2424-2424-2424-242424242424'),
  'moving a member dissolves its old group below two members');
SELECT public.set_superset_layout_v1(
  '17171717-1717-1717-1717-171717171717',
  '[{"group_id":"23232323-2323-2323-2323-232323232323","exercise_ids":["19191919-1919-1919-1919-191919191919","20202020-2020-2020-2020-202020202020"]}]');
SELECT pg_temp.expect_m3_error(
  $q$INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,is_completed) VALUES('19191919-1919-1919-1919-191919191919',1,10,20,false)$q$,
  '23505');
INSERT INTO public.workout_sets(id,workout_exercise_id,set_number,reps,weight_kg,is_completed)
  VALUES('27272727-2727-2727-2727-272727272727',
    '19191919-1919-1919-1919-191919191919',2,10,20,false);
SELECT pg_temp.expect_m3_error(
  $q$UPDATE public.workout_sets SET set_number=1 WHERE id='27272727-2727-2727-2727-272727272727'$q$,
  '23505');
DELETE FROM public.workout_sets WHERE id='27272727-2727-2727-2727-272727272727';
UPDATE public.workout_sets SET is_completed=true
  WHERE workout_exercise_id='19191919-1919-1919-1919-191919191919';
INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,is_completed)
  VALUES('20202020-2020-2020-2020-202020202020',1,10,5,true);
SELECT pg_temp.expect_m3_error(
  $q$UPDATE public.workout_exercises SET mode='bodyweight' WHERE id='19191919-1919-1919-1919-191919191919'$q$,
  '22023');
SELECT pg_temp.expect_m3_error(
  $q$SELECT public.set_superset_layout_v1('17171717-1717-1717-1717-171717171717','[{"group_id":"23232323-2323-2323-2323-232323232323","exercise_ids":["20202020-2020-2020-2020-202020202020","19191919-1919-1919-1919-191919191919"]}]')$q$,
  '22023');
SELECT pg_temp.expect_m3_error(
  $q$SELECT public.set_superset_layout_v1('17171717-1717-1717-1717-171717171717','[]')$q$,
  '22023');
SELECT pg_temp.expect_m3_error(
  $q$DELETE FROM public.workout_exercises WHERE id='20202020-2020-2020-2020-202020202020'$q$,
  '22023');
SELECT pg_temp.assert_m3(
  (SELECT count(*)=2 FROM public.workout_exercises
   WHERE superset_group_id='23232323-2323-2323-2323-232323232323')
  AND (SELECT count(*)=2 FROM public.workout_sets
       WHERE workout_exercise_id IN
         ('19191919-1919-1919-1919-191919191919',
          '20202020-2020-2020-2020-202020202020'))
  AND (SELECT count(*)=2 FROM public.workout_exercises
       WHERE superset_group_id='23232323-2323-2323-2323-232323232323'
         AND superset_locked),
  'locked group and historical set remain intact');
SELECT pg_temp.expect_m3_error(
  $q$UPDATE public.workout_exercises SET superset_locked=false WHERE id='19191919-1919-1919-1919-191919191919'$q$,
  '42501');
SELECT pg_temp.expect_m3_error(
  $q$SELECT * FROM public.workout_superset_locks$q$,'42501');
SELECT pg_temp.expect_m3_error(
  $q$SELECT * FROM public.workout_exercise_mode_locks$q$,'42501');
UPDATE public.workout_sets SET is_completed=false
  WHERE workout_exercise_id='20202020-2020-2020-2020-202020202020';
SELECT pg_temp.expect_m3_error(
  $q$SELECT public.set_superset_layout_v1('17171717-1717-1717-1717-171717171717','[]')$q$,
  '22023');
DELETE FROM public.workout_sets
  WHERE workout_exercise_id='20202020-2020-2020-2020-202020202020';
SELECT pg_temp.expect_m3_error(
  $q$UPDATE public.workout_exercises SET mode='timed' WHERE id='20202020-2020-2020-2020-202020202020'$q$,
  '22023');
SELECT pg_temp.assert_m3(
  public.is_workout_exercise_mode_locked('20202020-2020-2020-2020-202020202020'),
  'mode lock survives deletion of every set');
SELECT pg_temp.assert_m3(
  (SELECT count(*)=2 FROM public.workout_exercises
   WHERE superset_group_id='23232323-2323-2323-2323-232323232323'
     AND superset_locked),
  'durable lock remains visible after set uncompletion and deletion');
SELECT pg_temp.expect_m3_error(
  $q$SELECT public.set_superset_layout_v1('17171717-1717-1717-1717-171717171717','[]')$q$,
  '22023');
SELECT pg_temp.expect_m3_error(
  $q$INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,duration_seconds,is_completed) VALUES('21212121-2121-2121-2121-212121212121',1,1,0,60,true)$q$,
  '22023');
SELECT pg_temp.expect_m3_error(
  $q$INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,duration_seconds,is_completed) VALUES('19191919-1919-1919-1919-191919191919',2,10,20,60,true)$q$,
  '22023');
SELECT pg_temp.expect_m3_error(
  $q$INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,duration_seconds,is_completed) VALUES('19191919-1919-1919-1919-191919191919',2,0,0,60,true)$q$,
  '22023');
SELECT pg_temp.expect_m3_error(
  $q$INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,duration_seconds,is_completed) VALUES('20202020-2020-2020-2020-202020202020',2,0,0,60,true)$q$,
  '22023');
SELECT pg_temp.expect_m3_error(
  $q$INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,duration_seconds,is_completed) VALUES('21212121-2121-2121-2121-212121212121',1,0,0,0,true)$q$,
  '22023');
SELECT pg_temp.expect_m3_error(
  $q$INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,duration_seconds,is_completed) VALUES('22222222-2222-2222-2222-222222222222',1,0,1,60,true)$q$,
  '22023');
SELECT pg_temp.expect_m3_error(
  $q$INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,duration_seconds,is_completed) VALUES('22222222-2222-2222-2222-222222222222',1,1,0,60,true)$q$,
  '22023');
SELECT pg_temp.expect_m3_error(
  $q$INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,duration_seconds,is_completed) VALUES('22222222-2222-2222-2222-222222222222',1,0,0,7201,true)$q$,
  '22023');
SELECT pg_temp.expect_m3_error(
  $q$INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,duration_seconds,is_completed) VALUES('19191919-1919-1919-1919-191919191919',2,0,0,60,false)$q$,
  '22023');
SELECT pg_temp.expect_m3_error(
  $q$INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,duration_seconds,is_completed) VALUES('21212121-2121-2121-2121-212121212121',2,1,0,0,false)$q$,
  '22023');
SELECT pg_temp.expect_m3_error(
  $q$INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,duration_seconds,is_completed) VALUES('22222222-2222-2222-2222-222222222222',2,0,1,0,false)$q$,
  '22023');
INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,duration_seconds,is_completed)
  VALUES('21212121-2121-2121-2121-212121212121',1,0,0,1,true),
        ('22222222-2222-2222-2222-222222222222',1,0,0,7200,true);
INSERT INTO public.workout_exercises(id,workout_id,exercise_id)
  SELECT '25252525-2525-2525-2525-252525252525',
    '18181818-1818-1818-1818-181818181818',id
  FROM public.exercises ORDER BY id OFFSET 3 LIMIT 1;
SELECT pg_temp.assert_m3(
  (SELECT mode IS NULL AND superset_group_id IS NULL
   FROM public.workout_exercises
   WHERE id='25252525-2525-2525-2525-252525252525'),
  'legacy nullable mode remains explicit and ungrouped');
SELECT set_config('request.jwt.claim.sub','16161616-1616-1616-1616-161616161616',true);
SELECT set_config('request.jwt.claims',
  '{"sub":"16161616-1616-1616-1616-161616161616","role":"authenticated"}',true);
SELECT pg_temp.assert_m3(
  NOT public.is_workout_exercise_mode_locked('20202020-2020-2020-2020-202020202020'),
  'other owner cannot observe private mode lock');
SELECT pg_temp.expect_m3_error(
  $q$SELECT public.set_superset_layout_v1('17171717-1717-1717-1717-171717171717','[]')$q$,
  '42501');
SELECT set_config('request.jwt.claim.sub','15151515-1515-1515-1515-151515151515',true);
SELECT set_config('request.jwt.claims',
  '{"sub":"15151515-1515-1515-1515-151515151515","role":"authenticated"}',true);
CREATE TEMP TABLE m3_reward AS
  SELECT public.complete_workout('18181818-1818-1818-1818-181818181818') result;
SELECT pg_temp.assert_m3(
  (SELECT result=public.complete_workout('18181818-1818-1818-1818-181818181818') FROM m3_reward)
  AND (SELECT count(*)=1 FROM public.workout_rewards
       WHERE workout_id='18181818-1818-1818-1818-181818181818')
  AND (SELECT count(*)=1 FROM public.xp_logs
       WHERE source IN ('workout','quest') AND source_id='18181818-1818-1818-1818-181818181818')
  AND (SELECT count(*)=0 FROM public.exercise_prs
       WHERE exercise_id=(SELECT exercise_id FROM public.workout_exercises
         WHERE id='22222222-2222-2222-2222-222222222222')),
  'cardio completes once through complete_workout without a zero PR');
RESET ROLE;
ALTER TABLE public.workout_sets DISABLE TRIGGER guard_workout_set_mode;
INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,duration_seconds,is_completed)
  VALUES('19191919-1919-1919-1919-191919191919',2,10,20,60,true);
ALTER TABLE public.workout_sets ENABLE TRIGGER guard_workout_set_mode;
SET LOCAL ROLE authenticated;
SELECT pg_temp.expect_m3_error(
  $q$SELECT public.complete_workout('17171717-1717-1717-1717-171717171717')$q$,
  '22023');
SELECT pg_temp.assert_m3(
  (SELECT count(*)=0 FROM public.workout_rewards
   WHERE workout_id='17171717-1717-1717-1717-171717171717'),
  'malformed typed set cannot award');
DELETE FROM public.workout_sets WHERE workout_exercise_id='19191919-1919-1919-1919-191919191919' AND set_number=2;
CREATE TEMP TABLE m3_mixed_reward AS
  SELECT public.complete_workout('17171717-1717-1717-1717-171717171717') result;
SELECT pg_temp.assert_m3(
  (SELECT result=public.complete_workout('17171717-1717-1717-1717-171717171717')
   FROM m3_mixed_reward)
  AND (SELECT count(*)=1 FROM public.workout_rewards
       WHERE workout_id='17171717-1717-1717-1717-171717171717'),
  'mixed reps, bodyweight, and timed workout completes once');
RESET ROLE;
ROLLBACK;
