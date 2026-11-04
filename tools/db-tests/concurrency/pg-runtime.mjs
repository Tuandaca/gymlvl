// M3.6 isolated PostgreSQL runtime for genuine multi-connection evidence.
//
// This helper boots a disposable PostgreSQL 17.5 cluster from the npm package
// `embedded-postgres` inside the OS temp directory, applies the real versioned
// migrations and seeds, and hands out independent `pg.Client` connections.
// Nothing is installed machine-wide, nothing listens after teardown, and the
// data directory is removed even when a scenario throws.
//
// Rollback path: delete this file and the `concurrency/` directory. The helper
// never touches `supabase/**`, never contacts a remote project, and never edits
// the single-connection PGlite suite (`run.mjs`) which remains the regression
// authority.

import EmbeddedPostgres from 'embedded-postgres';
import net from 'node:net';
import os from 'node:os';
import path from 'node:path';
import assert from 'node:assert/strict';
import { existsSync } from 'node:fs';
import { readFile, readdir, rm } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
export const dbTestsDir = path.resolve(here, '..');
export const repoRoot = path.resolve(dbTestsDir, '../..');
const supabaseDir = path.join(repoRoot, 'supabase');

const BASE_PORT = 55432;
const MAX_PORT_ATTEMPTS = 6;
const SCRATCH_DATABASE = 'gymlvl_m36';

/**
 * PASS / FAIL reporting shared by the harness. Every failure marks the process
 * exit code so CI and the operator see a non-zero result.
 */
export const report = {
  failures: [],
  pass(label, detail = '') {
    console.log(`PASS ${label}${detail ? ` (${detail})` : ''}`);
  },
  fail(label, detail = '') {
    this.failures.push({ label, detail });
    console.error(`FAIL ${label}${detail ? `: ${detail}` : ''}`);
  },
  info(line = '') {
    console.log(line);
  },
  block(title) {
    console.log(`\n--- ${title} ---`);
  },
  finish() {
    if (this.failures.length > 0) process.exitCode = 1;
  },
};

/**
 * Mirrors the discovery rules in `tools/db-tests/run.mjs` exactly: versioned
 * migrations sorted by filename, seeds read from `supabase/config.toml`, and
 * `enabled = false` respected. Kept in sync deliberately so the two suites
 * never disagree about which SQL is authoritative.
 */
export async function discoverSqlPlan() {
  const migrationsDir = path.join(supabaseDir, 'migrations');
  const migrations = (await readdir(migrationsDir)).filter(name => name.endsWith('.sql')).sort();
  assert(migrations.length > 0, 'At least one versioned migration is required');
  for (const name of migrations) {
    assert.match(name, /^\d{14}_[a-z0-9_]+\.sql$/, `Unversioned migration: ${name}`);
  }

  const config = await readFile(path.join(supabaseDir, 'config.toml'), 'utf8');
  const seedSection = config.match(/\[db\.seed\]([\s\S]*?)(?=\n\[|$)/)?.[1] ?? '';
  const seeds = [];
  if (!/enabled\s*=\s*false/.test(seedSection)) {
    const declared = [...(seedSection.match(/sql_paths\s*=\s*\[([\s\S]*?)\]/)?.[1] ?? '')
      .matchAll(/"([^"]+)"/g)].map(match => match[1]);
    for (const name of declared) {
      const filename = path.resolve(supabaseDir, name);
      assert(filename.startsWith(supabaseDir + path.sep), 'Seed must be inside supabase');
      seeds.push({ name, filename });
    }
  }

  return {
    migrations: migrations.map(name => ({ name, filename: path.join(migrationsDir, name) })),
    seeds,
  };
}

function delay(ms) {
  return new Promise(resolve => { setTimeout(resolve, ms); });
}

/** True when nothing is listening on the loopback port. */
export function isPortFree(port) {
  return new Promise(resolve => {
    const probe = net.createServer();
    probe.once('error', () => resolve(false));
    probe.once('listening', () => probe.close(() => resolve(true)));
    probe.listen(port, '127.0.0.1');
  });
}

async function removeDirectory(directory) {
  for (let attempt = 0; attempt < 10; attempt += 1) {
    try {
      await rm(directory, { recursive: true, force: true });
      if (!existsSync(directory)) return;
    } catch {
      // Windows keeps handles briefly after taskkill; retry.
    }
    await delay(100);
  }
}

class Runtime {
  constructor(server, port, databaseDir, logs) {
    this.server = server;
    this.port = port;
    this.databaseDir = databaseDir;
    this.database = SCRATCH_DATABASE;
    this.logs = logs;
    this.clients = new Set();
    this.stopped = false;
  }

  /** Independent TCP connection. Every business caller gets its own. */
  async openClient(database = this.database) {
    const client = this.server.getPgClient(database, '127.0.0.1');
    await client.connect();
    this.clients.add(client);
    return client;
  }

  async closeClient(client) {
    this.clients.delete(client);
    try {
      await client.end();
    } catch {
      // Already closed by a failed transaction; nothing to do.
    }
  }

  async teardown() {
    if (this.stopped) return this.cleanupEvidence();
    this.stopped = true;
    for (const client of [...this.clients]) {
      await this.closeClient(client);
    }
    try {
      await this.server.stop();
    } catch {
      // taskkill can race with an already-exited postmaster.
    }
    await removeDirectory(this.databaseDir);
    return this.cleanupEvidence();
  }

  cleanupEvidence() {
    return {
      databaseDir: this.databaseDir,
      directoryRemoved: !existsSync(this.databaseDir),
      port: this.port,
    };
  }
}

async function applySqlFile(client, label, filename) {
  const sql = await readFile(filename, 'utf8');
  try {
    await client.query(sql);
  } catch (error) {
    throw new Error(`${label} failed [${error.code ?? 'no-code'}]: ${error.message}`);
  }
}

/**
 * Boot a disposable cluster, create a scratch database, and replay the real
 * schema. The caller owns teardown and must call it in a `finally` block.
 */
export async function startRuntime({ label = 'gymlvl-m36' } = {}) {
  const plan = await discoverSqlPlan();
  let lastError = null;

  for (let attempt = 0; attempt < MAX_PORT_ATTEMPTS; attempt += 1) {
    const port = BASE_PORT + attempt;
    if (!(await isPortFree(port))) {
      lastError = new Error(`port ${port} already in use`);
      continue;
    }

    const databaseDir = path.join(os.tmpdir(), `${label}-pg-${process.pid}-${attempt}`);
    await removeDirectory(databaseDir);

    const logs = [];
    const capture = message => {
      logs.push(String(message).trim());
      if (logs.length > 200) logs.shift();
    };

    const server = new EmbeddedPostgres({
      databaseDir,
      port,
      user: 'postgres',
      password: 'postgres',
      persistent: false,
      // The migrations carry Vietnamese catalogue text. Force a UTF8 cluster
      // so the real SQL applies exactly as it does on Supabase.
      initdbFlags: ['--encoding=UTF8', '--locale=C'],
      onLog: capture,
      onError: capture,
    });

    try {
      await server.initialise();
      await server.start();
    } catch (error) {
      lastError = error instanceof Error ? error : new Error(String(error ?? 'start failed'));
      await removeDirectory(databaseDir);
      continue;
    }

    const runtime = new Runtime(server, port, databaseDir, logs);
    try {
      const admin = await runtime.openClient('postgres');
      await admin.query(`CREATE DATABASE ${SCRATCH_DATABASE}`);
      await runtime.closeClient(admin);

      const setup = await runtime.openClient();
      await applySqlFile(setup, 'isolated auth/role bootstrap', path.join(dbTestsDir, 'bootstrap.sql'));
      report.info(`APPLIED bootstrap.sql (auth/role contract)`);

      for (const migration of plan.migrations) {
        await applySqlFile(setup, `migration ${migration.name}`, migration.filename);
        report.info(`APPLIED migration ${migration.name}`);
      }

      for (const seed of plan.seeds) {
        for (const pass of [1, 2]) {
          await applySqlFile(setup, `seed ${seed.name} pass ${pass}`, seed.filename);
        }
        report.info(`APPLIED seed ${seed.name} twice (idempotent replay)`);
      }

      const version = (await setup.query(
        "SELECT version() AS full, current_setting('server_version') AS short_version"
      )).rows[0];
      const catalog = Number((await setup.query('SELECT count(*) AS total FROM public.exercises')).rows[0].total);
      assert(catalog >= 120, `Exercise catalog must be seeded, found ${catalog}`);
      const ledger = Number((await setup.query('SELECT count(*) AS total FROM public.workout_write_operations')).rows[0].total);
      assert(ledger === 0, 'Ledger must start empty');

      await runtime.closeClient(setup);
      report.info(`READY ${version.full.split(',')[0]} on 127.0.0.1:${port} (catalog ${catalog} exercises)`);

      return { runtime, version };
    } catch (error) {
      await runtime.teardown();
      throw error;
    }
  }

  throw new Error(
    `Could not start an embedded cluster on ports ${BASE_PORT}-${BASE_PORT + MAX_PORT_ATTEMPTS - 1}: ${lastError?.message ?? 'unknown error'}`,
  );
}
