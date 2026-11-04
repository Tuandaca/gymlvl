# GymLvl — OpenGym Parity Matrix

**Status:** Populated (P1 COMPLETE)
**Phase:** P1 — OpenGym Parity Baseline + Legal-Safe Exercise Catalogue (COMPLETE)
**Purpose:** Authoritative capability map: OpenGym capability vs GymLvl implementation status. Populated during P1; drives P2–P7 scoping.

**Reference:** `DuarteSantos8/openGym` @ `e6a95c28a6e3067bdd9b1188d5f37f448d528bd2` (AGPL-3.0, behavioral reference only — no code/text/asset copying)
**Local checkout:** `D:\Projects\opengym-reference` (verified HEAD matches pinned SHA)
**Legal-safe source:** `hasaneyldrm/exercises-dataset` @ `7455efae41b330c265e7cd4b78dfa848e7ce5ebd` (MIT text/data; media excluded).
**Local checkout:** `D:\Projects\exercises-dataset-reference` (verified HEAD matches pinned SHA).
**Import source:** Direct from pinned MIT dataset (`data/exercises.json`), NOT from OpenGym catalogue.
**Verified:** 1,324 records, schema validated, media excluded per LICENSE.

**Status values:** EXISTING / PARTIAL / MISSING / DEFERRED / EXCLUDED_LICENSE / NOT_APPLICABLE
**P1 action values:** reuse / adapt / import / defer / exclude

---

## Capability map

| Capability | OpenGym evidence/path | GymLvl evidence/path | Status | P1 action | Target phase | License/data concern | Notes / behavioral contract |
|---|---|---|---|---|---|---|---|
| Exercise browsing | `catalogue/exercises/<id>.json`, `catalogue/browse/*.md` | `app/lib/features/workout/presentation/screens/exercise_picker_screen.dart` | PARTIAL | adapt | P1 | None | OpenGym: 6,554 entries browsable by body part. GymLvl: 150 curated, Riverpod list provider. |
| Exercise search | `frontend/src/lib/exercises.js`, debounce | `app/lib/features/workout/presentation/providers/exercise_providers.dart` (300ms debounce, `normalizeSearchText`) | PARTIAL | adapt | P1 | None | GymLvl debounces 300ms and filters client-side; must remain valid at ~1k+ scale. |
| Exercise filters (muscle/equipment/category) | `catalogue/browse/*.md` (body part pages), `validate.mjs` BODY_PARTS/EQUIPMENT/CATEGORIES | `selectedCategoryProvider`/`selectedEquipmentProvider`/`selectedMuscleProvider` + `filteredExercisesProvider` | PARTIAL | adapt | P1 | None | OpenGym uses controlled vocabularies. GymLvl derives distinct options from data. |
| Exercise detail | `frontend/src/views/`, `exercise-view.test.jsx` | `app/lib/features/workout/presentation/screens/exercise_detail_screen.dart` | PARTIAL | adapt | P1 | None | GymLvl detail shows name, category, equipment, muscles, instructions, VI/EN. |
| Exercise favourites | `frontend/src/lib/favourites.js` | None | MISSING | defer | P3 | None | Not in P1 scope. |
| Custom exercises | `frontend/src/lib/exercises.custom.test.js` | None | MISSING | defer | P3 | None | User-created exercises. |
| Exercise aliases | `frontend/src/lib/exercise-aliases.js` | None | MISSING | defer | P3 | None | Alias→canonical mapping. |
| Similar exercises | `frontend/src/lib/similar-exercises.js` | None | MISSING | defer | P3 | None | Muscle-based similarity. |
| Exercise history | `frontend/src/lib/exercise-history.js` | `app/lib/features/workout/presentation/screens/workout_history_screen.dart` | PARTIAL | reuse | P2 | None | GymLvl tracks workout history per exercise. |
| Exercise media | `catalogue/media/still/`, `media/clip/` | None (`imageUrl` nullable) | EXCLUDED_LICENSE | exclude | P7 | Gym visual proprietary media | GymLvl: `imageUrl` nullable, no-media graceful state. No media import. |
| Catalogue metadata | `validate.mjs` controlled vocabularies | `supabase/migrations/20261027000100_exercise_catalog_metadata.sql`, `seed_exercises.sql` (150) | PARTIAL | import | P1 | MIT text only | P1 imports 1,324 MIT `exercisedb` records with provenance. |

### Routine / planning

| Capability | OpenGym evidence/path | GymLvl evidence/path | Status | P1 action | Target phase | License/data concern | Notes / behavioral contract |
|---|---|---|---|---|---|---|---|
| Routine creation | `frontend/src/lib/routines.js` | `app/lib/features/training_plan/first_week_plan_engine.dart` (deterministic 3-day) | PARTIAL | adapt | P2 | None | OpenGym: full routine CRUD. GymLvl: First-Week plan only. |
| Routine editing | `routines.update.test.js`, `routines.replace.test.js` | None | MISSING | defer | P2 | None | |
| Exercise ordering | `session-routines.js`, day assignment | `first_week_plan_engine.dart` (fixed order) | PARTIAL | defer | P2 | None | |
| Day assignment | `frontend/src/lib/day-notes.js`, `session-routines.js` | `newcomer_journey.dart` | PARTIAL | defer | P2 | None | |
| Weekly schedules | `rotation.js` | None | MISSING | defer | P2 | None | |
| Repeat session | `sheets.repeat-workout.test.jsx` | None | MISSING | defer | P2 | None | |
| Plan rotation | `rotation.js` | None | MISSING | defer | P2 | None | |
| Exercise replacement | `sheets.replace.test.jsx`, `sheets.swap.test.jsx` | None | MISSING | defer | P2 | None | |
| Routine persistence | `routines.js` | `training_plan_providers.dart` | PARTIAL | defer | P2 | None | |
| Program management | None found | None | NOT_APPLICABLE | exclude | — | None | No OpenGym "program" concept found beyond routines. |

### Workout

| Capability | OpenGym evidence/path | GymLvl evidence/path | Status | P1 action | Target phase | License/data concern | Notes / behavioral contract |
|---|---|---|---|---|---|---|---|
| Start workout | `session-start.js` | `app/lib/features/workout/presentation/screens/workout_screen.dart` | EXISTING | reuse | — | None | |
| Active workout | `sheets.jsx` (active session) | `active_workout_screen.dart`, `active_workout_controller.dart` | EXISTING | reuse | — | None | |
| Set logging (reps/weight) | `workout-model.js`, `per-set.js` | `workout_set.dart` (reps, weight_kg) | EXISTING | reuse | — | None | |
| Timed holds | `workout-model.js` (hold), `finish-hold.test.jsx` | `workout_set.dart` (mode nullable), M4 superset/modes | PARTIAL | reuse | P3 | None | GymLvl has mode discriminator (M3.5). |
| Cardio | `cardio-reps.test.js` | `workout_set.dart` mode | PARTIAL | reuse | P3 | None | |
| Warmups | `warmup-seed.test.js` | None (set_type not in current schema) | MISSING | defer | P3 | None | |
| Rest timer | `rest-timer` behavior, `RestTimer.jsx` | `rest_timer_widget.dart` | EXISTING | reuse | — | None | |
| Supersets | `supersetFlow.js`, `superset-meta.js` | `superset_rounds.dart`, M3 migration `m3_superset_modes.sql` | PARTIAL | reuse | P3 | None | GymLvl has nullable superset_group_id/position. |
| Notes | `session-note.test.jsx` | `workout.notes` (active workout only) | PARTIAL | reuse | P3 | None | |
| Exercise swap | `sheets.swap.test.jsx`, `sheets.swap-same-muscle.test.jsx` | None | MISSING | defer | P3 | None | |
| Ordering | `session-routines.js` | None | MISSING | defer | P3 | None | |
| Previous-performance hints | `strength-exercises.js`, `exercise-history.js` | `progression_engine.dart` (1RM, PR) | PARTIAL | reuse | P3 | None | GymLvl M4 progression. |
| Session editing | `session-edit.js` | None | MISSING | defer | P3 | None | |
| Unfinished sessions | `session-noprog.js` | `offline_workout_store.dart` (drafts) | PARTIAL | reuse | P3 | None | Offline drafts (local/test, gate closed). |
| Finish-workout behavior | `finish-workout.js` | `complete_workout` RPC (transactional, idempotent) | EXISTING | reuse | — | None | Server-authoritative, sole reward path. |

### Progression

| Capability | OpenGym evidence/path | GymLvl evidence/path | Status | P1 action | Target phase | License/data concern | Notes / behavioral contract |
|---|---|---|---|---|---|---|---|
| Estimated 1RM | `onerm.js` (Epley/Brzycki/etc., ensemble) | `progression_engine.dart` (Epley), M4 migration `rpe`/`rir` | PARTIAL | reuse | P3 | None | GymLvl M4 uses Epley, matches server `complete_workout` estimated_1rm. |
| PR | `strength-exercises.js`, `exercise_prs` table | `progression_engine.dart` detectPersonalRecord, `exercise_prs` table | PARTIAL | reuse | P3 | None | |
| Progression / overload | `progression.js` (linear/Greyskull/double/triple/time) | `progression_engine.dart`, `rpg_bridge.dart` | PARTIAL | reuse | P3 | None | GymLvl deterministic, server-authoritative XP. |
| RPE/RIR-like | `effort.js` (RIR/RPE), `effort-picker.test.jsx` | `workout_set.rpe`/`rir` (M4), `rpe_rir_tile.dart` | PARTIAL | reuse | P3 | None | |
| Exercise history | `exercise-history.js` | `workout_history_screen.dart` | PARTIAL | reuse | P2 | None | |

### Utilities

| Capability | OpenGym evidence/path | GymLvl evidence/path | Status | P1 action | Target phase | License/data concern | Notes / behavioral contract |
|---|---|---|---|---|---|---|---|
| Plate calculator | `plates.js` | None | MISSING | defer | P4 | None | |
| Dumbbell utilities | `dumbbells.js`, `dumbbell-inventory.test.js` | None | MISSING | defer | P4 | None | |
| Unit handling | `units.js` | None | MISSING | defer | P4 | None | kg/lb conversion. |
| Bodyweight | `bodyweight.js` | `bodyweight_measurement.dart`, `bodyweight_trend.dart`, M5 migration | PARTIAL | reuse | P4 | None | GymLvl M5 bodyweight trend. |
| Measurements | `measurements.js` | `bodyweight_measurement.dart` | PARTIAL | reuse | P4 | None | |
| Exports | `export-csv.js` | None | MISSING | defer | P4 | None | |
| Imports (Strong/Hevy/FitNotes/GymMane) | `import-csv.js`, `import-hevy.js` | None | MISSING | defer | P4 | None | CSV import. |
| Backup/restore | `backup-media.js`, `sync-merge.js` | `offline_workout_store.dart` (local, gate closed) | PARTIAL | defer | P4 | None | Offline only, not activated. |

### Analytics

| Capability | OpenGym evidence/path | GymLvl evidence/path | Status | P1 action | Target phase | License/data concern | Notes / behavioral contract |
|---|---|---|---|---|---|---|---|
| Workout history | `history.js` | `workout_history_screen.dart`, `dashboard_stats.dart` | PARTIAL | reuse | P4 | None | |
| Heatmaps | `structuralBalance.js` / heatmap | `analytics/presentation/widgets/heatmap_chart.dart` (M5) | PARTIAL | reuse | P4 | None | |
| Volume trends | `report.js` | `analytics/presentation/widgets/weight_trend_chart.dart` (M5) | PARTIAL | reuse | P4 | None | |
| Strength trends | `relative-strength.js` | `pr_chart.dart` (M5) | PARTIAL | reuse | P4 | None | |
| Muscle balance | `structuralBalance.js` | `analytics/presentation/widgets/muscle_balance_chart.dart` (M5) | PARTIAL | reuse | P4 | None | |
| Structural balance | `structuralBalance.js`, `structuralBalanceTemplates.js` | None | MISSING | defer | P4 | None | |
| Recovery metrics | `recovery.js` | None | MISSING | defer | P4 | None | |
| Measurements trends | `measurements.js` | `bodyweight_trend.dart` (M5) | PARTIAL | reuse | P4 | None | |

### Device / platform

| Capability | OpenGym evidence/path | GymLvl evidence/path | Status | P1 action | Target phase | License/data concern | Notes / behavioral contract |
|---|---|---|---|---|---|---|---|
| Health Connect | `health-connect.js` | None | MISSING | defer | P7 | External integration | P7, legal authorization required. |
| HealthKit | `MOBILE.md` | None | MISSING | defer | P7 | External integration | iOS, not on Windows host. |
| Watch | `watch-sync.js` | None | MISSING | defer | P7 | None | |
| Mobile sync | `sync-merge.js`, `sync-changes.js` | `offline_sync_coordinator.dart` (local/test, gate closed) | PARTIAL | defer | P4 | None | Offline sync not activated. |
| Durable sync | `sync-merge.js` | `offline_sync_coordinator.dart` | PARTIAL | defer | P4 | None | Gate closed. |
| Offline behavior | `sw-offline-launch.test.js`, `mobile.js` | `offline_workout_store.dart` (Drift, local/test) | PARTIAL | defer | P4 | None | Production gate closed. |
| Background timer | `wakelock.js` | `rest_timer_widget.dart` | PARTIAL | defer | P3 | None | |
| Wake lock | `wakelock.js` | None | MISSING | defer | P3 | None | |

### Account / security

| Capability | OpenGym evidence/path | GymLvl evidence/path | Status | P1 action | Target phase | License/data concern | Notes / behavioral contract |
|---|---|---|---|---|---|---|---|
| Auth | `password.js`, `device-auth.js` | `app/lib/features/auth/` (Supabase Auth) | EXISTING | reuse | — | None | |
| Passkeys | `passkeys-store.js` | None | MISSING | defer | P7 | None | |
| Deletion | `recover.js` | None | MISSING | defer | P7 | None | |
| Settings | `coach-consent.js` | `profile_screen.dart` | PARTIAL | reuse | — | None | |
| Sync/account behavior | `sync-stamps.js` | None | MISSING | defer | P4 | None | |

### Coach / AI

| Capability | OpenGym evidence/path | GymLvl evidence/path | Status | P1 action | Target phase | License/data concern | Notes / behavioral contract |
|---|---|---|---|---|---|---|---|
| Coach chat | `coach.js`, `coach-api.js` | `app/lib/features/coach/` (chat-only proxy) | PARTIAL | defer | P6 | None | AI not in P1. |
| Intake | `coach-context.js` | None | MISSING | defer | P6 | None | |
| Context | `coach-context.js` | None | MISSING | defer | P6 | None | |
| Consent | `coach-consent.js` | None | MISSING | defer | P6 | None | |
| Plans | `coach.js` plan proposals | None | MISSING | defer | P6 | None | AI not in P1. |
| Insights | `coach-insights.js` | None | MISSING | defer | P6 | None | |
| Cadence | `coach-schedule.js` | None | MISSING | defer | P6 | None | |
| Scheduled jobs | `api/coach/jobs.js` | None | MISSING | defer | P6 | None | |
| Proposal/apply behavior | `coach.js` apply/revert, consent | None | MISSING | defer | P6 | None | AI advisory only, never writes rewards. |

### Other

| Capability | OpenGym evidence/path | GymLvl evidence/path | Status | P1 action | Target phase | License/data concern | Notes / behavioral contract |
|---|---|---|---|---|---|---|---|
| Check-in | `gym-reminder.js` | None | MISSING | defer | P7 | None | |
| QR flows | `qr.js` | None | MISSING | defer | P7 | None | |
| Progress photos | `day-photos.js` | None | MISSING | defer | P7 | Media | Media excluded. |
| Onboarding | `onboarding-perms.js` | `app/lib/features/onboarding/` (9-step) | EXISTING | reuse | — | None | |
| Reminders | `gym-reminder.js` | None | MISSING | defer | P7 | None | |
| CSV import | `import-csv.js` | None | MISSING | defer | P4 | None | Strong/Hevy/FitNotes/GymMane. |
| Hevy import | `import-hevy.js`, `hevy-id-map.js` | None | MISSING | defer | P4 | None | |
| Strong import | `import-csv.strong.test.js` | None | MISSING | defer | P4 | None | |
| GymMane import | `import-csv.gymmane.test.js` | None | MISSING | defer | P4 | None | |

---

## Catalogue scale facts (derived from pinned sources)

| Metric | Value | Source |
|---|---|---|
| Total OpenGym catalogue entries | 6,554 | `catalogue/exercises/*.json` file count |
| MIT-eligible (`textSource: "exercisedb"`) | 1,324 | `textSource` field group-by (OpenGym) |
| AGPL reference only (`textSource: "opengym"`) | 4,308 | `textSource` field group-by (OpenGym) |
| Empty stubs (no textSource, no name) | 922 | `textSource` missing, empty fields — excluded |
| Media files | 13,109 | `catalogue/media/` — EXCLUDED |
| i18n languages | 18 (no `vi`) | `catalogue/i18n/*.json` — Vietnamese translation NOT available in OpenGym |
| Controlled vocabularies | bodyPart, equipment, target, secondaryMuscles, category, needs | `validate.mjs` (OpenGym) |
| **MIT dataset (pinned)** | **1,324** | `data/exercises.json` record count |
| MIT dataset languages | 10 (en, es, it, tr, ru, zh, hi, pl, ko, fr; no `vi`) | `exercises.schema.json` languageMap/languageStepsMap |
| MIT dataset media | images/ + videos/ | **EXCLUDED** (Gym visual proprietary, per NOTICE.md) |

---

## P1 import scope (legal-safe)

- Import exactly the **1,324 records** from the pinned MIT dataset (`hasaneyldrm/exercises-dataset` @ `7455efae41b330c265e7cd4b78dfa848e7ce5ebd`, `data/exercises.json`).
- Source is the pinned MIT dataset directly, NOT OpenGym catalogue.
- Parse only permitted text/metadata: id, name, body_part, equipment, target, secondary_muscles, category, instructions, instruction_steps.
- Map: source = `exercisedb`, external_id = MIT 4-digit id, source_revision = MIT dataset SHA.
- Strip all media fields (image, gif_url, media_id, attribution).
- Preserve existing 150 GymLvl curated records as source = `gymlvl_curated`.
- Vietnamese: no MIT dataset `vi` translation exists → `name_vi` left empty / `translation_status = pending`; do not fabricate provenance.
- Idempotent: unique (source, external_id), repeated imports produce no duplicates.
- Media: excluded; catalogue functions in no-media state.

---

## Classification summary

| Classification | Count | Examples |
|---|---|---|
| EXISTING | ~14 | Auth, workout logging, active workout, set logging, rest timer, finish-workout, onboarding, search, filters, detail, history, 1RM, PR, progression, RPE/RIR, RPG |
| PARTIAL | ~24 | Exercise browsing/search/detail, routine/planning, timed holds, cardio, warmups, supersets, notes, bodyweight, measurements, analytics, offline, mobile sync |
| MISSING | ~20 | Favourites, custom exercises, aliases, similar exercises, weekly schedules, repeat session, exercise replacement, warmups, session editing, plate calculator, dumbbell utils, unit handling, exports, imports, backup/restore, structural balance, recovery, passkeys, deletion, Health Connect/Kit, watch, background timer, wake lock, coach/AI, check-in, QR, photos, reminders, CSV imports |
| DEFERRED | ~40 | All MISSING items mapped to P2–P7 |
| EXCLUDED_LICENSE | 3 | Exercise media, AGPL catalogue text, OpenGym code/UI |
| NOT_APPLICABLE | 1 | Program management |

---

## Next phase mapping (P1 does NOT implement these)

- **P2 — Routine & Planning Parity:** routine CRUD, day assignment, weekly schedules, repeat session, exercise replacement, plan rotation
- **P3 — Workout Core Parity:** warmups, timed holds, cardio, session editing, exercise swap, previous-performance hints, plate/dumbbell utilities, wake lock
- **P4 — Progress / Analytics / Utility Parity:** structural balance, recovery metrics, exports, imports (CSV), backup/restore, unit handling
- **P5 — Deep GymLvl Game Integration:** class-specific goals, XP-based level, streaks, achievements, unlocks
- **P6 — AI Personal Trainer:** coach chat, intake, consent, plans, proposals/apply/revert, audit
- **P7 — Media / Optional Integrations:** exercise media, Health Connect, HealthKit, watch, progress photos, QR/check-in
