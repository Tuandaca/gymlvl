import assert from 'node:assert/strict';
import { readFile, readdir } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { PGlite } from '@electric-sql/pglite';
import { pgcrypto } from '@electric-sql/pglite/contrib/pgcrypto';

/**
 * FND-DATA-001 / D-037 cohort validation — read-only, isolated PGlite, synthetic data only.
 *
 * Validates the two read-only cohort assessment queries against every versioned migration, with
 * positive/negative controls and the double-award guard behaviour. Writes nothing to production;
 * all inserts are synthetic rows inside a rolled-back transaction on an embedded single-connection
 * PGlite instance. This proves query syntax/schema validity and guard behaviour locally; it does NOT
 * prove real PostgreSQL concurrency (single connection) nor production data absence.
 */
const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../..');
const db = new PGlite({ extensions: { pgcrypto } });

async function runSql(label, filename) {
  await db.exec(await readFile(filename, 'utf8'));
  console.log(`PASS ${label}`);
}

async function main() {
  await runSql('isolated auth/role bootstrap', path.join(here, 'bootstrap.sql'));
  const migrationsDir = path.join(root, 'supabase/migrations');
  const migrations = (await readdir(migrationsDir))
    .filter((name) => name.endsWith('.sql'))
    .sort();
  assert(migrations.length > 0, 'At least one versioned migration is required');
  for (const name of migrations) {
    assert.match(name, /^\d{14}_[a-z0-9_]+\.sql$/, `Unversioned migration: ${name}`);
    await runSql(`migration ${name}`, path.join(migrationsDir, name));
  }

  const uid = '11111111-1111-1111-1111-111111111111';
  const wLegacy = '22222222-2222-2222-2222-222222222222';
  const wClean = '33333333-3333-3333-3333-333333333333';

  // Synthetic legacy cohort inside a transaction: completed, flag false, no reward row, ledger evidence.
  await db.query('BEGIN');
  try {
    await db.query(`SET session_replication_role = 'replica';`);
    await db.query(
      `INSERT INTO auth.users (id, email) VALUES ('${uid}', 'legacy@example.test') ON CONFLICT DO NOTHING;`,
    );
    await db.query(
      `INSERT INTO public.users (id, email) VALUES ('${uid}', 'legacy@example.test') ON CONFLICT DO NOTHING;`,
    );
    await db.exec(`
      INSERT INTO public.workouts (id, user_id, status, completed_at, training_started_at, is_xp_calculated)
      VALUES ('${wLegacy}', '${uid}', 'completed', now(), now() - interval '30 minutes', false),
             ('${wClean}', '${uid}', 'completed', now(), now() - interval '30 minutes', false);
      INSERT INTO public.xp_logs (user_id, amount, source, source_id)
      VALUES ('${uid}', 42, 'workout', '${wLegacy}');
    `);

    // Cohort B — at-risk ledger evidence (the exact legacy tuple the migration protects).
    const qB = `
WITH at_risk AS (
  SELECT w.id AS workout_id, w.user_id,
         count(l.id)::bigint AS ledger_rows,
         coalesce(sum(l.amount), 0)::bigint AS ledger_xp
  FROM public.workouts w
  JOIN public.xp_logs l
    ON l.user_id = w.user_id
   AND l.source_id = w.id::text
   AND l.source IN ('workout', 'quest')
  LEFT JOIN public.workout_rewards r ON r.workout_id = w.id
  WHERE w.status = 'completed'
    AND coalesce(w.is_xp_calculated, false) = false
    AND r.workout_id IS NULL
  GROUP BY w.id, w.user_id
)
SELECT count(*)::bigint AS at_risk_workouts,
       count(DISTINCT user_id)::bigint AS affected_users,
       coalesce(sum(ledger_rows), 0)::bigint AS ledger_rows,
       coalesce(sum(ledger_xp), 0)::bigint AS ledger_xp_evidence
FROM at_risk`;

    // Cohort A — rewarded-workout baseline.
    const qA = `
WITH rewarded AS (
  SELECT w.id, w.user_id, w.completed_at
  FROM public.workouts w
  JOIN public.workout_rewards r ON r.workout_id = w.id
  WHERE w.status = 'completed'
)
SELECT count(*)::bigint AS rewarded_workouts,
       count(DISTINCT user_id)::bigint AS users_with_reward,
       count(*) FILTER (WHERE completed_at IS NULL)::bigint AS missing_completed_at
FROM rewarded`;

    // Guard + supporting index presence.
    const guardSql = `
SELECT to_regclass('public.idx_xp_logs_user_source') IS NOT NULL AS index_present,
       (SELECT position('source_id=w.id::text' in pg_get_functiondef(p.oid)) > 0
        FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
        WHERE n.nspname = 'public' AND p.proname = 'complete_workout' LIMIT 1) AS guard_present`;

    const resB = (await db.query(qB)).rows[0];
    console.log('POSITIVE_CONTROL ' + JSON.stringify(resB));
    assert.equal(Number(resB.at_risk_workouts), 1, 'cohort B must isolate the synthetic at-risk tuple');
    assert.equal(Number(resB.affected_users), 1);
    assert.equal(Number(resB.ledger_rows), 1);
    assert.equal(Number(resB.ledger_xp_evidence), 42);

    const resA = (await db.query(qA)).rows[0];
    console.log('COHORT_A_BASELINE ' + JSON.stringify(resA));

    const guardRes = (await db.query(guardSql)).rows[0];
    console.log('GUARD_INDEX_PRESENCE ' + JSON.stringify(guardRes));
    assert.equal(guardRes.index_present, true);
    assert.equal(guardRes.guard_present, true);

    // Negative control: add the reward row -> cohort B must return to 0.
    await db.query(
      `INSERT INTO public.workout_rewards (workout_id, user_id, result) VALUES ('${wLegacy}', '${uid}', '{"earnedXP":42}'::jsonb);`,
    );
    const afterB = (await db.query(qB)).rows[0];
    console.log('NEGATIVE_CONTROL ' + JSON.stringify(afterB));
    assert.equal(Number(afterB.at_risk_workouts), 0, 'cohort B must clear once a reward row exists');

    // Guard: complete_workout must refuse a second award for the legacy tuple.
    await db.query(`DELETE FROM public.workout_rewards WHERE workout_id = '${wLegacy}';`);
    await db.query(`SELECT set_config('request.jwt.claims', json_build_object('sub', '${uid}', 'role', 'authenticated')::text, false)`);
    const guardCall = await db.query(`SELECT public.complete_workout('${wLegacy}', NULL) AS out`);
    console.log('GUARD_RESULT ' + JSON.stringify(guardCall.rows[0].out));
    assert.equal(guardCall.rows[0].out.alreadyAwarded, true);
    assert.equal(guardCall.rows[0].out.earnedXP, 0);
  } finally {
    await db.query('ROLLBACK');
    await db.close();
  }

  console.log('COHORT_VALIDATION_PASS all read-only cohort controls pass on isolated PGlite');
}

main().catch((error) => {
  console.error('COHORT_VALIDATION_FAIL:', error.message);
  process.exit(1);
});
