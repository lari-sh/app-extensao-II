// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medication_application_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MedicationApplicationStateData implements DiagnosticableTreeMixin {

 MedicationApplication? get application; List<MedicationApplicationEvent> get events; String? get cursor; DateTime? get serverNow; String get scheduleLabel; bool get loading; bool get busy; bool get uncertain; bool get canRetry; bool get loadFailed; bool get showCorrection; String get correctionReason; String? get correctionError; String? get message;
/// Create a copy of MedicationApplicationStateData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicationApplicationStateDataCopyWith<MedicationApplicationStateData> get copyWith => _$MedicationApplicationStateDataCopyWithImpl<MedicationApplicationStateData>(this as MedicationApplicationStateData, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MedicationApplicationStateData'))
    ..add(DiagnosticsProperty('application', application))..add(DiagnosticsProperty('events', events))..add(DiagnosticsProperty('cursor', cursor))..add(DiagnosticsProperty('serverNow', serverNow))..add(DiagnosticsProperty('scheduleLabel', scheduleLabel))..add(DiagnosticsProperty('loading', loading))..add(DiagnosticsProperty('busy', busy))..add(DiagnosticsProperty('uncertain', uncertain))..add(DiagnosticsProperty('canRetry', canRetry))..add(DiagnosticsProperty('loadFailed', loadFailed))..add(DiagnosticsProperty('showCorrection', showCorrection))..add(DiagnosticsProperty('correctionReason', correctionReason))..add(DiagnosticsProperty('correctionError', correctionError))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicationApplicationStateData&&(identical(other.application, application) || other.application == application)&&const DeepCollectionEquality().equals(other.events, events)&&(identical(other.cursor, cursor) || other.cursor == cursor)&&(identical(other.serverNow, serverNow) || other.serverNow == serverNow)&&(identical(other.scheduleLabel, scheduleLabel) || other.scheduleLabel == scheduleLabel)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.uncertain, uncertain) || other.uncertain == uncertain)&&(identical(other.canRetry, canRetry) || other.canRetry == canRetry)&&(identical(other.loadFailed, loadFailed) || other.loadFailed == loadFailed)&&(identical(other.showCorrection, showCorrection) || other.showCorrection == showCorrection)&&(identical(other.correctionReason, correctionReason) || other.correctionReason == correctionReason)&&(identical(other.correctionError, correctionError) || other.correctionError == correctionError)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,application,const DeepCollectionEquality().hash(events),cursor,serverNow,scheduleLabel,loading,busy,uncertain,canRetry,loadFailed,showCorrection,correctionReason,correctionError,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MedicationApplicationStateData(application: $application, events: $events, cursor: $cursor, serverNow: $serverNow, scheduleLabel: $scheduleLabel, loading: $loading, busy: $busy, uncertain: $uncertain, canRetry: $canRetry, loadFailed: $loadFailed, showCorrection: $showCorrection, correctionReason: $correctionReason, correctionError: $correctionError, message: $message)';
}


}

/// @nodoc
abstract mixin class $MedicationApplicationStateDataCopyWith<$Res>  {
  factory $MedicationApplicationStateDataCopyWith(MedicationApplicationStateData value, $Res Function(MedicationApplicationStateData) _then) = _$MedicationApplicationStateDataCopyWithImpl;
@useResult
$Res call({
 MedicationApplication? application, List<MedicationApplicationEvent> events, String? cursor, DateTime? serverNow, String scheduleLabel, bool loading, bool busy, bool uncertain, bool canRetry, bool loadFailed, bool showCorrection, String correctionReason, String? correctionError, String? message
});


$MedicationApplicationCopyWith<$Res>? get application;

}
/// @nodoc
class _$MedicationApplicationStateDataCopyWithImpl<$Res>
    implements $MedicationApplicationStateDataCopyWith<$Res> {
  _$MedicationApplicationStateDataCopyWithImpl(this._self, this._then);

  final MedicationApplicationStateData _self;
  final $Res Function(MedicationApplicationStateData) _then;

/// Create a copy of MedicationApplicationStateData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? application = freezed,Object? events = null,Object? cursor = freezed,Object? serverNow = freezed,Object? scheduleLabel = null,Object? loading = null,Object? busy = null,Object? uncertain = null,Object? canRetry = null,Object? loadFailed = null,Object? showCorrection = null,Object? correctionReason = null,Object? correctionError = freezed,Object? message = freezed,}) {
  return _then(_self.copyWith(
application: freezed == application ? _self.application : application // ignore: cast_nullable_to_non_nullable
as MedicationApplication?,events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as List<MedicationApplicationEvent>,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,serverNow: freezed == serverNow ? _self.serverNow : serverNow // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduleLabel: null == scheduleLabel ? _self.scheduleLabel : scheduleLabel // ignore: cast_nullable_to_non_nullable
as String,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,uncertain: null == uncertain ? _self.uncertain : uncertain // ignore: cast_nullable_to_non_nullable
as bool,canRetry: null == canRetry ? _self.canRetry : canRetry // ignore: cast_nullable_to_non_nullable
as bool,loadFailed: null == loadFailed ? _self.loadFailed : loadFailed // ignore: cast_nullable_to_non_nullable
as bool,showCorrection: null == showCorrection ? _self.showCorrection : showCorrection // ignore: cast_nullable_to_non_nullable
as bool,correctionReason: null == correctionReason ? _self.correctionReason : correctionReason // ignore: cast_nullable_to_non_nullable
as String,correctionError: freezed == correctionError ? _self.correctionError : correctionError // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of MedicationApplicationStateData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MedicationApplicationCopyWith<$Res>? get application {
    if (_self.application == null) {
    return null;
  }

  return $MedicationApplicationCopyWith<$Res>(_self.application!, (value) {
    return _then(_self.copyWith(application: value));
  });
}
}


/// Adds pattern-matching-related methods to [MedicationApplicationStateData].
extension MedicationApplicationStateDataPatterns on MedicationApplicationStateData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicationApplicationStateData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicationApplicationStateData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicationApplicationStateData value)  $default,){
final _that = this;
switch (_that) {
case _MedicationApplicationStateData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicationApplicationStateData value)?  $default,){
final _that = this;
switch (_that) {
case _MedicationApplicationStateData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MedicationApplication? application,  List<MedicationApplicationEvent> events,  String? cursor,  DateTime? serverNow,  String scheduleLabel,  bool loading,  bool busy,  bool uncertain,  bool canRetry,  bool loadFailed,  bool showCorrection,  String correctionReason,  String? correctionError,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicationApplicationStateData() when $default != null:
return $default(_that.application,_that.events,_that.cursor,_that.serverNow,_that.scheduleLabel,_that.loading,_that.busy,_that.uncertain,_that.canRetry,_that.loadFailed,_that.showCorrection,_that.correctionReason,_that.correctionError,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MedicationApplication? application,  List<MedicationApplicationEvent> events,  String? cursor,  DateTime? serverNow,  String scheduleLabel,  bool loading,  bool busy,  bool uncertain,  bool canRetry,  bool loadFailed,  bool showCorrection,  String correctionReason,  String? correctionError,  String? message)  $default,) {final _that = this;
switch (_that) {
case _MedicationApplicationStateData():
return $default(_that.application,_that.events,_that.cursor,_that.serverNow,_that.scheduleLabel,_that.loading,_that.busy,_that.uncertain,_that.canRetry,_that.loadFailed,_that.showCorrection,_that.correctionReason,_that.correctionError,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MedicationApplication? application,  List<MedicationApplicationEvent> events,  String? cursor,  DateTime? serverNow,  String scheduleLabel,  bool loading,  bool busy,  bool uncertain,  bool canRetry,  bool loadFailed,  bool showCorrection,  String correctionReason,  String? correctionError,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _MedicationApplicationStateData() when $default != null:
return $default(_that.application,_that.events,_that.cursor,_that.serverNow,_that.scheduleLabel,_that.loading,_that.busy,_that.uncertain,_that.canRetry,_that.loadFailed,_that.showCorrection,_that.correctionReason,_that.correctionError,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _MedicationApplicationStateData with DiagnosticableTreeMixin implements MedicationApplicationStateData {
  const _MedicationApplicationStateData({this.application, final  List<MedicationApplicationEvent> events = const [], this.cursor, this.serverNow, this.scheduleLabel = 'Vinculada à ficha do animal', this.loading = false, this.busy = false, this.uncertain = false, this.canRetry = false, this.loadFailed = false, this.showCorrection = false, this.correctionReason = '', this.correctionError, this.message}): _events = events;
  

@override final  MedicationApplication? application;
 final  List<MedicationApplicationEvent> _events;
@override@JsonKey() List<MedicationApplicationEvent> get events {
  if (_events is EqualUnmodifiableListView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_events);
}

@override final  String? cursor;
@override final  DateTime? serverNow;
@override@JsonKey() final  String scheduleLabel;
@override@JsonKey() final  bool loading;
@override@JsonKey() final  bool busy;
@override@JsonKey() final  bool uncertain;
@override@JsonKey() final  bool canRetry;
@override@JsonKey() final  bool loadFailed;
@override@JsonKey() final  bool showCorrection;
@override@JsonKey() final  String correctionReason;
@override final  String? correctionError;
@override final  String? message;

/// Create a copy of MedicationApplicationStateData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicationApplicationStateDataCopyWith<_MedicationApplicationStateData> get copyWith => __$MedicationApplicationStateDataCopyWithImpl<_MedicationApplicationStateData>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MedicationApplicationStateData'))
    ..add(DiagnosticsProperty('application', application))..add(DiagnosticsProperty('events', events))..add(DiagnosticsProperty('cursor', cursor))..add(DiagnosticsProperty('serverNow', serverNow))..add(DiagnosticsProperty('scheduleLabel', scheduleLabel))..add(DiagnosticsProperty('loading', loading))..add(DiagnosticsProperty('busy', busy))..add(DiagnosticsProperty('uncertain', uncertain))..add(DiagnosticsProperty('canRetry', canRetry))..add(DiagnosticsProperty('loadFailed', loadFailed))..add(DiagnosticsProperty('showCorrection', showCorrection))..add(DiagnosticsProperty('correctionReason', correctionReason))..add(DiagnosticsProperty('correctionError', correctionError))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicationApplicationStateData&&(identical(other.application, application) || other.application == application)&&const DeepCollectionEquality().equals(other._events, _events)&&(identical(other.cursor, cursor) || other.cursor == cursor)&&(identical(other.serverNow, serverNow) || other.serverNow == serverNow)&&(identical(other.scheduleLabel, scheduleLabel) || other.scheduleLabel == scheduleLabel)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.uncertain, uncertain) || other.uncertain == uncertain)&&(identical(other.canRetry, canRetry) || other.canRetry == canRetry)&&(identical(other.loadFailed, loadFailed) || other.loadFailed == loadFailed)&&(identical(other.showCorrection, showCorrection) || other.showCorrection == showCorrection)&&(identical(other.correctionReason, correctionReason) || other.correctionReason == correctionReason)&&(identical(other.correctionError, correctionError) || other.correctionError == correctionError)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,application,const DeepCollectionEquality().hash(_events),cursor,serverNow,scheduleLabel,loading,busy,uncertain,canRetry,loadFailed,showCorrection,correctionReason,correctionError,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MedicationApplicationStateData(application: $application, events: $events, cursor: $cursor, serverNow: $serverNow, scheduleLabel: $scheduleLabel, loading: $loading, busy: $busy, uncertain: $uncertain, canRetry: $canRetry, loadFailed: $loadFailed, showCorrection: $showCorrection, correctionReason: $correctionReason, correctionError: $correctionError, message: $message)';
}


}

/// @nodoc
abstract mixin class _$MedicationApplicationStateDataCopyWith<$Res> implements $MedicationApplicationStateDataCopyWith<$Res> {
  factory _$MedicationApplicationStateDataCopyWith(_MedicationApplicationStateData value, $Res Function(_MedicationApplicationStateData) _then) = __$MedicationApplicationStateDataCopyWithImpl;
@override @useResult
$Res call({
 MedicationApplication? application, List<MedicationApplicationEvent> events, String? cursor, DateTime? serverNow, String scheduleLabel, bool loading, bool busy, bool uncertain, bool canRetry, bool loadFailed, bool showCorrection, String correctionReason, String? correctionError, String? message
});


@override $MedicationApplicationCopyWith<$Res>? get application;

}
/// @nodoc
class __$MedicationApplicationStateDataCopyWithImpl<$Res>
    implements _$MedicationApplicationStateDataCopyWith<$Res> {
  __$MedicationApplicationStateDataCopyWithImpl(this._self, this._then);

  final _MedicationApplicationStateData _self;
  final $Res Function(_MedicationApplicationStateData) _then;

/// Create a copy of MedicationApplicationStateData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? application = freezed,Object? events = null,Object? cursor = freezed,Object? serverNow = freezed,Object? scheduleLabel = null,Object? loading = null,Object? busy = null,Object? uncertain = null,Object? canRetry = null,Object? loadFailed = null,Object? showCorrection = null,Object? correctionReason = null,Object? correctionError = freezed,Object? message = freezed,}) {
  return _then(_MedicationApplicationStateData(
application: freezed == application ? _self.application : application // ignore: cast_nullable_to_non_nullable
as MedicationApplication?,events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as List<MedicationApplicationEvent>,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,serverNow: freezed == serverNow ? _self.serverNow : serverNow // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduleLabel: null == scheduleLabel ? _self.scheduleLabel : scheduleLabel // ignore: cast_nullable_to_non_nullable
as String,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,uncertain: null == uncertain ? _self.uncertain : uncertain // ignore: cast_nullable_to_non_nullable
as bool,canRetry: null == canRetry ? _self.canRetry : canRetry // ignore: cast_nullable_to_non_nullable
as bool,loadFailed: null == loadFailed ? _self.loadFailed : loadFailed // ignore: cast_nullable_to_non_nullable
as bool,showCorrection: null == showCorrection ? _self.showCorrection : showCorrection // ignore: cast_nullable_to_non_nullable
as bool,correctionReason: null == correctionReason ? _self.correctionReason : correctionReason // ignore: cast_nullable_to_non_nullable
as String,correctionError: freezed == correctionError ? _self.correctionError : correctionError // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of MedicationApplicationStateData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MedicationApplicationCopyWith<$Res>? get application {
    if (_self.application == null) {
    return null;
  }

  return $MedicationApplicationCopyWith<$Res>(_self.application!, (value) {
    return _then(_self.copyWith(application: value));
  });
}
}

// dart format on
