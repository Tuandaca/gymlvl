// P10.3b placement concurrency checks against the real migration functions.
import { startRuntime, report } from './pg-runtime.mjs';

const USER = 'a1000000-0000-4000-8000-000000000001';
const ENROLL_OPERATION = 'd1000000-0000-4000-8000-000000000000';
const INITIAL_OPERATION = 'd1000000-0000-4000-8000-000000000001';
const RETRY_OPERATION = 'd1000000-0000-4000-8000-000000000002';
const WORKOUT_A = 'c1000000-0000-4000-8000-000000000001';
const WORKOUT_B = 'c1000000-0000-4000-8000-000000000002';
const WORKOUT_EXERCISE_A1 = 'e1000000-0000-4000-8000-000000000001';
const WORKOUT_EXERCISE_A2 = 'e1000000-0000-4000-8000-000000000002';
const WORKOUT_EXERCISE_B1 = 'e1000000-0000-4000-8000-000000000003';
const WORKOUT_EXERCISE_B2 = 'e1000000-0000-4000-8000-000000000004';
const delay = ms => new Promise(resolve => setTimeout(resolve, ms));

async function setClaims(client, userId) {
  await client.query(
    "SELECT set_config('request.jwt.claim.sub', $1, false), set_config('request.jwt.claims', $2, false)",
    [userId, JSON.stringify({ sub: userId, role: 'authenticated' })],
  );
}

async function seedPlacementUser(owner, exerciseIds) {
  await owner.query(`INSERT INTO auth.users (id, email, raw_user_meta_data)
    VALUES ($1, 'p10-concurrency@example.test', '{}'::jsonb)
    ON CONFLICT (id) DO NOTHING`, [USER]);
  await owner.query(`INSERT INTO public.users (id, email, onboarding_completed)
    VALUES ($1, 'p10-concurrency@example.test', true)
    ON CONFLICT (id) DO UPDATE SET onboarding_completed=true`, [USER]);
  await owner.query(`INSERT INTO public.profiles
    (id, environment, goals, class_name, experience_level, age, gender,
     height_cm, weight_kg, weekly_gym_days, weekly_home_days,
     preferred_training_days, timezone)
    VALUES ($1, 'gym', ARRAY['strength'], 'Powerlifting', 'intermediate', 29,
     'other', 175, 80, 3, 0, ARRAY['mon','wed','fri'], 'Asia/Ho_Chi_Minh')
    ON CONFLICT (id) DO NOTHING`, [USER]);
  await owner.query(`INSERT INTO public.user_classes
    (user_id, class_id, class_name, slot, difficulty)
    VALUES ($1, 'C', 'Powerlifting', 'primary', 'hard')
    ON CONFLICT (user_id, slot) DO UPDATE
      SET class_id='C', class_name='Powerlifting', difficulty='hard'`, [USER]);
  const [bench, squat] = exerciseIds;
  return {
    policyVersion: 'placement-v0.1',
    classId: 'C', hasTrainingExperience: true, skip: false,
    equipment: { barbell: true, pullUpBar: false },
    anchors: [
      { exerciseId: bench, protocolVersion: 'strict-v1', loadKg: 60, reps: 8, durationSeconds: 0 },
      { exerciseId: squat, protocolVersion: 'strict-v1', loadKg: 80, reps: 8, durationSeconds: 0 },
    ],
  };
}

async function submit(client, operationId, request) {
  return (await client.query(
    'SELECT public.submit_placement_assessment_v1($1::uuid, $2::jsonb) AS result',
    [operationId, JSON.stringify(request)],
  )).rows[0].result;
}

async function seedCompletedWorkout(owner, workoutId, exerciseIds, exerciseRowIds, dayOffset) {
  await setClaims(owner, USER);
  await owner.query(`INSERT INTO public.workouts
    (id, user_id, status, training_started_at, is_xp_calculated)
    VALUES ($1, $2, 'active', now() - ($3::int || ' days')::interval + interval '1 hour', false)
    ON CONFLICT (id) DO NOTHING`, [workoutId, USER, dayOffset]);
  for (let index = 0; index < exerciseIds.length; index += 1) {
    await owner.query(`INSERT INTO public.workout_exercises
      (id, workout_id, exercise_id, order_index)
      VALUES ($1, $2, $3, $4) ON CONFLICT (id) DO NOTHING`,
      [exerciseRowIds[index], workoutId, exerciseIds[index], index]);
    await owner.query(`INSERT INTO public.workout_sets
      (workout_exercise_id, set_number, reps, weight_kg, duration_seconds,
       rest_seconds, is_completed, set_type)
      VALUES ($1, 1, 8, $2, 0, 60, true, 'workout')
      `, [exerciseRowIds[index], index === 0 ? 60 : 80]);
  }
  await owner.query(
    `UPDATE public.workouts SET status='completed',
      completed_at=now() - ($2::int || ' days')::interval + interval '2 hours',
      is_xp_calculated=true WHERE id=$1`,
    [workoutId, dayOffset],
  );
  await setClaims(owner, '');
}

async function main() {
  const { runtime } = await startRuntime({ label: 'gymlvl-p10-placement' });
  const owner = await runtime.openClient();
  const first = await runtime.openClient();
  const second = await runtime.openClient();
  try {
    const exerciseRows = (await owner.query(
      `SELECT id, slug FROM public.exercises
        WHERE slug IN ('barbell-bench-press','barbell-squat')
        ORDER BY slug`,
    )).rows;
    if (exerciseRows.length !== 2) throw new Error('required curated anchors are missing');
    const request = await seedPlacementUser(owner, exerciseRows.map(row => row.id));
    await owner.query(
      'SELECT public.placement_register_v1($1::uuid,$2::uuid,$3::jsonb,true)',
      [USER, ENROLL_OPERATION, JSON.stringify(request)],
    );
    await setClaims(first, USER);
    await setClaims(second, USER);

    await first.query('BEGIN');
    await first.query('SELECT 1 FROM public.users WHERE id=$1 FOR UPDATE', [USER]);
    const firstCall = submit(first, INITIAL_OPERATION, request);
    const secondCall = submit(second, INITIAL_OPERATION, request);
    await delay(100);
    const waiting = (await owner.query(
      `SELECT count(*)::int AS n FROM pg_stat_activity
       WHERE wait_event_type='Lock' AND query ILIKE '%submit_placement_assessment%'`,
    )).rows[0].n;
    const firstResult = await firstCall;
    await first.query('COMMIT');
    const secondResult = await secondCall;
    await second.query('ROLLBACK').catch(() => {});

    const assessmentCount = Number((await owner.query(
      `SELECT count(*) FROM public.placement_assessments
       WHERE user_id=$1 AND operation_id=$2`, [USER, INITIAL_OPERATION],
    )).rows[0].count);
    if (assessmentCount !== 1) throw new Error(`duplicate submission created ${assessmentCount} rows`);
    if (JSON.stringify(firstResult) !== JSON.stringify(secondResult)) {
      throw new Error('duplicate submission replay returned different results');
    }
    report.pass('P10 duplicate submission/receipt serialization', `two connections; lock wait samples=${waiting}`);

    const retry = await submit(second, INITIAL_OPERATION, request);
    if (JSON.stringify(retry) !== JSON.stringify(firstResult)) throw new Error('retry result changed');
    report.pass('P10 retry-after-assessment replay', 'same operation remains immutable');

    await owner.query(`UPDATE public.user_classes
      SET class_id='B', class_name='Hiper-Growth', difficulty='medium'
      WHERE user_id=$1 AND slot='primary'`, [USER]);
    try {
      await submit(second, RETRY_OPERATION, request);
      throw new Error('class-switch submission unexpectedly succeeded');
    } catch (error) {
      if (!String(error.message).includes('current primary class')) throw error;
    }
    const afterSwitch = Number((await owner.query(
      'SELECT count(*) FROM public.placement_assessments WHERE user_id=$1', [USER],
    )).rows[0].count);
    if (afterSwitch !== 2) throw new Error(`class-switch failure changed assessment count: ${afterSwitch}`);
    report.pass('P10 class-change versus submission guard', 'old assessment preserved; new class rejected');

    await owner.query(
      `UPDATE public.user_classes SET class_id='C', class_name='Powerlifting', difficulty='hard'
       WHERE user_id=$1 AND slot='primary'`, [USER],
    );
    await owner.query(
      `UPDATE public.placement_assessments SET submitted_at=now() - interval '3 days', updated_at=now()
       WHERE user_id=$1 AND operation_id=$2`, [USER, INITIAL_OPERATION],
    );

    await owner.query(`SELECT public.placement_record_workout_v1(
      $1::uuid,$2::uuid,'{"earnedXP":50}'::jsonb)`,
      ['ffffffff-ffff-4fff-8fff-ffffffffffff', USER]);
    const evidenceCount = Number((await owner.query(
      'SELECT count(*) FROM public.placement_workout_evidence WHERE user_id=$1', [USER],
    )).rows[0].count);
    if (evidenceCount !== 0) throw new Error('invalid evidence created a row');
    report.pass('P10 invalid evidence no-op boundary', 'invalid workout produced no evidence or confirmation');

    await seedCompletedWorkout(owner, WORKOUT_A, exerciseRows.map(row => row.id),
      [WORKOUT_EXERCISE_A1, WORKOUT_EXERCISE_A2], 2);
    await seedCompletedWorkout(owner, WORKOUT_B, exerciseRows.map(row => row.id),
      [WORKOUT_EXERCISE_B1, WORKOUT_EXERCISE_B2], 1);
    await owner.query('BEGIN');
    await owner.query(
      `SELECT public.placement_record_workout_v1($1::uuid,$2::uuid,'{"earnedXP":50}'::jsonb)`,
      [WORKOUT_A, USER],
    );
    try {
      await owner.query(`SELECT 1 / 0`);
    } catch (_) {
      await owner.query('ROLLBACK');
    }
    const rolledBackEvidence = Number((await owner.query(
      'SELECT count(*) FROM public.placement_workout_evidence WHERE user_id=$1', [USER],
    )).rows[0].count);
    if (rolledBackEvidence !== 0) throw new Error('evidence survived forced transaction rollback');
    report.pass('P10 evidence transaction rollback', 'forced failure removed the provisional evidence row');

    const rewardClients = [await runtime.openClient(), await runtime.openClient()];
    await Promise.all(rewardClients.map(client => setClaims(client, USER)));
    const rewardResults = await Promise.allSettled(rewardClients.map((client, index) => client.query(
      `INSERT INTO public.workout_rewards(workout_id,user_id,result)
       VALUES ($1,$2,'{"earnedXP":50,"isSuspicious":false}'::jsonb)`,
      [index === 0 ? WORKOUT_A : WORKOUT_B, USER],
    )));
    await Promise.all(rewardClients.map(client => client.end()));
    const rewardRows = Number((await owner.query(
      'SELECT count(*) FROM public.workout_rewards WHERE workout_id = ANY($1::uuid[])', [[WORKOUT_A, WORKOUT_B]],
    )).rows[0].count);
    const successes = rewardResults.filter(result => result.status === 'fulfilled').length;
    const confirmations = Number((await owner.query(
      'SELECT count(*) FROM public.placement_confirmations WHERE user_id=$1', [USER],
    )).rows[0].count);
    const evidenceRows = Number((await owner.query(
      `SELECT count(*) FROM public.placement_workout_evidence
       WHERE user_id=$1 AND qualifying`, [USER],
    )).rows[0].count);
    if (rewardRows !== 2 || successes !== 2 || confirmations !== 1 || evidenceRows !== 2) {
      const errors = rewardResults.filter(result => result.status === 'rejected')
        .map(result => result.reason?.message ?? String(result.reason)).join(' | ');
      throw new Error(`concurrent reward rows=${rewardRows}, successes=${successes}, confirmations=${confirmations}, evidence=${evidenceRows}, errors=${errors}`);
    }
    report.pass('P10 concurrent completion serialization', 'two independent rewards, two evidence rows, one confirmation');
  } catch (error) {
    report.fail('P10 placement concurrency', error.message);
    report.info(`postgres-log: ${(runtime.logs ?? []).slice(-12).join(' | ')}`);
  } finally {
    await runtime.closeClient(first).catch(() => {});
    await runtime.closeClient(second).catch(() => {});
    await runtime.closeClient(owner).catch(() => {});
    await runtime.teardown();
    report.finish();
  }
}

await main();
