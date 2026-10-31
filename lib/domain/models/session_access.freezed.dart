// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_access.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SessionAccess {

 AccessLevel get level; String? get userId; AccessInterruption get interruption;
/// Create a copy of SessionAccess
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionAccessCopyWith<SessionAccess> get copyWith => _$SessionAccessCopyWithImpl<SessionAccess>(this as SessionAccess, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionAccess&&(identical(other.level, level) || other.level == level)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.interruption, interruption) || other.interruption == interruption));
}


@override
int get hashCode => Object.hash(runtimeType,level,userId,interruption);

@override
String toString() {
  return 'SessionAccess(level: $level, userId: $userId, interruption: $interruption)';
}


}

/// @nodoc
abstract mixin class $SessionAccessCopyWith<$Res>  {
  factory $SessionAccessCopyWith(SessionAccess value, $Res Function(SessionAccess) _then) = _$SessionAccessCopyWithImpl;
@useResult
$Res call({
 AccessLevel level, String? userId, AccessInterruption interruption
});




}
/// @nodoc
class _$SessionAccessCopyWithImpl<$Res>
    implements $SessionAccessCopyWith<$Res> {
  _$SessionAccessCopyWithImpl(this._self, this._then);

  final SessionAccess _self;
  final $Res Function(SessionAccess) _then;

/// Create a copy of SessionAccess
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? level = null,Object? userId = freezed,Object? interruption = null,}) {
  return _then(_self.copyWith(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as AccessLevel,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,interruption: null == interruption ? _self.interruption : interruption // ignore: cast_nullable_to_non_nullable
as AccessInterruption,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionAccess].
extension SessionAccessPatterns on SessionAccess {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionAccess value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionAccess() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionAccess value)  $default,){
final _that = this;
switch (_that) {
case _SessionAccess():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionAccess value)?  $default,){
final _that = this;
switch (_that) {
case _SessionAccess() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AccessLevel level,  String? userId,  AccessInterruption interruption)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionAccess() when $default != null:
return $default(_that.level,_that.userId,_that.interruption);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AccessLevel level,  String? userId,  AccessInterruption interruption)  $default,) {final _that = this;
switch (_that) {
case _SessionAccess():
return $default(_that.level,_that.userId,_that.interruption);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AccessLevel level,  String? userId,  AccessInterruption interruption)?  $default,) {final _that = this;
switch (_that) {
case _SessionAccess() when $default != null:
return $default(_that.level,_that.userId,_that.interruption);case _:
  return null;

}
}

}

/// @nodoc


class _SessionAccess extends SessionAccess {
  const _SessionAccess({this.level = AccessLevel.visitor, this.userId, this.interruption = AccessInterruption.definitiveLoss}): super._();
  

@override@JsonKey() final  AccessLevel level;
@override final  String? userId;
@override@JsonKey() final  AccessInterruption interruption;

/// Create a copy of SessionAccess
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionAccessCopyWith<_SessionAccess> get copyWith => __$SessionAccessCopyWithImpl<_SessionAccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionAccess&&(identical(other.level, level) || other.level == level)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.interruption, interruption) || other.interruption == interruption));
}


@override
int get hashCode => Object.hash(runtimeType,level,userId,interruption);

@override
String toString() {
  return 'SessionAccess(level: $level, userId: $userId, interruption: $interruption)';
}


}

/// @nodoc
abstract mixin class _$SessionAccessCopyWith<$Res> implements $SessionAccessCopyWith<$Res> {
  factory _$SessionAccessCopyWith(_SessionAccess value, $Res Function(_SessionAccess) _then) = __$SessionAccessCopyWithImpl;
@override @useResult
$Res call({
 AccessLevel level, String? userId, AccessInterruption interruption
});




}
/// @nodoc
class __$SessionAccessCopyWithImpl<$Res>
    implements _$SessionAccessCopyWith<$Res> {
  __$SessionAccessCopyWithImpl(this._self, this._then);

  final _SessionAccess _self;
  final $Res Function(_SessionAccess) _then;

/// Create a copy of SessionAccess
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? level = null,Object? userId = freezed,Object? interruption = null,}) {
  return _then(_SessionAccess(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as AccessLevel,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,interruption: null == interruption ? _self.interruption : interruption // ignore: cast_nullable_to_non_nullable
as AccessInterruption,
  ));
}


}

// dart format on
