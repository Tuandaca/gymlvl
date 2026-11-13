-- D-060 / D-062: local/test placement. No earned progression is modified here.
CREATE TABLE public.placement_assessments (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
 operation_id uuid NOT NULL, policy_version text NOT NULL CHECK(policy_version='placement-v0.1'),
 assessed_class_id text NOT NULL CHECK(assessed_class_id IN ('A','B','C','D','E','F')),
 submitted_at timestamptz NOT NULL DEFAULT clock_timestamp(), updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 status text NOT NULL CHECK(status IN ('pending','skipped','never_trained','ineligible','insufficient','superseded','confirmed')),
 normalized_request jsonb NOT NULL, submission_result jsonb NOT NULL,
 age_snapshot integer NOT NULL, body_mass_kg_snapshot numeric NOT NULL, timezone_snapshot text NOT NULL,
 anchor_inputs jsonb NOT NULL, anchor_scores jsonb NOT NULL DEFAULT '[]',
 provisional_class_level integer NOT NULL CHECK(provisional_class_level BETWEEN 1 AND 5),
 provisional_global_level integer NOT NULL CHECK(provisional_global_level IN (1,3,5,7,10)), reason text NOT NULL,
 is_initial_enrollment boolean NOT NULL DEFAULT false,
 initial_assessment_id uuid REFERENCES public.placement_assessments(id) ON DELETE CASCADE,
 has_training_experience boolean NOT NULL,
 recommended_plan_route text NOT NULL CHECK(recommended_plan_route IN ('beginner_first_week','routine_selection','none')),
 UNIQUE(user_id,operation_id), UNIQUE(id,user_id)
);
CREATE UNIQUE INDEX placement_one_initial ON public.placement_assessments(user_id) WHERE is_initial_enrollment;
CREATE UNIQUE INDEX placement_one_pending ON public.placement_assessments(user_id) WHERE status='pending';
CREATE TABLE public.placement_workout_evidence (
 assessment_id uuid NOT NULL, workout_id uuid NOT NULL REFERENCES public.workouts(id) ON DELETE CASCADE,
 user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
 completed_at timestamptz NOT NULL, local_date date NOT NULL, assessed_class_id text NOT NULL,
 phase text NOT NULL CHECK(phase IN ('evidence','progress')), qualifying boolean NOT NULL, reason text NOT NULL,
 anchor_scores jsonb NOT NULL DEFAULT '[]', class_score integer CHECK(class_score BETWEEN 1 AND 5),
 global_xp_delta integer NOT NULL DEFAULT 0 CHECK(global_xp_delta>=0), class_xp_delta integer NOT NULL DEFAULT 0 CHECK(class_xp_delta>=0),
 policy_version text NOT NULL CHECK(policy_version='placement-v0.1'),
 PRIMARY KEY(assessment_id,workout_id),
 FOREIGN KEY(assessment_id,user_id) REFERENCES public.placement_assessments(id,user_id) ON DELETE CASCADE
);
CREATE TABLE public.placement_confirmations (
 user_id uuid PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
 assessment_id uuid NOT NULL UNIQUE, assessed_class_id text NOT NULL,
 policy_version text NOT NULL CHECK(policy_version='placement-v0.1'),
 confirmed_class_floor integer NOT NULL CHECK(confirmed_class_floor BETWEEN 1 AND 5),
 confirmed_global_floor integer NOT NULL CHECK(confirmed_global_floor IN (1,3,5,7,10)),
 confirming_workout_id uuid REFERENCES public.workouts(id) ON DELETE SET NULL,
 confirmed_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 earned_global_xp_snapshot bigint NOT NULL, earned_class_xp_snapshot bigint NOT NULL,
 class_xp_base_snapshot integer NOT NULL, class_xp_slope_snapshot numeric NOT NULL,
 FOREIGN KEY(assessment_id,user_id) REFERENCES public.placement_assessments(id,user_id) ON DELETE CASCADE
);
ALTER TABLE public.placement_assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.placement_workout_evidence ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.placement_confirmations ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.placement_assessments,public.placement_workout_evidence,public.placement_confirmations FROM PUBLIC,anon,authenticated;
GRANT SELECT ON public.placement_assessments,public.placement_workout_evidence,public.placement_confirmations TO authenticated;
CREATE POLICY placement_owner_read ON public.placement_assessments FOR SELECT TO authenticated USING(user_id=(SELECT auth.uid()));
CREATE POLICY placement_owner_read ON public.placement_workout_evidence FOR SELECT TO authenticated USING(user_id=(SELECT auth.uid()));
CREATE POLICY placement_owner_read ON public.placement_confirmations FOR SELECT TO authenticated USING(user_id=(SELECT auth.uid()));

CREATE FUNCTION public.placement_score_v1(p_slug text,p_load numeric,p_reps integer,p_duration integer,p_mass numeric)
RETURNS integer LANGUAGE plpgsql IMMUTABLE SET search_path='' AS $$
DECLARE v numeric; bands numeric[]; i integer; result integer=1;
BEGIN
 IF p_slug IS NULL OR p_load IS NULL OR p_reps IS NULL OR p_duration IS NULL OR p_mass IS NULL
 OR p_load::text IN ('NaN','Infinity','-Infinity') OR p_mass::text IN ('NaN','Infinity','-Infinity')
 OR p_load<0 OR p_load>1000 OR p_reps<0 OR p_reps>1000 OR p_duration<0 OR p_duration>7200 THEN
 RAISE EXCEPTION 'Invalid placement metrics' USING ERRCODE='22023'; END IF;
 IF p_slug IN ('barbell-bench-press','barbell-squat','barbell-deadlift') THEN
 IF p_reps NOT BETWEEN 4 AND 10 OR p_duration<>0 OR p_load<=0 OR p_mass NOT BETWEEN 20 AND 400 THEN RAISE EXCEPTION 'Invalid barbell protocol' USING ERRCODE='22023'; END IF;
 v=p_load*(1+p_reps/30.0)/p_mass;
 bands=CASE p_slug WHEN 'barbell-bench-press' THEN ARRAY[0.4,0.6,0.8,1.0] WHEN 'barbell-squat' THEN ARRAY[0.75,1.0,1.25,1.5] ELSE ARRAY[0.9,1.2,1.5,1.8] END;
 ELSE
 IF p_load<>0 THEN RAISE EXCEPTION 'External bodyweight load is unsupported' USING ERRCODE='22023'; END IF;
 IF p_slug='plank' THEN
 IF p_reps<>0 THEN RAISE EXCEPTION 'Plank requires duration only' USING ERRCODE='22023'; END IF;
 v=p_duration; bands=ARRAY[30,60,90,120];
 ELSE
 IF p_duration<>0 THEN RAISE EXCEPTION 'Repetition anchor has duration' USING ERRCODE='22023'; END IF;
 v=p_reps;
 bands=CASE p_slug WHEN 'push-up' THEN ARRAY[5,10,20,30] WHEN 'pull-up' THEN ARRAY[1,3,6,10] WHEN 'bodyweight-air-squat' THEN ARRAY[10,20,30,40] ELSE NULL END;
 IF bands IS NULL THEN RAISE EXCEPTION 'Unsupported anchor' USING ERRCODE='22023'; END IF;
 END IF;
 END IF;
 FOR i IN 1..4 LOOP IF v>=bands[i] THEN result=i+1; END IF; END LOOP;
 RETURN result;
END $$;

CREATE FUNCTION public.placement_normalize_v1(p_request jsonb) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $$
DECLARE a jsonb; eq jsonb; normalized jsonb='[]'; eid uuid; seen uuid[]='{}'; slug text; metric text; n numeric; load numeric; reps integer; duration integer;
BEGIN
 IF jsonb_typeof(p_request) IS DISTINCT FROM 'object' OR EXISTS(SELECT 1 FROM jsonb_object_keys(p_request) k WHERE k NOT IN ('policyVersion','classId','hasTrainingExperience','skip','equipment','anchors'))
 OR p_request->>'policyVersion' IS DISTINCT FROM 'placement-v0.1' OR coalesce(p_request->>'classId','') NOT IN ('A','B','C','D','E','F')
 OR jsonb_typeof(p_request->'hasTrainingExperience') IS DISTINCT FROM 'boolean' OR jsonb_typeof(p_request->'skip') IS DISTINCT FROM 'boolean'
 THEN RAISE EXCEPTION 'Invalid placement request' USING ERRCODE='22023'; END IF;
 eq=p_request->'equipment';
 IF jsonb_typeof(eq) IS DISTINCT FROM 'object' OR EXISTS(SELECT 1 FROM jsonb_object_keys(eq) k WHERE k NOT IN ('barbell','pullUpBar'))
 OR jsonb_typeof(eq->'barbell') IS DISTINCT FROM 'boolean' OR jsonb_typeof(eq->'pullUpBar') IS DISTINCT FROM 'boolean'
 OR jsonb_typeof(p_request->'anchors') IS DISTINCT FROM 'array' THEN RAISE EXCEPTION 'Invalid equipment/anchors' USING ERRCODE='22023'; END IF;
 IF jsonb_array_length(p_request->'anchors')>3 THEN RAISE EXCEPTION 'At most three anchors' USING ERRCODE='22023'; END IF;
 FOR a IN SELECT value FROM jsonb_array_elements(p_request->'anchors') LOOP
 IF jsonb_typeof(a) IS DISTINCT FROM 'object' OR EXISTS(SELECT 1 FROM jsonb_object_keys(a) k WHERE k NOT IN ('exerciseId','protocolVersion','loadKg','reps','durationSeconds'))
 OR a->>'protocolVersion' IS DISTINCT FROM 'strict-v1' OR jsonb_typeof(a->'exerciseId') IS DISTINCT FROM 'string' THEN RAISE EXCEPTION 'Invalid anchor fields/protocol' USING ERRCODE='22023'; END IF;
 BEGIN eid=(a->>'exerciseId')::uuid; EXCEPTION WHEN invalid_text_representation THEN RAISE EXCEPTION 'Invalid exercise UUID' USING ERRCODE='22023'; END;
 IF eid=ANY(seen) THEN RAISE EXCEPTION 'Duplicate anchor' USING ERRCODE='22023'; END IF; seen=array_append(seen,eid);
 SELECT e.slug INTO slug FROM public.exercises e WHERE e.id=eid AND e.source='gymlvl_curated' AND e.user_id IS NULL AND e.slug IN ('barbell-bench-press','barbell-squat','barbell-deadlift','push-up','pull-up','bodyweight-air-squat','plank');
 IF slug IS NULL THEN RAISE EXCEPTION 'Unsupported canonical anchor' USING ERRCODE='22023'; END IF;
 FOREACH metric IN ARRAY ARRAY['loadKg','reps','durationSeconds'] LOOP
 IF a ? metric THEN
 IF jsonb_typeof(a->metric) IS DISTINCT FROM 'number' THEN RAISE EXCEPTION 'Numeric metrics required' USING ERRCODE='22023'; END IF;
 n=(a->>metric)::numeric;
 IF n<0 OR n>(CASE metric WHEN 'loadKg' THEN 1000 WHEN 'reps' THEN 1000 ELSE 7200 END) OR (metric<>'loadKg' AND n<>trunc(n)) THEN RAISE EXCEPTION 'Metric out of bounds' USING ERRCODE='22023'; END IF;
 END IF; END LOOP;
 load=coalesce((a->>'loadKg')::numeric,0); reps=coalesce((a->>'reps')::integer,0); duration=coalesce((a->>'durationSeconds')::integer,0);
 PERFORM public.placement_score_v1(slug,load,reps,duration,70);
 normalized=normalized||jsonb_build_array(jsonb_build_object('exerciseId',eid,'protocolVersion','strict-v1','loadKg',load,'reps',reps,'durationSeconds',duration));
 END LOOP;
 IF (p_request->>'skip')::boolean OR NOT (p_request->>'hasTrainingExperience')::boolean THEN normalized='[]'; END IF;
 SELECT coalesce(jsonb_agg(value ORDER BY value->>'exerciseId'),'[]') INTO normalized FROM jsonb_array_elements(normalized);
 RETURN p_request||jsonb_build_object('anchors',normalized);
END $$;

-- Private shared entry point. Only initialize_user's first onboarding may pass true.
CREATE FUNCTION public.placement_register_v1(p_user_id uuid,p_operation_id uuid,p_request jsonb,p_initial boolean DEFAULT false)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE req jsonb; old public.placement_assessments; initial public.placement_assessments; p public.profiles; a jsonb; slug text; allowed text[]; scores integer[]='{}'; anchor_scores jsonb='[]'; score integer; cl integer=1; gl integer=1; cap integer=5; outcome text='pending'; why text='provisional'; route text; ident uuid=gen_random_uuid(); receipt jsonb; primary_id text;
BEGIN
 IF p_user_id IS NULL OR p_operation_id IS NULL OR p_initial IS NULL THEN RAISE EXCEPTION 'Owner and operation required' USING ERRCODE='22023'; END IF;
 PERFORM 1 FROM public.users WHERE id=p_user_id FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Unknown user' USING ERRCODE='42501'; END IF;
 req=public.placement_normalize_v1(p_request);
 SELECT * INTO old FROM public.placement_assessments WHERE user_id=p_user_id AND operation_id=p_operation_id;
 IF FOUND THEN
 IF old.normalized_request<>req THEN RAISE EXCEPTION 'Operation reused with changed request' USING ERRCODE='22023'; END IF;
 RETURN old.submission_result;
 END IF;
 SELECT * INTO initial FROM public.placement_assessments WHERE user_id=p_user_id AND is_initial_enrollment;
 IF p_initial THEN
 IF initial.id IS NOT NULL THEN RAISE EXCEPTION 'Already enrolled' USING ERRCODE='22023'; END IF;
 ELSE
 IF initial.id IS NULL OR NOT initial.has_training_experience OR EXISTS(SELECT 1 FROM public.placement_confirmations WHERE user_id=p_user_id) THEN RAISE EXCEPTION 'Initial placement enrollment required' USING ERRCODE='42501'; END IF;
 IF NOT (req->>'hasTrainingExperience')::boolean THEN RAISE EXCEPTION 'Initial experience is immutable' USING ERRCODE='22023'; END IF;
 END IF;
 SELECT * INTO p FROM public.profiles WHERE id=p_user_id;
 SELECT class_id INTO primary_id FROM public.user_classes WHERE user_id=p_user_id AND slot='primary';
 IF p.id IS NULL OR p.age IS NULL OR p.weight_kg IS NULL OR primary_id IS DISTINCT FROM req->>'classId' THEN RAISE EXCEPTION 'Placement must assess current primary class' USING ERRCODE='22023'; END IF;
 route=CASE WHEN (req->>'hasTrainingExperience')::boolean THEN 'routine_selection' ELSE 'beginner_first_week' END;
 IF NOT (req->>'hasTrainingExperience')::boolean THEN outcome='never_trained'; why='never_trained';
 ELSIF (req->>'skip')::boolean THEN outcome='skipped'; why='skipped';
 ELSIF p.age NOT BETWEEN 18 AND 64 THEN outcome='ineligible'; why='unsupported_age';
 ELSIF p.weight_kg NOT BETWEEN 20 AND 400 THEN outcome='ineligible'; why='missing_body_mass';
 ELSE
 allowed=CASE primary_id WHEN 'A' THEN ARRAY['push-up','bodyweight-air-squat','plank'] WHEN 'D' THEN ARRAY['push-up','bodyweight-air-squat','plank'] WHEN 'E' THEN ARRAY['pull-up','push-up','plank'] WHEN 'F' THEN ARRAY['barbell-bench-press','barbell-squat','push-up'] ELSE ARRAY['barbell-bench-press','barbell-squat','barbell-deadlift'] END;
 IF primary_id IN ('B','C','F') AND NOT (req->'equipment'->>'barbell')::boolean THEN allowed=ARRAY['push-up','bodyweight-air-squat','plank']; outcome='ineligible'; why='missing_equipment'; END IF;
 cap=CASE WHEN primary_id IN ('A','D','F') OR (primary_id='E' AND NOT EXISTS(SELECT 1 FROM jsonb_array_elements(req->'anchors') x JOIN public.exercises e ON e.id=(x->>'exerciseId')::uuid WHERE e.slug='pull-up')) THEN 3 ELSE 5 END;
 FOR a IN SELECT value FROM jsonb_array_elements(req->'anchors') LOOP
 SELECT e.slug INTO slug FROM public.exercises e WHERE e.id=(a->>'exerciseId')::uuid;
 IF NOT slug=ANY(allowed) OR (slug='pull-up' AND NOT (req->'equipment'->>'pullUpBar')::boolean) THEN RAISE EXCEPTION 'Anchor does not match class/equipment' USING ERRCODE='22023'; END IF;
 score=public.placement_score_v1(slug,(a->>'loadKg')::numeric,(a->>'reps')::integer,(a->>'durationSeconds')::integer,p.weight_kg);
 scores=array_append(scores,score); anchor_scores=anchor_scores||jsonb_build_array(jsonb_build_object('exerciseId',a->'exerciseId','score',score));
 END LOOP;
 IF outcome='pending' THEN
 IF cardinality(scores)<2 THEN outcome='insufficient'; why='insufficient_anchors';
 ELSE SELECT array_agg(s ORDER BY s) INTO scores FROM unnest(scores) s; cl=least(cap,scores[CASE WHEN cardinality(scores)=3 THEN 2 ELSE 1 END]); END IF;
 END IF;
 END IF;
 gl=CASE cl WHEN 2 THEN 3 WHEN 3 THEN 5 WHEN 4 THEN 7 WHEN 5 THEN 10 ELSE 1 END;
 UPDATE public.placement_assessments SET status='superseded',updated_at=clock_timestamp() WHERE user_id=p_user_id AND status IN ('pending','insufficient');
 receipt=jsonb_build_object('assessmentId',ident,'policyVersion','placement-v0.1','status',outcome,'assessedClassId',primary_id,'provisionalClassLevel',cl,'provisionalGlobalLevel',gl,'reason',why,'recommendedPlanRoute',route);
 INSERT INTO public.placement_assessments(id,user_id,operation_id,policy_version,assessed_class_id,status,normalized_request,submission_result,age_snapshot,body_mass_kg_snapshot,timezone_snapshot,anchor_inputs,anchor_scores,provisional_class_level,provisional_global_level,reason,is_initial_enrollment,initial_assessment_id,has_training_experience,recommended_plan_route)
 VALUES(ident,p_user_id,p_operation_id,'placement-v0.1',primary_id,outcome,req,receipt,p.age,p.weight_kg,p.timezone,req->'anchors',anchor_scores,cl,gl,why,p_initial,initial.id,CASE WHEN p_initial THEN (req->>'hasTrainingExperience')::boolean ELSE initial.has_training_experience END,route);
 RETURN receipt;
END $$;
CREATE FUNCTION public.submit_placement_assessment_v1(p_operation_id uuid,p_request jsonb) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
BEGIN
 IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Authentication required' USING ERRCODE='42501'; END IF;
 RETURN public.placement_register_v1(auth.uid(),p_operation_id,p_request,false);
END $$;
REVOKE ALL ON FUNCTION public.placement_score_v1(text,numeric,integer,integer,numeric),public.placement_normalize_v1(jsonb),public.placement_register_v1(uuid,uuid,jsonb,boolean),public.submit_placement_assessment_v1(uuid,jsonb) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.submit_placement_assessment_v1(uuid,jsonb) TO authenticated;






-- Task 2: receipt-backed placement evidence and confirmation.
CREATE OR REPLACE FUNCTION public.placement_record_workout_v1(p_workout_id uuid,p_user_id uuid,p_result jsonb)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE a public.placement_assessments; w public.workouts; p public.profiles; d date; anchor jsonb; eid uuid; slug text; best integer; score integer; valid_count integer:=0; scores integer[]:='{}'; anchor_scores jsonb:='[]'; qualifying boolean:=false; reason text:='insufficient_anchors'; cap integer:=5; first_date date; second_date date; low integer; class_delta integer; class_base integer; class_slope numeric;
BEGIN
 -- Lock the primary class before assessment evidence. The reward insert already
 -- holds a key-share lock on users for its foreign key; upgrading users here
 -- would deadlock two concurrent reward receipts. Class-switch and placement
 -- evidence now serialize on the same user_classes row instead.
 PERFORM 1 FROM public.user_classes WHERE user_id=p_user_id AND slot='primary' FOR UPDATE;
 SELECT * INTO a FROM public.placement_assessments WHERE user_id=p_user_id AND status IN ('pending','insufficient') AND has_training_experience ORDER BY submitted_at DESC LIMIT 1 FOR UPDATE; IF a.id IS NULL THEN RETURN; END IF;
 IF NOT EXISTS (SELECT 1 FROM public.user_classes WHERE user_id=p_user_id AND slot='primary' AND class_id=a.assessed_class_id) THEN UPDATE public.placement_assessments SET status='superseded',updated_at=clock_timestamp() WHERE id=a.id; RETURN; END IF;
 SELECT * INTO w FROM public.workouts WHERE id=p_workout_id AND user_id=p_user_id; IF w.id IS NULL OR w.status<>'completed' OR w.training_started_at IS NULL OR w.completed_at IS NULL OR w.training_started_at < a.submitted_at OR w.is_imported OR coalesce((p_result->>'isSuspicious')::boolean,false) OR NOT w.is_xp_calculated THEN RETURN; END IF;
 SELECT * INTO p FROM public.profiles WHERE id=p_user_id; IF p.id IS NULL OR p.weight_kg IS NULL OR p.timezone IS NULL THEN RETURN; END IF; d=(w.completed_at AT TIME ZONE a.timezone_snapshot)::date;
 FOR anchor IN SELECT value FROM jsonb_array_elements(a.anchor_inputs) LOOP
   eid=(anchor->>'exerciseId')::uuid; SELECT e.slug INTO slug FROM public.exercises e WHERE e.id=eid AND e.source='gymlvl_curated' AND e.user_id IS NULL; IF slug IS NULL THEN CONTINUE; END IF;
   SELECT max(public.placement_score_v1(slug,s.weight_kg,s.reps,coalesce(s.duration_seconds,0),a.body_mass_kg_snapshot)) INTO best FROM public.workout_exercises we JOIN public.workout_sets s ON s.workout_exercise_id=we.id WHERE we.workout_id=w.id AND we.exercise_id=eid AND s.is_completed AND (s.set_type IS NULL OR s.set_type='workout') AND s.weight_kg BETWEEN 0 AND 1000 AND s.reps BETWEEN 0 AND 1000 AND ((slug='plank' AND s.weight_kg=0 AND s.reps=0 AND coalesce(s.duration_seconds,0) BETWEEN 1 AND 7200) OR (slug LIKE 'barbell-%' AND s.weight_kg>0 AND s.reps BETWEEN 4 AND 10 AND coalesce(s.duration_seconds,0)=0) OR (slug NOT LIKE 'barbell-%' AND slug<>'plank' AND s.weight_kg=0 AND coalesce(s.duration_seconds,0)=0));
   IF best IS NOT NULL THEN valid_count:=valid_count+1; scores:=array_append(scores,best); anchor_scores:=anchor_scores||jsonb_build_array(jsonb_build_object('exerciseId',eid,'score',best)); END IF;
 END LOOP;
 IF valid_count>=2 THEN SELECT array_agg(x ORDER BY x) INTO scores FROM unnest(scores) x; cap:=CASE WHEN a.assessed_class_id IN ('A','D','F') OR (a.assessed_class_id='E' AND NOT EXISTS(SELECT 1 FROM jsonb_array_elements(a.anchor_inputs) x JOIN public.exercises e ON e.id=(x->>'exerciseId')::uuid WHERE e.slug='pull-up')) THEN 3 ELSE 5 END; score:=least(cap,scores[CASE WHEN valid_count=3 THEN 2 ELSE 1 END]); qualifying:=true; reason:='completed_workout'; END IF;
 INSERT INTO public.placement_workout_evidence(assessment_id,workout_id,user_id,completed_at,local_date,assessed_class_id,phase,qualifying,reason,anchor_scores,class_score,global_xp_delta,class_xp_delta,policy_version) VALUES(a.id,w.id,p_user_id,w.completed_at,d,a.assessed_class_id,'evidence',qualifying,reason,anchor_scores,CASE WHEN qualifying THEN score ELSE NULL END,CASE WHEN qualifying THEN coalesce((p_result->>'earnedXP')::integer,0) ELSE 0 END,0,'placement-v0.1') ON CONFLICT DO NOTHING;
 IF NOT qualifying THEN RETURN; END IF; SELECT min(pe.local_date) INTO first_date FROM public.placement_workout_evidence pe WHERE pe.assessment_id=a.id AND pe.qualifying; SELECT min(pe.local_date) INTO second_date FROM public.placement_workout_evidence pe WHERE pe.assessment_id=a.id AND pe.qualifying AND pe.local_date>first_date; IF second_date IS NULL THEN RETURN; END IF;
 SELECT least(f.class_score,s.class_score) INTO low FROM (SELECT pe.class_score FROM public.placement_workout_evidence pe WHERE pe.assessment_id=a.id AND pe.qualifying AND pe.local_date=first_date ORDER BY pe.completed_at LIMIT 1) f CROSS JOIN (SELECT pe.class_score FROM public.placement_workout_evidence pe WHERE pe.assessment_id=a.id AND pe.qualifying AND pe.local_date=second_date ORDER BY pe.completed_at LIMIT 1) s;
 SELECT uc.current_xp,cd.xp_base,cd.xp_slope INTO class_delta,class_base,class_slope FROM public.user_classes uc JOIN public.class_definitions cd ON cd.class_id=uc.class_id WHERE uc.user_id=p_user_id AND uc.slot='primary';
 INSERT INTO public.placement_confirmations(user_id,assessment_id,assessed_class_id,policy_version,confirmed_class_floor,confirmed_global_floor,confirming_workout_id,earned_global_xp_snapshot,earned_class_xp_snapshot,class_xp_base_snapshot,class_xp_slope_snapshot) VALUES(p_user_id,a.id,a.assessed_class_id,'placement-v0.1',low,CASE low WHEN 2 THEN 3 WHEN 3 THEN 5 WHEN 4 THEN 7 WHEN 5 THEN 10 ELSE 1 END,w.id,(SELECT total_xp FROM public.users WHERE id=p_user_id),class_delta,class_base,class_slope) ON CONFLICT(user_id) DO NOTHING;
 IF FOUND THEN UPDATE public.placement_assessments SET status='confirmed',updated_at=clock_timestamp() WHERE id=a.id; END IF;
END $$;
CREATE OR REPLACE FUNCTION public.placement_workout_reward_trigger_v1() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$ BEGIN PERFORM public.placement_record_workout_v1(NEW.workout_id,NEW.user_id,NEW.result); RETURN NEW; END $$;
DROP TRIGGER IF EXISTS placement_workout_reward_evidence ON public.workout_rewards;
CREATE TRIGGER placement_workout_reward_evidence AFTER INSERT ON public.workout_rewards FOR EACH ROW EXECUTE FUNCTION public.placement_workout_reward_trigger_v1();
REVOKE ALL ON FUNCTION public.placement_record_workout_v1(uuid,uuid,jsonb),public.placement_workout_reward_trigger_v1() FROM PUBLIC,anon,authenticated;

-- Task 3: receipt-backed readiness projection. These values never mutate earned progression.
CREATE OR REPLACE FUNCTION public.placement_global_threshold_v1(p_level integer)
RETURNS bigint LANGUAGE sql IMMUTABLE SET search_path='' AS $$
 SELECT CASE WHEN p_level<=1 THEN 0 ELSE floor(100*power((p_level-1)::numeric,1.5))::bigint END
$$;

CREATE OR REPLACE FUNCTION public.get_placement_state_v1()
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE uid uuid:=auth.uid(); a public.placement_assessments; c public.placement_confirmations; u public.users; uc public.user_classes;
 gl integer:=1; cl integer:=1; rg integer:=1; rc integer:=1; gd bigint:=0; cd numeric:=0; nextg bigint; nextc numeric; gearned integer; cearned integer;
BEGIN
 IF uid IS NULL THEN RAISE EXCEPTION 'Authentication required' USING ERRCODE='42501'; END IF;
 SELECT * INTO u FROM public.users WHERE id=uid; SELECT * INTO a FROM public.placement_assessments WHERE user_id=uid ORDER BY submitted_at DESC LIMIT 1;
 IF a.id IS NULL THEN RETURN jsonb_build_object('status','unassessed'); END IF;
 SELECT * INTO c FROM public.placement_confirmations WHERE user_id=uid;
 SELECT * INTO uc FROM public.user_classes WHERE user_id=uid AND slot='primary';
 gearned:=coalesce(u.level,1); cearned:=coalesce(uc.level,1); gl:=coalesce(c.confirmed_global_floor,a.provisional_global_level,1); cl:=coalesce(c.confirmed_class_floor,a.provisional_class_level,1);
 IF c.user_id IS NOT NULL THEN
   IF uc.class_id IS DISTINCT FROM c.assessed_class_id THEN cl:=1; END IF;
   SELECT coalesce(sum(global_xp_delta),0),coalesce(sum(class_xp_delta),0) INTO gd,cd FROM public.placement_workout_evidence WHERE assessment_id=c.assessment_id AND phase='progress';
   WHILE gl<100 AND public.placement_global_threshold_v1(gl+1)-public.placement_global_threshold_v1(c.confirmed_global_floor)<=gd LOOP gl:=gl+1; END LOOP;
   IF uc.class_id=c.assessed_class_id THEN WHILE cl<20 AND floor(c.class_xp_base_snapshot*power((cl+1)::numeric,c.class_xp_slope_snapshot))-floor(c.class_xp_base_snapshot*power(c.confirmed_class_floor::numeric,c.class_xp_slope_snapshot))<=cd LOOP cl:=cl+1; END LOOP; END IF;
 END IF;
 rg:=greatest(gl,gearned); rc:=greatest(cl,cearned); nextg:=CASE WHEN gearned>gl THEN greatest(0,public.placement_global_threshold_v1(gearned+1)-u.total_xp) ELSE greatest(0,public.placement_global_threshold_v1(rg+1)-public.placement_global_threshold_v1(rg)-gd) END; nextc:=CASE WHEN c.user_id IS NULL OR uc.class_id IS DISTINCT FROM c.assessed_class_id THEN 0 WHEN cearned>cl THEN greatest(0,floor(uc.xp_base*power((cearned+1)::numeric,uc.xp_slope))-uc.current_xp) ELSE greatest(0,floor(c.class_xp_base_snapshot*power((rc+1)::numeric,c.class_xp_slope_snapshot))-floor(c.class_xp_base_snapshot*power(c.confirmed_class_floor::numeric,c.class_xp_slope_snapshot))-cd) END;
 RETURN jsonb_build_object('policyVersion',a.policy_version,'status',CASE WHEN c.user_id IS NOT NULL THEN 'confirmed' ELSE a.status END,'assessedClassId',a.assessed_class_id,'provisionalClassLevel',a.provisional_class_level,'provisionalGlobalLevel',a.provisional_global_level,'confirmedClassFloor',c.confirmed_class_floor,'confirmedGlobalFloor',c.confirmed_global_floor,'readinessClassLevel',rc,'readinessGlobalLevel',rg,'readinessXpToNextGlobalLevel',nextg,'readinessXpToNextClassLevel',nextc);
END $$;
REVOKE ALL ON FUNCTION public.get_placement_state_v1(),public.placement_global_threshold_v1(integer) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.get_placement_state_v1() TO authenticated;

CREATE OR REPLACE FUNCTION public.placement_workout_reward_trigger_v1() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE c public.placement_confirmations; a public.placement_assessments; w public.workouts; xp integer:=greatest(0,coalesce((NEW.result->>'earnedXP')::integer,0)); cxp integer:=0; x jsonb;
BEGIN
 SELECT * INTO c FROM public.placement_confirmations WHERE user_id=NEW.user_id;
 IF c.user_id IS NOT NULL AND NEW.result->>'isSuspicious' IS DISTINCT FROM 'true' THEN
   SELECT * INTO w FROM public.workouts WHERE id=NEW.workout_id AND user_id=NEW.user_id;
   IF w.id IS NOT NULL AND w.status='completed' AND NOT w.is_imported THEN
     SELECT * INTO a FROM public.placement_assessments WHERE id=c.assessment_id;
     FOR x IN SELECT value FROM jsonb_array_elements(coalesce(NEW.result->'classResults','[]'::jsonb)) LOOP IF x->>'classId'=c.assessed_class_id AND EXISTS (SELECT 1 FROM public.user_classes WHERE user_id=NEW.user_id AND slot='primary' AND class_id=c.assessed_class_id) THEN cxp:=greatest(0,coalesce((x->>'xpEarned')::integer,0)); END IF; END LOOP;
     INSERT INTO public.placement_workout_evidence(assessment_id,workout_id,user_id,completed_at,local_date,assessed_class_id,phase,qualifying,reason,global_xp_delta,class_xp_delta,policy_version) VALUES(c.assessment_id,NEW.workout_id,NEW.user_id,w.completed_at,(w.completed_at AT TIME ZONE a.timezone_snapshot)::date,c.assessed_class_id,'progress',false,'post_confirmation_receipt',xp,cxp,'placement-v0.1') ON CONFLICT DO NOTHING;
   END IF;
 ELSE PERFORM public.placement_record_workout_v1(NEW.workout_id,NEW.user_id,NEW.result); END IF;
 RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION public.placement_workout_reward_trigger_v1() FROM PUBLIC,anon,authenticated;

-- Extend initialize_user with optional placement payload while preserving one-argument calls.
CREATE OR REPLACE FUNCTION public.initialize_user(p_profile jsonb) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE uid uuid=auth.uid(); pr jsonb; primary_id text=p_profile->>'primary_class_id'; secondary_id text=nullif(p_profile->>'secondary_class_id',''); tz text=coalesce(p_profile->>'timezone','Asia/Ho_Chi_Minh'); u public.users; BEGIN
 IF uid IS NULL THEN RAISE EXCEPTION 'Authentication required' USING ERRCODE='42501'; END IF;
 SELECT * INTO u FROM public.users WHERE id=uid FOR UPDATE;
 IF u.id IS NULL THEN RAISE EXCEPTION 'Account profile unavailable' USING ERRCODE='22023'; END IF;
 IF u.onboarding_completed THEN RETURN jsonb_build_object('message','Onboarding already complete','setup',jsonb_build_object('level',u.level,'title',u.current_title)); END IF;
 IF primary_id NOT IN ('A','B','C','D','E','F') OR primary_id IS NULL OR (secondary_id IS NOT NULL AND (secondary_id NOT IN ('A','B','C','D','E','F') OR secondary_id=primary_id)) THEN RAISE EXCEPTION 'Invalid class selection' USING ERRCODE='22023'; END IF;
 IF coalesce(p_profile->>'environment','') NOT IN ('gym','home','calisthenics') OR coalesce(p_profile->>'experience_level','') NOT IN ('beginner','intermediate','advanced') OR coalesce(p_profile->>'gender','') NOT IN ('male','female','other') OR jsonb_typeof(p_profile->'goals') IS DISTINCT FROM 'array' THEN RAISE EXCEPTION 'Invalid profile' USING ERRCODE='22023'; END IF;
 IF p_profile->>'age' IS NULL OR p_profile->>'height_cm' IS NULL OR p_profile->>'weight_kg' IS NULL OR jsonb_array_length(p_profile->'goals') NOT BETWEEN 1 AND 3 OR EXISTS(SELECT 1 FROM jsonb_array_elements_text(p_profile->'goals') g WHERE g NOT IN ('fat_loss','hypertrophy','powerlifting')) THEN RAISE EXCEPTION 'Complete the required profile information' USING ERRCODE='22023'; END IF;
 IF jsonb_typeof(p_profile->'preferred_training_days') IS DISTINCT FROM 'array' THEN RAISE EXCEPTION 'Choose your training days' USING ERRCODE='22023'; END IF;
 IF jsonb_array_length(p_profile->'preferred_training_days') NOT BETWEEN 1 AND 7 OR EXISTS(SELECT 1 FROM jsonb_array_elements_text(p_profile->'preferred_training_days') d WHERE lower(d) NOT IN ('mon','tue','wed','thu','fri','sat','sun')) THEN RAISE EXCEPTION 'Choose valid training days' USING ERRCODE='22023'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_timezone_names WHERE name=tz) THEN RAISE EXCEPTION 'Invalid timezone' USING ERRCODE='22023'; END IF;
 INSERT INTO public.profiles(id,environment,goals,class_name,experience_level,age,gender,height_cm,weight_kg,weekly_gym_days,weekly_home_days,preferred_training_days,timezone)
 VALUES(uid,p_profile->>'environment',ARRAY(SELECT jsonb_array_elements_text(p_profile->'goals')),(SELECT class_name FROM public.class_definitions WHERE class_id=primary_id),p_profile->>'experience_level',(p_profile->>'age')::integer,p_profile->>'gender',(p_profile->>'height_cm')::numeric,(p_profile->>'weight_kg')::numeric,coalesce((p_profile->>'weekly_gym_days')::integer,3),coalesce((p_profile->>'weekly_home_days')::integer,0),ARRAY(SELECT jsonb_array_elements_text(coalesce(p_profile->'preferred_training_days','[]'::jsonb))),tz)
 ON CONFLICT(id) DO UPDATE SET environment=excluded.environment,goals=excluded.goals,class_name=excluded.class_name,experience_level=excluded.experience_level,age=excluded.age,gender=excluded.gender,height_cm=excluded.height_cm,weight_kg=excluded.weight_kg,weekly_gym_days=excluded.weekly_gym_days,weekly_home_days=excluded.weekly_home_days,preferred_training_days=excluded.preferred_training_days,timezone=excluded.timezone;
 INSERT INTO public.user_classes(user_id,class_id,class_name,slot,difficulty) SELECT uid,class_id,class_name,'primary',difficulty FROM public.class_definitions WHERE class_id=primary_id ON CONFLICT(user_id,slot) DO UPDATE SET class_id=excluded.class_id,class_name=excluded.class_name,difficulty=excluded.difficulty;
 IF secondary_id IS NOT NULL THEN INSERT INTO public.user_classes(user_id,class_id,class_name,slot,difficulty) SELECT uid,class_id,class_name,'secondary',difficulty FROM public.class_definitions WHERE class_id=secondary_id ON CONFLICT(user_id,slot) DO UPDATE SET class_id=excluded.class_id,class_name=excluded.class_name,difficulty=excluded.difficulty; END IF;
 UPDATE public.users SET onboarding_completed=true,level=1,total_xp=0,current_level_xp=0,current_title='Tân Binh' WHERE id=uid;
 INSERT INTO public.streaks(user_id) VALUES(uid) ON CONFLICT(user_id) DO NOTHING;
 IF p_profile ? 'placement' THEN
  pr:=p_profile->'placement'; IF jsonb_typeof(pr)='object' AND pr ? 'operationId' AND pr ? 'request' THEN
    RETURN jsonb_build_object('message','Onboarding complete','setup',jsonb_build_object('level',1,'title','Tân Binh'),'placement',public.placement_register_v1(uid,(pr->>'operationId')::uuid,pr->'request',true));
  END IF; END IF;
 RETURN jsonb_build_object('message','Onboarding complete','setup',jsonb_build_object('level',1,'title','Tân Binh'));
END $$;


REVOKE ALL ON FUNCTION public.initialize_user(jsonb) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.initialize_user(jsonb) TO authenticated;
