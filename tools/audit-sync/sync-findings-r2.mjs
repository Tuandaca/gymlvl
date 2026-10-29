// R2 canonical-register sync for docs/audit/FINDINGS_REGISTER.json.
//
// The register is a generated canonical data file with mixed formatting: findings
// are pretty-printed, top-level review objects are compact. This script therefore
// edits the JSON text surgically instead of re-serializing the whole document, so
// the diff stays inside the findings that actually changed.
//
// Usage:
//   node sync-findings-r2.mjs            # apply every update in this file
//   node sync-findings-r2.mjs FND-X-001  # apply only the listed ids
//
// Rules enforced here:
//   - every finding id that exists before the run still exists afterwards;
//   - no historical field is deleted (r2_review is appended, prior reviews stay);
//   - counts are recomputed from the resulting statuses, never hand-edited.
import { readFileSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const here = path.dirname(fileURLToPath(import.meta.url));
const registerPath = path.resolve(here, '../../docs/audit/FINDINGS_REGISTER.json');

const DATE = '2026-10-29';
const ENTRY_COMMIT = 'b85d674b27b7eb024b42a8d1b05d5f624a3ee6bc';

/** @type {Record<string, object>} */
const updates = {
  'FND-BUG-001': {
    status: 'Fixed',
    actual_behavior:
      'Fixed in repository scope: the merged release manifest produced by the real Gradle task ' +
      ':app:processReleaseMainManifest declares package com.gymlvl.app, android:label GymLvl with ' +
      'exactly one direct <manifest> android.permission.INTERNET and no nested or duplicate ' +
      'declaration. APK permission dump and installed-device connectivity remain NOT RUN.',
    related_tests: [
      'app/test/release_config_test.dart',
      'tools/android-verify/manifest-check.test.mjs',
      'tools/android-verify/run.mjs',
      '.github/workflows/verify.yml android-release-manifest job',
    ],
    missing_tests: [
      'APK permission dump (aapt) and installed-device backend connectivity NOT RUN',
      'The new android-release-manifest CI job is NOT RUN on a remote runner',
    ],
    r2_review: {
      date: DATE,
      round: 'R2',
      task: 'A-3',
      entry_commit: ENTRY_COMMIT,
      status_before: 'Accepted',
      status_after: 'Fixed',
      change:
        'Added tools/android-verify/run.mjs + manifest-check.mjs: run the real Gradle ' +
        ':app:processReleaseMainManifest and assert the merged manifest. Wired into ' +
        '.github/workflows/verify.yml as the android-release-manifest job. Source-level ' +
        'assertions in release_config_test.dart are retained but are no longer the only gate.',
      verification: [
        'gradlew :app:processReleaseMainManifest -> BUILD SUCCESSFUL (JDK 21, Gradle 8.13)',
        'node manifest-check.test.mjs -> 8/8 checks pass',
        'node run.mjs -> PASS merged release manifest: package=com.gymlvl.app label=GymLvl ' +
          'internet=1 nested=0 duplicates=0 (exit 0)',
      ],
      limits:
        'The merge task proves manifest content only. No release APK/AAB, no aapt permission ' +
        'dump, no signed artifact and no device connectivity. assembleRelease stays fail-closed ' +
        'without operator signing keys (D-030).',
    },
  },

  'FND-BUG-002': {
    r2_review: {
      date: DATE,
      round: 'R2',
      task: 'A-3 (adjacent)',
      entry_commit: ENTRY_COMMIT,
      status_before: 'Accepted',
      status_after: 'Accepted',
      change:
        'No signing change. The new merge gate runs :app:processReleaseMainManifest, which does ' +
        'not require signing inputs, so the fail-closed release configuration remains untouched.',
      verification: [
        ':app:processReleaseMainManifest -> BUILD SUCCESSFUL with no GYMLVL_RELEASE_* variables set',
        'app/android/app/build.gradle.kts still rejects a release build when any signing input is absent',
      ],
      limits:
        'assembleRelease, APK/AAB signing and signature verification remain BLOCKED on operator ' +
        'signing keys; no artifact proof exists in this session.',
    },
  },

  'FND-BUG-004': {
    actual_behavior:
      'Partially fixed: the profile identity and first edit field now resolve to readable ' +
      'ink-on-card contrast and a 200%-text assertion covers that pair. Seven other text nodes on ' +
      'the same screen still paint white or amber on a light card, and onboarding chip paints are ' +
      'still source-only, so the finding stays Accepted.',
    related_tests: ['app/test/ui_regression_test.dart'],
    r2_review: {
      date: DATE,
      round: 'R2',
      task: 'R2 profile contrast (partial)',
      entry_commit: ENTRY_COMMIT,
      status_before: 'Accepted',
      status_after: 'Accepted',
      change:
        'profile_screen.dart display name and edit TextField use AppTheme.textMain on ' +
        'AppTheme.panelBackground instead of Colors.white; ui_regression_test measures the real ' +
        'widget colours at 200% text.',
      verification: [
        'flutter test test/ui_regression_test.dart -> PASS ("profile identity and edit text meet ' +
          'contrast on the light card")',
      ],
      limits:
        'Residual nodes at profile_screen.dart:590,692,887,949,967,981 are listed for a separate ' +
        'contrast task and were not changed. Onboarding chip foreground/background stays ' +
        'unresolved. Not a whole-screen or all-state contrast certification.',
    },
  },

  'FND-BUG-006': {
    status: 'Fixed',
    actual_behavior:
      'Fixed in repository scope: unknown server reward and progress are nullable and hidden; ' +
      'dashboard, DailyQuestCard and CandyQuestCard no longer invent 35%, 350 or 100 values, and a ' +
      'completed quest alone renders full progress.',
    related_tests: [
      'app/test/quest_card_truthfulness_test.dart',
      'app/test/ui_regression_test.dart',
    ],
    missing_tests: ['Rendered quest cards against live server payloads NOT RUN'],
    r2_review: {
      date: DATE,
      round: 'R2',
      task: 'R2 quest truthfulness',
      entry_commit: ENTRY_COMMIT,
      status_before: 'Accepted',
      status_after: 'Fixed',
      change:
        'earnedXp/currentProgress/xpReward became nullable; unknown progress renders "- / target" ' +
        'and skips the bar; the claim label drops the amount; dashboard passes null instead of ' +
        '100/0.',
      verification: [
        'flutter test test/quest_card_truthfulness_test.dart -> 3/3 PASS',
        'flutter test test/ui_regression_test.dart -> PASS',
      ],
      limits: 'No live payload verification; the fix governs rendering of unknown values only.',
    },
  },

  'FND-BUG-007': {
    status: 'Fixed',
    actual_behavior:
      'Fixed in repository scope: /workout/summary redirects to /workout when no real summary ' +
      'context exists; the synthetic workout, +500 XP badge and LVL 1 / 0 / 1000 XP defaults were ' +
      'removed, and only receipt-provided level/XP values render.',
    related_tests: [
      'app/test/summary_truthfulness_test.dart',
      'app/test/navigation_integration_test.dart',
    ],
    missing_tests: ['Full authenticated deep-link journey against a live backend NOT RUN'],
    r2_review: {
      date: DATE,
      round: 'R2',
      task: 'R2 summary truthfulness',
      entry_commit: ENTRY_COMMIT,
      status_before: 'Accepted',
      status_after: 'Fixed',
      change:
        'hasWorkoutSummaryContext() guards the route redirect (D-034); earnedXp is int?; the level ' +
        'progress block renders only when xpResult exists; summary-preview/summary-default ' +
        'workouts and their fallbacks were deleted.',
      verification: ['flutter test test/summary_truthfulness_test.dart -> 5/5 PASS'],
      limits: 'No live receipt/deep-link verification; only the missing-context path is proven.',
    },
  },

  'FND-BUG-008': {
    status: 'Fixed',
    actual_behavior:
      'Fixed in repository scope: ResetPasswordScreen reports an error only after its own ' +
      'updatePassword submission (_submittedUpdate); a stale sign-in failure no longer appears at ' +
      'pristine recovery entry, while rejected and successful submits still report correctly.',
    related_tests: ['app/test/reset_password_entry_test.dart'],
    missing_tests: ['Live recovery email round-trip NOT RUN'],
    r2_review: {
      date: DATE,
      round: 'R2',
      task: 'R2 recovery entry error scoping',
      entry_commit: ENTRY_COMMIT,
      status_before: 'Accepted',
      status_after: 'Fixed',
      change:
        '_submittedUpdate is set immediately before updatePassword and the error panel renders only ' +
        'when _submittedUpdate && state.hasError.',
      verification: ['flutter test test/reset_password_entry_test.dart -> PASS'],
      limits: 'No live Supabase Auth recovery round-trip (no local stack / O-07).',
    },
  },

  'FND-BUG-009': {
    status: 'Fixed',
    actual_behavior:
      'Fixed in repository scope: an enabled CandyButton is focusable, shows a 3 px ink focus ' +
      'ring and activates once on Enter/Space through ActivateIntent; disabled buttons are skipped ' +
      'and pointer behaviour is unchanged.',
    related_tests: ['app/test/candy_button_keyboard_test.dart'],
    missing_tests: ['Screen-reader and physical-keyboard verification on a device NOT RUN'],
    r2_review: {
      date: DATE,
      round: 'R2',
      task: 'R2 keyboard-operable Candy primitive',
      entry_commit: ENTRY_COMMIT,
      status_before: 'Accepted',
      status_after: 'Fixed',
      change:
        'FocusableActionDetector wraps the existing GestureDetector; ActivateIntent maps Enter/' +
        'Space to onPressed; focus swaps the 2 px border for 3 px CandyColors.ink.',
      verification: [
        'flutter test test/candy_button_keyboard_test.dart -> 2/2 PASS (Tab/Enter/Space and ' +
          'pointer activation)',
      ],
      limits: 'Flutter test binding only; no device keyboard or assistive-technology run.',
    },
  },

  'FND-INTG-001': {
    status: 'Fixed',
    actual_behavior:
      'Fixed in repository scope: supabase/config.toml site_url is http://localhost:8080, with ' +
      'localhost, 127.0.0.1 and [::1] on port 8080 plus /** globs for the recovery query, and the ' +
      'legacy 127.0.0.1:3000 entries preserved. app/config.example.json and the documented run ' +
      'commands use --web-port 8080 and match the allowlist.',
    related_tests: ['app/test/auth_redirect_config_test.dart'],
    missing_tests: [
      'Live Supabase Auth recovery request with redirect_to=http://localhost:8080 and delivery of ' +
        'the returned email link NOT RUN (no local stack / O-07)',
    ],
    r2_review: {
      date: DATE,
      round: 'R2',
      task: 'A-2',
      entry_commit: ENTRY_COMMIT,
      status_before: 'Accepted',
      status_after: 'Fixed',
      change:
        'site_url/additional_redirect_urls realigned to the real Flutter web dev origin; ' +
        'config.example.json AUTH_REDIRECT_URL set to http://localhost:8080; README.md and ' +
        'docs/DEVELOPMENT.md run commands document --web-port 8080. No production values were ' +
        'invented.',
      verification: [
        'flutter test test/auth_redirect_config_test.dart -> 6/6 PASS (site_url, allowlist match, ' +
          'loopback origins, legacy :3000 preservation, /** globs, documented run commands)',
      ],
      limits:
        'Configuration contract only. No live Auth request, no email delivery, no production ' +
        'allowlist read. Native deep-link recovery remains unconfigured and is out of scope.',
    },
  },

  'FND-TEST-001': {
    related_tests: [
      'app/test/release_config_test.dart',
      '.github/workflows/verify.yml android-release-manifest job',
      'tools/android-verify/manifest-check.test.mjs',
    ],
    missing_tests: [
      'The new CI jobs are NOT RUN on a remote runner in this session',
      'Generated-file drift assertion',
      'Format gate is defined but was not added to the workflow in this batch',
    ],
    r2_review: {
      date: DATE,
      round: 'R2',
      task: 'A-3 (partial)',
      entry_commit: ENTRY_COMMIT,
      status_before: 'Accepted',
      status_after: 'Accepted',
      change:
        'release_config_test.dart source gate extended (label, plist, pubspec, INTERNET) and an ' +
        'android-release-manifest CI job now performs the real merge plus inspection.',
      verification: [
        'flutter test test/release_config_test.dart -> 13/13 PASS',
        'node manifest-check.test.mjs -> 8/8 PASS locally',
      ],
      limits:
        'No workflow execution in this session, so the CI gate is unproven end to end. Format and ' +
        'generated-code drift checks remain absent from the workflow.',
    },
  },

  'FND-DATA-001': {
    status: 'Fixed',
    actual_behavior:
      'Fixed in repository scope: complete_workout treats an existing xp_logs award row (source ' +
      'workout or quest) as prior-award provenance. A legacy completed false-flag tuple with prior ' +
      'credit/log now returns alreadyAwarded and writes no ledger, reward or class row, while a ' +
      'genuinely unawarded completed session still takes the normal award path. Production ' +
      'prevalence and missing-reward-row repair remain BLOCKED.',
    related_tests: ['supabase/tests/progression_regression.sql'],
    missing_tests: [
      'Production cohort counts and any workout_rewards backfill need live access (O-07) and ' +
        'operator approval; NOT RUN',
      'True two-connection scheduling NOT RUN (isolated single-connection PGlite)',
      'History with no ledger evidence cannot be distinguished from a legitimate unawarded session ' +
        'and is still awarded; an operator decision is required before any classification',
    ],
    r2_review: {
      date: DATE,
      round: 'R2',
      task: 'A-1',
      entry_commit: ENTRY_COMMIT,
      status_before: 'Accepted',
      status_after: 'Fixed',
      change:
        'Additive migration 20261029000200_prevent_legacy_double_award.sql re-creates ' +
        'complete_workout with one evidence-based guard (three added lines; the rest of the function ' +
        'is byte-identical) and adds idx_xp_logs_user_source. No row is deleted, rewritten or ' +
        'backfilled. The guard runs after the existing status/notes validation and before any award, ' +
        'under the existing users FOR UPDATE lock.',
      verification: [
        'RED without the migration: node tools/db-tests/run.mjs -> FAIL: ledger-only legacy workout ' +
          'never earns twice',
        'GREEN with the migration: node tools/db-tests/run.mjs -> PASS 12 SQL verification units ' +
          'and 365 ACL assertions (exit 0)',
        'covered cases: workout-source evidence, quest-source evidence, repeated retry, unchanged ' +
          'total_xp/xp_logs/user_classes, no fabricated workout_rewards row or is_xp_calculated flag, ' +
          'legitimate completed-unrewarded recovery still awards once',
      ],
      limits:
        'No production counts, no backfill, no live Supabase run and no true concurrent connection. ' +
        'switch_class still requires is_xp_calculated for ledger-only history; that recomputation was ' +
        'deliberately not changed here and is recorded as a separate operator decision.',
    },
  },

  'FND-BUG-003': {
    status: 'Fixed',
    actual_behavior:
      'Fixed in repository scope: the Android launcher label and the iOS display/name are GymLvl ' +
      '(observed as android:label="GymLvl" in the merged release manifest), and the in-app title, ' +
      'GYMLVL wordmarks, l10n appTitle and onboarding copy use the same spelling. Package, schema ' +
      'and auth identifiers are unchanged.',
    related_tests: [
      'app/test/release_config_test.dart',
      'app/test/widget_test.dart',
      'app/test/adversarial_edge_test.dart',
      'tools/android-verify/run.mjs',
    ],
    missing_tests: [
      'Launcher label and OS settings name on installed Android/iOS builds NOT RUN',
      'iOS build NOT RUN (Windows host)',
    ],
    r2_review: {
      date: DATE,
      round: 'R2',
      task: 'A-7',
      entry_commit: ENTRY_COMMIT,
      status_before: 'Accepted',
      status_after: 'Fixed',
      change:
        'Standardized every user-facing occurrence to GymLvl / GYMLVL: app.dart MaterialApp title, ' +
        'main.dart setup title and wordmark, main_shell_screen and auth_form wordmarks, l10n ' +
        'appTitle (arb + generated localizations), localization_engine new-player copy, README/' +
        'DEVELOPMENT headings and the CI workflow name. Technical identifiers (com.gymlvl.app, ' +
        'Supabase project id gymlvl, schema objects, env var names) were not renamed.',
      verification: [
        'Merged release manifest: android:label="GymLvl"',
        'flutter test test/widget_test.dart test/adversarial_edge_test.dart -> 31/31 PASS after the ' +
          'string change',
        'grep for GymLevel|GYMLEVEL across app/lib, app/test and .github -> no hits',
      ],
      limits:
        'The original finding expected the spelling GymLevel; the owner-approved A-7 scope ' +
        'supersedes it with GymLvl, and this register keeps that historical expectation. No ' +
        'installed-build or iOS verification. Web <title> comes from MaterialApp at runtime.',
    },
  },

  'FND-GOV-005': {
    status: 'Fixed',
    actual_behavior:
      'Fixed in repository scope: app/analysis.txt is untracked (git ls-files returns nothing), ' +
      'matched by app/.gitignore:48, and the 84,864-byte local copy is preserved on disk. No source, ' +
      'test, CI or script references it.',
    related_tests: [],
    missing_tests: [],
    r2_review: {
      date: DATE,
      round: 'R2',
      task: 'A-8',
      entry_commit: ENTRY_COMMIT,
      status_before: 'Accepted',
      status_after: 'Fixed',
      change:
        'git rm --cached app/analysis.txt (index only) plus an analysis.txt entry in app/.gitignore. ' +
        'The working-tree file is kept, so the stale transcript remains available locally.',
      verification: [
        'git ls-files app/analysis.txt -> empty',
        'Test-Path app/analysis.txt -> True, 84,864 bytes preserved',
        'git check-ignore -v app/analysis.txt -> app/.gitignore:48:analysis.txt',
        'grep analysis.txt across code/test/CI -> only audit and planning documents',
      ],
      limits:
        'The removal is staged in the index but not committed; publishing it requires an approved ' +
        'commit. Historical audit documents still describe the pre-fix state by design.',
    },
  },
};

const requested = new Set(process.argv.slice(2));
const text = readFileSync(registerPath, 'utf8');
const document = JSON.parse(text);

const knownIds = new Set(document.findings.map((finding) => finding.id));
for (const id of Object.keys(updates)) {
  if (!knownIds.has(id)) throw new Error(`Unknown finding id in update map: ${id}`);
}
for (const id of requested) {
  if (!updates[id]) throw new Error(`No update defined for requested id: ${id}`);
}

const selected = Object.keys(updates).filter((id) => requested.size === 0 || requested.has(id));

/** Return [start, end] text offsets of top-level objects inside an array value. */
function arrayItems(source, key) {
  const keyIndex = source.indexOf(`"${key}": [`);
  if (keyIndex < 0) throw new Error(`Array "${key}" not found`);
  let index = source.indexOf('[', keyIndex);
  const items = [];
  let depth = 0;
  let inString = false;
  let escaped = false;
  let itemStart = -1;
  for (; index < source.length; index += 1) {
    const char = source[index];
    if (inString) {
      if (escaped) escaped = false;
      else if (char === '\\') escaped = true;
      else if (char === '"') inString = false;
      continue;
    }
    if (char === '"') {
      inString = true;
      continue;
    }
    if (char === '[' || char === '{') {
      depth += 1;
      if (char === '{' && depth === 2 && itemStart < 0) itemStart = index;
      continue;
    }
    if (char === ']' || char === '}') {
      depth -= 1;
      if (char === '}' && depth === 1 && itemStart >= 0) {
        items.push([itemStart, index + 1]);
        itemStart = -1;
      }
      if (depth === 0) break;
    }
  }
  return items;
}

const indent = (json, prefix) => json.replace(/\n/g, `\n${prefix}`);

const replacements = [];
const beforeStatuses = [];
for (const [start, end] of arrayItems(text, 'findings')) {
  const original = text.slice(start, end);
  const finding = JSON.parse(original);
  if (!selected.includes(finding.id)) continue;
  const update = updates[finding.id];
  beforeStatuses.push(`${finding.id}:${finding.status}`);
  const merged = { ...finding, ...update };
  // Keep key order stable: status/related_tests/missing_tests already exist; r2_review is new.
  const serialized = indent(JSON.stringify(merged, null, 2), '    ');
  replacements.push({ start, end, value: serialized });
}

// Recompute counts from the post-update findings so they can never drift.
for (const replacement of replacements) {
  const finding = JSON.parse(replacement.value);
  const index = document.findings.findIndex((entry) => entry.id === finding.id);
  document.findings[index] = finding;
}
const countBy = (field, order) => {
  const tally = Object.fromEntries(order.map((value) => [value, 0]));
  for (const finding of document.findings) {
    tally[finding[field]] = (tally[finding[field]] ?? 0) + 1;
  }
  return tally;
};
document.counts = {
  total: document.findings.length,
  by_severity: countBy('severity', ['P0', 'P1', 'P2', 'P3', 'P4']),
  by_confidence: countBy('confidence', ['Confirmed', 'High', 'Medium', 'Low']),
  by_status: countBy('status', [
    'Open',
    'Needs Verification',
    'Accepted',
    'Fixed',
    'Deferred',
    'False Positive',
  ]),
};

const countsMatch = /"counts": \{/.exec(text);
if (!countsMatch) throw new Error('counts block not found');
const countsStart = text.indexOf('{', countsMatch.index);
let depth = 0;
let countsEnd = -1;
let inString = false;
let escaped = false;
for (let index = countsStart; index < text.length; index += 1) {
  const char = text[index];
  if (inString) {
    if (escaped) escaped = false;
    else if (char === '\\') escaped = true;
    else if (char === '"') inString = false;
    continue;
  }
  if (char === '"') inString = true;
  else if (char === '{') depth += 1;
  else if (char === '}') {
    depth -= 1;
    if (depth === 0) {
      countsEnd = index + 1;
      break;
    }
  }
}
if (countsEnd < 0) throw new Error('unterminated counts object');
replacements.push({
  start: countsStart,
  end: countsEnd,
  value: indent(JSON.stringify(document.counts, null, 2), '  '),
});

replacements.sort((a, b) => b.start - a.start);
let output = text;
for (const replacement of replacements) {
  output = output.slice(0, replacement.start) + replacement.value + output.slice(replacement.end);
}

// Round metadata lives at top level with two-space indentation. Per-finding
// r2_review objects are nested deeper, so the marker below is unambiguous.
const reviewMarker = '\n  "r2_review": ';
const parsed = JSON.parse(output);
if (parsed.r2_review === undefined) {
  parsed.r2_review = {
    date: DATE,
    round: 'R2',
    entry_commit: ENTRY_COMMIT,
    scope:
      'Controlled remediation A-1..A-8 approved by the owner on 2026-10-29. Statuses below record ' +
      'repository-scoped fixes with the quoted local verification; runtime/artifact/hosted gates ' +
      'remain NOT RUN or BLOCKED as stated per finding.',
    changed_findings: [],
    evidence_reference: 'docs/audits/codebase-health/REMEDIATION_EXECUTION.md',
    status_vocabulary: 'PASS / FAIL / BLOCKED / NOT RUN per AGENTS.md section 5',
    no_commit:
      'No commit, push, tag, deployment or production migration was performed by this batch.',
  };
}
parsed.r2_review.changed_findings = Array.from(
  new Set([...(parsed.r2_review.changed_findings ?? []), ...selected]),
);
const reviewJson = JSON.stringify(parsed.r2_review);

const markerIndex = output.indexOf(reviewMarker);
if (markerIndex < 0) {
  // First run: insert a new top-level key immediately before "findings".
  const anchor = '\n  "findings": [';
  const anchorIndex = output.indexOf(anchor);
  if (anchorIndex < 0) throw new Error('findings array anchor not found');
  output =
    output.slice(0, anchorIndex) +
    `${reviewMarker}${reviewJson},\n  "findings": [` +
    output.slice(anchorIndex + anchor.length);
} else {
  // Later runs: replace only the top-level r2_review value.
  const valueStart = output.indexOf('{', markerIndex);
  let depth = 0;
  let inString = false;
  let escaped = false;
  let valueEnd = -1;
  for (let index = valueStart; index < output.length; index += 1) {
    const char = output[index];
    if (inString) {
      if (escaped) escaped = false;
      else if (char === '\\') escaped = true;
      else if (char === '"') inString = false;
      continue;
    }
    if (char === '"') inString = true;
    else if (char === '{') depth += 1;
    else if (char === '}') {
      depth -= 1;
      if (depth === 0) {
        valueEnd = index + 1;
        break;
      }
    }
  }
  if (valueEnd < 0) throw new Error('unterminated r2_review object');
  output = output.slice(0, valueStart) + reviewJson + output.slice(valueEnd);
}

const finalDocument = JSON.parse(output);
writeFileSync(registerPath, output, 'utf8');

const statuses = finalDocument.counts.by_status;
console.log(`updated ${selected.length} finding(s): ${selected.join(', ')}`);
console.log(`before: ${beforeStatuses.join(', ')}`);
console.log(`findings: ${finalDocument.findings.length}`);
console.log(`by_status: ${JSON.stringify(statuses)}`);
