-- M5 analytics: additive indexes for analytics queries (heatmap, weight trend, PR chart, muscle balance).
-- Additive only: CREATE INDEX IF NOT EXISTS. No tables/columns dropped, renamed or truncated.
-- No RLS or grant changes. Backward compatible.
--
-- Rollback path: DROP INDEX IF EXISTS for each index below. Dropping an index
-- does not touch user data and is safe to reverse.

-- Heatmap / weight trend: completed workouts by user within a completed_at window.
CREATE INDEX IF NOT EXISTS idx_analytics_workouts_user_completed
  ON public.workouts(user_id, completed_at)
  WHERE status = 'completed';

-- Weight trend / muscle balance: completed sets joined via workout_exercise.
CREATE INDEX IF NOT EXISTS idx_analytics_workout_sets_completed
  ON public.workout_sets(workout_exercise_id)
  WHERE is_completed;

-- Muscle balance: exercise lookup on workout_exercises.
CREATE INDEX IF NOT EXISTS idx_analytics_workout_exercises_exercise_id
  ON public.workout_exercises(exercise_id);

-- PR chart: user PRs ordered by update time.
CREATE INDEX IF NOT EXISTS idx_analytics_exercise_prs_user_updated
  ON public.exercise_prs(user_id, updated_at DESC);

COMMENT ON INDEX public.idx_analytics_workouts_user_completed IS
  'M5 analytics: heatmap and weight trend windowed lookups over completed workouts';
COMMENT ON INDEX public.idx_analytics_workout_sets_completed IS
  'M5 analytics: completed-set volume aggregation join target';
COMMENT ON INDEX public.idx_analytics_workout_exercises_exercise_id IS
  'M5 analytics: muscle balance exercise join';
COMMENT ON INDEX public.idx_analytics_exercise_prs_user_updated IS
  'M5 analytics: PR chart ordering by user and update time';
