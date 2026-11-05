// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unlock.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Unlock {

 String get unlockId; String get title; String? get description; String get unlockType;// 'level' | 'achievement' | 'class' | 'quest'
 int get thresholdValue; String get rewardType;// 'badge' | 'title' | 'accent'
 String get rewardValue; bool get isUnlocked;
/// Create a copy of Unlock
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnlockCopyWith<Unlock> get copyWith => _$UnlockCopyWithImpl<Unlock>(this as Unlock, _$identity);

  /// Serializes this Unlock to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Unlock&&(identical(other.unlockId, unlockId) || other.unlockId == unlockId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.unlockType, unlockType) || other.unlockType == unlockType)&&(identical(other.thresholdValue, thresholdValue) || other.thresholdValue == thresholdValue)&&(identical(other.rewardType, rewardType) || other.rewardType == rewardType)&&(identical(other.rewardValue, rewardValue) || other.rewardValue == rewardValue)&&(identical(other.isUnlocked, isUnlocked) || other.isUnlocked == isUnlocked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,unlockId,title,description,unlockType,thresholdValue,rewardType,rewardValue,isUnlocked);

@override
String toString() {
  return 'Unlock(unlockId: $unlockId, title: $title, description: $description, unlockType: $unlockType, thresholdValue: $thresholdValue, rewardType: $rewardType, rewardValue: $rewardValue, isUnlocked: $isUnlocked)';
}


}

/// @nodoc
abstract mixin class $UnlockCopyWith<$Res>  {
  factory $UnlockCopyWith(Unlock value, $Res Function(Unlock) _then) = _$UnlockCopyWithImpl;
@useResult
$Res call({
 String unlockId, String title, String? description, String unlockType, int thresholdValue, String rewardType, String rewardValue, bool isUnlocked
});




}
/// @nodoc
class _$UnlockCopyWithImpl<$Res>
    implements $UnlockCopyWith<$Res> {
  _$UnlockCopyWithImpl(this._self, this._then);

  final Unlock _self;
  final $Res Function(Unlock) _then;

/// Create a copy of Unlock
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? unlockId = null,Object? title = null,Object? description = freezed,Object? unlockType = null,Object? thresholdValue = null,Object? rewardType = null,Object? rewardValue = null,Object? isUnlocked = null,}) {
  return _then(_self.copyWith(
unlockId: null == unlockId ? _self.unlockId : unlockId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,unlockType: null == unlockType ? _self.unlockType : unlockType // ignore: cast_nullable_to_non_nullable
as String,thresholdValue: null == thresholdValue ? _self.thresholdValue : thresholdValue // ignore: cast_nullable_to_non_nullable
as int,rewardType: null == rewardType ? _self.rewardType : rewardType // ignore: cast_nullable_to_non_nullable
as String,rewardValue: null == rewardValue ? _self.rewardValue : rewardValue // ignore: cast_nullable_to_non_nullable
as String,isUnlocked: null == isUnlocked ? _self.isUnlocked : isUnlocked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Unlock].
extension UnlockPatterns on Unlock {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Unlock value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Unlock() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Unlock value)  $default,){
final _that = this;
switch (_that) {
case _Unlock():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Unlock value)?  $default,){
final _that = this;
switch (_that) {
case _Unlock() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String unlockId,  String title,  String? description,  String unlockType,  int thresholdValue,  String rewardType,  String rewardValue,  bool isUnlocked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Unlock() when $default != null:
return $default(_that.unlockId,_that.title,_that.description,_that.unlockType,_that.thresholdValue,_that.rewardType,_that.rewardValue,_that.isUnlocked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String unlockId,  String title,  String? description,  String unlockType,  int thresholdValue,  String rewardType,  String rewardValue,  bool isUnlocked)  $default,) {final _that = this;
switch (_that) {
case _Unlock():
return $default(_that.unlockId,_that.title,_that.description,_that.unlockType,_that.thresholdValue,_that.rewardType,_that.rewardValue,_that.isUnlocked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String unlockId,  String title,  String? description,  String unlockType,  int thresholdValue,  String rewardType,  String rewardValue,  bool isUnlocked)?  $default,) {final _that = this;
switch (_that) {
case _Unlock() when $default != null:
return $default(_that.unlockId,_that.title,_that.description,_that.unlockType,_that.thresholdValue,_that.rewardType,_that.rewardValue,_that.isUnlocked);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Unlock implements Unlock {
  const _Unlock({required this.unlockId, required this.title, this.description, required this.unlockType, required this.thresholdValue, required this.rewardType, required this.rewardValue, required this.isUnlocked});
  factory _Unlock.fromJson(Map<String, dynamic> json) => _$UnlockFromJson(json);

@override final  String unlockId;
@override final  String title;
@override final  String? description;
@override final  String unlockType;
// 'level' | 'achievement' | 'class' | 'quest'
@override final  int thresholdValue;
@override final  String rewardType;
// 'badge' | 'title' | 'accent'
@override final  String rewardValue;
@override final  bool isUnlocked;

/// Create a copy of Unlock
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnlockCopyWith<_Unlock> get copyWith => __$UnlockCopyWithImpl<_Unlock>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnlockToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Unlock&&(identical(other.unlockId, unlockId) || other.unlockId == unlockId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.unlockType, unlockType) || other.unlockType == unlockType)&&(identical(other.thresholdValue, thresholdValue) || other.thresholdValue == thresholdValue)&&(identical(other.rewardType, rewardType) || other.rewardType == rewardType)&&(identical(other.rewardValue, rewardValue) || other.rewardValue == rewardValue)&&(identical(other.isUnlocked, isUnlocked) || other.isUnlocked == isUnlocked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,unlockId,title,description,unlockType,thresholdValue,rewardType,rewardValue,isUnlocked);

@override
String toString() {
  return 'Unlock(unlockId: $unlockId, title: $title, description: $description, unlockType: $unlockType, thresholdValue: $thresholdValue, rewardType: $rewardType, rewardValue: $rewardValue, isUnlocked: $isUnlocked)';
}


}

/// @nodoc
abstract mixin class _$UnlockCopyWith<$Res> implements $UnlockCopyWith<$Res> {
  factory _$UnlockCopyWith(_Unlock value, $Res Function(_Unlock) _then) = __$UnlockCopyWithImpl;
@override @useResult
$Res call({
 String unlockId, String title, String? description, String unlockType, int thresholdValue, String rewardType, String rewardValue, bool isUnlocked
});




}
/// @nodoc
class __$UnlockCopyWithImpl<$Res>
    implements _$UnlockCopyWith<$Res> {
  __$UnlockCopyWithImpl(this._self, this._then);

  final _Unlock _self;
  final $Res Function(_Unlock) _then;

/// Create a copy of Unlock
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? unlockId = null,Object? title = null,Object? description = freezed,Object? unlockType = null,Object? thresholdValue = null,Object? rewardType = null,Object? rewardValue = null,Object? isUnlocked = null,}) {
  return _then(_Unlock(
unlockId: null == unlockId ? _self.unlockId : unlockId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,unlockType: null == unlockType ? _self.unlockType : unlockType // ignore: cast_nullable_to_non_nullable
as String,thresholdValue: null == thresholdValue ? _self.thresholdValue : thresholdValue // ignore: cast_nullable_to_non_nullable
as int,rewardType: null == rewardType ? _self.rewardType : rewardType // ignore: cast_nullable_to_non_nullable
as String,rewardValue: null == rewardValue ? _self.rewardValue : rewardValue // ignore: cast_nullable_to_non_nullable
as String,isUnlocked: null == isUnlocked ? _self.isUnlocked : isUnlocked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
