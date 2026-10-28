-- Effective progression ACL adoption repair (D-027); no data/schema/policy changes.
-- Rollback: an error rolls back this entire transaction. After adoption, use a reviewed
-- forward correction of specific legitimate grants; never restore progression-write grants.
-- PUBLIC/default privileges already materialized on these tables are reconciled below.
-- Default ACL templates for future objects and unrelated/platform roles are not rewritten.
-- This is an adoption-time assertion, not protection against future administrator grants.
BEGIN;
DO $$
DECLARE
  t text;
  client text;
  principal text;
  privilege text;
  a record;
  r record;
  relation_oid oid;
  owner_oid oid;
  rls_enabled boolean;
  child_table boolean;
  editable text[];
  allowed boolean;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'users','profiles','exercises','workouts','workout_exercises','workout_sets',
    'xp_logs','streaks','exercise_prs','quests','quest_instances','user_classes',
    'class_definitions','class_synergies','workout_rewards','user_achievements','coach_daily_usage'
  ] LOOP
    relation_oid := to_regclass(format('public.%I',t));
    SELECT relowner,relrowsecurity INTO owner_oid,rls_enabled
      FROM pg_catalog.pg_class WHERE oid=relation_oid;
    IF relation_oid IS NULL OR rls_enabled IS DISTINCT FROM true THEN
      RAISE EXCEPTION 'effective progression ACL: required RLS table public.% unavailable',t
        USING ERRCODE='42501';
    END IF;
    child_table := t IN ('workout_exercises','workout_sets');
    editable := CASE t
      WHEN 'users' THEN ARRAY['display_name','avatar_url','locale']
      WHEN 'profiles' THEN ARRAY['environment','goals','experience_level','age','gender',
        'height_cm','weight_kg','weekly_gym_days','weekly_home_days','preferred_training_days']
      WHEN 'workouts' THEN ARRAY['notes']
      ELSE ARRAY[]::text[] END;

    -- A table-level REVOKE alone does not remove PUBLIC or surviving column ACLs.
    -- Preserve authenticated active-child DML and every platform role's direct grants.
    FOREACH principal IN ARRAY ARRAY['PUBLIC','anon','authenticated'] LOOP
      FOREACH privilege IN ARRAY ARRAY['INSERT','UPDATE','DELETE','TRUNCATE','REFERENCES','TRIGGER'] LOOP
        IF NOT (principal='authenticated' AND child_table AND privilege IN ('INSERT','UPDATE','DELETE')) THEN
          EXECUTE format('REVOKE %s ON TABLE public.%I FROM %s',privilege,t,
            CASE WHEN principal='PUBLIC' THEN 'PUBLIC' ELSE quote_ident(principal) END);
        END IF;
      END LOOP;
      FOR a IN SELECT attname FROM pg_catalog.pg_attribute
        WHERE attrelid=relation_oid AND attnum>0 AND NOT attisdropped LOOP
        FOREACH privilege IN ARRAY ARRAY['INSERT','UPDATE','REFERENCES'] LOOP
          allowed := principal='authenticated' AND
            ((child_table AND privilege IN ('INSERT','UPDATE')) OR
             (privilege='UPDATE' AND a.attname=ANY(editable)));
          IF NOT allowed THEN
            EXECUTE format('REVOKE %s (%I) ON TABLE public.%I FROM %s',privilege,a.attname,t,
              CASE WHEN principal='PUBLIC' THEN 'PUBLIC' ELSE quote_ident(principal) END);
          END IF;
        END LOOP;
      END LOOP;
    END LOOP;

    -- PostgreSQL table-level REVOKE can also remove the same named-role column
    -- grants. Re-establish only the existing canonical editable-column contract.
    IF cardinality(editable)>0 THEN
      FOR a IN SELECT unnest(editable) AS attname LOOP
        EXECUTE format('GRANT UPDATE (%I) ON TABLE public.%I TO authenticated',a.attname,t);
      END LOOP;
    END IF;

    -- Fail closed rather than revoke grants/memberships from an unmanaged parent role.
    -- MEMBER deliberately includes NOINHERIT memberships: SET ROLE can expose them.
    -- Diagnostics contain only role/object/privilege metadata, never user data.
    FOREACH client IN ARRAY ARRAY['anon','authenticated'] LOOP
      FOR r IN SELECT oid,rolname,rolsuper,rolbypassrls FROM pg_catalog.pg_roles
        WHERE rolname=client OR pg_catalog.pg_has_role(client,oid,'MEMBER')
        ORDER BY (rolname=client),rolname LOOP
        IF r.rolsuper OR r.rolbypassrls OR pg_catalog.pg_has_role(r.oid,owner_oid,'USAGE') THEN
          RAISE EXCEPTION 'effective progression ACL: client % inherited/role % has owner or RLS-bypass authority on public.%',client,r.rolname,t
            USING ERRCODE='42501',HINT='Review the incompatible role membership/ownership before retrying adoption; do not restore progression grants.';
        END IF;
        FOREACH privilege IN ARRAY ARRAY['INSERT','UPDATE','DELETE','TRUNCATE','REFERENCES','TRIGGER'] LOOP
          allowed := client='authenticated' AND child_table AND privilege IN ('INSERT','UPDATE','DELETE');
          IF NOT allowed AND pg_catalog.has_table_privilege(r.oid,relation_oid,privilege) THEN
            RAISE EXCEPTION 'effective progression ACL: client % inherited/role % retains % on public.%',client,r.rolname,privilege,t
              USING ERRCODE='42501',HINT='Review the named role and table ACL provenance before retrying adoption.';
          END IF;
        END LOOP;
        FOR a IN SELECT attnum,attname FROM pg_catalog.pg_attribute
          WHERE attrelid=relation_oid AND attnum>0 AND NOT attisdropped LOOP
          FOREACH privilege IN ARRAY ARRAY['INSERT','UPDATE','REFERENCES'] LOOP
            allowed := client='authenticated' AND
              ((child_table AND privilege IN ('INSERT','UPDATE')) OR
               (privilege='UPDATE' AND a.attname=ANY(editable)));
            IF NOT allowed AND pg_catalog.has_column_privilege(r.oid,relation_oid,a.attnum,privilege) THEN
              RAISE EXCEPTION 'effective progression ACL: client % inherited/role % retains % on public.%.%',client,r.rolname,privilege,t,a.attname
                USING ERRCODE='42501',HINT='Review the named role and column/table ACL provenance before retrying adoption.';
            END IF;
          END LOOP;
        END LOOP;
      END LOOP;
    END LOOP;
  END LOOP;
END $$;
COMMIT;
