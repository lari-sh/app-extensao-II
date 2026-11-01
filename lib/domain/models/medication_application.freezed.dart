// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medication_application.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MedicationApplication {

 String get id; String get treatmentId; String get animalId; String get animalName; String get medicationName; String get instructions; int get revision; int get version; DateTime get scheduledAt; String get scheduledLocalDate; String get scheduledLocalTime; MedicationApplicationState get state; String? get performedBy; String? get actorLabel; DateTime? get performedAt; String? get performedLocalDate; String? get performedLocalTime;
/// Create a copy of MedicationApplication
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicationApplicationCopyWith<MedicationApplication> get copyWith => _$MedicationApplicationCopyWithImpl<MedicationApplication>(this as MedicationApplication, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicationApplication&&(identical(other.id, id) || other.id == id)&&(identical(other.treatmentId, treatmentId) || other.treatmentId == treatmentId)&&(identical(other.animalId, animalId) || other.animalId == animalId)&&(identical(other.animalName, animalName) || other.animalName == animalName)&&(identical(other.medicationName, medicationName) || other.medicationName == medicationName)&&(identical(other.instructions, instructions) || other.instructions == instructions)&&(identical(other.revision, revision) || other.revision == revision)&&(identical(other.version, version) || other.version == version)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.scheduledLocalDate, scheduledLocalDate) || other.scheduledLocalDate == scheduledLocalDate)&&(identical(other.scheduledLocalTime, scheduledLocalTime) || other.scheduledLocalTime == scheduledLocalTime)&&(identical(other.state, state) || other.state == state)&&(identical(other.performedBy, performedBy) || other.performedBy == performedBy)&&(identical(other.actorLabel, actorLabel) || other.actorLabel == actorLabel)&&(identical(other.performedAt, performedAt) || other.performedAt == performedAt)&&(identical(other.performedLocalDate, performedLocalDate) || other.performedLocalDate == performedLocalDate)&&(identical(other.performedLocalTime, performedLocalTime) || other.performedLocalTime == performedLocalTime));
}


@override
int get hashCode => Object.hash(runtimeType,id,treatmentId,animalId,animalName,medicationName,instructions,revision,version,scheduledAt,scheduledLocalDate,scheduledLocalTime,state,performedBy,actorLabel,performedAt,performedLocalDate,performedLocalTime);

@override
String toString() {
  return 'MedicationApplication(id: $id, treatmentId: $treatmentId, animalId: $animalId, animalName: $animalName, medicationName: $medicationName, instructions: $instructions, revision: $revision, version: $version, scheduledAt: $scheduledAt, scheduledLocalDate: $scheduledLocalDate, scheduledLocalTime: $scheduledLocalTime, state: $state, performedBy: $performedBy, actorLabel: $actorLabel, performedAt: $performedAt, performedLocalDate: $performedLocalDate, performedLocalTime: $performedLocalTime)';
}


}

/// @nodoc
abstract mixin class $MedicationApplicationCopyWith<$Res>  {
  factory $MedicationApplicationCopyWith(MedicationApplication value, $Res Function(MedicationApplication) _then) = _$MedicationApplicationCopyWithImpl;
@useResult
$Res call({
 String id, String treatmentId, String animalId, String animalName, String medicationName, String instructions, int revision, int version, DateTime scheduledAt, String scheduledLocalDate, String scheduledLocalTime, MedicationApplicationState state, String? performedBy, String? actorLabel, DateTime? performedAt, String? performedLocalDate, String? performedLocalTime
});




}
/// @nodoc
class _$MedicationApplicationCopyWithImpl<$Res>
    implements $MedicationApplicationCopyWith<$Res> {
  _$MedicationApplicationCopyWithImpl(this._self, this._then);

  final MedicationApplication _self;
  final $Res Function(MedicationApplication) _then;

/// Create a copy of MedicationApplication
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? treatmentId = null,Object? animalId = null,Object? animalName = null,Object? medicationName = null,Object? instructions = null,Object? revision = null,Object? version = null,Object? scheduledAt = null,Object? scheduledLocalDate = null,Object? scheduledLocalTime = null,Object? state = null,Object? performedBy = freezed,Object? actorLabel = freezed,Object? performedAt = freezed,Object? performedLocalDate = freezed,Object? performedLocalTime = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,treatmentId: null == treatmentId ? _self.treatmentId : treatmentId // ignore: cast_nullable_to_non_nullable
as String,animalId: null == animalId ? _self.animalId : animalId // ignore: cast_nullable_to_non_nullable
as String,animalName: null == animalName ? _self.animalName : animalName // ignore: cast_nullable_to_non_nullable
as String,medicationName: null == medicationName ? _self.medicationName : medicationName // ignore: cast_nullable_to_non_nullable
as String,instructions: null == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String,revision: null == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as int,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,scheduledLocalDate: null == scheduledLocalDate ? _self.scheduledLocalDate : scheduledLocalDate // ignore: cast_nullable_to_non_nullable
as String,scheduledLocalTime: null == scheduledLocalTime ? _self.scheduledLocalTime : scheduledLocalTime // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as MedicationApplicationState,performedBy: freezed == performedBy ? _self.performedBy : performedBy // ignore: cast_nullable_to_non_nullable
as String?,actorLabel: freezed == actorLabel ? _self.actorLabel : actorLabel // ignore: cast_nullable_to_non_nullable
as String?,performedAt: freezed == performedAt ? _self.performedAt : performedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,performedLocalDate: freezed == performedLocalDate ? _self.performedLocalDate : performedLocalDate // ignore: cast_nullable_to_non_nullable
as String?,performedLocalTime: freezed == performedLocalTime ? _self.performedLocalTime : performedLocalTime // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicationApplication].
extension MedicationApplicationPatterns on MedicationApplication {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicationApplication value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicationApplication() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicationApplication value)  $default,){
final _that = this;
switch (_that) {
case _MedicationApplication():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicationApplication value)?  $default,){
final _that = this;
switch (_that) {
case _MedicationApplication() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String treatmentId,  String animalId,  String animalName,  String medicationName,  String instructions,  int revision,  int version,  DateTime scheduledAt,  String scheduledLocalDate,  String scheduledLocalTime,  MedicationApplicationState state,  String? performedBy,  String? actorLabel,  DateTime? performedAt,  String? performedLocalDate,  String? performedLocalTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicationApplication() when $default != null:
return $default(_that.id,_that.treatmentId,_that.animalId,_that.animalName,_that.medicationName,_that.instructions,_that.revision,_that.version,_that.scheduledAt,_that.scheduledLocalDate,_that.scheduledLocalTime,_that.state,_that.performedBy,_that.actorLabel,_that.performedAt,_that.performedLocalDate,_that.performedLocalTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String treatmentId,  String animalId,  String animalName,  String medicationName,  String instructions,  int revision,  int version,  DateTime scheduledAt,  String scheduledLocalDate,  String scheduledLocalTime,  MedicationApplicationState state,  String? performedBy,  String? actorLabel,  DateTime? performedAt,  String? performedLocalDate,  String? performedLocalTime)  $default,) {final _that = this;
switch (_that) {
case _MedicationApplication():
return $default(_that.id,_that.treatmentId,_that.animalId,_that.animalName,_that.medicationName,_that.instructions,_that.revision,_that.version,_that.scheduledAt,_that.scheduledLocalDate,_that.scheduledLocalTime,_that.state,_that.performedBy,_that.actorLabel,_that.performedAt,_that.performedLocalDate,_that.performedLocalTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String treatmentId,  String animalId,  String animalName,  String medicationName,  String instructions,  int revision,  int version,  DateTime scheduledAt,  String scheduledLocalDate,  String scheduledLocalTime,  MedicationApplicationState state,  String? performedBy,  String? actorLabel,  DateTime? performedAt,  String? performedLocalDate,  String? performedLocalTime)?  $default,) {final _that = this;
switch (_that) {
case _MedicationApplication() when $default != null:
return $default(_that.id,_that.treatmentId,_that.animalId,_that.animalName,_that.medicationName,_that.instructions,_that.revision,_that.version,_that.scheduledAt,_that.scheduledLocalDate,_that.scheduledLocalTime,_that.state,_that.performedBy,_that.actorLabel,_that.performedAt,_that.performedLocalDate,_that.performedLocalTime);case _:
  return null;

}
}

}

/// @nodoc


class _MedicationApplication extends MedicationApplication {
  const _MedicationApplication({required this.id, required this.treatmentId, required this.animalId, required this.animalName, required this.medicationName, this.instructions = '', required this.revision, required this.version, required this.scheduledAt, required this.scheduledLocalDate, required this.scheduledLocalTime, this.state = MedicationApplicationState.pending, this.performedBy, this.actorLabel, this.performedAt, this.performedLocalDate, this.performedLocalTime}): super._();
  

@override final  String id;
@override final  String treatmentId;
@override final  String animalId;
@override final  String animalName;
@override final  String medicationName;
@override@JsonKey() final  String instructions;
@override final  int revision;
@override final  int version;
@override final  DateTime scheduledAt;
@override final  String scheduledLocalDate;
@override final  String scheduledLocalTime;
@override@JsonKey() final  MedicationApplicationState state;
@override final  String? performedBy;
@override final  String? actorLabel;
@override final  DateTime? performedAt;
@override final  String? performedLocalDate;
@override final  String? performedLocalTime;

/// Create a copy of MedicationApplication
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicationApplicationCopyWith<_MedicationApplication> get copyWith => __$MedicationApplicationCopyWithImpl<_MedicationApplication>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicationApplication&&(identical(other.id, id) || other.id == id)&&(identical(other.treatmentId, treatmentId) || other.treatmentId == treatmentId)&&(identical(other.animalId, animalId) || other.animalId == animalId)&&(identical(other.animalName, animalName) || other.animalName == animalName)&&(identical(other.medicationName, medicationName) || other.medicationName == medicationName)&&(identical(other.instructions, instructions) || other.instructions == instructions)&&(identical(other.revision, revision) || other.revision == revision)&&(identical(other.version, version) || other.version == version)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.scheduledLocalDate, scheduledLocalDate) || other.scheduledLocalDate == scheduledLocalDate)&&(identical(other.scheduledLocalTime, scheduledLocalTime) || other.scheduledLocalTime == scheduledLocalTime)&&(identical(other.state, state) || other.state == state)&&(identical(other.performedBy, performedBy) || other.performedBy == performedBy)&&(identical(other.actorLabel, actorLabel) || other.actorLabel == actorLabel)&&(identical(other.performedAt, performedAt) || other.performedAt == performedAt)&&(identical(other.performedLocalDate, performedLocalDate) || other.performedLocalDate == performedLocalDate)&&(identical(other.performedLocalTime, performedLocalTime) || other.performedLocalTime == performedLocalTime));
}


@override
int get hashCode => Object.hash(runtimeType,id,treatmentId,animalId,animalName,medicationName,instructions,revision,version,scheduledAt,scheduledLocalDate,scheduledLocalTime,state,performedBy,actorLabel,performedAt,performedLocalDate,performedLocalTime);

@override
String toString() {
  return 'MedicationApplication(id: $id, treatmentId: $treatmentId, animalId: $animalId, animalName: $animalName, medicationName: $medicationName, instructions: $instructions, revision: $revision, version: $version, scheduledAt: $scheduledAt, scheduledLocalDate: $scheduledLocalDate, scheduledLocalTime: $scheduledLocalTime, state: $state, performedBy: $performedBy, actorLabel: $actorLabel, performedAt: $performedAt, performedLocalDate: $performedLocalDate, performedLocalTime: $performedLocalTime)';
}


}

/// @nodoc
abstract mixin class _$MedicationApplicationCopyWith<$Res> implements $MedicationApplicationCopyWith<$Res> {
  factory _$MedicationApplicationCopyWith(_MedicationApplication value, $Res Function(_MedicationApplication) _then) = __$MedicationApplicationCopyWithImpl;
@override @useResult
$Res call({
 String id, String treatmentId, String animalId, String animalName, String medicationName, String instructions, int revision, int version, DateTime scheduledAt, String scheduledLocalDate, String scheduledLocalTime, MedicationApplicationState state, String? performedBy, String? actorLabel, DateTime? performedAt, String? performedLocalDate, String? performedLocalTime
});




}
/// @nodoc
class __$MedicationApplicationCopyWithImpl<$Res>
    implements _$MedicationApplicationCopyWith<$Res> {
  __$MedicationApplicationCopyWithImpl(this._self, this._then);

  final _MedicationApplication _self;
  final $Res Function(_MedicationApplication) _then;

/// Create a copy of MedicationApplication
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? treatmentId = null,Object? animalId = null,Object? animalName = null,Object? medicationName = null,Object? instructions = null,Object? revision = null,Object? version = null,Object? scheduledAt = null,Object? scheduledLocalDate = null,Object? scheduledLocalTime = null,Object? state = null,Object? performedBy = freezed,Object? actorLabel = freezed,Object? performedAt = freezed,Object? performedLocalDate = freezed,Object? performedLocalTime = freezed,}) {
  return _then(_MedicationApplication(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,treatmentId: null == treatmentId ? _self.treatmentId : treatmentId // ignore: cast_nullable_to_non_nullable
as String,animalId: null == animalId ? _self.animalId : animalId // ignore: cast_nullable_to_non_nullable
as String,animalName: null == animalName ? _self.animalName : animalName // ignore: cast_nullable_to_non_nullable
as String,medicationName: null == medicationName ? _self.medicationName : medicationName // ignore: cast_nullable_to_non_nullable
as String,instructions: null == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String,revision: null == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as int,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,scheduledLocalDate: null == scheduledLocalDate ? _self.scheduledLocalDate : scheduledLocalDate // ignore: cast_nullable_to_non_nullable
as String,scheduledLocalTime: null == scheduledLocalTime ? _self.scheduledLocalTime : scheduledLocalTime // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as MedicationApplicationState,performedBy: freezed == performedBy ? _self.performedBy : performedBy // ignore: cast_nullable_to_non_nullable
as String?,actorLabel: freezed == actorLabel ? _self.actorLabel : actorLabel // ignore: cast_nullable_to_non_nullable
as String?,performedAt: freezed == performedAt ? _self.performedAt : performedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,performedLocalDate: freezed == performedLocalDate ? _self.performedLocalDate : performedLocalDate // ignore: cast_nullable_to_non_nullable
as String?,performedLocalTime: freezed == performedLocalTime ? _self.performedLocalTime : performedLocalTime // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$MedicationApplicationEvent {

 String get id; String get applicationId; MedicationEventType get type; String get actorId; String get actorLabel; DateTime get occurredAt; String get occurredLocalDate; String get occurredLocalTime; int get applicationVersion; String? get reason;
/// Create a copy of MedicationApplicationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicationApplicationEventCopyWith<MedicationApplicationEvent> get copyWith => _$MedicationApplicationEventCopyWithImpl<MedicationApplicationEvent>(this as MedicationApplicationEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicationApplicationEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.applicationId, applicationId) || other.applicationId == applicationId)&&(identical(other.type, type) || other.type == type)&&(identical(other.actorId, actorId) || other.actorId == actorId)&&(identical(other.actorLabel, actorLabel) || other.actorLabel == actorLabel)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.occurredLocalDate, occurredLocalDate) || other.occurredLocalDate == occurredLocalDate)&&(identical(other.occurredLocalTime, occurredLocalTime) || other.occurredLocalTime == occurredLocalTime)&&(identical(other.applicationVersion, applicationVersion) || other.applicationVersion == applicationVersion)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,id,applicationId,type,actorId,actorLabel,occurredAt,occurredLocalDate,occurredLocalTime,applicationVersion,reason);

@override
String toString() {
  return 'MedicationApplicationEvent(id: $id, applicationId: $applicationId, type: $type, actorId: $actorId, actorLabel: $actorLabel, occurredAt: $occurredAt, occurredLocalDate: $occurredLocalDate, occurredLocalTime: $occurredLocalTime, applicationVersion: $applicationVersion, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $MedicationApplicationEventCopyWith<$Res>  {
  factory $MedicationApplicationEventCopyWith(MedicationApplicationEvent value, $Res Function(MedicationApplicationEvent) _then) = _$MedicationApplicationEventCopyWithImpl;
@useResult
$Res call({
 String id, String applicationId, MedicationEventType type, String actorId, String actorLabel, DateTime occurredAt, String occurredLocalDate, String occurredLocalTime, int applicationVersion, String? reason
});




}
/// @nodoc
class _$MedicationApplicationEventCopyWithImpl<$Res>
    implements $MedicationApplicationEventCopyWith<$Res> {
  _$MedicationApplicationEventCopyWithImpl(this._self, this._then);

  final MedicationApplicationEvent _self;
  final $Res Function(MedicationApplicationEvent) _then;

/// Create a copy of MedicationApplicationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? applicationId = null,Object? type = null,Object? actorId = null,Object? actorLabel = null,Object? occurredAt = null,Object? occurredLocalDate = null,Object? occurredLocalTime = null,Object? applicationVersion = null,Object? reason = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,applicationId: null == applicationId ? _self.applicationId : applicationId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MedicationEventType,actorId: null == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String,actorLabel: null == actorLabel ? _self.actorLabel : actorLabel // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,occurredLocalDate: null == occurredLocalDate ? _self.occurredLocalDate : occurredLocalDate // ignore: cast_nullable_to_non_nullable
as String,occurredLocalTime: null == occurredLocalTime ? _self.occurredLocalTime : occurredLocalTime // ignore: cast_nullable_to_non_nullable
as String,applicationVersion: null == applicationVersion ? _self.applicationVersion : applicationVersion // ignore: cast_nullable_to_non_nullable
as int,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicationApplicationEvent].
extension MedicationApplicationEventPatterns on MedicationApplicationEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicationApplicationEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicationApplicationEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicationApplicationEvent value)  $default,){
final _that = this;
switch (_that) {
case _MedicationApplicationEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicationApplicationEvent value)?  $default,){
final _that = this;
switch (_that) {
case _MedicationApplicationEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String applicationId,  MedicationEventType type,  String actorId,  String actorLabel,  DateTime occurredAt,  String occurredLocalDate,  String occurredLocalTime,  int applicationVersion,  String? reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicationApplicationEvent() when $default != null:
return $default(_that.id,_that.applicationId,_that.type,_that.actorId,_that.actorLabel,_that.occurredAt,_that.occurredLocalDate,_that.occurredLocalTime,_that.applicationVersion,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String applicationId,  MedicationEventType type,  String actorId,  String actorLabel,  DateTime occurredAt,  String occurredLocalDate,  String occurredLocalTime,  int applicationVersion,  String? reason)  $default,) {final _that = this;
switch (_that) {
case _MedicationApplicationEvent():
return $default(_that.id,_that.applicationId,_that.type,_that.actorId,_that.actorLabel,_that.occurredAt,_that.occurredLocalDate,_that.occurredLocalTime,_that.applicationVersion,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String applicationId,  MedicationEventType type,  String actorId,  String actorLabel,  DateTime occurredAt,  String occurredLocalDate,  String occurredLocalTime,  int applicationVersion,  String? reason)?  $default,) {final _that = this;
switch (_that) {
case _MedicationApplicationEvent() when $default != null:
return $default(_that.id,_that.applicationId,_that.type,_that.actorId,_that.actorLabel,_that.occurredAt,_that.occurredLocalDate,_that.occurredLocalTime,_that.applicationVersion,_that.reason);case _:
  return null;

}
}

}

/// @nodoc


class _MedicationApplicationEvent implements MedicationApplicationEvent {
  const _MedicationApplicationEvent({required this.id, required this.applicationId, required this.type, required this.actorId, required this.actorLabel, required this.occurredAt, required this.occurredLocalDate, required this.occurredLocalTime, required this.applicationVersion, this.reason});
  

@override final  String id;
@override final  String applicationId;
@override final  MedicationEventType type;
@override final  String actorId;
@override final  String actorLabel;
@override final  DateTime occurredAt;
@override final  String occurredLocalDate;
@override final  String occurredLocalTime;
@override final  int applicationVersion;
@override final  String? reason;

/// Create a copy of MedicationApplicationEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicationApplicationEventCopyWith<_MedicationApplicationEvent> get copyWith => __$MedicationApplicationEventCopyWithImpl<_MedicationApplicationEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicationApplicationEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.applicationId, applicationId) || other.applicationId == applicationId)&&(identical(other.type, type) || other.type == type)&&(identical(other.actorId, actorId) || other.actorId == actorId)&&(identical(other.actorLabel, actorLabel) || other.actorLabel == actorLabel)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.occurredLocalDate, occurredLocalDate) || other.occurredLocalDate == occurredLocalDate)&&(identical(other.occurredLocalTime, occurredLocalTime) || other.occurredLocalTime == occurredLocalTime)&&(identical(other.applicationVersion, applicationVersion) || other.applicationVersion == applicationVersion)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,id,applicationId,type,actorId,actorLabel,occurredAt,occurredLocalDate,occurredLocalTime,applicationVersion,reason);

@override
String toString() {
  return 'MedicationApplicationEvent(id: $id, applicationId: $applicationId, type: $type, actorId: $actorId, actorLabel: $actorLabel, occurredAt: $occurredAt, occurredLocalDate: $occurredLocalDate, occurredLocalTime: $occurredLocalTime, applicationVersion: $applicationVersion, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$MedicationApplicationEventCopyWith<$Res> implements $MedicationApplicationEventCopyWith<$Res> {
  factory _$MedicationApplicationEventCopyWith(_MedicationApplicationEvent value, $Res Function(_MedicationApplicationEvent) _then) = __$MedicationApplicationEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String applicationId, MedicationEventType type, String actorId, String actorLabel, DateTime occurredAt, String occurredLocalDate, String occurredLocalTime, int applicationVersion, String? reason
});




}
/// @nodoc
class __$MedicationApplicationEventCopyWithImpl<$Res>
    implements _$MedicationApplicationEventCopyWith<$Res> {
  __$MedicationApplicationEventCopyWithImpl(this._self, this._then);

  final _MedicationApplicationEvent _self;
  final $Res Function(_MedicationApplicationEvent) _then;

/// Create a copy of MedicationApplicationEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? applicationId = null,Object? type = null,Object? actorId = null,Object? actorLabel = null,Object? occurredAt = null,Object? occurredLocalDate = null,Object? occurredLocalTime = null,Object? applicationVersion = null,Object? reason = freezed,}) {
  return _then(_MedicationApplicationEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,applicationId: null == applicationId ? _self.applicationId : applicationId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MedicationEventType,actorId: null == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String,actorLabel: null == actorLabel ? _self.actorLabel : actorLabel // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,occurredLocalDate: null == occurredLocalDate ? _self.occurredLocalDate : occurredLocalDate // ignore: cast_nullable_to_non_nullable
as String,occurredLocalTime: null == occurredLocalTime ? _self.occurredLocalTime : occurredLocalTime // ignore: cast_nullable_to_non_nullable
as String,applicationVersion: null == applicationVersion ? _self.applicationVersion : applicationVersion // ignore: cast_nullable_to_non_nullable
as int,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$MedicationCommandResult {

 String get operationKey; DateTime get serverNow; MedicationTreatment? get treatment; MedicationApplication? get application; MedicationApplicationEvent? get event; int get cancelledCount;
/// Create a copy of MedicationCommandResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicationCommandResultCopyWith<MedicationCommandResult> get copyWith => _$MedicationCommandResultCopyWithImpl<MedicationCommandResult>(this as MedicationCommandResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicationCommandResult&&(identical(other.operationKey, operationKey) || other.operationKey == operationKey)&&(identical(other.serverNow, serverNow) || other.serverNow == serverNow)&&(identical(other.treatment, treatment) || other.treatment == treatment)&&(identical(other.application, application) || other.application == application)&&(identical(other.event, event) || other.event == event)&&(identical(other.cancelledCount, cancelledCount) || other.cancelledCount == cancelledCount));
}


@override
int get hashCode => Object.hash(runtimeType,operationKey,serverNow,treatment,application,event,cancelledCount);

@override
String toString() {
  return 'MedicationCommandResult(operationKey: $operationKey, serverNow: $serverNow, treatment: $treatment, application: $application, event: $event, cancelledCount: $cancelledCount)';
}


}

/// @nodoc
abstract mixin class $MedicationCommandResultCopyWith<$Res>  {
  factory $MedicationCommandResultCopyWith(MedicationCommandResult value, $Res Function(MedicationCommandResult) _then) = _$MedicationCommandResultCopyWithImpl;
@useResult
$Res call({
 String operationKey, DateTime serverNow, MedicationTreatment? treatment, MedicationApplication? application, MedicationApplicationEvent? event, int cancelledCount
});


$MedicationTreatmentCopyWith<$Res>? get treatment;$MedicationApplicationCopyWith<$Res>? get application;$MedicationApplicationEventCopyWith<$Res>? get event;

}
/// @nodoc
class _$MedicationCommandResultCopyWithImpl<$Res>
    implements $MedicationCommandResultCopyWith<$Res> {
  _$MedicationCommandResultCopyWithImpl(this._self, this._then);

  final MedicationCommandResult _self;
  final $Res Function(MedicationCommandResult) _then;

/// Create a copy of MedicationCommandResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? operationKey = null,Object? serverNow = null,Object? treatment = freezed,Object? application = freezed,Object? event = freezed,Object? cancelledCount = null,}) {
  return _then(_self.copyWith(
operationKey: null == operationKey ? _self.operationKey : operationKey // ignore: cast_nullable_to_non_nullable
as String,serverNow: null == serverNow ? _self.serverNow : serverNow // ignore: cast_nullable_to_non_nullable
as DateTime,treatment: freezed == treatment ? _self.treatment : treatment // ignore: cast_nullable_to_non_nullable
as MedicationTreatment?,application: freezed == application ? _self.application : application // ignore: cast_nullable_to_non_nullable
as MedicationApplication?,event: freezed == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as MedicationApplicationEvent?,cancelledCount: null == cancelledCount ? _self.cancelledCount : cancelledCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of MedicationCommandResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MedicationTreatmentCopyWith<$Res>? get treatment {
    if (_self.treatment == null) {
    return null;
  }

  return $MedicationTreatmentCopyWith<$Res>(_self.treatment!, (value) {
    return _then(_self.copyWith(treatment: value));
  });
}/// Create a copy of MedicationCommandResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MedicationApplicationCopyWith<$Res>? get application {
    if (_self.application == null) {
    return null;
  }

  return $MedicationApplicationCopyWith<$Res>(_self.application!, (value) {
    return _then(_self.copyWith(application: value));
  });
}/// Create a copy of MedicationCommandResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MedicationApplicationEventCopyWith<$Res>? get event {
    if (_self.event == null) {
    return null;
  }

  return $MedicationApplicationEventCopyWith<$Res>(_self.event!, (value) {
    return _then(_self.copyWith(event: value));
  });
}
}


/// Adds pattern-matching-related methods to [MedicationCommandResult].
extension MedicationCommandResultPatterns on MedicationCommandResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicationCommandResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicationCommandResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicationCommandResult value)  $default,){
final _that = this;
switch (_that) {
case _MedicationCommandResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicationCommandResult value)?  $default,){
final _that = this;
switch (_that) {
case _MedicationCommandResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String operationKey,  DateTime serverNow,  MedicationTreatment? treatment,  MedicationApplication? application,  MedicationApplicationEvent? event,  int cancelledCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicationCommandResult() when $default != null:
return $default(_that.operationKey,_that.serverNow,_that.treatment,_that.application,_that.event,_that.cancelledCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String operationKey,  DateTime serverNow,  MedicationTreatment? treatment,  MedicationApplication? application,  MedicationApplicationEvent? event,  int cancelledCount)  $default,) {final _that = this;
switch (_that) {
case _MedicationCommandResult():
return $default(_that.operationKey,_that.serverNow,_that.treatment,_that.application,_that.event,_that.cancelledCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String operationKey,  DateTime serverNow,  MedicationTreatment? treatment,  MedicationApplication? application,  MedicationApplicationEvent? event,  int cancelledCount)?  $default,) {final _that = this;
switch (_that) {
case _MedicationCommandResult() when $default != null:
return $default(_that.operationKey,_that.serverNow,_that.treatment,_that.application,_that.event,_that.cancelledCount);case _:
  return null;

}
}

}

/// @nodoc


class _MedicationCommandResult implements MedicationCommandResult {
  const _MedicationCommandResult({required this.operationKey, required this.serverNow, this.treatment, this.application, this.event, this.cancelledCount = 0});
  

@override final  String operationKey;
@override final  DateTime serverNow;
@override final  MedicationTreatment? treatment;
@override final  MedicationApplication? application;
@override final  MedicationApplicationEvent? event;
@override@JsonKey() final  int cancelledCount;

/// Create a copy of MedicationCommandResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicationCommandResultCopyWith<_MedicationCommandResult> get copyWith => __$MedicationCommandResultCopyWithImpl<_MedicationCommandResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicationCommandResult&&(identical(other.operationKey, operationKey) || other.operationKey == operationKey)&&(identical(other.serverNow, serverNow) || other.serverNow == serverNow)&&(identical(other.treatment, treatment) || other.treatment == treatment)&&(identical(other.application, application) || other.application == application)&&(identical(other.event, event) || other.event == event)&&(identical(other.cancelledCount, cancelledCount) || other.cancelledCount == cancelledCount));
}


@override
int get hashCode => Object.hash(runtimeType,operationKey,serverNow,treatment,application,event,cancelledCount);

@override
String toString() {
  return 'MedicationCommandResult(operationKey: $operationKey, serverNow: $serverNow, treatment: $treatment, application: $application, event: $event, cancelledCount: $cancelledCount)';
}


}

/// @nodoc
abstract mixin class _$MedicationCommandResultCopyWith<$Res> implements $MedicationCommandResultCopyWith<$Res> {
  factory _$MedicationCommandResultCopyWith(_MedicationCommandResult value, $Res Function(_MedicationCommandResult) _then) = __$MedicationCommandResultCopyWithImpl;
@override @useResult
$Res call({
 String operationKey, DateTime serverNow, MedicationTreatment? treatment, MedicationApplication? application, MedicationApplicationEvent? event, int cancelledCount
});


@override $MedicationTreatmentCopyWith<$Res>? get treatment;@override $MedicationApplicationCopyWith<$Res>? get application;@override $MedicationApplicationEventCopyWith<$Res>? get event;

}
/// @nodoc
class __$MedicationCommandResultCopyWithImpl<$Res>
    implements _$MedicationCommandResultCopyWith<$Res> {
  __$MedicationCommandResultCopyWithImpl(this._self, this._then);

  final _MedicationCommandResult _self;
  final $Res Function(_MedicationCommandResult) _then;

/// Create a copy of MedicationCommandResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? operationKey = null,Object? serverNow = null,Object? treatment = freezed,Object? application = freezed,Object? event = freezed,Object? cancelledCount = null,}) {
  return _then(_MedicationCommandResult(
operationKey: null == operationKey ? _self.operationKey : operationKey // ignore: cast_nullable_to_non_nullable
as String,serverNow: null == serverNow ? _self.serverNow : serverNow // ignore: cast_nullable_to_non_nullable
as DateTime,treatment: freezed == treatment ? _self.treatment : treatment // ignore: cast_nullable_to_non_nullable
as MedicationTreatment?,application: freezed == application ? _self.application : application // ignore: cast_nullable_to_non_nullable
as MedicationApplication?,event: freezed == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as MedicationApplicationEvent?,cancelledCount: null == cancelledCount ? _self.cancelledCount : cancelledCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of MedicationCommandResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MedicationTreatmentCopyWith<$Res>? get treatment {
    if (_self.treatment == null) {
    return null;
  }

  return $MedicationTreatmentCopyWith<$Res>(_self.treatment!, (value) {
    return _then(_self.copyWith(treatment: value));
  });
}/// Create a copy of MedicationCommandResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MedicationApplicationCopyWith<$Res>? get application {
    if (_self.application == null) {
    return null;
  }

  return $MedicationApplicationCopyWith<$Res>(_self.application!, (value) {
    return _then(_self.copyWith(application: value));
  });
}/// Create a copy of MedicationCommandResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MedicationApplicationEventCopyWith<$Res>? get event {
    if (_self.event == null) {
    return null;
  }

  return $MedicationApplicationEventCopyWith<$Res>(_self.event!, (value) {
    return _then(_self.copyWith(event: value));
  });
}
}

// dart format on
