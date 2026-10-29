BEGIN;
CREATE FUNCTION pg_temp.assert_true(ok boolean,label text) RETURNS void LANGUAGE plpgsql AS $$ BEGIN IF ok IS DISTINCT FROM true THEN RAISE EXCEPTION 'FAIL: %',label; END IF; END $$;
INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','qa-progression@example.test','{}');
SELECT set_config('request.jwt.claim.sub','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',true);
SELECT set_config('request.jwt.claims','{"sub":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa","role":"authenticated"}',true);
SET LOCAL ROLE authenticated;
SELECT public.initialize_user('{"environment":"home","goals":["hypertrophy"],"experience_level":"beginner","age":25,"gender":"other","height_cm":170,"weight_kg":65,"weekly_gym_days":0,"weekly_home_days":3,"preferred_training_days":["mon","wed","fri"],"primary_class_id":"B"}');
RESET ROLE;
-- Historical completed-but-unrewarded sessions can be recovered without losing
-- their original dates, lowering last activity, or awarding twice.
UPDATE public.users SET total_xp=90,level=1,last_workout_date=now(),last_active_at=now() WHERE id=auth.uid();
INSERT INTO public.workouts(id,user_id,started_at,training_started_at) VALUES
 ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',auth.uid(),now()-interval '1 day 30 minutes',now()-interval '1 day 30 minutes'),
 ('cccccccc-cccc-cccc-cccc-cccccccccccc',auth.uid(),now()-interval '30 minutes',now()-interval '30 minutes'),
 ('dddddddd-dddd-dddd-dddd-dddddddddddd',auth.uid(),now()-interval '2 days 30 minutes',now()-interval '2 days 30 minutes');
INSERT INTO public.workout_exercises(id,workout_id,exercise_id) SELECT
 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1','bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',id FROM public.exercises WHERE category='Chest' ORDER BY name LIMIT 1;
INSERT INTO public.workout_exercises(id,workout_id,exercise_id) SELECT
 'cccccccc-cccc-cccc-cccc-ccccccccccc1','cccccccc-cccc-cccc-cccc-cccccccccccc',id FROM public.exercises WHERE category='Chest' ORDER BY name LIMIT 1;
INSERT INTO public.workout_exercises(id,workout_id,exercise_id) SELECT
 'dddddddd-dddd-dddd-dddd-ddddddddddd1','dddddddd-dddd-dddd-dddd-dddddddddddd',id FROM public.exercises WHERE category='Chest' ORDER BY name LIMIT 1;
INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,is_completed) SELECT id,n,10,20,true FROM public.workout_exercises CROSS JOIN generate_series(1,2)n WHERE workout_id IN('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb','cccccccc-cccc-cccc-cccc-cccccccccccc','dddddddd-dddd-dddd-dddd-dddddddddddd');
UPDATE public.workouts SET status='completed',completed_at=now()-interval '1 day',duration_seconds=1800 WHERE id='bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
UPDATE public.workouts SET status='completed',completed_at=now()-interval '2 days',duration_seconds=1800,is_xp_calculated=true WHERE id='dddddddd-dddd-dddd-dddd-dddddddddddd';
-- Duplicate historical ledger rows must be counted once during class switching.
INSERT INTO public.xp_logs(user_id,source,source_id,amount) VALUES(auth.uid(),'workout','dddddddd-dddd-dddd-dddd-dddddddddddd',100),(auth.uid(),'workout','dddddddd-dddd-dddd-dddd-dddddddddddd',100);
SET LOCAL ROLE authenticated;
SELECT pg_temp.assert_true((public.complete_workout('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb')->>'newLevel')::integer=2,'exact global 100-XP boundary reaches level2');
SELECT pg_temp.assert_true((SELECT current_level_xp=0 AND total_xp=100 FROM public.users),'within-level XP is nonnegative at boundary');
SELECT pg_temp.assert_true((SELECT last_workout_date>=now() AND last_active_at>=now() FROM public.users),'recovering history does not move last activity backwards');
SELECT pg_temp.assert_true((public.complete_workout('cccccccc-cccc-cccc-cccc-cccccccccccc')->>'streak')::integer=2,'consecutive local dates increment streak');
SELECT pg_temp.assert_true((public.complete_workout('dddddddd-dddd-dddd-dddd-dddddddddddd')->>'earnedXP')::integer=0,'legacy awarded workout never earns twice');
SELECT pg_temp.assert_true((public.switch_class('C','secondary')->>'xp_granted')::integer=120,'legacy awards retained and duplicate historical logs deduplicated');
SELECT pg_temp.assert_true((public.switch_class('C','secondary')->>'xp_granted')::integer=120,'repeated class switch preserves same history');
SELECT pg_temp.assert_true((SELECT count(*)=2 FROM public.workout_rewards),'legacy already-awarded history creates no new reward');
RESET ROLE;
-- FND-DATA-001: a legacy completed workout can carry xp_logs evidence while both the
-- reward row and is_xp_calculated are missing. Such a tuple must never earn a second
-- award, and a retry must stay idempotent without fabricating a reward row.
INSERT INTO public.workouts(id,user_id,started_at,training_started_at) VALUES
 ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',auth.uid(),now()-interval '3 days 30 minutes',now()-interval '3 days 30 minutes'),
 ('ffffffff-ffff-ffff-ffff-ffffffffffff',auth.uid(),now()-interval '4 days 30 minutes',now()-interval '4 days 30 minutes');
INSERT INTO public.workout_exercises(id,workout_id,exercise_id) SELECT 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeee1','eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',id FROM public.exercises WHERE category='Chest' ORDER BY name LIMIT 1;
INSERT INTO public.workout_exercises(id,workout_id,exercise_id) SELECT 'ffffffff-ffff-ffff-ffff-fffffffffff1','ffffffff-ffff-ffff-ffff-ffffffffffff',id FROM public.exercises WHERE category='Chest' ORDER BY name LIMIT 1;
INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,is_completed) SELECT id,n,10,20,true FROM public.workout_exercises CROSS JOIN generate_series(1,2)n WHERE workout_id IN('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee','ffffffff-ffff-ffff-ffff-ffffffffffff');
UPDATE public.workouts SET status='completed',completed_at=now()-interval '3 days',duration_seconds=1800 WHERE id='eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee';
UPDATE public.workouts SET status='completed',completed_at=now()-interval '4 days',duration_seconds=1800 WHERE id='ffffffff-ffff-ffff-ffff-ffffffffffff';
INSERT INTO public.xp_logs(user_id,source,source_id,amount) VALUES(auth.uid(),'workout','eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',100),(auth.uid(),'quest','ffffffff-ffff-ffff-ffff-ffffffffffff',120);
CREATE TEMP TABLE fnd_data_001_before AS SELECT u.total_xp,(SELECT count(*) FROM public.xp_logs) log_count,(SELECT count(*) FROM public.user_classes WHERE user_id=u.id) class_count FROM public.users u;
SET LOCAL ROLE authenticated;
SELECT pg_temp.assert_true((public.complete_workout('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee')->>'earnedXP')::integer=0,'ledger-only legacy workout never earns twice');
SELECT pg_temp.assert_true((public.complete_workout('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee')->>'alreadyAwarded')::boolean,'retry reports alreadyAwarded instead of awarding');
SELECT pg_temp.assert_true((public.complete_workout('ffffffff-ffff-ffff-ffff-ffffffffffff')->>'earnedXP')::integer=0,'quest-source ledger evidence also blocks a second award');
RESET ROLE;
SELECT pg_temp.assert_true((SELECT u.total_xp=(SELECT total_xp FROM fnd_data_001_before) FROM public.users u),'blocked retries leave total XP unchanged');
SELECT pg_temp.assert_true((SELECT count(*)=(SELECT log_count FROM fnd_data_001_before) FROM public.xp_logs),'blocked retries write no ledger rows');
SELECT pg_temp.assert_true((SELECT count(*)=(SELECT class_count FROM fnd_data_001_before) FROM public.user_classes),'blocked retries change no class progress');
SELECT pg_temp.assert_true(NOT EXISTS(SELECT 1 FROM public.workout_rewards WHERE workout_id IN('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee','ffffffff-ffff-ffff-ffff-ffffffffffff')),'no reward row is fabricated for legacy evidence');
SELECT pg_temp.assert_true(NOT EXISTS(SELECT 1 FROM public.workouts WHERE id='eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee' AND is_xp_calculated),'legacy is_xp_calculated flag is not fabricated');
-- At a class threshold the stored level and the client formula agree.
UPDATE public.user_classes SET current_xp=130,level=1 WHERE user_id=auth.uid() AND class_id='C';
SET LOCAL ROLE authenticated;
SELECT pg_temp.assert_true((public.switch_class('C','secondary')->>'level')::integer=2,'class level2 threshold is xp_base');
RESET ROLE;
SELECT set_config('request.jwt.claim.sub','',true);
SELECT set_config('request.jwt.claims','{}',true);
DELETE FROM auth.users WHERE id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
SELECT pg_temp.assert_true(NOT EXISTS(SELECT 1 FROM public.users WHERE id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),'privileged account deletion removes public profile');
SELECT pg_temp.assert_true(NOT EXISTS(SELECT 1 FROM public.workouts WHERE user_id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),'account deletion cascades through finished sessions');
SELECT pg_temp.assert_true(NOT EXISTS(SELECT 1 FROM public.workout_rewards WHERE user_id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),'account deletion cascades through reward ledger');
ROLLBACK;
