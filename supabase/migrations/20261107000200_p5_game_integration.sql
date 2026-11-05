-- P5 Deep GymLvl Game Integration (additive).
-- Extends the existing progression/quest/achievement system without creating
-- a parallel reward engine. complete_workout remains the sole authoritative
-- reward path; no client-supplied XP/level/achievement values are trusted.
--
-- Additive only: no existing tables/columns dropped or truncated, no data
-- deleted, no RLS weakened. Production is NOT applied by this migration.
--
-- Rollback path: DROP TABLE unlock_definitions/user_unlocks and DROP FUNCTION
-- get_player_production. Dropping the new tables/functions does not touch
-- existing progression data.

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 1. Expand the achievement catalogue (user_achievements CHECK constraint).
--    Existing rows keep the 4 legacy IDs; new IDs are derivable from values
--    complete_workout already computes (total_workouts, streak, new_level).
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DO $$
DECLARE cname text;
BEGIN
  SELECT conname INTO cname
  FROM pg_constraint
  WHERE conrelid = 'public.user_achievements'::regclass
    AND contype = 'c'
    AND pg_get_constraintdef(oid) LIKE '%achievement_id%';
  IF cname IS NOT NULL THEN
    EXECUTE format('ALTER TABLE public.user_achievements DROP CONSTRAINT %I', cname);
  END IF;
END $$;

ALTER TABLE public.user_achievements
  ADD CONSTRAINT user_achievements_achievement_id_check
  CHECK (achievement_id IN (
    'first_workout', 'five_workouts', 'ten_workouts',
    'streak_3', 'streak_7', 'level_10', 'level_20'
  ));

COMMENT ON CONSTRAINT user_achievements_achievement_id_check ON public.user_achievements IS
  'P5 achievement catalogue. Every ID is derivable server-side from validated completion data.';

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 2. Unlock definitions (level / achievement / class milestones).
--    Unlocks motivate progression but never lock core fitness functionality.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CREATE TABLE IF NOT EXISTS public.unlock_definitions (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  unlock_type TEXT NOT NULL CHECK (unlock_type IN ('level','achievement','class','quest')),
  threshold_value INTEGER NOT NULL,
  reward_type TEXT NOT NULL CHECK (reward_type IN ('badge','title','accent')),
  reward_value TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.user_unlocks (
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  unlock_id TEXT NOT NULL REFERENCES public.unlock_definitions(id) ON DELETE CASCADE,
  unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  PRIMARY KEY (user_id, unlock_id)
);

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 3. RLS for unlock tables: owner isolation only.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ALTER TABLE public.unlock_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_unlocks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Unlock definitions readable by all" ON public.unlock_definitions;
CREATE POLICY "Unlock definitions readable by all"
  ON public.unlock_definitions FOR SELECT
  USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Users can view own unlocks" ON public.user_unlocks;
CREATE POLICY "Users can view own unlocks"
  ON public.user_unlocks FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own unlocks" ON public.user_unlocks;
CREATE POLICY "Users can insert own unlocks"
  ON public.user_unlocks FOR INSERT
  WITH CHECK (auth.uid() = user_id);

GRANT SELECT ON public.unlock_definitions TO authenticated;
GRANT SELECT ON public.user_unlocks TO authenticated;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 4. Seed unlock definitions (level thresholds + achievement milestones).
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
INSERT INTO public.unlock_definitions(id,title,description,unlock_type,threshold_value,reward_type,reward_value) VALUES
  ('badge_first_workout','First Steps','Completed your first workout.','achievement',1,'badge','first_workout'),
  ('badge_streak_3','Steady Start','Trained on 3 separate days.','achievement',3,'badge','streak_3'),
  ('badge_streak_7','One Week','Trained on 7 separate days.','achievement',7,'badge','streak_7'),
  ('title_level_10','Veteran','Reached Level 10.','level',10,'title','Veteran'),
  ('title_level_20','Grand Master','Reached Level 20 (graduation).','level',20,'title','Grand Master'),
  ('badge_level_20','Graduate','Graduated your class at Level 20.','level',20,'badge','level_20')
ON CONFLICT (id) DO UPDATE SET
  title=excluded.title,
  description=excluded.description,
  unlock_type=excluded.unlock_type,
  threshold_value=excluded.threshold_value,
  reward_type=excluded.reward_type,
  reward_value=excluded.reward_value;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 5. Seed the quest catalogue so daily quests can be generated.
--    Categories map to exercise force_type/category so sync_daily_data can
--    build prescribed configs deterministically.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
INSERT INTO public.quests(title,description,type,difficulty,category,base_xp) VALUES
  ('Push Day','Complete 3 push exercises.','daily_routine','beginner','push',150),
  ('Pull Day','Complete 3 pull exercises.','daily_routine','beginner','pull',150),
  ('Legs Day','Complete 3 leg exercises.','daily_routine','beginner','legs',150),
  ('Full Body','Complete 3 full-body exercises.','daily_routine','beginner','full_body',150),
  ('Consistency Streak','Train on 3 separate days.','weekly_challenge','intermediate','full_body',300)
ON CONFLICT (id) DO NOTHING;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 6. Unified player-progression RPC.
--    Aggregates user, classes, streak, achievements, active quest into one
--    owner-scoped payload. Derives user from auth.uid() only.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CREATE OR REPLACE FUNCTION public.get_player_progression() RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE
  uid uuid := auth.uid();
  u public.users;
  p public.profiles;
  tz text := 'Asia/Ho_Chi_Minh';
  day date;
  streak jsonb := '[]'::jsonb;
  achievements jsonb := '[]'::jsonb;
  classes jsonb := '[]'::jsonb;
  active_quest jsonb := NULL;
  next_unlock jsonb := NULL;
  c record;
  a record;
  q record;
  unlock_rec record;
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'Authentication required' USING ERRCODE='42501'; END IF;

  SELECT * INTO u FROM public.users WHERE id=uid;
  IF u.id IS NULL THEN RAISE EXCEPTION 'Account profile unavailable' USING ERRCODE='22023'; END IF;

  SELECT coalesce(timezone,'Asia/Ho_Chi_Minh') INTO tz FROM public.profiles WHERE id=uid;
  day := (now() AT TIME ZONE tz)::date;

  -- Streak (respect timezone day boundary).
  SELECT to_jsonb(s) INTO streak FROM public.streaks s WHERE user_id=uid;

  -- Achievements earned by this user.
  SELECT coalesce(jsonb_agg(to_jsonb(ua) ORDER BY unlocked_at),'[]'::jsonb) INTO achievements
  FROM public.user_achievements ua WHERE user_id=uid;

  -- Classes with current XP/level.
  FOR c IN SELECT uc.class_id, uc.class_name, uc.slot, uc.current_xp, uc.level,
                        uc.is_graduated, cd.focus_categories, cd.xp_base, cd.xp_slope
           FROM public.user_classes uc
           JOIN public.class_definitions cd USING(class_id)
           WHERE uc.user_id=uid
           ORDER BY uc.slot, uc.class_id
  LOOP
    classes := classes || jsonb_build_object(
      'classId', c.class_id, 'className', c.class_name, 'slot', c.slot,
      'currentXP', c.current_xp, 'level', c.level,
      'isGraduated', c.is_graduated,
      'focusCategories', c.focus_categories,
      'xpBase', c.xp_base, 'xpSlope', c.xp_slope
    );
  END LOOP;

  -- Active (non-expired) quest instance for today.
  SELECT * INTO q FROM public.quest_instances
  WHERE user_id=uid AND status='active' AND quest_date=day AND expires_at>now()
  ORDER BY created_at LIMIT 1;
  IF q.id IS NOT NULL THEN
    active_quest := jsonb_build_object(
      'questId', q.id, 'questTitle', (SELECT title FROM public.quests WHERE id=q.quest_id),
      'status', q.status, 'earnedXp', q.earned_xp,
      'config', q.prescribed_config, 'expiresAt', q.expires_at
    );
  END IF;

  -- Next not-yet-unlocked unlock (level/achievement based, evaluated cheaply).
  FOR unlock_rec IN SELECT ud.id, ud.title, ud.description, ud.unlock_type, ud.threshold_value,
                                  ud.reward_type, ud.reward_value
                    FROM public.unlock_definitions ud
                    LEFT JOIN public.user_unlocks uu
                      ON uu.unlock_id=ud.id AND uu.user_id=uid
                    WHERE uu.unlock_id IS NULL
                    ORDER BY
                      CASE ud.unlock_type WHEN 'level' THEN 1 WHEN 'achievement' THEN 2 ELSE 3 END,
                      ud.threshold_value
                    LIMIT 1
  LOOP
    next_unlock := jsonb_build_object(
      'unlockId', unlock_rec.id, 'title', unlock_rec.title, 'description', unlock_rec.description,
      'unlockType', unlock_rec.unlock_type, 'thresholdValue', unlock_rec.threshold_value,
      'rewardType', unlock_rec.reward_type, 'rewardValue', unlock_rec.reward_value
    );
    EXIT;
  END LOOP;

  RETURN jsonb_build_object(
    'userId', uid,
    'level', u.level, 'totalXP', u.total_xp, 'currentTitle', u.current_title,
    'lastWorkoutDate', u.last_workout_date,
    'streak', streak,
    'achievements', achievements,
    'classes', classes,
    'activeQuest', active_quest,
    'nextUnlock', next_unlock
  );
END $$;

REVOKE ALL ON FUNCTION public.get_player_progression() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_player_progression() TO authenticated;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 7. Extend complete_workout to grant the expanded achievement catalogue.
--    All new IDs are derivable from values already computed (total_workouts,
--    streak, new_level). No new reward logic; identical idempotency/retry
--    guarantees. Reproduces the prior body with the FOREACH array extended.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CREATE OR REPLACE FUNCTION public.complete_workout(p_workout_id uuid, p_notes text DEFAULT NULL) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
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
  classes:=classes||jsonb_build_array(jsonb_build_object('classId',c.class_id,'className',c.class_name,'slot',c.slot,'xpEarned',cxp,'newTotalXP',c.current_xp+cxp,'newLevel',clevel,'leveledUp',clevel>c.level,'isGraduation',clevel=20 AND c.level<20));
 END LOOP;
 UPDATE public.users SET total_xp=total,level=new_level,current_level_xp=total-CASE WHEN new_level>1 THEN floor(100*power(new_level-1,1.5))::integer ELSE 0 END,current_title=title,last_workout_date=greatest(last_workout_date,finished),last_active_at=greatest(last_active_at,finished) WHERE id=uid;
 UPDATE public.streaks SET current_streak=streak,longest_streak=greatest(longest_streak,streak),last_activity_date=greatest(coalesce(last_activity_date,day),day) WHERE user_id=uid;
 UPDATE public.workouts SET status='completed',completed_at=finished,duration_seconds=duration,notes=coalesce(p_notes,notes),paused_at=NULL,is_xp_calculated=true WHERE id=w.id;
 INSERT INTO public.xp_logs(user_id,amount,source,source_id) VALUES(uid,earned,CASE WHEN quest_match THEN 'quest' ELSE 'workout' END,w.id::text);
 IF quest_match THEN UPDATE public.quest_instances SET status='completed',completed_at=finished,earned_xp=earned WHERE id=q.id; END IF;
 INSERT INTO public.exercise_prs(user_id,exercise_id,max_weight_kg,max_reps,estimated_1rm,is_confirmed)
 SELECT uid,we.exercise_id,max(s.weight_kg),max(s.reps),max(s.weight_kg * (1 + s.reps / 30.0)), true
  FROM public.workout_sets s
  JOIN public.workout_exercises we ON we.id = s.workout_exercise_id
  WHERE we.workout_id = w.id
    AND s.is_completed
    AND (we.mode IS NULL OR we.mode IN ('reps-weight', 'bodyweight'))
    AND (s.set_type IS NULL OR s.set_type = 'workout')
  GROUP BY we.exercise_id
 ON CONFLICT(user_id,exercise_id) DO UPDATE SET max_weight_kg=greatest(public.exercise_prs.max_weight_kg,excluded.max_weight_kg),max_reps=greatest(public.exercise_prs.max_reps,excluded.max_reps),estimated_1rm=greatest(public.exercise_prs.estimated_1rm,excluded.estimated_1rm),is_confirmed=true;
 SELECT count(*) INTO total_workouts FROM public.workouts WHERE user_id=uid AND status='completed';
 FOREACH achievement IN ARRAY ARRAY[
   'first_workout',
   CASE WHEN total_workouts>=5 THEN 'five_workouts' END,
   CASE WHEN total_workouts>=10 THEN 'ten_workouts' END,
   CASE WHEN streak>=3 THEN 'streak_3' END,
   CASE WHEN streak>=7 THEN 'streak_7' END,
   CASE WHEN new_level>=10 THEN 'level_10' END,
   CASE WHEN new_level>=20 THEN 'level_20' END
 ] LOOP
   IF achievement IS NOT NULL THEN
     INSERT INTO public.user_achievements(user_id,achievement_id) VALUES(uid,achievement) ON CONFLICT DO NOTHING;
     IF FOUND THEN achievements:=achievements||to_jsonb(achievement); END IF;
   END IF;
 END LOOP;
 result:=jsonb_build_object('message','Workout complete','earnedXP',earned,'totalXP',total,'newLevel',new_level,'leveledUp',new_level>old_level,'isQuest',quest_match,'newTitle',CASE WHEN new_level>old_level THEN title END,'nextLevelXp',floor(100*power(new_level,1.5)),'isSuspicious',suspicious,'classResults',classes,'achievements',achievements,'streak',streak);
 INSERT INTO public.workout_rewards(workout_id,user_id,result) VALUES(w.id,uid,result);
 UPDATE public.workouts SET reward_result=result WHERE id=w.id;
 RETURN result;
END $$;
