// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'achievement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Achievement {

 String get achievementId; String get title; String get description; DateTime? get unlockedAt; bool get isEarned;
/// Create a copy of Achievement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AchievementCopyWith<Achievement> get copyWith => _$AchievementCopyWithImpl<Achievement>(this as Achievement, _$identity);

  /// Serializes this Achievement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Achievement&&(identical(other.achievementId, achievementId) || other.achievementId == achievementId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.unlockedAt, unlockedAt) || other.unlockedAt == unlockedAt)&&(identical(other.isEarned, isEarned) || other.isEarned == isEarned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,achievementId,title,description,unlockedAt,isEarned);

@override
String toString() {
  return 'Achievement(achievementId: $achievementId, title: $title, description: $description, unlockedAt: $unlockedAt, isEarned: $isEarned)';
}


}

/// @nodoc
abstract mixin class $AchievementCopyWith<$Res>  {
  factory $AchievementCopyWith(Achievement value, $Res Function(Achievement) _then) = _$AchievementCopyWithImpl;
@useResult
$Res call({
 String achievementId, String title, String description, DateTime? unlockedAt, bool isEarned
});




}
/// @nodoc
class _$AchievementCopyWithImpl<$Res>
    implements $AchievementCopyWith<$Res> {
  _$AchievementCopyWithImpl(this._self, this._then);

  final Achievement _self;
  final $Res Function(Achievement) _then;

/// Create a copy of Achievement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? achievementId = null,Object? title = null,Object? description = null,Object? unlockedAt = freezed,Object? isEarned = null,}) {
  return _then(_self.copyWith(
achievementId: null == achievementId ? _self.achievementId : achievementId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,unlockedAt: freezed == unlockedAt ? _self.unlockedAt : unlockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isEarned: null == isEarned ? _self.isEarned : isEarned // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Achievement].
extension AchievementPatterns on Achievement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Achievement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Achievement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Achievement value)  $default,){
final _that = this;
switch (_that) {
case _Achievement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Achievement value)?  $default,){
final _that = this;
switch (_that) {
case _Achievement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String achievementId,  String title,  String description,  DateTime? unlockedAt,  bool isEarned)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Achievement() when $default != null:
return $default(_that.achievementId,_that.title,_that.description,_that.unlockedAt,_that.isEarned);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String achievementId,  String title,  String description,  DateTime? unlockedAt,  bool isEarned)  $default,) {final _that = this;
switch (_that) {
case _Achievement():
return $default(_that.achievementId,_that.title,_that.description,_that.unlockedAt,_that.isEarned);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String achievementId,  String title,  String description,  DateTime? unlockedAt,  bool isEarned)?  $default,) {final _that = this;
switch (_that) {
case _Achievement() when $default != null:
return $default(_that.achievementId,_that.title,_that.description,_that.unlockedAt,_that.isEarned);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Achievement implements Achievement {
  const _Achievement({required this.achievementId, required this.title, required this.description, this.unlockedAt, required this.isEarned});
  factory _Achievement.fromJson(Map<String, dynamic> json) => _$AchievementFromJson(json);

@override final  String achievementId;
@override final  String title;
@override final  String description;
@override final  DateTime? unlockedAt;
@override final  bool isEarned;

/// Create a copy of Achievement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AchievementCopyWith<_Achievement> get copyWith => __$AchievementCopyWithImpl<_Achievement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AchievementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Achievement&&(identical(other.achievementId, achievementId) || other.achievementId == achievementId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.unlockedAt, unlockedAt) || other.unlockedAt == unlockedAt)&&(identical(other.isEarned, isEarned) || other.isEarned == isEarned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,achievementId,title,description,unlockedAt,isEarned);

@override
String toString() {
  return 'Achievement(achievementId: $achievementId, title: $title, description: $description, unlockedAt: $unlockedAt, isEarned: $isEarned)';
}


}

/// @nodoc
abstract mixin class _$AchievementCopyWith<$Res> implements $AchievementCopyWith<$Res> {
  factory _$AchievementCopyWith(_Achievement value, $Res Function(_Achievement) _then) = __$AchievementCopyWithImpl;
@override @useResult
$Res call({
 String achievementId, String title, String description, DateTime? unlockedAt, bool isEarned
});




}
/// @nodoc
class __$AchievementCopyWithImpl<$Res>
    implements _$AchievementCopyWith<$Res> {
  __$AchievementCopyWithImpl(this._self, this._then);

  final _Achievement _self;
  final $Res Function(_Achievement) _then;

/// Create a copy of Achievement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? achievementId = null,Object? title = null,Object? description = null,Object? unlockedAt = freezed,Object? isEarned = null,}) {
  return _then(_Achievement(
achievementId: null == achievementId ? _self.achievementId : achievementId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,unlockedAt: freezed == unlockedAt ? _self.unlockedAt : unlockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isEarned: null == isEarned ? _self.isEarned : isEarned // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
