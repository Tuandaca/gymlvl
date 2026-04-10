// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DashboardStats {

@JsonKey(name: 'volume_trend') List<VolumePoint> get volumeTrend;@JsonKey(name: 'muscle_split') List<MuscleSplit> get muscleSplit;@JsonKey(name: 'recent_prs') List<PRRecord> get recentPRs;
/// Create a copy of DashboardStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardStatsCopyWith<DashboardStats> get copyWith => _$DashboardStatsCopyWithImpl<DashboardStats>(this as DashboardStats, _$identity);

  /// Serializes this DashboardStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardStats&&const DeepCollectionEquality().equals(other.volumeTrend, volumeTrend)&&const DeepCollectionEquality().equals(other.muscleSplit, muscleSplit)&&const DeepCollectionEquality().equals(other.recentPRs, recentPRs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(volumeTrend),const DeepCollectionEquality().hash(muscleSplit),const DeepCollectionEquality().hash(recentPRs));

@override
String toString() {
  return 'DashboardStats(volumeTrend: $volumeTrend, muscleSplit: $muscleSplit, recentPRs: $recentPRs)';
}


}

/// @nodoc
abstract mixin class $DashboardStatsCopyWith<$Res>  {
  factory $DashboardStatsCopyWith(DashboardStats value, $Res Function(DashboardStats) _then) = _$DashboardStatsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'volume_trend') List<VolumePoint> volumeTrend,@JsonKey(name: 'muscle_split') List<MuscleSplit> muscleSplit,@JsonKey(name: 'recent_prs') List<PRRecord> recentPRs
});




}
/// @nodoc
class _$DashboardStatsCopyWithImpl<$Res>
    implements $DashboardStatsCopyWith<$Res> {
  _$DashboardStatsCopyWithImpl(this._self, this._then);

  final DashboardStats _self;
  final $Res Function(DashboardStats) _then;

/// Create a copy of DashboardStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? volumeTrend = null,Object? muscleSplit = null,Object? recentPRs = null,}) {
  return _then(_self.copyWith(
volumeTrend: null == volumeTrend ? _self.volumeTrend : volumeTrend // ignore: cast_nullable_to_non_nullable
as List<VolumePoint>,muscleSplit: null == muscleSplit ? _self.muscleSplit : muscleSplit // ignore: cast_nullable_to_non_nullable
as List<MuscleSplit>,recentPRs: null == recentPRs ? _self.recentPRs : recentPRs // ignore: cast_nullable_to_non_nullable
as List<PRRecord>,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardStats].
extension DashboardStatsPatterns on DashboardStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardStats value)  $default,){
final _that = this;
switch (_that) {
case _DashboardStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardStats value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'volume_trend')  List<VolumePoint> volumeTrend, @JsonKey(name: 'muscle_split')  List<MuscleSplit> muscleSplit, @JsonKey(name: 'recent_prs')  List<PRRecord> recentPRs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardStats() when $default != null:
return $default(_that.volumeTrend,_that.muscleSplit,_that.recentPRs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'volume_trend')  List<VolumePoint> volumeTrend, @JsonKey(name: 'muscle_split')  List<MuscleSplit> muscleSplit, @JsonKey(name: 'recent_prs')  List<PRRecord> recentPRs)  $default,) {final _that = this;
switch (_that) {
case _DashboardStats():
return $default(_that.volumeTrend,_that.muscleSplit,_that.recentPRs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'volume_trend')  List<VolumePoint> volumeTrend, @JsonKey(name: 'muscle_split')  List<MuscleSplit> muscleSplit, @JsonKey(name: 'recent_prs')  List<PRRecord> recentPRs)?  $default,) {final _that = this;
switch (_that) {
case _DashboardStats() when $default != null:
return $default(_that.volumeTrend,_that.muscleSplit,_that.recentPRs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardStats implements DashboardStats {
  const _DashboardStats({@JsonKey(name: 'volume_trend') required final  List<VolumePoint> volumeTrend, @JsonKey(name: 'muscle_split') required final  List<MuscleSplit> muscleSplit, @JsonKey(name: 'recent_prs') final  List<PRRecord> recentPRs = const []}): _volumeTrend = volumeTrend,_muscleSplit = muscleSplit,_recentPRs = recentPRs;
  factory _DashboardStats.fromJson(Map<String, dynamic> json) => _$DashboardStatsFromJson(json);

 final  List<VolumePoint> _volumeTrend;
@override@JsonKey(name: 'volume_trend') List<VolumePoint> get volumeTrend {
  if (_volumeTrend is EqualUnmodifiableListView) return _volumeTrend;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_volumeTrend);
}

 final  List<MuscleSplit> _muscleSplit;
@override@JsonKey(name: 'muscle_split') List<MuscleSplit> get muscleSplit {
  if (_muscleSplit is EqualUnmodifiableListView) return _muscleSplit;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_muscleSplit);
}

 final  List<PRRecord> _recentPRs;
@override@JsonKey(name: 'recent_prs') List<PRRecord> get recentPRs {
  if (_recentPRs is EqualUnmodifiableListView) return _recentPRs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentPRs);
}


/// Create a copy of DashboardStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardStatsCopyWith<_DashboardStats> get copyWith => __$DashboardStatsCopyWithImpl<_DashboardStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardStats&&const DeepCollectionEquality().equals(other._volumeTrend, _volumeTrend)&&const DeepCollectionEquality().equals(other._muscleSplit, _muscleSplit)&&const DeepCollectionEquality().equals(other._recentPRs, _recentPRs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_volumeTrend),const DeepCollectionEquality().hash(_muscleSplit),const DeepCollectionEquality().hash(_recentPRs));

@override
String toString() {
  return 'DashboardStats(volumeTrend: $volumeTrend, muscleSplit: $muscleSplit, recentPRs: $recentPRs)';
}


}

/// @nodoc
abstract mixin class _$DashboardStatsCopyWith<$Res> implements $DashboardStatsCopyWith<$Res> {
  factory _$DashboardStatsCopyWith(_DashboardStats value, $Res Function(_DashboardStats) _then) = __$DashboardStatsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'volume_trend') List<VolumePoint> volumeTrend,@JsonKey(name: 'muscle_split') List<MuscleSplit> muscleSplit,@JsonKey(name: 'recent_prs') List<PRRecord> recentPRs
});




}
/// @nodoc
class __$DashboardStatsCopyWithImpl<$Res>
    implements _$DashboardStatsCopyWith<$Res> {
  __$DashboardStatsCopyWithImpl(this._self, this._then);

  final _DashboardStats _self;
  final $Res Function(_DashboardStats) _then;

/// Create a copy of DashboardStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? volumeTrend = null,Object? muscleSplit = null,Object? recentPRs = null,}) {
  return _then(_DashboardStats(
volumeTrend: null == volumeTrend ? _self._volumeTrend : volumeTrend // ignore: cast_nullable_to_non_nullable
as List<VolumePoint>,muscleSplit: null == muscleSplit ? _self._muscleSplit : muscleSplit // ignore: cast_nullable_to_non_nullable
as List<MuscleSplit>,recentPRs: null == recentPRs ? _self._recentPRs : recentPRs // ignore: cast_nullable_to_non_nullable
as List<PRRecord>,
  ));
}


}


/// @nodoc
mixin _$VolumePoint {

 String get date; double get value;
/// Create a copy of VolumePoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VolumePointCopyWith<VolumePoint> get copyWith => _$VolumePointCopyWithImpl<VolumePoint>(this as VolumePoint, _$identity);

  /// Serializes this VolumePoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VolumePoint&&(identical(other.date, date) || other.date == date)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,value);

@override
String toString() {
  return 'VolumePoint(date: $date, value: $value)';
}


}

/// @nodoc
abstract mixin class $VolumePointCopyWith<$Res>  {
  factory $VolumePointCopyWith(VolumePoint value, $Res Function(VolumePoint) _then) = _$VolumePointCopyWithImpl;
@useResult
$Res call({
 String date, double value
});




}
/// @nodoc
class _$VolumePointCopyWithImpl<$Res>
    implements $VolumePointCopyWith<$Res> {
  _$VolumePointCopyWithImpl(this._self, this._then);

  final VolumePoint _self;
  final $Res Function(VolumePoint) _then;

/// Create a copy of VolumePoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? value = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [VolumePoint].
extension VolumePointPatterns on VolumePoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VolumePoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VolumePoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VolumePoint value)  $default,){
final _that = this;
switch (_that) {
case _VolumePoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VolumePoint value)?  $default,){
final _that = this;
switch (_that) {
case _VolumePoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  double value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VolumePoint() when $default != null:
return $default(_that.date,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  double value)  $default,) {final _that = this;
switch (_that) {
case _VolumePoint():
return $default(_that.date,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  double value)?  $default,) {final _that = this;
switch (_that) {
case _VolumePoint() when $default != null:
return $default(_that.date,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VolumePoint implements VolumePoint {
  const _VolumePoint({required this.date, required this.value});
  factory _VolumePoint.fromJson(Map<String, dynamic> json) => _$VolumePointFromJson(json);

@override final  String date;
@override final  double value;

/// Create a copy of VolumePoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VolumePointCopyWith<_VolumePoint> get copyWith => __$VolumePointCopyWithImpl<_VolumePoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VolumePointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VolumePoint&&(identical(other.date, date) || other.date == date)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,value);

@override
String toString() {
  return 'VolumePoint(date: $date, value: $value)';
}


}

/// @nodoc
abstract mixin class _$VolumePointCopyWith<$Res> implements $VolumePointCopyWith<$Res> {
  factory _$VolumePointCopyWith(_VolumePoint value, $Res Function(_VolumePoint) _then) = __$VolumePointCopyWithImpl;
@override @useResult
$Res call({
 String date, double value
});




}
/// @nodoc
class __$VolumePointCopyWithImpl<$Res>
    implements _$VolumePointCopyWith<$Res> {
  __$VolumePointCopyWithImpl(this._self, this._then);

  final _VolumePoint _self;
  final $Res Function(_VolumePoint) _then;

/// Create a copy of VolumePoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? value = null,}) {
  return _then(_VolumePoint(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$MuscleSplit {

 String get label; double get value;
/// Create a copy of MuscleSplit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MuscleSplitCopyWith<MuscleSplit> get copyWith => _$MuscleSplitCopyWithImpl<MuscleSplit>(this as MuscleSplit, _$identity);

  /// Serializes this MuscleSplit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MuscleSplit&&(identical(other.label, label) || other.label == label)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,value);

@override
String toString() {
  return 'MuscleSplit(label: $label, value: $value)';
}


}

/// @nodoc
abstract mixin class $MuscleSplitCopyWith<$Res>  {
  factory $MuscleSplitCopyWith(MuscleSplit value, $Res Function(MuscleSplit) _then) = _$MuscleSplitCopyWithImpl;
@useResult
$Res call({
 String label, double value
});




}
/// @nodoc
class _$MuscleSplitCopyWithImpl<$Res>
    implements $MuscleSplitCopyWith<$Res> {
  _$MuscleSplitCopyWithImpl(this._self, this._then);

  final MuscleSplit _self;
  final $Res Function(MuscleSplit) _then;

/// Create a copy of MuscleSplit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? value = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [MuscleSplit].
extension MuscleSplitPatterns on MuscleSplit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MuscleSplit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MuscleSplit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MuscleSplit value)  $default,){
final _that = this;
switch (_that) {
case _MuscleSplit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MuscleSplit value)?  $default,){
final _that = this;
switch (_that) {
case _MuscleSplit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  double value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MuscleSplit() when $default != null:
return $default(_that.label,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  double value)  $default,) {final _that = this;
switch (_that) {
case _MuscleSplit():
return $default(_that.label,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  double value)?  $default,) {final _that = this;
switch (_that) {
case _MuscleSplit() when $default != null:
return $default(_that.label,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MuscleSplit implements MuscleSplit {
  const _MuscleSplit({required this.label, required this.value});
  factory _MuscleSplit.fromJson(Map<String, dynamic> json) => _$MuscleSplitFromJson(json);

@override final  String label;
@override final  double value;

/// Create a copy of MuscleSplit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MuscleSplitCopyWith<_MuscleSplit> get copyWith => __$MuscleSplitCopyWithImpl<_MuscleSplit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MuscleSplitToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MuscleSplit&&(identical(other.label, label) || other.label == label)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,value);

@override
String toString() {
  return 'MuscleSplit(label: $label, value: $value)';
}


}

/// @nodoc
abstract mixin class _$MuscleSplitCopyWith<$Res> implements $MuscleSplitCopyWith<$Res> {
  factory _$MuscleSplitCopyWith(_MuscleSplit value, $Res Function(_MuscleSplit) _then) = __$MuscleSplitCopyWithImpl;
@override @useResult
$Res call({
 String label, double value
});




}
/// @nodoc
class __$MuscleSplitCopyWithImpl<$Res>
    implements _$MuscleSplitCopyWith<$Res> {
  __$MuscleSplitCopyWithImpl(this._self, this._then);

  final _MuscleSplit _self;
  final $Res Function(_MuscleSplit) _then;

/// Create a copy of MuscleSplit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? value = null,}) {
  return _then(_MuscleSplit(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$PRRecord {

@JsonKey(name: 'exercises') Map<String, dynamic> get exerciseInfo;@JsonKey(name: 'max_weight_kg') double get maxWeight;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of PRRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PRRecordCopyWith<PRRecord> get copyWith => _$PRRecordCopyWithImpl<PRRecord>(this as PRRecord, _$identity);

  /// Serializes this PRRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PRRecord&&const DeepCollectionEquality().equals(other.exerciseInfo, exerciseInfo)&&(identical(other.maxWeight, maxWeight) || other.maxWeight == maxWeight)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(exerciseInfo),maxWeight,updatedAt);

@override
String toString() {
  return 'PRRecord(exerciseInfo: $exerciseInfo, maxWeight: $maxWeight, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PRRecordCopyWith<$Res>  {
  factory $PRRecordCopyWith(PRRecord value, $Res Function(PRRecord) _then) = _$PRRecordCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'exercises') Map<String, dynamic> exerciseInfo,@JsonKey(name: 'max_weight_kg') double maxWeight,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$PRRecordCopyWithImpl<$Res>
    implements $PRRecordCopyWith<$Res> {
  _$PRRecordCopyWithImpl(this._self, this._then);

  final PRRecord _self;
  final $Res Function(PRRecord) _then;

/// Create a copy of PRRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseInfo = null,Object? maxWeight = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
exerciseInfo: null == exerciseInfo ? _self.exerciseInfo : exerciseInfo // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,maxWeight: null == maxWeight ? _self.maxWeight : maxWeight // ignore: cast_nullable_to_non_nullable
as double,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PRRecord].
extension PRRecordPatterns on PRRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PRRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PRRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PRRecord value)  $default,){
final _that = this;
switch (_that) {
case _PRRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PRRecord value)?  $default,){
final _that = this;
switch (_that) {
case _PRRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'exercises')  Map<String, dynamic> exerciseInfo, @JsonKey(name: 'max_weight_kg')  double maxWeight, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PRRecord() when $default != null:
return $default(_that.exerciseInfo,_that.maxWeight,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'exercises')  Map<String, dynamic> exerciseInfo, @JsonKey(name: 'max_weight_kg')  double maxWeight, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PRRecord():
return $default(_that.exerciseInfo,_that.maxWeight,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'exercises')  Map<String, dynamic> exerciseInfo, @JsonKey(name: 'max_weight_kg')  double maxWeight, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PRRecord() when $default != null:
return $default(_that.exerciseInfo,_that.maxWeight,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PRRecord implements PRRecord {
  const _PRRecord({@JsonKey(name: 'exercises') required final  Map<String, dynamic> exerciseInfo, @JsonKey(name: 'max_weight_kg') required this.maxWeight, @JsonKey(name: 'updated_at') required this.updatedAt}): _exerciseInfo = exerciseInfo;
  factory _PRRecord.fromJson(Map<String, dynamic> json) => _$PRRecordFromJson(json);

 final  Map<String, dynamic> _exerciseInfo;
@override@JsonKey(name: 'exercises') Map<String, dynamic> get exerciseInfo {
  if (_exerciseInfo is EqualUnmodifiableMapView) return _exerciseInfo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_exerciseInfo);
}

@override@JsonKey(name: 'max_weight_kg') final  double maxWeight;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of PRRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PRRecordCopyWith<_PRRecord> get copyWith => __$PRRecordCopyWithImpl<_PRRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PRRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PRRecord&&const DeepCollectionEquality().equals(other._exerciseInfo, _exerciseInfo)&&(identical(other.maxWeight, maxWeight) || other.maxWeight == maxWeight)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_exerciseInfo),maxWeight,updatedAt);

@override
String toString() {
  return 'PRRecord(exerciseInfo: $exerciseInfo, maxWeight: $maxWeight, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PRRecordCopyWith<$Res> implements $PRRecordCopyWith<$Res> {
  factory _$PRRecordCopyWith(_PRRecord value, $Res Function(_PRRecord) _then) = __$PRRecordCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'exercises') Map<String, dynamic> exerciseInfo,@JsonKey(name: 'max_weight_kg') double maxWeight,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$PRRecordCopyWithImpl<$Res>
    implements _$PRRecordCopyWith<$Res> {
  __$PRRecordCopyWithImpl(this._self, this._then);

  final _PRRecord _self;
  final $Res Function(_PRRecord) _then;

/// Create a copy of PRRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseInfo = null,Object? maxWeight = null,Object? updatedAt = null,}) {
  return _then(_PRRecord(
exerciseInfo: null == exerciseInfo ? _self._exerciseInfo : exerciseInfo // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,maxWeight: null == maxWeight ? _self.maxWeight : maxWeight // ignore: cast_nullable_to_non_nullable
as double,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
