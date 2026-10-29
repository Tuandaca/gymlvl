// Gradle wrapper invocation planning for the release manifest gate
// (FND-BUG-001 / A-3).
//
// The gate must run the real Gradle merge task on every platform and must never
// fall back to a globally installed Gradle. Two wrapper forms exist:
//
//   Windows: `gradlew.bat`, which needs a shell (cmd.exe) to execute. The path is
//            quoted only when it contains whitespace.
//   POSIX:   `gradlew`, a shell script. Flutter materializes it with a
//            `#!/usr/bin/env bash` shebang and bash-only syntax (`JVM_OPTS=(...)`),
//            so it must run under bash. Ubuntu's /bin/sh is dash, which cannot
//            parse that syntax and aborts before Gradle starts (CI run
//            40832095175: `gradlew: 154: Syntax error: "(" unexpected`).
//
// Passing the wrapper as an argument to bash keeps whitespace safe without shell
// quoting and avoids interpolating untrusted text into a command line.
export const GRADLE_TASK = ':app:processReleaseMainManifest';

/** Build the platform-specific command/args pair. Pure, so it is unit-testable. */
export function gradleInvocation({ platform, wrapper, task = GRADLE_TASK }) {
  const args = [task, '--console=plain'];
  if (platform === 'win32') {
    return {
      command: /\s/.test(wrapper) ? `"${wrapper}"` : wrapper,
      args,
      shell: true,
    };
  }
  return { command: 'bash', args: [wrapper, ...args], shell: false };
}

/**
 * Run the merge task and normalize the outcome.
 *
 * Returns `{ status, message }` where status is 0 (merge succeeded) or 2
 * (BLOCKED: the gate could not run the merge). A failed merge is BLOCKED rather
 * than FAIL because no manifest was produced to inspect; the gate must never
 * report PASS in that case.
 */
export function runGradleMerge({
  platform,
  wrapper,
  androidDir,
  spawnSync,
  existsSync,
  env = process.env,
}) {
  if (!existsSync(wrapper)) {
    return { status: 2, message: `BLOCKED: Gradle wrapper not found at ${wrapper}` };
  }

  const invocation = gradleInvocation({ platform, wrapper });
  const childEnv = { ...env };
  if (!childEnv.JAVA_HOME && platform === 'win32') {
    const jbr = 'C:\\Program Files\\Android\\Android Studio\\jbr';
    if (existsSync(jbr)) childEnv.JAVA_HOME = jbr;
  }

  const result = spawnSync(invocation.command, invocation.args, {
    cwd: androidDir,
    env: childEnv,
    stdio: 'inherit',
    shell: invocation.shell,
  });

  if (result.error) {
    return { status: 2, message: `BLOCKED: ${result.error.message}` };
  }
  if (result.status !== 0) {
    return {
      status: 2,
      message: `BLOCKED: Gradle manifest merge exited with code ${result.status}`,
    };
  }
  return { status: 0, message: null };
}
