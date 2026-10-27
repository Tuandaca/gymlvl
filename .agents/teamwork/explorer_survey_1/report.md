# Comprehensive Flutter Client Exploration Report

- **Target**: Flutter Client in `d:\Projects\gymlvl\app`
- **Explorer**: `explorer_survey_1` (Client Explorer)
- **Timestamp**: 2026-10-26T14:37:00Z
- **Reference**: `ORIGINAL_REQUEST.md` (R1 & R3), `DISPATCH.md`

---

## Executive Summary

The GymLevel Flutter client is a fully-implemented, highly-resilient, production-grade RPG-style fitness application built with Flutter 3.38.5 (Dart 3.10.4), Riverpod 3.1.0, and GoRouter 17.1.0. All automated checks verify a spotless codebase:
- **`flutter analyze`**: **0 issues found** (0 errors, 0 warnings).
- **`dart format --output=none --set-exit-if-changed lib test`**: **92 files verified**, 0 changes needed.
- **`flutter test`**: **83 out of 83 tests passing** (100% pass rate in 11.2 seconds), including comprehensive unit, controller, state isolation, and UI regression suites across multiple viewports (320px to 1440px) and languages (VI/EN).
- **Production web build**: `flutter build web` bundle compiled in `app/build/web`.

---

## 1. Architecture, State Management, Routing & Localization

### 1.1 Directory & Layer Architecture
The app follows a modern feature-first layered architecture:
```
app/lib/
├── core/
│   ├── config/              # SupabaseConfig (fail-safe client key validation)
│   ├── localization/        # LocalizationEngine (VI/EN/bilingual dictionary & notifier)
│   ├── router/              # AppRouter (GoRouter setup, authRedirect, MainShellScreen)
│   └── theme/               # AppTheme (Cyberpunk/Solo Leveling dark neon design tokens)
├── features/
│   ├── auth/                # Data, Domain, Presentation (providers, screens)
│   ├── coach/               # AI Coach integration, rate-limiting & fallback
│   ├── dashboard/           # Dashboard stats, fl_chart widgets, class badges
│   ├── onboarding/          # 9-step onboarding, drafts, class synergy definitions
│   ├── profile/             # Profile biometrics, training schedule, class switching
│   ├── progression/         # Display XP calculator & LevelUpOverlay
│   ├── quests/              # Daily quests, sync, quest cards
│   └── workout/             # Workouts, active workout controller, sets, exercises, timers
├── l10n/                    # Arb templates and Flutter localization delegates
├── ui/                      # Reusable design system widgets (SystemButton, SystemPanel, etc.)
└── main.dart                # Startup logic, fail-safe ConfigurationApp
```

### 1.2 State Management (Riverpod 3.x)
- Uses `flutter_riverpod: ^3.1.0` and `riverpod_annotation: ^4.0.0`.
- No deprecated `StateProvider` is used; all controllers use modern `NotifierProvider` and `AsyncNotifierProvider`.
- **Identity isolation & lifecycle safety**:
  - `ActiveWorkoutController` (`lib/features/workout/presentation/controllers/active_workout_controller.dart:57-79`): Tracks identity changes via `ref.watch(authStateStreamProvider.select(...))`, increments internal `_generation`, cancels active timers (`_workoutTimer`, `_restTimer`), and clears cached state on user signout.
  - `OnboardingDraftNotifier` (`lib/features/onboarding/presentation/providers/onboarding_controller.dart:16-23`): Invalidates and resets biometric drafts when auth identity changes, preventing draft leaks between different users.
  - `CoachController` (`lib/features/coach/data/coach_repository.dart:78-88`): Uses generation tracking to ignore responses arriving after identity switch.
- **Command Serialization**:
  - `ActiveWorkoutController._enqueue` (`lib/features/workout/presentation/controllers/active_workout_controller.dart:108-129`): All mutations (add exercise, add set, update reps/weight, delete set) are serialized through a chaining `_pending` Future to eliminate race conditions. Completion (`completeWorkout`) automatically awaits all in-flight set updates before calling the backend RPC.

### 1.3 Routing & Navigation (GoRouter 17.x)
- Configured in `lib/core/router/app_router.dart:36-148`.
- Uses `StatefulShellRoute.indexedStack` with 4 bottom tabs:
  1. `/dashboard` -> `DashboardScreen`
  2. `/workout` -> `WorkoutScreen`
  3. `/quests` -> `QuestsScreen`
  4. `/profile` -> `ProfileScreen`
- Fullscreen subroutes outside shell:
  - `/session` -> `SessionGateScreen`
  - `/reset-password` -> `ResetPasswordScreen`
  - `/coach` -> `CoachScreen`
  - `/login` -> `LoginScreen`
  - `/register` -> `RegisterScreen`
  - `/onboarding` -> `OnboardingScreen`
  - `/workout/active` -> `ActiveWorkoutScreen`
  - `/workout/history` -> `WorkoutHistoryScreen`
  - `/workout/detail/:id` -> `WorkoutDetailScreen`
  - `/exercise-picker` -> `ExercisePickerScreen`
- **Auth Redirects (`lib/core/router/auth_redirect.dart:1-25`)**:
  - Pure function covered by comprehensive unit tests (`test/auth_redirect_test.dart`).
  - Gated during session loading or profile errors: redirects to `/session` (`SessionGateScreen`), keeping deep links intact while avoiding false onboarding redirects.
  - Unauthenticated users: redirected to `/login` (while allowing `/register`).
  - Password recovery: prioritized above onboarding and main shell (`/reset-password`).
  - Un-onboarded authenticated users: forced to `/onboarding`.
  - Authenticated and onboarded users: accessing `/login`, `/register`, `/session`, or `/onboarding` redirected to `/dashboard`.

### 1.4 Dual Localization Engine (VI / EN / Bilingual)
- Configured in `lib/core/localization/localization_engine.dart` and `lib/l10n/`.
- Supports 3 modes: `AppLangMode.vi`, `AppLangMode.en`, `AppLangMode.bilingual`.
- Persisted to local device storage via `SharedPreferences` (`lang_mode`).
- `StringL10n` extension provides convenient `'key'.tr(ref)` and `'key'.trInline(ref)` syntax.
- Static Class Definitions support bilingual resolvers: `resolveClassName`, `resolveClassFocus`, `resolveClassDesc`.
- Language toggle is accessible directly on the Auth screens (SegmentedButton) and Profile screen (AppBar selector).

---

## 2. Comprehensive Screen Flows & Features

### 2.1 Authentication Flow
- **Files**: `lib/features/auth/presentation/screens/auth_form_screen.dart`, `login_screen.dart`, `register_screen.dart`, `reset_password_screen.dart`, `session_gate_screen.dart`.
- **Registration**:
  - Input validation: email regex, minimum 8 characters for password, password confirmation matching.
  - Form uses `AutofillGroup` with `AutofillHints.email` and `AutofillHints.newPassword`.
  - Handles Supabase email confirmation states: shows `check_email` hint when user creation does not immediately yield a session.
- **Login**:
  - Email/password validation, autofill support, inline error banner with localized friendly text (no raw server stack trace leakage).
  - "Forgot password?" triggers `resetPassword` email dispatch with safe notices.
- **Password Recovery**:
  - Detected via Supabase auth event `AuthChangeEvent.passwordRecovery`.
  - Routes to `/reset-password` (`ResetPasswordScreen`), requiring an 8+ character new password and confirmation. Clears recovery flag only upon successful update or explicit sign out.
- **Session Persistence & Gate**:
  - When the app starts, `SupabaseConfig.client` checks stored session.
  - If network is degraded or profile load fails, `SessionGateScreen` displays a retry button and logout option, preventing broken UI states.

### 2.2 9-Step Onboarding Flow
- **File**: `lib/features/onboarding/presentation/screens/onboarding_screen.dart:1-1350`.
- Implemented as a sequenced `PageView` with `NeverScrollableScrollPhysics` and step progress bar (`FractionallySizedBox` showing `Step X/9`):
  1. **Step 1 - Language**: VI vs EN choice.
  2. **Step 2 - Environment**: Gym, Home, or Mixed equipment.
  3. **Step 3 - Goals**: Multi-selection (max 3) from Fat Loss, Hypertrophy, Powerlifting, Endurance, Calisthenics, Bodybuilding.
  4. **Step 4 - Primary RPG Class**: Mandatory selection from 6 classes (A: Shredder, B: Hiper-Growth, C: Powerlifting, D: Endurance, E: Calisthenics, F: Bodybuilding) with focus, description, and difficulty badges.
  5. **Step 5 - Secondary RPG Class**: Optional selection. Highlights recommended synergistic classes (e.g. A+D Cardio Storm, B+C Juggernaut, E+C Cyber Monk, F+B Apex Sculptor).
  6. **Step 6 - Experience Level**: Beginner, Intermediate, Advanced.
  7. **Step 7 - Biometrics**: Age (13–100), Height (100–250 cm), Weight (25–400 kg), Gender.
  8. **Step 8 - Schedule**: Weekly gym days + home days (1–7 total) and preferred days of the week.
  9. **Step 9 - Class Confirmation**: Summary card and "Awaken" / "Bắt đầu hành trình" action button.
- **Submission**: Calls PostgreSQL RPC `initialize_user` with all validated fields, then invalidates `currentUserProvider` to transition `onboarding_completed: true` and trigger route transition to `/dashboard`.

### 2.3 Interactive Workout Sessions
- **Files**: `lib/features/workout/presentation/screens/active_workout_screen.dart`, `workout_screen.dart`, `lib/features/workout/presentation/controllers/active_workout_controller.dart`.
- **Workout Lifecycle**:
  - **Setup Phase**: User can add exercises from the Exercise Catalog (`ExercisePickerScreen`), choose from preset categories (`WorkoutTemplates`), or load a Daily Quest. During setup phase, the elapsed workout timer does not run.
  - **Training Phase**: Clicking "Begin Workout" records `training_started_at` in database and starts the live timer.
  - **Active Timer**: Accurately computes duration excluding setup time and paused seconds (`ActiveWorkoutController.elapsedFor`). Supports pause/resume with persistence (`setWorkoutPaused`).
  - **Set Logging**: Each exercise tile exposes individual set rows (`SetRowWidget`) with numeric input for reps and weight (kg), and a completion checkbox.
  - **Rest Timer**: `RestTimerQuickSelect` modal sheet (30s, 60s, 90s, 120s) with live countdown, progress bar, skip option, and medium-impact haptic feedback on completion.
  - **Workout Completion**:
    - Validates that at least one set is completed (`completedSets > 0`).
    - Serializes pending set edits before completion.
    - Memoizes completion future (`_completion`) to eliminate duplicate submission bugs.
    - Calls backend RPC `finish_workout` to obtain authoritative XP and rewards.
    - Displays `LevelUpOverlay.show(...)` modal dialogue with level-up animations, new title, and earned XP.
  - **Safe Exit & Interruption**: Leaving active workout presents options: Stay, Pause & Leave, or Cancel/Abort. Active session is persisted so user can return from `/workout` via the neon resume card.

### 2.4 Dashboard, Stats & Charts
- **Files**: `lib/features/dashboard/presentation/screens/dashboard_screen.dart`, `lib/features/dashboard/presentation/widgets/stats_charts.dart`.
- **Header Profile**: Displays user display name, title, level, current level XP progress bar, and cumulative progression metrics.
- **Quick Actions**: "Start Workout" and "AI Coach" buttons.
- **Active RPG Classes**: Displays Primary and Secondary class cards, Level, XP progress, and active synergy pill.
- **Today's Objective**: Embedded `DailyQuestCard` showing exercises and status, or honest rest day banner if none assigned.
- **Biometric Analysis**:
  - Current streak and longest streak counter.
  - Achievement badges.
  - `VolumeTrendChart`: Weekly volume (kg) line chart powered by `fl_chart`, annotated with accessible Semantics for screen readers.
  - `MuscleRadarChart`: Clean, readable horizontal bar distribution for 1 to 6 muscle groups, avoiding distorted radar plots when only 1 or 2 muscle groups are trained.
- **Pull-to-Refresh**: Native `RefreshIndicator` refreshes user, classes, quests, and stats concurrently.

### 2.5 Daily Quests
- **Files**: `lib/features/quests/presentation/screens/quests_screen.dart`, `daily_quest_card.dart`, `quest_providers.dart`.
- Calls RPC `sync_daily_data` to synchronize today's active quest.
- Displays prescribed exercises (target sets, reps, weight) and reward conditions.
- Clicking "Start Workout" on quest card calls `ActiveWorkoutController.startQuest(quest)`: initializes the session, prefills all prescribed exercises with suggested targets, and navigates straight to `/workout/active`.
- If no quest is scheduled for today, displays an honest Rest Day card ("Hôm nay chưa có nhiệm vụ. Bạn vẫn có thể bắt đầu buổi tập riêng.").

### 2.6 Profile & RPG Class Progression/Switching
- **Files**: `lib/features/profile/presentation/screens/profile_screen.dart`, `class_definitions.dart`, `progression_engine.dart`.
- Profile screen supports viewing and editing biometric details (Age, Height, Weight, Schedule) with client-side boundary validation.
- **Class Switching**:
  - Allows switching Primary or Secondary RPG class via a modal bottom sheet.
  - Enforces synergy constraints when picking secondary class (`class_locked_synergy`).
  - Calls PostgreSQL RPC `switch_class`, applying retrospective leveling from workout history.
- **Authoritative vs Display XP**:
  - Client-side `ProgressionEngine.calculateXP` is strictly used for real-time preview only (`previewXP`).
  - Server database owns all real awards, streak bonuses, and level-ups.

### 2.7 AI Coach Integration & Graceful Degradation
- **Files**: `lib/features/coach/presentation/coach_screen.dart`, `lib/features/coach/data/coach_repository.dart`.
- Proxies requests to Supabase Edge Function `ai-coach` with a 35-second client timeout.
- Limits input to 2,000 characters and bounds history context to the last 8 messages.
- **Graceful Fallback**:
  - If server endpoint is unconfigured (`coach_unconfigured` / HTTP 503): displays friendly bilingual explanation ("AI Coach is not configured yet. Workout tracking and progress remain available."), preserving question in input field.
  - If daily rate limit (20 requests/day) is reached: informs user without breaking any workout logging.
  - Chat interface is completely decoupled from workout logging, ensuring zero blocker for standard training.

---

## 3. Responsive Design Across Viewports (320px to 1440px)

The client implements responsive design and layout constraints across all screens:

| Breakpoint / Range | Strategy | Implemented Component |
|---|---|---|
| **< 960px (Mobile/Tablet)** | Bottom Navigation Bar | `MainShellScreen` -> `NavigationBar` |
| **>= 960px (Desktop)** | Side Navigation Rail | `MainShellScreen` -> `NavigationRail` with bolt logo |
| **Narrow Mobile (320px - 390px)** | Centered single-column, horizontal scroll prevention, wrapping headers, responsive padding | `ConstrainedBox`, `SingleChildScrollView`, `Wrap` |
| **Tablet / Desktop (768px - 1440px)** | Bounded content containers with auto-calculated horizontal margins | Max-width constraints (440px to 900px) |

### Specific Screen Constraints
- **Auth Forms**: `ConstrainedBox(maxWidth: 480)`
- **Onboarding**: `_buildStepContainer` wraps in `SingleChildScrollView` + `ConstrainedBox(maxWidth: 680)`
- **Dashboard**: `ListView` with responsive padding `maxWidth > 920 ? (maxWidth - 880) / 2 : 20.0`
- **Quests**: `ListView` with responsive padding `maxWidth > 760 ? (maxWidth - 720) / 2 : 20.0`
- **Profile**: `SingleChildScrollView` with responsive padding `maxWidth > 760 ? (maxWidth - 720) / 2 : 20.0`
- **Active Workout**: Top-centered `ConstrainedBox(maxWidth: 900)`
- **AI Coach**: Center `ConstrainedBox(maxWidth: 800)`
- **Rest Timer**: `RestTimerQuickSelect` fits 320px width without button truncations

### Automated Viewport Verification
- In `app/test/ui_regression_test.dart`, all 4 main screens (`dashboard`, `quests`, `profile`, `onboarding`) are tested across `[320.0, 390.0, 768.0, 1440.0]` in both `vi` and `en` locales (32 layout test permutations), confirming **0 RenderFlex overflows**.
- In `app/test/workout_widgets_test.dart`, editable workout tiles are verified at `[320.0, 768.0, 1280.0]` in both `en` and `vi`.

---

## 4. Test Suite Analysis & Quality Status

### 4.1 Test Execution Results
Running `flutter test` executed 83 automated test cases:
```
00:11 +83: All tests passed!
```

### 4.2 Breakdown of Test Files

| Test File | Tests | Focus Areas |
|---|---|---|
| `auth_controller_test.dart` | 6 | Double-click protection, failure retry, registration failure handling, password reset, session recovery state, sign-out cleanup |
| `auth_redirect_test.dart` | 5 | Deep link gating behind `/session`, profile error handling, unauthenticated redirects, restored session routing, password recovery priority |
| `client_config_test.dart` | 1 | Rejection of `service_role` and secret keys, validation of public/anon client keys |
| `coach_controller_test.dart` | 3 | Blank/duplicate submission handling, unconfigured coach degradation & message preservation, 8-message history context bounding |
| `progression_engine_test.dart` | 7 | Duration indifference for XP, 1.5x streak multiplier cap, 1000 XP cap, zero completed sets handling, suspicious pace detection, level thresholds |
| `session_isolation_test.dart` | 2 | Scoping onboarding drafts to identity (cleared on new login, preserved on token refresh), signout recovery state cleanup |
| `workout_controller_test.dart` | 9 | Concurrent start handling, setup vs training phase distinction, paused/setup time exclusion from elapsed timer, double-finish prevention, failure retry, set update serialization, reload required after failed edit, disposed identity rejection |
| `workout_widgets_test.dart` | 8 | Responsive workout tiles at 320px, 768px, 1280px in VI/EN, set deletion tooltip, rest timer quick select at 320px, calendar-day date calculation |
| `widget_test.dart` | 2 | Actionable setup instructions in `ConfigurationApp`, narrow screen responsiveness |
| `ui_regression_test.dart` | 40 | 32 viewport x language layout tests (Dashboard, Quests, Profile, Onboarding at 320/390/768/1440 in VI/EN), input validation, password mismatch, 9 onboarding steps reachability, quest retry, empty quest state, scrollable level-up overlay, badge rendering |
| `verify_logic.dart` | 0 | Compatibility entry point delegating to `progression_engine_test.dart` |
| **Total** | **83** | **100% Passing** |

### 4.3 Static Analysis & Formatting
- `flutter analyze`: **0 issues found** (0 errors, 0 warnings, 0 infos).
- `dart format --output=none --set-exit-if-changed lib test`: Formatted 92 files (0 changed).

---

## 5. Security & Authoritative Boundary Review

1. **Client Key Safety**:
   `SupabaseConfig.isPublicClientKey` (`lib/core/config/supabase_config.dart:16-27`) fails closed:
   - Rejects keys starting with `sb_secret_`.
   - Decodes JWT payloads to verify `role == 'anon'`.
   - Rejects `service_role` keys, preventing accidental exposure of admin privileges in client builds.
2. **Authoritative Progression (R2 compliance)**:
   - The Flutter client contains **zero** direct database update calls to XP, levels, streak, or quest completion status.
   - All awards originate from PostgreSQL RPC functions: `initialize_user`, `finish_workout`, `switch_class`, `sync_daily_data`.
   - `ProgressionEngine.calculateXP` in the app is labeled and used strictly as a display preview.
3. **No Sensitive Token Logging**:
   - Authentication tokens, passwords, and bearer tokens are never logged to console or stored in unencrypted local state.

---

## 6. Known Gaps & Limitations

Based on comprehensive inspection of the codebase and project status:
1. **Deferred Scope (as documented in `docs/IMPLEMENTATION_STATUS.md`)**:
   - **Admin Application**: Proposal only, deferred.
   - **Push Notifications**: No SDK/APNS/FCM configuration present.
   - **Offline Catalog Sync**: No local SQLite/Hive caching for offline exercise library browsing; app requires connectivity to sync with Supabase.
   - **Avatar Upload**: No Supabase Storage bucket policy or client image picker pipeline implemented yet.
   - **Weekly / Hidden Quests**: Only daily quests are currently wired to UI.
2. **Platform Build Prerequisites**:
   - **Web**: Fully functional (`flutter build web` compiles clean).
   - **Windows Desktop**: Compiles and runs locally.
   - **Android**: Android SDK is installed, but licenses require acceptance before `flutter build apk` can proceed.
   - **iOS**: Requires macOS and Xcode (cannot be built on Windows host).

---

## 7. Feature-to-File Reference Map

| Domain / Feature | Primary Code Files | Test Files |
|---|---|---|
| **App Entry & Config** | `lib/main.dart`<br>`lib/core/config/supabase_config.dart` | `test/widget_test.dart`<br>`test/client_config_test.dart` |
| **Theme & UI Tokens** | `lib/core/theme/app_theme.dart`<br>`lib/ui/widgets/` | `test/ui_regression_test.dart` |
| **Router & Auth Guard** | `lib/core/router/app_router.dart`<br>`lib/core/router/auth_redirect.dart`<br>`lib/core/router/main_shell_screen.dart` | `test/auth_redirect_test.dart` |
| **Localization** | `lib/core/localization/localization_engine.dart`<br>`lib/l10n/` | `test/ui_regression_test.dart`<br>`test/workout_widgets_test.dart` |
| **Auth & Session Gate** | `lib/features/auth/presentation/screens/`<br>`lib/features/auth/presentation/providers/auth_providers.dart`<br>`lib/features/auth/data/supabase_auth_repository.dart` | `test/auth_controller_test.dart`<br>`test/session_isolation_test.dart` |
| **9-Step Onboarding** | `lib/features/onboarding/presentation/screens/onboarding_screen.dart`<br>`lib/features/onboarding/presentation/providers/onboarding_controller.dart`<br>`lib/features/onboarding/domain/class_definitions.dart` | `test/session_isolation_test.dart`<br>`test/ui_regression_test.dart` |
| **Interactive Workout** | `lib/features/workout/presentation/screens/active_workout_screen.dart`<br>`lib/features/workout/presentation/screens/workout_screen.dart`<br>`lib/features/workout/presentation/controllers/active_workout_controller.dart`<br>`lib/features/workout/data/supabase_workout_repository.dart` | `test/workout_controller_test.dart`<br>`test/workout_widgets_test.dart` |
| **Dashboard & Charts** | `lib/features/dashboard/presentation/screens/dashboard_screen.dart`<br>`lib/features/dashboard/presentation/widgets/stats_charts.dart`<br>`lib/features/dashboard/presentation/providers/` | `test/ui_regression_test.dart` |
| **Daily Quests** | `lib/features/quests/presentation/screens/quests_screen.dart`<br>`lib/features/quests/presentation/widgets/daily_quest_card.dart`<br>`lib/features/quests/presentation/providers/quest_providers.dart` | `test/ui_regression_test.dart` |
| **Profile & Class Switch**| `lib/features/profile/presentation/screens/profile_screen.dart`<br>`lib/features/dashboard/presentation/providers/class_providers.dart` | `test/ui_regression_test.dart` |
| **Progression & Level Up**| `lib/features/progression/domain/progression_engine.dart`<br>`lib/features/progression/presentation/widgets/level_up_overlay.dart` | `test/progression_engine_test.dart` |
| **AI Coach Proxy** | `lib/features/coach/presentation/coach_screen.dart`<br>`lib/features/coach/data/coach_repository.dart` | `test/coach_controller_test.dart` |
