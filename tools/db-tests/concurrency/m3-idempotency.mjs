// M3.6 genuine two-connection idempotency / concurrency evidence.
//
// Every business call runs on its own TCP connection as `authenticated` with
// session-level JWT claims, inside an explicit BEGIN ... COMMIT/ROLLBACK.
// A third monitor connection samples pg_stat_activity for a real row-lock wait,
// which is the proof that the two calls overlap instead of running in sequence.
//
// The harness only reads and writes its own disposable database. It never
// modifies supabase/**, never contacts a remote project, and reports a defect
// instead of patching SQL.

import { isDeepStrictEqual } from 'node:util';
import { isPortFree, report, startRuntime } from './pg-runtime.mjs';

const OWNER_A = 'a0000000-0000-4000-8000-000000000001';
const OWNER_B = 'b0000000-0000-4000-8000-000000000002';
const EMAIL_A = 'm36-owner-a@example.test';
const EMAIL_B = 'm36-owner-b@example.test';

const C1 = { workout: 'c1000000-0000-4000-8000-000000000001', exercise: 'e1000000-0000-4000-8000-000000000001', operation: 'd1000000-0000-4000-8000-000000000001' };
const C2 = { workout: 'c2000000-0000-4000-8000-000000000002', exercise: 'e2000000-0000-4000-8000-000000000002', operation: 'd2000000-0000-4000-8000-000000000002' };
const C3 = { workout: 'c3000000-0000-4000-8000-000000000003', exercise: 'e3000000-0000-4000-8000-000000000003', operation: 'd3000000-0000-4000-8000-000000000003' };
const C4 = { workout: 'c4000000-0000-4000-8000-000000000004', exercise: 'e4000000-0000-4000-8000-000000000004' };
const C5 = {
  workoutA: 'c5a00000-0000-4000-8000-000000000005',
  exerciseA: 'e5a00000-0000-4000-8000-000000000005',
  workoutB: 'c5b00000-0000-4000-8000-000000000005',
  exerciseB: 'e5b00000-0000-4000-8000-000000000005',
  operation: 'd5000000-0000-4000-8000-000000000005',
};
const C6 = { workout: 'c6000000-0000-4000-8000-000000000006', exercise: 'e6000000-0000-4000-8000-000000000006', operation: 'd6000000-0000-4000-8000-000000000006' };
const C7 = { importKey: 'p9-concurrent-history-1' };
const C8 = {
  workout: 'c8000000-0000-4000-8000-000000000008',
  existingExercise: 'e8000000-0000-4000-8000-000000000008',
  operation: 'd8000000-0000-4000-8000-000000000008',
};

const APPLY_SET_SQL = `SELECT r AS result, r::text AS result_text
  FROM (SELECT public.apply_workout_set_create_v1($1::uuid, $2::uuid, $3::jsonb) AS r) call`;
const COMPLETE_SQL = `SELECT r AS result, r::text AS result_text
  FROM (SELECT public.complete_workout($1::uuid) AS r) call`;
const IMPORT_WORKOUT_SQL = `SELECT r AS result, r::text AS result_text
  FROM (SELECT public.import_historical_workout_v1($1::text, $2::jsonb) AS r) call`;
const ADD_EXERCISE_SQL = `SELECT r AS result, r::text AS result_text
  FROM (SELECT public.add_workout_exercise_with_sets_v1($1::uuid, $2::uuid, $3::uuid, $4::text, $5::jsonb) AS r) call`;

let runtime;
let owner;
let monitorClient;
let monitorPid;
let importExerciseId;
let c8AddExerciseId;
const results = [];

function delay(ms) {
  return new Promise(resolve => { setTimeout(resolve, ms); });
}

function expect(condition, message) {
  if (!condition) throw new Error(message);
}

function setPayload(workoutExerciseId, options = {}) {
  const {
    setNumber = 1, reps = 10, weightKg = 20,
    durationSeconds = 0, restSeconds = 60, isCompleted = true,
  } = options;
  return {
    workout_exercise_id: workoutExerciseId,
    set_number: setNumber,
    reps,
    weight_kg: weightKg,
    duration_seconds: durationSeconds,
    rest_seconds: restSeconds,
    is_completed: isCompleted,
  };
}

function importPayload({ notes = 'concurrent history' } = {}) {
  return {
    started_at: '2026-11-01T10:00:00Z',
    completed_at: '2026-11-01T11:00:00Z',
    duration_seconds: 3600,
    notes,
    exercises: [{
      exercise_id: importExerciseId,
      order_index: 0,
      sets: [{
        set_number: 1,
        reps: 10,
        weight_kg: 20,
        duration_seconds: 0,
        set_type: 'workout',
        is_completed: true,
      }],
    }],
  };
}

async function rows(sql, params = []) {
  return (await owner.query(sql, params)).rows;
}

async function count(sql, params = []) {
  return Number((await rows(sql, params))[0].count);
}

async function setClaims(client, userId) {
  await client.query(
    "SELECT set_config('request.jwt.claim.sub', $1, false), set_config('request.jwt.claims', $2, false)",
    [userId ?? '', userId ? JSON.stringify({ sub: userId, role: 'authenticated' }) : ''],
  );
}

async function businessClient(userId, { authenticate = true } = {}) {
  const client = await runtime.openClient();
  const pid = (await client.query('SELECT pg_backend_pid() AS pid')).rows[0].pid;
  await client.query('SET ROLE authenticated');
  await setClaims(client, authenticate ? userId : null);
  return { client, pid, userId: authenticate ? userId : null };
}

/**
 * Begin an explicit transaction, run one RPC, then keep the transaction open
 * until the harness releases it. Holding the transaction is what keeps the
 * `FOR UPDATE` row lock alive long enough for the monitor connection to sample
 * a genuine `wait_event_type = 'Lock'`. On the error path the transaction is
 * aborted but still holds its locks until ROLLBACK, so the same proof works for
 * rejection scenarios.
 */
async function callInTransaction(connection, hold, { sql, params }) {
  const record = {
    pid: connection.pid,
    user: connection.userId,
    startedAt: Date.now(),
    rpcDoneAt: null,
    endAt: null,
    durationMs: null,
    result: null,
    resultText: null,
    error: null,
    outcome: null,
  };

  try {
    await connection.client.query('BEGIN');
  } catch (error) {
    record.error = { code: error.code ?? null, message: error.message };
    record.outcome = 'BEGIN_FAILED';
    record.endAt = Date.now();
    record.durationMs = record.endAt - record.startedAt;
    return record;
  }

  try {
    const res = await connection.client.query(sql, params);
    record.result = res.rows[0].result;
    record.resultText = res.rows[0].result_text;
  } catch (error) {
    record.error = {
      code: error.code ?? null,
      message: error.message,
      detail: error.detail ?? null,
      hint: error.hint ?? null,
    };
  }
  record.rpcDoneAt = Date.now();

  await hold;

  try {
    if (record.error) {
      await connection.client.query('ROLLBACK');
      record.outcome = 'ROLLBACK';
    } else {
      await connection.client.query('COMMIT');
      record.outcome = 'COMMIT';
    }
  } catch (error) {
    record.outcome = 'CLOSE_FAILED';
    record.commitError = error.message;
  }

  record.endAt = Date.now();
  record.durationMs = record.endAt - record.startedAt;
  return record;
}

async function callImmediately(connection, request) {
  return callInTransaction(connection, Promise.resolve(), request);
}

async function sampleLockWaits(pids) {
  const res = await monitorClient.query(
    `SELECT pid, state, wait_event_type, wait_event,
            pg_blocking_pids(pid) AS blockers,
            round(extract(epoch FROM (clock_timestamp() - query_start))::numeric, 3) AS seconds_in_query
       FROM pg_stat_activity
      WHERE pid = ANY($1::int[]) AND wait_event_type = 'Lock'`,
    [pids],
  );
  return res.rows;
}

async function observeLockWaits(pids, windowMs) {
  const deadline = Date.now() + windowMs;
  let polls = 0;
  while (Date.now() < deadline) {
    const sampled = await sampleLockWaits(pids);
    polls += 1;
    if (sampled.length > 0) return { observed: sampled[0], windowMs, polls, all: sampled };
    await delay(4);
  }
  return { observed: null, windowMs, polls, all: [] };
}

/**
 * Fire both calls before awaiting either one, keep both transactions open, and
 * watch for the row-lock wait that proves the calls overlapped.
 */
async function raceConcurrent({ first, second, firstRequest, secondRequest, windowMs }) {
  let release;
  const hold = new Promise(resolve => { release = resolve; });
  const inFlight = [
    callInTransaction(first, hold, firstRequest),
    callInTransaction(second, hold, secondRequest),
  ];
  const settled = Promise.allSettled(inFlight);

  let locks;
  try {
    locks = await observeLockWaits([first.pid, second.pid], windowMs);
  } finally {
    release();
  }

  const settledResults = await settled;
  const records = settledResults.map((entry, index) => {
    if (entry.status === 'fulfilled') return entry.value;
    return {
      pid: [first, second][index].pid,
      user: [first, second][index].userId,
      outcome: 'PROMISE_REJECTED',
      error: { code: null, message: String(entry.reason) },
    };
  });

  return { records, locks };
}

function printCall(record) {
  const parts = [`pid ${record.pid}`, `${record.durationMs}ms`, record.outcome];
  if (record.error) {
    parts.push(`SQLSTATE ${record.error.code ?? 'n/a'}`);
    parts.push(`message "${record.error.message}"`);
  }
  if (record.result) parts.push(`result ${JSON.stringify(record.result)}`);
  report.info(`call ${parts.join(' | ')}`);
}

function printLocks(locks) {
  if (!locks?.observed) {
    report.info(`lock wait: none observed in ${locks?.windowMs ?? 0}ms across ${locks?.polls ?? 0} samples`);
    return;
  }
  const row = locks.observed;
  const blockers = (row.blockers ?? []).join(',') || 'none';
  report.info(
    `lock wait: pid ${row.pid} waited on '${row.wait_event_type}/${row.wait_event}' `
    + `for ${row.seconds_in_query}s, blocked by pid ${blockers}, `
    + `${locks.polls} samples before release`,
  );
}

async function seedUser(userId, email) {
  await owner.query(
    `INSERT INTO auth.users (id, email, raw_user_meta_data)
     VALUES ($1, $2, '{}'::jsonb) ON CONFLICT (id) DO NOTHING`,
    [userId, email],
  );
  // The on_auth_user_created trigger normally creates this row; the explicit
  // insert keeps the seed valid even if the trigger is absent.
  await owner.query(
    'INSERT INTO public.users (id, email) VALUES ($1, $2) ON CONFLICT (id) DO NOTHING',
    [userId, email],
  );
}

async function seedWorkout({ userId, workoutId, workoutExerciseId, exerciseId, mode = null, startedMinutesAgo = 10 }) {
  await setClaims(owner, userId);
  try {
    await owner.query(
      `INSERT INTO public.workouts (id, user_id, status, training_started_at)
       VALUES ($1, $2, 'active', $3) ON CONFLICT (id) DO NOTHING`,
      [workoutId, userId, new Date(Date.now() - startedMinutesAgo * 60_000)],
    );
    await owner.query(
      `INSERT INTO public.workout_exercises (id, workout_id, exercise_id, order_index, mode)
       VALUES ($1, $2, $3, 0, $4) ON CONFLICT (id) DO NOTHING`,
      [workoutExerciseId, workoutId, exerciseId, mode],
    );
  } finally {
    await setClaims(owner, null);
  }
}

async function seedCompletedSets({ userId, workoutExerciseId, total, weightKg = 20 }) {
  await setClaims(owner, userId);
  try {
    for (let setNumber = 1; setNumber <= total; setNumber += 1) {
      await owner.query(
        `INSERT INTO public.workout_sets
           (workout_exercise_id, set_number, reps, weight_kg, duration_seconds, rest_seconds, is_completed)
         VALUES ($1, $2, 10, $3, 0, 60, true)`,
        [workoutExerciseId, setNumber, weightKg],
      );
    }
  } finally {
    await setClaims(owner, null);
  }
}

async function ledgerRows(userId, operationId) {
  return rows(
    `SELECT user_id, operation_id, workout_id, request_body, result
       FROM public.workout_write_operations
      WHERE user_id = $1 AND operation_id = $2`,
    [userId, operationId],
  );
}

async function importLedgerRows(userId, importKey) {
  return rows(
    `SELECT user_id, import_key, payload_digest, workout_id
       FROM public.historical_workout_imports
      WHERE user_id = $1 AND import_key = $2`,
    [userId, importKey],
  );
}

async function workoutSetRows(workoutId) {
  return rows(
    `SELECT s.id, s.set_number, s.weight_kg
       FROM public.workout_sets s
       JOIN public.workout_exercises we ON we.id = s.workout_exercise_id
      WHERE we.workout_id = $1 ORDER BY s.set_number`,
    [workoutId],
  );
}

function record(id, title, status, note) {
  results.push({ id, title, status, note });
}

async function scenarioC1() {
  report.block('C1 same operation ID, same payload (user A, active workout)');
  const first = await businessClient(OWNER_A);
  const second = await businessClient(OWNER_A);
  report.info(`connections: 2 business (pid ${first.pid}, pid ${second.pid}) + 1 monitor (pid ${monitorPid}) + 1 owner = 4 total`);
  report.info('transaction boundaries: BEGIN -> RPC -> lock-hold -> COMMIT (both callers)');

  try {
    const payload = setPayload(C1.exercise);
    const { records, locks } = await raceConcurrent({
      first,
      second,
      firstRequest: { sql: APPLY_SET_SQL, params: [C1.operation, C1.workout, JSON.stringify(payload)] },
      secondRequest: { sql: APPLY_SET_SQL, params: [C1.operation, C1.workout, JSON.stringify(payload)] },
      windowMs: 3000,
    });
    records.forEach(printCall);
    printLocks(locks);

    const [r1, r2] = records;
    expect(locks.observed, 'no row-lock wait was observed: a sequential result is not concurrency evidence');
    expect(!r1.error && !r2.error, `both callers must succeed, got ${r1.error?.code} / ${r2.error?.code}`);
    expect(isDeepStrictEqual(r1.result, r2.result), 'both callers must return the same JSON object');
    expect(r1.resultText === r2.resultText, 'both callers must return byte-identical JSON');
    expect(r1.result.set_id === r2.result.set_id, 'both callers must report the same set_id');
    expect(r1.result.operation_id === C1.operation, 'returned operation_id must match the request');
    expect(r1.result.workout_id === C1.workout, 'returned workout_id must match the request');

    const sets = await workoutSetRows(C1.workout);
    const ledger = await ledgerRows(OWNER_A, C1.operation);
    report.info(`rows: workout_sets=${sets.length}, workout_write_operations=${ledger.length}, users.total_xp unchanged`);
    expect(sets.length === 1, `exactly one workout_sets row expected, found ${sets.length}`);
    expect(sets[0].id === r1.result.set_id, 'the single stored set must be the returned set_id');
    expect(ledger.length === 1, `exactly one ledger row expected, found ${ledger.length}`);
    expect(ledger[0].result.set_id === r1.result.set_id, 'ledger result must match the caller result');

    record('C1', 'same-id/same-payload', 'PASS', `2 conns, lock wait observed on pid ${locks.observed.pid}`);
  } finally {
    await runtime.closeClient(first.client);
    await runtime.closeClient(second.client);
  }
}

async function scenarioC2() {
  report.block('C2 same operation ID, different payload');
  const first = await businessClient(OWNER_A);
  const second = await businessClient(OWNER_A);
  report.info(`connections: 2 business (pid ${first.pid}, pid ${second.pid}) + 1 monitor (pid ${monitorPid}) + 1 owner = 4 total`);
  report.info('transaction boundaries: BEGIN -> RPC -> lock-hold -> COMMIT / ROLLBACK');

  try {
    const payloadA = setPayload(C2.exercise, { weightKg: 20 });
    const payloadB = setPayload(C2.exercise, { weightKg: 25 });
    const { records, locks } = await raceConcurrent({
      first,
      second,
      firstRequest: { sql: APPLY_SET_SQL, params: [C2.operation, C2.workout, JSON.stringify(payloadA)] },
      secondRequest: { sql: APPLY_SET_SQL, params: [C2.operation, C2.workout, JSON.stringify(payloadB)] },
      windowMs: 3000,
    });
    records.forEach(printCall);
    printLocks(locks);

    expect(locks.observed, 'no row-lock wait was observed: a sequential result is not concurrency evidence');

    const winnerIndex = records.findIndex(item => !item.error);
    const loser = records.find(item => item.error);
    expect(winnerIndex >= 0, 'exactly one caller must succeed');
    expect(records.filter(item => !item.error).length === 1, 'both callers must not succeed');

    report.info(`SQLSTATE on the conflicting caller: ${loser.error.code}`);
    expect(loser.error.code === '23505', `expected SQLSTATE 23505, got ${loser.error.code}`);
    expect(
      /Operation ID reused with different content/i.test(loser.error.message),
      `expected operation-ID reuse message, got "${loser.error.message}"`,
    );

    const winnerWeight = winnerIndex === 0 ? 20 : 25;
    const sets = await workoutSetRows(C2.workout);
    const ledger = await ledgerRows(OWNER_A, C2.operation);
    const storedWeight = ledger[0]?.request_body?.payload?.weight_kg;
    report.info(`rows: workout_sets=${sets.length}, workout_write_operations=${ledger.length}, stored payload weight_kg=${storedWeight}`);
    expect(sets.length === 1, `exactly one workout_sets row expected, found ${sets.length}`);
    expect(ledger.length === 1, `exactly one ledger row expected, found ${ledger.length}`);
    expect(Number(storedWeight) === winnerWeight, `stored payload must match the winner request (${winnerWeight}kg)`);
    expect(Number(sets[0].weight_kg) === winnerWeight, 'the stored set must match the winner payload');

    record('C2', 'same-id/different-payload', 'PASS', `2 conns, lock wait observed on pid ${locks.observed.pid}, loser ${loser.error.code}`);
  } finally {
    await runtime.closeClient(first.client);
    await runtime.closeClient(second.client);
  }
}

async function scenarioC3() {
  report.block('C3 lost acknowledgement replay on a fresh connection');
  const first = await businessClient(OWNER_A);
  const second = await businessClient(OWNER_A);
  report.info(`connections: 2 business (pid ${first.pid}, pid ${second.pid}) + 1 monitor (pid ${monitorPid}) + 1 owner = 4 total`);
  report.info('transaction boundaries: BEGIN -> RPC -> COMMIT (original), BEGIN -> replay RPC -> COMMIT (fresh connection)');

  try {
    const payload = setPayload(C3.exercise);
    const request = { sql: APPLY_SET_SQL, params: [C3.operation, C3.workout, JSON.stringify(payload)] };
    const original = await callImmediately(first, request);
    printCall(original);
    expect(!original.error, `original call must succeed, got ${original.error?.code}`);
    expect(original.outcome === 'COMMIT', 'original call must commit');

    const replay = await callImmediately(second, request);
    printCall(replay);
    expect(!replay.error, `replay must succeed, got ${replay.error?.code}`);
    expect(replay.outcome === 'COMMIT', 'replay must commit');

    expect(original.resultText === replay.resultText, 'replay must return byte-identical JSON');
    expect(isDeepStrictEqual(original.result, replay.result), 'replay must return the same JSON object');

    const sets = await workoutSetRows(C3.workout);
    const ledger = await ledgerRows(OWNER_A, C3.operation);
    report.info(`rows: workout_sets=${sets.length}, workout_write_operations=${ledger.length}`);
    expect(sets.length === 1, `replay must not append a second set, found ${sets.length}`);
    expect(ledger.length === 1, `replay must not append a second ledger row, found ${ledger.length}`);

    record('C3', 'lost-ack replay', 'PASS', '2 conns, byte-identical replay, 1 set, 1 ledger row');
  } finally {
    await runtime.closeClient(first.client);
    await runtime.closeClient(second.client);
  }
}

async function scenarioC4() {
  report.block('C4 concurrent complete_workout (user A, 3 completed sets)');
  const first = await businessClient(OWNER_A);
  const second = await businessClient(OWNER_A);
  report.info(`connections: 2 business (pid ${first.pid}, pid ${second.pid}) + 1 monitor (pid ${monitorPid}) + 1 owner = 4 total`);
  report.info('transaction boundaries: BEGIN -> complete_workout -> lock-hold -> COMMIT (both callers)');

  try {
    const xpBefore = Number((await rows('SELECT total_xp FROM public.users WHERE id = $1', [OWNER_A]))[0].total_xp);
    const { records, locks } = await raceConcurrent({
      first,
      second,
      firstRequest: { sql: COMPLETE_SQL, params: [C4.workout] },
      secondRequest: { sql: COMPLETE_SQL, params: [C4.workout] },
      windowMs: 3000,
    });
    records.forEach(printCall);
    printLocks(locks);

    const [r1, r2] = records;
    expect(locks.observed, 'no row-lock wait was observed: a sequential result is not concurrency evidence');
    expect(!r1.error && !r2.error, `both completion callers must succeed, got ${r1.error?.code} / ${r2.error?.code}`);
    expect(isDeepStrictEqual(r1.result, r2.result), 'both callers must return the same reward JSON');
    expect(r1.resultText === r2.resultText, 'both callers must return byte-identical reward JSON');

    const rewards = await rows('SELECT workout_id, user_id, result FROM public.workout_rewards WHERE workout_id = $1', [C4.workout]);
    const xpAfter = Number((await rows('SELECT total_xp FROM public.users WHERE id = $1', [OWNER_A]))[0].total_xp);
    const xpLogs = await rows(
      `SELECT amount, source FROM public.xp_logs
        WHERE user_id = $1 AND source_id = $2 AND source IN ('workout','quest')`,
      [OWNER_A, C4.workout],
    );
    const earned = Number(r1.result.earnedXP);
    report.info(`rows: workout_rewards=${rewards.length}, xp_logs=${xpLogs.length}, total_xp ${xpBefore} -> ${xpAfter} (earnedXP=${earned})`);
    expect(rewards.length === 1, `exactly one workout_rewards row expected, found ${rewards.length}`);
    expect(xpLogs.length === 1, `exactly one workout/quest xp_logs row expected, found ${xpLogs.length}`);
    expect(Number(xpLogs[0].amount) === earned, 'xp_logs amount must equal the awarded XP');
    expect(xpAfter - xpBefore === earned, `total_xp must increase exactly once by ${earned}, delta was ${xpAfter - xpBefore}`);
    expect(isDeepStrictEqual(rewards[0].result, r1.result), 'stored reward must equal the caller result');

    record('C4', 'concurrent complete_workout', 'PASS', `2 conns, lock wait observed on pid ${locks.observed.pid}, +${earned} XP once`);
  } finally {
    await runtime.closeClient(first.client);
    await runtime.closeClient(second.client);
  }
}

async function scenarioC5() {
  report.block('C5 cross-user identical operation UUID');
  const first = await businessClient(OWNER_A);
  const second = await businessClient(OWNER_B);
  report.info(`connections: 2 business (user A pid ${first.pid}, user B pid ${second.pid}) + 1 monitor (pid ${monitorPid}) + 1 owner = 4 total`);
  report.info('transaction boundaries: BEGIN -> RPC -> lock-hold -> COMMIT (independent user rows)');

  try {
    const payloadA = setPayload(C5.exerciseA, { weightKg: 20 });
    const payloadB = setPayload(C5.exerciseB, { weightKg: 30 });
    const { records, locks } = await raceConcurrent({
      first,
      second,
      firstRequest: { sql: APPLY_SET_SQL, params: [C5.operation, C5.workoutA, JSON.stringify(payloadA)] },
      secondRequest: { sql: APPLY_SET_SQL, params: [C5.operation, C5.workoutB, JSON.stringify(payloadB)] },
      windowMs: 500,
    });
    records.forEach(printCall);
    printLocks(locks);

    const [r1, r2] = records;
    expect(!r1.error && !r2.error, `both users must succeed independently, got ${r1.error?.code} / ${r2.error?.code}`);
    expect(isDeepStrictEqual(r1.result, r2.result) === false, 'the two results must not be the identical ledger row');
    expect(r1.result.set_id !== r2.result.set_id, 'the two set_ids must differ');
    expect(r1.result.workout_id === C5.workoutA, 'user A result must reference user A workout');
    expect(r2.result.workout_id === C5.workoutB, 'user B result must reference user B workout');
    expect(r1.result.workout_id !== r2.result.workout_id, 'neither user may see the other workout');

    const ledger = await rows(
      `SELECT user_id, workout_id FROM public.workout_write_operations
        WHERE operation_id = $1 ORDER BY user_id`,
      [C5.operation],
    );
    report.info(`rows: workout_write_operations for the shared operation UUID=${ledger.length} (users ${ledger.map(item => item.user_id).join(', ')})`);
    expect(ledger.length === 2, `two ledger rows expected for the shared UUID, found ${ledger.length}`);
    expect(new Set(ledger.map(item => item.user_id)).size === 2, 'ledger rows must belong to two different users');
    expect(ledger.every(item => item.workout_id === (item.user_id === OWNER_A ? C5.workoutA : C5.workoutB)), 'each ledger row must reference its own workout');

    record('C5', 'cross-user same operation UUID', 'PASS', '2 conns, no shared lock required, 2 ledger rows');
  } finally {
    await runtime.closeClient(first.client);
    await runtime.closeClient(second.client);
  }
}

function errorLeaksIdentity(record) {
  const text = `${record.error?.message ?? ''} ${record.error?.detail ?? ''} ${record.error?.hint ?? ''}`;
  return [C6.workout, C6.exercise, OWNER_A, EMAIL_A].some(value => text.toLowerCase().includes(String(value).toLowerCase()));
}

async function scenarioC6() {
  report.block('C6 unauthorized workout ownership');
  const intruderFirst = await businessClient(OWNER_B);
  const intruderSecond = await businessClient(OWNER_B);
  const blocker = await businessClient(OWNER_B);
  const anonymous = await businessClient(null, { authenticate: false });
  report.info(
    `connections: 4 business (user B pid ${intruderFirst.pid}, user B pid ${intruderSecond.pid}, `
    + `row holder pid ${blocker.pid}, unauthenticated pid ${anonymous.pid}) + 1 monitor (pid ${monitorPid}) + 1 owner = 6 total`,
  );
  report.info('transaction boundaries: BEGIN -> RPC -> stop -> ROLLBACK (both rejected paths)');

  try {
    const xpBefore = Number((await rows('SELECT total_xp FROM public.users WHERE id = $1', [OWNER_A]))[0].total_xp);
    const payload = setPayload(C6.exercise);

    // Both RPCs reject immediately, and PostgreSQL releases row locks as soon
    // as a statement aborts, so two rejected calls cannot hold a lock long
    // enough to observe on their own. A separate user-B session takes the same
    // public.users row that both RPCs lock first (the real serialization point
    // of a concurrent legitimate request), keeping both rejected attempts
    // observably in flight. The authorization outcome is asserted separately.
    await blocker.client.query('BEGIN');
    await blocker.client.query('SELECT 1 FROM public.users WHERE id = $1 FOR UPDATE', [OWNER_B]);
    report.info(`row holder: pid ${blocker.pid} holds public.users FOR UPDATE for user B`);

    let release;
    const hold = new Promise(resolve => { release = resolve; });
    const settled = Promise.allSettled([
      callInTransaction(intruderFirst, hold, {
        sql: APPLY_SET_SQL,
        params: [C6.operation, C6.workout, JSON.stringify(payload)],
      }),
      callInTransaction(intruderSecond, hold, { sql: COMPLETE_SQL, params: [C6.workout] }),
    ]);

    let locks;
    try {
      locks = await observeLockWaits([intruderFirst.pid, intruderSecond.pid], 3000);
    } finally {
      await blocker.client.query('COMMIT').catch(() => {});
      release();
    }

    const records = (await settled).map((entry, index) => entry.status === 'fulfilled'
      ? entry.value
      : {
        pid: [intruderFirst, intruderSecond][index].pid,
        outcome: 'PROMISE_REJECTED',
        error: { code: null, message: String(entry.reason) },
      });
    records.forEach(printCall);
    printLocks(locks);
    const blockedPids = (locks.all ?? []).map(item => item.pid);
    report.info(`simultaneously blocked: ${blockedPids.length} (pids ${blockedPids.join(', ') || 'none'})`);

    expect(locks.observed, 'no row-lock wait was observed on the intruder account: not concurrency evidence');
    for (const item of records) {
      expect(item.error, 'both cross-user calls must be rejected');
      expect(item.error.code === '42501', `expected SQLSTATE 42501, got ${item.error.code}`);
      expect(!errorLeaksIdentity(item), `error text must not disclose owner identifiers: "${item.error.message}"`);
      expect(item.outcome === 'ROLLBACK', 'rejected calls must roll back');
    }

    const anonymousApply = await callImmediately(anonymous, {
      sql: APPLY_SET_SQL,
      params: [C6.operation, C6.workout, JSON.stringify(payload)],
    });
    const anonymousComplete = await callImmediately(anonymous, { sql: COMPLETE_SQL, params: [C6.workout] });
    printCall(anonymousApply);
    printCall(anonymousComplete);
    for (const item of [anonymousApply, anonymousComplete]) {
      expect(item.error, 'an unauthenticated caller must be rejected');
      expect(item.error.code === '42501', `expected SQLSTATE 42501, got ${item.error.code}`);
      expect(/Authentication required/i.test(item.error.message), `expected authentication message, got "${item.error.message}"`);
    }

    const sets = await workoutSetRows(C6.workout);
    const ledger = await count('SELECT count(*) FROM public.workout_write_operations WHERE operation_id = $1', [C6.operation]);
    const rewards = await count('SELECT count(*) FROM public.workout_rewards WHERE workout_id = $1', [C6.workout]);
    const xpLogs = await count('SELECT count(*) FROM public.xp_logs WHERE source_id = $1', [C6.workout]);
    const xpAfter = Number((await rows('SELECT total_xp FROM public.users WHERE id = $1', [OWNER_A]))[0].total_xp);
    report.info(`rows: workout_sets=${sets.length}, workout_write_operations=${ledger}, workout_rewards=${rewards}, xp_logs=${xpLogs}, total_xp ${xpBefore} -> ${xpAfter}`);
    expect(sets.length === 0, `no workout_sets row may be created, found ${sets.length}`);
    expect(ledger === 0, `no ledger row may be created, found ${ledger}`);
    expect(rewards === 0, `no workout_rewards row may be created, found ${rewards}`);
    expect(xpLogs === 0, `no xp_logs row may be created, found ${xpLogs}`);
    expect(xpBefore === xpAfter, 'owner total_xp must not change');

    record('C6', 'unauthorized workout ownership', 'PASS', `2 conns, lock wait observed on pid ${locks.observed.pid}, all rejected 42501`);
  } finally {
    await runtime.closeClient(intruderFirst.client);
    await runtime.closeClient(intruderSecond.client);
    await runtime.closeClient(blocker.client);
    await runtime.closeClient(anonymous.client);
  }
}

async function scenarioC7() {
  report.block('C7 concurrent historical import, same key and payload');
  const first = await businessClient(OWNER_A);
  const second = await businessClient(OWNER_A);
  report.info(`connections: 2 business (pid ${first.pid}, pid ${second.pid}) + 1 monitor (pid ${monitorPid}) + 1 owner = 4 total`);
  report.info('transaction boundaries: BEGIN -> import RPC -> lock-hold -> COMMIT (both callers)');

  try {
    const payload = JSON.stringify(importPayload());
    const xpBefore = Number((await rows('SELECT total_xp FROM public.users WHERE id = $1', [OWNER_A]))[0].total_xp);
    const unlocksBefore = await count('SELECT count(*) FROM public.user_unlocks WHERE user_id = $1', [OWNER_A]);
    const { records, locks } = await raceConcurrent({
      first,
      second,
      firstRequest: { sql: IMPORT_WORKOUT_SQL, params: [C7.importKey, payload] },
      secondRequest: { sql: IMPORT_WORKOUT_SQL, params: [C7.importKey, payload] },
      windowMs: 3000,
    });
    records.forEach(printCall);
    printLocks(locks);

    expect(locks.observed, 'no row-lock wait was observed: a sequential result is not concurrency evidence');
    expect(records.every(item => !item.error && item.outcome === 'COMMIT'), 'both imports must commit');
    expect(records[0].result.workoutId === records[1].result.workoutId, 'both callers must receive one workout ID');
    expect(records.filter(item => item.result.alreadyImported === false).length === 1, 'exactly one caller must create the workout');
    expect(records.filter(item => item.result.alreadyImported === true).length === 1, 'exactly one caller must receive the retry receipt');

    const workoutId = records[0].result.workoutId;
    const ledger = await importLedgerRows(OWNER_A, C7.importKey);
    const imported = await rows('SELECT id, user_id, status, is_imported FROM public.workouts WHERE id = $1', [workoutId]);
    const sets = await workoutSetRows(workoutId);
    const rewards = await count('SELECT count(*) FROM public.workout_rewards WHERE workout_id = $1', [workoutId]);
    const xpLogs = await count('SELECT count(*) FROM public.xp_logs WHERE source_id = $1', [workoutId]);
    const xpAfter = Number((await rows('SELECT total_xp FROM public.users WHERE id = $1', [OWNER_A]))[0].total_xp);
    const unlocksAfter = await count('SELECT count(*) FROM public.user_unlocks WHERE user_id = $1', [OWNER_A]);
    report.info(`rows: ledger=${ledger.length}, workouts=${imported.length}, sets=${sets.length}, rewards=${rewards}, xp_logs=${xpLogs}, total_xp ${xpBefore} -> ${xpAfter}, unlocks ${unlocksBefore} -> ${unlocksAfter}`);
    expect(ledger.length === 1 && ledger[0].workout_id === workoutId, 'exactly one ledger row must link the imported workout');
    expect(imported.length === 1 && imported[0].user_id === OWNER_A && imported[0].status === 'completed' && imported[0].is_imported, 'one completed imported workout must belong to user A');
    expect(sets.length === 1, 'exactly one imported set must exist');
    expect(rewards === 0 && xpLogs === 0 && xpAfter === xpBefore && unlocksAfter === unlocksBefore, 'historical import must not award progression');

    const changed = await callImmediately(first, {
      sql: IMPORT_WORKOUT_SQL,
      params: [C7.importKey, JSON.stringify(importPayload({ notes: 'changed content' }))],
    });
    printCall(changed);
    expect(changed.error?.code === '22023' && changed.outcome === 'ROLLBACK', 'same key with changed content must reject without mutation');
    expect((await importLedgerRows(OWNER_A, C7.importKey)).length === 1, 'conflicting retry must preserve one ledger row');

    record('C7', 'concurrent historical import', 'PASS', `2 conns, lock wait observed on pid ${locks.observed.pid}, one workout and no rewards`);
  } finally {
    await runtime.closeClient(first.client);
    await runtime.closeClient(second.client);
  }
}

async function scenarioC8() {
  report.block('C8 concurrent atomic exercise-and-sets add, same key and payload');
  const first = await businessClient(OWNER_A);
  const second = await businessClient(OWNER_A);
  report.info(`connections: 2 business (pid ${first.pid}, pid ${second.pid}) + 1 monitor (pid ${monitorPid}) + 1 owner = 4 total`);
  report.info('transaction boundaries: BEGIN -> add RPC -> lock-hold -> COMMIT (both callers)');

  try {
    const sets = JSON.stringify([
      { reps: 10, weight_kg: 20, duration_seconds: 0 },
      { reps: 9, weight_kg: 20, duration_seconds: 0 },
      { reps: 8, weight_kg: 20, duration_seconds: 0 },
    ]);
    const params = [C8.operation, C8.workout, c8AddExerciseId, null, sets];
    const { records, locks } = await raceConcurrent({
      first,
      second,
      firstRequest: { sql: ADD_EXERCISE_SQL, params },
      secondRequest: { sql: ADD_EXERCISE_SQL, params },
      windowMs: 3000,
    });
    records.forEach(printCall);
    printLocks(locks);

    expect(locks.observed, 'no row-lock wait was observed: a sequential result is not concurrency evidence');
    expect(records.every(item => !item.error && item.outcome === 'COMMIT'), 'both calls must commit');
    expect(records[0].result.workout_exercise_id === records[1].result.workout_exercise_id, 'same operation must return one exercise ID');
    const addedId = records[0].result.workout_exercise_id;
    const added = await rows('SELECT id, workout_id, exercise_id FROM public.workout_exercises WHERE id = $1', [addedId]);
    const newSets = await rows('SELECT id, set_number FROM public.workout_sets WHERE workout_exercise_id = $1 ORDER BY set_number', [addedId]);
    const ledger = await rows('SELECT operation_id, workout_id, mutation_kind FROM public.workout_write_operations WHERE user_id = $1 AND operation_id = $2', [OWNER_A, C8.operation]);
    const rewards = await count('SELECT count(*) FROM public.workout_rewards WHERE workout_id = $1', [C8.workout]);
    expect(added.length === 1 && added[0].workout_id === C8.workout && added[0].exercise_id === c8AddExerciseId, 'one added exercise must belong to the owner workout');
    expect(newSets.length === 3 && newSets.every((set, index) => set.set_number === index + 1), 'three default sets must be written exactly once');
    expect(ledger.length === 1 && ledger[0].workout_id === C8.workout, 'one private ledger receipt must exist');
    expect(rewards === 0, 'adding default sets must not award workout rewards');
    report.info(`rows: added exercises=${added.length}, sets=${newSets.length}, ledger=${ledger.length}, rewards=${rewards}`);

    const changed = await callImmediately(first, {
      sql: ADD_EXERCISE_SQL,
      params: [C8.operation, C8.workout, c8AddExerciseId, null, JSON.stringify([{ reps: 11, weight_kg: 20, duration_seconds: 0 }])],
    });
    printCall(changed);
    expect(changed.error?.code === '23505' && changed.outcome === 'ROLLBACK', 'same key with changed sets must reject');
    expect(await count('SELECT count(*) FROM public.workout_exercises WHERE workout_id = $1 AND exercise_id = $2', [C8.workout, c8AddExerciseId]) === 1, 'conflicting retry must not add a duplicate');

    record('C8', 'concurrent atomic exercise add', 'PASS', `2 conns, lock wait observed on pid ${locks.observed.pid}, one exercise with three sets`);
  } finally {
    await runtime.closeClient(first.client);
    await runtime.closeClient(second.client);
  }
}

function printSummary(version) {
  report.info('');
  const scenarios = [
    ['C1', 'same-id/same-payload'],
    ['C2', 'same-id/different-payload'],
    ['C3', 'lost-ack replay'],
    ['C4', 'concurrent complete_workout'],
    ['C5', 'cross-user same operation UUID'],
    ['C6', 'unauthorized workout ownership'],
    ['C7', 'concurrent historical import'],
    ['C8', 'concurrent atomic exercise add'],
  ];
  for (const [id, title] of scenarios) {
    const entry = results.find(item => item.id === id);
    const left = `SCENARIO ${id} ${title} `;
    const status = entry?.status ?? 'FAIL';
    const note = entry?.note ?? 'scenario did not run';
    report.info(`${left.padEnd(46, '.')} ${status} (${note})`);
  }
  const passed = results.filter(item => item.status === 'PASS').length;
  report.info(`TOTAL: ${passed}/${scenarios.length} scenarios ${passed === scenarios.length ? 'PASS' : 'FAIL'}`);
  report.info(`POSTGRES: PostgreSQL ${version.short_version} (embedded, isolated, two-connection)`);
}

async function main() {
  const started = await startRuntime({ label: 'gymlvl-m36' });
  runtime = started.runtime;

  owner = await runtime.openClient();
  monitorClient = await runtime.openClient();
  monitorPid = (await monitorClient.query('SELECT pg_backend_pid() AS pid')).rows[0].pid;

  const exercises = (await rows('SELECT id FROM public.exercises ORDER BY id LIMIT 4')).map(row => row.id);
  expect(exercises.length >= 4, 'the seeded exercise catalog must provide at least four exercises');

  await seedUser(OWNER_A, EMAIL_A);
  await seedUser(OWNER_B, EMAIL_B);
  await owner.query('UPDATE public.users SET onboarding_completed = true WHERE id = ANY($1::uuid[])', [[OWNER_A, OWNER_B]]);
  importExerciseId = exercises[0];
  c8AddExerciseId = exercises[1];

  await seedWorkout({ userId: OWNER_A, workoutId: C1.workout, workoutExerciseId: C1.exercise, exerciseId: exercises[0] });
  await seedWorkout({ userId: OWNER_A, workoutId: C2.workout, workoutExerciseId: C2.exercise, exerciseId: exercises[0] });
  await seedWorkout({ userId: OWNER_A, workoutId: C3.workout, workoutExerciseId: C3.exercise, exerciseId: exercises[0] });
  await seedWorkout({ userId: OWNER_A, workoutId: C4.workout, workoutExerciseId: C4.exercise, exerciseId: exercises[1] });
  await seedWorkout({ userId: OWNER_A, workoutId: C5.workoutA, workoutExerciseId: C5.exerciseA, exerciseId: exercises[2] });
  await seedWorkout({ userId: OWNER_B, workoutId: C5.workoutB, workoutExerciseId: C5.exerciseB, exerciseId: exercises[3] });
  await seedWorkout({ userId: OWNER_A, workoutId: C6.workout, workoutExerciseId: C6.exercise, exerciseId: exercises[0] });
  await seedWorkout({ userId: OWNER_A, workoutId: C8.workout, workoutExerciseId: C8.existingExercise, exerciseId: exercises[0] });
  await seedCompletedSets({ userId: OWNER_A, workoutExerciseId: C4.exercise, total: 3 });

  for (const scenario of [scenarioC1, scenarioC2, scenarioC3, scenarioC4, scenarioC5, scenarioC6, scenarioC7, scenarioC8]) {
    const id = scenario.name.replace('scenario', '');
    try {
      await scenario();
    } catch (error) {
      report.fail(id, error.message);
      if (!results.some(item => item.id === id)) record(id, 'scenario', 'FAIL', error.message);
      else results.find(item => item.id === id).status = 'FAIL';
    }
  }

  printSummary(started.version);
}

const watchdog = setTimeout(() => {
  console.error('FAIL watchdog: M3.6 harness exceeded 300s');
  process.exit(1);
}, 300_000);

let cleanup = null;
try {
  await main();
} catch (error) {
  report.fail('harness', error.message);
} finally {
  clearTimeout(watchdog);
  if (runtime) cleanup = await runtime.teardown();
}

if (cleanup) {
  report.info('');
  report.info(`CLEANUP data directory ${cleanup.databaseDir} removed=${cleanup.directoryRemoved}`);
  if (!cleanup.directoryRemoved) report.fail('cleanup', 'the isolated data directory still exists');
  const closed = await isPortFree(cleanup.port);
  report.info(`CLEANUP port ${cleanup.port} has no listener closed=${closed}`);
  if (!closed) report.fail('cleanup', `a server is still listening on port ${cleanup.port}`);
}

report.finish();
