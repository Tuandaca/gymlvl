// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quest_instance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QuestInstance {

 String get id;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'quest_id') String get questId;@JsonKey(name: 'prescribed_config') List<PrescribedExercise> get config;@JsonKey(name: 'status') String get status;@JsonKey(name: 'expires_at') DateTime get expiresAt;@JsonKey(name: 'completed_at') DateTime? get completedAt;@JsonKey(name: 'earned_xp') int? get earnedXp;
/// Create a copy of QuestInstance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuestInstanceCopyWith<QuestInstance> get copyWith => _$QuestInstanceCopyWithImpl<QuestInstance>(this as QuestInstance, _$identity);

  /// Serializes this QuestInstance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuestInstance&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.questId, questId) || other.questId == questId)&&const DeepCollectionEquality().equals(other.config, config)&&(identical(other.status, status) || other.status == status)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.earnedXp, earnedXp) || other.earnedXp == earnedXp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,questId,const DeepCollectionEquality().hash(config),status,expiresAt,completedAt,earnedXp);

@override
String toString() {
  return 'QuestInstance(id: $id, userId: $userId, questId: $questId, config: $config, status: $status, expiresAt: $expiresAt, completedAt: $completedAt, earnedXp: $earnedXp)';
}


}

/// @nodoc
abstract mixin class $QuestInstanceCopyWith<$Res>  {
  factory $QuestInstanceCopyWith(QuestInstance value, $Res Function(QuestInstance) _then) = _$QuestInstanceCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'quest_id') String questId,@JsonKey(name: 'prescribed_config') List<PrescribedExercise> config,@JsonKey(name: 'status') String status,@JsonKey(name: 'expires_at') DateTime expiresAt,@JsonKey(name: 'completed_at') DateTime? completedAt,@JsonKey(name: 'earned_xp') int? earnedXp
});




}
/// @nodoc
class _$QuestInstanceCopyWithImpl<$Res>
    implements $QuestInstanceCopyWith<$Res> {
  _$QuestInstanceCopyWithImpl(this._self, this._then);

  final QuestInstance _self;
  final $Res Function(QuestInstance) _then;

/// Create a copy of QuestInstance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? questId = null,Object? config = null,Object? status = null,Object? expiresAt = null,Object? completedAt = freezed,Object? earnedXp = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,questId: null == questId ? _self.questId : questId // ignore: cast_nullable_to_non_nullable
as String,config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as List<PrescribedExercise>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,earnedXp: freezed == earnedXp ? _self.earnedXp : earnedXp // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [QuestInstance].
extension QuestInstancePatterns on QuestInstance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuestInstance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuestInstance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuestInstance value)  $default,){
final _that = this;
switch (_that) {
case _QuestInstance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuestInstance value)?  $default,){
final _that = this;
switch (_that) {
case _QuestInstance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'quest_id')  String questId, @JsonKey(name: 'prescribed_config')  List<PrescribedExercise> config, @JsonKey(name: 'status')  String status, @JsonKey(name: 'expires_at')  DateTime expiresAt, @JsonKey(name: 'completed_at')  DateTime? completedAt, @JsonKey(name: 'earned_xp')  int? earnedXp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuestInstance() when $default != null:
return $default(_that.id,_that.userId,_that.questId,_that.config,_that.status,_that.expiresAt,_that.completedAt,_that.earnedXp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'quest_id')  String questId, @JsonKey(name: 'prescribed_config')  List<PrescribedExercise> config, @JsonKey(name: 'status')  String status, @JsonKey(name: 'expires_at')  DateTime expiresAt, @JsonKey(name: 'completed_at')  DateTime? completedAt, @JsonKey(name: 'earned_xp')  int? earnedXp)  $default,) {final _that = this;
switch (_that) {
case _QuestInstance():
return $default(_that.id,_that.userId,_that.questId,_that.config,_that.status,_that.expiresAt,_that.completedAt,_that.earnedXp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'quest_id')  String questId, @JsonKey(name: 'prescribed_config')  List<PrescribedExercise> config, @JsonKey(name: 'status')  String status, @JsonKey(name: 'expires_at')  DateTime expiresAt, @JsonKey(name: 'completed_at')  DateTime? completedAt, @JsonKey(name: 'earned_xp')  int? earnedXp)?  $default,) {final _that = this;
switch (_that) {
case _QuestInstance() when $default != null:
return $default(_that.id,_that.userId,_that.questId,_that.config,_that.status,_that.expiresAt,_that.completedAt,_that.earnedXp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuestInstance implements QuestInstance {
  const _QuestInstance({required this.id, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'quest_id') required this.questId, @JsonKey(name: 'prescribed_config') required final  List<PrescribedExercise> config, @JsonKey(name: 'status') required this.status, @JsonKey(name: 'expires_at') required this.expiresAt, @JsonKey(name: 'completed_at') this.completedAt, @JsonKey(name: 'earned_xp') this.earnedXp}): _config = config;
  factory _QuestInstance.fromJson(Map<String, dynamic> json) => _$QuestInstanceFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'quest_id') final  String questId;
 final  List<PrescribedExercise> _config;
@override@JsonKey(name: 'prescribed_config') List<PrescribedExercise> get config {
  if (_config is EqualUnmodifiableListView) return _config;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_config);
}

@override@JsonKey(name: 'status') final  String status;
@override@JsonKey(name: 'expires_at') final  DateTime expiresAt;
@override@JsonKey(name: 'completed_at') final  DateTime? completedAt;
@override@JsonKey(name: 'earned_xp') final  int? earnedXp;

/// Create a copy of QuestInstance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuestInstanceCopyWith<_QuestInstance> get copyWith => __$QuestInstanceCopyWithImpl<_QuestInstance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuestInstanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuestInstance&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.questId, questId) || other.questId == questId)&&const DeepCollectionEquality().equals(other._config, _config)&&(identical(other.status, status) || other.status == status)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.earnedXp, earnedXp) || other.earnedXp == earnedXp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,questId,const DeepCollectionEquality().hash(_config),status,expiresAt,completedAt,earnedXp);

@override
String toString() {
  return 'QuestInstance(id: $id, userId: $userId, questId: $questId, config: $config, status: $status, expiresAt: $expiresAt, completedAt: $completedAt, earnedXp: $earnedXp)';
}


}

/// @nodoc
abstract mixin class _$QuestInstanceCopyWith<$Res> implements $QuestInstanceCopyWith<$Res> {
  factory _$QuestInstanceCopyWith(_QuestInstance value, $Res Function(_QuestInstance) _then) = __$QuestInstanceCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'quest_id') String questId,@JsonKey(name: 'prescribed_config') List<PrescribedExercise> config,@JsonKey(name: 'status') String status,@JsonKey(name: 'expires_at') DateTime expiresAt,@JsonKey(name: 'completed_at') DateTime? completedAt,@JsonKey(name: 'earned_xp') int? earnedXp
});




}
/// @nodoc
class __$QuestInstanceCopyWithImpl<$Res>
    implements _$QuestInstanceCopyWith<$Res> {
  __$QuestInstanceCopyWithImpl(this._self, this._then);

  final _QuestInstance _self;
  final $Res Function(_QuestInstance) _then;

/// Create a copy of QuestInstance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? questId = null,Object? config = null,Object? status = null,Object? expiresAt = null,Object? completedAt = freezed,Object? earnedXp = freezed,}) {
  return _then(_QuestInstance(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,questId: null == questId ? _self.questId : questId // ignore: cast_nullable_to_non_nullable
as String,config: null == config ? _self._config : config // ignore: cast_nullable_to_non_nullable
as List<PrescribedExercise>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,earnedXp: freezed == earnedXp ? _self.earnedXp : earnedXp // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$PrescribedExercise {

@JsonKey(name: 'exercise_id') String get exerciseId;@JsonKey(name: 'exercise_name') String get exerciseName; int get sets; int get reps;@JsonKey(name: 'weight_kg') double get weightKg;
/// Create a copy of PrescribedExercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrescribedExerciseCopyWith<PrescribedExercise> get copyWith => _$PrescribedExerciseCopyWithImpl<PrescribedExercise>(this as PrescribedExercise, _$identity);

  /// Serializes this PrescribedExercise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrescribedExercise&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseId,exerciseName,sets,reps,weightKg);

@override
String toString() {
  return 'PrescribedExercise(exerciseId: $exerciseId, exerciseName: $exerciseName, sets: $sets, reps: $reps, weightKg: $weightKg)';
}


}

/// @nodoc
abstract mixin class $PrescribedExerciseCopyWith<$Res>  {
  factory $PrescribedExerciseCopyWith(PrescribedExercise value, $Res Function(PrescribedExercise) _then) = _$PrescribedExerciseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'exercise_id') String exerciseId,@JsonKey(name: 'exercise_name') String exerciseName, int sets, int reps,@JsonKey(name: 'weight_kg') double weightKg
});




}
/// @nodoc
class _$PrescribedExerciseCopyWithImpl<$Res>
    implements $PrescribedExerciseCopyWith<$Res> {
  _$PrescribedExerciseCopyWithImpl(this._self, this._then);

  final PrescribedExercise _self;
  final $Res Function(PrescribedExercise) _then;

/// Create a copy of PrescribedExercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseId = null,Object? exerciseName = null,Object? sets = null,Object? reps = null,Object? weightKg = null,}) {
  return _then(_self.copyWith(
exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PrescribedExercise].
extension PrescribedExercisePatterns on PrescribedExercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrescribedExercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrescribedExercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrescribedExercise value)  $default,){
final _that = this;
switch (_that) {
case _PrescribedExercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrescribedExercise value)?  $default,){
final _that = this;
switch (_that) {
case _PrescribedExercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'exercise_id')  String exerciseId, @JsonKey(name: 'exercise_name')  String exerciseName,  int sets,  int reps, @JsonKey(name: 'weight_kg')  double weightKg)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrescribedExercise() when $default != null:
return $default(_that.exerciseId,_that.exerciseName,_that.sets,_that.reps,_that.weightKg);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'exercise_id')  String exerciseId, @JsonKey(name: 'exercise_name')  String exerciseName,  int sets,  int reps, @JsonKey(name: 'weight_kg')  double weightKg)  $default,) {final _that = this;
switch (_that) {
case _PrescribedExercise():
return $default(_that.exerciseId,_that.exerciseName,_that.sets,_that.reps,_that.weightKg);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'exercise_id')  String exerciseId, @JsonKey(name: 'exercise_name')  String exerciseName,  int sets,  int reps, @JsonKey(name: 'weight_kg')  double weightKg)?  $default,) {final _that = this;
switch (_that) {
case _PrescribedExercise() when $default != null:
return $default(_that.exerciseId,_that.exerciseName,_that.sets,_that.reps,_that.weightKg);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrescribedExercise implements PrescribedExercise {
  const _PrescribedExercise({@JsonKey(name: 'exercise_id') required this.exerciseId, @JsonKey(name: 'exercise_name') required this.exerciseName, required this.sets, required this.reps, @JsonKey(name: 'weight_kg') required this.weightKg});
  factory _PrescribedExercise.fromJson(Map<String, dynamic> json) => _$PrescribedExerciseFromJson(json);

@override@JsonKey(name: 'exercise_id') final  String exerciseId;
@override@JsonKey(name: 'exercise_name') final  String exerciseName;
@override final  int sets;
@override final  int reps;
@override@JsonKey(name: 'weight_kg') final  double weightKg;

/// Create a copy of PrescribedExercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrescribedExerciseCopyWith<_PrescribedExercise> get copyWith => __$PrescribedExerciseCopyWithImpl<_PrescribedExercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrescribedExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrescribedExercise&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseId,exerciseName,sets,reps,weightKg);

@override
String toString() {
  return 'PrescribedExercise(exerciseId: $exerciseId, exerciseName: $exerciseName, sets: $sets, reps: $reps, weightKg: $weightKg)';
}


}

/// @nodoc
abstract mixin class _$PrescribedExerciseCopyWith<$Res> implements $PrescribedExerciseCopyWith<$Res> {
  factory _$PrescribedExerciseCopyWith(_PrescribedExercise value, $Res Function(_PrescribedExercise) _then) = __$PrescribedExerciseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'exercise_id') String exerciseId,@JsonKey(name: 'exercise_name') String exerciseName, int sets, int reps,@JsonKey(name: 'weight_kg') double weightKg
});




}
/// @nodoc
class __$PrescribedExerciseCopyWithImpl<$Res>
    implements _$PrescribedExerciseCopyWith<$Res> {
  __$PrescribedExerciseCopyWithImpl(this._self, this._then);

  final _PrescribedExercise _self;
  final $Res Function(_PrescribedExercise) _then;

/// Create a copy of PrescribedExercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseId = null,Object? exerciseName = null,Object? sets = null,Object? reps = null,Object? weightKg = null,}) {
  return _then(_PrescribedExercise(
exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
