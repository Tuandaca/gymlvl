import assert from 'node:assert/strict';
import { readFile, readdir } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { PGlite } from '@electric-sql/pglite';
import { pgcrypto } from '@electric-sql/pglite/contrib/pgcrypto';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../..');
const db = new PGlite({ extensions: { pgcrypto } });

let passed = 0;
let failed = 0;
const testResults = [];

function recordPass(name, details = '') {
  passed++;
  testResults.push({ name, status: 'PASS', details });
  console.log(`  [PASS] ${name}${details ? ` -- ${details}` : ''}`);
}

function recordFail(name, error) {
  failed++;
  const msg = error instanceof Error ? error.message : String(error);
  testResults.push({ name, status: 'FAIL', error: msg });
  console.error(`  [FAIL] ${name} -- ${msg}`);
}

async function runSql(filename) {
  const content = await readFile(filename, 'utf8');
  await db.exec(content);
}

async function setupDatabase() {
  console.log('\n================================================================');
  console.log('   GymLevel E2E Catalog & Duration Set Schema Verification');
  console.log('================================================================');
  console.log('--- Initializing Isolated PostgreSQL 17 Database Engine ---');

  // 1. Bootstrap auth/roles
  await runSql(path.join(here, 'bootstrap.sql'));

  // 2. Apply all versioned migrations in chronological order
  const migrationsDir = path.join(root, 'supabase/migrations');
  const migrationFiles = (await readdir(migrationsDir)).filter(f => f.endsWith('.sql')).sort();
  console.log(`Applying ${migrationFiles.length} migration(s)...`);
  for (const file of migrationFiles) {
    console.log(`  - migration: ${file}`);
    await runSql(path.join(migrationsDir, file));
  }

  // 3. Apply baseline seed
  const baselineSeed = path.join(root, 'supabase/seed.sql');
  if (existsSync(baselineSeed)) {
    console.log('Applying baseline seed.sql...');
    await runSql(baselineSeed);
  }

  // 4. Apply expanded exercise catalog seed if present
  const exerciseSeed = path.join(root, 'supabase/seed_exercises.sql');
  if (existsSync(exerciseSeed)) {
    console.log('Applying expanded seed_exercises.sql...');
    await runSql(exerciseSeed);
  } else {
    console.log('Notice: supabase/seed_exercises.sql not yet created in tree.');
  }

  console.log('Database initialization complete.\n');
}

async function testCatalogCount() {
  const testName = 'Catalog Count Verification (120 to 200 exercises)';
  try {
    const res = await db.query('SELECT count(*)::int AS count FROM public.exercises;');
    const count = res.rows[0].count;
    assert(
      count >= 120 && count <= 200,
      `Expected exercise catalog count between 120 and 200, but found ${count}`
    );
    recordPass(testName, `Catalog count: ${count} exercises`);
  } catch (err) {
    recordFail(testName, err);
  }
}

async function testBilingualNames() {
  const testName = 'Bilingual Exercise Names Verification (non-empty name_vi & name_en)';
  try {
    // Check if columns name_vi and name_en exist on public.exercises
    const colCheck = await db.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_schema = 'public' 
        AND table_name = 'exercises' 
        AND column_name IN ('name_vi', 'name_en');
    `);
    const cols = colCheck.rows.map(r => r.column_name);
    assert(
      cols.includes('name_vi'),
      'Column public.exercises.name_vi is missing from schema migration'
    );
    assert(
      cols.includes('name_en'),
      'Column public.exercises.name_en is missing from schema migration'
    );

    const invalidRes = await db.query(`
      SELECT id, name, slug, name_vi, name_en 
      FROM public.exercises 
      WHERE name_vi IS NULL OR trim(name_vi) = '' 
         OR name_en IS NULL OR trim(name_en) = '';
    `);
    assert(
      invalidRes.rows.length === 0,
      `Found ${invalidRes.rows.length} exercise(s) with missing name_vi or name_en (e.g. ${JSON.stringify(invalidRes.rows[0])})`
    );

    const total = await db.query('SELECT count(*)::int AS count FROM public.exercises;');
    recordPass(testName, `All ${total.rows[0].count} exercises have non-empty name_vi and name_en`);
  } catch (err) {
    recordFail(testName, err);
  }
}

async function testCategoryAndEquipmentCoverage() {
  const testName = 'Category & Equipment Coverage Across All Major Groups';
  try {
    // 1. Muscle Groups / Categories
    const requiredCategories = ['Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core'];
    const catRes = await db.query('SELECT DISTINCT category FROM public.exercises;');
    const presentCategories = catRes.rows.map(r => r.category);
    for (const reqCat of requiredCategories) {
      assert(
        presentCategories.includes(reqCat),
        `Missing required muscle category '${reqCat}'. Present: [${presentCategories.join(', ')}]`
      );
    }

    // 2. Equipment Groups
    const requiredEquipment = [
      { name: 'Barbell', check: eq => eq.includes('Barbell') },
      { name: 'Dumbbell', check: eq => eq.includes('Dumbbell') },
      { name: 'Cable', check: eq => eq.includes('Cable') || eq.includes('Cables') },
      { name: 'Machine', check: eq => eq.includes('Machine') },
      { name: 'Bodyweight', check: eq => eq.includes('Bodyweight') },
    ];
    const eqRes = await db.query('SELECT DISTINCT equipment FROM public.exercises;');
    const presentEquipment = eqRes.rows.map(r => r.equipment);
    for (const reqEq of requiredEquipment) {
      assert(
        reqEq.check(presentEquipment),
        `Missing required equipment type '${reqEq.name}'. Present: [${presentEquipment.join(', ')}]`
      );
    }

    // 3. Movement patterns (if column exists)
    const movCol = await db.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_schema = 'public' 
        AND table_name = 'exercises' 
        AND column_name = 'movement_pattern';
    `);
    if (movCol.rows.length > 0) {
      const requiredPatterns = ['push', 'pull', 'squat', 'hinge'];
      const movRes = await db.query('SELECT DISTINCT movement_pattern FROM public.exercises WHERE movement_pattern IS NOT NULL;');
      const presentPatterns = movRes.rows.map(r => r.movement_pattern);
      for (const reqPattern of requiredPatterns) {
        assert(
          presentPatterns.includes(reqPattern),
          `Missing required movement pattern '${reqPattern}'. Present: [${presentPatterns.join(', ')}]`
        );
      }
    }

    recordPass(
      testName,
      `Categories [${presentCategories.join(', ')}], Equipment [${presentEquipment.join(', ')}]`
    );
  } catch (err) {
    recordFail(testName, err);
  }
}

async function testStaticHoldDurationSetInsertion() {
  const testName = 'Static Hold Duration Set Support (duration_seconds > 0, reps = 0)';
  try {
    // 1. Verify duration_seconds column exists on public.workout_sets
    const colCheck = await db.query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_schema = 'public' 
        AND table_name = 'workout_sets' 
        AND column_name = 'duration_seconds';
    `);
    assert(
      colCheck.rows.length > 0,
      'Column public.workout_sets.duration_seconds is missing from schema migration'
    );

    // 2. Set up test user, workout, and exercise
    const userId = '88888888-4444-4000-8000-888888888888';
    await db.query(`
      INSERT INTO auth.users(id, email, raw_user_meta_data)
      VALUES($1, 'static-hold-tester@example.com', '{}')
      ON CONFLICT (id) DO NOTHING;
    `, [userId]);

    const userProfileCheck = await db.query('SELECT id FROM public.users WHERE id = $1', [userId]);
    if (userProfileCheck.rows.length === 0) {
      await db.query(`
        INSERT INTO public.users(id, email, username, experience_level, primary_class_id)
        VALUES($1, 'static-hold-tester@example.com', 'StaticTester', 'intermediate', 'warrior')
        ON CONFLICT (id) DO NOTHING;
      `, [userId]);
    }

    const exerciseRes = await db.query('SELECT id FROM public.exercises LIMIT 1;');
    assert(exerciseRes.rows.length > 0, 'No exercises found to attach workout to');
    const exerciseId = exerciseRes.rows[0].id;

    // Set request.jwt.claim.sub so auth.uid() returns userId
    await db.query(`SELECT set_config('request.jwt.claim.sub', $1, false)`, [userId]);
    await db.query(`SELECT set_config('request.jwt.claims', $1, false)`, [
      JSON.stringify({ sub: userId, role: 'authenticated' })
    ]);

    const workoutId = '99999999-4444-4000-8000-999999999999';
    await db.query(`
      INSERT INTO public.workouts(id, user_id, status, notes, started_at)
      VALUES($1, $2, 'active', 'Static Hold Test Workout', now())
      ON CONFLICT (id) DO NOTHING;
    `, [workoutId, userId]);

    const weRes = await db.query(`
      INSERT INTO public.workout_exercises(workout_id, exercise_id, order_index)
      VALUES($1, $2, 1)
      RETURNING id;
    `, [workoutId, exerciseId]);
    const workoutExerciseId = weRes.rows[0].id;

    // Test 4a: Insert valid static hold duration set (duration_seconds = 45, reps = 0, is_completed = true)
    const validSetRes = await db.query(`
      INSERT INTO public.workout_sets(
        workout_exercise_id, set_number, weight_kg, reps, duration_seconds, is_completed
      )
      VALUES($1, 1, 0, 0, 45, true)
      RETURNING id, reps, duration_seconds, is_completed;
    `, [workoutExerciseId]);

    assert.equal(validSetRes.rows.length, 1, 'Valid static hold set should insert successfully');
    assert.equal(validSetRes.rows[0].duration_seconds, 45);
    assert.equal(validSetRes.rows[0].reps, 0);
    assert.equal(validSetRes.rows[0].is_completed, true);

    // Test 4b: Assert that a completed set with reps = 0 AND duration_seconds = 0 violates the check constraint
    let constraintViolated = false;
    try {
      await db.query(`
        INSERT INTO public.workout_sets(
          workout_exercise_id, set_number, weight_kg, reps, duration_seconds, is_completed
        )
        VALUES($1, 2, 0, 0, 0, true);
      `, [workoutExerciseId]);
    } catch (constraintErr) {
      constraintViolated = true;
      assert(
        constraintErr.code === '23514',
        `Expected check constraint code 23514, got ${constraintErr.code}: ${constraintErr.message}`
      );
    }
    assert(
      constraintViolated,
      'Inserting completed set with reps=0 and duration_seconds=0 must violate check constraint'
    );

    // Test 4c: Assert that an uncompleted set with reps = 0 AND duration_seconds = 0 succeeds (in-progress)
    const uncompletedSet = await db.query(`
      INSERT INTO public.workout_sets(
        workout_exercise_id, set_number, weight_kg, reps, duration_seconds, is_completed
      )
      VALUES($1, 3, 0, 0, 0, false)
      RETURNING id, is_completed;
    `, [workoutExerciseId]);
    assert.equal(uncompletedSet.rows.length, 1, 'Uncompleted in-progress set allowed with zero reps/duration');

    recordPass(
      testName,
      'duration_seconds=45, reps=0 accepted; reps=0 and duration=0 correctly rejected by check constraint'
    );
  } catch (err) {
    recordFail(testName, err);
  } finally {
    await db.query(`SELECT set_config('request.jwt.claim.sub', '', false)`);
    await db.query(`SELECT set_config('request.jwt.claims', '{}', false)`);
  }
}

async function main() {
  try {
    await setupDatabase();

    console.log('--- Running E2E Catalog Test Suites ---');
    await testCatalogCount();
    await testBilingualNames();
    await testCategoryAndEquipmentCoverage();
    await testStaticHoldDurationSetInsertion();

    console.log('\n================================================================');
    console.log(`Results: ${passed} Passed, ${failed} Failed (Total ${passed + failed})`);
    console.log('================================================================');

    await db.close();
    process.exit(failed > 0 ? 1 : 0);
  } catch (fatal) {
    console.error('Fatal test execution error:', fatal);
    await db.close();
    process.exit(1);
  }
}

main();
