import { strict as assert } from 'node:assert';
import { test } from 'node:test';
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

import { loadExercisedbExercises, emitSql, slugify } from './import.mjs';

const SOURCE_REVISION =
  '7455efae41b330c265e7cd4b78dfa848e7ce5ebd';

// Use environment variable or fail with clear message
const SOURCE_DIR = process.env.EXERCISEDB_SOURCE_DIR;
if (!SOURCE_DIR) {
  console.error('EXERCISEDB_SOURCE_DIR not set; skipping import tests');
  process.exit(0);
}

test('slugify produces lowercase dash-separated slugs', () => {
  assert.strictEqual(slugify('Barbell Bench Press'), 'barbell-bench-press');
  assert.strictEqual(slugify('Push-up (on stability ball)'), 'push-up-on-stability-ball');
  assert.strictEqual(slugify('  leading and trailing  '), 'leading-and-trailing');
});

test('loadExercisedbExercises derives exact MIT record count (1,324)', () => {
  const { rows, totalRecords } = loadExercisedbExercises(SOURCE_DIR);

  assert.strictEqual(totalRecords, 1324);
  assert.strictEqual(rows.length, 1324);

  for (const row of rows) {
    assert.ok(row.id, `missing id`);
    assert.ok(row.name, `missing name`);
    assert.ok(row.slug, `missing slug`);
    assert.strictEqual(row.source, 'exercisedb');
    assert.strictEqual(row.sourceRevision, SOURCE_REVISION);
    assert.strictEqual(row.externalId, row.id);
    assert.strictEqual(row.imageUrl, null); // media stripped
    assert.strictEqual(row.nameVi, ''); // no Vietnamese in MIT dataset
    assert.ok(Array.isArray(row.instructions));
    assert.ok(Array.isArray(row.secondaryMuscles));
  }
});

test('all slugs are unique among imported rows', () => {
  const { rows } = loadExercisedbExercises(SOURCE_DIR);
  const slugs = rows.map((r) => r.slug);
  const unique = new Set(slugs);
  assert.strictEqual(unique.size, slugs.length, 'duplicate slug detected');
  assert.ok(slugs.every((slug) => slug.startsWith('exercisedb-')), 'source namespace avoids curated slug collisions');
  assert.strictEqual(new Set(rows.map((r) => `${r.source}:${r.externalId}`)).size, rows.length);
});

test('duplicate names are disambiguated with external id', () => {
  const { rows } = loadExercisedbExercises(SOURCE_DIR);
  const byName = new Map();
  for (const row of rows) {
    const key = row.name.toLowerCase();
    if (!byName.has(key)) byName.set(key, []);
    byName.get(key).push(row);
  }
  const duplicates = [...byName.values()].filter((g) => g.length > 1);
  assert.ok(duplicates.length > 0, 'expected duplicate-named records');
  for (const group of duplicates) {
    const slugs = group.map((r) => r.slug);
    assert.strictEqual(
      new Set(slugs).size,
      slugs.length,
      `duplicate slugs for name "${group[0].name}"`,
    );
    const firstSlug = group[0].slug;
    const disambiguated = group.some((r) => r.slug !== firstSlug);
    assert.ok(disambiguated, `name "${group[0].name}" not disambiguated`);
  }
});

test('media fields are stripped (image_url null, no media links)', () => {
  const { rows } = loadExercisedbExercises(SOURCE_DIR);
  for (const row of rows) {
    assert.strictEqual(row.imageUrl, null);
    assert.doesNotMatch(JSON.stringify(row), /https?:\/\/|\.(gif|png|jpe?g|webp|mp4)\b/i);
  }
});

test('direct CLI invocation writes output even when paths contain spaces', () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'gymlvl import '));
  const output = path.join(directory, 'catalogue output.sql');
  try {
    const result = spawnSync(process.execPath, [fileURLToPath(new URL('./import.mjs', import.meta.url)), '--source', SOURCE_DIR, '--output', output], { encoding: 'utf8' });
    assert.strictEqual(result.status, 0, result.stderr);
    assert.ok(fs.existsSync(output), `CLI exited ${result.status} without creating output; stderr: ${result.stderr}`);
    assert.match(fs.readFileSync(output, 'utf8'), /INSERT INTO public.exercises/);
    assert.strictEqual(result.stdout, '');
    assert.doesNotMatch(result.stderr, /INSERT INTO public.exercises/);
  } finally {
    fs.rmSync(directory, { recursive: true, force: true });
  }
});

test('emitSql preserves text array items and SQL quoting', () => {
  const { rows } = loadExercisedbExercises(SOURCE_DIR);
  const row = { ...rows[0], instructions: ["Don't stop, breathe.", 'Keep "neutral" posture.', String.raw`Back\slash`], secondaryMuscles: ['upper back', 'triceps'] };
  const sql = emitSql([row]);
  assert.ok(sql.includes(String.raw`ARRAY['Don''t stop, breathe.', 'Keep "neutral" posture.', 'Back\slash']::text[]`));
  assert.ok(sql.includes("ARRAY['upper back', 'triceps']::text[]"));
  assert.ok(sql.includes('ARRAY[]::text[]'));
});

test('MIT dataset fields mapped correctly', () => {
  const { rows } = loadExercisedbExercises(SOURCE_DIR);
  // Spot-check a few known records
  const byId = new Map(rows.map((r) => [r.externalId, r]));
  
  // ID 0001: "3/4 sit-up" -> "3/4 sit-up" (capitalizeFirst only capitalizes first char)
  const ex0001 = byId.get('0001');
  assert.ok(ex0001);
  assert.strictEqual(ex0001.name, '3/4 sit-up');
  assert.strictEqual(ex0001.category, 'Waist');
  assert.ok(ex0001.instructions.length > 0);
  
  // Verify equipment capitalization
  const exBodyweight = rows.find(r => r.equipment === 'Body weight');
  assert.ok(exBodyweight, 'expected body weight exercises');
  
  // Verify secondary_muscles is array
  for (const row of rows) {
    assert.ok(Array.isArray(row.secondaryMuscles));
  }
});

test('emitSql is idempotent: identical output on repeated calls', () => {
  const { rows } = loadExercisedbExercises(SOURCE_DIR);
  const first = emitSql(rows);
  const second = emitSql(rows);
  assert.strictEqual(first, second);
});

test('emitSql uses ON CONFLICT (source, external_id) DO NOTHING', () => {
  const { rows } = loadExercisedbExercises(SOURCE_DIR);
  const sql = emitSql(rows);
  assert.ok(sql.includes('ON CONFLICT (source, external_id) DO NOTHING'));
  assert.ok(sql.includes("'exercisedb', '"));
});

test('emitSql references pinned MIT dataset revision', () => {
  const { rows } = loadExercisedbExercises(SOURCE_DIR);
  const sql = emitSql(rows);
  assert.ok(sql.includes(SOURCE_REVISION));
});

test('generated SQL retains the complete upstream MIT notice without media links', () => {
  const notice = fs.readFileSync(path.join(SOURCE_DIR, 'LICENSE'), 'utf8')
    .split(/\r?\n-{10,}/)[0].trim();
  const sql = emitSql([]);
  const comments = sql.split('\n').filter((line) => line.startsWith('-- '))
    .map((line) => line.slice(3)).join('\n');
  assert.ok(comments.includes(notice.replace(/\r\n/g, '\n')));
  assert.doesNotMatch(sql, /https?:\/\//i);
});

test('every SQL INSERT lists provenance columns', () => {
  const { rows } = loadExercisedbExercises(SOURCE_DIR);
  const sql = emitSql(rows);
  for (const col of ['source', 'external_id', 'source_revision']) {
    assert.ok(sql.includes(col), `missing column ${col} in generated SQL`);
  }
});

test('generated SQL can be written to a file and is non-empty', () => {
  const { rows } = loadExercisedbExercises(SOURCE_DIR);
  const out = path.join(process.cwd(), 'seed_exercises_exercisedb.test.sql');
  try {
    const sql = emitSql(rows);
    fs.writeFileSync(out, sql, 'utf8');
    const written = fs.readFileSync(out, 'utf8');
    assert.ok(written.length > 0);
    assert.ok(written.includes('INSERT INTO public.exercises'));
  } finally {
    if (fs.existsSync(out)) fs.unlinkSync(out);
  }
});
