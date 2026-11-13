import assert from 'node:assert/strict';
import { readFile, readdir } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { PGlite } from '@electric-sql/pglite';
import { pgcrypto } from '@electric-sql/pglite/contrib/pgcrypto';
import { emitSql, loadExercisedbExercises } from '../catalogue-import/import.mjs';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../..');
const sourceDir = process.env.EXERCISEDB_SOURCE_DIR;
assert(sourceDir, 'Set EXERCISEDB_SOURCE_DIR to the pinned MIT checkout');
const { rows } = loadExercisedbExercises(sourceDir);
assert.equal(rows.length, 1324);
const db = new PGlite({ extensions: { pgcrypto } });
let failed = false;
const query = async (sql, params = []) => (await db.query(sql, params)).rows;
try {
  await db.exec(await readFile(path.join(here, 'bootstrap.sql'), 'utf8'));
  const migrationsDir = path.join(root, 'supabase/migrations');
  const migrations = (await readdir(migrationsDir)).filter(name => name.endsWith('.sql')).sort();
  assert(migrations.length > 0);
  for (const name of migrations) {
    await db.exec(await readFile(path.join(migrationsDir, name), 'utf8'));
  }
  const config = await readFile(path.join(root, 'supabase/config.toml'), 'utf8');
  const seedSection = config.match(/\[db\.seed\]([\s\S]*?)(?=\n\[|$)/)?.[1] ?? '';
  assert(!/enabled\s*=\s*false/.test(seedSection), 'Normal seed must be enabled');
  const seeds = [...(seedSection.match(/sql_paths\s*=\s*\[([\s\S]*?)\]/)?.[1] ?? '').matchAll(/"([^"]+)"/g)].map(match => match[1]);
  assert(seeds.length > 0);
  for (const seed of seeds) {
    const filename = path.resolve(root, 'supabase', seed);
    assert(filename.startsWith(path.join(root, 'supabase') + path.sep));
    await db.exec(await readFile(filename, 'utf8'));
  }
  const curated = await query('SELECT * FROM public.exercises ORDER BY id');
  assert.equal(curated.length, 150, 'Normal seed must contain 150 curated exercises');
  // Synthetic local history references an actual curated UUID through the real FK.
  await db.exec(`
    SELECT set_config('request.jwt.claim.sub', '99999999-9999-4999-8999-999999999999', false);
    SELECT set_config('request.jwt.claims', '{"sub":"99999999-9999-4999-8999-999999999999","role":"authenticated"}', false);
    INSERT INTO auth.users(id, email, raw_user_meta_data)
    VALUES ('99999999-9999-4999-8999-999999999999', 'p10-catalogue@example.test', '{}');
    INSERT INTO public.workouts(id, user_id, status)
    VALUES ('88888888-8888-4888-8888-888888888888', '99999999-9999-4999-8999-999999999999', 'active');
    INSERT INTO public.workout_exercises(id, workout_id, exercise_id)
    SELECT '77777777-7777-4777-8777-777777777777', '88888888-8888-4888-8888-888888888888', id
    FROM public.exercises ORDER BY id LIMIT 1;
  `);
  const historyBefore = await query('SELECT * FROM public.workout_exercises ORDER BY id');
  const sql = emitSql(rows);
  let firstImport;
  for (let pass = 1; pass <= 2; pass++) {
    await db.exec(sql);
    const imported = await query("SELECT * FROM public.exercises WHERE source = 'exercisedb' ORDER BY external_id");
    assert.equal((await query('SELECT id FROM public.exercises')).length, 1474, `Import ${pass}: total`);
    assert.equal(imported.length, 1324, `Import ${pass}: imported count`);
    const curatedAfter = await query("SELECT * FROM public.exercises WHERE source <> 'exercisedb' ORDER BY id");
    assert.deepEqual(curatedAfter, curated, 'All curated UUIDs and complete rows remain unchanged');
    assert.deepEqual(await query('SELECT * FROM public.workout_exercises ORDER BY id'), historyBefore);
    if (firstImport) assert.deepEqual(imported, firstImport, 'Replay must not change any imported row or UUID');
    firstImport = imported;
    assert.equal(new Set(imported.map(row => `${row.source}:${row.external_id}`)).size, 1324);
    assert.equal(new Set((await query('SELECT slug FROM public.exercises')).map(row => row.slug)).size, 1474);
    for (const expected of rows) {
      const actual = imported.find(row => row.external_id === expected.externalId);
      assert(actual);
      assert.equal(actual.source_revision, expected.sourceRevision);
      assert.equal(actual.image_url, null);
      assert.equal(actual.name_en, expected.nameEn);
      assert.deepEqual(actual.instructions, expected.instructions);
      assert.deepEqual(actual.secondary_muscles, expected.secondaryMuscles);
      assert(!/https?:\/\//i.test(JSON.stringify(actual)), 'Imported rows must contain no media links');
    }
    assert(imported.some(row => row.instructions.length > 1));
    assert(imported.some(row => row.secondary_muscles.length > 1));
    console.log(`PASS import ${pass}: 1474 total / 1324 imported; 150 curated rows and history unchanged; unique keys/slugs; exact arrays/provenance; no media`);
  }
  const searchable = rows.find(row => /press/i.test(row.name));
  assert(searchable, 'Pinned catalogue must supply a useful search fixture');
  const hits = await query("SELECT external_id FROM public.exercises WHERE name ILIKE '%press%' AND source = 'exercisedb' ORDER BY name, id");
  assert(hits.some(row => row.external_id === searchable.externalId));
  const filtered = await query("SELECT id FROM public.exercises WHERE category = $1 AND equipment = $2 AND source = 'exercisedb'", [searchable.category, searchable.equipment]);
  assert(filtered.length > 0);
  console.log(`PASS search/filter: ${hits.length} press matches; ${filtered.length} category/equipment matches; ${migrations.length} ordered migrations and ${seeds.length} normal seeds`);
  console.log('LIMITATION: isolated single-connection PGlite; no live Supabase gateway, device UI, RLS session or production verification.');
} catch (error) {
  failed = true;
  console.error(`FAIL catalogue rehearsal: ${error.message}`);
  if (error.code) console.error(`PostgreSQL code: ${error.code}`);
} finally {
  await db.close();
  if (failed) process.exitCode = 1;
}
