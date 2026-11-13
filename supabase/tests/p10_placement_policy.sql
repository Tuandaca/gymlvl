BEGIN;
DO $$ BEGIN
IF public.placement_score_v1('push-up',0,20,0,70)<>4 THEN RAISE EXCEPTION 'inclusive push-up threshold'; END IF;
IF public.placement_score_v1('barbell-squat',70,8,0,70)<>4 OR public.placement_score_v1('barbell-bench-press',42.5,8,0,70)<>3 OR public.placement_score_v1('barbell-deadlift',80,6,0,70)<>3 THEN RAISE EXCEPTION 'C golden scores'; END IF;
IF public.placement_score_v1('pull-up',0,4,0,70)<>3 OR public.placement_score_v1('push-up',0,22,0,70)<>4 OR public.placement_score_v1('plank',0,0,100,70)<>4 THEN RAISE EXCEPTION 'E golden scores'; END IF;
END $$;
ROLLBACK;

-- Numeric policy includes every exact and immediately-lower boundary.
BEGIN;
DO $$ DECLARE slug text; bands numeric[]; i integer; got integer; expected integer; load numeric;
BEGIN
 FOR slug,bands IN SELECT * FROM (VALUES
 ('barbell-bench-press',ARRAY[0.4,0.6,0.8,1.0]::numeric[]),('barbell-squat',ARRAY[0.75,1.0,1.25,1.5]::numeric[]),('barbell-deadlift',ARRAY[0.9,1.2,1.5,1.8]::numeric[]),
 ('push-up',ARRAY[5,10,20,30]::numeric[]),('pull-up',ARRAY[1,3,6,10]::numeric[]),('bodyweight-air-squat',ARRAY[10,20,30,40]::numeric[]),('plank',ARRAY[30,60,90,120]::numeric[])) v(s,b) LOOP
 FOR i IN 1..4 LOOP
 IF slug LIKE 'barbell-%' THEN
 -- Six repetitions at mass 72 makes e1RM/mass exactly load/60.
 got=public.placement_score_v1(slug,bands[i]*60,6,0,72);
 expected=public.placement_score_v1(slug,bands[i]*60-0.000001,6,0,72);
 ELSIF slug='plank' THEN got=public.placement_score_v1(slug,0,0,bands[i]::integer,70); expected=public.placement_score_v1(slug,0,0,bands[i]::integer-1,70);
 ELSE got=public.placement_score_v1(slug,0,bands[i]::integer,0,70); expected=public.placement_score_v1(slug,0,bands[i]::integer-1,0,70); END IF;
 IF got<>i+1 OR expected<>i THEN RAISE EXCEPTION 'threshold % band %: %, %',slug,i,got,expected; END IF;
 END LOOP; END LOOP;
END $$;
CREATE FUNCTION pg_temp.placement_request(c text, slugs text[], loads numeric[], reps integer[], durations integer[],barbell boolean DEFAULT true,pullbar boolean DEFAULT true) RETURNS jsonb LANGUAGE sql AS $$
 SELECT jsonb_build_object('policyVersion','placement-v0.1','classId',c,'hasTrainingExperience',true,'skip',false,'equipment',jsonb_build_object('barbell',barbell,'pullUpBar',pullbar),'anchors',coalesce((SELECT jsonb_agg(jsonb_build_object('exerciseId',e.id,'protocolVersion','strict-v1','loadKg',loads[i],'reps',reps[i],'durationSeconds',durations[i])) FROM generate_subscripts(slugs,1) i JOIN public.exercises e ON e.slug=slugs[i]),'[]'));
$$;
INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES ('a1000000-0000-4000-8000-000000000001','placement-policy@example.test','{}');
SELECT set_config('request.jwt.claim.sub','a1000000-0000-4000-8000-000000000001',true);
SELECT set_config('request.jwt.claims','{"sub":"a1000000-0000-4000-8000-000000000001","role":"authenticated"}',true);
SET LOCAL ROLE authenticated;
SELECT public.initialize_user('{"environment":"gym","goals":["hypertrophy"],"experience_level":"advanced","age":25,"gender":"other","height_cm":170,"weight_kg":70,"weekly_gym_days":3,"weekly_home_days":0,"preferred_training_days":["mon","wed","fri"],"primary_class_id":"C"}');
RESET ROLE;
DO $$ DECLARE req jsonb; r jsonb; replay jsonb; op uuid=gen_random_uuid(); uid uuid='a1000000-0000-4000-8000-000000000001';
BEGIN
 req=pg_temp.placement_request('C',ARRAY['barbell-squat','barbell-bench-press','barbell-deadlift'],ARRAY[70,42.5,80],ARRAY[8,8,6],ARRAY[0,0,0]);
 r=public.placement_register_v1(uid,op,req,true);
 IF (r->>'provisionalClassLevel')::int<>3 OR (r->>'provisionalGlobalLevel')::int<>5 THEN RAISE EXCEPTION 'C worked example %',r; END IF;
 IF (SELECT level<>1 OR total_xp<>0 FROM public.users WHERE id=uid) OR EXISTS(SELECT 1 FROM public.xp_logs WHERE user_id=uid) THEN RAISE EXCEPTION 'placement changed earned progression'; END IF;
 UPDATE public.user_classes SET class_id='E' WHERE user_id=uid AND slot='primary';
 -- Reordering/default zeros must retain immutable receipt after current class changes.
 SELECT jsonb_agg(value-'durationSeconds' ORDER BY value->>'exerciseId' DESC) INTO replay FROM jsonb_array_elements(req->'anchors');
 replay=public.submit_placement_assessment_v1(op,jsonb_set(req,'{anchors}',replay));
 IF replay<>r THEN RAISE EXCEPTION 'immutable replay'; END IF;
 BEGIN PERFORM public.submit_placement_assessment_v1(op,jsonb_set(req,'{skip}','true')); RAISE EXCEPTION 'changed operation accepted'; EXCEPTION WHEN SQLSTATE '22023' THEN NULL; END;
 req=pg_temp.placement_request('E',ARRAY['pull-up','push-up','plank'],ARRAY[0,0,0],ARRAY[4,22,0],ARRAY[0,0,100]);
 r=public.submit_placement_assessment_v1(gen_random_uuid(),req);
 IF (r->>'provisionalClassLevel')::int<>4 OR (r->>'provisionalGlobalLevel')::int<>7 THEN RAISE EXCEPTION 'E worked example'; END IF;
 IF (SELECT count(*) FROM public.placement_assessments WHERE user_id=uid AND status='pending')<>1 THEN RAISE EXCEPTION 'pending uniqueness'; END IF;
 req=pg_temp.placement_request('E',ARRAY['push-up','plank'],ARRAY[0,0],ARRAY[30,0],ARRAY[0,120],false,false);
 r=public.submit_placement_assessment_v1(gen_random_uuid(),req);
 IF (r->>'provisionalClassLevel')::int<>3 THEN RAISE EXCEPTION 'E floor-only cap'; END IF;
 req=pg_temp.placement_request('E',ARRAY['push-up'],ARRAY[0],ARRAY[30],ARRAY[0]);
 r=public.submit_placement_assessment_v1(gen_random_uuid(),req);
 IF r->>'status'<>'insufficient' OR (r->>'provisionalClassLevel')::int<>1 THEN RAISE EXCEPTION 'one anchor'; END IF;
 UPDATE public.profiles SET age=17 WHERE id=uid;
 r=public.submit_placement_assessment_v1(gen_random_uuid(),req);
 IF r->>'status'<>'ineligible' OR r->>'reason'<>'unsupported_age' THEN RAISE EXCEPTION 'age coverage'; END IF;
 UPDATE public.profiles SET age=25 WHERE id=uid;
 req=jsonb_set(req,'{skip}','true');
 r=public.submit_placement_assessment_v1(gen_random_uuid(),req);
 IF r->>'status'<>'skipped' OR (SELECT anchor_inputs<>'[]' FROM public.placement_assessments WHERE id=(r->>'assessmentId')::uuid) THEN RAISE EXCEPTION 'skip stores performance'; END IF;
 UPDATE public.user_classes SET class_id='C' WHERE user_id=uid AND slot='primary';
 req=pg_temp.placement_request('C',ARRAY['push-up','bodyweight-air-squat','plank'],ARRAY[0,0,0],ARRAY[30,40,0],ARRAY[0,120,120],false,false);
 req=jsonb_set(req,'{anchors,1,durationSeconds}','0');
 r=public.submit_placement_assessment_v1(gen_random_uuid(),req);
 IF r->>'reason'<>'missing_equipment' OR (r->>'provisionalClassLevel')::int<>1 THEN RAISE EXCEPTION 'B/C/F equipment gate'; END IF;
END $$;
ROLLBACK;
