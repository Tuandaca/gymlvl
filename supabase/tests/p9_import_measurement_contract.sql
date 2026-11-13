-- P9.2 measurement restore contract. Disposable database; fixtures roll back.
BEGIN;

CREATE FUNCTION pg_temp.p92_measurement_expect(ok boolean, label text) RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
  IF ok IS DISTINCT FROM true THEN RAISE EXCEPTION 'P9.2 FAIL: %', label; END IF;
END $$;

SELECT pg_temp.p92_measurement_expect(
  to_regprocedure('public.import_historical_measurement_v1(text,jsonb)') IS NOT NULL,
  'transactional historical measurement RPC exists'
);

INSERT INTO auth.users(id, email) VALUES
  ('92000000-0000-4000-8000-000000000011', 'p92-measure-a@example.test'),
  ('92000000-0000-4000-8000-000000000012', 'p92-measure-b@example.test');

SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claim.sub', '92000000-0000-4000-8000-000000000011', true);
SELECT set_config('request.jwt.claims', '{"sub":"92000000-0000-4000-8000-000000000011","role":"authenticated"}', true);

DO $$
DECLARE
  owner_a uuid := '92000000-0000-4000-8000-000000000011';
  owner_b uuid := '92000000-0000-4000-8000-000000000012';
  payload jsonb := jsonb_build_object(
    'measurement_type', 'waist', 'value', 82.5, 'unit', 'cm',
    'measured_at', '2026-11-01T07:30:00Z', 'notes', 'morning'
  );
  receipt jsonb;
  first_id uuid;
  second_id uuid;
  denied boolean;
BEGIN
  receipt := public.import_historical_measurement_v1('p92-measure-key', payload);
  first_id := (receipt->>'measurementId')::uuid;
  PERFORM pg_temp.p92_measurement_expect(first_id IS NOT NULL AND
    (receipt->>'alreadyImported')::boolean = false AND
    EXISTS (SELECT 1 FROM public.body_measurements WHERE id = first_id
      AND user_id = owner_a AND measurement_type = 'waist' AND value = 82.5
      AND unit = 'cm' AND notes = 'morning'),
    'first measurement import persists owner-scoped value');

  receipt := public.import_historical_measurement_v1('p92-measure-key', payload);
  PERFORM pg_temp.p92_measurement_expect(
    (receipt->>'measurementId')::uuid = first_id AND
    (receipt->>'alreadyImported')::boolean = true AND
    (SELECT count(*) = 1 FROM public.body_measurements WHERE user_id = owner_a),
    'same owner/key/payload measurement replay is idempotent');

  denied := false;
  BEGIN
    PERFORM public.import_historical_measurement_v1('p92-measure-key',
      jsonb_set(payload, '{value}', '83'::jsonb));
  EXCEPTION WHEN SQLSTATE '22023' THEN denied := true;
  END;
  PERFORM pg_temp.p92_measurement_expect(denied,
    'same measurement key with changed payload is rejected');

  denied := false;
  BEGIN
    PERFORM public.import_historical_measurement_v1('p92-invalid-value',
      jsonb_set(payload, '{value}', '-1'::jsonb));
  EXCEPTION WHEN SQLSTATE '22023' OR check_violation THEN denied := true;
  END;
  PERFORM pg_temp.p92_measurement_expect(denied AND
    (SELECT count(*) = 1 FROM public.body_measurements WHERE user_id = owner_a),
    'invalid measurement rolls back without partial row');

  denied := false;
  BEGIN
    PERFORM public.import_historical_measurement_v1('p92-invalid-unit',
      jsonb_set(payload, '{unit}', '"kg"'::jsonb));
  EXCEPTION WHEN SQLSTATE '22023' THEN denied := true;
  END;
  PERFORM pg_temp.p92_measurement_expect(denied AND
    (SELECT count(*) = 1 FROM public.body_measurements WHERE user_id = owner_a),
    'waist measurement rejects kg unit without a partial row');

  denied := false;
  BEGIN
    PERFORM public.import_historical_measurement_v1('p92-invalid-fat-unit',
      jsonb_set(jsonb_set(payload, '{measurement_type}',
        '"body_fat_percentage"'::jsonb), '{unit}', '"kg"'::jsonb));
  EXCEPTION WHEN SQLSTATE '22023' THEN denied := true;
  END;
  PERFORM pg_temp.p92_measurement_expect(denied AND
    (SELECT count(*) = 1 FROM public.body_measurements WHERE user_id = owner_a),
    'body fat percentage rejects kg unit without a partial row');

  PERFORM set_config('request.jwt.claim.sub', owner_b::text, true);
  PERFORM set_config('request.jwt.claims',
    json_build_object('sub', owner_b::text, 'role', 'authenticated')::text, true);
  receipt := public.import_historical_measurement_v1('p92-measure-key', payload);
  second_id := (receipt->>'measurementId')::uuid;
  PERFORM pg_temp.p92_measurement_expect(second_id <> first_id AND
    (receipt->>'alreadyImported')::boolean = false AND
    EXISTS (SELECT 1 FROM public.body_measurements WHERE id = second_id AND user_id = owner_b) AND
    NOT EXISTS (SELECT 1 FROM public.body_measurements WHERE id = first_id),
    'measurement key and row visibility are owner-scoped');
END $$;

ROLLBACK;
