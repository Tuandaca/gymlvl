// Android release permission gate (FND-BUG-001 / A-3).
//
// Source-level manifest tests cannot prove what the Android manifest merger
// produces. This gate runs the real merge task and inspects the merged manifest.
//
// Exit codes:
//   0  merged release manifest verified
//   1  merge produced a manifest that fails the assertions
//   2  BLOCKED: Android toolchain, Gradle wrapper or merged artifact unavailable
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { assertReleaseManifest } from './manifest-check.mjs';
import { runGradleMerge } from './gradle-invocation.mjs';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../..');
const androidDir = path.join(root, 'app/android');
const buildDir = path.join(root, 'app/build/app/intermediates');
const wrapper = path.join(androidDir, process.platform === 'win32' ? 'gradlew.bat' : 'gradlew');

const args = process.argv.slice(2);
const manifestArg = args.indexOf('--manifest');
const explicitManifest = manifestArg >= 0 ? path.resolve(args[manifestArg + 1]) : null;

function blocked(reason) {
  console.error(reason.startsWith('BLOCKED:') ? reason : `BLOCKED: ${reason}`);
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

if (explicitManifest) {
  if (!existsSync(explicitManifest)) blocked(`Manifest not found: ${explicitManifest}`);
} else {
  const merge = runGradleMerge({
    platform: process.platform,
    wrapper,
    androidDir,
    spawnSync,
    existsSync,
  });
  if (merge.status !== 0) blocked(merge.message);
}

if (process.exitCode !== 2) {
  const manifest = explicitManifest ?? findMergedManifest(buildDir);
  if (!manifest) {
    // The merge reported success but no release artifact exists; the gate cannot
    // inspect anything, so it must block instead of claiming a pass.
    blocked('no merged release manifest found after the merge task');
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
