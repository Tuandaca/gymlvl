-- FND-DATA-001: prevent a duplicate award for legacy workouts that already carry
-- xp_logs evidence but no workout_rewards row and no is_xp_calculated flag.
--
-- Additive only. This migration re-creates complete_workout with one extra guard and
-- adds a supporting index. It does not delete, rewrite or backfill any xp_logs, users
-- or workout_rewards row, so existing valid XP and history are preserved.
--
-- The guard is evidence-based: an xp_logs row for this workout (source workout or
-- quest) means the session was already awarded. The function then returns the same
-- alreadyAwarded payload as the is_xp_calculated branch and writes nothing. A legacy
-- completed session with no ledger row still takes the normal award path.
--
-- Concurrency: complete_workout locks public.users FOR UPDATE before this check, so
-- calls for the same user serialize and a retry sees either the reward row or the
-- ledger row. Retries therefore remain idempotent.
--
-- Operator decision still open: materializing the missing workout_rewards row from
-- ledger evidence is a data repair and is intentionally not performed here. See
-- docs/audits/codebase-health/REMEDIATION_EXECUTION.md.

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

-- CREATE OR REPLACE keeps the existing ACL; restate it so a fresh database matches.
REVOKE ALL ON FUNCTION public.complete_workout(uuid,text) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.complete_workout(uuid,text) TO authenticated;

-- Supports the new guard and the existing switch_class ledger join without a scan.
CREATE INDEX IF NOT EXISTS idx_xp_logs_user_source ON public.xp_logs(user_id,source_id);
