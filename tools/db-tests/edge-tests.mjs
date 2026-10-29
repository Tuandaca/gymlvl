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
// The RPC handler resolves hosted-project configuration from the environment
// and fails closed with 503 when it is absent. The bounded-body suite mocks
// fetch, so synthetic configuration keeps it self-contained while still
// allowing a real environment to override these values.
const syntheticSupabaseEnv = {
  SUPABASE_URL: process.env.SUPABASE_URL ?? 'https://project.test',
  SUPABASE_ANON_KEY:
    process.env.SUPABASE_ANON_KEY ??
    process.env.SUPABASE_PUBLISHABLE_KEY ??
    'synthetic-anon-key',
};
const result = spawnSync(binary, [...(check ? ['check'] : ['test', '--allow-env', '--allow-net']), '--frozen', '--lock', path.join(functions, 'deno.lock'), ...targets], {
  cwd: root,
  stdio: 'inherit',
  env: { ...process.env, ...syntheticSupabaseEnv, DENO_DIR: path.join(root, 'tmp/deno-cache') },
});
if (result.error) console.error(result.error.message);
process.exitCode = result.status ?? 1;
