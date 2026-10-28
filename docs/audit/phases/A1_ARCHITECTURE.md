# A1 — Architecture, Dependencies, Configuration and Infrastructure

**Date:** 2026-10-28
**Baseline:** `main` @ `e8c7c8e` (= `origin/main`), working tree clean at entry
**Acting agent:** `gymlvl-orchestrator` — proven from the server, not from configuration (§2)
**Status:** `PASS` with 10 new findings and two measurement corrections to A0's inventory
**Writes:** `docs/audit/**` only, plus the planning files named in `AGENTS.md` §6
**Implementation changes:** none. No application, SQL, CI, dependency, or configuration file was
modified. No dependency was installed. No database was started.

---

## 1. Scope and method

The stage prompt is `SESSION_HANDOFF.md` §6 (as it stood at A0.1 close). Every item it names is covered
below, with the section that covers it:

| Prompt item | Section |
|---|---|
| `.github/workflows/verify.yml` | §6 |
| `app/pubspec.yaml`, `app/analysis_options.yaml`, `app/l10n.yaml` | §4, §5.3 |
| `docs/planning/ARCHITECTURE.md` §§1–4, 7–9 versus the code | §3, §10 |
| `docs/planning/PROJECT_CONTEXT.md` §§3–5, 8 | §4, §8, §10 |
| `.opencode/**` configuration against observed agent behaviour | §7 |
| Migration ordering and versioning across the three SQL files | §8 |

Two items the stage brief lists but the A1 prompt does not name were also covered because they are
cheap and they are the two places where A1's own findings live: platform/build configuration (§5) and
cross-component configuration contracts (§9). Nothing in the prompt was skipped.

**Method.** Read-only inspection of configuration and documentation, plus executed static checks
(`flutter analyze`, `dart format`, the repository's own permission-rule evaluator). No runtime service
was started, no build artifact was produced, no destructive command was issued. A finding reaches
`Confirmed` only where a command was run in this session and its output is quoted; static reading alone
caps at `High` (`README.md` §6).

### 1.1 Delegation

Four specialists were asked for bounded, read-only reviews, run sequentially per D-021. No subagent was
given a write task, and every subagent reported an empty `git status --porcelain=v1` on exit.

| Agent | Scope requested | Contributed to |
|---|---|---|
| `flutter-specialist` | `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, build/lint configuration | §4, §5.3 |
| `supabase-specialist` | migration ordering, versioning scheme, structural consistency across the three files | §8 |
| `qa-reviewer` | independent read of `verify.yml` and the test gates | §6 |
| `context-keeper` | baseline currency and doc-vs-doc consistency | §10 |

**Attribution rule applied.** A subagent's statement is treated as a lead, not as evidence. Every claim
that survives into a finding was re-derived by the orchestrator with the command quoted in §12. No
subagent `PASS` is reported as a `PASS` here.

`context-keeper` could not execute `git ls-remote`, `git ls-tree`, `git rev-list`, `git show-ref`,
`git tag`, or piped commands (`Permission denied: shell`). Its doc-consistency observations were
therefore re-checked by the orchestrator, and only re-checked observations appear in §10.

---

## 2. Baseline and acting-agent verification

| Check | Command | Result | Status |
|---|---|---|---|
| Branch | `git rev-parse --abbrev-ref HEAD` | `main` | `PASS` |
| HEAD | `git rev-parse HEAD` | `e8c7c8e7e346790ac1807dc5c8d4e43c2ee880ef` | `PASS` |
| Remote | `git ls-remote origin refs/heads/main` | `e8c7c8e7e346790ac1807dc5c8d4e43c2ee880ef	refs/heads/main` | `PASS` — equal to local |
| Working tree | `git status --porcelain=v1` | `CLEAN (0 entries)` | `PASS` |
| Acting agent | `opencode-cli.exe api get /api/session/ses_e7e81bc84ffeWkbb0tV5jo0jwp` | `"agent":"gymlvl-orchestrator"`, `"location":{"directory":"D:\\Projects\\gymlvl"}` | `PASS` |

**HEAD advanced legitimately.** The A0.1 handoff records `947da1e`. One commit landed after it:
`e8c7c8e docs: record the D-024 commit SHA and push outcome`. `git log --oneline -8` shows a linear
history `e8c7c8e → 947da1e → 425686c → e400dbc → 9c8e142 → 59450c0 → b4063c6 → 17ca562`. Nothing was
reset, stashed, checked out, or rebased. The tree was clean at entry, so the "preserve unexpected work"
branch of `AGENTS.md` §2 did not trigger.

The expected checkpoint `e8c7c8e` therefore matched exactly, and no history anomaly exists to document.

---

## 3. System architecture and module boundaries

### 3.1 Runtime topology

Verified against code, not against prose:

| Edge | Evidence | Verdict |
|---|---|---|
| UI → Riverpod → repository → Supabase | `app/lib/main.dart` initializes the client and provider scope; repositories under `app/lib/features/*/data/**` hold the RPC calls | matches `docs/ARCHITECTURE.md` §Runtime and `docs/planning/ARCHITECTURE.md` §1 |
| Auth identity | `app/lib/features/auth/data/supabase_auth_repository.dart` uses `_supabase.auth` only | matches |
| PostgREST + RLS as the data path | no direct SQL client in `app/lib`; `supabase_flutter` only | matches |
| Edge Functions | `supabase/functions/**` present; called from `features/coach` | matches |
| Single backend | `pubspec.yaml` has no Firebase, no HTTP client beyond `supabase_flutter` | matches the "no alternate backend" claim |
| Storage upload | no upload call site in `app/lib` | matches "Storage exists but no flow is implemented" |

### 3.2 Module map versus the tree

`docs/planning/ARCHITECTURE.md` §2 lists `app/lib/{core,features,ui/candy}`. Measured, `app/lib/ui/`
contains **three** directories: `candy`, `theme`, `widgets`. `app/lib/l10n/` exists and is not in the
map. `app/lib/core/localization/` **is** in the map, which is the more interesting half of the same
problem: two localization locations exist, and the map names only one of them (§5.3, `FND-ARCH-002`).

### 3.3 Boundary observations

- The layering rule "client never writes progression" is a server-side grant question; it is not
  decidable from `app/lib` alone and is deferred to A4 (`FND-ARCH-001` already tracks the wording).
- `app/lib/core/config/supabase_config.dart:16-27` fails closed on a privileged key
  (`sb_secret_*` → `false`; JWT `role != anon` → `false`). This is a positive architecture result and is
  recorded here so it is not re-derived.
- No circular feature dependency was found by import inspection at the directory level. Per-symbol
  coupling is A2 work.

---

## 4. Dependencies and version constraints

### 4.1 Manifest

| Item | Value | Note |
|---|---|---|
| SDK constraint | `environment: sdk: ^3.10.4` (`pubspec.yaml:22`) | no `flutter:` constraint is declared |
| Direct runtime deps | 12 (`flutter_riverpod ^3.1.0`, `riverpod_annotation ^4.0.0`, `go_router ^17.1.0`, `freezed_annotation ^3.1.0`, `json_annotation ^4.9.0`, `intl ^0.20.2`, `supabase_flutter ^2.12.2`, `flutter_animate ^4.5.2`, `fl_chart ^1.2.0`, `shared_preferences ^2.5.5`, `cupertino_icons ^1.0.9`, plus the Flutter SDK) | all caret ranges |
| Direct dev deps | 7 (`flutter_lints ^6.0.0`, `build_runner ^2.13.1`, `riverpod_generator ^4.0.0+1`, `freezed ^3.2.3`, `json_serializable ^6.11.2`, `flutter_test`) | all caret ranges |
| Lock file | `app/pubspec.lock` tracked; 147 packages; 0 `git` deps; 0 `path` deps; 5 SDK deps | reproducible |
| `dependency_overrides` | none | good |
| Lock SDK floor | `dart: ">=3.10.4 <4.0.0"`, `flutter: ">=3.38.4"` | consistent with `pubspec.yaml` |

### 4.2 Toolchain agreement — three-way

| Source | Flutter | Dart |
|---|---|---|
| Local (`flutter --version`) | `3.38.5 • channel stable` | `3.10.4` |
| CI (`.github/workflows/verify.yml:37`) | `'3.38.5'`, `channel: stable` | — |
| Lock (`app/pubspec.lock` `sdks:`) | `>=3.38.4` | `>=3.10.4 <4.0.0` |

All three agree. `flutter analyze` and `dart format` both ran clean under this toolchain (§12), so the
pinned version is the version the code was written against.

### 4.3 Dependency risks

| Risk | Evidence | Severity of concern |
|---|---|---|
| No automated update or audit path | no `dependabot.yml`, no `flutter pub outdated` gate in CI | low now; becomes real at release |
| Caret ranges allow silent minor upgrades | every direct dep uses `^` | mitigated by the tracked lock file, but CI runs `flutter pub get` without asserting the lock is unchanged |
| Generator/lint versions are unpinned to a minor | `build_runner ^2.13.1`, `flutter_lints ^6.0.0` | generated-code drift is unguarded (folded into `FND-TEST-001`) |
| No `flutter:` SDK constraint in `pubspec.yaml` | `pubspec.yaml:21-22` | a Flutter downgrade below the lock floor is caught only by `pub get` |

No dependency is deprecated, abandoned, or duplicated by inspection. `flutter pub outdated` was **NOT
RUN**: it contacts the network and its result would describe upstream releases, not this codebase.

### 4.4 Lint and analyzer configuration

`app/analysis_options.yaml` is 28 lines: `include: package:flutter_lints/flutter.yaml`, an empty
`linter.rules:` block, and the template's own comments. No additional rule is enabled, no rule is
disabled, and no `analyzer:` section exists (so no `strict-casts`, `strict-raw-types`,
`language.experimental`, or `errors:` promotion).

Consequence: `flutter analyze` reporting `No issues found!` is a *baseline-lint* result. It does not
imply strict typing, and it is not evidence of type soundness at the boundaries. This is a
configuration fact, not a finding — the project never claimed strictness. It is recorded because
A2/A4 reviews must not over-read the analyze gate.

---

## 5. Build, platform and localization configuration

### 5.1 Android

| Item | Measured | Finding |
|---|---|---|
| `INTERNET` permission | **absent** from `app/android/app/src/main/AndroidManifest.xml`; present only in `src/debug/` and `src/profile/` (both line 6) | `FND-BUG-001` (P1) |
| Release source set | no `app/android/app/src/release/` directory exists | `FND-BUG-001` |
| Release signing | `app/android/app/build.gradle.kts:37` → `signingConfig = signingConfigs.getByName("debug")` | `FND-BUG-002` (P2) |
| Launcher label | `android:label="app"` (`AndroidManifest.xml:3`) | `FND-BUG-003` (P4) |
| `applicationId` | `com.gymlvl.app` (`build.gradle.kts:24`) | correct |
| SDK levels | `minSdk = flutter.minSdkVersion`, `targetSdk = flutter.targetSdkVersion` | delegated to the Flutter default; not a defect |

Android's manifest merger combines `main` with the selected build type. `debug` and `profile` are not
merged into a release build, so the release manifest is `main` alone, which declares no permission.
Every data path in this app is a network call, so the defect is total for a release artifact.

`TASK_BOARD.md` §M1-02 (lines 172-182) already plans this fix, including the same three items. It was
never registered as an audit finding. The findings are registered now so that a fix has an ID to close;
`origin` cites M1-02.

### 5.2 iOS

| Item | Measured | Finding |
|---|---|---|
| `CFBundleDisplayName` | `App` (`Info.plist:8`) | `FND-BUG-003` |
| `CFBundleName` | `app` (`Info.plist:16`) | `FND-BUG-003` |
| Bundle identifier | `$(PRODUCT_BUNDLE_IDENTIFIER)` — resolved by the Xcode project | not measured (no Xcode host) |
| Signing | Xcode-managed; no `ExportOptions.plist` in the tree | **NOT RUN** — no macOS host |

The in-app brand is `'GymLevel'` (`app/lib/app.dart:21`, `app/lib/l10n/app_en.arb` `appTitle`), so the
launcher name and the product name disagree on both platforms.

### 5.3 Localization pipeline

| Item | Measured |
|---|---|
| `app/l10n.yaml` | 3 lines: `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`, `output-localization-file: app_localizations.dart` |
| gen-l10n enabled | `app/pubspec.yaml:70` → `generate: true` |
| ARB content | `app_en.arb` 7 lines / **1 key** (`appTitle`); `app_vi.arb` 1 key |
| Generated output | `app/lib/l10n/app_localizations.dart` (4,839 B), `app_localizations_en.dart` (351 B), `app_localizations_vi.dart` (354 B) — tracked, not gitignored |
| Delegate installed | `app/lib/app.dart:28-33` (`AppLocalizations.delegate` + the three global delegates) |
| Delegate consumed | **nowhere.** The only `AppLocalizations.of` occurrences are the generated file's own doc comments (lines 14, 24) |
| Real UI text | `app/lib/core/localization/localization_engine.dart:46-266`, `const Map<String, Map<String,String>> _dictionary` — **104 keys**, each with `vi` and `en` (104/104, zero asymmetry) |
| Call sites | 209 `translateText(`/`.tr(ref)` occurrences across 18 files |
| Locale selection | `app/lib/app.dart:25` maps `AppLangMode` to `Locale('en'|'vi')`; `bilingual` falls through to `vi` |

Two mechanisms coexist: a working Flutter-standard pipeline that carries one string, and a hand-rolled
dictionary that carries all product text. Parity is exact, so there is no user-visible defect today;
the cost is tooling, translation workflow, and ICU capability. Recorded as `FND-ARCH-002` (P3).

---

## 6. CI/CD pipeline and test gates

`.github/workflows/verify.yml` — 52 lines, 48 non-blank, unchanged since `56c1122`.

| Element | Measured | Assessment |
|---|---|---|
| Triggers | `push` (no branch filter), `pull_request` | every branch consumes runners |
| Permissions | `permissions: contents: read` (line 7-8) | correct, least privilege |
| Job `database-and-edge` | `npm ci` → `npm test` → `npm run check:edge` → `npm run test:edge`, Node 22, npm cache | solid: migrations, seeds (applied twice), SQL regressions, Edge type-check and unit tests |
| Job `flutter` | `flutter pub get` → `flutter analyze` → `flutter test --reporter expanded` → `flutter build web --release` with placeholder dart-defines → upload artifact | analyze + test + web compile only |
| Formatting gate | **absent** | `dart format` is clean today (125 files, 0 changed) but nothing keeps it clean |
| Coverage | **absent** — no `--coverage`, no upload | G-06 stays true; no percentage may be claimed |
| Generated-file drift | **absent** — no `build_runner` re-run, no `git diff --exit-code` | stale generated code would pass CI |
| Android / iOS build | **absent** | `FND-BUG-001` and `FND-BUG-002` are undetectable by this pipeline |
| Action pinning | `actions/checkout@v4`, `actions/setup-node@v4`, `subosito/flutter-action@v2`, `actions/upload-artifact@v4` — mutable tags | supply-chain surface |
| `concurrency` / `timeout-minutes` | absent | redundant runs, no runaway-job bound |
| Lock-file assertion | `flutter pub get` may update `pubspec.lock` silently | no drift detection |

`docs/planning/ARCHITECTURE.md` §9 asserts "No Android APK build in CI today". The absence is therefore
documented, but the document does not state it as a *decision* with a rationale, and no other document
does either. `TASK_BOARD.md` §M1-05 plans "CI Android static build + config regression test". Recorded
as `FND-TEST-001` (P2).

The workflow's web build is a compile check with placeholder credentials. It proves the app compiles; it
proves nothing about configuration correctness, and the `--dart-define` values
(`SUPABASE_URL=http://127.0.0.1:54321`, `SUPABASE_PUBLISHABLE_KEY=sb_publishable_local_test`) are
consistent with `app/lib/core/config/supabase_config.dart:16-18`, which accepts any `sb_publishable_*`
key. That contract holds (§9).

---

## 7. OpenCode agent infrastructure and governance

### 7.1 Structure

| Item | Measured |
|---|---|
| Agents | 7 under `.opencode/agents/`: `gymlvl-orchestrator` (primary), `flutter-specialist`, `supabase-specialist`, `exercise-catalog`, `ui-ux-specialist`, `qa-reviewer`, `context-keeper` |
| Skills | 6 directories |
| Commands | 6: `audit`, `debug`, `mobile`, `orchestrate`, `plan`, `test` |
| Global config | `.opencode/opencode.jsonc` — single ordered rule set since D-024 |
| Rule count | **73 global + 62 agent** rules, parsed by the repository's own evaluator |
| Schema validity | `RESULT: PASS (0 probe failures, 0 schema problems)` on the documented probe set |

The orchestrator carries **no** `permissions` block by design (D-024); its comment at
`gymlvl-orchestrator.md:5-7` states the reason (a per-agent `shell "*" allow` would override the global
gates under last-match-wins). That reasoning matches the V2 rule model and is correct.

### 7.2 Gate coverage — measured, not assumed

The evaluator (`gymlvl-perm-check.mjs`, unmodified) passes its own 73+62 probe set. A1 added 18 probes
drawn from `AGENTS.md` §8 and the orchestrator's own "Hard refusals" section. Result:

`RESULT: FAIL (12 probe failures, 0 schema problems)`

| Probe | Expected | Got | Matching rule |
|---|---|---|---|
| `git push origin --force main` | ask | **allow** | `shell:* -> allow` |
| `git push origin --delete feature-x` | ask | **allow** | `shell:* -> allow` |
| `git push origin :feature-x` | ask | **allow** | `shell:* -> allow` |
| `git push origin --mirror` | ask | **allow** | `shell:* -> allow` |
| `git switch main` | ask | **allow** | `shell:* -> allow` |
| `git checkout main` | ask | **allow** | `shell:* -> allow` |
| `git checkout HEAD -- app/lib/main.dart` | ask | **allow** | `shell:* -> allow` |
| `git stash` | ask | **allow** | `shell:* -> allow` |
| `git tag -d v1` | ask | **allow** | `shell:* -> allow` |
| `git -c core.pager=cat push --force origin main` | ask | **allow** | `shell:* -> allow` |
| `Select-String -Path .env -Pattern .` | ask | **allow** | `shell:* -> allow` |
| `Copy-Item .env C:/Temp/x.txt` | ask | **allow** | `shell:* -> allow` |
| `git push --force-with-lease origin main` | ask | ask | `shell:git push --force* -> ask` |
| `git push origin +main:main` | ask | ask | `shell:git push * +* -> ask` |
| `git branch -d feature-x` | ask | ask | `shell:git branch -D* -> ask` |
| `git clean -fdx` | ask | ask | `shell:git clean * -> ask` |
| `rm -rf app` | ask | ask | `shell:rm -rf* -> ask` |
| `psql` | ask | ask | `shell:psql * -> ask` |

**Mechanism.** Every Git gate is prefix-anchored on the flag position
(`git push --force*`, `git push --delete*`, `git push --mirror*`), so a positional argument before the
flag defeats it. `git -c <option>` defeats every rule. `git switch`, bare `git stash`, `git checkout
<ref>`, and `git tag -d` have no rule at all. The secret gates enumerate four reader spellings
(`Get-Content`, `type`, `cat`, `more`) and miss every other built-in.

Recorded as `FND-GOV-004` (P2, Git) and `FND-SEC-001` (P2, secrets).

**Live confirmation is `NOT RUN` and must stay that way.** A live probe requires issuing a destructive
command. The evaluator is the repository's own reimplementation of the documented rule model, not the
harness itself; that is why both findings are `High` and not `Confirmed`.

### 7.3 Documentation of the gates

`gymlvl-orchestrator.md:54-58` states that force-push, history rewrites, branch deletion, and reading
secret files "all resolve to `ask`". For the spellings above, they do not. The gap between the stated
guarantee and the enforced rule set is the substance of both findings — not the existence of a denylist.

---

## 8. Migration ordering, versioning and structural consistency

### 8.1 Files and scheme

| File | Lines | Non-blank | Comment-only |
|---|---|---|---|
| `20261026000100_baseline.sql` | 661 | 550 | 157 |
| `20261026000200_authoritative_progression.sql` | 349 | 335 | 21 |
| `20261027000100_exercise_catalog_metadata.sql` | 367 | 334 | 10 |
| **Total** | **1,377** | **1,219** | **188** |

Versioning scheme: 14-digit `YYYYMMDDHHMMSS` prefix, `_`, lowercase snake_case description, `.sql`. The
three timestamps are strictly increasing in lexical and numeric order, which is the order the Supabase
CLI applies. The harness enforces the scheme:
`tools/db-tests/run.mjs:30` → `assert.match(name, /^\d{14}_[a-z0-9_]+\.sql$/, ...)`.

`PROJECT_CONTEXT.md:92-94` records 661 / 349 / 367 — these are **total lines** and they match exactly.

### 8.2 Structural consistency

| Property | Measured | Assessment |
|---|---|---|
| Tables | 14 + 3 + 0 = **17** | matches `PROJECT_CONTEXT.md:87-90` and `ARCHITECTURE.md:71` |
| Every `CREATE TABLE` guarded | 17/17 use `IF NOT EXISTS` | idempotent by construction |
| `IF NOT EXISTS` occurrences | 69 across the three files | — |
| Policy statements (textual) | **44** — 31 baseline, 10 static in progression, 1 on `coach_daily_usage`, 2 inside `format()` templates | matches A0's 44 |
| Policies effective at tip | **22** — the baseline set is dropped by the loop at `progression:61-70` (16 tables), then 10 static + 7 `own_read` + 4 `catalogue_read` + 1 `coach_daily_usage` are created | see §8.3 |
| `SECURITY DEFINER` functions | **11** (12 textual occurrences; `baseline:47` is a comment) | matches A0's 11 |
| Triggers | **10** (11 textual occurrences; `baseline:48` is a comment) | matches A0's 10 |
| Function definitions | 18 textual; 15 distinct names; 1 duplicate pair (`update_modified_column` defined at `baseline:106` and `baseline:158`, redefined at `progression:95`) | A3 owns the duplicate |
| Destructive DDL | no `DROP TABLE`, `DROP COLUMN`, `TRUNCATE`, or `DROP FUNCTION` anywhere | consistent with `AGENTS.md` §4 |

### 8.3 Ordering hazards (observations, not findings)

1. `progression:61-70` **drops every policy** on 16 named tables and re-creates a narrower set. The
   migration is therefore not additive in the RLS sense; it is a deliberate replacement. It is safe
   because it runs in the same transaction as the replacement, but a future migration that assumes the
   baseline policies still exist would be wrong. This is the migration-level counterpart of
   `FND-ARCH-001`.
2. `CREATE TABLE IF NOT EXISTS` is not equivalent to "the schema matches". On a target that already has
   a legacy table with a different shape, the statement succeeds and the shape stays wrong. The
   repository documents this (`docs/ARCHITECTURE.md:41`: "Remote adoption requires comparing the
   target's schema and migration history"), so it is a documented limitation, not a defect. It stays a
   release risk for any remote adoption.
3. There is no in-repo migration ledger. Ordering is implicit in the filename and enforced by the
   harness regex; which migrations a given remote has applied is not recorded anywhere in the
   repository. Deferred to A3, which owns migration history.

None of the three is registered as a finding: (1) is a design fact with a correct implementation, (2) is
documented, (3) is a tooling observation whose risk A3 can measure.

---

## 9. Cross-component configuration contracts

| Contract | Producer | Consumer | Verdict |
|---|---|---|---|
| Supabase URL / publishable key | `app/config.example.json`, CI `--dart-define` | `app/lib/core/config/supabase_config.dart:6-10` | **holds** — CI's `sb_publishable_local_test` passes `isPublicClientKey` |
| Public-key guard | `supabase_config.dart:16-27` | every data path via `SupabaseConfig.initialize` | **holds** — fails closed on `sb_secret_*` and on a JWT whose `role != anon` |
| Auth redirect | `app/config.example.json:4` → `AUTH_REDIRECT_URL` → `supabase_auth_repository.dart:30-34` | `supabase/config.toml:154-156` allowlist | **broken** — `FND-INTG-001` |
| Seed list | `supabase/config.toml:65` `sql_paths = ["./seed.sql", "./seed_exercises.sql"]` | `tools/db-tests/run.mjs:33-42` parses that key and applies each seed twice | **holds** |
| Seed list (second entry point) | hardcoded paths at `tools/db-tests/e2e-catalog-test.mjs:53-66` | not reachable from `package.json` scripts | divergence; observation §11 |
| Flutter version | `.github/workflows/verify.yml:37` `3.38.5` | `pubspec.lock` `flutter: ">=3.38.4"`, local `3.38.5` | **holds** |
| Web dev port | `app/lib/main.dart:64` documents `--web-port 8080` | `supabase/config.toml:154` `site_url` is port 3000 | **broken** — same finding |

`FND-INTG-001` details: `site_url = "http://127.0.0.1:3000"`,
`additional_redirect_urls = ["https://127.0.0.1:3000"]`, while the app sends
`redirectTo: "http://localhost:8080/"`. Neither allowlisted URL is one the Flutter dev server serves.

---

## 10. Documentation versus implementation — stale-claim inventory

This section completes the inventory `FND-GOV-002` depends on. Classification follows the rule set in
`SESSION_HANDOFF.md` §7: a **dated** evidence block is not stale merely because it names an older SHA;
a claim presented as *current* is.

### 10.1 Stale (presented as current, contradicted by the tree at `e8c7c8e`)

| # | Location | Claim | Measured |
|---|---|---|---|
| S-1 | `AGENTS.md:7-8` | "current `main` HEAD is `b4063c6`" | `e8c7c8e`, six commits later. Self-mitigating ("confirm with `git rev-parse main`") |
| S-2 | `PROJECT_CONTEXT.md:5-6`, `:34` | Baseline = consolidation checkpoint `17ca562` | seven commits behind |
| S-3 | `PROJECT_CONTEXT.md:40` | "Tracked files at HEAD \| 511" | **548** (`git ls-files \| Measure-Object`) |
| S-4 | `PROJECT_CONTEXT.md:36` | "`origin/main` — pushed and verified at the checkpoint" | true of the checkpoint; reads as current |
| S-5 | `PROJECT_CONTEXT.md:170` | glossary: "`main` @ `17ca562` \| Current consolidated baseline" | seven commits behind |
| S-6 | `DECISIONS.md:5` | "Baseline: `main` @ `17ca562`" | seven commits behind |
| S-7 | `DECISIONS.md:22-37` | summary table stops at D-014, then D-022/D-023 | D-015…D-021 and D-024 have sections but no row; the D-022 row states a policy D-024 replaced |
| S-8 | `MASTER_PLAN.md:5` | "Baseline: `main` @ `17ca562`" | seven commits behind. Editing it needs approval (`AGENTS.md` §6) |
| S-9 | `docs/ARCHITECTURE.md:43` | "Current migrations are `…baseline.sql` and `…authoritative_progression.sql`" | a third migration exists: `20261027000100_exercise_catalog_metadata.sql` |
| S-10 | `docs/planning/ARCHITECTURE.md:38-57` | module map lists `ui/candy/` only | `ui/theme/` and `ui/widgets/` exist; `app/lib/l10n/` is absent from the map |
| S-11 | `TASK_BOARD.md:4` | "Baseline: `main` @ `947da1e`" | `e8c7c8e` |
| S-12 | `TASK_BOARD.md:89-90` | "`origin/main` is still at `9c8e142`. End-to-end orchestrator write remains `NOT RUN`" | `origin/main` = `e8c7c8e`; the orchestrator write is verified (§2) |
| S-13 | `docs/planning/SESSION_HANDOFF.md:8`, `:25` | "Baseline: `main` @ `947da1e` = `origin/main`" | `e8c7c8e` |
| S-14 | `docs/planning/SESSION_HANDOFF.md:26` | "force-push stays gated" | `git push origin --force main` → `allow` (`FND-GOV-004`) |
| S-15 | `docs/agent-system/AGENT_SKILL_MATRIX.md:5`, `SKILL_SELECTION.md:5` | "Baseline: GymLvl `main` @ `b4063c6`" | reference documents, not session records; six commits behind |

### 10.2 Dated and correct — not stale

| Location | Why it is fine |
|---|---|
| `PROJECT_CONTEXT.md:66-79` §4 "Verified baseline evidence (2026-10-28, `main` @ `17ca562`)" | explicitly dated; its `analyze` and `format` results still reproduce at `e8c7c8e` (§12) |
| `docs/planning/ARCHITECTURE.md:4` "Last verified: 2026-10-28 at `56c1122`" | dated |
| `docs/IMPLEMENTATION_STATUS.md:3` "Date: 2026-10-26" | dated snapshot; `PROJECT_CONTEXT.md:185` labels it "(historical)", which resolves the precedence question |
| `docs/agent-system/{S2_IMPLEMENTATION_PLAN,WAVE1_IMPLEMENTATION,SOURCE_AUDIT,S3_VALIDATION_REPORT}.md` baseline lines | session records; a session record's baseline is its own, by definition |
| `CHANGELOG_AI.md` baseline lines | dated entries |

### 10.3 Claims re-verified as correct

| Location | Claim | Check |
|---|---|---|
| `docs/ARCHITECTURE.md:21` | no Firebase runtime dependency | `pubspec.yaml` has none |
| `docs/ARCHITECTURE.md:45` | ten named authenticated RPCs | all ten exist in the progression migration |
| `docs/ARCHITECTURE.md:41` | migration directory is the schema source of truth | no parallel schema definition exists in the tree |
| `PROJECT_CONTEXT.md:87-94` | 17 tables, 661/349/367 lines | exact match |
| `docs/planning/ARCHITECTURE.md:71` | "17 tables in total" | exact match |
| `docs/planning/ARCHITECTURE.md:88-90` | light mode is the product mode | `app/lib/app.dart:24` `themeMode: ThemeMode.light` |
| `docs/planning/ARCHITECTURE.md:88` | quests/streaks computed in `Asia/Ho_Chi_Minh` | **narrower than the code** — see `FND-ARCH-003` |

`FND-ARCH-003`: `progression:3` adds `profiles.timezone` defaulting to `Asia/Ho_Chi_Minh`, and
`progression:198`, `:241`, `:310-312` compute day boundaries from `coalesce(timezone,
'Asia/Ho_Chi_Minh')`. The invariant states a fixed zone; the implementation honours a per-user zone with
that default. A reviewer applying the invariant literally would hardcode the zone and shift quest and
streak day boundaries for any user whose profile timezone differs.

---

## 11. Observations not promoted to findings

Recorded so they are not re-derived, and so their status is explicit.

| # | Observation | Why not a finding |
|---|---|---|
| O-1 | `tools/db-tests/e2e-catalog-test.mjs` hardcodes the two seed paths instead of reading `[db.seed]`, and is not reachable from any `package.json` script. It also still prints "supabase/seed_exercises.sql not yet created in tree" although the file exists | dead second entry point; maintenance risk, no incorrect behavior. A5 owns harness cleanup |
| O-2 | `verify.yml` was recorded at A0 as 58 lines; it is 52 (48 non-blank) and has been unchanged since `56c1122` | audit-internal measurement correction, not a codebase defect |
| O-3 | `AUDIT_COVERAGE.md` recorded the migrations as 1,222 lines; remeasured 1,219 non-blank / 1,377 total | same class as O-2; corrected in place |
| O-4 | No migration ledger exists in the repository | tooling observation; A3 measures migration-history risk |
| O-5 | `CREATE TABLE IF NOT EXISTS` cannot repair a divergent pre-existing table | documented at `docs/ARCHITECTURE.md:41`; release risk, not a defect |
| O-6 | `update_modified_column` is defined three times (twice in baseline, redefined in progression) | harmless redefinition; A3 owns schema review |
| O-7 | `intl` is a direct dependency but the UI does not use it for formatting (the dictionary is a plain map) | follows from `FND-ARCH-002`; not a separate defect |
| O-8 | `bilingual` mode maps to `Locale('vi')` in `app.dart:25`; the dictionary has no bilingual rendering | behaviour question, A2 (C-05) |

---

## 12. Verification log

All commands were run in this session at `main` @ `e8c7c8e`, from `D:\Projects\gymlvl` unless a
`workdir` is stated.

| # | Command | Result | Status |
|---|---|---|---|
| 1 | `git rev-parse --abbrev-ref HEAD` | `main` | `PASS` |
| 2 | `git rev-parse HEAD` | `e8c7c8e7e346790ac1807dc5c8d4e43c2ee880ef` | `PASS` |
| 3 | `git ls-remote origin refs/heads/main` | `e8c7c8e7e346790ac1807dc5c8d4e43c2ee880ef	refs/heads/main` | `PASS` |
| 4 | `git status --porcelain=v1` | `CLEAN (0 entries)` | `PASS` |
| 5 | `opencode-cli.exe api get /api/session/ses_e7e81bc84ffeWkbb0tV5jo0jwp` | `"agent":"gymlvl-orchestrator"` | `PASS` |
| 6 | `cd app; flutter analyze` | `No issues found! (ran in 2.5s)`, exit 0 | `PASS` |
| 7 | `cd app; dart format --output=none --set-exit-if-changed lib test` | `Formatted 125 files (0 changed) in 0.71 seconds.`, exit 0 | `PASS` |
| 8 | `flutter --version` | `Flutter 3.38.5 • channel stable`, `Tools • Dart 3.10.4` | `PASS` |
| 9 | `node gymlvl-perm-check.mjs` (unmodified evaluator) | `RULES VALIDATED: 73 global + 62 agent` / `RESULT: PASS (0 probe failures, 0 schema problems)`, exit 0 | `PASS` |
| 10 | `node a1-git-gate-probe.mjs` (18 added probes) | `RESULT: FAIL (12 probe failures, 0 schema problems)`, exit 1 | `FAIL` — the failures are the finding |
| 11 | `node a1-lines2.mjs` (line accounting) | `TOTAL lines=1377 nonBlank=1219 commentOnly=188`; per file 661/349/367 | `PASS` |
| 12 | `node -e` table/policy/trigger/function census | 17 tables, 44 policy statements, 22 effective at tip, 11 `SECURITY DEFINER`, 10 triggers | `PASS` |
| 13 | `node a1-l10n.mjs` (dictionary census) | `outer keys: 104`, `'vi' entries: 104`, `'en' entries: 104` | `PASS` |
| 14 | `Get-ChildItem app\lib -Recurse -Filter *.dart \| Select-String "translateText\(\|\.tr\(ref\)"` | 209 matches in 18 files | `PASS` |
| 15 | `Get-ChildItem app\android\app\src -Recurse -Filter AndroidManifest.xml` + `Select-String INTERNET` | three manifests (debug, main, profile); `INTERNET` only at debug:6 and profile:6 | `PASS` — confirms `FND-BUG-001` |
| 16 | `git ls-files app/analysis.txt` + tail | tracked; `221 issues found. (ran in 12.1s)` | `PASS` — confirms `FND-GOV-005` |
| 17 | `git ls-files \| Measure-Object` | 548 | `PASS` |
| 18 | `git rev-list --count 17ca562..HEAD` | 7 | `PASS` |

Exit code 1 from `flutter --version` in the pipeline is an artifact of `Select-Object -First` closing the
stream early; the version output above is complete.

### 12.1 Not run, and why

| Check | Status | Reason |
|---|---|---|
| `flutter build web --release` | `NOT RUN` | writes `app/build/`; the CI job already performs it and A1 must not create build artifacts |
| `flutter build apk --release` / merged-manifest inspection | `NOT RUN` | Android SDK availability unconfirmed; would write build artifacts. This is what would promote `FND-BUG-001` to `Confirmed` |
| `flutter test` | `NOT RUN` | A5 scope. The 126-test result remains an S3/A0 measurement, not a current one |
| `npm test` (SQL harness), `npm run test:edge` | `NOT RUN` | A5 scope; requires the PGlite/Deno toolchain |
| `dart run build_runner build` | `NOT RUN` | writes generated files; would have measured generated-code drift |
| `flutter pub outdated` | `NOT RUN` | network; describes upstream, not this codebase |
| `supabase start` + `POST /auth/v1/recover` | `NOT RUN` | would start a local stack and mutate local state; `FND-INTG-001` stays `High` |
| Live permission probe per gate | `NOT RUN` | requires issuing a destructive or secret-reading command |
| iOS build / signing | `NOT RUN` | no macOS host |

---

## 13. New findings

| ID | Title | Sev | Conf | Status | Wave |
|---|---|---|---|---|---|
| `FND-BUG-001` | Android release manifest declares no `INTERNET` permission | P1 | High | `Accepted` | W1 |
| `FND-BUG-002` | Release build is signed with the debug keystore | P2 | High | `Accepted` | W1 |
| `FND-BUG-003` | Platform display name is the Flutter template default | P4 | High | `Accepted` | W1 |
| `FND-TEST-001` | CI cannot detect platform, formatting, or generated-code regressions | P2 | High | `Accepted` | W3 |
| `FND-INTG-001` | The documented local auth redirect is not in the Auth allowlist | P3 | High | `Accepted` | W4 |
| `FND-ARCH-002` | Two parallel localization mechanisms; the standard one carries no product text | P3 | High | `Accepted` | W4 |
| `FND-ARCH-003` | The stated timezone invariant is narrower than the per-user implementation | P3 | High | `Accepted` | W4 |
| `FND-GOV-004` | Git approval gates do not match the operations `AGENTS.md` §8 forbids | P2 | High | `Accepted` | W1 |
| `FND-SEC-001` | Shell secret gates cover a short list of command spellings | P2 | High | `Accepted` | W1 |
| `FND-GOV-005` | A stale analyzer transcript is tracked as `app/analysis.txt` | P4 | High | `Accepted` | W4 |

`FND-GOV-002` is extended, not duplicated: §10 is its inventory. Counts after A1 are in
`MASTER_FINDINGS.md` and `FINDINGS_REGISTER.json`.

---

## 14. Coverage changes

| ID | Before | After | Reviewer |
|---|---|---|---|
| C-22 CI workflow | `Not Reviewed` | `Reviewed (static)` | `qa-reviewer` + orchestrator re-read |
| C-25 Agent configuration | `Reviewed (static)` | `Reviewed (static)` — extended with a gate-coverage probe set | orchestrator + `qa-reviewer` |
| C-26 Planning documents | `In Review` | `Reviewed (static)` | `context-keeper` + orchestrator re-check |

A0's inventory figures are corrected in `AUDIT_COVERAGE.md` §2 for two rows (migrations 1,222 → 1,219
non-blank / 1,377 total; `verify.yml` 58 → 52). Both corrections are measurement fixes; neither changes
a finding.

---

## 15. What a resuming session must not assume

- That `flutter analyze` clean means the code is strictly typed. `analysis_options.yaml` enables nothing
  beyond `flutter_lints`.
- That the permission layer enforces `AGENTS.md` §8. It enforces 6 of 18 probed operations.
- That a release build of this app works. It cannot reach the network (`FND-BUG-001`), and it would be
  signed with a debug key (`FND-BUG-002`).
- That CI would catch either. It builds web only (`FND-TEST-001`).
- That the ARB files are the product's text. They hold one key (`FND-ARCH-002`).
- That A0's inventory numbers are exact. Two were off by 3 and 6 respectively (§14).
- That this stage's static conclusions are runtime conclusions. Every finding here is `High`, not
  `Confirmed`, except where a command was quoted in §12.
