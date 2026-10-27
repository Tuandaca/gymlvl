# Workout & Client Logic Architecture Audit

**Target Milestone**: Survey & Audit for Requirements R2 (Workout Tracker) & R5 (Performance & State Management)  
**Author**: Workout & Client Logic Explorer  
**Date**: 2026-10-27  
**Scope**: `app/lib/features/workout/**`, `app/lib/features/progression/**`, `app/lib/features/quests/**`, database schema, and Edge Functions.

---

## 1. Executive Summary

This investigation provides a comprehensive audit of GymLvl's workout tracking architecture, session management, set tracking, rest timers, data persistence, and progression integration.

### Core Findings Matrix

| Dimension | Current State | Requirement Standard (R2 / R5) | Gap Severity |
|---|---|---|---|
| **Workout Lifecycle** | Session start, pause/resume, add/remove exercises, complete via authoritative RPC. | End-to-end loop with exercise reordering, duplicate prevention, and clean recovery. | **Medium**: Exercise reordering exists only in repository; missing from controller and UI. |
| **Exercise Types** | Weighted exercises supported. Bodyweight is simulated by setting weight = 0 kg. | Native bodyweight (reps only), weighted (weight + reps), and time-based (duration/seconds). | **Critical**: Time-based exercises (e.g. Plank) are unsupported in schema (`workout_sets` lacks duration field) and database constraint requires `reps > 0`. |
| **Set Logging & Rest Timer** | Manual set toggle. In-memory rest timer (250ms ticks). Haptic on completion. | Interactive set toggle, rest timer with accurate pause/resume, background alert, audio/visual chimes. | **High**: Rest timer cannot pause; no audio alerts (no audio package installed in `pubspec.yaml`); no background alarms; no auto-start on set completion. |
| **Interruption Recovery & Persistence** | Server-only persistence in Supabase `public.workouts`. Zero local storage. | Interruption recovery across app restarts and browser refreshes with offline resilience. | **High**: Zero offline caching (`SharedPreferences` only stores language mode). App restart requires active network. Dashboard lacks active workout resume banner. |
| **Performance & State Bottlenecks** | Full-screen widget rebuilds every 1s (workout timer) and every 250ms (rest timer). Sequential N+1 network requests for presets and quests. Un-debounced set edits. | Fine-grained Riverpod selectors; transactional batch operations; debounced text fields. | **Critical**: Presets and quests fire 15–20 sequential HTTP requests; every typed character triggers a Supabase UPDATE; entire screens rebuild 4x/sec during rest. |
| **Workout Summary & Progression** | Authoritative `complete_workout` RPC computes XP, level, class XP, PRs, achievements. Returns rich JSON. | Workout summary modal/screen displaying immediate XP reward, volume, duration, class XP, and achievements. | **High**: `LevelUpOverlay` only displays earned XP and level number. Ignores volume, duration, streak updates, class progress, and achievements. No dedicated summary screen. |
| **Design System Tokens** | Legacy dark-neon HUD (`AppTheme.cyanNeon`, `AppTheme.purpleNeon`, `Orbitron` font, `SystemButton`). | Candy Neubrutalism (`CandyScaffold`, `CandyCard`, `CandyButton`, `CandyWorkoutSetRow`, `CandyExerciseCard`). | **High**: Must migrate all workout screens and widgets to Agent A's component library. |

---

## 2. Workout Lifecycle & Session Management

### 2.1 Complete Flow Walkthrough

```
[WorkoutScreen / QuestsScreen / DashboardScreen]
               │
               ▼
      startWorkout() (ActiveWorkoutController)
               │
               ▼
      RPC: start_workout() (PostgreSQL)
        - Checks existing active workout for user_id
        - If none, inserts new row into public.workouts (status='active')
        - Returns workout JSON
               │
               ▼
      ActiveWorkoutState (isSetupPhase: true)
               │
      ┌────────┴──────────────────────────┐
      ▼                                   ▼
Select Muscle Group Preset       Add Custom Exercise
(loadPresetExercises)             (ExercisePickerScreen)
      │                                   │
      └────────┬──────────────────────────┘
               ▼
      controller.beginTraining()
               │
               ▼
      RPC: begin_workout(p_workout_id)
        - Sets training_started_at = clock_timestamp()
               │
               ▼
      ActiveWorkoutState (isSetupPhase: false)
        - Starts _workoutTimer (1s interval)
        - Renders _training(state) ListView with WorkoutExerciseTiles
               │
      ┌────────┴──────────────────────────┐
      ▼                                   ▼
Log Sets / Start Rest            Pause / Resume Timer
(updateSet, startRest)           (set_workout_paused)
      │                                   │
      └────────┬──────────────────────────┘
               ▼
      controller.completeWorkout()
               │
               ▼
      RPC: complete_workout(p_workout_id, p_notes)
        - Locks users and workouts FOR UPDATE
        - Calculates duration, completed sets, volume, XP
        - Updates users, streaks, workouts, user_classes, exercise_prs, user_achievements
        - Stores immutable reward in public.workout_rewards
               │
               ▼
      LevelUpOverlay.show(...) -> Exit to /workout
```

### 2.2 Detailed Component Audit

#### A. Entry Points & Route Configuration
- **Routes in `app/lib/core/router/app_router.dart`**:
  - `/workout`: Inside `StatefulShellRoute` (tab 1). Hosts `WorkoutScreen`.
  - `/workout/active`: Outside shell (fullscreen). Hosts `ActiveWorkoutScreen`.
  - `/workout/history`: Outside shell. Hosts `WorkoutHistoryScreen`.
  - `/workout/detail/:id`: Outside shell. Hosts `WorkoutDetailScreen`.
  - `/exercise-picker`: Query parameter `multiSelect=true`. Hosts `ExercisePickerScreen`.
- **Observation on Dashboard Entry**:
  - `DashboardScreen` (`app/lib/features/dashboard/presentation/screens/dashboard_screen.dart:55-58`) has a "Start Workout" button navigating to `/workout`.
  - **Issue**: `DashboardScreen` does not watch `activeWorkoutControllerProvider` and has no active session banner. A user who closes the app during a workout and returns to the dashboard sees no indication that a workout is ongoing.

#### B. Setup Phase vs. Training Phase
- **Distinction mechanism**:
  - `workout.trainingStartedAt == null` indicates Setup Phase (`isSetupPhase = true`).
  - `workout.trainingStartedAt != null` indicates Training Phase (`isSetupPhase = false`).
- **Setup Phase (`_setup` in `active_workout_screen.dart:301-370`)**:
  - Preset categories: Chest, Back, Legs, Shoulders, Arms, Core.
  - Tapping a category chip invokes `controller.loadPresetExercises([group])`.
  - Custom exercise addition via `_addExercise()` -> `/exercise-picker?multiSelect=true`.
  - Selected exercises shown as simple `Card` with `ListTile`.
  - "Begin" CTA calls `controller.beginTraining()`.
- **Training Phase (`_training` in `active_workout_screen.dart:372-406`)**:
  - Renders `ListView.builder` of `WorkoutExerciseTile`.
  - Top bar displays elapsed time, pause/resume button, and "Finish" text button.
  - Floating Action Button to add more exercises mid-workout.

#### C. Exercise Customization (Add, Remove, Reorder)
- **Adding Exercises (`ActiveWorkoutController._addExercise`, lines 162-219)**:
  - Calls `_repository.addExerciseToWorkout(...)` (Supabase INSERT into `workout_exercises`).
  - Queries `_repository.getLastSetForExercise(exercise.id)` to pre-fill weight/reps.
  - Loops 3 times, calling `_repository.addSet(...)` for set 1, 2, 3.
  - Total queries per exercise added: **5 network requests**!
- **Removing Exercises (`ActiveWorkoutController.removeExercise`, lines 276-284)**:
  - Calls `_repository.removeExerciseFromWorkout(id)` (Supabase DELETE from `workout_exercises`, cascading to `workout_sets`).
  - Updates local state and triggers `_updatePreviewXP()`.
- **Reordering Exercises (`reorderExercises`)**:
  - In `WorkoutRepository` (`app/lib/features/workout/domain/workout_repository.dart:36-39`) and `SupabaseWorkoutRepository` (`supabase_workout_repository.dart:125-133`), a `reorderExercises(workoutId, ids)` method exists.
  - **Critical Defect**: Neither `ActiveWorkoutController` nor `ActiveWorkoutScreen` exposes reordering functionality! The UI uses standard `ListView.builder` with no drag handles or `ReorderableListView`. Users cannot reorder exercises during setup or training.

#### D. Completion & Idempotency
- **Client implementation (`ActiveWorkoutController._finish`, lines 396-438)**:
  - Awaits `_pending` mutation queue to ensure all set updates finish before completing.
  - Guards against `_mutationFailed` (requires reload if any set write failed).
  - Validates `state.completedSets > 0` and `!state.isSetupPhase`.
  - Calls `_repository.finishWorkout(state.workout!.id, notes: notes)`.
- **Server implementation (`complete_workout` in `supabase/migrations/20261026000200_authoritative_progression.sql:216-283`)**:
  - Idempotency check:
    ```sql
    SELECT r.result INTO result FROM public.workout_rewards r WHERE r.workout_id=w.id;
    IF result IS NOT NULL THEN RETURN result; END IF;
    ```
  - Replay safe: Submitting the same workout ID multiple times returns the cached reward without granting duplicate XP or incrementing streaks twice.

---

## 3. Exercise Types & Movement Patterns Support

### 3.1 Catalog Schema & Exercise Models

- **Database Table (`public.exercises` in `supabase/migrations/20261026000100_baseline.sql:127-138`)**:
  ```sql
  CREATE TABLE IF NOT EXISTS public.exercises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    category TEXT NOT NULL,         -- 'Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core'
    equipment TEXT NOT NULL,        -- 'Barbell', 'Dumbbell', 'Machine', 'Bodyweight', 'Cables'
    force_type TEXT,                -- 'Push', 'Pull', 'Static'
    mechanic TEXT,                  -- 'Compound', 'Isolation'
    instructions TEXT[] DEFAULT '{}',
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
  );
  ```
- **Domain Model (`Exercise` in `app/lib/features/workout/domain/exercise.dart:10-27`)**:
  - Mirrors database columns with Freezed.
  - **Missing metadata**: No `movement_pattern` (push, pull, squat, hinge, carry, lunge), no `secondary_muscles`, no `difficulty`, no `exercise_type` (`weighted`, `bodyweight`, `duration`).

### 3.2 Evaluation of the Three Exercise Types

#### 1. Weighted Exercises (Weight + Reps)
- **Status**: ✅ **Supported**.
- **Behavior**: User enters weight (kg) and reps. Defaults to previous set or 10 reps / 0 kg.
- **Set validation**: `weightKg` between 0 and 1000 kg, `reps` between 1 and 1000.

#### 2. Bodyweight Exercises (Reps Only)
- **Status**: ⚠️ **Partially / Hackily Supported**.
- **Current Behavior**:
  - Determined solely by string check: `exercise.equipment.toLowerCase().contains('body')`.
  - Weight is initialized to `0.0`.
  - **UI Defect**: `SetRowWidget` (`app/lib/features/workout/presentation/widgets/set_row_widget.dart:97-103`) still renders the `KG` input box displaying `0`. Users must look at a useless "0 kg" text field.
  - No option for "Weighted Bodyweight" (e.g. Pull-ups with added weight belt) where a base bodyweight is assumed and user enters added weight.

#### 3. Time-Based / Duration Exercises (Duration / Seconds)
- **Status**: ❌ **Completely Unsupported**.
- **Schema Defect**:
  - `public.workout_sets` (`20261026000100_baseline.sql:210-219`):
    ```sql
    CREATE TABLE IF NOT EXISTS public.workout_sets (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      workout_exercise_id UUID REFERENCES public.workout_exercises(id) ON DELETE CASCADE NOT NULL,
      set_number INTEGER NOT NULL DEFAULT 1,
      reps INTEGER NOT NULL DEFAULT 0,
      weight_kg DECIMAL NOT NULL DEFAULT 0,
      is_completed BOOLEAN NOT NULL DEFAULT false,
      rest_seconds INTEGER DEFAULT 0,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
    );
    ```
    *(Note: `rest_seconds` records inter-set rest intervals, not exercise duration).*
  - `workout_sets_valid_values` constraint (`20261026000200_authoritative_progression.sql:29-32`):
    `CHECK (... AND (NOT is_completed OR reps > 0))`
- **Behavior for Plank**:
  - In `supabase/seed.sql:33`, `Plank` is seeded (`equipment: 'Bodyweight'`, `force_type: 'Static'`).
  - When added to a workout, `_addExercise` assigns it `reps: 10`, `weight: 0`.
  - The UI asks the user for "10 reps" of Plank!
  - If the user attempts to enter 0 reps and 60 seconds duration, the database **throws a check constraint violation error** because `reps > 0` is enforced for all completed sets.
  - There is no duration field, duration input widget, or seconds countdown for static holds.

---

## 4. Set Logging & Rest Timer Mechanics

### 4.1 Set Logging Workflow
- **Widget (`SetRowWidget` in `app/lib/features/workout/presentation/widgets/set_row_widget.dart`)**:
  - Contains two `TextField` widgets (Weight, Reps) and an `IconButton` (completed toggle).
  - Tapping the completion icon calls `widget.onCompletedChanged?.call(!widget.isCompleted)`.
- **Controller handling (`ActiveWorkoutController.updateSet`, lines 299-335)**:
  - Validates `(isCompleted && reps <= 0)`. If invalid, sets `errorMessage: 'reps_required'`.
  - Calls `_repository.updateSet(setId, isCompleted: isCompleted)`.
  - Re-evaluates estimated XP via `_updatePreviewXP()`.
- **Auto-Rest Trigger**:
  - **Current Behavior**: Toggling a set as completed **DOES NOT** trigger the rest timer.
  - The user must scroll to the bottom of the exercise tile and manually tap the "Rest" button.

### 4.2 Rest Timer Implementation Audit
- **Timer Logic (`ActiveWorkoutController.startRest`, lines 354-377)**:
  ```dart
  void startRest(int seconds) {
    if (seconds <= 0 || seconds > 3600) return;
    _restTimer?.cancel();
    final deadline = DateTime.now().add(Duration(seconds: seconds));
    state = state.copyWith(
      isResting: true,
      restSecondsRemaining: seconds,
      restSecondsTotal: seconds,
    );
    _restTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      final remaining = math.max(
        0,
        (deadline.difference(DateTime.now()).inMilliseconds / 1000).ceil(),
      );
      if (remaining == 0) {
        timer.cancel();
        HapticFeedback.mediumImpact();
      }
      state = state.copyWith(
        isResting: remaining > 0,
        restSecondsRemaining: remaining,
      );
    });
  }
  ```
- **Technical Breakdown**:
  1. **Accuracy**: Uses `deadline.difference(DateTime.now())`, preventing tick accumulation drift.
  2. **Pause / Resume**: ❌ **Not Supported**. Calling `skipRest()` cancels the timer completely. There is no `pauseRest()` or `resumeRest()`.
  3. **Background & Lifecycle**:
     - The timer is a standard Dart `Timer.periodic`.
     - When the app is minimized on mobile or the screen locks, the OS may suspend Dart execution.
     - When reopened, the timer will recalculate against `deadline` and show the correct elapsed/completed state.
     - **Defect**: While backgrounded, **no alarm rings, no system notification is posted, and no sound plays**.
  4. **Auditory & Visual Alerts**:
     - Completion triggers `HapticFeedback.mediumImpact()` (device vibration).
     - **Auditory Alerts**: ❌ **Zero / Non-existent**. No sound, no beep, no audio chime.
     - `pubspec.yaml` contains **no audio library** (e.g. `audioplayers`, `soundpool`, `just_audio`).

---

## 5. Interruption Recovery & Persistence Audit

### 5.1 Storage Mechanism Audit

| Layer | Technology | Usage in Workout Feature |
|---|---|---|
| **Local Key-Value** | `shared_preferences: ^2.5.5` | Used **ONLY** for language mode (`app/lib/core/localization/localization_engine.dart:30`). **0% used for workouts**. |
| **Local Database** | Hive / SQLite / Drift | **Not installed / Not present** in `pubspec.yaml`. |
| **Remote Database** | Supabase PostgreSQL (`public.workouts`) | Active workout row stored with `status = 'active'`. Child rows in `workout_exercises` and `workout_sets`. |

### 5.2 Interruption Failure Modes

1. **App Restart / Process Death**:
   - On relaunch, Riverpod state initializes empty (`ActiveWorkoutState()`, `workout == null`).
   - If user opens `DashboardScreen` (default initial route), the app **does not check for an active workout**.
   - If user navigates to `WorkoutScreen`, `checkForActiveWorkout()` runs in `initState` post-frame callback:
     `SELECT *, workout_exercises(*, exercises(*), workout_sets(*)) FROM workouts WHERE user_id = ... AND status = 'active' LIMIT 1;`
   - If network is available: Session resumes.
   - If network is unavailable (offline gym): **Session is lost to the client until network returns**.
2. **In-Flight Network Failures During Workout**:
   - `_enqueue` catches errors:
     ```dart
     } catch (_) {
       if (ref.mounted && generation == _generation) {
         _mutationFailed = true;
         state = state.copyWith(errorMessage: 'save_failed');
       }
     }
     ```
   - If any set update fails due to spotty gym Wi-Fi, `_mutationFailed` is locked to `true`.
   - When user taps "Finish", `completeWorkout()` blocks completion:
     ```dart
     if (_mutationFailed) {
       state = state.copyWith(errorMessage: 'reload_required');
       return Future.value(null);
     }
     ```
   - User is forced to tap "Reload Saved", which queries Supabase and **discards all unsaved local set changes**!
   - There is no local write-ahead log (WAL) or offline mutation queue.

---

## 6. State & Performance Bottleneck Audit

### 6.1 Timer-Driven Full-Screen Rebuilds

In `ActiveWorkoutScreen` (`app/lib/features/workout/presentation/screens/active_workout_screen.dart:150`):
```dart
@override
Widget build(BuildContext context) {
  final state = ref.watch(activeWorkoutControllerProvider);
  ...
```
- **The Problem**:
  - `ref.watch(activeWorkoutControllerProvider)` observes the monolithic `ActiveWorkoutState`.
  - During training, `_workoutTimer` updates `elapsedSeconds` **every 1,000ms**.
  - During rest, `_restTimer` updates `restSecondsRemaining` **every 250ms**.
  - **Impact**: The entire `ActiveWorkoutScreen` widget tree (AppBar, setup wrap, exercise cards, set rows, text fields, action buttons) rebuilds **4 times every second** during rest countdowns, and every second during active training!
  - In `WorkoutScreen` (`workout_screen.dart:34`), `ref.watch(activeWorkoutControllerProvider)` also rebuilds the entire history screen every second if an active workout exists.
- **Root Cause**:
  - Absence of Riverpod fine-grained selectors (`select((s) => s.formattedElapsed)`).
  - Failure to isolate timer display into a dedicated leaf widget (`Consumer` listening only to timer sub-state).

### 6.2 Sequential N+1 Network Queries

#### Scenario 1: Loading Preset Exercises
In `ActiveWorkoutController.loadPresetExercises` (lines 256-274):
```dart
for (final name in names) {
  final matches = catalog.where((exercise) => exercise.name == name);
  if (matches.isEmpty) continue;
  await _addExercise(matches.first);
  if (!_isCurrent(generation)) return;
}
```
Inside `_addExercise` (lines 173-202):
1. `await _repository.addExerciseToWorkout(...)` -> 1 HTTP POST
2. `await _repository.getLastSetForExercise(...)` -> 1 HTTP GET
3. `await _repository.addSet(...)` -> 1 HTTP POST (Set 1)
4. `await _repository.addSet(...)` -> 1 HTTP POST (Set 2)
5. `await _repository.addSet(...)` -> 1 HTTP POST (Set 3)
- **Calculation**: 5 requests x 4 exercises = **20 sequential HTTP network requests**!
- On a 150ms mobile latency connection, loading a chest workout preset takes **3.0 to 4.5 seconds** of UI freezing/spinning!

#### Scenario 2: Starting a Daily Quest
In `ActiveWorkoutController.startQuest` (lines 232-254):
- For a 3-exercise quest: 3 exercises x 5 requests = **15 sequential HTTP requests** over the wire.

#### Scenario 3: Reordering Exercises
In `SupabaseWorkoutRepository.reorderExercises` (lines 125-133):
```dart
for (var i = 0; i < ids.length; i++) {
  await _supabase
      .from('workout_exercises')
      .update({'order_index': i})
      .eq('id', ids[i])
      .eq('workout_id', workoutId);
}
```
- Reordering 6 exercises executes **6 separate HTTP PATCH requests sequentially** without a transaction.

#### Scenario 4: Text Field Editing
In `SetRowWidget` (`set_row_widget.dart:200-213`):
```dart
onChanged: (value) {
  final parsed = int.tryParse(value);
  if (parsed != null && parsed <= 1000) {
    widget.onRepsChanged?.call(parsed);
  }
}
```
- `onChanged` triggers immediately on each keystroke without debounce.
- Typing "1", "2" fires two network update calls to Supabase sequentially.

---

## 7. Workout Summary, RPG Progression & Client Game Systems

### 7.1 Backend Completion Transaction (`complete_workout` RPC)

The database RPC `complete_workout` (`supabase/migrations/20261026000200_authoritative_progression.sql:216-283`) is a robust, production-grade PostgreSQL function:
1. **Concurrency Lock**: Serializes writes via `FOR UPDATE` on `users` and `workouts`.
2. **Anti-Cheat Validation**:
   - `duration = greatest(1, floor(extract(epoch FROM coalesce(w.paused_at, finished)-w.training_started_at))::integer-w.paused_seconds)`
   - `suspicious = completed_sets > 3 AND completed_sets * 60.0 / duration > 4` (suspicious pace caps XP at 10).
3. **Daily Quest Matching**:
   - Evaluates completed sets against `quest_instances.prescribed_config`.
   - If matched, awards quest base XP + streak multiplier.
4. **RPG Progression Updates**:
   - Calculates total XP, user level (`WHILE new_level < 100 AND total >= floor(100 * power(new_level, 1.5))`), and title.
   - Calculates Class XP for equipped user classes (`user_classes`), checking class focus categories and synergy bonuses (5% for perfect synergies like Cardio Storm, Juggernaut, Cyber Monk, Apex Sculptor).
   - Updates personal records (`exercise_prs`) with `max_weight_kg`, `max_reps`, and `estimated_1rm = max_weight * (1 + reps / 30.0)`.
   - Awards achievements (`first_workout`, `ten_workouts`, `streak_7`, `level_10`).
   - Persists immutable reward snapshot into `public.workout_rewards`.
5. **Returned Payload**:
   ```json
   {
     "message": "Workout complete",
     "earnedXP": 180,
     "totalXP": 620,
     "newLevel": 3,
     "leveledUp": true,
     "isQuest": false,
     "newTitle": "Tập Sự",
     "nextLevelXp": 519,
     "isSuspicious": false,
     "classResults": [
       {
         "classId": "B",
         "className": "Hiper-Growth",
         "slot": "primary",
         "xpEarned": 180,
         "newTotalXP": 540,
         "newLevel": 3,
         "leveledUp": false,
         "isGraduation": false
       }
     ],
     "achievements": ["first_workout"],
     "streak": 2
   }
   ```

### 7.2 Client Presentation Deficiencies

- **Current Presentation (`LevelUpOverlay` in `app/lib/features/progression/presentation/widgets/level_up_overlay.dart`)**:
  - Displays **only** a basic dialog with:
    - Trophy / Check icon
    - "Level Up" / "Workout Complete" title
    - New Level + New Title (if leveled up)
    - `+XX XP`
    - Total XP
    - "Continue" button
- **Gaps against Requirement R2 & R5**:
  1. **Volume & Duration**: Neither total volume (`kg`) nor actual duration (`minutes/seconds`) is displayed in the completion modal.
  2. **Class Progression**: Ignores `classResults`; user cannot see which classes gained XP or how close they are to graduating.
  3. **Streaks**: Ignores `streak`; does not celebrate streak increments or warn of streak loss.
  4. **Achievements**: Ignores `achievements`; unlocked achievements are silently recorded in DB without user celebration.
  5. **Post-Completion Flow**: Once dismissed, it pops immediately back to `/workout`. There is no dedicated post-workout summary card or review screen.

---

## 8. Actionable Implementation Roadmap for Agents B & C

### For Agent B (Workout Feature Lead — `app/lib/features/workout/**`)

1. **Implement Exercise Reordering**:
   - In `ActiveWorkoutController`: Add `Future<void> reorderExercises(List<String> workoutExerciseIds)`.
   - In `ActiveWorkoutScreen`: Wrap exercise list in `ReorderableListView.builder` with tactile drag handles.
2. **Support Bodyweight & Duration Exercise Types**:
   - In `WorkoutSet`: Add `durationSeconds` field.
   - In `SetRowWidget`: Inspect exercise type:
     - Weighted: Weight (kg) + Reps.
     - Bodyweight: Reps only (hide or dim weight input, or show "BW").
     - Time-based: Duration input (seconds/minutes picker) + optional weight (e.g. weighted plank).
3. **Rest Timer Overhaul**:
   - Add Pause and Resume methods to rest timer in `ActiveWorkoutController`.
   - Auto-trigger rest timer (configurable in settings) when a set is toggled to completed.
   - Add audio cue upon timer completion (integrate lightweight audio tone or system sound via platform channels / plugin).
4. **Performance & Riverpod Optimization**:
   - Isolate timer into a standalone `TimerNotifier` or use fine-grained selectors (`ref.watch(activeWorkoutControllerProvider.select((s) => s.formattedElapsed))`) so `ActiveWorkoutScreen` does not rebuild on every tick.
   - Debounce set input edits by 400ms to eliminate per-character HTTP requests.
5. **Workout Completion Summary Screen**:
   - Build a comprehensive `WorkoutSummaryDialog` / `WorkoutSummaryScreen` that displays:
     - Total Volume (calculated from `sets.fold(reps * weight)`)
     - Total Duration (formatted minutes and seconds)
     - XP earned + Level progress bar
     - Class progression breakdown tiles
     - Unlocked achievement badges
     - Streak counter update
6. **Migrate to Candy Neubrutalism**:
   - Replace legacy cyberpunk tokens (`AppTheme.cyanNeon`, `Orbitron` fonts, `SystemButton`) with `CandyScaffold`, `CandyCard`, `CandyButton`, `CandyExerciseCard`, `CandyWorkoutSetRow`.

### For Agent C (Backend & Game Systems Lead — `supabase/**`, `progression/**`, `quests/**`)

1. **Schema Migration for Time-Based Sets**:
   - Add column to `public.workout_sets`: `ALTER TABLE public.workout_sets ADD COLUMN IF NOT EXISTS duration_seconds INTEGER DEFAULT 0;`
   - Update constraint `workout_sets_valid_values`:
     `CHECK (... AND (NOT is_completed OR reps > 0 OR duration_seconds > 0))`
2. **Batch Exercise Insertion RPC**:
   - Create PostgreSQL RPC `add_workout_exercises_batch(p_workout_id UUID, p_exercises JSONB)` to insert all exercises and sets in a single atomic database transaction, replacing the 15–20 sequential HTTP round trips during preset/quest loading.
3. **Batch Reorder RPC**:
   - Create PostgreSQL RPC `reorder_workout_exercises(p_workout_id UUID, p_exercise_ids UUID[])` using `UPDATE ... FROM unnest(...)` to update `order_index` in one single query.
4. **Offline Resilience & Local Storage**:
   - Introduce local SQLite or persistent SharedPreferences cache for the active workout draft to guarantee interruption recovery even without an active internet connection.

---

*Report compiled by Workout & Client Logic Explorer for GymLvl multi-agent team.*
