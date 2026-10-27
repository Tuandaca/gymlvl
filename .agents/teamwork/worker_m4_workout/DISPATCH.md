# Dispatch Instructions — Worker M4 Workout Lifecycle & UX Resilience

## 2026-10-27T09:29:00Z
You are Agent B (Workout & Client Logic Specialist) for GymLvl.
Your working directory is: `d:\Projects\gymlvl\.agents\teamwork\worker_m4_workout`
Project root is: `d:\Projects\gymlvl`

### MANDATORY FIRST STEP:
Read the authoritative request file: `d:\Projects\gymlvl\.agents\teamwork\ORIGINAL_REQUEST.md` (under section `## 2026-10-27T08:45:05Z`).
Read `PROJECT.md` at project root: `d:\Projects\gymlvl\PROJECT.md`.
Read Explorer 2 survey handoff: `d:\Projects\gymlvl\.agents\teamwork\explorer_survey_workout_2\handoff.md`.
Read Explorer 2 survey report: `d:\Projects\gymlvl\.agents\teamwork\explorer_survey_workout_2\report.md`.
Read M3 migration: `supabase/migrations/20261027000100_exercise_catalog_metadata.sql` (to see the exact DB columns for exercises and duration_seconds in workout_sets).
Recommended domain skill: `d:\Projects\gymlvl\.agent\skills\mobile-design\SKILL.md`.

### MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A forensic auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

### EXCLUSIVE WRITE SCOPE:
- `app/lib/features/workout/**`
- `d:\Projects\gymlvl\.agents\teamwork\worker_m4_workout/**`
DO NOT write to any files outside `app/lib/features/workout/**` or your agent folder.

### Mission Requirements (Milestone M4 — Core Workout Lifecycle & UX Resilience):
1. **Domain Models Extension**:
   - Update `app/lib/features/workout/domain/exercise.dart`:
     - Add `slug`, `nameVi`, `nameEn`, `movementPattern`, `secondaryMuscles`, `difficulty`, `formCues`, `commonMistakes`, `alternativeExerciseSlugs`.
     - Update JSON serialization/deserialization.
   - Update `app/lib/features/workout/domain/workout_set.dart`:
     - Add `durationSeconds` (int, default 0).
     - Update JSON serialization (`duration_seconds`).
     - Validation helper: `bool get isValid => isCompleted ? (reps > 0 || durationSeconds > 0) : true;`.
   - Update `app/lib/features/workout/domain/workout_exercise.dart`:
     - Ensure set lists and exercise metadata serialize correctly with `durationSeconds`.
2. **Exercise Reordering**:
   - In `ActiveWorkoutController`: implement `void reorderExercises(int oldIndex, int newIndex)`.
   - In `ActiveWorkoutScreen`: wrap the exercise list in `ReorderableListView.builder` (or reorder drag handles on each exercise header) so athletes can reorder exercises seamlessly without losing set states.
3. **Time-Based & Static Hold Set Logging**:
   - For exercises where duration applies (e.g. Plank, static holds, cardio), allow logging `durationSeconds` (seconds input / countdown) instead of reps.
   - For bodyweight exercises with 0 weight, hide the confusing "0 kg" text or display "Bodyweight".
4. **Re-architect Rest Timer**:
   - 1-second countdown interval (replace 250ms timer loop).
   - Features: start, pause, resume, reset, +30s / -15s quick buttons.
   - Auto-start upon completing any set.
   - Audio/haptic notification on timer expiry (`HapticFeedback.heavyImpact()`).
   - Resilient background tracking: record `targetEndTime = DateTime.now().add(remainingDuration)` so that if the screen locks or app pauses, returning will calculate `remaining = targetEndTime.difference(now)` accurately without drift.
5. **Local Interruption Recovery (UX Resilience)**:
   - On every workout mutation (add exercise, remove exercise, log set, reorder), serialize active workout snapshot to `shared_preferences` under key `'gymlvl_active_workout_backup'`.
   - On app startup or entering `WorkoutScreen`, check if a backup exists. If found, show a prominent recovery banner: "Tiếp tục bài tập chưa hoàn thành? (Resume interrupted workout?)" with buttons to "Tiếp tục (Resume)" or "Hủy bỏ (Discard)".
   - When workout completes successfully or is discarded, remove `'gymlvl_active_workout_backup'` from `shared_preferences`.
6. **Post-Workout Summary Screen**:
   - Implement `WorkoutSummaryScreen` (or dialog): renders total volume (kg), workout duration, completed sets count, earned XP (+500 XP), level progress bar, and return CTA.
7. **Performance & State Optimization**:
   - Use Riverpod `.select()` on active workout controller to isolate timer ticks from exercise list rebuilds.
   - Ensure 0 RenderFlex overflows from 320px mobile to 1440px desktop.
8. **Verification**:
   - Verify code quality with analyzer:
     `cmd.exe /c "set LOCALAPPDATA=d:\Projects\gymlvl\.temp && set APPDATA=d:\Projects\gymlvl\.temp && C:\tools\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib/features/workout"`
   - Ensure 0 errors and 0 warnings.

### Deliverables:
- Write progress updates to: `d:\Projects\gymlvl\.agents\teamwork\worker_m4_workout\progress.md`
- Write completion handoff to: `d:\Projects\gymlvl\.agents\teamwork\worker_m4_workout\handoff.md`
- Notify orchestrator via `send_message` when complete.


## 2026-10-27T09:30:58Z
You are Agent B (Workout & Client Logic Specialist) for GymLvl.
Your working directory is: d:\Projects\gymlvl\.agents\teamwork\worker_m4_workout
Project root is: d:\Projects\gymlvl
Parent conversation ID: 5048b8e8-9ce2-4b77-ba4d-cbd08c2af2fd


## 2026-10-27T09:44:48Z
Sender: 5048b8e8-9ce2-4b77-ba4d-cbd08c2af2fd (Orchestrator)
Content:
Note that Dart analyzer or tools writing to default AppData will encounter OS Error: Access is denied (errno = 5). To run Dart commands cleanly in this sandbox, prefix with temp local appdata:
`cmd.exe /c "set LOCALAPPDATA=d:\Projects\gymlvl\.temp&& set APPDATA=d:\Projects\gymlvl\.temp&& C:\tools\flutter\bin\cache\dart-sdk\bin\dart.exe analyze <target>"`
Action: Use this command prefix for your analyzer and Dart checks. Continue implementing your workout lifecycle tasks.

## 2026-10-27T10:02:41Z
Sender: 5048b8e8-9ce2-4b77-ba4d-cbd08c2af2fd (Orchestrator)
Content:
Missing package errors during Dart analyze (`Target of URI doesn't exist`). Note that the 900+ analyzer errors in `task-385.log` are not code bugs — they are caused by the sandbox restricting reads to `C:\Users\tuand\AppData\Local\Pub\Cache`. We are setting up a local `.pub-cache` at `d:\Projects\gymlvl\.pub-cache` and updating `app/.dart_tool/package_config.json` to point to `file:///d:/Projects/gymlvl/.pub-cache`. Once this is in place, `dart analyze` will resolve all third-party packages properly.
Action: Focus on finishing your core workout lifecycle code (reordering, rest timer, local backup in shared_preferences, summary screen). Once package_config is updated, your analyzer checks will succeed.

## 2026-10-27T10:04:31Z
Sender: 5048b8e8-9ce2-4b77-ba4d-cbd08c2af2fd (Orchestrator)
Content:
The subagent sandbox environment enforces strict offline isolation where AppData\Local\Pub\Cache is restricted by security policy, as already documented in Worker M7's handoff caveat. Any analyzer errors referencing missing third-party pub-cache packages are an established environment sandbox limitation, not code defects.
Action: Proceed with completing your workout lifecycle features (reordering, rest timer resilience, offline recovery in shared_preferences, summary screen). Verify your code logic and deliver your handoff report.
