// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medication_schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MedicationSchedule {

 MedicationScheduleMode get mode; String get startsOn; String get startsTime; String get endsOn; String get endsTime; List<String> get fixedTimes; int? get intervalMinutes;
/// Create a copy of MedicationSchedule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicationScheduleCopyWith<MedicationSchedule> get copyWith => _$MedicationScheduleCopyWithImpl<MedicationSchedule>(this as MedicationSchedule, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicationSchedule&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.startsOn, startsOn) || other.startsOn == startsOn)&&(identical(other.startsTime, startsTime) || other.startsTime == startsTime)&&(identical(other.endsOn, endsOn) || other.endsOn == endsOn)&&(identical(other.endsTime, endsTime) || other.endsTime == endsTime)&&const DeepCollectionEquality().equals(other.fixedTimes, fixedTimes)&&(identical(other.intervalMinutes, intervalMinutes) || other.intervalMinutes == intervalMinutes));
}


@override
int get hashCode => Object.hash(runtimeType,mode,startsOn,startsTime,endsOn,endsTime,const DeepCollectionEquality().hash(fixedTimes),intervalMinutes);

@override
String toString() {
  return 'MedicationSchedule(mode: $mode, startsOn: $startsOn, startsTime: $startsTime, endsOn: $endsOn, endsTime: $endsTime, fixedTimes: $fixedTimes, intervalMinutes: $intervalMinutes)';
}


}

/// @nodoc
abstract mixin class $MedicationScheduleCopyWith<$Res>  {
  factory $MedicationScheduleCopyWith(MedicationSchedule value, $Res Function(MedicationSchedule) _then) = _$MedicationScheduleCopyWithImpl;
@useResult
$Res call({
 MedicationScheduleMode mode, String startsOn, String startsTime, String endsOn, String endsTime, List<String> fixedTimes, int? intervalMinutes
});




}
/// @nodoc
class _$MedicationScheduleCopyWithImpl<$Res>
    implements $MedicationScheduleCopyWith<$Res> {
  _$MedicationScheduleCopyWithImpl(this._self, this._then);

  final MedicationSchedule _self;
  final $Res Function(MedicationSchedule) _then;

/// Create a copy of MedicationSchedule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? startsOn = null,Object? startsTime = null,Object? endsOn = null,Object? endsTime = null,Object? fixedTimes = null,Object? intervalMinutes = freezed,}) {
  return _then(_self.copyWith(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as MedicationScheduleMode,startsOn: null == startsOn ? _self.startsOn : startsOn // ignore: cast_nullable_to_non_nullable
as String,startsTime: null == startsTime ? _self.startsTime : startsTime // ignore: cast_nullable_to_non_nullable
as String,endsOn: null == endsOn ? _self.endsOn : endsOn // ignore: cast_nullable_to_non_nullable
as String,endsTime: null == endsTime ? _self.endsTime : endsTime // ignore: cast_nullable_to_non_nullable
as String,fixedTimes: null == fixedTimes ? _self.fixedTimes : fixedTimes // ignore: cast_nullable_to_non_nullable
as List<String>,intervalMinutes: freezed == intervalMinutes ? _self.intervalMinutes : intervalMinutes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicationSchedule].
extension MedicationSchedulePatterns on MedicationSchedule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicationSchedule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicationSchedule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicationSchedule value)  $default,){
final _that = this;
switch (_that) {
case _MedicationSchedule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicationSchedule value)?  $default,){
final _that = this;
switch (_that) {
case _MedicationSchedule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MedicationScheduleMode mode,  String startsOn,  String startsTime,  String endsOn,  String endsTime,  List<String> fixedTimes,  int? intervalMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicationSchedule() when $default != null:
return $default(_that.mode,_that.startsOn,_that.startsTime,_that.endsOn,_that.endsTime,_that.fixedTimes,_that.intervalMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MedicationScheduleMode mode,  String startsOn,  String startsTime,  String endsOn,  String endsTime,  List<String> fixedTimes,  int? intervalMinutes)  $default,) {final _that = this;
switch (_that) {
case _MedicationSchedule():
return $default(_that.mode,_that.startsOn,_that.startsTime,_that.endsOn,_that.endsTime,_that.fixedTimes,_that.intervalMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MedicationScheduleMode mode,  String startsOn,  String startsTime,  String endsOn,  String endsTime,  List<String> fixedTimes,  int? intervalMinutes)?  $default,) {final _that = this;
switch (_that) {
case _MedicationSchedule() when $default != null:
return $default(_that.mode,_that.startsOn,_that.startsTime,_that.endsOn,_that.endsTime,_that.fixedTimes,_that.intervalMinutes);case _:
  return null;

}
}

}

/// @nodoc


class _MedicationSchedule extends MedicationSchedule {
  const _MedicationSchedule({this.mode = MedicationScheduleMode.fixedTimes, this.startsOn = '', this.startsTime = '08:00', this.endsOn = '', this.endsTime = '20:00', final  List<String> fixedTimes = const ['08:00', '20:00'], this.intervalMinutes}): _fixedTimes = fixedTimes,super._();
  

@override@JsonKey() final  MedicationScheduleMode mode;
@override@JsonKey() final  String startsOn;
@override@JsonKey() final  String startsTime;
@override@JsonKey() final  String endsOn;
@override@JsonKey() final  String endsTime;
 final  List<String> _fixedTimes;
@override@JsonKey() List<String> get fixedTimes {
  if (_fixedTimes is EqualUnmodifiableListView) return _fixedTimes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fixedTimes);
}

@override final  int? intervalMinutes;

/// Create a copy of MedicationSchedule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicationScheduleCopyWith<_MedicationSchedule> get copyWith => __$MedicationScheduleCopyWithImpl<_MedicationSchedule>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicationSchedule&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.startsOn, startsOn) || other.startsOn == startsOn)&&(identical(other.startsTime, startsTime) || other.startsTime == startsTime)&&(identical(other.endsOn, endsOn) || other.endsOn == endsOn)&&(identical(other.endsTime, endsTime) || other.endsTime == endsTime)&&const DeepCollectionEquality().equals(other._fixedTimes, _fixedTimes)&&(identical(other.intervalMinutes, intervalMinutes) || other.intervalMinutes == intervalMinutes));
}


@override
int get hashCode => Object.hash(runtimeType,mode,startsOn,startsTime,endsOn,endsTime,const DeepCollectionEquality().hash(_fixedTimes),intervalMinutes);

@override
String toString() {
  return 'MedicationSchedule(mode: $mode, startsOn: $startsOn, startsTime: $startsTime, endsOn: $endsOn, endsTime: $endsTime, fixedTimes: $fixedTimes, intervalMinutes: $intervalMinutes)';
}


}

/// @nodoc
abstract mixin class _$MedicationScheduleCopyWith<$Res> implements $MedicationScheduleCopyWith<$Res> {
  factory _$MedicationScheduleCopyWith(_MedicationSchedule value, $Res Function(_MedicationSchedule) _then) = __$MedicationScheduleCopyWithImpl;
@override @useResult
$Res call({
 MedicationScheduleMode mode, String startsOn, String startsTime, String endsOn, String endsTime, List<String> fixedTimes, int? intervalMinutes
});




}
/// @nodoc
class __$MedicationScheduleCopyWithImpl<$Res>
    implements _$MedicationScheduleCopyWith<$Res> {
  __$MedicationScheduleCopyWithImpl(this._self, this._then);

  final _MedicationSchedule _self;
  final $Res Function(_MedicationSchedule) _then;

/// Create a copy of MedicationSchedule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? startsOn = null,Object? startsTime = null,Object? endsOn = null,Object? endsTime = null,Object? fixedTimes = null,Object? intervalMinutes = freezed,}) {
  return _then(_MedicationSchedule(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as MedicationScheduleMode,startsOn: null == startsOn ? _self.startsOn : startsOn // ignore: cast_nullable_to_non_nullable
as String,startsTime: null == startsTime ? _self.startsTime : startsTime // ignore: cast_nullable_to_non_nullable
as String,endsOn: null == endsOn ? _self.endsOn : endsOn // ignore: cast_nullable_to_non_nullable
as String,endsTime: null == endsTime ? _self.endsTime : endsTime // ignore: cast_nullable_to_non_nullable
as String,fixedTimes: null == fixedTimes ? _self._fixedTimes : fixedTimes // ignore: cast_nullable_to_non_nullable
as List<String>,intervalMinutes: freezed == intervalMinutes ? _self.intervalMinutes : intervalMinutes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
