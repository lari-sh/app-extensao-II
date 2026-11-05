// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medication_treatment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MedicationTreatment {

 String get id; String get animalId; int get revision; int get version; String get medicationName; String get instructions; MedicationSchedule get schedule; MedicationTreatmentStatus get status;
/// Create a copy of MedicationTreatment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicationTreatmentCopyWith<MedicationTreatment> get copyWith => _$MedicationTreatmentCopyWithImpl<MedicationTreatment>(this as MedicationTreatment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicationTreatment&&(identical(other.id, id) || other.id == id)&&(identical(other.animalId, animalId) || other.animalId == animalId)&&(identical(other.revision, revision) || other.revision == revision)&&(identical(other.version, version) || other.version == version)&&(identical(other.medicationName, medicationName) || other.medicationName == medicationName)&&(identical(other.instructions, instructions) || other.instructions == instructions)&&(identical(other.schedule, schedule) || other.schedule == schedule)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,id,animalId,revision,version,medicationName,instructions,schedule,status);

@override
String toString() {
  return 'MedicationTreatment(id: $id, animalId: $animalId, revision: $revision, version: $version, medicationName: $medicationName, instructions: $instructions, schedule: $schedule, status: $status)';
}


}

/// @nodoc
abstract mixin class $MedicationTreatmentCopyWith<$Res>  {
  factory $MedicationTreatmentCopyWith(MedicationTreatment value, $Res Function(MedicationTreatment) _then) = _$MedicationTreatmentCopyWithImpl;
@useResult
$Res call({
 String id, String animalId, int revision, int version, String medicationName, String instructions, MedicationSchedule schedule, MedicationTreatmentStatus status
});


$MedicationScheduleCopyWith<$Res> get schedule;

}
/// @nodoc
class _$MedicationTreatmentCopyWithImpl<$Res>
    implements $MedicationTreatmentCopyWith<$Res> {
  _$MedicationTreatmentCopyWithImpl(this._self, this._then);

  final MedicationTreatment _self;
  final $Res Function(MedicationTreatment) _then;

/// Create a copy of MedicationTreatment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? animalId = null,Object? revision = null,Object? version = null,Object? medicationName = null,Object? instructions = null,Object? schedule = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,animalId: null == animalId ? _self.animalId : animalId // ignore: cast_nullable_to_non_nullable
as String,revision: null == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as int,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,medicationName: null == medicationName ? _self.medicationName : medicationName // ignore: cast_nullable_to_non_nullable
as String,instructions: null == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String,schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as MedicationSchedule,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MedicationTreatmentStatus,
  ));
}
/// Create a copy of MedicationTreatment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MedicationScheduleCopyWith<$Res> get schedule {
  
  return $MedicationScheduleCopyWith<$Res>(_self.schedule, (value) {
    return _then(_self.copyWith(schedule: value));
  });
}
}


/// Adds pattern-matching-related methods to [MedicationTreatment].
extension MedicationTreatmentPatterns on MedicationTreatment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicationTreatment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicationTreatment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicationTreatment value)  $default,){
final _that = this;
switch (_that) {
case _MedicationTreatment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicationTreatment value)?  $default,){
final _that = this;
switch (_that) {
case _MedicationTreatment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String animalId,  int revision,  int version,  String medicationName,  String instructions,  MedicationSchedule schedule,  MedicationTreatmentStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicationTreatment() when $default != null:
return $default(_that.id,_that.animalId,_that.revision,_that.version,_that.medicationName,_that.instructions,_that.schedule,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String animalId,  int revision,  int version,  String medicationName,  String instructions,  MedicationSchedule schedule,  MedicationTreatmentStatus status)  $default,) {final _that = this;
switch (_that) {
case _MedicationTreatment():
return $default(_that.id,_that.animalId,_that.revision,_that.version,_that.medicationName,_that.instructions,_that.schedule,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String animalId,  int revision,  int version,  String medicationName,  String instructions,  MedicationSchedule schedule,  MedicationTreatmentStatus status)?  $default,) {final _that = this;
switch (_that) {
case _MedicationTreatment() when $default != null:
return $default(_that.id,_that.animalId,_that.revision,_that.version,_that.medicationName,_that.instructions,_that.schedule,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _MedicationTreatment implements MedicationTreatment {
  const _MedicationTreatment({required this.id, required this.animalId, required this.revision, required this.version, required this.medicationName, this.instructions = '', required this.schedule, this.status = MedicationTreatmentStatus.active});
  

@override final  String id;
@override final  String animalId;
@override final  int revision;
@override final  int version;
@override final  String medicationName;
@override@JsonKey() final  String instructions;
@override final  MedicationSchedule schedule;
@override@JsonKey() final  MedicationTreatmentStatus status;

/// Create a copy of MedicationTreatment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicationTreatmentCopyWith<_MedicationTreatment> get copyWith => __$MedicationTreatmentCopyWithImpl<_MedicationTreatment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicationTreatment&&(identical(other.id, id) || other.id == id)&&(identical(other.animalId, animalId) || other.animalId == animalId)&&(identical(other.revision, revision) || other.revision == revision)&&(identical(other.version, version) || other.version == version)&&(identical(other.medicationName, medicationName) || other.medicationName == medicationName)&&(identical(other.instructions, instructions) || other.instructions == instructions)&&(identical(other.schedule, schedule) || other.schedule == schedule)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,id,animalId,revision,version,medicationName,instructions,schedule,status);

@override
String toString() {
  return 'MedicationTreatment(id: $id, animalId: $animalId, revision: $revision, version: $version, medicationName: $medicationName, instructions: $instructions, schedule: $schedule, status: $status)';
}


}

/// @nodoc
abstract mixin class _$MedicationTreatmentCopyWith<$Res> implements $MedicationTreatmentCopyWith<$Res> {
  factory _$MedicationTreatmentCopyWith(_MedicationTreatment value, $Res Function(_MedicationTreatment) _then) = __$MedicationTreatmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String animalId, int revision, int version, String medicationName, String instructions, MedicationSchedule schedule, MedicationTreatmentStatus status
});


@override $MedicationScheduleCopyWith<$Res> get schedule;

}
/// @nodoc
class __$MedicationTreatmentCopyWithImpl<$Res>
    implements _$MedicationTreatmentCopyWith<$Res> {
  __$MedicationTreatmentCopyWithImpl(this._self, this._then);

  final _MedicationTreatment _self;
  final $Res Function(_MedicationTreatment) _then;

/// Create a copy of MedicationTreatment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? animalId = null,Object? revision = null,Object? version = null,Object? medicationName = null,Object? instructions = null,Object? schedule = null,Object? status = null,}) {
  return _then(_MedicationTreatment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,animalId: null == animalId ? _self.animalId : animalId // ignore: cast_nullable_to_non_nullable
as String,revision: null == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as int,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,medicationName: null == medicationName ? _self.medicationName : medicationName // ignore: cast_nullable_to_non_nullable
as String,instructions: null == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String,schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as MedicationSchedule,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MedicationTreatmentStatus,
  ));
}

/// Create a copy of MedicationTreatment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MedicationScheduleCopyWith<$Res> get schedule {
  
  return $MedicationScheduleCopyWith<$Res>(_self.schedule, (value) {
    return _then(_self.copyWith(schedule: value));
  });
}
}

/// @nodoc
mixin _$MedicationTreatmentDraft {

 String? get treatmentId; String get animalId; int? get expectedRevision; int? get expectedVersion; String get medicationName; String get instructions; MedicationSchedule get schedule;
/// Create a copy of MedicationTreatmentDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicationTreatmentDraftCopyWith<MedicationTreatmentDraft> get copyWith => _$MedicationTreatmentDraftCopyWithImpl<MedicationTreatmentDraft>(this as MedicationTreatmentDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicationTreatmentDraft&&(identical(other.treatmentId, treatmentId) || other.treatmentId == treatmentId)&&(identical(other.animalId, animalId) || other.animalId == animalId)&&(identical(other.expectedRevision, expectedRevision) || other.expectedRevision == expectedRevision)&&(identical(other.expectedVersion, expectedVersion) || other.expectedVersion == expectedVersion)&&(identical(other.medicationName, medicationName) || other.medicationName == medicationName)&&(identical(other.instructions, instructions) || other.instructions == instructions)&&(identical(other.schedule, schedule) || other.schedule == schedule));
}


@override
int get hashCode => Object.hash(runtimeType,treatmentId,animalId,expectedRevision,expectedVersion,medicationName,instructions,schedule);

@override
String toString() {
  return 'MedicationTreatmentDraft(treatmentId: $treatmentId, animalId: $animalId, expectedRevision: $expectedRevision, expectedVersion: $expectedVersion, medicationName: $medicationName, instructions: $instructions, schedule: $schedule)';
}


}

/// @nodoc
abstract mixin class $MedicationTreatmentDraftCopyWith<$Res>  {
  factory $MedicationTreatmentDraftCopyWith(MedicationTreatmentDraft value, $Res Function(MedicationTreatmentDraft) _then) = _$MedicationTreatmentDraftCopyWithImpl;
@useResult
$Res call({
 String? treatmentId, String animalId, int? expectedRevision, int? expectedVersion, String medicationName, String instructions, MedicationSchedule schedule
});


$MedicationScheduleCopyWith<$Res> get schedule;

}
/// @nodoc
class _$MedicationTreatmentDraftCopyWithImpl<$Res>
    implements $MedicationTreatmentDraftCopyWith<$Res> {
  _$MedicationTreatmentDraftCopyWithImpl(this._self, this._then);

  final MedicationTreatmentDraft _self;
  final $Res Function(MedicationTreatmentDraft) _then;

/// Create a copy of MedicationTreatmentDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? treatmentId = freezed,Object? animalId = null,Object? expectedRevision = freezed,Object? expectedVersion = freezed,Object? medicationName = null,Object? instructions = null,Object? schedule = null,}) {
  return _then(_self.copyWith(
treatmentId: freezed == treatmentId ? _self.treatmentId : treatmentId // ignore: cast_nullable_to_non_nullable
as String?,animalId: null == animalId ? _self.animalId : animalId // ignore: cast_nullable_to_non_nullable
as String,expectedRevision: freezed == expectedRevision ? _self.expectedRevision : expectedRevision // ignore: cast_nullable_to_non_nullable
as int?,expectedVersion: freezed == expectedVersion ? _self.expectedVersion : expectedVersion // ignore: cast_nullable_to_non_nullable
as int?,medicationName: null == medicationName ? _self.medicationName : medicationName // ignore: cast_nullable_to_non_nullable
as String,instructions: null == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String,schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as MedicationSchedule,
  ));
}
/// Create a copy of MedicationTreatmentDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MedicationScheduleCopyWith<$Res> get schedule {
  
  return $MedicationScheduleCopyWith<$Res>(_self.schedule, (value) {
    return _then(_self.copyWith(schedule: value));
  });
}
}


/// Adds pattern-matching-related methods to [MedicationTreatmentDraft].
extension MedicationTreatmentDraftPatterns on MedicationTreatmentDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicationTreatmentDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicationTreatmentDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicationTreatmentDraft value)  $default,){
final _that = this;
switch (_that) {
case _MedicationTreatmentDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicationTreatmentDraft value)?  $default,){
final _that = this;
switch (_that) {
case _MedicationTreatmentDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? treatmentId,  String animalId,  int? expectedRevision,  int? expectedVersion,  String medicationName,  String instructions,  MedicationSchedule schedule)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicationTreatmentDraft() when $default != null:
return $default(_that.treatmentId,_that.animalId,_that.expectedRevision,_that.expectedVersion,_that.medicationName,_that.instructions,_that.schedule);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? treatmentId,  String animalId,  int? expectedRevision,  int? expectedVersion,  String medicationName,  String instructions,  MedicationSchedule schedule)  $default,) {final _that = this;
switch (_that) {
case _MedicationTreatmentDraft():
return $default(_that.treatmentId,_that.animalId,_that.expectedRevision,_that.expectedVersion,_that.medicationName,_that.instructions,_that.schedule);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? treatmentId,  String animalId,  int? expectedRevision,  int? expectedVersion,  String medicationName,  String instructions,  MedicationSchedule schedule)?  $default,) {final _that = this;
switch (_that) {
case _MedicationTreatmentDraft() when $default != null:
return $default(_that.treatmentId,_that.animalId,_that.expectedRevision,_that.expectedVersion,_that.medicationName,_that.instructions,_that.schedule);case _:
  return null;

}
}

}

/// @nodoc


class _MedicationTreatmentDraft extends MedicationTreatmentDraft {
  const _MedicationTreatmentDraft({this.treatmentId, this.animalId = '', this.expectedRevision, this.expectedVersion, this.medicationName = '', this.instructions = '', this.schedule = const MedicationSchedule()}): super._();
  

@override final  String? treatmentId;
@override@JsonKey() final  String animalId;
@override final  int? expectedRevision;
@override final  int? expectedVersion;
@override@JsonKey() final  String medicationName;
@override@JsonKey() final  String instructions;
@override@JsonKey() final  MedicationSchedule schedule;

/// Create a copy of MedicationTreatmentDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicationTreatmentDraftCopyWith<_MedicationTreatmentDraft> get copyWith => __$MedicationTreatmentDraftCopyWithImpl<_MedicationTreatmentDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicationTreatmentDraft&&(identical(other.treatmentId, treatmentId) || other.treatmentId == treatmentId)&&(identical(other.animalId, animalId) || other.animalId == animalId)&&(identical(other.expectedRevision, expectedRevision) || other.expectedRevision == expectedRevision)&&(identical(other.expectedVersion, expectedVersion) || other.expectedVersion == expectedVersion)&&(identical(other.medicationName, medicationName) || other.medicationName == medicationName)&&(identical(other.instructions, instructions) || other.instructions == instructions)&&(identical(other.schedule, schedule) || other.schedule == schedule));
}


@override
int get hashCode => Object.hash(runtimeType,treatmentId,animalId,expectedRevision,expectedVersion,medicationName,instructions,schedule);

@override
String toString() {
  return 'MedicationTreatmentDraft(treatmentId: $treatmentId, animalId: $animalId, expectedRevision: $expectedRevision, expectedVersion: $expectedVersion, medicationName: $medicationName, instructions: $instructions, schedule: $schedule)';
}


}

/// @nodoc
abstract mixin class _$MedicationTreatmentDraftCopyWith<$Res> implements $MedicationTreatmentDraftCopyWith<$Res> {
  factory _$MedicationTreatmentDraftCopyWith(_MedicationTreatmentDraft value, $Res Function(_MedicationTreatmentDraft) _then) = __$MedicationTreatmentDraftCopyWithImpl;
@override @useResult
$Res call({
 String? treatmentId, String animalId, int? expectedRevision, int? expectedVersion, String medicationName, String instructions, MedicationSchedule schedule
});


@override $MedicationScheduleCopyWith<$Res> get schedule;

}
/// @nodoc
class __$MedicationTreatmentDraftCopyWithImpl<$Res>
    implements _$MedicationTreatmentDraftCopyWith<$Res> {
  __$MedicationTreatmentDraftCopyWithImpl(this._self, this._then);

  final _MedicationTreatmentDraft _self;
  final $Res Function(_MedicationTreatmentDraft) _then;

/// Create a copy of MedicationTreatmentDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? treatmentId = freezed,Object? animalId = null,Object? expectedRevision = freezed,Object? expectedVersion = freezed,Object? medicationName = null,Object? instructions = null,Object? schedule = null,}) {
  return _then(_MedicationTreatmentDraft(
treatmentId: freezed == treatmentId ? _self.treatmentId : treatmentId // ignore: cast_nullable_to_non_nullable
as String?,animalId: null == animalId ? _self.animalId : animalId // ignore: cast_nullable_to_non_nullable
as String,expectedRevision: freezed == expectedRevision ? _self.expectedRevision : expectedRevision // ignore: cast_nullable_to_non_nullable
as int?,expectedVersion: freezed == expectedVersion ? _self.expectedVersion : expectedVersion // ignore: cast_nullable_to_non_nullable
as int?,medicationName: null == medicationName ? _self.medicationName : medicationName // ignore: cast_nullable_to_non_nullable
as String,instructions: null == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String,schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as MedicationSchedule,
  ));
}

/// Create a copy of MedicationTreatmentDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MedicationScheduleCopyWith<$Res> get schedule {
  
  return $MedicationScheduleCopyWith<$Res>(_self.schedule, (value) {
    return _then(_self.copyWith(schedule: value));
  });
}
}

// dart format on
