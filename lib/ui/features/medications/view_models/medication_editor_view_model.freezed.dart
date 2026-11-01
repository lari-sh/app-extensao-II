// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medication_editor_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MedicationEditorState implements DiagnosticableTreeMixin {

 String? get animalId; String get animalName; List<MedicationTreatment> get treatments; MedicationTreatmentDraft get draft; bool get hasDraft; bool get loading; bool get saving; bool get loadFailed; bool get uncertain; bool get canRetryPending; Map<String, String> get errors; int get formVersion; bool get intervalInHours; String get intervalInput; String? get cursor; String? get confirmedTreatmentId; String? get message;
/// Create a copy of MedicationEditorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicationEditorStateCopyWith<MedicationEditorState> get copyWith => _$MedicationEditorStateCopyWithImpl<MedicationEditorState>(this as MedicationEditorState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MedicationEditorState'))
    ..add(DiagnosticsProperty('animalId', animalId))..add(DiagnosticsProperty('animalName', animalName))..add(DiagnosticsProperty('treatments', treatments))..add(DiagnosticsProperty('draft', draft))..add(DiagnosticsProperty('hasDraft', hasDraft))..add(DiagnosticsProperty('loading', loading))..add(DiagnosticsProperty('saving', saving))..add(DiagnosticsProperty('loadFailed', loadFailed))..add(DiagnosticsProperty('uncertain', uncertain))..add(DiagnosticsProperty('canRetryPending', canRetryPending))..add(DiagnosticsProperty('errors', errors))..add(DiagnosticsProperty('formVersion', formVersion))..add(DiagnosticsProperty('intervalInHours', intervalInHours))..add(DiagnosticsProperty('intervalInput', intervalInput))..add(DiagnosticsProperty('cursor', cursor))..add(DiagnosticsProperty('confirmedTreatmentId', confirmedTreatmentId))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicationEditorState&&(identical(other.animalId, animalId) || other.animalId == animalId)&&(identical(other.animalName, animalName) || other.animalName == animalName)&&const DeepCollectionEquality().equals(other.treatments, treatments)&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.hasDraft, hasDraft) || other.hasDraft == hasDraft)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.saving, saving) || other.saving == saving)&&(identical(other.loadFailed, loadFailed) || other.loadFailed == loadFailed)&&(identical(other.uncertain, uncertain) || other.uncertain == uncertain)&&(identical(other.canRetryPending, canRetryPending) || other.canRetryPending == canRetryPending)&&const DeepCollectionEquality().equals(other.errors, errors)&&(identical(other.formVersion, formVersion) || other.formVersion == formVersion)&&(identical(other.intervalInHours, intervalInHours) || other.intervalInHours == intervalInHours)&&(identical(other.intervalInput, intervalInput) || other.intervalInput == intervalInput)&&(identical(other.cursor, cursor) || other.cursor == cursor)&&(identical(other.confirmedTreatmentId, confirmedTreatmentId) || other.confirmedTreatmentId == confirmedTreatmentId)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,animalId,animalName,const DeepCollectionEquality().hash(treatments),draft,hasDraft,loading,saving,loadFailed,uncertain,canRetryPending,const DeepCollectionEquality().hash(errors),formVersion,intervalInHours,intervalInput,cursor,confirmedTreatmentId,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MedicationEditorState(animalId: $animalId, animalName: $animalName, treatments: $treatments, draft: $draft, hasDraft: $hasDraft, loading: $loading, saving: $saving, loadFailed: $loadFailed, uncertain: $uncertain, canRetryPending: $canRetryPending, errors: $errors, formVersion: $formVersion, intervalInHours: $intervalInHours, intervalInput: $intervalInput, cursor: $cursor, confirmedTreatmentId: $confirmedTreatmentId, message: $message)';
}


}

/// @nodoc
abstract mixin class $MedicationEditorStateCopyWith<$Res>  {
  factory $MedicationEditorStateCopyWith(MedicationEditorState value, $Res Function(MedicationEditorState) _then) = _$MedicationEditorStateCopyWithImpl;
@useResult
$Res call({
 String? animalId, String animalName, List<MedicationTreatment> treatments, MedicationTreatmentDraft draft, bool hasDraft, bool loading, bool saving, bool loadFailed, bool uncertain, bool canRetryPending, Map<String, String> errors, int formVersion, bool intervalInHours, String intervalInput, String? cursor, String? confirmedTreatmentId, String? message
});


$MedicationTreatmentDraftCopyWith<$Res> get draft;

}
/// @nodoc
class _$MedicationEditorStateCopyWithImpl<$Res>
    implements $MedicationEditorStateCopyWith<$Res> {
  _$MedicationEditorStateCopyWithImpl(this._self, this._then);

  final MedicationEditorState _self;
  final $Res Function(MedicationEditorState) _then;

/// Create a copy of MedicationEditorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? animalId = freezed,Object? animalName = null,Object? treatments = null,Object? draft = null,Object? hasDraft = null,Object? loading = null,Object? saving = null,Object? loadFailed = null,Object? uncertain = null,Object? canRetryPending = null,Object? errors = null,Object? formVersion = null,Object? intervalInHours = null,Object? intervalInput = null,Object? cursor = freezed,Object? confirmedTreatmentId = freezed,Object? message = freezed,}) {
  return _then(_self.copyWith(
animalId: freezed == animalId ? _self.animalId : animalId // ignore: cast_nullable_to_non_nullable
as String?,animalName: null == animalName ? _self.animalName : animalName // ignore: cast_nullable_to_non_nullable
as String,treatments: null == treatments ? _self.treatments : treatments // ignore: cast_nullable_to_non_nullable
as List<MedicationTreatment>,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as MedicationTreatmentDraft,hasDraft: null == hasDraft ? _self.hasDraft : hasDraft // ignore: cast_nullable_to_non_nullable
as bool,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,loadFailed: null == loadFailed ? _self.loadFailed : loadFailed // ignore: cast_nullable_to_non_nullable
as bool,uncertain: null == uncertain ? _self.uncertain : uncertain // ignore: cast_nullable_to_non_nullable
as bool,canRetryPending: null == canRetryPending ? _self.canRetryPending : canRetryPending // ignore: cast_nullable_to_non_nullable
as bool,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,formVersion: null == formVersion ? _self.formVersion : formVersion // ignore: cast_nullable_to_non_nullable
as int,intervalInHours: null == intervalInHours ? _self.intervalInHours : intervalInHours // ignore: cast_nullable_to_non_nullable
as bool,intervalInput: null == intervalInput ? _self.intervalInput : intervalInput // ignore: cast_nullable_to_non_nullable
as String,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,confirmedTreatmentId: freezed == confirmedTreatmentId ? _self.confirmedTreatmentId : confirmedTreatmentId // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of MedicationEditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MedicationTreatmentDraftCopyWith<$Res> get draft {
  
  return $MedicationTreatmentDraftCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}
}


/// Adds pattern-matching-related methods to [MedicationEditorState].
extension MedicationEditorStatePatterns on MedicationEditorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicationEditorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicationEditorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicationEditorState value)  $default,){
final _that = this;
switch (_that) {
case _MedicationEditorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicationEditorState value)?  $default,){
final _that = this;
switch (_that) {
case _MedicationEditorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? animalId,  String animalName,  List<MedicationTreatment> treatments,  MedicationTreatmentDraft draft,  bool hasDraft,  bool loading,  bool saving,  bool loadFailed,  bool uncertain,  bool canRetryPending,  Map<String, String> errors,  int formVersion,  bool intervalInHours,  String intervalInput,  String? cursor,  String? confirmedTreatmentId,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicationEditorState() when $default != null:
return $default(_that.animalId,_that.animalName,_that.treatments,_that.draft,_that.hasDraft,_that.loading,_that.saving,_that.loadFailed,_that.uncertain,_that.canRetryPending,_that.errors,_that.formVersion,_that.intervalInHours,_that.intervalInput,_that.cursor,_that.confirmedTreatmentId,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? animalId,  String animalName,  List<MedicationTreatment> treatments,  MedicationTreatmentDraft draft,  bool hasDraft,  bool loading,  bool saving,  bool loadFailed,  bool uncertain,  bool canRetryPending,  Map<String, String> errors,  int formVersion,  bool intervalInHours,  String intervalInput,  String? cursor,  String? confirmedTreatmentId,  String? message)  $default,) {final _that = this;
switch (_that) {
case _MedicationEditorState():
return $default(_that.animalId,_that.animalName,_that.treatments,_that.draft,_that.hasDraft,_that.loading,_that.saving,_that.loadFailed,_that.uncertain,_that.canRetryPending,_that.errors,_that.formVersion,_that.intervalInHours,_that.intervalInput,_that.cursor,_that.confirmedTreatmentId,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? animalId,  String animalName,  List<MedicationTreatment> treatments,  MedicationTreatmentDraft draft,  bool hasDraft,  bool loading,  bool saving,  bool loadFailed,  bool uncertain,  bool canRetryPending,  Map<String, String> errors,  int formVersion,  bool intervalInHours,  String intervalInput,  String? cursor,  String? confirmedTreatmentId,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _MedicationEditorState() when $default != null:
return $default(_that.animalId,_that.animalName,_that.treatments,_that.draft,_that.hasDraft,_that.loading,_that.saving,_that.loadFailed,_that.uncertain,_that.canRetryPending,_that.errors,_that.formVersion,_that.intervalInHours,_that.intervalInput,_that.cursor,_that.confirmedTreatmentId,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _MedicationEditorState with DiagnosticableTreeMixin implements MedicationEditorState {
  const _MedicationEditorState({this.animalId, this.animalName = '', final  List<MedicationTreatment> treatments = const [], this.draft = const MedicationTreatmentDraft(), this.hasDraft = false, this.loading = false, this.saving = false, this.loadFailed = false, this.uncertain = false, this.canRetryPending = false, final  Map<String, String> errors = const {}, this.formVersion = 0, this.intervalInHours = true, this.intervalInput = '8', this.cursor, this.confirmedTreatmentId, this.message}): _treatments = treatments,_errors = errors;
  

@override final  String? animalId;
@override@JsonKey() final  String animalName;
 final  List<MedicationTreatment> _treatments;
@override@JsonKey() List<MedicationTreatment> get treatments {
  if (_treatments is EqualUnmodifiableListView) return _treatments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_treatments);
}

@override@JsonKey() final  MedicationTreatmentDraft draft;
@override@JsonKey() final  bool hasDraft;
@override@JsonKey() final  bool loading;
@override@JsonKey() final  bool saving;
@override@JsonKey() final  bool loadFailed;
@override@JsonKey() final  bool uncertain;
@override@JsonKey() final  bool canRetryPending;
 final  Map<String, String> _errors;
@override@JsonKey() Map<String, String> get errors {
  if (_errors is EqualUnmodifiableMapView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_errors);
}

@override@JsonKey() final  int formVersion;
@override@JsonKey() final  bool intervalInHours;
@override@JsonKey() final  String intervalInput;
@override final  String? cursor;
@override final  String? confirmedTreatmentId;
@override final  String? message;

/// Create a copy of MedicationEditorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicationEditorStateCopyWith<_MedicationEditorState> get copyWith => __$MedicationEditorStateCopyWithImpl<_MedicationEditorState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MedicationEditorState'))
    ..add(DiagnosticsProperty('animalId', animalId))..add(DiagnosticsProperty('animalName', animalName))..add(DiagnosticsProperty('treatments', treatments))..add(DiagnosticsProperty('draft', draft))..add(DiagnosticsProperty('hasDraft', hasDraft))..add(DiagnosticsProperty('loading', loading))..add(DiagnosticsProperty('saving', saving))..add(DiagnosticsProperty('loadFailed', loadFailed))..add(DiagnosticsProperty('uncertain', uncertain))..add(DiagnosticsProperty('canRetryPending', canRetryPending))..add(DiagnosticsProperty('errors', errors))..add(DiagnosticsProperty('formVersion', formVersion))..add(DiagnosticsProperty('intervalInHours', intervalInHours))..add(DiagnosticsProperty('intervalInput', intervalInput))..add(DiagnosticsProperty('cursor', cursor))..add(DiagnosticsProperty('confirmedTreatmentId', confirmedTreatmentId))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicationEditorState&&(identical(other.animalId, animalId) || other.animalId == animalId)&&(identical(other.animalName, animalName) || other.animalName == animalName)&&const DeepCollectionEquality().equals(other._treatments, _treatments)&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.hasDraft, hasDraft) || other.hasDraft == hasDraft)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.saving, saving) || other.saving == saving)&&(identical(other.loadFailed, loadFailed) || other.loadFailed == loadFailed)&&(identical(other.uncertain, uncertain) || other.uncertain == uncertain)&&(identical(other.canRetryPending, canRetryPending) || other.canRetryPending == canRetryPending)&&const DeepCollectionEquality().equals(other._errors, _errors)&&(identical(other.formVersion, formVersion) || other.formVersion == formVersion)&&(identical(other.intervalInHours, intervalInHours) || other.intervalInHours == intervalInHours)&&(identical(other.intervalInput, intervalInput) || other.intervalInput == intervalInput)&&(identical(other.cursor, cursor) || other.cursor == cursor)&&(identical(other.confirmedTreatmentId, confirmedTreatmentId) || other.confirmedTreatmentId == confirmedTreatmentId)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,animalId,animalName,const DeepCollectionEquality().hash(_treatments),draft,hasDraft,loading,saving,loadFailed,uncertain,canRetryPending,const DeepCollectionEquality().hash(_errors),formVersion,intervalInHours,intervalInput,cursor,confirmedTreatmentId,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MedicationEditorState(animalId: $animalId, animalName: $animalName, treatments: $treatments, draft: $draft, hasDraft: $hasDraft, loading: $loading, saving: $saving, loadFailed: $loadFailed, uncertain: $uncertain, canRetryPending: $canRetryPending, errors: $errors, formVersion: $formVersion, intervalInHours: $intervalInHours, intervalInput: $intervalInput, cursor: $cursor, confirmedTreatmentId: $confirmedTreatmentId, message: $message)';
}


}

/// @nodoc
abstract mixin class _$MedicationEditorStateCopyWith<$Res> implements $MedicationEditorStateCopyWith<$Res> {
  factory _$MedicationEditorStateCopyWith(_MedicationEditorState value, $Res Function(_MedicationEditorState) _then) = __$MedicationEditorStateCopyWithImpl;
@override @useResult
$Res call({
 String? animalId, String animalName, List<MedicationTreatment> treatments, MedicationTreatmentDraft draft, bool hasDraft, bool loading, bool saving, bool loadFailed, bool uncertain, bool canRetryPending, Map<String, String> errors, int formVersion, bool intervalInHours, String intervalInput, String? cursor, String? confirmedTreatmentId, String? message
});


@override $MedicationTreatmentDraftCopyWith<$Res> get draft;

}
/// @nodoc
class __$MedicationEditorStateCopyWithImpl<$Res>
    implements _$MedicationEditorStateCopyWith<$Res> {
  __$MedicationEditorStateCopyWithImpl(this._self, this._then);

  final _MedicationEditorState _self;
  final $Res Function(_MedicationEditorState) _then;

/// Create a copy of MedicationEditorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? animalId = freezed,Object? animalName = null,Object? treatments = null,Object? draft = null,Object? hasDraft = null,Object? loading = null,Object? saving = null,Object? loadFailed = null,Object? uncertain = null,Object? canRetryPending = null,Object? errors = null,Object? formVersion = null,Object? intervalInHours = null,Object? intervalInput = null,Object? cursor = freezed,Object? confirmedTreatmentId = freezed,Object? message = freezed,}) {
  return _then(_MedicationEditorState(
animalId: freezed == animalId ? _self.animalId : animalId // ignore: cast_nullable_to_non_nullable
as String?,animalName: null == animalName ? _self.animalName : animalName // ignore: cast_nullable_to_non_nullable
as String,treatments: null == treatments ? _self._treatments : treatments // ignore: cast_nullable_to_non_nullable
as List<MedicationTreatment>,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as MedicationTreatmentDraft,hasDraft: null == hasDraft ? _self.hasDraft : hasDraft // ignore: cast_nullable_to_non_nullable
as bool,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,loadFailed: null == loadFailed ? _self.loadFailed : loadFailed // ignore: cast_nullable_to_non_nullable
as bool,uncertain: null == uncertain ? _self.uncertain : uncertain // ignore: cast_nullable_to_non_nullable
as bool,canRetryPending: null == canRetryPending ? _self.canRetryPending : canRetryPending // ignore: cast_nullable_to_non_nullable
as bool,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,formVersion: null == formVersion ? _self.formVersion : formVersion // ignore: cast_nullable_to_non_nullable
as int,intervalInHours: null == intervalInHours ? _self.intervalInHours : intervalInHours // ignore: cast_nullable_to_non_nullable
as bool,intervalInput: null == intervalInput ? _self.intervalInput : intervalInput // ignore: cast_nullable_to_non_nullable
as String,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,confirmedTreatmentId: freezed == confirmedTreatmentId ? _self.confirmedTreatmentId : confirmedTreatmentId // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of MedicationEditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MedicationTreatmentDraftCopyWith<$Res> get draft {
  
  return $MedicationTreatmentDraftCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}
}

// dart format on
