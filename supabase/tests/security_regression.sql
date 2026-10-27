-- Executable PostgreSQL assertions, run in a disposable database only.
-- Works with `psql -v ON_ERROR_STOP=1 -f ...` or tools/db-tests/run.mjs.
BEGIN;
CREATE TEMP TABLE checks_context(key text PRIMARY KEY,value jsonb);
GRANT ALL ON checks_context TO authenticated,anon;
CREATE FUNCTION pg_temp.assert_true(ok boolean,label text) RETURNS void LANGUAGE plpgsql AS $$ BEGIN IF ok IS DISTINCT FROM true THEN RAISE EXCEPTION 'FAIL: %',label; END IF; END $$;
CREATE FUNCTION pg_temp.denied(statement text,expected text DEFAULT '42501') RETURNS void LANGUAGE plpgsql AS $$ BEGIN
 BEGIN EXECUTE statement; EXCEPTION WHEN OTHERS THEN IF SQLSTATE=expected THEN RETURN; END IF; RAISE; END;
 RAISE EXCEPTION 'FAIL: expected SQLSTATE %',expected;
END $$;

INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES
 ('11111111-1111-1111-1111-111111111111','qa-athlete-one@example.test','{}'),
 ('22222222-2222-2222-2222-222222222222','qa-athlete-two@example.test','{}');
SELECT pg_temp.assert_true((SELECT count(*)=2 FROM public.users WHERE email LIKE 'qa-athlete-%'),'signup trigger creates account profiles');
SET LOCAL ROLE anon;
SELECT pg_temp.denied('SELECT * FROM public.users');
SELECT pg_temp.denied('SELECT public.start_workout()');
SELECT pg_temp.denied('SELECT public.consume_coach_request()');
RESET ROLE;

SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub','11111111-1111-1111-1111-111111111111',true);
SELECT set_config('request.jwt.claims','{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}',true);
SELECT pg_temp.assert_true((SELECT count(*)=1 FROM public.users),'RLS hides other users');
SELECT pg_temp.denied('UPDATE public.users SET total_xp=999999');
SELECT pg_temp.denied('UPDATE public.users SET onboarding_completed=true');
SELECT pg_temp.denied('INSERT INTO public.users(id,email,total_xp) VALUES(''11111111-1111-1111-1111-111111111111'',''x'',999)');
SELECT pg_temp.denied('SELECT public.workout_json(gen_random_uuid())');
SELECT pg_temp.denied('SELECT public.start_workout()','22023');
SELECT pg_temp.denied('SELECT public.initialize_user(''{"environment":"gym","goals":["hypertrophy"],"experience_level":"advanced","gender":"male","primary_class_id":"B","preferred_training_days":["mon"]}'')','22023');
SELECT pg_temp.denied('SELECT public.initialize_user(''{"environment":"gym","goals":["invalid"],"experience_level":"advanced","age":28,"gender":"male","height_cm":175,"weight_kg":70,"primary_class_id":"B","preferred_training_days":["mon"]}'')','22023');
SELECT pg_temp.denied('SELECT public.initialize_user(''{"environment":"gym","goals":["hypertrophy"],"experience_level":"advanced","age":28,"gender":"male","height_cm":175,"weight_kg":70,"primary_class_id":"B","preferred_training_days":["invalid"]}'')','22023');
SELECT public.initialize_user('{"environment":"gym","goals":["hypertrophy"],"experience_level":"advanced","age":28,"gender":"male","height_cm":175,"weight_kg":70,"weekly_gym_days":3,"weekly_home_days":0,"preferred_training_days":["Mon","Wed","Fri"],"primary_class_id":"B","secondary_class_id":"C","timezone":"Asia/Ho_Chi_Minh"}');
SELECT pg_temp.assert_true((SELECT level=1 AND total_xp=0 AND onboarding_completed FROM public.users),'experience does not manufacture XP');
SELECT public.initialize_user('{"experience_level":"advanced","total_xp":99999}');
SELECT pg_temp.assert_true((SELECT level=1 AND total_xp=0 FROM public.users),'repeat onboarding preserves progression');
SELECT pg_temp.denied('UPDATE public.user_classes SET level=20,current_xp=100000');
SELECT pg_temp.denied('INSERT INTO public.xp_logs(user_id,amount,source) VALUES(auth.uid(),999,''workout'')');
SELECT pg_temp.denied('UPDATE public.streaks SET current_streak=1000');
SELECT pg_temp.denied('INSERT INTO public.user_achievements(user_id,achievement_id) VALUES(auth.uid(),''level_10'')');

INSERT INTO checks_context VALUES('workout',public.start_workout());
SELECT pg_temp.assert_true(public.start_workout()->>'id'=(SELECT value->>'id' FROM checks_context WHERE key='workout'),'start is replay safe');
SELECT pg_temp.assert_true((SELECT value->'training_started_at'='null'::jsonb FROM checks_context WHERE key='workout'),'new session starts in setup');
SELECT pg_temp.denied('UPDATE public.workouts SET is_xp_calculated=false,status=''completed''');
SELECT pg_temp.denied('UPDATE public.workouts SET started_at=now()-interval ''1 hour''');
INSERT INTO public.workout_exercises(id,workout_id,exercise_id) SELECT '33333333-3333-3333-3333-333333333333',(value->>'id')::uuid,(SELECT id FROM public.exercises WHERE category='Chest' ORDER BY name LIMIT 1) FROM checks_context WHERE key='workout';
SELECT public.begin_workout((SELECT (value->>'id')::uuid FROM checks_context WHERE key='workout'));
SELECT pg_temp.denied('SELECT public.complete_workout((SELECT (value->>''id'')::uuid FROM checks_context WHERE key=''workout''))','22023');
SELECT pg_temp.assert_true((SELECT status='active' FROM public.workouts),'invalid completion rolls back session transition');
SELECT public.set_workout_paused((SELECT (value->>'id')::uuid FROM checks_context WHERE key='workout'),true);
SELECT pg_temp.assert_true((SELECT paused_at IS NOT NULL FROM public.workouts),'pause persists');
SELECT public.set_workout_paused((SELECT (value->>'id')::uuid FROM checks_context WHERE key='workout'),false);
SELECT pg_temp.assert_true((SELECT paused_at IS NULL FROM public.workouts),'resume persists');
SELECT pg_temp.denied('INSERT INTO public.workout_sets(workout_exercise_id,reps,weight_kg,is_completed) VALUES(''33333333-3333-3333-3333-333333333333'',0,20,true)','23514');
SELECT pg_temp.denied('INSERT INTO public.workout_sets(workout_exercise_id,reps,weight_kg) VALUES(''33333333-3333-3333-3333-333333333333'',10,-1)','23514');
INSERT INTO public.workout_sets(id,workout_exercise_id,set_number,reps,weight_kg,baseline_weight_kg,is_completed) VALUES
 ('44444444-4444-4444-4444-444444444444','33333333-3333-3333-3333-333333333333',1,10,20,0.00001,true),
 ('55555555-5555-5555-5555-555555555555','33333333-3333-3333-3333-333333333333',2,10,20,0.00001,true);
SELECT pg_temp.assert_true((SELECT bool_and(baseline_weight_kg=0) FROM public.workout_sets),'client cannot choose reward baseline');
UPDATE public.workout_sets SET baseline_weight_kg=0.001;
SELECT pg_temp.assert_true((SELECT bool_and(baseline_weight_kg=0) FROM public.workout_sets),'baseline is immutable on update');

-- A different authenticated user cannot see or mutate these workout rows.
SELECT set_config('request.jwt.claim.sub','22222222-2222-2222-2222-222222222222',true);
SELECT set_config('request.jwt.claims','{"sub":"22222222-2222-2222-2222-222222222222","role":"authenticated"}',true);
SELECT pg_temp.assert_true((SELECT count(*)=0 FROM public.workouts),'workout user isolation');
SELECT pg_temp.assert_true((SELECT count(*)=0 FROM public.workout_sets),'set user isolation');
SELECT pg_temp.denied('SELECT public.complete_workout((SELECT (value->>''id'')::uuid FROM checks_context WHERE key=''workout''))');
SELECT pg_temp.denied('INSERT INTO public.workout_sets(workout_exercise_id,reps,weight_kg) VALUES(''33333333-3333-3333-3333-333333333333'',10,20)');
SELECT set_config('request.jwt.claim.sub','11111111-1111-1111-1111-111111111111',true);
SELECT set_config('request.jwt.claims','{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}',true);
RESET ROLE;
UPDATE public.workouts SET training_started_at=now()-interval '10 minutes' WHERE id=(SELECT (value->>'id')::uuid FROM checks_context WHERE key='workout');
SET LOCAL ROLE authenticated;
INSERT INTO checks_context VALUES('reward',public.complete_workout((SELECT (value->>'id')::uuid FROM checks_context WHERE key='workout')));
SELECT pg_temp.assert_true((SELECT (value->>'earnedXP')::integer=10 AND (value->>'totalXP')::integer=10 FROM checks_context WHERE key='reward'),'two baseline-free sets earn exactly 10 XP');
SELECT pg_temp.assert_true(public.complete_workout((SELECT (value->>'id')::uuid FROM checks_context WHERE key='workout'))=(SELECT value FROM checks_context WHERE key='reward'),'reward replay returns original result');
SELECT pg_temp.assert_true((SELECT count(*)=1 FROM public.workout_rewards),'one immutable reward per workout');
SELECT pg_temp.assert_true((SELECT total_xp=10 FROM public.users),'replay does not double XP');
SELECT pg_temp.assert_true((SELECT count(*)=1 FROM public.xp_logs WHERE source='workout'),'replay does not duplicate ledger');
SELECT pg_temp.assert_true((SELECT max_weight_kg=20 AND max_reps=10 FROM public.exercise_prs),'PR written transactionally');
SELECT pg_temp.assert_true((SELECT current_streak=1 FROM public.streaks),'first workout starts streak');
SELECT pg_temp.assert_true((SELECT count(*)=1 FROM public.user_achievements WHERE achievement_id='first_workout'),'first workout achievement persisted');
SELECT pg_temp.assert_true((SELECT bool_and(current_xp=10) FROM public.user_classes),'class IDs and synergy align with client catalogue');
UPDATE public.workout_sets SET weight_kg=999;
SELECT pg_temp.assert_true((SELECT bool_and(weight_kg=20) FROM public.workout_sets),'completed sets cannot be changed');
SELECT pg_temp.denied('INSERT INTO public.workout_sets(workout_exercise_id,reps,weight_kg) VALUES(''33333333-3333-3333-3333-333333333333'',10,20)');
SELECT pg_temp.denied('SELECT public.cancel_workout((SELECT (value->>''id'')::uuid FROM checks_context WHERE key=''workout''))','22023');

INSERT INTO checks_context VALUES('quest',public.sync_daily_data());
SELECT pg_temp.assert_true(public.sync_daily_data()->'quest'->>'id'=(SELECT value->'quest'->>'id' FROM checks_context WHERE key='quest'),'daily quest is idempotent');
SELECT pg_temp.assert_true((SELECT count(*)=1 FROM public.quest_instances),'one daily quest');
SELECT pg_temp.assert_true((SELECT quest_date=(now() AT TIME ZONE 'Asia/Ho_Chi_Minh')::date AND expires_at=(((now() AT TIME ZONE 'Asia/Ho_Chi_Minh')::date+1)::timestamp AT TIME ZONE 'Asia/Ho_Chi_Minh') FROM public.quest_instances),'quest uses local calendar boundaries');
SELECT pg_temp.assert_true((SELECT jsonb_array_length(value->'quest'->'prescribed_config')>0 FROM checks_context WHERE key='quest'),'quest category maps to seeded exercises');
SELECT pg_temp.denied('UPDATE public.quest_instances SET status=''completed'',earned_xp=9999');
INSERT INTO checks_context VALUES('quest_workout',public.start_workout());
DO $$ DECLARE t jsonb; eid uuid; BEGIN
 FOR t IN SELECT jsonb_array_elements(value->'quest'->'prescribed_config') FROM checks_context WHERE key='quest' LOOP
  INSERT INTO public.workout_exercises(workout_id,exercise_id) VALUES((SELECT (value->>'id')::uuid FROM checks_context WHERE key='quest_workout'),(t->>'exercise_id')::uuid) RETURNING id INTO eid;
  INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,is_completed) SELECT eid,n,(t->>'reps')::integer,(t->>'weight_kg')::numeric,true FROM generate_series(1,(t->>'sets')::integer) n;
 END LOOP;
END $$;
SELECT public.begin_workout((SELECT (value->>'id')::uuid FROM checks_context WHERE key='quest_workout'));
RESET ROLE;
UPDATE public.workouts SET training_started_at=now()-interval '30 minutes' WHERE id=(SELECT (value->>'id')::uuid FROM checks_context WHERE key='quest_workout');
SET LOCAL ROLE authenticated;
INSERT INTO checks_context VALUES('quest_reward',public.complete_workout((SELECT (value->>'id')::uuid FROM checks_context WHERE key='quest_workout')));
SELECT pg_temp.assert_true((SELECT (value->>'isQuest')::boolean AND (value->>'earnedXP')::integer>=300 FROM checks_context WHERE key='quest_reward'),'quest exact targets earn server template reward');
SELECT pg_temp.assert_true((SELECT status='completed' FROM public.quest_instances),'quest completion persisted');
SELECT pg_temp.assert_true((SELECT current_streak=1 FROM public.streaks),'same-day workouts do not increment streak');
SELECT pg_temp.assert_true(jsonb_array_length(public.get_user_stats()->'volume_trend')=7,'stats always contain seven local days');
SELECT pg_temp.assert_true(jsonb_array_length(public.get_user_stats()->'achievements')>=1,'stats include achievements');
SELECT public.switch_class('A','secondary');
SELECT pg_temp.assert_true((SELECT class_id='A' AND current_xp>=0 FROM public.user_classes WHERE slot='secondary'),'class switching derives history');
SELECT pg_temp.denied('SELECT public.switch_class(''B'',''secondary'')','22023');
DO $$ DECLARE n integer; BEGIN FOR n IN 1..20 LOOP PERFORM pg_temp.assert_true(public.consume_coach_request(),'coach requests below quota accepted'); END LOOP; PERFORM pg_temp.assert_true(NOT public.consume_coach_request(),'coach daily quota enforced'); END $$;
SELECT pg_temp.denied('UPDATE public.coach_daily_usage SET request_count=0');
RESET ROLE;
UPDATE public.streaks SET last_activity_date=(now() AT TIME ZONE 'Asia/Ho_Chi_Minh')::date-2,current_streak=4 WHERE user_id='11111111-1111-1111-1111-111111111111';
SET LOCAL ROLE authenticated;
SELECT pg_temp.assert_true((public.get_user_stats()->'streak'->>'current_streak')::integer=0,'stale streak displays zero even before sync');
SELECT public.sync_daily_data();
SELECT pg_temp.assert_true((SELECT current_streak=0 FROM public.streaks),'missed day resets current streak');
RESET ROLE;
ROLLBACK;
