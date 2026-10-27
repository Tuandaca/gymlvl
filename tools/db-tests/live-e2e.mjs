// Run only against an explicitly identified, migrated test/staging project.
// Uses two temporary admin-created identities; deletes only those created here.
import assert from 'node:assert/strict';
import { randomBytes, randomUUID } from 'node:crypto';
const url = process.env.SUPABASE_URL?.replace(/\/$/, '');
const publicKey = process.env.SUPABASE_PUBLISHABLE_KEY ?? process.env.SUPABASE_ANON_KEY;
const adminKey = process.env.TEST_SERVICE_ROLE_KEY;
const confirmedHost = process.env.GYMLVL_E2E_EXPECTED_HOST;
if (!url || !publicKey || !adminKey || new URL(url).host !== confirmedHost) {
  throw new Error('Set public URL/key, TEST_SERVICE_ROLE_KEY, and GYMLVL_E2E_EXPECTED_HOST to the explicitly verified target.');
}
const created = [];
let failures = 0;

async function call(route, { method = 'GET', body, token = publicKey, admin = false, headers = {} } = {}) {
  const response = await fetch(`${url}${route}`, {
    method,
    headers: { apikey: admin ? adminKey : publicKey, Authorization: `Bearer ${admin ? adminKey : token}`, 'Content-Type': 'application/json', ...headers },
    ...(body === undefined ? {} : { body: JSON.stringify(body) }),
    signal: AbortSignal.timeout(30000),
  });
  let result;
  try { result = await response.json(); } catch { result = null; }
  return { status: response.status, ok: response.ok, body: result };
}
function requireOk(response, label) {
  assert(response.ok, `${label}: HTTP ${response.status}`);
  return response.body;
}
function check(ok, label) {
  assert(ok, label);
  console.log(`PASS ${label}`);
}
async function rpc(name, token, body = {}) {
  return call(`/rest/v1/rpc/${name}`, { method: 'POST', token, body });
}

try {
  const users = [];
  for (let index = 0; index < 2; index++) {
    const email = `gymlvl-e2e-${randomUUID()}@example.test`;
    const password = randomBytes(30).toString('base64url');
    const account = requireOk(await call('/auth/v1/admin/users', {
      method: 'POST', admin: true, body: { email, password, email_confirm: true, user_metadata: { display_name: 'Temporary QA athlete' } },
    }), 'create isolated test account');
    created.push(account.id);
    const session = requireOk(await call('/auth/v1/token?grant_type=password', { method: 'POST', body: { email, password } }), 'sign in');
    users.push({ id: account.id, token: session.access_token, refresh: session.refresh_token });
  }
  check(users.every(user => user.token && user.id), 'two isolated test identities sign in');
  const [first, second] = users;
  const refreshed = requireOk(await call('/auth/v1/token?grant_type=refresh_token', { method: 'POST', body: { refresh_token: first.refresh } }), 'restore session');
  first.token = refreshed.access_token;
  check(requireOk(await call('/auth/v1/user', { token: first.token }), 'restored identity').id === first.id, 'session refresh preserves identity');

  const profile = { environment: 'gym', goals: ['hypertrophy'], experience_level: 'beginner', age: 25, gender: 'other', height_cm: 170, weight_kg: 70, weekly_gym_days: 3, weekly_home_days: 0, preferred_training_days: ['Mon', 'Wed', 'Fri'], primary_class_id: 'B', secondary_class_id: 'C', timezone: 'Asia/Ho_Chi_Minh' };
  for (const user of users) requireOk(await rpc('initialize_user', user.token, { p_profile: profile }), 'onboarding');
  const own = requireOk(await call('/rest/v1/users?select=id,onboarding_completed,total_xp', { token: first.token }), 'own profile');
  check(own.length === 1 && own[0].id === first.id && own[0].onboarding_completed && own[0].total_xp === 0, 'signup profile, onboarding, and user isolation');
  check(!(await call(`/rest/v1/users?id=eq.${first.id}`, { method: 'PATCH', token: first.token, body: { total_xp: 999999 } })).ok, 'direct XP mutation denied');
  check(!(await call('/rest/v1/users?select=id')).ok, 'anonymous private profile read denied');

  const workout = requireOk(await rpc('start_workout', first.token), 'start workout');
  check(requireOk(await rpc('start_workout', first.token), 'replay start').id === workout.id, 'duplicate workout start returns same session');
  const exercises = requireOk(await call('/rest/v1/exercises?select=id&limit=1', { token: first.token }), 'exercise catalog');
  check(exercises.length === 1, 'authenticated exercise catalogue available');
  const logged = requireOk(await call('/rest/v1/workout_exercises', { method: 'POST', token: first.token, body: { workout_id: workout.id, exercise_id: exercises[0].id }, headers: { Prefer: 'return=representation' } }), 'add exercise')[0];
  requireOk(await rpc('begin_workout', first.token, { p_workout_id: workout.id }), 'begin training');
  const paused = requireOk(await rpc('set_workout_paused', first.token, { p_workout_id: workout.id, p_paused: true }), 'pause');
  const resumed = requireOk(await rpc('set_workout_paused', first.token, { p_workout_id: workout.id, p_paused: false }), 'resume');
  check(paused.paused_at != null && resumed.paused_at == null, 'pause and resume persist on server');
  const set = requireOk(await call('/rest/v1/workout_sets', { method: 'POST', token: first.token, body: { workout_exercise_id: logged.id, set_number: 1, reps: 10, weight_kg: 20, baseline_weight_kg: 0.00001, is_completed: true }, headers: { Prefer: 'return=representation' } }), 'log completed set')[0];
  check(Number(set.baseline_weight_kg) === 0, 'server ignores forged reward baseline');
  check(requireOk(await call(`/rest/v1/workouts?id=eq.${workout.id}`, { token: second.token }), 'cross-user read').length === 0, 'other user cannot read workout');
  check(!(await rpc('complete_workout', second.token, { p_workout_id: workout.id })).ok, 'other user cannot complete workout');

  const concurrent = await Promise.all([
    rpc('complete_workout', first.token, { p_workout_id: workout.id }),
    rpc('complete_workout', first.token, { p_workout_id: workout.id }),
  ]);
  const rewards = concurrent.map(response => requireOk(response, 'concurrent completion'));
  check(rewards[0].earnedXP === 5 && JSON.stringify(rewards[0]) === JSON.stringify(rewards[1]), 'concurrent completion returns one authoritative reward');
  const history = requireOk(await call(`/rest/v1/workouts?id=eq.${workout.id}&select=status,is_xp_calculated,workout_exercises(workout_sets(reps,weight_kg,is_completed))`, { token: first.token }), 'persisted history');
  check(history[0].status === 'completed' && history[0].is_xp_calculated && history[0].workout_exercises[0].workout_sets[0].reps === 10, 'completed workout and logged sets persist in history');
  check(requireOk(await call('/rest/v1/workout_rewards?select=workout_id', { token: first.token }), 'reward ledger').length === 1, 'duplicate submissions create one reward ledger entry');
  const stats = requireOk(await rpc('get_user_stats', first.token), 'dashboard stats');
  check(stats.streak.current_streak === 1 && stats.achievements.some(item => item.achievement_id === 'first_workout'), 'streak and first-workout achievement persist');
  const quest = requireOk(await rpc('sync_daily_data', first.token), 'daily quest');
  check(quest.quest.id === requireOk(await rpc('sync_daily_data', first.token), 'replay quest').quest.id, 'daily quest sync is idempotent');

  check((await call('/functions/v1/get-user-stats', { method: 'POST', token: 'invalid-token', body: {} })).status === 401, 'deployed Edge gateway rejects invalid token');
  requireOk(await call('/functions/v1/get-user-stats', { method: 'POST', token: first.token, body: {} }), 'authenticated deployed Edge function');
  console.log('PASS authenticated deployed Edge function uses current user');
  if (process.env.GYMLVL_E2E_COACH_UNCONFIGURED === 'true') {
    check((await call('/functions/v1/ai-coach', { method: 'POST', token: first.token, body: { message: 'How should I recover between workouts?' } })).status === 503, 'AI Coach safely reports unconfigured provider');
  }
  requireOk(await call('/auth/v1/logout', { method: 'POST', token: first.token }), 'sign out');
  console.log('PASS sign out');
} catch (error) {
  failures++;
  console.error(`FAIL live E2E: ${error instanceof assert.AssertionError ? error.message : 'network or service operation failed'}`);
} finally {
  for (const id of created) {
    try {
      // Explicitly remove only this run's reward row before legacy RESTRICT FKs.
      requireOk(await call(`/rest/v1/workout_rewards?user_id=eq.${id}`, { method: 'DELETE', admin: true }), 'cleanup temporary reward');
      requireOk(await call(`/auth/v1/admin/users/${id}`, { method: 'DELETE', admin: true }), 'cleanup temporary account');
      console.log('PASS temporary test identity and records removed');
    } catch {
      failures++;
      console.error('FAIL cleanup: a temporary gymlvl-e2e account requires administrator cleanup; identify by its generated email prefix.');
    }
  }
  if (failures) process.exitCode = 1;
}
