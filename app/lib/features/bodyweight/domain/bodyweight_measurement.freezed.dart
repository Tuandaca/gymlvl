// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bodyweight_measurement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BodyweightMeasurement {

 String get id; String get userId;@JsonKey(name: 'weight_kg') double get weightKg;@JsonKey(name: 'measured_at') DateTime get measuredAt;@JsonKey(name: 'source') BodyweightSource get source; String? get notes;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of BodyweightMeasurement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BodyweightMeasurementCopyWith<BodyweightMeasurement> get copyWith => _$BodyweightMeasurementCopyWithImpl<BodyweightMeasurement>(this as BodyweightMeasurement, _$identity);

  /// Serializes this BodyweightMeasurement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BodyweightMeasurement&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.measuredAt, measuredAt) || other.measuredAt == measuredAt)&&(identical(other.source, source) || other.source == source)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,weightKg,measuredAt,source,notes,createdAt);

@override
String toString() {
  return 'BodyweightMeasurement(id: $id, userId: $userId, weightKg: $weightKg, measuredAt: $measuredAt, source: $source, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BodyweightMeasurementCopyWith<$Res>  {
  factory $BodyweightMeasurementCopyWith(BodyweightMeasurement value, $Res Function(BodyweightMeasurement) _then) = _$BodyweightMeasurementCopyWithImpl;
@useResult
$Res call({
 String id, String userId,@JsonKey(name: 'weight_kg') double weightKg,@JsonKey(name: 'measured_at') DateTime measuredAt,@JsonKey(name: 'source') BodyweightSource source, String? notes,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$BodyweightMeasurementCopyWithImpl<$Res>
    implements $BodyweightMeasurementCopyWith<$Res> {
  _$BodyweightMeasurementCopyWithImpl(this._self, this._then);

  final BodyweightMeasurement _self;
  final $Res Function(BodyweightMeasurement) _then;

/// Create a copy of BodyweightMeasurement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? weightKg = null,Object? measuredAt = null,Object? source = null,Object? notes = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,measuredAt: null == measuredAt ? _self.measuredAt : measuredAt // ignore: cast_nullable_to_non_nullable
as DateTime,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as BodyweightSource,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [BodyweightMeasurement].
extension BodyweightMeasurementPatterns on BodyweightMeasurement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BodyweightMeasurement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BodyweightMeasurement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BodyweightMeasurement value)  $default,){
final _that = this;
switch (_that) {
case _BodyweightMeasurement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BodyweightMeasurement value)?  $default,){
final _that = this;
switch (_that) {
case _BodyweightMeasurement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId, @JsonKey(name: 'weight_kg')  double weightKg, @JsonKey(name: 'measured_at')  DateTime measuredAt, @JsonKey(name: 'source')  BodyweightSource source,  String? notes, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BodyweightMeasurement() when $default != null:
return $default(_that.id,_that.userId,_that.weightKg,_that.measuredAt,_that.source,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId, @JsonKey(name: 'weight_kg')  double weightKg, @JsonKey(name: 'measured_at')  DateTime measuredAt, @JsonKey(name: 'source')  BodyweightSource source,  String? notes, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _BodyweightMeasurement():
return $default(_that.id,_that.userId,_that.weightKg,_that.measuredAt,_that.source,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId, @JsonKey(name: 'weight_kg')  double weightKg, @JsonKey(name: 'measured_at')  DateTime measuredAt, @JsonKey(name: 'source')  BodyweightSource source,  String? notes, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _BodyweightMeasurement() when $default != null:
return $default(_that.id,_that.userId,_that.weightKg,_that.measuredAt,_that.source,_that.notes,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BodyweightMeasurement extends BodyweightMeasurement {
  const _BodyweightMeasurement({required this.id, required this.userId, @JsonKey(name: 'weight_kg') required this.weightKg, @JsonKey(name: 'measured_at') required this.measuredAt, @JsonKey(name: 'source') required this.source, this.notes, @JsonKey(name: 'created_at') this.createdAt}): super._();
  factory _BodyweightMeasurement.fromJson(Map<String, dynamic> json) => _$BodyweightMeasurementFromJson(json);

@override final  String id;
@override final  String userId;
@override@JsonKey(name: 'weight_kg') final  double weightKg;
@override@JsonKey(name: 'measured_at') final  DateTime measuredAt;
@override@JsonKey(name: 'source') final  BodyweightSource source;
@override final  String? notes;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of BodyweightMeasurement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BodyweightMeasurementCopyWith<_BodyweightMeasurement> get copyWith => __$BodyweightMeasurementCopyWithImpl<_BodyweightMeasurement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BodyweightMeasurementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BodyweightMeasurement&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.measuredAt, measuredAt) || other.measuredAt == measuredAt)&&(identical(other.source, source) || other.source == source)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,weightKg,measuredAt,source,notes,createdAt);

@override
String toString() {
  return 'BodyweightMeasurement(id: $id, userId: $userId, weightKg: $weightKg, measuredAt: $measuredAt, source: $source, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BodyweightMeasurementCopyWith<$Res> implements $BodyweightMeasurementCopyWith<$Res> {
  factory _$BodyweightMeasurementCopyWith(_BodyweightMeasurement value, $Res Function(_BodyweightMeasurement) _then) = __$BodyweightMeasurementCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId,@JsonKey(name: 'weight_kg') double weightKg,@JsonKey(name: 'measured_at') DateTime measuredAt,@JsonKey(name: 'source') BodyweightSource source, String? notes,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$BodyweightMeasurementCopyWithImpl<$Res>
    implements _$BodyweightMeasurementCopyWith<$Res> {
  __$BodyweightMeasurementCopyWithImpl(this._self, this._then);

  final _BodyweightMeasurement _self;
  final $Res Function(_BodyweightMeasurement) _then;

/// Create a copy of BodyweightMeasurement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? weightKg = null,Object? measuredAt = null,Object? source = null,Object? notes = freezed,Object? createdAt = freezed,}) {
  return _then(_BodyweightMeasurement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,weightKg: null == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double,measuredAt: null == measuredAt ? _self.measuredAt : measuredAt // ignore: cast_nullable_to_non_nullable
as DateTime,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as BodyweightSource,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
