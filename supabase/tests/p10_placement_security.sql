BEGIN;
DO $$ BEGIN
IF has_table_privilege('authenticated','public.placement_assessments','INSERT') OR has_table_privilege('anon','public.placement_assessments','SELECT') THEN RAISE EXCEPTION 'placement ACL'; END IF;
IF has_function_privilege('authenticated','public.placement_score_v1(text,numeric,integer,integer,numeric)','EXECUTE') THEN RAISE EXCEPTION 'helper exposed'; END IF;
END $$;
ROLLBACK;

BEGIN;
CREATE FUNCTION pg_temp.expect_placement_invalid(req jsonb) RETURNS void LANGUAGE plpgsql AS $$ BEGIN
 BEGIN PERFORM public.placement_normalize_v1(req); RAISE EXCEPTION 'malicious request accepted: %',req;
 EXCEPTION WHEN SQLSTATE '22023' THEN NULL; END;
END $$;
DO $$ DECLARE req jsonb; a jsonb; bad jsonb; eid uuid; metric text;
BEGIN
 SELECT id INTO eid FROM public.exercises WHERE slug='push-up';
 a=jsonb_build_object('exerciseId',eid,'protocolVersion','strict-v1','reps',20);
 req=jsonb_build_object('policyVersion','placement-v0.1','classId','A','hasTrainingExperience',true,'skip',false,'equipment',jsonb_build_object('barbell',false,'pullUpBar',false),'anchors',jsonb_build_array(a));
 PERFORM pg_temp.expect_placement_invalid(req||'{"level":10}');
 PERFORM pg_temp.expect_placement_invalid(jsonb_set(req,'{hasTrainingExperience}','"true"'));
 PERFORM pg_temp.expect_placement_invalid(jsonb_set(req,'{anchors}',jsonb_build_array(a,a)));
 PERFORM pg_temp.expect_placement_invalid(jsonb_set(req,'{anchors}',jsonb_build_array(a,a,a,a)));
 PERFORM pg_temp.expect_placement_invalid(jsonb_set(req,'{anchors,0,protocolVersion}','"assisted-v1"'));
 PERFORM pg_temp.expect_placement_invalid(jsonb_set(req,'{anchors,0,exerciseId}','"00000000-0000-0000-0000-000000000000"'));
 PERFORM pg_temp.expect_placement_invalid(jsonb_set(req,'{anchors,0,exerciseId}','"not-a-uuid"'));
 PERFORM pg_temp.expect_placement_invalid(jsonb_set(req,'{anchors,0,loadKg}','5'));
 PERFORM pg_temp.expect_placement_invalid(jsonb_set(req,'{anchors,0,durationSeconds}','10'));
 PERFORM pg_temp.expect_placement_invalid(jsonb_set(req,'{anchors,0,reps}','1.5'));
 FOREACH bad IN ARRAY ARRAY['"NaN"'::jsonb,'"Infinity"'::jsonb,'null'::jsonb,'1e1000'::jsonb,'-1'::jsonb] LOOP
 PERFORM pg_temp.expect_placement_invalid(jsonb_set(req,'{anchors,0,reps}',bad)); END LOOP;
 BEGIN PERFORM public.placement_score_v1('barbell-squat','NaN',8,0,70); RAISE EXCEPTION 'nonfinite helper accepted'; EXCEPTION WHEN SQLSTATE '22023' THEN NULL; END;
END $$;
INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES ('a1000000-0000-4000-8000-000000000002','placement-owner@example.test','{}'),('a1000000-0000-4000-8000-000000000003','placement-other@example.test','{}');
SELECT set_config('request.jwt.claim.sub','a1000000-0000-4000-8000-000000000002',true);
SELECT set_config('request.jwt.claims','{"sub":"a1000000-0000-4000-8000-000000000002","role":"authenticated"}',true);
SET LOCAL ROLE authenticated;
SELECT public.initialize_user('{"environment":"home","goals":["hypertrophy"],"experience_level":"beginner","age":25,"gender":"other","height_cm":170,"weight_kg":70,"weekly_gym_days":0,"weekly_home_days":3,"preferred_training_days":["mon","wed","fri"],"primary_class_id":"A"}');
DO $$ BEGIN
 BEGIN PERFORM public.submit_placement_assessment_v1(gen_random_uuid(),'{"policyVersion":"placement-v0.1","classId":"A","hasTrainingExperience":true,"skip":true,"equipment":{"barbell":false,"pullUpBar":false},"anchors":[]}'); RAISE EXCEPTION 'legacy enrollment accepted'; EXCEPTION WHEN SQLSTATE '42501' THEN NULL; END;
END $$;
RESET ROLE;
SELECT public.placement_register_v1('a1000000-0000-4000-8000-000000000002',gen_random_uuid(),'{"policyVersion":"placement-v0.1","classId":"A","hasTrainingExperience":false,"skip":false,"equipment":{"barbell":false,"pullUpBar":false},"anchors":[]}',true);
SET LOCAL ROLE authenticated;
DO $$ BEGIN
 IF (SELECT count(*) FROM public.placement_assessments)<>1 THEN RAISE EXCEPTION 'owner cannot read'; END IF;
 BEGIN PERFORM public.submit_placement_assessment_v1(gen_random_uuid(),'{"policyVersion":"placement-v0.1","classId":"A","hasTrainingExperience":true,"skip":true,"equipment":{"barbell":false,"pullUpBar":false},"anchors":[]}'); RAISE EXCEPTION 'never trained enrollment changed'; EXCEPTION WHEN SQLSTATE '42501' THEN NULL; END;
 BEGIN UPDATE public.placement_assessments SET status='confirmed'; RAISE EXCEPTION 'client write accepted'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
 BEGIN PERFORM public.placement_register_v1(auth.uid(),gen_random_uuid(),'{}',true); RAISE EXCEPTION 'helper execute accepted'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END $$;
SELECT set_config('request.jwt.claim.sub','a1000000-0000-4000-8000-000000000003',true);
DO $$ BEGIN IF EXISTS(SELECT 1 FROM public.placement_assessments) THEN RAISE EXCEPTION 'other owner visible'; END IF; END $$;
RESET ROLE;
SET LOCAL ROLE anon;
DO $$ BEGIN
 BEGIN PERFORM 1 FROM public.placement_assessments; RAISE EXCEPTION 'anon read accepted'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
 BEGIN PERFORM public.submit_placement_assessment_v1(gen_random_uuid(),'{}'); RAISE EXCEPTION 'anon RPC accepted'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END $$;
RESET ROLE;
DO $$ DECLARE tab text; priv text; fn text;
BEGIN
 FOREACH tab IN ARRAY ARRAY['placement_assessments','placement_workout_evidence','placement_confirmations'] LOOP
 FOREACH priv IN ARRAY ARRAY['INSERT','UPDATE','DELETE','TRUNCATE','TRIGGER','REFERENCES'] LOOP
 IF has_table_privilege('authenticated','public.'||tab,priv) OR has_table_privilege('anon','public.'||tab,priv) THEN RAISE EXCEPTION 'unsafe % %',tab,priv; END IF;
 END LOOP; END LOOP;
END $$;
ROLLBACK;
