// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfileDraft {

// 1. Environment
 String? get environment;// 2. Goals (max 3)
 List<String> get goals;// 3. Class (generated after environment and goals)
 String? get className;// 4. Experience Level
 String? get experienceLevel;// 5. Biometrics
 int? get age; String? get gender; double? get heightCm; double? get weightKg;// 6. Scheduling & Frequency
 int get weeklyGymDays; int get weeklyHomeDays; List<String> get preferredDays;
/// Create a copy of UserProfileDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileDraftCopyWith<UserProfileDraft> get copyWith => _$UserProfileDraftCopyWithImpl<UserProfileDraft>(this as UserProfileDraft, _$identity);

  /// Serializes this UserProfileDraft to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfileDraft&&(identical(other.environment, environment) || other.environment == environment)&&const DeepCollectionEquality().equals(other.goals, goals)&&(identical(other.className, className) || other.className == className)&&(identical(other.experienceLevel, experienceLevel) || other.experienceLevel == experienceLevel)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.weeklyGymDays, weeklyGymDays) || other.weeklyGymDays == weeklyGymDays)&&(identical(other.weeklyHomeDays, weeklyHomeDays) || other.weeklyHomeDays == weeklyHomeDays)&&const DeepCollectionEquality().equals(other.preferredDays, preferredDays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,environment,const DeepCollectionEquality().hash(goals),className,experienceLevel,age,gender,heightCm,weightKg,weeklyGymDays,weeklyHomeDays,const DeepCollectionEquality().hash(preferredDays));

@override
String toString() {
  return 'UserProfileDraft(environment: $environment, goals: $goals, className: $className, experienceLevel: $experienceLevel, age: $age, gender: $gender, heightCm: $heightCm, weightKg: $weightKg, weeklyGymDays: $weeklyGymDays, weeklyHomeDays: $weeklyHomeDays, preferredDays: $preferredDays)';
}


}

/// @nodoc
abstract mixin class $UserProfileDraftCopyWith<$Res>  {
  factory $UserProfileDraftCopyWith(UserProfileDraft value, $Res Function(UserProfileDraft) _then) = _$UserProfileDraftCopyWithImpl;
@useResult
$Res call({
 String? environment, List<String> goals, String? className, String? experienceLevel, int? age, String? gender, double? heightCm, double? weightKg, int weeklyGymDays, int weeklyHomeDays, List<String> preferredDays
});




}
/// @nodoc
class _$UserProfileDraftCopyWithImpl<$Res>
    implements $UserProfileDraftCopyWith<$Res> {
  _$UserProfileDraftCopyWithImpl(this._self, this._then);

  final UserProfileDraft _self;
  final $Res Function(UserProfileDraft) _then;

/// Create a copy of UserProfileDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? environment = freezed,Object? goals = null,Object? className = freezed,Object? experienceLevel = freezed,Object? age = freezed,Object? gender = freezed,Object? heightCm = freezed,Object? weightKg = freezed,Object? weeklyGymDays = null,Object? weeklyHomeDays = null,Object? preferredDays = null,}) {
  return _then(_self.copyWith(
environment: freezed == environment ? _self.environment : environment // ignore: cast_nullable_to_non_nullable
as String?,goals: null == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as List<String>,className: freezed == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String?,experienceLevel: freezed == experienceLevel ? _self.experienceLevel : experienceLevel // ignore: cast_nullable_to_non_nullable
as String?,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,weeklyGymDays: null == weeklyGymDays ? _self.weeklyGymDays : weeklyGymDays // ignore: cast_nullable_to_non_nullable
as int,weeklyHomeDays: null == weeklyHomeDays ? _self.weeklyHomeDays : weeklyHomeDays // ignore: cast_nullable_to_non_nullable
as int,preferredDays: null == preferredDays ? _self.preferredDays : preferredDays // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfileDraft].
extension UserProfileDraftPatterns on UserProfileDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfileDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfileDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfileDraft value)  $default,){
final _that = this;
switch (_that) {
case _UserProfileDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfileDraft value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfileDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? environment,  List<String> goals,  String? className,  String? experienceLevel,  int? age,  String? gender,  double? heightCm,  double? weightKg,  int weeklyGymDays,  int weeklyHomeDays,  List<String> preferredDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfileDraft() when $default != null:
return $default(_that.environment,_that.goals,_that.className,_that.experienceLevel,_that.age,_that.gender,_that.heightCm,_that.weightKg,_that.weeklyGymDays,_that.weeklyHomeDays,_that.preferredDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? environment,  List<String> goals,  String? className,  String? experienceLevel,  int? age,  String? gender,  double? heightCm,  double? weightKg,  int weeklyGymDays,  int weeklyHomeDays,  List<String> preferredDays)  $default,) {final _that = this;
switch (_that) {
case _UserProfileDraft():
return $default(_that.environment,_that.goals,_that.className,_that.experienceLevel,_that.age,_that.gender,_that.heightCm,_that.weightKg,_that.weeklyGymDays,_that.weeklyHomeDays,_that.preferredDays);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? environment,  List<String> goals,  String? className,  String? experienceLevel,  int? age,  String? gender,  double? heightCm,  double? weightKg,  int weeklyGymDays,  int weeklyHomeDays,  List<String> preferredDays)?  $default,) {final _that = this;
switch (_that) {
case _UserProfileDraft() when $default != null:
return $default(_that.environment,_that.goals,_that.className,_that.experienceLevel,_that.age,_that.gender,_that.heightCm,_that.weightKg,_that.weeklyGymDays,_that.weeklyHomeDays,_that.preferredDays);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfileDraft implements UserProfileDraft {
  const _UserProfileDraft({this.environment, final  List<String> goals = const [], this.className, this.experienceLevel, this.age, this.gender, this.heightCm, this.weightKg, this.weeklyGymDays = 3, this.weeklyHomeDays = 0, final  List<String> preferredDays = const []}): _goals = goals,_preferredDays = preferredDays;
  factory _UserProfileDraft.fromJson(Map<String, dynamic> json) => _$UserProfileDraftFromJson(json);

// 1. Environment
@override final  String? environment;
// 2. Goals (max 3)
 final  List<String> _goals;
// 2. Goals (max 3)
@override@JsonKey() List<String> get goals {
  if (_goals is EqualUnmodifiableListView) return _goals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_goals);
}

// 3. Class (generated after environment and goals)
@override final  String? className;
// 4. Experience Level
@override final  String? experienceLevel;
// 5. Biometrics
@override final  int? age;
@override final  String? gender;
@override final  double? heightCm;
@override final  double? weightKg;
// 6. Scheduling & Frequency
@override@JsonKey() final  int weeklyGymDays;
@override@JsonKey() final  int weeklyHomeDays;
 final  List<String> _preferredDays;
@override@JsonKey() List<String> get preferredDays {
  if (_preferredDays is EqualUnmodifiableListView) return _preferredDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_preferredDays);
}


/// Create a copy of UserProfileDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileDraftCopyWith<_UserProfileDraft> get copyWith => __$UserProfileDraftCopyWithImpl<_UserProfileDraft>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileDraftToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfileDraft&&(identical(other.environment, environment) || other.environment == environment)&&const DeepCollectionEquality().equals(other._goals, _goals)&&(identical(other.className, className) || other.className == className)&&(identical(other.experienceLevel, experienceLevel) || other.experienceLevel == experienceLevel)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.weeklyGymDays, weeklyGymDays) || other.weeklyGymDays == weeklyGymDays)&&(identical(other.weeklyHomeDays, weeklyHomeDays) || other.weeklyHomeDays == weeklyHomeDays)&&const DeepCollectionEquality().equals(other._preferredDays, _preferredDays));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,environment,const DeepCollectionEquality().hash(_goals),className,experienceLevel,age,gender,heightCm,weightKg,weeklyGymDays,weeklyHomeDays,const DeepCollectionEquality().hash(_preferredDays));

@override
String toString() {
  return 'UserProfileDraft(environment: $environment, goals: $goals, className: $className, experienceLevel: $experienceLevel, age: $age, gender: $gender, heightCm: $heightCm, weightKg: $weightKg, weeklyGymDays: $weeklyGymDays, weeklyHomeDays: $weeklyHomeDays, preferredDays: $preferredDays)';
}


}

/// @nodoc
abstract mixin class _$UserProfileDraftCopyWith<$Res> implements $UserProfileDraftCopyWith<$Res> {
  factory _$UserProfileDraftCopyWith(_UserProfileDraft value, $Res Function(_UserProfileDraft) _then) = __$UserProfileDraftCopyWithImpl;
@override @useResult
$Res call({
 String? environment, List<String> goals, String? className, String? experienceLevel, int? age, String? gender, double? heightCm, double? weightKg, int weeklyGymDays, int weeklyHomeDays, List<String> preferredDays
});




}
/// @nodoc
class __$UserProfileDraftCopyWithImpl<$Res>
    implements _$UserProfileDraftCopyWith<$Res> {
  __$UserProfileDraftCopyWithImpl(this._self, this._then);

  final _UserProfileDraft _self;
  final $Res Function(_UserProfileDraft) _then;

/// Create a copy of UserProfileDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? environment = freezed,Object? goals = null,Object? className = freezed,Object? experienceLevel = freezed,Object? age = freezed,Object? gender = freezed,Object? heightCm = freezed,Object? weightKg = freezed,Object? weeklyGymDays = null,Object? weeklyHomeDays = null,Object? preferredDays = null,}) {
  return _then(_UserProfileDraft(
environment: freezed == environment ? _self.environment : environment // ignore: cast_nullable_to_non_nullable
as String?,goals: null == goals ? _self._goals : goals // ignore: cast_nullable_to_non_nullable
as List<String>,className: freezed == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String?,experienceLevel: freezed == experienceLevel ? _self.experienceLevel : experienceLevel // ignore: cast_nullable_to_non_nullable
as String?,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,weeklyGymDays: null == weeklyGymDays ? _self.weeklyGymDays : weeklyGymDays // ignore: cast_nullable_to_non_nullable
as int,weeklyHomeDays: null == weeklyHomeDays ? _self.weeklyHomeDays : weeklyHomeDays // ignore: cast_nullable_to_non_nullable
as int,preferredDays: null == preferredDays ? _self._preferredDays : preferredDays // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
