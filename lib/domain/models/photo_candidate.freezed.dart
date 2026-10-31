// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_candidate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PhotoCandidate {

 List<int> get bytes; String get mime;
/// Create a copy of PhotoCandidate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoCandidateCopyWith<PhotoCandidate> get copyWith => _$PhotoCandidateCopyWithImpl<PhotoCandidate>(this as PhotoCandidate, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoCandidate&&const DeepCollectionEquality().equals(other.bytes, bytes)&&(identical(other.mime, mime) || other.mime == mime));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(bytes),mime);

@override
String toString() {
  return 'PhotoCandidate(bytes: $bytes, mime: $mime)';
}


}

/// @nodoc
abstract mixin class $PhotoCandidateCopyWith<$Res>  {
  factory $PhotoCandidateCopyWith(PhotoCandidate value, $Res Function(PhotoCandidate) _then) = _$PhotoCandidateCopyWithImpl;
@useResult
$Res call({
 List<int> bytes, String mime
});




}
/// @nodoc
class _$PhotoCandidateCopyWithImpl<$Res>
    implements $PhotoCandidateCopyWith<$Res> {
  _$PhotoCandidateCopyWithImpl(this._self, this._then);

  final PhotoCandidate _self;
  final $Res Function(PhotoCandidate) _then;

/// Create a copy of PhotoCandidate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bytes = null,Object? mime = null,}) {
  return _then(_self.copyWith(
bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as List<int>,mime: null == mime ? _self.mime : mime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PhotoCandidate].
extension PhotoCandidatePatterns on PhotoCandidate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhotoCandidate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhotoCandidate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhotoCandidate value)  $default,){
final _that = this;
switch (_that) {
case _PhotoCandidate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhotoCandidate value)?  $default,){
final _that = this;
switch (_that) {
case _PhotoCandidate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<int> bytes,  String mime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhotoCandidate() when $default != null:
return $default(_that.bytes,_that.mime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<int> bytes,  String mime)  $default,) {final _that = this;
switch (_that) {
case _PhotoCandidate():
return $default(_that.bytes,_that.mime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<int> bytes,  String mime)?  $default,) {final _that = this;
switch (_that) {
case _PhotoCandidate() when $default != null:
return $default(_that.bytes,_that.mime);case _:
  return null;

}
}

}

/// @nodoc


class _PhotoCandidate implements PhotoCandidate {
  const _PhotoCandidate({required final  List<int> bytes, required this.mime}): _bytes = bytes;
  

 final  List<int> _bytes;
@override List<int> get bytes {
  if (_bytes is EqualUnmodifiableListView) return _bytes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bytes);
}

@override final  String mime;

/// Create a copy of PhotoCandidate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotoCandidateCopyWith<_PhotoCandidate> get copyWith => __$PhotoCandidateCopyWithImpl<_PhotoCandidate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotoCandidate&&const DeepCollectionEquality().equals(other._bytes, _bytes)&&(identical(other.mime, mime) || other.mime == mime));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_bytes),mime);

@override
String toString() {
  return 'PhotoCandidate(bytes: $bytes, mime: $mime)';
}


}

/// @nodoc
abstract mixin class _$PhotoCandidateCopyWith<$Res> implements $PhotoCandidateCopyWith<$Res> {
  factory _$PhotoCandidateCopyWith(_PhotoCandidate value, $Res Function(_PhotoCandidate) _then) = __$PhotoCandidateCopyWithImpl;
@override @useResult
$Res call({
 List<int> bytes, String mime
});




}
/// @nodoc
class __$PhotoCandidateCopyWithImpl<$Res>
    implements _$PhotoCandidateCopyWith<$Res> {
  __$PhotoCandidateCopyWithImpl(this._self, this._then);

  final _PhotoCandidate _self;
  final $Res Function(_PhotoCandidate) _then;

/// Create a copy of PhotoCandidate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bytes = null,Object? mime = null,}) {
  return _then(_PhotoCandidate(
bytes: null == bytes ? _self._bytes : bytes // ignore: cast_nullable_to_non_nullable
as List<int>,mime: null == mime ? _self.mime : mime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
