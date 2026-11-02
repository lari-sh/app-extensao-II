// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SessionState implements DiagnosticableTreeMixin {

 SessionPhase get phase; String? get userId; bool get canAccessPrivate; bool get canManageTeam; StaffRole? get staffRole; bool get hidePrivate; bool get retainPrivate; bool get requiresReauthentication; bool get signingOut; int get privateGeneration; int get accessEpoch; String? get message;
/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionStateCopyWith<SessionState> get copyWith => _$SessionStateCopyWithImpl<SessionState>(this as SessionState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'SessionState'))
    ..add(DiagnosticsProperty('phase', phase))..add(DiagnosticsProperty('userId', userId))..add(DiagnosticsProperty('canAccessPrivate', canAccessPrivate))..add(DiagnosticsProperty('canManageTeam', canManageTeam))..add(DiagnosticsProperty('staffRole', staffRole))..add(DiagnosticsProperty('hidePrivate', hidePrivate))..add(DiagnosticsProperty('retainPrivate', retainPrivate))..add(DiagnosticsProperty('requiresReauthentication', requiresReauthentication))..add(DiagnosticsProperty('signingOut', signingOut))..add(DiagnosticsProperty('privateGeneration', privateGeneration))..add(DiagnosticsProperty('accessEpoch', accessEpoch))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.canAccessPrivate, canAccessPrivate) || other.canAccessPrivate == canAccessPrivate)&&(identical(other.canManageTeam, canManageTeam) || other.canManageTeam == canManageTeam)&&(identical(other.staffRole, staffRole) || other.staffRole == staffRole)&&(identical(other.hidePrivate, hidePrivate) || other.hidePrivate == hidePrivate)&&(identical(other.retainPrivate, retainPrivate) || other.retainPrivate == retainPrivate)&&(identical(other.requiresReauthentication, requiresReauthentication) || other.requiresReauthentication == requiresReauthentication)&&(identical(other.signingOut, signingOut) || other.signingOut == signingOut)&&(identical(other.privateGeneration, privateGeneration) || other.privateGeneration == privateGeneration)&&(identical(other.accessEpoch, accessEpoch) || other.accessEpoch == accessEpoch)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,phase,userId,canAccessPrivate,canManageTeam,staffRole,hidePrivate,retainPrivate,requiresReauthentication,signingOut,privateGeneration,accessEpoch,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'SessionState(phase: $phase, userId: $userId, canAccessPrivate: $canAccessPrivate, canManageTeam: $canManageTeam, staffRole: $staffRole, hidePrivate: $hidePrivate, retainPrivate: $retainPrivate, requiresReauthentication: $requiresReauthentication, signingOut: $signingOut, privateGeneration: $privateGeneration, accessEpoch: $accessEpoch, message: $message)';
}


}

/// @nodoc
abstract mixin class $SessionStateCopyWith<$Res>  {
  factory $SessionStateCopyWith(SessionState value, $Res Function(SessionState) _then) = _$SessionStateCopyWithImpl;
@useResult
$Res call({
 SessionPhase phase, String? userId, bool canAccessPrivate, bool canManageTeam, StaffRole? staffRole, bool hidePrivate, bool retainPrivate, bool requiresReauthentication, bool signingOut, int privateGeneration, int accessEpoch, String? message
});




}
/// @nodoc
class _$SessionStateCopyWithImpl<$Res>
    implements $SessionStateCopyWith<$Res> {
  _$SessionStateCopyWithImpl(this._self, this._then);

  final SessionState _self;
  final $Res Function(SessionState) _then;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phase = null,Object? userId = freezed,Object? canAccessPrivate = null,Object? canManageTeam = null,Object? staffRole = freezed,Object? hidePrivate = null,Object? retainPrivate = null,Object? requiresReauthentication = null,Object? signingOut = null,Object? privateGeneration = null,Object? accessEpoch = null,Object? message = freezed,}) {
  return _then(_self.copyWith(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as SessionPhase,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,canAccessPrivate: null == canAccessPrivate ? _self.canAccessPrivate : canAccessPrivate // ignore: cast_nullable_to_non_nullable
as bool,canManageTeam: null == canManageTeam ? _self.canManageTeam : canManageTeam // ignore: cast_nullable_to_non_nullable
as bool,staffRole: freezed == staffRole ? _self.staffRole : staffRole // ignore: cast_nullable_to_non_nullable
as StaffRole?,hidePrivate: null == hidePrivate ? _self.hidePrivate : hidePrivate // ignore: cast_nullable_to_non_nullable
as bool,retainPrivate: null == retainPrivate ? _self.retainPrivate : retainPrivate // ignore: cast_nullable_to_non_nullable
as bool,requiresReauthentication: null == requiresReauthentication ? _self.requiresReauthentication : requiresReauthentication // ignore: cast_nullable_to_non_nullable
as bool,signingOut: null == signingOut ? _self.signingOut : signingOut // ignore: cast_nullable_to_non_nullable
as bool,privateGeneration: null == privateGeneration ? _self.privateGeneration : privateGeneration // ignore: cast_nullable_to_non_nullable
as int,accessEpoch: null == accessEpoch ? _self.accessEpoch : accessEpoch // ignore: cast_nullable_to_non_nullable
as int,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionState].
extension SessionStatePatterns on SessionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionState value)  $default,){
final _that = this;
switch (_that) {
case _SessionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionState value)?  $default,){
final _that = this;
switch (_that) {
case _SessionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SessionPhase phase,  String? userId,  bool canAccessPrivate,  bool canManageTeam,  StaffRole? staffRole,  bool hidePrivate,  bool retainPrivate,  bool requiresReauthentication,  bool signingOut,  int privateGeneration,  int accessEpoch,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionState() when $default != null:
return $default(_that.phase,_that.userId,_that.canAccessPrivate,_that.canManageTeam,_that.staffRole,_that.hidePrivate,_that.retainPrivate,_that.requiresReauthentication,_that.signingOut,_that.privateGeneration,_that.accessEpoch,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SessionPhase phase,  String? userId,  bool canAccessPrivate,  bool canManageTeam,  StaffRole? staffRole,  bool hidePrivate,  bool retainPrivate,  bool requiresReauthentication,  bool signingOut,  int privateGeneration,  int accessEpoch,  String? message)  $default,) {final _that = this;
switch (_that) {
case _SessionState():
return $default(_that.phase,_that.userId,_that.canAccessPrivate,_that.canManageTeam,_that.staffRole,_that.hidePrivate,_that.retainPrivate,_that.requiresReauthentication,_that.signingOut,_that.privateGeneration,_that.accessEpoch,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SessionPhase phase,  String? userId,  bool canAccessPrivate,  bool canManageTeam,  StaffRole? staffRole,  bool hidePrivate,  bool retainPrivate,  bool requiresReauthentication,  bool signingOut,  int privateGeneration,  int accessEpoch,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _SessionState() when $default != null:
return $default(_that.phase,_that.userId,_that.canAccessPrivate,_that.canManageTeam,_that.staffRole,_that.hidePrivate,_that.retainPrivate,_that.requiresReauthentication,_that.signingOut,_that.privateGeneration,_that.accessEpoch,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _SessionState with DiagnosticableTreeMixin implements SessionState {
  const _SessionState({this.phase = SessionPhase.checking, this.userId, this.canAccessPrivate = false, this.canManageTeam = false, this.staffRole, this.hidePrivate = true, this.retainPrivate = false, this.requiresReauthentication = false, this.signingOut = false, this.privateGeneration = 0, this.accessEpoch = 0, this.message});
  

@override@JsonKey() final  SessionPhase phase;
@override final  String? userId;
@override@JsonKey() final  bool canAccessPrivate;
@override@JsonKey() final  bool canManageTeam;
@override final  StaffRole? staffRole;
@override@JsonKey() final  bool hidePrivate;
@override@JsonKey() final  bool retainPrivate;
@override@JsonKey() final  bool requiresReauthentication;
@override@JsonKey() final  bool signingOut;
@override@JsonKey() final  int privateGeneration;
@override@JsonKey() final  int accessEpoch;
@override final  String? message;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionStateCopyWith<_SessionState> get copyWith => __$SessionStateCopyWithImpl<_SessionState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'SessionState'))
    ..add(DiagnosticsProperty('phase', phase))..add(DiagnosticsProperty('userId', userId))..add(DiagnosticsProperty('canAccessPrivate', canAccessPrivate))..add(DiagnosticsProperty('canManageTeam', canManageTeam))..add(DiagnosticsProperty('staffRole', staffRole))..add(DiagnosticsProperty('hidePrivate', hidePrivate))..add(DiagnosticsProperty('retainPrivate', retainPrivate))..add(DiagnosticsProperty('requiresReauthentication', requiresReauthentication))..add(DiagnosticsProperty('signingOut', signingOut))..add(DiagnosticsProperty('privateGeneration', privateGeneration))..add(DiagnosticsProperty('accessEpoch', accessEpoch))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.canAccessPrivate, canAccessPrivate) || other.canAccessPrivate == canAccessPrivate)&&(identical(other.canManageTeam, canManageTeam) || other.canManageTeam == canManageTeam)&&(identical(other.staffRole, staffRole) || other.staffRole == staffRole)&&(identical(other.hidePrivate, hidePrivate) || other.hidePrivate == hidePrivate)&&(identical(other.retainPrivate, retainPrivate) || other.retainPrivate == retainPrivate)&&(identical(other.requiresReauthentication, requiresReauthentication) || other.requiresReauthentication == requiresReauthentication)&&(identical(other.signingOut, signingOut) || other.signingOut == signingOut)&&(identical(other.privateGeneration, privateGeneration) || other.privateGeneration == privateGeneration)&&(identical(other.accessEpoch, accessEpoch) || other.accessEpoch == accessEpoch)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,phase,userId,canAccessPrivate,canManageTeam,staffRole,hidePrivate,retainPrivate,requiresReauthentication,signingOut,privateGeneration,accessEpoch,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'SessionState(phase: $phase, userId: $userId, canAccessPrivate: $canAccessPrivate, canManageTeam: $canManageTeam, staffRole: $staffRole, hidePrivate: $hidePrivate, retainPrivate: $retainPrivate, requiresReauthentication: $requiresReauthentication, signingOut: $signingOut, privateGeneration: $privateGeneration, accessEpoch: $accessEpoch, message: $message)';
}


}

/// @nodoc
abstract mixin class _$SessionStateCopyWith<$Res> implements $SessionStateCopyWith<$Res> {
  factory _$SessionStateCopyWith(_SessionState value, $Res Function(_SessionState) _then) = __$SessionStateCopyWithImpl;
@override @useResult
$Res call({
 SessionPhase phase, String? userId, bool canAccessPrivate, bool canManageTeam, StaffRole? staffRole, bool hidePrivate, bool retainPrivate, bool requiresReauthentication, bool signingOut, int privateGeneration, int accessEpoch, String? message
});




}
/// @nodoc
class __$SessionStateCopyWithImpl<$Res>
    implements _$SessionStateCopyWith<$Res> {
  __$SessionStateCopyWithImpl(this._self, this._then);

  final _SessionState _self;
  final $Res Function(_SessionState) _then;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? userId = freezed,Object? canAccessPrivate = null,Object? canManageTeam = null,Object? staffRole = freezed,Object? hidePrivate = null,Object? retainPrivate = null,Object? requiresReauthentication = null,Object? signingOut = null,Object? privateGeneration = null,Object? accessEpoch = null,Object? message = freezed,}) {
  return _then(_SessionState(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as SessionPhase,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,canAccessPrivate: null == canAccessPrivate ? _self.canAccessPrivate : canAccessPrivate // ignore: cast_nullable_to_non_nullable
as bool,canManageTeam: null == canManageTeam ? _self.canManageTeam : canManageTeam // ignore: cast_nullable_to_non_nullable
as bool,staffRole: freezed == staffRole ? _self.staffRole : staffRole // ignore: cast_nullable_to_non_nullable
as StaffRole?,hidePrivate: null == hidePrivate ? _self.hidePrivate : hidePrivate // ignore: cast_nullable_to_non_nullable
as bool,retainPrivate: null == retainPrivate ? _self.retainPrivate : retainPrivate // ignore: cast_nullable_to_non_nullable
as bool,requiresReauthentication: null == requiresReauthentication ? _self.requiresReauthentication : requiresReauthentication // ignore: cast_nullable_to_non_nullable
as bool,signingOut: null == signingOut ? _self.signingOut : signingOut // ignore: cast_nullable_to_non_nullable
as bool,privateGeneration: null == privateGeneration ? _self.privateGeneration : privateGeneration // ignore: cast_nullable_to_non_nullable
as int,accessEpoch: null == accessEpoch ? _self.accessEpoch : accessEpoch // ignore: cast_nullable_to_non_nullable
as int,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
