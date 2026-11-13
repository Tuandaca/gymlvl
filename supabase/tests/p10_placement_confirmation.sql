-- Task 2: atomic enrollment and receipt-backed confirmation, isolated fixtures.
BEGIN;
INSERT INTO auth.users(id,email) VALUES ('a2000000-0000-4000-8000-000000000001','placement-confirm@example.test');
SELECT set_config('request.jwt.claim.sub','a2000000-0000-4000-8000-000000000001',true);
SELECT set_config('request.jwt.claims','{"sub":"a2000000-0000-4000-8000-000000000001","role":"authenticated"}',true);
SET LOCAL ROLE authenticated;
DO $$ DECLARE r jsonb; BEGIN
 r=public.initialize_user('{"environment":"calisthenics","goals":["hypertrophy"],"experience_level":"advanced","age":25,"gender":"other","height_cm":170,"weight_kg":70,"weekly_gym_days":0,"weekly_home_days":3,"preferred_training_days":["mon","wed","fri"],"primary_class_id":"E","placement":{"operationId":"a2000000-0000-4000-8000-000000000010","request":{"policyVersion":"placement-v0.1","classId":"E","hasTrainingExperience":true,"skip":false,"equipment":{"barbell":false,"pullUpBar":true},"anchors":[]}}}');
 IF r->'placement'->>'status' IS DISTINCT FROM 'insufficient' THEN RAISE EXCEPTION 'first onboarding placement missing'; END IF;
END $$;
RESET ROLE;
SELECT set_config('request.jwt.claim.sub','a2000000-0000-4000-8000-000000000001',true);
SELECT set_config('request.jwt.claims','{"sub":"a2000000-0000-4000-8000-000000000001","role":"authenticated"}',true);
SET LOCAL ROLE authenticated;
DO $$ DECLARE r jsonb; BEGIN
 r=public.submit_placement_assessment_v1('a2000000-0000-4000-8000-000000000011',jsonb_build_object('policyVersion','placement-v0.1','classId','E','hasTrainingExperience',true,'skip',false,'equipment',jsonb_build_object('barbell',false,'pullUpBar',true),'anchors',jsonb_build_array(jsonb_build_object('exerciseId',(SELECT id FROM public.exercises WHERE slug='pull-up' LIMIT 1),'protocolVersion','strict-v1','loadKg',0,'reps',4,'durationSeconds',0),jsonb_build_object('exerciseId',(SELECT id FROM public.exercises WHERE slug='push-up' LIMIT 1),'protocolVersion','strict-v1','loadKg',0,'reps',22,'durationSeconds',0))));
 IF r->>'status' IS DISTINCT FROM 'pending' OR r->>'reason' IS DISTINCT FROM 'provisional' THEN RAISE EXCEPTION 'assessment retry status %',r; END IF;
 IF (SELECT count(*) FROM public.placement_assessments WHERE user_id='a2000000-0000-4000-8000-000000000001' AND status='superseded')<>1 THEN RAISE EXCEPTION 'insufficient assessment was not superseded'; END IF;
END $$;
RESET ROLE;
UPDATE public.placement_assessments SET submitted_at=clock_timestamp()-interval '3 days' WHERE user_id='a2000000-0000-4000-8000-000000000001' AND status='pending';
DO $$ DECLARE wid uuid; weid uuid; weid2 uuid; exid uuid; exid2 uuid; reward uuid; uid uuid:='a2000000-0000-4000-8000-000000000001'; BEGIN
 SELECT id INTO exid FROM public.exercises WHERE slug='pull-up' LIMIT 1;
 SELECT id INTO exid2 FROM public.exercises WHERE slug='push-up' LIMIT 1;
 wid:='a2000000-0000-4000-8000-000000000101'; weid:='a2000000-0000-4000-8000-000000000102'; weid2:='a2000000-0000-4000-8000-000000000107'; reward:='a2000000-0000-4000-8000-000000000103';
 INSERT INTO public.workouts(id,user_id,status,training_started_at,is_xp_calculated) VALUES(wid,uid,'active',clock_timestamp()-interval '2 days',false);
 INSERT INTO public.workout_exercises(id,workout_id,exercise_id,order_index) VALUES(weid,wid,exid,0);
 INSERT INTO public.workout_exercises(id,workout_id,exercise_id,order_index) VALUES(weid2,wid,exid2,1);
 INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,duration_seconds,is_completed) VALUES(weid,1,4,0,0,true);
 INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,duration_seconds,is_completed) VALUES(weid2,1,22,0,0,true);
 UPDATE public.workouts SET status='completed',completed_at=training_started_at,is_xp_calculated=true WHERE id=wid;
 INSERT INTO public.workout_rewards(workout_id,user_id,result) VALUES(wid,uid,'{"earnedXP":50,"isSuspicious":false}'::jsonb);
 wid:='a2000000-0000-4000-8000-000000000104'; weid:='a2000000-0000-4000-8000-000000000105'; weid2:='a2000000-0000-4000-8000-000000000108'; reward:='a2000000-0000-4000-8000-000000000106';
 INSERT INTO public.workouts(id,user_id,status,training_started_at,is_xp_calculated) VALUES(wid,uid,'active',clock_timestamp()-interval '1 day',false);
 INSERT INTO public.workout_exercises(id,workout_id,exercise_id,order_index) VALUES(weid,wid,exid,0);
 INSERT INTO public.workout_exercises(id,workout_id,exercise_id,order_index) VALUES(weid2,wid,exid2,1);
 INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,duration_seconds,is_completed) VALUES(weid,1,4,0,0,true);
 INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,duration_seconds,is_completed) VALUES(weid2,1,22,0,0,true);
 UPDATE public.workouts SET status='completed',completed_at=training_started_at,is_xp_calculated=true WHERE id=wid;
 INSERT INTO public.workout_rewards(workout_id,user_id,result) VALUES(wid,uid,'{"earnedXP":50,"isSuspicious":false}'::jsonb);
 IF (SELECT count(*) FROM public.placement_confirmations WHERE user_id=uid)<>1 THEN RAISE EXCEPTION 'two-date confirmation missing'; END IF;
 IF (SELECT count(*) FROM public.placement_workout_evidence WHERE user_id=uid AND qualifying)<>2 THEN RAISE EXCEPTION 'evidence count mismatch'; END IF;
END $$;
RESET ROLE;
ROLLBACK;
