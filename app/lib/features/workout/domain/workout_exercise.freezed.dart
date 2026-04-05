// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_exercise.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkoutExercise {

 String get id;@JsonKey(name: 'workout_id') String get workoutId;@JsonKey(name: 'exercise_id') String get exerciseId;@JsonKey(name: 'order_index') int get orderIndex; String? get notes;@JsonKey(name: 'created_at') DateTime? get createdAt;/// Nested exercise detail (from join query)
@JsonKey(name: 'exercises') Exercise? get exercise;/// Nested sets (from join query)
@JsonKey(name: 'workout_sets') List<WorkoutSet> get sets;
/// Create a copy of WorkoutExercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutExerciseCopyWith<WorkoutExercise> get copyWith => _$WorkoutExerciseCopyWithImpl<WorkoutExercise>(this as WorkoutExercise, _$identity);

  /// Serializes this WorkoutExercise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.exercise, exercise) || other.exercise == exercise)&&const DeepCollectionEquality().equals(other.sets, sets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workoutId,exerciseId,orderIndex,notes,createdAt,exercise,const DeepCollectionEquality().hash(sets));

@override
String toString() {
  return 'WorkoutExercise(id: $id, workoutId: $workoutId, exerciseId: $exerciseId, orderIndex: $orderIndex, notes: $notes, createdAt: $createdAt, exercise: $exercise, sets: $sets)';
}


}

/// @nodoc
abstract mixin class $WorkoutExerciseCopyWith<$Res>  {
  factory $WorkoutExerciseCopyWith(WorkoutExercise value, $Res Function(WorkoutExercise) _then) = _$WorkoutExerciseCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'workout_id') String workoutId,@JsonKey(name: 'exercise_id') String exerciseId,@JsonKey(name: 'order_index') int orderIndex, String? notes,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'exercises') Exercise? exercise,@JsonKey(name: 'workout_sets') List<WorkoutSet> sets
});


$ExerciseCopyWith<$Res>? get exercise;

}
/// @nodoc
class _$WorkoutExerciseCopyWithImpl<$Res>
    implements $WorkoutExerciseCopyWith<$Res> {
  _$WorkoutExerciseCopyWithImpl(this._self, this._then);

  final WorkoutExercise _self;
  final $Res Function(WorkoutExercise) _then;

/// Create a copy of WorkoutExercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? workoutId = null,Object? exerciseId = null,Object? orderIndex = null,Object? notes = freezed,Object? createdAt = freezed,Object? exercise = freezed,Object? sets = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workoutId: null == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,exercise: freezed == exercise ? _self.exercise : exercise // ignore: cast_nullable_to_non_nullable
as Exercise?,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as List<WorkoutSet>,
  ));
}
/// Create a copy of WorkoutExercise
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExerciseCopyWith<$Res>? get exercise {
    if (_self.exercise == null) {
    return null;
  }

  return $ExerciseCopyWith<$Res>(_self.exercise!, (value) {
    return _then(_self.copyWith(exercise: value));
  });
}
}


/// Adds pattern-matching-related methods to [WorkoutExercise].
extension WorkoutExercisePatterns on WorkoutExercise {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutExercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutExercise() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutExercise value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutExercise():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutExercise value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutExercise() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'workout_id')  String workoutId, @JsonKey(name: 'exercise_id')  String exerciseId, @JsonKey(name: 'order_index')  int orderIndex,  String? notes, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'exercises')  Exercise? exercise, @JsonKey(name: 'workout_sets')  List<WorkoutSet> sets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutExercise() when $default != null:
return $default(_that.id,_that.workoutId,_that.exerciseId,_that.orderIndex,_that.notes,_that.createdAt,_that.exercise,_that.sets);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'workout_id')  String workoutId, @JsonKey(name: 'exercise_id')  String exerciseId, @JsonKey(name: 'order_index')  int orderIndex,  String? notes, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'exercises')  Exercise? exercise, @JsonKey(name: 'workout_sets')  List<WorkoutSet> sets)  $default,) {final _that = this;
switch (_that) {
case _WorkoutExercise():
return $default(_that.id,_that.workoutId,_that.exerciseId,_that.orderIndex,_that.notes,_that.createdAt,_that.exercise,_that.sets);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'workout_id')  String workoutId, @JsonKey(name: 'exercise_id')  String exerciseId, @JsonKey(name: 'order_index')  int orderIndex,  String? notes, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'exercises')  Exercise? exercise, @JsonKey(name: 'workout_sets')  List<WorkoutSet> sets)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutExercise() when $default != null:
return $default(_that.id,_that.workoutId,_that.exerciseId,_that.orderIndex,_that.notes,_that.createdAt,_that.exercise,_that.sets);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutExercise implements WorkoutExercise {
  const _WorkoutExercise({required this.id, @JsonKey(name: 'workout_id') required this.workoutId, @JsonKey(name: 'exercise_id') required this.exerciseId, @JsonKey(name: 'order_index') this.orderIndex = 0, this.notes, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'exercises') this.exercise, @JsonKey(name: 'workout_sets') final  List<WorkoutSet> sets = const []}): _sets = sets;
  factory _WorkoutExercise.fromJson(Map<String, dynamic> json) => _$WorkoutExerciseFromJson(json);

@override final  String id;
@override@JsonKey(name: 'workout_id') final  String workoutId;
@override@JsonKey(name: 'exercise_id') final  String exerciseId;
@override@JsonKey(name: 'order_index') final  int orderIndex;
@override final  String? notes;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
/// Nested exercise detail (from join query)
@override@JsonKey(name: 'exercises') final  Exercise? exercise;
/// Nested sets (from join query)
 final  List<WorkoutSet> _sets;
/// Nested sets (from join query)
@override@JsonKey(name: 'workout_sets') List<WorkoutSet> get sets {
  if (_sets is EqualUnmodifiableListView) return _sets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sets);
}


/// Create a copy of WorkoutExercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutExerciseCopyWith<_WorkoutExercise> get copyWith => __$WorkoutExerciseCopyWithImpl<_WorkoutExercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.exercise, exercise) || other.exercise == exercise)&&const DeepCollectionEquality().equals(other._sets, _sets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workoutId,exerciseId,orderIndex,notes,createdAt,exercise,const DeepCollectionEquality().hash(_sets));

@override
String toString() {
  return 'WorkoutExercise(id: $id, workoutId: $workoutId, exerciseId: $exerciseId, orderIndex: $orderIndex, notes: $notes, createdAt: $createdAt, exercise: $exercise, sets: $sets)';
}


}

/// @nodoc
abstract mixin class _$WorkoutExerciseCopyWith<$Res> implements $WorkoutExerciseCopyWith<$Res> {
  factory _$WorkoutExerciseCopyWith(_WorkoutExercise value, $Res Function(_WorkoutExercise) _then) = __$WorkoutExerciseCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'workout_id') String workoutId,@JsonKey(name: 'exercise_id') String exerciseId,@JsonKey(name: 'order_index') int orderIndex, String? notes,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'exercises') Exercise? exercise,@JsonKey(name: 'workout_sets') List<WorkoutSet> sets
});


@override $ExerciseCopyWith<$Res>? get exercise;

}
/// @nodoc
class __$WorkoutExerciseCopyWithImpl<$Res>
    implements _$WorkoutExerciseCopyWith<$Res> {
  __$WorkoutExerciseCopyWithImpl(this._self, this._then);

  final _WorkoutExercise _self;
  final $Res Function(_WorkoutExercise) _then;

/// Create a copy of WorkoutExercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? workoutId = null,Object? exerciseId = null,Object? orderIndex = null,Object? notes = freezed,Object? createdAt = freezed,Object? exercise = freezed,Object? sets = null,}) {
  return _then(_WorkoutExercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workoutId: null == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,exercise: freezed == exercise ? _self.exercise : exercise // ignore: cast_nullable_to_non_nullable
as Exercise?,sets: null == sets ? _self._sets : sets // ignore: cast_nullable_to_non_nullable
as List<WorkoutSet>,
  ));
}

/// Create a copy of WorkoutExercise
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExerciseCopyWith<$Res>? get exercise {
    if (_self.exercise == null) {
    return null;
  }

  return $ExerciseCopyWith<$Res>(_self.exercise!, (value) {
    return _then(_self.copyWith(exercise: value));
  });
}
}

// dart format on
