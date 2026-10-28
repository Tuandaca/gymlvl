# A4 — Bounded synthetic SQL evidence

**Date/task:** 2026-10-28, A4 workout/progression business logic only.
**Measured commit:** main `c95cb4873455b39f3ab2b6c0f929b43d87f4d8d3`.
**Author:** delegated supabase-specialist; exclusive ownership of this new evidence file and the
new external directory below. No register/planning/product/permanent-test edits.
**Result:** PASS for the finite fixture assertions described here, not a product-wide PASS. The108
assertions include fixture/catalog/source guards; defect-observing assertions deliberately preserve
the product behavior failures described below.

## 1. Authorization, setup and limits

The user's A4 authorization permits isolated synthetic tests; the orchestrator bounded this delegation
to the eight case groups below. Initial inspection found the five
expected orchestrator-owned dirty documentation paths, branch main and the SHA above. Both
`C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a4-sql-20261028` and this evidence path were
absent before creation (`EXTERNAL_DIRECTORY_ABSENT`, `EVIDENCE_PATH_ABSENT`). The stop-if-present
condition did not trigger. The external directory contains only `probe.mjs` and `run-01.log`.

The installed PGlite module and pgcrypto extension were imported by local file URL. No installation,
secret/environment-file read, live database, real account, HTTP request, remote migration/deploy,
full-app copy or cleanup occurred. `globalThis.fetch` throws on every attempted use; the final
counter is zero. Node `--version` returned `v22.17.1`; installed PGlite package metadata says0.4.6
(inspection, not an independently queried PostgreSQL server-version claim).

Each variant creates its own in-memory PGlite database, applies the existing bootstrap, three
migrations and both configured seeds in order, then asserts150 catalog rows. Synthetic fixture
state is inside a transaction rolled back at the end; the database is then closed. The fifteen
databases run sequentially. They are **independent fixtures, not concurrent database connections**.
No persistent Supabase/local/remote database was changed; the migrations were executed only inside
the disposable in-memory databases.

All exercise IDs are resolved from the seeded catalog by slug or from actual generated quest
targets. Synthetic identity/session IDs are not exercise IDs. Actual award RPC calls run with
`SET LOCAL ROLE authenticated` and the synthetic caller's Auth claims. Admin statements only create
explicit fixture state: historical flags/timestamps/credit, template selection, streak and injected
error instrumentation. This is not an A3 RLS/PUBLIC-ACL rerun.

### Exact runtime command and exits

From `D:\Projects\gymlvl`, PowerShell:

```powershell
node 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a4-sql-20261028\probe.mjs' 2>&1 | Tee-Object -FilePath 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a4-sql-20261028\run-01.log'; $code=$LASTEXITCODE; Write-Output "NODE_EXIT=$code"; exit $code
```

Specialist executed once, exit0; wrapper output `NODE_EXIT=0`. **No unexpected assertion failure, diagnostic
revision or rerun occurred.** Two22023 errors and oneP0001 error below are deliberately expected
and asserted, not concealed failed runs. No product repair was attempted.

The orchestrator subsequently reran the exact retained probe independently to verify the material
P1 DATA001 reproduction and its controls. `node <external-path>/probe.mjs` -> the same eight groups,
15 DBs,108 assertions, zero fetch attempts; `A4_INDEPENDENT_SQL_EXIT=0`. This is a separately justified
verification run, not a claim of two concurrent connections. No source revision or product change.

Artifact hashes from `Get-FileHash -Algorithm SHA256 -LiteralPath ...` (exit0):

- `probe.mjs`: `37D3ECDA9AA9F311B1FD15A9D590C485D90DE62FFAE5EB9FC1B1AD278AC4E600`
- `run-01.log`: `90F1BD5890D888C2E0A17685F6AF6E9E85A0E9E1F88A1B0052F103BFA0974E1B`

The script prints SHA256 for all six SQL inputs and the statically inspected controller; these
appear in the complete output below. Full final source is retained in section4 so QA need not
access an external directory. The source uses fixed workspace paths intentionally.

## 2. Expected predicates and observed outcomes

1. **Initial/replay and legacy controls:** ordinary initial completion and legitimate completed,
   false-flag/unrewarded recovery each earn10 XP once, return an identical replay result, and retain
   one global award log and one reward row. A true-flag prior-credit/log control returns0 earned XP,
   leaves total10/logs1 and creates no reward row. All asserted outcomes observed.
2. **DATA001 conditional prior-award tuple:** fixture explicitly starts with completed status,
   false flag, **no workout_rewards row, prior total_xp=10 and one existing workout XP log=10**.
   Invocation earns another10: total20, two workout award logs, one reward row. Replay returns the
   same result and adds no third credit. This reproduces a conditional mechanism, not a live legacy
   population, an ordinary retry defect, or duplication of every kind of historical reward.
3. **Timed completion contradiction:** an authenticated insert of a completed Plank set with
   reps0/duration30 is accepted by the final CHECK. Completion rejects22023 `Invalid workout
   measurements`; the eleven-table state snapshot is unchanged and no credit/log/reward exists.
   Changing only reps to1 permits completion earning5. This is distinct from the existing hidden-rep
   Add Set behavior in FND-INTG-004.
4. **Class switching:** actual B/C completion earns20 global XP and21 C XP. C->A->C secondary-slot
   switching restores20 C XP despite an unchanged class XP log of21. Global total remains20. No
   contrary result occurred; the predicted loss was reproduced in the same fixture.
5. **Full Body focus:** seeded Burpee category is `Full Body`; configured A/D/E focus contains
   `full_body`. In separate single-class fixtures, each20-XP Burpee session credits8 class XP.
   Same-day matched controls credit20 class XP for20 global XP: Jumping Jack for A/D and Crunch
   for E. No pair synergy, previous exercise PR or quest reward confounds these comparisons.
6. **Generated timed quest contract:** fixture changes only non-full_body seeded quest template
   types to `a4_fixture_unused`, making actual `sync_daily_data` selection deterministic. No exercise
   metadata or RPC is modified. It generates Ab Wheel Rollout (carry), Arnold Press and Back
   Extension targets, each3x12. Source-guarded JS mirrors the client's timed0reps/30sec defaults:
   all sets persist, but Ab Wheel has0 qualifying sets against required3; other targets have3.
   Completion rejects22023, user total remains0 and quest remains active. A synthetic positive-rep
   SQL control satisfies the same generated quest and earns450. **Dart/UI did not execute**; the
   runtime facts are SQL generation, persistence, matching predicate and controls, with the client
   defaults linked by source inspection. The classification of a carry exercise is existing seed
   metadata, not independently validated exercise science.
7. **Late failure/rollback:** fixture-only AFTER INSERT trigger on workout_rewards raisesP0001,
   after the RPC's user/class/workout/PR/quest/log changes have been reached. The auth helper catches
   the expected error and rolls back to its savepoint. Exact snapshots of users, user_classes,
   workouts, workout_exercises, workout_sets, exercise_prs, quest_instances, streaks, xp_logs,
   workout_rewards and user_achievements match pre-call state; quest remains active, credit0.
   Removing only the disposable trigger permits the same quest workout to complete for350 XP.
   This demonstrates SQL transaction rollback, not transport failure/crash recovery.
8. **Fixed Vietnam midnight controls:** legacy `completed_at` selects finished time; no system clock,
   SQL clock function or product function is replaced. At16:59:59Z local day27 accepts the day27
   quest; at17:00:00Z local day28 rejects the old day27/expired quest and accepts a day28 quest.
   Consecutive activity raises streak3->4; same-day activity leaves3. Original completion instants
   are preserved. Earned XP402/11/402/385 and quest states match the exact assertions below.
   Old-quest rejection jointly changes day and expiry; this is not single-variable isolation of
   the expiry guard. Its strict timestamp predicate is separately printed. The old quest stays
   `active` because complete_workout does not run sync's expiration maintenance.

### Finding reconciliation proposals (no register edits)

- **FND-DATA-001:** add conditional fixture evidence to the existing ID. Severity P1 remains a
  proposal; confidence is Confirmed for this precise synthetic tuple only. A real production cohort
  remains unknown. The true-flag and ordinary replay controls must remain alongside this evidence.
- **New P2 / Confirmed synthetic candidate:** final completion rejects CHECK-valid zero-rep timed
  sets. Cross-reference INTG004, whose hidden-positive-rep client root cause is different.
- **New P2 / Confirmed synthetic candidate:** switching away/back loses awarded class synergy XP.
  Do not merge into ARCH001's distinction between awards and derived maintenance.
- **New P2 / Confirmed synthetic candidate:** `Full Body` versus `full_body` causes A/D/E focus
  under-credit; coordinate with the catalog review rather than duplicate that finding.
- **C6 contract evidence:** reconcile with timed/catalog findings. Do not label real Flutter quest
  execution Confirmed or automatically create another overlapping finding.

Source anchors: progression migration223-230,264-280 (DATA001/replay);238 and catalog migration
359-367 (timed mismatch);259-265 versus294-303 (synergy recomputation);42,45-46,235,261 (focus);
205-212,245-251 and controller298-317 (quest);267-281 (rollback);233-245,254-255,268-271 (dates).

**NOT RUN:** real two-connection scheduling/lock waits, lost HTTP response, local Supabase gateway,
production cohort, real Flutter/SDK interaction, full DST/timezone matrix. A5 owner: supabase-specialist
with independent qa-reviewer; assert exactly one award under independently scheduled completion/
child-write transactions and correct lock-wait midnight semantics in an explicitly approved isolated
multi-connection environment. Flutter specialist owns actual generated-quest/default UI interaction.
No extra case or dependency/environment hunt was started to fill these gaps.

## 3. Complete run output

`NODE_EXIT=0` was emitted by the wrapper after Tee-Object, not stored in the hashed run log.

```text
SOURCE {"path":"tools/db-tests/bootstrap.sql","sha256":"fbfdd130ab2a2db10f9c5f850589fee746bee1b327e366c41179ca5931a7f250"}
SOURCE {"path":"supabase/migrations/20261026000100_baseline.sql","sha256":"e4e56bd1a1bb770fb28fec09ee5590302b89554d33f255b559499d1d8c21fc44"}
SOURCE {"path":"supabase/migrations/20261026000200_authoritative_progression.sql","sha256":"4b5f5682a25da4abbba8ca0aa3c4b6ed22ab92bc30021a9cef8b5f750b2dfc62"}
SOURCE {"path":"supabase/migrations/20261027000100_exercise_catalog_metadata.sql","sha256":"143b69653bb9b178fbc8b3fda6380ee1021be958a39d32f7bfac4f53727fbefb"}
SOURCE {"path":"supabase/seed.sql","sha256":"a96d9f5830b8cab1b99501725d1a9ff31fedb8a18900a463240ac246db392c68"}
SOURCE {"path":"supabase/seed_exercises.sql","sha256":"9af8382923d798fee30ccbe32986873440f5fd25588a0cea00acf408ad00c748"}
SOURCE {"path":"app/lib/features/workout/presentation/controllers/active_workout_controller.dart","sha256":"ea33a79b61171d62e12877ec9c31b0871e67d6cde44fd298394db95432aa5222"}
OBS C1/normal {"earned":10,"replayIdentical":true,"total":10,"rewards":1,"logs":1,"flag":true}
PASS C1/normal
OBS C1/unrewarded_recovery {"earned":10,"replayIdentical":true,"total":10,"rewards":1,"logs":1,"flag":true}
PASS C1/unrewarded_recovery
OBS C1/true_flag_prior_credit {"earned":0,"replayIdentical":true,"total":10,"rewards":0,"logs":1,"flag":true}
PASS C1/true_flag_prior_credit
OBS C2/DATA001 {"before":{"total":10,"rewards":0,"logs":1,"flag":false},"earnedAgain":10,"after":{"total":20,"rewards":1,"logs":2,"flag":true},"replayAddsThirdCredit":false,"productionCohortEstablished":false}
PASS C2/DATA001_conditional_prior_award
OBS C3/expected_rejection {"code":"22023","message":"Invalid workout measurements"}
OBS C3/timed {"persistedZeroRep30Seconds":1,"rejectionStateUnchanged":true,"repControlEarned":5}
PASS C3/timed_and_rep_control
OBS C4/synergy {"globalEarned":20,"originalClassCredit":21,"restoredClassXP":20,"retainedClassLog":21,"globalTotalUnchanged":20}
PASS C4/synergy_round_trip
OBS C5/A {"seedCategory":"Full Body","configuredFullBodyToken":"full_body","fullBodyGlobalXP":20,"fullBodyClassXP":8,"matchedControlSlug":"jumping-jack","matchedGlobalXP":20,"matchedClassXP":20}
PASS C5/category_focus_A
OBS C5/D {"seedCategory":"Full Body","configuredFullBodyToken":"full_body","fullBodyGlobalXP":20,"fullBodyClassXP":8,"matchedControlSlug":"jumping-jack","matchedGlobalXP":20,"matchedClassXP":20}
PASS C5/category_focus_D
OBS C5/E {"seedCategory":"Full Body","configuredFullBodyToken":"full_body","fullBodyGlobalXP":20,"fullBodyClassXP":8,"matchedControlSlug":"crunch","matchedGlobalXP":20,"matchedClassXP":20}
PASS C5/category_focus_E
OBS C6/expected_rejection {"code":"22023","message":"Invalid workout measurements"}
OBS C6/quest {"templateSelection":"fixture restricts daily templates to seeded full_body","targets":[{"slug":"ab-wheel-rollout","timed":true,"requiredReps":12,"defaultReps":0,"defaultSeconds":30,"requiredSets":3,"matchingSets":0},{"slug":"arnold-press","timed":false,"requiredReps":12,"defaultReps":12,"defaultSeconds":0,"requiredSets":3,"matchingSets":3},{"slug":"back-extension-hyperextension","timed":false,"requiredReps":12,"defaultReps":12,"defaultSeconds":0,"requiredSets":3,"matchingSets":3}],"clientDefaultsSourceInspected":true,"dartExecuted":false,"positiveRepControlIsQuest":true,"positiveRepControlEarned":450}
PASS C6/generated_timed_quest
OBS C7/injected_error {"code":"P0001","message":"A4 fixture late reward insert failure"}
OBS C7/atomicity {"comparedTables":["users","user_classes","workouts","workout_exercises","workout_sets","exercise_prs","quest_instances","streaks","xp_logs","workout_rewards","user_achievements"],"unchangedAfterError":true,"activeQuestAfterError":true,"noAwardAfterError":true,"uninstrumentedControlIsQuest":true,"uninstrumentedControlEarned":350}
PASS C7/late_error_atomicity
OBS C8/before_old_quest {"finishedUTC":"2026-10-27T16:59:59Z","localDay":"2026-10-27","questDay":"2026-10-27","strictlyUnexpired":true,"previousActivityDay":"2026-10-26","streak":4,"isQuest":true,"earnedXP":402,"questStatus":"completed","originalFinishedPreserved":true}
PASS C8/before_old_quest
OBS C8/at_old_expiry {"finishedUTC":"2026-10-27T17:00:00Z","localDay":"2026-10-28","questDay":"2026-10-27","strictlyUnexpired":false,"previousActivityDay":"2026-10-27","streak":4,"isQuest":false,"earnedXP":11,"questStatus":"active","originalFinishedPreserved":true}
PASS C8/at_old_expiry
OBS C8/at_new_day_quest {"finishedUTC":"2026-10-27T17:00:00Z","localDay":"2026-10-28","questDay":"2026-10-28","strictlyUnexpired":true,"previousActivityDay":"2026-10-27","streak":4,"isQuest":true,"earnedXP":402,"questStatus":"completed","originalFinishedPreserved":true}
PASS C8/at_new_day_quest
OBS C8/same_local_day {"finishedUTC":"2026-10-27T17:00:00Z","localDay":"2026-10-28","questDay":"2026-10-28","strictlyUnexpired":true,"previousActivityDay":"2026-10-28","streak":3,"isQuest":true,"earnedXP":385,"questStatus":"completed","originalFinishedPreserved":true}
PASS C8/same_local_day
SUMMARY {"status":"PASS","groups":8,"independentDatabases":15,"assertions":108,"fetchAttempts":0,"realTwoConnectionConcurrency":"NOT RUN","scope":"synthetic fixture assertions, not production correctness"}
```

## 4. Full final executed source — probe.mjs

```javascript
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import { pathToFileURL } from 'node:url';
import path from 'node:path';

const root = 'D:/Projects/gymlvl';
let fetchAttempts = 0;
globalThis.fetch = async () => { fetchAttempts++; throw new Error('A4 network fetch forbidden'); };
const { PGlite } = await import(pathToFileURL(path.join(root, 'tools/db-tests/node_modules/@electric-sql/pglite/dist/index.js')).href);
const { pgcrypto } = await import(pathToFileURL(path.join(root, 'tools/db-tests/node_modules/@electric-sql/pglite/dist/contrib/pgcrypto.js')).href);
const sqlPaths = [
  'tools/db-tests/bootstrap.sql',
  'supabase/migrations/20261026000100_baseline.sql',
  'supabase/migrations/20261026000200_authoritative_progression.sql',
  'supabase/migrations/20261027000100_exercise_catalog_metadata.sql',
  'supabase/seed.sql', 'supabase/seed_exercises.sql',
];
const clientPath = 'app/lib/features/workout/presentation/controllers/active_workout_controller.dart';
const sources = new Map();
for (const name of [...sqlPaths, clientPath]) {
  const bytes = await readFile(path.join(root, name));
  sources.set(name, bytes.toString('utf8'));
  console.log('SOURCE ' + JSON.stringify({ path: name, sha256: createHash('sha256').update(bytes).digest('hex') }));
}
const uid = 'a4444444-4444-4444-4444-444444444444';
let variants = 0;
let assertions = 0;
function eq(actual, expected) { assertions++; assert.deepStrictEqual(actual, expected); }
function ok(value) { assertions++; assert.ok(value); }
function out(label, data) { console.log('OBS ' + label + ' ' + JSON.stringify(data)); }
async function scalar(db, sql, values = []) { return (await db.query(sql, values)).rows[0].v; }
async function auth(db, fn) {
  await db.exec('SAVEPOINT auth_call; SET LOCAL ROLE authenticated;');
  try {
    const value = await fn();
    await db.exec('RESET ROLE; RELEASE SAVEPOINT auth_call;');
    return value;
  } catch (error) {
    await db.exec('ROLLBACK TO SAVEPOINT auth_call; RELEASE SAVEPOINT auth_call;');
    throw error;
  }
}
async function rpc(db, name, args = []) {
  const placeholders = args.map((_, i) => '$' + (i + 1)).join(',');
  return auth(db, () => scalar(db, `SELECT public.${name}(${placeholders}) AS v`, args));
}
async function errorCode(fn, code, label) {
  let observed;
  try { await fn(); } catch (error) { observed = { code: error.code, message: error.message }; }
  ok(observed);
  eq(observed.code, code);
  out(label, observed);
}
async function fresh(label, primary, secondary, fn) {
  const db = new PGlite({ extensions: { pgcrypto } });
  try {
    for (const name of sqlPaths) await db.exec(sources.get(name));
    eq(await scalar(db, 'SELECT count(*)::integer AS v FROM public.exercises'), 150);
    await db.exec('BEGIN;');
    await db.query("INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES($1,'a4-synthetic@example.test','{}')", [uid]);
    await db.query("SELECT set_config('request.jwt.claim.sub',$1,true),set_config('request.jwt.claims',$2,true)", [uid, JSON.stringify({ sub: uid, role: 'authenticated' })]);
    const profile = { environment: 'home', goals: ['hypertrophy'], experience_level: 'beginner', age: 25, gender: 'other', height_cm: 170, weight_kg: 65, weekly_gym_days: 0, weekly_home_days: 3, preferred_training_days: ['mon', 'wed', 'fri'], primary_class_id: primary, timezone: 'Asia/Ho_Chi_Minh' };
    if (secondary) profile.secondary_class_id = secondary;
    await rpc(db, 'initialize_user', [JSON.stringify(profile)]);
    await fn(db);
    await db.exec('ROLLBACK;');
    variants++;
    console.log('PASS ' + label);
  } finally { await db.close(); }
}
async function catalog(db, slug) {
  const rows = (await db.query('SELECT id,slug,name,category,force_type,movement_pattern FROM public.exercises WHERE slug=$1', [slug])).rows;
  eq(rows.length, 1);
  return rows[0];
}
async function addExercise(db, wid, slug, n = 2, reps = 10, seconds = 0) {
  const e = await catalog(db, slug);
  const we = await auth(db, () => scalar(db, 'INSERT INTO public.workout_exercises(workout_id,exercise_id) VALUES($1,$2) RETURNING id AS v', [wid, e.id]));
  await auth(db, () => db.query('INSERT INTO public.workout_sets(workout_exercise_id,set_number,reps,weight_kg,duration_seconds,is_completed) SELECT $1,n,$2,0,$3,true FROM generate_series(1,$4::integer)n', [we, reps, seconds, n]));
  return { e, we };
}
async function workout(db, slug = 'barbell-bench-press', n = 2, reps = 10, seconds = 0) {
  const w = await rpc(db, 'start_workout');
  const added = await addExercise(db, w.id, slug, n, reps, seconds);
  await rpc(db, 'begin_workout', [w.id]);
  await db.query("UPDATE public.workouts SET training_started_at=clock_timestamp()-interval '10 minutes' WHERE id=$1", [w.id]);
  return { wid: w.id, ...added };
}
async function legacy(db, wid, flag, finished = null) {
  await db.query("UPDATE public.workouts SET status='completed',is_xp_calculated=$2,completed_at=coalesce($3::timestamptz,now()-interval '1 day'),training_started_at=coalesce($3::timestamptz,now()-interval '1 day')-interval '10 minutes',started_at=coalesce($3::timestamptz,now()-interval '1 day')-interval '10 minutes' WHERE id=$1", [wid, flag, finished]);
}
async function priorCredit(db, wid) {
  await db.query('UPDATE public.users SET total_xp=10,current_level_xp=10 WHERE id=$1', [uid]);
  await db.query("INSERT INTO public.xp_logs(user_id,amount,source,source_id) VALUES($1,10,'workout',$2)", [uid, wid]);
}
async function metrics(db, wid) {
  return (await db.query("SELECT (SELECT total_xp FROM public.users WHERE id=$1) total,(SELECT count(*)::integer FROM public.workout_rewards WHERE workout_id=$2) rewards,(SELECT count(*)::integer FROM public.xp_logs WHERE source_id=$2::text AND source IN ('workout','quest')) logs,(SELECT is_xp_calculated FROM public.workouts WHERE id=$2) flag", [uid, wid])).rows[0];
}
async function snapshot(db) {
  const tables = ['users','user_classes','workouts','workout_exercises','workout_sets','exercise_prs','quest_instances','streaks','xp_logs','workout_rewards','user_achievements'];
  const state = {};
  for (const table of tables) state[table] = await scalar(db, `SELECT coalesce(jsonb_agg(j ORDER BY j::text),'[]'::jsonb) AS v FROM (SELECT to_jsonb(t) j FROM public.${table} t) s`);
  return state;
}
async function quest(db, exerciseId, day = null, expiry = null, created = null) {
  const qid = await scalar(db, "SELECT id AS v FROM public.quests WHERE category='push' LIMIT 1");
  const config = [{ exercise_id: exerciseId, sets: 2, reps: 10, weight_kg: 0 }];
  return scalar(db, "INSERT INTO public.quest_instances(user_id,quest_id,prescribed_config,quest_date,expires_at,created_at) VALUES($1,$2,$3::jsonb,coalesce($4::date,(now() AT TIME ZONE 'Asia/Ho_Chi_Minh')::date),coalesce($5::timestamptz,(((now() AT TIME ZONE 'Asia/Ho_Chi_Minh')::date+1)::timestamp AT TIME ZONE 'Asia/Ho_Chi_Minh')),coalesce($6::timestamptz,now())) RETURNING id AS v", [uid, qid, JSON.stringify(config), day, expiry, created]);
}

try {
  for (const mode of ['normal', 'unrewarded_recovery', 'true_flag_prior_credit']) {
    await fresh('C1/' + mode, 'B', null, async db => {
      const { wid } = await workout(db);
      if (mode !== 'normal') await legacy(db, wid, mode === 'true_flag_prior_credit');
      if (mode === 'true_flag_prior_credit') await priorCredit(db, wid);
      const first = await rpc(db, 'complete_workout', [wid]);
      const replay = await rpc(db, 'complete_workout', [wid]);
      eq(replay, first);
      const m = await metrics(db, wid);
      eq(m, { total: 10, rewards: mode === 'true_flag_prior_credit' ? 0 : 1, logs: 1, flag: true });
      eq(first.earnedXP, mode === 'true_flag_prior_credit' ? 0 : 10);
      out('C1/' + mode, { earned: first.earnedXP, replayIdentical: true, ...m });
    });
  }
  await fresh('C2/DATA001_conditional_prior_award', 'B', null, async db => {
    const { wid } = await workout(db);
    await legacy(db, wid, false);
    await priorCredit(db, wid);
    const before = await metrics(db, wid);
    eq(before, { total: 10, rewards: 0, logs: 1, flag: false });
    const reward = await rpc(db, 'complete_workout', [wid]);
    eq(reward.earnedXP, 10);
    const after = await metrics(db, wid);
    eq(after, { total: 20, rewards: 1, logs: 2, flag: true });
    eq(await rpc(db, 'complete_workout', [wid]), reward);
    eq(await metrics(db, wid), after);
    out('C2/DATA001', { before, earnedAgain: reward.earnedXP, after, replayAddsThirdCredit: false, productionCohortEstablished: false });
  });
  await fresh('C3/timed_and_rep_control', 'B', null, async db => {
    const { wid, we } = await workout(db, 'plank', 1, 0, 30);
    const persisted = await scalar(db, 'SELECT count(*)::integer AS v FROM public.workout_sets WHERE workout_exercise_id=$1 AND reps=0 AND duration_seconds=30 AND is_completed', [we]);
    eq(persisted, 1);
    const before = await snapshot(db);
    await errorCode(() => rpc(db, 'complete_workout', [wid]), '22023', 'C3/expected_rejection');
    eq(await snapshot(db), before);
    eq(await metrics(db, wid), { total: 0, rewards: 0, logs: 0, flag: false });
    await auth(db, () => db.query('UPDATE public.workout_sets SET reps=1 WHERE workout_exercise_id=$1', [we]));
    const control = await rpc(db, 'complete_workout', [wid]);
    eq(control.earnedXP, 5);
    out('C3/timed', { persistedZeroRep30Seconds: persisted, rejectionStateUnchanged: true, repControlEarned: control.earnedXP });
  });
  await fresh('C4/synergy_round_trip', 'B', 'C', async db => {
    const { wid } = await workout(db, 'barbell-bench-press', 4);
    const reward = await rpc(db, 'complete_workout', [wid]);
    eq(reward.earnedXP, 20);
    const initial = reward.classResults.find(c => c.classId === 'C').newTotalXP;
    eq(initial, 21);
    await rpc(db, 'switch_class', ['A', 'secondary']);
    const back = await rpc(db, 'switch_class', ['C', 'secondary']);
    eq(back.xp_granted, 20);
    eq(await scalar(db, "SELECT sum(class_xp_earned)::integer AS v FROM public.xp_logs WHERE class_id='C'"), 21);
    eq((await metrics(db, wid)).total, 20);
    out('C4/synergy', { globalEarned: reward.earnedXP, originalClassCredit: initial, restoredClassXP: back.xp_granted, retainedClassLog: 21, globalTotalUnchanged: 20 });
  });
  for (const classId of ['A', 'D', 'E']) {
    await fresh('C5/category_focus_' + classId, classId, null, async db => {
      const full = await workout(db, 'burpee', 4);
      eq(full.e.category, 'Full Body');
      const r1 = await rpc(db, 'complete_workout', [full.wid]);
      const controlSlug = classId === 'E' ? 'crunch' : 'jumping-jack';
      const control = await workout(db, controlSlug, 4);
      const r2 = await rpc(db, 'complete_workout', [control.wid]);
      eq([r1.earnedXP, r2.earnedXP], [20, 20]);
      eq([r1.classResults[0].xpEarned, r2.classResults[0].xpEarned], [8, 20]);
      const focus = await scalar(db, 'SELECT focus_categories AS v FROM public.class_definitions WHERE class_id=$1', [classId]);
      ok(focus.includes('full_body'));
      out('C5/' + classId, { seedCategory: full.e.category, configuredFullBodyToken: 'full_body', fullBodyGlobalXP: r1.earnedXP, fullBodyClassXP: r1.classResults[0].xpEarned, matchedControlSlug: controlSlug, matchedGlobalXP: r2.earnedXP, matchedClassXP: r2.classResults[0].xpEarned });
    });
  }
  await fresh('C6/generated_timed_quest', 'B', null, async db => {
    // Fixture-only deterministic template selection; exercise rows are untouched.
    await db.exec("UPDATE public.quests SET type='a4_fixture_unused' WHERE category<>'full_body';");
    const generated = await rpc(db, 'sync_daily_data');
    const targets = generated.quest.prescribed_config;
    eq(targets.length, 3);
    const client = sources.get(clientPath);
    ok(client.includes("exercise.movementPattern == 'carry'"));
    ok(/final defaultReps = isTimed\s*\? 0/.test(client));
    ok(client.includes('final defaultDuration = isTimed ? 30 : 0;'));
    const w = await rpc(db, 'start_workout');
    const observed = [];
    let timedCount = 0;
    for (const t of targets) {
      const e = (await db.query('SELECT id,slug,name,category,force_type,movement_pattern FROM public.exercises WHERE id=$1', [t.exercise_id])).rows[0];
      ok(e);
      const timed = e.force_type?.toLowerCase() === 'static' || e.movement_pattern === 'carry' || e.category.toLowerCase() === 'cardio' || e.slug.includes('plank');
      const reps = timed ? 0 : t.reps;
      const duration = timed ? 30 : 0;
      const { we } = await addExercise(db, w.id, e.slug, t.sets, reps, duration);
      const matches = await scalar(db, 'SELECT count(*)::integer AS v FROM public.workout_sets WHERE workout_exercise_id=$1 AND is_completed AND reps >= $2 AND weight_kg >= $3', [we, t.reps, t.weight_kg]);
      if (timed) { timedCount++; eq(t.reps, 12); eq(matches, 0); }
      observed.push({ slug: e.slug, timed, requiredReps: t.reps, defaultReps: reps, defaultSeconds: duration, requiredSets: t.sets, matchingSets: matches });
    }
    ok(timedCount > 0);
    await rpc(db, 'begin_workout', [w.id]);
    await db.query("UPDATE public.workouts SET training_started_at=clock_timestamp()-interval '10 minutes' WHERE id=$1", [w.id]);
    await errorCode(() => rpc(db, 'complete_workout', [w.id]), '22023', 'C6/expected_rejection');
    eq((await metrics(db, w.id)).total, 0);
    eq(await scalar(db, 'SELECT status AS v FROM public.quest_instances WHERE id=$1', [generated.quest.id]), 'active');
    // Synthetic SQL positive-rep control, not an executed Flutter interaction.
    await auth(db, () => db.exec('UPDATE public.workout_sets SET reps=12 WHERE duration_seconds=30;'));
    const control = await rpc(db, 'complete_workout', [w.id]);
    eq(control.isQuest, true);
    eq(control.earnedXP, 450);
    out('C6/quest', { templateSelection: 'fixture restricts daily templates to seeded full_body', targets: observed, clientDefaultsSourceInspected: true, dartExecuted: false, positiveRepControlIsQuest: control.isQuest, positiveRepControlEarned: control.earnedXP });
  });
  await fresh('C7/late_error_atomicity', 'B', 'C', async db => {
    const { wid, e } = await workout(db);
    const qid = await quest(db, e.id);
    await db.exec("CREATE FUNCTION pg_temp.a4_fail_reward() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN RAISE EXCEPTION 'A4 fixture late reward insert failure' USING ERRCODE='P0001'; END $$; CREATE TRIGGER a4_fixture_fail_reward AFTER INSERT ON public.workout_rewards FOR EACH ROW EXECUTE FUNCTION pg_temp.a4_fail_reward();");
    const before = await snapshot(db);
    await errorCode(() => rpc(db, 'complete_workout', [wid]), 'P0001', 'C7/injected_error');
    eq(await snapshot(db), before);
    eq((await metrics(db, wid)).total, 0);
    eq(await scalar(db, 'SELECT status AS v FROM public.quest_instances WHERE id=$1', [qid]), 'active');
    // Remove only this disposable instrumentation; the product RPC is unchanged.
    await db.exec('DROP TRIGGER a4_fixture_fail_reward ON public.workout_rewards;');
    const control = await rpc(db, 'complete_workout', [wid]);
    eq(control.isQuest, true);
    eq(control.earnedXP, 350);
    out('C7/atomicity', { comparedTables: Object.keys(before), unchangedAfterError: true, activeQuestAfterError: true, noAwardAfterError: true, uninstrumentedControlIsQuest: control.isQuest, uninstrumentedControlEarned: control.earnedXP });
  });
  const boundaryCases = [
    ['before_old_quest', '2026-10-27T16:59:59Z', '2026-10-27', '2026-10-27T17:00:00Z', '2026-10-26', 4, true, 402],
    ['at_old_expiry', '2026-10-27T17:00:00Z', '2026-10-27', '2026-10-27T17:00:00Z', '2026-10-27', 4, false, 11],
    ['at_new_day_quest', '2026-10-27T17:00:00Z', '2026-10-28', '2026-10-28T17:00:00Z', '2026-10-27', 4, true, 402],
    ['same_local_day', '2026-10-27T17:00:00Z', '2026-10-28', '2026-10-28T17:00:00Z', '2026-10-28', 3, true, 385],
  ];
  for (const [name, finished, qday, expiry, previous, streak, isQuest, earned] of boundaryCases) {
    await fresh('C8/' + name, 'B', null, async db => {
      const { wid, e } = await workout(db);
      await legacy(db, wid, false, finished);
      const qid = await quest(db, e.id, qday, expiry, '2026-10-26T17:00:00Z');
      await db.query('UPDATE public.streaks SET current_streak=3,longest_streak=3,last_activity_date=$1::date WHERE user_id=$2', [previous, uid]);
      const clock = (await db.query("SELECT $1::timestamptz AT TIME ZONE 'Asia/Ho_Chi_Minh' AS local_finished,($1::timestamptz AT TIME ZONE 'Asia/Ho_Chi_Minh')::date::text AS local_day,$2::timestamptz > $1::timestamptz AS unexpired", [finished, expiry])).rows[0];
      const result = await rpc(db, 'complete_workout', [wid]);
      eq([result.streak, result.isQuest, result.earnedXP], [streak, isQuest, earned]);
      const storedFinished = await scalar(db, 'SELECT extract(epoch FROM completed_at)::double precision AS v FROM public.workouts WHERE id=$1', [wid]);
      eq(storedFinished, Date.parse(finished) / 1000);
      const status = await scalar(db, 'SELECT status AS v FROM public.quest_instances WHERE id=$1', [qid]);
      eq(status, isQuest ? 'completed' : 'active');
      out('C8/' + name, { finishedUTC: finished, localDay: clock.local_day, questDay: qday, strictlyUnexpired: clock.unexpired, previousActivityDay: previous, streak: result.streak, isQuest: result.isQuest, earnedXP: result.earnedXP, questStatus: status, originalFinishedPreserved: true });
    });
  }
  eq(fetchAttempts, 0);
  console.log('SUMMARY ' + JSON.stringify({ status: 'PASS', groups: 8, independentDatabases: variants, assertions, fetchAttempts, realTwoConnectionConcurrency: 'NOT RUN', scope: 'synthetic fixture assertions, not production correctness' }));
} catch (error) {
  console.error('FAIL ' + JSON.stringify({ name: error.name, code: error.code, message: error.message, stack: error.stack }));
  process.exitCode = 1;
}
```

## 5. Git preservation and artifact checks

Before creating this evidence file, `git diff --check` exited0 with no whitespace error, only the
existing four tracked documents' LF/CRLF warnings. `git diff --stat` reported four files changed,
48 insertions(+); the phase file was untracked and therefore excluded from that stat. Initial status:

```text
 M docs/audit/SESSION_HANDOFF.md
 M docs/planning/CHANGELOG_AI.md
 M docs/planning/SESSION_HANDOFF.md
 M docs/planning/TASK_BOARD.md
?? docs/audit/phases/A4_WORKOUT_PROGRESSION.md
```

Only this new evidence document is written by this delegation inside the repository. No commit,
push, tag, permanent test or product change is made. Whole-stage acceptance and independent QA
belong to the orchestrator.

Final artifact validation command, from the repository root (exit0):

```powershell
@'
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { createHash } from 'node:crypto';
const base = 'C:/Users/tuand/AppData/Local/Temp/opencode/gymlvl-a4-sql-20261028/';
const md = await readFile('docs/audit/phases/A4_SQL_EVIDENCE.md', 'utf8');
const source = md.match(/## 4\. Full final executed source[^\n]*\n\n```javascript\n([\s\S]*?)```/)[1];
const actual = await readFile(base + 'probe.mjs', 'utf8');
assert.equal(source, actual);
const bytes = await readFile(base + 'run-01.log');
const raw = bytes[0] === 255 && bytes[1] === 254 ? bytes.toString('utf16le') : bytes.toString('utf8');
const log = raw.replace(/^\uFEFF/, '').replace(/\r\n/g, '\n');
const retained = md.match(/## 3\. Complete run output[\s\S]*?```text\n([\s\S]*?)```/)[1];
assert.equal(retained, log);
assert.equal(log.match(/^PASS /gm).length, 15);
const summary = JSON.parse(log.match(/^SUMMARY (.+)$/m)[1]);
assert.equal(summary.assertions, 108);
assert.equal(summary.fetchAttempts, 0);
for (const line of log.match(/^SOURCE .+$/gm)) {
  const entry = JSON.parse(line.substring(7));
  const now = createHash('sha256').update(await readFile(entry.path)).digest('hex');
  assert.equal(now, entry.sha256);
}
assert.equal(/[\t ]+$/m.test(md), false);
console.log('A4_ARTIFACT_CHECK source_exact=true output_exact=true variants=15 assertions=108 fetch_attempts=0 source_hashes_match=7 trailing_whitespace=false');
console.log('SOURCE_SHA256 ' + createHash('sha256').update(actual).digest('hex'));
'@ | node --input-type=module
```

Observed output:

```text
A4_ARTIFACT_CHECK source_exact=true output_exact=true variants=15 assertions=108 fetch_attempts=0 source_hashes_match=7 trailing_whitespace=false
SOURCE_SHA256 37d3ecda9aa9f311b1fd15a9d590c485d90de62ffae5eb9fc1b1ad278ac4e600
ARTIFACT_CHECK_EXIT=0
DIFF_CHECK_EXIT=0
```

`git diff --check` exited0, with the same four existing LF/CRLF warnings and no whitespace errors.
This command excludes untracked documents; the Node check explicitly checks this new document for
trailing whitespace. `git diff --stat` remains four tracked files /48 insertions(+). Final
`git status --porcelain=v1` shows exactly the original five paths plus this delegated evidence file:

```text
 M docs/audit/SESSION_HANDOFF.md
 M docs/planning/CHANGELOG_AI.md
 M docs/planning/SESSION_HANDOFF.md
 M docs/planning/TASK_BOARD.md
?? docs/audit/phases/A4_SQL_EVIDENCE.md
?? docs/audit/phases/A4_WORKOUT_PROGRESSION.md
```

`git rev-parse HEAD` remains `c95cb4873455b39f3ab2b6c0f929b43d87f4d8d3`. These are current-session
executed checks, not carried results. No pre-existing dirty file was modified by this delegation.
