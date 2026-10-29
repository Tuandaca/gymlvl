# GymLvl — Remediation Execution Record

**Executed:** 2026-10-29
**Baseline:** `main` @ `b85d674b27b7eb024b42a8d1b05d5f624a3ee6bc` (dirty tree preserved: owner work +
this batch)
**Scope:** verification-first remediation of the confirmed findings in
`docs/audit/FINDINGS_REGISTER.json` (35 findings), one logical group at a time.
**Status vocabulary:** `PASS`, `FAIL`, `BLOCKED`, `NOT RUN` per `AGENTS.md` §5. Every result below was
produced by a command executed in this session; nothing is carried over from an earlier session.

---

## 1. Ground rules applied

| Rule | Application |
|---|---|
| Verify before editing | Each finding was re-read at source, and reproduced at runtime where possible, before any code change |
| One group at a time | Edits were grouped by finding; the affected test file(s) were run after each group |
| Smallest safe change | No refactors, no renames, no dependency changes, no formatting of untouched files |
| Preserve user work | Pre-existing dirty paths (`app/android/gradle.properties`, `docs/audit/*`, `docs/planning/ARCHITECTURE.md`, `docs/planning/DECISIONS.md`, `docs/planning/SESSION_HANDOFF.md`, `app/android/run_gradle.bat`, `gradle_check.ps1`, `run_gradle_check.bat`, `docs/audit/phases/A8_BATCH_EXECUTION.md`) were left untouched |
| No unapproved decisions | No migration, no `supabase/config.toml` change, no permission-config change, no commit/push/tag |

---

## 2. Verification baseline (this session)

| Check | Command | Result |
|---|---|---|
| Static analysis | `cd app; flutter analyze --no-pub` | `PASS` — `No issues found!` |
| Formatting | `cd app; dart format --output=none --set-exit-if-changed lib test` | `PASS` — 133 files, 0 changed |
| Flutter suite (entry) | `cd app; flutter test --no-pub` | `PASS` — 200/200 |
| Flutter suite (final) | `cd app; flutter test --no-pub` | `PASS` — `+215: All tests passed!` |
| SQL + ACL | `cd tools/db-tests; node run.mjs` | `PASS` — `11 SQL verification units`, `365 assertions` over `10 isolated databases` |
| Edge | `cd tools/db-tests; node edge-tests.mjs` | `PASS` — `44 passed | 0 failed` |

Environment limits that still bind every result:

- SQL runs on a single-connection PGlite PostgreSQL 17.5 instance — **not** a Supabase stack (no
  gateway, no PostgREST, no Auth service, no concurrent sessions).
- Edge tests run the handlers in-process under Deno with a mocked `fetch` — **not** the hosted Edge
  runtime.
- No Android SDK/Gradle build succeeds on this host; iOS cannot be built on Windows.

---

## 3. Finding-by-finding outcome

Legend: **Fixed** = code changed and regression test added in this session; **Verified as
non-defect** = the audit claim was reproduced/refuted without a product change; **BLOCKED** = needs a
prerequisite or approval; **Not re-verified** = untouched this session.

### 3.1 Fixed or partially fixed in this session (8 findings)

| Finding | Change | Regression coverage | Result |
|---|---|---|---|
| FND-BUG-003 | Android `android:label="GymLvl"`, iOS `CFBundleDisplayName`/`CFBundleName="GymLvl"`; pubspec description harmonized (consistency, not a canonical finding) | `app/test/release_config_test.dart` (label + plist assertions) | `PASS` — 3 added cases |
| FND-BUG-004 (partial) | Profile display name and edit field → `AppTheme.textMain` (was `Colors.white` on a light card) | `app/test/ui_regression_test.dart` — 200 %-text contrast assertion ≥ 4.5:1 | `PASS` — remaining legacy white-on-card text elsewhere on the screen is **not** fixed |
| FND-BUG-006 | Removed fabricated 35 % progress and the `350` / `100` XP fallbacks; progress and reward are nullable and hidden when unknown | `app/test/quest_card_truthfulness_test.dart` (3 cases) | `PASS` |
| FND-BUG-007 | `/workout/summary` redirects when there is no real summary context; synthetic workout, `+500 XP`, and the `LVL 1` / `0 / 1000 XP` level defaults removed (level and progress render only from receipt fields that exist) | `app/test/summary_truthfulness_test.dart` (5 cases) | `PASS` |
| FND-BUG-008 | `ResetPasswordScreen` reports errors only after its own submit (`_submittedUpdate`) | `app/test/reset_password_entry_test.dart` | `PASS` |
| FND-BUG-009 | `CandyButton` uses `FocusableActionDetector` + `ActivateIntent` + 3 px ink focus ring; disabled buttons skipped | `app/test/candy_button_keyboard_test.dart` (2 cases: Tab/Enter/Space + pointer, disabled skipped) | `PASS` |
| FND-SEC-004 | Diagnosed the 8 Edge failures as missing `SUPABASE_URL`/`SUPABASE_ANON_KEY`; the handler fails closed with 503. Runner now injects synthetic config when absent, so the suite is self-contained | `node edge-tests.mjs` | `PASS` — 44/44 (previously 36/44) |
| FND-TEST-001 (partial) | Source-level release-config gate extended (label, plist, pubspec, INTERNET) inside `release_config_test.dart` | `app/test/release_config_test.dart` — 13/13 | `PASS` — CI Android build job still **NOT RUN** / absent |

### 3.2 Reproduced, fix blocked (2 findings)

| Finding | Evidence collected this session | Why the fix is blocked |
|---|---|---|
| FND-DATA-001 | Isolated PGlite tuple (`status='completed'`, `is_xp_calculated=false`, no `workout_rewards` row, one prior `xp_logs` row of 100) receives a **second** award: `total_xp` 100 → 110, level 1 → 2, `workout_rewards` 0 → 1, `xp_logs` 1 → 3. Guard is at `supabase/migrations/20261026000200_authoritative_progression.sql:223-230` | Fix is an additive migration plus a live-data count/backfill decision. Requires owner approval and live Supabase access (`O-07`). No migration was written |
| FND-INTG-001 | Confirmed: `supabase/config.toml:154` `site_url = "http://127.0.0.1:3000"`, `:156` `additional_redirect_urls = ["https://127.0.0.1:3000"]`, while `app/config.example.json` and `main.dart:64` use `http://localhost:8080/` | Changing `supabase/config.toml` (Auth allowlist) is a configuration change requiring approval; the alternative is changing the documented dev port |

### 3.3 Verified as already fixed / non-defect (5 findings)

| Finding | Verification |
|---|---|
| FND-BUG-001 | `app/android/app/src/main/AndroidManifest.xml` declares `android.permission.INTERNET` as a direct `<manifest>` child; `release_config_test.dart` 13/13 `PASS`. **Merged** release manifest and APK permissions: `NOT RUN` (no Android build environment) |
| FND-SEC-002, FND-CONC-001, FND-INTG-002 | 61 focused tests across `workout_async_identity_test.dart`, `workout_snapshot_ownership_test.dart`, `workout_completion_reconciliation_test.dart` → `PASS`. Real multi-identity Auth persistence: `NOT RUN` |
| FND-SEC-003 | `node run.mjs` → 11 SQL units + 365 ACL assertions `PASS` (isolated PGlite, single connection) |

### 3.4 Not re-verified this session (18 findings)

`FND-ARCH-001` (False Positive), `FND-GOV-001`, `FND-GOV-002`, `FND-GOV-003` (False Positive),
`FND-GOV-004`, `FND-SEC-001`, `FND-BUG-005`, `FND-INTG-003`, `FND-INTG-004`, `FND-DATA-002`,
`FND-INTG-005`, `FND-INTG-006`, `FND-INTG-007`, `FND-INTG-008`, `FND-INTG-009`, `FND-ARCH-002`,
`FND-ARCH-003`, `FND-TEST-002`.

These retain their canonical status. No claim is made about them.

### 3.5 Checked and still open (1 finding)

| Finding | Evidence | Why it is not fixed |
|---|---|---|
| FND-GOV-005 | The canonical finding is about **`app/analysis.txt`**, not a root-level file. `git ls-files app/analysis.txt` → `app/analysis.txt`; the file exists (84,864 bytes) and is tracked | An earlier check of the wrong path (`git ls-files analysis.txt` → empty) was mis-read as a resolution. Removing a tracked file is a repository change, so it is proposed as approval item A-8 rather than performed silently |

---

## 4. Detail of the code changes

### FND-BUG-003 — product identity (canonical display-name finding)

- `app/android/app/src/main/AndroidManifest.xml`: `android:label="app"` → `"GymLvl"`.
- `app/ios/Runner/Info.plist`: `CFBundleDisplayName` `App` → `GymLvl`; `CFBundleName` `app` → `GymLvl`.
- `app/pubspec.yaml`: description `GymLevel: …` → `GymLvl: …` (consistency change; the pubspec
  description is not itself a canonical finding).
- Tests assert the three sources, not a built artifact. Canonical FND-BUG-002 is the separate
  fail-closed signing finding and remains `Accepted`.

### FND-BUG-007 — truthful workout summary

- `app/lib/features/workout/presentation/screens/workout_summary_screen.dart`:
  - new `hasWorkoutSummaryContext(Object?)` — true only for an already built summary screen, a
    `Workout`, or a map carrying a real `workout`.
  - `earnedXp` is `int?`; the `+XP` badge is rendered only when a receipt exists.
  - level progress block is rendered only when `xpResult != null`.
- `app/lib/core/router/app_router.dart`: `/workout/summary` has
  `redirect: hasWorkoutSummaryContext(state.extra) ? null : '/workout'`; the synthetic
  `summary-preview` / `summary-default` workouts and their fallbacks were deleted.
- Behavior consequence: a deep link with no context navigates back to `/workout` instead of showing a
  fake completed workout with 500 XP.

### FND-BUG-006 — truthful quest cards

- `app/lib/features/quests/presentation/widgets/daily_quest_card.dart`:
  - `earnedXp` is `int?`; the XP badge and the `ĐÃ NHẬN +n XP` label are omitted when unknown.
  - `progress` is `1.0` only for a completed quest, otherwise `null`; the progress bar is skipped.
- `app/lib/ui/candy/candy_quest_card.dart`: `currentProgress` and `xpReward` are `int?`;
  unknown progress renders `- / target`, the bar is skipped, and the claim label drops the amount.
- `app/lib/features/dashboard/presentation/screens/dashboard_screen.dart`: unknown reward and
  unknown progress are passed through as `null` instead of `100` / `0`.

### FND-BUG-008 — recovery entry error scoping

- `app/lib/features/auth/presentation/screens/reset_password_screen.dart`: added
  `_submittedUpdate`, set immediately before `updatePassword`, and the error panel renders only when
  `_submittedUpdate && state.hasError`.

### FND-BUG-009 — keyboard-operable Candy button

- `app/lib/ui/candy/candy_button.dart`: `FocusableActionDetector` wraps the existing
  `GestureDetector`; `ActivateIntent` maps Enter/Space to `onPressed`; `_hasFocus` swaps the 2 px
  border for 3 px `CandyColors.ink`; disabled buttons are excluded from focus traversal; pointer
  behavior is unchanged.

### FND-BUG-004 — profile contrast (partial)

- `app/lib/features/profile/presentation/screens/profile_screen.dart`: display-name `Text` and the
  edit `TextField` use `AppTheme.textMain` (`CandyColors.ink`) on `AppTheme.panelBackground`
  (`CandyColors.card`) instead of `Colors.white`.
- The 200 %-text test measures the real widget colours, not a replica.
- Residual (not fixed, outside this finding's stated pair): 7 text nodes on the same screen still
  paint white or amber on a light card — `profile_screen.dart:887, 949, 967, 981` (`Colors.white` on
  `panelBackground`), `:590` (section header on `AppTheme.background`), `:692` (`Colors.amber` on
  white). They are listed for a separate contrast task, not silently changed.

### FND-SEC-004 — Edge test runner configuration

- `tools/db-tests/edge-tests.mjs`: injects `SUPABASE_URL` / `SUPABASE_ANON_KEY` defaults when the
  environment does not provide them, while still honoring a real environment. `supabase/functions/_shared/http.ts`
  was not changed. Consequence: the config-absent 503 branch (`http.ts:24`) is no longer exercised by
  this suite, because the runner always supplies both variables and no test deletes them; the
  remaining suite covers other 503 paths (`databaseError`, coach provider failure).

---

## 5. Commands → results (final run)

| # | Command | Result |
|---|---|---|
| 1 | `cd app; flutter analyze --no-pub` | `PASS` — `No issues found!` |
| 2 | `cd app; dart format --output=none --set-exit-if-changed lib test` | `PASS` — `Formatted 133 files (0 changed)` |
| 3 | `cd app; flutter test --no-pub` | `PASS` — `+215: All tests passed!` |
| 4 | `cd tools/db-tests; node run.mjs` | `PASS` — `11 SQL verification units`, `effective ACL regression: 10 isolated databases, 365 assertions` |
| 5 | `cd tools/db-tests; node edge-tests.mjs` | `PASS` — `44 passed | 0 failed` |
| 6 | `git ls-files app/analysis.txt` | `FAIL` — returns `app/analysis.txt`; the file is still tracked, so FND-GOV-005 is **open** (approval item A-8) |
| 7 | `flutter build apk --release` + `aapt dump permissions` | `NOT RUN` — no working Android build/Gradle environment |
| 8 | iOS build | `NOT RUN` — Windows host, no Xcode |
| 9 | Live Supabase Auth/RLS/gateway/concurrency | `NOT RUN` — no approved project or credentials (`O-07`) |

Test-count note: 200 at entry → 215 at exit. The four new files add 11 cases (summary 5, reset 1,
keyboard 2, quest 3); `release_config_test.dart` gained 3; `ui_regression_test.dart` gained 1. Total
+15. `dart format` moved 129 → 133 files because four test files were added.

---

## 6. Change inventory (this session)

**Modified**

- `app/android/app/src/main/AndroidManifest.xml`
- `app/ios/Runner/Info.plist`
- `app/pubspec.yaml`
- `app/lib/core/router/app_router.dart`
- `app/lib/features/auth/presentation/screens/reset_password_screen.dart`
- `app/lib/features/dashboard/presentation/screens/dashboard_screen.dart`
- `app/lib/features/profile/presentation/screens/profile_screen.dart`
- `app/lib/features/quests/presentation/widgets/daily_quest_card.dart`
- `app/lib/features/workout/presentation/screens/workout_summary_screen.dart`
- `app/lib/ui/candy/candy_button.dart`
- `app/lib/ui/candy/candy_quest_card.dart`
- `app/test/release_config_test.dart`
- `app/test/ui_regression_test.dart`
- `tools/db-tests/edge-tests.mjs`

**Added**

- `app/test/summary_truthfulness_test.dart`
- `app/test/reset_password_entry_test.dart`
- `app/test/candy_button_keyboard_test.dart`
- `app/test/quest_card_truthfulness_test.dart`
- `docs/audits/codebase-health/REMEDIATION_EXECUTION.md` (this file)
- `docs/audits/codebase-health/FINDINGS_REGISTER.md` (rewritten, 35 findings reconciled)

**Documentation updated**

- `docs/planning/PROJECT_CONTEXT.md` (baseline + §4.1 session evidence + corrected §8 conflict rows)
- `docs/planning/DECISIONS.md` (D-034)
- `docs/planning/TASK_BOARD.md`, `docs/planning/SESSION_HANDOFF.md`, `docs/planning/CHANGELOG_AI.md`

**Untouched, preserved** — `app/android/gradle.properties`, `docs/audit/FINDINGS_REGISTER.json`,
`docs/audit/MASTER_FINDINGS.md`, `docs/planning/ARCHITECTURE.md`, `app/android/run_gradle.bat`,
`docs/audit/phases/A8_BATCH_EXECUTION.md`, `gradle_check.ps1`, `run_gradle_check.bat`.

---

## 7. Approvals required before the remaining work

> **R2 update (2026-10-29):** A-2, A-3, A-4, A-7 and A-8 were executed and locally verified; A-1 was
> implemented as an additive guard with production counts/backfill still blocked. The table below is
> preserved as the original approval request; see §8 for the executed evidence.

| # | Approval needed | Unblocks | Risk if skipped |
|---|---|---|---|
| A-1 | Additive migration `2026…_legacy_double_award_guard.sql` guarding `complete_workout` on pre-existing ledger/reward evidence, plus a read-only live count/backfill plan | FND-DATA-001 | Silent repeat awards to legacy users |
| A-2 | `supabase/config.toml` `site_url` / `additional_redirect_urls` realignment to the documented dev port | FND-INTG-001 | Local password recovery redirect is rejected by the Auth allowlist |
| A-3 | Permission-gate hardening in `.opencode/` (secret-read spellings, destructive git spellings) | FND-SEC-001, FND-GOV-004 | Under-specified gates; canonical JSON already marks them Fixed from an earlier session |
| A-4 | Canonical JSON status sync for the 9 findings changed this session (7 to Fixed, 2 partial notes); FND-GOV-005 stays Accepted **and open** until A-8 | Register accuracy | Markdown and JSON diverge on status |
| A-5 | Isolated PostgreSQL/Docker stack and an Android device/emulator | FND-INTG-008/009, FND-BUG-001 merged manifest, FND-INTG-007 | Runtime claims stay `NOT RUN` |
| A-6 | Live Supabase project and credentials | FND-SEC-004 hosted, FND-INTG-007 real journey, FND-DATA-001 cohort | No production evidence |
| A-7 | Brand string decision: launcher label is now `GymLvl`, while in-app wordmark/app title remain `GYMLEVEL`/`GymLevel` (`app.dart:21`, `main_shell_screen.dart:189`, `auth_form_screen.dart:116`, `l10n/*`). Pick one spelling, then either rename the UI strings or revert the platform labels | FND-BUG-002 residual, FND-BUG-003, brand consistency | Two spellings ship to users; A6 already deferred brand choice to the product owner |
| A-8 | Remove the tracked stale analyzer transcript `app/analysis.txt` (84,864 bytes, `git ls-files app/analysis.txt` confirms it is tracked) | FND-GOV-005 | Stale transcript stays in the repository; deleting a tracked file needs approval |

No commit, push, tag, migration, config change, or deployment was performed.

**Next action (historical):** await A-1…A-4, A-7, A-8; on approval, execute A-2 (smallest,
config-only) first, then A-1 with its read-only live count before any backfill.

---

## 8. R2 controlled remediation (2026-10-29)

**Entry:** `main` @ `b85d674b27b7eb024b42a8d1b05d5f624a3ee6bc`, dirty tree preserved (owner work + A8
batch). **Scope approved:** A-2, A-3, A-4, A-7, A-8 and conditional A-1.
**Not performed:** commit, push, tag, deployment, production migration, production backfill.

### 8.1 A-2 — Auth redirect allowlist (FND-INTG-001 → Fixed)

- `supabase/config.toml`: `site_url = "http://localhost:8080"`; `additional_redirect_urls` covers
  `localhost`, `127.0.0.1` and `[::1]` on port 8080 (exact + `/**` globs for the recovery `?code=`
  query) and keeps the legacy `:3000` entries.
- `app/config.example.json`: `AUTH_REDIRECT_URL = "http://localhost:8080"`.
- `README.md` / `docs/DEVELOPMENT.md`: documented run command uses `--web-port 8080`.
- New `app/test/auth_redirect_config_test.dart` parses the TOML and JSON and asserts the contract.
- `PASS` — `flutter test test/auth_redirect_config_test.dart` → 6/6.
- Limits: no live `POST /auth/v1/recover` round trip and no email delivery (`O-07`); native deep-link
  recovery is not configured.

### 8.2 A-3 — Android merged-release-manifest gate (FND-BUG-001 → Fixed)

- New `tools/android-verify/run.mjs` + `manifest-check.mjs` run the real Gradle
  `:app:processReleaseMainManifest` and assert the merged manifest (package, label, exactly one direct
  `<manifest>` INTERNET permission, no nested/duplicate declaration, balanced tags).
- New `tools/android-verify/manifest-check.test.mjs` fixtures; new `android-release-manifest` job in
  `.github/workflows/verify.yml`.
- `PASS` — `gradlew :app:processReleaseMainManifest` → `BUILD SUCCESSFUL` (JDK 21, Gradle 8.13).
- `PASS` — merged manifest `app/build/app/intermediates/merged_manifest/release/processReleaseMainManifest/AndroidManifest.xml`:
  `package="com.gymlvl.app"` (L3), `android:label="GymLvl"` (L38), direct `INTERNET` (L11).
- `PASS` — `node manifest-check.test.mjs` 8/8; `node run.mjs` → exit 0 with
  `PASS merged release manifest: package=com.gymlvl.app label=GymLvl internet=1 nested=0 duplicates=0`.
- Final-consistency check found the A-7 rename had joined the flutter job's `steps:` key and its first
  entry onto one line, which YAML cannot parse. Fixed and re-validated: a throwaway Dart script using
  `package:yaml` parsed the workflow (`jobs: database-and-edge, flutter, android-release-manifest`;
  flutter 7 steps, android 6 steps, db 6 steps). No permanent YAML check was added — that remains part
  of `FND-TEST-001`.
- Limits: no release APK/AAB, no `aapt dump permissions`, no signed artifact, no device connectivity;
  `assembleRelease` stays fail-closed without operator keys (D-030). The CI job is NOT RUN.

### 8.3 A-4 — Canonical register synchronization

- `tools/audit-sync/sync-findings-r2.mjs` edits `docs/audit/FINDINGS_REGISTER.json` surgically
  (only the changed finding objects and `counts`), preserves all 35 IDs and every historical field,
  and recomputes counts from the resulting statuses.
- 12 findings gained an `r2_review` block: BUG-001, BUG-002 (no status change), BUG-003, BUG-004
  (partial), BUG-006, BUG-007, BUG-008, BUG-009, INTG-001, TEST-001 (no status change), GOV-005 and
  DATA-001.
- Resulting counts: **Fixed 18 · Accepted 12 · Needs Verification 3 · False Positive 2 · total 35**
  (severity 0/3/24/6/2 and confidence 16/18/1/0 unchanged).
- `PASS` — JSON parses, IDs stable (35/35 unique), non-target objects deep-equal to the pre-run backup.

### 8.4 A-7 — Single user-facing brand spelling (FND-BUG-003 → Fixed)

- `GymLvl`/`GYMLVL` now used in `app.dart` (MaterialApp title), `main.dart` (setup title + wordmark),
  `main_shell_screen.dart` and `auth_form_screen.dart` wordmarks, `l10n` `appTitle` (arb + generated
  files), `localization_engine.dart` new-player copy, README/DEVELOPMENT headings and the CI workflow
  name. No package, Supabase project, schema, env or auth identifier was renamed.
- `PASS` — `flutter test test/widget_test.dart test/adversarial_edge_test.dart` → 31/31.
- `PASS` — no `GymLevel`/`GYMLEVEL` remains under `app/lib`, `app/test` or `.github`.
- Limits: installed Android/iOS launcher label and iOS build NOT RUN; the original expectation
  `GymLevel` is retained in the register as historical, superseded by D-036.

### 8.5 A-8 — `app/analysis.txt` untracked (FND-GOV-005 → Fixed)

- `git rm --cached app/analysis.txt` (index only; the 84,864-byte local file is preserved) and an
  `analysis.txt` entry in `app/.gitignore`.
- `PASS` — `git ls-files app/analysis.txt` → empty; `git check-ignore -v` → `app/.gitignore:48`.
- No source, test, CI or script referenced the file; only audit/planning documents describe it.
- Limits: the index change is staged, not committed.

### 8.6 A-1 — Duplicate-award guard (FND-DATA-001 → Fixed, repository scope)

- New additive migration `supabase/migrations/20261029000200_prevent_legacy_double_award.sql`:
  `CREATE OR REPLACE FUNCTION public.complete_workout(...)` with one evidence-based guard plus
  `CREATE INDEX IF NOT EXISTS idx_xp_logs_user_source ON public.xp_logs(user_id, source_id)`.
- Guard: if an `xp_logs` row for this workout already exists (`source` `workout` or `quest`,
  `source_id` = workout id), return the existing `alreadyAwarded` payload and write nothing. The guard
  runs after status/notes validation and before any award, under the existing `users` row lock.
- The function body is otherwise byte-identical to the source migration (verified by diff: 3 added
  lines only). No row is deleted, rewritten or backfilled; `users.total_xp` is never used to infer an
  award.
- `FAIL` (RED, migration absent) — `node run.mjs` → `FAIL: ledger-only legacy workout never earns twice`.
- `PASS` (GREEN, migration present) — `node run.mjs` → 12 SQL verification units, 365 ACL assertions,
  exit 0. New assertions cover workout-source and quest-source ledger evidence, a second retry,
  unchanged `total_xp`/`xp_logs`/`user_classes`, no fabricated `workout_rewards` row or
  `is_xp_calculated` flag, and legitimate completed-unrewarded recovery still awarding once.
- Concurrency: `complete_workout` already takes `FOR UPDATE` on `public.users` and the workout row, so
  calls for one user serialize; a retry observes either the reward row or the ledger row. True
  two-connection scheduling NOT RUN (PGlite is single-connection).
- Still blocked (operator decision, `O-07`): production counts, classification of ambiguous history,
  and any `workout_rewards` backfill. `switch_class` still requires `is_xp_calculated` for ledger-only
  history; that recomputation was deliberately not changed.

Read-only queries prepared for the operator (NOT RUN — no live project):

```sql
-- At-risk sessions: completed, false flag, no reward row, but ledger evidence exists.
SELECT count(*) AS at_risk
FROM public.workouts w
WHERE w.status = 'completed'
  AND coalesce(w.is_xp_calculated, false) = false
  AND NOT EXISTS (SELECT 1 FROM public.workout_rewards r WHERE r.workout_id = w.id)
  AND EXISTS (
    SELECT 1 FROM public.xp_logs l
    WHERE l.user_id = w.user_id AND l.source_id = w.id::text AND l.source IN ('workout','quest')
  );

-- Sessions whose ledger already contains more than one main award (possible past double award).
SELECT user_id, source_id, count(*) AS awards
FROM public.xp_logs
WHERE source IN ('workout','quest') AND source_id IS NOT NULL
GROUP BY user_id, source_id
HAVING count(*) > 1;
```

### 8.7 Final R2 gates (all executed at `b85d674` + this batch)

| # | Command | Result |
|---|---|---|
| 1 | `cd app; flutter analyze --no-pub` | `PASS` — `No issues found!` (exit 0) |
| 2 | `cd app; dart format --output=none --set-exit-if-changed lib test` | `PASS` — 134 files, 0 changed (exit 0) |
| 3 | `cd app; flutter test --no-pub` | `PASS` — `+221: All tests passed!` (exit 0) |
| 4 | `cd tools/db-tests; node run.mjs` | `PASS` — 12 SQL units, 365 ACL assertions (exit 0) |
| 5 | `cd tools/db-tests; node edge-tests.mjs` | `PASS` — 44/44 (exit 0) |
| 6 | `node tools/android-verify/manifest-check.test.mjs` | `PASS` — 8/8 (exit 0) |
| 7 | `node tools/android-verify/run.mjs` | `PASS` — merged release manifest verified (exit 0) |
| 7a | Workflow YAML parse (`package:yaml`, throwaway script) | `PASS` — 3 jobs, step lists loaded |
| 8 | `flutter build apk --release` / iOS build | `NOT RUN` — signing keys absent / Windows host |
| 9 | Live Supabase Auth, RLS, gateway, concurrency | `NOT RUN` — no approved project (`O-07`) |
| 10 | CI workflow (`android-release-manifest`, flutter job) | `NOT RUN` — no remote run |

### 8.8 R2 change inventory

**Modified:** `supabase/config.toml`, `app/config.example.json`, `README.md`, `docs/DEVELOPMENT.md`,
`supabase/tests/progression_regression.sql`, `app/lib/app.dart`, `app/lib/main.dart`,
`app/lib/core/router/main_shell_screen.dart`,
`app/lib/features/auth/presentation/screens/auth_form_screen.dart`,
`app/lib/core/localization/localization_engine.dart`, `app/lib/l10n/app_en.arb`,
`app/lib/l10n/app_vi.arb`, `app/lib/l10n/app_localizations.dart`,
`app/lib/l10n/app_localizations_en.dart`, `app/lib/l10n/app_localizations_vi.dart`,
`app/test/widget_test.dart`, `app/test/adversarial_edge_test.dart`, `.github/workflows/verify.yml`,
`app/.gitignore`, `docs/audit/FINDINGS_REGISTER.json`, `docs/audit/MASTER_FINDINGS.md`,
`docs/audits/codebase-health/*`, `docs/planning/*`.

**Added:** `app/test/auth_redirect_config_test.dart`, `tools/android-verify/{manifest-check.mjs,run.mjs,manifest-check.test.mjs,package.json}`,
`tools/audit-sync/sync-findings-r2.mjs`,
`supabase/migrations/20261029000200_prevent_legacy_double_award.sql`.

**Untracked (index only):** `app/analysis.txt` (local file preserved, now git-ignored).

**Next action:** operator decides on `O-07` access and the read-only at-risk counts before any
backfill; separately approve a commit of this batch and a remote CI run.

---

## 9. R2 finalization — commit preparation and CI status (2026-10-29)

**State: `READY_FOR_APPROVAL`.** No commit, push, remote workflow run, deployment or live database
access was performed. Verification below was executed in this finalization pass at
`main` @ `b85d674` with the working tree unchanged otherwise.

### 9.1 Repository safety

| Check | Result |
|---|---|
| Branch / HEAD | `main` / `b85d674b27b7eb024b42a8d1b05d5f624a3ee6bc` |
| Remote state | `git ls-remote origin refs/heads/main` → `b85d674…`; local equals remote, nothing pushed |
| Index | Only `app/analysis.txt` (A-8) staged: `git diff --cached --numstat` → `- -` |
| Working tree | 63 paths: 19 = prior A-8 batch, 39 = R2, 5 = excluded owner/ambiguous artifacts |
| `app/analysis.txt` | exists locally (84,864 bytes), matched by `app/.gitignore:48` |
| Secrets scan | `git diff -U0` + new tool/docs files grepped for `service_role`, `sk-*`, `AKIA*`, private-key headers → no hits |
| Binaries / generated output | no `build/`, `.apk`, `.aab`, `.dill` or `.dart_tool` paths in status; new untracked files are text (2.7–27 KB) |
| Excluded (owner / ambiguous) | `app/android/gradle.properties` (`-Xmx8G`→`-Xmx2g`, not required by this batch), `app/android/run_gradle.bat`, `gradle_check.ps1`, `run_gradle_check.bat`, `docs/audit/phases/A8_BATCH_EXECUTION.md` |

### 9.2 Local gates (re-executed in this pass)

| # | Command | Result |
|---|---|---|
| 1 | `cd app; flutter analyze --no-pub` | `PASS` — `No issues found!` (exit 0) |
| 2 | `cd app; dart format --output=none --set-exit-if-changed lib test` | `PASS` — 134 files, 0 changed (exit 0) |
| 3 | `cd app; flutter test --no-pub` | `PASS` — `+221: All tests passed!` (exit 0) |
| 4 | `cd tools/db-tests; node run.mjs` | `PASS` — 12 SQL units, 365 ACL assertions (exit 0) |
| 5 | `cd tools/db-tests; node edge-tests.mjs` | `PASS` — 44 passed / 0 failed (exit 0) |
| 6 | `node tools/android-verify/manifest-check.test.mjs` | `PASS` — 8/8 (exit 0) |
| 7 | `node tools/android-verify/run.mjs` | `PASS` — `package=com.gymlvl.app label=GymLvl internet=1 nested=0 duplicates=0` (exit 0) |
| 8 | `loadYaml(.github/workflows/verify.yml)` via `package:yaml` | `PASS` — 3 jobs (`database-and-edge` 6 steps, `flutter` 7, `android-release-manifest` 6) |
| 9 | Register integrity (`node -e`) | `PASS` — 35 findings, 35 unique IDs, Fixed 18 / Accepted 12 / NV 3 / FP 2 |

### 9.3 CI observation at the current HEAD (read-only)

`gh run list` shows the workflow is red at `b85d674`, before any of this batch lands:

| Run | Head | Conclusion | Detail |
|---|---|---|---|
| `40798076003` | `b85d674` | **failure** | `flutter` job success; `database-and-edge` failed at `npm run test:edge` |
| `40746581864` | A7 B0 | failure | same class (pre-batch) |
| `40737281388`, `40737074747`, `40731805765` | A6 | success | baseline was green |

Root cause of the current red run (quoted from the job log):

```
RPC UTF-8 byte overflow rejected with missing/lying length=undefined => bounded_body_test.ts:64:10
error: Error: Expected 413, got 503
```

Eight RPC bounded-body tests fail because the hosted handler resolves `SUPABASE_URL` /
`SUPABASE_ANON_KEY` from the environment and fails closed with 503. This is a CI-environment gap, not
an application defect, and it is exactly what the uncommitted `tools/db-tests/edge-tests.mjs`
synthetic-environment change addresses (44/44 locally). The remote result for that change is
**PENDING_APPROVAL** — it can only be observed after the commit is pushed.

### 9.4 Proposed commit set (not executed)

**Commit A — prior A-8 batch, prerequisite for A-3's assertions**
`fix(app): release metadata, quest/summary truthfulness, and recovery error scoping`

19 files: `app/android/app/src/main/AndroidManifest.xml`, `app/ios/Runner/Info.plist`,
`app/pubspec.yaml`, `app/lib/core/router/app_router.dart`,
`app/lib/features/auth/presentation/screens/reset_password_screen.dart`,
`app/lib/features/dashboard/presentation/screens/dashboard_screen.dart`,
`app/lib/features/profile/presentation/screens/profile_screen.dart`,
`app/lib/features/quests/presentation/widgets/daily_quest_card.dart`,
`app/lib/features/workout/presentation/screens/workout_summary_screen.dart`,
`app/lib/ui/candy/candy_button.dart`, `app/lib/ui/candy/candy_quest_card.dart`,
`app/test/release_config_test.dart`, `app/test/ui_regression_test.dart`,
`app/test/{summary_truthfulness,reset_password_entry,candy_button_keyboard,quest_card_truthfulness}_test.dart`,
`tools/db-tests/edge-tests.mjs`, `docs/planning/ARCHITECTURE.md`.
Evidence: the A8 session (215/215 at that checkpoint); not re-executed as an isolated tree now.

**Commit B — this R2 batch**
`fix(auth,ci,db): R2 — redirect allowlist, manifest gate, GymLvl branding, ledger guard`
`+ docs(audit): sync canonical register to 18 Fixed / 12 Accepted`

39 files: `supabase/config.toml`, `supabase/tests/progression_regression.sql`,
`supabase/migrations/20261029000200_prevent_legacy_double_award.sql`, `app/config.example.json`,
`README.md`, `app/README.md`, `docs/DEVELOPMENT.md`, `.github/workflows/verify.yml`,
`app/.gitignore`, `app/analysis.txt` (deletion), `app/lib/{app.dart,main.dart}`,
`app/lib/core/router/main_shell_screen.dart`,
`app/lib/features/auth/presentation/screens/auth_form_screen.dart`,
`app/lib/core/localization/localization_engine.dart`, `app/lib/l10n/*` (5),
`app/test/{widget_test,adversarial_edge_test,auth_redirect_config_test}.dart`,
`tools/android-verify/*` (4), `tools/audit-sync/sync-findings-r2.mjs`,
`docs/audit/{FINDINGS_REGISTER.json,MASTER_FINDINGS.md}`,
`docs/audits/codebase-health/*` (4),
`docs/planning/{DECISIONS,PROJECT_CONTEXT,TASK_BOARD,SESSION_HANDOFF,CHANGELOG_AI}.md`.
Evidence: §9.2 (this tree), §8.7.

Exclusion rationale: the five excluded paths are owner/ambiguous or unrelated to R2; leaving
`gradle.properties` alone keeps the owner's JVM tuning decision intact.

### 9.5 Live-data readiness (nothing executed against production)

The two §8.6 queries were syntax-checked read-only against the isolated PGlite schema built from the
same migrations: `PASS q1 at-risk cohort: rows=1 {"at_risk":0}`, `PASS q2 duplicate ledger: rows=0`.
They are `SELECT`-only, take no row locks beyond `ACCESS SHARE`, and expose counts only. Run them in a
read-only transaction with a statement timeout, e.g.:

```sql
BEGIN READ ONLY;
SET LOCAL statement_timeout = '30s';
-- q1 / q2 from §8.6
ROLLBACK;
```

`q2` scans `xp_logs` without `idx_xp_logs_user_source` on production (that index ships with the
migration), so run it off-peak. Interpretation: `q1` = sessions whose ledger already proves an award
but which lack a reward row/flag — the population the new guard now protects; `q2` = ledger rows that
already contain more than one award for the same workout/quest — possible historical double awards.
Neither query classifies ambiguous history or authorizes a backfill.

### 9.6 Approvals still required

1. Approve the exact two-commit manifest in §9.4 (no push implied).
2. Approve the push that triggers remote CI, then let the run be observed end to end.
3. Provide `O-07` access/authorization for the read-only counts; any `workout_rewards` repair is a
   separate, later approval.

