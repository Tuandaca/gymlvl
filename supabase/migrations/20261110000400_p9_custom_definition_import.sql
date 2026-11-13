-- P9.2: restore one same-account custom exercise definition atomically.
-- This RPC owns no catalogue media or external provenance and never overwrites
-- a UUID or slug collision. Keep the private receipt with restored user data.

CREATE TABLE IF NOT EXISTS public.custom_exercise_imports (
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  import_key text NOT NULL,
  payload_digest text NOT NULL,
  exercise_id uuid NOT NULL REFERENCES public.exercises(id) ON DELETE CASCADE,
  created boolean NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id,import_key)
);
ALTER TABLE public.custom_exercise_imports ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.custom_exercise_imports FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.import_custom_exercise_v1(
  p_import_key text, p_payload jsonb
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE
  uid uuid := auth.uid();
  existing_receipt public.custom_exercise_imports;
  existing_exercise public.exercises;
  digest text;
  eid uuid;
  field_name text;
  text_value text;
  instructions_value text[];
  secondary_value text[];
  cues_value text[];
  mistakes_value text[];
  alternatives_value text[];
  created_now boolean := false;
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE='42501';
  END IF;
  IF p_import_key IS NULL OR length(p_import_key) NOT BETWEEN 1 AND 128
     OR p_import_key <> btrim(p_import_key)
     OR p_import_key ~ '[[:cntrl:]]' THEN
    RAISE EXCEPTION 'Invalid custom import key' USING ERRCODE='22023';
  END IF;
  IF jsonb_typeof(p_payload) IS DISTINCT FROM 'object'
     OR octet_length(p_payload::text) > 32768 THEN
    RAISE EXCEPTION 'Invalid custom definition' USING ERRCODE='22023';
  END IF;
  IF EXISTS (SELECT 1 FROM jsonb_object_keys(p_payload) k WHERE k NOT IN
    ('id','name','category','equipment','force_type','mechanic','instructions',
     'slug','name_vi','name_en','movement_pattern','secondary_muscles',
     'difficulty','form_cues','common_mistakes','alternative_exercise_slugs',
     'is_archived'))
     OR NOT p_payload ?& ARRAY[
      'id','name','category','equipment','force_type','mechanic','instructions',
      'slug','name_vi','name_en','movement_pattern','secondary_muscles',
      'difficulty','form_cues','common_mistakes','alternative_exercise_slugs',
      'is_archived'] THEN
    RAISE EXCEPTION 'Invalid custom definition fields' USING ERRCODE='22023';
  END IF;
  IF jsonb_typeof(p_payload->'id') IS DISTINCT FROM 'string'
     OR jsonb_typeof(p_payload->'name') IS DISTINCT FROM 'string'
     OR jsonb_typeof(p_payload->'category') IS DISTINCT FROM 'string'
     OR jsonb_typeof(p_payload->'equipment') IS DISTINCT FROM 'string'
     OR jsonb_typeof(p_payload->'slug') IS DISTINCT FROM 'string'
     OR jsonb_typeof(p_payload->'name_vi') IS DISTINCT FROM 'string'
     OR jsonb_typeof(p_payload->'name_en') IS DISTINCT FROM 'string'
     OR jsonb_typeof(p_payload->'is_archived') IS DISTINCT FROM 'boolean' THEN
    RAISE EXCEPTION 'Invalid custom definition types' USING ERRCODE='22023';
  END IF;
  FOREACH field_name IN ARRAY ARRAY['force_type','mechanic','movement_pattern','difficulty'] LOOP
    IF jsonb_typeof(p_payload->field_name) NOT IN ('string','null') THEN
      RAISE EXCEPTION 'Invalid custom definition type' USING ERRCODE='22023';
    END IF;
  END LOOP;
  FOREACH field_name IN ARRAY ARRAY['name','category','equipment','slug','name_vi',
    'name_en','force_type','mechanic','movement_pattern','difficulty'] LOOP
    text_value := p_payload->>field_name;
    IF text_value IS NOT NULL AND
       (length(text_value)>500 OR text_value ~ '[[:cntrl:]]') THEN
      RAISE EXCEPTION 'Invalid custom definition text' USING ERRCODE='22023';
    END IF;
  END LOOP;
  IF length(p_payload->>'name') NOT BETWEEN 1 AND 200
     OR length(p_payload->>'category') NOT BETWEEN 1 AND 100
     OR length(p_payload->>'equipment') NOT BETWEEN 1 AND 100
     OR length(p_payload->>'slug') NOT BETWEEN 1 AND 200
     OR (p_payload->>'name') <> btrim(p_payload->>'name')
     OR (p_payload->>'category') <> btrim(p_payload->>'category')
     OR (p_payload->>'equipment') <> btrim(p_payload->>'equipment')
     OR (p_payload->>'slug') <> btrim(p_payload->>'slug') THEN
    RAISE EXCEPTION 'Invalid custom definition text' USING ERRCODE='22023';
  END IF;
  FOREACH field_name IN ARRAY ARRAY['instructions','secondary_muscles',
    'form_cues','common_mistakes','alternative_exercise_slugs'] LOOP
    IF jsonb_typeof(p_payload->field_name) IS DISTINCT FROM 'array' THEN
      RAISE EXCEPTION 'Invalid custom definition array' USING ERRCODE='22023';
    END IF;
    IF jsonb_array_length(p_payload->field_name)>50 OR EXISTS (
      SELECT 1 FROM jsonb_array_elements(p_payload->field_name) v
      WHERE jsonb_typeof(v) <> 'string'
         OR length(v #>> '{}')>500 OR (v #>> '{}') ~ '[[:cntrl:]]'
    ) THEN
      RAISE EXCEPTION 'Invalid custom definition array' USING ERRCODE='22023';
    END IF;
  END LOOP;
  BEGIN
    eid := (p_payload->>'id')::uuid;
  EXCEPTION WHEN invalid_text_representation THEN
    RAISE EXCEPTION 'Invalid custom exercise UUID' USING ERRCODE='22023';
  END;
  instructions_value := ARRAY(SELECT jsonb_array_elements_text(p_payload->'instructions'));
  secondary_value := ARRAY(SELECT jsonb_array_elements_text(p_payload->'secondary_muscles'));
  cues_value := ARRAY(SELECT jsonb_array_elements_text(p_payload->'form_cues'));
  mistakes_value := ARRAY(SELECT jsonb_array_elements_text(p_payload->'common_mistakes'));
  alternatives_value := ARRAY(SELECT jsonb_array_elements_text(p_payload->'alternative_exercise_slugs'));
  digest := encode(sha256(convert_to(p_payload::text,'UTF8')),'hex');
  PERFORM 1 FROM public.users WHERE id=uid AND onboarding_completed FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Complete onboarding first' USING ERRCODE='42501'; END IF;
  SELECT * INTO existing_receipt FROM public.custom_exercise_imports
    WHERE user_id=uid AND import_key=p_import_key FOR UPDATE;
  IF existing_receipt.exercise_id IS NOT NULL THEN
    IF existing_receipt.payload_digest <> digest OR existing_receipt.exercise_id <> eid THEN
      RAISE EXCEPTION 'Custom import key already used for different content' USING ERRCODE='22023';
    END IF;
    -- The owner may edit or archive the exercise after a successful import.
    -- A retry returns the original receipt without replacing those later edits.
    RETURN jsonb_build_object('exerciseId',eid,'alreadyImported',true,
      'created',existing_receipt.created);
  END IF;
  SELECT * INTO existing_exercise FROM public.exercises WHERE id=eid FOR UPDATE;
  IF FOUND THEN
    IF existing_exercise.user_id IS DISTINCT FROM uid
       OR existing_exercise.source <> 'user'
       OR existing_exercise.image_url IS NOT NULL
       OR existing_exercise.external_id IS NOT NULL
       OR existing_exercise.source_revision IS NOT NULL
       OR ROW(existing_exercise.name,existing_exercise.category,
         existing_exercise.equipment,existing_exercise.force_type,
         existing_exercise.mechanic,existing_exercise.instructions,
         existing_exercise.slug,existing_exercise.name_vi,existing_exercise.name_en,
         existing_exercise.movement_pattern,existing_exercise.secondary_muscles,
         existing_exercise.difficulty,existing_exercise.form_cues,
         existing_exercise.common_mistakes,existing_exercise.alternative_exercise_slugs,
         existing_exercise.is_archived)
       IS DISTINCT FROM ROW(
         p_payload->>'name',p_payload->>'category',p_payload->>'equipment',
         p_payload->>'force_type',p_payload->>'mechanic',instructions_value,
         p_payload->>'slug',p_payload->>'name_vi',p_payload->>'name_en',
         p_payload->>'movement_pattern',secondary_value,p_payload->>'difficulty',
         cues_value,mistakes_value,alternatives_value,
         (p_payload->>'is_archived')::boolean) THEN
      RAISE EXCEPTION 'Custom exercise UUID has a different definition' USING ERRCODE='22023';
    END IF;
  ELSE
    INSERT INTO public.exercises(id,user_id,source,is_archived,name,category,
      equipment,force_type,mechanic,instructions,slug,name_vi,name_en,
      movement_pattern,secondary_muscles,difficulty,form_cues,common_mistakes,
      alternative_exercise_slugs,external_id,source_revision,image_url)
    VALUES(eid,uid,'user',(p_payload->>'is_archived')::boolean,
      p_payload->>'name',p_payload->>'category',p_payload->>'equipment',
      p_payload->>'force_type',p_payload->>'mechanic',instructions_value,
      p_payload->>'slug',p_payload->>'name_vi',p_payload->>'name_en',
      p_payload->>'movement_pattern',secondary_value,p_payload->>'difficulty',
      cues_value,mistakes_value,alternatives_value,NULL,NULL,NULL);
    -- The legacy INSERT trigger fills an empty name_en. Restore the explicit
    -- untranslated value without altering the catalogue-wide trigger.
    IF p_payload->>'name_en' = '' THEN
      UPDATE public.exercises SET name_en='' WHERE id=eid;
    END IF;
    created_now := true;
  END IF;
  INSERT INTO public.custom_exercise_imports(user_id,import_key,payload_digest,
    exercise_id,created)
    VALUES(uid,p_import_key,digest,eid,created_now);
  RETURN jsonb_build_object('exerciseId',eid,'alreadyImported',false,
    'created',created_now);
END $$;

REVOKE ALL ON FUNCTION public.import_custom_exercise_v1(text,jsonb)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.import_custom_exercise_v1(text,jsonb)
  TO authenticated;
