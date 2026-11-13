-- P9.2: owner-scoped, per-measurement import with a durable retry receipt.
-- Recovery: stop invoking this RPC and ship a reviewed additive correction.
-- Existing measurements and receipts remain user data and are not deleted.

CREATE TABLE IF NOT EXISTS public.historical_measurement_imports (
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  import_key text NOT NULL,
  payload_digest text NOT NULL,
  measurement_id uuid NOT NULL UNIQUE REFERENCES public.body_measurements(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, import_key)
);
ALTER TABLE public.historical_measurement_imports ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.historical_measurement_imports FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.import_historical_measurement_v1(
  p_import_key text, p_payload jsonb
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE
  uid uuid := auth.uid();
  existing public.historical_measurement_imports;
  digest text;
  measured timestamptz;
  measurement_value numeric;
  mid uuid;
  measurement_kind text;
  measurement_unit text;
BEGIN
  IF uid IS NULL THEN RAISE EXCEPTION 'Authentication required' USING ERRCODE='42501'; END IF;
  IF p_import_key IS NULL OR length(p_import_key) NOT BETWEEN 1 AND 128
     OR p_import_key <> btrim(p_import_key)
     OR p_import_key ~ '[[:cntrl:]]' THEN
    RAISE EXCEPTION 'Invalid measurement import key' USING ERRCODE='22023';
  END IF;
  IF jsonb_typeof(p_payload) IS DISTINCT FROM 'object'
     OR octet_length(p_payload::text) > 8192
     OR EXISTS (SELECT 1 FROM jsonb_object_keys(p_payload) k
                WHERE k NOT IN ('measurement_type','value','unit','measured_at','notes')) THEN
    RAISE EXCEPTION 'Invalid measurement import payload' USING ERRCODE='22023';
  END IF;
  digest := encode(sha256(convert_to(p_payload::text,'UTF8')),'hex');
  PERFORM 1 FROM public.users WHERE id=uid FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Account unavailable' USING ERRCODE='42501'; END IF;
  SELECT * INTO existing FROM public.historical_measurement_imports
    WHERE user_id=uid AND import_key=p_import_key FOR UPDATE;
  IF existing.measurement_id IS NOT NULL THEN
    IF existing.payload_digest <> digest THEN
      RAISE EXCEPTION 'Measurement import key already used for different content' USING ERRCODE='22023';
    END IF;
    RETURN jsonb_build_object('measurementId',existing.measurement_id,'alreadyImported',true);
  END IF;
  measurement_kind := p_payload->>'measurement_type';
  measurement_unit := p_payload->>'unit';
  IF jsonb_typeof(p_payload->'measurement_type') IS DISTINCT FROM 'string'
     OR measurement_kind NOT IN ('body_weight','body_fat_percentage','chest','waist','hips','upper_arm','thigh')
     OR jsonb_typeof(p_payload->'value') IS DISTINCT FROM 'number'
     OR jsonb_typeof(p_payload->'unit') IS DISTINCT FROM 'string'
     OR measurement_unit NOT IN ('kg','cm','percent')
     OR jsonb_typeof(p_payload->'measured_at') IS DISTINCT FROM 'string'
     OR coalesce(p_payload->>'measured_at','') !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}T'
     OR coalesce(p_payload->>'measured_at','') !~ '(Z|[+-][0-9]{2}:[0-9]{2})$'
     OR (p_payload ? 'notes' AND jsonb_typeof(p_payload->'notes') NOT IN ('string','null'))
     OR length(coalesce(p_payload->>'notes','')) > 4000 THEN
    RAISE EXCEPTION 'Invalid measurement import payload' USING ERRCODE='22023';
  END IF;
  BEGIN
    measured := (p_payload->>'measured_at')::timestamptz;
    measurement_value := (p_payload->>'value')::numeric;
  EXCEPTION WHEN invalid_datetime_format OR datetime_field_overflow OR numeric_value_out_of_range THEN
    RAISE EXCEPTION 'Invalid measurement date or value' USING ERRCODE='22023';
  END;
  IF measured > now() + interval '5 minutes'
     OR measurement_value <= 0 OR measurement_value > 1000 THEN
    RAISE EXCEPTION 'Invalid measurement date or value' USING ERRCODE='22023';
  END IF;
  IF (measurement_kind = 'body_weight' AND measurement_unit <> 'kg')
     OR (measurement_kind = 'body_fat_percentage' AND measurement_unit <> 'percent')
     OR (measurement_kind IN ('chest','waist','hips','upper_arm','thigh')
         AND measurement_unit <> 'cm') THEN
    RAISE EXCEPTION 'Measurement unit does not match its type' USING ERRCODE='22023';
  END IF;
  INSERT INTO public.body_measurements(user_id,measurement_type,value,unit,measured_at,notes)
    VALUES(uid,measurement_kind,measurement_value,measurement_unit,measured,p_payload->>'notes')
    RETURNING id INTO mid;
  INSERT INTO public.historical_measurement_imports(user_id,import_key,payload_digest,measurement_id)
    VALUES(uid,p_import_key,digest,mid);
  RETURN jsonb_build_object('measurementId',mid,'alreadyImported',false);
END $$;

REVOKE ALL ON FUNCTION public.import_historical_measurement_v1(text,jsonb)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.import_historical_measurement_v1(text,jsonb)
  TO authenticated;
