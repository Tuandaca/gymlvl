# A3 — retained synthetic PostgreSQL ownership and ACL evidence

**Baseline:** main f877e40987423f3804fe0d2887c44d19f3423aff, 2026-10-28.
**Scope:** actual installed PGlite PostgreSQL17.5, synthetic A/B/anon roles and claims, independent
in-memory databases. No real account/production access, secret/env read, network, install or source
change. Existing migrations/seeds initialize only these disposable databases. No reward arithmetic
or legacy double-award fixture. Catalog ID selected from existing seed, never invented.

## Procedure and outcomes

Save the exact source below in a new unused external task directory as `audit-probe.mjs`; adjust
only `root` for a different checkout with already-installed tools/db-tests dependencies. Do not
overwrite existing user files. The actual directory was
`C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a3-sql-20261028`, verified absent before creation.
The source and original UTF-16 PowerShell `output.log` are retained there, not deleted. This document
is the repository-readable evidence copy for QA; no external-directory permission was widened.

Commands, from repository root (all source hashes logged by each invocation):

```powershell
node 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a3-sql-20261028\audit-probe.mjs'
# Original invocation: FAIL / exit 1. Fresh-boundary assertions pass, then named-role
# column-grant survival hypothesis fails. This failure is deliberately retained.
node 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a3-sql-20261028\audit-probe.mjs' --remaining-public-cases
# Independent PUBLIC cases: PASS / exit 0, 2 DBs /14 assertions; does not replace exit 1.
node 'C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-a3-sql-20261028\audit-probe.mjs' --named-column-control
# Diagnostic denial control: PASS / exit 0, 1 DB /4 assertions; original assertion unchanged.
```

Specialist ran all three invocations; orchestrator independently reran both explicit variants, exit0.
Default invocation must still fail at the disproved assertion: do not present this harness as an
all-green suite or delete the original contrary evidence. Fresh and diagnostic negative controls
deny own total_xp UPDATE; PUBLIC column grant is a deliberately injected pre-existing condition.
Its observed effect does not establish any deployed ACL or production exploit.

The retained187-line version includes continuation/diagnostic switches added after the original
failure; line offsets in the original stack therefore differ. The failed expectation remains in
the default branch unchanged. The document block is byte-equal after line-ending/final-newline
normalization to the externally retained source used for the successful variant reruns, verified
by orchestrator (`187` lines; normalized SHA256
`5419412f43eee5f20afc8c64c001e63a0fafd96bd92dfe9857ef19b881c20eb2`).
Do not claim that this hash describes an unmodified initial pre-diagnostic script version.

## Exact retained source

```javascript
// Retained A3 audit-only probe. No repository writes, network, real credentials, or live DB.
// Synthetic conditional ACL observations are not claims about deployed privileges.
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import { pathToFileURL } from 'node:url';
import path from 'node:path';

globalThis.fetch = () => { throw new Error('Network is prohibited in this isolated probe'); };
const root = 'D:\\Projects\\gymlvl';
const installed = path.join(root, 'tools/db-tests/node_modules/@electric-sql/pglite/dist');
const { PGlite } = await import(pathToFileURL(path.join(installed, 'index.js')).href);
const { pgcrypto } = await import(pathToFileURL(path.join(installed, 'contrib/pgcrypto.js')).href);
const files = [
  'tools/db-tests/bootstrap.sql',
  'supabase/migrations/20261026000100_baseline.sql',
  'supabase/migrations/20261026000200_authoritative_progression.sql',
  'supabase/migrations/20261027000100_exercise_catalog_metadata.sql',
  'supabase/seed.sql',
  'supabase/seed_exercises.sql',
];
const sources = [];
for (const file of files) {
  const bytes = await readFile(path.join(root, file));
  sources.push(bytes.toString('utf8'));
  console.log(`SOURCE ${file} SHA256=${createHash('sha256').update(bytes).digest('hex')}`);
}
const A = '11111111-1111-4111-8111-111111111111';
const B = '22222222-2222-4222-8222-222222222222';
let checks = 0;
let databases = 0;
function pass(label, actual, expected) {
  assert.deepEqual(actual, expected, label);
  checks++;
  console.log(`PASS ${label}: ${JSON.stringify(actual)}`);
}
async function scalar(db, sql, args = []) {
  const result = await db.query(sql, args);
  return Object.values(result.rows[0])[0];
}
async function denied(db, label, sql, args = [], expected = '42501') {
  let caught;
  try { await db.query(sql, args); } catch (error) { caught = error; }
  assert.ok(caught, `${label}: expected rejection, statement unexpectedly succeeded`);
  pass(`${label} SQLSTATE`, caught.code, expected);
}
async function role(db, uid, name = 'authenticated') {
  await db.exec('RESET ROLE');
  await db.query("SELECT set_config('request.jwt.claim.sub',$1,false), set_config('request.jwt.claims',$2,false), set_config('request.jwt.claim.role',$3,false)",
    [uid, JSON.stringify(uid ? { sub: uid, role: name } : { role: name }), name]);
  await db.exec(`SET ROLE ${name}`);
  assert.equal(await scalar(db, 'SELECT current_user'), name);
}
async function ownXp(db, label, writable) {
  await role(db, A);
  pass(`${label} authenticated effective UPDATE(total_xp)`,
    await scalar(db, "SELECT has_column_privilege(current_user,'public.users','total_xp','UPDATE')"), writable);
  if (writable) {
    pass(`${label} own XP write RETURNING`, await scalar(db,
      'UPDATE public.users SET total_xp=777 WHERE id=$1 RETURNING total_xp', [A]), 777);
    pass(`${label} own persisted XP`, await scalar(db, 'SELECT total_xp FROM public.users WHERE id=$1', [A]), 777);
    pass(`${label} other user still hidden`, await scalar(db, 'SELECT count(*)::int FROM public.users WHERE id=$1', [B]), 0);
  } else {
    await denied(db, `${label} own XP write denied`, 'UPDATE public.users SET total_xp=777 WHERE id=$1', [A]);
    pass(`${label} own XP unchanged`, await scalar(db, 'SELECT total_xp FROM public.users WHERE id=$1', [A]), 0);
  }
}
async function runCase(label, injectedGrant, verify) {
  const db = new PGlite({ extensions: { pgcrypto } });
  databases++;
  console.log(`CASE ${label} BEGIN (new independent in-memory database)`);
  try {
    await db.exec(sources[0]);
    await db.exec(sources[1]);
    if (injectedGrant) {
      console.log(`SYNTHETIC PREEXISTING ACL after baseline, before progression: ${injectedGrant}`);
      await db.exec(injectedGrant);
    }
    for (const sql of sources.slice(2)) await db.exec(sql);
    console.log(`POSTGRES ${await scalar(db, 'SHOW server_version')}`);
    pass(`${label} catalog seed count`, await scalar(db, 'SELECT count(*)::int FROM public.exercises'), 150);
    await db.query(`INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES
      ($1,'a3-athlete-a@example.test','{}'),($2,'a3-athlete-b@example.test','{}')`, [A, B]);
    await verify(db);
    console.log(`CASE ${label} COMPLETE`);
  } finally {
    await db.close();
    console.log(`CLOSED ${label} in-memory database`);
  }
}
async function boundaries(db) {
  const profile = JSON.stringify({ environment: 'gym', goals: ['hypertrophy'], experience_level: 'beginner',
    age: 25, gender: 'other', height_cm: 170, weight_kg: 65, weekly_gym_days: 3,
    weekly_home_days: 0, preferred_training_days: ['mon', 'wed', 'fri'], primary_class_id: 'B' });
  await role(db, A);
  await db.query('SELECT public.initialize_user($1::jsonb)', [profile]);
  const aw = await scalar(db, 'SELECT public.start_workout()');
  const eid = await scalar(db, 'SELECT id FROM public.exercises ORDER BY id LIMIT 1');
  pass('fresh selected exercise exists in seeded catalog', await scalar(db,
    'SELECT count(*)::int FROM public.exercises WHERE id=$1', [eid]), 1);
  console.log(`CATALOG EXISTING exercise_id=${eid}`);
  const ae = await scalar(db, 'INSERT INTO public.workout_exercises(workout_id,exercise_id) VALUES($1,$2) RETURNING id', [aw.id, eid]);
  const aset = await scalar(db, 'INSERT INTO public.workout_sets(workout_exercise_id,reps,weight_kg,is_completed) VALUES($1,10,20,false) RETURNING id', [ae]);
  await db.query('SELECT public.begin_workout($1)', [aw.id]);
  pass('fresh A sees own workout', await scalar(db, 'SELECT count(*)::int FROM public.workouts WHERE id=$1', [aw.id]), 1);
  pass('fresh A sees own set', await scalar(db, 'SELECT count(*)::int FROM public.workout_sets WHERE id=$1', [aset]), 1);

  await role(db, B);
  pass('fresh B cannot SELECT A workout', await scalar(db, 'SELECT count(*)::int FROM public.workouts WHERE id=$1', [aw.id]), 0);
  pass('fresh B cannot SELECT A set', await scalar(db, 'SELECT count(*)::int FROM public.workout_sets WHERE id=$1', [aset]), 0);
  for (const [name, sql] of [
    ['begin', 'SELECT public.begin_workout($1)'],
    ['pause', 'SELECT public.set_workout_paused($1,true)'],
    ['cancel', 'SELECT public.cancel_workout($1)'],
    ['complete', 'SELECT public.complete_workout($1)'],
  ]) await denied(db, `fresh B foreign ${name} denied`, sql, [aw.id]);
  await denied(db, 'fresh B exercise insert into A workout denied',
    'INSERT INTO public.workout_exercises(workout_id,exercise_id) VALUES($1,$2)', [aw.id, eid]);
  await denied(db, 'fresh B set insert into A exercise denied',
    'INSERT INTO public.workout_sets(workout_exercise_id,reps) VALUES($1,10)', [ae]);

  await db.query('SELECT public.initialize_user($1::jsonb)', [profile]);
  const bw = await scalar(db, 'SELECT public.start_workout()');
  const be = await scalar(db, 'INSERT INTO public.workout_exercises(workout_id,exercise_id) VALUES($1,$2) RETURNING id', [bw.id, eid]);
  const bset = await scalar(db, 'INSERT INTO public.workout_sets(workout_exercise_id,reps) VALUES($1,10) RETURNING id', [be]);
  await denied(db, 'fresh B own exercise reparent to A workout denied',
    'UPDATE public.workout_exercises SET workout_id=$1 WHERE id=$2', [aw.id, be], '22023');
  await denied(db, 'fresh B own set reparent to A exercise denied',
    'UPDATE public.workout_sets SET workout_exercise_id=$1 WHERE id=$2', [ae, bset], '22023');
  const update = await db.query('UPDATE public.workout_sets SET reps=99 WHERE id=$1 RETURNING id', [aset]);
  pass('fresh B update of hidden A set affects zero rows', update.rows.length, 0);
  pass('fresh B exercise parent unchanged', await scalar(db, 'SELECT workout_id FROM public.workout_exercises WHERE id=$1', [be]), bw.id);
  pass('fresh B set parent unchanged', await scalar(db, 'SELECT workout_exercise_id FROM public.workout_sets WHERE id=$1', [bset]), be);

  await role(db, A);
  pass('fresh A set unchanged after B attempts', await scalar(db, 'SELECT reps FROM public.workout_sets WHERE id=$1', [aset]), 10);
  pass('fresh foreign complete made no award rows', await scalar(db, 'SELECT count(*)::int FROM public.workout_rewards'), 0);
  pass('fresh A workout remains active', await scalar(db, 'SELECT status FROM public.workouts WHERE id=$1', [aw.id]), 'active');
  await role(db, '', 'anon');
  for (const table of ['users', 'workouts', 'workout_sets', 'workout_rewards']) {
    await denied(db, `fresh anonymous ${table} SELECT denied`, `SELECT * FROM public.${table}`);
  }
}

try {
  if (process.argv.includes('--named-column-control')) {
    console.log('DIAGNOSTIC CONTROL: test denial after the original named-column survival hypothesis failed; original assertion and failure remain retained.');
    await runCase('named authenticated column grant diagnostic', 'GRANT UPDATE(total_xp) ON public.users TO authenticated;',
      db => ownXp(db, 'named-column-diagnostic', false));
  } else {
  // Preserve the original failed authenticated-column assertion. This explicit
  // continuation mode runs only the independent PUBLIC cases after that failure.
  if (!process.argv.includes('--remaining-public-cases')) {
  await runCase('fresh-tip negative control and A/B boundaries', '', async db => {
    await ownXp(db, 'fresh', false);
    await boundaries(db);
  });
  await runCase('legacy authenticated column grant', 'GRANT UPDATE(total_xp) ON public.users TO authenticated;',
    db => ownXp(db, 'legacy-auth-column', true));
  } else {
    console.log('CONTINUATION ONLY: original authenticated-column hypothesis failed (false !== true); retained in output.log. No rerun or suppression of that failed assertion.');
  }
  await runCase('legacy PUBLIC column grant', 'GRANT UPDATE(total_xp) ON public.users TO PUBLIC;', async db => {
    await ownXp(db, 'legacy-public-column', true);
    await role(db, '', 'anon');
    pass('legacy-public-column anon inherits UPDATE privilege', await scalar(db,
      "SELECT has_column_privilege(current_user,'public.users','total_xp','UPDATE')"), true);
    await denied(db, 'legacy-public-column anon cannot SELECT users', 'SELECT * FROM public.users');
  });
  await runCase('legacy PUBLIC table SELECT grant', 'GRANT SELECT ON public.users TO PUBLIC;', async db => {
    await ownXp(db, 'legacy-public-select', false);
    await role(db, '', 'anon');
    pass('legacy-public-select anon inherits SELECT privilege', await scalar(db,
      "SELECT has_table_privilege(current_user,'public.users','SELECT')"), true);
    pass('legacy-public-select anon sees zero rows because RLS still applies', await scalar(db, 'SELECT count(*)::int FROM public.users'), 0);
    await role(db, B);
    pass('legacy-public-select B still cannot SELECT A', await scalar(db, 'SELECT count(*)::int FROM public.users WHERE id=$1', [A]), 0);
  });
  }
  console.log(`PASS THIS INVOCATION databases=${databases} assertions=${checks} failures=0`);
  if (process.argv.includes('--remaining-public-cases') || process.argv.includes('--named-column-control')) console.log('OVERALL ORIGINAL HYPOTHESIS: FAIL; this continuation does not replace NODE_EXIT=1 from the original invocation.');
  console.log('LIMITATION: conditional synthetic ACL inheritance reproduced; fresh control denied XP writes. No production ACL/cohort/gateway/concurrency claim; no reward arithmetic tested.');
} catch (error) {
  console.error(`FAIL ${error.stack ?? error}`);
  if (error.code) console.error(`SQLSTATE ${error.code}`);
  process.exitCode = 1;
}
```

## Complete assertion output by variant (source-hash lines/stack wrapper omitted only)

Default invocation, FAIL/exit1. Random generated parent IDs below are synthetic observations, not
stable expected UUIDs; source asserts equality to the returned parent, not these fixed values.

```text
CASE fresh-tip negative control and A/B boundaries BEGIN (new independent in-memory database)
POSTGRES 17.5
PASS fresh-tip negative control and A/B boundaries catalog seed count: 150
PASS fresh authenticated effective UPDATE(total_xp): false
PASS fresh own XP write denied SQLSTATE: "42501"
PASS fresh own XP unchanged: 0
PASS fresh selected exercise exists in seeded catalog: 1
CATALOG EXISTING exercise_id=0156c14b-c03f-44cc-94c0-c2b1bc1a6caf
PASS fresh A sees own workout: 1
PASS fresh A sees own set: 1
PASS fresh B cannot SELECT A workout: 0
PASS fresh B cannot SELECT A set: 0
PASS fresh B foreign begin denied SQLSTATE: "42501"
PASS fresh B foreign pause denied SQLSTATE: "42501"
PASS fresh B foreign cancel denied SQLSTATE: "42501"
PASS fresh B foreign complete denied SQLSTATE: "42501"
PASS fresh B exercise insert into A workout denied SQLSTATE: "42501"
PASS fresh B set insert into A exercise denied SQLSTATE: "42501"
PASS fresh B own exercise reparent to A workout denied SQLSTATE: "22023"
PASS fresh B own set reparent to A exercise denied SQLSTATE: "22023"
PASS fresh B update of hidden A set affects zero rows: 0
PASS fresh B exercise parent unchanged: "b37a499b-76f7-434e-8a2f-adc7e1fb811b"
PASS fresh B set parent unchanged: "46838752-71e8-492f-9c80-05b5d733bec5"
PASS fresh A set unchanged after B attempts: 10
PASS fresh foreign complete made no award rows: 0
PASS fresh A workout remains active: "active"
PASS fresh anonymous users SELECT denied SQLSTATE: "42501"
PASS fresh anonymous workouts SELECT denied SQLSTATE: "42501"
PASS fresh anonymous workout_sets SELECT denied SQLSTATE: "42501"
PASS fresh anonymous workout_rewards SELECT denied SQLSTATE: "42501"
CASE fresh-tip negative control and A/B boundaries COMPLETE
CLOSED fresh-tip negative control and A/B boundaries in-memory database
CASE legacy authenticated column grant BEGIN (new independent in-memory database)
SYNTHETIC PREEXISTING ACL after baseline, before progression: GRANT UPDATE(total_xp) ON public.users TO authenticated;
POSTGRES 17.5
PASS legacy authenticated column grant catalog seed count: 150
CLOSED legacy authenticated column grant in-memory database
FAIL AssertionError [ERR_ASSERTION]: legacy-auth-column authenticated effective UPDATE(total_xp)
false !== true
SQLSTATE ERR_ASSERTION
NODE_EXIT=1
```

PUBLIC continuation, PASS/exit0; original failure retained:

```text
CONTINUATION ONLY: original authenticated-column hypothesis failed (false !== true); retained in output.log. No rerun or suppression of that failed assertion.
CASE legacy PUBLIC column grant BEGIN (new independent in-memory database)
SYNTHETIC PREEXISTING ACL after baseline, before progression: GRANT UPDATE(total_xp) ON public.users TO PUBLIC;
POSTGRES 17.5
PASS legacy PUBLIC column grant catalog seed count: 150
PASS legacy-public-column authenticated effective UPDATE(total_xp): true
PASS legacy-public-column own XP write RETURNING: 777
PASS legacy-public-column own persisted XP: 777
PASS legacy-public-column other user still hidden: 0
PASS legacy-public-column anon inherits UPDATE privilege: true
PASS legacy-public-column anon cannot SELECT users SQLSTATE: "42501"
CASE legacy PUBLIC column grant COMPLETE
CLOSED legacy PUBLIC column grant in-memory database
CASE legacy PUBLIC table SELECT grant BEGIN (new independent in-memory database)
SYNTHETIC PREEXISTING ACL after baseline, before progression: GRANT SELECT ON public.users TO PUBLIC;
POSTGRES 17.5
PASS legacy PUBLIC table SELECT grant catalog seed count: 150
PASS legacy-public-select authenticated effective UPDATE(total_xp): false
PASS legacy-public-select own XP write denied SQLSTATE: "42501"
PASS legacy-public-select own XP unchanged: 0
PASS legacy-public-select anon inherits SELECT privilege: true
PASS legacy-public-select anon sees zero rows because RLS still applies: 0
PASS legacy-public-select B still cannot SELECT A: 0
CASE legacy PUBLIC table SELECT grant COMPLETE
CLOSED legacy PUBLIC table SELECT grant in-memory database
PASS THIS INVOCATION databases=2 assertions=14 failures=0
OVERALL ORIGINAL HYPOTHESIS: FAIL; this continuation does not replace NODE_EXIT=1 from the original invocation.
LIMITATION: conditional synthetic ACL inheritance reproduced; fresh control denied XP writes. No production ACL/cohort/gateway/concurrency claim; no reward arithmetic tested.
NODE_EXIT=0
```

Named-role control, PASS/exit0:

```text
DIAGNOSTIC CONTROL: test denial after the original named-column survival hypothesis failed; original assertion and failure remain retained.
CASE named authenticated column grant diagnostic BEGIN (new independent in-memory database)
SYNTHETIC PREEXISTING ACL after baseline, before progression: GRANT UPDATE(total_xp) ON public.users TO authenticated;
POSTGRES 17.5
PASS named authenticated column grant diagnostic catalog seed count: 150
PASS named-column-diagnostic authenticated effective UPDATE(total_xp): false
PASS named-column-diagnostic own XP write denied SQLSTATE: "42501"
PASS named-column-diagnostic own XP unchanged: 0
CASE named authenticated column grant diagnostic COMPLETE
CLOSED named authenticated column grant diagnostic in-memory database
PASS THIS INVOCATION databases=1 assertions=4 failures=0
OVERALL ORIGINAL HYPOTHESIS: FAIL; this continuation does not replace NODE_EXIT=1 from the original invocation.
LIMITATION: conditional synthetic ACL inheritance reproduced; fresh control denied XP writes. No production ACL/cohort/gateway/concurrency claim; no reward arithmetic tested.
NODE_EXIT=0
```

## Source hashes reported by each invocation

```text
tools/db-tests/bootstrap.sql fbfdd130ab2a2db10f9c5f850589fee746bee1b327e366c41179ca5931a7f250
baseline.sql e4e56bd1a1bb770fb28fec09ee5590302b89554d33f255b559499d1d8c21fc44
authoritative_progression.sql 4b5f5682a25da4abbba8ca0aa3c4b6ed22ab92bc30021a9cef8b5f750b2dfc62
exercise_catalog_metadata.sql 143b69653bb9b178fbc8b3fda6380ee1021be958a39d32f7bfac4f53727fbefb
supabase/seed.sql a96d9f5830b8cab1b99501725d1a9ff31fedb8a18900a463240ac246db392c68
supabase/seed_exercises.sql 9af8382923d798fee30ccbe32986873440f5fd25588a0cea00acf408ad00c748
```

These observations establish a conditional PUBLIC-ACL migration-adoption defect, not an installed
fresh-schema bypass. No unconditional cross-user data access or anonymous RLS bypass was reproduced.
Role bootstrap is synthetic and does not verify Supabase gateway/JWT parsing or deployed defaults.
