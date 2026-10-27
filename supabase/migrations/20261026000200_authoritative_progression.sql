-- Authoritative progression. Additive adoption of the legacy schema; no user data is deleted.
-- Reconcile the linked project's schema/history before deploying these migrations.
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS timezone text NOT NULL DEFAULT 'Asia/Ho_Chi_Minh';
ALTER TABLE public.workouts ADD COLUMN IF NOT EXISTS training_started_at timestamptz;
ALTER TABLE public.workouts ADD COLUMN IF NOT EXISTS paused_at timestamptz;
ALTER TABLE public.workouts ADD COLUMN IF NOT EXISTS paused_seconds integer NOT NULL DEFAULT 0;
ALTER TABLE public.workouts ADD COLUMN IF NOT EXISTS reward_result jsonb;
-- Existing sessions had no separate setup stage. Preserve their elapsed time.
UPDATE public.workouts SET training_started_at=started_at WHERE training_started_at IS NULL;
ALTER TABLE public.quest_instances ADD COLUMN IF NOT EXISTS quest_date date;
-- Leave legacy duplicates intact. New assignments have one unique calendar-day key.
CREATE UNIQUE INDEX IF NOT EXISTS quest_instances_unique_day ON public.quest_instances(user_id,quest_date) WHERE quest_date IS NOT NULL;
CREATE TABLE IF NOT EXISTS public.workout_rewards (
  workout_id uuid PRIMARY KEY REFERENCES public.workouts(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  result jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS public.user_achievements (
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  achievement_id text NOT NULL CHECK(achievement_id IN ('first_workout','ten_workouts','streak_7','level_10')),
  unlocked_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY(user_id,achievement_id)
);
CREATE INDEX IF NOT EXISTS workout_rewards_user ON public.workout_rewards(user_id);
CREATE INDEX IF NOT EXISTS workout_history_user_completed ON public.workouts(user_id,completed_at DESC) WHERE status='completed';

-- Validate new writes without invalidating historical records during adoption.
ALTER TABLE public.workout_sets ADD CONSTRAINT workout_sets_valid_values CHECK (
  set_number BETWEEN 1 AND 100 AND reps BETWEEN 0 AND 1000 AND weight_kg BETWEEN 0 AND 1000
  AND rest_seconds BETWEEN 0 AND 7200 AND baseline_weight_kg BETWEEN 0 AND 1000
  AND (NOT is_completed OR reps > 0)) NOT VALID;
ALTER TABLE public.workouts ADD CONSTRAINT workout_pause_nonnegative CHECK(paused_seconds>=0) NOT VALID;
ALTER TABLE public.profiles ADD CONSTRAINT profiles_valid_measurements CHECK(
  age BETWEEN 13 AND 120 AND height_cm BETWEEN 80 AND 250 AND weight_kg BETWEEN 20 AND 400
  AND weekly_gym_days BETWEEN 0 AND 7 AND weekly_home_days BETWEEN 0 AND 7
  AND weekly_gym_days+weekly_home_days BETWEEN 1 AND 7) NOT VALID;

-- Current A-F client catalogue. Historical G/H records remain readable.
ALTER TABLE public.class_definitions ADD COLUMN IF NOT EXISTS focus_categories text[] NOT NULL DEFAULT '{}';
INSERT INTO public.class_definitions(class_id,class_name,focus,difficulty,graduation_xp,xp_base,xp_slope,focus_categories) VALUES
 ('A','Shredder','Cardio and conditioning','easy',6000,80,1.40,ARRAY['cardio','hiit','full_body']),
 ('B','Hiper-Growth','Muscle growth','medium',8500,100,1.45,ARRAY['chest','back','legs','shoulders','arms']),
 ('C','Powerlifting','Strength','hard',11000,130,1.55,ARRAY['legs','back','chest']),
 ('D','Endurance','Stamina','easy',7000,80,1.40,ARRAY['cardio','full_body','endurance']),
 ('E','Calisthenics','Bodyweight control','medium',9000,100,1.45,ARRAY['calisthenics','core','full_body','arms','back','chest']),
 ('F','Bodybuilding','Muscle symmetry','hardcore',15000,160,1.65,ARRAY['chest','back','legs','shoulders','arms'])
ON CONFLICT(class_id) DO UPDATE SET class_name=excluded.class_name,focus=excluded.focus,difficulty=excluded.difficulty,
 graduation_xp=excluded.graduation_xp,xp_base=excluded.xp_base,xp_slope=excluded.xp_slope,focus_categories=excluded.focus_categories;
-- Replace catalogue-only synergy definitions; no user state or history is removed.
UPDATE public.class_synergies SET is_perfect=false,bonus_percent=0;
INSERT INTO public.class_synergies(primary_class_id,secondary_class_id,synergy_name,bonus_percent,is_perfect) VALUES
 ('A','D','Cardio Storm',5,true),('D','A','Cardio Storm',5,true),
 ('B','C','Juggernaut',5,true),('C','B','Juggernaut',5,true),
 ('E','C','Cyber Monk',5,true),('C','E','Cyber Monk',5,true),
 ('F','B','Apex Sculptor',5,true),('B','F','Apex Sculptor',5,true)
ON CONFLICT(primary_class_id,secondary_class_id) DO UPDATE SET synergy_name=excluded.synergy_name,bonus_percent=excluded.bonus_percent,is_perfect=true;

-- Explicit privileges and replacement policies prevent legacy permissive policies
-- from silently continuing to grant progression writes.
DO $$ DECLARE t text; p record; BEGIN
 FOREACH t IN ARRAY ARRAY['users','profiles','exercises','workouts','workout_exercises','workout_sets','xp_logs','streaks','exercise_prs','quests','quest_instances','user_classes','class_definitions','class_synergies','workout_rewards','user_achievements'] LOOP
  EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY',t);
  EXECUTE format('REVOKE ALL ON public.%I FROM anon, authenticated',t);
  EXECUTE format('GRANT SELECT ON public.%I TO authenticated',t);
  FOR p IN SELECT policyname FROM pg_policies WHERE schemaname='public' AND tablename=t LOOP
   EXECUTE format('DROP POLICY %I ON public.%I',p.policyname,t);
  END LOOP;
 END LOOP;
END $$;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT UPDATE(display_name,avatar_url,locale) ON public.users TO authenticated;
GRANT UPDATE(environment,goals,experience_level,age,gender,height_cm,weight_kg,weekly_gym_days,weekly_home_days,preferred_training_days) ON public.profiles TO authenticated;
GRANT UPDATE(notes) ON public.workouts TO authenticated;
GRANT INSERT,UPDATE,DELETE ON public.workout_exercises,public.workout_sets TO authenticated;
CREATE POLICY own_users_read ON public.users FOR SELECT TO authenticated USING(id=(SELECT auth.uid()));
CREATE POLICY own_users_edit ON public.users FOR UPDATE TO authenticated USING(id=(SELECT auth.uid())) WITH CHECK(id=(SELECT auth.uid()));
CREATE POLICY own_profiles_read ON public.profiles FOR SELECT TO authenticated USING(id=(SELECT auth.uid()));
CREATE POLICY own_profiles_edit ON public.profiles FOR UPDATE TO authenticated USING(id=(SELECT auth.uid())) WITH CHECK(id=(SELECT auth.uid()));
CREATE POLICY own_workouts_read ON public.workouts FOR SELECT TO authenticated USING(user_id=(SELECT auth.uid()));
CREATE POLICY own_workouts_notes ON public.workouts FOR UPDATE TO authenticated USING(user_id=(SELECT auth.uid()) AND status='active') WITH CHECK(user_id=(SELECT auth.uid()) AND status='active');
CREATE POLICY own_exercises_read ON public.workout_exercises FOR SELECT TO authenticated USING(EXISTS(SELECT 1 FROM public.workouts w WHERE w.id=workout_id AND w.user_id=(SELECT auth.uid())));
CREATE POLICY own_exercises_write ON public.workout_exercises FOR ALL TO authenticated USING(EXISTS(SELECT 1 FROM public.workouts w WHERE w.id=workout_id AND w.user_id=(SELECT auth.uid()) AND w.status='active')) WITH CHECK(EXISTS(SELECT 1 FROM public.workouts w WHERE w.id=workout_id AND w.user_id=(SELECT auth.uid()) AND w.status='active'));
CREATE POLICY own_sets_read ON public.workout_sets FOR SELECT TO authenticated USING(EXISTS(SELECT 1 FROM public.workout_exercises we JOIN public.workouts w ON w.id=we.workout_id WHERE we.id=workout_exercise_id AND w.user_id=(SELECT auth.uid())));
CREATE POLICY own_sets_write ON public.workout_sets FOR ALL TO authenticated USING(EXISTS(SELECT 1 FROM public.workout_exercises we JOIN public.workouts w ON w.id=we.workout_id WHERE we.id=workout_exercise_id AND w.user_id=(SELECT auth.uid()) AND w.status='active')) WITH CHECK(EXISTS(SELECT 1 FROM public.workout_exercises we JOIN public.workouts w ON w.id=we.workout_id WHERE we.id=workout_exercise_id AND w.user_id=(SELECT auth.uid()) AND w.status='active'));
DO $$ DECLARE t text; BEGIN
 FOREACH t IN ARRAY ARRAY['xp_logs','streaks','exercise_prs','quest_instances','user_classes','workout_rewards','user_achievements'] LOOP
  EXECUTE format('CREATE POLICY own_read ON public.%I FOR SELECT TO authenticated USING(user_id=(SELECT auth.uid()))',t);
 END LOOP;
 FOREACH t IN ARRAY ARRAY['exercises','quests','class_definitions','class_synergies'] LOOP
  EXECUTE format('CREATE POLICY catalogue_read ON public.%I FOR SELECT TO authenticated USING(true)',t);
 END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.update_modified_column() RETURNS trigger LANGUAGE plpgsql SET search_path='' AS $$ BEGIN NEW.updated_at=now(); RETURN NEW; END $$;
CREATE OR REPLACE FUNCTION public.handle_new_user() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
BEGIN
 INSERT INTO public.users(id,email,display_name) VALUES(NEW.id,coalesce(NEW.email,''),left(coalesce(NEW.raw_user_meta_data->>'full_name',split_part(NEW.email,'@',1),'Athlete'),80)) ON CONFLICT(id) DO NOTHING;
 RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
INSERT INTO public.users(id,email,display_name) SELECT id,coalesce(email,''),left(coalesce(raw_user_meta_data->>'full_name',split_part(email,'@',1),'Athlete'),80) FROM auth.users ON CONFLICT(id) DO NOTHING;

-- Child writes acquire the same parent lock as completion. A stale request
-- cannot alter sets after rewards have been calculated.
CREATE OR REPLACE FUNCTION public.guard_workout_child() RETURNS trigger LANGUAGE plpgsql SET search_path='' AS $$
DECLARE wid uuid; owner_id uuid; parent_status text; eid uuid; old_parent uuid; BEGIN
 -- Auth account deletion cascades through finished sessions. Client roles have
 -- no workout DELETE privilege; allow only the trusted no-user admin cascade.
 IF TG_OP='DELETE' AND auth.uid() IS NULL AND current_user IN ('postgres','supabase_admin','supabase_auth_admin','service_role') THEN RETURN OLD; END IF;
 IF TG_TABLE_NAME='workout_sets' THEN
  SELECT workout_id,exercise_id INTO wid,eid FROM public.workout_exercises WHERE id=CASE WHEN TG_OP='DELETE' THEN OLD.workout_exercise_id ELSE NEW.workout_exercise_id END;
  IF TG_OP='UPDATE' AND NEW.workout_exercise_id IS DISTINCT FROM OLD.workout_exercise_id THEN RAISE EXCEPTION 'A set cannot be moved to another exercise' USING ERRCODE='22023'; END IF;
 ELSE
  wid=CASE WHEN TG_OP='DELETE' THEN OLD.workout_id ELSE NEW.workout_id END;
  IF TG_OP='UPDATE' AND (NEW.workout_id IS DISTINCT FROM OLD.workout_id OR NEW.exercise_id IS DISTINCT FROM OLD.exercise_id) THEN RAISE EXCEPTION 'An exercise cannot change its session or identity' USING ERRCODE='22023'; END IF;
 END IF;
 SELECT user_id,status INTO owner_id,parent_status FROM public.workouts WHERE id=wid FOR UPDATE;
 IF owner_id IS NULL OR owner_id IS DISTINCT FROM auth.uid() OR parent_status<>'active' THEN RAISE EXCEPTION 'Workout is unavailable or already finished' USING ERRCODE='42501'; END IF;
 IF TG_TABLE_NAME='workout_sets' AND TG_OP='INSERT' THEN
  SELECT coalesce(max_weight_kg,0) INTO NEW.baseline_weight_kg FROM public.exercise_prs WHERE user_id=owner_id AND exercise_id=eid;
  NEW.baseline_weight_kg=greatest(0,least(1000,coalesce(NEW.baseline_weight_kg,0)));
 ELSIF TG_TABLE_NAME='workout_sets' AND TG_OP='UPDATE' THEN
  NEW.baseline_weight_kg=OLD.baseline_weight_kg;
 END IF;
 IF TG_OP='DELETE' THEN RETURN OLD; END IF;
 RETURN NEW;
END $$;
CREATE TRIGGER guard_exercise_write BEFORE INSERT OR UPDATE OR DELETE ON public.workout_exercises FOR EACH ROW EXECUTE FUNCTION public.guard_workout_child();
CREATE TRIGGER guard_set_write BEFORE INSERT OR UPDATE OR DELETE ON public.workout_sets FOR EACH ROW EXECUTE FUNCTION public.guard_workout_child();

CREATE OR REPLACE FUNCTION public.workout_json(p_id uuid) RETURNS jsonb LANGUAGE sql STABLE SET search_path='' AS $$
 SELECT to_jsonb(w)||jsonb_build_object('workout_exercises',coalesce((SELECT jsonb_agg(to_jsonb(we)||jsonb_build_object('exercises',to_jsonb(e),'workout_sets',coalesce((SELECT jsonb_agg(to_jsonb(s) ORDER BY s.set_number,s.created_at) FROM public.workout_sets s WHERE s.workout_exercise_id=we.id),'[]'::jsonb)) ORDER BY we.order_index,we.created_at) FROM public.workout_exercises we JOIN public.exercises e ON e.id=we.exercise_id WHERE we.workout_id=w.id),'[]'::jsonb)) FROM public.workouts w WHERE w.id=p_id AND w.user_id=auth.uid()
$$;

CREATE OR REPLACE FUNCTION public.initialize_user(p_profile jsonb) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE uid uuid=auth.uid(); primary_id text=p_profile->>'primary_class_id'; secondary_id text=nullif(p_profile->>'secondary_class_id',''); tz text=coalesce(p_profile->>'timezone','Asia/Ho_Chi_Minh'); u public.users; BEGIN
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
 RETURN jsonb_build_object('message','Onboarding complete','setup',jsonb_build_object('level',1,'title','Tân Binh'));
END $$;

CREATE OR REPLACE FUNCTION public.start_workout() RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE uid uuid=auth.uid(); wid uuid; ready boolean; BEGIN
 IF uid IS NULL THEN RAISE EXCEPTION 'Authentication required' USING ERRCODE='42501'; END IF;
 SELECT onboarding_completed INTO ready FROM public.users WHERE id=uid FOR UPDATE;
 IF ready IS DISTINCT FROM true THEN RAISE EXCEPTION 'Complete onboarding first' USING ERRCODE='22023'; END IF;
 SELECT id INTO wid FROM public.workouts WHERE user_id=uid AND status='active' ORDER BY started_at DESC LIMIT 1 FOR UPDATE;
 IF wid IS NULL THEN INSERT INTO public.workouts(user_id) VALUES(uid) RETURNING id INTO wid; END IF;
 RETURN public.workout_json(wid);
END $$;
CREATE OR REPLACE FUNCTION public.begin_workout(p_workout_id uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE w public.workouts; BEGIN
 SELECT * INTO w FROM public.workouts WHERE id=p_workout_id AND user_id=auth.uid() FOR UPDATE;
 IF w.id IS NULL OR w.status<>'active' THEN RAISE EXCEPTION 'Active workout not found' USING ERRCODE='42501'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.workout_exercises WHERE workout_id=w.id) THEN RAISE EXCEPTION 'Add an exercise first' USING ERRCODE='22023'; END IF;
 UPDATE public.workouts SET training_started_at=coalesce(training_started_at,clock_timestamp()) WHERE id=w.id;
 RETURN public.workout_json(w.id);
END $$;
CREATE OR REPLACE FUNCTION public.set_workout_paused(p_workout_id uuid,p_paused boolean) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE w public.workouts; BEGIN
 SELECT * INTO w FROM public.workouts WHERE id=p_workout_id AND user_id=auth.uid() FOR UPDATE;
 IF w.id IS NULL OR w.status<>'active' OR w.training_started_at IS NULL THEN RAISE EXCEPTION 'Running workout not found' USING ERRCODE='42501'; END IF;
 IF p_paused AND w.paused_at IS NULL THEN UPDATE public.workouts SET paused_at=clock_timestamp() WHERE id=w.id;
 ELSIF NOT p_paused AND w.paused_at IS NOT NULL THEN UPDATE public.workouts SET paused_seconds=paused_seconds+greatest(0,floor(extract(epoch FROM clock_timestamp()-paused_at))::integer),paused_at=NULL WHERE id=w.id; END IF;
 RETURN public.workout_json(w.id);
END $$;
CREATE OR REPLACE FUNCTION public.cancel_workout(p_workout_id uuid) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE w public.workouts; BEGIN
 SELECT * INTO w FROM public.workouts WHERE id=p_workout_id AND user_id=auth.uid() FOR UPDATE;
 IF w.id IS NULL THEN RAISE EXCEPTION 'Workout not found' USING ERRCODE='42501'; END IF;
 IF w.status='completed' THEN RAISE EXCEPTION 'Completed workouts cannot be cancelled' USING ERRCODE='22023'; END IF;
 UPDATE public.workouts SET status='cancelled',paused_at=NULL WHERE id=w.id;
END $$;

CREATE OR REPLACE FUNCTION public.sync_daily_data() RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE uid uuid=auth.uid(); p public.profiles; day date; q public.quest_instances; template public.quests; config jsonb; BEGIN
 IF uid IS NULL THEN RAISE EXCEPTION 'Authentication required' USING ERRCODE='42501'; END IF;
 PERFORM 1 FROM public.users WHERE id=uid FOR UPDATE;
 SELECT * INTO p FROM public.profiles WHERE id=uid;
 IF p.id IS NULL THEN RAISE EXCEPTION 'Complete onboarding first' USING ERRCODE='22023'; END IF;
 day=(now() AT TIME ZONE p.timezone)::date;
 UPDATE public.streaks SET current_streak=0 WHERE user_id=uid AND last_activity_date<day-1;
 UPDATE public.quest_instances SET status='expired' WHERE user_id=uid AND status='active' AND expires_at<=now();
 SELECT * INTO q FROM public.quest_instances WHERE user_id=uid AND quest_date=day LIMIT 1;
 IF q.id IS NOT NULL THEN RETURN jsonb_build_object('message','Quest already exists for today','quest',to_jsonb(q),'isDiscovery',false); END IF;
 SELECT * INTO template FROM public.quests WHERE type='daily_routine' ORDER BY category,id OFFSET (extract(doy FROM day)::integer % greatest(1,(SELECT count(*)::integer FROM public.quests WHERE type='daily_routine'))) LIMIT 1;
 IF template.id IS NULL THEN RAISE EXCEPTION 'Quest catalogue unavailable' USING ERRCODE='22023'; END IF;
 SELECT jsonb_agg(jsonb_build_object('exercise_id',e.id,'exercise_name',e.name,'sets',3,'reps',12,'weight_kg',CASE WHEN e.equipment='Bodyweight' THEN 0 ELSE coalesce(round(pr.max_weight_kg*0.8*2)/2,0) END) ORDER BY e.name) INTO config
 FROM (SELECT * FROM public.exercises ex WHERE
  (template.category='push' AND lower(ex.force_type)='push' AND lower(ex.category)<>'legs') OR
  (template.category='pull' AND lower(ex.force_type)='pull' AND lower(ex.category)<>'legs') OR
  (template.category='legs' AND lower(ex.category)='legs') OR template.category='full_body'
  ORDER BY ex.name LIMIT 3) e LEFT JOIN public.exercise_prs pr ON pr.exercise_id=e.id AND pr.user_id=uid;
 IF config IS NULL THEN RAISE EXCEPTION 'Exercises for today are unavailable' USING ERRCODE='22023'; END IF;
 INSERT INTO public.quest_instances(user_id,quest_id,prescribed_config,expires_at,quest_date) VALUES(uid,template.id,config,((day+1)::timestamp AT TIME ZONE p.timezone),day) RETURNING * INTO q;
 RETURN jsonb_build_object('message','New quest generated','quest',to_jsonb(q),'isDiscovery',NOT EXISTS(SELECT 1 FROM public.exercise_prs WHERE user_id=uid));
END $$;

CREATE OR REPLACE FUNCTION public.complete_workout(p_workout_id uuid,p_notes text DEFAULT NULL) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE uid uuid=auth.uid(); u public.users; w public.workouts; result jsonb; tz text; day date; finished timestamptz=clock_timestamp(); duration integer;
 completed_sets integer; categories text[]; base_xp numeric; earned integer; total integer; new_level integer=1; old_level integer; streak integer; prev_date date; suspicious boolean; quest_match boolean=false;
 q public.quest_instances; target jsonb; target_count integer; target_matches integer; quest_base integer; title text; classes jsonb='[]'; c record; cxp integer; clevel integer; synergy numeric=1; achievements jsonb='[]'; achievement text; total_workouts integer;
BEGIN
 IF uid IS NULL THEN RAISE EXCEPTION 'Authentication required' USING ERRCODE='42501'; END IF;
 -- Serialize all progression for the same user, including different workouts.
 SELECT * INTO u FROM public.users WHERE id=uid FOR UPDATE;
 SELECT * INTO w FROM public.workouts WHERE id=p_workout_id AND user_id=uid FOR UPDATE;
 IF w.id IS NULL THEN RAISE EXCEPTION 'Workout not found' USING ERRCODE='42501'; END IF;
 SELECT r.result INTO result FROM public.workout_rewards r WHERE r.workout_id=w.id;
 IF result IS NOT NULL THEN RETURN result; END IF;
 -- Legacy already-awarded sessions must never gain a second reward.
 IF w.is_xp_calculated THEN RETURN jsonb_build_object('earnedXP',0,'totalXP',u.total_xp,'newLevel',u.level,'leveledUp',false,'isQuest',false,'newTitle',NULL,'nextLevelXp',floor(100*power(u.level,1.5)),'isSuspicious',false,'classResults','[]'::jsonb,'achievements','[]'::jsonb,'alreadyAwarded',true); END IF;
 IF w.status NOT IN ('active','completed') OR w.training_started_at IS NULL THEN RAISE EXCEPTION 'Workout has not started or was cancelled' USING ERRCODE='22023'; END IF;
 IF length(coalesce(p_notes,''))>4000 THEN RAISE EXCEPTION 'Notes are too long' USING ERRCODE='22023'; END IF;
 -- A legacy completed/unrewarded session retains its original completion time.
 IF w.status='completed' THEN finished=coalesce(w.completed_at,finished); END IF;
 duration=greatest(1,floor(extract(epoch FROM coalesce(w.paused_at,finished)-w.training_started_at))::integer-w.paused_seconds);
 SELECT count(*)::integer,array_agg(DISTINCT lower(e.category)),sum(CASE WHEN s.baseline_weight_kg>0 THEN 5*least(3,greatest(0.2,s.weight_kg/s.baseline_weight_kg)) ELSE 5 END)
 INTO completed_sets,categories,base_xp FROM public.workout_sets s JOIN public.workout_exercises we ON we.id=s.workout_exercise_id JOIN public.exercises e ON e.id=we.exercise_id WHERE we.workout_id=w.id AND s.is_completed;
 IF completed_sets=0 THEN RAISE EXCEPTION 'Complete at least one set before finishing' USING ERRCODE='22023'; END IF;
 IF completed_sets>300 OR EXISTS(SELECT 1 FROM public.workout_sets s JOIN public.workout_exercises we ON we.id=s.workout_exercise_id WHERE we.workout_id=w.id AND s.is_completed AND (s.reps<1 OR s.reps>1000 OR s.weight_kg<0 OR s.weight_kg>1000)) THEN RAISE EXCEPTION 'Invalid workout measurements' USING ERRCODE='22023'; END IF;
 suspicious=completed_sets>3 AND completed_sets*60.0/duration>4;
 SELECT timezone INTO tz FROM public.profiles WHERE id=uid;
 day=(finished AT TIME ZONE coalesce(tz,'Asia/Ho_Chi_Minh'))::date;
 INSERT INTO public.streaks(user_id) VALUES(uid) ON CONFLICT(user_id) DO NOTHING;
 SELECT current_streak,last_activity_date INTO streak,prev_date FROM public.streaks WHERE user_id=uid FOR UPDATE;
 streak=CASE WHEN prev_date=day THEN streak WHEN prev_date=day-1 THEN streak+1 WHEN prev_date>day THEN streak ELSE 1 END;
 SELECT * INTO q FROM public.quest_instances WHERE user_id=uid AND status='active' AND quest_date=day AND expires_at>finished ORDER BY created_at LIMIT 1 FOR UPDATE;
 IF q.id IS NOT NULL AND jsonb_typeof(q.prescribed_config)='array' AND jsonb_array_length(q.prescribed_config)>0 THEN
  target_count=jsonb_array_length(q.prescribed_config); target_matches=0;
  FOR target IN SELECT jsonb_array_elements(q.prescribed_config) LOOP
   IF (SELECT count(*) FROM public.workout_sets s JOIN public.workout_exercises we ON we.id=s.workout_exercise_id WHERE we.workout_id=w.id AND we.exercise_id=(target->>'exercise_id')::uuid AND s.is_completed AND s.reps>=coalesce((target->>'reps')::integer,1) AND s.weight_kg>=coalesce((target->>'weight_kg')::numeric,0))>=coalesce((target->>'sets')::integer,3) THEN target_matches=target_matches+1; END IF;
  END LOOP;
  quest_match=target_matches=target_count;
 END IF;
 IF suspicious THEN earned=10;
 ELSIF quest_match THEN SELECT qt.base_xp INTO quest_base FROM public.quests qt WHERE qt.id=q.quest_id; earned=least(1000,floor(coalesce(quest_base,300)*least(2,1+greatest(0,streak-1)*0.05))::integer);
 ELSE earned=least(1000,floor((base_xp+greatest(0,cardinality(categories)-1)*8)*least(1.5,1+greatest(0,streak-1)*0.05))::integer); END IF;
 total=coalesce(u.total_xp,0)+earned; old_level=coalesce(u.level,1);
 WHILE new_level<100 AND total>=floor(100*power(new_level,1.5)) LOOP new_level=new_level+1; END LOOP;
 title=CASE WHEN new_level>=100 THEN 'Bất Tử' WHEN new_level>=75 THEN 'Thần Thoại' WHEN new_level>=50 THEN 'Huyền Thoại' WHEN new_level>=30 THEN 'Anh Hùng' WHEN new_level>=20 THEN 'Dũng Sĩ' WHEN new_level>=15 THEN 'Đấu Sĩ' WHEN new_level>=10 THEN 'Chiến Binh' WHEN new_level>=5 THEN 'Tập Sự' ELSE 'Tân Binh' END;
 SELECT coalesce(max(1+s.bonus_percent/100.0),1) INTO synergy FROM public.user_classes a JOIN public.user_classes b ON a.user_id=b.user_id AND a.slot='primary' AND b.slot='secondary' JOIN public.class_synergies s ON s.primary_class_id=a.class_id AND s.secondary_class_id=b.class_id AND s.is_perfect WHERE a.user_id=uid;
 FOR c IN SELECT uc.*,cd.focus_categories,cd.xp_base,cd.xp_slope FROM public.user_classes uc JOIN public.class_definitions cd USING(class_id) WHERE uc.user_id=uid AND NOT uc.is_graduated FOR UPDATE OF uc LOOP
  cxp=floor(earned*(CASE WHEN categories&&c.focus_categories THEN 1 ELSE 0.4 END)*synergy)::integer; clevel=1;
  WHILE clevel<20 AND c.current_xp+cxp>=floor(c.xp_base*power(clevel,c.xp_slope)) LOOP clevel=clevel+1; END LOOP;
  UPDATE public.user_classes SET current_xp=c.current_xp+cxp,level=clevel,is_graduated=clevel=20,graduated_at=CASE WHEN clevel=20 THEN finished ELSE NULL END WHERE id=c.id;
  INSERT INTO public.xp_logs(user_id,amount,source,source_id,class_id,class_xp_earned) VALUES(uid,cxp,'class_xp',w.id::text,c.class_id,cxp);
  classes=classes||jsonb_build_array(jsonb_build_object('classId',c.class_id,'className',c.class_name,'slot',c.slot,'xpEarned',cxp,'newTotalXP',c.current_xp+cxp,'newLevel',clevel,'leveledUp',clevel>c.level,'isGraduation',clevel=20 AND c.level<20));
 END LOOP;
 UPDATE public.users SET total_xp=total,level=new_level,current_level_xp=total-CASE WHEN new_level>1 THEN floor(100*power(new_level-1,1.5))::integer ELSE 0 END,current_title=title,last_workout_date=greatest(last_workout_date,finished),last_active_at=greatest(last_active_at,finished) WHERE id=uid;
 UPDATE public.streaks SET current_streak=streak,longest_streak=greatest(longest_streak,streak),last_activity_date=greatest(coalesce(last_activity_date,day),day) WHERE user_id=uid;
 UPDATE public.workouts SET status='completed',completed_at=finished,duration_seconds=duration,notes=coalesce(p_notes,notes),paused_at=NULL,is_xp_calculated=true WHERE id=w.id;
 INSERT INTO public.xp_logs(user_id,amount,source,source_id) VALUES(uid,earned,CASE WHEN quest_match THEN 'quest' ELSE 'workout' END,w.id::text);
 IF quest_match THEN UPDATE public.quest_instances SET status='completed',completed_at=finished,earned_xp=earned WHERE id=q.id; END IF;
 INSERT INTO public.exercise_prs(user_id,exercise_id,max_weight_kg,max_reps,estimated_1rm,is_confirmed)
 SELECT uid,we.exercise_id,max(s.weight_kg),max(s.reps),max(s.weight_kg*(1+s.reps/30.0)),true FROM public.workout_sets s JOIN public.workout_exercises we ON we.id=s.workout_exercise_id WHERE we.workout_id=w.id AND s.is_completed GROUP BY we.exercise_id
 ON CONFLICT(user_id,exercise_id) DO UPDATE SET max_weight_kg=greatest(public.exercise_prs.max_weight_kg,excluded.max_weight_kg),max_reps=greatest(public.exercise_prs.max_reps,excluded.max_reps),estimated_1rm=greatest(public.exercise_prs.estimated_1rm,excluded.estimated_1rm),is_confirmed=true;
 SELECT count(*) INTO total_workouts FROM public.workouts WHERE user_id=uid AND status='completed';
 FOREACH achievement IN ARRAY ARRAY['first_workout',CASE WHEN total_workouts>=10 THEN 'ten_workouts' END,CASE WHEN streak>=7 THEN 'streak_7' END,CASE WHEN new_level>=10 THEN 'level_10' END] LOOP
  IF achievement IS NOT NULL THEN INSERT INTO public.user_achievements(user_id,achievement_id) VALUES(uid,achievement) ON CONFLICT DO NOTHING; IF FOUND THEN achievements=achievements||to_jsonb(achievement); END IF; END IF;
 END LOOP;
 result=jsonb_build_object('message','Workout complete','earnedXP',earned,'totalXP',total,'newLevel',new_level,'leveledUp',new_level>old_level,'isQuest',quest_match,'newTitle',CASE WHEN new_level>old_level THEN title END,'nextLevelXp',floor(100*power(new_level,1.5)),'isSuspicious',suspicious,'classResults',classes,'achievements',achievements,'streak',streak);
 INSERT INTO public.workout_rewards(workout_id,user_id,result) VALUES(w.id,uid,result);
 UPDATE public.workouts SET reward_result=result WHERE id=w.id;
 RETURN result;
END $$;

CREATE OR REPLACE FUNCTION public.switch_class(p_new_class_id text,p_slot text) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE uid uuid=auth.uid(); c public.class_definitions; xp integer; lvl integer=1; BEGIN
 IF uid IS NULL THEN RAISE EXCEPTION 'Authentication required' USING ERRCODE='42501'; END IF;
 PERFORM 1 FROM public.users WHERE id=uid AND onboarding_completed FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Complete onboarding first' USING ERRCODE='22023'; END IF;
 IF p_slot NOT IN ('primary','secondary') OR p_slot IS NULL OR p_new_class_id NOT IN ('A','B','C','D','E','F') OR p_new_class_id IS NULL THEN RAISE EXCEPTION 'Invalid class selection' USING ERRCODE='22023'; END IF;
 IF EXISTS(SELECT 1 FROM public.user_classes WHERE user_id=uid AND class_id=p_new_class_id AND slot<>p_slot) THEN RAISE EXCEPTION 'Class already equipped in another slot' USING ERRCODE='22023'; END IF;
 SELECT * INTO c FROM public.class_definitions WHERE class_id=p_new_class_id;
 -- Recompute from immutable, awarded sessions only. No active/cancelled sets.
 WITH awards AS (
  SELECT r.workout_id,(r.result->>'earnedXP')::integer amount FROM public.workout_rewards r WHERE r.user_id=uid
  UNION ALL
  SELECT w.id,greatest(0,least(1000,max(l.amount))) amount FROM public.workouts w JOIN public.xp_logs l ON l.source_id=w.id::text AND l.user_id=w.user_id AND l.source IN ('workout','quest') WHERE w.user_id=uid AND w.status='completed' AND w.is_xp_calculated AND NOT EXISTS(SELECT 1 FROM public.workout_rewards r WHERE r.workout_id=w.id) GROUP BY w.id
 ) SELECT coalesce(sum(floor(a.amount*CASE WHEN EXISTS(SELECT 1 FROM public.workout_exercises we JOIN public.exercises e ON e.id=we.exercise_id JOIN public.workout_sets s ON s.workout_exercise_id=we.id AND s.is_completed WHERE we.workout_id=a.workout_id AND lower(e.category)=ANY(c.focus_categories)) THEN 1 ELSE 0.4 END)),0)::integer INTO xp FROM awards a;
 -- Existing class progress may include legacy sessions without a complete ledger.
 SELECT greatest(xp,coalesce(max(current_xp),0)) INTO xp FROM public.user_classes WHERE user_id=uid AND class_id=p_new_class_id;
 WHILE lvl<20 AND xp>=floor(c.xp_base*power(lvl,c.xp_slope)) LOOP lvl=lvl+1; END LOOP;
 INSERT INTO public.user_classes(user_id,class_id,class_name,slot,difficulty,current_xp,level,is_graduated,graduated_at) VALUES(uid,c.class_id,c.class_name,p_slot,c.difficulty,xp,lvl,lvl=20,CASE WHEN lvl=20 THEN now() END)
 ON CONFLICT(user_id,slot) DO UPDATE SET class_id=excluded.class_id,class_name=excluded.class_name,difficulty=excluded.difficulty,current_xp=excluded.current_xp,level=excluded.level,is_graduated=excluded.is_graduated,graduated_at=excluded.graduated_at;
 RETURN jsonb_build_object('success',true,'class_id',c.class_id,'xp_granted',xp,'level',lvl);
END $$;

CREATE OR REPLACE FUNCTION public.get_user_stats() RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE uid uuid=auth.uid(); tz text; day date; volumes jsonb; muscles jsonb; prs jsonb; streak jsonb; achievements jsonb; BEGIN
 IF uid IS NULL THEN RAISE EXCEPTION 'Authentication required' USING ERRCODE='42501'; END IF;
 SELECT coalesce(timezone,'Asia/Ho_Chi_Minh') INTO tz FROM public.profiles WHERE id=uid; tz=coalesce(tz,'Asia/Ho_Chi_Minh'); day=(now() AT TIME ZONE tz)::date;
 SELECT jsonb_agg(jsonb_build_object('date',d::date,'value',coalesce(v.volume,0)) ORDER BY d) INTO volumes FROM generate_series(day-6,day,'1 day'::interval) d LEFT JOIN (
  SELECT (w.completed_at AT TIME ZONE tz)::date workout_day,sum(s.reps*s.weight_kg) volume FROM public.workouts w JOIN public.workout_exercises we ON we.workout_id=w.id JOIN public.workout_sets s ON s.workout_exercise_id=we.id AND s.is_completed WHERE w.user_id=uid AND w.status='completed' AND w.completed_at>=((day-6)::timestamp AT TIME ZONE tz) GROUP BY workout_day
 ) v ON v.workout_day=d::date;
 SELECT jsonb_agg(jsonb_build_object('label',cat,'value',coalesce(v.volume,0))) INTO muscles FROM unnest(ARRAY['Chest','Back','Legs','Shoulders','Arms','Core']) cat LEFT JOIN (
  SELECT e.category,sum(s.reps*s.weight_kg) volume FROM public.workouts w JOIN public.workout_exercises we ON we.workout_id=w.id JOIN public.exercises e ON e.id=we.exercise_id JOIN public.workout_sets s ON s.workout_exercise_id=we.id AND s.is_completed WHERE w.user_id=uid AND w.status='completed' AND w.completed_at>=((day-6)::timestamp AT TIME ZONE tz) GROUP BY e.category
 ) v ON v.category=cat;
 SELECT coalesce(jsonb_agg(to_jsonb(p)),'[]') INTO prs FROM (SELECT pr.exercise_id,jsonb_build_object('name',e.name) exercises,pr.max_weight_kg,pr.updated_at FROM public.exercise_prs pr JOIN public.exercises e ON e.id=pr.exercise_id WHERE pr.user_id=uid ORDER BY pr.updated_at DESC LIMIT 5) p;
 SELECT to_jsonb(s)||jsonb_build_object('current_streak',CASE WHEN last_activity_date<day-1 THEN 0 ELSE current_streak END) INTO streak FROM public.streaks s WHERE user_id=uid;
 SELECT coalesce(jsonb_agg(to_jsonb(a) ORDER BY unlocked_at),'[]') INTO achievements FROM public.user_achievements a WHERE user_id=uid;
 RETURN jsonb_build_object('volume_trend',volumes,'muscle_split',muscles,'recent_prs',prs,'streak',streak,'achievements',achievements);
END $$;

-- Functions default to PUBLIC EXECUTE in PostgreSQL. Explicitly close every
-- function installed by these migrations, including trigger/helper functions.
REVOKE ALL ON FUNCTION public.update_modified_column(),public.handle_new_user(),public.guard_workout_child(),public.workout_json(uuid),public.initialize_user(jsonb),public.start_workout(),public.begin_workout(uuid),public.set_workout_paused(uuid,boolean),public.cancel_workout(uuid),public.sync_daily_data(),public.complete_workout(uuid,text),public.switch_class(text,text),public.get_user_stats() FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.initialize_user(jsonb),public.start_workout(),public.begin_workout(uuid),public.set_workout_paused(uuid,boolean),public.cancel_workout(uuid),public.sync_daily_data(),public.complete_workout(uuid,text),public.switch_class(text,text),public.get_user_stats() TO authenticated;
-- Guard against an unmanaged legacy PR upsert RPC, if it exists remotely.
DO $$ BEGIN IF to_regprocedure('public.upsert_exercise_pr(uuid,uuid,numeric)') IS NOT NULL THEN EXECUTE 'REVOKE ALL ON FUNCTION public.upsert_exercise_pr(uuid,uuid,numeric) FROM PUBLIC,anon,authenticated'; END IF; END $$;

CREATE TABLE IF NOT EXISTS public.coach_daily_usage (
 user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
 usage_date date NOT NULL,
 request_count integer NOT NULL DEFAULT 0 CHECK(request_count BETWEEN 0 AND 20),
 PRIMARY KEY(user_id,usage_date)
);
ALTER TABLE public.coach_daily_usage ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.coach_daily_usage FROM anon,authenticated;
GRANT SELECT ON public.coach_daily_usage TO authenticated;
CREATE POLICY own_read ON public.coach_daily_usage FOR SELECT TO authenticated USING(user_id=(SELECT auth.uid()));
CREATE OR REPLACE FUNCTION public.consume_coach_request() RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE uid uuid=auth.uid(); n integer; BEGIN
 IF uid IS NULL THEN RAISE EXCEPTION 'Authentication required' USING ERRCODE='42501'; END IF;
 INSERT INTO public.coach_daily_usage(user_id,usage_date,request_count) VALUES(uid,(now() AT TIME ZONE 'UTC')::date,1)
 ON CONFLICT(user_id,usage_date) DO UPDATE SET request_count=public.coach_daily_usage.request_count+1 WHERE public.coach_daily_usage.request_count<20
 RETURNING request_count INTO n;
 RETURN n IS NOT NULL;
END $$;
REVOKE ALL ON FUNCTION public.consume_coach_request() FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.consume_coach_request() TO authenticated;
