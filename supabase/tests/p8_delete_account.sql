-- P8: Account deletion security contract verification.
-- Disposable local/test database only. All rows roll back. No production DB writes.
BEGIN;
CREATE FUNCTION pg_temp.p8_assert_true(ok boolean, label text) RETURNS void
LANGUAGE plpgsql AS $$ BEGIN
  IF ok IS DISTINCT FROM true THEN RAISE EXCEPTION 'FAIL: %', label; END IF;
END $$;

-- Two owners for cross-user RLS checks.
INSERT INTO auth.users(id, email, raw_user_meta_data) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','p8-owner-a@example.test','{}'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb','p8-owner-b@example.test','{}')
ON CONFLICT (id) DO NOTHING;

-- Seed catalogue exercises referenced by routine/workout exercises.
INSERT INTO public.exercises(id,name,slug,category,equipment,created_at,updated_at) VALUES
  ('11111111-1111-1111-1111-111111111111','Bench Press','p8-test-bench-press','Chest','Barbell',now(),now()),
  ('22222222-2222-2222-2222-222222222222','Push-up','p8-test-push-up','Chest','Bodyweight',now(),now());

-- Owner A data: workouts (insert as active so triggers allow child rows),
-- then mark one completed to simulate a finished session.
SELECT set_config('request.jwt.claim.sub','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',true);
SELECT set_config('request.jwt.claims','{"sub":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa","role":"authenticated"}',true);
INSERT INTO public.workouts(id,user_id,status,training_started_at) VALUES
  ('1a1a1a1a-1a1a-1a1a-1a1a-1a1a1a1a1a1a','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','active',now()-interval '1 hour'),
  ('2b2b2b2b-2b2b-2b2b-2b2b-2b2b2b2b2b2b','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','active',now()-interval '2 days');
INSERT INTO public.workout_exercises(id,workout_id,exercise_id) VALUES
  ('3c3c3c3c-3c3c-3c3c-3c3c-3c3c3c3c3c3c','1a1a1a1a-1a1a-1a1a-1a1a-1a1a1a1a1a1a','11111111-1111-1111-1111-111111111111'),
  ('4d4d4d4d-4d4d-4d4d-4d4d-4d4d4d4d4d4d','2b2b2b2b-2b2b-2b2b-2b2b-2b2b2b2b2b2b','22222222-2222-2222-2222-222222222222');
INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,is_completed) VALUES
  ('3c3c3c3c-3c3c-3c3c-3c3c-3c3c3c3c3c3c',1,10,20,true),
  ('4d4d4d4d-4d4d-4d4d-4d4d-4d4d4d4d4d4d',1,10,20,true);
-- Mark one workout as completed (simulates a finished session).
UPDATE public.workouts SET status='completed' WHERE id='2b2b2b2b-2b2b-2b2b-2b2b-2b2b2b2b2b2b';
INSERT INTO public.xp_logs(user_id,source,source_id,amount) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','workout','2b2b2b2b-2b2b-2b2b-2b2b-2b2b2b2b2b2b',100);
INSERT INTO public.streaks(user_id,current_streak,last_activity_date) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',5,now());
INSERT INTO public.user_achievements(user_id,achievement_id) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','first_workout');

-- Owner B data: separate workout.
SELECT set_config('request.jwt.claim.sub','bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',true);
SELECT set_config('request.jwt.claims','{"sub":"bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb","role":"authenticated"}',true);
INSERT INTO public.workouts(id,user_id,status,training_started_at) VALUES
  ('5e5e5e5e-5e5e-5e5e-5e5e-5e5e5e5e5e5e','bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb','active',now()-interval '30 minutes');
INSERT INTO public.workout_exercises(id,workout_id,exercise_id) VALUES
  ('6f6f6f6f-6f6f-6f6f-6f6f-6f6f6f6f6f6f','5e5e5e5e-5e5e-5e5e-5e5e-5e5e5e5e5e5e','11111111-1111-1111-1111-111111111111');
INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,is_completed) VALUES
  ('6f6f6f6f-6f6f-6f6f-6f6f-6f6f6f6f6f6f',1,10,20,true);

-- Owner A deletes own account data.
SELECT set_config('request.jwt.claim.sub','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',true);
SELECT set_config('request.jwt.claims','{"sub":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa","role":"authenticated"}',true);
SELECT public.delete_account_data();

-- Owner A data must be removed.
SELECT pg_temp.p8_assert_true(
  NOT EXISTS(SELECT 1 FROM public.workouts WHERE user_id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
  'owner A workouts removed');
SELECT pg_temp.p8_assert_true(
  NOT EXISTS(SELECT 1 FROM public.workout_exercises we JOIN public.workouts w ON w.id=we.workout_id WHERE w.user_id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
  'owner A workout_exercises removed');
SELECT pg_temp.p8_assert_true(
  NOT EXISTS(SELECT 1 FROM public.workout_sets s JOIN public.workout_exercises we ON we.id=s.workout_exercise_id JOIN public.workouts w ON w.id=we.workout_id WHERE w.user_id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
  'owner A workout_sets removed');
SELECT pg_temp.p8_assert_true(
  NOT EXISTS(SELECT 1 FROM public.xp_logs WHERE user_id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
  'owner A xp_logs removed');
SELECT pg_temp.p8_assert_true(
  NOT EXISTS(SELECT 1 FROM public.streaks WHERE user_id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
  'owner A streaks removed');
SELECT pg_temp.p8_assert_true(
  NOT EXISTS(SELECT 1 FROM public.user_achievements WHERE user_id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
  'owner A user_achievements removed');
SELECT pg_temp.p8_assert_true(
  NOT EXISTS(SELECT 1 FROM public.users WHERE id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
  'owner A public.users row removed');

-- Owner B data must remain intact.
SELECT pg_temp.p8_assert_true(
  EXISTS(SELECT 1 FROM public.workouts WHERE user_id='bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'),
  'owner B workouts preserved');
SELECT pg_temp.p8_assert_true(
  EXISTS(SELECT 1 FROM public.workout_exercises we JOIN public.workouts w ON w.id=we.workout_id WHERE w.user_id='bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'),
  'owner B workout_exercises preserved');
SELECT pg_temp.p8_assert_true(
  EXISTS(SELECT 1 FROM public.workout_sets s JOIN public.workout_exercises we ON we.id=s.workout_exercise_id JOIN public.workouts w ON w.id=we.workout_id WHERE w.user_id='bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'),
  'owner B workout_sets preserved');

-- Catalog data must remain intact.
SELECT pg_temp.p8_assert_true(
  EXISTS(SELECT 1 FROM public.exercises WHERE id='11111111-1111-1111-1111-111111111111'),
  'catalogue exercises preserved');

RESET ROLE;
ROLLBACK;
