import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:app/features/workout/domain/workout_mode_contract.dart';

part 'routine_models.freezed.dart';
part 'routine_models.g.dart';

/// Routine schedule mode
enum ScheduleMode {
  fixedWeek('fixed_week'),
  rotation('rotation');

  const ScheduleMode(this.wireValue);
  final String wireValue;
}

ScheduleMode? scheduleModeFromJson(String? value) {
  if (value == null) return null;
  for (final mode in ScheduleMode.values) {
    if (mode.wireValue == value) return mode;
  }
  throw FormatException('Unsupported schedule mode: $value');
}

String? scheduleModeToJson(ScheduleMode? value) => value?.wireValue;

/// Planned workout status
enum PlannedWorkoutStatus {
  planned('planned'),
  started('started'),
  completed('completed'),
  cancelled('cancelled');

  const PlannedWorkoutStatus(this.wireValue);
  final String wireValue;
}

PlannedWorkoutStatus? plannedWorkoutStatusFromJson(String? value) {
  if (value == null) return null;
  for (final status in PlannedWorkoutStatus.values) {
    if (status.wireValue == value) return status;
  }
  throw FormatException('Unsupported planned workout status: $value');
}

String? plannedWorkoutStatusToJson(PlannedWorkoutStatus? value) =>
    value?.wireValue;

@freezed
abstract class RoutineExercise with _$RoutineExercise {
  const factory RoutineExercise({
    required String id,
    required String routineId,
    required String exerciseId,
    required int orderIndex,
    required int sets,
    required int reps,
    int? repsMin,
    required double weightKg,
    int? durationSeconds,
    int? restSeconds,
    int? rpeTarget,
    int? rirTarget,
    int? warmupSets,
    required WorkoutMode mode,
    String? notes,
    String? supersetGroupId,
    int? supersetPosition,
    @Default(false) bool isWarmup,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _RoutineExercise;

  factory RoutineExercise.fromJson(Map<String, dynamic> json) =>
      _$RoutineExerciseFromJson(json);
}

@freezed
abstract class RoutineSupersetGroup with _$RoutineSupersetGroup {
  const factory RoutineSupersetGroup({
    required String id,
    required String routineId,
    required int position,
    DateTime? createdAt,
  }) = _RoutineSupersetGroup;

  factory RoutineSupersetGroup.fromJson(Map<String, dynamic> json) =>
      _$RoutineSupersetGroupFromJson(json);
}

@freezed
abstract class Routine with _$Routine {
  const factory Routine({
    required String id,
    required String userId,
    required String name,
    String? emoji,
    @Default(false) bool isArchived,
    @Default(1) int version,
    @Default([]) List<RoutineExercise> exercises,
    @Default([])
    List<String> supersetGroupIds, // IDs of superset groups in this routine
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Routine;

  factory Routine.fromJson(Map<String, dynamic> json) =>
      _$RoutineFromJson(json);
}

extension RoutineX on Routine {
  int get exerciseCount => exercises.length;

  bool get hasSupersetGroups => supersetGroupIds.isNotEmpty;

  RoutineExercise? getExercise(String id) {
    try {
      return exercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}

@freezed
abstract class RoutineSupersetGroupModel with _$RoutineSupersetGroupModel {
  const factory RoutineSupersetGroupModel({
    required String id,
    required String routineId,
    required int position,
    @Default([]) List<String> exerciseIds,
    DateTime? createdAt,
  }) = _RoutineSupersetGroupModel;

  factory RoutineSupersetGroupModel.fromJson(Map<String, dynamic> json) =>
      _$RoutineSupersetGroupModelFromJson(json);
}

@freezed
abstract class RoutineSchedule with _$RoutineSchedule {
  const factory RoutineSchedule.fixedWeek({
    required String id,
    required String routineId,
    required int weekday, // 1=Monday ... 7=Sunday
  }) = FixedWeekSchedule;

  const factory RoutineSchedule.rotation({
    required String id,
    required String routineId,
    required int position,
    String? supersetGroupId,
  }) = RotationSchedule;

  factory RoutineSchedule.fromJson(Map<String, dynamic> json) =>
      _$RoutineScheduleFromJson(json);
}

@freezed
abstract class PlannedWorkout with _$PlannedWorkout {
  const factory PlannedWorkout({
    required String id,
    required String userId,
    required String routineId,
    required String routineName,
    required Map<String, dynamic> routineSnapshot, // Immutable snapshot
    required DateTime scheduledDate, // Local date
    @Default(PlannedWorkoutStatus.planned) PlannedWorkoutStatus status,
    String? workoutId, // Linked workout when started
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PlannedWorkout;

  factory PlannedWorkout.fromJson(Map<String, dynamic> json) =>
      _$PlannedWorkoutFromJson(json);
}

@freezed
abstract class RoutineExerciseConfig with _$RoutineExerciseConfig {
  const factory RoutineExerciseConfig({
    required String exerciseId,
    required int orderIndex,
    required int sets,
    required int reps,
    int? repsMin,
    required double weightKg,
    int? durationSeconds,
    int? restSeconds,
    int? rpeTarget,
    int? rirTarget,
    int? warmupSets,
    required WorkoutMode mode,
    String? notes,
    String? supersetGroupId,
    int? supersetPosition,
    @Default(false) bool isWarmup,
    String? routineExerciseId, // For updates
  }) = _RoutineExerciseConfig;

  factory RoutineExerciseConfig.fromJson(Map<String, dynamic> json) =>
      _$RoutineExerciseConfigFromJson(json);
}

@freezed
abstract class RoutineScheduleModel with _$RoutineScheduleModel {
  const factory RoutineScheduleModel.fixedWeek({
    required String id,
    required String routineId,
    required int weekday, // 1=Monday ... 7=Sunday
  }) = FixedWeekScheduleModel;

  const factory RoutineScheduleModel.rotation({
    required String id,
    required String routineId,
    required int position,
    String? supersetGroupId,
  }) = RotationScheduleModel;

  factory RoutineScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$RoutineScheduleModelFromJson(json);
}

@freezed
abstract class PlannedWorkoutModel with _$PlannedWorkoutModel {
  const factory PlannedWorkoutModel({
    required String id,
    required String userId,
    required String routineId,
    required String routineName,
    required Map<String, dynamic> routineSnapshot,
    required DateTime scheduledDate,
    @Default(PlannedWorkoutStatus.planned) PlannedWorkoutStatus status,
    String? workoutId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PlannedWorkoutModel;

  factory PlannedWorkoutModel.fromJson(Map<String, dynamic> json) =>
      _$PlannedWorkoutModelFromJson(json);
}

@freezed
abstract class DuplicateRoutineConfig with _$DuplicateRoutineConfig {
  const factory DuplicateRoutineConfig({
    required String routineId,
    required String newName,
    @Default('🔁') String emoji,
  }) = _DuplicateRoutineConfig;

  factory DuplicateRoutineConfig.fromJson(Map<String, dynamic> json) =>
      _$DuplicateRoutineConfigFromJson(json);
}

@freezed
abstract class ReplaceExerciseConfig with _$ReplaceExerciseConfig {
  const factory ReplaceExerciseConfig({
    required String routineId,
    required String routineExerciseId,
    required String newExerciseId,
    Map<String, dynamic>? config, // Optional override config
  }) = _ReplaceExerciseConfig;

  factory ReplaceExerciseConfig.fromJson(Map<String, dynamic> json) =>
      _$ReplaceExerciseConfigFromJson(json);
}

@freezed
abstract class ScheduleRoutineConfig with _$ScheduleRoutineConfig {
  const factory ScheduleRoutineConfig.fixedWeek({
    required String routineId,
    required int weekday, // 1=Monday ... 7=Sunday
  }) = ScheduleFixedWeekConfig;

  const factory ScheduleRoutineConfig.rotation({
    required String routineId,
    required int position,
    String? supersetGroupId,
  }) = ScheduleRotationConfig;

  factory ScheduleRoutineConfig.fromJson(Map<String, dynamic> json) =>
      _$ScheduleRoutineConfigFromJson(json);
}

extension ScheduleRoutineConfigX on ScheduleRoutineConfig {
  bool get isFixedWeek => this is ScheduleFixedWeekConfig;
  bool get isRotation => this is ScheduleRotationConfig;
  int? get weekday => this is ScheduleFixedWeekConfig
      ? (this as ScheduleFixedWeekConfig).weekday
      : null;
  int? get position => this is ScheduleRotationConfig
      ? (this as ScheduleRotationConfig).position
      : null;
  String? get supersetGroupId => this is ScheduleRotationConfig
      ? (this as ScheduleRotationConfig).supersetGroupId
      : null;
}

@freezed
abstract class CreatePlannedWorkoutConfig with _$CreatePlannedWorkoutConfig {
  const factory CreatePlannedWorkoutConfig({
    required String routineId,
    required DateTime scheduledDate,
  }) = _CreatePlannedWorkoutConfig;

  factory CreatePlannedWorkoutConfig.fromJson(Map<String, dynamic> json) =>
      _$CreatePlannedWorkoutConfigFromJson(json);
}

@freezed
abstract class StartPlannedWorkoutConfig with _$StartPlannedWorkoutConfig {
  const factory StartPlannedWorkoutConfig({required String plannedWorkoutId}) =
      _StartPlannedWorkoutConfig;

  factory StartPlannedWorkoutConfig.fromJson(Map<String, dynamic> json) =>
      _$StartPlannedWorkoutConfigFromJson(json);
}

@freezed
abstract class CompletePlannedWorkoutConfig
    with _$CompletePlannedWorkoutConfig {
  const factory CompletePlannedWorkoutConfig({
    required String plannedWorkoutId,
    required String workoutId,
  }) = _CompletePlannedWorkoutConfig;

  factory CompletePlannedWorkoutConfig.fromJson(Map<String, dynamic> json) =>
      _$CompletePlannedWorkoutConfigFromJson(json);
}

@freezed
abstract class RepeatWorkoutConfig with _$RepeatWorkoutConfig {
  const factory RepeatWorkoutConfig({
    required String completedWorkoutId,
    DateTime? scheduledDate, // Optional: defaults to tomorrow
  }) = _RepeatWorkoutConfig;

  factory RepeatWorkoutConfig.fromJson(Map<String, dynamic> json) =>
      _$RepeatWorkoutConfigFromJson(json);
}

@freezed
abstract class RoutineExerciseConfigUpdate with _$RoutineExerciseConfigUpdate {
  const factory RoutineExerciseConfigUpdate({
    required String routineId,
    required String routineExerciseId,
    int? sets,
    int? reps,
    int? repsMin,
    double? weightKg,
    int? durationSeconds,
    int? restSeconds,
    int? rpeTarget,
    int? rirTarget,
    int? warmupSets,
    WorkoutMode? mode,
    String? notes,
    String? supersetGroupId,
    int? supersetPosition,
  }) = _RoutineExerciseConfigUpdate;

  factory RoutineExerciseConfigUpdate.fromJson(Map<String, dynamic> json) =>
      _$RoutineExerciseConfigUpdateFromJson(json);
}
