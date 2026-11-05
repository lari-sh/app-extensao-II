// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'accept_invitation_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AcceptInvitationState implements DiagnosticableTreeMixin {

 TeamInvitation? get invitation; bool get loading; bool get busy; bool get accepted; bool get passwordSaved; Map<String, String> get errors; String? get message;
/// Create a copy of AcceptInvitationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AcceptInvitationStateCopyWith<AcceptInvitationState> get copyWith => _$AcceptInvitationStateCopyWithImpl<AcceptInvitationState>(this as AcceptInvitationState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AcceptInvitationState'))
    ..add(DiagnosticsProperty('invitation', invitation))..add(DiagnosticsProperty('loading', loading))..add(DiagnosticsProperty('busy', busy))..add(DiagnosticsProperty('accepted', accepted))..add(DiagnosticsProperty('passwordSaved', passwordSaved))..add(DiagnosticsProperty('errors', errors))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AcceptInvitationState&&(identical(other.invitation, invitation) || other.invitation == invitation)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.accepted, accepted) || other.accepted == accepted)&&(identical(other.passwordSaved, passwordSaved) || other.passwordSaved == passwordSaved)&&const DeepCollectionEquality().equals(other.errors, errors)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,invitation,loading,busy,accepted,passwordSaved,const DeepCollectionEquality().hash(errors),message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AcceptInvitationState(invitation: $invitation, loading: $loading, busy: $busy, accepted: $accepted, passwordSaved: $passwordSaved, errors: $errors, message: $message)';
}


}

/// @nodoc
abstract mixin class $AcceptInvitationStateCopyWith<$Res>  {
  factory $AcceptInvitationStateCopyWith(AcceptInvitationState value, $Res Function(AcceptInvitationState) _then) = _$AcceptInvitationStateCopyWithImpl;
@useResult
$Res call({
 TeamInvitation? invitation, bool loading, bool busy, bool accepted, bool passwordSaved, Map<String, String> errors, String? message
});


$TeamInvitationCopyWith<$Res>? get invitation;

}
/// @nodoc
class _$AcceptInvitationStateCopyWithImpl<$Res>
    implements $AcceptInvitationStateCopyWith<$Res> {
  _$AcceptInvitationStateCopyWithImpl(this._self, this._then);

  final AcceptInvitationState _self;
  final $Res Function(AcceptInvitationState) _then;

/// Create a copy of AcceptInvitationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? invitation = freezed,Object? loading = null,Object? busy = null,Object? accepted = null,Object? passwordSaved = null,Object? errors = null,Object? message = freezed,}) {
  return _then(_self.copyWith(
invitation: freezed == invitation ? _self.invitation : invitation // ignore: cast_nullable_to_non_nullable
as TeamInvitation?,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,accepted: null == accepted ? _self.accepted : accepted // ignore: cast_nullable_to_non_nullable
as bool,passwordSaved: null == passwordSaved ? _self.passwordSaved : passwordSaved // ignore: cast_nullable_to_non_nullable
as bool,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of AcceptInvitationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamInvitationCopyWith<$Res>? get invitation {
    if (_self.invitation == null) {
    return null;
  }

  return $TeamInvitationCopyWith<$Res>(_self.invitation!, (value) {
    return _then(_self.copyWith(invitation: value));
  });
}
}


/// Adds pattern-matching-related methods to [AcceptInvitationState].
extension AcceptInvitationStatePatterns on AcceptInvitationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AcceptInvitationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AcceptInvitationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AcceptInvitationState value)  $default,){
final _that = this;
switch (_that) {
case _AcceptInvitationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AcceptInvitationState value)?  $default,){
final _that = this;
switch (_that) {
case _AcceptInvitationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TeamInvitation? invitation,  bool loading,  bool busy,  bool accepted,  bool passwordSaved,  Map<String, String> errors,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AcceptInvitationState() when $default != null:
return $default(_that.invitation,_that.loading,_that.busy,_that.accepted,_that.passwordSaved,_that.errors,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TeamInvitation? invitation,  bool loading,  bool busy,  bool accepted,  bool passwordSaved,  Map<String, String> errors,  String? message)  $default,) {final _that = this;
switch (_that) {
case _AcceptInvitationState():
return $default(_that.invitation,_that.loading,_that.busy,_that.accepted,_that.passwordSaved,_that.errors,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TeamInvitation? invitation,  bool loading,  bool busy,  bool accepted,  bool passwordSaved,  Map<String, String> errors,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _AcceptInvitationState() when $default != null:
return $default(_that.invitation,_that.loading,_that.busy,_that.accepted,_that.passwordSaved,_that.errors,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _AcceptInvitationState with DiagnosticableTreeMixin implements AcceptInvitationState {
  const _AcceptInvitationState({this.invitation, this.loading = false, this.busy = false, this.accepted = false, this.passwordSaved = false, final  Map<String, String> errors = const {}, this.message}): _errors = errors;
  

@override final  TeamInvitation? invitation;
@override@JsonKey() final  bool loading;
@override@JsonKey() final  bool busy;
@override@JsonKey() final  bool accepted;
@override@JsonKey() final  bool passwordSaved;
 final  Map<String, String> _errors;
@override@JsonKey() Map<String, String> get errors {
  if (_errors is EqualUnmodifiableMapView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_errors);
}

@override final  String? message;

/// Create a copy of AcceptInvitationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AcceptInvitationStateCopyWith<_AcceptInvitationState> get copyWith => __$AcceptInvitationStateCopyWithImpl<_AcceptInvitationState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AcceptInvitationState'))
    ..add(DiagnosticsProperty('invitation', invitation))..add(DiagnosticsProperty('loading', loading))..add(DiagnosticsProperty('busy', busy))..add(DiagnosticsProperty('accepted', accepted))..add(DiagnosticsProperty('passwordSaved', passwordSaved))..add(DiagnosticsProperty('errors', errors))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AcceptInvitationState&&(identical(other.invitation, invitation) || other.invitation == invitation)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.accepted, accepted) || other.accepted == accepted)&&(identical(other.passwordSaved, passwordSaved) || other.passwordSaved == passwordSaved)&&const DeepCollectionEquality().equals(other._errors, _errors)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,invitation,loading,busy,accepted,passwordSaved,const DeepCollectionEquality().hash(_errors),message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AcceptInvitationState(invitation: $invitation, loading: $loading, busy: $busy, accepted: $accepted, passwordSaved: $passwordSaved, errors: $errors, message: $message)';
}


}

/// @nodoc
abstract mixin class _$AcceptInvitationStateCopyWith<$Res> implements $AcceptInvitationStateCopyWith<$Res> {
  factory _$AcceptInvitationStateCopyWith(_AcceptInvitationState value, $Res Function(_AcceptInvitationState) _then) = __$AcceptInvitationStateCopyWithImpl;
@override @useResult
$Res call({
 TeamInvitation? invitation, bool loading, bool busy, bool accepted, bool passwordSaved, Map<String, String> errors, String? message
});


@override $TeamInvitationCopyWith<$Res>? get invitation;

}
/// @nodoc
class __$AcceptInvitationStateCopyWithImpl<$Res>
    implements _$AcceptInvitationStateCopyWith<$Res> {
  __$AcceptInvitationStateCopyWithImpl(this._self, this._then);

  final _AcceptInvitationState _self;
  final $Res Function(_AcceptInvitationState) _then;

/// Create a copy of AcceptInvitationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? invitation = freezed,Object? loading = null,Object? busy = null,Object? accepted = null,Object? passwordSaved = null,Object? errors = null,Object? message = freezed,}) {
  return _then(_AcceptInvitationState(
invitation: freezed == invitation ? _self.invitation : invitation // ignore: cast_nullable_to_non_nullable
as TeamInvitation?,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,accepted: null == accepted ? _self.accepted : accepted // ignore: cast_nullable_to_non_nullable
as bool,passwordSaved: null == passwordSaved ? _self.passwordSaved : passwordSaved // ignore: cast_nullable_to_non_nullable
as bool,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of AcceptInvitationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamInvitationCopyWith<$Res>? get invitation {
    if (_self.invitation == null) {
    return null;
  }

  return $TeamInvitationCopyWith<$Res>(_self.invitation!, (value) {
    return _then(_self.copyWith(invitation: value));
  });
}
}

// dart format on
