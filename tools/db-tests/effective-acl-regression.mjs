import assert from 'node:assert/strict';
import { readFile, readdir } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { PGlite } from '@electric-sql/pglite';
import { pgcrypto } from '@electric-sql/pglite/contrib/pgcrypto';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../..');
const repairName = '20261029000100_effective_progression_acl.sql';
const A = '11111111-1111-4111-8111-111111111111';
const B = '22222222-2222-4222-8222-222222222222';
const profile = { environment: 'gym', goals: ['hypertrophy'], experience_level: 'beginner',
  age: 25, gender: 'other', height_cm: 170, weight_kg: 65, weekly_gym_days: 3,
  weekly_home_days: 0, preferred_training_days: ['mon', 'wed', 'fri'], primary_class_id: 'B' };

export async function runEffectiveAclRegression() {
  let checks = 0;
  const migrationDir = path.join(root, 'supabase/migrations');
  const migrations = (await readdir(migrationDir)).filter(n => n.endsWith('.sql')).sort();
  // Before the repair exists this deliberately exercises the unmodified legacy chain (RED).
  const repair = migrations.includes(repairName)
    ? await readFile(path.join(migrationDir, repairName), 'utf8') : '';
  const pass = (label, actual, expected) => {
    assert.deepEqual(actual, expected, label);
    checks++;
    console.log(`PASS ACL ${label}`);
  };
  const scalar = async (db, sql, args = []) => Object.values((await db.query(sql, args)).rows[0])[0];
  async function denied(db, label, sql, args = []) {
    let caught;
    try { await db.query(sql, args); } catch (error) { caught = error; }
    assert.ok(caught, `${label}: expected SQLSTATE 42501; statement unexpectedly succeeded`);
    pass(`${label} SQLSTATE 42501`, caught.code, '42501');
  }
  async function role(db, uid = A, name = 'authenticated') {
    await db.exec('RESET ROLE');
    await db.query("SELECT set_config('request.jwt.claim.sub',$1,false), set_config('request.jwt.claims',$2,false)",
      [uid, JSON.stringify({ sub: uid || undefined, role: name })]);
    await db.exec(`SET ROLE ${name}`);
  }
  async function controls(db, label) {
    await db.query(`INSERT INTO auth.users(id,email) VALUES ($1,'acl-a@example.test'),($2,'acl-b@example.test')`, [A, B]);
    await role(db);
    await denied(db, `${label} actual authenticated own XP UPDATE forbidden`,
      'UPDATE public.users SET total_xp=777 WHERE id=$1 RETURNING total_xp', [A]);
    pass(`${label} XP unchanged`, await scalar(db, 'SELECT total_xp FROM public.users WHERE id=$1', [A]), 0);
    await db.query('SELECT public.initialize_user($1::jsonb)', [JSON.stringify(profile)]);
    pass(`${label} allowed display name edit`, await scalar(db,
      "UPDATE public.users SET display_name='Safe edit' WHERE id=$1 RETURNING display_name", [A]), 'Safe edit');
    pass(`${label} allowed profile edit`, await scalar(db,
      'UPDATE public.profiles SET weight_kg=66 WHERE id=$1 RETURNING weight_kg::int', [A]), 66);
    const workout = await scalar(db, 'SELECT public.start_workout()');
    pass(`${label} active notes edit`, await scalar(db,
      "UPDATE public.workouts SET notes='Safe notes' WHERE id=$1 RETURNING notes", [workout.id]), 'Safe notes');
    await denied(db, `${label} completion field forbidden`, "UPDATE public.workouts SET status='completed' WHERE id=$1", [workout.id]);
    await denied(db, `${label} profile class forbidden`, "UPDATE public.profiles SET class_name='forged' WHERE id=$1", [A]);
    for (const table of ['xp_logs', 'streaks', 'exercise_prs', 'quest_instances', 'user_classes', 'workout_rewards', 'user_achievements', 'coach_daily_usage']) {
      for (const privilege of ['INSERT', 'UPDATE', 'DELETE', 'TRUNCATE', 'REFERENCES', 'TRIGGER']) {
        pass(`${label} authenticated ${table} ${privilege} absent`, await scalar(db,
          'SELECT has_table_privilege(current_user,$1,$2)', [`public.${table}`, privilege]), false);
      }
    }
    // Exercise IDs come only from the installed catalogue; completion remains the award path.
    const eid = await scalar(db, 'SELECT id FROM public.exercises ORDER BY id LIMIT 1');
    const we = await scalar(db, 'INSERT INTO public.workout_exercises(workout_id,exercise_id) VALUES($1,$2) RETURNING id', [workout.id, eid]);
    await db.query('INSERT INTO public.workout_sets(workout_exercise_id,reps,weight_kg,is_completed) VALUES($1,10,20,true)', [we]);
    await db.query('SELECT public.begin_workout($1)', [workout.id]);
    await role(db, B);
    pass(`${label} second user cannot read first`, await scalar(db, 'SELECT count(*)::int FROM public.users WHERE id=$1', [A]), 0);
    pass(`${label} second user safe edit affects zero rows`, (await db.query(
      "UPDATE public.users SET display_name='foreign' WHERE id=$1 RETURNING id", [A])).rows.length, 0);
    pass(`${label} second user notes edit affects zero rows`, (await db.query(
      "UPDATE public.workouts SET notes='foreign' WHERE id=$1 RETURNING id", [workout.id])).rows.length, 0);
    await denied(db, `${label} second user completion denied`, 'SELECT public.complete_workout($1)', [workout.id]);
    await role(db);
    const result = await scalar(db, 'SELECT public.complete_workout($1)', [workout.id]);
    assert.ok(result.earnedXP > 0, 'authoritative RPC must still award XP');
    pass(`${label} completion retry idempotent`, await scalar(db, 'SELECT public.complete_workout($1)', [workout.id]), result);
    pass(`${label} completed notes immutable`, (await db.query(
      "UPDATE public.workouts SET notes='late' WHERE id=$1 RETURNING id", [workout.id])).rows.length, 0);
    await role(db, '', 'anon');
    await denied(db, `${label} anonymous XP UPDATE forbidden`, 'UPDATE public.users SET total_xp=777 WHERE id=$1', [A]);
    pass(`${label} anon has no effective XP UPDATE`, await scalar(db,
      "SELECT has_column_privilege(current_user,'public.users','total_xp','UPDATE')"), false);
    pass(`${label} anon RLS sees no users with harmless PUBLIC SELECT`, await scalar(db, 'SELECT count(*)::int FROM public.users'), 0);
    await denied(db, `${label} anon RPC execution denied`, 'SELECT public.complete_workout($1)', [workout.id]);
    await role(db, '', 'service_role');
    pass(`${label} platform service table grant preserved`, await scalar(db,
      "SELECT has_table_privilege(current_user,'public.users','UPDATE')"), true);
    pass(`${label} service RLS bypass unchanged`, await scalar(db, 'SELECT count(*)::int FROM public.users'), 2);
    await db.exec('RESET ROLE');
  }
  async function scenario(label, beforeProgression = '', beforeRepair = '', incompatible = false) {
    const db = new PGlite({ extensions: { pgcrypto } });
    console.log(`CASE ACL ${label}`);
    try {
      await db.exec(await readFile(path.join(here, 'bootstrap.sql'), 'utf8'));
      for (const name of migrations.filter(n => n < repairName)) {
        await db.exec(await readFile(path.join(migrationDir, name), 'utf8'));
        if (name === '20261026000100_baseline.sql' && beforeProgression) await db.exec(beforeProgression);
      }
      await db.exec('GRANT SELECT ON public.users TO PUBLIC;');
      if (beforeRepair) await db.exec(beforeRepair);
      const defaultsBefore = await db.query('SELECT oid,defaclacl::text FROM pg_default_acl ORDER BY oid');
      if (incompatible) {
        assert.ok(repair, 'repair migration required for fail-closed tests');
        const aclBefore = await db.query("SELECT relname,relacl::text FROM pg_class WHERE relnamespace='public'::regnamespace ORDER BY relname");
        const columnsBefore = await db.query("SELECT attrelid,attnum,attacl::text FROM pg_attribute WHERE attrelid IN (SELECT oid FROM pg_class WHERE relnamespace='public'::regnamespace) ORDER BY attrelid,attnum");
        let caught;
        try { await db.exec(repair); } catch (error) { caught = error; }
        assert.ok(caught, `${label}: incompatible inherited access must reject adoption`);
        pass(`${label} diagnostic SQLSTATE`, caught.code, '42501');
        assert.match(caught.message, /effective progression ACL.*(inherited|role)/i);
        console.log(`PASS ACL ${label} fail-closed diagnostic: ${caught.message}`);
        await db.exec('ROLLBACK');
        pass(`${label} table ACL changes rolled back`, await db.query("SELECT relname,relacl::text FROM pg_class WHERE relnamespace='public'::regnamespace ORDER BY relname"), aclBefore);
        pass(`${label} column ACL changes rolled back`, await db.query("SELECT attrelid,attnum,attacl::text FROM pg_attribute WHERE attrelid IN (SELECT oid FROM pg_class WHERE relnamespace='public'::regnamespace) ORDER BY attrelid,attnum"), columnsBefore);
        pass(`${label} PUBLIC column revoke rolled back`, await scalar(db,
          "SELECT has_column_privilege('anon','public.users','total_xp','UPDATE')"), true);
        return;
      }
      if (repair) {
        await db.exec(repair);
        await db.exec(repair);
        pass(`${label} migration replay succeeds`, true, true);
      }
      pass(`${label} unrelated future-object default ACL templates preserved`,
        await db.query('SELECT oid,defaclacl::text FROM pg_default_acl ORDER BY oid'), defaultsBefore);
      for (const file of ['seed.sql', 'seed_exercises.sql']) await db.exec(await readFile(path.join(root, 'supabase', file), 'utf8'));
      await controls(db, label);
    } finally {
      await db.close();
    }
  }
  await scenario('fresh');
  await scenario('legacy named column', 'GRANT UPDATE(total_xp) ON public.users TO authenticated;');
  await scenario('legacy PUBLIC column', 'GRANT UPDATE(total_xp) ON public.users TO PUBLIC;');
  await scenario('legacy PUBLIC table/default', `ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO PUBLIC;
    GRANT ALL ON public.users,public.profiles,public.workouts,public.xp_logs TO PUBLIC;`);
  await scenario('named post-adoption table/column', '', `GRANT UPDATE ON public.users TO authenticated;
    GRANT UPDATE(total_xp),INSERT(total_xp),REFERENCES(total_xp) ON public.users TO anon;
    GRANT UPDATE(current_xp) ON public.user_classes TO authenticated;`);
  await scenario('inherited protected column', '', `CREATE ROLE legacy_progression NOLOGIN;
    GRANT UPDATE(total_xp) ON public.users TO legacy_progression;
    GRANT legacy_progression TO authenticated;
    GRANT UPDATE(total_xp) ON public.users TO PUBLIC;`, true);
  await scenario('inherited bypass policy', '', `CREATE ROLE legacy_bypass NOLOGIN BYPASSRLS;
    GRANT legacy_bypass TO authenticated;
    GRANT UPDATE(total_xp) ON public.users TO PUBLIC;`, true);
  // Ownership and superuser authority exist only in each disposable in-memory database.
  await scenario('inherited table-owner authority', '', `CREATE ROLE legacy_owner NOLOGIN;
    ALTER TABLE public.users OWNER TO legacy_owner;
    GRANT legacy_owner TO authenticated;
    GRANT UPDATE(total_xp) ON public.users TO PUBLIC;`, true);
  await scenario('inherited superuser authority', '', `CREATE ROLE legacy_superuser NOLOGIN SUPERUSER;
    GRANT legacy_superuser TO authenticated;
    GRANT UPDATE(total_xp) ON public.users TO PUBLIC;`, true);
  await scenario('non-inherited SET role path', '', `CREATE ROLE legacy_set NOLOGIN;
    GRANT UPDATE(total_xp) ON public.users TO legacy_set;
    GRANT legacy_set TO authenticated WITH INHERIT FALSE;
    GRANT UPDATE(total_xp) ON public.users TO PUBLIC;`, true);
  console.log(`PASS effective ACL regression: 10 isolated databases, ${checks} assertions`);
  console.log('LIMITATION: synthetic PGlite ACL adoption only; no deployed ACL inventory, gateway or future administrator-grant guarantee.');
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  try { await runEffectiveAclRegression(); } catch (error) {
    console.error(`FAIL effective ACL regression: ${error.stack ?? error}`);
    process.exitCode = 1;
  }
}
