// Android release permission gate (FND-BUG-001 / A-3).
//
// Source-level manifest tests cannot prove what the Android manifest merger
// produces. This gate runs the real merge task and inspects the merged manifest.
//
// Exit codes:
//   0  merged release manifest verified
//   1  merge produced a manifest that fails the assertions
//   2  BLOCKED: Android toolchain or Gradle wrapper unavailable
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { assertReleaseManifest } from './manifest-check.mjs';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../..');
const androidDir = path.join(root, 'app/android');
const buildDir = path.join(root, 'app/build/app/intermediates');
const wrapper = path.join(androidDir, process.platform === 'win32' ? 'gradlew.bat' : 'gradlew');

const args = process.argv.slice(2);
const manifestArg = args.indexOf('--manifest');
const explicitManifest = manifestArg >= 0 ? path.resolve(args[manifestArg + 1]) : null;

function blocked(reason) {
  console.error(`BLOCKED: ${reason}`);
  process.exitCode = 2;
}

function findMergedManifest(dir) {
  if (!existsSync(dir)) return null;
  const hits = [];
  const walk = (current) => {
    for (const entry of readdirSync(current)) {
      const full = path.join(current, entry);
      if (statSync(full).isDirectory()) walk(full);
      else if (
        entry === 'AndroidManifest.xml' &&
        full.includes('merged_manifest') &&
        full.includes(`${path.sep}release${path.sep}`)
      ) {
        hits.push(full);
      }
    }
  };
  walk(dir);
  if (hits.length === 0) return null;
  // Prefer the app module over plugin modules, then the shortest path.
  hits.sort((a, b) => {
    const appA = a.includes(`${path.sep}app${path.sep}intermediates`) ? 0 : 1;
    const appB = b.includes(`${path.sep}app${path.sep}intermediates`) ? 0 : 1;
    return appA - appB || a.length - b.length;
  });
  return hits[0];
}

function runMerge() {
  if (!existsSync(wrapper)) return blocked(`Gradle wrapper not found at ${wrapper}`);
  const env = { ...process.env };
  if (!env.JAVA_HOME && process.platform === 'win32') {
    const jbr = 'C:\\Program Files\\Android\\Android Studio\\jbr';
    if (existsSync(jbr)) env.JAVA_HOME = jbr;
  }
  const command = process.platform === 'win32' ? wrapper : 'sh';
  const commandArgs =
    process.platform === 'win32'
      ? [':app:processReleaseMainManifest', '--console=plain']
      : [wrapper, ':app:processReleaseMainManifest', '--console=plain'];
  const result = spawnSync(command, commandArgs, {
    cwd: androidDir,
    env,
    stdio: 'inherit',
    shell: process.platform === 'win32',
  });
  if (result.error) return blocked(result.error.message);
  if (result.status !== 0) {
    return blocked(`Gradle manifest merge exited with code ${result.status}`);
  }
  return true;
}

if (explicitManifest) {
  if (!existsSync(explicitManifest)) blocked(`Manifest not found: ${explicitManifest}`);
} else if (runMerge() !== true) {
  // blocked() already set the exit code.
} else {
  // continue below
}

if (process.exitCode !== 2) {
  const manifest = explicitManifest ?? findMergedManifest(buildDir);
  if (!manifest) {
    console.error('FAIL: no merged release manifest found; run the merge task first');
    process.exitCode = 1;
  } else {
    try {
      const report = assertReleaseManifest(readFileSync(manifest, 'utf8'));
      console.log(`MERGED_MANIFEST=${manifest}`);
      console.log(
        `PASS merged release manifest: package=${report.packageName} label=${report.label} ` +
          `internet=${report.directInternet} nested=${report.nestedInternet} duplicates=${report.duplicates}`,
      );
    } catch (error) {
      console.error(`FAIL: ${error.message}`);
      process.exitCode = 1;
    }
  }
}
