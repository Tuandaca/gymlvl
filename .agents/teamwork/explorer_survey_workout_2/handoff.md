# Handoff Report — Workout & Client Logic Architecture Survey

**Target**: Lead Orchestrator & Multi-Agent Engineering Team (Agents B, C, A, E)  
**Author**: Workout & Client Logic Explorer (`explorer_survey_workout_2`)  
**Timestamp**: 2026-10-27T09:05:00Z  
**Working Directory**: `d:\Projects\gymlvl\.agents\teamwork\explorer_survey_workout_2`  
**Reference Report**: `d:\Projects\gymlvl\.agents\teamwork\explorer_survey_workout_2\report.md`

---

## 1. Observation

Direct observations from codebase inspection:

1. **Reordering Exercises**:
   - `WorkoutRepository` (`app/lib/features/workout/domain/workout_repository.dart:36-39`) defines `Future<void> reorderExercises(String workoutId, List<String> workoutExerciseIds);`.
   - `SupabaseWorkoutRepository` (`app/lib/features/workout/data/supabase_workout_repository.dart:125-133`) implements it via a loop:
     ```dart
     for (var i = 0; i < ids.length; i++) {
       await _supabase
           .from('workout_exercises')
           .update({'order_index': i})
           .eq('id', ids[i])
           .eq('workout_id', workoutId);
     }
     ```
   - `ActiveWorkoutController` (`app/lib/features/workout/presentation/controllers/active_workout_controller.dart`) contains **no** method for reordering exercises.
   - `ActiveWorkoutScreen` (`app/lib/features/workout/presentation/screens/active_workout_screen.dart:372-406`) renders exercises via a standard non-reorderable `ListView.builder`.

2. **Exercise Types Support**:
   - `public.workout_sets` schema (`supabase/migrations/20261026000100_baseline.sql:210-219`):
     Columns are: `id`, `workout_exercise_id`, `set_number`, `reps`, `weight_kg`, `is_completed`, `rest_seconds`, `created_at`. There is no `duration_seconds` or `time` column.
   - Database constraint (`supabase/migrations/20261026000200_authoritative_progression.sql:29-32`):
     ```sql
     ALTER TABLE public.workout_sets ADD CONSTRAINT workout_sets_valid_values CHECK (
       set_number BETWEEN 1 AND 100 AND reps BETWEEN 0 AND 1000 AND weight_kg BETWEEN 0 AND 1000
       AND rest_seconds BETWEEN 0 AND 7200 AND baseline_weight_kg BETWEEN 0 AND 1000
       AND (NOT is_completed OR reps > 0)) NOT VALID;
     ```
   - In `supabase/seed.sql:33`, `Plank` is seeded (`equipment: 'Bodyweight'`, `force_type: 'Static'`).
   - In `ActiveWorkoutController._addExercise` (lines 183-199), bodyweight is checked via `exercise.equipment.toLowerCase().contains('body')`. Weight is set to 0.0, but reps defaults to 10.
   - In `SetRowWidget` (`app/lib/features/workout/presentation/widgets/set_row_widget.dart:97-103`), the `KG` input box is always rendered with `0` for bodyweight exercises; no duration input exists.

3. **Rest Timer**:
   - In `ActiveWorkoutController.startRest` (lines 354-377), timer is instantiated as:
     `_restTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) { ... });`
   - Completion triggers only `HapticFeedback.mediumImpact()`.
   - In `app/pubspec.yaml`, dependencies are: `flutter_riverpod`, `riverpod_annotation`, `go_router`, `freezed_annotation`, `json_annotation`, `intl`, `supabase_flutter`, `flutter_animate`, `fl_chart`, `shared_preferences`. There are **no audio packages**.
   - Toggling a set in `SetRowWidget` (`set_row_widget.dart:120-123`) calls `onCompletedChanged`, which calls `controller.updateSet(...)`. It does **not** call `startRest`.

4. **Persistence & Interruption Recovery**:
   - In `app/lib`, `SharedPreferences` is imported and used **only** in `app/lib/core/localization/localization_engine.dart:30,40` for language preference.
   - No local database (Hive, SQLite, Drift) exists in `app/pubspec.yaml`.
   - On app restart, `ActiveWorkoutController.build()` (lines 68-79) initializes empty state `const ActiveWorkoutState()`.
   - In `DashboardScreen` (`app/lib/features/dashboard/presentation/screens/dashboard_screen.dart`), there is no check or UI for an active workout.
   - If set update fails, `_mutationFailed` is set to `true` (line 118). `completeWorkout()` blocks completion with `errorMessage: 'reload_required'` (line 387), forcing server reload that discards local edits.

5. **State & Performance Bottlenecks**:
   - `ActiveWorkoutScreen` (`active_workout_screen.dart:150`) has `final state = ref.watch(activeWorkoutControllerProvider);` without selectors.
   - `_workoutTimer` updates `elapsedSeconds` every 1,000ms (line 465).
   - `_restTimer` updates `restSecondsRemaining` every 250ms (line 363).
   - `loadPresetExercises` (lines 256-274) iterates through names and calls `_addExercise`, which performs 5 HTTP requests per exercise (1 insert workout_exercise, 1 fetch previous set, 3 insert workout_set), resulting in 20 sequential HTTP round trips for a 4-exercise preset.
   - In `SetRowWidget` (`set_row_widget.dart:200-213`), `TextField.onChanged` fires on every keystroke without debouncing, invoking `controller.updateSet(...)` and sending an immediate Supabase PATCH request.

6. **Workout Summary & Progression**:
   - Database function `complete_workout` (`20261026000200_authoritative_progression.sql:216-283`) returns JSON with: `earnedXP`, `totalXP`, `newLevel`, `leveledUp`, `isQuest`, `newTitle`, `nextLevelXp`, `isSuspicious`, `classResults`, `achievements`, `streak`.
   - `LevelUpOverlay` (`app/lib/features/progression/presentation/widgets/level_up_overlay.dart:28-95`) only displays `earnedXP`, `totalXP`, `newLevel`, and `newTitle`.
   - Volume, duration, class XP breakdown, achievements, and streak updates are **not rendered**.
   - Upon dismissing `LevelUpOverlay`, the screen exits back to `/workout`. No summary view is shown.

---

## 2. Logic Chain

1. **Exercise Reordering Gap**:
   - From Observation 1: `reorderExercises` exists in the data layer but is absent in `ActiveWorkoutController` and `ActiveWorkoutScreen`.
   - Therefore: End-user exercise reordering is completely non-functional from the UI, failing Acceptance Criteria R2 ("customize (reorder, add, remove)").

2. **Duration / Static Hold Unsupported**:
   - From Observation 2: `public.workout_sets` lacks duration columns, and the DB constraint forbids `reps = 0` when `is_completed = true`.
   - Furthermore, `SetRowWidget` only provides inputs for reps and weight.
   - Therefore: Adding time-based exercises like Plank forces users to enter arbitrary reps, violating Requirement R2 ("support bodyweight, weighted, and time-based exercises with movement-appropriate defaults").

3. **Rest Timer Alert & Accuracy Deficiencies**:
   - From Observation 3: Rest timer ticks every 250ms causing UI thrashing; has no pause/resume; cannot alert users audibly because no audio dependency exists in `pubspec.yaml`; does not fire in the background.
   - Therefore: Acceptance Criteria R2 ("Rest timer accurately counts down, supports pause/resume, and triggers auditory/visual notification upon completion") is currently unsatisfied.

4. **Offline Vulnerability & Data Loss Risk**:
   - From Observation 4: Workouts are persisted only in Supabase. There is zero local caching.
   - If a user loses internet in a gym basement or process death occurs offline, the workout cannot be resumed on startup.
   - If a single set mutation fails, the user is locked from finishing until they reload from the server, wiping local uncommitted changes.
   - Therefore: Requirement R2 ("Interruption recovery: persist workout state locally and in Supabase") is only half-implemented (remote only, zero local).

5. **Client Performance Degraded by Unbatched Requests & Monolithic Watchers**:
   - From Observation 5: Full-screen rebuilds trigger up to 4 times per second during rest countdowns because `ActiveWorkoutScreen` watches the entire `ActiveWorkoutState`.
   - In addition, loading presets or quests executes 15–20 sequential HTTP requests, causing notable UI hangs on mobile networks.
   - Therefore: Optimization under Requirement R5 is mandatory (leaf timer widgets, Riverpod `.select()`, batched database RPCs, and debounced text inputs).

6. **Summary Presentation Incompleteness**:
   - From Observation 6: Although the backend calculates volume, duration, class XP, achievements, and streaks, `LevelUpOverlay` drops all metrics except global XP and level.
   - Therefore: Requirement R2 ("Workout completion summary with immediate XP reward modal and accurate volume/duration calculations") is incomplete on the client presentation layer.

---

## 3. Caveats

1. **Live Device Performance**: Tests were audited statically and via unit test harnesses; actual frame drop profiling on low-end Android hardware was not measured with Flutter DevTools in this session.
2. **Audio Platform Dependencies**: Adding audio alerts for the rest timer will require adding an audio package (e.g., `audioplayers` or `soundpool`) or utilizing platform channels for native system beeps to ensure web and mobile compatibility.
3. **Database Migration Strategy**: Modifying `public.workout_sets` to add `duration_seconds` and altering the check constraint must be coordinated with Agent C to avoid breaking historical test suites.

---

## 4. Conclusion

The workout tracking engine has a solid foundation with authoritative transactional completion (`complete_workout`), concurrency locking, and idempotency protection. However, it currently exhibits 5 major blockers for Requirements R2 and R5:
1. **Missing Time-Based & Bodyweight UX**: No duration field in DB, no duration input in UI, and DB constraint prohibits reps = 0.
2. **No UI Reordering**: Reorder method is missing from controller and UI.
3. **Rest Timer Deficiencies**: No audio alert, no pause/resume, no background notifications, 250ms tick thrashing.
4. **Performance Bottlenecks**: 15–20 sequential N+1 queries during preset/quest loading; un-debounced set edits; timer-driven full-screen rebuilds.
5. **Incomplete Completion Summary**: `LevelUpOverlay` omits volume, duration, class progression, and achievements.

---

## 5. Verification Method

To independently verify these findings:

1. **Verify Missing Reorder in Controller & UI**:
   - Inspect `app/lib/features/workout/presentation/controllers/active_workout_controller.dart`: Note absence of any `reorder` method.
   - Inspect `app/lib/features/workout/presentation/screens/active_workout_screen.dart:372-406`: Note use of `ListView.builder` rather than `ReorderableListView`.
2. **Verify Duration Constraint & Schema Absence**:
   - Inspect `supabase/migrations/20261026000100_baseline.sql:210-219`: Verify columns of `public.workout_sets`.
   - Inspect `supabase/migrations/20261026000200_authoritative_progression.sql:29-32`: Verify check constraint `(NOT is_completed OR reps > 0)`.
3. **Verify Rest Timer Implementation**:
   - Inspect `ActiveWorkoutController.startRest` (`active_workout_controller.dart:354-377`): Note 250ms tick rate, absence of pause/resume, and call to `HapticFeedback.mediumImpact()` with no audio playback.
   - Inspect `app/pubspec.yaml:30-53`: Verify absence of audio packages.
4. **Verify Sequential N+1 Queries**:
   - Inspect `ActiveWorkoutController.loadPresetExercises` (`active_workout_controller.dart:256-274`) and `_addExercise` (lines 173-202): Count 5 sequential `await` calls per exercise in a loop.
5. **Verify Monolithic Watcher Rebuilds**:
   - Inspect `ActiveWorkoutScreen.build` (`active_workout_screen.dart:150`): Note `ref.watch(activeWorkoutControllerProvider)` without `.select(...)`.

---

*Handoff prepared and verified by Workout & Client Logic Explorer.*
