// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_workout_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostWorkoutResult {

 String get message; int get earnedXP; int get totalXP; int get newLevel; bool get leveledUp; bool get isQuest; String? get newTitle; int get nextLevelXp; bool get isSuspicious; List<ClassResult> get classResults; List<String> get achievements; int get streak;
/// Create a copy of PostWorkoutResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostWorkoutResultCopyWith<PostWorkoutResult> get copyWith => _$PostWorkoutResultCopyWithImpl<PostWorkoutResult>(this as PostWorkoutResult, _$identity);

  /// Serializes this PostWorkoutResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostWorkoutResult&&(identical(other.message, message) || other.message == message)&&(identical(other.earnedXP, earnedXP) || other.earnedXP == earnedXP)&&(identical(other.totalXP, totalXP) || other.totalXP == totalXP)&&(identical(other.newLevel, newLevel) || other.newLevel == newLevel)&&(identical(other.leveledUp, leveledUp) || other.leveledUp == leveledUp)&&(identical(other.isQuest, isQuest) || other.isQuest == isQuest)&&(identical(other.newTitle, newTitle) || other.newTitle == newTitle)&&(identical(other.nextLevelXp, nextLevelXp) || other.nextLevelXp == nextLevelXp)&&(identical(other.isSuspicious, isSuspicious) || other.isSuspicious == isSuspicious)&&const DeepCollectionEquality().equals(other.classResults, classResults)&&const DeepCollectionEquality().equals(other.achievements, achievements)&&(identical(other.streak, streak) || other.streak == streak));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,earnedXP,totalXP,newLevel,leveledUp,isQuest,newTitle,nextLevelXp,isSuspicious,const DeepCollectionEquality().hash(classResults),const DeepCollectionEquality().hash(achievements),streak);

@override
String toString() {
  return 'PostWorkoutResult(message: $message, earnedXP: $earnedXP, totalXP: $totalXP, newLevel: $newLevel, leveledUp: $leveledUp, isQuest: $isQuest, newTitle: $newTitle, nextLevelXp: $nextLevelXp, isSuspicious: $isSuspicious, classResults: $classResults, achievements: $achievements, streak: $streak)';
}


}

/// @nodoc
abstract mixin class $PostWorkoutResultCopyWith<$Res>  {
  factory $PostWorkoutResultCopyWith(PostWorkoutResult value, $Res Function(PostWorkoutResult) _then) = _$PostWorkoutResultCopyWithImpl;
@useResult
$Res call({
 String message, int earnedXP, int totalXP, int newLevel, bool leveledUp, bool isQuest, String? newTitle, int nextLevelXp, bool isSuspicious, List<ClassResult> classResults, List<String> achievements, int streak
});




}
/// @nodoc
class _$PostWorkoutResultCopyWithImpl<$Res>
    implements $PostWorkoutResultCopyWith<$Res> {
  _$PostWorkoutResultCopyWithImpl(this._self, this._then);

  final PostWorkoutResult _self;
  final $Res Function(PostWorkoutResult) _then;

/// Create a copy of PostWorkoutResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,Object? earnedXP = null,Object? totalXP = null,Object? newLevel = null,Object? leveledUp = null,Object? isQuest = null,Object? newTitle = freezed,Object? nextLevelXp = null,Object? isSuspicious = null,Object? classResults = null,Object? achievements = null,Object? streak = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,earnedXP: null == earnedXP ? _self.earnedXP : earnedXP // ignore: cast_nullable_to_non_nullable
as int,totalXP: null == totalXP ? _self.totalXP : totalXP // ignore: cast_nullable_to_non_nullable
as int,newLevel: null == newLevel ? _self.newLevel : newLevel // ignore: cast_nullable_to_non_nullable
as int,leveledUp: null == leveledUp ? _self.leveledUp : leveledUp // ignore: cast_nullable_to_non_nullable
as bool,isQuest: null == isQuest ? _self.isQuest : isQuest // ignore: cast_nullable_to_non_nullable
as bool,newTitle: freezed == newTitle ? _self.newTitle : newTitle // ignore: cast_nullable_to_non_nullable
as String?,nextLevelXp: null == nextLevelXp ? _self.nextLevelXp : nextLevelXp // ignore: cast_nullable_to_non_nullable
as int,isSuspicious: null == isSuspicious ? _self.isSuspicious : isSuspicious // ignore: cast_nullable_to_non_nullable
as bool,classResults: null == classResults ? _self.classResults : classResults // ignore: cast_nullable_to_non_nullable
as List<ClassResult>,achievements: null == achievements ? _self.achievements : achievements // ignore: cast_nullable_to_non_nullable
as List<String>,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PostWorkoutResult].
extension PostWorkoutResultPatterns on PostWorkoutResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostWorkoutResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostWorkoutResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostWorkoutResult value)  $default,){
final _that = this;
switch (_that) {
case _PostWorkoutResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostWorkoutResult value)?  $default,){
final _that = this;
switch (_that) {
case _PostWorkoutResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String message,  int earnedXP,  int totalXP,  int newLevel,  bool leveledUp,  bool isQuest,  String? newTitle,  int nextLevelXp,  bool isSuspicious,  List<ClassResult> classResults,  List<String> achievements,  int streak)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostWorkoutResult() when $default != null:
return $default(_that.message,_that.earnedXP,_that.totalXP,_that.newLevel,_that.leveledUp,_that.isQuest,_that.newTitle,_that.nextLevelXp,_that.isSuspicious,_that.classResults,_that.achievements,_that.streak);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String message,  int earnedXP,  int totalXP,  int newLevel,  bool leveledUp,  bool isQuest,  String? newTitle,  int nextLevelXp,  bool isSuspicious,  List<ClassResult> classResults,  List<String> achievements,  int streak)  $default,) {final _that = this;
switch (_that) {
case _PostWorkoutResult():
return $default(_that.message,_that.earnedXP,_that.totalXP,_that.newLevel,_that.leveledUp,_that.isQuest,_that.newTitle,_that.nextLevelXp,_that.isSuspicious,_that.classResults,_that.achievements,_that.streak);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String message,  int earnedXP,  int totalXP,  int newLevel,  bool leveledUp,  bool isQuest,  String? newTitle,  int nextLevelXp,  bool isSuspicious,  List<ClassResult> classResults,  List<String> achievements,  int streak)?  $default,) {final _that = this;
switch (_that) {
case _PostWorkoutResult() when $default != null:
return $default(_that.message,_that.earnedXP,_that.totalXP,_that.newLevel,_that.leveledUp,_that.isQuest,_that.newTitle,_that.nextLevelXp,_that.isSuspicious,_that.classResults,_that.achievements,_that.streak);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostWorkoutResult implements PostWorkoutResult {
  const _PostWorkoutResult({required this.message, required this.earnedXP, required this.totalXP, required this.newLevel, required this.leveledUp, required this.isQuest, this.newTitle, required this.nextLevelXp, required this.isSuspicious, final  List<ClassResult> classResults = const [], final  List<String> achievements = const [], required this.streak}): _classResults = classResults,_achievements = achievements;
  factory _PostWorkoutResult.fromJson(Map<String, dynamic> json) => _$PostWorkoutResultFromJson(json);

@override final  String message;
@override final  int earnedXP;
@override final  int totalXP;
@override final  int newLevel;
@override final  bool leveledUp;
@override final  bool isQuest;
@override final  String? newTitle;
@override final  int nextLevelXp;
@override final  bool isSuspicious;
 final  List<ClassResult> _classResults;
@override@JsonKey() List<ClassResult> get classResults {
  if (_classResults is EqualUnmodifiableListView) return _classResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_classResults);
}

 final  List<String> _achievements;
@override@JsonKey() List<String> get achievements {
  if (_achievements is EqualUnmodifiableListView) return _achievements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_achievements);
}

@override final  int streak;

/// Create a copy of PostWorkoutResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostWorkoutResultCopyWith<_PostWorkoutResult> get copyWith => __$PostWorkoutResultCopyWithImpl<_PostWorkoutResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostWorkoutResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostWorkoutResult&&(identical(other.message, message) || other.message == message)&&(identical(other.earnedXP, earnedXP) || other.earnedXP == earnedXP)&&(identical(other.totalXP, totalXP) || other.totalXP == totalXP)&&(identical(other.newLevel, newLevel) || other.newLevel == newLevel)&&(identical(other.leveledUp, leveledUp) || other.leveledUp == leveledUp)&&(identical(other.isQuest, isQuest) || other.isQuest == isQuest)&&(identical(other.newTitle, newTitle) || other.newTitle == newTitle)&&(identical(other.nextLevelXp, nextLevelXp) || other.nextLevelXp == nextLevelXp)&&(identical(other.isSuspicious, isSuspicious) || other.isSuspicious == isSuspicious)&&const DeepCollectionEquality().equals(other._classResults, _classResults)&&const DeepCollectionEquality().equals(other._achievements, _achievements)&&(identical(other.streak, streak) || other.streak == streak));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,earnedXP,totalXP,newLevel,leveledUp,isQuest,newTitle,nextLevelXp,isSuspicious,const DeepCollectionEquality().hash(_classResults),const DeepCollectionEquality().hash(_achievements),streak);

@override
String toString() {
  return 'PostWorkoutResult(message: $message, earnedXP: $earnedXP, totalXP: $totalXP, newLevel: $newLevel, leveledUp: $leveledUp, isQuest: $isQuest, newTitle: $newTitle, nextLevelXp: $nextLevelXp, isSuspicious: $isSuspicious, classResults: $classResults, achievements: $achievements, streak: $streak)';
}


}

/// @nodoc
abstract mixin class _$PostWorkoutResultCopyWith<$Res> implements $PostWorkoutResultCopyWith<$Res> {
  factory _$PostWorkoutResultCopyWith(_PostWorkoutResult value, $Res Function(_PostWorkoutResult) _then) = __$PostWorkoutResultCopyWithImpl;
@override @useResult
$Res call({
 String message, int earnedXP, int totalXP, int newLevel, bool leveledUp, bool isQuest, String? newTitle, int nextLevelXp, bool isSuspicious, List<ClassResult> classResults, List<String> achievements, int streak
});




}
/// @nodoc
class __$PostWorkoutResultCopyWithImpl<$Res>
    implements _$PostWorkoutResultCopyWith<$Res> {
  __$PostWorkoutResultCopyWithImpl(this._self, this._then);

  final _PostWorkoutResult _self;
  final $Res Function(_PostWorkoutResult) _then;

/// Create a copy of PostWorkoutResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? earnedXP = null,Object? totalXP = null,Object? newLevel = null,Object? leveledUp = null,Object? isQuest = null,Object? newTitle = freezed,Object? nextLevelXp = null,Object? isSuspicious = null,Object? classResults = null,Object? achievements = null,Object? streak = null,}) {
  return _then(_PostWorkoutResult(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,earnedXP: null == earnedXP ? _self.earnedXP : earnedXP // ignore: cast_nullable_to_non_nullable
as int,totalXP: null == totalXP ? _self.totalXP : totalXP // ignore: cast_nullable_to_non_nullable
as int,newLevel: null == newLevel ? _self.newLevel : newLevel // ignore: cast_nullable_to_non_nullable
as int,leveledUp: null == leveledUp ? _self.leveledUp : leveledUp // ignore: cast_nullable_to_non_nullable
as bool,isQuest: null == isQuest ? _self.isQuest : isQuest // ignore: cast_nullable_to_non_nullable
as bool,newTitle: freezed == newTitle ? _self.newTitle : newTitle // ignore: cast_nullable_to_non_nullable
as String?,nextLevelXp: null == nextLevelXp ? _self.nextLevelXp : nextLevelXp // ignore: cast_nullable_to_non_nullable
as int,isSuspicious: null == isSuspicious ? _self.isSuspicious : isSuspicious // ignore: cast_nullable_to_non_nullable
as bool,classResults: null == classResults ? _self._classResults : classResults // ignore: cast_nullable_to_non_nullable
as List<ClassResult>,achievements: null == achievements ? _self._achievements : achievements // ignore: cast_nullable_to_non_nullable
as List<String>,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ClassResult {

 String get classId; String get className; String get slot; int get xpEarned; int get newTotalXP; int get newLevel; bool get leveledUp; bool get isGraduation;
/// Create a copy of ClassResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClassResultCopyWith<ClassResult> get copyWith => _$ClassResultCopyWithImpl<ClassResult>(this as ClassResult, _$identity);

  /// Serializes this ClassResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClassResult&&(identical(other.classId, classId) || other.classId == classId)&&(identical(other.className, className) || other.className == className)&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.xpEarned, xpEarned) || other.xpEarned == xpEarned)&&(identical(other.newTotalXP, newTotalXP) || other.newTotalXP == newTotalXP)&&(identical(other.newLevel, newLevel) || other.newLevel == newLevel)&&(identical(other.leveledUp, leveledUp) || other.leveledUp == leveledUp)&&(identical(other.isGraduation, isGraduation) || other.isGraduation == isGraduation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,classId,className,slot,xpEarned,newTotalXP,newLevel,leveledUp,isGraduation);

@override
String toString() {
  return 'ClassResult(classId: $classId, className: $className, slot: $slot, xpEarned: $xpEarned, newTotalXP: $newTotalXP, newLevel: $newLevel, leveledUp: $leveledUp, isGraduation: $isGraduation)';
}


}

/// @nodoc
abstract mixin class $ClassResultCopyWith<$Res>  {
  factory $ClassResultCopyWith(ClassResult value, $Res Function(ClassResult) _then) = _$ClassResultCopyWithImpl;
@useResult
$Res call({
 String classId, String className, String slot, int xpEarned, int newTotalXP, int newLevel, bool leveledUp, bool isGraduation
});




}
/// @nodoc
class _$ClassResultCopyWithImpl<$Res>
    implements $ClassResultCopyWith<$Res> {
  _$ClassResultCopyWithImpl(this._self, this._then);

  final ClassResult _self;
  final $Res Function(ClassResult) _then;

/// Create a copy of ClassResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? classId = null,Object? className = null,Object? slot = null,Object? xpEarned = null,Object? newTotalXP = null,Object? newLevel = null,Object? leveledUp = null,Object? isGraduation = null,}) {
  return _then(_self.copyWith(
classId: null == classId ? _self.classId : classId // ignore: cast_nullable_to_non_nullable
as String,className: null == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as String,xpEarned: null == xpEarned ? _self.xpEarned : xpEarned // ignore: cast_nullable_to_non_nullable
as int,newTotalXP: null == newTotalXP ? _self.newTotalXP : newTotalXP // ignore: cast_nullable_to_non_nullable
as int,newLevel: null == newLevel ? _self.newLevel : newLevel // ignore: cast_nullable_to_non_nullable
as int,leveledUp: null == leveledUp ? _self.leveledUp : leveledUp // ignore: cast_nullable_to_non_nullable
as bool,isGraduation: null == isGraduation ? _self.isGraduation : isGraduation // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ClassResult].
extension ClassResultPatterns on ClassResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClassResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClassResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClassResult value)  $default,){
final _that = this;
switch (_that) {
case _ClassResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClassResult value)?  $default,){
final _that = this;
switch (_that) {
case _ClassResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String classId,  String className,  String slot,  int xpEarned,  int newTotalXP,  int newLevel,  bool leveledUp,  bool isGraduation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClassResult() when $default != null:
return $default(_that.classId,_that.className,_that.slot,_that.xpEarned,_that.newTotalXP,_that.newLevel,_that.leveledUp,_that.isGraduation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String classId,  String className,  String slot,  int xpEarned,  int newTotalXP,  int newLevel,  bool leveledUp,  bool isGraduation)  $default,) {final _that = this;
switch (_that) {
case _ClassResult():
return $default(_that.classId,_that.className,_that.slot,_that.xpEarned,_that.newTotalXP,_that.newLevel,_that.leveledUp,_that.isGraduation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String classId,  String className,  String slot,  int xpEarned,  int newTotalXP,  int newLevel,  bool leveledUp,  bool isGraduation)?  $default,) {final _that = this;
switch (_that) {
case _ClassResult() when $default != null:
return $default(_that.classId,_that.className,_that.slot,_that.xpEarned,_that.newTotalXP,_that.newLevel,_that.leveledUp,_that.isGraduation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClassResult implements ClassResult {
  const _ClassResult({required this.classId, required this.className, required this.slot, required this.xpEarned, required this.newTotalXP, required this.newLevel, required this.leveledUp, required this.isGraduation});
  factory _ClassResult.fromJson(Map<String, dynamic> json) => _$ClassResultFromJson(json);

@override final  String classId;
@override final  String className;
@override final  String slot;
@override final  int xpEarned;
@override final  int newTotalXP;
@override final  int newLevel;
@override final  bool leveledUp;
@override final  bool isGraduation;

/// Create a copy of ClassResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClassResultCopyWith<_ClassResult> get copyWith => __$ClassResultCopyWithImpl<_ClassResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClassResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClassResult&&(identical(other.classId, classId) || other.classId == classId)&&(identical(other.className, className) || other.className == className)&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.xpEarned, xpEarned) || other.xpEarned == xpEarned)&&(identical(other.newTotalXP, newTotalXP) || other.newTotalXP == newTotalXP)&&(identical(other.newLevel, newLevel) || other.newLevel == newLevel)&&(identical(other.leveledUp, leveledUp) || other.leveledUp == leveledUp)&&(identical(other.isGraduation, isGraduation) || other.isGraduation == isGraduation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,classId,className,slot,xpEarned,newTotalXP,newLevel,leveledUp,isGraduation);

@override
String toString() {
  return 'ClassResult(classId: $classId, className: $className, slot: $slot, xpEarned: $xpEarned, newTotalXP: $newTotalXP, newLevel: $newLevel, leveledUp: $leveledUp, isGraduation: $isGraduation)';
}


}

/// @nodoc
abstract mixin class _$ClassResultCopyWith<$Res> implements $ClassResultCopyWith<$Res> {
  factory _$ClassResultCopyWith(_ClassResult value, $Res Function(_ClassResult) _then) = __$ClassResultCopyWithImpl;
@override @useResult
$Res call({
 String classId, String className, String slot, int xpEarned, int newTotalXP, int newLevel, bool leveledUp, bool isGraduation
});




}
/// @nodoc
class __$ClassResultCopyWithImpl<$Res>
    implements _$ClassResultCopyWith<$Res> {
  __$ClassResultCopyWithImpl(this._self, this._then);

  final _ClassResult _self;
  final $Res Function(_ClassResult) _then;

/// Create a copy of ClassResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? classId = null,Object? className = null,Object? slot = null,Object? xpEarned = null,Object? newTotalXP = null,Object? newLevel = null,Object? leveledUp = null,Object? isGraduation = null,}) {
  return _then(_ClassResult(
classId: null == classId ? _self.classId : classId // ignore: cast_nullable_to_non_nullable
as String,className: null == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as String,xpEarned: null == xpEarned ? _self.xpEarned : xpEarned // ignore: cast_nullable_to_non_nullable
as int,newTotalXP: null == newTotalXP ? _self.newTotalXP : newTotalXP // ignore: cast_nullable_to_non_nullable
as int,newLevel: null == newLevel ? _self.newLevel : newLevel // ignore: cast_nullable_to_non_nullable
as int,leveledUp: null == leveledUp ? _self.leveledUp : leveledUp // ignore: cast_nullable_to_non_nullable
as bool,isGraduation: null == isGraduation ? _self.isGraduation : isGraduation // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
