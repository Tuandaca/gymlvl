# Original User Request

## 2026-10-26T14:17:05Z

GymLevel: RPG-style Fitness Gamification App built with Flutter (Riverpod, GoRouter) and Supabase (PostgreSQL, Auth, Edge Functions). Autonomously progress through remaining project phases, verify all flows, and produce the final polished build for real user acceptance testing before production deployment.

Working directory: d:\Projects\gymlvl
Integrity mode: development

## Requirements

### R1. Flutter Client Integrity and Stability
Ensure all Flutter client workflows (Auth registration/login/recovery, 9-step onboarding, interactive workout sessions with timer and set tracking, dashboard stats/charts, daily quests, and RPG class progression) compile cleanly, conform to responsive design across viewports (320px to 1440px), support full VI/EN localization, and have 100% passing automated test suites with zero analyzer warnings.

### R2. Backend Authoritative Operations and Database Security
Enforce authoritative server-side progression (XP, levels, quest completions, streak calculations) through PostgreSQL migrations, RLS policies, and Supabase Edge Functions. Prevent direct client manipulation of XP/rewards, avoid bearer-token logging, and guarantee atomic transactional workout submissions.

### R3. AI Coach Integration and Graceful Degradation
Support the server-side AI Coach Edge Function proxy with configurable chat completion endpoints, strict rate-limiting (20 req/day), request sanitization, and graceful 503 fallback when unconfigured without interrupting offline/standard workout logging.

### R4. Automated Verification, Phase Progression, and Build Readiness
Validate all components against the test harness: Flutter unit/widget/regression tests, isolated PostgreSQL 17 regression suites, Edge Function Deno tests, browser smoke tests, and build a deployable release bundle ready for end-user acceptance testing.

## Acceptance Criteria

### Automated Test Passing
- [ ] `flutter analyze` passes with 0 errors and 0 warnings in `app/`.
- [ ] `dart format --output=none --set-exit-if-changed lib test` passes without changes in `app/`.
- [ ] All Flutter unit, widget, and UI regression tests pass (`flutter test`).
- [ ] Isolated PostgreSQL 17 test harness passes all 7 SQL verification suites (`npm.cmd test` in `tools/db-tests`).
- [ ] Edge functions test harness passes all 14 Deno tests (`npm.cmd run test:edge` in `tools/db-tests`).
- [ ] Web production build compiles successfully (`flutter build web`) and passes browser smoke verification (`npm.cmd run test:web`).

### Core User Journeys
- [ ] User can authenticate, recover password, and persist authentication state across app relaunches.
- [ ] User completes onboarding through all 9 steps without layout overflows at 320px mobile viewport or desktop.
- [ ] User can start, pause, resume, log sets/weight/reps, and complete a workout with authoritative XP calculation and duplicate submission prevention.
- [ ] Dashboard displays accurate stats, level progression, and RPG class attributes in both Vietnamese and English.
- [ ] AI Coach gracefully displays offline/unconfigured notice when server endpoint is unconfigured.
- [ ] Final runnable package and clear instructions are prepared for end-user acceptance testing.


## 2026-10-27T08:45:05Z

# GYMLVL — FULL PRODUCT RECOVERY & CANDY NEUBRUTALISM REDESIGN

Working directory: d:\Projects\gymlvl
Integrity mode: development
Requested team: Full multi-agent engineering team (Agents A–E + Lead Orchestrator)

## Project Summary
GymLvl is an RPG-style fitness gamification application (Flutter, Riverpod, GoRouter, Supabase PostgreSQL, Edge Functions) turning workouts into character progression (XP, levels, quests, streaks). Transform the application into a polished, responsive, and tactile production-ready product featuring a complete core workout loop, reliable RPG progression, an expanded exercise catalog (120–200 exercises), and a bold Candy Neubrutalism visual system.

## 1. Non-Negotiable Rules
- Audit the actual repository before editing code. Do not trust the README as the source of truth.
- Preserve working functionality and existing user data.
- Never deploy destructive database changes or use TRUNCATE against populated user data.
- Do not create fake implementations, misleading success messages, fake analytics, or decorative buttons without functional behavior.
- Do not leave TODO placeholders for any feature declared complete.
- Do not hide exceptions by returning null or empty collections when genuine errors occur.
- Do not rewrite the entire application unnecessarily; fix proven issues and document architectural decisions.
- Each agent must own a clearly defined file scope to prevent merge conflicts:
  - Agent A (UI/UX Design System): `app/lib/core/theme/**`, `app/lib/ui/**`, shared assets.
  - Agent B (Workout Feature): `app/lib/features/workout/**`.
  - Agent C (Backend & Game Systems): `supabase/functions/**`, `supabase/migrations/**`, `app/lib/features/progression/**`, `app/lib/features/quests/**`.
  - Agent D (Exercise Content): `supabase/seed_exercises.sql`, exercise catalog scripts & datasets.
  - Agent E (QA & Performance): `app/test/**`, `supabase/functions/tests/**`, test harnesses.
  - Lead Agent (Orchestrator): architecture decisions, routing (`app/lib/core/router/**`), `main.dart`, integration review.
- Each agent must provide tests, implementation notes, and evidence of completion.

## 2. Requirements

### R1. Candy Neubrutalism Design System & Dashboard Overhaul
- Completely replace legacy cyberpunk/dark-neon HUD with the **Candy Neubrutalism** visual system:
  - Palette: Canvas `#fdf9f0`, Card `#ffffff`, Ink/Borders `#111111`, Hot Pink `#ff3d81` (primary), Canary Yellow `#ffd23f`, Mint Green `#3ddc97`, Soft Lilac `#c8a2ff`, Coral `#ff6b5e` (error/negative). Subtle 24px grid background (`rgba(17,17,17,0.05)`).
  - Typography: `Archivo Black` (display/headings), `Space Grotesk` (UI/body), `Space Mono` (numbers, stats, timestamps, XP). Full Vietnamese diacritic support.
  - Borders & Shadows: 2px solid `#111111` borders, hard unblurred `#111111` drop shadows (small 4px, medium 6px, large 9px), 18px card radii, fully rounded status pills.
  - Centralized component library: `CandyScaffold`, `CandyCard`, `CandyButton` (tactile 80-140ms press with downward-right offset & reduced shadow), `CandyTextField`, `CandyBadge`, `CandyDialog`, `CandyBottomSheet`, `CandySkeleton`, `CandyEmptyState`, `CandyErrorState`, `CandyStatTile`, `CandyProgressBar`, `CandyNavigationItem`, `CandyExerciseCard`, `CandyWorkoutSetRow`, `CandyQuestCard`.
  - Rebuilt Dashboard layout: personalized greeting + RPG class badge, hero XP/level progression card, 4 accent KPI tiles, weekly activity visualization, daily quest summary, streak tracker, workout volume trend chart, recent workout feed, and primary CTA to train.

### R2. Complete Core Workout Lifecycle & UX Resilience
- Complete the end-to-end workout loop without dead ends or fake controls:
  - Create or resume workouts without duplicate active workouts.
  - Search, filter, add, remove, and reorder exercises.
  - Support bodyweight, weighted, and time-based exercises with movement-appropriate defaults.
  - Interactive set logging with toggle completion, rest timer (with accurate pause/resume/background handling), and inline editable weight/reps.
  - Interruption recovery: persist workout state locally and in Supabase so app restarts seamlessly recover active workouts.
  - Workout completion summary with immediate XP reward modal and accurate volume/duration calculations.

### R3. Authoritative Progression, Quests & Streak Integrity
- Server-authoritative and atomic XP calculation via PostgreSQL transactions / RPCs (`calculate_workout_xp`), ensuring idempotency keyed by workout ID and duplicate reward prevention.
- Reliable class-level progression curve with accurate XP progress bars and level-up celebrations.
- Daily quest generation with accurate exercise category mapping (e.g. chest/push, legs/squat), functional "Start Quest" action that pre-configures a workout, quest progress tracking, and idempotent reward claiming.
- Timezone-aware streak tracking that properly calculates daily activity boundaries, handles missed days, and prevents double-crediting.

### R4. Curated Exercise Catalog Expansion (120–200 Exercises)
- Expand the exercise catalog from the current baseline to 120–200 high-quality, verified exercises.
- Provide comprehensive metadata: stable slug/ID, Vietnamese & English names, primary & secondary muscle groups, equipment (barbell, dumbbell, cable, machine, bodyweight, band), movement patterns (push, pull, squat, hinge, carry, lunge), difficulty, instructions, form cues, common mistakes, and alternative exercises.
- Use idempotent, non-destructive SQL seed scripts (`supabase/seed_exercises.sql`) with data-driven categorization.

### R5. Performance, State Management & Navigation Optimization
- Eliminate UI freezing, sequential N+1 Supabase queries, and timer-driven full-screen rebuilds.
- Batch workout exercise and set persistence into transactional operations.
- Fine-grained Riverpod provider selectors to prevent unnecessary widget rebuilds.
- Smooth GoRouter navigation with consistent slide/fade route transitions, tab state preservation, and zero layout overflow from 320px mobile to 1440px desktop.

### R6. Automated Verification, Testing & Multi-Agent Ownership
- Strictly adhere to agent file ownership and parallel execution strategy (Stage 0 Baseline -> Stage 1 Foundation -> Stage 2 Parallel Implementation -> Stage 3 Integration -> Stage 4 Polish).
- Automated test suites covering logic, state management, SQL transactions, and UI regressions.

## Acceptance Criteria

### Design System & Visual Integrity
- [ ] No remnants of legacy dark-neon/cyberpunk theme or hardcoded Orbitron fonts remain in user-facing screens.
- [ ] Visual tokens (Candy palette, 2px borders, hard drop shadows, Archivo Black / Space Grotesk / Space Mono) applied consistently across all screens.
- [ ] Tactile micro-interactions (button press downward-right translation, smooth XP progress bar, modal transitions) operate within target timings without frame drops.
- [ ] Zero layout overflows or clipping across all viewports (320px mobile, tablet, 1440px desktop) in both Vietnamese and English.

### Core Workout & Interruption Recovery
- [ ] User can initiate, customize (reorder, add, remove), and complete a workout session with bodyweight and weighted exercises.
- [ ] Active workout persists through app restarts or browser refreshes, allowing seamless resume without data loss.
- [ ] Rest timer accurately counts down, supports pause/resume, and triggers auditory/visual notification upon completion.
- [ ] Completed workouts persist atomically into `workouts`, `workout_exercises`, and `workout_sets` without N+1 sequential bottlenecks.

### Progression, Quests & Streaks
- [ ] XP awarded exclusively through server-authoritative transactional logic with idempotency check (submitting the same workout twice yields 0 duplicate XP).
- [ ] Daily quests generate correctly based on user timezone, match exercise categories accurately, and track progress to completion.
- [ ] "Start Quest" button launches a pre-populated workout session matching the quest criteria.
- [ ] Streak counter increments on consecutive active days and resets cleanly upon missed days according to user timezone.

### Exercise Catalog
- [ ] Exercise library contains between 120 and 200 exercises in `supabase/seed_exercises.sql`.
- [ ] Filter by muscle group, equipment, and movement pattern functions accurately using data-driven queries.
- [ ] Each exercise renders dual Vietnamese/English naming and detailed form cues.

### Automated Test Passing & Code Quality
- [ ] `flutter analyze` passes with 0 errors and 0 warnings in `app/`.
- [ ] `dart format --output=none --set-exit-if-changed lib test` passes cleanly in `app/`.
- [ ] All Flutter unit, widget, and regression tests pass (`flutter test`).
- [ ] Database migrations and PostgreSQL RPC suites pass cleanly.
- [ ] Supabase Edge Functions pass all Deno unit/contract tests (`deno test`).
- [ ] Production web release compiles cleanly (`flutter build web`).
- [ ] No TODO placeholders, fake metrics, or silent error suppressions (`return null`) in completed features.
