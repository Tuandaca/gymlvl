// Regression tests for the Gradle wrapper invocation used by the release
// manifest gate. These cover the defect that failed CI run 40832095175:
// the bash-only `gradlew` script was executed through `sh` (dash) on Linux.
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { GRADLE_TASK, gradleInvocation, runGradleMerge } from './gradle-invocation.mjs';

const here = path.dirname(fileURLToPath(import.meta.url));

let failures = 0;
function check(name, fn) {
  try {
    fn();
    console.log(`ok - ${name}`);
  } catch (error) {
    failures += 1;
    console.error(`not ok - ${name}: ${error.message}`);
  }
}
function equal(actual, expected, label) {
  if (actual !== expected) {
    throw new Error(`${label}: expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`);
  }
}
const wrapperPosix = '/home/runner/work/gymlvl/gymlvl/app/android/gradlew';
const wrapperWindows = 'D:\\Projects\\gymlvl\\app\\android\\gradlew.bat';
const fakeSpawn = (calls, result = { status: 0 }) => (command, args, options) => {
  calls.push({ command, args, options });
  return result;
};

check('windows runs gradlew.bat through a shell with the merge task', () => {
  const inv = gradleInvocation({ platform: 'win32', wrapper: wrapperWindows });
  equal(inv.command, wrapperWindows, 'command');
  equal(inv.shell, true, 'shell');
  equal(inv.args.length, 2, 'arg count');
  equal(inv.args[0], GRADLE_TASK, 'task');
  equal(inv.args[1], '--console=plain', 'console flag');
  equal(inv.command.includes('gradlew.bat'), true, 'wrapper name');
});

check('windows quotes a wrapper path that contains spaces', () => {
  const inv = gradleInvocation({
    platform: 'win32',
    wrapper: 'C:\\Users\\Jane Doe\\gymlvl\\app\\android\\gradlew.bat',
  });
  equal(inv.command, '"C:\\Users\\Jane Doe\\gymlvl\\app\\android\\gradlew.bat"', 'quoted command');
  equal(inv.shell, true, 'shell');
});

check('linux runs the wrapper with bash, not sh', () => {
  const inv = gradleInvocation({ platform: 'linux', wrapper: wrapperPosix });
  equal(inv.command, 'bash', 'interpreter');
  equal(inv.shell, false, 'no shell interpolation');
  equal(inv.args[0], wrapperPosix, 'wrapper path is argv[1] of bash');
  equal(inv.args[1], GRADLE_TASK, 'task preserved');
  equal(inv.args[2], '--console=plain', 'console flag preserved');
});

check('linux keeps a wrapper path with spaces as one argument', () => {
  const spaced = '/tmp/jane doe/gymlvl/app/android/gradlew';
  const inv = gradleInvocation({ platform: 'linux', wrapper: spaced });
  equal(inv.args[0], spaced, 'path not split or quoted');
  equal(inv.args.length, 3, 'arg count');
});

check('custom gradle task and flags are preserved on both platforms', () => {
  const win = gradleInvocation({ platform: 'win32', wrapper: wrapperWindows, task: ':app:foo' });
  const posix = gradleInvocation({ platform: 'linux', wrapper: wrapperPosix, task: ':app:foo' });
  equal(win.args[0], ':app:foo', 'windows task');
  equal(posix.args[1], ':app:foo', 'posix task');
  equal(win.args[1], '--console=plain', 'windows flag');
  equal(posix.args[2], '--console=plain', 'posix flag');
});

check('missing wrapper is BLOCKED and nothing is spawned', () => {
  const calls = [];
  const outcome = runGradleMerge({
    platform: 'linux',
    wrapper: wrapperPosix,
    androidDir: '/tmp/android',
    spawnSync: fakeSpawn(calls),
    existsSync: () => false,
  });
  equal(outcome.status, 2, 'status');
  equal(outcome.message.startsWith('BLOCKED:'), true, 'message');
  equal(calls.length, 0, 'spawn calls');
});

check('a gradle failure is BLOCKED with the child exit code', () => {
  const calls = [];
  const outcome = runGradleMerge({
    platform: 'linux',
    wrapper: wrapperPosix,
    androidDir: '/tmp/android',
    spawnSync: fakeSpawn(calls, { status: 3 }),
    existsSync: () => true,
    env: {},
  });
  equal(outcome.status, 2, 'status');
  equal(outcome.message, 'BLOCKED: Gradle manifest merge exited with code 3', 'message');
  equal(calls.length, 1, 'spawn calls');
  equal(calls[0].command, 'bash', 'interpreter used');
});

check('a spawn error is BLOCKED', () => {
  const outcome = runGradleMerge({
    platform: 'linux',
    wrapper: wrapperPosix,
    androidDir: '/tmp/android',
    spawnSync: () => ({ error: new Error('bash not found') }),
    existsSync: () => true,
    env: {},
  });
  equal(outcome.status, 2, 'status');
  equal(outcome.message, 'BLOCKED: bash not found', 'message');
});

check('a successful merge reports status 0 without a message', () => {
  const calls = [];
  const outcome = runGradleMerge({
    platform: 'win32',
    wrapper: wrapperWindows,
    androidDir: 'D:\\Projects\\gymlvl\\app\\android',
    spawnSync: fakeSpawn(calls),
    existsSync: (target) => target === wrapperWindows,
    env: { JAVA_HOME: 'C:\\jdk' },
  });
  equal(outcome.status, 0, 'status');
  equal(outcome.message, null, 'message');
  equal(calls[0].options.cwd, 'D:\\Projects\\gymlvl\\app\\android', 'working directory');
  equal(calls[0].options.env.JAVA_HOME, 'C:\\jdk', 'JAVA_HOME preserved');
});

check('explicit missing manifest is BLOCKED, never PASS', () => {
  const result = spawnSync(
    process.execPath,
    [path.join(here, 'run.mjs'), '--manifest', path.join(here, 'does-not-exist.xml')],
    { encoding: 'utf8' },
  );
  equal(result.status, 2, 'exit code');
  equal(result.stderr.includes('BLOCKED'), true, 'stderr mentions BLOCKED');
  equal(result.stdout.includes('PASS'), false, 'stdout never claims PASS');
});

if (failures > 0) {
  console.error(`${failures} gradle-invocation test(s) failed`);
  process.exitCode = 1;
} else {
  console.log('all gradle-invocation tests passed');
}
