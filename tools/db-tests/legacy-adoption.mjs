// Optional safety rehearsal using a private backup; no production connections.
// All record contents remain in memory. Output contains table names/counts only.
import assert from 'node:assert/strict';
import { readFile, readdir } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { PGlite } from '@electric-sql/pglite';
import { pgcrypto } from '@electric-sql/pglite/contrib/pgcrypto';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../..');
const filename = process.env.GYMLVL_LEGACY_BACKUP;
if (!filename) throw new Error('Set GYMLVL_LEGACY_BACKUP to a private local backup JSON file.');
const envelope = JSON.parse((await readFile(filename, 'utf8')).replace(/^\uFEFF/, ''));
const backup = envelope.rows?.[0]?.backup;
assert(backup && typeof backup === 'object', 'Expected rows[0].backup JSON envelope');
const tables = ['users', 'profiles', 'exercises', 'quests', 'class_definitions', 'class_synergies', 'workouts', 'workout_exercises', 'workout_sets', 'xp_logs', 'streaks', 'exercise_prs', 'quest_instances', 'user_classes'];
const db = new PGlite({ extensions: { pgcrypto } });
const original = new Map();
let failed = false;

function key(table, row) {
  if (table === 'class_definitions') return row.class_id;
  if (table === 'class_synergies') return `${row.primary_class_id}:${row.secondary_class_id}`;
  return row.id;
}

try {
  await db.exec(await readFile(path.join(here, 'bootstrap.sql'), 'utf8'));
  const migrations = (await readdir(path.join(root, 'supabase/migrations'))).filter(name => name.endsWith('.sql')).sort();
  const baseline = await readFile(path.join(root, 'supabase/migrations', migrations[0]), 'utf8');
  await db.exec(baseline);
  // These baseline catalogue records exist only in this disposable in-memory DB.
  await db.exec('DELETE FROM public.class_synergies; DELETE FROM public.class_definitions;');
  for (let index = 0; index < backup.users.length; index++) {
    await db.query('INSERT INTO auth.users(id,email) VALUES($1,$2)', [backup.users[index].id, `legacy-${index}@example.test`]);
  }
  for (const table of tables) {
    const rows = backup[table];
    assert(Array.isArray(rows), `Missing backup table: ${table}`);
    if (rows.length) await db.query(`INSERT INTO public.${table} SELECT * FROM jsonb_populate_recordset(NULL::public.${table},$1::jsonb)`, [JSON.stringify(rows)]);
    original.set(table, (await db.query(`SELECT to_jsonb(t) AS record FROM public.${table} t`)).rows.map(row => row.record));
  }
  // Simulate applying the canonical baseline to an already-populated legacy schema.
  await db.exec(baseline);
  for (const migration of migrations.slice(1)) {
    await db.exec(await readFile(path.join(root, 'supabase/migrations', migration), 'utf8'));
  }
  for (const table of tables) {
    const before = original.get(table);
    const after = (await db.query(`SELECT to_jsonb(t) AS record FROM public.${table} t`)).rows.map(row => row.record);
    const catalog = table === 'class_definitions' || table === 'class_synergies';
    assert(catalog ? after.length >= before.length : after.length === before.length, `${table}: row count changed unexpectedly`);
    const lookup = new Map(after.map(row => [key(table, row), row]));
    for (const row of before) {
      const current = lookup.get(key(table, row));
      assert(current, `${table}: a legacy record disappeared`);
      if (catalog) continue; // A-F catalogue descriptions/bonuses intentionally reconciled.
      for (const field of Object.keys(row)) {
        if (table === 'workouts' && field === 'updated_at') continue; // Backfill fires original timestamp trigger.
        // Avoid assertion diagnostics that could print private record values.
        assert(JSON.stringify(row[field]) === JSON.stringify(current[field]), `${table}.${field}: a legacy value changed`);
      }
    }
    console.log(`PASS legacy preservation ${table}: ${before.length} records`);
  }
  const timers = await db.query('SELECT count(*)::int AS missing FROM public.workouts WHERE training_started_at IS DISTINCT FROM started_at');
  assert.equal(timers.rows[0].missing, 0, 'Legacy workout clocks must preserve original started_at');
  const role = await db.query("SELECT has_column_privilege('authenticated','public.users','total_xp','UPDATE') AS writable");
  assert.equal(role.rows[0].writable, false, 'Adoption must revoke client XP writes');
  console.log('PASS populated legacy schema adoption, original user data preserved, XP privileges closed');
} catch (error) {
  failed = true;
  // Never echo SQL DETAIL, parameters, backup paths, identifiers, or row values.
  console.error(`FAIL legacy adoption: ${error.code ?? 'assertion'}; ${error instanceof assert.AssertionError ? error.message : 'database operation failed; inspect locally without printing private data'}`);
} finally {
  await db.close();
  if (failed) process.exitCode = 1;
}
