// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_upload_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PhotoUploadState {

 String get jobId; PhotoJobStatus get status; String? get photoId; String? get currentPhotoId;
/// Create a copy of PhotoUploadState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoUploadStateCopyWith<PhotoUploadState> get copyWith => _$PhotoUploadStateCopyWithImpl<PhotoUploadState>(this as PhotoUploadState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoUploadState&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.status, status) || other.status == status)&&(identical(other.photoId, photoId) || other.photoId == photoId)&&(identical(other.currentPhotoId, currentPhotoId) || other.currentPhotoId == currentPhotoId));
}


@override
int get hashCode => Object.hash(runtimeType,jobId,status,photoId,currentPhotoId);

@override
String toString() {
  return 'PhotoUploadState(jobId: $jobId, status: $status, photoId: $photoId, currentPhotoId: $currentPhotoId)';
}


}

/// @nodoc
abstract mixin class $PhotoUploadStateCopyWith<$Res>  {
  factory $PhotoUploadStateCopyWith(PhotoUploadState value, $Res Function(PhotoUploadState) _then) = _$PhotoUploadStateCopyWithImpl;
@useResult
$Res call({
 String jobId, PhotoJobStatus status, String? photoId, String? currentPhotoId
});




}
/// @nodoc
class _$PhotoUploadStateCopyWithImpl<$Res>
    implements $PhotoUploadStateCopyWith<$Res> {
  _$PhotoUploadStateCopyWithImpl(this._self, this._then);

  final PhotoUploadState _self;
  final $Res Function(PhotoUploadState) _then;

/// Create a copy of PhotoUploadState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? jobId = null,Object? status = null,Object? photoId = freezed,Object? currentPhotoId = freezed,}) {
  return _then(_self.copyWith(
jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PhotoJobStatus,photoId: freezed == photoId ? _self.photoId : photoId // ignore: cast_nullable_to_non_nullable
as String?,currentPhotoId: freezed == currentPhotoId ? _self.currentPhotoId : currentPhotoId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PhotoUploadState].
extension PhotoUploadStatePatterns on PhotoUploadState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhotoUploadState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhotoUploadState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhotoUploadState value)  $default,){
final _that = this;
switch (_that) {
case _PhotoUploadState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhotoUploadState value)?  $default,){
final _that = this;
switch (_that) {
case _PhotoUploadState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String jobId,  PhotoJobStatus status,  String? photoId,  String? currentPhotoId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhotoUploadState() when $default != null:
return $default(_that.jobId,_that.status,_that.photoId,_that.currentPhotoId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String jobId,  PhotoJobStatus status,  String? photoId,  String? currentPhotoId)  $default,) {final _that = this;
switch (_that) {
case _PhotoUploadState():
return $default(_that.jobId,_that.status,_that.photoId,_that.currentPhotoId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String jobId,  PhotoJobStatus status,  String? photoId,  String? currentPhotoId)?  $default,) {final _that = this;
switch (_that) {
case _PhotoUploadState() when $default != null:
return $default(_that.jobId,_that.status,_that.photoId,_that.currentPhotoId);case _:
  return null;

}
}

}

/// @nodoc


class _PhotoUploadState implements PhotoUploadState {
  const _PhotoUploadState({required this.jobId, required this.status, this.photoId, this.currentPhotoId});
  

@override final  String jobId;
@override final  PhotoJobStatus status;
@override final  String? photoId;
@override final  String? currentPhotoId;

/// Create a copy of PhotoUploadState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotoUploadStateCopyWith<_PhotoUploadState> get copyWith => __$PhotoUploadStateCopyWithImpl<_PhotoUploadState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotoUploadState&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.status, status) || other.status == status)&&(identical(other.photoId, photoId) || other.photoId == photoId)&&(identical(other.currentPhotoId, currentPhotoId) || other.currentPhotoId == currentPhotoId));
}


@override
int get hashCode => Object.hash(runtimeType,jobId,status,photoId,currentPhotoId);

@override
String toString() {
  return 'PhotoUploadState(jobId: $jobId, status: $status, photoId: $photoId, currentPhotoId: $currentPhotoId)';
}


}

/// @nodoc
abstract mixin class _$PhotoUploadStateCopyWith<$Res> implements $PhotoUploadStateCopyWith<$Res> {
  factory _$PhotoUploadStateCopyWith(_PhotoUploadState value, $Res Function(_PhotoUploadState) _then) = __$PhotoUploadStateCopyWithImpl;
@override @useResult
$Res call({
 String jobId, PhotoJobStatus status, String? photoId, String? currentPhotoId
});




}
/// @nodoc
class __$PhotoUploadStateCopyWithImpl<$Res>
    implements _$PhotoUploadStateCopyWith<$Res> {
  __$PhotoUploadStateCopyWithImpl(this._self, this._then);

  final _PhotoUploadState _self;
  final $Res Function(_PhotoUploadState) _then;

/// Create a copy of PhotoUploadState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? jobId = null,Object? status = null,Object? photoId = freezed,Object? currentPhotoId = freezed,}) {
  return _then(_PhotoUploadState(
jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PhotoJobStatus,photoId: freezed == photoId ? _self.photoId : photoId // ignore: cast_nullable_to_non_nullable
as String?,currentPhotoId: freezed == currentPhotoId ? _self.currentPhotoId : currentPhotoId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
