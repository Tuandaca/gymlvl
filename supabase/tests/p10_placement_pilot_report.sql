-- P10.3b Task 5: isolated pilot-report contract fixture.
-- This is a privileged/report-side query shape test only; it creates no RPC and
-- grants no authenticated access. Synthetic rows model the owner-scoped ledger.
BEGIN;

CREATE TEMP TABLE pilot_attempts (
  user_id uuid NOT NULL,
  onboarding_completed boolean NOT NULL,
  supplied_envelope boolean NOT NULL,
  attempt_no integer NOT NULL,
  policy_version text NOT NULL,
  class_id text NOT NULL,
  status text NOT NULL,
  recommended_plan_route text,
  age_snapshot integer,
  body_mass_snapshot numeric
);

INSERT INTO pilot_attempts VALUES
  ('a0000000-0000-4000-8000-000000000001', true, true, 1, 'placement-v0.1', 'B', 'confirmed', 'routine_selection', 28, 80),
  ('a0000000-0000-4000-8000-000000000001', true, true, 2, 'placement-v0.1', 'B', 'superseded', 'routine_selection', 28, 80),
  ('a0000000-0000-4000-8000-000000000002', true, true, 1, 'placement-v0.1', 'A', 'skipped', 'beginner_first_week', 22, 65),
  ('a0000000-0000-4000-8000-000000000003', true, true, 1, 'placement-v0.1', 'F', 'ineligible', NULL, NULL, NULL),
  ('a0000000-0000-4000-8000-000000000004', true, false, 1, 'placement-v0.1', 'C', 'confirmed', 'none', 31, 90),
  ('a0000000-0000-4000-8000-000000000005', false, true, 1, 'placement-v0.1', 'D', 'confirmed', 'routine_selection', 35, 75);

DO $$
DECLARE enrolled integer; attempts integer; route_count integer; suppressed text; missing integer;
BEGIN
  -- Offer denominator: completed onboarding plus placement envelope, by account.
  SELECT count(DISTINCT user_id) INTO enrolled
  FROM pilot_attempts WHERE onboarding_completed AND supplied_envelope;
  IF enrolled <> 3 THEN RAISE EXCEPTION 'completed-onboarding denominator mismatch: %', enrolled; END IF;

  -- Attempts remain a separate denominator; retries do not inflate enrolled accounts.
  SELECT count(*) INTO attempts
  FROM pilot_attempts WHERE onboarding_completed AND supplied_envelope;
  IF attempts <> 4 THEN RAISE EXCEPTION 'attempt denominator mismatch: %', attempts; END IF;

  SELECT count(*) INTO route_count
  FROM pilot_attempts
  WHERE onboarding_completed AND supplied_envelope AND recommended_plan_route IS NOT NULL;
  IF route_count <> 3 THEN RAISE EXCEPTION 'route missingness mismatch: %', route_count; END IF;

  -- Small-cell rule: subgroup counts/rates are suppressed below 20.
  SELECT CASE WHEN count(*) < 20 THEN 'insufficient_sample' ELSE count(*)::text END INTO suppressed
  FROM pilot_attempts WHERE onboarding_completed AND supplied_envelope AND status='confirmed';
  IF suppressed <> 'insufficient_sample' THEN RAISE EXCEPTION 'small-cell suppression failed: %', suppressed; END IF;

  SELECT count(*) INTO missing
  FROM pilot_attempts
  WHERE onboarding_completed AND supplied_envelope AND (recommended_plan_route IS NULL OR age_snapshot IS NULL OR body_mass_snapshot IS NULL);
  IF missing <> 1 THEN RAISE EXCEPTION 'missingness report mismatch: %', missing; END IF;

  -- The fixture intentionally contains no gender/biological-sex field or analysis.
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pilot_attempts' AND column_name IN ('gender','biological_sex'))
    THEN RAISE EXCEPTION 'unauthorized demographic field present';
  END IF;
END $$;

ROLLBACK;
