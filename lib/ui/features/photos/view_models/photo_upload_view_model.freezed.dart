// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_upload_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PhotoPanelState implements DiagnosticableTreeMixin {

 String? get animalId; String? get photoId; PhotoContent? get image; PhotoCandidate? get candidate; bool get busy; bool get uncertain; bool get canRetry; bool get hasRecovery; String? get message;
/// Create a copy of PhotoPanelState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoPanelStateCopyWith<PhotoPanelState> get copyWith => _$PhotoPanelStateCopyWithImpl<PhotoPanelState>(this as PhotoPanelState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'PhotoPanelState'))
    ..add(DiagnosticsProperty('animalId', animalId))..add(DiagnosticsProperty('photoId', photoId))..add(DiagnosticsProperty('image', image))..add(DiagnosticsProperty('candidate', candidate))..add(DiagnosticsProperty('busy', busy))..add(DiagnosticsProperty('uncertain', uncertain))..add(DiagnosticsProperty('canRetry', canRetry))..add(DiagnosticsProperty('hasRecovery', hasRecovery))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoPanelState&&(identical(other.animalId, animalId) || other.animalId == animalId)&&(identical(other.photoId, photoId) || other.photoId == photoId)&&(identical(other.image, image) || other.image == image)&&(identical(other.candidate, candidate) || other.candidate == candidate)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.uncertain, uncertain) || other.uncertain == uncertain)&&(identical(other.canRetry, canRetry) || other.canRetry == canRetry)&&(identical(other.hasRecovery, hasRecovery) || other.hasRecovery == hasRecovery)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,animalId,photoId,image,candidate,busy,uncertain,canRetry,hasRecovery,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'PhotoPanelState(animalId: $animalId, photoId: $photoId, image: $image, candidate: $candidate, busy: $busy, uncertain: $uncertain, canRetry: $canRetry, hasRecovery: $hasRecovery, message: $message)';
}


}

/// @nodoc
abstract mixin class $PhotoPanelStateCopyWith<$Res>  {
  factory $PhotoPanelStateCopyWith(PhotoPanelState value, $Res Function(PhotoPanelState) _then) = _$PhotoPanelStateCopyWithImpl;
@useResult
$Res call({
 String? animalId, String? photoId, PhotoContent? image, PhotoCandidate? candidate, bool busy, bool uncertain, bool canRetry, bool hasRecovery, String? message
});


$PhotoContentCopyWith<$Res>? get image;$PhotoCandidateCopyWith<$Res>? get candidate;

}
/// @nodoc
class _$PhotoPanelStateCopyWithImpl<$Res>
    implements $PhotoPanelStateCopyWith<$Res> {
  _$PhotoPanelStateCopyWithImpl(this._self, this._then);

  final PhotoPanelState _self;
  final $Res Function(PhotoPanelState) _then;

/// Create a copy of PhotoPanelState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? animalId = freezed,Object? photoId = freezed,Object? image = freezed,Object? candidate = freezed,Object? busy = null,Object? uncertain = null,Object? canRetry = null,Object? hasRecovery = null,Object? message = freezed,}) {
  return _then(_self.copyWith(
animalId: freezed == animalId ? _self.animalId : animalId // ignore: cast_nullable_to_non_nullable
as String?,photoId: freezed == photoId ? _self.photoId : photoId // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as PhotoContent?,candidate: freezed == candidate ? _self.candidate : candidate // ignore: cast_nullable_to_non_nullable
as PhotoCandidate?,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,uncertain: null == uncertain ? _self.uncertain : uncertain // ignore: cast_nullable_to_non_nullable
as bool,canRetry: null == canRetry ? _self.canRetry : canRetry // ignore: cast_nullable_to_non_nullable
as bool,hasRecovery: null == hasRecovery ? _self.hasRecovery : hasRecovery // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of PhotoPanelState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PhotoContentCopyWith<$Res>? get image {
    if (_self.image == null) {
    return null;
  }

  return $PhotoContentCopyWith<$Res>(_self.image!, (value) {
    return _then(_self.copyWith(image: value));
  });
}/// Create a copy of PhotoPanelState
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


/// Adds pattern-matching-related methods to [PhotoPanelState].
extension PhotoPanelStatePatterns on PhotoPanelState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhotoPanelState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhotoPanelState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhotoPanelState value)  $default,){
final _that = this;
switch (_that) {
case _PhotoPanelState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhotoPanelState value)?  $default,){
final _that = this;
switch (_that) {
case _PhotoPanelState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? animalId,  String? photoId,  PhotoContent? image,  PhotoCandidate? candidate,  bool busy,  bool uncertain,  bool canRetry,  bool hasRecovery,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhotoPanelState() when $default != null:
return $default(_that.animalId,_that.photoId,_that.image,_that.candidate,_that.busy,_that.uncertain,_that.canRetry,_that.hasRecovery,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? animalId,  String? photoId,  PhotoContent? image,  PhotoCandidate? candidate,  bool busy,  bool uncertain,  bool canRetry,  bool hasRecovery,  String? message)  $default,) {final _that = this;
switch (_that) {
case _PhotoPanelState():
return $default(_that.animalId,_that.photoId,_that.image,_that.candidate,_that.busy,_that.uncertain,_that.canRetry,_that.hasRecovery,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? animalId,  String? photoId,  PhotoContent? image,  PhotoCandidate? candidate,  bool busy,  bool uncertain,  bool canRetry,  bool hasRecovery,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _PhotoPanelState() when $default != null:
return $default(_that.animalId,_that.photoId,_that.image,_that.candidate,_that.busy,_that.uncertain,_that.canRetry,_that.hasRecovery,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _PhotoPanelState with DiagnosticableTreeMixin implements PhotoPanelState {
  const _PhotoPanelState({this.animalId, this.photoId, this.image, this.candidate, this.busy = false, this.uncertain = false, this.canRetry = false, this.hasRecovery = false, this.message});
  

@override final  String? animalId;
@override final  String? photoId;
@override final  PhotoContent? image;
@override final  PhotoCandidate? candidate;
@override@JsonKey() final  bool busy;
@override@JsonKey() final  bool uncertain;
@override@JsonKey() final  bool canRetry;
@override@JsonKey() final  bool hasRecovery;
@override final  String? message;

/// Create a copy of PhotoPanelState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotoPanelStateCopyWith<_PhotoPanelState> get copyWith => __$PhotoPanelStateCopyWithImpl<_PhotoPanelState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'PhotoPanelState'))
    ..add(DiagnosticsProperty('animalId', animalId))..add(DiagnosticsProperty('photoId', photoId))..add(DiagnosticsProperty('image', image))..add(DiagnosticsProperty('candidate', candidate))..add(DiagnosticsProperty('busy', busy))..add(DiagnosticsProperty('uncertain', uncertain))..add(DiagnosticsProperty('canRetry', canRetry))..add(DiagnosticsProperty('hasRecovery', hasRecovery))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotoPanelState&&(identical(other.animalId, animalId) || other.animalId == animalId)&&(identical(other.photoId, photoId) || other.photoId == photoId)&&(identical(other.image, image) || other.image == image)&&(identical(other.candidate, candidate) || other.candidate == candidate)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.uncertain, uncertain) || other.uncertain == uncertain)&&(identical(other.canRetry, canRetry) || other.canRetry == canRetry)&&(identical(other.hasRecovery, hasRecovery) || other.hasRecovery == hasRecovery)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,animalId,photoId,image,candidate,busy,uncertain,canRetry,hasRecovery,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'PhotoPanelState(animalId: $animalId, photoId: $photoId, image: $image, candidate: $candidate, busy: $busy, uncertain: $uncertain, canRetry: $canRetry, hasRecovery: $hasRecovery, message: $message)';
}


}

/// @nodoc
abstract mixin class _$PhotoPanelStateCopyWith<$Res> implements $PhotoPanelStateCopyWith<$Res> {
  factory _$PhotoPanelStateCopyWith(_PhotoPanelState value, $Res Function(_PhotoPanelState) _then) = __$PhotoPanelStateCopyWithImpl;
@override @useResult
$Res call({
 String? animalId, String? photoId, PhotoContent? image, PhotoCandidate? candidate, bool busy, bool uncertain, bool canRetry, bool hasRecovery, String? message
});


@override $PhotoContentCopyWith<$Res>? get image;@override $PhotoCandidateCopyWith<$Res>? get candidate;

}
/// @nodoc
class __$PhotoPanelStateCopyWithImpl<$Res>
    implements _$PhotoPanelStateCopyWith<$Res> {
  __$PhotoPanelStateCopyWithImpl(this._self, this._then);

  final _PhotoPanelState _self;
  final $Res Function(_PhotoPanelState) _then;

/// Create a copy of PhotoPanelState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? animalId = freezed,Object? photoId = freezed,Object? image = freezed,Object? candidate = freezed,Object? busy = null,Object? uncertain = null,Object? canRetry = null,Object? hasRecovery = null,Object? message = freezed,}) {
  return _then(_PhotoPanelState(
animalId: freezed == animalId ? _self.animalId : animalId // ignore: cast_nullable_to_non_nullable
as String?,photoId: freezed == photoId ? _self.photoId : photoId // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as PhotoContent?,candidate: freezed == candidate ? _self.candidate : candidate // ignore: cast_nullable_to_non_nullable
as PhotoCandidate?,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,uncertain: null == uncertain ? _self.uncertain : uncertain // ignore: cast_nullable_to_non_nullable
as bool,canRetry: null == canRetry ? _self.canRetry : canRetry // ignore: cast_nullable_to_non_nullable
as bool,hasRecovery: null == hasRecovery ? _self.hasRecovery : hasRecovery // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of PhotoPanelState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PhotoContentCopyWith<$Res>? get image {
    if (_self.image == null) {
    return null;
  }

  return $PhotoContentCopyWith<$Res>(_self.image!, (value) {
    return _then(_self.copyWith(image: value));
  });
}/// Create a copy of PhotoPanelState
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
