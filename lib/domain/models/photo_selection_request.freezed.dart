// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_selection_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PhotoSelectionRequest {

 String get animalId; String get userId;
/// Create a copy of PhotoSelectionRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoSelectionRequestCopyWith<PhotoSelectionRequest> get copyWith => _$PhotoSelectionRequestCopyWithImpl<PhotoSelectionRequest>(this as PhotoSelectionRequest, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoSelectionRequest&&(identical(other.animalId, animalId) || other.animalId == animalId)&&(identical(other.userId, userId) || other.userId == userId));
}


@override
int get hashCode => Object.hash(runtimeType,animalId,userId);

@override
String toString() {
  return 'PhotoSelectionRequest(animalId: $animalId, userId: $userId)';
}


}

/// @nodoc
abstract mixin class $PhotoSelectionRequestCopyWith<$Res>  {
  factory $PhotoSelectionRequestCopyWith(PhotoSelectionRequest value, $Res Function(PhotoSelectionRequest) _then) = _$PhotoSelectionRequestCopyWithImpl;
@useResult
$Res call({
 String animalId, String userId
});




}
/// @nodoc
class _$PhotoSelectionRequestCopyWithImpl<$Res>
    implements $PhotoSelectionRequestCopyWith<$Res> {
  _$PhotoSelectionRequestCopyWithImpl(this._self, this._then);

  final PhotoSelectionRequest _self;
  final $Res Function(PhotoSelectionRequest) _then;

/// Create a copy of PhotoSelectionRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? animalId = null,Object? userId = null,}) {
  return _then(_self.copyWith(
animalId: null == animalId ? _self.animalId : animalId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PhotoSelectionRequest].
extension PhotoSelectionRequestPatterns on PhotoSelectionRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhotoSelectionRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhotoSelectionRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhotoSelectionRequest value)  $default,){
final _that = this;
switch (_that) {
case _PhotoSelectionRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhotoSelectionRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PhotoSelectionRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String animalId,  String userId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhotoSelectionRequest() when $default != null:
return $default(_that.animalId,_that.userId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String animalId,  String userId)  $default,) {final _that = this;
switch (_that) {
case _PhotoSelectionRequest():
return $default(_that.animalId,_that.userId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String animalId,  String userId)?  $default,) {final _that = this;
switch (_that) {
case _PhotoSelectionRequest() when $default != null:
return $default(_that.animalId,_that.userId);case _:
  return null;

}
}

}

/// @nodoc


class _PhotoSelectionRequest implements PhotoSelectionRequest {
  const _PhotoSelectionRequest({required this.animalId, required this.userId});
  

@override final  String animalId;
@override final  String userId;

/// Create a copy of PhotoSelectionRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotoSelectionRequestCopyWith<_PhotoSelectionRequest> get copyWith => __$PhotoSelectionRequestCopyWithImpl<_PhotoSelectionRequest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotoSelectionRequest&&(identical(other.animalId, animalId) || other.animalId == animalId)&&(identical(other.userId, userId) || other.userId == userId));
}


@override
int get hashCode => Object.hash(runtimeType,animalId,userId);

@override
String toString() {
  return 'PhotoSelectionRequest(animalId: $animalId, userId: $userId)';
}


}

/// @nodoc
abstract mixin class _$PhotoSelectionRequestCopyWith<$Res> implements $PhotoSelectionRequestCopyWith<$Res> {
  factory _$PhotoSelectionRequestCopyWith(_PhotoSelectionRequest value, $Res Function(_PhotoSelectionRequest) _then) = __$PhotoSelectionRequestCopyWithImpl;
@override @useResult
$Res call({
 String animalId, String userId
});




}
/// @nodoc
class __$PhotoSelectionRequestCopyWithImpl<$Res>
    implements _$PhotoSelectionRequestCopyWith<$Res> {
  __$PhotoSelectionRequestCopyWithImpl(this._self, this._then);

  final _PhotoSelectionRequest _self;
  final $Res Function(_PhotoSelectionRequest) _then;

/// Create a copy of PhotoSelectionRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? animalId = null,Object? userId = null,}) {
  return _then(_PhotoSelectionRequest(
animalId: null == animalId ? _self.animalId : animalId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
