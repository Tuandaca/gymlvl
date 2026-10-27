// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'active_workout_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ActiveWorkoutState {
  Workout? get workout;
  List<WorkoutExercise> get exercises;
  int get elapsedSeconds;
  bool get isSetupPhase;
  bool get isResting;
  int get restSecondsRemaining;
  int get restSecondsTotal;
  bool get isRestPaused;
  DateTime? get restTargetEndTime;
  bool get isLoading;
  bool get isCompleting;
  bool get isTimerPaused;
  int get previewXP;
  String? get errorMessage;

  /// Create a copy of ActiveWorkoutState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ActiveWorkoutStateCopyWith<ActiveWorkoutState> get copyWith =>
      _$ActiveWorkoutStateCopyWithImpl<ActiveWorkoutState>(
        this as ActiveWorkoutState,
        _$identity,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ActiveWorkoutState &&
            (identical(other.workout, workout) || other.workout == workout) &&
            const DeepCollectionEquality().equals(other.exercises, exercises) &&
            (identical(other.elapsedSeconds, elapsedSeconds) ||
                other.elapsedSeconds == elapsedSeconds) &&
            (identical(other.isSetupPhase, isSetupPhase) ||
                other.isSetupPhase == isSetupPhase) &&
            (identical(other.isResting, isResting) ||
                other.isResting == isResting) &&
            (identical(other.restSecondsRemaining, restSecondsRemaining) ||
                other.restSecondsRemaining == restSecondsRemaining) &&
            (identical(other.restSecondsTotal, restSecondsTotal) ||
                other.restSecondsTotal == restSecondsTotal) &&
            (identical(other.isRestPaused, isRestPaused) ||
                other.isRestPaused == isRestPaused) &&
            (identical(other.restTargetEndTime, restTargetEndTime) ||
                other.restTargetEndTime == restTargetEndTime) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isCompleting, isCompleting) ||
                other.isCompleting == isCompleting) &&
            (identical(other.isTimerPaused, isTimerPaused) ||
                other.isTimerPaused == isTimerPaused) &&
            (identical(other.previewXP, previewXP) ||
                other.previewXP == previewXP) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    workout,
    const DeepCollectionEquality().hash(exercises),
    elapsedSeconds,
    isSetupPhase,
    isResting,
    restSecondsRemaining,
    restSecondsTotal,
    isRestPaused,
    restTargetEndTime,
    isLoading,
    isCompleting,
    isTimerPaused,
    previewXP,
    errorMessage,
  );

  @override
  String toString() {
    return 'ActiveWorkoutState(workout: $workout, exercises: $exercises, elapsedSeconds: $elapsedSeconds, isSetupPhase: $isSetupPhase, isResting: $isResting, restSecondsRemaining: $restSecondsRemaining, restSecondsTotal: $restSecondsTotal, isRestPaused: $isRestPaused, restTargetEndTime: $restTargetEndTime, isLoading: $isLoading, isCompleting: $isCompleting, isTimerPaused: $isTimerPaused, previewXP: $previewXP, errorMessage: $errorMessage)';
  }
}

/// @nodoc
abstract mixin class $ActiveWorkoutStateCopyWith<$Res> {
  factory $ActiveWorkoutStateCopyWith(
    ActiveWorkoutState value,
    $Res Function(ActiveWorkoutState) _then,
  ) = _$ActiveWorkoutStateCopyWithImpl;
  @useResult
  $Res call({
    Workout? workout,
    List<WorkoutExercise> exercises,
    int elapsedSeconds,
    bool isSetupPhase,
    bool isResting,
    int restSecondsRemaining,
    int restSecondsTotal,
    bool isRestPaused,
    DateTime? restTargetEndTime,
    bool isLoading,
    bool isCompleting,
    bool isTimerPaused,
    int previewXP,
    String? errorMessage,
  });

  $WorkoutCopyWith<$Res>? get workout;
}

/// @nodoc
class _$ActiveWorkoutStateCopyWithImpl<$Res>
    implements $ActiveWorkoutStateCopyWith<$Res> {
  _$ActiveWorkoutStateCopyWithImpl(this._self, this._then);

  final ActiveWorkoutState _self;
  final $Res Function(ActiveWorkoutState) _then;

  /// Create a copy of ActiveWorkoutState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workout = freezed,
    Object? exercises = null,
    Object? elapsedSeconds = null,
    Object? isSetupPhase = null,
    Object? isResting = null,
    Object? restSecondsRemaining = null,
    Object? restSecondsTotal = null,
    Object? isRestPaused = null,
    Object? restTargetEndTime = freezed,
    Object? isLoading = null,
    Object? isCompleting = null,
    Object? isTimerPaused = null,
    Object? previewXP = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _self.copyWith(
        workout: freezed == workout ? _self.workout : workout as Workout?,
        exercises: null == exercises
            ? _self.exercises
            : exercises as List<WorkoutExercise>,
        elapsedSeconds: null == elapsedSeconds
            ? _self.elapsedSeconds
            : elapsedSeconds as int,
        isSetupPhase: null == isSetupPhase
            ? _self.isSetupPhase
            : isSetupPhase as bool,
        isResting: null == isResting ? _self.isResting : isResting as bool,
        restSecondsRemaining: null == restSecondsRemaining
            ? _self.restSecondsRemaining
            : restSecondsRemaining as int,
        restSecondsTotal: null == restSecondsTotal
            ? _self.restSecondsTotal
            : restSecondsTotal as int,
        isRestPaused: null == isRestPaused
            ? _self.isRestPaused
            : isRestPaused as bool,
        restTargetEndTime: freezed == restTargetEndTime
            ? _self.restTargetEndTime
            : restTargetEndTime as DateTime?,
        isLoading: null == isLoading ? _self.isLoading : isLoading as bool,
        isCompleting: null == isCompleting
            ? _self.isCompleting
            : isCompleting as bool,
        isTimerPaused: null == isTimerPaused
            ? _self.isTimerPaused
            : isTimerPaused as bool,
        previewXP: null == previewXP ? _self.previewXP : previewXP as int,
        errorMessage: freezed == errorMessage
            ? _self.errorMessage
            : errorMessage as String?,
      ),
    );
  }

  /// Create a copy of ActiveWorkoutState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WorkoutCopyWith<$Res>? get workout {
    if (_self.workout == null) {
      return null;
    }

    return $WorkoutCopyWith<$Res>(_self.workout!, (value) {
      return _then(_self.copyWith(workout: value));
    });
  }
}

/// Adds pattern-matching-related methods to [ActiveWorkoutState].
extension ActiveWorkoutStatePatterns on ActiveWorkoutState {
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ActiveWorkoutState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ActiveWorkoutState() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }
}

/// @nodoc
class _ActiveWorkoutState extends ActiveWorkoutState {
  const _ActiveWorkoutState({
    this.workout,
    final List<WorkoutExercise> exercises = const [],
    this.elapsedSeconds = 0,
    this.isSetupPhase = true,
    this.isResting = false,
    this.restSecondsRemaining = 0,
    this.restSecondsTotal = 0,
    this.isRestPaused = false,
    this.restTargetEndTime,
    this.isLoading = false,
    this.isCompleting = false,
    this.isTimerPaused = false,
    this.previewXP = 0,
    this.errorMessage,
  }) : _exercises = exercises,
       super._();

  @override
  final Workout? workout;
  final List<WorkoutExercise> _exercises;
  @override
  @JsonKey()
  List<WorkoutExercise> get exercises {
    if (_exercises is EqualUnmodifiableListView) return _exercises;
    return EqualUnmodifiableListView(_exercises);
  }

  @override
  @JsonKey()
  final int elapsedSeconds;
  @override
  @JsonKey()
  final bool isSetupPhase;
  @override
  @JsonKey()
  final bool isResting;
  @override
  @JsonKey()
  final int restSecondsRemaining;
  @override
  @JsonKey()
  final int restSecondsTotal;
  @override
  @JsonKey()
  final bool isRestPaused;
  @override
  final DateTime? restTargetEndTime;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isCompleting;
  @override
  @JsonKey()
  final bool isTimerPaused;
  @override
  @JsonKey()
  final int previewXP;
  @override
  final String? errorMessage;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ActiveWorkoutStateCopyWith<_ActiveWorkoutState> get copyWith =>
      __$ActiveWorkoutStateCopyWithImpl<_ActiveWorkoutState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ActiveWorkoutState &&
            (identical(other.workout, workout) || other.workout == workout) &&
            const DeepCollectionEquality().equals(
              other._exercises,
              _exercises,
            ) &&
            (identical(other.elapsedSeconds, elapsedSeconds) ||
                other.elapsedSeconds == elapsedSeconds) &&
            (identical(other.isSetupPhase, isSetupPhase) ||
                other.isSetupPhase == isSetupPhase) &&
            (identical(other.isResting, isResting) ||
                other.isResting == isResting) &&
            (identical(other.restSecondsRemaining, restSecondsRemaining) ||
                other.restSecondsRemaining == restSecondsRemaining) &&
            (identical(other.restSecondsTotal, restSecondsTotal) ||
                other.restSecondsTotal == restSecondsTotal) &&
            (identical(other.isRestPaused, isRestPaused) ||
                other.isRestPaused == isRestPaused) &&
            (identical(other.restTargetEndTime, restTargetEndTime) ||
                other.restTargetEndTime == restTargetEndTime) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isCompleting, isCompleting) ||
                other.isCompleting == isCompleting) &&
            (identical(other.isTimerPaused, isTimerPaused) ||
                other.isTimerPaused == isTimerPaused) &&
            (identical(other.previewXP, previewXP) ||
                other.previewXP == previewXP) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    workout,
    const DeepCollectionEquality().hash(_exercises),
    elapsedSeconds,
    isSetupPhase,
    isResting,
    restSecondsRemaining,
    restSecondsTotal,
    isRestPaused,
    restTargetEndTime,
    isLoading,
    isCompleting,
    isTimerPaused,
    previewXP,
    errorMessage,
  );

  @override
  String toString() {
    return 'ActiveWorkoutState(workout: $workout, exercises: $exercises, elapsedSeconds: $elapsedSeconds, isSetupPhase: $isSetupPhase, isResting: $isResting, restSecondsRemaining: $restSecondsRemaining, restSecondsTotal: $restSecondsTotal, isRestPaused: $isRestPaused, restTargetEndTime: $restTargetEndTime, isLoading: $isLoading, isCompleting: $isCompleting, isTimerPaused: $isTimerPaused, previewXP: $previewXP, errorMessage: $errorMessage)';
  }
}

/// @nodoc
abstract mixin class _$ActiveWorkoutStateCopyWith<$Res>
    implements $ActiveWorkoutStateCopyWith<$Res> {
  factory _$ActiveWorkoutStateCopyWith(
    _ActiveWorkoutState value,
    $Res Function(_ActiveWorkoutState) _then,
  ) = __$ActiveWorkoutStateCopyWithImpl;
  @override
  @useResult
  $Res call({
    Workout? workout,
    List<WorkoutExercise> exercises,
    int elapsedSeconds,
    bool isSetupPhase,
    bool isResting,
    int restSecondsRemaining,
    int restSecondsTotal,
    bool isRestPaused,
    DateTime? restTargetEndTime,
    bool isLoading,
    bool isCompleting,
    bool isTimerPaused,
    int previewXP,
    String? errorMessage,
  });

  @override
  $WorkoutCopyWith<$Res>? get workout;
}

/// @nodoc
class __$ActiveWorkoutStateCopyWithImpl<$Res>
    implements _$ActiveWorkoutStateCopyWith<$Res> {
  __$ActiveWorkoutStateCopyWithImpl(this._self, this._then);

  final _ActiveWorkoutState _self;
  final $Res Function(_ActiveWorkoutState) _then;

  /// Create a copy of ActiveWorkoutState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? workout = freezed,
    Object? exercises = null,
    Object? elapsedSeconds = null,
    Object? isSetupPhase = null,
    Object? isResting = null,
    Object? restSecondsRemaining = null,
    Object? restSecondsTotal = null,
    Object? isRestPaused = null,
    Object? restTargetEndTime = freezed,
    Object? isLoading = null,
    Object? isCompleting = null,
    Object? isTimerPaused = null,
    Object? previewXP = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _ActiveWorkoutState(
        workout: freezed == workout ? _self.workout : workout as Workout?,
        exercises: null == exercises
            ? _self._exercises
            : exercises as List<WorkoutExercise>,
        elapsedSeconds: null == elapsedSeconds
            ? _self.elapsedSeconds
            : elapsedSeconds as int,
        isSetupPhase: null == isSetupPhase
            ? _self.isSetupPhase
            : isSetupPhase as bool,
        isResting: null == isResting ? _self.isResting : isResting as bool,
        restSecondsRemaining: null == restSecondsRemaining
            ? _self.restSecondsRemaining
            : restSecondsRemaining as int,
        restSecondsTotal: null == restSecondsTotal
            ? _self.restSecondsTotal
            : restSecondsTotal as int,
        isRestPaused: null == isRestPaused
            ? _self.isRestPaused
            : isRestPaused as bool,
        restTargetEndTime: freezed == restTargetEndTime
            ? _self.restTargetEndTime
            : restTargetEndTime as DateTime?,
        isLoading: null == isLoading ? _self.isLoading : isLoading as bool,
        isCompleting: null == isCompleting
            ? _self.isCompleting
            : isCompleting as bool,
        isTimerPaused: null == isTimerPaused
            ? _self.isTimerPaused
            : isTimerPaused as bool,
        previewXP: null == previewXP ? _self.previewXP : previewXP as int,
        errorMessage: freezed == errorMessage
            ? _self.errorMessage
            : errorMessage as String?,
      ),
    );
  }

  @override
  @pragma('vm:prefer-inline')
  $WorkoutCopyWith<$Res>? get workout {
    if (_self.workout == null) {
      return null;
    }

    return $WorkoutCopyWith<$Res>(_self.workout!, (value) {
      return _then(_self.copyWith(workout: value));
    });
  }
}

// dart format on
