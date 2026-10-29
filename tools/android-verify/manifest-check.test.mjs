import {
  analyzeManifest,
  assertReleaseManifest,
  manifestProblems,
} from './manifest-check.mjs';

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
    throw new Error(`${label}: expected ${expected}, got ${actual}`);
  }
}
function throws(fn, label) {
  try {
    fn();
  } catch {
    return;
  }
  throw new Error(`${label}: expected a failure`);
}

const valid = `<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.gymlvl.app">
    <uses-permission android:name="android.permission.INTERNET" />
    <application android:label="GymLvl" android:name="\${applicationName}">
        <activity android:name=".MainActivity" />
    </application>
</manifest>`;

const nested = `<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.gymlvl.app">
    <application android:label="GymLvl">
        <uses-permission android:name="android.permission.INTERNET" />
    </application>
</manifest>`;

const duplicated = `<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.gymlvl.app">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.INTERNET" />
    <application android:label="GymLvl" />
</manifest>`;

const missing = `<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.gymlvl.app">
    <application android:label="GymLvl" />
</manifest>`;

const placeholderLabel = `<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.gymlvl.app">
    <uses-permission android:name="android.permission.INTERNET" />
    <application android:label="app" />
</manifest>`;

check('accepts a merged manifest with one direct INTERNET permission', () => {
  const report = assertReleaseManifest(valid);
  equal(report.directInternet, 1, 'direct INTERNET');
  equal(report.nestedInternet, 0, 'nested INTERNET');
  equal(report.label, 'GymLvl', 'label');
});

check('ignores the xml declaration and comments', () => {
  const report = analyzeManifest(
    `<!-- generated -->\n${valid.replace('<?xml version="1.0" encoding="utf-8"?>', '')}`,
  );
  equal(report.directInternet, 1, 'direct INTERNET');
});

check('rejects INTERNET nested under <application>', () => {
  const report = analyzeManifest(nested);
  equal(report.directInternet, 0, 'direct INTERNET');
  equal(report.nestedInternet, 1, 'nested INTERNET');
  throws(() => assertReleaseManifest(nested), 'nested INTERNET');
});

check('rejects duplicate INTERNET declarations', () => {
  const report = analyzeManifest(duplicated);
  equal(report.duplicates, 1, 'duplicates');
  throws(() => assertReleaseManifest(duplicated), 'duplicate INTERNET');
});

check('rejects a manifest without INTERNET', () => {
  throws(() => assertReleaseManifest(missing), 'missing INTERNET');
});

check('rejects the placeholder app label', () => {
  throws(() => assertReleaseManifest(placeholderLabel), 'placeholder label');
});

check('rejects an unbalanced manifest', () => {
  throws(
    () => analyzeManifest('<manifest><application></manifest>'),
    'unbalanced manifest',
  );
});

check('reports every problem at once', () => {
  const problems = manifestProblems(
    analyzeManifest(`<manifest package="wrong"><application android:label="app" /></manifest>`),
  );
  equal(problems.length, 3, 'problem count');
});

if (failures > 0) {
  console.error(`${failures} manifest-check test(s) failed`);
  process.exitCode = 1;
} else {
  console.log('all manifest-check tests passed');
}
