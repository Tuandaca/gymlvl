BEGIN;
CREATE FUNCTION pg_temp.assert_true(ok boolean, label text) RETURNS void
LANGUAGE plpgsql AS $$ BEGIN
  IF ok IS DISTINCT FROM true THEN RAISE EXCEPTION 'FAIL: %', label; END IF;
END $$;
CREATE FUNCTION pg_temp.expect_denied(command text, label text) RETURNS void
LANGUAGE plpgsql AS $$ BEGIN
  EXECUTE command;
  RAISE EXCEPTION 'FAIL: %', label;
EXCEPTION WHEN insufficient_privilege THEN NULL;
END $$;

INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES
  ('a9000000-0000-4000-8000-000000000041','p9-unlock-a@example.test','{}'),
  ('a9000000-0000-4000-8000-000000000042','p9-unlock-b@example.test','{}');
SELECT set_config('request.jwt.claim.sub','a9000000-0000-4000-8000-000000000041',true);
SELECT set_config('request.jwt.claims','{"sub":"a9000000-0000-4000-8000-000000000041","role":"authenticated"}',true);
SET LOCAL ROLE authenticated;
SELECT public.initialize_user('{"environment":"home","goals":["hypertrophy"],"experience_level":"beginner","age":25,"gender":"other","height_cm":170,"weight_kg":65,"weekly_gym_days":0,"weekly_home_days":3,"preferred_training_days":["mon","wed","fri"],"primary_class_id":"A"}');
RESET ROLE;
SELECT set_config('request.jwt.claim.sub','a9000000-0000-4000-8000-000000000042',true);
SELECT set_config('request.jwt.claims','{"sub":"a9000000-0000-4000-8000-000000000042","role":"authenticated"}',true);
SET LOCAL ROLE authenticated;
SELECT public.initialize_user('{"environment":"home","goals":["hypertrophy"],"experience_level":"beginner","age":25,"gender":"other","height_cm":170,"weight_kg":65,"weekly_gym_days":0,"weekly_home_days":3,"preferred_training_days":["mon","wed","fri"],"primary_class_id":"A"}');
RESET ROLE;

-- Verified historical evidence can grant a missing unlock without replaying XP.
UPDATE public.users SET level=10,total_xp=1000 WHERE id='a9000000-0000-4000-8000-000000000041';
INSERT INTO public.user_achievements(user_id,achievement_id)
VALUES ('a9000000-0000-4000-8000-000000000041','first_workout');
SELECT pg_temp.assert_true(public.sync_verified_unlocks_v1('a9000000-0000-4000-8000-000000000041')=2,
  'verified backfill grants first-workout badge and level-10 title');
SELECT pg_temp.assert_true(public.sync_verified_unlocks_v1('a9000000-0000-4000-8000-000000000041')=0,
  'unlock sync is idempotent');
SELECT pg_temp.assert_true((SELECT total_xp=1000 FROM public.users
  WHERE id='a9000000-0000-4000-8000-000000000041'),
  'unlock sync never writes XP');
SELECT pg_temp.assert_true((SELECT count(*)=0 FROM public.user_unlocks
  WHERE user_id='a9000000-0000-4000-8000-000000000042'),
  'other user receives no unlock');
SELECT pg_temp.assert_true(NOT has_function_privilege('authenticated',
  'public.sync_verified_unlocks_v1(uuid)','EXECUTE'),
  'client cannot invoke server-only unlock sync');

SET LOCAL ROLE authenticated;
SELECT pg_temp.expect_denied(
  $q$INSERT INTO public.user_unlocks(user_id,unlock_id) VALUES
  ('a9000000-0000-4000-8000-000000000041','title_level_20')$q$,
  'client cannot forge a level-20 unlock');
SELECT pg_temp.assert_true((SELECT count(*)=0 FROM public.user_unlocks
  WHERE user_id='a9000000-0000-4000-8000-000000000041'),
  'other account cannot read owner unlocks');
SELECT set_config('request.jwt.claim.sub','a9000000-0000-4000-8000-000000000041',true);
SELECT set_config('request.jwt.claims','{"sub":"a9000000-0000-4000-8000-000000000041","role":"authenticated"}',true);
SELECT pg_temp.assert_true((SELECT count(*)=2 FROM public.user_unlocks
  WHERE user_id='a9000000-0000-4000-8000-000000000041'),
  'owner can read only the two verified unlocks');
RESET ROLE;
ROLLBACK;
