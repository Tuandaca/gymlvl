/// Client-side analytics aggregation over existing workout/progression data.
///
/// All results are estimates for display only. PostgreSQL remains the
/// authoritative source; this engine never writes XP, levels, streaks, PRs,
/// or completed workouts. `complete_workout` remains the sole reward path.
///
/// Identical input always yields identical output: no clock, locale, or
/// random dependence beyond the explicit timezone offset and window bounds.
library;

import 'package:app/features/workout/domain/exercise.dart';
import 'package:app/features/workout/domain/workout.dart';
import 'package:app/features/workout/domain/workout_exercise.dart';
import 'package:app/features/workout/domain/workout_set.dart';
import 'analytics_models.dart';

/// Default Asia/Ho_Chi_Minh offset (+7) used to bucket UTC instants into
/// local dates for streaks, quests and daily aggregates (ARCHITECTURE.md §4.7).
const int kDefaultTimezoneOffsetHours = 7;

/// Aggregates workout frequency, volume trend, PR chart and muscle balance.
class AnalyticsEngine {
  /// Hours added to a UTC instant to obtain the local date used for bucketing.
  final int timezoneOffsetHours;

  const AnalyticsEngine({this.timezoneOffsetHours = kDefaultTimezoneOffsetHours});

  /// Local (midnight) date for [instant] using [offset].
  DateTime _localDate(DateTime instant, int offset) {
    final local = instant.toUtc().add(Duration(hours: offset));
    return DateTime(local.year, local.month, local.day);
  }

  /// True when [instant] (UTC) lies in [start, end) when both are set.
  bool _inWindow(DateTime instant, {DateTime? start, DateTime? end}) {
    if (start != null && instant.isBefore(start)) return false;
    if (end != null && !instant.isBefore(end)) return false;
    return true;
  }

  /// Round [value] to 2 decimal places deterministically.
  static double _round2(double value) {
    if (!value.isFinite) return 0.0;
    return (value * 100).round() / 100;
  }

  /// Build a lookup of valid exercise IDs from [exercises].
  Set<String> _validExerciseIds(List<Exercise> exercises) {
    return exercises.map((e) => e.id).toSet();
  }

  /// Workout frequency by local day.
  ///
  /// Counts distinct completed workouts per local date. Workouts outside the
  /// optional [start]/[end) window (UTC instants) are excluded. Returns an
  /// empty list when no data exists.
  List<HeatmapPoint> heatmap({
    required List<Workout> workouts,
    DateTime? start,
    DateTime? end,
    int? timezoneOffsetHours,
  }) {
    final offset = timezoneOffsetHours ?? this.timezoneOffsetHours;
    final counts = <DateTime, int>{};
    for (final w in workouts) {
      if (w.status != WorkoutStatus.completed || w.completedAt == null) continue;
      if (!_inWindow(w.completedAt!, start: start, end: end)) continue;
      final day = _localDate(w.completedAt!, offset);
      counts[day] = (counts[day] ?? 0) + 1;
    }
    final result = counts.entries
        .map((e) => HeatmapPoint(date: e.key, workoutCount: e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  /// Volume over time: one point per local day with completed-set volume.
  ///
  /// Each completed set contributes ``reps * weight_kg`` (timed/cardio sets
  /// with reps == 0 and weight == 0 contribute 0 volume but still count as a
  /// set). Sets are attributed to the local date of their workout's
  /// ``completed_at``. Sets referencing an unknown or missing
  /// ``workout_exercise`` / exercise are skipped (exercise ID validation).
  /// Returns an empty list when no data exists.
  List<WeightTrendPoint> weightTrend({
    required List<WorkoutSet> sets,
    required List<WorkoutExercise> workoutExercises,
    required List<Workout> workouts,
    required List<Exercise> exercises,
    DateTime? start,
    DateTime? end,
    int? timezoneOffsetHours,
  }) {
    final offset = timezoneOffsetHours ?? this.timezoneOffsetHours;
    final validExerciseIds = _validExerciseIds(exercises);
    final weById = <String, WorkoutExercise>{};
    for (final we in workoutExercises) {
      weById[we.id] = we;
    }
    final wById = <String, Workout>{};
    for (final w in workouts) {
      wById[w.id] = w;
    }

    final byDay = <DateTime, _DayVolume>{};
    for (final s in sets) {
      if (!s.isCompleted) continue;
      final we = weById[s.workoutExerciseId];
      if (we == null) continue;
      if (!validExerciseIds.contains(we.exerciseId)) continue;
      final w = wById[we.workoutId];
      if (w == null || w.completedAt == null) continue;
      if (!_inWindow(w.completedAt!, start: start, end: end)) continue;
      final day = _localDate(w.completedAt!, offset);
      final entry = byDay.putIfAbsent(day, () => _DayVolume());
      entry.volumeKg += s.reps * s.weightKg;
      entry.totalReps += s.reps;
      entry.totalSets += 1;
    }

    final result = byDay.entries
        .map((e) => WeightTrendPoint(
              date: e.key,
              volumeKg: _round2(e.value.volumeKg),
              totalReps: e.value.totalReps,
              totalSets: e.value.totalSets,
            ))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  /// Personal-record chart from the authoritative `exercise_prs` table.
  ///
  /// Never recalculates PRs: values come straight from [prRecords] (server
  /// side). Only records whose [exerciseId] exists in [exercises] are kept
  /// (exercise ID validation). Results are sorted by [updatedAt] descending,
  /// then [exerciseId] ascending for deterministic output. Returns an empty
  /// list when no data exists.
  List<PRChartPoint> prChart({
    required List<PrRecord> prRecords,
    required List<Exercise> exercises,
  }) {
    final validExerciseIds = _validExerciseIds(exercises);
    final nameById = <String, String>{};
    for (final e in exercises) {
      nameById[e.id] = e.name;
    }

    final filtered = prRecords.where((r) => validExerciseIds.contains(r.exerciseId)).toList()
      ..sort((a, b) {
        final c = b.updatedAt.compareTo(a.updatedAt);
        if (c != 0) return c;
        return a.exerciseId.compareTo(b.exerciseId);
      });

    return filtered
        .map((r) => PRChartPoint(
              exerciseId: r.exerciseId,
              exerciseName: nameById[r.exerciseId] ?? r.exerciseId,
              maxWeightKg: _round2(r.maxWeightKg),
              maxReps: r.maxReps,
              estimated1rm: _round2(r.estimated1rm),
              updatedAt: r.updatedAt,
            ))
        .toList();
  }

  /// Volume by exercise category within the window.
  ///
  /// Each completed set contributes ``reps * weight_kg`` to its exercise's
  /// category. Sets with unknown/missing exercises are skipped. [percent] is
  /// the category's share of total window volume (0-100), rounded to 2 dp;
  /// when total volume is 0 every percent is 0. Sorted by volume descending,
  /// then category ascending. Returns an empty list when no data exists.
  List<MuscleBalancePoint> muscleBalance({
    required List<WorkoutSet> sets,
    required List<WorkoutExercise> workoutExercises,
    required List<Workout> workouts,
    required List<Exercise> exercises,
    DateTime? start,
    DateTime? end,
    int? timezoneOffsetHours,
  }) {
    final validExerciseIds = _validExerciseIds(exercises);
    final weById = <String, WorkoutExercise>{};
    for (final we in workoutExercises) {
      weById[we.id] = we;
    }
    final wById = <String, Workout>{};
    for (final w in workouts) {
      wById[w.id] = w;
    }
    final categoryByExerciseId = <String, String>{};
    for (final e in exercises) {
      categoryByExerciseId[e.id] = e.category;
    }

    final byCategory = <String, _DayVolume>{};
    double totalVolume = 0;
    for (final s in sets) {
      if (!s.isCompleted) continue;
      final we = weById[s.workoutExerciseId];
      if (we == null) continue;
      if (!validExerciseIds.contains(we.exerciseId)) continue;
      final w = wById[we.workoutId];
      if (w == null || w.completedAt == null) continue;
      if (!_inWindow(w.completedAt!, start: start, end: end)) continue;
      final category = categoryByExerciseId[we.exerciseId];
      if (category == null) continue;
      final volume = s.reps * s.weightKg;
      final entry = byCategory.putIfAbsent(category, () => _DayVolume());
      entry.volumeKg += volume;
      entry.totalReps += s.reps;
      entry.totalSets += 1;
      totalVolume += volume;
    }

    final result = byCategory.entries
        .map((e) => MuscleBalancePoint(
              category: e.key,
              volumeKg: _round2(e.value.volumeKg),
              totalReps: e.value.totalReps,
              totalSets: e.value.totalSets,
              percent: totalVolume == 0
                  ? 0.0
                  : _round2(e.value.volumeKg / totalVolume * 100),
            ))
        .toList()
      ..sort((a, b) {
        final c = b.volumeKg.compareTo(a.volumeKg);
        if (c != 0) return c;
        return a.category.compareTo(b.category);
    });
    return result;
  }

  /// Aggregates all four metrics over the same inputs and window.
  ///
  /// Convenience wrapper around [heatmap], [weightTrend], [prChart] and
  /// [muscleBalance]. Returns [AnalyticsResult] with empty lists when no data
  /// exists.
  AnalyticsResult aggregate({
    required List<Workout> workouts,
    required List<WorkoutSet> sets,
    required List<WorkoutExercise> workoutExercises,
    required List<Exercise> exercises,
    required List<PrRecord> prRecords,
    DateTime? start,
    DateTime? end,
    int? timezoneOffsetHours,
  }) {
    return AnalyticsResult(
      heatmap: heatmap(
        workouts: workouts,
        start: start,
        end: end,
        timezoneOffsetHours: timezoneOffsetHours,
      ),
      weightTrend: weightTrend(
        sets: sets,
        workoutExercises: workoutExercises,
        workouts: workouts,
        exercises: exercises,
        start: start,
        end: end,
        timezoneOffsetHours: timezoneOffsetHours,
      ),
      prChart: prChart(prRecords: prRecords, exercises: exercises),
      muscleBalance: muscleBalance(
        sets: sets,
        workoutExercises: workoutExercises,
        workouts: workouts,
        exercises: exercises,
        start: start,
        end: end,
        timezoneOffsetHours: timezoneOffsetHours,
      ),
    );
  }
}

/// Mutable accumulator for volume aggregation within a single day/category.
class _DayVolume {
  double volumeKg = 0;
  int totalReps = 0;
  int totalSets = 0;
}
