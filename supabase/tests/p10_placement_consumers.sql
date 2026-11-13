-- Consumer projection contract: readiness remains separate from earned progression.
BEGIN;
DO $$ DECLARE j jsonb; BEGIN
  IF public.placement_global_threshold_v1(6)-public.placement_global_threshold_v1(5) <> 318 THEN RAISE EXCEPTION 'floor 5 delta mismatch'; END IF;
  j:=jsonb_build_object('readinessGlobalLevel',10,'readinessClassLevel',5,'level',1,'current_title','Tân Binh');
  IF (j->>'level')::int=10 OR j->>'current_title' IS DISTINCT FROM 'Tân Binh' THEN RAISE EXCEPTION 'readiness replaced earned fields'; END IF;
END $$;
ROLLBACK;
