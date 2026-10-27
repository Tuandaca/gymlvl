# M0 Audit — Repository, Migration, and License Findings

**Milestone:** M0 — Audit and migration planning
**Status:** COMPLETE (reported by the prior session; planning only)
**Audit date:** 2026-10-27/28
**Audit baseline at the time:** branch `codex/supabase-product-audit`, HEAD `e003803`, 166 dirty
status entries
**Current baseline (2026-10-28):** `56c1122`, pushed; the nine memory files created after the
baseline are uncommitted
**Durable record created:** 2026-10-28

## 0. Provenance of this document

The M0 report was produced in a previous session and delivered **only in the conversation
transcript**. A workspace search on 2026-10-28, before this file was created, found **no file**
containing the M0 report:

- No `M0_AUDIT.md`, `*M0*` report, or `*AUDIT*` report in the repository (excluding tool internals).
- The only related file was the original product plan,
  `docs/planning/GymLvl_OpenGym_Migration_Master_Plan.md`.

This document is a **structured reconstruction** of the M0 report, not a verbatim copy. Facts are
labelled by source. Do not treat reconstructed text as a new test run.

**Evidence labels:**

- **[V]** Verified by the prior session from source/command output.
- **[I]** Inferred by the prior session.
- **[U]** Unverified or blocked.
- **[V-now]** Re-verified in the current bootstrap session (2026-10-28) at `56c1122`.

## 1. What M0 actually did

M0 was **planning and audit only**:

- Read GymLvl source, migrations, docs, tests, and CI.
- Read the pinned revisions of the three reference repositories.
- Ran the existing test suites.
- Produced the migration matrix, target architecture, AI proposal, roadmap, and M1 scope.
- Made **no application code, SQL, deployment, or production changes**.

No commit was made by M0 itself. The subsequent `56c1122` commit was created outside the M0
session; its actor and timing are **[U]**.

## 2. Snapshot at audit time

| Check | Result |
|---|---|
| Branch / HEAD | `codex/supabase-product-audit` / `e003803` **[V]** |
| Working tree | **166 dirty entries**, 109 changed tracked files, +9,253/−8,080 **[V]** |
| Remote `main` | `e003803` (2026-04-20) **[V]** |
| `flutter analyze` | PASS, 0 issues (54s) **[V]** |
| `flutter test` | PASS, 126/126 **[V]** |
| `tools/db-tests npm test` | PASS, 10/10 SQL units on PostgreSQL 17.5/PGlite **[V]** |
| `npm run test:edge` | PASS, 15/15 Deno tests **[V]** |
| Android release build/device smoke | **NOT RUN** — Windows host; Android SDK state unknown/blocked **[U]** |
| iOS build | **NOT RUN** — not possible on Windows **[U]** |
| Live Supabase / live AI provider | **NOT RUN** — out of scope, no credentials used **[U]** |

## 3. Pinned reference revisions

| Source | SHA | Date | License |
|---|---|---|---|
| `Tuandaca/gymlvl` | `e0038038300d5bfaf3c4747094cf36a132eb8711` | 2026-04-20 | **No LICENSE file** in repo **[V]** |
| `emilfunk/opengym` (A) | `678bf5bf10446e8997a77d43e89c9b2721d8d0fc` | 2026-08-01 | AGPL-3.0 **[V]** |
| `DuarteSantos8/openGym` (B) | `e6a95c28a6e3067bdd9b1188d5f37f448d528bd2` | 2026-10-27 | AGPL-3.0 + app-store additional permission **[V]** |
| `hasaneyldrm/exercises-dataset` (C) | `7455efae41b330c265e7cd4b78dfa848e7ce5ebd` | 2026-07-16 | MIT for text/data; media excluded **[V]** |

## 4. Reference findings

### 4.1 Reference A — `emilfunk/opengym`

An older OpenGym base (1,324-exercise library) plus an AI Coach. Key verified files:

- `api/coach/routes.js` — user and admin routes for plan creation, review, pending resolution,
  consent withdrawal, provider enablement, credentials, caps, and health.
- `api/coach/jobs.js` — file-backed per-user jobs, daily caps, 5-minute timeout, max two concurrent
  jobs, 14-day pending proposals.
- `api/coach/payload.js` — allowlisted payload builder with five categories (`plan`, `training`,
  `bodyweight`, `profile`, `prefs`), pseudonymous handle, 12-week/60-session cap.
- `api/coach/validate.js` — closed change-type list, exercise-ID resolution against `library.json`,
  bounds, target resolution against the current plan.
- `api/coach/prompts/create.md` — plan-generation contract: week, routines, exercises, modes,
  progression policies, supersets.
- `frontend/src/lib/coach.js` — client-side apply/snapshot/revert; proposals never write
  server-side; applying is ordinary local editing.
- `api/coach/library.json` — 1,324 exercises.
- `docs/AI_COACH.md` — core principle: **Coach configures the plan; deterministic engine calculates
  the load.** AI outage does not block training.

### 4.2 Reference B — `DuarteSantos8/openGym`

Current upstream, materially ahead of A and already containing an evolved coach.

| Area | Verified evidence |
|---|---|
| Exercise catalogue | `catalogue/exercises/*.json` = **6,554**; 17 translation files; 13,109 media files |
| Content licensing | `NOTICE.md`: entries marked `textSource: "exercisedb"` retain MIT text from the 1,324 dataset; newer catalogue text is AGPL; media is Gym visual proprietary, not AGPL |
| Workout engine | `frontend/src/lib/workout-model.js` (work/warm-up, drop set, rest-pause, failure, per-side), `history.js`, `views/Workout.jsx` |
| Progression | `frontend/src/lib/progression.js`: `off/linear/greyskull/double/triple/time`, deloads, Epley-based deload target selection, per-exercise overrides |
| 1RM | `frontend/src/lib/onerm.js`: Epley/Brzycki/Lombardi/O'Conner/Mayhew/Wathan/Lander; weighted ensemble; rep cap 12 (15 ensemble) |
| Effort | `frontend/src/lib/effort.js`: RIR internal unit, RPE conversion, rated-set coverage, hard-set threshold |
| Rest timer | `components/RestTimer.jsx`: countdown, wheel adjustment, skip, reschedule-safe |
| Muscle map | `components/BodyMap.jsx`; geometry from MuscleMap under MIT (`NOTICE.md`) |
| Import | `lib/import-csv.js`: FitNotes, Strong, Hevy, openGym, GymMane |
| Plan sharing | `lib/plan-share.js`: merge-on-import, printable plan, canonical shape |
| AI Coach v2 | `api/coach/core/schemas.js`, `plan-hash.js`, `refine-changes.js`, `pipeline.js`, `validate.js`; schema-enforced output, plan fingerprint, repair round, phone/BYOK, ask/debrief |
| Mobile | `docs/MOBILE.md`: Capacitor shell; local-file build; CDN media |

**Correction:** the original master plan's 5,632 catalogue count is stale. Use **6,554**.

### 4.3 Reference C — exercise dataset

| Fact | Evidence |
|---|---|
| Records | **1,324** (parsed `data/exercises.json`) |
| Schema | `data/exercises.schema.json` (Draft 2020-12) |
| ID | Zero-padded four-digit string (`"0025"`) |
| Body parts | 10 values: upper arms 292, upper legs 227, back 203, waist 169, chest 163, shoulders 143, lower legs 59, lower arms 37, cardio 29, neck 2 |
| Equipment | 27 normalized values |
| Text | `instructions` + `instruction_steps` in 10 languages (en, it, tr, es, ru, zh, hi, pl, ko, fr); 0 missing English text/steps |
| Missing metadata | No difficulty, movement pattern, mechanic, RPE, contraindication, or per-record media license |
| Media fields | `image`, `gif_url`, `media_id`, `attribution` — all excluded from MIT |
| Provenance | Dataset → ExerciseDB v1 / AscendAPI; OpenGym `NOTICE.md` confirms MIT text provenance |

**Import consequence:** import text only under MIT with notice. Strip every media field/link. Keep
`exercises.image_url` null.

## 5. GymLvl architecture at audit time

### 5.1 Runtime

```text
Flutter screens
  → Riverpod 3 Notifiers
  → Supabase repositories
  → Supabase Auth
  → PostgREST + RLS
  → Edge Functions (Deno)
  → transactional RPCs
  → PostgreSQL
```

- Flutter 3.38.5 / Dart 3.10.4; Riverpod 3.1; GoRouter 17.1; Freezed 3; Supabase Flutter 2.12.2;
  `shared_preferences`; `fl_chart`.
- **No local database** (no Drift/Isar/SQLite), no connectivity layer, no sync outbox.
- **No wakelock, notifications, health, or media packages.**

### 5.2 Feature modules

| Module | State at audit |
|---|---|
| Auth | Session gate, login/register/reset, password recovery, explicit error states |
| Onboarding | Nine steps; `initialize_user(jsonb)`; six classes A–F; primary/secondary class |
| Dashboard | RPG hero XP, KPI tiles, 7-day activity, quests, volume chart, recent workouts |
| Workout | Picker, active session, rest timer, reorder, add/remove, local backup, summary, history, detail |
| Progression | Display-only XP estimate; server `complete_workout` authoritative |
| Quests | Daily quests; server generation/completion; streak-aware |
| Profile | Preferences, class display, locale |
| Coach | **Chat only**; `ai-coach` proxy; quota; no plan generation or mutation |

### 5.3 Backend

- 14 baseline tables + `workout_rewards`, `user_achievements`, `coach_daily_usage` = **17 tables**.
- Migrations: `20261026000100_baseline.sql` (661 lines),
  `20261026000200_authoritative_progression.sql` (349 lines),
  `20261027000100_exercise_catalog_metadata.sql` (367 lines).
- Catalog: **150** curated exercises.
- `complete_workout`: transactional, row-locks user/workout, replays `workout_rewards`, clamps
  suspicious pace, writes XP ledger/class XP/quest/streak. SQL regression passes.
- RLS/grants hardened; direct XP/level writes denied.

## 6. Defect register

Severity: P0 blocks release or risks data loss; P1 blocks product credibility; P2 polish/truth.

| ID | Severity | Finding | Evidence | Status 2026-10-28 |
|---|---|---|---|---|
| G-01 | **P0 mobile** | Release Android manifest has no `INTERNET` permission; only debug/profile do. A release APK cannot reach Supabase. | `android/app/src/main/AndroidManifest.xml` vs `debug/AndroidManifest.xml` | **OPEN** **[V-now]** |
| G-02 | **P0 data safety** | 166 uncommitted entries, 109 changed files, only a local branch; no snapshot/tag. | `git status` at audit | **RESOLVED EXTERNALLY** — committed/pushed as `56c1122`; tree clean **[V-now]** |
| G-03 | P1 | Android label `app`; iOS `CFBundleDisplayName` `App`, `CFBundleName` `app`. | manifests/plist | **OPEN** **[V-now]** |
| G-04 | P1 | "Offline" is overstated: active workout has a `shared_preferences` backup, but set add/update awaits the network before updating UI. No offline queue. | `active_workout_controller.dart`, `supabase_workout_repository.dart` | **OPEN** |
| G-05 | P1 | Catalog is 150 exercises, not 1,324; no `source`, `external_id`, `provenance`, `license`, or `content_version`; no import pipeline. | migration + seed | **OPEN** |
| G-06 | P1 | Exercise search loads the full table and filters only `name`; `name_vi`/`name_en`/instructions unused. | `exercise_providers.dart` | **OPEN** |
| G-07 | P1 | No weekly plan/routine/schedule domain; templates are hard-coded category lists. | `workout_templates.dart`, schema | **OPEN** |
| G-08 | P1 | No RPE/RIR, 1RM, PR display, warm-up/drop/rest-pause sets, supersets, cardio mode, per-side work, or plate math. | workout domain/UI; DB has `exercise_prs` only | **OPEN** |
| G-09 | P1 | AI Coach is chat-only: no intake, typed JSON, validation, proposal, approval, apply/revert, consent record, or audit log. Sends profile + 7-day history without a recorded consent version. | `coach_repository.dart`, `ai-coach/service.ts` | **OPEN** |
| G-10 | P1 | Docs contradict reality: `PROJECT.md` claims Orbitron eliminated while `pubspec.yaml` still declares it; `TEST_READY.md` says 83 tests; status says 126; milestone tables disagree. | docs | **OPEN** |
| G-11 | P2 | `CandyFonts.fallback = 'Inter'` is declared but no `fontFamilyFallback` found; Vietnamese coverage depends on each font. | theme | **OPEN** |
| G-12 | P2 | Legacy dark theme (`#030308`) remains in `core/theme/app_theme.dart`; app hardcodes light mode. | theme | **OPEN** |
| G-13 | P2 | No analytics: muscle map, heatmap, weight trend, PR chart, lift balance. | dashboard only | **OPEN** |
| G-14 | P2 | No Android CI build; iOS not built; Playwright smoke exists but was not run in the audit. | `.github/workflows/verify.yml` | **OPEN** |
| G-15 | Legal | No `LICENSE` or NOTICE in the GymLvl repo; provenance of the 150 curated Vietnamese texts undocumented. | repo root | **OPEN** **[V-now]** |

## 7. OpenGym A/B comparison

| Capability | A (emilfunk) | B (Duarte) | GymLvl at audit |
|---|---|---|---|
| 1,324 MIT text catalog | Yes | Superseded by 6,554 | 150 curated |
| Search/filter/aliases | Legacy | Yes, body part + equipment + custom + favourites | Name-only full-table filter |
| Exercise detail | Yes | Yes | Basic |
| Media demos | 1,324 | 6,554 | **Prohibited** |
| Weekly plan/routines | Yes | Yes + rotation + reschedule | None |
| Starter plans | Yes | Four starter plans | None |
| Guided workout | Yes | Much richer | Basic |
| Supersets/warm-ups/drop/rest-pause | Partial | Yes | None |
| Timed holds/cardio | Yes | Yes | Partial duration support |
| Rest timer | Yes | Yes, wheel + alerts | Foreground timer |
| Progression policies | Linear/Greyskull/double/time | + triple, deload tuning, per-exercise | None |
| 1RM/PR | Yes | Formula suite/ensemble, cap 12 | DB table only |
| RPE/RIR | Yes | Yes, normalized RIR | None |
| Bodyweight/weigh-ins | Yes | Yes + goal + rate | Initial weight only |
| Muscle map/heatmap | Yes | + recovery/untrained modes | None |
| History editing | Yes | Yes | None |
| Import/export | Limited | FitNotes/Strong/Hevy/Health/JSON | None |
| AI plan generation/review | Yes | Schema-enforced + mobile BYOK | Chat only |
| Consent/audit/apply/revert | Yes | Yes | None |
| Passkeys/sync/admin | Yes | Yes | Supabase auth only |
| Health/watch | No | Yes | None |

**What changed between A and B:** A is a fork snapshot around OpenGym 1.2 plus the original coach.
B is current upstream with schema-constrained output, one repair round, plan-hash staleness guard,
change-list validation, ask/debrief, and mobile BYOK. B's engine is materially richer.

**Both are AGPL.** B's app-store exception belongs to its copyright holder and does not transfer.

## 8. Feature gap and migration priority

| # | Capability | Current GymLvl | Decision | Priority | Milestone |
|---|---|---|---|---|---|
| 1 | Release Android/iOS config | Broken INTERNET; placeholder names | Fix natively | **P0** | M1 |
| 2 | Baseline freeze & docs truth | Clean commit, stale docs | Verify + reconcile | **P0** | M1 |
| 3 | Exercise catalog import (1,324) | 150 | Import MIT text only; new ETL | **P0** | M2 |
| 4 | Catalog schema/provenance | Minimal | Additive columns + source map | **P0** | M2 |
| 5 | Search/filter/local cache | Full-table fetch, name-only | Fresh Dart + local cache | **P0** | M2 |
| 6 | Offline workout logging | Backup only | Local outbox (Drift proposed) | **P0** | M3 |
| 7 | Workout modes (reps/time/cardio/bodyweight) | Partial | Extend schema/domain | **P0** | M3 |
| 8 | Rest timer + wake lock + background | Foreground timer | Harden; wakelock/notification | P1 | M3 |
| 9 | Supersets/warm-ups/drop sets | None | Superset + warm-up first | P1 | M3 |
| 10 | Weekly plans/routines/scheduling | None | New plan domain + UI | P1 | M5 |
| 11 | Progression policies/deload | None | Pure-Dart engine from spec/tests | **P0** | M4 |
| 12 | 1RM/PR | DB table only | Calculation + UI | P1 | M4 |
| 13 | RPE/RIR | None | Nullable columns + UI | P1 | M4 |
| 14 | Bodyweight trend | Initial weight only | Weigh-in table/chart | P2 | M5 |
| 15 | Muscle map/heatmap | None | Flutter painter; optional MIT geometry | P2 | M5 |
| 16 | History edit | None | Correction flow | P2 | M5 |
| 17 | AI intake/plan/review/apply | Chat only | Typed proposal architecture | P1 | M6 |
| 18 | Import/export/share | None | Later | P3 | M9 |
| 19 | Media | None | **Postponed** | P3 | M7 (gated) |
| 20 | Health/watch | None | Later | P3 | M9 |

### Reuse as concepts/specifications/tests

Coach/engine separation; consent categories; payload allowlist; pseudonymization; plan fingerprint;
closed change-type list; one repair round; proposal → approve → snapshot → apply → revert.
Progression semantics: advance only when every prescribed set met target; deload after consecutive
misses; Epley cap at 12 reps. RIR as internal effort unit; RPE conversion. Catalog taxonomy and
translation patterns. Test scenarios: duplicate completion, offline reconnect, timer background,
invalid IDs, stale proposals.

### Must be fresh Dart/SQL

All Flutter UI/state; local database/sync/outbox; progression math and validator; Supabase schema,
RLS, RPCs, Edge gateway; any catalog transformation.

### Never reuse

AGPL source, comments, prompts, catalogue text, or assets; Gym visual media, hotlinks, thumbnails,
GIFs, or derived media; OpenGym UI styling.

## 9. License and provenance matrix

| Item | Owner/source | License | Can GymLvl use it? | Obligations |
|---|---|---|---|---|
| GymLvl application code | GymLvl contributors | **No license file → all rights reserved by default** **[V-now]** | Internal use only until a license decision | Add project LICENSE; clarify contributor rights |
| 150 curated exercise texts | GymLvl (provenance undocumented) | Unknown **[U]** | Treat as project-owned only after audit | Document origin/reviewer |
| Dataset text/metadata | Hasan Emir Yıldırım; ExerciseDB v1 | **MIT** | Yes | MIT copyright + NOTICE; retain source/version; strip media |
| Dataset images/GIFs | Gym visual | Proprietary | **No** | Do not download, copy, hotlink, process, or feed to AI |
| OpenGym A code | emilfunk contributors | **AGPL-3.0** | Reference only | No copy/translation/port without compliance decision |
| OpenGym B code | Duarte Santos | **AGPL-3.0** + app-store exception | Reference only | Same; exception not transferable |
| OpenGym B new catalogue text | openGym community | **AGPL-3.0** | No (unless GymLvl goes AGPL) | Clean-room rewrite only |
| OpenGym media | Gym visual | Proprietary | **No** | No media reuse |
| MuscleMap geometry | Melih Colpan | **MIT** | Optional | Attribution + MIT notice |
| Bundled fonts | Google/OFL | **OFL** | Yes | Keep OFL notices; do not sell fonts standalone |
| Flutter packages | pub.dev | Various permissive | Yes | Standard notices |

**Recommended posture:** keep GymLvl proprietary for now; import only MIT text; require a written
legal decision before any AGPL-derived code or catalogue text. A clean-room process needs a behavior
spec → independent Dart implementation → tests derived from public behavior, with no AGPL source
open during implementation.

**Media:** no work authorized. `exercise_media` should default to `rights_status='unavailable'`;
release CI should fail if a `licensed` row lacks evidence.

## 10. Target architecture proposed by M0

### 10.1 Flutter modules

```text
app/lib/
  core/
    design_system/        # existing ui/candy, tokens, typography
    data/                 # repository interfaces, local db, sync
    config/ router/ localization/
  features/
    auth/
    onboarding/
    exercise_library/     # catalog, search, detail, aliases
    training_plan/        # plans, days, routines, scheduling
    workout/              # session, logging, timers, summary
    progression/          # pure Dart policies, 1RM, PR, deload
    analytics/            # heatmap, body map, weight, PR charts
    quests/ progression-rpg/ profile/
    coach/                # intake, proposals, review, consent
```

**Local storage recommendation: Drift.** Mature SQLite, migrations, testable, suitable for catalog
cache + outbox + drafts. Required tables: `cached_exercises`, `cached_instructions`,
`active_workout_draft`, `pending_mutations`, `sync_state`, `catalog_version`. This is a
**proposal**, not implemented and not yet approved.

### 10.2 Data contracts (additive)

```text
exercise_catalog
  id uuid pk (legacy exercises.id preserved)
  source text, external_id text, slug text unique
  name_en text, name_vi text
  body_part text, equipment text, target text, secondary_muscles text[]
  category text, movement_pattern text, difficulty text
  instructions jsonb, content_version int, active bool
  provenance jsonb
  UNIQUE(source, external_id)

exercise_source_map(legacy_exercise_id, source, external_id, confidence)
exercise_media(exercise_id, kind, object_key, rights_status default 'unavailable',
               license_reference, attribution, checksum)
```

Do not overwrite the existing 150 rows or change their UUIDs.

```text
training_plans(id, user_id, name, goal, class_id, version, status, created_at)
plan_days(id, plan_id, weekday, routine_id, order)
plan_routines(id, plan_id, name, progression_policy, notes)
plan_exercises(id, routine_id, exercise_id, position, mode, sets,
               reps_min, reps_max, seconds, distance, target_weight,
               rest_seconds, superset_group, progression_policy)
```

Workout sets gain nullable additive columns: `mode`, `set_type`, `rpe`, `rir`, `per_side`,
`distance_m`, `speed_kph`, `incline`, `failure`.

```text
coach_profiles(...)
coach_consents(...)
coach_proposals(id, user_id, kind, plan_version, plan_hash, payload_json,
                status, created_at, expires_at)
coach_proposal_items(id, proposal_id, change_type, target, before, after,
                     rationale, status)
coach_audit_logs(id, user_id, action, proposal_id, summary, created_at)
```

Proposals are inert; application is a transactional RPC, never an AI write.

### 10.3 Completion boundary

- `complete_workout(workout_id, idempotency_key)` remains the only award path.
- XP ledger uniqueness remains.
- AI/plan changes never touch completed workouts.
- Timestamps normalized to UTC; streaks/quests use `Asia/Ho_Chi_Minh` explicitly.

## 11. AI Coach architecture proposal

| Layer | Owns |
|---|---|
| AI gateway (Edge) | Auth, consent, quota, payload allowlist, provider call, schema validation, proposal persistence, audit |
| AI model | Judgement: routines, exercise selection, rationale, review changes |
| Deterministic Dart engine | Load targets, progression, deload, 1RM, PR |
| User | Approves/rejects each change |
| Database RPC | Atomic apply/revert, plan version/hash check, ownership check |

Flow: consent + intake → save profile/consent → request plan → Edge builds allowlisted payload +
pseudonym + catalog slice → provider returns structured JSON → Edge validates IDs/ranges/schema →
stores inert proposal → user selects changes → transactional RPC verifies hash/ownership, snapshots,
applies, audits → new plan version.

Non-negotiable contracts:

- No AI write access to `xp_logs`, `workouts`, `workout_sets`, `exercise_prs`, `users`, or
  `user_classes`.
- No invented exercise IDs; every ID resolves against the catalog or an explicit custom exercise.
- No load above actual history for a known exercise; unknown exercises start without weight.
- No medical diagnosis; pain/red flags trigger conservative advice and a recommendation to seek
  qualified care.
- Consent recorded and revocable; withdrawal deletes server-side proposal data and stops egress.
- Payload allowlist, versioned; no name, email, user ID, token, or media.
- Plan fingerprint prevents applying a proposal to a changed plan.
- One repair round, then fail safely. Never loop.
- Core training works without AI.

Provider abstraction: Deno adapter `invoke({ kind, payload, schema, model, timeoutMs }) -> { text }`.
Adapters: OpenAI-compatible, Gemini, fixture. Keys only in Supabase secrets.

Cost/abuse: atomic `consume_coach_request()` quota; per-intent caps; payload cap ~20 KB; history
window 12 weeks/60 sessions; timeout 15–25 s; no retry storm; token/cost counters; `COACH_DISABLED`
kill switch.

## 12. Risks and rollback

| Risk | Severity | Likelihood | Mitigation | Rollback |
|---|---|---|---|---|
| Uncommitted work lost | Critical | Was high | External bundle/archive; clean commit baseline | Restore bundle; never `reset --hard` |
| AGPL contamination | Critical | Medium | Clean-room spec; no sharing; provenance log; legal review | Remove derived files; reimplement |
| Media license breach | Critical | Medium | No media import; DB `unavailable`; CI scan | Purge assets/CDN; disable media UI |
| Existing history broken | Critical | Low | Additive migrations; preserve UUIDs; dry run on copy | Restore backup; feature flag |
| Offline data loss | High | Medium | Outbox + idempotency keys + replay tests | Revert to last synced state |
| AI applies bad plan | High | Medium | Validator, plan hash, approval, snapshot | `revert_coach_proposal`; workouts untouched |
| AI data leak | High | Medium | Consent, allowlist, pseudonym, RLS, no logs | Revoke consent; delete proposals; rotate keys |
| Prompt injection | High | High | Treat input as data; closed change types; no tools | Reject job; audit; no state change |
| Mobile release failure | High | High today | Fix manifest; CI build; device smoke | Rebuild previous artifact |
| Performance on 1,324 catalog | Medium | High | Local cache, pagination, FTS | Feature flag to 150 catalog |
| Docs drift | Medium | High | Single status source; doc checks | Revert doc commit |
| Supabase free-tier limits | Medium | Medium | Query budgets, cache, monitoring | Upgrade or reduce sync |
| Dependency drift | Medium | Medium | Pin versions; review updates | Restore lockfile |

Rollback rules:

1. **Git:** one branch per milestone; no force push; no destructive reset; preserve dirty workspace.
2. **Database:** backup before M2/M4; additive migrations with tested down scripts; never
   `TRUNCATE`/`DROP` user-linked tables; import to staging then upsert.
3. **Import:** source-keyed, idempotent; deleting imported rows must not orphan workout references.
4. **AI:** kill switch; proposals inert; apply snapshots the previous plan; revert plan only.
5. **Mobile:** internal build first; keep previous APK; staged rollout.

## 13. M1 scope proposed by M0

M0 recommended re-baselining M1 from "design-system foundation" (already implemented) to
release-critical stabilization:

- M1-01 snapshot/baseline artifacts
- M1-02 Android/iOS release config
- M1-03 typography cleanup + Vietnamese fallback
- M1-04 documentation truth pass
- M1-05 CI Android static build + config regression test
- M1-06 rendered baseline screenshots

See `MASTER_PLAN.md` §4 for the current definitions. M0's original M1-01 also proposed
`PROJECT_CONSTITUTION.md` and `UPSTREAM_SOURCE_MANIFEST.json`; the bootstrap session created the
memory system instead, and M1-01 now owns the manifest and license ledger.

## 14. Changes since the audit

| Date | Change | Effect |
|---|---|---|
| 2026-10-28 | Work committed as `56c1122` and pushed to `origin/codex/supabase-product-audit` | G-02 resolved; baseline is clean; 381 files, +33,198/−8,080 |
| 2026-10-28 | External backup bundle + archive created and verified | Preservation evidence recorded in `SESSION_HANDOFF.md` |
| 2026-10-28 | Nine memory/process files created | Durable context for future agents |
| 2026-10-28 | Baseline suites re-run at `56c1122` | analyze 0, Flutter 126, SQL 10, Edge 15, format clean |

**Not verified:** who created `56c1122`, whether CI ran on it, whether the Android release build
works, whether a live Supabase project matches the migrations, and whether the 150 curated exercise
texts have clean provenance.

## 15. What M0 did not do

- No application, SQL, Edge Function, or deployment changes.
- No catalog import.
- No media download or licensing outreach.
- No AGPL code reuse.
- No production database access.
- No commit or push.
- No claim that any unrun platform test passed.
