-- P9.2: atomic, owner-scoped historical workout import without progression.
-- Recovery: stop using this RPC and ship a reviewed additive correction. Keep
-- imported history and the idempotency ledger; never delete user data to roll
-- back a client integration.

ALTER TABLE public.workouts
  ADD COLUMN IF NOT EXISTS is_imported boolean NOT NULL DEFAULT false;

CREATE TABLE IF NOT EXISTS public.historical_workout_imports (
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  import_key text NOT NULL,
  payload_digest text NOT NULL,
  workout_id uuid NOT NULL UNIQUE REFERENCES public.workouts(id) ON DELETE CASCADE,
  created_custom_exercise_ids uuid[] NOT NULL DEFAULT '{}',
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, import_key)
);
ALTER TABLE public.historical_workout_imports ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.historical_workout_imports FROM PUBLIC, anon, authenticated;

-- An imported workout is created active while its children are inserted, then
-- completed in the same transaction. Its owner may reference an archived custom
-- exercise from historical records, while interactive workouts still cannot.
CREATE OR REPLACE FUNCTION public.guard_workout_child() RETURNS trigger LANGUAGE plpgsql SET search_path='' AS $$
DECLARE wid uuid; owner_id uuid; parent_status text; eid uuid; importing boolean; BEGIN
 IF TG_OP='DELETE' AND auth.uid() IS NULL AND current_user IN ('postgres','supabase_admin','supabase_auth_admin','service_role') THEN RETURN OLD; END IF;
 IF TG_TABLE_NAME='workout_sets' THEN
  SELECT workout_id,exercise_id INTO wid,eid FROM public.workout_exercises WHERE id=CASE WHEN TG_OP='DELETE' THEN OLD.workout_exercise_id ELSE NEW.workout_exercise_id END;
  IF TG_OP='UPDATE' AND NEW.workout_exercise_id IS DISTINCT FROM OLD.workout_exercise_id THEN RAISE EXCEPTION 'A set cannot be moved to another exercise' USING ERRCODE='22023'; END IF;
 ELSE
  wid=CASE WHEN TG_OP='DELETE' THEN OLD.workout_id ELSE NEW.workout_id END;
  IF TG_OP='UPDATE' AND (NEW.workout_id IS DISTINCT FROM OLD.workout_id OR NEW.exercise_id IS DISTINCT FROM OLD.exercise_id) THEN RAISE EXCEPTION 'An exercise cannot change its session or identity' USING ERRCODE='22023'; END IF;
 END IF;
 SELECT user_id,status,is_imported INTO owner_id,parent_status,importing FROM public.workouts WHERE id=wid FOR UPDATE;
 IF owner_id IS NULL OR owner_id IS DISTINCT FROM auth.uid() OR parent_status<>'active' THEN RAISE EXCEPTION 'Workout is unavailable or already finished' USING ERRCODE='42501'; END IF;
 IF TG_TABLE_NAME='workout_exercises' AND TG_OP='INSERT' THEN
  PERFORM 1 FROM public.exercises e
   WHERE e.id=NEW.exercise_id
     AND ((e.user_id IS NULL AND e.source <> 'user')
       OR (e.user_id=owner_id AND e.source='user' AND (NOT e.is_archived OR importing)));
  IF NOT FOUND THEN RAISE EXCEPTION 'Exercise is unavailable for this workout' USING ERRCODE='42501'; END IF;
 END IF;
 IF TG_TABLE_NAME='workout_sets' AND TG_OP='INSERT' THEN
  IF NOT importing THEN
   SELECT coalesce(max_weight_kg,0) INTO NEW.baseline_weight_kg FROM public.exercise_prs WHERE user_id=owner_id AND exercise_id=eid;
  END IF;
  NEW.baseline_weight_kg=greatest(0,least(1000,coalesce(NEW.baseline_weight_kg,0)));
 ELSIF TG_TABLE_NAME='workout_sets' AND TG_OP='UPDATE' THEN
  NEW.baseline_weight_kg=OLD.baseline_weight_kg;
 END IF;
 IF TG_OP='DELETE' THEN RETURN OLD; END IF;
 RETURN NEW;
END $$;

CREATE OR REPLACE FUNCTION public.import_historical_workout_v1(
  p_import_key text, p_payload jsonb
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE
  uid uuid := auth.uid();
  existing public.historical_workout_imports;
  digest text;
  started timestamptz;
  training_started timestamptz;
  completed timestamptz;
  duration integer;
  paused_duration integer;
  source_workout_id uuid;
  wid uuid;
  weid uuid;
  exercise jsonb;
  set_data jsonb;
  eid uuid;
  mode_name text;
  set_kind text;
  exercise_number integer := 0;
  set_number integer;
  order_number integer;
  seen_orders integer[] := ARRAY[]::integer[];
  seen_sets integer[];
  reps_value integer;
  weight_value numeric;
  seconds_value integer;
  rest_value integer;
  completed_value boolean;
  exercise_notes text;
  has_manifest boolean;
  group_id uuid;
  group_position integer;
  group_locked boolean;
  group_members jsonb := '[]'::jsonb;
  group_map jsonb := '{}'::jsonb;
  group_layout jsonb;
  group_record record;
  mapped_group_id uuid;
  set_baseline numeric;
  set_rpe integer;
  set_rir integer;
  custom_descriptor jsonb;
  custom_name text;
  custom_category text;
  custom_equipment text;
  existing_exercise public.exercises;
  created_custom_ids uuid[] := ARRAY[]::uuid[];
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'Authentication required' USING ERRCODE='42501'; END IF;
  IF p_import_key IS NULL OR length(p_import_key) NOT BETWEEN 1 AND 128
     OR p_import_key <> btrim(p_import_key)
     OR p_import_key ~ '[[:cntrl:]]' THEN
    RAISE EXCEPTION 'Invalid import key' USING ERRCODE='22023';
  END IF;
  IF jsonb_typeof(p_payload) IS DISTINCT FROM 'object'
     OR octet_length(p_payload::text) > 262144
     OR EXISTS (SELECT 1 FROM jsonb_object_keys(p_payload) k
                WHERE k NOT IN ('started_at','training_started_at','completed_at',
                  'paused_at','paused_seconds','duration_seconds','notes',
                  'exercises','source_id','source_file','source_workout_id')) THEN
    RAISE EXCEPTION 'Invalid import payload' USING ERRCODE='22023';
  END IF;
  digest := encode(sha256(convert_to(p_payload::text,'UTF8')),'hex');
  -- User lock serializes imports and live reward completion for this owner.
  PERFORM 1 FROM public.users WHERE id=uid AND onboarding_completed FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Complete onboarding first' USING ERRCODE='42501'; END IF;
  SELECT * INTO existing FROM public.historical_workout_imports
    WHERE user_id=uid AND import_key=p_import_key FOR UPDATE;
  IF existing.workout_id IS NOT NULL THEN
    IF existing.payload_digest <> digest THEN
      RAISE EXCEPTION 'Import key already used for different content' USING ERRCODE='22023';
    END IF;
    RETURN jsonb_build_object('workoutId',existing.workout_id,
      'alreadyImported',true,
      'createdCustomExerciseIds',to_jsonb(existing.created_custom_exercise_ids));
  END IF;
  IF p_payload ? 'source_workout_id' THEN
    IF jsonb_typeof(p_payload->'source_workout_id') IS DISTINCT FROM 'string' THEN
      RAISE EXCEPTION 'Invalid source workout UUID' USING ERRCODE='22023';
    END IF;
    BEGIN
      source_workout_id := (p_payload->>'source_workout_id')::uuid;
    EXCEPTION WHEN invalid_text_representation THEN
      RAISE EXCEPTION 'Invalid source workout UUID' USING ERRCODE='22023';
    END;
    -- A local backup may contain a workout that is still present. Never clone
    -- that graph under a new UUID or import key. The exact-key ledger retry
    -- above remains the only exception.
    IF EXISTS (SELECT 1 FROM public.workouts
               WHERE id=source_workout_id AND user_id=uid) THEN
      RAISE EXCEPTION 'Source workout already exists' USING ERRCODE='22023';
    END IF;
  END IF;
  IF jsonb_typeof(p_payload->'started_at') IS DISTINCT FROM 'string'
     OR jsonb_typeof(p_payload->'completed_at') IS DISTINCT FROM 'string'
     OR coalesce(p_payload->>'started_at','') !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}T'
     OR coalesce(p_payload->>'completed_at','') !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}T'
     OR coalesce(p_payload->>'started_at','') !~ '(Z|[+-][0-9]{2}:[0-9]{2})$'
     OR coalesce(p_payload->>'completed_at','') !~ '(Z|[+-][0-9]{2}:[0-9]{2})$'
     OR jsonb_typeof(p_payload->'duration_seconds') IS DISTINCT FROM 'number'
     OR coalesce(p_payload->>'duration_seconds','') !~ '^[0-9]+$'
     OR (p_payload ? 'training_started_at' AND jsonb_typeof(p_payload->'training_started_at') NOT IN ('string','null'))
     OR (jsonb_typeof(p_payload->'training_started_at') = 'string' AND
         (coalesce(p_payload->>'training_started_at','') !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}T'
          OR coalesce(p_payload->>'training_started_at','') !~ '(Z|[+-][0-9]{2}:[0-9]{2})$'))
     OR (p_payload ? 'paused_at' AND jsonb_typeof(p_payload->'paused_at') IS DISTINCT FROM 'null')
     OR (p_payload ? 'paused_seconds' AND
         (jsonb_typeof(p_payload->'paused_seconds') IS DISTINCT FROM 'number'
          OR coalesce(p_payload->>'paused_seconds','') !~ '^[0-9]+$'))
     OR jsonb_typeof(p_payload->'exercises') IS DISTINCT FROM 'array'
     OR jsonb_array_length(p_payload->'exercises') NOT BETWEEN 1 AND 100
     OR (p_payload ? 'notes' AND jsonb_typeof(p_payload->'notes') NOT IN ('string','null'))
     OR length(coalesce(p_payload->>'notes','')) > 4000 THEN
    RAISE EXCEPTION 'Invalid import payload' USING ERRCODE='22023';
  END IF;
  BEGIN
    started := (p_payload->>'started_at')::timestamptz;
    training_started := CASE WHEN p_payload ? 'training_started_at'
      THEN (p_payload->>'training_started_at')::timestamptz ELSE started END;
    completed := (p_payload->>'completed_at')::timestamptz;
    duration := (p_payload->>'duration_seconds')::integer;
    paused_duration := coalesce((p_payload->>'paused_seconds')::integer,0);
  EXCEPTION WHEN invalid_datetime_format OR datetime_field_overflow OR numeric_value_out_of_range THEN
    RAISE EXCEPTION 'Invalid import timestamps or duration' USING ERRCODE='22023';
  END;
  IF completed <= started OR completed > now() + interval '5 minutes'
     OR (training_started IS NOT NULL AND
       (training_started < started OR training_started > completed))
     OR duration NOT BETWEEN 1 AND 86400
     OR paused_duration NOT BETWEEN 0 AND 86400 THEN
    RAISE EXCEPTION 'Invalid import chronology' USING ERRCODE='22023';
  END IF;
  INSERT INTO public.workouts(user_id,status,started_at,training_started_at,
    completed_at,duration_seconds,paused_seconds,notes,is_imported,is_xp_calculated)
  VALUES(uid,'active',started,training_started,NULL,0,paused_duration,
    p_payload->>'notes',true,false)
  RETURNING id INTO wid;
  FOR exercise IN SELECT value FROM jsonb_array_elements(p_payload->'exercises') LOOP
    exercise_number := exercise_number + 1;
    IF jsonb_typeof(exercise) IS DISTINCT FROM 'object'
       OR EXISTS (SELECT 1 FROM jsonb_object_keys(exercise) k
                  WHERE k NOT IN ('exercise_id','custom_exercise','order_index',
                    'mode','notes','sets','superset_group_id','superset_position',
                    'superset_locked','exercise_source','exercise_external_id',
                    'exercise_source_revision'))
       OR (exercise ? 'exercise_id') = (exercise ? 'custom_exercise')
       OR (exercise ? 'exercise_id' AND jsonb_typeof(exercise->'exercise_id') IS DISTINCT FROM 'string')
       OR (exercise ? 'custom_exercise' AND jsonb_typeof(exercise->'custom_exercise') IS DISTINCT FROM 'object')
       OR jsonb_typeof(exercise->'order_index') IS DISTINCT FROM 'number'
       OR coalesce(exercise->>'order_index','') !~ '^[0-9]+$'
       OR jsonb_typeof(exercise->'sets') IS DISTINCT FROM 'array'
       OR jsonb_array_length(exercise->'sets') NOT BETWEEN 0 AND 100
       OR (exercise ? 'superset_locked' AND
           jsonb_typeof(exercise->'superset_locked') IS DISTINCT FROM 'boolean')
       OR ((exercise->'superset_group_id' IS NOT NULL
             AND jsonb_typeof(exercise->'superset_group_id') IS DISTINCT FROM 'null')
           <> (exercise->'superset_position' IS NOT NULL
             AND jsonb_typeof(exercise->'superset_position') IS DISTINCT FROM 'null'))
       OR (exercise ? 'notes' AND jsonb_typeof(exercise->'notes') NOT IN ('string','null'))
       OR length(coalesce(exercise->>'notes','')) > 1000 THEN
      RAISE EXCEPTION 'Invalid imported exercise' USING ERRCODE='22023';
    END IF;
    BEGIN
      order_number := (exercise->>'order_index')::integer;
    EXCEPTION WHEN invalid_text_representation OR numeric_value_out_of_range THEN
      RAISE EXCEPTION 'Invalid imported exercise identity' USING ERRCODE='22023';
    END;
    IF order_number > 99 OR order_number = ANY(seen_orders) THEN
      RAISE EXCEPTION 'Invalid imported exercise order' USING ERRCODE='22023';
    END IF;
    seen_orders := array_append(seen_orders,order_number);
    mode_name := exercise->>'mode';
    IF mode_name IS NOT NULL AND mode_name NOT IN ('reps-weight','bodyweight','timed','cardio') THEN
      RAISE EXCEPTION 'Invalid imported exercise mode' USING ERRCODE='22023';
    END IF;
    exercise_notes := exercise->>'notes';
    has_manifest := exercise ? 'exercise_source'
      OR exercise ? 'exercise_external_id'
      OR exercise ? 'exercise_source_revision';
    IF has_manifest AND
       (NOT exercise ?& ARRAY['exercise_source','exercise_external_id',
          'exercise_source_revision']
        OR jsonb_typeof(exercise->'exercise_source') IS DISTINCT FROM 'string'
        OR jsonb_typeof(exercise->'exercise_external_id') NOT IN ('string','null')
        OR jsonb_typeof(exercise->'exercise_source_revision') NOT IN ('string','null')) THEN
      RAISE EXCEPTION 'Invalid imported exercise provenance' USING ERRCODE='22023';
    END IF;
    group_id := NULL;
    group_position := NULL;
    group_locked := coalesce((exercise->>'superset_locked')::boolean,false);
    IF exercise->'superset_group_id' IS NOT NULL
       AND jsonb_typeof(exercise->'superset_group_id') IS DISTINCT FROM 'null' THEN
      IF jsonb_typeof(exercise->'superset_group_id') IS DISTINCT FROM 'string'
         OR jsonb_typeof(exercise->'superset_position') IS DISTINCT FROM 'number'
         OR coalesce(exercise->>'superset_position','') !~ '^[0-9]+$' THEN
        RAISE EXCEPTION 'Invalid imported superset' USING ERRCODE='22023';
      END IF;
      BEGIN
        group_id := (exercise->>'superset_group_id')::uuid;
        group_position := (exercise->>'superset_position')::integer;
      EXCEPTION WHEN invalid_text_representation OR numeric_value_out_of_range THEN
        RAISE EXCEPTION 'Invalid imported superset' USING ERRCODE='22023';
      END;
      IF group_position > 99 THEN
        RAISE EXCEPTION 'Invalid imported superset position' USING ERRCODE='22023';
      END IF;
    ELSIF group_locked THEN
      RAISE EXCEPTION 'Ungrouped exercise cannot be superset locked' USING ERRCODE='22023';
    END IF;
    IF exercise ? 'custom_exercise' THEN
      custom_descriptor := exercise->'custom_exercise';
      IF EXISTS (SELECT 1 FROM jsonb_object_keys(custom_descriptor) k
                 WHERE k NOT IN ('id','name','category','equipment'))
         OR jsonb_typeof(custom_descriptor->'id') IS DISTINCT FROM 'string'
         OR jsonb_typeof(custom_descriptor->'name') IS DISTINCT FROM 'string'
         OR jsonb_typeof(custom_descriptor->'category') IS DISTINCT FROM 'string'
         OR jsonb_typeof(custom_descriptor->'equipment') IS DISTINCT FROM 'string' THEN
        RAISE EXCEPTION 'Invalid custom exercise descriptor' USING ERRCODE='22023';
      END IF;
      custom_name := custom_descriptor->>'name';
      custom_category := custom_descriptor->>'category';
      custom_equipment := custom_descriptor->>'equipment';
      IF length(custom_name) NOT BETWEEN 1 AND 200 OR custom_name <> btrim(custom_name)
         OR length(custom_category) NOT BETWEEN 1 AND 100 OR custom_category <> btrim(custom_category)
         OR length(custom_equipment) NOT BETWEEN 1 AND 100 OR custom_equipment <> btrim(custom_equipment)
         OR custom_name ~ '[[:cntrl:]]' OR custom_category ~ '[[:cntrl:]]'
         OR custom_equipment ~ '[[:cntrl:]]' THEN
        RAISE EXCEPTION 'Invalid custom exercise descriptor' USING ERRCODE='22023';
      END IF;
      BEGIN
        eid := (custom_descriptor->>'id')::uuid;
      EXCEPTION WHEN invalid_text_representation THEN
        RAISE EXCEPTION 'Invalid custom exercise UUID' USING ERRCODE='22023';
      END;
      SELECT * INTO existing_exercise FROM public.exercises WHERE id=eid FOR UPDATE;
      IF FOUND THEN
        IF existing_exercise.user_id IS DISTINCT FROM uid
           OR existing_exercise.source <> 'user'
           OR existing_exercise.name <> custom_name
           OR existing_exercise.category <> custom_category
           OR existing_exercise.equipment <> custom_equipment
           OR existing_exercise.external_id IS NOT NULL
           OR existing_exercise.source_revision IS NOT NULL
           OR existing_exercise.image_url IS NOT NULL THEN
          RAISE EXCEPTION 'Custom exercise UUID has a different definition' USING ERRCODE='22023';
        END IF;
      ELSE
        INSERT INTO public.exercises(id,user_id,source,is_archived,slug,name,
          category,equipment,external_id,source_revision,image_url)
        VALUES(eid,uid,'user',false,'custom-'||lower(eid::text),custom_name,
          custom_category,custom_equipment,NULL,NULL,NULL);
        -- The legacy INSERT trigger treats an untranslated name as English.
        -- Keep both locale slots empty for an unknown-language CSV label.
        UPDATE public.exercises SET name_en='' WHERE id=eid;
        created_custom_ids := array_append(created_custom_ids,eid);
      END IF;
    ELSE
      BEGIN
        eid := (exercise->>'exercise_id')::uuid;
      EXCEPTION WHEN invalid_text_representation THEN
        RAISE EXCEPTION 'Invalid imported exercise identity' USING ERRCODE='22023';
      END;
    END IF;
    -- Explicit owner check is required because this function bypasses RLS.
    IF NOT EXISTS(SELECT 1 FROM public.exercises e WHERE e.id=eid
      AND ((e.user_id IS NULL AND e.source <> 'user')
        OR (e.user_id=uid AND e.source='user'))
      AND (NOT has_manifest OR
        (e.source IS NOT DISTINCT FROM exercise->>'exercise_source'
         AND e.external_id IS NOT DISTINCT FROM exercise->>'exercise_external_id'
         AND e.source_revision IS NOT DISTINCT FROM exercise->>'exercise_source_revision'))) THEN
      RAISE EXCEPTION 'Imported exercise is unavailable' USING ERRCODE='22023';
    END IF;
    INSERT INTO public.workout_exercises(workout_id,exercise_id,order_index,mode,notes)
      VALUES(wid,eid,order_number,mode_name,exercise_notes) RETURNING id INTO weid;
    IF group_id IS NOT NULL THEN
      group_members := group_members || jsonb_build_array(jsonb_build_object(
        'group_id',group_id,'position',group_position,'weid',weid,
        'locked',group_locked));
    END IF;
    seen_sets := ARRAY[]::integer[];
    FOR set_data IN SELECT value FROM jsonb_array_elements(exercise->'sets') LOOP
      IF jsonb_typeof(set_data) IS DISTINCT FROM 'object'
         OR EXISTS (SELECT 1 FROM jsonb_object_keys(set_data) k
                    WHERE k NOT IN ('set_number','reps','weight_kg','duration_seconds',
                      'rest_seconds','is_completed','set_type','baseline_weight_kg',
                      'rpe','rir'))
         OR jsonb_typeof(set_data->'set_number') IS DISTINCT FROM 'number'
         OR coalesce(set_data->>'set_number','') !~ '^[0-9]+$'
         OR jsonb_typeof(set_data->'reps') IS DISTINCT FROM 'number'
         OR coalesce(set_data->>'reps','') !~ '^[0-9]+$'
         OR jsonb_typeof(set_data->'weight_kg') IS DISTINCT FROM 'number'
         OR jsonb_typeof(set_data->'duration_seconds') IS DISTINCT FROM 'number'
         OR coalesce(set_data->>'duration_seconds','') !~ '^[0-9]+$'
         OR (set_data ? 'rest_seconds' AND (jsonb_typeof(set_data->'rest_seconds') IS DISTINCT FROM 'number'
             OR coalesce(set_data->>'rest_seconds','') !~ '^[0-9]+$'))
         OR (set_data ? 'is_completed' AND jsonb_typeof(set_data->'is_completed') IS DISTINCT FROM 'boolean')
         OR (set_data ? 'set_type' AND jsonb_typeof(set_data->'set_type') IS DISTINCT FROM 'string') THEN
        RAISE EXCEPTION 'Invalid imported set' USING ERRCODE='22023';
      END IF;
      IF (set_data ? 'baseline_weight_kg' AND
            jsonb_typeof(set_data->'baseline_weight_kg') IS DISTINCT FROM 'number')
         OR (set_data ? 'rpe' AND jsonb_typeof(set_data->'rpe') NOT IN ('number','null'))
         OR (set_data ? 'rir' AND jsonb_typeof(set_data->'rir') NOT IN ('number','null')) THEN
        RAISE EXCEPTION 'Invalid imported set' USING ERRCODE='22023';
      END IF;
      BEGIN
        set_number := (set_data->>'set_number')::integer;
        reps_value := (set_data->>'reps')::integer;
        weight_value := (set_data->>'weight_kg')::numeric;
        seconds_value := (set_data->>'duration_seconds')::integer;
        rest_value := coalesce((set_data->>'rest_seconds')::integer,0);
        set_baseline := coalesce((set_data->>'baseline_weight_kg')::numeric,0);
        set_rpe := (set_data->>'rpe')::integer;
        set_rir := (set_data->>'rir')::integer;
      EXCEPTION WHEN numeric_value_out_of_range OR invalid_text_representation THEN
        RAISE EXCEPTION 'Invalid imported set values' USING ERRCODE='22023';
      END;
      set_kind := coalesce(set_data->>'set_type','workout');
      completed_value := coalesce((set_data->>'is_completed')::boolean,true);
      IF set_number NOT BETWEEN 1 AND 100 OR set_number = ANY(seen_sets)
         OR reps_value NOT BETWEEN 0 AND 1000
         OR weight_value NOT BETWEEN 0 AND 1000
         OR seconds_value NOT BETWEEN 0 AND 7200
         OR rest_value NOT BETWEEN 0 AND 7200
         OR set_baseline NOT BETWEEN 0 AND 1000
         OR (set_rpe IS NOT NULL AND set_rpe NOT BETWEEN 1 AND 10)
         OR (set_rir IS NOT NULL AND set_rir NOT BETWEEN 0 AND 10)
         OR set_kind NOT IN ('workout','warmup')
         OR (completed_value AND reps_value=0 AND seconds_value=0) THEN
        RAISE EXCEPTION 'Invalid imported set values' USING ERRCODE='22023';
      END IF;
      seen_sets := array_append(seen_sets,set_number);
      INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,
        duration_seconds,rest_seconds,is_completed,set_type,
        baseline_weight_kg,rpe,rir)
      VALUES(weid,set_number,reps_value,weight_value,seconds_value,rest_value,
        completed_value,set_kind,set_baseline,set_rpe,set_rir);
    END LOOP;
  END LOOP;
  FOR group_record IN
    SELECT gm.group_id, count(*)::integer AS member_count,
      min(gm.position) AS min_position, max(gm.position) AS max_position,
      count(DISTINCT gm.position)::integer AS distinct_positions,
      count(DISTINCT gm.locked)::integer AS distinct_locks
    FROM jsonb_to_recordset(group_members) AS gm(
      group_id uuid,position integer,weid uuid,locked boolean)
    GROUP BY gm.group_id
  LOOP
    IF group_record.member_count < 2 OR group_record.min_position <> 0
       OR group_record.max_position <> group_record.member_count-1
       OR group_record.distinct_positions <> group_record.member_count
       OR group_record.distinct_locks <> 1 THEN
      RAISE EXCEPTION 'Invalid imported superset layout' USING ERRCODE='22023';
    END IF;
    mapped_group_id := pg_catalog.gen_random_uuid();
    group_map := group_map || jsonb_build_object(
      group_record.group_id::text,mapped_group_id);
  END LOOP;
  IF EXISTS (
    SELECT 1 FROM jsonb_to_recordset(group_members) AS gm(
      group_id uuid,position integer,weid uuid,locked boolean)
    JOIN public.workout_sets s ON s.workout_exercise_id=gm.weid
    WHERE s.is_completed AND NOT gm.locked
  ) THEN
    RAISE EXCEPTION 'Completed superset must retain its lock' USING ERRCODE='22023';
  END IF;
  SELECT coalesce(jsonb_agg(jsonb_build_object('group_id',
    (group_map->>(g.group_id::text))::uuid,
    'exercise_ids',g.exercise_ids)),'[]'::jsonb) INTO group_layout
  FROM (SELECT gm.group_id,jsonb_agg(gm.weid ORDER BY gm.position) AS exercise_ids
    FROM jsonb_to_recordset(group_members) AS gm(
      group_id uuid,position integer,weid uuid,locked boolean)
    GROUP BY gm.group_id) g;
  IF group_layout <> '[]'::jsonb THEN
    PERFORM public.set_superset_layout_v1(wid,group_layout);
    -- The source may retain a durable lock after all sets were uncompleted.
    INSERT INTO public.workout_superset_locks(workout_id,group_id)
      SELECT wid,(group_map->>(gm.group_id::text))::uuid
        FROM jsonb_to_recordset(group_members) AS gm(
        group_id uuid,position integer,weid uuid,locked boolean)
      WHERE gm.locked GROUP BY gm.group_id ON CONFLICT DO NOTHING;
    UPDATE public.workout_exercises we SET superset_locked=true
      FROM jsonb_to_recordset(group_members) AS gm(
        group_id uuid,position integer,weid uuid,locked boolean)
      WHERE we.id=gm.weid AND gm.locked AND NOT we.superset_locked;
  END IF;
  UPDATE public.workouts SET status='completed',completed_at=completed,
    duration_seconds=duration WHERE id=wid;
  INSERT INTO public.historical_workout_imports(user_id,import_key,payload_digest,
    workout_id,created_custom_exercise_ids)
    VALUES(uid,p_import_key,digest,wid,created_custom_ids);
  RETURN jsonb_build_object('workoutId',wid,'alreadyImported',false,
    'createdCustomExerciseIds',to_jsonb(created_custom_ids));
END $$;

REVOKE ALL ON FUNCTION public.import_historical_workout_v1(text,jsonb)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.import_historical_workout_v1(text,jsonb)
  TO authenticated;

-- Imported history never enters the live reward path or workout-count achievements.
CREATE OR REPLACE FUNCTION public.complete_workout(p_workout_id uuid, p_notes text DEFAULT NULL) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE uid uuid=auth.uid(); u public.users; w public.workouts; result jsonb; tz text; day date; finished timestamptz=clock_timestamp(); duration integer;
 completed_sets integer; categories text[]; base_xp numeric; earned integer; total integer; new_level integer=1; old_level integer; streak integer; prev_date date; suspicious boolean; quest_match boolean=false;
 q public.quest_instances; target jsonb; target_count integer; target_matches integer; quest_base integer; title text; classes jsonb='[]'; c record; cxp integer; clevel integer; synergy numeric=1; achievements jsonb='[]'; achievement text; total_workouts integer;
BEGIN
 IF uid IS NULL THEN RAISE EXCEPTION 'Authentication required' USING ERRCODE='42501'; END IF;
 -- Serialize all progression for the same user, including different workouts.
 SELECT * INTO u FROM public.users WHERE id=uid FOR UPDATE;
 SELECT * INTO w FROM public.workouts WHERE id=p_workout_id AND user_id=uid FOR UPDATE;
 IF w.id IS NULL THEN RAISE EXCEPTION 'Workout not found' USING ERRCODE='42501'; END IF;
 IF w.is_imported THEN RAISE EXCEPTION 'Imported workouts cannot earn rewards' USING ERRCODE='22023'; END IF;
 SELECT r.result INTO result FROM public.workout_rewards r WHERE r.workout_id=w.id;
 IF result IS NOT NULL THEN RETURN result; END IF;
 -- Legacy already-awarded sessions must never gain a second reward.
 IF w.is_xp_calculated THEN RETURN jsonb_build_object('earnedXP',0,'totalXP',u.total_xp,'newLevel',u.level,'leveledUp',false,'isQuest',false,'newTitle',NULL,'nextLevelXp',floor(100*power(u.level,1.5)),'isSuspicious',false,'classResults','[]'::jsonb,'achievements','[]'::jsonb,'alreadyAwarded',true); END IF;
 -- A legacy tuple can carry ledger evidence without a reward row or flag; that means
 -- XP was already granted. Never award it twice and never fabricate a replacement.
 IF EXISTS(SELECT 1 FROM public.xp_logs l WHERE l.user_id=uid AND l.source_id=w.id::text AND l.source IN ('workout','quest')) THEN RETURN jsonb_build_object('earnedXP',0,'totalXP',u.total_xp,'newLevel',u.level,'leveledUp',false,'isQuest',false,'newTitle',NULL,'nextLevelXp',floor(100*power(u.level,1.5)),'isSuspicious',false,'classResults','[]'::jsonb,'achievements','[]'::jsonb,'alreadyAwarded',true); END IF;
 IF w.status NOT IN ('active','completed') OR w.training_started_at IS NULL THEN RAISE EXCEPTION 'Workout has not started or was cancelled' USING ERRCODE='22023'; END IF;
 IF length(coalesce(p_notes,''))>4000 THEN RAISE EXCEPTION 'Notes are too long' USING ERRCODE='22023'; END IF;
 -- A legacy completed/unrewarded session retains its original completion time.
 IF w.status='completed' THEN finished=coalesce(w.completed_at,finished); END IF;
 duration=greatest(1,floor(extract(epoch FROM coalesce(w.paused_at,finished)-w.training_started_at))::integer-w.paused_seconds);
 -- Warm-up sets are excluded from completed-set count, categories and base XP.
 SELECT count(*)::integer,array_agg(DISTINCT lower(e.category)),sum(CASE WHEN s.baseline_weight_kg>0 THEN 5*least(3,greatest(0.2,s.weight_kg/s.baseline_weight_kg)) ELSE 5 END)
 INTO completed_sets,categories,base_xp FROM public.workout_sets s JOIN public.workout_exercises we ON we.id=s.workout_exercise_id JOIN public.exercises e ON e.id=we.exercise_id WHERE we.workout_id=w.id AND s.is_completed AND (s.set_type IS NULL OR s.set_type='workout');
 IF completed_sets=0 THEN RAISE EXCEPTION 'Complete at least one set before finishing' USING ERRCODE='22023'; END IF;
 -- Mode-specific measurement validation (restored from m3_superset_modes.sql).
 IF completed_sets>300 OR EXISTS(SELECT 1 FROM public.workout_sets s JOIN public.workout_exercises we ON we.id=s.workout_exercise_id WHERE we.workout_id=w.id AND s.is_completed AND (s.weight_kg<0 OR s.weight_kg>1000 OR (we.mode IN ('timed','cardio') AND (s.reps<>0 OR coalesce(s.duration_seconds,0) NOT BETWEEN 1 AND 7200 OR s.weight_kg<>0)) OR (we.mode IN ('reps-weight','bodyweight') AND (s.reps<1 OR s.reps>1000 OR s.duration_seconds IS DISTINCT FROM 0)) OR (we.mode IS NULL AND (s.reps<1 OR s.reps>1000)))) THEN RAISE EXCEPTION 'Invalid workout measurements' USING ERRCODE='22023'; END IF;
 suspicious=completed_sets>3 AND completed_sets*60.0/duration>4;
 SELECT timezone INTO tz FROM public.profiles WHERE id=uid;
 day=(finished AT TIME ZONE coalesce(tz,'Asia/Ho_Chi_Minh'))::date;
 INSERT INTO public.streaks(user_id) VALUES(uid) ON CONFLICT(user_id) DO NOTHING;
 SELECT current_streak,last_activity_date INTO streak,prev_date FROM public.streaks WHERE user_id=uid FOR UPDATE;
 streak=CASE WHEN prev_date=day THEN streak WHEN prev_date=day-1 THEN streak+1 WHEN prev_date>day THEN streak ELSE 1 END;
 SELECT * INTO q FROM public.quest_instances WHERE user_id=uid AND status='active' AND quest_date=day AND expires_at>finished ORDER BY created_at LIMIT 1 FOR UPDATE;
 IF q.id IS NOT NULL AND jsonb_typeof(q.prescribed_config)='array' AND jsonb_array_length(q.prescribed_config)>0 THEN
  target_count=jsonb_array_length(q.prescribed_config); target_matches=0;
  FOR target IN SELECT jsonb_array_elements(q.prescribed_config) LOOP
   IF (SELECT count(*) FROM public.workout_sets s JOIN public.workout_exercises we ON we.id=s.workout_exercise_id WHERE we.workout_id=w.id AND we.exercise_id=(target->>'exercise_id')::uuid AND s.is_completed AND (s.set_type IS NULL OR s.set_type='workout') AND s.reps>=coalesce((target->>'reps')::integer,1) AND s.weight_kg>=coalesce((target->>'weight_kg')::numeric,0))>=coalesce((target->>'sets')::integer,3) THEN target_matches=target_matches+1; END IF;
  END LOOP;
  quest_match=target_matches=target_count;
 END IF;
 IF suspicious THEN earned=10;
 ELSIF quest_match THEN SELECT qt.base_xp INTO quest_base FROM public.quests qt WHERE qt.id=q.quest_id; earned=least(1000,floor(coalesce(quest_base,300)*least(2,1+greatest(0,streak-1)*0.05))::integer);
 ELSE earned=least(1000,floor((base_xp+greatest(0,cardinality(categories)-1)*8)*least(1.5,1+greatest(0,streak-1)*0.05))::integer); END IF;
 total=coalesce(u.total_xp,0)+earned; old_level=coalesce(u.level,1);
 WHILE new_level<100 AND total>=floor(100*power(new_level,1.5)) LOOP new_level=new_level+1; END LOOP;
 title=CASE WHEN new_level>=100 THEN 'Bất Tử' WHEN new_level>=75 THEN 'Thần Thoại' WHEN new_level>=50 THEN 'Huyền Thoại' WHEN new_level>=30 THEN 'Anh Hùng' WHEN new_level>=20 THEN 'Dũng Sĩ' WHEN new_level>=15 THEN 'Đấu Sĩ' WHEN new_level>=10 THEN 'Chiến Binh' WHEN new_level>=5 THEN 'Tập Sự' ELSE 'Tân Binh' END;
 SELECT coalesce(max(1+s.bonus_percent/100.0),1) INTO synergy FROM public.user_classes a JOIN public.user_classes b ON a.user_id=b.user_id AND a.slot='primary' AND b.slot='secondary' JOIN public.class_synergies s ON s.primary_class_id=a.class_id AND s.secondary_class_id=b.class_id AND s.is_perfect WHERE a.user_id=uid;
 FOR c IN SELECT uc.*,cd.focus_categories,cd.xp_base,cd.xp_slope FROM public.user_classes uc JOIN public.class_definitions cd USING(class_id) WHERE uc.user_id=uid AND NOT uc.is_graduated FOR UPDATE OF uc LOOP
  cxp=floor(earned*(CASE WHEN categories&&c.focus_categories THEN 1 ELSE 0.4 END)*synergy)::integer; clevel=1;
  WHILE clevel<20 AND c.current_xp+cxp>=floor(c.xp_base*power(clevel,c.xp_slope)) LOOP clevel=clevel+1; END LOOP;
  UPDATE public.user_classes SET current_xp=c.current_xp+cxp,level=clevel,is_graduated=clevel=20,graduated_at=CASE WHEN clevel=20 THEN finished ELSE NULL END WHERE id=c.id;
  INSERT INTO public.xp_logs(user_id,amount,source,source_id,class_id,class_xp_earned) VALUES(uid,cxp,'class_xp',w.id::text,c.class_id,cxp);
  classes:=classes||jsonb_build_array(jsonb_build_object('classId',c.class_id,'className',c.class_name,'slot',c.slot,'xpEarned',cxp,'newTotalXP',c.current_xp+cxp,'newLevel',clevel,'leveledUp',clevel>c.level,'isGraduation',clevel=20 AND c.level<20));
 END LOOP;
 UPDATE public.users SET total_xp=total,level=new_level,current_level_xp=total-CASE WHEN new_level>1 THEN floor(100*power(new_level-1,1.5))::integer ELSE 0 END,current_title=title,last_workout_date=greatest(last_workout_date,finished),last_active_at=greatest(last_active_at,finished) WHERE id=uid;
 UPDATE public.streaks SET current_streak=streak,longest_streak=greatest(longest_streak,streak),last_activity_date=greatest(coalesce(last_activity_date,day),day) WHERE user_id=uid;
 UPDATE public.workouts SET status='completed',completed_at=finished,duration_seconds=duration,notes=coalesce(p_notes,notes),paused_at=NULL,is_xp_calculated=true WHERE id=w.id;
 INSERT INTO public.xp_logs(user_id,amount,source,source_id) VALUES(uid,earned,CASE WHEN quest_match THEN 'quest' ELSE 'workout' END,w.id::text);
 IF quest_match THEN UPDATE public.quest_instances SET status='completed',completed_at=finished,earned_xp=earned WHERE id=q.id; END IF;
 -- PRs are computed from working sets only; warm-up sets never create a PR.
 INSERT INTO public.exercise_prs(user_id,exercise_id,max_weight_kg,max_reps,estimated_1rm,is_confirmed)
 SELECT uid,we.exercise_id,max(s.weight_kg),max(s.reps),max(s.weight_kg * (1 + s.reps / 30.0)), true
  FROM public.workout_sets s
  JOIN public.workout_exercises we ON we.id = s.workout_exercise_id
  WHERE we.workout_id = w.id
    AND s.is_completed
    AND (we.mode IS NULL OR we.mode IN ('reps-weight', 'bodyweight'))
    AND (s.set_type IS NULL OR s.set_type = 'workout')
 GROUP BY we.exercise_id
 ON CONFLICT(user_id,exercise_id) DO UPDATE SET max_weight_kg=greatest(public.exercise_prs.max_weight_kg,excluded.max_weight_kg),max_reps=greatest(public.exercise_prs.max_reps,excluded.max_reps),estimated_1rm=greatest(public.exercise_prs.estimated_1rm,excluded.estimated_1rm),is_confirmed=true;
 SELECT count(*) INTO total_workouts FROM public.workouts WHERE user_id=uid AND status='completed' AND NOT is_imported;
 FOREACH achievement IN ARRAY ARRAY[
   'first_workout',
   CASE WHEN total_workouts>=5 THEN 'five_workouts' END,
   CASE WHEN total_workouts>=10 THEN 'ten_workouts' END,
   CASE WHEN streak>=3 THEN 'streak_3' END,
   CASE WHEN streak>=7 THEN 'streak_7' END,
   CASE WHEN new_level>=10 THEN 'level_10' END,
   CASE WHEN new_level>=20 THEN 'level_20' END
 ] LOOP
   IF achievement IS NOT NULL THEN
     INSERT INTO public.user_achievements(user_id,achievement_id) VALUES(uid,achievement) ON CONFLICT DO NOTHING;
     IF FOUND THEN achievements:=achievements||to_jsonb(achievement); END IF;
   END IF;
 END LOOP;
 result:=jsonb_build_object('message','Workout complete','earnedXP',earned,'totalXP',total,'newLevel',new_level,'leveledUp',new_level>old_level,'isQuest',quest_match,'newTitle',CASE WHEN new_level>old_level THEN title END,'nextLevelXp',floor(100*power(new_level,1.5)),'isSuspicious',suspicious,'classResults',classes,'achievements',achievements,'streak',streak);
 INSERT INTO public.workout_rewards(workout_id,user_id,result) VALUES(w.id,uid,result);
 UPDATE public.workouts SET reward_result=result WHERE id=w.id;
 RETURN result;
END $$;

REVOKE ALL ON FUNCTION public.complete_workout(uuid,text) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.complete_workout(uuid,text) TO authenticated;
