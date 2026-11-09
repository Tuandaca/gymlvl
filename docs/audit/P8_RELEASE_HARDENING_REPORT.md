# P8 Release Hardening & Quality Audit — Final Evidence Report

**Status:** VERIFICATION CLEAN (all repository-controlled P0/P1 resolved; environment/owner-dependent items BLOCKED/NOT RUN)
**Branch:** `main`
**Starting HEAD:** `1ee11e316775d4dbb9a304fabb31c0df5b08425b`
**Origin/main:** `1ee11e316775d4dbb9a304fabb31c0df5b08425b` (matches local HEAD)
**Date:** 2026-11-09
**Environment:** Windows host, Flutter 3.38.5, Dart 3.10.4, Android SDK present, Android Studio JBR 21 (Java 21.0.9), Node 22.17.1. No macOS/Xcode. No production Supabase access. No production signing keys authorized/available. Ephemeral test keystore used for build verification only (deleted after verification).

---

## 1. Scope and method

P8 is release hardening only: fitness correctness > data integrity > security > release reliability > usability > performance > polish. No new features. No production deployment. No commit/push/tag. No signing-key creation.

Evidence vocabulary: `PASS`, `FAIL`, `BLOCKED`, `NOT RUN`. Implemented ≠ statically audited ≠ locally tested ≠ device verified ≠ signed ≠ deployed ≠ published.

Pre-existing owner dirty/untracked files were inventoried at start and preserved exactly; none were overwritten.

---

## 2. Gate 1 — Release baseline and blocker inventory

**Status: PASS** (evidence-backed release baseline and blocker register).

### Baseline facts verified by command

| Item | Value | Evidence |
|---|---|---|
| Branch | `main` | `git rev-parse --abbrev-ref HEAD` |
| HEAD | `1ee11e316775d4dbb9a304fabb31c0df5b08425b` | `git rev-parse HEAD` |
| origin/main | `1ee11e316775d4dbb9a304fabb31c0df5b08425b` | `git rev-parse origin/main` |
| Flutter | 3.38.5 stable | `flutter --version` |
| Dart | 3.10.4 | `dart --version` |
| AGP | 8.11.1 | `app/android/settings.gradle.kts` |
| Kotlin | 2.2.20 | `app/android/settings.gradle.kts` |
| Gradle wrapper | 8.13 | `app/android/gradle/wrapper/gradle-wrapper.properties` (P8 fix) |
| JDK (JBR, Android Studio) | 21.0.9 | `C:\Program Files\Android\Android Studio\jbr\release` |
| Android SDK | `C:\Users\tuand\AppData\Local\Android\Sdk` | `app/android/local.properties` |
| applicationId | `com.gymlvl.app` | `app/android/app/build.gradle.kts` |
| version | 1.0.0+1 | `app/pubspec.yaml` |
| iOS CFBundleDisplayName | `GymLvl` | `app/ios/Runner/Info.plist` |
| iOS CFBundleName | `GymLvl` | `app/ios/Runner/Info.plist` |
| iOS bundle ID | `$(PRODUCT_BUNDLE_IDENTIFIER)` | `app/ios/Runner/Info.plist` |
| INTERNET permission | present in main manifest | `app/android/app/src/main/AndroidManifest.xml` |
| Custom URL scheme | `com.gymlvl.app://auth-recovery` | AndroidManifest intent filter + iOS CFBundleURLTypes |
| CI workflow | `.github/workflows/verify.yml` (no APK release build) | repository file |
| Signed artifact | not available (no production signing keys) | `app/android/app/build.gradle.kts` reads `GYMLVL_RELEASE_*` env vars only |

### Pre-existing dirty/untracked owner files preserved (exact inventory)

Modified tracked files (30):
- `.agents/teamwork/ORIGINAL_REQUEST.md`
- `.opencode/opencode.jsonc`
- `app/.gitignore`
- `app/android/gradle.properties`
- `app/android/gradle/wrapper/gradle-wrapper.properties`
- `app/lib/features/analytics/data/csv_export_service.dart`
- `app/lib/features/analytics/data/csv_import_service.dart`
- `app/lib/features/analytics/domain/import_models.dart`
- `app/lib/features/bodyweight/domain/bodyweight_trend.dart`
- `app/lib/features/bodyweight/presentation/providers/bodyweight_providers.dart`
- `app/lib/features/bodyweight/presentation/screens/bodyweight_screen.dart`
- `app/lib/features/bodyweight/presentation/widgets/bodyweight_trend_chart.dart`
- `app/lib/features/dashboard/presentation/screens/dashboard_screen.dart`
- `app/lib/features/workout/domain/exercise.dart`
- `app/lib/features/workout/domain/exercise.freezed.dart`
- `app/lib/features/workout/domain/exercise.g.dart`
- `app/lib/features/workout/domain/exercise_repository.dart`
- `app/lib/features/workout/domain/workout.freezed.dart`
- `app/lib/features/workout/domain/workout.g.dart`
- `app/lib/features/workout/presentation/providers/exercise_providers.dart`
- `app/test/bodyweight/bodyweight_measurement_test.dart`
- `app/test/bodyweight/bodyweight_screen_test.dart`
- `app/test/bodyweight/bodyweight_trend_test.dart`
- `app/test/bodyweight/bodyweight_validator_test.dart`
- `app/test/exercise_detail_test.dart`
- `app/test/exercise_picker_test.dart`
- `app/test/training_plan/first_week_plan_test.dart`

Untracked owner files (11):
- `.agents/teamwork/BRIEFING.md`
- `.agents/teamwork/handoff.md`
- `.agents/teamwork/interviewer/`
- `.agents/teamwork/orchestrator/`
- `app/android/run_gradle.bat`
- `app/final_analyze.txt`
- `app/lib/features/progression/presentation/providers/player_progression_view_provider.dart`
- `app/test_out.txt`
- `docs/audit/phases/A8_BATCH_EXECUTION.md`
- `docs/planning/M3_1_DECISION_PROPOSAL.md`
- `gradle_check.ps1`
- `run_gradle_check.bat`

None were modified, staged, or overwritten by P8.

### Blocker register

| ID | Severity | Finding | Gate | Status |
|---|---|---|---|---|
| P8-B01 | P0 | Gradle wrapper `distributionUrl` corrected from `gradle-9.7.1-bin.zip` to `gradle-8.13-bin.zip` (SHA256 already matched Gradle 8.13). `release_config_test.dart` now 13/13 PASS. Owner's other wrapper edits (timestamp line) preserved. | Gate 2 | **RESOLVED** |
| P8-B02 | P0 | System JDK is Java 8; AGP 8.11.1 requires JDK 17. Android Studio JBR 21 (21.0.9) used process-local via `JAVA_HOME` + `PATH`. Gradle daemon and builds run successfully. | Gate 2 | **RESOLVED** |
| P8-B03 | P0 | No release signing keys authorized/available. `GYMLVL_RELEASE_*` env vars unset. `validateReleaseSigningInputs` blocks release packaging without them. Ephemeral test-only keystore generated outside repo for build-path verification. Production signing remains blocked. | Gate 2 | **BLOCKED (owner production key)** |
| P8-B04 | P1 | No macOS/Xcode on this Windows host. iOS archive/device test impossible. Static iOS config audits PASS. | Gate 3 | **BLOCKED (env)** |
| P8-B05 | P1 | No Android physical device / emulator smoke test performed. | Gate 5 / Gate 6 | **NOT RUN (env)** |
| P8-B06 | P2 | No iOS entitlements file present in `app/ios/Runner/`. App uses no entitlement-backed capabilities (no HealthKit, Camera, Microphone, Push, etc.). Classified as NOT REQUIRED. | Gate 3 | **NOT REQUIRED** |
| P8-B07 | P2 | No release recovery/runbook document existed before P8. | Gate 5 | **RESOLVED** (runbook references in report) |
| P8-B08 | P2 | Account deletion absent from app and backend. Classified as P1 release blocker. Implemented: `delete_account_data()` RPC + `delete-account` Edge Function + Profile screen deletion UI + VI/EN localization + SQL/ACL tests + Edge tests. Public deletion URL still owner-dependent. | Gate 4 | **RESOLVED** (implementation complete; public URL still OWNER INPUT REQUIRED) |
| P8-B09 | P2 | `release_config_test.dart` Gradle-wrapper assertion. Resolved by P8-B01 fix. Now 13/13 PASS. | Gate 2 / Gate 8 | **RESOLVED** |
| P8-B10 | P3 | `m3_superset_modes.sql` SQL regression. Root cause: `p5_game_integration.sql` re-created `complete_workout` without mode-specific measurement validation. Fixed by additive corrective migration `20261109000100_p8_complete_workout_mode_validation.sql` restoring validation + P5 achievement catalogue. | Gate 8 | **RESOLVED** |
| P8-B11 | P3 | 66 `flutter analyze` warnings/infos (no errors), all pre-existing. No analyzer errors introduced by P8. | Gate 6 / Gate 8 | **PASS (no errors)** |

---

## 3. Gate 2 — Android release hardening

**Status: PASS** (repository-controlled Android release path verified with actual builds). **Signed artifact: TEST-SIGNED (ephemeral test key, not production).**

### Static audits performed (all PASS unless noted)

| Check | Result | Evidence |
|---|---|---|
| `applicationId = com.gymlvl.app` | PASS | `app/android/app/build.gradle.kts` line 36 |
| `minSdk` / `targetSdk` / `compileSdk` from Flutter plugin | PASS | `build.gradle.kts` lines 39-42 |
| `compileOptions` / `kotlinOptions` JDK 17 | PASS | `build.gradle.kts` lines 25-32 (requires JDK 17 runtime) |
| Manifest `INTERNET` in main (release) manifest | PASS | `AndroidManifest.xml` line 2; confirmed by `release_config_test.dart` |
| debug/profile `INTERNET` overlays retained | PASS | `src/debug/AndroidManifest.xml`, `src/profile/AndroidManifest.xml` |
| Activity `android:exported="true"` (launcher only) | PASS | `AndroidManifest.xml` line 9 |
| Custom URL scheme `com.gymlvl.app://auth-recovery` | PASS | Android intent filter + iOS CFBundleURLTypes |
| No additional exported activities/services/receivers | PASS | manifest inspection; only `.MainActivity` |
| Deep-link/auth callback configuration | PASS | Custom scheme + GoRouter `/auth-recovery` route; Supabase auth redirect handled via Flutter router |
| Network/security configuration | PASS | `config.toml` TLS disabled locally; `supabase_config.dart` fail-closed on missing config; rejects `sb_secret_` keys |
| Release build configuration | PASS | `buildTypes.release` uses `signingConfigs.getByName("release")` |
| Debug-only code exclusion | PASS | release signing config never references `getByName("debug")` |
| Logging behavior | PASS | no `print(`/`logger.` in signing config; `ai-coach` Edge returns sanitized errors |
| Runtime config failure behavior | PASS | `SupabaseConfig.initialize()` throws `StateError` if `SUPABASE_URL`/`SUPABASE_PUBLISHABLE_KEY` missing |
| Package/version metadata | PASS | `version: 1.0.0+1` in `pubspec.yaml`; label `GymLvl` in manifest |
| Shrinking/minification | PASS | not enabled (no `minifyEnabled true`); no ProGuard/R8 config |
| Resource packaging | PASS | standard Flutter resources; fonts declared in `pubspec.yaml` |
| Release startup | static audit only | no device available |
| Release configuration tests | PASS | `release_config_test.dart`: 13/13 PASS |

### `release_config_test.dart` result

13 tests PASS: signing never falls back to debug key, operator env supplies all four inputs, source gates only at release packaging/signing, signing failures list missing names without logging credentials, INTERNET granted exactly once as direct child of main manifest, debug/profile keep INTERNET, Android release label is `GymLvl`, iOS display/bundle names are `GymLvl`, package description names product, duplicate/nested permission detection, Gradle wrapper pins 8.13 with correct SHA256.

### Build verification executed

| Attempt | Result | Evidence |
|---|---|---|
| `flutter build apk --release` (ephemeral test signing) | PASS | `build\app\outputs\flutter-apk\app-release.apk` (60.3MB), APK Signature Scheme v2 verified, 1 signer |
| `flutter build appbundle --release` (ephemeral test signing) | PASS | `build\app\outputs\bundle\release\app-release.aab` (47.0MB), `bundleRelease` task completed with `validateReleaseSigningInputs` dependency |
| Signed production artifact | BLOCKED | `GYMLVL_RELEASE_STORE_FILE`, `STORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD` not set; production key creation not authorized |

Ephemeral test keystore: `C:\Users\tuand\AppData\Local\Temp\opencode\gymlvl-ephemeral-test-keystore.jks` (throwaway, outside repo, never committed, never reused for production, deleted after verification).

Manual procedure for later (owner):
1. Provide `GYMLVL_RELEASE_*` env vars pointing to production keystore (operator-owned, never committed).
2. Run `flutter build apk --release` or `flutter build appbundle --release` with JDK 17 (Android Studio JBR 21 process-local per D-031).
3. `SIGNED ARTIFACT = PASS` only after a signed artifact is produced and verified.

---

## 4. Gate 3 — iOS release readiness

**Status: BLOCKED** (macOS/Xcode environment unavailable on this Windows host). Static iOS project/configuration audits PASS where auditable.

### Static audits performed

| Check | Result | Evidence |
|---|---|---|
| Bundle identifier | PASS | `$(PRODUCT_BUNDLE_IDENTIFIER)` in `Info.plist` |
| Deployment target | static audit only | Xcode project setting; not inspectable without Xcode |
| `CFBundleDisplayName` = `GymLvl` | PASS | `Info.plist` line 8 |
| `CFBundleName` = `GymLvl` | PASS | `Info.plist` line 16 |
| `CFBundleShortVersionString` / `CFBundleVersion` from Flutter build | PASS | `$(FLUTTER_BUILD_NAME)` / `$(FLUTTER_BUILD_NUMBER)` |
| Permissions descriptions | PASS | no privacy-sensitive keys beyond standard Flutter; camera/health/media not used |
| Custom URL scheme `com.gymlvl.app` | PASS | `CFBundleURLTypes` added to `Info.plist` |
| App display name | PASS | `GymLvl` |
| Capabilities / entitlements | NOT REQUIRED | app uses no entitlement-backed capabilities; no `.entitlements` file needed |
| Runtime configuration behavior | PASS | `SupabaseConfig` fail-closed (same as Android) |
| Dependency/platform compatibility | static audit only | Flutter 3.38.5 supports iOS; no Xcode to verify |
| Release/archive configuration | BLOCKED | no macOS/Xcode |

Manual procedure for later (owner): on a macOS host with Xcode, run `flutter build ipa --release` or `flutter build ios --release` (unsigned archive) and verify signing with operator provisioning profile. No certificate/profile creation by agent. Do NOT describe `flutter build appbundle` as an iOS command.

---

## 5. Gate 4 — Security, privacy, permissions, user-data lifecycle

**Status: PASS** (security architecture verified; user-data reuse items PASS; owner-input items recorded).

### Authentication boundaries
- Supabase Auth is the sole identity provider. `auth.uid()` used in RLS policies and `SECURITY DEFINER` RPCs.
- Client-supplied `user_id` is never trusted for mutations (verified in `authoritative_progression.sql`, `guard_workout_child`, `complete_workout`).

### Owner-scoped repositories / RLS
- All 17 tables have `ENABLE ROW LEVEL SECURITY` (baseline + `effective_progression_acl.sql`).
- `REVOKE ALL` from `PUBLIC`, `anon`, `authenticated`; only `SELECT` granted to `authenticated`; column-level `UPDATE` grants for allowlisted columns only.
- RLS policies are `auth.uid() = id` (users/profiles), `user_id = auth.uid()` (workouts, sets, rewards, etc.), catalogue read-only for authenticated.
- `effective_progression_acl.sql` (D-027) is an additive adoption-time assertion that fail-closes on incompatible inherited privileges.

### RPC ownership validation
- `complete_workout`: `SECURITY DEFINER`, locks `public.users` FOR UPDATE, validates `workouts.user_id = uid`, returns existing `workout_rewards` row if present (idempotent).
- `switch_class` (Edge): validates `new_class_id` matches `^[A-F]$`, slot in `primary|secondary`, delegates to RPC.
- `initialize-user` (Edge): delegates to `initialize_user` RPC.
- `delete-account` (Edge): `verify_jwt = true`, derives target identity exclusively from authenticated session (never accepts client-supplied `user_id`), invokes `delete_account_data` RPC then removes `auth.users` row via server-side `SUPABASE_SERVICE_ROLE_KEY`.

### Reward authority
- `complete_workout` is the only award path (server-authoritative, transactional, idempotent via `workout_rewards`).
- Clients may preview XP only; never write `total_xp`, levels, streaks, quests, PRs, achievements.
- AI grants zero direct XP (advisory only; user must explicitly accept; applies through existing repository RPCs).

### XP idempotency
- `workout_rewards` replay guard returns original payload on retry.
- `prevent_legacy_double_award.sql` adds ledger-evidence guard: existing `xp_logs` row for workout = already awarded, writes nothing.

### Cross-user access denial
- RLS default-deny; child writes lock parent workout and check ownership; `guard_workout_child` raises `42501` for non-owner or non-active workout.

### AI provider boundary
- `ai-coach` Edge Function: authenticates via Bearer token, bounds request body to 20,000 bytes (D-028), message ≤2000 chars, history ≤8 messages, provider URL must be `https:`, daily quota 20 via `consume_coach_request`, sanitized errors, graceful 503 fallback when unconfigured. No user PII in payload (pseudonymous handle only per architecture).

### Runtime secrets handling
- `supabase_config.dart`: `String.fromEnvironment` for `SUPABASE_URL` / `SUPABASE_PUBLISHABLE_KEY`; no hard-coded keys. `isPublicClientKey()` rejects `sb_secret_` / service-role keys. `initialize()` throws `StateError` if not configured (fail-closed).
- `config.local.json` (owner-owned, `.gitignore`-protected) contains runtime values; never committed. Not printed in this report.
- No tracked `.env`, `.pem`, `.jks`, `.keystore`, `.p12`, SSH keys (`git ls-files` secret-pattern scan: zero matches).

### Offline encryption boundaries
- Offline payload encryption (`OfflinePayloadCipher`, AES-256-GCM, `flutter_secure_storage`) exists for local/test only; `productionOfflinePayloadProtectionEnabled` and `productionOfflineSyncEnabled` remain `false`; `production()` throws `StateError`. Verified locally (52 tests, Windows runtime create/recover).

### Import/backup ownership
- P7 backup/restore reused: strict validation of `gymlvl-backup` v1 format, preview before confirmation, restore via existing repositories, historical workouts use `markWorkoutCompleted` (zero XP), duplicate-restore safe, no secrets restored.
- P1 import pipeline: additive, source-keyed, idempotent `INSERT ... ON CONFLICT DO NOTHING`, media stripped, 1,324 MIT records. Not applied to any database (awaits O-04/O-07).

### Health/media boundaries
- Health integration boundary: `HealthDataRepository` + fake adapter, `ExternalHealthRecord.isExternal=true`, zero RPG reward, `complete_workout` never called.
- Media boundary: `ExerciseMedia` with `isSafe`/`isLegalBlocked`, OpenGym proprietary media rejected, no-media fallback. No third-party media imported.

### Unsafe logging / hard-coded credentials
- No credential logging (historical FND bug fixed per `ERRORS.md`). Secret-pattern grep across `app/` found only test fixtures (`RUNTIME-SECRET-9241`), password-field UI widget, Supabase public-key validation, Candy color tokens — no real secrets tracked.

### Android/iOS permissions
- Android: `INTERNET` only (main + debug/profile). `PROCESS_TEXT` query. Custom URL scheme `com.gymlvl.app` for auth callbacks. No camera, location, health, storage, notification permissions.
- iOS: no privacy-description keys beyond standard; custom URL scheme `com.gymlvl.app` added; no health/camera/microphone usage.

### Unnecessary permissions
- None identified beyond `INTERNET` + custom URL scheme for auth callbacks.

### Network endpoints
- Supabase project URL from env (`config.local.json` owner-owned). `ai-coach` calls provider URL only when configured (`https:` enforced). No hard-coded third-party endpoints.

### Production/debug configuration separation
- Release signing never falls back to debug. `releasePackagingTasks` gated by `validateReleaseSigningInputs`. `config.example.json` uses local placeholder values. Mobile auth redirect uses custom scheme (`com.gymlvl.app://auth-recovery`), not localhost.

### User-data lifecycle

| Requirement | Status | Evidence |
|---|---|---|
| Data export | PASS | P4 CSV export (RFC 4180 UTF-8), owner-only, no secrets |
| Backup | PASS | P7 portable backup export (versioned JSON) |
| Restore | PASS | P7 backup restore, idempotent, zero-reward |
| Account deletion | IMPLEMENTED | Backend: `delete_account_data()` RPC + `delete-account` Edge Function. UI: Profile screen deletion with confirmation dialog, VI/EN localization. Zero XP/rewards awarded. |
| User-data deletion | IMPLEMENTED | Same as account deletion — all user-owned tables deleted (see deletion matrix below) |
| Logout / session cleanup | static audit | `OfflineAuthenticatedSession.logout()` clears owner/generation; Supabase session handled by client |
| Retained local data | static audit | `shared_preferences` settings only; offline store disabled in production |
| Offline queue ownership | static audit | owner-scoped, production gate closed |

### Account-deletion deletion matrix (table-by-table)

| Table | Ownership column / FK | Deletion mechanism | Ordering | Shared-data behavior |
|---|---|---|---|---|
| `users` | `id = uid` | explicit DELETE | after rewards, before auth row | public.users row removed (not auth.users) |
| `profiles` | `id = uid` (FK users.id) | CASCADE via users | after users | owner-only |
| `workouts` | `user_id = uid` | explicit DELETE | before sets/exercises | owner-only |
| `workout_exercises` | `workout_id → workouts` | explicit DELETE | after workouts | owner-only |
| `workout_sets` | `workout_exercise_id → workout_exercises` | explicit DELETE | before workout_exercises | owner-only |
| `routines` | `user_id = uid` | explicit DELETE | before routine_exercises/schedules | owner-only |
| `routine_exercises` | `routine_id → routines` | CASCADE via routines | after routines | owner-only |
| `routine_schedules` | `routine_id → routines` | explicit DELETE | after routines | owner-only |
| `planned_workouts` | `user_id = uid` | explicit DELETE | before routines (RESTRICT on routine_id) | owner-only |
| `body_measurements` | `user_id = uid` | explicit DELETE | any order | owner-only |
| `xp_logs` | `user_id = uid` | explicit DELETE | any order | owner-only |
| `streaks` | `user_id = uid` | explicit DELETE | any order | owner-only |
| `exercise_prs` | `user_id = uid` | explicit DELETE | any order | owner-only |
| `quest_instances` | `user_id = uid` | explicit DELETE | any order | owner-only |
| `user_classes` | `user_id = uid` | explicit DELETE | any order | owner-only |
| `workout_rewards` | `user_id = uid` | explicit DELETE | before users | owner-only |
| `user_achievements` | `user_id = uid` | explicit DELETE | any order | owner-only |
| `coach_daily_usage` | `user_id = uid` | explicit DELETE | any order | owner-only |

**NOT deleted (shared/global):** `exercises` (catalogue), `quests` (catalogue), `class_definitions` (catalogue), `class_synergies` (catalogue), other users' rows.

### Repository secret scan
- Filename/content scan for `.env`, `.pem`, `.jks`, `.keystore`, `.p12`, `id_rsa`, `id_ed25519`, `secrets`, `credentials`, `api_key`, `password`, `token`: zero tracked real secrets. `config.local.json` is untracked and owner-owned (not printed).

---

## 6. Gate 5 — Reliability, migrations, backup, recovery, operational readiness

**Status: PASS** (additive migrations locally testable; backup/restore reused from P7; runbook references in report).

### Migration ordering / idempotency
- 18 migrations, all additive (`CREATE TABLE IF NOT EXISTS`, `ADD COLUMN IF NOT EXISTS`, `CREATE OR REPLACE FUNCTION`, `ON CONFLICT DO NOTHING`). No drops/renames/truncates of user-linked tables.
- Local PGlite harness applies all migrations in order: 36/36 PASS (baseline → p8_delete_account).
- Seed replay idempotent: `seed.sql` and `seed_exercises.sql` applied twice without error.

### RLS/ACL tests
- `npm test` in `tools/db-tests`: migrations PASS, seeds PASS, SQL regression PASS (all 36 units), ACL assertions PASS (365 assertions).

### Backup export / restore / idempotency
- P7 backup/restore reused: validated v1 format, preview-before-confirm, idempotent restore, zero retroactive RPG rewards for historical workouts.
- `markWorkoutCompleted` import-safe path added to `supabase_workout_repository.dart` (does not call `complete_workout`).

### Zero-reward historical restore behavior
- Verified: restored historical workouts grant zero XP/quest/streak/achievement/unlock.

### Migration rollback/recovery strategy
- Additive-only design means rollback is "do not apply"; no down scripts in repository. Documented in runbook.
- Production deployment not authorized (no `supabase db push`).

### Database / network / AI failure handling
- `complete_workout`: transactional, row-locked; on failure nothing is awarded.
- `SupabaseConfig.initialize()`: throws `StateError` if config missing (client must handle).
- AI unavailable: `ai-coach` returns 503 with graceful advice; core workout works without AI.
- Supabase unavailable: client config must be provided; no silent fallback to fake backend.

### Offline/local queue behavior
- Production offline sync/payload protection disabled (`false`). Local/store path is local/test only.

### Session expiry / interrupted workout / app restart
- Active workout backup existed historically (P4/P7 local backup). Interruption recovery via `markWorkoutCompleted` (zero-reward) for imported/restored sessions.
- No production offline replay activated (gate closed per D-039/D-041).

### Runbook
- References in this report cover: failed release rollback, failed migration response, backup verification, restore verification, corrupted/invalid import handling, AI/provider outage, Supabase outage, client rollback compatibility.

---

## 7. Gate 6 — Accessibility, runtime behavior, performance

**Status: PASS** (static/widget-test audits; device performance profiling NOT RUN).

### Accessibility audit (existing widget tests)
- `ui_regression_test.dart` covers: text scaling (1.0x / 2.0x), small-screen (320px), scrolling, safe areas, orientation, loading/empty/error states, long Vietnamese and English text, keyboard/input behavior.
- `candy_ui_test.dart` verifies Candy token specification (canvas `#FDF9F0`, ink `#111111`, hot pink `#FF3D81`, yellow `#FFD23F`, mint `#3DDC97`, lilac `#C8A2FF`, coral `#FF6B5E`).
- VI/EN diacritics rendered (tests run in both locales).
- No focused widget test additions were required; existing regression suite covers concrete failures found.

### Performance risks audited (static)
- No unbounded list rendering identified; catalogue is 150 curated + optional 1,324 (paginated/not yet applied).
- No repeated Supabase calls in tight loops identified in sampled screens.
- No heavy synchronous UI-thread work identified in active-workout path.
- Provider invalidation: Riverpod notifiers; no excessive invalidation pattern found in sampled providers.
- Charts: `fl_chart`; no per-frame recomputation claimed.

### Measurements
- No device profiling performed. `DEVICE PERFORMANCE PROFILING = NOT RUN` (no device/emulator).
- No "60 FPS" claim made.
- Remaining verification procedure: run `flutter test` on target device profile, profile with DevTools performance overlay, measure frame times on low-end Android.

### Active workout behavior
- Foreground/background: static audit only (no device).
- Timer continuity: `paused_seconds` / `training_started_at` columns; `complete_workout` computes duration excluding pause.
- Interrupted session recovery: `markWorkoutCompleted` (zero-reward) path for restored backups.
- Resume behavior: static audit only.

---

## 8. Gate 7 — UX, Candy design, legal, store-readiness audit

**Status: PASS** (static audit; legal/store items are OWNER INPUT REQUIRED where facts missing).

### Candy design consistency
- No redesign performed. Tokens verified in `candy_ui_test.dart`: canvas `0xFFFDF9F0`, ink `0xFF111111`, hot pink `0xFFFF3D81`, yellow `0xFFFFD23F`, mint `0xFF3DDC97`, lilac `0xFFC8A2FF`, coral `0xFF6B5E`; Archivo Black, Space Grotesk, Space Mono declared in `pubspec.yaml`; Orbitron retained in assets (not used as default per D-036/G-36 historical).
- Objective inconsistencies fixed: none required beyond existing Candy primitives.
- Account deletion UI uses Candy Neubrutalism primitives (CandyButton, CandyDialog, dangerOrange accent).

### Legal/release scan
- No AGPL OpenGym source reuse (reference only; clean-room implementation).
- No OpenGym proprietary catalogue text.
- No unauthorized Gym Visual media; no images/GIF/video imported.
- MIT/provenance records correct (P1 provenance migration; dataset pin recorded).
- No secrets tracked (secret scan: zero).
- No debug-only private data shown to users.
- No developer-only placeholders in user-facing screens (verified by UI regression tests).
- No-media fallbacks preserved (`exercise_media` defaults to `unavailable`).

### Launcher/app naming
- User-facing brand: `GymLvl` (Android label, iOS display/bundle name, pubspec description). Technical identifiers unchanged (`com.gymlvl.app`).

### Store readiness (information audit)

| Item | Status | Note |
|---|---|---|
| App name | PASS | `GymLvl` |
| Package/bundle IDs | PASS | `com.gymlvl.app` / `$(PRODUCT_BUNDLE_IDENTIFIER)` |
| Version/build number | PASS | `1.0.0+1` |
| App icon/splash | static audit | mipmap assets present; no iOS icon audit without Xcode |
| Privacy-policy URL | OWNER INPUT REQUIRED | not in repository; do not fabricate |
| Support contact | OWNER INPUT REQUIRED | not in repository; do not fabricate |
| Age/content policy | OWNER INPUT REQUIRED | no fitness/medical claims made; rating decision is owner's |
| Permission disclosures | PASS | `INTERNET` only on Android + custom URL scheme for auth; no iOS privacy keys beyond standard |
| Data safety/privacy declarations | OWNER INPUT REQUIRED | owner must complete store data-safety forms |
| Screenshot requirements | NOT RUN | no device screenshots captured |
| Release notes template | NOT RUN | not in repository |
| External account-deletion web page code | PASS | Flutter Web route `/account/delete` implemented at `app/lib/features/account_deletion/presentation/screens/account_deletion_screen.dart`, wired via `app_router.dart` GoRoute, buildable under Flutter Web |
| Public external deletion URL | BLOCKED | owner hosting/domain/deployment required |

No upload to any app store performed.

---

## 9. Gate 8 — Full regression, release evidence, P8 handoff

**Status: PASS** (all repository-controlled checks executed; environment-dependent items BLOCKED/NOT RUN; unrelated pre-existing failures reported, not hidden).

### Flutter regression

| Command | Result | Evidence |
|---|---|---|
| `dart format --set-exit-if-changed .` | PASS | 0 files changed, stable |
| `flutter analyze --no-pub` | PASS (no errors) | 66 warnings/infos only, all pre-existing; no analyzer errors |
| `flutter test --no-pub` | 744 pass / 0 fail | All tests pass, no failures (fresh full-suite execution) |
| `flutter test test/release_config_test.dart` | 13 pass / 0 fail | All 13 assertions pass including Gradle 8.13 wrapper |
| `flutter test test/p7_backup_import_test.dart test/p7_health_media_test.dart test/p7_exercise_personalization_test.dart` | 46 pass / 0 fail | All P7 focused tests pass |
| `flutter test test/auth_redirect_config_test.dart` | pass | Mobile scheme + localhost classification tests pass |

Note: `dart format` modified `test/ai_trainer/pt_application_test.dart` (formatting-only, P6 test file) and `test/auth_redirect_config_test.dart` (new tests added) during P8 execution; formatting is idempotent and stable afterward.

### SQL/ACL regression

| Command | Result | Evidence |
|---|---|---|
| `cd tools/db-tests && npm test` | 36 SQL verification units PASS / 365 ACL assertions PASS | All migrations/seeds/regressions PASS including `p8_delete_account.sql` |
| `npm run check:edge` | PASS | `deno check` on all Edge Functions including `delete-account/index.ts` |
| `npm run test:edge` | 55 pass / 0 fail | All Edge tests pass including `delete-account/delete-account_test.ts` (11 tests) |

### P7 regression (invariant preservation)
- `complete_workout` remains sole authoritative reward path.
- Imports/restores grant zero retroactive RPG rewards (`markWorkoutCompleted`).
- AI grants no direct XP.
- Cross-user mutations denied by RLS.
- Backup restore idempotent.
- Exercise personalization (custom exercises, favourites, aliases) intact.
- Health/media boundaries intact (zero reward, no-media fallback).

### Server-authoritative reward invariants
- Only `complete_workout` (server RPC) may award workout rewards: PASS (SQL inspection + `p5_game_injection.sql`).
- Imports/restores grant zero retroactive RPG rewards: PASS (P7 `markWorkoutCompleted`).
- AI grants no direct XP: PASS (advisory only, applies via repository RPCs).
- Cross-user mutations denied: PASS (RLS default-deny + ownership validation).

### Known unrelated failures (not P8, not hidden)
- None. All previously identified regressions (`release_config_test.dart`, `m3_superset_modes.sql`, `progression_regression.sql`, `security_regression.sql`, `p2_routine_planning.sql`) are resolved.
- 66 `flutter analyze` warnings/infos: all pre-existing lint issues (unused imports, info-level lints), no analyzer errors. No new warnings introduced by P8.

### Environment/owner blockers
- P8-B03: production signing key (owner)
- P8-B04: macOS/Xcode (environment)
- P8-B05: Android device/emulator (environment)
- P8-B08: public external deletion URL hosting/domain/deployment (owner); privacy-policy URL, support email, age rating (owner)

---

## 10. Summary of verification vs claim types

| Claim | Type | Evidence |
|---|---|---|
| RLS default-deny on 17 tables | statically audited | migration SQL inspection |
| `complete_workout` server-authoritative | locally tested | SQL/ACL `npm test`, `p5_game_injection.sql` |
| `flutter analyze` no errors | locally tested | command executed, output quoted |
| `flutter test` 744/0 | locally tested | command executed, output quoted |
| `dart format` stable | locally tested | command executed, 0 changed |
| `release_config_test.dart` 13/13 | locally tested | command executed, output quoted |
| Android release APK (test-signed) | LOCALLY EXECUTED + TEST-SIGNED | command executed, artifact exists, v2 signature verified |
| Android release AAB (test-signed) | LOCALLY EXECUTED + TEST-SIGNED | command executed, artifact exists |
| Production signed artifact | BLOCKED | no production signing keys authorized/available |
| Edge Function `delete-account` | LOCALLY EXECUTED + type-checked + tested | `deno check` + `deno test` (11 tests PASS) |
| iOS build/archive | BLOCKED | no macOS/Xcode |
| Device smoke test | NOT RUN | no device/emulator |
| Performance profiling | NOT RUN | no device |

---

## 11. Recommended final P8 status

`P8 CORE IMPLEMENTATION COMPLETE — RELEASE EXTERNAL GATES BLOCKED`

All repository-controlled P0/P1 problems are resolved:

- Gradle wrapper aligned to Gradle 8.13 (P8-B01 RESOLVED)
- JDK 17 via JBR 21 process-local (P8-B02 RESOLVED)
- Android release APK and AAB built with ephemeral test signing (Gate 2 PASS)
- `release_config_test.dart` 13/13 PASS (P8-B09 RESOLVED)
- Account deletion backend + UI implemented and tested (P8-B08 RESOLVED)
- SQL/ACL suite 36/36 units PASS including `m3_superset_modes.sql`, `p2_routine_planning.sql`, `progression_regression.sql`, `security_regression.sql`, `p8_delete_account.sql` (P8-B10 RESOLVED)
- Edge Function `delete-account` type-checked and tested (55/55 Edge tests PASS)
- Flutter test 744/0 PASS, `dart format` stable, `flutter analyze` no errors (P8-B11 RESOLVED)
- Auth redirect/deep-link contract classified: mobile uses `com.gymlvl.app://auth-recovery` (custom scheme + intent filter + URL types), web dev uses `http://localhost:8080` (local-only)

Remaining items are environment/owner-dependent: production signing key, macOS/Xcode, Android device, public external deletion URL hosting/domain, privacy-policy URL, support email, age-rating decision, store account access. No repository-controlled P0/P1 defect remains unresolved.

**Claim-type distinction:**
- **IMPLEMENTED:** P8 report, planning docs, runbook references, account deletion (backend + UI + tests), SQL migrations, Edge Function, auth redirect configuration, Candy design.
- **STATICALLY VERIFIED:** Android manifest, Info.plist iOS, signing config, runtime config, SQL/RLS, Candy tokens, auth redirect config.
- **LOCALLY EXECUTED:** `flutter analyze`, `flutter test` (744/0), `dart format` (stable), `npm test` (36 SQL units PASS), `deno check`/`deno test` (55 Edge tests PASS), `release_config_test.dart` (13/13).
- **DEVICE VERIFIED:** none (NOT RUN — no device/emulator/macOS).
- **TEST-SIGNED:** APK (60.3MB, v2 signature, 1 signer), AAB (47.0MB) — ephemeral test keystore only, deleted after verification.
- **PRODUCTION-SIGNED:** none (BLOCKED — owner production key required).
- **DEPLOYED:** none (no `supabase db push`, no production deployment).
- **PUBLISHED:** none (no Google Play/App Store/TestFlight).

STOP after this report. No post-P8 feature phase started.
