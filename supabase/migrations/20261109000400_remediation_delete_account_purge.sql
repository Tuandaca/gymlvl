-- Remediation: complete the account-deletion purge surface.
--
-- Context / production divergence note:
--   20261109000200_p8_delete_account.sql created delete_account_data(). It relies
--   on ON DELETE CASCADE from public.users for most child tables, which is correct,
--   but it missed public.workout_write_operations: that ledger intentionally has no
--   foreign key (it must survive independently of a workout row), so its rows are
--   NOT cascaded and would survive account deletion as orphaned user data.
--
-- This migration is additive: it only replaces the function body. Signature and
-- grants are unchanged. No table, column, policy or grant is modified.
--
-- Rollback / recovery: re-apply 20261109000200_p8_delete_account.sql to return to
-- the previous body. No data migration is required in either direction.

CREATE OR REPLACE FUNCTION public.delete_account_data() RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE uid uuid := auth.uid();
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE = '42501';
  END IF;

  -- The idempotency ledger has no foreign key to users or workouts by design.
  -- Purge it explicitly so no orphaned request bodies survive deletion.
  DELETE FROM public.workout_write_operations WHERE user_id = uid;

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

  -- planned_workouts.routine_id is ON DELETE RESTRICT, so occurrences must go
  -- before their routines.
  DELETE FROM public.planned_workouts WHERE user_id = uid;
  DELETE FROM public.routine_schedules
  WHERE routine_id IN (SELECT id FROM public.routines WHERE user_id = uid);
  DELETE FROM public.routines WHERE user_id = uid;

  -- Explicit deletes here are equivalent to the ON DELETE CASCADE path but keep
  -- the purge readable and independent of future FK changes.
  DELETE FROM public.body_measurements WHERE user_id = uid;
  DELETE FROM public.bodyweight_measurements WHERE user_id = uid;
  DELETE FROM public.exercise_favourites WHERE user_id = uid;
  DELETE FROM public.exercise_aliases WHERE user_id = uid;
  DELETE FROM public.import_records WHERE user_id = uid;

  DELETE FROM public.xp_logs WHERE user_id = uid;
  DELETE FROM public.streaks WHERE user_id = uid;
  DELETE FROM public.exercise_prs WHERE user_id = uid;
  DELETE FROM public.quest_instances WHERE user_id = uid;
  DELETE FROM public.user_classes WHERE user_id = uid;
  DELETE FROM public.workout_rewards WHERE user_id = uid;
  DELETE FROM public.user_achievements WHERE user_id = uid;
  DELETE FROM public.user_unlocks WHERE user_id = uid;
  DELETE FROM public.coach_daily_usage WHERE user_id = uid;

  -- Custom exercises are owned by the user; curated catalogue rows (user_id NULL)
  -- are never touched.
  DELETE FROM public.exercises WHERE user_id = uid;

  DELETE FROM public.users WHERE id = uid;

  RETURN jsonb_build_object(
    'message', 'Account data deleted',
    'user_id', uid,
    'deleted_at', clock_timestamp()
  );
END $$;

REVOKE ALL ON FUNCTION public.delete_account_data() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.delete_account_data() TO authenticated;
