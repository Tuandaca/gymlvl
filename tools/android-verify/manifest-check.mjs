// Release-manifest assertions for the Android permission gate (FND-BUG-001).
//
// This module contains no I/O: it inspects XML text so the same rule set can be
// unit-tested with fixtures and applied to a real merged manifest.
//
// The rule: `android.permission.INTERNET` must appear exactly once, as a direct
// child of <manifest>, never nested inside <application>. A nested declaration is
// silently ignored by the platform and would leave the release build offline.

const INTERNET = 'android.permission.INTERNET';

function tokens(source) {
  return source.match(/<!--[\s\S]*?-->|<\?[\s\S]*?\?>|<[^>]+>/g) ?? [];
}

function attributes(tag) {
  const attrs = {};
  const pattern = /([\w:.-]+)\s*=\s*"([^"]*)"/g;
  let match;
  while ((match = pattern.exec(tag)) !== null) attrs[match[1]] = match[2];
  return attrs;
}

export function analyzeManifest(source) {
  const stack = [];
  const directInternet = [];
  const nestedInternet = [];
  let packageName = null;
  let label = null;
  let applications = 0;

  for (const token of tokens(source)) {
    if (token.startsWith('<!--') || token.startsWith('<?')) continue;

    if (token.startsWith('</')) {
      const name = /^<\/\s*([\w:.-]+)/.exec(token)?.[1];
      if (!name || stack.pop() !== name) {
        throw new Error(`Unbalanced manifest tag: ${token}`);
      }
      continue;
    }

    const name = /^<\s*([\w:.-]+)/.exec(token)?.[1];
    if (!name) continue;

    if (name === 'manifest') {
      packageName = attributes(token)['package'] ?? null;
    }

    if (name === 'application') {
      applications += 1;
      label = attributes(token)['android:label'] ?? null;
    }

    if (name === 'uses-permission') {
      const permission = attributes(token)['android:name'];
      if (permission === INTERNET) {
        if (stack[stack.length - 1] === 'manifest') directInternet.push(permission);
        else nestedInternet.push(stack[stack.length - 1] ?? 'unknown');
      }
    }

    if (!token.endsWith('/>')) stack.push(name);
  }

  if (stack.length !== 0) {
    throw new Error(`Unbalanced manifest; unclosed: ${stack.join(', ')}`);
  }

  return {
    packageName,
    label,
    applications,
    directInternet: directInternet.length,
    nestedInternet: nestedInternet.length,
    duplicates: Math.max(0, directInternet.length - 1),
  };
}

export function manifestProblems(report, { expectedLabel = 'GymLvl' } = {}) {
  const problems = [];
  if (report.applications !== 1) {
    problems.push(`expected exactly one <application>, found ${report.applications}`);
  }
  if (report.packageName !== 'com.gymlvl.app') {
    problems.push(`unexpected package "${report.packageName}"`);
  }
  if (report.label !== expectedLabel) {
    problems.push(`application label "${report.label}" is not "${expectedLabel}"`);
  }
  if (report.directInternet !== 1) {
    problems.push(
      `expected exactly one direct <manifest> INTERNET permission, found ${report.directInternet}`,
    );
  }
  if (report.duplicates > 0) {
    problems.push(`duplicate INTERNET declarations: ${report.duplicates}`);
  }
  if (report.nestedInternet > 0) {
    problems.push(
      `INTERNET is nested under <${report.nestedInternet}> and would be ignored`,
    );
  }
  return problems;
}

export function assertReleaseManifest(source, options) {
  const report = analyzeManifest(source);
  const problems = manifestProblems(report, options);
  if (problems.length > 0) {
    throw new Error(`Release manifest check failed:\n- ${problems.join('\n- ')}`);
  }
  return report;
}
