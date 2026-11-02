// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recovery_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecoveryState implements DiagnosticableTreeMixin {

 bool get busy; bool get loading; bool get available; bool get completed; Map<String, String> get errors; String? get message;
/// Create a copy of RecoveryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecoveryStateCopyWith<RecoveryState> get copyWith => _$RecoveryStateCopyWithImpl<RecoveryState>(this as RecoveryState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'RecoveryState'))
    ..add(DiagnosticsProperty('busy', busy))..add(DiagnosticsProperty('loading', loading))..add(DiagnosticsProperty('available', available))..add(DiagnosticsProperty('completed', completed))..add(DiagnosticsProperty('errors', errors))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecoveryState&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.available, available) || other.available == available)&&(identical(other.completed, completed) || other.completed == completed)&&const DeepCollectionEquality().equals(other.errors, errors)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,busy,loading,available,completed,const DeepCollectionEquality().hash(errors),message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'RecoveryState(busy: $busy, loading: $loading, available: $available, completed: $completed, errors: $errors, message: $message)';
}


}

/// @nodoc
abstract mixin class $RecoveryStateCopyWith<$Res>  {
  factory $RecoveryStateCopyWith(RecoveryState value, $Res Function(RecoveryState) _then) = _$RecoveryStateCopyWithImpl;
@useResult
$Res call({
 bool busy, bool loading, bool available, bool completed, Map<String, String> errors, String? message
});




}
/// @nodoc
class _$RecoveryStateCopyWithImpl<$Res>
    implements $RecoveryStateCopyWith<$Res> {
  _$RecoveryStateCopyWithImpl(this._self, this._then);

  final RecoveryState _self;
  final $Res Function(RecoveryState) _then;

/// Create a copy of RecoveryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? busy = null,Object? loading = null,Object? available = null,Object? completed = null,Object? errors = null,Object? message = freezed,}) {
  return _then(_self.copyWith(
busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecoveryState].
extension RecoveryStatePatterns on RecoveryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecoveryState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecoveryState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecoveryState value)  $default,){
final _that = this;
switch (_that) {
case _RecoveryState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecoveryState value)?  $default,){
final _that = this;
switch (_that) {
case _RecoveryState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool busy,  bool loading,  bool available,  bool completed,  Map<String, String> errors,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecoveryState() when $default != null:
return $default(_that.busy,_that.loading,_that.available,_that.completed,_that.errors,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool busy,  bool loading,  bool available,  bool completed,  Map<String, String> errors,  String? message)  $default,) {final _that = this;
switch (_that) {
case _RecoveryState():
return $default(_that.busy,_that.loading,_that.available,_that.completed,_that.errors,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool busy,  bool loading,  bool available,  bool completed,  Map<String, String> errors,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _RecoveryState() when $default != null:
return $default(_that.busy,_that.loading,_that.available,_that.completed,_that.errors,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _RecoveryState with DiagnosticableTreeMixin implements RecoveryState {
  const _RecoveryState({this.busy = false, this.loading = false, this.available = false, this.completed = false, final  Map<String, String> errors = const {}, this.message}): _errors = errors;
  

@override@JsonKey() final  bool busy;
@override@JsonKey() final  bool loading;
@override@JsonKey() final  bool available;
@override@JsonKey() final  bool completed;
 final  Map<String, String> _errors;
@override@JsonKey() Map<String, String> get errors {
  if (_errors is EqualUnmodifiableMapView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_errors);
}

@override final  String? message;

/// Create a copy of RecoveryState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecoveryStateCopyWith<_RecoveryState> get copyWith => __$RecoveryStateCopyWithImpl<_RecoveryState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'RecoveryState'))
    ..add(DiagnosticsProperty('busy', busy))..add(DiagnosticsProperty('loading', loading))..add(DiagnosticsProperty('available', available))..add(DiagnosticsProperty('completed', completed))..add(DiagnosticsProperty('errors', errors))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecoveryState&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.available, available) || other.available == available)&&(identical(other.completed, completed) || other.completed == completed)&&const DeepCollectionEquality().equals(other._errors, _errors)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,busy,loading,available,completed,const DeepCollectionEquality().hash(_errors),message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'RecoveryState(busy: $busy, loading: $loading, available: $available, completed: $completed, errors: $errors, message: $message)';
}


}

/// @nodoc
abstract mixin class _$RecoveryStateCopyWith<$Res> implements $RecoveryStateCopyWith<$Res> {
  factory _$RecoveryStateCopyWith(_RecoveryState value, $Res Function(_RecoveryState) _then) = __$RecoveryStateCopyWithImpl;
@override @useResult
$Res call({
 bool busy, bool loading, bool available, bool completed, Map<String, String> errors, String? message
});




}
/// @nodoc
class __$RecoveryStateCopyWithImpl<$Res>
    implements _$RecoveryStateCopyWith<$Res> {
  __$RecoveryStateCopyWithImpl(this._self, this._then);

  final _RecoveryState _self;
  final $Res Function(_RecoveryState) _then;

/// Create a copy of RecoveryState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? busy = null,Object? loading = null,Object? available = null,Object? completed = null,Object? errors = null,Object? message = freezed,}) {
  return _then(_RecoveryState(
busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as bool,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
