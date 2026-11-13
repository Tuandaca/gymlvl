-- P10.3b Task 3 projection/readiness contract tests (run after migration).
BEGIN;
DO $$ BEGIN
 IF to_regprocedure('public.get_placement_state_v1()') IS NULL THEN RAISE EXCEPTION 'state RPC missing'; END IF;
 IF to_regprocedure('public.placement_global_threshold_v1(integer)') IS NULL THEN RAISE EXCEPTION 'global threshold helper missing'; END IF;
 IF NOT (SELECT relrowsecurity FROM pg_class WHERE oid='public.placement_workout_evidence'::regclass) THEN RAISE EXCEPTION 'evidence RLS disabled'; END IF;
 IF NOT has_function_privilege('authenticated','public.get_placement_state_v1()','EXECUTE') THEN RAISE EXCEPTION 'state RPC not executable'; END IF;
 IF has_table_privilege('authenticated','public.placement_workout_evidence','INSERT') THEN RAISE EXCEPTION 'client can insert evidence'; END IF;
 IF public.placement_global_threshold_v1(5)<>800 OR public.placement_global_threshold_v1(6)-public.placement_global_threshold_v1(5)<>318 THEN RAISE EXCEPTION 'threshold mismatch'; END IF;
END $$;
ROLLBACK;
