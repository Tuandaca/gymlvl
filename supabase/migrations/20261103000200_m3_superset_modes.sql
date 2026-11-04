-- M3 owner-approved contracts. Local/test migration only; production activation remains gated.
ALTER TABLE public.workout_exercises
  ADD COLUMN IF NOT EXISTS superset_position integer,
  ADD COLUMN IF NOT EXISTS superset_locked boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS mode text;

ALTER TABLE public.workout_exercises
  ADD CONSTRAINT workout_exercises_superset_position_pair
    CHECK ((superset_group_id IS NULL) = (superset_position IS NULL)),
  ADD CONSTRAINT workout_exercises_superset_position_nonnegative
    CHECK (superset_position IS NULL OR superset_position >= 0),
  ADD CONSTRAINT workout_exercises_mode_valid
    CHECK (mode IS NULL OR mode IN ('reps-weight', 'bodyweight', 'timed', 'cardio'));

CREATE UNIQUE INDEX workout_exercises_superset_position_unique
  ON public.workout_exercises(workout_id, superset_group_id, superset_position)
  WHERE superset_group_id IS NOT NULL;

-- A durable lock preserves the first-completed-set boundary even when that
-- set is later uncompleted or deleted. Clients have no direct ledger access.
CREATE TABLE public.workout_superset_locks (
  workout_id uuid NOT NULL REFERENCES public.workouts(id) ON DELETE CASCADE,
  group_id uuid NOT NULL,
  locked_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (workout_id, group_id)
);
ALTER TABLE public.workout_superset_locks ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.workout_superset_locks FROM PUBLIC, anon, authenticated;

-- Preserve "once had a set" even if every set is later deleted. The initial
-- INSERT captures existing rows without changing their user-linked fields.
CREATE TABLE public.workout_exercise_mode_locks (
  workout_exercise_id uuid PRIMARY KEY
    REFERENCES public.workout_exercises(id) ON DELETE CASCADE,
  locked_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.workout_exercise_mode_locks ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.workout_exercise_mode_locks FROM PUBLIC, anon, authenticated;
INSERT INTO public.workout_exercise_mode_locks(workout_exercise_id)
  SELECT DISTINCT workout_exercise_id FROM public.workout_sets
  ON CONFLICT DO NOTHING;

-- The invoker trigger can inspect a private lock only through this
-- owner-scoped predicate; callers learn no other account's lock state.
CREATE OR REPLACE FUNCTION public.is_workout_exercise_mode_locked(p_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.workout_exercise_mode_locks l
    JOIN public.workout_exercises we ON we.id = l.workout_exercise_id
    JOIN public.workouts w ON w.id = we.workout_id
    WHERE l.workout_exercise_id = p_id AND w.user_id = auth.uid()
  );
$$;
REVOKE ALL ON FUNCTION public.is_workout_exercise_mode_locked(uuid)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.is_workout_exercise_mode_locked(uuid)
  TO authenticated;

-- Group changes are mediated by the transactional RPC. Existing authenticated
-- table grants remain for unrelated exercise fields.
CREATE OR REPLACE FUNCTION public.guard_workout_exercise_contract()
RETURNS trigger LANGUAGE plpgsql SET search_path = '' AS $$
DECLARE layout_owner text;
BEGIN
  SELECT pg_catalog.pg_get_userbyid(p.proowner) INTO layout_owner
    FROM pg_catalog.pg_proc p
    WHERE p.oid = 'public.set_superset_layout_v1(uuid,jsonb)'::pg_catalog.regprocedure;
  IF TG_OP = 'DELETE' THEN
    IF OLD.superset_group_id IS NOT NULL THEN
      RAISE EXCEPTION 'Ungroup before deleting an exercise' USING ERRCODE = '22023';
    END IF;
    RETURN OLD;
  END IF;
  IF TG_OP = 'INSERT' THEN
    IF NEW.superset_locked THEN
      RAISE EXCEPTION 'Superset lock is server-owned' USING ERRCODE = '42501';
    END IF;
    IF NEW.superset_group_id IS NOT NULL AND current_user IS DISTINCT FROM layout_owner THEN
      RAISE EXCEPTION 'Use set_superset_layout_v1 to group exercises' USING ERRCODE = '42501';
    END IF;
  ELSE
    IF (NEW.superset_group_id, NEW.superset_position)
       IS DISTINCT FROM (OLD.superset_group_id, OLD.superset_position)
       AND current_user IS DISTINCT FROM layout_owner THEN
      RAISE EXCEPTION 'Use set_superset_layout_v1 to change groups' USING ERRCODE = '42501';
    END IF;
    IF NEW.mode IS DISTINCT FROM OLD.mode AND (
      public.is_workout_exercise_mode_locked(OLD.id)
      OR EXISTS (SELECT 1 FROM public.workout_sets
                 WHERE workout_exercise_id = OLD.id)
    ) THEN
      RAISE EXCEPTION 'Mode cannot change after the first set' USING ERRCODE = '22023';
    END IF;
    IF NEW.superset_locked IS DISTINCT FROM OLD.superset_locked
       AND (current_user IS DISTINCT FROM layout_owner OR OLD.superset_locked) THEN
      RAISE EXCEPTION 'Superset lock is server-owned and irreversible' USING ERRCODE = '42501';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;
CREATE TRIGGER guard_workout_exercise_contract
  BEFORE INSERT OR UPDATE OR DELETE ON public.workout_exercises
  FOR EACH ROW EXECUTE FUNCTION public.guard_workout_exercise_contract();
REVOKE ALL ON FUNCTION public.guard_workout_exercise_contract()
  FROM PUBLIC, anon, authenticated;

-- Keep the pre-approval trigger in place and replace its behavior only after
-- the approved RPC guard is installed. No table, column, or history is dropped.
CREATE OR REPLACE FUNCTION public.reject_unapproved_superset_group()
RETURNS trigger LANGUAGE plpgsql SET search_path = '' AS $$
BEGIN
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION public.reject_unapproved_superset_group()
  FROM PUBLIC, anon, authenticated;

-- Legacy NULL mode keeps its existing validation. Typed completed sets use
-- their explicit discriminator; no mode is inferred from nullable measurements.
CREATE OR REPLACE FUNCTION public.guard_workout_set_mode()
RETURNS trigger LANGUAGE plpgsql SET search_path = '' AS $$
DECLARE exercise_mode text;
BEGIN
  SELECT mode INTO exercise_mode FROM public.workout_exercises
    WHERE id = NEW.workout_exercise_id;
  IF exercise_mode IN ('reps-weight', 'bodyweight')
     AND (NEW.duration_seconds IS DISTINCT FROM 0
          OR (NEW.is_completed AND
              (NEW.reps IS NULL OR NEW.reps NOT BETWEEN 1 AND 1000
               OR NEW.weight_kg IS NULL OR NEW.weight_kg NOT BETWEEN 0 AND 1000))) THEN
    RAISE EXCEPTION 'Invalid reps or external load' USING ERRCODE = '22023';
  END IF;
  IF exercise_mode IN ('timed', 'cardio')
     AND (NEW.reps IS DISTINCT FROM 0 OR NEW.weight_kg IS DISTINCT FROM 0
          OR (NEW.is_completed AND
              (NEW.duration_seconds IS NULL
               OR NEW.duration_seconds NOT BETWEEN 1 AND 7200))) THEN
    RAISE EXCEPTION 'Invalid duration-only set' USING ERRCODE = '22023';
  END IF;
  RETURN NEW;
END;
$$;
CREATE TRIGGER guard_workout_set_mode
  BEFORE INSERT OR UPDATE ON public.workout_sets
  FOR EACH ROW EXECUTE FUNCTION public.guard_workout_set_mode();
REVOKE ALL ON FUNCTION public.guard_workout_set_mode()
  FROM PUBLIC, anon, authenticated;

-- Legacy ungrouped rows are untouched. Grouped rounds require one set number
-- per member. Trigger names sort alphabetically: guard_set_write locks the
-- workout before guard_set_write_group_number checks for duplicates.
CREATE OR REPLACE FUNCTION public.guard_group_set_number()
RETURNS trigger LANGUAGE plpgsql SET search_path = '' AS $$
DECLARE group_id uuid;
BEGIN
  SELECT superset_group_id INTO group_id
    FROM public.workout_exercises WHERE id = NEW.workout_exercise_id;
  IF group_id IS NOT NULL AND EXISTS (
    SELECT 1 FROM public.workout_sets s
    WHERE s.workout_exercise_id = NEW.workout_exercise_id
      AND s.set_number = NEW.set_number
      AND s.id IS DISTINCT FROM NEW.id
  ) THEN
    RAISE EXCEPTION 'Duplicate set number in superset member'
      USING ERRCODE = '23505';
  END IF;
  RETURN NEW;
END;
$$;
CREATE TRIGGER guard_set_write_group_number
  BEFORE INSERT OR UPDATE OF set_number, workout_exercise_id
  ON public.workout_sets
  FOR EACH ROW EXECUTE FUNCTION public.guard_group_set_number();
REVOKE ALL ON FUNCTION public.guard_group_set_number()
  FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.record_workout_exercise_mode_lock()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
BEGIN
  INSERT INTO public.workout_exercise_mode_locks(workout_exercise_id)
    VALUES (NEW.workout_exercise_id) ON CONFLICT DO NOTHING;
  RETURN NEW;
END;
$$;
CREATE TRIGGER record_workout_exercise_mode_lock
  AFTER INSERT ON public.workout_sets
  FOR EACH ROW EXECUTE FUNCTION public.record_workout_exercise_mode_lock();
REVOKE ALL ON FUNCTION public.record_workout_exercise_mode_lock()
  FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.record_superset_completion_lock()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
BEGIN
  IF NEW.is_completed THEN
    INSERT INTO public.workout_superset_locks(workout_id, group_id)
    SELECT we.workout_id, we.superset_group_id
    FROM public.workout_exercises we
    WHERE we.id = NEW.workout_exercise_id AND we.superset_group_id IS NOT NULL
    ON CONFLICT DO NOTHING;
    UPDATE public.workout_exercises member
      SET superset_locked = true
      FROM public.workout_exercises completed
      WHERE completed.id = NEW.workout_exercise_id
        AND completed.superset_group_id IS NOT NULL
        AND member.workout_id = completed.workout_id
        AND member.superset_group_id = completed.superset_group_id
        AND NOT member.superset_locked;
  END IF;
  RETURN NEW;
END;
$$;
CREATE TRIGGER record_superset_completion_lock
  AFTER INSERT OR UPDATE OF is_completed ON public.workout_sets
  FOR EACH ROW EXECUTE FUNCTION public.record_superset_completion_lock();
REVOKE ALL ON FUNCTION public.record_superset_completion_lock()
  FROM PUBLIC, anon, authenticated;

-- The function runs in one PostgreSQL transaction. It locks in the same
-- user -> workout order as complete_workout and the idempotent write RPC.
CREATE OR REPLACE FUNCTION public.set_superset_layout_v1(
  p_workout_id uuid, p_groups jsonb
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
  uid uuid := auth.uid();
  group_spec jsonb;
  member_spec jsonb;
  group_id uuid;
  member_id uuid;
  position integer;
  member_ids uuid[] := ARRAY[]::uuid[];
  group_ids uuid[] := ARRAY[]::uuid[];
  normalized_groups jsonb := '[]'::jsonb;
  frozen record;
  desired_group uuid;
  desired_position integer;
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501'; END IF;
  IF p_workout_id IS NULL OR jsonb_typeof(p_groups) IS DISTINCT FROM 'array' THEN
    RAISE EXCEPTION 'Invalid superset layout' USING ERRCODE = '22023';
  END IF;
  PERFORM 1 FROM public.users WHERE id = uid FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Account unavailable' USING ERRCODE = '42501'; END IF;
  PERFORM 1 FROM public.workouts WHERE id = p_workout_id AND user_id = uid AND status = 'active' FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Workout unavailable' USING ERRCODE = '42501'; END IF;
  PERFORM 1 FROM public.workout_exercises WHERE workout_id = p_workout_id ORDER BY id FOR UPDATE;

  FOR group_spec IN SELECT value FROM jsonb_array_elements(p_groups) LOOP
    IF jsonb_typeof(group_spec) IS DISTINCT FROM 'object'
       OR jsonb_typeof(group_spec->'exercise_ids') IS DISTINCT FROM 'array' THEN
      RAISE EXCEPTION 'Invalid superset group' USING ERRCODE = '22023';
    END IF;
    -- A one-member group dissolves as part of this transaction.
    IF jsonb_array_length(group_spec->'exercise_ids') < 2 THEN CONTINUE; END IF;
    normalized_groups := normalized_groups || jsonb_build_array(group_spec);
    group_id := (group_spec->>'group_id')::uuid;
    IF group_id IS NULL OR group_id = ANY(group_ids) OR EXISTS (
      SELECT 1 FROM public.workout_exercises
      WHERE superset_group_id = group_id AND workout_id <> p_workout_id
    ) THEN
      RAISE EXCEPTION 'Duplicate or cross-workout group ID' USING ERRCODE = '22023';
    END IF;
    group_ids := array_append(group_ids, group_id);
    position := 0;
    FOR member_spec IN SELECT value FROM jsonb_array_elements(group_spec->'exercise_ids') LOOP
      member_id := (member_spec #>> '{}')::uuid;
      IF member_id IS NULL OR member_id = ANY(member_ids) OR NOT EXISTS (
        SELECT 1 FROM public.workout_exercises
        WHERE id = member_id AND workout_id = p_workout_id
      ) THEN
        RAISE EXCEPTION 'Duplicate or foreign workout exercise' USING ERRCODE = '22023';
      END IF;
      IF EXISTS (
        SELECT 1 FROM public.workout_sets s
        WHERE s.workout_exercise_id = member_id
        GROUP BY s.set_number HAVING count(*) > 1
      ) THEN
        RAISE EXCEPTION 'Duplicate historical set number in group member'
          USING ERRCODE = '23505';
      END IF;
      member_ids := array_append(member_ids, member_id);
      position := position + 1;
    END LOOP;
  END LOOP;

  -- Compare final membership/order before any write. The append-only lock
  -- freezes every member, including members without completed sets.
  FOR frozen IN
    SELECT we.id, we.superset_group_id, we.superset_position
    FROM public.workout_exercises we
    WHERE we.workout_id = p_workout_id AND we.superset_group_id IS NOT NULL
      AND EXISTS (SELECT 1 FROM public.workout_superset_locks l
        WHERE l.workout_id = p_workout_id
          AND l.group_id = we.superset_group_id)
  LOOP
    desired_group := NULL;
    desired_position := NULL;
    FOR group_spec IN SELECT value FROM jsonb_array_elements(normalized_groups) LOOP
      position := 0;
      FOR member_spec IN SELECT value FROM jsonb_array_elements(group_spec->'exercise_ids') LOOP
        IF (member_spec #>> '{}')::uuid = frozen.id THEN
          desired_group := (group_spec->>'group_id')::uuid;
          desired_position := position;
        END IF;
        position := position + 1;
      END LOOP;
    END LOOP;
    IF (desired_group, desired_position)
       IS DISTINCT FROM (frozen.superset_group_id, frozen.superset_position) THEN
      RAISE EXCEPTION 'Completed superset membership and order are locked' USING ERRCODE = '22023';
    END IF;
  END LOOP;

  -- Clear first to avoid transient unique-position collisions while swapping.
  UPDATE public.workout_exercises
    SET superset_group_id = NULL, superset_position = NULL
    WHERE workout_id = p_workout_id AND superset_group_id IS NOT NULL;
  FOR group_spec IN SELECT value FROM jsonb_array_elements(normalized_groups) LOOP
    group_id := (group_spec->>'group_id')::uuid;
    position := 0;
    FOR member_spec IN SELECT value FROM jsonb_array_elements(group_spec->'exercise_ids') LOOP
      UPDATE public.workout_exercises
        SET superset_group_id = group_id, superset_position = position
        WHERE id = (member_spec #>> '{}')::uuid;
      position := position + 1;
    END LOOP;
  END LOOP;
  INSERT INTO public.workout_superset_locks(workout_id, group_id)
  SELECT p_workout_id, grouped.superset_group_id
  FROM public.workout_exercises grouped
  JOIN public.workout_sets s ON s.workout_exercise_id = grouped.id
  WHERE grouped.workout_id = p_workout_id
    AND grouped.superset_group_id IS NOT NULL AND s.is_completed
  GROUP BY grouped.superset_group_id
  ON CONFLICT DO NOTHING;
  UPDATE public.workout_exercises member
    SET superset_locked = true
    FROM public.workout_superset_locks l
    WHERE member.workout_id = p_workout_id
      AND member.superset_group_id = l.group_id
      AND l.workout_id = p_workout_id
      AND NOT member.superset_locked;
  RETURN jsonb_build_object('workout_id', p_workout_id, 'group_count', jsonb_array_length(normalized_groups));
END;
$$;
REVOKE ALL ON FUNCTION public.set_superset_layout_v1(uuid, jsonb)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.set_superset_layout_v1(uuid, jsonb)
  TO authenticated;

-- Preserve the sole reward authority while accepting typed duration-only sets.
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
 -- A legacy tuple can carry ledger evidence without a reward row or flag; that means
 -- XP was already granted. Never award it twice and never fabricate a replacement.
 IF EXISTS(SELECT 1 FROM public.xp_logs l WHERE l.user_id=uid AND l.source_id=w.id::text AND l.source IN ('workout','quest')) THEN RETURN jsonb_build_object('earnedXP',0,'totalXP',u.total_xp,'newLevel',u.level,'leveledUp',false,'isQuest',false,'newTitle',NULL,'nextLevelXp',floor(100*power(u.level,1.5)),'isSuspicious',false,'classResults','[]'::jsonb,'achievements','[]'::jsonb,'alreadyAwarded',true); END IF;
 -- A legacy completed/unrewarded session retains its original completion time.
 IF w.status='completed' THEN finished=coalesce(w.completed_at,finished); END IF;
 duration=greatest(1,floor(extract(epoch FROM coalesce(w.paused_at,finished)-w.training_started_at))::integer-w.paused_seconds);
 SELECT count(*)::integer,array_agg(DISTINCT lower(e.category)),sum(CASE WHEN s.baseline_weight_kg>0 THEN 5*least(3,greatest(0.2,s.weight_kg/s.baseline_weight_kg)) ELSE 5 END)
 INTO completed_sets,categories,base_xp FROM public.workout_sets s JOIN public.workout_exercises we ON we.id=s.workout_exercise_id JOIN public.exercises e ON e.id=we.exercise_id WHERE we.workout_id=w.id AND s.is_completed;
 IF completed_sets=0 THEN RAISE EXCEPTION 'Complete at least one set before finishing' USING ERRCODE='22023'; END IF;
 IF completed_sets>300 OR EXISTS(SELECT 1 FROM public.workout_sets s JOIN public.workout_exercises we ON we.id=s.workout_exercise_id WHERE we.workout_id=w.id AND s.is_completed AND (s.weight_kg<0 OR s.weight_kg>1000 OR (we.mode IN ('timed','cardio') AND (s.reps<>0 OR coalesce(s.duration_seconds,0) NOT BETWEEN 1 AND 7200 OR s.weight_kg<>0)) OR (we.mode IN ('reps-weight','bodyweight') AND (s.reps<1 OR s.reps>1000 OR s.duration_seconds IS DISTINCT FROM 0)) OR (we.mode IS NULL AND (s.reps<1 OR s.reps>1000)))) THEN RAISE EXCEPTION 'Invalid workout measurements' USING ERRCODE='22023'; END IF;
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
 SELECT uid,we.exercise_id,max(s.weight_kg),max(s.reps),max(s.weight_kg*(1+s.reps/30.0)),true FROM public.workout_sets s JOIN public.workout_exercises we ON we.id=s.workout_exercise_id WHERE we.workout_id=w.id AND s.is_completed AND (we.mode IS NULL OR we.mode IN ('reps-weight','bodyweight')) GROUP BY we.exercise_id
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

REVOKE ALL ON FUNCTION public.complete_workout(uuid,text) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.complete_workout(uuid,text) TO authenticated;
