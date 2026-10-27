# Project: GymLvl — Full Product Recovery & Candy Neubrutalism Redesign

## Architecture
- **Client Tier**: Flutter (Dart 3.10.4 / Flutter 3.38.5) targeting Mobile, Web, and Desktop.
  - **Design System**: Candy Neubrutalism visual system (`CandyTheme`, `CandyColors`). Canvas `#fdf9f0`, Card `#ffffff`, Ink/Borders `#111111`, Hot Pink `#ff3d81`, Canary Yellow `#ffd23f`, Mint Green `#3ddc97`, Soft Lilac `#c8a2ff`, Coral `#ff6b5e`. 2px solid ink borders, hard unblurred drop shadows (4px/6px/9px), 18px card radii, fully rounded status pills.
  - **Typography**: Bundled variable fonts in `app/assets/fonts/` with full Vietnamese diacritic support: `Archivo` (weight 900 for display/headings), `Space Grotesk` (UI/body), `Space Mono` (numbers, stats, timestamps, XP). Complete elimination of legacy `Orbitron` fonts and dark-neon tokens.
  - **Component Library**: 16 tactile `Candy*` primitives in `app/lib/ui/candy/` (`CandyScaffold`, `CandyCard`, `CandyButton` with 80-140ms downward-right press offset, `CandyTextField`, `CandyBadge`, `CandyDialog`, `CandyBottomSheet`, `CandySkeleton`, `CandyEmptyState`, `CandyErrorState`, `CandyStatTile`, `CandyProgressBar`, `CandyNavigationItem`, `CandyExerciseCard`, `CandyWorkoutSetRow`, `CandyQuestCard`).
  - **State Management**: Riverpod 3.1.0 with fine-grained selectors (`.select()`) preventing timer-induced full-screen rebuilds.
  - **Navigation & Routing**: GoRouter 17.1.0 with smooth slide/fade transitions, persistent bottom tabs, active workout banner/modal, and zero layout overflow from 320px to 1440px.
  - **Workout Tracking Engine**: Complete core loop supporting weighted, bodyweight, and time-based/duration exercises. Interactive set logging, rest timer (with accurate 1s countdown, pause/resume, audio/haptic alert, background recovery), reorderable exercises (`ReorderableListView`), debounced set mutations, and local state persistence via `shared_preferences` for offline interruption recovery.
  - **Summary & Celebration**: Post-workout summary screen rendering earned XP, level progression, total volume, duration, class XP breakdown, and quest completions.
- **Backend Tier**: Supabase / PostgreSQL 17 with strict security hardening.
  - **Database Schema**: 17 core tables plus additive migration `20261027000100_exercise_catalog_metadata.sql` introducing exercise metadata (`slug`, `name_vi`, `name_en`, `secondary_muscles`, `movement_pattern`, `difficulty`, `form_cues`, `common_mistakes`, `alternative_exercise_slugs`) and set duration support (`duration_seconds` on `workout_sets`).
  - **Exercise Catalog**: 120–200 verified exercises seeded via idempotent `supabase/seed_exercises.sql` (`ON CONFLICT (slug) DO UPDATE`).
  - **Authoritative Progression**: Atomic `complete_workout` RPC with row locking (`FOR UPDATE`), idempotency replay protection via `workout_rewards`, anti-cheat rapid set limiter (>4 sets/min pace clamping), trigger anti-tamper guards on sets, and timezone-aware daily quests and streaks.
- **Edge Runtime Tier**: Deno-based Supabase Edge Functions.
  - `ai-coach`: Authenticated proxy with 20 req/day quota, request sanitization, 25s timeout, and graceful 503 fallback when unconfigured.
  - Proxy RPCs: `calculate-xp`, `get-user-stats`, `initialize-user`, `switch-class`, `sync-daily-data`.
- **Dual-Track Verification & QA Harness**:
  - Flutter test runner: `flutter analyze` (0 warnings), `dart format` (0 changes), `flutter test` (unit, widget, and UI regression across 320px–1440px viewports in VI and EN).
  - PostgreSQL test runner: Isolated PGlite runner executing 7 SQL test suites plus new migration and catalog verification.
  - Deno test runner: 14 Edge Function unit tests + adversarial coach and anti-cheat test suites.
  - Web production build: `flutter build web` verified with browser smoke testing.

---

## Feature Inventory
| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| 1 | Candy Neubrutalism Tokens & Palette | Replace dark cyberpunk theme with light Canvas `#fdf9f0`, Card `#ffffff`, Ink `#111111`, Hot Pink `#ff3d81`, Canary Yellow `#ffd23f`, Mint `#3ddc97`, Lilac `#c8a2ff`, Coral `#ff6b5e`, and 2px borders | M1 | survey |
| 2 | Vietnamese Typography System | Replace Orbitron with bundled Archivo (Black 900), Space Grotesk, and Space Mono with full Vietnamese diacritics support | M1 | survey |
| 3 | Candy Component Primitives (16 widgets) | Centralized tactile Neubrutalist widgets (`CandyScaffold`, `CandyCard`, `CandyButton`, `CandyTextField`, `CandyBadge`, etc.) | M1 | survey |
| 4 | Rebuilt Neubrutalist Dashboard | Dashboard with personalized greeting, RPG class badge, hero XP progression, 4 KPI tiles, 7-day activity grid, daily quests, streak, volume chart, recent workouts, and CTA | M2 | survey |
| 5 | Exercise Catalog Schema & 120-200 Seed Data | Additive migration for exercise metadata + `supabase/seed_exercises.sql` with 120-200 rich bilingual exercises | M3 | survey |
| 6 | Exercise Types Support (Weighted/Bodyweight/Time) | Full support for bodyweight (0kg hidden, reps only), weighted (kg + reps), and duration-based (seconds/timer) exercises in DB, models, and UI | M4 | survey |
| 7 | Interactive Workout Tracking & Exercise Reordering | Reorderable exercise list, add/remove exercises, inline set editing, debounced mutations, and completed toggles | M4 | survey |
| 8 | Resilient Rest Timer & Background Recovery | Accurate 1s rest timer, pause/resume, audio chime & haptic alert, auto-start on set completion, and background timestamp preservation | M4 | survey |
| 9 | Local Interruption Recovery | Persist active workout state in local storage (`shared_preferences`) alongside Supabase for offline restart & refresh resilience | M4 | survey |
| 10 | Post-Workout Summary & Level-Up Modal | Comprehensive post-workout summary rendering volume, duration, XP, level progression, class progression, and achievements | M4 | survey |
| 11 | Authoritative Progression & Quests Verification | PostgreSQL RPC atomicity, replay protection, quest category mapping, timezone streaks, and Deno edge proxies | M5 | survey |
| 12 | Performance & State Optimization | Elimination of N+1 queries during preset loading, fine-grained Riverpod selectors, and 320px-1440px layout overflow guards | M6 | survey |
| 13 | Dual-Track E2E Test Suite & Test Readiness | Publish `TEST_INFRA.md`, design Tiers 1-4 opaque-box tests, verify all layers, and publish `TEST_READY.md` | M7 | survey |
| 14 | Polish, Hardening & Forensic Victory Audit | Zero analyzer warnings, clean formatting, release web compilation, and clean forensic audit verdict | M8 | survey |

---

## Milestones

| # | Name | Scope & Owner | Dependencies | Status |
|---|------|---------------|-------------|--------|
| M0 | Survey & Baseline Audit | Complete repo audit across UI, Workout, and Backend systems | none | DONE |
| M1 | Candy Neubrutalism Design System Foundation | Agent A: `app/lib/core/theme/**`, `app/lib/ui/**`, bundled font assets, 16 `Candy*` primitives, eradicate Orbitron | M0 | DONE |
| M2 | Candy Neubrutalism Dashboard Overhaul | Agent A: Rebuild `dashboard_screen.dart` with 4 KPI tiles, weekly activity grid, recent workout feed, hero XP card, tactile CTA | M1 | IN_PROGRESS |
| M3 | Exercise Catalog Schema & Seed Data Expansion | Agent D & C: Additive migration for exercise metadata & duration, author `supabase/seed_exercises.sql` (120-200 exercises), update config & test runner | M0 | DONE |
| M4 | Core Workout Lifecycle & UX Resilience | Agent B: Exercise reordering, weighted/bodyweight/time-based types, rest timer with pause/resume & audio alert, local interruption recovery, post-workout summary screen | M1, M3 | DONE |
| M5 | Progression, Quests & Game Systems Polish | Agent C: Connect quests to workout templates, timezone streaks, class progression, and verify Edge functions | M3, M4 | IN_PROGRESS |
| M6 | Performance, State & Navigation Integration | Lead Orchestrator: Route transitions, Riverpod selectors, debounced set inputs, batching RPCs, 320px-1440px viewport validation | M2, M4, M5 | PLANNED |
| M7 | Comprehensive Dual-Track E2E Test Suite | Agent E: Publish `TEST_INFRA.md`, build Tiers 1-4 automated tests across Flutter, PostgreSQL, Edge, and browser smoke, publish `TEST_READY.md` | M1–M6 | IN_PROGRESS |
| M8 | Final Acceptance Verification & Victory Audit | All Agents & Lead Orchestrator: 100% test pass, release web build, forensic audit, user acceptance guide | M7 | PLANNED |

---

## Interface Contracts

### Exercise Metadata & Duration Schema
- **`public.exercises` Table Extensions**:
  - `slug text UNIQUE`: URL/ID-safe unique identifier (e.g. `barbell-bench-press`).
  - `name_vi text NOT NULL DEFAULT ''`: Vietnamese display name.
  - `name_en text NOT NULL DEFAULT ''`: English display name.
  - `secondary_muscles text[] DEFAULT '{}'`: Secondary targeted muscle groups.
  - `movement_pattern text`: `push`, `pull`, `squat`, `hinge`, `carry`, `lunge`, `isolation`.
  - `difficulty text`: `beginner`, `intermediate`, `advanced`.
  - `form_cues text[] DEFAULT '{}'`: Key technique reminders.
  - `common_mistakes text[] DEFAULT '{}'`: Pitfalls to avoid.
  - `alternative_exercise_slugs text[] DEFAULT '{}'`: Suggested alternatives.
- **`public.workout_sets` Table Extensions**:
  - `duration_seconds integer DEFAULT 0`: Duration in seconds for static holds or timed exercises.
  - Check constraint updated: `(NOT is_completed OR reps > 0 OR duration_seconds > 0)`.

### Candy Neubrutalism Component APIs
- **`CandyButton`**:
  - Props: `label`, `onPressed`, `variant` (primary Pink, secondary Yellow, mint Green, lilac Lilac, danger Coral), `icon`, `size`, `isLoading`.
  - Behavior: Tactile downward-right translation (2px offset) and shadow reduction (4px to 2px) on press (80–140ms duration).
- **`CandyCard`**:
  - Props: `child`, `backgroundColor`, `borderColor`, `borderWidth` (default 2px), `shadowOffset` (default 6px), `padding`, `borderRadius` (default 18px).
- **`CandyScaffold`**:
  - Props: `body`, `appBar`, `floatingActionButton`, `bottomNavigationBar`, `gridBackground` (default true, 24px grid pattern `#111111` at 5% opacity).

### Workout Local Recovery Contract
- **Storage Key**: `gymlvl_active_workout_backup`
- **JSON Structure**: `{ "workout": WorkoutJson, "local_updated_at": Iso8601String, "unsaved_sets": [...] }`
- **Behavior**: On app launch, check local storage before or concurrently with Supabase; if local backup exists and has newer timestamps, offer immediate restore or auto-restore with toast notification.

---

## Code Layout & Team Ownership
- **Agent A (UI/UX Design System)**:
  - `app/lib/core/theme/**`
  - `app/lib/ui/**` (specifically `app/lib/ui/candy/**`)
  - `app/assets/fonts/**`
  - `app/lib/features/dashboard/**`
- **Agent B (Workout Feature)**:
  - `app/lib/features/workout/**`
- **Agent C (Backend & Game Systems)**:
  - `supabase/migrations/**`
  - `supabase/functions/**`
  - `app/lib/features/progression/**`
  - `app/lib/features/quests/**`
- **Agent D (Exercise Content)**:
  - `supabase/seed_exercises.sql`
  - Exercise catalog scripts, datasets, and catalog sync utilities
- **Agent E (QA & Performance)**:
  - `app/test/**`
  - `supabase/functions/tests/**`
  - `tools/db-tests/**`
  - `TEST_INFRA.md`, `TEST_READY.md`
- **Lead Agent (Orchestrator)**:
  - Architecture decisions, `PROJECT.md`, routing (`app/lib/core/router/**`), `app/lib/main.dart`, integration review.
