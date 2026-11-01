// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medication_calendar_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MedicationCalendarState implements DiagnosticableTreeMixin {

 String get month; String get selectedDay; MedicationMonth? get monthData; DateTime? get serverNow; int? get agendaVersion; List<MedicationApplication> get items; String? get cursor; bool get loadingMonth; bool get loadingDay; String? get monthError; String? get dayError;
/// Create a copy of MedicationCalendarState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicationCalendarStateCopyWith<MedicationCalendarState> get copyWith => _$MedicationCalendarStateCopyWithImpl<MedicationCalendarState>(this as MedicationCalendarState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MedicationCalendarState'))
    ..add(DiagnosticsProperty('month', month))..add(DiagnosticsProperty('selectedDay', selectedDay))..add(DiagnosticsProperty('monthData', monthData))..add(DiagnosticsProperty('serverNow', serverNow))..add(DiagnosticsProperty('agendaVersion', agendaVersion))..add(DiagnosticsProperty('items', items))..add(DiagnosticsProperty('cursor', cursor))..add(DiagnosticsProperty('loadingMonth', loadingMonth))..add(DiagnosticsProperty('loadingDay', loadingDay))..add(DiagnosticsProperty('monthError', monthError))..add(DiagnosticsProperty('dayError', dayError));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicationCalendarState&&(identical(other.month, month) || other.month == month)&&(identical(other.selectedDay, selectedDay) || other.selectedDay == selectedDay)&&(identical(other.monthData, monthData) || other.monthData == monthData)&&(identical(other.serverNow, serverNow) || other.serverNow == serverNow)&&(identical(other.agendaVersion, agendaVersion) || other.agendaVersion == agendaVersion)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.cursor, cursor) || other.cursor == cursor)&&(identical(other.loadingMonth, loadingMonth) || other.loadingMonth == loadingMonth)&&(identical(other.loadingDay, loadingDay) || other.loadingDay == loadingDay)&&(identical(other.monthError, monthError) || other.monthError == monthError)&&(identical(other.dayError, dayError) || other.dayError == dayError));
}


@override
int get hashCode => Object.hash(runtimeType,month,selectedDay,monthData,serverNow,agendaVersion,const DeepCollectionEquality().hash(items),cursor,loadingMonth,loadingDay,monthError,dayError);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MedicationCalendarState(month: $month, selectedDay: $selectedDay, monthData: $monthData, serverNow: $serverNow, agendaVersion: $agendaVersion, items: $items, cursor: $cursor, loadingMonth: $loadingMonth, loadingDay: $loadingDay, monthError: $monthError, dayError: $dayError)';
}


}

/// @nodoc
abstract mixin class $MedicationCalendarStateCopyWith<$Res>  {
  factory $MedicationCalendarStateCopyWith(MedicationCalendarState value, $Res Function(MedicationCalendarState) _then) = _$MedicationCalendarStateCopyWithImpl;
@useResult
$Res call({
 String month, String selectedDay, MedicationMonth? monthData, DateTime? serverNow, int? agendaVersion, List<MedicationApplication> items, String? cursor, bool loadingMonth, bool loadingDay, String? monthError, String? dayError
});


$MedicationMonthCopyWith<$Res>? get monthData;

}
/// @nodoc
class _$MedicationCalendarStateCopyWithImpl<$Res>
    implements $MedicationCalendarStateCopyWith<$Res> {
  _$MedicationCalendarStateCopyWithImpl(this._self, this._then);

  final MedicationCalendarState _self;
  final $Res Function(MedicationCalendarState) _then;

/// Create a copy of MedicationCalendarState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? selectedDay = null,Object? monthData = freezed,Object? serverNow = freezed,Object? agendaVersion = freezed,Object? items = null,Object? cursor = freezed,Object? loadingMonth = null,Object? loadingDay = null,Object? monthError = freezed,Object? dayError = freezed,}) {
  return _then(_self.copyWith(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,selectedDay: null == selectedDay ? _self.selectedDay : selectedDay // ignore: cast_nullable_to_non_nullable
as String,monthData: freezed == monthData ? _self.monthData : monthData // ignore: cast_nullable_to_non_nullable
as MedicationMonth?,serverNow: freezed == serverNow ? _self.serverNow : serverNow // ignore: cast_nullable_to_non_nullable
as DateTime?,agendaVersion: freezed == agendaVersion ? _self.agendaVersion : agendaVersion // ignore: cast_nullable_to_non_nullable
as int?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<MedicationApplication>,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,loadingMonth: null == loadingMonth ? _self.loadingMonth : loadingMonth // ignore: cast_nullable_to_non_nullable
as bool,loadingDay: null == loadingDay ? _self.loadingDay : loadingDay // ignore: cast_nullable_to_non_nullable
as bool,monthError: freezed == monthError ? _self.monthError : monthError // ignore: cast_nullable_to_non_nullable
as String?,dayError: freezed == dayError ? _self.dayError : dayError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of MedicationCalendarState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MedicationMonthCopyWith<$Res>? get monthData {
    if (_self.monthData == null) {
    return null;
  }

  return $MedicationMonthCopyWith<$Res>(_self.monthData!, (value) {
    return _then(_self.copyWith(monthData: value));
  });
}
}


/// Adds pattern-matching-related methods to [MedicationCalendarState].
extension MedicationCalendarStatePatterns on MedicationCalendarState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicationCalendarState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicationCalendarState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicationCalendarState value)  $default,){
final _that = this;
switch (_that) {
case _MedicationCalendarState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicationCalendarState value)?  $default,){
final _that = this;
switch (_that) {
case _MedicationCalendarState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String month,  String selectedDay,  MedicationMonth? monthData,  DateTime? serverNow,  int? agendaVersion,  List<MedicationApplication> items,  String? cursor,  bool loadingMonth,  bool loadingDay,  String? monthError,  String? dayError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicationCalendarState() when $default != null:
return $default(_that.month,_that.selectedDay,_that.monthData,_that.serverNow,_that.agendaVersion,_that.items,_that.cursor,_that.loadingMonth,_that.loadingDay,_that.monthError,_that.dayError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String month,  String selectedDay,  MedicationMonth? monthData,  DateTime? serverNow,  int? agendaVersion,  List<MedicationApplication> items,  String? cursor,  bool loadingMonth,  bool loadingDay,  String? monthError,  String? dayError)  $default,) {final _that = this;
switch (_that) {
case _MedicationCalendarState():
return $default(_that.month,_that.selectedDay,_that.monthData,_that.serverNow,_that.agendaVersion,_that.items,_that.cursor,_that.loadingMonth,_that.loadingDay,_that.monthError,_that.dayError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String month,  String selectedDay,  MedicationMonth? monthData,  DateTime? serverNow,  int? agendaVersion,  List<MedicationApplication> items,  String? cursor,  bool loadingMonth,  bool loadingDay,  String? monthError,  String? dayError)?  $default,) {final _that = this;
switch (_that) {
case _MedicationCalendarState() when $default != null:
return $default(_that.month,_that.selectedDay,_that.monthData,_that.serverNow,_that.agendaVersion,_that.items,_that.cursor,_that.loadingMonth,_that.loadingDay,_that.monthError,_that.dayError);case _:
  return null;

}
}

}

/// @nodoc


class _MedicationCalendarState with DiagnosticableTreeMixin implements MedicationCalendarState {
  const _MedicationCalendarState({this.month = '', this.selectedDay = '', this.monthData, this.serverNow, this.agendaVersion, final  List<MedicationApplication> items = const [], this.cursor, this.loadingMonth = false, this.loadingDay = false, this.monthError, this.dayError}): _items = items;
  

@override@JsonKey() final  String month;
@override@JsonKey() final  String selectedDay;
@override final  MedicationMonth? monthData;
@override final  DateTime? serverNow;
@override final  int? agendaVersion;
 final  List<MedicationApplication> _items;
@override@JsonKey() List<MedicationApplication> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? cursor;
@override@JsonKey() final  bool loadingMonth;
@override@JsonKey() final  bool loadingDay;
@override final  String? monthError;
@override final  String? dayError;

/// Create a copy of MedicationCalendarState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicationCalendarStateCopyWith<_MedicationCalendarState> get copyWith => __$MedicationCalendarStateCopyWithImpl<_MedicationCalendarState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MedicationCalendarState'))
    ..add(DiagnosticsProperty('month', month))..add(DiagnosticsProperty('selectedDay', selectedDay))..add(DiagnosticsProperty('monthData', monthData))..add(DiagnosticsProperty('serverNow', serverNow))..add(DiagnosticsProperty('agendaVersion', agendaVersion))..add(DiagnosticsProperty('items', items))..add(DiagnosticsProperty('cursor', cursor))..add(DiagnosticsProperty('loadingMonth', loadingMonth))..add(DiagnosticsProperty('loadingDay', loadingDay))..add(DiagnosticsProperty('monthError', monthError))..add(DiagnosticsProperty('dayError', dayError));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicationCalendarState&&(identical(other.month, month) || other.month == month)&&(identical(other.selectedDay, selectedDay) || other.selectedDay == selectedDay)&&(identical(other.monthData, monthData) || other.monthData == monthData)&&(identical(other.serverNow, serverNow) || other.serverNow == serverNow)&&(identical(other.agendaVersion, agendaVersion) || other.agendaVersion == agendaVersion)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.cursor, cursor) || other.cursor == cursor)&&(identical(other.loadingMonth, loadingMonth) || other.loadingMonth == loadingMonth)&&(identical(other.loadingDay, loadingDay) || other.loadingDay == loadingDay)&&(identical(other.monthError, monthError) || other.monthError == monthError)&&(identical(other.dayError, dayError) || other.dayError == dayError));
}


@override
int get hashCode => Object.hash(runtimeType,month,selectedDay,monthData,serverNow,agendaVersion,const DeepCollectionEquality().hash(_items),cursor,loadingMonth,loadingDay,monthError,dayError);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MedicationCalendarState(month: $month, selectedDay: $selectedDay, monthData: $monthData, serverNow: $serverNow, agendaVersion: $agendaVersion, items: $items, cursor: $cursor, loadingMonth: $loadingMonth, loadingDay: $loadingDay, monthError: $monthError, dayError: $dayError)';
}


}

/// @nodoc
abstract mixin class _$MedicationCalendarStateCopyWith<$Res> implements $MedicationCalendarStateCopyWith<$Res> {
  factory _$MedicationCalendarStateCopyWith(_MedicationCalendarState value, $Res Function(_MedicationCalendarState) _then) = __$MedicationCalendarStateCopyWithImpl;
@override @useResult
$Res call({
 String month, String selectedDay, MedicationMonth? monthData, DateTime? serverNow, int? agendaVersion, List<MedicationApplication> items, String? cursor, bool loadingMonth, bool loadingDay, String? monthError, String? dayError
});


@override $MedicationMonthCopyWith<$Res>? get monthData;

}
/// @nodoc
class __$MedicationCalendarStateCopyWithImpl<$Res>
    implements _$MedicationCalendarStateCopyWith<$Res> {
  __$MedicationCalendarStateCopyWithImpl(this._self, this._then);

  final _MedicationCalendarState _self;
  final $Res Function(_MedicationCalendarState) _then;

/// Create a copy of MedicationCalendarState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? selectedDay = null,Object? monthData = freezed,Object? serverNow = freezed,Object? agendaVersion = freezed,Object? items = null,Object? cursor = freezed,Object? loadingMonth = null,Object? loadingDay = null,Object? monthError = freezed,Object? dayError = freezed,}) {
  return _then(_MedicationCalendarState(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,selectedDay: null == selectedDay ? _self.selectedDay : selectedDay // ignore: cast_nullable_to_non_nullable
as String,monthData: freezed == monthData ? _self.monthData : monthData // ignore: cast_nullable_to_non_nullable
as MedicationMonth?,serverNow: freezed == serverNow ? _self.serverNow : serverNow // ignore: cast_nullable_to_non_nullable
as DateTime?,agendaVersion: freezed == agendaVersion ? _self.agendaVersion : agendaVersion // ignore: cast_nullable_to_non_nullable
as int?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<MedicationApplication>,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,loadingMonth: null == loadingMonth ? _self.loadingMonth : loadingMonth // ignore: cast_nullable_to_non_nullable
as bool,loadingDay: null == loadingDay ? _self.loadingDay : loadingDay // ignore: cast_nullable_to_non_nullable
as bool,monthError: freezed == monthError ? _self.monthError : monthError // ignore: cast_nullable_to_non_nullable
as String?,dayError: freezed == dayError ? _self.dayError : dayError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of MedicationCalendarState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MedicationMonthCopyWith<$Res>? get monthData {
    if (_self.monthData == null) {
    return null;
  }

  return $MedicationMonthCopyWith<$Res>(_self.monthData!, (value) {
    return _then(_self.copyWith(monthData: value));
  });
}
}

// dart format on
