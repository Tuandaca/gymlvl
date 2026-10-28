import assert from 'node:assert/strict';
import { readFile, readdir } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { PGlite } from '@electric-sql/pglite';
import { pgcrypto } from '@electric-sql/pglite/contrib/pgcrypto';
import { runEffectiveAclRegression } from './effective-acl-regression.mjs';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../..');
const db = new PGlite({ extensions: { pgcrypto } });
let completed = 0;

async function runSql(label, filename) {
  try {
    await db.exec(await readFile(filename, 'utf8'));
    completed++;
    console.log(`PASS ${label}`);
  } catch (error) {
    console.error(`FAIL ${label}: ${error.message}`);
    throw error;
  }
}

try {
  await runSql('isolated auth/role bootstrap', path.join(here, 'bootstrap.sql'));
  const migrationsDir = path.join(root, 'supabase/migrations');
  const migrations = (await readdir(migrationsDir)).filter(name => name.endsWith('.sql')).sort();
  assert(migrations.length > 0, 'At least one versioned migration is required');
  for (const name of migrations) {
    assert.match(name, /^\d{14}_[a-z0-9_]+\.sql$/, `Unversioned migration: ${name}`);
    await runSql(`migration ${name}`, path.join(migrationsDir, name));
  }
  const config = await readFile(path.join(root, 'supabase/config.toml'), 'utf8');
  const seedSection = config.match(/\[db\.seed\]([\s\S]*?)(?=\n\[|$)/)?.[1] ?? '';
  if (!/enabled\s*=\s*false/.test(seedSection)) {
    const seedFiles = [...(seedSection.match(/sql_paths\s*=\s*\[([\s\S]*?)\]/)?.[1] ?? '').matchAll(/"([^"]+)"/g)].map(match => match[1]);
    for (const name of seedFiles) {
      const filename = path.resolve(root, 'supabase', name);
      assert(filename.startsWith(path.join(root, 'supabase') + path.sep), 'Seed must be inside supabase');
      await runSql(`seed ${name}`, filename);
      await runSql(`seed replay ${name}`, filename);
    }
  }
  const testsDir = path.join(root, 'supabase/tests');
  const tests = (await readdir(testsDir)).filter(name => name.endsWith('.sql')).sort();
  assert(tests.length > 0, 'SQL regression tests are required');
  for (const name of tests) await runSql(`SQL regression ${name}`, path.join(testsDir, name));

  // Exercise catalog & schema verification
  const countRes = await db.query('SELECT count(*)::integer as total FROM public.exercises');
  const totalExercises = Number(countRes.rows[0].total);
  assert(totalExercises >= 120 && totalExercises <= 200, `Exercise count must be between 120 and 200, found ${totalExercises}`);
  console.log(`VERIFIED exercise catalog count: ${totalExercises} exercises (target 120-200)`);

  const nullRes = await db.query("SELECT count(*)::integer as nulls FROM public.exercises WHERE slug IS NULL OR slug = '' OR name_vi = '' OR name_en = '' OR movement_pattern IS NULL");
  const nullCount = Number(nullRes.rows[0].nulls);
  assert(nullCount === 0, `Exercises must not have null or empty required metadata, found ${nullCount}`);
  console.log(`VERIFIED exercise catalog metadata integrity (0 null/empty fields)`);

  const colRes = await db.query("SELECT column_name FROM information_schema.columns WHERE table_schema='public' AND table_name='workout_sets' AND column_name='duration_seconds'");
  assert(colRes.rows.length === 1, 'workout_sets.duration_seconds column must exist');
  console.log(`VERIFIED workout_sets duration_seconds column exists`);

  // Test workout_sets_valid_values constraint for duration_seconds & static holds
  await db.exec(`
    BEGIN;
    SELECT set_config('request.jwt.claim.sub', '99999999-9999-9999-9999-999999999999', true);
    SELECT set_config('request.jwt.claims', '{"sub":"99999999-9999-9999-9999-999999999999","role":"authenticated"}', true);
    INSERT INTO auth.users(id, email, raw_user_meta_data) VALUES ('99999999-9999-9999-9999-999999999999', 'duration-test@example.test', '{}');
    INSERT INTO public.workouts(id, user_id, status) VALUES ('88888888-8888-8888-8888-888888888888', '99999999-9999-9999-9999-999999999999', 'active');
    INSERT INTO public.workout_exercises(id, workout_id, exercise_id) SELECT '77777777-7777-7777-7777-777777777777', '88888888-8888-8888-8888-888888888888', id FROM public.exercises LIMIT 1;

    -- Valid: static hold with 0 reps and 60 seconds duration
    INSERT INTO public.workout_sets(workout_exercise_id, reps, weight_kg, duration_seconds, is_completed)
    VALUES ('77777777-7777-7777-7777-777777777777', 0, 0, 60, true);
    ROLLBACK;
  `);

  await assert.rejects(
    async () => {
      try {
        await db.exec(`
          BEGIN;
          SELECT set_config('request.jwt.claim.sub', '99999999-9999-9999-9999-999999999999', true);
          SELECT set_config('request.jwt.claims', '{"sub":"99999999-9999-9999-9999-999999999999","role":"authenticated"}', true);
          INSERT INTO auth.users(id, email, raw_user_meta_data) VALUES ('99999999-9999-9999-9999-999999999999', 'fail-test@example.test', '{}');
          INSERT INTO public.workouts(id, user_id, status) VALUES ('88888888-8888-8888-8888-888888888888', '99999999-9999-9999-9999-999999999999', 'active');
          INSERT INTO public.workout_exercises(id, workout_id, exercise_id) SELECT '77777777-7777-7777-7777-777777777777', '88888888-8888-8888-8888-888888888888', id FROM public.exercises LIMIT 1;
          -- Invalid: completed with 0 reps and 0 duration_seconds should fail check constraint
          INSERT INTO public.workout_sets(workout_exercise_id, reps, weight_kg, duration_seconds, is_completed)
          VALUES ('77777777-7777-7777-7777-777777777777', 0, 0, 0, true);
          COMMIT;
        `);
      } finally {
        await db.exec('ROLLBACK;');
      }
    },
    /23514|check_violation|workout_sets_valid_values/i
  );
  console.log(`VERIFIED static hold / duration_seconds check constraint behavior`);

  await runEffectiveAclRegression();
  console.log(`PASS ${completed} SQL verification units against PostgreSQL ${String((await db.query('show server_version')).rows[0].server_version)}`);
  console.log('LIMITATION: isolated single-connection PostgreSQL; Supabase gateway/Auth/Edge runtime and true concurrent sessions require the local stack.');
} catch (error) {
  console.error(`FAIL verification: ${error.message}`);
  if (error.code) console.error(`PostgreSQL code: ${error.code}`);
  process.exitCode = 1;
} finally {
  await db.close();
}
