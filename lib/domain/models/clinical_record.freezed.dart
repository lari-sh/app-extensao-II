// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clinical_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClinicalRecord {

 String? get id; ClinicalRecordKind get kind; String get description;
/// Create a copy of ClinicalRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClinicalRecordCopyWith<ClinicalRecord> get copyWith => _$ClinicalRecordCopyWithImpl<ClinicalRecord>(this as ClinicalRecord, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClinicalRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.description, description) || other.description == description));
}


@override
int get hashCode => Object.hash(runtimeType,id,kind,description);

@override
String toString() {
  return 'ClinicalRecord(id: $id, kind: $kind, description: $description)';
}


}

/// @nodoc
abstract mixin class $ClinicalRecordCopyWith<$Res>  {
  factory $ClinicalRecordCopyWith(ClinicalRecord value, $Res Function(ClinicalRecord) _then) = _$ClinicalRecordCopyWithImpl;
@useResult
$Res call({
 String? id, ClinicalRecordKind kind, String description
});




}
/// @nodoc
class _$ClinicalRecordCopyWithImpl<$Res>
    implements $ClinicalRecordCopyWith<$Res> {
  _$ClinicalRecordCopyWithImpl(this._self, this._then);

  final ClinicalRecord _self;
  final $Res Function(ClinicalRecord) _then;

/// Create a copy of ClinicalRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? kind = null,Object? description = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ClinicalRecordKind,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ClinicalRecord].
extension ClinicalRecordPatterns on ClinicalRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClinicalRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClinicalRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClinicalRecord value)  $default,){
final _that = this;
switch (_that) {
case _ClinicalRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClinicalRecord value)?  $default,){
final _that = this;
switch (_that) {
case _ClinicalRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  ClinicalRecordKind kind,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClinicalRecord() when $default != null:
return $default(_that.id,_that.kind,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  ClinicalRecordKind kind,  String description)  $default,) {final _that = this;
switch (_that) {
case _ClinicalRecord():
return $default(_that.id,_that.kind,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  ClinicalRecordKind kind,  String description)?  $default,) {final _that = this;
switch (_that) {
case _ClinicalRecord() when $default != null:
return $default(_that.id,_that.kind,_that.description);case _:
  return null;

}
}

}

/// @nodoc


class _ClinicalRecord implements ClinicalRecord {
  const _ClinicalRecord({this.id, required this.kind, required this.description});
  

@override final  String? id;
@override final  ClinicalRecordKind kind;
@override final  String description;

/// Create a copy of ClinicalRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClinicalRecordCopyWith<_ClinicalRecord> get copyWith => __$ClinicalRecordCopyWithImpl<_ClinicalRecord>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClinicalRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.description, description) || other.description == description));
}


@override
int get hashCode => Object.hash(runtimeType,id,kind,description);

@override
String toString() {
  return 'ClinicalRecord(id: $id, kind: $kind, description: $description)';
}


}

/// @nodoc
abstract mixin class _$ClinicalRecordCopyWith<$Res> implements $ClinicalRecordCopyWith<$Res> {
  factory _$ClinicalRecordCopyWith(_ClinicalRecord value, $Res Function(_ClinicalRecord) _then) = __$ClinicalRecordCopyWithImpl;
@override @useResult
$Res call({
 String? id, ClinicalRecordKind kind, String description
});




}
/// @nodoc
class __$ClinicalRecordCopyWithImpl<$Res>
    implements _$ClinicalRecordCopyWith<$Res> {
  __$ClinicalRecordCopyWithImpl(this._self, this._then);

  final _ClinicalRecord _self;
  final $Res Function(_ClinicalRecord) _then;

/// Create a copy of ClinicalRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? kind = null,Object? description = null,}) {
  return _then(_ClinicalRecord(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ClinicalRecordKind,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
