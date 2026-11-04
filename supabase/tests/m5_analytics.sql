-- M5 analytics: additive index + aggregation contract verification.
-- Disposable local/test database only; all rows roll back. Production activation remains gated.
-- Mirrors the Dart AnalyticsEngine semantics (windowed, timezone-bucketed, exercise-ID-validated).
BEGIN;
CREATE FUNCTION pg_temp.m5_assert(ok boolean, label text) RETURNS void
LANGUAGE plpgsql AS $$ BEGIN
  IF ok IS DISTINCT FROM true THEN RAISE EXCEPTION 'FAIL: %', label; END IF;
END $$;
CREATE FUNCTION pg_temp.m5_denied(statement text, expected text) RETURNS void
LANGUAGE plpgsql AS $$ BEGIN
  BEGIN
    EXECUTE statement;
  EXCEPTION WHEN OTHERS THEN
    IF SQLSTATE = expected THEN RETURN; END IF;
    RAISE;
  END;
  RAISE EXCEPTION 'FAIL: expected %', expected;
END $$;

-- Owner 'aaaa' and other user 'bbbb'.
INSERT INTO auth.users (id, email, raw_user_meta_data) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'm5-owner@example.test', '{}'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'm5-other@example.test', '{}')
ON CONFLICT (id) DO NOTHING;

SELECT set_config('request.jwt.claim.sub', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', true);
SELECT set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa","role":"authenticated"}', true);

-- Two workouts for the owner (inserted active so set writes pass the guard
-- trigger), then marked completed with the desired completed_at.
INSERT INTO public.workouts (id, user_id, status) VALUES
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'active'),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'active');

-- Catalog exercises (seeded by seed.sql / seed_exercises.sql).
INSERT INTO public.workout_exercises (id, workout_id, exercise_id)
VALUES
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'cccccccc-cccc-cccc-cccc-cccccccccccc',
    (SELECT id FROM public.exercises WHERE name = 'Bench Press (Barbell)' LIMIT 1)),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeef', 'dddddddd-dddd-dddd-dddd-dddddddddddd',
    (SELECT id FROM public.exercises WHERE name = 'Deadlift (Barbell)' LIMIT 1));

-- All sets inserted while workouts are still active (guard trigger requires active).
-- Completed sets: we1 has two sets (10x20 + 8x30 = 440 vol, 18 reps, 2 sets).
-- we2 has one set (12x15 = 180 vol, 12 reps, 1 set). s4 is uncompleted.
INSERT INTO public.workout_sets (id, workout_exercise_id, set_number, reps, weight_kg, is_completed)
VALUES
  ('44444444-4444-4444-4444-444444444444', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 1, 10, 20, true),
  ('55555555-5555-5555-5555-555555555555', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 2, 8, 30, true),
  ('66666666-6666-6666-6666-666666666666', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeef', 1, 12, 15, true),
  ('77777777-7777-7777-7777-777777777777', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 3, 10, 20, false);

UPDATE public.workouts SET status='completed', completed_at='2026-11-03 10:00:00+00'
  WHERE id='cccccccc-cccc-cccc-cccc-cccccccccccc';
UPDATE public.workouts SET status='completed', completed_at='2026-11-04 10:00:00+00'
  WHERE id='dddddddd-dddd-dddd-dddd-dddddddddddd';

-- ---------------------------------------------------------------------------
-- 1. Additive indexes exist.
-- ---------------------------------------------------------------------------
SELECT pg_temp.m5_assert(
  (SELECT count(*) = 4 FROM pg_indexes
   WHERE schemaname = 'public'
     AND indexname IN (
       'idx_analytics_workouts_user_completed',
       'idx_analytics_workout_sets_completed',
       'idx_analytics_workout_exercises_exercise_id',
       'idx_analytics_exercise_prs_user_updated')),
  'all four M5 analytics indexes exist'
);

-- ---------------------------------------------------------------------------
-- 2. Heatmap: distinct completed workouts per local day (owner tz +7).
--    UTC 10:00 on Nov 3 -> 17:00 local Nov 3; UTC 10:00 on Nov 4 -> 17:00 local Nov 4.
-- ---------------------------------------------------------------------------
SELECT pg_temp.m5_assert(
  (SELECT count(*) = 2 FROM (
    SELECT date_trunc('day', completed_at AT TIME ZONE 'UTC' + interval '7 hours')::date AS d
    FROM public.workouts
    WHERE user_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
      AND status = 'completed' AND completed_at IS NOT NULL
    GROUP BY d
  ) h),
  'heatmap has 2 local days for owner'
);
SELECT pg_temp.m5_assert(
  (SELECT count(*) = 1 FROM public.workouts
   WHERE user_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
     AND status = 'completed'
     AND date_trunc('day', completed_at AT TIME ZONE 'UTC' + interval '7 hours')::date
       = DATE '2026-11-03'),
  'heatmap Nov 3 has 1 workout'
);
SELECT pg_temp.m5_assert(
  (SELECT count(*) = 1 FROM public.workouts
   WHERE user_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
     AND status = 'completed'
     AND date_trunc('day', completed_at AT TIME ZONE 'UTC' + interval '7 hours')::date
       = DATE '2026-11-04'),
  'heatmap Nov 4 has 1 workout'
);

-- ---------------------------------------------------------------------------
-- 3. Weight trend: volume per local day from completed sets.
--    Nov 3: 440 vol / 18 reps / 2 sets. Nov 4: 180 vol / 12 reps / 1 set.
-- ---------------------------------------------------------------------------
SELECT pg_temp.m5_assert(
  (SELECT count(*) = 2 FROM (
    SELECT date_trunc('day', w.completed_at AT TIME ZONE 'UTC' + interval '7 hours')::date AS d,
           sum(s.reps * s.weight_kg) AS volume,
           sum(s.reps) AS reps, count(*) AS sets
    FROM public.workout_sets s
    JOIN public.workout_exercises we ON we.id = s.workout_exercise_id
    JOIN public.workouts w ON w.id = we.workout_id
    WHERE s.is_completed AND w.user_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
      AND w.status = 'completed' AND w.completed_at IS NOT NULL
    GROUP BY d
  ) t),
  'weight trend has 2 local days'
);
SELECT pg_temp.m5_assert(
  (SELECT sum(s.reps * s.weight_kg) = 440
   FROM public.workout_sets s
   JOIN public.workout_exercises we ON we.id = s.workout_exercise_id
   JOIN public.workouts w ON w.id = we.workout_id
   WHERE s.is_completed AND w.user_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
     AND date_trunc('day', w.completed_at AT TIME ZONE 'UTC' + interval '7 hours')::date
       = DATE '2026-11-03'),
  'weight trend Nov 3 volume is 440'
);
SELECT pg_temp.m5_assert(
  (SELECT count(*) = 2 FROM public.workout_sets s
   JOIN public.workout_exercises we ON we.id = s.workout_exercise_id
   JOIN public.workouts w ON w.id = we.workout_id
   WHERE s.is_completed AND w.user_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
     AND date_trunc('day', w.completed_at AT TIME ZONE 'UTC' + interval '7 hours')::date
       = DATE '2026-11-03'),
  'weight trend Nov 3 set count is 2'
);

-- ---------------------------------------------------------------------------
-- 4. Muscle balance: volume by category.
--    Bench Press (Barbell) = Chest (440). Deadlift (Barbell) = Legs (180).
--    Total = 620. Chest percent = 440/620*100.
-- ---------------------------------------------------------------------------
SELECT pg_temp.m5_assert(
  (SELECT count(*) = 2 FROM (
    SELECT e.category, sum(s.reps * s.weight_kg) AS volume
    FROM public.workout_sets s
    JOIN public.workout_exercises we ON we.id = s.workout_exercise_id
    JOIN public.workouts w ON w.id = we.workout_id
    JOIN public.exercises e ON e.id = we.exercise_id
    WHERE s.is_completed AND w.user_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
      AND w.status = 'completed' AND w.completed_at IS NOT NULL
    GROUP BY e.category
  ) m),
  'muscle balance has 2 categories'
);
SELECT pg_temp.m5_assert(
  (SELECT sum(s.reps * s.weight_kg) = 440 FROM public.workout_sets s
   JOIN public.workout_exercises we ON we.id = s.workout_exercise_id
   JOIN public.workouts w ON w.id = we.workout_id
   JOIN public.exercises e ON e.id = we.exercise_id
   WHERE s.is_completed AND w.user_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
     AND e.category = 'Chest'),
  'muscle balance Chest volume is 440'
);

-- ---------------------------------------------------------------------------
-- 5. Time window: [start, end) is inclusive of start, exclusive of end.
--    Nov 3 workout is inside; Nov 4 workout (10:00 UTC) is outside [Nov 3, Nov 4).
-- ---------------------------------------------------------------------------
SELECT pg_temp.m5_assert(
  (SELECT count(*) = 1 FROM public.workouts
   WHERE user_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
     AND status = 'completed' AND completed_at IS NOT NULL
     AND completed_at >= TIMESTAMPTZ '2026-11-03 00:00:00+00'
     AND completed_at <  TIMESTAMPTZ '2026-11-04 00:00:00+00'),
  'window [Nov 3, Nov 4) includes only the Nov 3 workout'
);

-- ---------------------------------------------------------------------------
-- 6. Legacy/inactive sets: uncompleted sets are skipped; null-mode completed sets count.
-- (s4 uncompleted set was inserted above while workout was still active.)
-- ---------------------------------------------------------------------------
SELECT pg_temp.m5_assert(
  (SELECT count(*) = 2 FROM public.workout_sets s
   JOIN public.workout_exercises we ON we.id = s.workout_exercise_id
   JOIN public.workouts w ON w.id = we.workout_id
   WHERE s.is_completed AND w.id = 'cccccccc-cccc-cccc-cccc-cccccccccccc'),
  'uncompleted set excluded from completed-set count'
);

-- ---------------------------------------------------------------------------
-- 7. RLS not weakened: owner sees own rows through RLS; other user sees none
--    and cannot insert. (SET LOCAL ROLE authenticated mirrors m4_rpe_rir.sql.)
-- ---------------------------------------------------------------------------
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', true);
SELECT set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa","role":"authenticated"}', true);
SELECT pg_temp.m5_assert(
  (SELECT count(*) = 3 FROM public.workout_sets WHERE workout_exercise_id = 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee'),
  'owner sees own sets through RLS'
);
SELECT set_config('request.jwt.claim.sub', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', true);
SELECT set_config('request.jwt.claims',
  '{"sub":"bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb","role":"authenticated"}', true);
SELECT pg_temp.m5_assert(
  (SELECT count(*) = 0 FROM public.workout_sets WHERE workout_exercise_id = 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee'),
  'other user cannot see owner rows through RLS'
);
SELECT pg_temp.m5_denied(
  $q$INSERT INTO public.workout_sets (id, workout_exercise_id, set_number, reps, weight_kg, is_completed)
    VALUES ('88888888-8888-8888-8888-888888888888', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 9, 10, 20, true)$q$,
  '42501'
);

ROLLBACK;
