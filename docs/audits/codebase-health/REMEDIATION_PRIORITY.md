# GymLvl — Remediation Priority Plan

**Generated:** 2026-10-29
**Baseline:** `main` @ `b85d674b27b7eb024b42a8d1b05d5f624a3ee6bc`
**Scope:** Execution-oriented sequence for confirmed/probable defects only. No speculative work.

---

## Remediation Groups (Dependency-Ordered)

### Group 0 — Tooling Unblocker (Prerequisite for All Runtime Verification)
**Status 2026-10-29: RESOLVED.** Shell execution works in the current session; every command in
`REMEDIATION_EXECUTION.md` ran. The original blocker is preserved below for provenance.
**Original blocker:** Shell tool `Invalid arguments: command Missing Key` prevented command execution.

| Task | Acceptance | Verification |
|------|------------|--------------|
| Fix OpenCode shell tool invocation | `shell` tool executes commands successfully | `cd D:\Projects\gymlvl\app && flutter --version` → PASS |

---

### Group 1 — P0/P1 Release Blockers (Android/iOS Config)
**Depends on:** Group 0
**Independent:** Yes — can execute in parallel once shell works

#### 1.1 Android Merged Manifest Verification — DONE (manifest), APK OPEN
| Task | Acceptance | Verification |
|------|------------|--------------|
| Execute `:app:processReleaseMainManifest` | Merge succeeds | `PASS` — BUILD SUCCESSFUL (JDK 21, Gradle 8.13) |
| Inspect merged manifest | `INTERNET` direct child, package/label correct | `PASS` — gate `tools/android-verify/run.mjs`, 1 direct / 0 nested / 0 duplicate |
| Execute `flutter build apk --release` | Build completes, APK produced | `BLOCKED` — fail-closed signing keys absent (D-030) |

#### 1.2 Android App Name Correction — DONE
| Task | Acceptance | Verification |
|------|------------|--------------|
| Change `android:label="app"` → `android:label="GymLvl"` | Source manifest has correct label | `PASS` |
| Verify merged release manifest | Merged manifest shows `GymLvl` | `PASS` — `android:label="GymLvl"` in the merged manifest |

#### 1.3 iOS App Name Correction — DONE (source), BUILD OPEN
| Task | Acceptance | Verification |
|------|------------|--------------|
| Change `CFBundleDisplayName` → `GymLvl` | Source plist has correct name | `PASS` |
| Change `CFBundleName` → `GymLvl` | Source plist has correct name | `PASS` |
| Build verification | Installed app shows `GymLvl` | `NOT RUN` — Windows host, no Xcode |

#### 1.4 Add Android CI Job — DONE (job added), NOT RUN
| Task | Acceptance | Verification |
|------|------------|--------------|
| Add `android-release-manifest` job to `.github/workflows/verify.yml` | Job runs the real merge and inspects the manifest | Job added; `NOT RUN` on a remote runner |

---

### Group 2 — P1 Data Integrity (Database)
**Depends on:** Group 0 (for live verification)
**Independent:** Schema design can proceed; migration execution needs live DB approval

#### 2.1 FND-DATA-001 — Legacy Duplicate XP Guard — GUARD DONE, BACKFILL OPEN
| Task | Acceptance | Verification |
|------|------------|--------------|
| Additive guard: treat existing `xp_logs` award evidence as prior provenance | No second award, no fabricated reward row | `PASS` — `supabase/migrations/20261029000200_prevent_legacy_double_award.sql`; RED→GREEN regression |
| Reject the earlier true-flag-only backfill proposal | Guard must distinguish ledger-backed history without relying on `is_xp_calculated` | `PASS` — guard uses `xp_logs`; no backfill performed |
| Classify production history and any `workout_rewards` repair | Counts reviewed by the owner before any write | `BLOCKED` — live access (O-07) and operator approval |

**Note:** The guard does not infer an award from `users.total_xp` and does not mutate historical rows.

---

### Group 3 — P2 Fixed Items (Already Implemented, Need Runtime Validation)
**Depends on:** Group 0
**Status:** Code changes complete (R1-01, R1-02, R1-03, R2-06); only runtime verification blocked

| Finding | Implementation | Runtime Verification Needed |
|---------|----------------|------------------------------|
| FND-CONC-001 | Private cancel/context revalidation; 25 focused tests pass | Real concurrent session test (R1-04) |
| FND-SEC-002 | Owner-match snapshot; 31 tests pass including VI/EN rendered | Cross-identity backup adoption with real auth (R1-04) |
| FND-INTG-002 | Authoritative acknowledgement semantics; 18 tests pass | Barrier/commit-lost-ACK/reject/reload with real DB (R1-07) |
| FND-ARCH-003 | Documentation correction only (D-033) | SQL day-boundary tests for non-default zones (R1-07) |

**Action:** No code changes needed. Schedule verification when isolated PostgreSQL/Supabase stack available (R1-04/07).

---

### Group 4 — P2/P3 Configuration & Documentation (No Runtime Dependency)
**Independent:** Can execute immediately

#### 4.1 Documentation Truth Pass (FND-GOV-002)
| Task | Acceptance | Verification |
|------|------------|--------------|
| Update `PROJECT_CONTEXT.md` §2 baseline to self-updating rule + last SHA/date | No fixed SHA presented as current | Manual review |
| Update `DECISIONS.md` summary table through D-033 | All decisions listed | Table matches sections |
| Update `MASTER_PLAN.md`, `TASK_BOARD.md`, `SESSION_HANDOFF.md` stale claims | 15 claims corrected per A1 inventory | Cross-reference with `git rev-parse HEAD`, `git ls-files` |

#### 4.2 Permission Gate Hardening (FND-GOV-004, FND-SEC-001)
| Task | Acceptance | Verification |
|------|------------|--------------|
| Expand Git destructive-operation patterns in `.opencode/opencode.jsonc` | 18/18 probes gated (was 12/18) | `node gymlvl-perm-check.mjs` → PASS |
| Expand secret-read patterns (shell forms) | `cat .env`, `Get-Content .env` etc. gated | Same validator |
| **Requires approval** — configuration change | User confirms | Record in DECISIONS.md |

#### 4.3 Auth Redirect Allowlist (FND-INTG-001) — DONE
| Task | Acceptance | Verification |
|------|------------|--------------|
| Align `supabase/config.toml` site/redirect URLs with the documented `--web-port 8080` dev origin | Configured redirect is allowlisted; legacy `:3000` kept | `PASS` — `app/test/auth_redirect_config_test.dart` 6/6 |
| Live recovery round-trip | Email returns to the running app | `NOT RUN` — no local stack (O-07) |

#### 4.4 Localization Consolidation (FND-ARCH-002)
| Task | Acceptance | Verification |
|------|------------|--------------|
| Document ownership boundary between `LocalizationEngine` and `AppLocalizations` | Clear comment in both files | Code review |
| **Optional:** Consolidate to single mechanism | No duplicate locale state | `flutter analyze` clean |

#### 4.5 Cosmetic Fixes
| Task | Acceptance | Verification |
|------|------------|--------------|
| FND-BUG-003: platform/in-app display name → `GymLvl` | One user-facing spelling | `PASS` — merged manifest + iOS plist + A-7 strings |
| `pubspec.yaml` description consistency | Description matches product name | `PASS` |
| FND-GOV-005: Remove `app/analysis.txt` from tracking; add to `.gitignore` | File untracked; ignored | `PASS` — `git ls-files` empty, local file preserved |

---

### Group 5 — P2 Needs Verification (Require Live Environment)
**Depends on:** Group 0 + Live Supabase/PostgreSQL
**Cannot proceed without:** Approved live Supabase project (O-07)

| Finding | Required Verification |
|---------|----------------------|
| FND-SEC-004 | Edge function buffering order under load; DoS protection; network cancellation |
| FND-INTG-007 | Real Dart timed quest journey (device/timezone/locale matrix) |
| FND-DATA-001 production portion | Live cohort counts and any backfill; the repository guard is already implemented |

---

### Group 6 — Milestone Prerequisites (Decisions Required)
**Block future milestones. No code work until approved.**

| Decision | Blocks | Owner |
|----------|--------|-------|
| O-03: Approve Drift as local store | M3 (offline-first) | Project owner |
| O-04: Full 1,324 import vs curated subset | M2 (catalog import) | Project owner |
| O-05: AI provider and cost policy | M6 (AI PT v1) | Project owner |
| O-06: Android SDK/device availability | M1-02, M1-05, M8 | Project owner |
| O-07: Live Supabase project/credentials | M2+ verification | Project owner |
| O-08: 150 exercise provenance | Catalog trust / M2 | Project owner |
| O-09: Checkpoint tag name | M1-01 | Project owner |
| O-10: Apache-2.0 notice for context-window-management | Public release | Project owner |
| O-11: `.opencode/` + `docs/agent-system/` commit strategy | Next authorized commit | Project owner |

---

## Execution Sequence Summary

```
Group 0 (Tooling) → [PARALLEL: Group 1 (Android/iOS), Group 4 (Docs/Config)]
                                    ↓
                         Group 2 (Data Integrity) — needs live DB approval
                                    ↓
                         Group 3 (Runtime Validation) — needs isolated PG/Supabase stack
                                    ↓
                         Group 5 (Live Verification) — needs live Supabase project
                                    ↓
                         Group 6 (Decisions) — gates M2+
```

---

## Acceptance Criteria by Group

| Group | Criteria |
|-------|----------|
| 0 | Shell tool executes; `flutter --version` works |
| 1 | Android release APK has INTERNET; app names correct; CI builds Android |
| 2 | Guard implemented and regression-tested; production counts/backfill still need approval |
| 3 | R1-04/07 isolated stack tests pass (concurrent sessions, barrier, ACK loss) |
| 4 | 15 stale claims corrected; permission probes 18/18; auth redirect allowlist and config test pass |
| 5 | Live Supabase: SEC004 DoS, INTG007 quest journey, DATA001 cohort verified |
| 6 | All O-03 through O-11 decided and recorded in DECISIONS.md |

---

## Remaining Environment Prerequisites

| Prerequisite | Required For | Status |
|--------------|--------------|--------|
| Shell tool functional | All runtime verification | RESOLVED 2026-10-29 |
| Android SDK + device/emulator | Group 1.1, 1.2, 1.4 | NOT CONFIRMED |
| macOS + Xcode | Group 1.3 | IMPOSSIBLE ON WINDOWS |
| Live Supabase project (approved) | Group 2, 3, 5 | NOT PROVIDED |
| Isolated PostgreSQL/Supabase stack (Docker) | Group 3 | NOT AVAILABLE |
| Cached Gradle dependencies (no OOM) | Group 1.1 | PARTIAL — D:\gymlvl-a7-verification-20261029 created |

---

## What Should NOT Be Changed Yet

| Item | Reason |
|------|--------|
| Drift dependency addition | O-03 not approved |
| Catalog import (1,324 or subset) | M1 incomplete; O-04 not approved |
| AI Coach typed proposal architecture | M6; O-05 not approved |
| Exercise media pipeline | M7 gated; explicitly postponed (D-003) |
| AGPL code reuse | D-002; requires legal decision (O-01, O-02) |
| Production deployment | Explicitly NOT AUTHORIZED |
| Force push / history rewrite | D-009 / D-019 — requires explicit approval |
| Schema changes to progression tables | Server-authoritative invariant (D-008); additive migrations only |
| Weakening RLS/grants | Security regression would fail |
| Orbitron font removal | M1-03 planned; not yet authorized |