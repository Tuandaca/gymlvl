-- P10.4 RPG loop contract audit: authoritative reward path remains intact and
-- placement readiness is receipt-derived only.
BEGIN;
DO $$ BEGIN
 IF to_regprocedure('public.complete_workout(uuid,text)') IS NULL THEN RAISE EXCEPTION 'complete_workout RPC missing'; END IF;
 IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgrelid='public.workout_rewards'::regclass AND tgname='placement_workout_reward_evidence') THEN RAISE EXCEPTION 'placement receipt trigger missing'; END IF;
 IF has_table_privilege('authenticated','public.xp_logs','INSERT') THEN RAISE EXCEPTION 'client can insert XP ledger'; END IF;
 IF has_table_privilege('authenticated','public.workout_rewards','INSERT') THEN RAISE EXCEPTION 'client can forge reward receipt'; END IF;
 IF NOT has_function_privilege('authenticated','public.get_placement_state_v1()','EXECUTE') THEN RAISE EXCEPTION 'readiness state RPC unavailable'; END IF;
 IF has_function_privilege('authenticated','public.placement_record_workout_v1(uuid,uuid,jsonb)','EXECUTE') THEN RAISE EXCEPTION 'placement evidence writer exposed'; END IF;
END $$;
ROLLBACK;
