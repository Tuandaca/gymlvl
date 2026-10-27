// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_set.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkoutSet {
  String get id;
  @JsonKey(name: 'workout_exercise_id')
  String get workoutExerciseId;
  @JsonKey(name: 'set_number')
  int get setNumber;
  int get reps;
  @JsonKey(name: 'weight_kg')
  double get weightKg;
  @JsonKey(name: 'baseline_weight_kg')
  double get baselineWeightKg;
  @JsonKey(name: 'is_completed')
  bool get isCompleted;
  @JsonKey(name: 'rest_seconds')
  int get restSeconds;
  @JsonKey(name: 'duration_seconds')
  int get durationSeconds;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of WorkoutSet
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WorkoutSetCopyWith<WorkoutSet> get copyWith =>
      _$WorkoutSetCopyWithImpl<WorkoutSet>(this as WorkoutSet, _$identity);

  /// Serializes this WorkoutSet to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is WorkoutSet &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.workoutExerciseId, workoutExerciseId) ||
                other.workoutExerciseId == workoutExerciseId) &&
            (identical(other.setNumber, setNumber) ||
                other.setNumber == setNumber) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.baselineWeightKg, baselineWeightKg) ||
                other.baselineWeightKg == baselineWeightKg) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.restSeconds, restSeconds) ||
                other.restSeconds == restSeconds) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    workoutExerciseId,
    setNumber,
    reps,
    weightKg,
    baselineWeightKg,
    isCompleted,
    restSeconds,
    durationSeconds,
    createdAt,
  );

  @override
  String toString() {
    return 'WorkoutSet(id: $id, workoutExerciseId: $workoutExerciseId, setNumber: $setNumber, reps: $reps, weightKg: $weightKg, baselineWeightKg: $baselineWeightKg, isCompleted: $isCompleted, restSeconds: $restSeconds, durationSeconds: $durationSeconds, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $WorkoutSetCopyWith<$Res> {
  factory $WorkoutSetCopyWith(
    WorkoutSet value,
    $Res Function(WorkoutSet) _then,
  ) = _$WorkoutSetCopyWithImpl;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'workout_exercise_id') String workoutExerciseId,
    @JsonKey(name: 'set_number') int setNumber,
    int reps,
    @JsonKey(name: 'weight_kg') double weightKg,
    @JsonKey(name: 'baseline_weight_kg') double baselineWeightKg,
    @JsonKey(name: 'is_completed') bool isCompleted,
    @JsonKey(name: 'rest_seconds') int restSeconds,
    @JsonKey(name: 'duration_seconds') int durationSeconds,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$WorkoutSetCopyWithImpl<$Res> implements $WorkoutSetCopyWith<$Res> {
  _$WorkoutSetCopyWithImpl(this._self, this._then);

  final WorkoutSet _self;
  final $Res Function(WorkoutSet) _then;

  /// Create a copy of WorkoutSet
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? workoutExerciseId = null,
    Object? setNumber = null,
    Object? reps = null,
    Object? weightKg = null,
    Object? baselineWeightKg = null,
    Object? isCompleted = null,
    Object? restSeconds = null,
    Object? durationSeconds = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _self.copyWith(
        id: null == id ? _self.id : id as String,
        workoutExerciseId: null == workoutExerciseId
            ? _self.workoutExerciseId
            : workoutExerciseId as String,
        setNumber: null == setNumber ? _self.setNumber : setNumber as int,
        reps: null == reps ? _self.reps : reps as int,
        weightKg: null == weightKg ? _self.weightKg : weightKg as double,
        baselineWeightKg: null == baselineWeightKg
            ? _self.baselineWeightKg
            : baselineWeightKg as double,
        isCompleted: null == isCompleted
            ? _self.isCompleted
            : isCompleted as bool,
        restSeconds: null == restSeconds
            ? _self.restSeconds
            : restSeconds as int,
        durationSeconds: null == durationSeconds
            ? _self.durationSeconds
            : durationSeconds as int,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt as DateTime?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to [WorkoutSet].
extension WorkoutSetPatterns on WorkoutSet {
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      String id,
      @JsonKey(name: 'workout_exercise_id') String workoutExerciseId,
      @JsonKey(name: 'set_number') int setNumber,
      int reps,
      @JsonKey(name: 'weight_kg') double weightKg,
      @JsonKey(name: 'baseline_weight_kg') double baselineWeightKg,
      @JsonKey(name: 'is_completed') bool isCompleted,
      @JsonKey(name: 'rest_seconds') int restSeconds,
      @JsonKey(name: 'duration_seconds') int durationSeconds,
      @JsonKey(name: 'created_at') DateTime? createdAt,
    )?
    $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WorkoutSet() when $default != null:
        return $default(
          _that.id,
          _that.workoutExerciseId,
          _that.setNumber,
          _that.reps,
          _that.weightKg,
          _that.baselineWeightKg,
          _that.isCompleted,
          _that.restSeconds,
          _that.durationSeconds,
          _that.createdAt,
        );
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _WorkoutSet extends WorkoutSet {
  const _WorkoutSet({
    required this.id,
    @JsonKey(name: 'workout_exercise_id') required this.workoutExerciseId,
    @JsonKey(name: 'set_number') this.setNumber = 1,
    this.reps = 0,
    @JsonKey(name: 'weight_kg') this.weightKg = 0,
    @JsonKey(name: 'baseline_weight_kg') this.baselineWeightKg = 0,
    @JsonKey(name: 'is_completed') this.isCompleted = false,
    @JsonKey(name: 'rest_seconds') this.restSeconds = 0,
    @JsonKey(name: 'duration_seconds') this.durationSeconds = 0,
    @JsonKey(name: 'created_at') this.createdAt,
  }) : super._();

  factory _WorkoutSet.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSetFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'workout_exercise_id')
  final String workoutExerciseId;
  @override
  @JsonKey(name: 'set_number')
  final int setNumber;
  @override
  final int reps;
  @override
  @JsonKey(name: 'weight_kg')
  final double weightKg;
  @override
  @JsonKey(name: 'baseline_weight_kg')
  final double baselineWeightKg;
  @override
  @JsonKey(name: 'is_completed')
  final bool isCompleted;
  @override
  @JsonKey(name: 'rest_seconds')
  final int restSeconds;
  @override
  @JsonKey(name: 'duration_seconds')
  final int durationSeconds;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WorkoutSetCopyWith<_WorkoutSet> get copyWith =>
      __$WorkoutSetCopyWithImpl<_WorkoutSet>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$WorkoutSetToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _WorkoutSet &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.workoutExerciseId, workoutExerciseId) ||
                other.workoutExerciseId == workoutExerciseId) &&
            (identical(other.setNumber, setNumber) ||
                other.setNumber == setNumber) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.baselineWeightKg, baselineWeightKg) ||
                other.baselineWeightKg == baselineWeightKg) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.restSeconds, restSeconds) ||
                other.restSeconds == restSeconds) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    workoutExerciseId,
    setNumber,
    reps,
    weightKg,
    baselineWeightKg,
    isCompleted,
    restSeconds,
    durationSeconds,
    createdAt,
  );

  @override
  String toString() {
    return 'WorkoutSet(id: $id, workoutExerciseId: $workoutExerciseId, setNumber: $setNumber, reps: $reps, weightKg: $weightKg, baselineWeightKg: $baselineWeightKg, isCompleted: $isCompleted, restSeconds: $restSeconds, durationSeconds: $durationSeconds, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$WorkoutSetCopyWith<$Res>
    implements $WorkoutSetCopyWith<$Res> {
  factory _$WorkoutSetCopyWith(
    _WorkoutSet value,
    $Res Function(_WorkoutSet) _then,
  ) = __$WorkoutSetCopyWithImpl;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'workout_exercise_id') String workoutExerciseId,
    @JsonKey(name: 'set_number') int setNumber,
    int reps,
    @JsonKey(name: 'weight_kg') double weightKg,
    @JsonKey(name: 'baseline_weight_kg') double baselineWeightKg,
    @JsonKey(name: 'is_completed') bool isCompleted,
    @JsonKey(name: 'rest_seconds') int restSeconds,
    @JsonKey(name: 'duration_seconds') int durationSeconds,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$WorkoutSetCopyWithImpl<$Res> implements _$WorkoutSetCopyWith<$Res> {
  __$WorkoutSetCopyWithImpl(this._self, this._then);

  final _WorkoutSet _self;
  final $Res Function(_WorkoutSet) _then;

  /// Create a copy of WorkoutSet
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? workoutExerciseId = null,
    Object? setNumber = null,
    Object? reps = null,
    Object? weightKg = null,
    Object? baselineWeightKg = null,
    Object? isCompleted = null,
    Object? restSeconds = null,
    Object? durationSeconds = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _WorkoutSet(
        id: null == id ? _self.id : id as String,
        workoutExerciseId: null == workoutExerciseId
            ? _self.workoutExerciseId
            : workoutExerciseId as String,
        setNumber: null == setNumber ? _self.setNumber : setNumber as int,
        reps: null == reps ? _self.reps : reps as int,
        weightKg: null == weightKg ? _self.weightKg : weightKg as double,
        baselineWeightKg: null == baselineWeightKg
            ? _self.baselineWeightKg
            : baselineWeightKg as double,
        isCompleted: null == isCompleted
            ? _self.isCompleted
            : isCompleted as bool,
        restSeconds: null == restSeconds
            ? _self.restSeconds
            : restSeconds as int,
        durationSeconds: null == durationSeconds
            ? _self.durationSeconds
            : durationSeconds as int,
        createdAt: freezed == createdAt
            ? _self.createdAt
            : createdAt as DateTime?,
      ),
    );
  }
}

// dart format on
