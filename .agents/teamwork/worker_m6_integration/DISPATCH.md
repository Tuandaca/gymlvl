# DISPATCH — Milestone M6: Performance, State & Navigation Integration

## Objective
Integrate navigation, app router, bottom navigation, active workout resume banner across tabs, and verify app-wide Candy Neubrutalism design compliance with zero remaining Orbitron references.

## Authoritative Requirements & Scope
- **Authoritative Spec**: `d:\Projects\gymlvl\.agents\teamwork\ORIGINAL_REQUEST.md` and `d:\Projects\gymlvl\PROJECT.md`.
- **Target Files & Directories**:
  - `app/lib/core/router/**` (specifically `app/lib/core/router/app_router.dart`)
  - `app/lib/main.dart` and `app/lib/app.dart`
  - Integration of bottom navigation bar using `CandyNavigationItem` / tactile styling
  - Integration of persistent active workout resume banner across tabs (when `activeWorkoutControllerProvider` has an active workout or local storage key `gymlvl_active_workout_backup` is present)
  - Eradication of any remaining `Orbitron` references across `app/lib/**`

## Mandatory Tasks
1. **App Router Audit & Wiring (`app/lib/core/router/app_router.dart`)**:
   - Verify and wire GoRouter configuration with all routes:
     - `/` or `/dashboard`: `DashboardScreen`
     - `/workout`: `WorkoutScreen`
     - `/workout/active`: `ActiveWorkoutScreen`
     - `/workout/summary`: `WorkoutSummaryScreen`
     - `/quests`: `QuestsScreen`
     - `/profile`: `ProfileScreen`
   - Implement or update `ScaffoldWithNavBar` / ShellRoute using tactile `CandyNavigationItem` primitives:
     - Dashboard (icon: `Icons.dashboard_rounded`, label: 'Tổng quan' / 'Dashboard')
     - Workout (icon: `Icons.fitness_center_rounded`, label: 'Tập luyện' / 'Workout')
     - Quests (icon: `Icons.military_tech_rounded`, label: 'Nhiệm vụ' / 'Quests')
     - Profile (icon: `Icons.person_rounded`, label: 'Hồ sơ' / 'Profile')
2. **Persistent Active Workout Banner**:
   - If a workout is currently active (`activeWorkoutState.isWorkoutActive`), render a high-visibility, sticky Neubrutalist banner directly above the bottom navigation bar across all tabs:
     - Shows current elapsed time (1s counter), exercise name, and a tactile "Tiếp tục" / "Resume" `CandyButton` that navigates immediately to `/workout/active`.
3. **App & Main Theme Integration**:
   - Inspect `app/lib/main.dart` and `app/lib/app.dart`.
   - Ensure the app uses `CandyTheme.theme` or `CandyTheme.darkTheme` / `CandyTheme.lightTheme` as configured in Milestone M1.
   - Verify splash screen and root error boundaries.
4. **App-wide Orbitron Eradication Verification**:
   - Run `git grep -i "Orbitron" app/lib` across the entire codebase.
   - If any references remain in any file, replace them with appropriate `CandyFonts` (`Archivo`, `SpaceGrotesk`, `SpaceMono`).
   - Confirm 0 occurrences of Orbitron in `app/lib`.
5. **Verification**:
   - Run Dart analysis on modified files (`lib/core/router`, `lib/main.dart`, etc.).
   - Verify `test/candy_ui_test.dart` passes.
   - Write comprehensive hard handoff to `d:\Projects\gymlvl\.agents\teamwork\worker_m6_integration\handoff.md`.

## Mandatory Integrity Warning
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.


## 2026-10-27T10:14:54Z
Received dispatch from 5048b8e8-9ce2-4b77-ba4d-cbd08c2af2fd:
Worker M6: Navigation & Integration Specialist.
Scope:
- app/lib/core/router/** (app_router.dart, navigation components, scaffold with nav bar)
- app/lib/main.dart, app/lib/app.dart
- Eradication of any remaining Orbitron references in app/lib/**
