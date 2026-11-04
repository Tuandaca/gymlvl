-- M5 bodyweight: bodyweight_measurements table contract verification.
-- Disposable local/test database only; all rows roll back. Production activation
-- remains gated. No production DB change, no live Supabase.
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
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'm5-bodyweight-owner@example.test', '{}'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'm5-bodyweight-other@example.test', '{}')
ON CONFLICT (id) DO NOTHING;

-- Owner profile with authoritative body mass (baseline).
INSERT INTO public.profiles (id, environment, goals, class_name,
  experience_level, age, gender, height_cm, weight_kg)
VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'home',
   ARRAY['general_fitness'], 'Fat Slayer', 'beginner', 28, 'male',
   175, 75.0)
ON CONFLICT (id) DO NOTHING;

SELECT set_config('request.jwt.claim.sub', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', true);
SELECT set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa","role":"authenticated"}', true);

-- ---------------------------------------------------------------------------
-- 1. Table exists with expected columns and constraints.
-- ---------------------------------------------------------------------------
SELECT pg_temp.m5_assert(
  (SELECT count(*) = 1 FROM information_schema.columns
   WHERE table_schema = 'public' AND table_name = 'bodyweight_measurements'
     AND column_name = 'id'),
  'bodyweight_measurements.id exists'
);
SELECT pg_temp.m5_assert(
  (SELECT count(*) = 1 FROM information_schema.columns
   WHERE table_schema = 'public' AND table_name = 'bodyweight_measurements'
     AND column_name = 'weight_kg'),
  'bodyweight_measurements.weight_kg exists'
);
SELECT pg_temp.m5_assert(
  (SELECT count(*) = 1 FROM information_schema.columns
   WHERE table_schema = 'public' AND table_name = 'bodyweight_measurements'
     AND column_name = 'measured_at'),
  'bodyweight_measurements.measured_at exists'
);
SELECT pg_temp.m5_assert(
  (SELECT count(*) = 1 FROM information_schema.columns
   WHERE table_schema = 'public' AND table_name = 'bodyweight_measurements'
     AND column_name = 'source'),
  'bodyweight_measurements.source exists'
);
SELECT pg_temp.m5_assert(
  (SELECT count(*) = 1 FROM information_schema.table_constraints
   WHERE table_schema = 'public' AND table_name = 'bodyweight_measurements'
     AND constraint_type = 'CHECK' AND constraint_name LIKE '%weight_kg%'),
  'bodyweight_measurements.weight_kg has a CHECK constraint'
);

-- ---------------------------------------------------------------------------
-- 2. Additive: profiles.weight_kg and workout_sets.weight_kg are untouched.
--    profiles.weight_kg remains NOT NULL; workout_sets.weight_kg remains the
--    external/additional load column (no body-mass semantics added).
-- ---------------------------------------------------------------------------
SELECT pg_temp.m5_assert(
  (SELECT count(*) = 1 FROM information_schema.columns
   WHERE table_schema = 'public' AND table_name = 'profiles'
     AND column_name = 'weight_kg' AND is_nullable = 'NO'),
  'profiles.weight_kg remains NOT NULL'
);
SELECT pg_temp.m5_assert(
  (SELECT count(*) = 1 FROM information_schema.columns
   WHERE table_schema = 'public' AND table_name = 'workout_sets'
     AND column_name = 'weight_kg'),
  'workout_sets.weight_kg remains (external load only)'
);

-- ---------------------------------------------------------------------------
-- 3. Owner can insert and read their own measurements.
-- ---------------------------------------------------------------------------
INSERT INTO public.bodyweight_measurements (id, user_id, weight_kg, measured_at, source)
VALUES
  ('ffffffff-ffff-ffff-ffff-fffffffffff1', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 75.0,
   TIMESTAMPTZ '2026-11-01 08:00:00+00', 'profile_baseline'),
  ('ffffffff-ffff-ffff-ffff-fffffffffff2', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 76.5,
   TIMESTAMPTZ '2026-11-02 08:00:00+00', 'manual_weigh_in'),
  ('ffffffff-ffff-ffff-ffff-fffffffffff3', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 75.8,
   TIMESTAMPTZ '2026-11-03 08:00:00+00', 'scale');

SELECT pg_temp.m5_assert(
  (SELECT count(*) = 3 FROM public.bodyweight_measurements
   WHERE user_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
  'owner sees 3 own measurements'
);
SELECT pg_temp.m5_assert(
  (SELECT weight_kg FROM public.bodyweight_measurements
   WHERE id = 'ffffffff-ffff-ffff-ffff-fffffffffff2') = 76.5,
  'owner reads correct weight_kg'
);

-- ---------------------------------------------------------------------------
-- 4. RLS: other user cannot see owner rows and cannot insert into them.
-- ---------------------------------------------------------------------------
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', true);
SELECT set_config('request.jwt.claims',
  '{"sub":"bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb","role":"authenticated"}', true);
SELECT pg_temp.m5_assert(
  (SELECT count(*) = 0 FROM public.bodyweight_measurements
   WHERE user_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
  'other user cannot see owner measurements through RLS'
);
SELECT pg_temp.m5_denied(
  $q$INSERT INTO public.bodyweight_measurements (id, user_id, weight_kg, measured_at, source)
    VALUES ('ffffffff-ffff-ffff-ffff-fffffffffff9', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 80.0,
      TIMESTAMPTZ '2026-11-04 08:00:00+00', 'manual_weigh_in')$q$,
  '42501'
);

-- ---------------------------------------------------------------------------
-- 5. Trend ordering: measurements sort by measured_at ascending.
-- ---------------------------------------------------------------------------
SELECT set_config('request.jwt.claim.sub', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', true);
SELECT set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa","role":"authenticated"}', true);
SELECT pg_temp.m5_assert(
  (SELECT array_agg(weight_kg ORDER BY measured_at)
   FROM public.bodyweight_measurements
   WHERE user_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa') =
   ARRAY[75.0, 76.5, 75.8]::decimal[],
  'trend points order by measured_at ascending'
);

-- ---------------------------------------------------------------------------
-- 6. CHECK constraint rejects non-positive or absurd body mass.
-- ---------------------------------------------------------------------------
SELECT pg_temp.m5_denied(
  $q$INSERT INTO public.bodyweight_measurements (id, user_id, weight_kg, measured_at, source)
    VALUES ('ffffffff-ffff-ffff-ffff-fffffffffff8', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 0,
      TIMESTAMPTZ '2026-11-04 08:00:00+00', 'manual_weigh_in')$q$,
  '23514'
);

-- ---------------------------------------------------------------------------
-- 7. Profiles.weight_kg is the baseline source: profile row is untouched by
--    measurement inserts (no derived write back).
-- ---------------------------------------------------------------------------
SELECT pg_temp.m5_assert(
  (SELECT weight_kg FROM public.profiles
   WHERE id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa') = 75.0,
  'profiles.weight_kg remains the authoritative baseline (75 kg)'
);

ROLLBACK;
