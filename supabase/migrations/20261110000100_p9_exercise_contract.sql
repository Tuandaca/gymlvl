-- P9 exercise contract: isolate user-owned exercises and preserve history.
--
-- The earlier catalogue_read policy is permissive and combines with the P7
-- owner policy, exposing custom exercises to other authenticated users.
-- Client DELETE on exercises can cascade into workout history and PRs; the
-- supported client operation is archive via is_archived instead.
--
-- Recovery: use a subsequent reviewed migration to replace these policies or
-- this function if the contract changes. Do not restore the broad read policy
-- or client DELETE while user-linked exercise references exist.

DROP POLICY IF EXISTS catalogue_read ON public.exercises;
DROP POLICY IF EXISTS "Anyone can view exercises" ON public.exercises;
CREATE POLICY "Anyone can view exercises" ON public.exercises
  FOR SELECT TO authenticated
  USING (
    (user_id IS NULL AND source <> 'user')
    OR (user_id = (SELECT auth.uid()) AND source = 'user')
  );

DROP POLICY IF EXISTS "Users can delete own custom exercises" ON public.exercises;
REVOKE DELETE ON public.exercises FROM PUBLIC, anon, authenticated;

-- Existing cross-owner references cannot be repaired by an access-policy
-- migration without changing user history. Stop deployment for review if an
-- earlier client attached another user's private exercise by guessed UUID.
DO $$
BEGIN
 IF EXISTS (
   SELECT 1
   FROM public.workout_exercises we
   JOIN public.workouts w ON w.id = we.workout_id
   JOIN public.exercises e ON e.id = we.exercise_id
   WHERE e.source = 'user'
     AND e.user_id IS DISTINCT FROM w.user_id
 ) THEN
   RAISE EXCEPTION 'Cross-owner custom exercise references require review before P9 migration'
     USING ERRCODE = '23514';
 END IF;
END $$;

-- A foreign key checks existence, not whether the caller may use that row.
-- Keep the original workout lock and identity guard; validate only new
-- workout-exercise references so existing archived history stays readable.
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
 IF TG_TABLE_NAME='workout_exercises' AND TG_OP='INSERT' THEN
  PERFORM 1 FROM public.exercises e
   WHERE e.id=NEW.exercise_id
     AND ((e.user_id IS NULL AND e.source <> 'user')
       OR (e.user_id=owner_id AND e.source='user' AND NOT e.is_archived));
  IF NOT FOUND THEN RAISE EXCEPTION 'Exercise is unavailable for this workout' USING ERRCODE='42501'; END IF;
 END IF;
 IF TG_TABLE_NAME='workout_sets' AND TG_OP='INSERT' THEN
  SELECT coalesce(max_weight_kg,0) INTO NEW.baseline_weight_kg FROM public.exercise_prs WHERE user_id=owner_id AND exercise_id=eid;
  NEW.baseline_weight_kg=greatest(0,least(1000,coalesce(NEW.baseline_weight_kg,0)));
 ELSIF TG_TABLE_NAME='workout_sets' AND TG_OP='UPDATE' THEN
  NEW.baseline_weight_kg=OLD.baseline_weight_kg;
 END IF;
 IF TG_OP='DELETE' THEN RETURN OLD; END IF;
 RETURN NEW;
END $$;

-- SECURITY DEFINER bypasses the catalogue RLS policy. Apply the same owner
-- boundary explicitly, and omit archived exercises from new quest targets.
-- Keep the existing quest schedule, target values and reward contract intact.
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
   NOT ex.is_archived
   AND ((ex.user_id IS NULL AND ex.source <> 'user')
     OR (ex.user_id = uid AND ex.source = 'user'))
   AND ((template.category='push' AND lower(ex.force_type)='push' AND lower(ex.category)<>'legs') OR
     (template.category='pull' AND lower(ex.force_type)='pull' AND lower(ex.category)<>'legs') OR
     (template.category='legs' AND lower(ex.category)='legs') OR template.category='full_body')
   ORDER BY ex.name LIMIT 3) e LEFT JOIN public.exercise_prs pr ON pr.exercise_id=e.id AND pr.user_id=uid;
 IF config IS NULL THEN RAISE EXCEPTION 'Exercises for today are unavailable' USING ERRCODE='22023'; END IF;
 INSERT INTO public.quest_instances(user_id,quest_id,prescribed_config,expires_at,quest_date) VALUES(uid,template.id,config,((day+1)::timestamp AT TIME ZONE p.timezone),day) RETURNING * INTO q;
 RETURN jsonb_build_object('message','New quest generated','quest',to_jsonb(q),'isDiscovery',NOT EXISTS(SELECT 1 FROM public.exercise_prs WHERE user_id=uid));
END $$;
