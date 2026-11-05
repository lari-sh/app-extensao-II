// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_content.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PhotoContent {

 List<int> get bytes; String get mime;
/// Create a copy of PhotoContent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoContentCopyWith<PhotoContent> get copyWith => _$PhotoContentCopyWithImpl<PhotoContent>(this as PhotoContent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoContent&&const DeepCollectionEquality().equals(other.bytes, bytes)&&(identical(other.mime, mime) || other.mime == mime));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(bytes),mime);

@override
String toString() {
  return 'PhotoContent(bytes: $bytes, mime: $mime)';
}


}

/// @nodoc
abstract mixin class $PhotoContentCopyWith<$Res>  {
  factory $PhotoContentCopyWith(PhotoContent value, $Res Function(PhotoContent) _then) = _$PhotoContentCopyWithImpl;
@useResult
$Res call({
 List<int> bytes, String mime
});




}
/// @nodoc
class _$PhotoContentCopyWithImpl<$Res>
    implements $PhotoContentCopyWith<$Res> {
  _$PhotoContentCopyWithImpl(this._self, this._then);

  final PhotoContent _self;
  final $Res Function(PhotoContent) _then;

/// Create a copy of PhotoContent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bytes = null,Object? mime = null,}) {
  return _then(_self.copyWith(
bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as List<int>,mime: null == mime ? _self.mime : mime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PhotoContent].
extension PhotoContentPatterns on PhotoContent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhotoContent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhotoContent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhotoContent value)  $default,){
final _that = this;
switch (_that) {
case _PhotoContent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhotoContent value)?  $default,){
final _that = this;
switch (_that) {
case _PhotoContent() when $default != null:
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
case _PhotoContent() when $default != null:
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
case _PhotoContent():
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
case _PhotoContent() when $default != null:
return $default(_that.bytes,_that.mime);case _:
  return null;

}
}

}

/// @nodoc


class _PhotoContent implements PhotoContent {
  const _PhotoContent({required final  List<int> bytes, required this.mime}): _bytes = bytes;
  

 final  List<int> _bytes;
@override List<int> get bytes {
  if (_bytes is EqualUnmodifiableListView) return _bytes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bytes);
}

@override final  String mime;

/// Create a copy of PhotoContent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotoContentCopyWith<_PhotoContent> get copyWith => __$PhotoContentCopyWithImpl<_PhotoContent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotoContent&&const DeepCollectionEquality().equals(other._bytes, _bytes)&&(identical(other.mime, mime) || other.mime == mime));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_bytes),mime);

@override
String toString() {
  return 'PhotoContent(bytes: $bytes, mime: $mime)';
}


}

/// @nodoc
abstract mixin class _$PhotoContentCopyWith<$Res> implements $PhotoContentCopyWith<$Res> {
  factory _$PhotoContentCopyWith(_PhotoContent value, $Res Function(_PhotoContent) _then) = __$PhotoContentCopyWithImpl;
@override @useResult
$Res call({
 List<int> bytes, String mime
});




}
/// @nodoc
class __$PhotoContentCopyWithImpl<$Res>
    implements _$PhotoContentCopyWith<$Res> {
  __$PhotoContentCopyWithImpl(this._self, this._then);

  final _PhotoContent _self;
  final $Res Function(_PhotoContent) _then;

/// Create a copy of PhotoContent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bytes = null,Object? mime = null,}) {
  return _then(_PhotoContent(
bytes: null == bytes ? _self._bytes : bytes // ignore: cast_nullable_to_non_nullable
as List<int>,mime: null == mime ? _self.mime : mime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
