-- P5 focused contract verification: comprehensive tests for all nine frozen P5 gates.
--
-- Gate 1  : Unified progression — get_player_progression() structure (owner-scoped).
-- Gate 2  : Class-linked progression — switch_class() idempotency; class data in progression.
-- Gate 3  : Workout-derived quests — quest completion via complete_workout, XP exactly once.
-- Gate 4  : Achievement/milestone system — exactly-once awards; 7-ID catalogue.
-- Gate 5  : Unlock system — exactly-once unlocks; core fitness ungated.
-- Gate 6  : Streak integration — same-day idempotency, next-day increment, TZ boundary.
-- Gate 7  : Post-workout feedback — complete_workout result payload keys.
-- Gate 8  : Dashboard/player profile — unified state for presentation.
-- Gate 9  : Focused security + regression — owner read, cross-user denial, no client XP
--         mutation, duplicate blocks, idempotent retry.
--
-- Disposable local/test database only: every statement runs in ONE transaction and rolls back.
-- No production DB writes. Additive assertions only: no schema changes, no RLS weakening.
--
-- Fixture relationship: auth.uid() = user id; workouts.user_id = auth.uid();
-- workouts.id is an INDEPENDENT UUID (never equal to auth.uid()).

BEGIN;

-- =====================================================================
-- Assertion helpers (defined before use, public schema).
-- =====================================================================
CREATE OR REPLACE FUNCTION public.p5_assert(ok boolean, label text) RETURNS void
LANGUAGE plpgsql AS $func$
BEGIN
  IF ok IS DISTINCT FROM true THEN RAISE EXCEPTION 'FAIL: %', label; END IF;
END $func$;

CREATE OR REPLACE FUNCTION public.p5_denied(statement text, expected text DEFAULT '42501') RETURNS void
LANGUAGE plpgsql AS $func$
BEGIN
  BEGIN
    EXECUTE statement;
    EXCEPTION WHEN OTHERS THEN
      IF SQLSTATE = expected THEN RETURN; END IF;
      RAISE;
  END;
  RAISE EXCEPTION 'FAIL: expected SQLSTATE %', expected;
END $func$;

-- =====================================================================
-- Auth context: owner = ...9999 (all gate tests), other = ...8888 (cross-user).
-- set_config(..., true) is transaction-scoped; the whole file is one transaction.
-- =====================================================================
SELECT set_config('request.jwt.claim.sub','99999999-9999-9999-9999-999999999999',true);
SELECT set_config('request.jwt.claims','{"sub":"99999999-9999-9999-9999-999999999999","role":"authenticated"}',true);

-- Two owners for cross-user RLS checks (auth.users trigger mirrors into public.users).
INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES
  ('99999999-9999-9999-9999-999999999999','p5-owner@example.test','{}'),
  ('88888888-8888-8888-8888-888888888888','p5-other@example.test','{}')
ON CONFLICT (id) DO NOTHING;

-- One catalogue exercise (independent id, never equal to a user id).
INSERT INTO public.exercises(id,name,slug,category,equipment,force_type,created_at,updated_at) VALUES
  ('11111111-1111-1111-1111-111111111111','Bench Press','p5-test-bench-press','Chest','Barbell','Push',now(),now())
ON CONFLICT (id) DO NOTHING;

-- Quest template for Gate 3 (idempotent; P5 migration seeds the catalogue too).
INSERT INTO public.quests(id,title,description,type,difficulty,category,base_xp,created_at) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','P5 Test Push Day','Complete one bench-press set.','daily_routine','beginner','push',150,now())
ON CONFLICT (id) DO NOTHING;

-- Owner account + streak row.
INSERT INTO public.users(id,email,display_name,level,total_xp,onboarding_completed) VALUES
  ('99999999-9999-9999-9999-999999999999','p5-owner@example.test','Owner',1,0,true)
ON CONFLICT (id) DO UPDATE SET onboarding_completed=true;
INSERT INTO public.streaks(user_id) VALUES ('99999999-9999-9999-9999-999999999999') ON CONFLICT (user_id) DO NOTHING;

-- =====================================================================
-- Workout W1: bench press, 1 set x 10 reps @ 50 kg. Independent workout_id.
-- =====================================================================
INSERT INTO public.workouts(id,user_id,status,duration_seconds,started_at,training_started_at,completed_at) VALUES
  ('22222222-2222-2222-2222-222222222222','99999999-9999-9999-9999-999999999999','active',0,now(),now(),NULL);
INSERT INTO public.workout_exercises(id,workout_id,exercise_id,order_index) VALUES
  ('33333333-3333-3333-3333-333333333333','22222222-2222-2222-2222-222222222222','11111111-1111-1111-1111-111111111111',0);
INSERT INTO public.workout_sets(id,workout_exercise_id,set_number,reps,weight_kg,is_completed,baseline_weight_kg) VALUES
  ('44444444-4444-4444-4444-444444444444','33333333-3333-3333-3333-333333333333',1,10,50,true,0);

-- =====================================================================
-- Gate 7 feed + Gate 1: complete W1, inspect the authoritative result payload.
-- =====================================================================
SELECT public.complete_workout('22222222-2222-2222-2222-222222222222');

CREATE TEMP TABLE p5_w1(result jsonb);
INSERT INTO p5_w1 SELECT result FROM public.workout_rewards WHERE workout_id='22222222-2222-2222-2222-222222222222';

-- W1: single baseline-free set earns exactly 5 XP; first workout starts the streak at 1.
SELECT public.p5_assert(
  (SELECT (result->>'earnedXP')::integer FROM p5_w1) = 5,
  'GATE 7/1: W1 earns exactly 5 XP'
);
SELECT public.p5_assert(
  (SELECT (result->>'totalXP')::integer FROM p5_w1) = 5,
  'GATE 7/1: W1 totalXP is 5'
);
SELECT public.p5_assert(
  (SELECT (result->>'newLevel')::integer FROM p5_w1) = 1,
  'GATE 7/1: W1 newLevel is 1'
);
SELECT public.p5_assert(
  (SELECT (result->>'streak')::integer FROM p5_w1) = 1,
  'GATE 6/7: W1 streak starts at 1'
);

-- Result payload contains every documented feedback key (newTitle may be null/absent when no level-up).
SELECT public.p5_assert(
  (SELECT (
    result ? 'earnedXP'
    AND result ? 'totalXP'
    AND result ? 'newLevel'
    AND result ? 'leveledUp'
    AND result ? 'isQuest'
    AND result ? 'newTitle'
    AND result ? 'nextLevelXp'
    AND result ? 'isSuspicious'
    AND result ? 'classResults'
    AND result ? 'achievements'
    AND result ? 'streak'
  ) FROM p5_w1),
  'GATE 7: complete_workout result contains the full feedback payload'
);

-- =====================================================================
-- Gate 2: Class-linked progression — switch_class() must not duplicate XP
--         or re-award historical workouts; class data appears in progression.
-- =====================================================================
-- First switch: class A (primary). Class focus excludes Chest, so W1's 5 XP yields 2 class XP.
-- Second switch on the same slot: identical result — no XP duplication, no re-award of history.
SELECT public.p5_assert(
  public.switch_class('A','primary') = public.switch_class('A','primary'),
  'GATE 2: switch_class repeat returns identical result (no XP duplication)'
);
SELECT public.p5_assert(
  (public.switch_class('A','primary'))->>'class_id' = 'A',
  'GATE 2: switch_class returns equipped class_id'
);
-- Equip a second class; both must appear in the unified progression response.
SELECT public.switch_class('B','secondary');
SELECT public.p5_assert(
  jsonb_array_length(public.get_player_progression()->'classes') = 2,
  'GATE 2/8: progression classes contain both equipped classes (A primary, B secondary)'
);
SELECT public.p5_assert(
  EXISTS(SELECT 1 FROM jsonb_array_elements(public.get_player_progression()->'classes') c WHERE c->>'classId' = 'A'),
  'GATE 2: progression class A present'
);
SELECT public.p5_assert(
  EXISTS(SELECT 1 FROM jsonb_array_elements(public.get_player_progression()->'classes') c WHERE c->>'classId' = 'B'),
  'GATE 2: progression class B present'
);

-- =====================================================================
-- Gate 3: Workout-derived quests — W2 matches today's active quest,
--         quest instance completed and quest XP awarded exactly once.
-- =====================================================================
INSERT INTO public.workouts(id,user_id,status,duration_seconds,started_at,training_started_at,completed_at) VALUES
  ('22222222-2222-2222-2222-222222222223','99999999-9999-9999-9999-999999999999','active',0,now(),now(),NULL);
INSERT INTO public.workout_exercises(id,workout_id,exercise_id,order_index) VALUES
  ('33333333-3333-3333-3333-333333333334','22222222-2222-2222-2222-222222222223','11111111-1111-1111-1111-111111111111',0);
INSERT INTO public.workout_sets(id,workout_exercise_id,set_number,reps,weight_kg,is_completed,baseline_weight_kg) VALUES
  ('44444444-4444-4444-4444-444444444445','33333333-3333-3333-3333-333333333334',1,10,50,true,0);

-- Active quest instance for today (local calendar boundary), single target matching W2's set.
INSERT INTO public.quest_instances(id,user_id,quest_id,status,prescribed_config,expires_at,quest_date) VALUES
  ('55555555-5555-5555-5555-555555555555','99999999-9999-9999-9999-999999999999',
   (SELECT id FROM public.quests WHERE id='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
   'active',
   '[{"exercise_id":"11111111-1111-1111-1111-111111111111","sets":1,"reps":10,"weight_kg":50}]'::jsonb,
   now() + interval '7 days',
   (now() AT TIME ZONE 'Asia/Ho_Chi_Minh')::date);

SELECT public.complete_workout('22222222-2222-2222-2222-222222222223');

CREATE TEMP TABLE p5_w2(result jsonb);
INSERT INTO p5_w2 SELECT result FROM public.workout_rewards WHERE workout_id='22222222-2222-2222-2222-222222222223';

SELECT public.p5_assert(
  (SELECT (result->>'isQuest')::boolean FROM p5_w2) = true,
  'GATE 3: quest-matching workout reports isQuest=true'
);
SELECT public.p5_assert(
  (SELECT (result->>'earnedXP')::integer FROM p5_w2) = 150,
  'GATE 3: quest XP equals catalogue base_xp exactly once'
);
SELECT public.p5_assert(
  (SELECT (result->>'totalXP')::integer FROM p5_w2) = 155,
  'GATE 3: W2 totalXP is 5 + 150 = 155'
);
SELECT public.p5_assert(
  (SELECT status FROM public.quest_instances WHERE id='55555555-5555-5555-5555-555555555555') = 'completed'
  AND (SELECT earned_xp FROM public.quest_instances WHERE id='55555555-5555-5555-5555-555555555555') = 150,
  'GATE 3: quest instance marked completed with earned_xp persisted'
);

-- Quest reward exactly once: retry returns the cached result, no second reward row, no extra XP.
SELECT public.complete_workout('22222222-2222-2222-2222-222222222223');
SELECT public.p5_assert(
  (SELECT count(*) FROM public.workout_rewards WHERE workout_id='22222222-2222-2222-2222-222222222223') = 1,
  'GATE 3/9: quest workout has exactly one reward row (retry safe)'
);
SELECT public.p5_assert(
  (SELECT total_xp FROM public.users WHERE id='99999999-9999-9999-9999-999999999999') = 155,
  'GATE 3/9: quest retry does not award XP a second time'
);

-- =====================================================================
-- Gate 6: Streak integration — same-day idempotency, next-day increment,
--         local time-zone day boundary.
-- =====================================================================
-- W1 and W2 are the same local day: streak stays 1 (same-day idempotency).
SELECT public.p5_assert(
  (SELECT current_streak FROM public.streaks WHERE user_id='99999999-9999-9999-9999-999999999999') = 1,
  'GATE 6: same-day workouts do not increment the streak (still 1 after W2)'
);

-- Simulate a return the next local day: yesterday was the last activity day, streak was 1.
UPDATE public.streaks
SET last_activity_date = (now() AT TIME ZONE 'Asia/Ho_Chi_Minh')::date - 1,
    current_streak = 1
WHERE user_id = '99999999-9999-9999-9999-999999999999';

-- Workout W3: next calendar day -> streak increments to 2.
INSERT INTO public.workouts(id,user_id,status,duration_seconds,started_at,training_started_at,completed_at) VALUES
  ('22222222-2222-2222-2222-222222222224','99999999-9999-9999-9999-999999999999','active',0,now(),now(),NULL);
INSERT INTO public.workout_exercises(id,workout_id,exercise_id,order_index) VALUES
  ('33333333-3333-3333-3333-333333333335','22222222-2222-2222-2222-222222222224','11111111-1111-1111-1111-111111111111',0);
INSERT INTO public.workout_sets(id,workout_exercise_id,set_number,reps,weight_kg,is_completed,baseline_weight_kg) VALUES
  ('44444444-4444-4444-4444-444444444446','33333333-3333-3333-3333-333333333335',1,10,50,true,0);
SELECT public.complete_workout('22222222-2222-2222-2222-222222222224');

SELECT public.p5_assert(
  (SELECT current_streak FROM public.streaks WHERE user_id='99999999-9999-9999-9999-999999999999') = 2,
  'GATE 6: next-day workout increments streak to 2'
);
SELECT public.p5_assert(
  (SELECT last_activity_date FROM public.streaks WHERE user_id='99999999-9999-9999-9999-999999999999') = (now() AT TIME ZONE 'Asia/Ho_Chi_Minh')::date,
  'GATE 6: streak day boundary follows the local timezone, not UTC'
);

-- Workout W4: same day as W3 -> streak stays 2 (same-day idempotency, second case).
INSERT INTO public.workouts(id,user_id,status,duration_seconds,started_at,training_started_at,completed_at) VALUES
  ('22222222-2222-2222-2222-222222222225','99999999-9999-9999-9999-999999999999','active',0,now(),now(),NULL);
INSERT INTO public.workout_exercises(id,workout_id,exercise_id,order_index) VALUES
  ('33333333-3333-3333-3333-333333333336','22222222-2222-2222-2222-222222222225','11111111-1111-1111-1111-111111111111',0);
INSERT INTO public.workout_sets(id,workout_exercise_id,set_number,reps,weight_kg,is_completed,baseline_weight_kg) VALUES
  ('44444444-4444-4444-4444-444444444447','33333333-3333-3333-3333-333333333336',1,10,50,true,0);
SELECT public.complete_workout('22222222-2222-2222-2222-222222222225');

SELECT public.p5_assert(
  (SELECT current_streak FROM public.streaks WHERE user_id='99999999-9999-9999-9999-999999999999') = 2,
  'GATE 6: same-day workout W4 keeps streak at 2'
);

-- Workout W5: same day -> streak still 2; total completed workouts reaches 5 -> five_workouts.
INSERT INTO public.workouts(id,user_id,status,duration_seconds,started_at,training_started_at,completed_at) VALUES
  ('22222222-2222-2222-2222-222222222226','99999999-9999-9999-9999-999999999999','active',0,now(),now(),NULL);
INSERT INTO public.workout_exercises(id,workout_id,exercise_id,order_index) VALUES
  ('33333333-3333-3333-3333-333333333337','22222222-2222-2222-2222-222222222226','11111111-1111-1111-1111-111111111111',0);
INSERT INTO public.workout_sets(id,workout_exercise_id,set_number,reps,weight_kg,is_completed,baseline_weight_kg) VALUES
  ('44444444-4444-4444-4444-444444444448','33333333-3333-3333-3333-333333333337',1,10,50,true,0);
SELECT public.complete_workout('22222222-2222-2222-2222-222222222226');

SELECT public.p5_assert(
  (SELECT current_streak FROM public.streaks WHERE user_id='99999999-9999-9999-9999-999999999999') = 2,
  'GATE 6: same-day workout W5 keeps streak at 2'
);

-- =====================================================================
-- Gate 4: Achievements — exactly-once awards; 7-ID catalogue.
-- =====================================================================
SELECT public.p5_assert(
  (SELECT count(*) FROM public.user_achievements WHERE user_id='99999999-9999-9999-9999-999999999999' AND achievement_id='first_workout') = 1,
  'GATE 4: first_workout earned exactly once (W1)'
);
SELECT public.p5_assert(
  (SELECT count(*) FROM public.user_achievements WHERE user_id='99999999-9999-9999-9999-999999999999' AND achievement_id='five_workouts') = 1,
  'GATE 4: five_workouts earned exactly once (W5)'
);
SELECT public.p5_assert(
  (SELECT count(*) FROM public.user_achievements WHERE user_id='99999999-9999-9999-9999-999999999999' AND achievement_id IN ('streak_3','streak_7','level_10','level_20')) = 0,
  'GATE 4: higher-tier achievements not yet earned (streak 2, level 2)'
);
SELECT public.p5_assert(
  (SELECT count(*) FROM public.user_achievements WHERE user_id='99999999-9999-9999-9999-999999999999') = 2,
  'GATE 4: exactly two achievement rows total'
);

-- Duplicate award is a no-op (ON CONFLICT DO NOTHING on the primary key).
INSERT INTO public.user_achievements(user_id,achievement_id) VALUES('99999999-9999-9999-9999-999999999999','first_workout') ON CONFLICT DO NOTHING;
SELECT public.p5_assert(
  (SELECT count(*) FROM public.user_achievements WHERE user_id='99999999-9999-9999-9999-999999999999' AND achievement_id='first_workout') = 1,
  'GATE 4: duplicate first_workout insert does not duplicate the row'
);

-- Unknown achievement id is rejected by the CHECK constraint (catalogue-limited).
SELECT public.p5_denied(
  $q$INSERT INTO public.user_achievements(user_id,achievement_id) VALUES('99999999-9999-9999-9999-999999999999','bogus_achievement')$q$,
  '23514'
);

-- All 7 catalogue IDs are present in the CHECK constraint.
SELECT public.p5_assert(
  (SELECT pg_get_constraintdef(oid) FROM pg_constraint WHERE conname='user_achievements_achievement_id_check' AND conrelid='public.user_achievements'::regclass) LIKE '%first_workout%'
  AND (SELECT pg_get_constraintdef(oid) FROM pg_constraint WHERE conname='user_achievements_achievement_id_check' AND conrelid='public.user_achievements'::regclass) LIKE '%five_workouts%'
  AND (SELECT pg_get_constraintdef(oid) FROM pg_constraint WHERE conname='user_achievements_achievement_id_check' AND conrelid='public.user_achievements'::regclass) LIKE '%ten_workouts%'
  AND (SELECT pg_get_constraintdef(oid) FROM pg_constraint WHERE conname='user_achievements_achievement_id_check' AND conrelid='public.user_achievements'::regclass) LIKE '%streak_3%'
  AND (SELECT pg_get_constraintdef(oid) FROM pg_constraint WHERE conname='user_achievements_achievement_id_check' AND conrelid='public.user_achievements'::regclass) LIKE '%streak_7%'
  AND (SELECT pg_get_constraintdef(oid) FROM pg_constraint WHERE conname='user_achievements_achievement_id_check' AND conrelid='public.user_achievements'::regclass) LIKE '%level_10%'
  AND (SELECT pg_get_constraintdef(oid) FROM pg_constraint WHERE conname='user_achievements_achievement_id_check' AND conrelid='public.user_achievements'::regclass) LIKE '%level_20%',
  'GATE 4: CHECK constraint lists all 7 catalogue IDs'
);

-- =====================================================================
-- Gate 5: Unlocks — exactly-once; core fitness ungated behind unlocks.
-- =====================================================================
-- Core fitness remains ungated: all five completions succeed while the
-- server grants only verified, applicable unlocks.
SELECT public.p5_assert(
  (SELECT count(*) FROM public.workout_rewards WHERE user_id='99999999-9999-9999-9999-999999999999') = 5,
  'GATE 5: all five workouts completed with rewards (core fitness ungated)'
);
SELECT public.p5_assert(
  (SELECT count(*) FROM public.user_unlocks WHERE user_id='99999999-9999-9999-9999-999999999999') = 1,
  'GATE 5: first-workout badge unlocked during completion; higher milestones remain locked'
);

-- The server earned this unlock exactly once.
SELECT public.p5_assert(
  (SELECT count(*) FROM public.user_unlocks WHERE user_id='99999999-9999-9999-9999-999999999999' AND unlock_id='badge_first_workout') = 1,
  'GATE 5: badge_first_workout unlock earned exactly once'
);
-- Duplicate unlock blocked by PRIMARY KEY (user_id, unlock_id).
SELECT public.p5_denied(
  $q$INSERT INTO public.user_unlocks(user_id,unlock_id) VALUES('99999999-9999-9999-9999-999999999999','badge_first_workout')$q$,
  '23505'
);

-- =====================================================================
-- Gate 1: Unified progression structure; Gate 8: dashboard values.
-- =====================================================================
SELECT public.p5_assert(
  (SELECT public.get_player_progression()->>'userId') = '99999999-9999-9999-9999-999999999999',
  'GATE 1: progression.userId equals the owner'
);
SELECT public.p5_assert(
  (SELECT public.get_player_progression()->>'level') = '2',
  'GATE 1/8: progression.level = 2'
);
SELECT public.p5_assert(
  (SELECT public.get_player_progression()->>'totalXP') = '170',
  'GATE 8: progression.totalXP matches users.total_xp (170)'
);
SELECT public.p5_assert(
  (SELECT public.get_player_progression()->'streak'->>'current_streak')::integer = 2,
  'GATE 8: progression.streak matches streaks.current_streak'
);
SELECT public.p5_assert(
  jsonb_typeof(public.get_player_progression()->'achievements') = 'array'
  AND jsonb_typeof(public.get_player_progression()->'classes') = 'array',
  'GATE 1: progression achievements and classes are arrays'
);
SELECT public.p5_assert(
  EXISTS(SELECT 1 FROM jsonb_array_elements(public.get_player_progression()->'achievements') a WHERE a->>'achievement_id' = 'first_workout')
  AND EXISTS(SELECT 1 FROM jsonb_array_elements(public.get_player_progression()->'achievements') a WHERE a->>'achievement_id' = 'five_workouts'),
  'GATE 8: progression achievements include first_workout and five_workouts'
);
SELECT public.p5_assert(
  public.get_player_progression()->>'activeQuest' IS NULL,
  'GATE 8: activeQuest is null after the quest was completed'
);
SELECT public.p5_assert(
  (SELECT public.get_player_progression()->'nextUnlock'->>'unlockId') = 'title_level_10',
  'GATE 8: nextUnlock is the next locked level milestone (title_level_10)'
);

-- =====================================================================
-- Gate 9: Focused security + regression (cross-user context).
-- =====================================================================
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub','88888888-8888-8888-8888-888888888888',true);
SELECT set_config('request.jwt.claims','{"sub":"88888888-8888-8888-8888-888888888888","role":"authenticated"}',true);

-- Owner-scoped only: the RPC returns the session user's own state, never the owner's.
SELECT public.p5_assert(
  (SELECT public.get_player_progression()->>'userId') = '88888888-8888-8888-8888-888888888888',
  'GATE 9: get_player_progression is owner-scoped (returns other user id)'
);
SELECT public.p5_assert(
  jsonb_array_length(public.get_player_progression()->'achievements') = 0,
  'GATE 9: other user has no achievements in their own progression'
);

-- Cross-user reads return nothing for the owner's game rows.
SELECT public.p5_assert(
  (SELECT count(*) FROM public.user_achievements WHERE user_id='99999999-9999-9999-9999-999999999999') = 0,
  'GATE 9: other user sees no owner achievements'
);
SELECT public.p5_assert(
  (SELECT count(*) FROM public.user_unlocks WHERE user_id='99999999-9999-9999-9999-999999999999') = 0,
  'GATE 9: other user sees no owner unlocks'
);
SELECT public.p5_assert(
  (SELECT count(*) FROM public.quest_instances WHERE user_id='99999999-9999-9999-9999-999999999999') = 0,
  'GATE 9: other user sees no owner quests'
);
SELECT public.p5_assert(
  (SELECT count(*) FROM public.streaks WHERE user_id='99999999-9999-9999-9999-999999999999') = 0,
  'GATE 9: other user sees no owner streaks'
);

-- Cross-user writes are denied.
SELECT public.p5_denied(
  $q$INSERT INTO public.user_achievements(user_id,achievement_id) VALUES('99999999-9999-9999-9999-999999999999','first_workout')$q$
);
SELECT public.p5_denied(
  $q$INSERT INTO public.user_unlocks(user_id,unlock_id) VALUES('99999999-9999-9999-9999-999999999999','badge_first_workout')$q$
);
SELECT public.p5_denied(
  $q$UPDATE public.streaks SET current_streak = 999 WHERE user_id = '99999999-9999-9999-9999-999999999999'$q$
);
SELECT public.p5_denied(
  $q$UPDATE public.quest_instances SET status = 'completed', earned_xp = 9999 WHERE user_id = '99999999-9999-9999-9999-999999999999'$q$
);
SELECT public.p5_denied(
  $q$SELECT public.complete_workout('22222222-2222-2222-2222-222222222222')$q$
);

-- No arbitrary client XP mutation (even the owner cannot write total_xp directly).
SELECT set_config('request.jwt.claim.sub','99999999-9999-9999-9999-999999999999',true);
SELECT public.p5_denied(
  $q$UPDATE public.users SET total_xp = 999999 WHERE id = '99999999-9999-9999-9999-999999999999'$q$
);

-- Unauthenticated context is rejected by the progression RPC.
SELECT set_config('request.jwt.claim.sub','',true);
SELECT set_config('request.jwt.claims','{}',true);
SELECT public.p5_denied('SELECT public.get_player_progression()');

RESET ROLE;
ROLLBACK;
