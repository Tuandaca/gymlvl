-- P9 exercise ownership contract. Disposable database only; all fixtures roll back.
BEGIN;

CREATE FUNCTION pg_temp.p9_expect(ok boolean, label text) RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
  IF ok IS DISTINCT FROM true THEN
    PERFORM set_config('p9.failures', current_setting('p9.failures') || ' [' || label || ']', true);
    RAISE NOTICE 'P9 RED: %', label;
  END IF;
END $$;
SELECT set_config('p9.failures', '', true);

INSERT INTO auth.users(id, email) VALUES
  ('90000000-0000-4000-8000-000000000001', 'p9-owner-a@example.test'),
  ('90000000-0000-4000-8000-000000000002', 'p9-owner-b@example.test');
-- Simulate a malformed administrator/import row. It must never enter catalogue reads.
INSERT INTO public.exercises(id, name, slug, category, equipment, source, user_id) VALUES
  ('90000000-0000-4000-8000-000000000099', '! P9 orphan custom', 'p9-orphan', 'Arms', 'Dumbbell', 'user', NULL);

-- The daily quest must consider all exercises so the deliberately first-sorted
-- custom rows exercise the SECURITY DEFINER selector, not a random category.
UPDATE public.quests SET category = 'full_body' WHERE type = 'daily_routine';

SELECT set_config('request.jwt.claim.sub', '90000000-0000-4000-8000-000000000001', true);
SELECT set_config('request.jwt.claims', '{"sub":"90000000-0000-4000-8000-000000000001","role":"authenticated"}', true);
SET ROLE authenticated;
SELECT public.initialize_user('{"environment":"gym","goals":["hypertrophy"],"experience_level":"beginner","age":25,"gender":"other","height_cm":170,"weight_kg":65,"preferred_training_days":["mon","wed","fri"],"primary_class_id":"B"}'::jsonb);
INSERT INTO public.exercises(id, name, slug, category, equipment, source, user_id, is_archived) VALUES
  ('90000000-0000-4000-8000-000000000011', '!! P9 archived', 'p9-archived', 'Arms', 'Dumbbell', 'user', '90000000-0000-4000-8000-000000000001', true),
  ('90000000-0000-4000-8000-000000000012', '!!! P9 referenced', 'p9-referenced', 'Arms', 'Dumbbell', 'user', '90000000-0000-4000-8000-000000000001', false);

SELECT set_config('request.jwt.claim.sub', '90000000-0000-4000-8000-000000000002', true);
SELECT set_config('request.jwt.claims', '{"sub":"90000000-0000-4000-8000-000000000002","role":"authenticated"}', true);
SELECT public.initialize_user('{"environment":"gym","goals":["hypertrophy"],"experience_level":"beginner","age":25,"gender":"other","height_cm":170,"weight_kg":65,"preferred_training_days":["mon","wed","fri"],"primary_class_id":"B"}'::jsonb);
INSERT INTO public.exercises(id, name, slug, category, equipment, source, user_id, is_archived) VALUES
  ('90000000-0000-4000-8000-000000000021', '! P9 foreign', 'p9-foreign', 'Arms', 'Dumbbell', 'user', '90000000-0000-4000-8000-000000000002', false);
DO $$
DECLARE denied boolean := false;
BEGIN
  BEGIN
    INSERT INTO public.exercises(id, name, slug, category, equipment, source, user_id) VALUES
      ('90000000-0000-4000-8000-000000000022', 'zz P9 forged owner', 'p9-forged-owner', 'Arms', 'Dumbbell', 'user', '90000000-0000-4000-8000-000000000001');
  EXCEPTION WHEN insufficient_privilege THEN
    denied := true;
  END;
  PERFORM pg_temp.p9_expect(denied, 'custom INSERT cannot claim another owner');
  denied := false;
  BEGIN
    INSERT INTO public.exercises(id, name, slug, category, equipment, source, user_id) VALUES
      ('90000000-0000-4000-8000-000000000023', 'zz P9 missing owner', 'p9-missing-owner', 'Arms', 'Dumbbell', 'user', NULL);
  EXCEPTION WHEN insufficient_privilege THEN
    denied := true;
  END;
  PERFORM pg_temp.p9_expect(denied, 'custom INSERT requires authenticated owner');
END $$;
CREATE TEMP TABLE p9_other_workout(id uuid) ON COMMIT DROP;
INSERT INTO p9_other_workout(id) SELECT (public.start_workout()->>'id')::uuid;
INSERT INTO public.workout_exercises(workout_id, exercise_id)
SELECT id, '90000000-0000-4000-8000-000000000021'::uuid FROM p9_other_workout;
-- A guessed UUID must not let B attach A's private exercise to B's workout.
DO $$
DECLARE foreign_inserted boolean := false;
BEGIN
  BEGIN
    INSERT INTO public.workout_exercises(workout_id, exercise_id)
    SELECT id, '90000000-0000-4000-8000-000000000012'::uuid FROM p9_other_workout;
    foreign_inserted := true;
  EXCEPTION WHEN foreign_key_violation OR insufficient_privilege THEN
    NULL;
  END;
  PERFORM pg_temp.p9_expect(NOT foreign_inserted,
    'workout rejects another owner custom exercise UUID');
END $$;

SELECT set_config('request.jwt.claim.sub', '90000000-0000-4000-8000-000000000001', true);
SELECT set_config('request.jwt.claims', '{"sub":"90000000-0000-4000-8000-000000000001","role":"authenticated"}', true);

-- An existing catalogue_read policy must not make another user's custom row visible.
SELECT pg_temp.p9_expect(
  (SELECT count(*) = 0 FROM public.exercises WHERE id = '90000000-0000-4000-8000-000000000021'),
  'authenticated SELECT hides foreign custom exercise');
SELECT pg_temp.p9_expect(
  (SELECT count(*) = 1 FROM public.exercises WHERE id = '90000000-0000-4000-8000-000000000011'),
  'owner can read archived custom exercise for history');
SELECT pg_temp.p9_expect(
  (SELECT count(*) = 0 FROM public.exercises WHERE id = '90000000-0000-4000-8000-000000000099'),
  'source user with null owner is not catalogue-visible');

-- SECURITY DEFINER bypasses caller RLS; it must filter the same owner/archive rule.
SELECT pg_temp.p9_expect(
  NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements(public.sync_daily_data()->'quest'->'prescribed_config') item
    WHERE item->>'exercise_id' IN (
      '90000000-0000-4000-8000-000000000011',
      '90000000-0000-4000-8000-000000000021'
    )
  ),
  'daily quest excludes archived and foreign custom exercises');

-- An owner may archive a used custom exercise, but cannot erase workout history.
CREATE TEMP TABLE p9_workout(id uuid) ON COMMIT DROP;
INSERT INTO p9_workout(id) SELECT (public.start_workout()->>'id')::uuid;
INSERT INTO public.workout_exercises(workout_id, exercise_id)
SELECT id, '90000000-0000-4000-8000-000000000012'::uuid FROM p9_workout;
DO $$
BEGIN
  DELETE FROM public.exercises WHERE id = '90000000-0000-4000-8000-000000000012';
EXCEPTION WHEN foreign_key_violation OR insufficient_privilege THEN
  NULL; -- Rejection preserves the referenced row and history.
END $$;
SELECT pg_temp.p9_expect(
  (SELECT count(*) = 1 FROM public.workout_exercises
   WHERE exercise_id = '90000000-0000-4000-8000-000000000012'),
  'authenticated DELETE cannot erase referenced workout history');
UPDATE public.exercises SET is_archived = true
WHERE id = '90000000-0000-4000-8000-000000000012';
SELECT pg_temp.p9_expect(
  (SELECT count(*) = 1 FROM public.workout_exercises
   WHERE exercise_id = '90000000-0000-4000-8000-000000000012'),
  'archiving own custom exercise preserves workout history');

-- Anonymous callers must not read catalogue or custom rows.
SELECT set_config('request.jwt.claim.sub', '', true);
SELECT set_config('request.jwt.claims', '', true);
SET ROLE anon;
DO $$
DECLARE denied boolean := false;
BEGIN
  BEGIN
    PERFORM 1 FROM public.exercises LIMIT 1;
  EXCEPTION WHEN insufficient_privilege THEN
    denied := true;
  END;
  PERFORM pg_temp.p9_expect(denied, 'anonymous exercise SELECT denied');
  denied := false;
  BEGIN
    INSERT INTO public.exercises(id, name, slug, category, equipment, source, user_id) VALUES
      ('90000000-0000-4000-8000-000000000024', 'zz P9 anonymous', 'p9-anonymous', 'Arms', 'Dumbbell', 'user', NULL);
  EXCEPTION WHEN insufficient_privilege THEN
    denied := true;
  END;
  PERFORM pg_temp.p9_expect(denied, 'anonymous custom INSERT denied');
END $$;

-- The server-side account purge may remove A's rows but must preserve B's.
SELECT set_config('request.jwt.claim.sub', '90000000-0000-4000-8000-000000000001', true);
SELECT set_config('request.jwt.claims', '{"sub":"90000000-0000-4000-8000-000000000001","role":"authenticated"}', true);
SET ROLE authenticated;
DO $$
DECLARE purged boolean := true;
BEGIN
  BEGIN
    PERFORM public.delete_account_data();
  EXCEPTION WHEN insufficient_privilege THEN
    purged := false;
  END;
  PERFORM pg_temp.p9_expect(purged,
    'account purge succeeds despite another owner guessing a private exercise UUID');
END $$;

RESET ROLE;
SELECT pg_temp.p9_expect(
  (SELECT count(*) = 0 FROM public.exercises
   WHERE user_id = '90000000-0000-4000-8000-000000000001'),
  'account purge removes only the deleted owner custom exercises');
SELECT pg_temp.p9_expect(
  (SELECT count(*) = 1 FROM public.exercises
   WHERE id = '90000000-0000-4000-8000-000000000021'),
  'account purge preserves other owner custom exercise');
SELECT pg_temp.p9_expect(
  (SELECT count(*) = 1 FROM public.workout_exercises
   WHERE exercise_id = '90000000-0000-4000-8000-000000000021'),
  'account purge preserves other owner workout history');
DO $$
BEGIN
  IF current_setting('p9.failures') <> '' THEN
    RAISE EXCEPTION 'P9 exercise contract failures:%', current_setting('p9.failures');
  END IF;
END $$;
ROLLBACK;
