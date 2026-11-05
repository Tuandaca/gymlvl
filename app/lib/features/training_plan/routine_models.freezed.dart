// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'routine_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RoutineExercise {

 String get id; String get routineId; String get exerciseId; int get orderIndex; int get sets; int get reps; int? get repsMin; double get weightKg; int? get durationSeconds; int? get restSeconds; int? get rpeTarget; int? get rirTarget; int? get warmupSets; WorkoutMode get mode; String? get notes; String? get supersetGroupId; int? get supersetPosition; bool get isWarmup; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of RoutineExercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutineExerciseCopyWith<RoutineExercise> get copyWith => _$RoutineExerciseCopyWithImpl<RoutineExercise>(this as RoutineExercise, _$identity);

  /// Serializes this RoutineExercise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutineExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.repsMin, repsMin) || other.repsMin == repsMin)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.rpeTarget, rpeTarget) || other.rpeTarget == rpeTarget)&&(identical(other.rirTarget, rirTarget) || other.rirTarget == rirTarget)&&(identical(other.warmupSets, warmupSets) || other.warmupSets == warmupSets)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.supersetGroupId, supersetGroupId) || other.supersetGroupId == supersetGroupId)&&(identical(other.supersetPosition, supersetPosition) || other.supersetPosition == supersetPosition)&&(identical(other.isWarmup, isWarmup) || other.isWarmup == isWarmup)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,routineId,exerciseId,orderIndex,sets,reps,repsMin,weightKg,durationSeconds,restSeconds,rpeTarget,rirTarget,warmupSets,mode,notes,supersetGroupId,supersetPosition,isWarmup,createdAt,updatedAt]);

@override
String toString() {
  return 'RoutineExercise(id: $id, routineId: $routineId, exerciseId: $exerciseId, orderIndex: $orderIndex, sets: $sets, reps: $reps, repsMin: $repsMin, weightKg: $weightKg, durationSeconds: $durationSeconds, restSeconds: $restSeconds, rpeTarget: $rpeTarget, rirTarget: $rirTarget, warmupSets: $warmupSets, mode: $mode, notes: $notes, supersetGroupId: $supersetGroupId, supersetPosition: $supersetPosition, isWarmup: $isWarmup, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $RoutineExerciseCopyWith<$Res>  {
  factory $RoutineExerciseCopyWith(RoutineExercise value, $Res Function(RoutineExercise) _then) = _$RoutineExerciseCopyWithImpl;
@useResult
$Res call({
 String id, String routineId, String exerciseId, int orderIndex, int sets, int reps, int? repsMin, double weightKg, int? durationSeconds, int? restSeconds, int? rpeTarget, int? rirTarget, int? warmupSets, WorkoutMode mode, String? notes, String? supersetGroupId, int? supersetPosition, bool isWarmup, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$RoutineExerciseCopyWithImpl<$Res>
    implements $RoutineExerciseCopyWith<$Res> {
  _$RoutineExerciseCopyWithImpl(this._self, this._then);

  final RoutineExercise _self;
  final $Res Function(RoutineExercise) _then;

/// Create a copy of RoutineExercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? routineId = null,Object? exerciseId = null,Object? orderIndex = null,Object? sets = null,Object? reps = null,Object? repsMin = freezed,Object? weightKg = null,Object? durationSeconds = freezed,Object? restSeconds = freezed,Object? rpeTarget = freezed,Object? rirTarget = freezed,Object? warmupSets = freezed,Object? mode = null,Object? notes = freezed,Object? supersetGroupId = freezed,Object? supersetPosition = freezed,Object? isWarmup = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,repsMin: freezed == repsMin ? _self.repsMin : repsMin // ignore: cast_nullable_to_non_nullable
as int?,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,restSeconds: freezed == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int?,rpeTarget: freezed == rpeTarget ? _self.rpeTarget : rpeTarget // ignore: cast_nullable_to_non_nullable
as int?,rirTarget: freezed == rirTarget ? _self.rirTarget : rirTarget // ignore: cast_nullable_to_non_nullable
as int?,warmupSets: freezed == warmupSets ? _self.warmupSets : warmupSets // ignore: cast_nullable_to_non_nullable
as int?,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as WorkoutMode,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,supersetGroupId: freezed == supersetGroupId ? _self.supersetGroupId : supersetGroupId // ignore: cast_nullable_to_non_nullable
as String?,supersetPosition: freezed == supersetPosition ? _self.supersetPosition : supersetPosition // ignore: cast_nullable_to_non_nullable
as int?,isWarmup: null == isWarmup ? _self.isWarmup : isWarmup // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RoutineExercise].
extension RoutineExercisePatterns on RoutineExercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutineExercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutineExercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutineExercise value)  $default,){
final _that = this;
switch (_that) {
case _RoutineExercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutineExercise value)?  $default,){
final _that = this;
switch (_that) {
case _RoutineExercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String routineId,  String exerciseId,  int orderIndex,  int sets,  int reps,  int? repsMin,  double weightKg,  int? durationSeconds,  int? restSeconds,  int? rpeTarget,  int? rirTarget,  int? warmupSets,  WorkoutMode mode,  String? notes,  String? supersetGroupId,  int? supersetPosition,  bool isWarmup,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutineExercise() when $default != null:
return $default(_that.id,_that.routineId,_that.exerciseId,_that.orderIndex,_that.sets,_that.reps,_that.repsMin,_that.weightKg,_that.durationSeconds,_that.restSeconds,_that.rpeTarget,_that.rirTarget,_that.warmupSets,_that.mode,_that.notes,_that.supersetGroupId,_that.supersetPosition,_that.isWarmup,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String routineId,  String exerciseId,  int orderIndex,  int sets,  int reps,  int? repsMin,  double weightKg,  int? durationSeconds,  int? restSeconds,  int? rpeTarget,  int? rirTarget,  int? warmupSets,  WorkoutMode mode,  String? notes,  String? supersetGroupId,  int? supersetPosition,  bool isWarmup,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _RoutineExercise():
return $default(_that.id,_that.routineId,_that.exerciseId,_that.orderIndex,_that.sets,_that.reps,_that.repsMin,_that.weightKg,_that.durationSeconds,_that.restSeconds,_that.rpeTarget,_that.rirTarget,_that.warmupSets,_that.mode,_that.notes,_that.supersetGroupId,_that.supersetPosition,_that.isWarmup,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String routineId,  String exerciseId,  int orderIndex,  int sets,  int reps,  int? repsMin,  double weightKg,  int? durationSeconds,  int? restSeconds,  int? rpeTarget,  int? rirTarget,  int? warmupSets,  WorkoutMode mode,  String? notes,  String? supersetGroupId,  int? supersetPosition,  bool isWarmup,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _RoutineExercise() when $default != null:
return $default(_that.id,_that.routineId,_that.exerciseId,_that.orderIndex,_that.sets,_that.reps,_that.repsMin,_that.weightKg,_that.durationSeconds,_that.restSeconds,_that.rpeTarget,_that.rirTarget,_that.warmupSets,_that.mode,_that.notes,_that.supersetGroupId,_that.supersetPosition,_that.isWarmup,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoutineExercise implements RoutineExercise {
  const _RoutineExercise({required this.id, required this.routineId, required this.exerciseId, required this.orderIndex, required this.sets, required this.reps, this.repsMin, required this.weightKg, this.durationSeconds, this.restSeconds, this.rpeTarget, this.rirTarget, this.warmupSets, required this.mode, this.notes, this.supersetGroupId, this.supersetPosition, this.isWarmup = false, this.createdAt, this.updatedAt});
  factory _RoutineExercise.fromJson(Map<String, dynamic> json) => _$RoutineExerciseFromJson(json);

@override final  String id;
@override final  String routineId;
@override final  String exerciseId;
@override final  int orderIndex;
@override final  int sets;
@override final  int reps;
@override final  int? repsMin;
@override final  double weightKg;
@override final  int? durationSeconds;
@override final  int? restSeconds;
@override final  int? rpeTarget;
@override final  int? rirTarget;
@override final  int? warmupSets;
@override final  WorkoutMode mode;
@override final  String? notes;
@override final  String? supersetGroupId;
@override final  int? supersetPosition;
@override@JsonKey() final  bool isWarmup;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of RoutineExercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutineExerciseCopyWith<_RoutineExercise> get copyWith => __$RoutineExerciseCopyWithImpl<_RoutineExercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoutineExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutineExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.repsMin, repsMin) || other.repsMin == repsMin)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.rpeTarget, rpeTarget) || other.rpeTarget == rpeTarget)&&(identical(other.rirTarget, rirTarget) || other.rirTarget == rirTarget)&&(identical(other.warmupSets, warmupSets) || other.warmupSets == warmupSets)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.supersetGroupId, supersetGroupId) || other.supersetGroupId == supersetGroupId)&&(identical(other.supersetPosition, supersetPosition) || other.supersetPosition == supersetPosition)&&(identical(other.isWarmup, isWarmup) || other.isWarmup == isWarmup)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,routineId,exerciseId,orderIndex,sets,reps,repsMin,weightKg,durationSeconds,restSeconds,rpeTarget,rirTarget,warmupSets,mode,notes,supersetGroupId,supersetPosition,isWarmup,createdAt,updatedAt]);

@override
String toString() {
  return 'RoutineExercise(id: $id, routineId: $routineId, exerciseId: $exerciseId, orderIndex: $orderIndex, sets: $sets, reps: $reps, repsMin: $repsMin, weightKg: $weightKg, durationSeconds: $durationSeconds, restSeconds: $restSeconds, rpeTarget: $rpeTarget, rirTarget: $rirTarget, warmupSets: $warmupSets, mode: $mode, notes: $notes, supersetGroupId: $supersetGroupId, supersetPosition: $supersetPosition, isWarmup: $isWarmup, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$RoutineExerciseCopyWith<$Res> implements $RoutineExerciseCopyWith<$Res> {
  factory _$RoutineExerciseCopyWith(_RoutineExercise value, $Res Function(_RoutineExercise) _then) = __$RoutineExerciseCopyWithImpl;
@override @useResult
$Res call({
 String id, String routineId, String exerciseId, int orderIndex, int sets, int reps, int? repsMin, double weightKg, int? durationSeconds, int? restSeconds, int? rpeTarget, int? rirTarget, int? warmupSets, WorkoutMode mode, String? notes, String? supersetGroupId, int? supersetPosition, bool isWarmup, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$RoutineExerciseCopyWithImpl<$Res>
    implements _$RoutineExerciseCopyWith<$Res> {
  __$RoutineExerciseCopyWithImpl(this._self, this._then);

  final _RoutineExercise _self;
  final $Res Function(_RoutineExercise) _then;

/// Create a copy of RoutineExercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? routineId = null,Object? exerciseId = null,Object? orderIndex = null,Object? sets = null,Object? reps = null,Object? repsMin = freezed,Object? weightKg = null,Object? durationSeconds = freezed,Object? restSeconds = freezed,Object? rpeTarget = freezed,Object? rirTarget = freezed,Object? warmupSets = freezed,Object? mode = null,Object? notes = freezed,Object? supersetGroupId = freezed,Object? supersetPosition = freezed,Object? isWarmup = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_RoutineExercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,repsMin: freezed == repsMin ? _self.repsMin : repsMin // ignore: cast_nullable_to_non_nullable
as int?,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,restSeconds: freezed == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int?,rpeTarget: freezed == rpeTarget ? _self.rpeTarget : rpeTarget // ignore: cast_nullable_to_non_nullable
as int?,rirTarget: freezed == rirTarget ? _self.rirTarget : rirTarget // ignore: cast_nullable_to_non_nullable
as int?,warmupSets: freezed == warmupSets ? _self.warmupSets : warmupSets // ignore: cast_nullable_to_non_nullable
as int?,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as WorkoutMode,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,supersetGroupId: freezed == supersetGroupId ? _self.supersetGroupId : supersetGroupId // ignore: cast_nullable_to_non_nullable
as String?,supersetPosition: freezed == supersetPosition ? _self.supersetPosition : supersetPosition // ignore: cast_nullable_to_non_nullable
as int?,isWarmup: null == isWarmup ? _self.isWarmup : isWarmup // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$RoutineSupersetGroup {

 String get id; String get routineId; int get position; DateTime? get createdAt;
/// Create a copy of RoutineSupersetGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutineSupersetGroupCopyWith<RoutineSupersetGroup> get copyWith => _$RoutineSupersetGroupCopyWithImpl<RoutineSupersetGroup>(this as RoutineSupersetGroup, _$identity);

  /// Serializes this RoutineSupersetGroup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutineSupersetGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.position, position) || other.position == position)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,routineId,position,createdAt);

@override
String toString() {
  return 'RoutineSupersetGroup(id: $id, routineId: $routineId, position: $position, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $RoutineSupersetGroupCopyWith<$Res>  {
  factory $RoutineSupersetGroupCopyWith(RoutineSupersetGroup value, $Res Function(RoutineSupersetGroup) _then) = _$RoutineSupersetGroupCopyWithImpl;
@useResult
$Res call({
 String id, String routineId, int position, DateTime? createdAt
});




}
/// @nodoc
class _$RoutineSupersetGroupCopyWithImpl<$Res>
    implements $RoutineSupersetGroupCopyWith<$Res> {
  _$RoutineSupersetGroupCopyWithImpl(this._self, this._then);

  final RoutineSupersetGroup _self;
  final $Res Function(RoutineSupersetGroup) _then;

/// Create a copy of RoutineSupersetGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? routineId = null,Object? position = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RoutineSupersetGroup].
extension RoutineSupersetGroupPatterns on RoutineSupersetGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutineSupersetGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutineSupersetGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutineSupersetGroup value)  $default,){
final _that = this;
switch (_that) {
case _RoutineSupersetGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutineSupersetGroup value)?  $default,){
final _that = this;
switch (_that) {
case _RoutineSupersetGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String routineId,  int position,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutineSupersetGroup() when $default != null:
return $default(_that.id,_that.routineId,_that.position,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String routineId,  int position,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _RoutineSupersetGroup():
return $default(_that.id,_that.routineId,_that.position,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String routineId,  int position,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _RoutineSupersetGroup() when $default != null:
return $default(_that.id,_that.routineId,_that.position,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoutineSupersetGroup implements RoutineSupersetGroup {
  const _RoutineSupersetGroup({required this.id, required this.routineId, required this.position, this.createdAt});
  factory _RoutineSupersetGroup.fromJson(Map<String, dynamic> json) => _$RoutineSupersetGroupFromJson(json);

@override final  String id;
@override final  String routineId;
@override final  int position;
@override final  DateTime? createdAt;

/// Create a copy of RoutineSupersetGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutineSupersetGroupCopyWith<_RoutineSupersetGroup> get copyWith => __$RoutineSupersetGroupCopyWithImpl<_RoutineSupersetGroup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoutineSupersetGroupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutineSupersetGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.position, position) || other.position == position)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,routineId,position,createdAt);

@override
String toString() {
  return 'RoutineSupersetGroup(id: $id, routineId: $routineId, position: $position, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$RoutineSupersetGroupCopyWith<$Res> implements $RoutineSupersetGroupCopyWith<$Res> {
  factory _$RoutineSupersetGroupCopyWith(_RoutineSupersetGroup value, $Res Function(_RoutineSupersetGroup) _then) = __$RoutineSupersetGroupCopyWithImpl;
@override @useResult
$Res call({
 String id, String routineId, int position, DateTime? createdAt
});




}
/// @nodoc
class __$RoutineSupersetGroupCopyWithImpl<$Res>
    implements _$RoutineSupersetGroupCopyWith<$Res> {
  __$RoutineSupersetGroupCopyWithImpl(this._self, this._then);

  final _RoutineSupersetGroup _self;
  final $Res Function(_RoutineSupersetGroup) _then;

/// Create a copy of RoutineSupersetGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? routineId = null,Object? position = null,Object? createdAt = freezed,}) {
  return _then(_RoutineSupersetGroup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$Routine {

 String get id; String get userId; String get name; String? get emoji; bool get isArchived; int get version; List<RoutineExercise> get exercises; List<String> get supersetGroupIds;// IDs of superset groups in this routine
 DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Routine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutineCopyWith<Routine> get copyWith => _$RoutineCopyWithImpl<Routine>(this as Routine, _$identity);

  /// Serializes this Routine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Routine&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other.exercises, exercises)&&const DeepCollectionEquality().equals(other.supersetGroupIds, supersetGroupIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,emoji,isArchived,version,const DeepCollectionEquality().hash(exercises),const DeepCollectionEquality().hash(supersetGroupIds),createdAt,updatedAt);

@override
String toString() {
  return 'Routine(id: $id, userId: $userId, name: $name, emoji: $emoji, isArchived: $isArchived, version: $version, exercises: $exercises, supersetGroupIds: $supersetGroupIds, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $RoutineCopyWith<$Res>  {
  factory $RoutineCopyWith(Routine value, $Res Function(Routine) _then) = _$RoutineCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String name, String? emoji, bool isArchived, int version, List<RoutineExercise> exercises, List<String> supersetGroupIds, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$RoutineCopyWithImpl<$Res>
    implements $RoutineCopyWith<$Res> {
  _$RoutineCopyWithImpl(this._self, this._then);

  final Routine _self;
  final $Res Function(Routine) _then;

/// Create a copy of Routine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? emoji = freezed,Object? isArchived = null,Object? version = null,Object? exercises = null,Object? supersetGroupIds = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<RoutineExercise>,supersetGroupIds: null == supersetGroupIds ? _self.supersetGroupIds : supersetGroupIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Routine].
extension RoutinePatterns on Routine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Routine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Routine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Routine value)  $default,){
final _that = this;
switch (_that) {
case _Routine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Routine value)?  $default,){
final _that = this;
switch (_that) {
case _Routine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String? emoji,  bool isArchived,  int version,  List<RoutineExercise> exercises,  List<String> supersetGroupIds,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Routine() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.emoji,_that.isArchived,_that.version,_that.exercises,_that.supersetGroupIds,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String? emoji,  bool isArchived,  int version,  List<RoutineExercise> exercises,  List<String> supersetGroupIds,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Routine():
return $default(_that.id,_that.userId,_that.name,_that.emoji,_that.isArchived,_that.version,_that.exercises,_that.supersetGroupIds,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String name,  String? emoji,  bool isArchived,  int version,  List<RoutineExercise> exercises,  List<String> supersetGroupIds,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Routine() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.emoji,_that.isArchived,_that.version,_that.exercises,_that.supersetGroupIds,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Routine implements Routine {
  const _Routine({required this.id, required this.userId, required this.name, this.emoji, this.isArchived = false, this.version = 1, final  List<RoutineExercise> exercises = const [], final  List<String> supersetGroupIds = const [], this.createdAt, this.updatedAt}): _exercises = exercises,_supersetGroupIds = supersetGroupIds;
  factory _Routine.fromJson(Map<String, dynamic> json) => _$RoutineFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String name;
@override final  String? emoji;
@override@JsonKey() final  bool isArchived;
@override@JsonKey() final  int version;
 final  List<RoutineExercise> _exercises;
@override@JsonKey() List<RoutineExercise> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}

 final  List<String> _supersetGroupIds;
@override@JsonKey() List<String> get supersetGroupIds {
  if (_supersetGroupIds is EqualUnmodifiableListView) return _supersetGroupIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_supersetGroupIds);
}

// IDs of superset groups in this routine
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Routine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutineCopyWith<_Routine> get copyWith => __$RoutineCopyWithImpl<_Routine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoutineToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Routine&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other._exercises, _exercises)&&const DeepCollectionEquality().equals(other._supersetGroupIds, _supersetGroupIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,emoji,isArchived,version,const DeepCollectionEquality().hash(_exercises),const DeepCollectionEquality().hash(_supersetGroupIds),createdAt,updatedAt);

@override
String toString() {
  return 'Routine(id: $id, userId: $userId, name: $name, emoji: $emoji, isArchived: $isArchived, version: $version, exercises: $exercises, supersetGroupIds: $supersetGroupIds, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$RoutineCopyWith<$Res> implements $RoutineCopyWith<$Res> {
  factory _$RoutineCopyWith(_Routine value, $Res Function(_Routine) _then) = __$RoutineCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String name, String? emoji, bool isArchived, int version, List<RoutineExercise> exercises, List<String> supersetGroupIds, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$RoutineCopyWithImpl<$Res>
    implements _$RoutineCopyWith<$Res> {
  __$RoutineCopyWithImpl(this._self, this._then);

  final _Routine _self;
  final $Res Function(_Routine) _then;

/// Create a copy of Routine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? emoji = freezed,Object? isArchived = null,Object? version = null,Object? exercises = null,Object? supersetGroupIds = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Routine(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<RoutineExercise>,supersetGroupIds: null == supersetGroupIds ? _self._supersetGroupIds : supersetGroupIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$RoutineSupersetGroupModel {

 String get id; String get routineId; int get position; List<String> get exerciseIds; DateTime? get createdAt;
/// Create a copy of RoutineSupersetGroupModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutineSupersetGroupModelCopyWith<RoutineSupersetGroupModel> get copyWith => _$RoutineSupersetGroupModelCopyWithImpl<RoutineSupersetGroupModel>(this as RoutineSupersetGroupModel, _$identity);

  /// Serializes this RoutineSupersetGroupModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutineSupersetGroupModel&&(identical(other.id, id) || other.id == id)&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.position, position) || other.position == position)&&const DeepCollectionEquality().equals(other.exerciseIds, exerciseIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,routineId,position,const DeepCollectionEquality().hash(exerciseIds),createdAt);

@override
String toString() {
  return 'RoutineSupersetGroupModel(id: $id, routineId: $routineId, position: $position, exerciseIds: $exerciseIds, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $RoutineSupersetGroupModelCopyWith<$Res>  {
  factory $RoutineSupersetGroupModelCopyWith(RoutineSupersetGroupModel value, $Res Function(RoutineSupersetGroupModel) _then) = _$RoutineSupersetGroupModelCopyWithImpl;
@useResult
$Res call({
 String id, String routineId, int position, List<String> exerciseIds, DateTime? createdAt
});




}
/// @nodoc
class _$RoutineSupersetGroupModelCopyWithImpl<$Res>
    implements $RoutineSupersetGroupModelCopyWith<$Res> {
  _$RoutineSupersetGroupModelCopyWithImpl(this._self, this._then);

  final RoutineSupersetGroupModel _self;
  final $Res Function(RoutineSupersetGroupModel) _then;

/// Create a copy of RoutineSupersetGroupModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? routineId = null,Object? position = null,Object? exerciseIds = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,exerciseIds: null == exerciseIds ? _self.exerciseIds : exerciseIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RoutineSupersetGroupModel].
extension RoutineSupersetGroupModelPatterns on RoutineSupersetGroupModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutineSupersetGroupModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutineSupersetGroupModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutineSupersetGroupModel value)  $default,){
final _that = this;
switch (_that) {
case _RoutineSupersetGroupModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutineSupersetGroupModel value)?  $default,){
final _that = this;
switch (_that) {
case _RoutineSupersetGroupModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String routineId,  int position,  List<String> exerciseIds,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutineSupersetGroupModel() when $default != null:
return $default(_that.id,_that.routineId,_that.position,_that.exerciseIds,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String routineId,  int position,  List<String> exerciseIds,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _RoutineSupersetGroupModel():
return $default(_that.id,_that.routineId,_that.position,_that.exerciseIds,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String routineId,  int position,  List<String> exerciseIds,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _RoutineSupersetGroupModel() when $default != null:
return $default(_that.id,_that.routineId,_that.position,_that.exerciseIds,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoutineSupersetGroupModel implements RoutineSupersetGroupModel {
  const _RoutineSupersetGroupModel({required this.id, required this.routineId, required this.position, final  List<String> exerciseIds = const [], this.createdAt}): _exerciseIds = exerciseIds;
  factory _RoutineSupersetGroupModel.fromJson(Map<String, dynamic> json) => _$RoutineSupersetGroupModelFromJson(json);

@override final  String id;
@override final  String routineId;
@override final  int position;
 final  List<String> _exerciseIds;
@override@JsonKey() List<String> get exerciseIds {
  if (_exerciseIds is EqualUnmodifiableListView) return _exerciseIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exerciseIds);
}

@override final  DateTime? createdAt;

/// Create a copy of RoutineSupersetGroupModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutineSupersetGroupModelCopyWith<_RoutineSupersetGroupModel> get copyWith => __$RoutineSupersetGroupModelCopyWithImpl<_RoutineSupersetGroupModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoutineSupersetGroupModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutineSupersetGroupModel&&(identical(other.id, id) || other.id == id)&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.position, position) || other.position == position)&&const DeepCollectionEquality().equals(other._exerciseIds, _exerciseIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,routineId,position,const DeepCollectionEquality().hash(_exerciseIds),createdAt);

@override
String toString() {
  return 'RoutineSupersetGroupModel(id: $id, routineId: $routineId, position: $position, exerciseIds: $exerciseIds, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$RoutineSupersetGroupModelCopyWith<$Res> implements $RoutineSupersetGroupModelCopyWith<$Res> {
  factory _$RoutineSupersetGroupModelCopyWith(_RoutineSupersetGroupModel value, $Res Function(_RoutineSupersetGroupModel) _then) = __$RoutineSupersetGroupModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String routineId, int position, List<String> exerciseIds, DateTime? createdAt
});




}
/// @nodoc
class __$RoutineSupersetGroupModelCopyWithImpl<$Res>
    implements _$RoutineSupersetGroupModelCopyWith<$Res> {
  __$RoutineSupersetGroupModelCopyWithImpl(this._self, this._then);

  final _RoutineSupersetGroupModel _self;
  final $Res Function(_RoutineSupersetGroupModel) _then;

/// Create a copy of RoutineSupersetGroupModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? routineId = null,Object? position = null,Object? exerciseIds = null,Object? createdAt = freezed,}) {
  return _then(_RoutineSupersetGroupModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,exerciseIds: null == exerciseIds ? _self._exerciseIds : exerciseIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

RoutineSchedule _$RoutineScheduleFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'fixedWeek':
          return FixedWeekSchedule.fromJson(
            json
          );
                case 'rotation':
          return RotationSchedule.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'RoutineSchedule',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$RoutineSchedule {

 String get id; String get routineId;
/// Create a copy of RoutineSchedule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutineScheduleCopyWith<RoutineSchedule> get copyWith => _$RoutineScheduleCopyWithImpl<RoutineSchedule>(this as RoutineSchedule, _$identity);

  /// Serializes this RoutineSchedule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutineSchedule&&(identical(other.id, id) || other.id == id)&&(identical(other.routineId, routineId) || other.routineId == routineId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,routineId);

@override
String toString() {
  return 'RoutineSchedule(id: $id, routineId: $routineId)';
}


}

/// @nodoc
abstract mixin class $RoutineScheduleCopyWith<$Res>  {
  factory $RoutineScheduleCopyWith(RoutineSchedule value, $Res Function(RoutineSchedule) _then) = _$RoutineScheduleCopyWithImpl;
@useResult
$Res call({
 String id, String routineId
});




}
/// @nodoc
class _$RoutineScheduleCopyWithImpl<$Res>
    implements $RoutineScheduleCopyWith<$Res> {
  _$RoutineScheduleCopyWithImpl(this._self, this._then);

  final RoutineSchedule _self;
  final $Res Function(RoutineSchedule) _then;

/// Create a copy of RoutineSchedule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? routineId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RoutineSchedule].
extension RoutineSchedulePatterns on RoutineSchedule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( FixedWeekSchedule value)?  fixedWeek,TResult Function( RotationSchedule value)?  rotation,required TResult orElse(),}){
final _that = this;
switch (_that) {
case FixedWeekSchedule() when fixedWeek != null:
return fixedWeek(_that);case RotationSchedule() when rotation != null:
return rotation(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( FixedWeekSchedule value)  fixedWeek,required TResult Function( RotationSchedule value)  rotation,}){
final _that = this;
switch (_that) {
case FixedWeekSchedule():
return fixedWeek(_that);case RotationSchedule():
return rotation(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( FixedWeekSchedule value)?  fixedWeek,TResult? Function( RotationSchedule value)?  rotation,}){
final _that = this;
switch (_that) {
case FixedWeekSchedule() when fixedWeek != null:
return fixedWeek(_that);case RotationSchedule() when rotation != null:
return rotation(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id,  String routineId,  int weekday)?  fixedWeek,TResult Function( String id,  String routineId,  int position,  String? supersetGroupId)?  rotation,required TResult orElse(),}) {final _that = this;
switch (_that) {
case FixedWeekSchedule() when fixedWeek != null:
return fixedWeek(_that.id,_that.routineId,_that.weekday);case RotationSchedule() when rotation != null:
return rotation(_that.id,_that.routineId,_that.position,_that.supersetGroupId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id,  String routineId,  int weekday)  fixedWeek,required TResult Function( String id,  String routineId,  int position,  String? supersetGroupId)  rotation,}) {final _that = this;
switch (_that) {
case FixedWeekSchedule():
return fixedWeek(_that.id,_that.routineId,_that.weekday);case RotationSchedule():
return rotation(_that.id,_that.routineId,_that.position,_that.supersetGroupId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id,  String routineId,  int weekday)?  fixedWeek,TResult? Function( String id,  String routineId,  int position,  String? supersetGroupId)?  rotation,}) {final _that = this;
switch (_that) {
case FixedWeekSchedule() when fixedWeek != null:
return fixedWeek(_that.id,_that.routineId,_that.weekday);case RotationSchedule() when rotation != null:
return rotation(_that.id,_that.routineId,_that.position,_that.supersetGroupId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class FixedWeekSchedule implements RoutineSchedule {
  const FixedWeekSchedule({required this.id, required this.routineId, required this.weekday, final  String? $type}): $type = $type ?? 'fixedWeek';
  factory FixedWeekSchedule.fromJson(Map<String, dynamic> json) => _$FixedWeekScheduleFromJson(json);

@override final  String id;
@override final  String routineId;
 final  int weekday;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of RoutineSchedule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FixedWeekScheduleCopyWith<FixedWeekSchedule> get copyWith => _$FixedWeekScheduleCopyWithImpl<FixedWeekSchedule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FixedWeekScheduleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FixedWeekSchedule&&(identical(other.id, id) || other.id == id)&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.weekday, weekday) || other.weekday == weekday));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,routineId,weekday);

@override
String toString() {
  return 'RoutineSchedule.fixedWeek(id: $id, routineId: $routineId, weekday: $weekday)';
}


}

/// @nodoc
abstract mixin class $FixedWeekScheduleCopyWith<$Res> implements $RoutineScheduleCopyWith<$Res> {
  factory $FixedWeekScheduleCopyWith(FixedWeekSchedule value, $Res Function(FixedWeekSchedule) _then) = _$FixedWeekScheduleCopyWithImpl;
@override @useResult
$Res call({
 String id, String routineId, int weekday
});




}
/// @nodoc
class _$FixedWeekScheduleCopyWithImpl<$Res>
    implements $FixedWeekScheduleCopyWith<$Res> {
  _$FixedWeekScheduleCopyWithImpl(this._self, this._then);

  final FixedWeekSchedule _self;
  final $Res Function(FixedWeekSchedule) _then;

/// Create a copy of RoutineSchedule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? routineId = null,Object? weekday = null,}) {
  return _then(FixedWeekSchedule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,weekday: null == weekday ? _self.weekday : weekday // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class RotationSchedule implements RoutineSchedule {
  const RotationSchedule({required this.id, required this.routineId, required this.position, this.supersetGroupId, final  String? $type}): $type = $type ?? 'rotation';
  factory RotationSchedule.fromJson(Map<String, dynamic> json) => _$RotationScheduleFromJson(json);

@override final  String id;
@override final  String routineId;
 final  int position;
 final  String? supersetGroupId;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of RoutineSchedule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RotationScheduleCopyWith<RotationSchedule> get copyWith => _$RotationScheduleCopyWithImpl<RotationSchedule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RotationScheduleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RotationSchedule&&(identical(other.id, id) || other.id == id)&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.position, position) || other.position == position)&&(identical(other.supersetGroupId, supersetGroupId) || other.supersetGroupId == supersetGroupId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,routineId,position,supersetGroupId);

@override
String toString() {
  return 'RoutineSchedule.rotation(id: $id, routineId: $routineId, position: $position, supersetGroupId: $supersetGroupId)';
}


}

/// @nodoc
abstract mixin class $RotationScheduleCopyWith<$Res> implements $RoutineScheduleCopyWith<$Res> {
  factory $RotationScheduleCopyWith(RotationSchedule value, $Res Function(RotationSchedule) _then) = _$RotationScheduleCopyWithImpl;
@override @useResult
$Res call({
 String id, String routineId, int position, String? supersetGroupId
});




}
/// @nodoc
class _$RotationScheduleCopyWithImpl<$Res>
    implements $RotationScheduleCopyWith<$Res> {
  _$RotationScheduleCopyWithImpl(this._self, this._then);

  final RotationSchedule _self;
  final $Res Function(RotationSchedule) _then;

/// Create a copy of RoutineSchedule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? routineId = null,Object? position = null,Object? supersetGroupId = freezed,}) {
  return _then(RotationSchedule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,supersetGroupId: freezed == supersetGroupId ? _self.supersetGroupId : supersetGroupId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PlannedWorkout {

 String get id; String get userId; String get routineId; String get routineName; Map<String, dynamic> get routineSnapshot;// Immutable snapshot
 DateTime get scheduledDate;// Local date
 PlannedWorkoutStatus get status; String? get workoutId;// Linked workout when started
 DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of PlannedWorkout
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlannedWorkoutCopyWith<PlannedWorkout> get copyWith => _$PlannedWorkoutCopyWithImpl<PlannedWorkout>(this as PlannedWorkout, _$identity);

  /// Serializes this PlannedWorkout to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlannedWorkout&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.routineName, routineName) || other.routineName == routineName)&&const DeepCollectionEquality().equals(other.routineSnapshot, routineSnapshot)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,routineId,routineName,const DeepCollectionEquality().hash(routineSnapshot),scheduledDate,status,workoutId,createdAt,updatedAt);

@override
String toString() {
  return 'PlannedWorkout(id: $id, userId: $userId, routineId: $routineId, routineName: $routineName, routineSnapshot: $routineSnapshot, scheduledDate: $scheduledDate, status: $status, workoutId: $workoutId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PlannedWorkoutCopyWith<$Res>  {
  factory $PlannedWorkoutCopyWith(PlannedWorkout value, $Res Function(PlannedWorkout) _then) = _$PlannedWorkoutCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String routineId, String routineName, Map<String, dynamic> routineSnapshot, DateTime scheduledDate, PlannedWorkoutStatus status, String? workoutId, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$PlannedWorkoutCopyWithImpl<$Res>
    implements $PlannedWorkoutCopyWith<$Res> {
  _$PlannedWorkoutCopyWithImpl(this._self, this._then);

  final PlannedWorkout _self;
  final $Res Function(PlannedWorkout) _then;

/// Create a copy of PlannedWorkout
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? routineId = null,Object? routineName = null,Object? routineSnapshot = null,Object? scheduledDate = null,Object? status = null,Object? workoutId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,routineName: null == routineName ? _self.routineName : routineName // ignore: cast_nullable_to_non_nullable
as String,routineSnapshot: null == routineSnapshot ? _self.routineSnapshot : routineSnapshot // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,scheduledDate: null == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PlannedWorkoutStatus,workoutId: freezed == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlannedWorkout].
extension PlannedWorkoutPatterns on PlannedWorkout {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlannedWorkout value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlannedWorkout() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlannedWorkout value)  $default,){
final _that = this;
switch (_that) {
case _PlannedWorkout():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlannedWorkout value)?  $default,){
final _that = this;
switch (_that) {
case _PlannedWorkout() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String routineId,  String routineName,  Map<String, dynamic> routineSnapshot,  DateTime scheduledDate,  PlannedWorkoutStatus status,  String? workoutId,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlannedWorkout() when $default != null:
return $default(_that.id,_that.userId,_that.routineId,_that.routineName,_that.routineSnapshot,_that.scheduledDate,_that.status,_that.workoutId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String routineId,  String routineName,  Map<String, dynamic> routineSnapshot,  DateTime scheduledDate,  PlannedWorkoutStatus status,  String? workoutId,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PlannedWorkout():
return $default(_that.id,_that.userId,_that.routineId,_that.routineName,_that.routineSnapshot,_that.scheduledDate,_that.status,_that.workoutId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String routineId,  String routineName,  Map<String, dynamic> routineSnapshot,  DateTime scheduledDate,  PlannedWorkoutStatus status,  String? workoutId,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PlannedWorkout() when $default != null:
return $default(_that.id,_that.userId,_that.routineId,_that.routineName,_that.routineSnapshot,_that.scheduledDate,_that.status,_that.workoutId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlannedWorkout implements PlannedWorkout {
  const _PlannedWorkout({required this.id, required this.userId, required this.routineId, required this.routineName, required final  Map<String, dynamic> routineSnapshot, required this.scheduledDate, this.status = PlannedWorkoutStatus.planned, this.workoutId, this.createdAt, this.updatedAt}): _routineSnapshot = routineSnapshot;
  factory _PlannedWorkout.fromJson(Map<String, dynamic> json) => _$PlannedWorkoutFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String routineId;
@override final  String routineName;
 final  Map<String, dynamic> _routineSnapshot;
@override Map<String, dynamic> get routineSnapshot {
  if (_routineSnapshot is EqualUnmodifiableMapView) return _routineSnapshot;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_routineSnapshot);
}

// Immutable snapshot
@override final  DateTime scheduledDate;
// Local date
@override@JsonKey() final  PlannedWorkoutStatus status;
@override final  String? workoutId;
// Linked workout when started
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of PlannedWorkout
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlannedWorkoutCopyWith<_PlannedWorkout> get copyWith => __$PlannedWorkoutCopyWithImpl<_PlannedWorkout>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlannedWorkoutToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlannedWorkout&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.routineName, routineName) || other.routineName == routineName)&&const DeepCollectionEquality().equals(other._routineSnapshot, _routineSnapshot)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,routineId,routineName,const DeepCollectionEquality().hash(_routineSnapshot),scheduledDate,status,workoutId,createdAt,updatedAt);

@override
String toString() {
  return 'PlannedWorkout(id: $id, userId: $userId, routineId: $routineId, routineName: $routineName, routineSnapshot: $routineSnapshot, scheduledDate: $scheduledDate, status: $status, workoutId: $workoutId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PlannedWorkoutCopyWith<$Res> implements $PlannedWorkoutCopyWith<$Res> {
  factory _$PlannedWorkoutCopyWith(_PlannedWorkout value, $Res Function(_PlannedWorkout) _then) = __$PlannedWorkoutCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String routineId, String routineName, Map<String, dynamic> routineSnapshot, DateTime scheduledDate, PlannedWorkoutStatus status, String? workoutId, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$PlannedWorkoutCopyWithImpl<$Res>
    implements _$PlannedWorkoutCopyWith<$Res> {
  __$PlannedWorkoutCopyWithImpl(this._self, this._then);

  final _PlannedWorkout _self;
  final $Res Function(_PlannedWorkout) _then;

/// Create a copy of PlannedWorkout
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? routineId = null,Object? routineName = null,Object? routineSnapshot = null,Object? scheduledDate = null,Object? status = null,Object? workoutId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_PlannedWorkout(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,routineName: null == routineName ? _self.routineName : routineName // ignore: cast_nullable_to_non_nullable
as String,routineSnapshot: null == routineSnapshot ? _self._routineSnapshot : routineSnapshot // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,scheduledDate: null == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PlannedWorkoutStatus,workoutId: freezed == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$RoutineExerciseConfig {

 String get exerciseId; int get orderIndex; int get sets; int get reps; int? get repsMin; double get weightKg; int? get durationSeconds; int? get restSeconds; int? get rpeTarget; int? get rirTarget; int? get warmupSets; WorkoutMode get mode; String? get notes; String? get supersetGroupId; int? get supersetPosition; bool get isWarmup; String? get routineExerciseId;
/// Create a copy of RoutineExerciseConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutineExerciseConfigCopyWith<RoutineExerciseConfig> get copyWith => _$RoutineExerciseConfigCopyWithImpl<RoutineExerciseConfig>(this as RoutineExerciseConfig, _$identity);

  /// Serializes this RoutineExerciseConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutineExerciseConfig&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.repsMin, repsMin) || other.repsMin == repsMin)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.rpeTarget, rpeTarget) || other.rpeTarget == rpeTarget)&&(identical(other.rirTarget, rirTarget) || other.rirTarget == rirTarget)&&(identical(other.warmupSets, warmupSets) || other.warmupSets == warmupSets)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.supersetGroupId, supersetGroupId) || other.supersetGroupId == supersetGroupId)&&(identical(other.supersetPosition, supersetPosition) || other.supersetPosition == supersetPosition)&&(identical(other.isWarmup, isWarmup) || other.isWarmup == isWarmup)&&(identical(other.routineExerciseId, routineExerciseId) || other.routineExerciseId == routineExerciseId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseId,orderIndex,sets,reps,repsMin,weightKg,durationSeconds,restSeconds,rpeTarget,rirTarget,warmupSets,mode,notes,supersetGroupId,supersetPosition,isWarmup,routineExerciseId);

@override
String toString() {
  return 'RoutineExerciseConfig(exerciseId: $exerciseId, orderIndex: $orderIndex, sets: $sets, reps: $reps, repsMin: $repsMin, weightKg: $weightKg, durationSeconds: $durationSeconds, restSeconds: $restSeconds, rpeTarget: $rpeTarget, rirTarget: $rirTarget, warmupSets: $warmupSets, mode: $mode, notes: $notes, supersetGroupId: $supersetGroupId, supersetPosition: $supersetPosition, isWarmup: $isWarmup, routineExerciseId: $routineExerciseId)';
}


}

/// @nodoc
abstract mixin class $RoutineExerciseConfigCopyWith<$Res>  {
  factory $RoutineExerciseConfigCopyWith(RoutineExerciseConfig value, $Res Function(RoutineExerciseConfig) _then) = _$RoutineExerciseConfigCopyWithImpl;
@useResult
$Res call({
 String exerciseId, int orderIndex, int sets, int reps, int? repsMin, double weightKg, int? durationSeconds, int? restSeconds, int? rpeTarget, int? rirTarget, int? warmupSets, WorkoutMode mode, String? notes, String? supersetGroupId, int? supersetPosition, bool isWarmup, String? routineExerciseId
});




}
/// @nodoc
class _$RoutineExerciseConfigCopyWithImpl<$Res>
    implements $RoutineExerciseConfigCopyWith<$Res> {
  _$RoutineExerciseConfigCopyWithImpl(this._self, this._then);

  final RoutineExerciseConfig _self;
  final $Res Function(RoutineExerciseConfig) _then;

/// Create a copy of RoutineExerciseConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseId = null,Object? orderIndex = null,Object? sets = null,Object? reps = null,Object? repsMin = freezed,Object? weightKg = null,Object? durationSeconds = freezed,Object? restSeconds = freezed,Object? rpeTarget = freezed,Object? rirTarget = freezed,Object? warmupSets = freezed,Object? mode = null,Object? notes = freezed,Object? supersetGroupId = freezed,Object? supersetPosition = freezed,Object? isWarmup = null,Object? routineExerciseId = freezed,}) {
  return _then(_self.copyWith(
exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,repsMin: freezed == repsMin ? _self.repsMin : repsMin // ignore: cast_nullable_to_non_nullable
as int?,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,restSeconds: freezed == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int?,rpeTarget: freezed == rpeTarget ? _self.rpeTarget : rpeTarget // ignore: cast_nullable_to_non_nullable
as int?,rirTarget: freezed == rirTarget ? _self.rirTarget : rirTarget // ignore: cast_nullable_to_non_nullable
as int?,warmupSets: freezed == warmupSets ? _self.warmupSets : warmupSets // ignore: cast_nullable_to_non_nullable
as int?,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as WorkoutMode,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,supersetGroupId: freezed == supersetGroupId ? _self.supersetGroupId : supersetGroupId // ignore: cast_nullable_to_non_nullable
as String?,supersetPosition: freezed == supersetPosition ? _self.supersetPosition : supersetPosition // ignore: cast_nullable_to_non_nullable
as int?,isWarmup: null == isWarmup ? _self.isWarmup : isWarmup // ignore: cast_nullable_to_non_nullable
as bool,routineExerciseId: freezed == routineExerciseId ? _self.routineExerciseId : routineExerciseId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RoutineExerciseConfig].
extension RoutineExerciseConfigPatterns on RoutineExerciseConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutineExerciseConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutineExerciseConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutineExerciseConfig value)  $default,){
final _that = this;
switch (_that) {
case _RoutineExerciseConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutineExerciseConfig value)?  $default,){
final _that = this;
switch (_that) {
case _RoutineExerciseConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String exerciseId,  int orderIndex,  int sets,  int reps,  int? repsMin,  double weightKg,  int? durationSeconds,  int? restSeconds,  int? rpeTarget,  int? rirTarget,  int? warmupSets,  WorkoutMode mode,  String? notes,  String? supersetGroupId,  int? supersetPosition,  bool isWarmup,  String? routineExerciseId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutineExerciseConfig() when $default != null:
return $default(_that.exerciseId,_that.orderIndex,_that.sets,_that.reps,_that.repsMin,_that.weightKg,_that.durationSeconds,_that.restSeconds,_that.rpeTarget,_that.rirTarget,_that.warmupSets,_that.mode,_that.notes,_that.supersetGroupId,_that.supersetPosition,_that.isWarmup,_that.routineExerciseId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String exerciseId,  int orderIndex,  int sets,  int reps,  int? repsMin,  double weightKg,  int? durationSeconds,  int? restSeconds,  int? rpeTarget,  int? rirTarget,  int? warmupSets,  WorkoutMode mode,  String? notes,  String? supersetGroupId,  int? supersetPosition,  bool isWarmup,  String? routineExerciseId)  $default,) {final _that = this;
switch (_that) {
case _RoutineExerciseConfig():
return $default(_that.exerciseId,_that.orderIndex,_that.sets,_that.reps,_that.repsMin,_that.weightKg,_that.durationSeconds,_that.restSeconds,_that.rpeTarget,_that.rirTarget,_that.warmupSets,_that.mode,_that.notes,_that.supersetGroupId,_that.supersetPosition,_that.isWarmup,_that.routineExerciseId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String exerciseId,  int orderIndex,  int sets,  int reps,  int? repsMin,  double weightKg,  int? durationSeconds,  int? restSeconds,  int? rpeTarget,  int? rirTarget,  int? warmupSets,  WorkoutMode mode,  String? notes,  String? supersetGroupId,  int? supersetPosition,  bool isWarmup,  String? routineExerciseId)?  $default,) {final _that = this;
switch (_that) {
case _RoutineExerciseConfig() when $default != null:
return $default(_that.exerciseId,_that.orderIndex,_that.sets,_that.reps,_that.repsMin,_that.weightKg,_that.durationSeconds,_that.restSeconds,_that.rpeTarget,_that.rirTarget,_that.warmupSets,_that.mode,_that.notes,_that.supersetGroupId,_that.supersetPosition,_that.isWarmup,_that.routineExerciseId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoutineExerciseConfig implements RoutineExerciseConfig {
  const _RoutineExerciseConfig({required this.exerciseId, required this.orderIndex, required this.sets, required this.reps, this.repsMin, required this.weightKg, this.durationSeconds, this.restSeconds, this.rpeTarget, this.rirTarget, this.warmupSets, required this.mode, this.notes, this.supersetGroupId, this.supersetPosition, this.isWarmup = false, this.routineExerciseId});
  factory _RoutineExerciseConfig.fromJson(Map<String, dynamic> json) => _$RoutineExerciseConfigFromJson(json);

@override final  String exerciseId;
@override final  int orderIndex;
@override final  int sets;
@override final  int reps;
@override final  int? repsMin;
@override final  double weightKg;
@override final  int? durationSeconds;
@override final  int? restSeconds;
@override final  int? rpeTarget;
@override final  int? rirTarget;
@override final  int? warmupSets;
@override final  WorkoutMode mode;
@override final  String? notes;
@override final  String? supersetGroupId;
@override final  int? supersetPosition;
@override@JsonKey() final  bool isWarmup;
@override final  String? routineExerciseId;

/// Create a copy of RoutineExerciseConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutineExerciseConfigCopyWith<_RoutineExerciseConfig> get copyWith => __$RoutineExerciseConfigCopyWithImpl<_RoutineExerciseConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoutineExerciseConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutineExerciseConfig&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.repsMin, repsMin) || other.repsMin == repsMin)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.rpeTarget, rpeTarget) || other.rpeTarget == rpeTarget)&&(identical(other.rirTarget, rirTarget) || other.rirTarget == rirTarget)&&(identical(other.warmupSets, warmupSets) || other.warmupSets == warmupSets)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.supersetGroupId, supersetGroupId) || other.supersetGroupId == supersetGroupId)&&(identical(other.supersetPosition, supersetPosition) || other.supersetPosition == supersetPosition)&&(identical(other.isWarmup, isWarmup) || other.isWarmup == isWarmup)&&(identical(other.routineExerciseId, routineExerciseId) || other.routineExerciseId == routineExerciseId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseId,orderIndex,sets,reps,repsMin,weightKg,durationSeconds,restSeconds,rpeTarget,rirTarget,warmupSets,mode,notes,supersetGroupId,supersetPosition,isWarmup,routineExerciseId);

@override
String toString() {
  return 'RoutineExerciseConfig(exerciseId: $exerciseId, orderIndex: $orderIndex, sets: $sets, reps: $reps, repsMin: $repsMin, weightKg: $weightKg, durationSeconds: $durationSeconds, restSeconds: $restSeconds, rpeTarget: $rpeTarget, rirTarget: $rirTarget, warmupSets: $warmupSets, mode: $mode, notes: $notes, supersetGroupId: $supersetGroupId, supersetPosition: $supersetPosition, isWarmup: $isWarmup, routineExerciseId: $routineExerciseId)';
}


}

/// @nodoc
abstract mixin class _$RoutineExerciseConfigCopyWith<$Res> implements $RoutineExerciseConfigCopyWith<$Res> {
  factory _$RoutineExerciseConfigCopyWith(_RoutineExerciseConfig value, $Res Function(_RoutineExerciseConfig) _then) = __$RoutineExerciseConfigCopyWithImpl;
@override @useResult
$Res call({
 String exerciseId, int orderIndex, int sets, int reps, int? repsMin, double weightKg, int? durationSeconds, int? restSeconds, int? rpeTarget, int? rirTarget, int? warmupSets, WorkoutMode mode, String? notes, String? supersetGroupId, int? supersetPosition, bool isWarmup, String? routineExerciseId
});




}
/// @nodoc
class __$RoutineExerciseConfigCopyWithImpl<$Res>
    implements _$RoutineExerciseConfigCopyWith<$Res> {
  __$RoutineExerciseConfigCopyWithImpl(this._self, this._then);

  final _RoutineExerciseConfig _self;
  final $Res Function(_RoutineExerciseConfig) _then;

/// Create a copy of RoutineExerciseConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseId = null,Object? orderIndex = null,Object? sets = null,Object? reps = null,Object? repsMin = freezed,Object? weightKg = null,Object? durationSeconds = freezed,Object? restSeconds = freezed,Object? rpeTarget = freezed,Object? rirTarget = freezed,Object? warmupSets = freezed,Object? mode = null,Object? notes = freezed,Object? supersetGroupId = freezed,Object? supersetPosition = freezed,Object? isWarmup = null,Object? routineExerciseId = freezed,}) {
  return _then(_RoutineExerciseConfig(
exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,repsMin: freezed == repsMin ? _self.repsMin : repsMin // ignore: cast_nullable_to_non_nullable
as int?,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,restSeconds: freezed == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int?,rpeTarget: freezed == rpeTarget ? _self.rpeTarget : rpeTarget // ignore: cast_nullable_to_non_nullable
as int?,rirTarget: freezed == rirTarget ? _self.rirTarget : rirTarget // ignore: cast_nullable_to_non_nullable
as int?,warmupSets: freezed == warmupSets ? _self.warmupSets : warmupSets // ignore: cast_nullable_to_non_nullable
as int?,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as WorkoutMode,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,supersetGroupId: freezed == supersetGroupId ? _self.supersetGroupId : supersetGroupId // ignore: cast_nullable_to_non_nullable
as String?,supersetPosition: freezed == supersetPosition ? _self.supersetPosition : supersetPosition // ignore: cast_nullable_to_non_nullable
as int?,isWarmup: null == isWarmup ? _self.isWarmup : isWarmup // ignore: cast_nullable_to_non_nullable
as bool,routineExerciseId: freezed == routineExerciseId ? _self.routineExerciseId : routineExerciseId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

RoutineScheduleModel _$RoutineScheduleModelFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'fixedWeek':
          return FixedWeekScheduleModel.fromJson(
            json
          );
                case 'rotation':
          return RotationScheduleModel.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'RoutineScheduleModel',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$RoutineScheduleModel {

 String get id; String get routineId;
/// Create a copy of RoutineScheduleModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutineScheduleModelCopyWith<RoutineScheduleModel> get copyWith => _$RoutineScheduleModelCopyWithImpl<RoutineScheduleModel>(this as RoutineScheduleModel, _$identity);

  /// Serializes this RoutineScheduleModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutineScheduleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.routineId, routineId) || other.routineId == routineId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,routineId);

@override
String toString() {
  return 'RoutineScheduleModel(id: $id, routineId: $routineId)';
}


}

/// @nodoc
abstract mixin class $RoutineScheduleModelCopyWith<$Res>  {
  factory $RoutineScheduleModelCopyWith(RoutineScheduleModel value, $Res Function(RoutineScheduleModel) _then) = _$RoutineScheduleModelCopyWithImpl;
@useResult
$Res call({
 String id, String routineId
});




}
/// @nodoc
class _$RoutineScheduleModelCopyWithImpl<$Res>
    implements $RoutineScheduleModelCopyWith<$Res> {
  _$RoutineScheduleModelCopyWithImpl(this._self, this._then);

  final RoutineScheduleModel _self;
  final $Res Function(RoutineScheduleModel) _then;

/// Create a copy of RoutineScheduleModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? routineId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RoutineScheduleModel].
extension RoutineScheduleModelPatterns on RoutineScheduleModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( FixedWeekScheduleModel value)?  fixedWeek,TResult Function( RotationScheduleModel value)?  rotation,required TResult orElse(),}){
final _that = this;
switch (_that) {
case FixedWeekScheduleModel() when fixedWeek != null:
return fixedWeek(_that);case RotationScheduleModel() when rotation != null:
return rotation(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( FixedWeekScheduleModel value)  fixedWeek,required TResult Function( RotationScheduleModel value)  rotation,}){
final _that = this;
switch (_that) {
case FixedWeekScheduleModel():
return fixedWeek(_that);case RotationScheduleModel():
return rotation(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( FixedWeekScheduleModel value)?  fixedWeek,TResult? Function( RotationScheduleModel value)?  rotation,}){
final _that = this;
switch (_that) {
case FixedWeekScheduleModel() when fixedWeek != null:
return fixedWeek(_that);case RotationScheduleModel() when rotation != null:
return rotation(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id,  String routineId,  int weekday)?  fixedWeek,TResult Function( String id,  String routineId,  int position,  String? supersetGroupId)?  rotation,required TResult orElse(),}) {final _that = this;
switch (_that) {
case FixedWeekScheduleModel() when fixedWeek != null:
return fixedWeek(_that.id,_that.routineId,_that.weekday);case RotationScheduleModel() when rotation != null:
return rotation(_that.id,_that.routineId,_that.position,_that.supersetGroupId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id,  String routineId,  int weekday)  fixedWeek,required TResult Function( String id,  String routineId,  int position,  String? supersetGroupId)  rotation,}) {final _that = this;
switch (_that) {
case FixedWeekScheduleModel():
return fixedWeek(_that.id,_that.routineId,_that.weekday);case RotationScheduleModel():
return rotation(_that.id,_that.routineId,_that.position,_that.supersetGroupId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id,  String routineId,  int weekday)?  fixedWeek,TResult? Function( String id,  String routineId,  int position,  String? supersetGroupId)?  rotation,}) {final _that = this;
switch (_that) {
case FixedWeekScheduleModel() when fixedWeek != null:
return fixedWeek(_that.id,_that.routineId,_that.weekday);case RotationScheduleModel() when rotation != null:
return rotation(_that.id,_that.routineId,_that.position,_that.supersetGroupId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class FixedWeekScheduleModel implements RoutineScheduleModel {
  const FixedWeekScheduleModel({required this.id, required this.routineId, required this.weekday, final  String? $type}): $type = $type ?? 'fixedWeek';
  factory FixedWeekScheduleModel.fromJson(Map<String, dynamic> json) => _$FixedWeekScheduleModelFromJson(json);

@override final  String id;
@override final  String routineId;
 final  int weekday;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of RoutineScheduleModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FixedWeekScheduleModelCopyWith<FixedWeekScheduleModel> get copyWith => _$FixedWeekScheduleModelCopyWithImpl<FixedWeekScheduleModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FixedWeekScheduleModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FixedWeekScheduleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.weekday, weekday) || other.weekday == weekday));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,routineId,weekday);

@override
String toString() {
  return 'RoutineScheduleModel.fixedWeek(id: $id, routineId: $routineId, weekday: $weekday)';
}


}

/// @nodoc
abstract mixin class $FixedWeekScheduleModelCopyWith<$Res> implements $RoutineScheduleModelCopyWith<$Res> {
  factory $FixedWeekScheduleModelCopyWith(FixedWeekScheduleModel value, $Res Function(FixedWeekScheduleModel) _then) = _$FixedWeekScheduleModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String routineId, int weekday
});




}
/// @nodoc
class _$FixedWeekScheduleModelCopyWithImpl<$Res>
    implements $FixedWeekScheduleModelCopyWith<$Res> {
  _$FixedWeekScheduleModelCopyWithImpl(this._self, this._then);

  final FixedWeekScheduleModel _self;
  final $Res Function(FixedWeekScheduleModel) _then;

/// Create a copy of RoutineScheduleModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? routineId = null,Object? weekday = null,}) {
  return _then(FixedWeekScheduleModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,weekday: null == weekday ? _self.weekday : weekday // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class RotationScheduleModel implements RoutineScheduleModel {
  const RotationScheduleModel({required this.id, required this.routineId, required this.position, this.supersetGroupId, final  String? $type}): $type = $type ?? 'rotation';
  factory RotationScheduleModel.fromJson(Map<String, dynamic> json) => _$RotationScheduleModelFromJson(json);

@override final  String id;
@override final  String routineId;
 final  int position;
 final  String? supersetGroupId;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of RoutineScheduleModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RotationScheduleModelCopyWith<RotationScheduleModel> get copyWith => _$RotationScheduleModelCopyWithImpl<RotationScheduleModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RotationScheduleModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RotationScheduleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.position, position) || other.position == position)&&(identical(other.supersetGroupId, supersetGroupId) || other.supersetGroupId == supersetGroupId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,routineId,position,supersetGroupId);

@override
String toString() {
  return 'RoutineScheduleModel.rotation(id: $id, routineId: $routineId, position: $position, supersetGroupId: $supersetGroupId)';
}


}

/// @nodoc
abstract mixin class $RotationScheduleModelCopyWith<$Res> implements $RoutineScheduleModelCopyWith<$Res> {
  factory $RotationScheduleModelCopyWith(RotationScheduleModel value, $Res Function(RotationScheduleModel) _then) = _$RotationScheduleModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String routineId, int position, String? supersetGroupId
});




}
/// @nodoc
class _$RotationScheduleModelCopyWithImpl<$Res>
    implements $RotationScheduleModelCopyWith<$Res> {
  _$RotationScheduleModelCopyWithImpl(this._self, this._then);

  final RotationScheduleModel _self;
  final $Res Function(RotationScheduleModel) _then;

/// Create a copy of RoutineScheduleModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? routineId = null,Object? position = null,Object? supersetGroupId = freezed,}) {
  return _then(RotationScheduleModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,supersetGroupId: freezed == supersetGroupId ? _self.supersetGroupId : supersetGroupId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PlannedWorkoutModel {

 String get id; String get userId; String get routineId; String get routineName; Map<String, dynamic> get routineSnapshot; DateTime get scheduledDate; PlannedWorkoutStatus get status; String? get workoutId; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of PlannedWorkoutModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlannedWorkoutModelCopyWith<PlannedWorkoutModel> get copyWith => _$PlannedWorkoutModelCopyWithImpl<PlannedWorkoutModel>(this as PlannedWorkoutModel, _$identity);

  /// Serializes this PlannedWorkoutModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlannedWorkoutModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.routineName, routineName) || other.routineName == routineName)&&const DeepCollectionEquality().equals(other.routineSnapshot, routineSnapshot)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,routineId,routineName,const DeepCollectionEquality().hash(routineSnapshot),scheduledDate,status,workoutId,createdAt,updatedAt);

@override
String toString() {
  return 'PlannedWorkoutModel(id: $id, userId: $userId, routineId: $routineId, routineName: $routineName, routineSnapshot: $routineSnapshot, scheduledDate: $scheduledDate, status: $status, workoutId: $workoutId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PlannedWorkoutModelCopyWith<$Res>  {
  factory $PlannedWorkoutModelCopyWith(PlannedWorkoutModel value, $Res Function(PlannedWorkoutModel) _then) = _$PlannedWorkoutModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String routineId, String routineName, Map<String, dynamic> routineSnapshot, DateTime scheduledDate, PlannedWorkoutStatus status, String? workoutId, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$PlannedWorkoutModelCopyWithImpl<$Res>
    implements $PlannedWorkoutModelCopyWith<$Res> {
  _$PlannedWorkoutModelCopyWithImpl(this._self, this._then);

  final PlannedWorkoutModel _self;
  final $Res Function(PlannedWorkoutModel) _then;

/// Create a copy of PlannedWorkoutModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? routineId = null,Object? routineName = null,Object? routineSnapshot = null,Object? scheduledDate = null,Object? status = null,Object? workoutId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,routineName: null == routineName ? _self.routineName : routineName // ignore: cast_nullable_to_non_nullable
as String,routineSnapshot: null == routineSnapshot ? _self.routineSnapshot : routineSnapshot // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,scheduledDate: null == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PlannedWorkoutStatus,workoutId: freezed == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlannedWorkoutModel].
extension PlannedWorkoutModelPatterns on PlannedWorkoutModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlannedWorkoutModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlannedWorkoutModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlannedWorkoutModel value)  $default,){
final _that = this;
switch (_that) {
case _PlannedWorkoutModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlannedWorkoutModel value)?  $default,){
final _that = this;
switch (_that) {
case _PlannedWorkoutModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String routineId,  String routineName,  Map<String, dynamic> routineSnapshot,  DateTime scheduledDate,  PlannedWorkoutStatus status,  String? workoutId,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlannedWorkoutModel() when $default != null:
return $default(_that.id,_that.userId,_that.routineId,_that.routineName,_that.routineSnapshot,_that.scheduledDate,_that.status,_that.workoutId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String routineId,  String routineName,  Map<String, dynamic> routineSnapshot,  DateTime scheduledDate,  PlannedWorkoutStatus status,  String? workoutId,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PlannedWorkoutModel():
return $default(_that.id,_that.userId,_that.routineId,_that.routineName,_that.routineSnapshot,_that.scheduledDate,_that.status,_that.workoutId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String routineId,  String routineName,  Map<String, dynamic> routineSnapshot,  DateTime scheduledDate,  PlannedWorkoutStatus status,  String? workoutId,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PlannedWorkoutModel() when $default != null:
return $default(_that.id,_that.userId,_that.routineId,_that.routineName,_that.routineSnapshot,_that.scheduledDate,_that.status,_that.workoutId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlannedWorkoutModel implements PlannedWorkoutModel {
  const _PlannedWorkoutModel({required this.id, required this.userId, required this.routineId, required this.routineName, required final  Map<String, dynamic> routineSnapshot, required this.scheduledDate, this.status = PlannedWorkoutStatus.planned, this.workoutId, this.createdAt, this.updatedAt}): _routineSnapshot = routineSnapshot;
  factory _PlannedWorkoutModel.fromJson(Map<String, dynamic> json) => _$PlannedWorkoutModelFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String routineId;
@override final  String routineName;
 final  Map<String, dynamic> _routineSnapshot;
@override Map<String, dynamic> get routineSnapshot {
  if (_routineSnapshot is EqualUnmodifiableMapView) return _routineSnapshot;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_routineSnapshot);
}

@override final  DateTime scheduledDate;
@override@JsonKey() final  PlannedWorkoutStatus status;
@override final  String? workoutId;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of PlannedWorkoutModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlannedWorkoutModelCopyWith<_PlannedWorkoutModel> get copyWith => __$PlannedWorkoutModelCopyWithImpl<_PlannedWorkoutModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlannedWorkoutModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlannedWorkoutModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.routineName, routineName) || other.routineName == routineName)&&const DeepCollectionEquality().equals(other._routineSnapshot, _routineSnapshot)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,routineId,routineName,const DeepCollectionEquality().hash(_routineSnapshot),scheduledDate,status,workoutId,createdAt,updatedAt);

@override
String toString() {
  return 'PlannedWorkoutModel(id: $id, userId: $userId, routineId: $routineId, routineName: $routineName, routineSnapshot: $routineSnapshot, scheduledDate: $scheduledDate, status: $status, workoutId: $workoutId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PlannedWorkoutModelCopyWith<$Res> implements $PlannedWorkoutModelCopyWith<$Res> {
  factory _$PlannedWorkoutModelCopyWith(_PlannedWorkoutModel value, $Res Function(_PlannedWorkoutModel) _then) = __$PlannedWorkoutModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String routineId, String routineName, Map<String, dynamic> routineSnapshot, DateTime scheduledDate, PlannedWorkoutStatus status, String? workoutId, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$PlannedWorkoutModelCopyWithImpl<$Res>
    implements _$PlannedWorkoutModelCopyWith<$Res> {
  __$PlannedWorkoutModelCopyWithImpl(this._self, this._then);

  final _PlannedWorkoutModel _self;
  final $Res Function(_PlannedWorkoutModel) _then;

/// Create a copy of PlannedWorkoutModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? routineId = null,Object? routineName = null,Object? routineSnapshot = null,Object? scheduledDate = null,Object? status = null,Object? workoutId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_PlannedWorkoutModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,routineName: null == routineName ? _self.routineName : routineName // ignore: cast_nullable_to_non_nullable
as String,routineSnapshot: null == routineSnapshot ? _self._routineSnapshot : routineSnapshot // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,scheduledDate: null == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PlannedWorkoutStatus,workoutId: freezed == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$DuplicateRoutineConfig {

 String get routineId; String get newName; String get emoji;
/// Create a copy of DuplicateRoutineConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DuplicateRoutineConfigCopyWith<DuplicateRoutineConfig> get copyWith => _$DuplicateRoutineConfigCopyWithImpl<DuplicateRoutineConfig>(this as DuplicateRoutineConfig, _$identity);

  /// Serializes this DuplicateRoutineConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DuplicateRoutineConfig&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.newName, newName) || other.newName == newName)&&(identical(other.emoji, emoji) || other.emoji == emoji));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,routineId,newName,emoji);

@override
String toString() {
  return 'DuplicateRoutineConfig(routineId: $routineId, newName: $newName, emoji: $emoji)';
}


}

/// @nodoc
abstract mixin class $DuplicateRoutineConfigCopyWith<$Res>  {
  factory $DuplicateRoutineConfigCopyWith(DuplicateRoutineConfig value, $Res Function(DuplicateRoutineConfig) _then) = _$DuplicateRoutineConfigCopyWithImpl;
@useResult
$Res call({
 String routineId, String newName, String emoji
});




}
/// @nodoc
class _$DuplicateRoutineConfigCopyWithImpl<$Res>
    implements $DuplicateRoutineConfigCopyWith<$Res> {
  _$DuplicateRoutineConfigCopyWithImpl(this._self, this._then);

  final DuplicateRoutineConfig _self;
  final $Res Function(DuplicateRoutineConfig) _then;

/// Create a copy of DuplicateRoutineConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? routineId = null,Object? newName = null,Object? emoji = null,}) {
  return _then(_self.copyWith(
routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,newName: null == newName ? _self.newName : newName // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DuplicateRoutineConfig].
extension DuplicateRoutineConfigPatterns on DuplicateRoutineConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DuplicateRoutineConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DuplicateRoutineConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DuplicateRoutineConfig value)  $default,){
final _that = this;
switch (_that) {
case _DuplicateRoutineConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DuplicateRoutineConfig value)?  $default,){
final _that = this;
switch (_that) {
case _DuplicateRoutineConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String routineId,  String newName,  String emoji)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DuplicateRoutineConfig() when $default != null:
return $default(_that.routineId,_that.newName,_that.emoji);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String routineId,  String newName,  String emoji)  $default,) {final _that = this;
switch (_that) {
case _DuplicateRoutineConfig():
return $default(_that.routineId,_that.newName,_that.emoji);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String routineId,  String newName,  String emoji)?  $default,) {final _that = this;
switch (_that) {
case _DuplicateRoutineConfig() when $default != null:
return $default(_that.routineId,_that.newName,_that.emoji);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DuplicateRoutineConfig implements DuplicateRoutineConfig {
  const _DuplicateRoutineConfig({required this.routineId, required this.newName, this.emoji = '🔁'});
  factory _DuplicateRoutineConfig.fromJson(Map<String, dynamic> json) => _$DuplicateRoutineConfigFromJson(json);

@override final  String routineId;
@override final  String newName;
@override@JsonKey() final  String emoji;

/// Create a copy of DuplicateRoutineConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DuplicateRoutineConfigCopyWith<_DuplicateRoutineConfig> get copyWith => __$DuplicateRoutineConfigCopyWithImpl<_DuplicateRoutineConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DuplicateRoutineConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DuplicateRoutineConfig&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.newName, newName) || other.newName == newName)&&(identical(other.emoji, emoji) || other.emoji == emoji));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,routineId,newName,emoji);

@override
String toString() {
  return 'DuplicateRoutineConfig(routineId: $routineId, newName: $newName, emoji: $emoji)';
}


}

/// @nodoc
abstract mixin class _$DuplicateRoutineConfigCopyWith<$Res> implements $DuplicateRoutineConfigCopyWith<$Res> {
  factory _$DuplicateRoutineConfigCopyWith(_DuplicateRoutineConfig value, $Res Function(_DuplicateRoutineConfig) _then) = __$DuplicateRoutineConfigCopyWithImpl;
@override @useResult
$Res call({
 String routineId, String newName, String emoji
});




}
/// @nodoc
class __$DuplicateRoutineConfigCopyWithImpl<$Res>
    implements _$DuplicateRoutineConfigCopyWith<$Res> {
  __$DuplicateRoutineConfigCopyWithImpl(this._self, this._then);

  final _DuplicateRoutineConfig _self;
  final $Res Function(_DuplicateRoutineConfig) _then;

/// Create a copy of DuplicateRoutineConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? routineId = null,Object? newName = null,Object? emoji = null,}) {
  return _then(_DuplicateRoutineConfig(
routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,newName: null == newName ? _self.newName : newName // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ReplaceExerciseConfig {

 String get routineId; String get routineExerciseId; String get newExerciseId; Map<String, dynamic>? get config;
/// Create a copy of ReplaceExerciseConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReplaceExerciseConfigCopyWith<ReplaceExerciseConfig> get copyWith => _$ReplaceExerciseConfigCopyWithImpl<ReplaceExerciseConfig>(this as ReplaceExerciseConfig, _$identity);

  /// Serializes this ReplaceExerciseConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReplaceExerciseConfig&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.routineExerciseId, routineExerciseId) || other.routineExerciseId == routineExerciseId)&&(identical(other.newExerciseId, newExerciseId) || other.newExerciseId == newExerciseId)&&const DeepCollectionEquality().equals(other.config, config));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,routineId,routineExerciseId,newExerciseId,const DeepCollectionEquality().hash(config));

@override
String toString() {
  return 'ReplaceExerciseConfig(routineId: $routineId, routineExerciseId: $routineExerciseId, newExerciseId: $newExerciseId, config: $config)';
}


}

/// @nodoc
abstract mixin class $ReplaceExerciseConfigCopyWith<$Res>  {
  factory $ReplaceExerciseConfigCopyWith(ReplaceExerciseConfig value, $Res Function(ReplaceExerciseConfig) _then) = _$ReplaceExerciseConfigCopyWithImpl;
@useResult
$Res call({
 String routineId, String routineExerciseId, String newExerciseId, Map<String, dynamic>? config
});




}
/// @nodoc
class _$ReplaceExerciseConfigCopyWithImpl<$Res>
    implements $ReplaceExerciseConfigCopyWith<$Res> {
  _$ReplaceExerciseConfigCopyWithImpl(this._self, this._then);

  final ReplaceExerciseConfig _self;
  final $Res Function(ReplaceExerciseConfig) _then;

/// Create a copy of ReplaceExerciseConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? routineId = null,Object? routineExerciseId = null,Object? newExerciseId = null,Object? config = freezed,}) {
  return _then(_self.copyWith(
routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,routineExerciseId: null == routineExerciseId ? _self.routineExerciseId : routineExerciseId // ignore: cast_nullable_to_non_nullable
as String,newExerciseId: null == newExerciseId ? _self.newExerciseId : newExerciseId // ignore: cast_nullable_to_non_nullable
as String,config: freezed == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReplaceExerciseConfig].
extension ReplaceExerciseConfigPatterns on ReplaceExerciseConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReplaceExerciseConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReplaceExerciseConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReplaceExerciseConfig value)  $default,){
final _that = this;
switch (_that) {
case _ReplaceExerciseConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReplaceExerciseConfig value)?  $default,){
final _that = this;
switch (_that) {
case _ReplaceExerciseConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String routineId,  String routineExerciseId,  String newExerciseId,  Map<String, dynamic>? config)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReplaceExerciseConfig() when $default != null:
return $default(_that.routineId,_that.routineExerciseId,_that.newExerciseId,_that.config);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String routineId,  String routineExerciseId,  String newExerciseId,  Map<String, dynamic>? config)  $default,) {final _that = this;
switch (_that) {
case _ReplaceExerciseConfig():
return $default(_that.routineId,_that.routineExerciseId,_that.newExerciseId,_that.config);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String routineId,  String routineExerciseId,  String newExerciseId,  Map<String, dynamic>? config)?  $default,) {final _that = this;
switch (_that) {
case _ReplaceExerciseConfig() when $default != null:
return $default(_that.routineId,_that.routineExerciseId,_that.newExerciseId,_that.config);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReplaceExerciseConfig implements ReplaceExerciseConfig {
  const _ReplaceExerciseConfig({required this.routineId, required this.routineExerciseId, required this.newExerciseId, final  Map<String, dynamic>? config}): _config = config;
  factory _ReplaceExerciseConfig.fromJson(Map<String, dynamic> json) => _$ReplaceExerciseConfigFromJson(json);

@override final  String routineId;
@override final  String routineExerciseId;
@override final  String newExerciseId;
 final  Map<String, dynamic>? _config;
@override Map<String, dynamic>? get config {
  final value = _config;
  if (value == null) return null;
  if (_config is EqualUnmodifiableMapView) return _config;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of ReplaceExerciseConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReplaceExerciseConfigCopyWith<_ReplaceExerciseConfig> get copyWith => __$ReplaceExerciseConfigCopyWithImpl<_ReplaceExerciseConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReplaceExerciseConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReplaceExerciseConfig&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.routineExerciseId, routineExerciseId) || other.routineExerciseId == routineExerciseId)&&(identical(other.newExerciseId, newExerciseId) || other.newExerciseId == newExerciseId)&&const DeepCollectionEquality().equals(other._config, _config));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,routineId,routineExerciseId,newExerciseId,const DeepCollectionEquality().hash(_config));

@override
String toString() {
  return 'ReplaceExerciseConfig(routineId: $routineId, routineExerciseId: $routineExerciseId, newExerciseId: $newExerciseId, config: $config)';
}


}

/// @nodoc
abstract mixin class _$ReplaceExerciseConfigCopyWith<$Res> implements $ReplaceExerciseConfigCopyWith<$Res> {
  factory _$ReplaceExerciseConfigCopyWith(_ReplaceExerciseConfig value, $Res Function(_ReplaceExerciseConfig) _then) = __$ReplaceExerciseConfigCopyWithImpl;
@override @useResult
$Res call({
 String routineId, String routineExerciseId, String newExerciseId, Map<String, dynamic>? config
});




}
/// @nodoc
class __$ReplaceExerciseConfigCopyWithImpl<$Res>
    implements _$ReplaceExerciseConfigCopyWith<$Res> {
  __$ReplaceExerciseConfigCopyWithImpl(this._self, this._then);

  final _ReplaceExerciseConfig _self;
  final $Res Function(_ReplaceExerciseConfig) _then;

/// Create a copy of ReplaceExerciseConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? routineId = null,Object? routineExerciseId = null,Object? newExerciseId = null,Object? config = freezed,}) {
  return _then(_ReplaceExerciseConfig(
routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,routineExerciseId: null == routineExerciseId ? _self.routineExerciseId : routineExerciseId // ignore: cast_nullable_to_non_nullable
as String,newExerciseId: null == newExerciseId ? _self.newExerciseId : newExerciseId // ignore: cast_nullable_to_non_nullable
as String,config: freezed == config ? _self._config : config // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

ScheduleRoutineConfig _$ScheduleRoutineConfigFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'fixedWeek':
          return ScheduleFixedWeekConfig.fromJson(
            json
          );
                case 'rotation':
          return ScheduleRotationConfig.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'ScheduleRoutineConfig',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$ScheduleRoutineConfig {

 String get routineId;
/// Create a copy of ScheduleRoutineConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleRoutineConfigCopyWith<ScheduleRoutineConfig> get copyWith => _$ScheduleRoutineConfigCopyWithImpl<ScheduleRoutineConfig>(this as ScheduleRoutineConfig, _$identity);

  /// Serializes this ScheduleRoutineConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleRoutineConfig&&(identical(other.routineId, routineId) || other.routineId == routineId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,routineId);

@override
String toString() {
  return 'ScheduleRoutineConfig(routineId: $routineId)';
}


}

/// @nodoc
abstract mixin class $ScheduleRoutineConfigCopyWith<$Res>  {
  factory $ScheduleRoutineConfigCopyWith(ScheduleRoutineConfig value, $Res Function(ScheduleRoutineConfig) _then) = _$ScheduleRoutineConfigCopyWithImpl;
@useResult
$Res call({
 String routineId
});




}
/// @nodoc
class _$ScheduleRoutineConfigCopyWithImpl<$Res>
    implements $ScheduleRoutineConfigCopyWith<$Res> {
  _$ScheduleRoutineConfigCopyWithImpl(this._self, this._then);

  final ScheduleRoutineConfig _self;
  final $Res Function(ScheduleRoutineConfig) _then;

/// Create a copy of ScheduleRoutineConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? routineId = null,}) {
  return _then(_self.copyWith(
routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ScheduleRoutineConfig].
extension ScheduleRoutineConfigPatterns on ScheduleRoutineConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ScheduleFixedWeekConfig value)?  fixedWeek,TResult Function( ScheduleRotationConfig value)?  rotation,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ScheduleFixedWeekConfig() when fixedWeek != null:
return fixedWeek(_that);case ScheduleRotationConfig() when rotation != null:
return rotation(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ScheduleFixedWeekConfig value)  fixedWeek,required TResult Function( ScheduleRotationConfig value)  rotation,}){
final _that = this;
switch (_that) {
case ScheduleFixedWeekConfig():
return fixedWeek(_that);case ScheduleRotationConfig():
return rotation(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ScheduleFixedWeekConfig value)?  fixedWeek,TResult? Function( ScheduleRotationConfig value)?  rotation,}){
final _that = this;
switch (_that) {
case ScheduleFixedWeekConfig() when fixedWeek != null:
return fixedWeek(_that);case ScheduleRotationConfig() when rotation != null:
return rotation(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String routineId,  int weekday)?  fixedWeek,TResult Function( String routineId,  int position,  String? supersetGroupId)?  rotation,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ScheduleFixedWeekConfig() when fixedWeek != null:
return fixedWeek(_that.routineId,_that.weekday);case ScheduleRotationConfig() when rotation != null:
return rotation(_that.routineId,_that.position,_that.supersetGroupId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String routineId,  int weekday)  fixedWeek,required TResult Function( String routineId,  int position,  String? supersetGroupId)  rotation,}) {final _that = this;
switch (_that) {
case ScheduleFixedWeekConfig():
return fixedWeek(_that.routineId,_that.weekday);case ScheduleRotationConfig():
return rotation(_that.routineId,_that.position,_that.supersetGroupId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String routineId,  int weekday)?  fixedWeek,TResult? Function( String routineId,  int position,  String? supersetGroupId)?  rotation,}) {final _that = this;
switch (_that) {
case ScheduleFixedWeekConfig() when fixedWeek != null:
return fixedWeek(_that.routineId,_that.weekday);case ScheduleRotationConfig() when rotation != null:
return rotation(_that.routineId,_that.position,_that.supersetGroupId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class ScheduleFixedWeekConfig implements ScheduleRoutineConfig {
  const ScheduleFixedWeekConfig({required this.routineId, required this.weekday, final  String? $type}): $type = $type ?? 'fixedWeek';
  factory ScheduleFixedWeekConfig.fromJson(Map<String, dynamic> json) => _$ScheduleFixedWeekConfigFromJson(json);

@override final  String routineId;
 final  int weekday;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of ScheduleRoutineConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleFixedWeekConfigCopyWith<ScheduleFixedWeekConfig> get copyWith => _$ScheduleFixedWeekConfigCopyWithImpl<ScheduleFixedWeekConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduleFixedWeekConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleFixedWeekConfig&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.weekday, weekday) || other.weekday == weekday));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,routineId,weekday);

@override
String toString() {
  return 'ScheduleRoutineConfig.fixedWeek(routineId: $routineId, weekday: $weekday)';
}


}

/// @nodoc
abstract mixin class $ScheduleFixedWeekConfigCopyWith<$Res> implements $ScheduleRoutineConfigCopyWith<$Res> {
  factory $ScheduleFixedWeekConfigCopyWith(ScheduleFixedWeekConfig value, $Res Function(ScheduleFixedWeekConfig) _then) = _$ScheduleFixedWeekConfigCopyWithImpl;
@override @useResult
$Res call({
 String routineId, int weekday
});




}
/// @nodoc
class _$ScheduleFixedWeekConfigCopyWithImpl<$Res>
    implements $ScheduleFixedWeekConfigCopyWith<$Res> {
  _$ScheduleFixedWeekConfigCopyWithImpl(this._self, this._then);

  final ScheduleFixedWeekConfig _self;
  final $Res Function(ScheduleFixedWeekConfig) _then;

/// Create a copy of ScheduleRoutineConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? routineId = null,Object? weekday = null,}) {
  return _then(ScheduleFixedWeekConfig(
routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,weekday: null == weekday ? _self.weekday : weekday // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ScheduleRotationConfig implements ScheduleRoutineConfig {
  const ScheduleRotationConfig({required this.routineId, required this.position, this.supersetGroupId, final  String? $type}): $type = $type ?? 'rotation';
  factory ScheduleRotationConfig.fromJson(Map<String, dynamic> json) => _$ScheduleRotationConfigFromJson(json);

@override final  String routineId;
 final  int position;
 final  String? supersetGroupId;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of ScheduleRoutineConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleRotationConfigCopyWith<ScheduleRotationConfig> get copyWith => _$ScheduleRotationConfigCopyWithImpl<ScheduleRotationConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduleRotationConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleRotationConfig&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.position, position) || other.position == position)&&(identical(other.supersetGroupId, supersetGroupId) || other.supersetGroupId == supersetGroupId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,routineId,position,supersetGroupId);

@override
String toString() {
  return 'ScheduleRoutineConfig.rotation(routineId: $routineId, position: $position, supersetGroupId: $supersetGroupId)';
}


}

/// @nodoc
abstract mixin class $ScheduleRotationConfigCopyWith<$Res> implements $ScheduleRoutineConfigCopyWith<$Res> {
  factory $ScheduleRotationConfigCopyWith(ScheduleRotationConfig value, $Res Function(ScheduleRotationConfig) _then) = _$ScheduleRotationConfigCopyWithImpl;
@override @useResult
$Res call({
 String routineId, int position, String? supersetGroupId
});




}
/// @nodoc
class _$ScheduleRotationConfigCopyWithImpl<$Res>
    implements $ScheduleRotationConfigCopyWith<$Res> {
  _$ScheduleRotationConfigCopyWithImpl(this._self, this._then);

  final ScheduleRotationConfig _self;
  final $Res Function(ScheduleRotationConfig) _then;

/// Create a copy of ScheduleRoutineConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? routineId = null,Object? position = null,Object? supersetGroupId = freezed,}) {
  return _then(ScheduleRotationConfig(
routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,supersetGroupId: freezed == supersetGroupId ? _self.supersetGroupId : supersetGroupId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CreatePlannedWorkoutConfig {

 String get routineId; DateTime get scheduledDate;
/// Create a copy of CreatePlannedWorkoutConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatePlannedWorkoutConfigCopyWith<CreatePlannedWorkoutConfig> get copyWith => _$CreatePlannedWorkoutConfigCopyWithImpl<CreatePlannedWorkoutConfig>(this as CreatePlannedWorkoutConfig, _$identity);

  /// Serializes this CreatePlannedWorkoutConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatePlannedWorkoutConfig&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,routineId,scheduledDate);

@override
String toString() {
  return 'CreatePlannedWorkoutConfig(routineId: $routineId, scheduledDate: $scheduledDate)';
}


}

/// @nodoc
abstract mixin class $CreatePlannedWorkoutConfigCopyWith<$Res>  {
  factory $CreatePlannedWorkoutConfigCopyWith(CreatePlannedWorkoutConfig value, $Res Function(CreatePlannedWorkoutConfig) _then) = _$CreatePlannedWorkoutConfigCopyWithImpl;
@useResult
$Res call({
 String routineId, DateTime scheduledDate
});




}
/// @nodoc
class _$CreatePlannedWorkoutConfigCopyWithImpl<$Res>
    implements $CreatePlannedWorkoutConfigCopyWith<$Res> {
  _$CreatePlannedWorkoutConfigCopyWithImpl(this._self, this._then);

  final CreatePlannedWorkoutConfig _self;
  final $Res Function(CreatePlannedWorkoutConfig) _then;

/// Create a copy of CreatePlannedWorkoutConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? routineId = null,Object? scheduledDate = null,}) {
  return _then(_self.copyWith(
routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,scheduledDate: null == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CreatePlannedWorkoutConfig].
extension CreatePlannedWorkoutConfigPatterns on CreatePlannedWorkoutConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreatePlannedWorkoutConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreatePlannedWorkoutConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreatePlannedWorkoutConfig value)  $default,){
final _that = this;
switch (_that) {
case _CreatePlannedWorkoutConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreatePlannedWorkoutConfig value)?  $default,){
final _that = this;
switch (_that) {
case _CreatePlannedWorkoutConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String routineId,  DateTime scheduledDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreatePlannedWorkoutConfig() when $default != null:
return $default(_that.routineId,_that.scheduledDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String routineId,  DateTime scheduledDate)  $default,) {final _that = this;
switch (_that) {
case _CreatePlannedWorkoutConfig():
return $default(_that.routineId,_that.scheduledDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String routineId,  DateTime scheduledDate)?  $default,) {final _that = this;
switch (_that) {
case _CreatePlannedWorkoutConfig() when $default != null:
return $default(_that.routineId,_that.scheduledDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreatePlannedWorkoutConfig implements CreatePlannedWorkoutConfig {
  const _CreatePlannedWorkoutConfig({required this.routineId, required this.scheduledDate});
  factory _CreatePlannedWorkoutConfig.fromJson(Map<String, dynamic> json) => _$CreatePlannedWorkoutConfigFromJson(json);

@override final  String routineId;
@override final  DateTime scheduledDate;

/// Create a copy of CreatePlannedWorkoutConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatePlannedWorkoutConfigCopyWith<_CreatePlannedWorkoutConfig> get copyWith => __$CreatePlannedWorkoutConfigCopyWithImpl<_CreatePlannedWorkoutConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreatePlannedWorkoutConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatePlannedWorkoutConfig&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,routineId,scheduledDate);

@override
String toString() {
  return 'CreatePlannedWorkoutConfig(routineId: $routineId, scheduledDate: $scheduledDate)';
}


}

/// @nodoc
abstract mixin class _$CreatePlannedWorkoutConfigCopyWith<$Res> implements $CreatePlannedWorkoutConfigCopyWith<$Res> {
  factory _$CreatePlannedWorkoutConfigCopyWith(_CreatePlannedWorkoutConfig value, $Res Function(_CreatePlannedWorkoutConfig) _then) = __$CreatePlannedWorkoutConfigCopyWithImpl;
@override @useResult
$Res call({
 String routineId, DateTime scheduledDate
});




}
/// @nodoc
class __$CreatePlannedWorkoutConfigCopyWithImpl<$Res>
    implements _$CreatePlannedWorkoutConfigCopyWith<$Res> {
  __$CreatePlannedWorkoutConfigCopyWithImpl(this._self, this._then);

  final _CreatePlannedWorkoutConfig _self;
  final $Res Function(_CreatePlannedWorkoutConfig) _then;

/// Create a copy of CreatePlannedWorkoutConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? routineId = null,Object? scheduledDate = null,}) {
  return _then(_CreatePlannedWorkoutConfig(
routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,scheduledDate: null == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$StartPlannedWorkoutConfig {

 String get plannedWorkoutId;
/// Create a copy of StartPlannedWorkoutConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StartPlannedWorkoutConfigCopyWith<StartPlannedWorkoutConfig> get copyWith => _$StartPlannedWorkoutConfigCopyWithImpl<StartPlannedWorkoutConfig>(this as StartPlannedWorkoutConfig, _$identity);

  /// Serializes this StartPlannedWorkoutConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StartPlannedWorkoutConfig&&(identical(other.plannedWorkoutId, plannedWorkoutId) || other.plannedWorkoutId == plannedWorkoutId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,plannedWorkoutId);

@override
String toString() {
  return 'StartPlannedWorkoutConfig(plannedWorkoutId: $plannedWorkoutId)';
}


}

/// @nodoc
abstract mixin class $StartPlannedWorkoutConfigCopyWith<$Res>  {
  factory $StartPlannedWorkoutConfigCopyWith(StartPlannedWorkoutConfig value, $Res Function(StartPlannedWorkoutConfig) _then) = _$StartPlannedWorkoutConfigCopyWithImpl;
@useResult
$Res call({
 String plannedWorkoutId
});




}
/// @nodoc
class _$StartPlannedWorkoutConfigCopyWithImpl<$Res>
    implements $StartPlannedWorkoutConfigCopyWith<$Res> {
  _$StartPlannedWorkoutConfigCopyWithImpl(this._self, this._then);

  final StartPlannedWorkoutConfig _self;
  final $Res Function(StartPlannedWorkoutConfig) _then;

/// Create a copy of StartPlannedWorkoutConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? plannedWorkoutId = null,}) {
  return _then(_self.copyWith(
plannedWorkoutId: null == plannedWorkoutId ? _self.plannedWorkoutId : plannedWorkoutId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [StartPlannedWorkoutConfig].
extension StartPlannedWorkoutConfigPatterns on StartPlannedWorkoutConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StartPlannedWorkoutConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StartPlannedWorkoutConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StartPlannedWorkoutConfig value)  $default,){
final _that = this;
switch (_that) {
case _StartPlannedWorkoutConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StartPlannedWorkoutConfig value)?  $default,){
final _that = this;
switch (_that) {
case _StartPlannedWorkoutConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String plannedWorkoutId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StartPlannedWorkoutConfig() when $default != null:
return $default(_that.plannedWorkoutId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String plannedWorkoutId)  $default,) {final _that = this;
switch (_that) {
case _StartPlannedWorkoutConfig():
return $default(_that.plannedWorkoutId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String plannedWorkoutId)?  $default,) {final _that = this;
switch (_that) {
case _StartPlannedWorkoutConfig() when $default != null:
return $default(_that.plannedWorkoutId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StartPlannedWorkoutConfig implements StartPlannedWorkoutConfig {
  const _StartPlannedWorkoutConfig({required this.plannedWorkoutId});
  factory _StartPlannedWorkoutConfig.fromJson(Map<String, dynamic> json) => _$StartPlannedWorkoutConfigFromJson(json);

@override final  String plannedWorkoutId;

/// Create a copy of StartPlannedWorkoutConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StartPlannedWorkoutConfigCopyWith<_StartPlannedWorkoutConfig> get copyWith => __$StartPlannedWorkoutConfigCopyWithImpl<_StartPlannedWorkoutConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StartPlannedWorkoutConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StartPlannedWorkoutConfig&&(identical(other.plannedWorkoutId, plannedWorkoutId) || other.plannedWorkoutId == plannedWorkoutId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,plannedWorkoutId);

@override
String toString() {
  return 'StartPlannedWorkoutConfig(plannedWorkoutId: $plannedWorkoutId)';
}


}

/// @nodoc
abstract mixin class _$StartPlannedWorkoutConfigCopyWith<$Res> implements $StartPlannedWorkoutConfigCopyWith<$Res> {
  factory _$StartPlannedWorkoutConfigCopyWith(_StartPlannedWorkoutConfig value, $Res Function(_StartPlannedWorkoutConfig) _then) = __$StartPlannedWorkoutConfigCopyWithImpl;
@override @useResult
$Res call({
 String plannedWorkoutId
});




}
/// @nodoc
class __$StartPlannedWorkoutConfigCopyWithImpl<$Res>
    implements _$StartPlannedWorkoutConfigCopyWith<$Res> {
  __$StartPlannedWorkoutConfigCopyWithImpl(this._self, this._then);

  final _StartPlannedWorkoutConfig _self;
  final $Res Function(_StartPlannedWorkoutConfig) _then;

/// Create a copy of StartPlannedWorkoutConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? plannedWorkoutId = null,}) {
  return _then(_StartPlannedWorkoutConfig(
plannedWorkoutId: null == plannedWorkoutId ? _self.plannedWorkoutId : plannedWorkoutId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CompletePlannedWorkoutConfig {

 String get plannedWorkoutId; String get workoutId;
/// Create a copy of CompletePlannedWorkoutConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompletePlannedWorkoutConfigCopyWith<CompletePlannedWorkoutConfig> get copyWith => _$CompletePlannedWorkoutConfigCopyWithImpl<CompletePlannedWorkoutConfig>(this as CompletePlannedWorkoutConfig, _$identity);

  /// Serializes this CompletePlannedWorkoutConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompletePlannedWorkoutConfig&&(identical(other.plannedWorkoutId, plannedWorkoutId) || other.plannedWorkoutId == plannedWorkoutId)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,plannedWorkoutId,workoutId);

@override
String toString() {
  return 'CompletePlannedWorkoutConfig(plannedWorkoutId: $plannedWorkoutId, workoutId: $workoutId)';
}


}

/// @nodoc
abstract mixin class $CompletePlannedWorkoutConfigCopyWith<$Res>  {
  factory $CompletePlannedWorkoutConfigCopyWith(CompletePlannedWorkoutConfig value, $Res Function(CompletePlannedWorkoutConfig) _then) = _$CompletePlannedWorkoutConfigCopyWithImpl;
@useResult
$Res call({
 String plannedWorkoutId, String workoutId
});




}
/// @nodoc
class _$CompletePlannedWorkoutConfigCopyWithImpl<$Res>
    implements $CompletePlannedWorkoutConfigCopyWith<$Res> {
  _$CompletePlannedWorkoutConfigCopyWithImpl(this._self, this._then);

  final CompletePlannedWorkoutConfig _self;
  final $Res Function(CompletePlannedWorkoutConfig) _then;

/// Create a copy of CompletePlannedWorkoutConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? plannedWorkoutId = null,Object? workoutId = null,}) {
  return _then(_self.copyWith(
plannedWorkoutId: null == plannedWorkoutId ? _self.plannedWorkoutId : plannedWorkoutId // ignore: cast_nullable_to_non_nullable
as String,workoutId: null == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CompletePlannedWorkoutConfig].
extension CompletePlannedWorkoutConfigPatterns on CompletePlannedWorkoutConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompletePlannedWorkoutConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompletePlannedWorkoutConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompletePlannedWorkoutConfig value)  $default,){
final _that = this;
switch (_that) {
case _CompletePlannedWorkoutConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompletePlannedWorkoutConfig value)?  $default,){
final _that = this;
switch (_that) {
case _CompletePlannedWorkoutConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String plannedWorkoutId,  String workoutId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompletePlannedWorkoutConfig() when $default != null:
return $default(_that.plannedWorkoutId,_that.workoutId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String plannedWorkoutId,  String workoutId)  $default,) {final _that = this;
switch (_that) {
case _CompletePlannedWorkoutConfig():
return $default(_that.plannedWorkoutId,_that.workoutId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String plannedWorkoutId,  String workoutId)?  $default,) {final _that = this;
switch (_that) {
case _CompletePlannedWorkoutConfig() when $default != null:
return $default(_that.plannedWorkoutId,_that.workoutId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CompletePlannedWorkoutConfig implements CompletePlannedWorkoutConfig {
  const _CompletePlannedWorkoutConfig({required this.plannedWorkoutId, required this.workoutId});
  factory _CompletePlannedWorkoutConfig.fromJson(Map<String, dynamic> json) => _$CompletePlannedWorkoutConfigFromJson(json);

@override final  String plannedWorkoutId;
@override final  String workoutId;

/// Create a copy of CompletePlannedWorkoutConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompletePlannedWorkoutConfigCopyWith<_CompletePlannedWorkoutConfig> get copyWith => __$CompletePlannedWorkoutConfigCopyWithImpl<_CompletePlannedWorkoutConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompletePlannedWorkoutConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompletePlannedWorkoutConfig&&(identical(other.plannedWorkoutId, plannedWorkoutId) || other.plannedWorkoutId == plannedWorkoutId)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,plannedWorkoutId,workoutId);

@override
String toString() {
  return 'CompletePlannedWorkoutConfig(plannedWorkoutId: $plannedWorkoutId, workoutId: $workoutId)';
}


}

/// @nodoc
abstract mixin class _$CompletePlannedWorkoutConfigCopyWith<$Res> implements $CompletePlannedWorkoutConfigCopyWith<$Res> {
  factory _$CompletePlannedWorkoutConfigCopyWith(_CompletePlannedWorkoutConfig value, $Res Function(_CompletePlannedWorkoutConfig) _then) = __$CompletePlannedWorkoutConfigCopyWithImpl;
@override @useResult
$Res call({
 String plannedWorkoutId, String workoutId
});




}
/// @nodoc
class __$CompletePlannedWorkoutConfigCopyWithImpl<$Res>
    implements _$CompletePlannedWorkoutConfigCopyWith<$Res> {
  __$CompletePlannedWorkoutConfigCopyWithImpl(this._self, this._then);

  final _CompletePlannedWorkoutConfig _self;
  final $Res Function(_CompletePlannedWorkoutConfig) _then;

/// Create a copy of CompletePlannedWorkoutConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? plannedWorkoutId = null,Object? workoutId = null,}) {
  return _then(_CompletePlannedWorkoutConfig(
plannedWorkoutId: null == plannedWorkoutId ? _self.plannedWorkoutId : plannedWorkoutId // ignore: cast_nullable_to_non_nullable
as String,workoutId: null == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RepeatWorkoutConfig {

 String get completedWorkoutId; DateTime? get scheduledDate;
/// Create a copy of RepeatWorkoutConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RepeatWorkoutConfigCopyWith<RepeatWorkoutConfig> get copyWith => _$RepeatWorkoutConfigCopyWithImpl<RepeatWorkoutConfig>(this as RepeatWorkoutConfig, _$identity);

  /// Serializes this RepeatWorkoutConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RepeatWorkoutConfig&&(identical(other.completedWorkoutId, completedWorkoutId) || other.completedWorkoutId == completedWorkoutId)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,completedWorkoutId,scheduledDate);

@override
String toString() {
  return 'RepeatWorkoutConfig(completedWorkoutId: $completedWorkoutId, scheduledDate: $scheduledDate)';
}


}

/// @nodoc
abstract mixin class $RepeatWorkoutConfigCopyWith<$Res>  {
  factory $RepeatWorkoutConfigCopyWith(RepeatWorkoutConfig value, $Res Function(RepeatWorkoutConfig) _then) = _$RepeatWorkoutConfigCopyWithImpl;
@useResult
$Res call({
 String completedWorkoutId, DateTime? scheduledDate
});




}
/// @nodoc
class _$RepeatWorkoutConfigCopyWithImpl<$Res>
    implements $RepeatWorkoutConfigCopyWith<$Res> {
  _$RepeatWorkoutConfigCopyWithImpl(this._self, this._then);

  final RepeatWorkoutConfig _self;
  final $Res Function(RepeatWorkoutConfig) _then;

/// Create a copy of RepeatWorkoutConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? completedWorkoutId = null,Object? scheduledDate = freezed,}) {
  return _then(_self.copyWith(
completedWorkoutId: null == completedWorkoutId ? _self.completedWorkoutId : completedWorkoutId // ignore: cast_nullable_to_non_nullable
as String,scheduledDate: freezed == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RepeatWorkoutConfig].
extension RepeatWorkoutConfigPatterns on RepeatWorkoutConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RepeatWorkoutConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RepeatWorkoutConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RepeatWorkoutConfig value)  $default,){
final _that = this;
switch (_that) {
case _RepeatWorkoutConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RepeatWorkoutConfig value)?  $default,){
final _that = this;
switch (_that) {
case _RepeatWorkoutConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String completedWorkoutId,  DateTime? scheduledDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RepeatWorkoutConfig() when $default != null:
return $default(_that.completedWorkoutId,_that.scheduledDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String completedWorkoutId,  DateTime? scheduledDate)  $default,) {final _that = this;
switch (_that) {
case _RepeatWorkoutConfig():
return $default(_that.completedWorkoutId,_that.scheduledDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String completedWorkoutId,  DateTime? scheduledDate)?  $default,) {final _that = this;
switch (_that) {
case _RepeatWorkoutConfig() when $default != null:
return $default(_that.completedWorkoutId,_that.scheduledDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RepeatWorkoutConfig implements RepeatWorkoutConfig {
  const _RepeatWorkoutConfig({required this.completedWorkoutId, this.scheduledDate});
  factory _RepeatWorkoutConfig.fromJson(Map<String, dynamic> json) => _$RepeatWorkoutConfigFromJson(json);

@override final  String completedWorkoutId;
@override final  DateTime? scheduledDate;

/// Create a copy of RepeatWorkoutConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RepeatWorkoutConfigCopyWith<_RepeatWorkoutConfig> get copyWith => __$RepeatWorkoutConfigCopyWithImpl<_RepeatWorkoutConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RepeatWorkoutConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RepeatWorkoutConfig&&(identical(other.completedWorkoutId, completedWorkoutId) || other.completedWorkoutId == completedWorkoutId)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,completedWorkoutId,scheduledDate);

@override
String toString() {
  return 'RepeatWorkoutConfig(completedWorkoutId: $completedWorkoutId, scheduledDate: $scheduledDate)';
}


}

/// @nodoc
abstract mixin class _$RepeatWorkoutConfigCopyWith<$Res> implements $RepeatWorkoutConfigCopyWith<$Res> {
  factory _$RepeatWorkoutConfigCopyWith(_RepeatWorkoutConfig value, $Res Function(_RepeatWorkoutConfig) _then) = __$RepeatWorkoutConfigCopyWithImpl;
@override @useResult
$Res call({
 String completedWorkoutId, DateTime? scheduledDate
});




}
/// @nodoc
class __$RepeatWorkoutConfigCopyWithImpl<$Res>
    implements _$RepeatWorkoutConfigCopyWith<$Res> {
  __$RepeatWorkoutConfigCopyWithImpl(this._self, this._then);

  final _RepeatWorkoutConfig _self;
  final $Res Function(_RepeatWorkoutConfig) _then;

/// Create a copy of RepeatWorkoutConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? completedWorkoutId = null,Object? scheduledDate = freezed,}) {
  return _then(_RepeatWorkoutConfig(
completedWorkoutId: null == completedWorkoutId ? _self.completedWorkoutId : completedWorkoutId // ignore: cast_nullable_to_non_nullable
as String,scheduledDate: freezed == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$RoutineExerciseConfigUpdate {

 String get routineId; String get routineExerciseId; int? get sets; int? get reps; int? get repsMin; double? get weightKg; int? get durationSeconds; int? get restSeconds; int? get rpeTarget; int? get rirTarget; int? get warmupSets; WorkoutMode? get mode; String? get notes; String? get supersetGroupId; int? get supersetPosition;
/// Create a copy of RoutineExerciseConfigUpdate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutineExerciseConfigUpdateCopyWith<RoutineExerciseConfigUpdate> get copyWith => _$RoutineExerciseConfigUpdateCopyWithImpl<RoutineExerciseConfigUpdate>(this as RoutineExerciseConfigUpdate, _$identity);

  /// Serializes this RoutineExerciseConfigUpdate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutineExerciseConfigUpdate&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.routineExerciseId, routineExerciseId) || other.routineExerciseId == routineExerciseId)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.repsMin, repsMin) || other.repsMin == repsMin)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.rpeTarget, rpeTarget) || other.rpeTarget == rpeTarget)&&(identical(other.rirTarget, rirTarget) || other.rirTarget == rirTarget)&&(identical(other.warmupSets, warmupSets) || other.warmupSets == warmupSets)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.supersetGroupId, supersetGroupId) || other.supersetGroupId == supersetGroupId)&&(identical(other.supersetPosition, supersetPosition) || other.supersetPosition == supersetPosition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,routineId,routineExerciseId,sets,reps,repsMin,weightKg,durationSeconds,restSeconds,rpeTarget,rirTarget,warmupSets,mode,notes,supersetGroupId,supersetPosition);

@override
String toString() {
  return 'RoutineExerciseConfigUpdate(routineId: $routineId, routineExerciseId: $routineExerciseId, sets: $sets, reps: $reps, repsMin: $repsMin, weightKg: $weightKg, durationSeconds: $durationSeconds, restSeconds: $restSeconds, rpeTarget: $rpeTarget, rirTarget: $rirTarget, warmupSets: $warmupSets, mode: $mode, notes: $notes, supersetGroupId: $supersetGroupId, supersetPosition: $supersetPosition)';
}


}

/// @nodoc
abstract mixin class $RoutineExerciseConfigUpdateCopyWith<$Res>  {
  factory $RoutineExerciseConfigUpdateCopyWith(RoutineExerciseConfigUpdate value, $Res Function(RoutineExerciseConfigUpdate) _then) = _$RoutineExerciseConfigUpdateCopyWithImpl;
@useResult
$Res call({
 String routineId, String routineExerciseId, int? sets, int? reps, int? repsMin, double? weightKg, int? durationSeconds, int? restSeconds, int? rpeTarget, int? rirTarget, int? warmupSets, WorkoutMode? mode, String? notes, String? supersetGroupId, int? supersetPosition
});




}
/// @nodoc
class _$RoutineExerciseConfigUpdateCopyWithImpl<$Res>
    implements $RoutineExerciseConfigUpdateCopyWith<$Res> {
  _$RoutineExerciseConfigUpdateCopyWithImpl(this._self, this._then);

  final RoutineExerciseConfigUpdate _self;
  final $Res Function(RoutineExerciseConfigUpdate) _then;

/// Create a copy of RoutineExerciseConfigUpdate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? routineId = null,Object? routineExerciseId = null,Object? sets = freezed,Object? reps = freezed,Object? repsMin = freezed,Object? weightKg = freezed,Object? durationSeconds = freezed,Object? restSeconds = freezed,Object? rpeTarget = freezed,Object? rirTarget = freezed,Object? warmupSets = freezed,Object? mode = freezed,Object? notes = freezed,Object? supersetGroupId = freezed,Object? supersetPosition = freezed,}) {
  return _then(_self.copyWith(
routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,routineExerciseId: null == routineExerciseId ? _self.routineExerciseId : routineExerciseId // ignore: cast_nullable_to_non_nullable
as String,sets: freezed == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int?,reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int?,repsMin: freezed == repsMin ? _self.repsMin : repsMin // ignore: cast_nullable_to_non_nullable
as int?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,restSeconds: freezed == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int?,rpeTarget: freezed == rpeTarget ? _self.rpeTarget : rpeTarget // ignore: cast_nullable_to_non_nullable
as int?,rirTarget: freezed == rirTarget ? _self.rirTarget : rirTarget // ignore: cast_nullable_to_non_nullable
as int?,warmupSets: freezed == warmupSets ? _self.warmupSets : warmupSets // ignore: cast_nullable_to_non_nullable
as int?,mode: freezed == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as WorkoutMode?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,supersetGroupId: freezed == supersetGroupId ? _self.supersetGroupId : supersetGroupId // ignore: cast_nullable_to_non_nullable
as String?,supersetPosition: freezed == supersetPosition ? _self.supersetPosition : supersetPosition // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [RoutineExerciseConfigUpdate].
extension RoutineExerciseConfigUpdatePatterns on RoutineExerciseConfigUpdate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutineExerciseConfigUpdate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutineExerciseConfigUpdate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutineExerciseConfigUpdate value)  $default,){
final _that = this;
switch (_that) {
case _RoutineExerciseConfigUpdate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutineExerciseConfigUpdate value)?  $default,){
final _that = this;
switch (_that) {
case _RoutineExerciseConfigUpdate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String routineId,  String routineExerciseId,  int? sets,  int? reps,  int? repsMin,  double? weightKg,  int? durationSeconds,  int? restSeconds,  int? rpeTarget,  int? rirTarget,  int? warmupSets,  WorkoutMode? mode,  String? notes,  String? supersetGroupId,  int? supersetPosition)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutineExerciseConfigUpdate() when $default != null:
return $default(_that.routineId,_that.routineExerciseId,_that.sets,_that.reps,_that.repsMin,_that.weightKg,_that.durationSeconds,_that.restSeconds,_that.rpeTarget,_that.rirTarget,_that.warmupSets,_that.mode,_that.notes,_that.supersetGroupId,_that.supersetPosition);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String routineId,  String routineExerciseId,  int? sets,  int? reps,  int? repsMin,  double? weightKg,  int? durationSeconds,  int? restSeconds,  int? rpeTarget,  int? rirTarget,  int? warmupSets,  WorkoutMode? mode,  String? notes,  String? supersetGroupId,  int? supersetPosition)  $default,) {final _that = this;
switch (_that) {
case _RoutineExerciseConfigUpdate():
return $default(_that.routineId,_that.routineExerciseId,_that.sets,_that.reps,_that.repsMin,_that.weightKg,_that.durationSeconds,_that.restSeconds,_that.rpeTarget,_that.rirTarget,_that.warmupSets,_that.mode,_that.notes,_that.supersetGroupId,_that.supersetPosition);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String routineId,  String routineExerciseId,  int? sets,  int? reps,  int? repsMin,  double? weightKg,  int? durationSeconds,  int? restSeconds,  int? rpeTarget,  int? rirTarget,  int? warmupSets,  WorkoutMode? mode,  String? notes,  String? supersetGroupId,  int? supersetPosition)?  $default,) {final _that = this;
switch (_that) {
case _RoutineExerciseConfigUpdate() when $default != null:
return $default(_that.routineId,_that.routineExerciseId,_that.sets,_that.reps,_that.repsMin,_that.weightKg,_that.durationSeconds,_that.restSeconds,_that.rpeTarget,_that.rirTarget,_that.warmupSets,_that.mode,_that.notes,_that.supersetGroupId,_that.supersetPosition);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoutineExerciseConfigUpdate implements RoutineExerciseConfigUpdate {
  const _RoutineExerciseConfigUpdate({required this.routineId, required this.routineExerciseId, this.sets, this.reps, this.repsMin, this.weightKg, this.durationSeconds, this.restSeconds, this.rpeTarget, this.rirTarget, this.warmupSets, this.mode, this.notes, this.supersetGroupId, this.supersetPosition});
  factory _RoutineExerciseConfigUpdate.fromJson(Map<String, dynamic> json) => _$RoutineExerciseConfigUpdateFromJson(json);

@override final  String routineId;
@override final  String routineExerciseId;
@override final  int? sets;
@override final  int? reps;
@override final  int? repsMin;
@override final  double? weightKg;
@override final  int? durationSeconds;
@override final  int? restSeconds;
@override final  int? rpeTarget;
@override final  int? rirTarget;
@override final  int? warmupSets;
@override final  WorkoutMode? mode;
@override final  String? notes;
@override final  String? supersetGroupId;
@override final  int? supersetPosition;

/// Create a copy of RoutineExerciseConfigUpdate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutineExerciseConfigUpdateCopyWith<_RoutineExerciseConfigUpdate> get copyWith => __$RoutineExerciseConfigUpdateCopyWithImpl<_RoutineExerciseConfigUpdate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoutineExerciseConfigUpdateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutineExerciseConfigUpdate&&(identical(other.routineId, routineId) || other.routineId == routineId)&&(identical(other.routineExerciseId, routineExerciseId) || other.routineExerciseId == routineExerciseId)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.repsMin, repsMin) || other.repsMin == repsMin)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.rpeTarget, rpeTarget) || other.rpeTarget == rpeTarget)&&(identical(other.rirTarget, rirTarget) || other.rirTarget == rirTarget)&&(identical(other.warmupSets, warmupSets) || other.warmupSets == warmupSets)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.supersetGroupId, supersetGroupId) || other.supersetGroupId == supersetGroupId)&&(identical(other.supersetPosition, supersetPosition) || other.supersetPosition == supersetPosition));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,routineId,routineExerciseId,sets,reps,repsMin,weightKg,durationSeconds,restSeconds,rpeTarget,rirTarget,warmupSets,mode,notes,supersetGroupId,supersetPosition);

@override
String toString() {
  return 'RoutineExerciseConfigUpdate(routineId: $routineId, routineExerciseId: $routineExerciseId, sets: $sets, reps: $reps, repsMin: $repsMin, weightKg: $weightKg, durationSeconds: $durationSeconds, restSeconds: $restSeconds, rpeTarget: $rpeTarget, rirTarget: $rirTarget, warmupSets: $warmupSets, mode: $mode, notes: $notes, supersetGroupId: $supersetGroupId, supersetPosition: $supersetPosition)';
}


}

/// @nodoc
abstract mixin class _$RoutineExerciseConfigUpdateCopyWith<$Res> implements $RoutineExerciseConfigUpdateCopyWith<$Res> {
  factory _$RoutineExerciseConfigUpdateCopyWith(_RoutineExerciseConfigUpdate value, $Res Function(_RoutineExerciseConfigUpdate) _then) = __$RoutineExerciseConfigUpdateCopyWithImpl;
@override @useResult
$Res call({
 String routineId, String routineExerciseId, int? sets, int? reps, int? repsMin, double? weightKg, int? durationSeconds, int? restSeconds, int? rpeTarget, int? rirTarget, int? warmupSets, WorkoutMode? mode, String? notes, String? supersetGroupId, int? supersetPosition
});




}
/// @nodoc
class __$RoutineExerciseConfigUpdateCopyWithImpl<$Res>
    implements _$RoutineExerciseConfigUpdateCopyWith<$Res> {
  __$RoutineExerciseConfigUpdateCopyWithImpl(this._self, this._then);

  final _RoutineExerciseConfigUpdate _self;
  final $Res Function(_RoutineExerciseConfigUpdate) _then;

/// Create a copy of RoutineExerciseConfigUpdate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? routineId = null,Object? routineExerciseId = null,Object? sets = freezed,Object? reps = freezed,Object? repsMin = freezed,Object? weightKg = freezed,Object? durationSeconds = freezed,Object? restSeconds = freezed,Object? rpeTarget = freezed,Object? rirTarget = freezed,Object? warmupSets = freezed,Object? mode = freezed,Object? notes = freezed,Object? supersetGroupId = freezed,Object? supersetPosition = freezed,}) {
  return _then(_RoutineExerciseConfigUpdate(
routineId: null == routineId ? _self.routineId : routineId // ignore: cast_nullable_to_non_nullable
as String,routineExerciseId: null == routineExerciseId ? _self.routineExerciseId : routineExerciseId // ignore: cast_nullable_to_non_nullable
as String,sets: freezed == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int?,reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int?,repsMin: freezed == repsMin ? _self.repsMin : repsMin // ignore: cast_nullable_to_non_nullable
as int?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,restSeconds: freezed == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int?,rpeTarget: freezed == rpeTarget ? _self.rpeTarget : rpeTarget // ignore: cast_nullable_to_non_nullable
as int?,rirTarget: freezed == rirTarget ? _self.rirTarget : rirTarget // ignore: cast_nullable_to_non_nullable
as int?,warmupSets: freezed == warmupSets ? _self.warmupSets : warmupSets // ignore: cast_nullable_to_non_nullable
as int?,mode: freezed == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as WorkoutMode?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,supersetGroupId: freezed == supersetGroupId ? _self.supersetGroupId : supersetGroupId // ignore: cast_nullable_to_non_nullable
as String?,supersetPosition: freezed == supersetPosition ? _self.supersetPosition : supersetPosition // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
