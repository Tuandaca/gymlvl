-- M4 additive rpe/rir contract verification; disposable local/test database only.
-- All rows roll back. Production activation remains gated.
BEGIN;
CREATE FUNCTION pg_temp.m4_assert(ok boolean, label text) RETURNS void
LANGUAGE plpgsql AS $$ BEGIN
  IF ok IS DISTINCT FROM true THEN RAISE EXCEPTION 'FAIL: %', label; END IF;
END $$;
CREATE FUNCTION pg_temp.m4_denied(statement text, expected text) RETURNS void
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
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'm4-owner@example.test', '{}'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'm4-other@example.test', '{}')
ON CONFLICT (id) DO NOTHING;

-- Đặt auth.uid() = chủ sở hữu 'aaaa' TRUỚC khi chèn workout/workout_exercises,
-- sao cho trigger sở hữu workout (guard_workout_child) nhận chủ sở hữu chính xác.
-- Giống mô hình M3: set claim JWT trước các thao tác ghi.
SELECT set_config('request.jwt.claim.sub', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', true);
SELECT set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa","role":"authenticated"}', true);

INSERT INTO public.workouts (id, user_id, status) VALUES
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'active');
INSERT INTO public.workout_exercises (id, workout_id, exercise_id)
  SELECT 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'cccccccc-cccc-cccc-cccc-cccccccccccc', id
  FROM public.exercises ORDER BY id LIMIT 1;

-- 1. cột rpe/rir tồn tại trên workout_sets
SELECT pg_temp.m4_assert(
  (SELECT count(*) = 2 FROM information_schema.columns
   WHERE table_schema = 'public' AND table_name = 'workout_sets'
     AND column_name IN ('rpe', 'rir')),
  'rpe and rir columns exist on workout_sets'
);

-- 2. ràng buộc CHECK có tên
SELECT pg_temp.m4_assert(
  (SELECT count(*) = 2 FROM pg_catalog.pg_constraint
   WHERE conrelid = 'public.workout_sets'::regclass
     AND conname IN ('workout_sets_rpe_range', 'workout_sets_rir_range')),
  'rpe and rir named CHECK constraints present'
);

-- 3. rpe (1-10) và rir (0-10) hợp lệ -> chèn thành công
INSERT INTO public.workout_sets(workout_exercise_id, set_number, reps, weight_kg, rpe, rir)
  VALUES ('dddddddd-dddd-dddd-dddd-dddddddddddd', 1, 10, 20, 8, 2);
SELECT pg_temp.m4_assert(
  (SELECT rpe = 8 AND rir = 2 FROM public.workout_sets
   WHERE workout_exercise_id = 'dddddddd-dddd-dddd-dddd-dddddddddddd' AND set_number = 1),
  'valid rpe 8 and rir 2 insert succeeds'
);

-- 4. rpe/rir không hợp lệ -> check_violation (23514)
SELECT pg_temp.m4_denied(
  $q$INSERT INTO public.workout_sets(workout_exercise_id, set_number, reps, weight_kg, rpe)
    VALUES ('dddddddd-dddd-dddd-dddd-dddddddddddd', 2, 10, 20, 0)$q$,
  '23514'
);
SELECT pg_temp.m4_denied(
  $q$INSERT INTO public.workout_sets(workout_exercise_id, set_number, reps, weight_kg, rpe)
    VALUES ('dddddddd-dddd-dddd-dddd-dddddddddddd', 3, 10, 20, 11)$q$,
  '23514'
);
SELECT pg_temp.m4_denied(
  $q$INSERT INTO public.workout_sets(workout_exercise_id, set_number, reps, weight_kg, rir)
    VALUES ('dddddddd-dddd-dddd-dddd-dddddddddddd', 4, 10, 20, -1)$q$,
  '23514'
);
SELECT pg_temp.m4_denied(
  $q$INSERT INTO public.workout_sets(workout_exercise_id, set_number, reps, weight_kg, rir)
    VALUES ('dddddddd-dddd-dddd-dddd-dddddddddddd', 5, 10, 20, 11)$q$,
  '23514'
);

-- 5. NULL rpe/rir chấp nhận (backward compatible)
INSERT INTO public.workout_sets(workout_exercise_id, set_number, reps, weight_kg, rpe, rir)
  VALUES ('dddddddd-dddd-dddd-dddd-dddddddddddd', 6, 10, 20, NULL, NULL);
SELECT pg_temp.m4_assert(
  (SELECT rpe IS NULL AND rir IS NULL FROM public.workout_sets
   WHERE workout_exercise_id = 'dddddddd-dddd-dddd-dddd-dddddddddddd' AND set_number = 6),
  'NULL rpe and rir accepted'
);
INSERT INTO public.workout_sets(workout_exercise_id, set_number, reps, weight_kg, rpe, rir)
  VALUES ('dddddddd-dddd-dddd-dddd-dddddddddddd', 7, 10, 20, NULL, 5);
SELECT pg_temp.m4_assert(
  (SELECT rpe IS NULL AND rir = 5 FROM public.workout_sets
   WHERE workout_exercise_id = 'dddddddd-dddd-dddd-dddd-dddddddddddd' AND set_number = 7),
  'NULL rpe with valid rir accepted'
);
INSERT INTO public.workout_sets(workout_exercise_id, set_number, reps, weight_kg, rpe, rir)
  VALUES ('dddddddd-dddd-dddd-dddd-dddddddddddd', 8, 10, 20, 7, NULL);
SELECT pg_temp.m4_assert(
  (SELECT rpe = 7 AND rir IS NULL FROM public.workout_sets
   WHERE workout_exercise_id = 'dddddddd-dddd-dddd-dddd-dddddddddddd' AND set_number = 8),
  'valid rpe with NULL rir accepted'
);

-- 6. dòng cũ không bị ảnh hưởng
SELECT pg_temp.m4_assert(
  (SELECT count(*) = 4 FROM public.workout_sets WHERE workout_exercise_id = 'dddddddd-dddd-dddd-dddd-dddddddddddd')
   AND (SELECT rpe = 8 AND rir = 2 FROM public.workout_sets
        WHERE workout_exercise_id = 'dddddddd-dddd-dddd-dddd-dddddddddddd' AND set_number = 1),
  'existing rows unaffected; successful inserts retained'
);

-- 7. RLS không suy giảm: chủ sở hữu 'aaaa' xem được dòng của mình (qua RLS)
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', true);
SELECT set_config('request.jwt.claims',
  '{"sub":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa","role":"authenticated"}', true);
SELECT pg_temp.m4_assert(
  (SELECT count(*) = 4 FROM public.workout_sets
   WHERE workout_exercise_id = 'dddddddd-dddd-dddd-dddd-dddddddddddd'),
  'owner sees all own sets through RLS'
);

-- Chuyển sang người dùng khác 'bbbb'; RLS phải ẩn dòng của chủ sở hữu và từ chối ghi
SELECT set_config('request.jwt.claim.sub', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', true);
SELECT set_config('request.jwt.claims',
  '{"sub":"bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb","role":"authenticated"}', true);
SELECT pg_temp.m4_assert(
  (SELECT count(*) = 0 FROM public.workout_sets
   WHERE workout_exercise_id = 'dddddddd-dddd-dddd-dddd-dddddddddddd'),
  'other user cannot see owner rows'
);
SELECT pg_temp.m4_denied(
  $q$INSERT INTO public.workout_sets(workout_exercise_id, set_number, reps, weight_kg, rpe, rir)
    VALUES ('dddddddd-dddd-dddd-dddd-dddddddddddd', 9, 10, 20, 5, 1)$q$,
  '42501'
);

ROLLBACK;
