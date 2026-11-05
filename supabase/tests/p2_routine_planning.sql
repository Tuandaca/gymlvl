-- P2 focused contract verification: routines, schedules, snapshots, start, repeat.
-- Disposable local/test database only; all rows roll back. No production DB writes.
BEGIN;
CREATE FUNCTION pg_temp.p2_assert(ok boolean, label text) RETURNS void
LANGUAGE plpgsql AS $$ BEGIN
  IF ok IS DISTINCT FROM true THEN RAISE EXCEPTION 'FAIL: %', label; END IF;
END $$;
CREATE FUNCTION pg_temp.p2_denied(statement text, expected text DEFAULT '42501') RETURNS void
LANGUAGE plpgsql AS $$ BEGIN
  BEGIN
    EXECUTE statement;
  EXCEPTION WHEN OTHERS THEN
    IF SQLSTATE = expected THEN RETURN; END IF;
    RAISE;
  END;
  RAISE EXCEPTION 'FAIL: expected %', expected;
END $$;

-- Two owners for cross-user RLS checks.
INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'p2-owner@example.test', '{}'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'p2-other@example.test', '{}')
ON CONFLICT (id) DO NOTHING;

-- Seed catalogue exercises referenced by routine exercises.
INSERT INTO public.exercises(id,name,slug,category,equipment,created_at,updated_at) VALUES
  ('11111111-1111-1111-1111-111111111111','Bench Press','p2-test-bench-press','Chest','Barbell',now(),now()),
  ('22222222-2222-2222-2222-222222222222','Push-up','p2-test-push-up','Chest','Bodyweight',now(),now()),
  ('33333333-3333-3333-3333-333333333333','Squat','p2-test-squat','Legs','Barbell',now(),now()),
  ('44444444-4444-4444-4444-444444444444','Plank','p2-test-plank','Core','Bodyweight',now(),now());

SELECT set_config('request.jwt.claim.sub','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',true);
SELECT set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa","role":"authenticated"}',true);

-- ==============================================================================
-- 1. Routine create + exercise + snapshot at schedule time
-- ==============================================================================
SELECT public.create_routine(
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  'Push Day',
  '💪',
  '[{"exercise_id":"11111111-1111-1111-1111-111111111111","order_index":0,"sets":3,"reps":10,"weight_kg":20,"mode":"reps-weight"},{"exercise_id":"22222222-2222-2222-2222-222222222222","order_index":1,"sets":3,"reps":12,"weight_kg":0,"mode":"bodyweight"}]'
);

SELECT pg_temp.p2_assert(
  (SELECT count(*) FROM public.routines WHERE user_id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa' AND name='Push Day')=1,
  'routine created for owner'
);
SELECT pg_temp.p2_assert(
  (SELECT count(*) FROM public.routine_exercises re JOIN public.routines r ON r.id=re.routine_id WHERE r.name='Push Day')=2,
  'two routine exercises persisted'
);

-- schedule_routine with valid weekday
SELECT public.schedule_routine(
  (SELECT id FROM public.routines WHERE name='Push Day' AND user_id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
  'fixed_week', 1, NULL, NULL
);

SELECT pg_temp.p2_assert(
  (SELECT count(*) FROM public.routine_schedules rs JOIN public.routines r ON r.id=rs.routine_id WHERE r.name='Push Day' AND rs.weekday=1)=1,
  'fixed-week schedule assigned weekday=1'
);

-- schedule_routine rejects weekday outside 1..7
SELECT pg_temp.p2_denied(
  $q$SELECT public.schedule_routine((SELECT id FROM public.routines WHERE name='Push Day'),'fixed_week',8,NULL,NULL)$q$,
  '22023'
);

-- create_planned_workout captures immutable snapshot
SELECT public.create_planned_workout(
  (SELECT id FROM public.routines WHERE name='Push Day' AND user_id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
  '2026-11-09'
);

SELECT pg_temp.p2_assert(
  (SELECT count(*) FROM public.planned_workouts pw JOIN public.routines r ON r.id=pw.routine_id WHERE r.name='Push Day' AND pw.scheduled_date='2026-11-09')=1,
  'planned workout occurrence created'
);

-- Snapshot records both exercises with correct values
SELECT pg_temp.p2_assert(
  (SELECT jsonb_array_length(pw.routine_snapshot->'routine'->'exercises')
   FROM public.planned_workouts pw JOIN public.routines r ON r.id=pw.routine_id
   WHERE r.name='Push Day' AND pw.scheduled_date='2026-11-09')=2,
  'snapshot contains two exercises'
);
SELECT pg_temp.p2_assert(
  (SELECT (pw.routine_snapshot->'routine'->'exercises'->>1)::jsonb->>'weight_kg'
   FROM public.planned_workouts pw JOIN public.routines r ON r.id=pw.routine_id
   WHERE r.name='Push Day' AND pw.scheduled_date='2026-11-09')='0',
  'snapshot preserves bodyweight weight_kg=0'
);

-- ==============================================================================
-- 2. Snapshot immutability: editing routine does not rewrite existing snapshot
-- ==============================================================================
UPDATE public.routines SET name='Push Day v2', updated_at=now()
WHERE name='Push Day' AND user_id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

SELECT pg_temp.p2_assert(
  (SELECT (pw.routine_snapshot->'routine'->>'name')
   FROM public.planned_workouts pw JOIN public.routines r ON r.id=pw.routine_id
   WHERE r.name='Push Day v2' AND pw.scheduled_date='2026-11-09')='Push Day',
  'existing occurrence snapshot unchanged after routine rename'
);

-- Second occurrence scheduled after the edit keeps its own snapshot
SELECT public.create_planned_workout(
  (SELECT id FROM public.routines WHERE name='Push Day v2' AND user_id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
  '2026-11-16'
);

SELECT pg_temp.p2_assert(
  (SELECT (pw.routine_snapshot->'routine'->>'name')
   FROM public.planned_workouts pw JOIN public.routines r ON r.id=pw.routine_id
   WHERE r.name='Push Day v2' AND pw.scheduled_date='2026-11-16')='Push Day v2',
  'new occurrence captures edited routine name'
);
SELECT pg_temp.p2_assert(
  (SELECT (pw.routine_snapshot->'routine'->'exercises'->>1)::jsonb->>'weight_kg'
   FROM public.planned_workouts pw JOIN public.routines r ON r.id=pw.routine_id
   WHERE r.name='Push Day v2' AND pw.scheduled_date='2026-11-16')='0',
  'new occurrence snapshot reflects edited exercise config'
);

-- Two scheduled occurrences retain independent snapshots
SELECT pg_temp.p2_assert(
  (SELECT count(*) FROM (
    SELECT DISTINCT pw.routine_snapshot
    FROM public.planned_workouts pw JOIN public.routines r ON r.id=pw.routine_id
    WHERE r.name ILIKE 'Push Day%' AND pw.scheduled_date IN ('2026-11-09','2026-11-16')
  ) s)=2,
  'two occurrences have independent snapshots'
);

-- ==============================================================================
-- 3. start_planned_workout creates NEW workout identity from snapshot
-- ==============================================================================
SELECT public.start_planned_workout(
  (SELECT pw.id FROM public.planned_workouts pw WHERE pw.scheduled_date='2026-11-09')
);

SELECT pg_temp.p2_assert(
  (SELECT pw.status FROM public.planned_workouts pw WHERE pw.scheduled_date='2026-11-09')='started',
  'planned workout marked started'
);
SELECT pg_temp.p2_assert(
  (SELECT pw.workout_id IS NOT NULL FROM public.planned_workouts pw WHERE pw.scheduled_date='2026-11-09'),
  'planned workout linked to new workout identity'
);
SELECT pg_temp.p2_assert(
  (SELECT count(*) FROM public.workouts w JOIN public.planned_workouts pw ON pw.workout_id=w.id WHERE w.status='active')=1,
  'new active workout created from planned occurrence'
);
SELECT pg_temp.p2_assert(
  (SELECT count(*) FROM public.workout_exercises we JOIN public.planned_workouts pw ON pw.workout_id=we.workout_id WHERE pw.scheduled_date='2026-11-09')=2,
  'workout_exercises derived from snapshot (two exercises)'
);

-- ==============================================================================
-- 4. Repeat completed workout -> new identity, old unchanged
-- ==============================================================================
-- Mark the started workout as completed
UPDATE public.workouts SET status='completed', completed_at=now()
WHERE id=(SELECT pw.workout_id FROM public.planned_workouts pw WHERE pw.scheduled_date='2026-11-09');

SELECT pg_temp.p2_assert(
  (SELECT w.status='completed' FROM public.workouts w JOIN public.planned_workouts pw ON pw.workout_id=w.id WHERE pw.scheduled_date='2026-11-09'),
  'completed workout is completed'
);

SELECT public.repeat_workout(
  (SELECT w.id FROM public.workouts w JOIN public.planned_workouts pw ON pw.workout_id=w.id WHERE pw.scheduled_date='2026-11-09')
);

SELECT pg_temp.p2_assert(
  (SELECT count(*) FROM public.planned_workouts WHERE routine_name LIKE '%(Repeat)%')=1,
  'repeat creates new planned workout identity'
);
SELECT pg_temp.p2_assert(
  (SELECT count(*) FROM public.routines WHERE name LIKE '%(Repeat)%')=1,
  'repeat creates new routine identity'
);
SELECT pg_temp.p2_assert(
  (SELECT count(*) FROM public.workouts w WHERE w.id=(SELECT pw.workout_id FROM public.planned_workouts pw WHERE pw.scheduled_date='2026-11-09') AND w.status='completed')=1,
  'old completed workout unchanged after repeat'
);

-- repeat rejects a workout with no exercises
INSERT INTO public.workouts(id,user_id,status,notes,training_started_at) VALUES
  ('cccccccc-cccc-cccc-cccc-cccccccccccc','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','completed','empty',now());
SELECT pg_temp.p2_denied(
  $q$SELECT public.repeat_workout('cccccccc-cccc-cccc-cccc-cccccccccccc')$q$,
  '22023'
);

-- ==============================================================================
-- 5. Cross-user RLS denial
-- ==============================================================================
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub','bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',true);
SELECT set_config('request.jwt.claims',
  '{"sub":"bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb","role":"authenticated"}',true);

-- Other user cannot see owner's planned workouts
SELECT pg_temp.p2_assert(
  (SELECT count(*) FROM public.planned_workouts WHERE user_id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa')=0,
  'other user cannot see owner planned workouts through RLS'
);

-- Other user cannot start owner's planned workout
SELECT pg_temp.p2_denied(
  $q$SELECT public.start_planned_workout((SELECT pw.id FROM public.planned_workouts pw JOIN public.routines r ON r.id=pw.routine_id WHERE r.name='Push Day v2' AND pw.scheduled_date='2026-11-09'))$q$,
  '42501'
);

-- Other user cannot create routine for owner
SELECT pg_temp.p2_denied(
  $q$SELECT public.create_routine('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','Hack','🔓','[]')$q$,
  '42501'
);

RESET ROLE;

ROLLBACK;
