# GymLvl — Findings Register

**Generated:** 2026-10-29 (R2 local pass; R3 local pass; remote CI for R3 changes **pending owner approval**, not yet observed)
**Baseline:** `main` @ `b85d674b27b7eb024b42a8d1b05d5f624a3ee6bc` (tree dirty; owner work preserved)
**Canonical source:** `docs/audit/FINDINGS_REGISTER.json` (35 findings, machine-readable)
**Scope:** Complete inventory. "Session evidence" records only checks executed on 2026-10-29;
everything else retains the canonical status without re-verification.
**R2 pass:** A-2, A-3, A-4, A-7, A-8 and conditional A-1 executed. Evidence:
`REMEDIATION_EXECUTION.md` §8. Final local gates: `flutter analyze` exit 0, `dart format` 134 files
0 changed, `flutter test` 221/221, SQL 12 units + 365 ACL assertions, Edge 44/44, Android
merged-manifest gate exit 0.

---

## Reconciliation: 35 findings, not 37, and the previous 23-row table

The earlier draft of this file carried the canonical totals (35) in its summary tables while
enumerating only 23 IDs. The two numbers that were compared — 35 and 37 — are different measures:

| Figure | What it actually counts |
|---|---|
| **35** | Findings in `docs/audit/FINDINGS_REGISTER.json` (P0 0 / P1 3 / P2 24 / P3 6 / P4 2) |
| **37** | Bounded-body Edge tests at `CODEBASE_HEALTH_REPORT.md:110` (`29/37 pass`, 8 failing) — not findings |
| **23** | IDs enumerated by the previous draft of this Markdown register |
| **70** | Sum of the previous draft's mixed confidence+status header line; it added two different dimensions |

No 37-entry findings inventory exists. The 23-row draft omitted 12 canonical findings:

`FND-TEST-001`, `FND-BUG-004`, `FND-BUG-005`, `FND-BUG-006`, `FND-BUG-007`, `FND-INTG-003`,
`FND-INTG-004`, `FND-BUG-008`, `FND-BUG-009`, `FND-INTG-008`, `FND-INTG-009`, `FND-TEST-002`.

The earlier draft also drifted from the canonical register in four places. Canonical values win:

| Finding | Canonical JSON | Previous draft | Resolution |
|---|---|---|---|
| FND-SEC-002 | P1 / Fixed | P2 / Fixed | Canonical P1 |
| FND-BUG-002 | P2 / Accepted | P1 / Accepted | Canonical P2 |
| FND-ARCH-003 | P3 / Fixed | P2 / Fixed | Canonical P3 |
| FND-GOV-004, FND-SEC-001 | P2 / Fixed | P3 / Accepted | Canonical P2 / Fixed |
| FND-SEC-004 | P2 / Fixed | P2 / Needs Verification | Canonical Fixed |
| FND-INTG-007 | P2 / Accepted | P2 / Needs Verification | Canonical Accepted |

It also misattributed FND-INTG-001: the finding is the local Auth redirect allowlist mismatch in
`supabase/config.toml` / `config.example.json`, not a `/coach` router allowlist.

**Counts (canonical):** Accepted 11 · Fixed 20 · Needs Verification 2 · False Positive 2.
**Confidence:** Confirmed 16 · High 18 · Medium 1 · Low 0.

Two titles previously drifted from the canonical JSON in this Markdown file and are corrected below:
`FND-BUG-002` is the **fail-closed release signing** finding (not the display name), and
`FND-BUG-003` is the **platform display name** finding (not the pubspec description). The pubspec
description edit was a consistency change, not a canonical finding.

---

## Complete Inventory (35)

Statuses below are canonical. "Session 2026-10-29" describes only work executed in this session.

### P1 — 3

| ID | Conf. | Status | Subsystem | Title | Session 2026-10-29 |
|---|---|---|---|---|---|
| FND-BUG-001 | High | Fixed | Android | Release merged manifest never verified for `INTERNET` | **Fixed (repository scope):** real Gradle `:app:processReleaseMainManifest` ran; merged manifest has one direct `<manifest>` INTERNET, `package=com.gymlvl.app`, `label=GymLvl`. Gate `tools/android-verify/run.mjs` exit 0. APK/`aapt`/device and CI job **NOT RUN**. |
| FND-DATA-001 | Confirmed | Fixed | Database | Conditional prior-award legacy tuple can receive another workout credit | **Fixed (repository scope):** additive migration `20261029000200` treats an existing `xp_logs` award row as prior provenance and returns `alreadyAwarded` without writing. RED without migration, GREEN with it (SQL 12 units + 365 ACL). Production counts/backfill **BLOCKED** (`O-07`). |
| FND-SEC-002 | Confirmed | Fixed | Flutter/Workout | Cross-identity backup adoption after storage await | Owner-match snapshot retained; 61 focused tests (async identity + snapshot ownership + completion reconciliation) PASS. Real multi-identity Auth **NOT RUN**. |

### P2 — 24

| ID | Conf. | Status | Subsystem | Title | Session 2026-10-29 |
|---|---|---|---|---|---|
| FND-CONC-001 | Confirmed | Fixed | Flutter/Workout | Discard queue cycle and post-await identity race | Same 61 focused tests PASS. Isolated-stack concurrency **NOT RUN**. |
| FND-ARCH-001 | High | False Positive | Architecture | XP write invariant stated narrower than implementation | Not re-verified. |
| FND-GOV-001 | Confirmed | Fixed | Governance | Agents could not write `docs/audit/**` | Not re-verified (superseded by D-024). |
| FND-GOV-004 | High | Fixed | Governance | Destructive git-operation gates miss spellings | Config change requires approval; not re-verified. |
| FND-SEC-001 | High | Fixed | Governance | Secret-read gates cover four spellings only | Config change requires approval; not re-verified. |
| FND-TEST-001 | High | Accepted | CI | CI cannot detect platform, formatting, or generated-code regressions | CI hardened (R3): `invoke.test.mjs` now runs in the manifest-gate step (18 Android tests), a `dart format --set-exit-if-changed` gate, per-job `timeout-minutes`, workflow-level `concurrency`+cancel, `push.branches: [main]`, and `checkout`/`setup-node`/`setup-java`/`upload-artifact` pinned to Node-24 commit SHAs (`subosito/flutter-action@v2` kept: composite). **Generated-code drift gate deliberately withheld** — regenerating at locked generator versions rewrites 12 tracked files (measured locally, 846+/1303 lines)—so it would fail immediately. All gates **PASS locally** (format 0 changed, invoke 10/10, manifest 8/8, YAML 3 jobs); remote CI for these steps **NOT RUN** pending owner approval, so the finding stays Accepted. |
| FND-BUG-004 | Confirmed | Fixed | Profile UI | White-on-white profile identity and edit text | **Fixed (R3 repository scope):** the identity/edit pair plus all seven remaining white/amber-on-card text nodes resolve ink-on-card contrast; onboarding chip icon+label and day-chip label/checkmark paints resolved from the live tree. 8-test negative control fails on pre-fix paints, proving the assertions detect regressions. Still source-only: class-picker sheet, accent text and dark theme (separate scope). |
| FND-BUG-005 | Medium | Fixed | Dashboard | KPIs silently limited to last three workouts | **Fixed (R3):** every KPI tile now states its real window (VOLUME -> 7-day trend, WORKOUTS/SETS -> last 3 sessions). `dashboard_kpi_window_test.dart` asserts EN/VI labels and a 320 px no-overflow case; full suite 231/231. Whether 7-day/3-session is the product-intended aggregate (vs lifetime) is unchanged and remains a product decision. |
| FND-BUG-006 | High | Fixed | Quest UI | Fixed 35% progress and 350/100 fallback rewards | Fabricated progress/reward removed; 3 regression tests PASS. Live payloads **NOT RUN**. |
| FND-BUG-007 | High | Fixed | Workout summary | Deep link fabricates completed workout and 500 XP | Summary now redirects without context; XP badge and level/progress render only from receipt fields; 5 regression tests PASS. Live journey **NOT RUN**. |
| FND-INTG-002 | Confirmed | Fixed | Flutter/Database | Completion acknowledgement/hydration semantics | Same 61 focused tests PASS. Real backend **NOT RUN**. |
| FND-INTG-003 | High | Accepted | Coach | Accepted answer length rejected on next history request | Not re-verified. |
| FND-INTG-004 | Confirmed | Accepted | Workout UI | Timed "Add Set" sends hidden reps and zero duration | Not re-verified. |
| FND-SEC-003 | Confirmed | Fixed | Database | Conditional PUBLIC ACL fixture (no production exploit) | 12 SQL units + 365 ACL assertions PASS. |
| FND-SEC-004 | Confirmed | Fixed | Edge Functions | Authenticated buffering/provider-response boundary | `node edge-tests.mjs` 44/44 PASS after synthetic env fix in the runner; hosted runtime **NOT RUN**. |
| FND-DATA-002 | Confirmed | Accepted | Database | `switch_class` recomputation may lose class history | Not re-verified. Related to the A-1 limit: `switch_class` still requires `is_xp_calculated` for ledger-only history. |
| FND-INTG-005 | Confirmed | Accepted | Database | Set duration persistence vs authoritative completion | Not re-verified. |
| FND-INTG-006 | Confirmed | Accepted | Database | Exercise category keys vs class-focus matching | Not re-verified. |
| FND-INTG-007 | Confirmed | Accepted | Database | Generated prescription JSON vs Dart contract | Not re-verified. |
| FND-BUG-008 | Confirmed | Fixed | Auth UI | Stale sign-in error shown on recovery entry | Recovery now reports only its own submit failures; regression test PASS. Live email round-trip **NOT RUN**. |
| FND-BUG-009 | Confirmed | Fixed | Candy UI | `CandyButton` not keyboard reachable/activatable | Focusable action detector + visible focus ring; 2 keyboard tests PASS (Tab/Enter/Space, disabled skipped, pointer retained). Device/AT **NOT RUN**. |
| FND-INTG-008 | High | Needs Verification | Workout transport | Lost add-set acknowledgement permits duplicate insert | Isolated-stack test **BLOCKED**. |
| FND-INTG-009 | High | Needs Verification | Workout transport | Sequential reorder can diverge on partial failure | Isolated-stack test **BLOCKED**. |
| FND-BUG-002 | High | Accepted | Android/iOS signing | Fail-closed release signing source correction awaits Gradle gates and artifact proof | The new merge gate runs without signing keys; fail-closed `build.gradle.kts` unchanged. `assembleRelease`/signature verification **BLOCKED** on operator keys. |

### P3 — 6

| ID | Conf. | Status | Subsystem | Title | Session 2026-10-29 |
|---|---|---|---|---|---|
| FND-GOV-002 | Confirmed | Accepted | Governance | 15 stale claims across project memory documents | Partially applied: `PROJECT_CONTEXT.md` baseline rule and §8 conflicts corrected. Remaining claims open. |
| FND-GOV-003 | High | False Positive | Governance | Chained-command permission semantics | Not re-verified. |
| FND-INTG-001 | High | Fixed | Auth config | Local Auth redirect target is not allowlisted | **Fixed:** `site_url=http://localhost:8080`; allowlist covers localhost/127.0.0.1/[::1]:8080 (+`/**`) and keeps legacy `:3000`; docs use `--web-port 8080`; new config test 6/6 PASS. Live recovery **NOT RUN**. |
| FND-ARCH-002 | High | Accepted | Localization | Two locale mechanisms | Not re-verified. |
| FND-ARCH-003 | High | Fixed | Documentation | Timezone invariant wording vs implementation | Documentation-only; no runtime check. |
| FND-TEST-002 | High | Accepted | Tests | Candy spec-replica tests do not cover production primitives | Not re-verified. |

### P4 — 2

| ID | Conf. | Status | Subsystem | Title | Session 2026-10-29 |
|---|---|---|---|---|---|
| FND-BUG-003 | High | Fixed | App metadata | The platform display name is the Flutter template default | **Fixed:** merged manifest `android:label="GymLvl"`, iOS `CFBundleDisplayName`/`CFBundleName`; A-7 standardized in-app title, wordmarks and l10n to `GymLvl`/`GYMLVL`. Installed-build/iOS label **NOT RUN**. |
| FND-GOV-005 | High | Fixed | Repository hygiene | Stale analyzer transcript tracked as `app/analysis.txt` | **Fixed:** `git rm --cached app/analysis.txt` + `app/.gitignore` entry; 84,864-byte local file preserved; `git ls-files` empty. Index change staged, not committed. |

---

## Status Distribution (canonical, after R2)

| Canonical status | Count | R2 change |
|---|---|---|
| Fixed | 18 | +9 (BUG-001, BUG-003, BUG-006, BUG-007, BUG-008, BUG-009, INTG-001, GOV-005, DATA-001) |
| Accepted | 12 | −9; BUG-004 remains Accepted as a partial fix and BUG-002 remains Accepted for signing |
| Needs Verification | 3 | unchanged |
| False Positive | 2 | unchanged |
| **Total** | **35** | — |

Severity (P0 0 / P1 3 / P2 24 / P3 6 / P4 2) and confidence (Confirmed 16 / High 18 / Medium 1 / Low 0)
are unchanged; no finding was added or removed.

---

## Evidence Status Legend

| Status | Meaning |
|---|---|
| **CONFIRMED** | Direct code evidence or reproducible failure |
| **HIGH** | Strong evidence, execution verification incomplete |
| **NEEDS_VERIFICATION** | Hypothesis requiring additional validation |
| **ENVIRONMENT_BLOCKED** | Not testable because tooling/infrastructure is unavailable |
