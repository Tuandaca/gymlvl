-- P9.2 full custom-definition restore contract. Fixtures roll back.
BEGIN;

CREATE FUNCTION pg_temp.p92_definition_expect(ok boolean, label text) RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
  IF ok IS DISTINCT FROM true THEN RAISE EXCEPTION 'P9.2 FAIL: %', label; END IF;
END $$;

SELECT pg_temp.p92_definition_expect(
  to_regprocedure('public.import_custom_exercise_v1(text,jsonb)') IS NOT NULL,
  'owner-scoped full custom-definition RPC exists'
);

INSERT INTO auth.users(id,email) VALUES
  ('95000000-0000-4000-8000-000000000001','p92-definition-a@example.test'),
  ('95000000-0000-4000-8000-000000000002','p92-definition-b@example.test');
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub','95000000-0000-4000-8000-000000000001',true);
SELECT set_config('request.jwt.claims','{"sub":"95000000-0000-4000-8000-000000000001","role":"authenticated"}',true);
SELECT public.initialize_user('{"environment":"gym","goals":["hypertrophy"],"experience_level":"beginner","age":25,"gender":"other","height_cm":170,"weight_kg":65,"preferred_training_days":["mon","wed","fri"],"primary_class_id":"B"}'::jsonb);

DO $$
DECLARE
  owner_a uuid := '95000000-0000-4000-8000-000000000001';
  owner_b uuid := '95000000-0000-4000-8000-000000000002';
  custom_id uuid := '95000000-0000-4000-8000-000000000011';
  empty_name_id uuid := '95000000-0000-4000-8000-000000000012';
  slug_collision_id uuid := '95000000-0000-4000-8000-000000000013';
  payload jsonb;
  workout_payload jsonb;
  receipt jsonb;
  imported_workout_id uuid;
  denied boolean;
BEGIN
  payload := jsonb_build_object(
    'id',custom_id,
    'name','Archived Owner Row',
    'category','Back',
    'equipment','Dumbbell',
    'force_type','Pull',
    'mechanic','Compound',
    'instructions',jsonb_build_array('Keep spine neutral'),
    'slug','owner-restored-row',
    'name_vi','Bài tập riêng',
    'name_en','Owner Row',
    'movement_pattern','pull',
    'secondary_muscles',jsonb_build_array('Biceps'),
    'difficulty','beginner',
    'form_cues',jsonb_build_array('Brace'),
    'common_mistakes',jsonb_build_array('Swinging'),
    'alternative_exercise_slugs',jsonb_build_array('row'),
    'is_archived',true
  );
  receipt := public.import_custom_exercise_v1('p92-definition-key',payload);
  PERFORM pg_temp.p92_definition_expect(
    (receipt->>'exerciseId')::uuid=custom_id AND
    (receipt->>'alreadyImported')::boolean=false AND
    (receipt->>'created')::boolean=true AND
    EXISTS (SELECT 1 FROM public.exercises e WHERE e.id=custom_id AND e.user_id=owner_a
      AND e.source='user' AND e.is_archived AND e.slug='owner-restored-row'
      AND e.name_vi='Bài tập riêng' AND e.name_en='Owner Row'
      AND e.movement_pattern='pull' AND e.secondary_muscles=ARRAY['Biceps']::text[]
      AND e.form_cues=ARRAY['Brace']::text[]
      AND e.common_mistakes=ARRAY['Swinging']::text[]
      AND e.alternative_exercise_slugs=ARRAY['row']::text[]
      AND e.image_url IS NULL AND e.external_id IS NULL AND e.source_revision IS NULL),
    'full archived custom text is restored without media or provenance');

  receipt := public.import_custom_exercise_v1('p92-definition-key',payload);
  PERFORM pg_temp.p92_definition_expect(
    (receipt->>'exerciseId')::uuid=custom_id AND
    (receipt->>'alreadyImported')::boolean=true AND
    (receipt->>'created')::boolean=true AND
    (SELECT count(*)=1 FROM public.exercises WHERE id=custom_id),
    'exact full-definition retry is idempotent');

  receipt := public.import_custom_exercise_v1('p92-definition-existing-key',payload);
  PERFORM pg_temp.p92_definition_expect(
    (receipt->>'exerciseId')::uuid=custom_id AND
    (receipt->>'alreadyImported')::boolean=false AND
    (receipt->>'created')::boolean=false AND
    (SELECT count(*)=1 FROM public.exercises WHERE id=custom_id),
    'identical pre-existing owner definition is reused without new-row count');
  receipt := public.import_custom_exercise_v1('p92-definition-existing-key',payload);
  PERFORM pg_temp.p92_definition_expect(
    (receipt->>'exerciseId')::uuid=custom_id AND
    (receipt->>'alreadyImported')::boolean=true AND
    (receipt->>'created')::boolean=false,
    'reuse receipt preserves created=false on exact retry');

  denied := false;
  BEGIN
    PERFORM public.import_custom_exercise_v1('p92-definition-key',
      jsonb_set(payload,'{name}','"Changed Name"'::jsonb));
  EXCEPTION WHEN SQLSTATE '22023' THEN denied := true;
  END;
  PERFORM pg_temp.p92_definition_expect(denied AND
    (SELECT name='Archived Owner Row' FROM public.exercises WHERE id=custom_id),
    'same key changed definition conflicts without overwrite');

  denied := false;
  BEGIN
    PERFORM public.import_custom_exercise_v1('p92-definition-new-key',
      jsonb_set(payload,'{name}','"Changed Name"'::jsonb));
  EXCEPTION WHEN SQLSTATE '22023' OR unique_violation THEN denied := true;
  END;
  PERFORM pg_temp.p92_definition_expect(denied AND
    (SELECT name='Archived Owner Row' FROM public.exercises WHERE id=custom_id),
    'same owner UUID collision never overwrites a different definition');

  denied := false;
  BEGIN
    PERFORM public.import_custom_exercise_v1('p92-definition-media',
      jsonb_set(payload,'{image_url}','"https://example.invalid/media.jpg"'::jsonb));
  EXCEPTION WHEN SQLSTATE '22023' THEN denied := true;
  END;
  PERFORM pg_temp.p92_definition_expect(denied,
    'custom definition rejects media field');

  receipt := public.import_custom_exercise_v1('p92-empty-name-en',
    jsonb_set(jsonb_set(jsonb_set(payload,'{id}',to_jsonb(empty_name_id)),
      '{slug}','"owner-empty-name-en"'::jsonb),'{name_en}','""'::jsonb));
  PERFORM pg_temp.p92_definition_expect(
    (receipt->>'exerciseId')::uuid=empty_name_id AND
    (SELECT name_en='' FROM public.exercises WHERE id=empty_name_id),
    'explicit empty name_en survives full-definition restore');
  receipt := public.import_custom_exercise_v1('p92-empty-name-en',
    jsonb_set(jsonb_set(jsonb_set(payload,'{id}',to_jsonb(empty_name_id)),
      '{slug}','"owner-empty-name-en"'::jsonb),'{name_en}','""'::jsonb));
  PERFORM pg_temp.p92_definition_expect(
    (receipt->>'exerciseId')::uuid=empty_name_id AND
    (receipt->>'alreadyImported')::boolean=true AND
    (SELECT name_en='' FROM public.exercises WHERE id=empty_name_id),
    'empty name_en remains exact on retry');

  denied := false;
  BEGIN
    PERFORM public.import_custom_exercise_v1('p92-slug-collision',
      jsonb_set(payload,'{id}',to_jsonb(slug_collision_id)));
  EXCEPTION WHEN SQLSTATE '22023' OR unique_violation THEN denied := true;
  END;
  PERFORM pg_temp.p92_definition_expect(denied AND
    NOT EXISTS (SELECT 1 FROM public.exercises WHERE id=slug_collision_id),
    'same-owner slug collision cannot silently rewrite a definition');

  workout_payload := jsonb_build_object(
    'started_at','2026-11-01T10:00:00Z',
    'completed_at','2026-11-01T11:00:00Z',
    'duration_seconds',3600,
    'exercises',jsonb_build_array(jsonb_build_object(
      'exercise_id',custom_id,'order_index',0,
      'sets',jsonb_build_array(jsonb_build_object('set_number',1,'reps',10,
        'weight_kg',20,'duration_seconds',0,'set_type','workout'))
    ))
  );
  receipt := public.import_historical_workout_v1('p92-archived-custom-link',workout_payload);
  imported_workout_id := (receipt->>'workoutId')::uuid;
  PERFORM pg_temp.p92_definition_expect(
    EXISTS (SELECT 1 FROM public.workout_exercises WHERE workout_id=imported_workout_id
      AND exercise_id=custom_id) AND
    (SELECT is_archived FROM public.exercises WHERE id=custom_id),
    'archived custom remains archived and usable in historical workout');

  UPDATE public.exercises SET name='Owner Edited Row', is_archived=false
    WHERE id=custom_id;
  PERFORM pg_temp.p92_definition_expect(
    (SELECT name='Owner Edited Row' AND is_archived=false
      FROM public.exercises WHERE id=custom_id),
    'owner can update custom definition after restore');
  receipt := public.import_custom_exercise_v1('p92-definition-key',payload);
  PERFORM pg_temp.p92_definition_expect(
    (receipt->>'exerciseId')::uuid=custom_id AND
    (receipt->>'alreadyImported')::boolean=true AND
    (receipt->>'created')::boolean=true AND
    (SELECT name='Owner Edited Row' AND is_archived=false
      FROM public.exercises WHERE id=custom_id),
    'exact import replay returns stored receipt without overwriting owner edits');

  PERFORM set_config('request.jwt.claim.sub',owner_b::text,true);
  PERFORM set_config('request.jwt.claims',
    json_build_object('sub',owner_b::text,'role','authenticated')::text,true);
  PERFORM public.initialize_user('{"environment":"gym","goals":["hypertrophy"],"experience_level":"beginner","age":25,"gender":"other","height_cm":170,"weight_kg":65,"preferred_training_days":["mon","wed","fri"],"primary_class_id":"B"}'::jsonb);
  denied := false;
  BEGIN
    PERFORM public.import_custom_exercise_v1('p92-cross-owner-collision',payload);
  EXCEPTION WHEN SQLSTATE '22023' OR unique_violation OR insufficient_privilege THEN denied := true;
  END;
  PERFORM pg_temp.p92_definition_expect(denied AND
    NOT EXISTS (SELECT 1 FROM public.exercises WHERE id=custom_id),
    'another owner cannot claim custom UUID or read its private row');
END $$;

ROLLBACK;
