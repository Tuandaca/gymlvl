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

 String get id;@JsonKey(name: 'workout_exercise_id') String get workoutExerciseId;@JsonKey(name: 'set_number') int get setNumber; int get reps;@JsonKey(name: 'weight_kg') double get weightKg;@JsonKey(name: 'is_completed') bool get isCompleted;@JsonKey(name: 'rest_seconds') int get restSeconds;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of WorkoutSet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutSetCopyWith<WorkoutSet> get copyWith => _$WorkoutSetCopyWithImpl<WorkoutSet>(this as WorkoutSet, _$identity);

  /// Serializes this WorkoutSet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutSet&&(identical(other.id, id) || other.id == id)&&(identical(other.workoutExerciseId, workoutExerciseId) || other.workoutExerciseId == workoutExerciseId)&&(identical(other.setNumber, setNumber) || other.setNumber == setNumber)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workoutExerciseId,setNumber,reps,weightKg,isCompleted,restSeconds,createdAt);

@override
String toString() {
  return 'WorkoutSet(id: $id, workoutExerciseId: $workoutExerciseId, setNumber: $setNumber, reps: $reps, weightKg: $weightKg, isCompleted: $isCompleted, restSeconds: $restSeconds, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $WorkoutSetCopyWith<$Res>  {
  factory $WorkoutSetCopyWith(WorkoutSet value, $Res Function(WorkoutSet) _then) = _$WorkoutSetCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'workout_exercise_id') String workoutExerciseId,@JsonKey(name: 'set_number') int setNumber, int reps,@JsonKey(name: 'weight_kg') double weightKg,@JsonKey(name: 'is_completed') bool isCompleted,@JsonKey(name: 'rest_seconds') int restSeconds,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$WorkoutSetCopyWithImpl<$Res>
    implements $WorkoutSetCopyWith<$Res> {
  _$WorkoutSetCopyWithImpl(this._self, this._then);

  final WorkoutSet _self;
  final $Res Function(WorkoutSet) _then;

/// Create a copy of WorkoutSet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? workoutExerciseId = null,Object? setNumber = null,Object? reps = null,Object? weightKg = null,Object? isCompleted = null,Object? restSeconds = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workoutExerciseId: null == workoutExerciseId ? _self.workoutExerciseId : workoutExerciseId // ignore: cast_nullable_to_non_nullable
as String,setNumber: null == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,restSeconds: null == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutSet].
extension WorkoutSetPatterns on WorkoutSet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutSet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutSet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutSet value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutSet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutSet value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutSet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'workout_exercise_id')  String workoutExerciseId, @JsonKey(name: 'set_number')  int setNumber,  int reps, @JsonKey(name: 'weight_kg')  double weightKg, @JsonKey(name: 'is_completed')  bool isCompleted, @JsonKey(name: 'rest_seconds')  int restSeconds, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutSet() when $default != null:
return $default(_that.id,_that.workoutExerciseId,_that.setNumber,_that.reps,_that.weightKg,_that.isCompleted,_that.restSeconds,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'workout_exercise_id')  String workoutExerciseId, @JsonKey(name: 'set_number')  int setNumber,  int reps, @JsonKey(name: 'weight_kg')  double weightKg, @JsonKey(name: 'is_completed')  bool isCompleted, @JsonKey(name: 'rest_seconds')  int restSeconds, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _WorkoutSet():
return $default(_that.id,_that.workoutExerciseId,_that.setNumber,_that.reps,_that.weightKg,_that.isCompleted,_that.restSeconds,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'workout_exercise_id')  String workoutExerciseId, @JsonKey(name: 'set_number')  int setNumber,  int reps, @JsonKey(name: 'weight_kg')  double weightKg, @JsonKey(name: 'is_completed')  bool isCompleted, @JsonKey(name: 'rest_seconds')  int restSeconds, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutSet() when $default != null:
return $default(_that.id,_that.workoutExerciseId,_that.setNumber,_that.reps,_that.weightKg,_that.isCompleted,_that.restSeconds,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutSet implements WorkoutSet {
  const _WorkoutSet({required this.id, @JsonKey(name: 'workout_exercise_id') required this.workoutExerciseId, @JsonKey(name: 'set_number') this.setNumber = 1, this.reps = 0, @JsonKey(name: 'weight_kg') this.weightKg = 0, @JsonKey(name: 'is_completed') this.isCompleted = false, @JsonKey(name: 'rest_seconds') this.restSeconds = 0, @JsonKey(name: 'created_at') this.createdAt});
  factory _WorkoutSet.fromJson(Map<String, dynamic> json) => _$WorkoutSetFromJson(json);

@override final  String id;
@override@JsonKey(name: 'workout_exercise_id') final  String workoutExerciseId;
@override@JsonKey(name: 'set_number') final  int setNumber;
@override@JsonKey() final  int reps;
@override@JsonKey(name: 'weight_kg') final  double weightKg;
@override@JsonKey(name: 'is_completed') final  bool isCompleted;
@override@JsonKey(name: 'rest_seconds') final  int restSeconds;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of WorkoutSet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutSetCopyWith<_WorkoutSet> get copyWith => __$WorkoutSetCopyWithImpl<_WorkoutSet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutSetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutSet&&(identical(other.id, id) || other.id == id)&&(identical(other.workoutExerciseId, workoutExerciseId) || other.workoutExerciseId == workoutExerciseId)&&(identical(other.setNumber, setNumber) || other.setNumber == setNumber)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workoutExerciseId,setNumber,reps,weightKg,isCompleted,restSeconds,createdAt);

@override
String toString() {
  return 'WorkoutSet(id: $id, workoutExerciseId: $workoutExerciseId, setNumber: $setNumber, reps: $reps, weightKg: $weightKg, isCompleted: $isCompleted, restSeconds: $restSeconds, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$WorkoutSetCopyWith<$Res> implements $WorkoutSetCopyWith<$Res> {
  factory _$WorkoutSetCopyWith(_WorkoutSet value, $Res Function(_WorkoutSet) _then) = __$WorkoutSetCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'workout_exercise_id') String workoutExerciseId,@JsonKey(name: 'set_number') int setNumber, int reps,@JsonKey(name: 'weight_kg') double weightKg,@JsonKey(name: 'is_completed') bool isCompleted,@JsonKey(name: 'rest_seconds') int restSeconds,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$WorkoutSetCopyWithImpl<$Res>
    implements _$WorkoutSetCopyWith<$Res> {
  __$WorkoutSetCopyWithImpl(this._self, this._then);

  final _WorkoutSet _self;
  final $Res Function(_WorkoutSet) _then;

/// Create a copy of WorkoutSet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? workoutExerciseId = null,Object? setNumber = null,Object? reps = null,Object? weightKg = null,Object? isCompleted = null,Object? restSeconds = null,Object? createdAt = freezed,}) {
  return _then(_WorkoutSet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workoutExerciseId: null == workoutExerciseId ? _self.workoutExerciseId : workoutExerciseId // ignore: cast_nullable_to_non_nullable
as String,setNumber: null == setNumber ? _self.setNumber : setNumber // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,restSeconds: null == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
