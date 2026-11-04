// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HeatmapPoint {

/// Local date (midnight, user timezone) the workout was completed on.
 DateTime get date;/// Number of distinct completed workouts on that day.
 int get workoutCount;
/// Create a copy of HeatmapPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HeatmapPointCopyWith<HeatmapPoint> get copyWith => _$HeatmapPointCopyWithImpl<HeatmapPoint>(this as HeatmapPoint, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HeatmapPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.workoutCount, workoutCount) || other.workoutCount == workoutCount));
}


@override
int get hashCode => Object.hash(runtimeType,date,workoutCount);

@override
String toString() {
  return 'HeatmapPoint(date: $date, workoutCount: $workoutCount)';
}


}

/// @nodoc
abstract mixin class $HeatmapPointCopyWith<$Res>  {
  factory $HeatmapPointCopyWith(HeatmapPoint value, $Res Function(HeatmapPoint) _then) = _$HeatmapPointCopyWithImpl;
@useResult
$Res call({
 DateTime date, int workoutCount
});




}
/// @nodoc
class _$HeatmapPointCopyWithImpl<$Res>
    implements $HeatmapPointCopyWith<$Res> {
  _$HeatmapPointCopyWithImpl(this._self, this._then);

  final HeatmapPoint _self;
  final $Res Function(HeatmapPoint) _then;

/// Create a copy of HeatmapPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? workoutCount = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,workoutCount: null == workoutCount ? _self.workoutCount : workoutCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [HeatmapPoint].
extension HeatmapPointPatterns on HeatmapPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HeatmapPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HeatmapPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HeatmapPoint value)  $default,){
final _that = this;
switch (_that) {
case _HeatmapPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HeatmapPoint value)?  $default,){
final _that = this;
switch (_that) {
case _HeatmapPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  int workoutCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HeatmapPoint() when $default != null:
return $default(_that.date,_that.workoutCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  int workoutCount)  $default,) {final _that = this;
switch (_that) {
case _HeatmapPoint():
return $default(_that.date,_that.workoutCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  int workoutCount)?  $default,) {final _that = this;
switch (_that) {
case _HeatmapPoint() when $default != null:
return $default(_that.date,_that.workoutCount);case _:
  return null;

}
}

}

/// @nodoc


class _HeatmapPoint implements HeatmapPoint {
  const _HeatmapPoint({required this.date, required this.workoutCount});
  

/// Local date (midnight, user timezone) the workout was completed on.
@override final  DateTime date;
/// Number of distinct completed workouts on that day.
@override final  int workoutCount;

/// Create a copy of HeatmapPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HeatmapPointCopyWith<_HeatmapPoint> get copyWith => __$HeatmapPointCopyWithImpl<_HeatmapPoint>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HeatmapPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.workoutCount, workoutCount) || other.workoutCount == workoutCount));
}


@override
int get hashCode => Object.hash(runtimeType,date,workoutCount);

@override
String toString() {
  return 'HeatmapPoint(date: $date, workoutCount: $workoutCount)';
}


}

/// @nodoc
abstract mixin class _$HeatmapPointCopyWith<$Res> implements $HeatmapPointCopyWith<$Res> {
  factory _$HeatmapPointCopyWith(_HeatmapPoint value, $Res Function(_HeatmapPoint) _then) = __$HeatmapPointCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, int workoutCount
});




}
/// @nodoc
class __$HeatmapPointCopyWithImpl<$Res>
    implements _$HeatmapPointCopyWith<$Res> {
  __$HeatmapPointCopyWithImpl(this._self, this._then);

  final _HeatmapPoint _self;
  final $Res Function(_HeatmapPoint) _then;

/// Create a copy of HeatmapPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? workoutCount = null,}) {
  return _then(_HeatmapPoint(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,workoutCount: null == workoutCount ? _self.workoutCount : workoutCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$WeightTrendPoint {

/// Local date (midnight, user timezone).
 DateTime get date;/// Sum of reps * weight_kg for completed sets on that day, rounded to 2 dp.
 double get volumeKg;/// Total completed reps on that day.
 int get totalReps;/// Total completed sets on that day.
 int get totalSets;
/// Create a copy of WeightTrendPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeightTrendPointCopyWith<WeightTrendPoint> get copyWith => _$WeightTrendPointCopyWithImpl<WeightTrendPoint>(this as WeightTrendPoint, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeightTrendPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.volumeKg, volumeKg) || other.volumeKg == volumeKg)&&(identical(other.totalReps, totalReps) || other.totalReps == totalReps)&&(identical(other.totalSets, totalSets) || other.totalSets == totalSets));
}


@override
int get hashCode => Object.hash(runtimeType,date,volumeKg,totalReps,totalSets);

@override
String toString() {
  return 'WeightTrendPoint(date: $date, volumeKg: $volumeKg, totalReps: $totalReps, totalSets: $totalSets)';
}


}

/// @nodoc
abstract mixin class $WeightTrendPointCopyWith<$Res>  {
  factory $WeightTrendPointCopyWith(WeightTrendPoint value, $Res Function(WeightTrendPoint) _then) = _$WeightTrendPointCopyWithImpl;
@useResult
$Res call({
 DateTime date, double volumeKg, int totalReps, int totalSets
});




}
/// @nodoc
class _$WeightTrendPointCopyWithImpl<$Res>
    implements $WeightTrendPointCopyWith<$Res> {
  _$WeightTrendPointCopyWithImpl(this._self, this._then);

  final WeightTrendPoint _self;
  final $Res Function(WeightTrendPoint) _then;

/// Create a copy of WeightTrendPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? volumeKg = null,Object? totalReps = null,Object? totalSets = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,volumeKg: null == volumeKg ? _self.volumeKg : volumeKg // ignore: cast_nullable_to_non_nullable
as double,totalReps: null == totalReps ? _self.totalReps : totalReps // ignore: cast_nullable_to_non_nullable
as int,totalSets: null == totalSets ? _self.totalSets : totalSets // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WeightTrendPoint].
extension WeightTrendPointPatterns on WeightTrendPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeightTrendPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeightTrendPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeightTrendPoint value)  $default,){
final _that = this;
switch (_that) {
case _WeightTrendPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeightTrendPoint value)?  $default,){
final _that = this;
switch (_that) {
case _WeightTrendPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  double volumeKg,  int totalReps,  int totalSets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeightTrendPoint() when $default != null:
return $default(_that.date,_that.volumeKg,_that.totalReps,_that.totalSets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  double volumeKg,  int totalReps,  int totalSets)  $default,) {final _that = this;
switch (_that) {
case _WeightTrendPoint():
return $default(_that.date,_that.volumeKg,_that.totalReps,_that.totalSets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  double volumeKg,  int totalReps,  int totalSets)?  $default,) {final _that = this;
switch (_that) {
case _WeightTrendPoint() when $default != null:
return $default(_that.date,_that.volumeKg,_that.totalReps,_that.totalSets);case _:
  return null;

}
}

}

/// @nodoc


class _WeightTrendPoint implements WeightTrendPoint {
  const _WeightTrendPoint({required this.date, required this.volumeKg, required this.totalReps, required this.totalSets});
  

/// Local date (midnight, user timezone).
@override final  DateTime date;
/// Sum of reps * weight_kg for completed sets on that day, rounded to 2 dp.
@override final  double volumeKg;
/// Total completed reps on that day.
@override final  int totalReps;
/// Total completed sets on that day.
@override final  int totalSets;

/// Create a copy of WeightTrendPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeightTrendPointCopyWith<_WeightTrendPoint> get copyWith => __$WeightTrendPointCopyWithImpl<_WeightTrendPoint>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeightTrendPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.volumeKg, volumeKg) || other.volumeKg == volumeKg)&&(identical(other.totalReps, totalReps) || other.totalReps == totalReps)&&(identical(other.totalSets, totalSets) || other.totalSets == totalSets));
}


@override
int get hashCode => Object.hash(runtimeType,date,volumeKg,totalReps,totalSets);

@override
String toString() {
  return 'WeightTrendPoint(date: $date, volumeKg: $volumeKg, totalReps: $totalReps, totalSets: $totalSets)';
}


}

/// @nodoc
abstract mixin class _$WeightTrendPointCopyWith<$Res> implements $WeightTrendPointCopyWith<$Res> {
  factory _$WeightTrendPointCopyWith(_WeightTrendPoint value, $Res Function(_WeightTrendPoint) _then) = __$WeightTrendPointCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, double volumeKg, int totalReps, int totalSets
});




}
/// @nodoc
class __$WeightTrendPointCopyWithImpl<$Res>
    implements _$WeightTrendPointCopyWith<$Res> {
  __$WeightTrendPointCopyWithImpl(this._self, this._then);

  final _WeightTrendPoint _self;
  final $Res Function(_WeightTrendPoint) _then;

/// Create a copy of WeightTrendPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? volumeKg = null,Object? totalReps = null,Object? totalSets = null,}) {
  return _then(_WeightTrendPoint(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,volumeKg: null == volumeKg ? _self.volumeKg : volumeKg // ignore: cast_nullable_to_non_nullable
as double,totalReps: null == totalReps ? _self.totalReps : totalReps // ignore: cast_nullable_to_non_nullable
as int,totalSets: null == totalSets ? _self.totalSets : totalSets // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$PRChartPoint {

 String get exerciseId; String get exerciseName;/// Server-authoritative max weight (kg).
 double get maxWeightKg;/// Server-authoritative max reps.
 int get maxReps;/// Server-side Epley 1RM estimate (kg), already rounded to 2 dp.
 double get estimated1rm;/// When the PR row was last updated (UTC).
 DateTime get updatedAt;
/// Create a copy of PRChartPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PRChartPointCopyWith<PRChartPoint> get copyWith => _$PRChartPointCopyWithImpl<PRChartPoint>(this as PRChartPoint, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PRChartPoint&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.maxWeightKg, maxWeightKg) || other.maxWeightKg == maxWeightKg)&&(identical(other.maxReps, maxReps) || other.maxReps == maxReps)&&(identical(other.estimated1rm, estimated1rm) || other.estimated1rm == estimated1rm)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,exerciseId,exerciseName,maxWeightKg,maxReps,estimated1rm,updatedAt);

@override
String toString() {
  return 'PRChartPoint(exerciseId: $exerciseId, exerciseName: $exerciseName, maxWeightKg: $maxWeightKg, maxReps: $maxReps, estimated1rm: $estimated1rm, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PRChartPointCopyWith<$Res>  {
  factory $PRChartPointCopyWith(PRChartPoint value, $Res Function(PRChartPoint) _then) = _$PRChartPointCopyWithImpl;
@useResult
$Res call({
 String exerciseId, String exerciseName, double maxWeightKg, int maxReps, double estimated1rm, DateTime updatedAt
});




}
/// @nodoc
class _$PRChartPointCopyWithImpl<$Res>
    implements $PRChartPointCopyWith<$Res> {
  _$PRChartPointCopyWithImpl(this._self, this._then);

  final PRChartPoint _self;
  final $Res Function(PRChartPoint) _then;

/// Create a copy of PRChartPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseId = null,Object? exerciseName = null,Object? maxWeightKg = null,Object? maxReps = null,Object? estimated1rm = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,maxWeightKg: null == maxWeightKg ? _self.maxWeightKg : maxWeightKg // ignore: cast_nullable_to_non_nullable
as double,maxReps: null == maxReps ? _self.maxReps : maxReps // ignore: cast_nullable_to_non_nullable
as int,estimated1rm: null == estimated1rm ? _self.estimated1rm : estimated1rm // ignore: cast_nullable_to_non_nullable
as double,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PRChartPoint].
extension PRChartPointPatterns on PRChartPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PRChartPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PRChartPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PRChartPoint value)  $default,){
final _that = this;
switch (_that) {
case _PRChartPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PRChartPoint value)?  $default,){
final _that = this;
switch (_that) {
case _PRChartPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String exerciseId,  String exerciseName,  double maxWeightKg,  int maxReps,  double estimated1rm,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PRChartPoint() when $default != null:
return $default(_that.exerciseId,_that.exerciseName,_that.maxWeightKg,_that.maxReps,_that.estimated1rm,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String exerciseId,  String exerciseName,  double maxWeightKg,  int maxReps,  double estimated1rm,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PRChartPoint():
return $default(_that.exerciseId,_that.exerciseName,_that.maxWeightKg,_that.maxReps,_that.estimated1rm,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String exerciseId,  String exerciseName,  double maxWeightKg,  int maxReps,  double estimated1rm,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PRChartPoint() when $default != null:
return $default(_that.exerciseId,_that.exerciseName,_that.maxWeightKg,_that.maxReps,_that.estimated1rm,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _PRChartPoint implements PRChartPoint {
  const _PRChartPoint({required this.exerciseId, required this.exerciseName, required this.maxWeightKg, required this.maxReps, required this.estimated1rm, required this.updatedAt});
  

@override final  String exerciseId;
@override final  String exerciseName;
/// Server-authoritative max weight (kg).
@override final  double maxWeightKg;
/// Server-authoritative max reps.
@override final  int maxReps;
/// Server-side Epley 1RM estimate (kg), already rounded to 2 dp.
@override final  double estimated1rm;
/// When the PR row was last updated (UTC).
@override final  DateTime updatedAt;

/// Create a copy of PRChartPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PRChartPointCopyWith<_PRChartPoint> get copyWith => __$PRChartPointCopyWithImpl<_PRChartPoint>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PRChartPoint&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.maxWeightKg, maxWeightKg) || other.maxWeightKg == maxWeightKg)&&(identical(other.maxReps, maxReps) || other.maxReps == maxReps)&&(identical(other.estimated1rm, estimated1rm) || other.estimated1rm == estimated1rm)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,exerciseId,exerciseName,maxWeightKg,maxReps,estimated1rm,updatedAt);

@override
String toString() {
  return 'PRChartPoint(exerciseId: $exerciseId, exerciseName: $exerciseName, maxWeightKg: $maxWeightKg, maxReps: $maxReps, estimated1rm: $estimated1rm, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PRChartPointCopyWith<$Res> implements $PRChartPointCopyWith<$Res> {
  factory _$PRChartPointCopyWith(_PRChartPoint value, $Res Function(_PRChartPoint) _then) = __$PRChartPointCopyWithImpl;
@override @useResult
$Res call({
 String exerciseId, String exerciseName, double maxWeightKg, int maxReps, double estimated1rm, DateTime updatedAt
});




}
/// @nodoc
class __$PRChartPointCopyWithImpl<$Res>
    implements _$PRChartPointCopyWith<$Res> {
  __$PRChartPointCopyWithImpl(this._self, this._then);

  final _PRChartPoint _self;
  final $Res Function(_PRChartPoint) _then;

/// Create a copy of PRChartPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseId = null,Object? exerciseName = null,Object? maxWeightKg = null,Object? maxReps = null,Object? estimated1rm = null,Object? updatedAt = null,}) {
  return _then(_PRChartPoint(
exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,maxWeightKg: null == maxWeightKg ? _self.maxWeightKg : maxWeightKg // ignore: cast_nullable_to_non_nullable
as double,maxReps: null == maxReps ? _self.maxReps : maxReps // ignore: cast_nullable_to_non_nullable
as int,estimated1rm: null == estimated1rm ? _self.estimated1rm : estimated1rm // ignore: cast_nullable_to_non_nullable
as double,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$MuscleBalancePoint {

 String get category;/// Sum of reps * weight_kg for completed sets in this category, rounded to 2 dp.
 double get volumeKg;/// Total completed reps in this category.
 int get totalReps;/// Total completed sets in this category.
 int get totalSets;/// Share of total window volume (0-100), rounded to 2 dp.
 double get percent;
/// Create a copy of MuscleBalancePoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MuscleBalancePointCopyWith<MuscleBalancePoint> get copyWith => _$MuscleBalancePointCopyWithImpl<MuscleBalancePoint>(this as MuscleBalancePoint, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MuscleBalancePoint&&(identical(other.category, category) || other.category == category)&&(identical(other.volumeKg, volumeKg) || other.volumeKg == volumeKg)&&(identical(other.totalReps, totalReps) || other.totalReps == totalReps)&&(identical(other.totalSets, totalSets) || other.totalSets == totalSets)&&(identical(other.percent, percent) || other.percent == percent));
}


@override
int get hashCode => Object.hash(runtimeType,category,volumeKg,totalReps,totalSets,percent);

@override
String toString() {
  return 'MuscleBalancePoint(category: $category, volumeKg: $volumeKg, totalReps: $totalReps, totalSets: $totalSets, percent: $percent)';
}


}

/// @nodoc
abstract mixin class $MuscleBalancePointCopyWith<$Res>  {
  factory $MuscleBalancePointCopyWith(MuscleBalancePoint value, $Res Function(MuscleBalancePoint) _then) = _$MuscleBalancePointCopyWithImpl;
@useResult
$Res call({
 String category, double volumeKg, int totalReps, int totalSets, double percent
});




}
/// @nodoc
class _$MuscleBalancePointCopyWithImpl<$Res>
    implements $MuscleBalancePointCopyWith<$Res> {
  _$MuscleBalancePointCopyWithImpl(this._self, this._then);

  final MuscleBalancePoint _self;
  final $Res Function(MuscleBalancePoint) _then;

/// Create a copy of MuscleBalancePoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? volumeKg = null,Object? totalReps = null,Object? totalSets = null,Object? percent = null,}) {
  return _then(_self.copyWith(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,volumeKg: null == volumeKg ? _self.volumeKg : volumeKg // ignore: cast_nullable_to_non_nullable
as double,totalReps: null == totalReps ? _self.totalReps : totalReps // ignore: cast_nullable_to_non_nullable
as int,totalSets: null == totalSets ? _self.totalSets : totalSets // ignore: cast_nullable_to_non_nullable
as int,percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [MuscleBalancePoint].
extension MuscleBalancePointPatterns on MuscleBalancePoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MuscleBalancePoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MuscleBalancePoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MuscleBalancePoint value)  $default,){
final _that = this;
switch (_that) {
case _MuscleBalancePoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MuscleBalancePoint value)?  $default,){
final _that = this;
switch (_that) {
case _MuscleBalancePoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String category,  double volumeKg,  int totalReps,  int totalSets,  double percent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MuscleBalancePoint() when $default != null:
return $default(_that.category,_that.volumeKg,_that.totalReps,_that.totalSets,_that.percent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String category,  double volumeKg,  int totalReps,  int totalSets,  double percent)  $default,) {final _that = this;
switch (_that) {
case _MuscleBalancePoint():
return $default(_that.category,_that.volumeKg,_that.totalReps,_that.totalSets,_that.percent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String category,  double volumeKg,  int totalReps,  int totalSets,  double percent)?  $default,) {final _that = this;
switch (_that) {
case _MuscleBalancePoint() when $default != null:
return $default(_that.category,_that.volumeKg,_that.totalReps,_that.totalSets,_that.percent);case _:
  return null;

}
}

}

/// @nodoc


class _MuscleBalancePoint implements MuscleBalancePoint {
  const _MuscleBalancePoint({required this.category, required this.volumeKg, required this.totalReps, required this.totalSets, required this.percent});
  

@override final  String category;
/// Sum of reps * weight_kg for completed sets in this category, rounded to 2 dp.
@override final  double volumeKg;
/// Total completed reps in this category.
@override final  int totalReps;
/// Total completed sets in this category.
@override final  int totalSets;
/// Share of total window volume (0-100), rounded to 2 dp.
@override final  double percent;

/// Create a copy of MuscleBalancePoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MuscleBalancePointCopyWith<_MuscleBalancePoint> get copyWith => __$MuscleBalancePointCopyWithImpl<_MuscleBalancePoint>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MuscleBalancePoint&&(identical(other.category, category) || other.category == category)&&(identical(other.volumeKg, volumeKg) || other.volumeKg == volumeKg)&&(identical(other.totalReps, totalReps) || other.totalReps == totalReps)&&(identical(other.totalSets, totalSets) || other.totalSets == totalSets)&&(identical(other.percent, percent) || other.percent == percent));
}


@override
int get hashCode => Object.hash(runtimeType,category,volumeKg,totalReps,totalSets,percent);

@override
String toString() {
  return 'MuscleBalancePoint(category: $category, volumeKg: $volumeKg, totalReps: $totalReps, totalSets: $totalSets, percent: $percent)';
}


}

/// @nodoc
abstract mixin class _$MuscleBalancePointCopyWith<$Res> implements $MuscleBalancePointCopyWith<$Res> {
  factory _$MuscleBalancePointCopyWith(_MuscleBalancePoint value, $Res Function(_MuscleBalancePoint) _then) = __$MuscleBalancePointCopyWithImpl;
@override @useResult
$Res call({
 String category, double volumeKg, int totalReps, int totalSets, double percent
});




}
/// @nodoc
class __$MuscleBalancePointCopyWithImpl<$Res>
    implements _$MuscleBalancePointCopyWith<$Res> {
  __$MuscleBalancePointCopyWithImpl(this._self, this._then);

  final _MuscleBalancePoint _self;
  final $Res Function(_MuscleBalancePoint) _then;

/// Create a copy of MuscleBalancePoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? volumeKg = null,Object? totalReps = null,Object? totalSets = null,Object? percent = null,}) {
  return _then(_MuscleBalancePoint(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,volumeKg: null == volumeKg ? _self.volumeKg : volumeKg // ignore: cast_nullable_to_non_nullable
as double,totalReps: null == totalReps ? _self.totalReps : totalReps // ignore: cast_nullable_to_non_nullable
as int,totalSets: null == totalSets ? _self.totalSets : totalSets // ignore: cast_nullable_to_non_nullable
as int,percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$AnalyticsResult {

 List<HeatmapPoint> get heatmap; List<WeightTrendPoint> get weightTrend; List<PRChartPoint> get prChart; List<MuscleBalancePoint> get muscleBalance;
/// Create a copy of AnalyticsResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyticsResultCopyWith<AnalyticsResult> get copyWith => _$AnalyticsResultCopyWithImpl<AnalyticsResult>(this as AnalyticsResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyticsResult&&const DeepCollectionEquality().equals(other.heatmap, heatmap)&&const DeepCollectionEquality().equals(other.weightTrend, weightTrend)&&const DeepCollectionEquality().equals(other.prChart, prChart)&&const DeepCollectionEquality().equals(other.muscleBalance, muscleBalance));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(heatmap),const DeepCollectionEquality().hash(weightTrend),const DeepCollectionEquality().hash(prChart),const DeepCollectionEquality().hash(muscleBalance));

@override
String toString() {
  return 'AnalyticsResult(heatmap: $heatmap, weightTrend: $weightTrend, prChart: $prChart, muscleBalance: $muscleBalance)';
}


}

/// @nodoc
abstract mixin class $AnalyticsResultCopyWith<$Res>  {
  factory $AnalyticsResultCopyWith(AnalyticsResult value, $Res Function(AnalyticsResult) _then) = _$AnalyticsResultCopyWithImpl;
@useResult
$Res call({
 List<HeatmapPoint> heatmap, List<WeightTrendPoint> weightTrend, List<PRChartPoint> prChart, List<MuscleBalancePoint> muscleBalance
});




}
/// @nodoc
class _$AnalyticsResultCopyWithImpl<$Res>
    implements $AnalyticsResultCopyWith<$Res> {
  _$AnalyticsResultCopyWithImpl(this._self, this._then);

  final AnalyticsResult _self;
  final $Res Function(AnalyticsResult) _then;

/// Create a copy of AnalyticsResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? heatmap = null,Object? weightTrend = null,Object? prChart = null,Object? muscleBalance = null,}) {
  return _then(_self.copyWith(
heatmap: null == heatmap ? _self.heatmap : heatmap // ignore: cast_nullable_to_non_nullable
as List<HeatmapPoint>,weightTrend: null == weightTrend ? _self.weightTrend : weightTrend // ignore: cast_nullable_to_non_nullable
as List<WeightTrendPoint>,prChart: null == prChart ? _self.prChart : prChart // ignore: cast_nullable_to_non_nullable
as List<PRChartPoint>,muscleBalance: null == muscleBalance ? _self.muscleBalance : muscleBalance // ignore: cast_nullable_to_non_nullable
as List<MuscleBalancePoint>,
  ));
}

}


/// Adds pattern-matching-related methods to [AnalyticsResult].
extension AnalyticsResultPatterns on AnalyticsResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyticsResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyticsResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyticsResult value)  $default,){
final _that = this;
switch (_that) {
case _AnalyticsResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyticsResult value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyticsResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<HeatmapPoint> heatmap,  List<WeightTrendPoint> weightTrend,  List<PRChartPoint> prChart,  List<MuscleBalancePoint> muscleBalance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyticsResult() when $default != null:
return $default(_that.heatmap,_that.weightTrend,_that.prChart,_that.muscleBalance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<HeatmapPoint> heatmap,  List<WeightTrendPoint> weightTrend,  List<PRChartPoint> prChart,  List<MuscleBalancePoint> muscleBalance)  $default,) {final _that = this;
switch (_that) {
case _AnalyticsResult():
return $default(_that.heatmap,_that.weightTrend,_that.prChart,_that.muscleBalance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<HeatmapPoint> heatmap,  List<WeightTrendPoint> weightTrend,  List<PRChartPoint> prChart,  List<MuscleBalancePoint> muscleBalance)?  $default,) {final _that = this;
switch (_that) {
case _AnalyticsResult() when $default != null:
return $default(_that.heatmap,_that.weightTrend,_that.prChart,_that.muscleBalance);case _:
  return null;

}
}

}

/// @nodoc


class _AnalyticsResult implements AnalyticsResult {
  const _AnalyticsResult({required final  List<HeatmapPoint> heatmap, required final  List<WeightTrendPoint> weightTrend, required final  List<PRChartPoint> prChart, required final  List<MuscleBalancePoint> muscleBalance}): _heatmap = heatmap,_weightTrend = weightTrend,_prChart = prChart,_muscleBalance = muscleBalance;
  

 final  List<HeatmapPoint> _heatmap;
@override List<HeatmapPoint> get heatmap {
  if (_heatmap is EqualUnmodifiableListView) return _heatmap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_heatmap);
}

 final  List<WeightTrendPoint> _weightTrend;
@override List<WeightTrendPoint> get weightTrend {
  if (_weightTrend is EqualUnmodifiableListView) return _weightTrend;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weightTrend);
}

 final  List<PRChartPoint> _prChart;
@override List<PRChartPoint> get prChart {
  if (_prChart is EqualUnmodifiableListView) return _prChart;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_prChart);
}

 final  List<MuscleBalancePoint> _muscleBalance;
@override List<MuscleBalancePoint> get muscleBalance {
  if (_muscleBalance is EqualUnmodifiableListView) return _muscleBalance;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_muscleBalance);
}


/// Create a copy of AnalyticsResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyticsResultCopyWith<_AnalyticsResult> get copyWith => __$AnalyticsResultCopyWithImpl<_AnalyticsResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyticsResult&&const DeepCollectionEquality().equals(other._heatmap, _heatmap)&&const DeepCollectionEquality().equals(other._weightTrend, _weightTrend)&&const DeepCollectionEquality().equals(other._prChart, _prChart)&&const DeepCollectionEquality().equals(other._muscleBalance, _muscleBalance));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_heatmap),const DeepCollectionEquality().hash(_weightTrend),const DeepCollectionEquality().hash(_prChart),const DeepCollectionEquality().hash(_muscleBalance));

@override
String toString() {
  return 'AnalyticsResult(heatmap: $heatmap, weightTrend: $weightTrend, prChart: $prChart, muscleBalance: $muscleBalance)';
}


}

/// @nodoc
abstract mixin class _$AnalyticsResultCopyWith<$Res> implements $AnalyticsResultCopyWith<$Res> {
  factory _$AnalyticsResultCopyWith(_AnalyticsResult value, $Res Function(_AnalyticsResult) _then) = __$AnalyticsResultCopyWithImpl;
@override @useResult
$Res call({
 List<HeatmapPoint> heatmap, List<WeightTrendPoint> weightTrend, List<PRChartPoint> prChart, List<MuscleBalancePoint> muscleBalance
});




}
/// @nodoc
class __$AnalyticsResultCopyWithImpl<$Res>
    implements _$AnalyticsResultCopyWith<$Res> {
  __$AnalyticsResultCopyWithImpl(this._self, this._then);

  final _AnalyticsResult _self;
  final $Res Function(_AnalyticsResult) _then;

/// Create a copy of AnalyticsResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? heatmap = null,Object? weightTrend = null,Object? prChart = null,Object? muscleBalance = null,}) {
  return _then(_AnalyticsResult(
heatmap: null == heatmap ? _self._heatmap : heatmap // ignore: cast_nullable_to_non_nullable
as List<HeatmapPoint>,weightTrend: null == weightTrend ? _self._weightTrend : weightTrend // ignore: cast_nullable_to_non_nullable
as List<WeightTrendPoint>,prChart: null == prChart ? _self._prChart : prChart // ignore: cast_nullable_to_non_nullable
as List<PRChartPoint>,muscleBalance: null == muscleBalance ? _self._muscleBalance : muscleBalance // ignore: cast_nullable_to_non_nullable
as List<MuscleBalancePoint>,
  ));
}


}

// dart format on
