-- D-053: synchronize only unlocks justified by server-owned evidence.
-- Backfill existing entitlements without XP/reward writes. Future inserts into
-- workout_rewards (only from complete_workout) trigger the same sync in the
-- completion transaction. Recovery: ship an additive correction, never delete
-- earned unlocks or replay rewards.

UPDATE public.unlock_definitions SET unlock_type='class'
WHERE id='badge_level_20' AND unlock_type='level';

DROP POLICY IF EXISTS "Users can insert own unlocks" ON public.user_unlocks;
REVOKE INSERT,UPDATE,DELETE,TRUNCATE ON public.user_unlocks
  FROM PUBLIC,anon,authenticated;

CREATE OR REPLACE FUNCTION public.sync_verified_unlocks_v1(p_user_id uuid)
RETURNS integer LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE inserted_count integer;
BEGIN
  IF p_user_id IS NULL THEN
    RAISE EXCEPTION 'Invalid user ID' USING ERRCODE='22023';
  END IF;
  INSERT INTO public.user_unlocks(user_id,unlock_id)
  SELECT p_user_id,d.id FROM public.unlock_definitions d
  JOIN public.users u ON u.id=p_user_id
  WHERE (d.id='badge_first_workout' AND EXISTS (
           SELECT 1 FROM public.user_achievements a
           WHERE a.user_id=p_user_id AND a.achievement_id='first_workout'))
     OR (d.id='badge_streak_3' AND EXISTS (
           SELECT 1 FROM public.user_achievements a
           WHERE a.user_id=p_user_id AND a.achievement_id='streak_3'))
     OR (d.id='badge_streak_7' AND EXISTS (
           SELECT 1 FROM public.user_achievements a
           WHERE a.user_id=p_user_id AND a.achievement_id='streak_7'))
     OR (d.id='title_level_10' AND u.level>=10)
     OR (d.id='title_level_20' AND u.level>=20)
     OR (d.id='badge_level_20' AND EXISTS (
           SELECT 1 FROM public.user_classes c
           WHERE c.user_id=p_user_id AND c.is_graduated AND c.level=20))
  ON CONFLICT(user_id,unlock_id) DO NOTHING;
  GET DIAGNOSTICS inserted_count=ROW_COUNT;
  RETURN inserted_count;
END $$;
REVOKE ALL ON FUNCTION public.sync_verified_unlocks_v1(uuid)
  FROM PUBLIC,anon,authenticated;

CREATE OR REPLACE FUNCTION public.reward_unlock_sync_v1()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
BEGIN
  PERFORM public.sync_verified_unlocks_v1(NEW.user_id);
  RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION public.reward_unlock_sync_v1()
  FROM PUBLIC,anon,authenticated;

CREATE TRIGGER p9_reward_unlocks_after_insert
AFTER INSERT ON public.workout_rewards FOR EACH ROW
EXECUTE FUNCTION public.reward_unlock_sync_v1();

DO $$ DECLARE existing_user record;
BEGIN
  FOR existing_user IN SELECT id FROM public.users LOOP
    PERFORM public.sync_verified_unlocks_v1(existing_user.id);
  END LOOP;
END $$;
