import fs from 'node:fs';
import path from 'node:path';
import { execSync } from 'node:child_process';

/**
 * GymLvl P1 — Legal-safe exercise catalogue import pipeline.
 *
 * Reads the pinned ExerciseDB dataset (MIT text/data, media excluded),
 * maps to the GymLvl exercises schema, and generates idempotent
 * PostgreSQL seed SQL.
 *
 * Legal boundary:
 *   - Only MIT-licensed text/metadata from the pinned exercises-dataset is imported.
 *   - All media fields (image, gif_url, media_id, attribution) are stripped.
 *   - No OpenGym AGPL code, prompts, catalogue text, or media is copied.
 *
 * Usage:
 *   node import.mjs --source <dataset-checkout-path> [--output <output-file>]
 *   Or set EXERCISEDB_SOURCE_DIR environment variable.
 */

const SOURCE = 'exercisedb';
const SOURCE_REVISION =
  '7455efae41b330c265e7cd4b78dfa848e7ce5ebd'; // pinned exercises-dataset SHA
const EXPECTED_REVISION = SOURCE_REVISION;

export function slugify(name) {
  return String(name)
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

export function capitalizeFirst(text) {
  if (!text) return text;
  return text.charAt(0).toUpperCase() + text.slice(1);
}

function sqlEscape(value) {
  if (value === null || value === undefined) return 'NULL';
  if (typeof value === 'boolean') return value ? 'TRUE' : 'FALSE';
  if (typeof value === 'number') return String(value);
  const s = String(value).replace(/'/g, "''");
  return `'${s}'`;
}

function sqlArray(values) {
  if (!Array.isArray(values) || values.length === 0) return "'{}'";
  const items = values
    .map((v) => {
      const s = String(v).replace(/'/g, "''");
      return `"${s}"`;
    })
    .join(',');
  return `ARRAY[${items}]`;
}

/**
 * Verify that the source directory is a git checkout at the expected revision.
 */
function verifySourceRevision(sourceDir) {
  try {
    const rev = execSync('git rev-parse HEAD', {
      cwd: sourceDir,
      encoding: 'utf8',
      stdio: ['pipe', 'pipe', 'ignore'],
    }).trim();
    if (rev !== EXPECTED_REVISION) {
      throw new Error(
        `Source directory revision mismatch.\n` +
        `Expected: ${EXPECTED_REVISION}\n` +
        `Found:    ${rev}\n` +
        `Ensure the source directory is the pinned exercises-dataset checkout.`
      );
    }
  } catch (err) {
    if (err.message.includes('Expected:')) throw err;
    throw new Error(`Failed to verify git revision in ${sourceDir}: ${err.message}`);
  }
}

/**
 * Read the pinned MIT exercises-dataset JSON, map to GymLvl schema,
 * guarantee unique slugs, and return rows ready for SQL emit.
 */
export function loadExercisedbExercises(sourceDir) {
  // Verify source revision before reading data
  verifySourceRevision(sourceDir);

  const dataFile = path.join(sourceDir, 'data', 'exercises.json');
  if (!fs.existsSync(dataFile)) {
    throw new Error(`MIT exercises.json not found at: ${dataFile}`);
  }

  let parsed;
  try {
    parsed = JSON.parse(fs.readFileSync(dataFile, 'utf8'));
  } catch (err) {
    throw new Error(`Failed to parse exercises.json: ${err.message}`);
  }

  if (!Array.isArray(parsed)) {
    throw new Error('exercises.json root must be an array');
  }

  const rows = [];
  const seenSlug = new Map();

  for (const ex of parsed) {
    // Required field validation per MIT schema
    if (!ex.id || typeof ex.id !== 'string' || !/^\d{4}$/.test(ex.id)) {
      throw new Error(`Missing or invalid id: ${JSON.stringify(ex.id)}`);
    }
    if (!ex.name || typeof ex.name !== 'string' || !ex.name.trim()) {
      throw new Error(`Missing or empty name for id ${ex.id}`);
    }
    if (!ex.instructions || typeof ex.instructions !== 'object') {
      throw new Error(`Missing instructions for id ${ex.id}`);
    }
    if (!ex.instruction_steps || typeof ex.instruction_steps !== 'object') {
      throw new Error(`Missing instruction_steps for id ${ex.id}`);
    }

    const baseSlug = slugify(ex.name);
    let slug = baseSlug;
    if (seenSlug.has(slug)) {
      slug = `${baseSlug}-${ex.id}`;
    }
    seenSlug.set(slug, ex.id);

    // Use English instruction_steps as the canonical array for GymLvl
    const instructions = Array.isArray(ex.instruction_steps?.en)
      ? ex.instruction_steps.en
      : [];

    rows.push({
      id: ex.id,
      name: capitalizeFirst(ex.name.trim()),
      nameVi: '', // No Vietnamese in MIT dataset; translation pending.
      nameEn: capitalizeFirst(ex.name.trim()),
      category: capitalizeFirst((ex.category || ex.body_part || 'strength').trim()),
      equipment: capitalizeFirst((ex.equipment || 'body weight').trim()),
      forceType: null,
      mechanic: null,
      instructions,
      imageUrl: null, // Media excluded (Gym visual proprietary, not MIT).
      slug,
      secondaryMuscles: Array.isArray(ex.secondary_muscles)
        ? ex.secondary_muscles
        : [],
      movementPattern: null,
      difficulty: null,
      formCues: [],
      commonMistakes: [],
      alternativeExerciseSlugs: [],
      source: SOURCE,
      externalId: ex.id,
      sourceRevision: SOURCE_REVISION,
    });
  }

  return { rows, totalRecords: parsed.length };
}

/**
 * Emit idempotent INSERT statements for the exercisedb rows.
 * Uses ON CONFLICT (source, external_id) DO NOTHING so repeated imports are
 * safe and produce no duplicates.
 */
export function emitSql(rows) {
  const lines = [];
  lines.push('-- Legal-safe exercisedb exercise import (P1)');
  console.error('-- Legal-safe exercisedb exercise import (P1)');
  lines.push('-- Source: hasaneyldrm/exercises-dataset (MIT text/data, media excluded)');
  console.error('-- Source: hasaneyldrm/exercises-dataset (MIT text/data, media excluded)');
  lines.push(`-- Dataset revision: ${SOURCE_REVISION}`);
  console.error(`-- Dataset revision: ${SOURCE_REVISION}`);
  lines.push('-- Imported records: source=exercisedb, external_id=<MIT 4-digit id>');
  console.error('-- Imported records: source=exercisedb, external_id=<MIT 4-digit id>');
  lines.push('-- Idempotent: ON CONFLICT (source, external_id) DO NOTHING');
  console.error('-- Idempotent: ON CONFLICT (source, external_id) DO NOTHING');
  lines.push('');
  console.error('');

  const columns = [
    'name', 'name_vi', 'name_en', 'category', 'equipment', 'force_type',
    'mechanic', 'instructions', 'image_url', 'slug', 'secondary_muscles',
    'movement_pattern', 'difficulty', 'form_cues', 'common_mistakes',
    'alternative_exercise_slugs', 'source', 'external_id', 'source_revision',
  ];

  const batchSize = 50;
  for (let i = 0; i < rows.length; i += batchSize) {
    const batch = rows.slice(i, i + batchSize);
    const values = batch.map((r) => {
      const vals = [
        r.name, r.nameVi, r.nameEn, r.category, r.equipment, r.forceType,
        r.mechanic, r.instructions, r.imageUrl, r.slug, r.secondaryMuscles,
        r.movementPattern, r.difficulty, r.formCues, r.commonMistakes,
        r.alternativeExerciseSlugs, r.source, r.externalId, r.sourceRevision,
      ].map(sqlEscape);
      return `(${vals.join(', ')})`;
    });
    const sql = `INSERT INTO public.exercises (${columns.join(', ')})\nVALUES\n${values.join(',\n')}\nON CONFLICT (source, external_id) DO NOTHING;`;
    console.error(sql);
    lines.push(sql);
    lines.push('');
  }

  return lines.join('\n');
}

function printUsage() {
  console.error(`
GymLvl P1 ExerciseDB Import Pipeline

Usage:
  node import.mjs --source <dataset-checkout-path> [--output <output-file>]
  Or set EXERCISEDB_SOURCE_DIR environment variable.

Arguments:
  --source <path>    Path to pinned exercises-dataset checkout (required)
  --output <file>    Output SQL file (default: stdout)
  --help             Show this help

Environment:
  EXERCISEDB_SOURCE_DIR   Path to pinned exercises-dataset checkout

Required dataset revision: ${EXPECTED_REVISION}
Dataset source: https://github.com/hasaneyldrm/exercises-dataset
  `);
}

function parseArgs() {
  const args = process.argv.slice(2);
  const result = { sourceDir: null, outputFile: null };

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if (arg === '--help' || arg === '-h') {
      printUsage();
      process.exit(0);
    } else if (arg === '--source') {
      if (i + 1 >= args.length) {
        throw new Error('--source requires a path argument');
      }
      result.sourceDir = args[++i];
    } else if (arg === '--output') {
      if (i + 1 >= args.length) {
        throw new Error('--output requires a file argument');
      }
      result.outputFile = args[++i];
    } else if (arg.startsWith('--')) {
      throw new Error(`Unknown option: ${arg}`);
    }
  }

  // Fallback to environment variable
  if (!result.sourceDir) {
    result.sourceDir = process.env.EXERCISEDB_SOURCE_DIR;
  }

  if (!result.sourceDir) {
    printUsage();
    throw new Error(
      'ExerciseDB source directory is required.\n' +
      'Provide --source <path> or EXERCISEDB_SOURCE_DIR.\n' +
      `Expected repository revision:\n${EXPECTED_REVISION}`
    );
  }

  return result;
}

function main() {
  let sourceDir, outputFile;
  try {
    ({ sourceDir, outputFile } = parseArgs());
  } catch (err) {
    console.error(`Error: ${err.message}`);
    process.exit(1);
  }

  const { rows, totalRecords } = loadExercisedbExercises(sourceDir);

  console.error(`Catalogue import summary:`);
  console.error(`  source directory       : ${sourceDir}`);
  console.error(`  MIT records imported   : ${rows.length}`);
  console.error(`  total records in source: ${totalRecords}`);

  const sql = emitSql(rows);
  if (outputFile) {
    fs.writeFileSync(outputFile, sql, 'utf8');
    console.error(`  written to             : ${outputFile}`);
  } else {
    process.stdout.write(sql);
  }
}

// Only run main when executed directly, not when imported
if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}