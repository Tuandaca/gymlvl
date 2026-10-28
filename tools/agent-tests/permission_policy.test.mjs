import assert from 'node:assert/strict';
import { readFileSync, readdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import test from 'node:test';

// Static policy regression model, NOT the live OpenCode harness or a security sandbox.
// Contract: https://opencode.ai/v2/docs/permissions (2026-10-29): whole-value */?,
// last match, agent rules appended, Windows slash/case normalization, shell trailing " *".
// Scanner decomposition, inherited config, policies and saved approvals are not modeled.
// All dangerous-looking resources below are inert strings; no commands are executed.
const root = new URL('../../', import.meta.url);
const load = (path) => readFileSync(new URL(path, root), 'utf8');
const config = JSON.parse(load('.opencode/opencode.jsonc')
  .replace(/^\s*\/\/.*$/gm, ''));

function agentRules(text) {
  const frontmatter = text.split(/^---\s*$/m)[1];
  assert.ok(frontmatter, 'agent frontmatter is required');
  const section = frontmatter.split(/^permissions:\s*$/m)[1];
  if (!section) return [];
  const rules = [];
  // Deliberately limited to this repository's flat YAML rule triples; fail on shape drift.
  const lines = section.split('\n').filter((line) => line.trim() && !line.trim().startsWith('#'));
  assert.equal(lines.length % 3, 0);
  for (let i = 0; i < lines.length; i += 3) {
    const action = /^\s+- action: ([\w*]+)\s*$/.exec(lines[i]);
    const resource = /^\s+resource: (".*")\s*$/.exec(lines[i + 1]);
    const effect = /^\s+effect: (allow|deny|ask)\s*$/.exec(lines[i + 2]);
    assert.ok(action && resource && effect, `unsupported permission triple: ${lines.slice(i, i + 3)}`);
    rules.push({ action: action[1], resource: JSON.parse(resource[1]), effect: effect[1] });
  }
  return rules;
}

const agents = Object.fromEntries(readdirSync(fileURLToPath(new URL('.opencode/agents/', root)))
  .filter((name) => name.endsWith('.md'))
  .map((name) => [name.slice(0, -3), agentRules(load(`.opencode/agents/${name}`))]));
const reviewers = ['qa-reviewer', 'context-keeper'];
const developers = ['gymlvl-orchestrator', 'flutter-specialist', 'supabase-specialist',
  'exercise-catalog', 'ui-ux-specialist'];

function matches(pattern, value, windows = process.platform === 'win32') {
  const normalize = (text) => {
    const slashes = text.replaceAll('\\', '/');
    return windows ? slashes.toLowerCase() : slashes;
  };
  const expression = [...normalize(pattern)].map((char) => char === '*' ? '[\\s\\S]*'
    : char === '?' ? '[\\s\\S]' : char.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')).join('');
  return new RegExp(`^${expression}$`).test(normalize(value));
}

function resolve(rules, action, resource, windows = process.platform === 'win32') {
  let effect = 'ask';
  for (const rule of rules) {
    if (!matches(rule.action, action, windows)) continue;
    const noArgs = action === 'shell' && rule.resource.endsWith(' *')
      && matches(rule.resource.slice(0, -2), resource, windows);
    if (noArgs || matches(rule.resource, resource, windows)) effect = rule.effect;
  }
  return effect;
}
const effective = (agent, action, resource) => resolve([...config.permissions, ...agents[agent]], action, resource);
const rule = (action, resource, effect) => ({ action, resource, effect });

// D-024's original 73 ordered rules, with ONLY the approved D-026 fallback changed.
const original = [
  ...['read', 'edit', 'glob', 'grep', 'shell', 'webfetch', 'websearch',
    'external_directory', 'question', 'skill'].map((action) => rule(action, '*', action === 'shell' ? 'ask' : 'allow')),
  ...['*.env', '*.env.*', '*.env.example', '*.pem', '*.p12', '*.keystore', '*.jks',
    '*id_rsa*', '*id_ed25519*', '*/.git-credentials'].map((resource) => rule('read', resource,
    resource === '*.env.example' ? 'allow' : 'ask')),
  ...['Get-Content *.env', 'Get-Content *.env.*', 'Get-Content *.pem', 'Get-Content *.p12',
    'Get-Content *.keystore', 'Get-Content *.jks', 'Get-Content *id_rsa*',
    'Get-Content *id_ed25519*', 'Get-Content *.git-credentials', 'type *.env',
    'type *.env.*', 'cat *.env', 'cat *.env.*', 'more *.env', 'more *.env.*',
    'git push --force*', 'git push -f*', 'git push * +*', 'git push --mirror*',
    'git push --delete*', 'git reset --hard*', 'git clean *', 'git filter-branch*',
    'git rebase*', 'git commit --amend*', 'git branch -D*', 'git restore*',
    'git checkout -- *', 'git checkout .', 'git stash drop*', 'git stash clear*',
    'Remove-Item -Recurse*', 'Remove-Item * -Recurse*', 'rm -rf*', 'rm -r *', 'rmdir /s*',
    'supabase db push*', 'supabase db reset --linked*', 'supabase db remote*',
    'supabase link*', 'supabase unlink*', 'supabase functions deploy*',
    'supabase projects*', 'supabase secrets*', 'psql *'].map((resource) => rule('shell', resource, 'ask')),
  rule('subagent', '*', 'deny'), rule('subagent', 'gymlvl-orchestrator', 'deny'),
  ...['flutter-specialist', 'supabase-specialist', 'exercise-catalog', 'ui-ux-specialist',
    'qa-reviewer', 'context-keeper'].map((resource) => rule('subagent', resource, 'allow')),
];

const alternateCommands = [
  'arbitrary-tool --anything', 'node -e "/* inert fixture */"', 'python -c "pass"',
  'powershell -Command "Write-Output fixture"', 'cmd /c echo fixture',
  'gc .env', 'Get-Content -LiteralPath .env -Raw', 'Get-Content secrets.jks -Raw',
  'Get-Content private_id_ed25519 -Raw', 'Get-Content .git-credentials -Raw',
  'Select-String -Path .env -Pattern token', 'type private.pem', 'cat private.p12',
  'more private.keystore', 'git push origin main --force', 'git push origin -f',
  'git -C app push --force', 'git push origin +main:main', 'git push origin --mirror',
  'git push origin --delete main', 'git reset HEAD --hard', 'git commit -a --amend',
  'git branch --delete --force fixture', 'Remove-Item fixture -Force -Recurse',
  'rm -fr fixture', 'supabase --workdir fixture db push', 'supabase db reset --debug --linked',
];

test('model follows documented matching, not shell parsing or substring matching', () => {
  assert.equal(matches('*.env', 'nested/private.env'), true);
  assert.equal(matches('x?z', 'xyz'), true);
  assert.equal(matches('x?z', 'xz'), false);
  assert.equal(matches('git status', 'prefix git status'), false);
  assert.equal(matches('DIR/*.ENV', 'dir\\private.env', true), true);
  assert.equal(matches('DIR/*.ENV', 'dir/private.env', false), false);
  assert.equal(matches('file[1]', 'file[1]'), true);
  assert.equal(matches('file[1]', 'file1'), false);
  const rules = [rule('shell', '*', 'ask'), rule('shell', 'git status *', 'allow')];
  assert.equal(resolve(rules, 'shell', 'git status'), 'allow');
  assert.equal(resolve(rules, 'shell', 'git status --short'), 'allow');
  assert.equal(resolve(rules, 'read', 'git status'), 'ask');
  assert.equal(resolve([...rules, rule('shell', 'git status', 'deny')], 'shell', 'git status'), 'deny');
  assert.equal(resolve([], 'shell', 'anything'), 'ask');
});

test('global policy retains all 73 ordered rules with only shell fallback changed', () => {
  assert.equal(original.length, 73);
  assert.deepEqual(config.permissions, original);
});

test('all seven agent definitions participate in effective policy', () => {
  assert.deepEqual(Object.keys(agents).sort(), [...developers, ...reviewers].sort());
});

for (const agent of developers) {
  test(`${agent}: alternate secret reader requires approval`, () => {
    assert.equal(effective(agent, 'shell', 'gc .env'), 'ask');
  });
  test(`${agent}: remote-first force-push spelling requires approval`, () => {
    assert.equal(effective(agent, 'shell', 'git push origin main --force'), 'ask');
  });
  test(`${agent}: arbitrary and alternate sensitive shell forms require approval`, () => {
    for (const command of alternateCommands) {
      assert.equal(effective(agent, 'shell', command), 'ask', command);
    }
  });
  test(`${agent}: safe routine commands request approval rather than denial`, () => {
    for (const command of ['git status', 'git diff --check', 'node --test tools/agent-tests/permission_policy.test.mjs',
      'flutter analyze', 'git commit -m fixture', 'git push origin main', 'supabase start']) {
      assert.equal(effective(agent, 'shell', command), 'ask', command);
    }
    assert.equal(effective(agent, 'edit', 'app/lib/fixture.dart'), 'allow');
  });
}

for (const agent of Object.keys(agents)) {
  test(`${agent}: original sensitive gates cannot become allow after agent append`, () => {
    for (const gate of original.filter((entry) => entry.effect === 'ask' && entry.resource !== '*')) {
      const fixture = gate.resource.replaceAll('*', 'fixture').replaceAll('?', 'x');
      assert.notEqual(effective(agent, gate.action, fixture), 'allow', `${gate.action}: ${fixture}`);
    }
    for (const path of ['.env', 'nested/.env.production', 'keys/private.pem', 'keys/private.p12',
      'keys/private.keystore', 'keys/private.jks', 'keys/id_rsa', 'keys/id_ed25519', 'user/.git-credentials']) {
      assert.equal(effective(agent, 'read', path), 'ask', path);
    }
    assert.equal(effective(agent, 'read', 'nested/.env.example'), 'allow');
    assert.equal(effective(agent, 'subagent', 'unknown-agent'), 'deny');
    assert.equal(effective(agent, 'subagent', 'gymlvl-orchestrator'), 'deny');
    for (const target of [...developers.filter((name) => name !== 'gymlvl-orchestrator'), ...reviewers]) {
      assert.equal(effective(agent, 'subagent', target), reviewers.includes(agent) ? 'deny' : 'allow');
    }
  });
}

for (const agent of reviewers) {
  test(`${agent}: read-only restrictions survive without broad secret-reader exceptions`, () => {
    assert.equal(effective(agent, 'edit', 'docs/fixture.md'), 'deny');
    assert.equal(effective(agent, 'shell', 'git status'), 'allow');
    assert.equal(effective(agent, 'shell', 'git branch'), 'allow');
    assert.equal(effective(agent, 'shell', 'git branch --list fixture'), 'allow');
    assert.equal(effective(agent, 'read', 'docs/fixture.md'), 'allow');
    for (const action of ['webfetch', 'websearch', 'external_directory']) {
      assert.equal(effective(agent, action, '*'), 'deny');
    }
    for (const command of [...alternateCommands, 'git branch -D fixture', 'git branch fixture',
      'Get-Content secret.jks', 'Get-Content private_id_ed25519', 'Get-Content .git-credentials',
      'Get-Content -Path ".env"', 'Select-String -LiteralPath private.pem -Pattern key']) {
      assert.equal(effective(agent, 'shell', command), 'deny', command);
    }
  });
}
