// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'animal_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnimalDraft {

 String? get id; String get name; AnimalSpecies? get species; AnimalSex? get sex; AnimalSize? get size; String get approximateAge; String get publicDescription; String get clinicalNotes; bool get isVaccinated; bool get isNeutered; List<ClinicalRecord> get careRecords;
/// Create a copy of AnimalDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimalDraftCopyWith<AnimalDraft> get copyWith => _$AnimalDraftCopyWithImpl<AnimalDraft>(this as AnimalDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimalDraft&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.species, species) || other.species == species)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.size, size) || other.size == size)&&(identical(other.approximateAge, approximateAge) || other.approximateAge == approximateAge)&&(identical(other.publicDescription, publicDescription) || other.publicDescription == publicDescription)&&(identical(other.clinicalNotes, clinicalNotes) || other.clinicalNotes == clinicalNotes)&&(identical(other.isVaccinated, isVaccinated) || other.isVaccinated == isVaccinated)&&(identical(other.isNeutered, isNeutered) || other.isNeutered == isNeutered)&&const DeepCollectionEquality().equals(other.careRecords, careRecords));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,species,sex,size,approximateAge,publicDescription,clinicalNotes,isVaccinated,isNeutered,const DeepCollectionEquality().hash(careRecords));

@override
String toString() {
  return 'AnimalDraft(id: $id, name: $name, species: $species, sex: $sex, size: $size, approximateAge: $approximateAge, publicDescription: $publicDescription, clinicalNotes: $clinicalNotes, isVaccinated: $isVaccinated, isNeutered: $isNeutered, careRecords: $careRecords)';
}


}

/// @nodoc
abstract mixin class $AnimalDraftCopyWith<$Res>  {
  factory $AnimalDraftCopyWith(AnimalDraft value, $Res Function(AnimalDraft) _then) = _$AnimalDraftCopyWithImpl;
@useResult
$Res call({
 String? id, String name, AnimalSpecies? species, AnimalSex? sex, AnimalSize? size, String approximateAge, String publicDescription, String clinicalNotes, bool isVaccinated, bool isNeutered, List<ClinicalRecord> careRecords
});




}
/// @nodoc
class _$AnimalDraftCopyWithImpl<$Res>
    implements $AnimalDraftCopyWith<$Res> {
  _$AnimalDraftCopyWithImpl(this._self, this._then);

  final AnimalDraft _self;
  final $Res Function(AnimalDraft) _then;

/// Create a copy of AnimalDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? species = freezed,Object? sex = freezed,Object? size = freezed,Object? approximateAge = null,Object? publicDescription = null,Object? clinicalNotes = null,Object? isVaccinated = null,Object? isNeutered = null,Object? careRecords = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,species: freezed == species ? _self.species : species // ignore: cast_nullable_to_non_nullable
as AnimalSpecies?,sex: freezed == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as AnimalSex?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as AnimalSize?,approximateAge: null == approximateAge ? _self.approximateAge : approximateAge // ignore: cast_nullable_to_non_nullable
as String,publicDescription: null == publicDescription ? _self.publicDescription : publicDescription // ignore: cast_nullable_to_non_nullable
as String,clinicalNotes: null == clinicalNotes ? _self.clinicalNotes : clinicalNotes // ignore: cast_nullable_to_non_nullable
as String,isVaccinated: null == isVaccinated ? _self.isVaccinated : isVaccinated // ignore: cast_nullable_to_non_nullable
as bool,isNeutered: null == isNeutered ? _self.isNeutered : isNeutered // ignore: cast_nullable_to_non_nullable
as bool,careRecords: null == careRecords ? _self.careRecords : careRecords // ignore: cast_nullable_to_non_nullable
as List<ClinicalRecord>,
  ));
}

}


/// Adds pattern-matching-related methods to [AnimalDraft].
extension AnimalDraftPatterns on AnimalDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnimalDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnimalDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnimalDraft value)  $default,){
final _that = this;
switch (_that) {
case _AnimalDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnimalDraft value)?  $default,){
final _that = this;
switch (_that) {
case _AnimalDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String name,  AnimalSpecies? species,  AnimalSex? sex,  AnimalSize? size,  String approximateAge,  String publicDescription,  String clinicalNotes,  bool isVaccinated,  bool isNeutered,  List<ClinicalRecord> careRecords)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnimalDraft() when $default != null:
return $default(_that.id,_that.name,_that.species,_that.sex,_that.size,_that.approximateAge,_that.publicDescription,_that.clinicalNotes,_that.isVaccinated,_that.isNeutered,_that.careRecords);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String name,  AnimalSpecies? species,  AnimalSex? sex,  AnimalSize? size,  String approximateAge,  String publicDescription,  String clinicalNotes,  bool isVaccinated,  bool isNeutered,  List<ClinicalRecord> careRecords)  $default,) {final _that = this;
switch (_that) {
case _AnimalDraft():
return $default(_that.id,_that.name,_that.species,_that.sex,_that.size,_that.approximateAge,_that.publicDescription,_that.clinicalNotes,_that.isVaccinated,_that.isNeutered,_that.careRecords);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String name,  AnimalSpecies? species,  AnimalSex? sex,  AnimalSize? size,  String approximateAge,  String publicDescription,  String clinicalNotes,  bool isVaccinated,  bool isNeutered,  List<ClinicalRecord> careRecords)?  $default,) {final _that = this;
switch (_that) {
case _AnimalDraft() when $default != null:
return $default(_that.id,_that.name,_that.species,_that.sex,_that.size,_that.approximateAge,_that.publicDescription,_that.clinicalNotes,_that.isVaccinated,_that.isNeutered,_that.careRecords);case _:
  return null;

}
}

}

/// @nodoc


class _AnimalDraft extends AnimalDraft {
  const _AnimalDraft({this.id, this.name = '', this.species, this.sex, this.size, this.approximateAge = '', this.publicDescription = '', this.clinicalNotes = '', this.isVaccinated = false, this.isNeutered = false, final  List<ClinicalRecord> careRecords = const []}): _careRecords = careRecords,super._();
  

@override final  String? id;
@override@JsonKey() final  String name;
@override final  AnimalSpecies? species;
@override final  AnimalSex? sex;
@override final  AnimalSize? size;
@override@JsonKey() final  String approximateAge;
@override@JsonKey() final  String publicDescription;
@override@JsonKey() final  String clinicalNotes;
@override@JsonKey() final  bool isVaccinated;
@override@JsonKey() final  bool isNeutered;
 final  List<ClinicalRecord> _careRecords;
@override@JsonKey() List<ClinicalRecord> get careRecords {
  if (_careRecords is EqualUnmodifiableListView) return _careRecords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_careRecords);
}


/// Create a copy of AnimalDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalDraftCopyWith<_AnimalDraft> get copyWith => __$AnimalDraftCopyWithImpl<_AnimalDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimalDraft&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.species, species) || other.species == species)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.size, size) || other.size == size)&&(identical(other.approximateAge, approximateAge) || other.approximateAge == approximateAge)&&(identical(other.publicDescription, publicDescription) || other.publicDescription == publicDescription)&&(identical(other.clinicalNotes, clinicalNotes) || other.clinicalNotes == clinicalNotes)&&(identical(other.isVaccinated, isVaccinated) || other.isVaccinated == isVaccinated)&&(identical(other.isNeutered, isNeutered) || other.isNeutered == isNeutered)&&const DeepCollectionEquality().equals(other._careRecords, _careRecords));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,species,sex,size,approximateAge,publicDescription,clinicalNotes,isVaccinated,isNeutered,const DeepCollectionEquality().hash(_careRecords));

@override
String toString() {
  return 'AnimalDraft(id: $id, name: $name, species: $species, sex: $sex, size: $size, approximateAge: $approximateAge, publicDescription: $publicDescription, clinicalNotes: $clinicalNotes, isVaccinated: $isVaccinated, isNeutered: $isNeutered, careRecords: $careRecords)';
}


}

/// @nodoc
abstract mixin class _$AnimalDraftCopyWith<$Res> implements $AnimalDraftCopyWith<$Res> {
  factory _$AnimalDraftCopyWith(_AnimalDraft value, $Res Function(_AnimalDraft) _then) = __$AnimalDraftCopyWithImpl;
@override @useResult
$Res call({
 String? id, String name, AnimalSpecies? species, AnimalSex? sex, AnimalSize? size, String approximateAge, String publicDescription, String clinicalNotes, bool isVaccinated, bool isNeutered, List<ClinicalRecord> careRecords
});




}
/// @nodoc
class __$AnimalDraftCopyWithImpl<$Res>
    implements _$AnimalDraftCopyWith<$Res> {
  __$AnimalDraftCopyWithImpl(this._self, this._then);

  final _AnimalDraft _self;
  final $Res Function(_AnimalDraft) _then;

/// Create a copy of AnimalDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? species = freezed,Object? sex = freezed,Object? size = freezed,Object? approximateAge = null,Object? publicDescription = null,Object? clinicalNotes = null,Object? isVaccinated = null,Object? isNeutered = null,Object? careRecords = null,}) {
  return _then(_AnimalDraft(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,species: freezed == species ? _self.species : species // ignore: cast_nullable_to_non_nullable
as AnimalSpecies?,sex: freezed == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as AnimalSex?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as AnimalSize?,approximateAge: null == approximateAge ? _self.approximateAge : approximateAge // ignore: cast_nullable_to_non_nullable
as String,publicDescription: null == publicDescription ? _self.publicDescription : publicDescription // ignore: cast_nullable_to_non_nullable
as String,clinicalNotes: null == clinicalNotes ? _self.clinicalNotes : clinicalNotes // ignore: cast_nullable_to_non_nullable
as String,isVaccinated: null == isVaccinated ? _self.isVaccinated : isVaccinated // ignore: cast_nullable_to_non_nullable
as bool,isNeutered: null == isNeutered ? _self.isNeutered : isNeutered // ignore: cast_nullable_to_non_nullable
as bool,careRecords: null == careRecords ? _self._careRecords : careRecords // ignore: cast_nullable_to_non_nullable
as List<ClinicalRecord>,
  ));
}


}

// dart format on
