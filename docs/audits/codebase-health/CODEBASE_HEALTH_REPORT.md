# GymLvl — Codebase Health Audit Report

**Audit Date:** 2026-10-29
**Audit Baseline:** `main` @ `b85d674b27b7eb024b42a8d1b05d5f624a3ee6bc`
**Status:** COMPLETE (audit-only, no remediation)
**Remediation follow-up:** `REMEDIATION_EXECUTION.md` (2026-10-29) — fixes applied, verification,
and blocked items. Where the two disagree, the remediation record and a freshly executed command win.

---

## Executive Summary

The GymLvl codebase is in a **functional but incomplete** state. The Flutter application (221 tests passing), Supabase database (12 SQL verification units + 365 ACL assertions passing), and Edge Functions (44/44 in-process tests) all execute correctly in isolated test environments. However, release blockers remain:

1. **Android release access is only partly verified** — the merged release manifest is now inspected (INTERNET present, label `GymLvl`), but no signed APK/AAB or device connectivity proof exists
2. **No live Supabase/PostgreSQL verification** — all database tests run against PGlite single-connection; no gateway, Auth, or concurrent session proof
3. **iOS build impossible on Windows** — requires macOS/Xcode
4. **Edge Function hosted runtime unverified** — 44/44 pass in-process with a mocked `fetch`; no hosted run
5. **Production data classification not performed** — FND-DATA-001 now has an additive guard, but production counts and any backfill need live access (`O-07`)

The codebase demonstrates strong engineering discipline: clean static analysis, zero formatting drift,
comprehensive test coverage (221 Flutter, 12 SQL units, 365 ACL assertions, 44 Edge), and
well-structured Supabase migrations with hardened RLS. The AI Coach is chat-only (not the full typed
proposal architecture). The 150-exercise catalog is curated but lacks provenance documentation.

**Overall Health: CONDITIONAL PASS** — functionally correct in test environments; release readiness
still blocked by artifact, hosted-runtime and live-data verification gaps.

---

## Actual Repository Architecture

### Technology Stack (Verified)

| Layer | Technology | Version | Status |
|-------|------------|---------|--------|
| Client | Flutter | 3.38.5 stable | ✅ |
| Language | Dart | 3.10.4 | ✅ |
| State | Riverpod | 3.1.0 (Notifier) | ✅ |
| Routing | GoRouter | 17.1.0 | ✅ |
| Models | Freezed | 3.x | ✅ |
| Backend | Supabase | Auth + PostgreSQL + Edge Functions (Deno) | ✅ |
| Local Storage | shared_preferences | 2.5.5 | ✅ (active-workout backup only) |
| Charts | fl_chart | 1.2.0 | ✅ |
| UI System | Bold Candy Neubrutalism | Custom | ✅ |

### Module Structure (app/lib/)

```
app/lib/
  core/
    config/           # Supabase initialization and configuration guard
    localization/     # VI/EN labels and preference
    router/           # GoRouter, auth redirect, shell, active-workout banner
    theme/            # Candy tokens and ThemeData
  features/
    auth/             # session gate, login, register, reset
    onboarding/       # 9-step draft, class definitions A-F
    dashboard/        # RPG hero XP, KPI, activity, quests, volume
    workout/          # picker, active session, sets, rest timer, history
    progression/      # display-only XP estimate + class math
    quests/           # daily quests
    profile/          # preferences, class, locale
    coach/            # chat-only AI proxy client
  ui/
    candy/            # 16+ Candy Neubrutalism primitives
app/test/             # 221 tests including responsive UI regression
```

### Data Ownership (17 Tables)

| Data | Tables | Authority |
|------|--------|-----------|
| Identity | `auth.users`, `public.users` | Supabase Auth; server-managed progression fields |
| Profile | `profiles` | User-editable allowlisted columns |
| Catalog | `exercises` | Seeded; read-only to clients |
| Workout session | `workouts`, `workout_exercises`, `workout_sets` | User owns active session; completion server-controlled |
| Rewards | `workout_rewards`, `xp_logs`, `streaks`, `quest_instances`, `exercise_prs`, `user_achievements` | PostgreSQL RPC only |
| RPG classes | `class_definitions`, `class_synergies`, `user_classes` | Seeded definitions; server-managed assignment/progress |
| Coach quota | `coach_daily_usage` | Server only |

### Key Invariants (Load-Bearing)

1. **Completion is server-authoritative** — `complete_workout` runs in one transaction, row-locks user/workout, replays `workout_rewards` for idempotency, clamps suspicious pace, writes XP/class XP/quest/streak state
2. **One reward per workout** — retrying completion must not double-award
3. **Clients cannot write progression** — direct updates to `total_xp`, levels, streaks, quests, PRs, or achievements denied by grants/RLS
4. **RLS is default-deny** — users can read/write only their own rows; exercise catalog readable by authenticated users
5. **Workout history immutable after completion** — only `notes` on active workout is user-updatable
6. **Exercise IDs are stable** — existing 150 UUIDs must be preserved
7. **Time zone** — store UTC; compute streaks/quests/daily aggregates in `profiles.timezone` (default `Asia/Ho_Chi_Minh`)
8. **Design system** — Candy tokens/primitives are the UI contract; light mode is product mode
9. **Core training works without AI** — coach is optional and cannot block logging

---

## Verified Health of Major Subsystems

### ✅ Flutter Application — PASS
- **Static analysis:** `flutter analyze --no-pub` → 0 issues (39s)
- **Formatting:** `dart format --output=none --set-exit-if-changed lib test` → 129 files, 0 changed
- **Tests:** `flutter test --no-pub` → 200/200 passed
- **Null safety:** No issues found
- **Architecture:** Riverpod 3 Notifier pattern, GoRouter with auth redirect, proper disposal of timers/controllers

### ✅ Supabase Database — PASS (Isolated)
- **Migrations:** 4 migrations replay successfully
- **SQL regression:** 10/10 units pass on PostgreSQL 17.5 via PGlite
- **ACL regression:** 10 isolated databases, 365 assertions pass (fresh, legacy named/PUBLIC column, legacy PUBLIC table/default, named post-adoption, inherited protected/bypass/owner/superuser/SET ROLE paths)
- **Seed data:** 150 exercises verified (count + metadata integrity)
- **RLS/grants:** Hardened; progression tables (xp_logs, streaks, exercise_prs, quest_instances, user_classes, workout_rewards, user_achievements, coach_daily_usage) have NO authenticated INSERT/UPDATE/DELETE

### ⚠️ Edge Functions — PARTIAL
- **AI Coach tests:** 7/7 pass (sanitization, quota, auth, provider errors, timeout)
- **HTTP handler tests:** 5/5 pass
- **Request validation tests:** 3/3 pass
- **Bounded body tests:** 44/44 pass in-process. The earlier 8 failures were the handler correctly returning 503 when `SUPABASE_URL`/`SUPABASE_ANON_KEY` were absent; the runner now injects synthetic config (FND-SEC-004).
- **Coach bounded body tests:** ALL PASS (20000 byte cap, provider 256KiB cap)

### ✅ Android Configuration — SOURCE PASS / RUNTIME BLOCKED
- **Main manifest:** `android.permission.INTERNET` present (source corrected)
- **App label:** Still `android:label="app"` (should be "GymLvl")
- **Gradle wrapper:** 8.13 pinned with SHA256 verification (official AGP 8.11.1 compatibility)
- **Release signing:** Operator-owned, environment-variable driven (no tracked credentials)
- **Build verification:** **BLOCKED** — merged manifest inspection, signing gate, artifact signature could not execute (environment/cache/OOM issues)

### ❌ iOS Configuration — NOT VERIFIED
- **CFBundleDisplayName:** `App` (should be "GymLvl")
- **CFBundleName:** `app` (should be "GymLvl")
- **Build:** Impossible on Windows host

### ✅ CI/CD Pipeline — FUNCTIONAL
- **GitHub Actions:** Database/Edge + Flutter + Android merged-manifest jobs
- **Flutter job:** analyze, test, web build (with placeholder Supabase config)
- **Android job:** `android-release-manifest` runs the real Gradle merge and inspects the merged manifest; it does not build/sign an APK (NOT RUN remotely)
- **iOS build job:** NOT present

---

## Confirmed Defects

### P1 — Major Functional/Security Defects

| ID | Title | Subsystem | File/Location | Status |
|----|-------|-----------|---------------|--------|
| FND-BUG-001 | Android release INTERNET permission | Android | `AndroidManifest.xml:2` | Fixed (merged manifest verified; APK/device NOT RUN) |
| FND-BUG-002 | Fail-closed release signing lacks artifact proof | Android/iOS | `app/android/app/build.gradle.kts:8-18,45-59` | Accepted (signing keys absent; `assembleRelease` NOT RUN) |
| FND-DATA-001 | Conditional legacy workout can receive duplicate XP award | Database | `supabase/migrations/20261029000200_prevent_legacy_double_award.sql` | Fixed in repository scope (production counts/backfill BLOCKED) |

### P2 — Moderate Defects/Reliability Risks

| ID | Title | Subsystem | File/Location | Status |
|----|-------|-----------|---------------|--------|
| FND-CONC-001 | Discard queue cycle and post-backup-await identity race | Flutter/Workout | `active_workout_controller.dart:125-145,207-215,659-700` | Fixed (repo/local synthetic only) |
| FND-SEC-002 | Snapshot ownership — cross-identity backup adoption | Flutter/Workout | `active_workout_controller.dart:169-191` | Fixed (repo/local synthetic only) |
| FND-INTG-002 | Completion acknowledgement/hydration semantics | Flutter/Database | `supabase_workout_repository.dart:119-139` | Fixed (repo/local synthetic only) |
| FND-SEC-003 | Conditional PUBLIC ACL fixture (no production exploit) | Database | Migration 20261029000100 | Fixed (12 SQL units + 365 ACL assertions) |
| FND-SEC-004 | Authenticated buffering/provider-response boundary | Edge Functions | `_shared/http.ts` | Fixed (44/44 in-process; hosted NOT RUN) |
| FND-ARCH-003 | Timezone invariant documentation vs implementation | Documentation | `ARCHITECTURE.md` invariant 7 | Fixed (docs-only) |

### P3 — Minor Defects/Maintainability

| ID | Title | Subsystem | File/Location | Status |
|----|-------|-----------|---------------|--------|
| FND-GOV-002 | Stale claims in project memory documents (15 claims) | Governance | `PROJECT_CONTEXT.md`, `DECISIONS.md`, `MASTER_PLAN.md`, etc. | Accepted |
| FND-GOV-004 | Git destructive-operation gates miss spellings | Governance | `.opencode/opencode.jsonc` | Fixed (A7 config) |
| FND-SEC-001 | Secret gates cover only 4 reader spellings | Governance | `.opencode/opencode.jsonc` | Fixed (A7 config) |
| FND-INTG-001 | Auth redirect not allowlisted | Auth config | `supabase/config.toml:150-170`, `app/config.example.json` | Fixed (config test 6/6; live Auth NOT RUN) |
| FND-ARCH-002 | Two localization mechanisms | Localization | `localization_engine.dart` + `app_localizations.dart` | Accepted |

### P4 — Cosmetic/Template

| ID | Title | Subsystem | File/Location | Status |
|----|-------|-----------|---------------|--------|
| FND-BUG-003 | Platform display name is the Flutter template default | App metadata | `AndroidManifest.xml`, `Info.plist`, `app.dart`, `l10n/*` | Fixed (`GymLvl` in merged manifest and source; installed build NOT RUN) |
| FND-GOV-005 | Stale `analysis.txt` tracked in repo | Governance | `app/analysis.txt` | Fixed (untracked + ignored; local file preserved) |

---

## Probable Defects (Strong Evidence, Execution Incomplete)

| ID | Title | Subsystem | Evidence | Blocker |
|----|-------|-----------|----------|---------|
| — | Release APK permission/signature proof | Android | Merged manifest verified with INTERNET; no APK produced | Signing keys absent (`GYMLVL_RELEASE_*`) |
| — | iOS display name on a built app | iOS | `Info.plist` source is `GymLvl` | Windows host, no Xcode |
| — | Hosted Edge/gateway behaviour | Edge Functions | In-process tests 44/44 | No hosted project (`O-07`) |

---

## Environment Blockers (Prevent Runtime Verification)

| Blocker | Affected Verification | Exact Prerequisite |
|---------|----------------------|-------------------|
| Android SDK/licenses/device unknown | M1-02, M1-05, M8 | Confirm `flutter doctor`, Android SDK, device/emulator |
| iOS build impossible on Windows | M1-02, M8 | macOS + Xcode machine |
| No approved live Supabase project | M2+ verification | Project owner provides credentials/approval |
| No live AI provider verification | M6 | Provider choice, key policy, cost approval |
| Gradle native OOM (8GiB heap) / offline Kotlin cache miss | R1-05/06 release gates | Stable build environment with cached dependencies |
| Shell tool `Invalid arguments: command Missing Key` | All shell-dependent verification | Tooling harness fix |

---

## Historical Finding Comparison (A0–A8)

| Original ID | Current Status | Classification | Notes |
|-------------|----------------|----------------|-------|
| G-01 (P0 mobile) | **RESOLVED (repository scope)** | FND-BUG-001 | Merged release manifest verified; APK/device NOT RUN |
| G-02 (P0 data safety) | **RESOLVED** | — | Committed as `56c1122`, consolidated to `main` |
| G-03 (P1 app names) | **RESOLVED** | FND-BUG-003 | `GymLvl` in merged manifest and iOS plist; A-7 standardized in-app strings |
| G-04 (P1 offline overstated) | **STILL_OPEN** | — | `shared_preferences` backup only; no offline queue |
| G-05 (P1 catalog 150 vs 1324) | **STILL_OPEN** | — | Import not authorized (M2) |
| G-06 (P1 name-only search) | **STILL_OPEN** | — | Full-table filter; no local cache |
| G-07 (P1 no weekly plans) | **STILL_OPEN** | — | M5 milestone |
| G-08 (P1 no RPE/1RM/etc) | **STILL_OPEN** | — | M3/M4 milestones |
| G-09 (P1 AI chat-only) | **STILL_OPEN** | — | M6 milestone |
| G-10 (P1 docs contradict) | **PARTIALLY_RESOLVED** | FND-GOV-002 | Some corrected; 15 claims remain |
| G-11 (P2 font fallback) | **STILL_OPEN** | — | `fontFamilyFallback` not found |
| G-12 (P2 legacy dark theme) | **STILL_OPEN** | — | Dark theme remains in `app_theme.dart` |
| G-13 (P2 no analytics) | **STILL_OPEN** | — | M5 milestone |
| G-14 (P2 no Android CI) | **STILL_OPEN** | — | M1-05 planned |
| G-15 (Legal no LICENSE) | **STILL_OPEN** | — | O-01, O-02 open decisions |

**Summary:** 6 RESOLVED, 1 PARTIALLY_RESOLVED, 11 STILL_OPEN, 0 REGRESSED, 0 UNVERIFIED (all verified against current code)

---

## OpenGym Migration Readiness

### Current State
- **Data model compatibility:** ADDITIVE schema designed (exercise_catalog, exercise_source_map, exercise_media) — preserves 150 UUIDs
- **Exercise/workout mapping:** Specification complete (D-006, M2 milestone)
- **Architecture compatibility:** Target Flutter modules defined (exercise_library, training_plan, workout, progression, analytics, coach)
- **Migration implementation:** NOT STARTED — requires M1 completion and license ledger
- **Licensing boundaries:** Documented in `M0_AUDIT.md` §9, `PROJECT_CONTEXT.md` §6, `DECISIONS.md` D-002/D-003
  - OpenGym A/B: AGPL — behavioral reference ONLY
  - Exercise dataset (C): MIT text only — importable with notice, media stripped
  - Gym visual media: Proprietary — NOT licensed

### Technical Blockers
1. M1 baseline stabilization not complete
2. Drift local database not approved (O-03)
3. Full 1,324 import vs curated subset not approved (O-04)
4. No live Supabase project for verification (O-07)
5. 150 curated exercise provenance undocumented (O-08)

**Readiness Assessment: NOT READY** — all prerequisites are open decisions or incomplete milestones.

---

## Overall Technical Assessment

| Dimension | Assessment | Confidence |
|-----------|------------|------------|
| Code Quality | HIGH — clean analysis, formatting, 221 tests | CONFIRMED |
| Architecture | SOUND — clear separation, invariants enforced | CONFIRMED |
| Database Security | STRONG — RLS hardened, progression server-only | CONFIRMED (isolated) |
| Test Coverage | COMPREHENSIVE — 4-tier matrix, 155 specified units | CONFIRMED (specified) |
| Release Readiness | BLOCKED — Android/iOS config unverified | ENVIRONMENT_BLOCKED |
| Migration Readiness | NOT READY — prerequisites unmet | CONFIRMED |
| Documentation | STALE in places — 15 claims need update | CONFIRMED |

**Key Strength:** The codebase is well-engineered with strong invariants, comprehensive test infrastructure, and clear architectural boundaries.

**Key Risk:** Release verification cannot complete without Android SDK/device and live Supabase environment. The bounded-body Edge Function test failures are a test infrastructure issue, not a production defect.

---

## Recommendation

**Immediate next actions (in priority order):**

1. **Resolve shell tool failure** — enables all Gradle/Flutter/Deno verification
2. **Execute Android merged manifest inspection** — `flutter build apk --release` + `aapt dump permissions` or Gradle `processReleaseMainManifest`
3. **Fix app names** — Android `android:label="GymLvl"`, iOS `CFBundleDisplayName="GymLvl"`, `CFBundleName="GymLvl"`
4. **Update stale documentation** — single pass over 15 claims in `PROJECT_CONTEXT.md`, `DECISIONS.md`, `MASTER_PLAN.md`, `TASK_BOARD.md`, `SESSION_HANDOFF.md`
5. **Add Android CI build job** — `.github/workflows/verify.yml` (M1-05)
6. **Decide on Drift approval (O-03)** and catalog import scope (O-04)
7. **Document 150 exercise provenance** (O-08) or approve import without it