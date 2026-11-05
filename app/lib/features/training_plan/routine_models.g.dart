// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RoutineExercise _$RoutineExerciseFromJson(Map<String, dynamic> json) =>
    _RoutineExercise(
      id: json['id'] as String,
      routineId: json['routineId'] as String,
      exerciseId: json['exerciseId'] as String,
      orderIndex: (json['orderIndex'] as num).toInt(),
      sets: (json['sets'] as num).toInt(),
      reps: (json['reps'] as num).toInt(),
      repsMin: (json['repsMin'] as num?)?.toInt(),
      weightKg: (json['weightKg'] as num).toDouble(),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
      restSeconds: (json['restSeconds'] as num?)?.toInt(),
      rpeTarget: (json['rpeTarget'] as num?)?.toInt(),
      rirTarget: (json['rirTarget'] as num?)?.toInt(),
      warmupSets: (json['warmupSets'] as num?)?.toInt(),
      mode: $enumDecode(_$WorkoutModeEnumMap, json['mode']),
      notes: json['notes'] as String?,
      supersetGroupId: json['supersetGroupId'] as String?,
      supersetPosition: (json['supersetPosition'] as num?)?.toInt(),
      isWarmup: json['isWarmup'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$RoutineExerciseToJson(_RoutineExercise instance) =>
    <String, dynamic>{
      'id': instance.id,
      'routineId': instance.routineId,
      'exerciseId': instance.exerciseId,
      'orderIndex': instance.orderIndex,
      'sets': instance.sets,
      'reps': instance.reps,
      'repsMin': instance.repsMin,
      'weightKg': instance.weightKg,
      'durationSeconds': instance.durationSeconds,
      'restSeconds': instance.restSeconds,
      'rpeTarget': instance.rpeTarget,
      'rirTarget': instance.rirTarget,
      'warmupSets': instance.warmupSets,
      'mode': _$WorkoutModeEnumMap[instance.mode]!,
      'notes': instance.notes,
      'supersetGroupId': instance.supersetGroupId,
      'supersetPosition': instance.supersetPosition,
      'isWarmup': instance.isWarmup,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$WorkoutModeEnumMap = {
  WorkoutMode.repsWeight: 'repsWeight',
  WorkoutMode.bodyweight: 'bodyweight',
  WorkoutMode.timed: 'timed',
  WorkoutMode.cardio: 'cardio',
};

_RoutineSupersetGroup _$RoutineSupersetGroupFromJson(
  Map<String, dynamic> json,
) => _RoutineSupersetGroup(
  id: json['id'] as String,
  routineId: json['routineId'] as String,
  position: (json['position'] as num).toInt(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$RoutineSupersetGroupToJson(
  _RoutineSupersetGroup instance,
) => <String, dynamic>{
  'id': instance.id,
  'routineId': instance.routineId,
  'position': instance.position,
  'createdAt': instance.createdAt?.toIso8601String(),
};

_Routine _$RoutineFromJson(Map<String, dynamic> json) => _Routine(
  id: json['id'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  emoji: json['emoji'] as String?,
  isArchived: json['isArchived'] as bool? ?? false,
  version: (json['version'] as num?)?.toInt() ?? 1,
  exercises:
      (json['exercises'] as List<dynamic>?)
          ?.map((e) => RoutineExercise.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  supersetGroupIds:
      (json['supersetGroupIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$RoutineToJson(_Routine instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'name': instance.name,
  'emoji': instance.emoji,
  'isArchived': instance.isArchived,
  'version': instance.version,
  'exercises': instance.exercises,
  'supersetGroupIds': instance.supersetGroupIds,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

_RoutineSupersetGroupModel _$RoutineSupersetGroupModelFromJson(
  Map<String, dynamic> json,
) => _RoutineSupersetGroupModel(
  id: json['id'] as String,
  routineId: json['routineId'] as String,
  position: (json['position'] as num).toInt(),
  exerciseIds:
      (json['exerciseIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$RoutineSupersetGroupModelToJson(
  _RoutineSupersetGroupModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'routineId': instance.routineId,
  'position': instance.position,
  'exerciseIds': instance.exerciseIds,
  'createdAt': instance.createdAt?.toIso8601String(),
};

FixedWeekSchedule _$FixedWeekScheduleFromJson(Map<String, dynamic> json) =>
    FixedWeekSchedule(
      id: json['id'] as String,
      routineId: json['routineId'] as String,
      weekday: (json['weekday'] as num).toInt(),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$FixedWeekScheduleToJson(FixedWeekSchedule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'routineId': instance.routineId,
      'weekday': instance.weekday,
      'runtimeType': instance.$type,
    };

RotationSchedule _$RotationScheduleFromJson(Map<String, dynamic> json) =>
    RotationSchedule(
      id: json['id'] as String,
      routineId: json['routineId'] as String,
      position: (json['position'] as num).toInt(),
      supersetGroupId: json['supersetGroupId'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$RotationScheduleToJson(RotationSchedule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'routineId': instance.routineId,
      'position': instance.position,
      'supersetGroupId': instance.supersetGroupId,
      'runtimeType': instance.$type,
    };

_PlannedWorkout _$PlannedWorkoutFromJson(Map<String, dynamic> json) =>
    _PlannedWorkout(
      id: json['id'] as String,
      userId: json['userId'] as String,
      routineId: json['routineId'] as String,
      routineName: json['routineName'] as String,
      routineSnapshot: json['routineSnapshot'] as Map<String, dynamic>,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      status:
          $enumDecodeNullable(_$PlannedWorkoutStatusEnumMap, json['status']) ??
          PlannedWorkoutStatus.planned,
      workoutId: json['workoutId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PlannedWorkoutToJson(_PlannedWorkout instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'routineId': instance.routineId,
      'routineName': instance.routineName,
      'routineSnapshot': instance.routineSnapshot,
      'scheduledDate': instance.scheduledDate.toIso8601String(),
      'status': _$PlannedWorkoutStatusEnumMap[instance.status]!,
      'workoutId': instance.workoutId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$PlannedWorkoutStatusEnumMap = {
  PlannedWorkoutStatus.planned: 'planned',
  PlannedWorkoutStatus.started: 'started',
  PlannedWorkoutStatus.completed: 'completed',
  PlannedWorkoutStatus.cancelled: 'cancelled',
};

_RoutineExerciseConfig _$RoutineExerciseConfigFromJson(
  Map<String, dynamic> json,
) => _RoutineExerciseConfig(
  exerciseId: json['exerciseId'] as String,
  orderIndex: (json['orderIndex'] as num).toInt(),
  sets: (json['sets'] as num).toInt(),
  reps: (json['reps'] as num).toInt(),
  repsMin: (json['repsMin'] as num?)?.toInt(),
  weightKg: (json['weightKg'] as num).toDouble(),
  durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
  restSeconds: (json['restSeconds'] as num?)?.toInt(),
  rpeTarget: (json['rpeTarget'] as num?)?.toInt(),
  rirTarget: (json['rirTarget'] as num?)?.toInt(),
  warmupSets: (json['warmupSets'] as num?)?.toInt(),
  mode: $enumDecode(_$WorkoutModeEnumMap, json['mode']),
  notes: json['notes'] as String?,
  supersetGroupId: json['supersetGroupId'] as String?,
  supersetPosition: (json['supersetPosition'] as num?)?.toInt(),
  isWarmup: json['isWarmup'] as bool? ?? false,
  routineExerciseId: json['routineExerciseId'] as String?,
);

Map<String, dynamic> _$RoutineExerciseConfigToJson(
  _RoutineExerciseConfig instance,
) => <String, dynamic>{
  'exerciseId': instance.exerciseId,
  'orderIndex': instance.orderIndex,
  'sets': instance.sets,
  'reps': instance.reps,
  'repsMin': instance.repsMin,
  'weightKg': instance.weightKg,
  'durationSeconds': instance.durationSeconds,
  'restSeconds': instance.restSeconds,
  'rpeTarget': instance.rpeTarget,
  'rirTarget': instance.rirTarget,
  'warmupSets': instance.warmupSets,
  'mode': _$WorkoutModeEnumMap[instance.mode]!,
  'notes': instance.notes,
  'supersetGroupId': instance.supersetGroupId,
  'supersetPosition': instance.supersetPosition,
  'isWarmup': instance.isWarmup,
  'routineExerciseId': instance.routineExerciseId,
};

FixedWeekScheduleModel _$FixedWeekScheduleModelFromJson(
  Map<String, dynamic> json,
) => FixedWeekScheduleModel(
  id: json['id'] as String,
  routineId: json['routineId'] as String,
  weekday: (json['weekday'] as num).toInt(),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$FixedWeekScheduleModelToJson(
  FixedWeekScheduleModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'routineId': instance.routineId,
  'weekday': instance.weekday,
  'runtimeType': instance.$type,
};

RotationScheduleModel _$RotationScheduleModelFromJson(
  Map<String, dynamic> json,
) => RotationScheduleModel(
  id: json['id'] as String,
  routineId: json['routineId'] as String,
  position: (json['position'] as num).toInt(),
  supersetGroupId: json['supersetGroupId'] as String?,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$RotationScheduleModelToJson(
  RotationScheduleModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'routineId': instance.routineId,
  'position': instance.position,
  'supersetGroupId': instance.supersetGroupId,
  'runtimeType': instance.$type,
};

_PlannedWorkoutModel _$PlannedWorkoutModelFromJson(Map<String, dynamic> json) =>
    _PlannedWorkoutModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      routineId: json['routineId'] as String,
      routineName: json['routineName'] as String,
      routineSnapshot: json['routineSnapshot'] as Map<String, dynamic>,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      status:
          $enumDecodeNullable(_$PlannedWorkoutStatusEnumMap, json['status']) ??
          PlannedWorkoutStatus.planned,
      workoutId: json['workoutId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PlannedWorkoutModelToJson(
  _PlannedWorkoutModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'routineId': instance.routineId,
  'routineName': instance.routineName,
  'routineSnapshot': instance.routineSnapshot,
  'scheduledDate': instance.scheduledDate.toIso8601String(),
  'status': _$PlannedWorkoutStatusEnumMap[instance.status]!,
  'workoutId': instance.workoutId,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

_DuplicateRoutineConfig _$DuplicateRoutineConfigFromJson(
  Map<String, dynamic> json,
) => _DuplicateRoutineConfig(
  routineId: json['routineId'] as String,
  newName: json['newName'] as String,
  emoji: json['emoji'] as String? ?? '🔁',
);

Map<String, dynamic> _$DuplicateRoutineConfigToJson(
  _DuplicateRoutineConfig instance,
) => <String, dynamic>{
  'routineId': instance.routineId,
  'newName': instance.newName,
  'emoji': instance.emoji,
};

_ReplaceExerciseConfig _$ReplaceExerciseConfigFromJson(
  Map<String, dynamic> json,
) => _ReplaceExerciseConfig(
  routineId: json['routineId'] as String,
  routineExerciseId: json['routineExerciseId'] as String,
  newExerciseId: json['newExerciseId'] as String,
  config: json['config'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ReplaceExerciseConfigToJson(
  _ReplaceExerciseConfig instance,
) => <String, dynamic>{
  'routineId': instance.routineId,
  'routineExerciseId': instance.routineExerciseId,
  'newExerciseId': instance.newExerciseId,
  'config': instance.config,
};

ScheduleFixedWeekConfig _$ScheduleFixedWeekConfigFromJson(
  Map<String, dynamic> json,
) => ScheduleFixedWeekConfig(
  routineId: json['routineId'] as String,
  weekday: (json['weekday'] as num).toInt(),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$ScheduleFixedWeekConfigToJson(
  ScheduleFixedWeekConfig instance,
) => <String, dynamic>{
  'routineId': instance.routineId,
  'weekday': instance.weekday,
  'runtimeType': instance.$type,
};

ScheduleRotationConfig _$ScheduleRotationConfigFromJson(
  Map<String, dynamic> json,
) => ScheduleRotationConfig(
  routineId: json['routineId'] as String,
  position: (json['position'] as num).toInt(),
  supersetGroupId: json['supersetGroupId'] as String?,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$ScheduleRotationConfigToJson(
  ScheduleRotationConfig instance,
) => <String, dynamic>{
  'routineId': instance.routineId,
  'position': instance.position,
  'supersetGroupId': instance.supersetGroupId,
  'runtimeType': instance.$type,
};

_CreatePlannedWorkoutConfig _$CreatePlannedWorkoutConfigFromJson(
  Map<String, dynamic> json,
) => _CreatePlannedWorkoutConfig(
  routineId: json['routineId'] as String,
  scheduledDate: DateTime.parse(json['scheduledDate'] as String),
);

Map<String, dynamic> _$CreatePlannedWorkoutConfigToJson(
  _CreatePlannedWorkoutConfig instance,
) => <String, dynamic>{
  'routineId': instance.routineId,
  'scheduledDate': instance.scheduledDate.toIso8601String(),
};

_StartPlannedWorkoutConfig _$StartPlannedWorkoutConfigFromJson(
  Map<String, dynamic> json,
) => _StartPlannedWorkoutConfig(
  plannedWorkoutId: json['plannedWorkoutId'] as String,
);

Map<String, dynamic> _$StartPlannedWorkoutConfigToJson(
  _StartPlannedWorkoutConfig instance,
) => <String, dynamic>{'plannedWorkoutId': instance.plannedWorkoutId};

_CompletePlannedWorkoutConfig _$CompletePlannedWorkoutConfigFromJson(
  Map<String, dynamic> json,
) => _CompletePlannedWorkoutConfig(
  plannedWorkoutId: json['plannedWorkoutId'] as String,
  workoutId: json['workoutId'] as String,
);

Map<String, dynamic> _$CompletePlannedWorkoutConfigToJson(
  _CompletePlannedWorkoutConfig instance,
) => <String, dynamic>{
  'plannedWorkoutId': instance.plannedWorkoutId,
  'workoutId': instance.workoutId,
};

_RepeatWorkoutConfig _$RepeatWorkoutConfigFromJson(Map<String, dynamic> json) =>
    _RepeatWorkoutConfig(
      completedWorkoutId: json['completedWorkoutId'] as String,
      scheduledDate: json['scheduledDate'] == null
          ? null
          : DateTime.parse(json['scheduledDate'] as String),
    );

Map<String, dynamic> _$RepeatWorkoutConfigToJson(
  _RepeatWorkoutConfig instance,
) => <String, dynamic>{
  'completedWorkoutId': instance.completedWorkoutId,
  'scheduledDate': instance.scheduledDate?.toIso8601String(),
};

_RoutineExerciseConfigUpdate _$RoutineExerciseConfigUpdateFromJson(
  Map<String, dynamic> json,
) => _RoutineExerciseConfigUpdate(
  routineId: json['routineId'] as String,
  routineExerciseId: json['routineExerciseId'] as String,
  sets: (json['sets'] as num?)?.toInt(),
  reps: (json['reps'] as num?)?.toInt(),
  repsMin: (json['repsMin'] as num?)?.toInt(),
  weightKg: (json['weightKg'] as num?)?.toDouble(),
  durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
  restSeconds: (json['restSeconds'] as num?)?.toInt(),
  rpeTarget: (json['rpeTarget'] as num?)?.toInt(),
  rirTarget: (json['rirTarget'] as num?)?.toInt(),
  warmupSets: (json['warmupSets'] as num?)?.toInt(),
  mode: $enumDecodeNullable(_$WorkoutModeEnumMap, json['mode']),
  notes: json['notes'] as String?,
  supersetGroupId: json['supersetGroupId'] as String?,
  supersetPosition: (json['supersetPosition'] as num?)?.toInt(),
);

Map<String, dynamic> _$RoutineExerciseConfigUpdateToJson(
  _RoutineExerciseConfigUpdate instance,
) => <String, dynamic>{
  'routineId': instance.routineId,
  'routineExerciseId': instance.routineExerciseId,
  'sets': instance.sets,
  'reps': instance.reps,
  'repsMin': instance.repsMin,
  'weightKg': instance.weightKg,
  'durationSeconds': instance.durationSeconds,
  'restSeconds': instance.restSeconds,
  'rpeTarget': instance.rpeTarget,
  'rirTarget': instance.rirTarget,
  'warmupSets': instance.warmupSets,
  'mode': _$WorkoutModeEnumMap[instance.mode],
  'notes': instance.notes,
  'supersetGroupId': instance.supersetGroupId,
  'supersetPosition': instance.supersetPosition,
};
