import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { readdirSync } from 'node:fs';
import path from 'node:path';
const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../..');
const binary = path.join(here, 'node_modules/deno', process.platform === 'win32' ? 'deno.exe' : 'deno');
const functions = path.join(root, 'supabase/functions');
const check = process.argv.includes('--check');
const targets = check
  ? readdirSync(functions, { withFileTypes: true })
      .filter(entry => entry.isDirectory() && !entry.name.startsWith('_') && entry.name !== 'tests')
      .map(entry => path.join(functions, entry.name, 'index.ts'))
  : [functions];
const result = spawnSync(binary, [...(check ? ['check'] : ['test', '--allow-env', '--allow-net']), '--frozen', '--lock', path.join(functions, 'deno.lock'), ...targets], {
  cwd: root,
  stdio: 'inherit',
  env: { ...process.env, DENO_DIR: path.join(root, 'tmp/deno-cache') },
});
if (result.error) console.error(result.error.message);
process.exitCode = result.status ?? 1;
