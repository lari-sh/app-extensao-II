// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'animal_editor_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnimalEditorState implements DiagnosticableTreeMixin {

 AnimalDraft get draft; bool get loading; bool get saving; bool get uncertain; bool get canRetryPending; bool get loadFailed; Map<String, String> get errors; int get formVersion; String? get primaryPhotoId; String? get savedId; String? get message;
/// Create a copy of AnimalEditorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimalEditorStateCopyWith<AnimalEditorState> get copyWith => _$AnimalEditorStateCopyWithImpl<AnimalEditorState>(this as AnimalEditorState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AnimalEditorState'))
    ..add(DiagnosticsProperty('draft', draft))..add(DiagnosticsProperty('loading', loading))..add(DiagnosticsProperty('saving', saving))..add(DiagnosticsProperty('uncertain', uncertain))..add(DiagnosticsProperty('canRetryPending', canRetryPending))..add(DiagnosticsProperty('loadFailed', loadFailed))..add(DiagnosticsProperty('errors', errors))..add(DiagnosticsProperty('formVersion', formVersion))..add(DiagnosticsProperty('primaryPhotoId', primaryPhotoId))..add(DiagnosticsProperty('savedId', savedId))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimalEditorState&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.saving, saving) || other.saving == saving)&&(identical(other.uncertain, uncertain) || other.uncertain == uncertain)&&(identical(other.canRetryPending, canRetryPending) || other.canRetryPending == canRetryPending)&&(identical(other.loadFailed, loadFailed) || other.loadFailed == loadFailed)&&const DeepCollectionEquality().equals(other.errors, errors)&&(identical(other.formVersion, formVersion) || other.formVersion == formVersion)&&(identical(other.primaryPhotoId, primaryPhotoId) || other.primaryPhotoId == primaryPhotoId)&&(identical(other.savedId, savedId) || other.savedId == savedId)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,draft,loading,saving,uncertain,canRetryPending,loadFailed,const DeepCollectionEquality().hash(errors),formVersion,primaryPhotoId,savedId,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AnimalEditorState(draft: $draft, loading: $loading, saving: $saving, uncertain: $uncertain, canRetryPending: $canRetryPending, loadFailed: $loadFailed, errors: $errors, formVersion: $formVersion, primaryPhotoId: $primaryPhotoId, savedId: $savedId, message: $message)';
}


}

/// @nodoc
abstract mixin class $AnimalEditorStateCopyWith<$Res>  {
  factory $AnimalEditorStateCopyWith(AnimalEditorState value, $Res Function(AnimalEditorState) _then) = _$AnimalEditorStateCopyWithImpl;
@useResult
$Res call({
 AnimalDraft draft, bool loading, bool saving, bool uncertain, bool canRetryPending, bool loadFailed, Map<String, String> errors, int formVersion, String? primaryPhotoId, String? savedId, String? message
});


$AnimalDraftCopyWith<$Res> get draft;

}
/// @nodoc
class _$AnimalEditorStateCopyWithImpl<$Res>
    implements $AnimalEditorStateCopyWith<$Res> {
  _$AnimalEditorStateCopyWithImpl(this._self, this._then);

  final AnimalEditorState _self;
  final $Res Function(AnimalEditorState) _then;

/// Create a copy of AnimalEditorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? draft = null,Object? loading = null,Object? saving = null,Object? uncertain = null,Object? canRetryPending = null,Object? loadFailed = null,Object? errors = null,Object? formVersion = null,Object? primaryPhotoId = freezed,Object? savedId = freezed,Object? message = freezed,}) {
  return _then(_self.copyWith(
draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as AnimalDraft,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,uncertain: null == uncertain ? _self.uncertain : uncertain // ignore: cast_nullable_to_non_nullable
as bool,canRetryPending: null == canRetryPending ? _self.canRetryPending : canRetryPending // ignore: cast_nullable_to_non_nullable
as bool,loadFailed: null == loadFailed ? _self.loadFailed : loadFailed // ignore: cast_nullable_to_non_nullable
as bool,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,formVersion: null == formVersion ? _self.formVersion : formVersion // ignore: cast_nullable_to_non_nullable
as int,primaryPhotoId: freezed == primaryPhotoId ? _self.primaryPhotoId : primaryPhotoId // ignore: cast_nullable_to_non_nullable
as String?,savedId: freezed == savedId ? _self.savedId : savedId // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of AnimalEditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnimalDraftCopyWith<$Res> get draft {
  
  return $AnimalDraftCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}
}


/// Adds pattern-matching-related methods to [AnimalEditorState].
extension AnimalEditorStatePatterns on AnimalEditorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnimalEditorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnimalEditorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnimalEditorState value)  $default,){
final _that = this;
switch (_that) {
case _AnimalEditorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnimalEditorState value)?  $default,){
final _that = this;
switch (_that) {
case _AnimalEditorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AnimalDraft draft,  bool loading,  bool saving,  bool uncertain,  bool canRetryPending,  bool loadFailed,  Map<String, String> errors,  int formVersion,  String? primaryPhotoId,  String? savedId,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnimalEditorState() when $default != null:
return $default(_that.draft,_that.loading,_that.saving,_that.uncertain,_that.canRetryPending,_that.loadFailed,_that.errors,_that.formVersion,_that.primaryPhotoId,_that.savedId,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AnimalDraft draft,  bool loading,  bool saving,  bool uncertain,  bool canRetryPending,  bool loadFailed,  Map<String, String> errors,  int formVersion,  String? primaryPhotoId,  String? savedId,  String? message)  $default,) {final _that = this;
switch (_that) {
case _AnimalEditorState():
return $default(_that.draft,_that.loading,_that.saving,_that.uncertain,_that.canRetryPending,_that.loadFailed,_that.errors,_that.formVersion,_that.primaryPhotoId,_that.savedId,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AnimalDraft draft,  bool loading,  bool saving,  bool uncertain,  bool canRetryPending,  bool loadFailed,  Map<String, String> errors,  int formVersion,  String? primaryPhotoId,  String? savedId,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _AnimalEditorState() when $default != null:
return $default(_that.draft,_that.loading,_that.saving,_that.uncertain,_that.canRetryPending,_that.loadFailed,_that.errors,_that.formVersion,_that.primaryPhotoId,_that.savedId,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _AnimalEditorState with DiagnosticableTreeMixin implements AnimalEditorState {
  const _AnimalEditorState({this.draft = const AnimalDraft(), this.loading = false, this.saving = false, this.uncertain = false, this.canRetryPending = false, this.loadFailed = false, final  Map<String, String> errors = const {}, this.formVersion = 0, this.primaryPhotoId, this.savedId, this.message}): _errors = errors;
  

@override@JsonKey() final  AnimalDraft draft;
@override@JsonKey() final  bool loading;
@override@JsonKey() final  bool saving;
@override@JsonKey() final  bool uncertain;
@override@JsonKey() final  bool canRetryPending;
@override@JsonKey() final  bool loadFailed;
 final  Map<String, String> _errors;
@override@JsonKey() Map<String, String> get errors {
  if (_errors is EqualUnmodifiableMapView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_errors);
}

@override@JsonKey() final  int formVersion;
@override final  String? primaryPhotoId;
@override final  String? savedId;
@override final  String? message;

/// Create a copy of AnimalEditorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalEditorStateCopyWith<_AnimalEditorState> get copyWith => __$AnimalEditorStateCopyWithImpl<_AnimalEditorState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AnimalEditorState'))
    ..add(DiagnosticsProperty('draft', draft))..add(DiagnosticsProperty('loading', loading))..add(DiagnosticsProperty('saving', saving))..add(DiagnosticsProperty('uncertain', uncertain))..add(DiagnosticsProperty('canRetryPending', canRetryPending))..add(DiagnosticsProperty('loadFailed', loadFailed))..add(DiagnosticsProperty('errors', errors))..add(DiagnosticsProperty('formVersion', formVersion))..add(DiagnosticsProperty('primaryPhotoId', primaryPhotoId))..add(DiagnosticsProperty('savedId', savedId))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimalEditorState&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.saving, saving) || other.saving == saving)&&(identical(other.uncertain, uncertain) || other.uncertain == uncertain)&&(identical(other.canRetryPending, canRetryPending) || other.canRetryPending == canRetryPending)&&(identical(other.loadFailed, loadFailed) || other.loadFailed == loadFailed)&&const DeepCollectionEquality().equals(other._errors, _errors)&&(identical(other.formVersion, formVersion) || other.formVersion == formVersion)&&(identical(other.primaryPhotoId, primaryPhotoId) || other.primaryPhotoId == primaryPhotoId)&&(identical(other.savedId, savedId) || other.savedId == savedId)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,draft,loading,saving,uncertain,canRetryPending,loadFailed,const DeepCollectionEquality().hash(_errors),formVersion,primaryPhotoId,savedId,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AnimalEditorState(draft: $draft, loading: $loading, saving: $saving, uncertain: $uncertain, canRetryPending: $canRetryPending, loadFailed: $loadFailed, errors: $errors, formVersion: $formVersion, primaryPhotoId: $primaryPhotoId, savedId: $savedId, message: $message)';
}


}

/// @nodoc
abstract mixin class _$AnimalEditorStateCopyWith<$Res> implements $AnimalEditorStateCopyWith<$Res> {
  factory _$AnimalEditorStateCopyWith(_AnimalEditorState value, $Res Function(_AnimalEditorState) _then) = __$AnimalEditorStateCopyWithImpl;
@override @useResult
$Res call({
 AnimalDraft draft, bool loading, bool saving, bool uncertain, bool canRetryPending, bool loadFailed, Map<String, String> errors, int formVersion, String? primaryPhotoId, String? savedId, String? message
});


@override $AnimalDraftCopyWith<$Res> get draft;

}
/// @nodoc
class __$AnimalEditorStateCopyWithImpl<$Res>
    implements _$AnimalEditorStateCopyWith<$Res> {
  __$AnimalEditorStateCopyWithImpl(this._self, this._then);

  final _AnimalEditorState _self;
  final $Res Function(_AnimalEditorState) _then;

/// Create a copy of AnimalEditorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? draft = null,Object? loading = null,Object? saving = null,Object? uncertain = null,Object? canRetryPending = null,Object? loadFailed = null,Object? errors = null,Object? formVersion = null,Object? primaryPhotoId = freezed,Object? savedId = freezed,Object? message = freezed,}) {
  return _then(_AnimalEditorState(
draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as AnimalDraft,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,uncertain: null == uncertain ? _self.uncertain : uncertain // ignore: cast_nullable_to_non_nullable
as bool,canRetryPending: null == canRetryPending ? _self.canRetryPending : canRetryPending // ignore: cast_nullable_to_non_nullable
as bool,loadFailed: null == loadFailed ? _self.loadFailed : loadFailed // ignore: cast_nullable_to_non_nullable
as bool,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,formVersion: null == formVersion ? _self.formVersion : formVersion // ignore: cast_nullable_to_non_nullable
as int,primaryPhotoId: freezed == primaryPhotoId ? _self.primaryPhotoId : primaryPhotoId // ignore: cast_nullable_to_non_nullable
as String?,savedId: freezed == savedId ? _self.savedId : savedId // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of AnimalEditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnimalDraftCopyWith<$Res> get draft {
  
  return $AnimalDraftCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}
}

// dart format on
