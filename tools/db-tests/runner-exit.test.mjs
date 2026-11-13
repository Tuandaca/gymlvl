import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtemp, writeFile, rm } from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import test from 'node:test';

const here = path.dirname(fileURLToPath(import.meta.url));

test('failing SQL makes the verification process exit nonzero', async () => {
  const dir = await mkdtemp(path.join(os.tmpdir(), 'gymlvl-db-probe-'));
  const probe = path.join(dir, 'expected_failure.sql');
  try {
    await writeFile(probe, 'SELECT 1 / 0;\n');
    const result = spawnSync(process.execPath, ['run.mjs'], {
      cwd: here,
      env: { ...process.env, GYMLVL_DB_TEST_PROBE_SQL: probe },
      encoding: 'utf8',
      timeout: 30000,
    });
    assert.match(result.stderr, /FAIL injected SQL regression: division by zero/);
    assert.equal(result.status, 1, 'runner must signal SQL failure to CI');
  } finally {
    await rm(dir, { recursive: true, force: true });
  }
});
