-- P10.3b Task 5 privileged pilot report (read-only query).
-- Execute only from an owner/privileged reporting connection. This file defines
-- no function, grant, or authenticated entry point and performs no writes.
WITH enrolled AS (
  SELECT DISTINCT a.user_id
  FROM public.placement_assessments a
  JOIN public.users u ON u.id = a.user_id
  WHERE a.is_initial_enrollment
    AND u.onboarding_completed
), attempts AS (
  SELECT a.policy_version, a.assessed_class_id AS class_id, a.status,
         a.recommended_plan_route, a.age_snapshot, a.body_mass_kg_snapshot,
         a.user_id
  FROM public.placement_assessments a
  JOIN enrolled e ON e.user_id = a.user_id
), grouped AS (
  SELECT policy_version, class_id, status,
         count(*)::bigint AS attempt_count,
         count(DISTINCT user_id)::bigint AS account_count,
         count(*) FILTER (WHERE recommended_plan_route IS NULL)::bigint AS route_missing,
         count(*) FILTER (WHERE age_snapshot IS NULL OR body_mass_kg_snapshot IS NULL)::bigint AS snapshot_missing
  FROM attempts
  GROUP BY policy_version, class_id, status
)
SELECT policy_version, class_id, status,
       CASE WHEN account_count < 20 THEN 'insufficient_sample' ELSE account_count::text END AS accounts,
       CASE WHEN attempt_count < 20 THEN 'insufficient_sample' ELSE attempt_count::text END AS attempts,
       CASE WHEN account_count < 20 THEN 'insufficient_sample' ELSE route_missing::text END AS route_missing,
       CASE WHEN account_count < 20 THEN 'insufficient_sample' ELSE snapshot_missing::text END AS snapshot_missing
FROM grouped
ORDER BY policy_version, class_id, status;
