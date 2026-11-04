-- Disposable local/test database only. All rows roll back.
BEGIN;
CREATE TEMP TABLE m3_context (key text PRIMARY KEY, value jsonb);
GRANT ALL ON m3_context TO authenticated;
CREATE FUNCTION pg_temp.m3_assert(ok boolean, label text) RETURNS void
LANGUAGE plpgsql AS $$ BEGIN
  IF ok IS DISTINCT FROM true THEN RAISE EXCEPTION 'FAIL: %', label; END IF;
END $$;
CREATE FUNCTION pg_temp.m3_denied(statement text, expected text) RETURNS void
LANGUAGE plpgsql AS $$ BEGIN
  BEGIN
    EXECUTE statement;
  EXCEPTION WHEN OTHERS THEN
    IF SQLSTATE = expected THEN RETURN; END IF;
    RAISE;
  END;
  RAISE EXCEPTION 'FAIL: expected %', expected;
END $$;

INSERT INTO auth.users (id, email, raw_user_meta_data) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'm3-owner@example.test', '{}'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'm3-other@example.test', '{}');
INSERT INTO public.workouts (id, user_id, status) VALUES
  ('cccccccc-cccc-cccc-cccc-cccccccccccc',
   'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'active');
SELECT set_config('request.jwt.claim.sub',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', true);
SELECT set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa","role":"authenticated"}', true);
INSERT INTO public.workout_exercises (id, workout_id, exercise_id)
  SELECT 'dddddddd-dddd-dddd-dddd-dddddddddddd',
    'cccccccc-cccc-cccc-cccc-cccccccccccc', id
  FROM public.exercises ORDER BY id LIMIT 1;
SELECT pg_temp.m3_assert(
  (SELECT superset_group_id IS NULL FROM public.workout_exercises
   WHERE id = 'dddddddd-dddd-dddd-dddd-dddddddddddd'),
  'legacy exercise remains ungrouped'
);
SELECT pg_temp.m3_assert(
  NOT has_table_privilege('authenticated',
    'public.workout_write_operations', 'SELECT,INSERT,UPDATE,DELETE')
  AND NOT has_table_privilege('anon',
    'public.workout_write_operations', 'SELECT,INSERT,UPDATE,DELETE'),
  'ledger has no direct client table privileges'
);
SET LOCAL ROLE anon;
SELECT pg_temp.m3_denied(
  $q$SELECT public.apply_workout_set_create_v1(
    'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
    'cccccccc-cccc-cccc-cccc-cccccccccccc', '{}'::jsonb)$q$,
  '42501'
);
RESET ROLE;

SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', true);
SELECT set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa","role":"authenticated"}', true);
SELECT pg_temp.m3_denied(
  $q$UPDATE public.workout_exercises
    SET superset_group_id = '99999999-9999-9999-9999-999999999999'
    WHERE id = 'dddddddd-dddd-dddd-dddd-dddddddddddd'$q$,
  '42501'
);
SELECT pg_temp.m3_denied(
  $q$INSERT INTO public.workout_exercises (
    id, workout_id, exercise_id, superset_group_id)
    SELECT '13131313-1313-1313-1313-131313131313',
      'cccccccc-cccc-cccc-cccc-cccccccccccc', exercise_id,
      '99999999-9999-9999-9999-999999999999'
    FROM public.workout_exercises
    WHERE id = 'dddddddd-dddd-dddd-dddd-dddddddddddd'$q$,
  '42501'
);
INSERT INTO m3_context VALUES (
  'first', public.apply_workout_set_create_v1(
    'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    '{"workout_exercise_id":"dddddddd-dddd-dddd-dddd-dddddddddddd", "set_number":1,"reps":10,"weight_kg":20,"duration_seconds":0,"rest_seconds":60,"is_completed":true}'
  )
);
SELECT pg_temp.m3_assert(
  public.apply_workout_set_create_v1(
    'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    '{"is_completed":true,"rest_seconds":60,"duration_seconds":0,"weight_kg":20.0,"reps":10,"set_number":1,"workout_exercise_id":"DDDDDDDD-DDDD-DDDD-DDDD-DDDDDDDDDDDD"}'
  ) = (SELECT value FROM m3_context WHERE key = 'first'),
  'key order, numeric scale, and UUID case canonicalize to one response'
);
RESET ROLE;
SELECT pg_temp.m3_assert(
  (SELECT count(*) = 1 FROM public.workout_sets
    WHERE workout_exercise_id = 'dddddddd-dddd-dddd-dddd-dddddddddddd')
  AND (SELECT count(*) = 1 FROM public.workout_write_operations)
  AND (SELECT length(request_fingerprint) = 64
       AND request_fingerprint =
         encode(sha256(convert_to(request_body::text, 'UTF8')), 'hex')
       FROM public.workout_write_operations),
  'duplicate delivery creates one set and one verified fingerprint'
);
CREATE FUNCTION pg_temp.m3_reject_ledger() RETURNS trigger
LANGUAGE plpgsql AS $$ BEGIN
  RAISE EXCEPTION 'synthetic ledger failure' USING ERRCODE = '23514';
END $$;
CREATE TRIGGER m3_reject_ledger_before_insert
  BEFORE INSERT ON public.workout_write_operations
  FOR EACH ROW EXECUTE FUNCTION pg_temp.m3_reject_ledger();
SET LOCAL ROLE authenticated;
SELECT pg_temp.m3_denied(
  $q$SELECT public.apply_workout_set_create_v1(
    '14141414-1414-1414-1414-141414141414',
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    '{"workout_exercise_id":"dddddddd-dddd-dddd-dddd-dddddddddddd","set_number":2,"reps":10,"weight_kg":20,"duration_seconds":0,"rest_seconds":60,"is_completed":true}')$q$,
  '23514'
);
RESET ROLE;
DROP TRIGGER m3_reject_ledger_before_insert
  ON public.workout_write_operations;
SELECT pg_temp.m3_assert(
  (SELECT count(*) = 1 FROM public.workout_sets
   WHERE workout_exercise_id = 'dddddddd-dddd-dddd-dddd-dddddddddddd')
  AND (SELECT count(*) = 1 FROM public.workout_write_operations),
  'ledger failure rolls back the business mutation'
);
SET LOCAL ROLE authenticated;
SELECT pg_temp.m3_denied(
  $q$SELECT public.apply_workout_set_create_v1(
    'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    '{"workout_exercise_id":"dddddddd-dddd-dddd-dddd-dddddddddddd","set_number":1,"reps":11,"weight_kg":20,"duration_seconds":0,"rest_seconds":60,"is_completed":true}')$q$,
  '23505'
);
SELECT pg_temp.m3_denied(
  $q$SELECT public.apply_workout_set_create_v1(
    'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
    '12121212-1212-1212-1212-121212121212',
    '{"workout_exercise_id":"dddddddd-dddd-dddd-dddd-dddddddddddd","set_number":1,"reps":10,"weight_kg":20,"duration_seconds":0,"rest_seconds":60,"is_completed":true}')$q$,
  '23505'
);
SELECT pg_temp.m3_denied(
  $q$SELECT public.apply_workout_set_create_v1(
    'ffffffff-ffff-ffff-ffff-ffffffffffff',
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    '{"workout_exercise_id":"dddddddd-dddd-dddd-dddd-dddddddddddd","set_number":1,"reps":0,"weight_kg":20,"duration_seconds":0,"rest_seconds":60,"is_completed":true}')$q$,
  '23514'
);
SELECT pg_temp.m3_denied(
  $q$SELECT public.apply_workout_set_create_v1(
    'ffffffff-ffff-ffff-ffff-ffffffffffff',
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    '{"workout_exercise_id":"dddddddd-dddd-dddd-dddd-dddddddddddd","set_number":1,"reps":10,"weight_kg":20,"duration_seconds":0,"rest_seconds":60,"is_completed":true,"extra":1}')$q$,
  '22023'
);
SELECT pg_temp.m3_denied(
  $q$SELECT * FROM public.workout_write_operations$q$, '42501');
SELECT set_config('request.jwt.claim.sub',
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', true);
SELECT set_config('request.jwt.claims',
  '{"sub":"bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb","role":"authenticated"}', true);
SELECT pg_temp.m3_denied(
  $q$SELECT public.apply_workout_set_create_v1(
    'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    '{"workout_exercise_id":"dddddddd-dddd-dddd-dddd-dddddddddddd","set_number":1,"reps":10,"weight_kg":20,"duration_seconds":0,"rest_seconds":60,"is_completed":true}')$q$,
  '42501'
);
RESET ROLE;
UPDATE public.workouts SET training_started_at = now() - interval '10 minutes'
  WHERE id = 'cccccccc-cccc-cccc-cccc-cccccccccccc';
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub',
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', true);
SELECT set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa","role":"authenticated"}', true);
INSERT INTO m3_context VALUES (
  'reward', public.complete_workout(
    'cccccccc-cccc-cccc-cccc-cccccccccccc'
  )
);
SELECT pg_temp.m3_assert(
  public.complete_workout('cccccccc-cccc-cccc-cccc-cccccccccccc') =
    (SELECT value FROM m3_context WHERE key = 'reward'),
  'completion retry returns one original reward'
);
SELECT pg_temp.m3_assert(
  public.apply_workout_set_create_v1(
    'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    '{"workout_exercise_id":"dddddddd-dddd-dddd-dddd-dddddddddddd","set_number":1,"reps":10,"weight_kg":20,"duration_seconds":0,"rest_seconds":60,"is_completed":true}'
  ) = (SELECT value FROM m3_context WHERE key = 'first'),
  'lost acknowledgement can replay after completion'
);
SELECT pg_temp.m3_denied(
  $q$SELECT public.apply_workout_set_create_v1(
    'ffffffff-ffff-ffff-ffff-ffffffffffff',
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    '{"workout_exercise_id":"dddddddd-dddd-dddd-dddd-dddddddddddd","set_number":2,"reps":10,"weight_kg":20,"duration_seconds":0,"rest_seconds":60,"is_completed":true}')$q$,
  '42501'
);
RESET ROLE;
SELECT pg_temp.m3_assert(
  (SELECT count(*) = 1 FROM public.workout_sets
   WHERE workout_exercise_id = 'dddddddd-dddd-dddd-dddd-dddddddddddd')
  AND (SELECT count(*) = 1 FROM public.workout_write_operations)
  AND (SELECT count(*) = 1 FROM public.workout_rewards
       WHERE workout_id = 'cccccccc-cccc-cccc-cccc-cccccccccccc')
  AND (SELECT count(*) = 1 FROM public.xp_logs
       WHERE source IN ('workout','quest')
         AND source_id = 'cccccccc-cccc-cccc-cccc-cccccccccccc'),
  'write replay and completion retry do not duplicate sets or rewards'
);
ROLLBACK;
