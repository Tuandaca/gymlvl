-- P8 Release Hardening: account deletion support.
--
-- Adds a server-side function delete_account_data() that removes all
-- user-owned GymLvl data for the authenticated caller. Intended to be
-- invoked by the delete-account Edge Function before the auth user record
-- is removed. Does NOT delete the auth.users row itself (that requires
-- service_role privileges and is performed by the Edge Function).
--
-- Additive only: creates a new function, grants EXECUTE to authenticated,
-- and establishes owner-scoped RLS (the function runs SECURITY DEFINER but
-- only the authenticated caller's own data is ever deleted).
--
-- No existing tables, columns, policies, or grants are modified.
-- No production deployment is authorized by this migration.

CREATE OR REPLACE FUNCTION public.delete_account_data() RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE uid uuid := auth.uid();
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;

  -- Mark all user workouts active so the workout-child guard (which rejects
  -- writes to sets/exercises on completed workouts) does not block deletion.
  UPDATE public.workouts SET status = 'active' WHERE user_id = uid;

  -- Delete child rows first, then parents, working outward from the user.
  DELETE FROM public.workout_sets
  WHERE workout_exercise_id IN (
    SELECT we.id FROM public.workout_exercises we
    JOIN public.workouts w ON w.id = we.workout_id
    WHERE w.user_id = uid
  );

  DELETE FROM public.workout_exercises
  WHERE workout_id IN (SELECT id FROM public.workouts WHERE user_id = uid);

  DELETE FROM public.workouts WHERE user_id = uid;

  DELETE FROM public.planned_workouts WHERE user_id = uid;

  DELETE FROM public.routines WHERE user_id = uid;

  DELETE FROM public.routine_schedules
  WHERE routine_id IN (SELECT id FROM public.routines WHERE user_id = uid);

  DELETE FROM public.body_measurements WHERE user_id = uid;

  DELETE FROM public.xp_logs WHERE user_id = uid;
  DELETE FROM public.streaks WHERE user_id = uid;
  DELETE FROM public.exercise_prs WHERE user_id = uid;
  DELETE FROM public.quest_instances WHERE user_id = uid;
  DELETE FROM public.user_classes WHERE user_id = uid;
  DELETE FROM public.workout_rewards WHERE user_id = uid;
  DELETE FROM public.user_achievements WHERE user_id = uid;
  DELETE FROM public.coach_daily_usage WHERE user_id = uid;

  DELETE FROM public.users WHERE id = uid;

  RETURN jsonb_build_object(
    'message', 'Account data deleted',
    'user_id', uid,
    'deleted_at', clock_timestamp()
  );
END $$;

REVOKE ALL ON FUNCTION public.delete_account_data() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.delete_account_data() TO authenticated;
