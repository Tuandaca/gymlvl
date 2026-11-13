import { createHash } from 'node:crypto';
import { spawn } from 'node:child_process';
import { copyFile, lstat, mkdir, mkdtemp, readFile, readdir, realpath, rm } from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const sourceRoots = ['lib', 'test', 'integration_test'];
const configFiles = ['pubspec.yaml', 'pubspec.lock', 'analysis_options.yaml', 'l10n.yaml', 'build.yaml'];
const generatedSuffixes = ['.g.dart', '.freezed.dart', '.drift.dart'];

function isGenerated(relative) {
  return generatedSuffixes.some((suffix) => relative.endsWith(suffix));
}

async function walkRegular(root, relative, onFile) {
  const absolute = path.join(root, relative);
  const stats = await lstat(absolute);
  if (stats.isSymbolicLink()) throw new Error(`Refusing symbolic link: ${relative}`);
  if (stats.isFile()) {
    await onFile(absolute, relative.replaceAll(path.sep, '/'));
    return;
  }
  if (!stats.isDirectory()) throw new Error(`Refusing non-regular input: ${relative}`);
  for (const entry of (await readdir(absolute)).sort()) {
    await walkRegular(root, path.join(relative, entry), onFile);
  }
}

async function existingRoots(root) {
  const roots = [];
  for (const name of sourceRoots) {
    try {
      await lstat(path.join(root, name));
      roots.push(name);
    } catch (error) {
      if (error.code !== 'ENOENT') throw error;
    }
  }
  return roots;
}

export async function collectGenerated(root) {
  const result = new Map();
  for (const name of await existingRoots(root)) {
    await walkRegular(root, name, async (absolute, relative) => {
      if (isGenerated(relative)) result.set(relative, await readFile(absolute, 'utf8'));
    });
  }
  return result;
}

export function compareGenerated(before, after) {
  const normalize = (content) => content.replaceAll('\r\n', '\n');
  const modified = [...before.keys()].filter((key) => after.has(key)
    && normalize(before.get(key)) !== normalize(after.get(key))).sort();
  const missing = [...before.keys()].filter((key) => !after.has(key)).sort();
  const extra = [...after.keys()].filter((key) => !before.has(key)).sort();
  return { modified, missing, extra };
}

async function collectInputs(root) {
  const inputs = new Map();
  const hashFile = async (absolute, relative) => {
    if (!isGenerated(relative)) {
      inputs.set(relative, createHash('sha256').update(await readFile(absolute)).digest('hex'));
    }
  };
  for (const name of await existingRoots(root)) await walkRegular(root, name, hashFile);
  for (const name of configFiles) {
    try {
      await walkRegular(root, name, hashFile);
    } catch (error) {
      if (error.code !== 'ENOENT') throw error;
      if (name === 'pubspec.yaml' || name === 'pubspec.lock') throw error;
    }
  }
  return inputs;
}

async function copyInputs(from, to) {
  const copy = async (absolute, relative) => {
    // A fresh graph must regenerate every output; copying stale or orphaned
    // output would make a deleted source appear up to date.
    if (isGenerated(relative)) return;
    const destination = path.join(to, relative);
    await mkdir(path.dirname(destination), { recursive: true });
    await copyFile(absolute, destination);
  };
  for (const name of await existingRoots(from)) await walkRegular(from, name, copy);
  for (const name of configFiles) {
    try {
      await walkRegular(from, name, copy);
    } catch (error) {
      if (error.code !== 'ENOENT') throw error;
      if (name === 'pubspec.yaml' || name === 'pubspec.lock') throw error;
    }
  }
}

function compareInputs(before, after) {
  return [...new Set([...before.keys(), ...after.keys()])]
    .filter((key) => before.get(key) !== after.get(key)).sort();
}

async function runCommand(command, args, cwd) {
  const windows = process.platform === 'win32';
  const executable = windows ? (process.env.ComSpec || 'cmd.exe') : command;
  const commandArgs = windows
    ? ['/d', '/s', '/c', `${command}.bat ${args.join(' ')}`]
    : args;
  const exitCode = await new Promise((resolve, reject) => {
    const child = spawn(executable, commandArgs, {
      cwd,
      stdio: 'inherit',
    });
    child.once('error', reject);
    child.once('exit', (code, signal) => signal ? reject(new Error(`${command} killed by ${signal}`)) : resolve(code));
  });
  if (exitCode !== 0) throw new Error(`${command} ${args.join(' ')} exited ${exitCode}`);
}

function within(parent, child) {
  const relative = path.relative(parent, child);
  return relative !== '' && relative !== '..' && !relative.startsWith(`..${path.sep}`) && !path.isAbsolute(relative);
}

export async function runCheck(appRoot, { keepTemp = false } = {}) {
  const source = path.resolve(appRoot);
  const sourceReal = await realpath(source);
  const beforeGenerated = await collectGenerated(source);
  const beforeInputs = await collectInputs(source);
  const temp = await mkdtemp(path.join(os.tmpdir(), 'gymlvl-codegen-'));
  const tempReal = await realpath(temp);
  const tempParentReal = await realpath(os.tmpdir());
  if (within(sourceReal, tempReal) || !within(tempParentReal, tempReal)) {
    throw new Error(`Unsafe generation directory: ${temp}`);
  }
  let retain = keepTemp;
  try {
    await copyInputs(source, temp);
    if (compareInputs(beforeInputs, await collectInputs(source)).length
      || Object.values(compareGenerated(beforeGenerated, await collectGenerated(source)))
        .some((files) => files.length)) {
      throw new Error('App inputs changed while copying; rerun the guard.');
    }
    await runCommand('flutter', ['pub', 'get', '--enforce-lockfile'], temp);
    await runCommand('dart', ['run', 'build_runner', 'build', '--delete-conflicting-outputs'], temp);
    const changedInputs = compareInputs(beforeInputs, await collectInputs(source));
    if (changedInputs.length) throw new Error(`App inputs changed during generation: ${changedInputs.join(', ')}`);
    const changedGenerated = compareGenerated(beforeGenerated, await collectGenerated(source));
    if (Object.values(changedGenerated).some((files) => files.length)) {
      throw new Error('App generated files changed during generation; rerun the guard.');
    }
    const changedTemporaryInputs = compareInputs(beforeInputs, await collectInputs(temp));
    if (changedTemporaryInputs.length) {
      throw new Error(`Generator changed inputs/lockfile: ${changedTemporaryInputs.join(', ')}`);
    }
    const drift = compareGenerated(beforeGenerated, await collectGenerated(temp));
    if (Object.values(drift).some((files) => files.length)) {
      retain = true;
      for (const [kind, files] of Object.entries(drift)) {
        for (const file of files) process.stderr.write(`${kind}: ${file}\n`);
      }
      throw new Error(`Generated-code drift. Isolated output retained at ${temp}`);
    }
    process.stdout.write(`Generated-code drift: PASS (${beforeGenerated.size} outputs checked).\n`);
  } finally {
    if (retain) process.stderr.write(`Isolated generation directory: ${temp}\n`);
    else if (within(tempParentReal, await realpath(temp))) await rm(temp, { recursive: true, force: true });
  }
}

const invoked = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (invoked) {
  const args = process.argv.slice(2);
  const appIndex = args.indexOf('--app');
  const validArgs = args.filter((arg, index) => arg === '--keep-temp'
    || (arg === '--app' && index === appIndex)
    || (index === appIndex + 1 && appIndex !== -1));
  if (validArgs.length !== args.length || (appIndex !== -1 && !args[appIndex + 1])) {
    process.stderr.write('Usage: node tools/generated-code/check.mjs [--keep-temp] [--app path]\n');
    process.exitCode = 2;
  } else {
    const appRoot = appIndex === -1 ? path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../../app') : args[appIndex + 1];
    runCheck(appRoot, { keepTemp: args.includes('--keep-temp') }).catch((error) => {
      process.stderr.write(`${error.message}\n`);
      process.exitCode = 1;
    });
  }
}
