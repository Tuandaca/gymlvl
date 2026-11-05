// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_progression.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlayerProgression {

 String get userId; int get level; int get totalXP; String? get currentTitle; DateTime? get lastWorkoutDate; StreakInfo? get streak; List<AchievementSummary> get achievements; List<ClassProgress> get classes; Map<String, dynamic>? get activeQuest; Map<String, dynamic>? get nextUnlock; int get xpToNextLevel;
/// Create a copy of PlayerProgression
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerProgressionCopyWith<PlayerProgression> get copyWith => _$PlayerProgressionCopyWithImpl<PlayerProgression>(this as PlayerProgression, _$identity);

  /// Serializes this PlayerProgression to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerProgression&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.level, level) || other.level == level)&&(identical(other.totalXP, totalXP) || other.totalXP == totalXP)&&(identical(other.currentTitle, currentTitle) || other.currentTitle == currentTitle)&&(identical(other.lastWorkoutDate, lastWorkoutDate) || other.lastWorkoutDate == lastWorkoutDate)&&(identical(other.streak, streak) || other.streak == streak)&&const DeepCollectionEquality().equals(other.achievements, achievements)&&const DeepCollectionEquality().equals(other.classes, classes)&&const DeepCollectionEquality().equals(other.activeQuest, activeQuest)&&const DeepCollectionEquality().equals(other.nextUnlock, nextUnlock)&&(identical(other.xpToNextLevel, xpToNextLevel) || other.xpToNextLevel == xpToNextLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,level,totalXP,currentTitle,lastWorkoutDate,streak,const DeepCollectionEquality().hash(achievements),const DeepCollectionEquality().hash(classes),const DeepCollectionEquality().hash(activeQuest),const DeepCollectionEquality().hash(nextUnlock),xpToNextLevel);

@override
String toString() {
  return 'PlayerProgression(userId: $userId, level: $level, totalXP: $totalXP, currentTitle: $currentTitle, lastWorkoutDate: $lastWorkoutDate, streak: $streak, achievements: $achievements, classes: $classes, activeQuest: $activeQuest, nextUnlock: $nextUnlock, xpToNextLevel: $xpToNextLevel)';
}


}

/// @nodoc
abstract mixin class $PlayerProgressionCopyWith<$Res>  {
  factory $PlayerProgressionCopyWith(PlayerProgression value, $Res Function(PlayerProgression) _then) = _$PlayerProgressionCopyWithImpl;
@useResult
$Res call({
 String userId, int level, int totalXP, String? currentTitle, DateTime? lastWorkoutDate, StreakInfo? streak, List<AchievementSummary> achievements, List<ClassProgress> classes, Map<String, dynamic>? activeQuest, Map<String, dynamic>? nextUnlock, int xpToNextLevel
});


$StreakInfoCopyWith<$Res>? get streak;

}
/// @nodoc
class _$PlayerProgressionCopyWithImpl<$Res>
    implements $PlayerProgressionCopyWith<$Res> {
  _$PlayerProgressionCopyWithImpl(this._self, this._then);

  final PlayerProgression _self;
  final $Res Function(PlayerProgression) _then;

/// Create a copy of PlayerProgression
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? level = null,Object? totalXP = null,Object? currentTitle = freezed,Object? lastWorkoutDate = freezed,Object? streak = freezed,Object? achievements = null,Object? classes = null,Object? activeQuest = freezed,Object? nextUnlock = freezed,Object? xpToNextLevel = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,totalXP: null == totalXP ? _self.totalXP : totalXP // ignore: cast_nullable_to_non_nullable
as int,currentTitle: freezed == currentTitle ? _self.currentTitle : currentTitle // ignore: cast_nullable_to_non_nullable
as String?,lastWorkoutDate: freezed == lastWorkoutDate ? _self.lastWorkoutDate : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
as DateTime?,streak: freezed == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as StreakInfo?,achievements: null == achievements ? _self.achievements : achievements // ignore: cast_nullable_to_non_nullable
as List<AchievementSummary>,classes: null == classes ? _self.classes : classes // ignore: cast_nullable_to_non_nullable
as List<ClassProgress>,activeQuest: freezed == activeQuest ? _self.activeQuest : activeQuest // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,nextUnlock: freezed == nextUnlock ? _self.nextUnlock : nextUnlock // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,xpToNextLevel: null == xpToNextLevel ? _self.xpToNextLevel : xpToNextLevel // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of PlayerProgression
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreakInfoCopyWith<$Res>? get streak {
    if (_self.streak == null) {
    return null;
  }

  return $StreakInfoCopyWith<$Res>(_self.streak!, (value) {
    return _then(_self.copyWith(streak: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlayerProgression].
extension PlayerProgressionPatterns on PlayerProgression {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerProgression value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerProgression() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerProgression value)  $default,){
final _that = this;
switch (_that) {
case _PlayerProgression():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerProgression value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerProgression() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  int level,  int totalXP,  String? currentTitle,  DateTime? lastWorkoutDate,  StreakInfo? streak,  List<AchievementSummary> achievements,  List<ClassProgress> classes,  Map<String, dynamic>? activeQuest,  Map<String, dynamic>? nextUnlock,  int xpToNextLevel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerProgression() when $default != null:
return $default(_that.userId,_that.level,_that.totalXP,_that.currentTitle,_that.lastWorkoutDate,_that.streak,_that.achievements,_that.classes,_that.activeQuest,_that.nextUnlock,_that.xpToNextLevel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  int level,  int totalXP,  String? currentTitle,  DateTime? lastWorkoutDate,  StreakInfo? streak,  List<AchievementSummary> achievements,  List<ClassProgress> classes,  Map<String, dynamic>? activeQuest,  Map<String, dynamic>? nextUnlock,  int xpToNextLevel)  $default,) {final _that = this;
switch (_that) {
case _PlayerProgression():
return $default(_that.userId,_that.level,_that.totalXP,_that.currentTitle,_that.lastWorkoutDate,_that.streak,_that.achievements,_that.classes,_that.activeQuest,_that.nextUnlock,_that.xpToNextLevel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  int level,  int totalXP,  String? currentTitle,  DateTime? lastWorkoutDate,  StreakInfo? streak,  List<AchievementSummary> achievements,  List<ClassProgress> classes,  Map<String, dynamic>? activeQuest,  Map<String, dynamic>? nextUnlock,  int xpToNextLevel)?  $default,) {final _that = this;
switch (_that) {
case _PlayerProgression() when $default != null:
return $default(_that.userId,_that.level,_that.totalXP,_that.currentTitle,_that.lastWorkoutDate,_that.streak,_that.achievements,_that.classes,_that.activeQuest,_that.nextUnlock,_that.xpToNextLevel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayerProgression implements PlayerProgression {
  const _PlayerProgression({required this.userId, required this.level, required this.totalXP, this.currentTitle, this.lastWorkoutDate, this.streak, final  List<AchievementSummary> achievements = const [], final  List<ClassProgress> classes = const [], final  Map<String, dynamic>? activeQuest, final  Map<String, dynamic>? nextUnlock, this.xpToNextLevel = 0}): _achievements = achievements,_classes = classes,_activeQuest = activeQuest,_nextUnlock = nextUnlock;
  factory _PlayerProgression.fromJson(Map<String, dynamic> json) => _$PlayerProgressionFromJson(json);

@override final  String userId;
@override final  int level;
@override final  int totalXP;
@override final  String? currentTitle;
@override final  DateTime? lastWorkoutDate;
@override final  StreakInfo? streak;
 final  List<AchievementSummary> _achievements;
@override@JsonKey() List<AchievementSummary> get achievements {
  if (_achievements is EqualUnmodifiableListView) return _achievements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_achievements);
}

 final  List<ClassProgress> _classes;
@override@JsonKey() List<ClassProgress> get classes {
  if (_classes is EqualUnmodifiableListView) return _classes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_classes);
}

 final  Map<String, dynamic>? _activeQuest;
@override Map<String, dynamic>? get activeQuest {
  final value = _activeQuest;
  if (value == null) return null;
  if (_activeQuest is EqualUnmodifiableMapView) return _activeQuest;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _nextUnlock;
@override Map<String, dynamic>? get nextUnlock {
  final value = _nextUnlock;
  if (value == null) return null;
  if (_nextUnlock is EqualUnmodifiableMapView) return _nextUnlock;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey() final  int xpToNextLevel;

/// Create a copy of PlayerProgression
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerProgressionCopyWith<_PlayerProgression> get copyWith => __$PlayerProgressionCopyWithImpl<_PlayerProgression>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayerProgressionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerProgression&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.level, level) || other.level == level)&&(identical(other.totalXP, totalXP) || other.totalXP == totalXP)&&(identical(other.currentTitle, currentTitle) || other.currentTitle == currentTitle)&&(identical(other.lastWorkoutDate, lastWorkoutDate) || other.lastWorkoutDate == lastWorkoutDate)&&(identical(other.streak, streak) || other.streak == streak)&&const DeepCollectionEquality().equals(other._achievements, _achievements)&&const DeepCollectionEquality().equals(other._classes, _classes)&&const DeepCollectionEquality().equals(other._activeQuest, _activeQuest)&&const DeepCollectionEquality().equals(other._nextUnlock, _nextUnlock)&&(identical(other.xpToNextLevel, xpToNextLevel) || other.xpToNextLevel == xpToNextLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,level,totalXP,currentTitle,lastWorkoutDate,streak,const DeepCollectionEquality().hash(_achievements),const DeepCollectionEquality().hash(_classes),const DeepCollectionEquality().hash(_activeQuest),const DeepCollectionEquality().hash(_nextUnlock),xpToNextLevel);

@override
String toString() {
  return 'PlayerProgression(userId: $userId, level: $level, totalXP: $totalXP, currentTitle: $currentTitle, lastWorkoutDate: $lastWorkoutDate, streak: $streak, achievements: $achievements, classes: $classes, activeQuest: $activeQuest, nextUnlock: $nextUnlock, xpToNextLevel: $xpToNextLevel)';
}


}

/// @nodoc
abstract mixin class _$PlayerProgressionCopyWith<$Res> implements $PlayerProgressionCopyWith<$Res> {
  factory _$PlayerProgressionCopyWith(_PlayerProgression value, $Res Function(_PlayerProgression) _then) = __$PlayerProgressionCopyWithImpl;
@override @useResult
$Res call({
 String userId, int level, int totalXP, String? currentTitle, DateTime? lastWorkoutDate, StreakInfo? streak, List<AchievementSummary> achievements, List<ClassProgress> classes, Map<String, dynamic>? activeQuest, Map<String, dynamic>? nextUnlock, int xpToNextLevel
});


@override $StreakInfoCopyWith<$Res>? get streak;

}
/// @nodoc
class __$PlayerProgressionCopyWithImpl<$Res>
    implements _$PlayerProgressionCopyWith<$Res> {
  __$PlayerProgressionCopyWithImpl(this._self, this._then);

  final _PlayerProgression _self;
  final $Res Function(_PlayerProgression) _then;

/// Create a copy of PlayerProgression
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? level = null,Object? totalXP = null,Object? currentTitle = freezed,Object? lastWorkoutDate = freezed,Object? streak = freezed,Object? achievements = null,Object? classes = null,Object? activeQuest = freezed,Object? nextUnlock = freezed,Object? xpToNextLevel = null,}) {
  return _then(_PlayerProgression(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,totalXP: null == totalXP ? _self.totalXP : totalXP // ignore: cast_nullable_to_non_nullable
as int,currentTitle: freezed == currentTitle ? _self.currentTitle : currentTitle // ignore: cast_nullable_to_non_nullable
as String?,lastWorkoutDate: freezed == lastWorkoutDate ? _self.lastWorkoutDate : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
as DateTime?,streak: freezed == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as StreakInfo?,achievements: null == achievements ? _self._achievements : achievements // ignore: cast_nullable_to_non_nullable
as List<AchievementSummary>,classes: null == classes ? _self._classes : classes // ignore: cast_nullable_to_non_nullable
as List<ClassProgress>,activeQuest: freezed == activeQuest ? _self._activeQuest : activeQuest // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,nextUnlock: freezed == nextUnlock ? _self._nextUnlock : nextUnlock // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,xpToNextLevel: null == xpToNextLevel ? _self.xpToNextLevel : xpToNextLevel // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of PlayerProgression
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreakInfoCopyWith<$Res>? get streak {
    if (_self.streak == null) {
    return null;
  }

  return $StreakInfoCopyWith<$Res>(_self.streak!, (value) {
    return _then(_self.copyWith(streak: value));
  });
}
}


/// @nodoc
mixin _$StreakInfo {

 int get currentStreak; int get longestStreak; DateTime? get lastActivityDate;
/// Create a copy of StreakInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreakInfoCopyWith<StreakInfo> get copyWith => _$StreakInfoCopyWithImpl<StreakInfo>(this as StreakInfo, _$identity);

  /// Serializes this StreakInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreakInfo&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.lastActivityDate, lastActivityDate) || other.lastActivityDate == lastActivityDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentStreak,longestStreak,lastActivityDate);

@override
String toString() {
  return 'StreakInfo(currentStreak: $currentStreak, longestStreak: $longestStreak, lastActivityDate: $lastActivityDate)';
}


}

/// @nodoc
abstract mixin class $StreakInfoCopyWith<$Res>  {
  factory $StreakInfoCopyWith(StreakInfo value, $Res Function(StreakInfo) _then) = _$StreakInfoCopyWithImpl;
@useResult
$Res call({
 int currentStreak, int longestStreak, DateTime? lastActivityDate
});




}
/// @nodoc
class _$StreakInfoCopyWithImpl<$Res>
    implements $StreakInfoCopyWith<$Res> {
  _$StreakInfoCopyWithImpl(this._self, this._then);

  final StreakInfo _self;
  final $Res Function(StreakInfo) _then;

/// Create a copy of StreakInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentStreak = null,Object? longestStreak = null,Object? lastActivityDate = freezed,}) {
  return _then(_self.copyWith(
currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,lastActivityDate: freezed == lastActivityDate ? _self.lastActivityDate : lastActivityDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [StreakInfo].
extension StreakInfoPatterns on StreakInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StreakInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StreakInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StreakInfo value)  $default,){
final _that = this;
switch (_that) {
case _StreakInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StreakInfo value)?  $default,){
final _that = this;
switch (_that) {
case _StreakInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int currentStreak,  int longestStreak,  DateTime? lastActivityDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StreakInfo() when $default != null:
return $default(_that.currentStreak,_that.longestStreak,_that.lastActivityDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int currentStreak,  int longestStreak,  DateTime? lastActivityDate)  $default,) {final _that = this;
switch (_that) {
case _StreakInfo():
return $default(_that.currentStreak,_that.longestStreak,_that.lastActivityDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int currentStreak,  int longestStreak,  DateTime? lastActivityDate)?  $default,) {final _that = this;
switch (_that) {
case _StreakInfo() when $default != null:
return $default(_that.currentStreak,_that.longestStreak,_that.lastActivityDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StreakInfo implements StreakInfo {
  const _StreakInfo({required this.currentStreak, required this.longestStreak, this.lastActivityDate});
  factory _StreakInfo.fromJson(Map<String, dynamic> json) => _$StreakInfoFromJson(json);

@override final  int currentStreak;
@override final  int longestStreak;
@override final  DateTime? lastActivityDate;

/// Create a copy of StreakInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreakInfoCopyWith<_StreakInfo> get copyWith => __$StreakInfoCopyWithImpl<_StreakInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StreakInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StreakInfo&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.lastActivityDate, lastActivityDate) || other.lastActivityDate == lastActivityDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentStreak,longestStreak,lastActivityDate);

@override
String toString() {
  return 'StreakInfo(currentStreak: $currentStreak, longestStreak: $longestStreak, lastActivityDate: $lastActivityDate)';
}


}

/// @nodoc
abstract mixin class _$StreakInfoCopyWith<$Res> implements $StreakInfoCopyWith<$Res> {
  factory _$StreakInfoCopyWith(_StreakInfo value, $Res Function(_StreakInfo) _then) = __$StreakInfoCopyWithImpl;
@override @useResult
$Res call({
 int currentStreak, int longestStreak, DateTime? lastActivityDate
});




}
/// @nodoc
class __$StreakInfoCopyWithImpl<$Res>
    implements _$StreakInfoCopyWith<$Res> {
  __$StreakInfoCopyWithImpl(this._self, this._then);

  final _StreakInfo _self;
  final $Res Function(_StreakInfo) _then;

/// Create a copy of StreakInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentStreak = null,Object? longestStreak = null,Object? lastActivityDate = freezed,}) {
  return _then(_StreakInfo(
currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,lastActivityDate: freezed == lastActivityDate ? _self.lastActivityDate : lastActivityDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ClassProgress {

 String get classId; String get className; String get slot; int get currentXP; int get level; bool get isGraduated; int? get xpBase; double? get xpSlope;
/// Create a copy of ClassProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClassProgressCopyWith<ClassProgress> get copyWith => _$ClassProgressCopyWithImpl<ClassProgress>(this as ClassProgress, _$identity);

  /// Serializes this ClassProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClassProgress&&(identical(other.classId, classId) || other.classId == classId)&&(identical(other.className, className) || other.className == className)&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.currentXP, currentXP) || other.currentXP == currentXP)&&(identical(other.level, level) || other.level == level)&&(identical(other.isGraduated, isGraduated) || other.isGraduated == isGraduated)&&(identical(other.xpBase, xpBase) || other.xpBase == xpBase)&&(identical(other.xpSlope, xpSlope) || other.xpSlope == xpSlope));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,classId,className,slot,currentXP,level,isGraduated,xpBase,xpSlope);

@override
String toString() {
  return 'ClassProgress(classId: $classId, className: $className, slot: $slot, currentXP: $currentXP, level: $level, isGraduated: $isGraduated, xpBase: $xpBase, xpSlope: $xpSlope)';
}


}

/// @nodoc
abstract mixin class $ClassProgressCopyWith<$Res>  {
  factory $ClassProgressCopyWith(ClassProgress value, $Res Function(ClassProgress) _then) = _$ClassProgressCopyWithImpl;
@useResult
$Res call({
 String classId, String className, String slot, int currentXP, int level, bool isGraduated, int? xpBase, double? xpSlope
});




}
/// @nodoc
class _$ClassProgressCopyWithImpl<$Res>
    implements $ClassProgressCopyWith<$Res> {
  _$ClassProgressCopyWithImpl(this._self, this._then);

  final ClassProgress _self;
  final $Res Function(ClassProgress) _then;

/// Create a copy of ClassProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? classId = null,Object? className = null,Object? slot = null,Object? currentXP = null,Object? level = null,Object? isGraduated = null,Object? xpBase = freezed,Object? xpSlope = freezed,}) {
  return _then(_self.copyWith(
classId: null == classId ? _self.classId : classId // ignore: cast_nullable_to_non_nullable
as String,className: null == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as String,currentXP: null == currentXP ? _self.currentXP : currentXP // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,isGraduated: null == isGraduated ? _self.isGraduated : isGraduated // ignore: cast_nullable_to_non_nullable
as bool,xpBase: freezed == xpBase ? _self.xpBase : xpBase // ignore: cast_nullable_to_non_nullable
as int?,xpSlope: freezed == xpSlope ? _self.xpSlope : xpSlope // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClassProgress].
extension ClassProgressPatterns on ClassProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClassProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClassProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClassProgress value)  $default,){
final _that = this;
switch (_that) {
case _ClassProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClassProgress value)?  $default,){
final _that = this;
switch (_that) {
case _ClassProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String classId,  String className,  String slot,  int currentXP,  int level,  bool isGraduated,  int? xpBase,  double? xpSlope)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClassProgress() when $default != null:
return $default(_that.classId,_that.className,_that.slot,_that.currentXP,_that.level,_that.isGraduated,_that.xpBase,_that.xpSlope);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String classId,  String className,  String slot,  int currentXP,  int level,  bool isGraduated,  int? xpBase,  double? xpSlope)  $default,) {final _that = this;
switch (_that) {
case _ClassProgress():
return $default(_that.classId,_that.className,_that.slot,_that.currentXP,_that.level,_that.isGraduated,_that.xpBase,_that.xpSlope);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String classId,  String className,  String slot,  int currentXP,  int level,  bool isGraduated,  int? xpBase,  double? xpSlope)?  $default,) {final _that = this;
switch (_that) {
case _ClassProgress() when $default != null:
return $default(_that.classId,_that.className,_that.slot,_that.currentXP,_that.level,_that.isGraduated,_that.xpBase,_that.xpSlope);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClassProgress implements ClassProgress {
  const _ClassProgress({required this.classId, required this.className, required this.slot, required this.currentXP, required this.level, required this.isGraduated, this.xpBase, this.xpSlope});
  factory _ClassProgress.fromJson(Map<String, dynamic> json) => _$ClassProgressFromJson(json);

@override final  String classId;
@override final  String className;
@override final  String slot;
@override final  int currentXP;
@override final  int level;
@override final  bool isGraduated;
@override final  int? xpBase;
@override final  double? xpSlope;

/// Create a copy of ClassProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClassProgressCopyWith<_ClassProgress> get copyWith => __$ClassProgressCopyWithImpl<_ClassProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClassProgressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClassProgress&&(identical(other.classId, classId) || other.classId == classId)&&(identical(other.className, className) || other.className == className)&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.currentXP, currentXP) || other.currentXP == currentXP)&&(identical(other.level, level) || other.level == level)&&(identical(other.isGraduated, isGraduated) || other.isGraduated == isGraduated)&&(identical(other.xpBase, xpBase) || other.xpBase == xpBase)&&(identical(other.xpSlope, xpSlope) || other.xpSlope == xpSlope));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,classId,className,slot,currentXP,level,isGraduated,xpBase,xpSlope);

@override
String toString() {
  return 'ClassProgress(classId: $classId, className: $className, slot: $slot, currentXP: $currentXP, level: $level, isGraduated: $isGraduated, xpBase: $xpBase, xpSlope: $xpSlope)';
}


}

/// @nodoc
abstract mixin class _$ClassProgressCopyWith<$Res> implements $ClassProgressCopyWith<$Res> {
  factory _$ClassProgressCopyWith(_ClassProgress value, $Res Function(_ClassProgress) _then) = __$ClassProgressCopyWithImpl;
@override @useResult
$Res call({
 String classId, String className, String slot, int currentXP, int level, bool isGraduated, int? xpBase, double? xpSlope
});




}
/// @nodoc
class __$ClassProgressCopyWithImpl<$Res>
    implements _$ClassProgressCopyWith<$Res> {
  __$ClassProgressCopyWithImpl(this._self, this._then);

  final _ClassProgress _self;
  final $Res Function(_ClassProgress) _then;

/// Create a copy of ClassProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? classId = null,Object? className = null,Object? slot = null,Object? currentXP = null,Object? level = null,Object? isGraduated = null,Object? xpBase = freezed,Object? xpSlope = freezed,}) {
  return _then(_ClassProgress(
classId: null == classId ? _self.classId : classId // ignore: cast_nullable_to_non_nullable
as String,className: null == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as String,currentXP: null == currentXP ? _self.currentXP : currentXP // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,isGraduated: null == isGraduated ? _self.isGraduated : isGraduated // ignore: cast_nullable_to_non_nullable
as bool,xpBase: freezed == xpBase ? _self.xpBase : xpBase // ignore: cast_nullable_to_non_nullable
as int?,xpSlope: freezed == xpSlope ? _self.xpSlope : xpSlope // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$AchievementSummary {

 String get achievementId; DateTime get unlockedAt;
/// Create a copy of AchievementSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AchievementSummaryCopyWith<AchievementSummary> get copyWith => _$AchievementSummaryCopyWithImpl<AchievementSummary>(this as AchievementSummary, _$identity);

  /// Serializes this AchievementSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AchievementSummary&&(identical(other.achievementId, achievementId) || other.achievementId == achievementId)&&(identical(other.unlockedAt, unlockedAt) || other.unlockedAt == unlockedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,achievementId,unlockedAt);

@override
String toString() {
  return 'AchievementSummary(achievementId: $achievementId, unlockedAt: $unlockedAt)';
}


}

/// @nodoc
abstract mixin class $AchievementSummaryCopyWith<$Res>  {
  factory $AchievementSummaryCopyWith(AchievementSummary value, $Res Function(AchievementSummary) _then) = _$AchievementSummaryCopyWithImpl;
@useResult
$Res call({
 String achievementId, DateTime unlockedAt
});




}
/// @nodoc
class _$AchievementSummaryCopyWithImpl<$Res>
    implements $AchievementSummaryCopyWith<$Res> {
  _$AchievementSummaryCopyWithImpl(this._self, this._then);

  final AchievementSummary _self;
  final $Res Function(AchievementSummary) _then;

/// Create a copy of AchievementSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? achievementId = null,Object? unlockedAt = null,}) {
  return _then(_self.copyWith(
achievementId: null == achievementId ? _self.achievementId : achievementId // ignore: cast_nullable_to_non_nullable
as String,unlockedAt: null == unlockedAt ? _self.unlockedAt : unlockedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AchievementSummary].
extension AchievementSummaryPatterns on AchievementSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AchievementSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AchievementSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AchievementSummary value)  $default,){
final _that = this;
switch (_that) {
case _AchievementSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AchievementSummary value)?  $default,){
final _that = this;
switch (_that) {
case _AchievementSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String achievementId,  DateTime unlockedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AchievementSummary() when $default != null:
return $default(_that.achievementId,_that.unlockedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String achievementId,  DateTime unlockedAt)  $default,) {final _that = this;
switch (_that) {
case _AchievementSummary():
return $default(_that.achievementId,_that.unlockedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String achievementId,  DateTime unlockedAt)?  $default,) {final _that = this;
switch (_that) {
case _AchievementSummary() when $default != null:
return $default(_that.achievementId,_that.unlockedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AchievementSummary implements AchievementSummary {
  const _AchievementSummary({required this.achievementId, required this.unlockedAt});
  factory _AchievementSummary.fromJson(Map<String, dynamic> json) => _$AchievementSummaryFromJson(json);

@override final  String achievementId;
@override final  DateTime unlockedAt;

/// Create a copy of AchievementSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AchievementSummaryCopyWith<_AchievementSummary> get copyWith => __$AchievementSummaryCopyWithImpl<_AchievementSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AchievementSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AchievementSummary&&(identical(other.achievementId, achievementId) || other.achievementId == achievementId)&&(identical(other.unlockedAt, unlockedAt) || other.unlockedAt == unlockedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,achievementId,unlockedAt);

@override
String toString() {
  return 'AchievementSummary(achievementId: $achievementId, unlockedAt: $unlockedAt)';
}


}

/// @nodoc
abstract mixin class _$AchievementSummaryCopyWith<$Res> implements $AchievementSummaryCopyWith<$Res> {
  factory _$AchievementSummaryCopyWith(_AchievementSummary value, $Res Function(_AchievementSummary) _then) = __$AchievementSummaryCopyWithImpl;
@override @useResult
$Res call({
 String achievementId, DateTime unlockedAt
});




}
/// @nodoc
class __$AchievementSummaryCopyWithImpl<$Res>
    implements _$AchievementSummaryCopyWith<$Res> {
  __$AchievementSummaryCopyWithImpl(this._self, this._then);

  final _AchievementSummary _self;
  final $Res Function(_AchievementSummary) _then;

/// Create a copy of AchievementSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? achievementId = null,Object? unlockedAt = null,}) {
  return _then(_AchievementSummary(
achievementId: null == achievementId ? _self.achievementId : achievementId // ignore: cast_nullable_to_non_nullable
as String,unlockedAt: null == unlockedAt ? _self.unlockedAt : unlockedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
