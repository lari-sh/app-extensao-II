// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_recovery_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PhotoRecoveryState implements DiagnosticableTreeMixin {

 PhotoCandidate? get candidate; bool get busy; String? get message;
/// Create a copy of PhotoRecoveryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoRecoveryStateCopyWith<PhotoRecoveryState> get copyWith => _$PhotoRecoveryStateCopyWithImpl<PhotoRecoveryState>(this as PhotoRecoveryState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'PhotoRecoveryState'))
    ..add(DiagnosticsProperty('candidate', candidate))..add(DiagnosticsProperty('busy', busy))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoRecoveryState&&(identical(other.candidate, candidate) || other.candidate == candidate)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,candidate,busy,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'PhotoRecoveryState(candidate: $candidate, busy: $busy, message: $message)';
}


}

/// @nodoc
abstract mixin class $PhotoRecoveryStateCopyWith<$Res>  {
  factory $PhotoRecoveryStateCopyWith(PhotoRecoveryState value, $Res Function(PhotoRecoveryState) _then) = _$PhotoRecoveryStateCopyWithImpl;
@useResult
$Res call({
 PhotoCandidate? candidate, bool busy, String? message
});


$PhotoCandidateCopyWith<$Res>? get candidate;

}
/// @nodoc
class _$PhotoRecoveryStateCopyWithImpl<$Res>
    implements $PhotoRecoveryStateCopyWith<$Res> {
  _$PhotoRecoveryStateCopyWithImpl(this._self, this._then);

  final PhotoRecoveryState _self;
  final $Res Function(PhotoRecoveryState) _then;

/// Create a copy of PhotoRecoveryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? candidate = freezed,Object? busy = null,Object? message = freezed,}) {
  return _then(_self.copyWith(
candidate: freezed == candidate ? _self.candidate : candidate // ignore: cast_nullable_to_non_nullable
as PhotoCandidate?,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of PhotoRecoveryState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PhotoCandidateCopyWith<$Res>? get candidate {
    if (_self.candidate == null) {
    return null;
  }

  return $PhotoCandidateCopyWith<$Res>(_self.candidate!, (value) {
    return _then(_self.copyWith(candidate: value));
  });
}
}


/// Adds pattern-matching-related methods to [PhotoRecoveryState].
extension PhotoRecoveryStatePatterns on PhotoRecoveryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhotoRecoveryState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhotoRecoveryState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhotoRecoveryState value)  $default,){
final _that = this;
switch (_that) {
case _PhotoRecoveryState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhotoRecoveryState value)?  $default,){
final _that = this;
switch (_that) {
case _PhotoRecoveryState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PhotoCandidate? candidate,  bool busy,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhotoRecoveryState() when $default != null:
return $default(_that.candidate,_that.busy,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PhotoCandidate? candidate,  bool busy,  String? message)  $default,) {final _that = this;
switch (_that) {
case _PhotoRecoveryState():
return $default(_that.candidate,_that.busy,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PhotoCandidate? candidate,  bool busy,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _PhotoRecoveryState() when $default != null:
return $default(_that.candidate,_that.busy,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _PhotoRecoveryState with DiagnosticableTreeMixin implements PhotoRecoveryState {
  const _PhotoRecoveryState({this.candidate, this.busy = false, this.message});
  

@override final  PhotoCandidate? candidate;
@override@JsonKey() final  bool busy;
@override final  String? message;

/// Create a copy of PhotoRecoveryState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotoRecoveryStateCopyWith<_PhotoRecoveryState> get copyWith => __$PhotoRecoveryStateCopyWithImpl<_PhotoRecoveryState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'PhotoRecoveryState'))
    ..add(DiagnosticsProperty('candidate', candidate))..add(DiagnosticsProperty('busy', busy))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotoRecoveryState&&(identical(other.candidate, candidate) || other.candidate == candidate)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,candidate,busy,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'PhotoRecoveryState(candidate: $candidate, busy: $busy, message: $message)';
}


}

/// @nodoc
abstract mixin class _$PhotoRecoveryStateCopyWith<$Res> implements $PhotoRecoveryStateCopyWith<$Res> {
  factory _$PhotoRecoveryStateCopyWith(_PhotoRecoveryState value, $Res Function(_PhotoRecoveryState) _then) = __$PhotoRecoveryStateCopyWithImpl;
@override @useResult
$Res call({
 PhotoCandidate? candidate, bool busy, String? message
});


@override $PhotoCandidateCopyWith<$Res>? get candidate;

}
/// @nodoc
class __$PhotoRecoveryStateCopyWithImpl<$Res>
    implements _$PhotoRecoveryStateCopyWith<$Res> {
  __$PhotoRecoveryStateCopyWithImpl(this._self, this._then);

  final _PhotoRecoveryState _self;
  final $Res Function(_PhotoRecoveryState) _then;

/// Create a copy of PhotoRecoveryState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? candidate = freezed,Object? busy = null,Object? message = freezed,}) {
  return _then(_PhotoRecoveryState(
candidate: freezed == candidate ? _self.candidate : candidate // ignore: cast_nullable_to_non_nullable
as PhotoCandidate?,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of PhotoRecoveryState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PhotoCandidateCopyWith<$Res>? get candidate {
    if (_self.candidate == null) {
    return null;
  }

  return $PhotoCandidateCopyWith<$Res>(_self.candidate!, (value) {
    return _then(_self.copyWith(candidate: value));
  });
}
}

// dart format on
