import assert from 'node:assert/strict';
import { mkdtemp, mkdir, readFile, rm, symlink, writeFile } from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { collectGenerated, compareGenerated } from './check.mjs';

async function fixture(t) {
  const root = await mkdtemp(path.join(os.tmpdir(), 'gymlvl-codegen-test-'));
  t.after(() => rm(root, { recursive: true, force: true }));
  return root;
}

async function put(root, relative, content) {
  const target = path.join(root, relative);
  await mkdir(path.dirname(target), { recursive: true });
  await writeFile(target, content);
  return target;
}

test('inventory includes generated outputs in each supported source root only', async (t) => {
  const root = await fixture(t);
  await put(root, 'lib/domain/model.g.dart', 'json\n');
  await put(root, 'lib/domain/model.freezed.dart', 'freezed\n');
  await put(root, 'test/helpers/fake.g.dart', 'fake\n');
  await put(root, 'integration_test/helpers/client.g.dart', 'client\n');
  await put(root, 'lib/domain/model.dart', 'source\n');
  await put(root, 'build/cache/stale.g.dart', 'ignored\n');
  await put(root, '.dart_tool/cache/stale.freezed.dart', 'ignored\n');
  const actual = await collectGenerated(root);
  assert.ok(actual instanceof Map);
  assert.deepEqual([...actual.keys()].sort(), [
    'integration_test/helpers/client.g.dart',
    'lib/domain/model.freezed.dart',
    'lib/domain/model.g.dart',
    'test/helpers/fake.g.dart',
  ]);
  assert.equal(actual.get('lib/domain/model.g.dart'), 'json\n');
});

test('an app without optional source roots has an empty generated inventory', async (t) => {
  assert.equal((await collectGenerated(await fixture(t))).size, 0);
});

test('comparison identifies modified, deleted, and unexpected generated outputs', () => {
  const before = new Map([
    ['lib/z.g.dart', 'before'],
    ['lib/a.freezed.dart', 'old'],
    ['lib/deleted.g.dart', 'keep'],
    ['lib/unchanged.g.dart', 'same'],
  ]);
  const after = new Map([
    ['lib/z.g.dart', 'after'],
    ['lib/a.freezed.dart', 'new'],
    ['lib/unexpected.g.dart', 'extra'],
    ['lib/unchanged.g.dart', 'same'],
  ]);
  assert.deepEqual(compareGenerated(before, after), {
    modified: ['lib/a.freezed.dart', 'lib/z.g.dart'],
    missing: ['lib/deleted.g.dart'],
    extra: ['lib/unexpected.g.dart'],
  });
});

test('comparison accepts CRLF versus LF but preserves meaningful whitespace differences', () => {
  assert.deepEqual(
    compareGenerated(new Map([['lib/a.g.dart', 'first\r\nsecond\r\n']]),
      new Map([['lib/a.g.dart', 'first\nsecond\n']])),
    { modified: [], missing: [], extra: [] },
  );
  assert.deepEqual(
    compareGenerated(new Map([['lib/a.g.dart', 'first\n']]),
      new Map([['lib/a.g.dart', 'first \n']])),
    { modified: ['lib/a.g.dart'], missing: [], extra: [] },
  );
});

test('collection is read-only and returns a detached snapshot', async (t) => {
  const root = await fixture(t);
  const target = await put(root, 'lib/a.g.dart', 'original\r\n');
  const before = await collectGenerated(root);
  assert.equal(await readFile(target, 'utf8'), 'original\r\n');
  await writeFile(target, 'changed\n');
  const after = await collectGenerated(root);
  assert.deepEqual(compareGenerated(before, after), {
    modified: ['lib/a.g.dart'], missing: [], extra: [],
  });
});

test('inventory rejects directory links escaping a source root', async (t) => {
  const root = await fixture(t);
  const external = await fixture(t);
  await put(external, 'secret.g.dart', 'must not read\n');
  await mkdir(path.join(root, 'lib'));
  await symlink(external, path.join(root, 'lib', 'escape'),
    process.platform === 'win32' ? 'junction' : 'dir');
  await assert.rejects(() => collectGenerated(root), /symlink|symbolic|link/i);
  assert.equal(await readFile(path.join(external, 'secret.g.dart'), 'utf8'), 'must not read\n');
});

test('inventory rejects a linked source root itself', async (t) => {
  const root = await fixture(t);
  const external = await fixture(t);
  await put(external, 'a.g.dart', 'external\n');
  await symlink(external, path.join(root, 'lib'),
    process.platform === 'win32' ? 'junction' : 'dir');
  await assert.rejects(() => collectGenerated(root), /symlink|symbolic|link/i);
});
