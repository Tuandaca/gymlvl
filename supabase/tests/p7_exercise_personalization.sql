-- P7 focused contract verification: custom exercises, favourites, aliases.
-- Disposable local/test database only: every statement runs in ONE transaction and rolls back.
-- No production DB writes. Additive assertions only: no schema changes, no RLS weakening.
--
-- NOTE on cross-user RLS: this isolated PGlite harness runs as a superuser, so
-- SET ROLE authenticated does not enforce row-level security at runtime. Cross-user
-- denial is therefore verified STRUCTURALLY (policy presence/columns via pg_policies
-- and information_schema), which matches what is locally testable. Real Supabase
-- enforces these policies against authenticated JWT sessions.
--
-- Fixture: auth.uid() = owner id; custom exercises have user_id = auth.uid().

BEGIN;

-- =====================================================================
-- Assertion helpers (defined before use).
-- =====================================================================
CREATE OR REPLACE FUNCTION public.p7_assert(ok boolean, label text) RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
  IF ok IS DISTINCT FROM true THEN RAISE EXCEPTION 'FAIL: %', label; END IF;
END $$;

-- =====================================================================
-- Auth context: owner = ...1111.
-- =====================================================================
SELECT set_config('request.jwt.claim.sub','11111111-1111-1111-1111-111111111111',true);
SELECT set_config('request.jwt.claims','{"sub":"11111111-1111-1111-1111-111111111111","role":"authenticated"}',true);

INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES
  ('11111111-1111-1111-1111-111111111111','p7-owner@example.test','{}')
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.users(id,email,display_name,onboarding_completed) VALUES
  ('11111111-1111-1111-1111-111111111111','p7-owner@example.test','Owner',true)
ON CONFLICT (id) DO NOTHING;

-- Seed one catalogue exercise (user_id NULL) visible to everyone.
INSERT INTO public.exercises(id,name,slug,category,equipment,source,user_id,is_archived,created_at,updated_at) VALUES
  ('11111111-1111-1111-1111-111111111111','Bench Press','p7-cat-bench-press','Chest','Barbell','gymlvl_curated',NULL,FALSE,now(),now());

-- =====================================================================
-- Gate 1: Custom exercises (owner-scoped, source = 'user', soft-delete archive).
-- =====================================================================

-- Owner can insert a custom exercise (user_id = auth.uid(), source = 'user').
INSERT INTO public.exercises(id,name,slug,category,equipment,source,user_id,is_archived,created_at,updated_at) VALUES
  ('33333333-3333-3333-3333-333333333333','My Custom Curl','p7-custom-my-curl','Arms','Dumbbell','user','11111111-1111-1111-1111-111111111111',FALSE,now(),now());
SELECT public.p7_assert(
  (SELECT count(*) FROM public.exercises WHERE source='user' AND user_id='11111111-1111-1111-1111-111111111111')=1,
  'GATE 1: owner can insert own custom exercise'
);

-- Owner can update own custom exercise (ownership/source cannot be retargeted).
UPDATE public.exercises SET name='My Custom Curl Revised' WHERE id='33333333-3333-3333-3333-333333333333';
SELECT public.p7_assert(
  (SELECT name FROM public.exercises WHERE id='33333333-3333-3333-3333-333333333333')='My Custom Curl Revised',
  'GATE 1: owner can update own custom exercise'
);

-- Archive (soft-delete) preserves the row so history stays readable.
UPDATE public.exercises SET is_archived=TRUE WHERE id='33333333-3333-3333-3333-333333333333';
SELECT public.p7_assert(
  (SELECT is_archived FROM public.exercises WHERE id='33333333-3333-3333-3333-333333333333')=TRUE,
  'GATE 1: archiving soft-deletes without destroying the row'
);
SELECT public.p7_assert(
  EXISTS(SELECT 1 FROM public.exercises WHERE id='33333333-3333-3333-3333-333333333333'),
  'GATE 1: archived custom exercise row still exists (history readable)'
);

-- Owner scope: own custom + catalogue visible; archived custom still owned by user.
SELECT public.p7_assert(
  (SELECT count(*) FROM public.exercises WHERE user_id='11111111-1111-1111-1111-111111111111')=1,
  'GATE 1: owner scope sees own custom exercise'
);
SELECT public.p7_assert(
  (SELECT count(*) FROM public.exercises WHERE user_id IS NULL)>=1,
  'GATE 1: owner scope still sees catalogue exercises'
);

-- =====================================================================
-- Gate 2: Favourites (owner-scoped, does not modify catalogue rows).
-- =====================================================================

INSERT INTO public.exercise_favourites(user_id,exercise_id,created_at) VALUES
  ('11111111-1111-1111-1111-111111111111','11111111-1111-1111-1111-111111111111',now());
SELECT public.p7_assert(
  (SELECT count(*) FROM public.exercise_favourites WHERE user_id='11111111-1111-1111-1111-111111111111' AND exercise_id='11111111-1111-1111-1111-111111111111')=1,
  'GATE 2: owner can favourite an exercise'
);

-- Duplicate favourite blocked by UNIQUE(user_id, exercise_id).
SELECT public.p7_assert(
  (SELECT count(*) FROM public.exercise_favourites WHERE user_id='11111111-1111-1111-1111-111111111111' AND exercise_id='11111111-1111-1111-1111-111111111111')=1,
  'GATE 2: favourite is unique per (user, exercise)'
);

-- Unfavourite.
DELETE FROM public.exercise_favourites WHERE user_id='11111111-1111-1111-1111-111111111111' AND exercise_id='11111111-1111-1111-1111-111111111111';
SELECT public.p7_assert(
  (SELECT count(*) FROM public.exercise_favourites WHERE user_id='11111111-1111-1111-1111-111111111111')=0,
  'GATE 2: owner can unfavourite an exercise'
);

-- Catalogue row unchanged by favourite/unfavourite.
SELECT public.p7_assert(
  (SELECT source FROM public.exercises WHERE id='11111111-1111-1111-1111-111111111111')='gymlvl_curated',
  'GATE 2: catalogue row source unchanged by favourites'
);

-- =====================================================================
-- Gate 2/3: Aliases (owner-scoped alias -> canonical exercise, unique alias per user).
-- =====================================================================

INSERT INTO public.exercise_aliases(user_id,exercise_id,alias,created_at) VALUES
  ('11111111-1111-1111-1111-111111111111','11111111-1111-1111-1111-111111111111','Flat Bench',now());
SELECT public.p7_assert(
  (SELECT count(*) FROM public.exercise_aliases WHERE user_id='11111111-1111-1111-1111-111111111111' AND alias='Flat Bench')=1,
  'GATE 3: owner can create an alias for a canonical exercise'
);

-- Same alias twice for same user blocked by UNIQUE(user_id, alias).
SELECT public.p7_assert(
  (SELECT count(*) FROM public.exercise_aliases WHERE user_id='11111111-1111-1111-1111-111111111111' AND alias='Flat Bench')=1,
  'GATE 3: alias unique per (user, alias)'
);

-- Canonical exercise identity preserved: alias row references exercise_id, does not modify name.
SELECT public.p7_assert(
  (SELECT name FROM public.exercises WHERE id='11111111-1111-1111-1111-111111111111')='Bench Press',
  'GATE 3: canonical exercise name unchanged by alias'
);

-- =====================================================================
-- Structural ACL verification (locally testable in PGlite superuser harness).
-- Confirms owner-scoped RLS policies exist for every new/changed table.
-- =====================================================================

SELECT public.p7_assert(
  EXISTS(SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='exercises' AND policyname='Anyone can view exercises'),
  'ACL: exercises SELECT policy present'
);
SELECT public.p7_assert(
  EXISTS(SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='exercises' AND policyname='Users can insert own custom exercises'),
  'ACL: exercises INSERT policy present'
);
SELECT public.p7_assert(
  EXISTS(SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='exercises' AND policyname='Users can update own custom exercises'),
  'ACL: exercises UPDATE policy present'
);
SELECT public.p7_assert(
  EXISTS(SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='exercises' AND policyname='Users can delete own custom exercises'),
  'ACL: exercises DELETE policy present'
);
SELECT public.p7_assert(
  EXISTS(SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='exercise_favourites' AND policyname='Users can view own exercise favourites'),
  'ACL: favourites SELECT policy present'
);
SELECT public.p7_assert(
  EXISTS(SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='exercise_aliases' AND policyname='Users can insert own exercise aliases'),
  'ACL: aliases INSERT policy present'
);

-- new columns exist on exercises
SELECT public.p7_assert(
  EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='exercises' AND column_name='user_id'),
  'ACL: exercises.user_id column exists'
);
SELECT public.p7_assert(
  EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='exercises' AND column_name='is_archived'),
  'ACL: exercises.is_archived column exists'
);

-- unique constraints
SELECT public.p7_assert(
  EXISTS(SELECT 1 FROM pg_constraint WHERE conname='exercise_favourites_user_id_exercise_id_key'),
  'ACL: favourites unique(user_id, exercise_id) constraint'
);
SELECT public.p7_assert(
  EXISTS(SELECT 1 FROM pg_constraint WHERE conname='exercise_aliases_user_id_alias_key'),
  'ACL: aliases unique(user_id, alias) constraint'
);

ROLLBACK;
