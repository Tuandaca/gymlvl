import assert from 'node:assert/strict';
import { readFile, readdir } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { PGlite } from '@electric-sql/pglite';
import { pgcrypto } from '@electric-sql/pglite/contrib/pgcrypto';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../..');
const db = new PGlite({ extensions: { pgcrypto } });

let passed = 0;
let totalTests = 0;

function pass(name) {
  passed++;
  console.log(`  [PASS] ${name}`);
}

async function runSqlFile(filename) {
  await db.exec(await readFile(filename, 'utf8'));
}

async function setupDatabase() {
  console.log('--- Initializing Isolated PostgreSQL 17 Engine ---');
  await runSqlFile(path.join(here, 'bootstrap.sql'));

  const migrationsDir = path.join(root, 'supabase/migrations');
  const migrations = (await readdir(migrationsDir)).filter(name => name.endsWith('.sql')).sort();
  for (const name of migrations) {
    await runSqlFile(path.join(migrationsDir, name));
  }

  await runSqlFile(path.join(root, 'supabase/seed.sql'));
  console.log('Database initialized with migrations and seed data.\n');
}

async function asUser(userId, role, fn) {
  await db.query(`SELECT set_config('request.jwt.claim.sub', $1, false)`, [userId]);
  await db.query(`SELECT set_config('request.jwt.claims', $1, false)`, [
    JSON.stringify({ sub: userId, role })
  ]);
  await db.query(`SET ROLE ${role}`);
  try {
    return await fn();
  } finally {
    await db.query('RESET ROLE');
    await db.query(`SELECT set_config('request.jwt.claim.sub', '', false)`);
    await db.query(`SELECT set_config('request.jwt.claims', '{}', false)`);
  }
}

async function testPaceLimitClamping() {
  console.log('--- Test Suite 1: Rapid Workout Submission & Pace Limit Clamping (>4 sets/min -> 10 XP) ---');
  const userId = 'aaaaaaaa-1111-4000-8000-111111111111';

  // Seed user in auth.users
  await db.query(`
    INSERT INTO auth.users(id, email, raw_user_meta_data)
    VALUES($1, 'pace-test@example.test', '{}')
  `, [userId]);

  await asUser(userId, 'authenticated', async () => {
    await db.query(`
      SELECT public.initialize_user($1)
    `, [JSON.stringify({
      environment: 'gym',
      goals: ['hypertrophy'],
      experience_level: 'intermediate',
      age: 26,
      gender: 'male',
      height_cm: 175,
      weight_kg: 70,
      weekly_gym_days: 4,
      weekly_home_days: 0,
      preferred_training_days: ['Mon', 'Wed', 'Fri'],
      primary_class_id: 'B',
      secondary_class_id: 'C',
      timezone: 'Asia/Ho_Chi_Minh'
    })]);
  });

  // Get exercise IDs
  const exerciseRes = await db.query(`SELECT id FROM public.exercises WHERE category='Chest' ORDER BY name LIMIT 1`);
  const exerciseId = exerciseRes.rows[0].id;

  // Helper to create and populate a workout for user
  async function createWorkoutWithSets(numSets, elapsedSeconds) {
    let workoutId;
    let weId;
    await asUser(userId, 'authenticated', async () => {
      const sw = await db.query(`SELECT public.start_workout() as w`);
      workoutId = sw.rows[0].w.id;
      const we = await db.query(`
        INSERT INTO public.workout_exercises(workout_id, exercise_id)
        VALUES($1, $2) RETURNING id
      `, [workoutId, exerciseId]);
      weId = we.rows[0].id;

      for (let s = 1; s <= numSets; s++) {
        await db.query(`
          INSERT INTO public.workout_sets(workout_exercise_id, set_number, reps, weight_kg, is_completed)
          VALUES($1, $2, 10, 50, true)
        `, [weId, s]);
      }
      await db.query(`SELECT public.begin_workout($1)`, [workoutId]);
    });

    // Simulate elapsed duration by updating training_started_at (requires superuser since client is blocked)
    await db.query(`
      UPDATE public.workouts
      SET training_started_at = clock_timestamp() - ($1 || ' seconds')::interval
      WHERE id = $2
    `, [elapsedSeconds, workoutId]);

    return workoutId;
  }

  // Case 1: Normal pace: 5 sets over 600 seconds (10 minutes = 0.5 sets/min)
  totalTests++;
  const normalWorkoutId = await createWorkoutWithSets(5, 600);
  const normalRes = await asUser(userId, 'authenticated', async () => {
    const res = await db.query(`SELECT public.complete_workout($1) as r`, [normalWorkoutId]);
    return res.rows[0].r;
  });

  assert.equal(normalRes.isSuspicious, false, 'Normal pace must NOT be marked suspicious');
  assert.ok(normalRes.earnedXP > 10, `Normal pace earned XP (${normalRes.earnedXP}) must be greater than 10 flat`);
  pass(`Case 1: Normal pace (0.5 sets/min) earns ${normalRes.earnedXP} XP (isSuspicious=false)`);

  // Case 2: Bot attack / rapid pace: 5 sets in 30 seconds (10 sets/min > 4 sets/min)
  totalTests++;
  const rapidWorkoutId = await createWorkoutWithSets(5, 30);
  const rapidRes = await asUser(userId, 'authenticated', async () => {
    const res = await db.query(`SELECT public.complete_workout($1) as r`, [rapidWorkoutId]);
    return res.rows[0].r;
  });

  assert.equal(rapidRes.isSuspicious, true, 'Rapid pace (>4 sets/min) must be marked suspicious');
  assert.equal(rapidRes.earnedXP, 10, 'Rapid pace (>4 sets/min) must be clamped to exactly 10 XP flat');
  pass(`Case 2: Rapid pace attack (10 sets/min) clamped to ${rapidRes.earnedXP} XP (isSuspicious=true)`);

  // Case 3: Boundary edge: 4 sets in 50 seconds (4.8 sets/min > 4)
  totalTests++;
  const edgeRapidId = await createWorkoutWithSets(4, 50);
  const edgeRapidRes = await asUser(userId, 'authenticated', async () => {
    const res = await db.query(`SELECT public.complete_workout($1) as r`, [edgeRapidId]);
    return res.rows[0].r;
  });

  assert.equal(edgeRapidRes.isSuspicious, true, '4 sets in 50s (4.8 sets/min) must be marked suspicious');
  assert.equal(edgeRapidRes.earnedXP, 10, '4 sets in 50s must be clamped to 10 XP');
  pass(`Case 3: Boundary edge (4.8 sets/min > 4) clamped to ${edgeRapidRes.earnedXP} XP (isSuspicious=true)`);

  // Case 4: Boundary edge: 4 sets in 70 seconds (3.43 sets/min <= 4)
  totalTests++;
  const edgeSlowId = await createWorkoutWithSets(4, 70);
  const edgeSlowRes = await asUser(userId, 'authenticated', async () => {
    const res = await db.query(`SELECT public.complete_workout($1) as r`, [edgeSlowId]);
    return res.rows[0].r;
  });

  assert.equal(edgeSlowRes.isSuspicious, false, '4 sets in 70s (3.43 sets/min) must NOT be marked suspicious');
  assert.ok(edgeSlowRes.earnedXP > 10, `4 sets in 70s earned normal XP: ${edgeSlowRes.earnedXP}`);
  pass(`Case 4: Boundary edge (3.43 sets/min <= 4) earns ${edgeSlowRes.earnedXP} XP (isSuspicious=false)`);

  // Case 5: 320 sets extreme volume bot attack (4 exercises x 80 sets) rejected by complete_workout with 22023
  totalTests++;
  let extremeWorkoutId;
  await asUser(userId, 'authenticated', async () => {
    const sw = await db.query(`SELECT public.start_workout() as w`);
    extremeWorkoutId = sw.rows[0].w.id;
    for (let e = 1; e <= 4; e++) {
      const we = await db.query(`
        INSERT INTO public.workout_exercises(workout_id, exercise_id)
        VALUES($1, $2) RETURNING id
      `, [extremeWorkoutId, exerciseId]);
      const weId = we.rows[0].id;
      for (let s = 1; s <= 80; s++) {
        await db.query(`
          INSERT INTO public.workout_sets(workout_exercise_id, set_number, reps, weight_kg, is_completed)
          VALUES($1, $2, 10, 50, true)
        `, [weId, s]);
      }
    }
    await db.query(`SELECT public.begin_workout($1)`, [extremeWorkoutId]);
  });

  let extremeRejected = false;
  try {
    await asUser(userId, 'authenticated', async () => {
      await db.query(`SELECT public.complete_workout($1)`, [extremeWorkoutId]);
    });
  } catch (err) {
    if (err.code === '22023' || err.message.includes('Invalid workout measurements')) {
      extremeRejected = true;
    } else {
      throw err;
    }
  }
  assert.ok(extremeRejected, 'Workouts with >300 sets must be rejected with 22023');
  pass('Case 5: Extreme volume attack (>300 sets) rejected by complete_workout with 22023');

  // Case 6: Check constraint boundaries on workout_sets (set_number > 100, reps=0 when completed, negative weight)
  totalTests++;
  let set101Blocked = false;
  let reps0Blocked = false;
  let negWeightBlocked = false;
  await asUser(userId, 'authenticated', async () => {
    const sw = await db.query(`SELECT public.start_workout() as w`);
    const wid = sw.rows[0].w.id;
    const we = await db.query(`INSERT INTO public.workout_exercises(workout_id, exercise_id) VALUES($1, $2) RETURNING id`, [wid, exerciseId]);
    const weId = we.rows[0].id;

    try {
      await db.query(`INSERT INTO public.workout_sets(workout_exercise_id, set_number, reps, weight_kg, is_completed) VALUES($1, 101, 10, 50, true)`, [weId]);
    } catch (e) {
      if (e.code === '23514') set101Blocked = true;
    }

    try {
      await db.query(`INSERT INTO public.workout_sets(workout_exercise_id, set_number, reps, weight_kg, is_completed) VALUES($1, 1, 0, 50, true)`, [weId]);
    } catch (e) {
      if (e.code === '23514') reps0Blocked = true;
    }

    try {
      await db.query(`INSERT INTO public.workout_sets(workout_exercise_id, set_number, reps, weight_kg, is_completed) VALUES($1, 1, 10, -5, true)`, [weId]);
    } catch (e) {
      if (e.code === '23514') negWeightBlocked = true;
    }
  });

  assert.ok(set101Blocked, 'set_number > 100 must be blocked by CHECK constraint 23514');
  assert.ok(reps0Blocked, 'completed set with 0 reps must be blocked by CHECK constraint 23514');
  assert.ok(negWeightBlocked, 'negative weight must be blocked by CHECK constraint 23514');
  pass('Case 6: Database CHECK constraints prevent invalid sets (set_number>100, reps=0, negative weight)');
  console.log('');
}

async function testReplayProtection() {
  console.log('--- Test Suite 2: Replay Protection & Idempotency via workout_rewards ---');
  const userId = 'bbbbbbbb-2222-4000-8000-222222222222';

  await db.query(`
    INSERT INTO auth.users(id, email, raw_user_meta_data)
    VALUES($1, 'replay-test@example.test', '{}')
  `, [userId]);

  await asUser(userId, 'authenticated', async () => {
    await db.query(`
      SELECT public.initialize_user($1)
    `, [JSON.stringify({
      environment: 'gym',
      goals: ['hypertrophy'],
      experience_level: 'intermediate',
      age: 26,
      gender: 'male',
      height_cm: 175,
      weight_kg: 70,
      weekly_gym_days: 4,
      weekly_home_days: 0,
      preferred_training_days: ['Mon', 'Wed', 'Fri'],
      primary_class_id: 'B',
      secondary_class_id: 'C',
      timezone: 'Asia/Ho_Chi_Minh'
    })]);
  });

  const exerciseRes = await db.query(`SELECT id FROM public.exercises WHERE category='Legs' LIMIT 1`);
  const exerciseId = exerciseRes.rows[0].id;

  let workoutId;
  await asUser(userId, 'authenticated', async () => {
    const sw = await db.query(`SELECT public.start_workout() as w`);
    workoutId = sw.rows[0].w.id;
    const we = await db.query(`
      INSERT INTO public.workout_exercises(workout_id, exercise_id)
      VALUES($1, $2) RETURNING id
    `, [workoutId, exerciseId]);
    const weId = we.rows[0].id;

    for (let i = 1; i <= 3; i++) {
      await db.query(`
        INSERT INTO public.workout_sets(workout_exercise_id, set_number, reps, weight_kg, is_completed)
        VALUES($1, $2, 12, 60, true)
      `, [weId, i]);
    }
    await db.query(`SELECT public.begin_workout($1)`, [workoutId]);
  });

  // Set duration to 15 minutes
  await db.query(`
    UPDATE public.workouts
    SET training_started_at = clock_timestamp() - interval '900 seconds'
    WHERE id = $1
  `, [workoutId]);

  // First completion
  totalTests++;
  const firstRes = await asUser(userId, 'authenticated', async () => {
    const res = await db.query(`SELECT public.complete_workout($1) as r`, [workoutId]);
    return res.rows[0].r;
  });

  assert.ok(firstRes.earnedXP > 0, 'First completion should earn positive XP');
  const userAfterFirst = (await db.query(`SELECT total_xp, level FROM public.users WHERE id=$1`, [userId])).rows[0];
  const streakAfterFirst = (await db.query(`SELECT current_streak FROM public.streaks WHERE user_id=$1`, [userId])).rows[0];
  const logsAfterFirst = (await db.query(`SELECT count(*)::int as c FROM public.xp_logs WHERE user_id=$1 AND source='workout'`, [userId])).rows[0].c;
  const rewardsAfterFirst = (await db.query(`SELECT count(*)::int as c FROM public.workout_rewards WHERE workout_id=$1`, [workoutId])).rows[0].c;

  assert.equal(rewardsAfterFirst, 1, 'Exactly one row in workout_rewards created');
  assert.equal(logsAfterFirst, 1, 'Exactly one row in xp_logs created');
  pass(`Case 1: First completion earned ${firstRes.earnedXP} XP; 1 row written to workout_rewards`);

  // Replay completion 10 times in a row
  totalTests++;
  for (let replay = 1; replay <= 10; replay++) {
    const replayRes = await asUser(userId, 'authenticated', async () => {
      const res = await db.query(`SELECT public.complete_workout($1) as r`, [workoutId]);
      return res.rows[0].r;
    });

    assert.deepEqual(replayRes, firstRes, `Replay attempt ${replay} must return identical cached result`);
  }

  const userAfterReplay = (await db.query(`SELECT total_xp, level FROM public.users WHERE id=$1`, [userId])).rows[0];
  const streakAfterReplay = (await db.query(`SELECT current_streak FROM public.streaks WHERE user_id=$1`, [userId])).rows[0];
  const logsAfterReplay = (await db.query(`SELECT count(*)::int as c FROM public.xp_logs WHERE user_id=$1 AND source='workout'`, [userId])).rows[0].c;
  const rewardsAfterReplay = (await db.query(`SELECT count(*)::int as c FROM public.workout_rewards WHERE workout_id=$1`, [workoutId])).rows[0].c;

  assert.equal(userAfterReplay.total_xp, userAfterFirst.total_xp, 'Total XP must NOT increase on replay');
  assert.equal(streakAfterReplay.current_streak, streakAfterFirst.current_streak, 'Streak must NOT duplicate on replay');
  assert.equal(logsAfterReplay, 1, 'xp_logs must remain exactly 1 row');
  assert.equal(rewardsAfterReplay, 1, 'workout_rewards must remain exactly 1 row');
  pass('Case 2: 10 repeated replay submissions return exact cached reward with 0 duplicate XP and 0 ledger duplicates');

  // Case 3: Completed workout sets are immutable (anti-tamper)
  totalTests++;
  await asUser(userId, 'authenticated', async () => {
    await db.query(`UPDATE public.workout_sets SET weight_kg = 999 WHERE workout_exercise_id IN (SELECT id FROM public.workout_exercises WHERE workout_id=$1)`, [workoutId]);
  });
  const setsCheck = await db.query(`
    SELECT weight_kg FROM public.workout_sets
    WHERE workout_exercise_id IN (SELECT id FROM public.workout_exercises WHERE workout_id=$1)
  `, [workoutId]);
  for (const row of setsCheck.rows) {
    assert.equal(Number(row.weight_kg), 60, 'Completed workout set weights cannot be modified');
  }
  pass('Case 3: Post-completion set tampering blocked by trigger (weight preserved at 60kg)');

  // Case 4: Legacy already-awarded workout with is_xp_calculated = true
  totalTests++;
  const legacyWorkoutId = '00000000-0000-4000-8000-000000000029';
  await db.query(`
    INSERT INTO public.workouts(id, user_id, status, started_at, training_started_at, is_xp_calculated)
    VALUES($1, $2, 'completed', now() - interval '2 days', now() - interval '2 days', true)
  `, [legacyWorkoutId, userId]);

  const legacyRes = await asUser(userId, 'authenticated', async () => {
    const res = await db.query(`SELECT public.complete_workout($1) as r`, [legacyWorkoutId]);
    return res.rows[0].r;
  });

  assert.equal(legacyRes.earnedXP, 0, 'Legacy already awarded workout must return earnedXP = 0');
  assert.equal(legacyRes.alreadyAwarded, true, 'Legacy already awarded workout must set alreadyAwarded = true');
  pass('Case 4: Legacy awarded workout returns earnedXP: 0 without duplicate reward');
  console.log('');
}

async function testPrivilegeEscalationDefenses() {
  console.log('--- Test Suite 3: Client Direct SQL Updates Privilege Boundaries (42501) ---');
  const userId = 'cccccccc-3333-4000-8000-333333333333';

  await db.query(`
    INSERT INTO auth.users(id, email, raw_user_meta_data)
    VALUES($1, 'priv-test@example.test', '{}')
  `, [userId]);

  await asUser(userId, 'authenticated', async () => {
    await db.query(`
      SELECT public.initialize_user($1)
    `, [JSON.stringify({
      environment: 'gym',
      goals: ['hypertrophy'],
      experience_level: 'intermediate',
      age: 26,
      gender: 'male',
      height_cm: 175,
      weight_kg: 70,
      weekly_gym_days: 4,
      weekly_home_days: 0,
      preferred_training_days: ['Mon', 'Wed', 'Fri'],
      primary_class_id: 'B',
      secondary_class_id: 'C',
      timezone: 'Asia/Ho_Chi_Minh'
    })]);
  });

  async function assertDenied(sql, label, expectedSqlState = '42501') {
    totalTests++;
    let errorCaught = null;
    try {
      await asUser(userId, 'authenticated', async () => {
        await db.query(sql);
      });
    } catch (err) {
      errorCaught = err;
    }
    assert.ok(errorCaught !== null, `Expected rejection for: ${label}`);
    assert.equal(errorCaught.code, expectedSqlState, `Expected SQLSTATE ${expectedSqlState} for ${label}, got ${errorCaught.code}: ${errorCaught.message}`);
    pass(`${label} -> Rejected with ${expectedSqlState}`);
  }

  // Direct SQL updates to forbidden progression tables/columns
  await assertDenied(`UPDATE public.users SET total_xp = 999999`, 'Direct UPDATE users.total_xp');
  await assertDenied(`UPDATE public.users SET level = 99`, 'Direct UPDATE users.level');
  await assertDenied(`UPDATE public.users SET current_level_xp = 500`, 'Direct UPDATE users.current_level_xp');
  await assertDenied(`UPDATE public.users SET onboarding_completed = true`, 'Direct UPDATE users.onboarding_completed');
  await assertDenied(`INSERT INTO public.users(id, email, total_xp) VALUES('${userId}', 'x', 999)`, 'Direct INSERT into users');
  await assertDenied(`DELETE FROM public.users WHERE id='${userId}'`, 'Direct DELETE from users');

  await assertDenied(`UPDATE public.user_classes SET current_xp = 99999`, 'Direct UPDATE user_classes.current_xp');
  await assertDenied(`UPDATE public.user_classes SET level = 20`, 'Direct UPDATE user_classes.level');
  await assertDenied(`INSERT INTO public.user_classes(user_id, class_id, slot, current_xp) VALUES('${userId}', 'D', 'primary', 500)`, 'Direct INSERT user_classes');

  await assertDenied(`UPDATE public.quest_instances SET status = 'completed', earned_xp = 500`, 'Direct UPDATE quest_instances');
  await assertDenied(`INSERT INTO public.quest_instances(user_id, quest_id, quest_date) VALUES('${userId}', gen_random_uuid(), now()::date)`, 'Direct INSERT quest_instances');

  await assertDenied(`INSERT INTO public.xp_logs(user_id, amount, source) VALUES('${userId}', 1000, 'workout')`, 'Direct INSERT xp_logs');
  await assertDenied(`UPDATE public.streaks SET current_streak = 50`, 'Direct UPDATE streaks');
  await assertDenied(`INSERT INTO public.workout_rewards(workout_id, user_id, result) VALUES(gen_random_uuid(), '${userId}', '{}')`, 'Direct INSERT workout_rewards');
  await assertDenied(`UPDATE public.coach_daily_usage SET request_count = 0`, 'Direct UPDATE coach_daily_usage');
  await assertDenied(`INSERT INTO public.user_achievements(user_id, achievement_id) VALUES('${userId}', 'level_10')`, 'Direct INSERT user_achievements');

  // Verify that client cannot tamper with workouts.started_at or training_started_at
  await assertDenied(`UPDATE public.workouts SET started_at = now() - interval '1 hour'`, 'Direct UPDATE workouts.started_at');
  await assertDenied(`UPDATE public.workouts SET is_xp_calculated = false, status = 'completed'`, 'Direct UPDATE workouts.is_xp_calculated');

  // Verify that PERMITTED profile updates succeed
  totalTests++;
  await asUser(userId, 'authenticated', async () => {
    await db.query(`UPDATE public.users SET display_name = 'Valid Athlete' WHERE id = $1`, [userId]);
    await db.query(`UPDATE public.profiles SET height_cm = 182 WHERE id = $1`, [userId]);
  });
  const updatedUser = (await db.query(`SELECT display_name FROM public.users WHERE id=$1`, [userId])).rows[0];
  const updatedProfile = (await db.query(`SELECT height_cm FROM public.profiles WHERE id=$1`, [userId])).rows[0];
  assert.equal(updatedUser.display_name, 'Valid Athlete');
  assert.equal(Number(updatedProfile.height_cm), 182);
  pass('Safe client updates on public.users (display_name) and public.profiles (height_cm) succeed');
  console.log('');
}

async function testCoachRateLimitingAndFallback() {
  console.log('--- Test Suite 4: AI Coach Rate Limiting (20 req/day) & Unconfigured Fallback ---');
  const userId = 'dddddddd-4444-4000-8000-444444444444';

  await db.query(`
    INSERT INTO auth.users(id, email, raw_user_meta_data)
    VALUES($1, 'coach-test@example.test', '{}')
  `, [userId]);

  await asUser(userId, 'authenticated', async () => {
    await db.query(`
      SELECT public.initialize_user($1)
    `, [JSON.stringify({
      environment: 'gym',
      goals: ['hypertrophy'],
      experience_level: 'intermediate',
      age: 26,
      gender: 'male',
      height_cm: 175,
      weight_kg: 70,
      weekly_gym_days: 4,
      weekly_home_days: 0,
      preferred_training_days: ['Mon', 'Wed', 'Fri'],
      primary_class_id: 'B',
      secondary_class_id: 'C',
      timezone: 'Asia/Ho_Chi_Minh'
    })]);
  });

  // Verify anon cannot call consume_coach_request()
  totalTests++;
  let anonBlocked = false;
  try {
    await asUser(userId, 'anon', async () => {
      await db.query(`SELECT public.consume_coach_request()`);
    });
  } catch (err) {
    if (err.code === '42501') anonBlocked = true;
  }
  assert.ok(anonBlocked, 'anon must be blocked from consume_coach_request with 42501');
  pass('Case 1: Anonymous users blocked from consume_coach_request() with 42501');

  // Verify exactly 20 calls are accepted, 21st is rejected
  totalTests++;
  await asUser(userId, 'authenticated', async () => {
    for (let req = 1; req <= 20; req++) {
      const res = await db.query(`SELECT public.consume_coach_request() as ok`);
      assert.equal(res.rows[0].ok, true, `Coach request ${req} of 20 must be accepted`);
    }

    const denied = await db.query(`SELECT public.consume_coach_request() as ok`);
    assert.equal(denied.rows[0].ok, false, '21st coach request within same UTC day must return false');
  });

  const usageCount = (await db.query(`
    SELECT request_count FROM public.coach_daily_usage WHERE user_id=$1
  `, [userId])).rows[0].request_count;
  assert.equal(usageCount, 20, 'coach_daily_usage request_count capped at exactly 20');
  pass('Case 2: Database RPC consume_coach_request() accepts exactly 20 requests and rejects the 21st');

  // Verify table check constraint prevents tampering beyond 20
  totalTests++;
  let checkConstraintTriggered = false;
  try {
    await db.query(`
      UPDATE public.coach_daily_usage SET request_count = 21 WHERE user_id=$1
    `, [userId]);
  } catch (err) {
    if (err.code === '23514') checkConstraintTriggered = true; // check_violation
  }
  assert.ok(checkConstraintTriggered, 'Table check constraint request_count BETWEEN 0 AND 20 triggered');
  pass('Case 3: Table CHECK constraint enforces request_count BETWEEN 0 AND 20 (code 23514)');
  console.log('');
}

try {
  await setupDatabase();
  await testPaceLimitClamping();
  await testReplayProtection();
  await testPrivilegeEscalationDefenses();
  await testCoachRateLimitingAndFallback();

  console.log(`========================================`);
  console.log(`ALL ADVERSARIAL TESTS PASSED: ${passed}/${totalTests} units`);
  console.log(`========================================`);
} catch (error) {
  console.error(`FAIL: ${error.message}`);
  console.error(error.stack);
  process.exitCode = 1;
} finally {
  await db.close();
}
