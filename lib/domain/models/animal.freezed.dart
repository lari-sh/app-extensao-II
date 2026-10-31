// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'animal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PublicAnimal {

 String get id; String get name; AnimalSpecies get species; AnimalSex get sex; AnimalSize get size; String get approximateAge; String get publicDescription; AnimalStatus get status; bool get isPublished; bool get isVaccinated; bool get isNeutered; String? get primaryPhotoId;
/// Create a copy of PublicAnimal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicAnimalCopyWith<PublicAnimal> get copyWith => _$PublicAnimalCopyWithImpl<PublicAnimal>(this as PublicAnimal, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicAnimal&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.species, species) || other.species == species)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.size, size) || other.size == size)&&(identical(other.approximateAge, approximateAge) || other.approximateAge == approximateAge)&&(identical(other.publicDescription, publicDescription) || other.publicDescription == publicDescription)&&(identical(other.status, status) || other.status == status)&&(identical(other.isPublished, isPublished) || other.isPublished == isPublished)&&(identical(other.isVaccinated, isVaccinated) || other.isVaccinated == isVaccinated)&&(identical(other.isNeutered, isNeutered) || other.isNeutered == isNeutered)&&(identical(other.primaryPhotoId, primaryPhotoId) || other.primaryPhotoId == primaryPhotoId));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,species,sex,size,approximateAge,publicDescription,status,isPublished,isVaccinated,isNeutered,primaryPhotoId);

@override
String toString() {
  return 'PublicAnimal(id: $id, name: $name, species: $species, sex: $sex, size: $size, approximateAge: $approximateAge, publicDescription: $publicDescription, status: $status, isPublished: $isPublished, isVaccinated: $isVaccinated, isNeutered: $isNeutered, primaryPhotoId: $primaryPhotoId)';
}


}

/// @nodoc
abstract mixin class $PublicAnimalCopyWith<$Res>  {
  factory $PublicAnimalCopyWith(PublicAnimal value, $Res Function(PublicAnimal) _then) = _$PublicAnimalCopyWithImpl;
@useResult
$Res call({
 String id, String name, AnimalSpecies species, AnimalSex sex, AnimalSize size, String approximateAge, String publicDescription, AnimalStatus status, bool isPublished, bool isVaccinated, bool isNeutered, String? primaryPhotoId
});




}
/// @nodoc
class _$PublicAnimalCopyWithImpl<$Res>
    implements $PublicAnimalCopyWith<$Res> {
  _$PublicAnimalCopyWithImpl(this._self, this._then);

  final PublicAnimal _self;
  final $Res Function(PublicAnimal) _then;

/// Create a copy of PublicAnimal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? species = null,Object? sex = null,Object? size = null,Object? approximateAge = null,Object? publicDescription = null,Object? status = null,Object? isPublished = null,Object? isVaccinated = null,Object? isNeutered = null,Object? primaryPhotoId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,species: null == species ? _self.species : species // ignore: cast_nullable_to_non_nullable
as AnimalSpecies,sex: null == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as AnimalSex,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as AnimalSize,approximateAge: null == approximateAge ? _self.approximateAge : approximateAge // ignore: cast_nullable_to_non_nullable
as String,publicDescription: null == publicDescription ? _self.publicDescription : publicDescription // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AnimalStatus,isPublished: null == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool,isVaccinated: null == isVaccinated ? _self.isVaccinated : isVaccinated // ignore: cast_nullable_to_non_nullable
as bool,isNeutered: null == isNeutered ? _self.isNeutered : isNeutered // ignore: cast_nullable_to_non_nullable
as bool,primaryPhotoId: freezed == primaryPhotoId ? _self.primaryPhotoId : primaryPhotoId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PublicAnimal].
extension PublicAnimalPatterns on PublicAnimal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicAnimal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicAnimal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicAnimal value)  $default,){
final _that = this;
switch (_that) {
case _PublicAnimal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicAnimal value)?  $default,){
final _that = this;
switch (_that) {
case _PublicAnimal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  AnimalSpecies species,  AnimalSex sex,  AnimalSize size,  String approximateAge,  String publicDescription,  AnimalStatus status,  bool isPublished,  bool isVaccinated,  bool isNeutered,  String? primaryPhotoId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicAnimal() when $default != null:
return $default(_that.id,_that.name,_that.species,_that.sex,_that.size,_that.approximateAge,_that.publicDescription,_that.status,_that.isPublished,_that.isVaccinated,_that.isNeutered,_that.primaryPhotoId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  AnimalSpecies species,  AnimalSex sex,  AnimalSize size,  String approximateAge,  String publicDescription,  AnimalStatus status,  bool isPublished,  bool isVaccinated,  bool isNeutered,  String? primaryPhotoId)  $default,) {final _that = this;
switch (_that) {
case _PublicAnimal():
return $default(_that.id,_that.name,_that.species,_that.sex,_that.size,_that.approximateAge,_that.publicDescription,_that.status,_that.isPublished,_that.isVaccinated,_that.isNeutered,_that.primaryPhotoId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  AnimalSpecies species,  AnimalSex sex,  AnimalSize size,  String approximateAge,  String publicDescription,  AnimalStatus status,  bool isPublished,  bool isVaccinated,  bool isNeutered,  String? primaryPhotoId)?  $default,) {final _that = this;
switch (_that) {
case _PublicAnimal() when $default != null:
return $default(_that.id,_that.name,_that.species,_that.sex,_that.size,_that.approximateAge,_that.publicDescription,_that.status,_that.isPublished,_that.isVaccinated,_that.isNeutered,_that.primaryPhotoId);case _:
  return null;

}
}

}

/// @nodoc


class _PublicAnimal implements PublicAnimal {
  const _PublicAnimal({required this.id, required this.name, required this.species, required this.sex, required this.size, required this.approximateAge, this.publicDescription = '', this.status = AnimalStatus.available, this.isPublished = false, this.isVaccinated = false, this.isNeutered = false, this.primaryPhotoId});
  

@override final  String id;
@override final  String name;
@override final  AnimalSpecies species;
@override final  AnimalSex sex;
@override final  AnimalSize size;
@override final  String approximateAge;
@override@JsonKey() final  String publicDescription;
@override@JsonKey() final  AnimalStatus status;
@override@JsonKey() final  bool isPublished;
@override@JsonKey() final  bool isVaccinated;
@override@JsonKey() final  bool isNeutered;
@override final  String? primaryPhotoId;

/// Create a copy of PublicAnimal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicAnimalCopyWith<_PublicAnimal> get copyWith => __$PublicAnimalCopyWithImpl<_PublicAnimal>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicAnimal&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.species, species) || other.species == species)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.size, size) || other.size == size)&&(identical(other.approximateAge, approximateAge) || other.approximateAge == approximateAge)&&(identical(other.publicDescription, publicDescription) || other.publicDescription == publicDescription)&&(identical(other.status, status) || other.status == status)&&(identical(other.isPublished, isPublished) || other.isPublished == isPublished)&&(identical(other.isVaccinated, isVaccinated) || other.isVaccinated == isVaccinated)&&(identical(other.isNeutered, isNeutered) || other.isNeutered == isNeutered)&&(identical(other.primaryPhotoId, primaryPhotoId) || other.primaryPhotoId == primaryPhotoId));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,species,sex,size,approximateAge,publicDescription,status,isPublished,isVaccinated,isNeutered,primaryPhotoId);

@override
String toString() {
  return 'PublicAnimal(id: $id, name: $name, species: $species, sex: $sex, size: $size, approximateAge: $approximateAge, publicDescription: $publicDescription, status: $status, isPublished: $isPublished, isVaccinated: $isVaccinated, isNeutered: $isNeutered, primaryPhotoId: $primaryPhotoId)';
}


}

/// @nodoc
abstract mixin class _$PublicAnimalCopyWith<$Res> implements $PublicAnimalCopyWith<$Res> {
  factory _$PublicAnimalCopyWith(_PublicAnimal value, $Res Function(_PublicAnimal) _then) = __$PublicAnimalCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, AnimalSpecies species, AnimalSex sex, AnimalSize size, String approximateAge, String publicDescription, AnimalStatus status, bool isPublished, bool isVaccinated, bool isNeutered, String? primaryPhotoId
});




}
/// @nodoc
class __$PublicAnimalCopyWithImpl<$Res>
    implements _$PublicAnimalCopyWith<$Res> {
  __$PublicAnimalCopyWithImpl(this._self, this._then);

  final _PublicAnimal _self;
  final $Res Function(_PublicAnimal) _then;

/// Create a copy of PublicAnimal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? species = null,Object? sex = null,Object? size = null,Object? approximateAge = null,Object? publicDescription = null,Object? status = null,Object? isPublished = null,Object? isVaccinated = null,Object? isNeutered = null,Object? primaryPhotoId = freezed,}) {
  return _then(_PublicAnimal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,species: null == species ? _self.species : species // ignore: cast_nullable_to_non_nullable
as AnimalSpecies,sex: null == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as AnimalSex,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as AnimalSize,approximateAge: null == approximateAge ? _self.approximateAge : approximateAge // ignore: cast_nullable_to_non_nullable
as String,publicDescription: null == publicDescription ? _self.publicDescription : publicDescription // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AnimalStatus,isPublished: null == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool,isVaccinated: null == isVaccinated ? _self.isVaccinated : isVaccinated // ignore: cast_nullable_to_non_nullable
as bool,isNeutered: null == isNeutered ? _self.isNeutered : isNeutered // ignore: cast_nullable_to_non_nullable
as bool,primaryPhotoId: freezed == primaryPhotoId ? _self.primaryPhotoId : primaryPhotoId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$ManagedAnimal {

 PublicAnimal get animal; String get clinicalNotes; List<ClinicalRecord> get careRecords;
/// Create a copy of ManagedAnimal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ManagedAnimalCopyWith<ManagedAnimal> get copyWith => _$ManagedAnimalCopyWithImpl<ManagedAnimal>(this as ManagedAnimal, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ManagedAnimal&&(identical(other.animal, animal) || other.animal == animal)&&(identical(other.clinicalNotes, clinicalNotes) || other.clinicalNotes == clinicalNotes)&&const DeepCollectionEquality().equals(other.careRecords, careRecords));
}


@override
int get hashCode => Object.hash(runtimeType,animal,clinicalNotes,const DeepCollectionEquality().hash(careRecords));

@override
String toString() {
  return 'ManagedAnimal(animal: $animal, clinicalNotes: $clinicalNotes, careRecords: $careRecords)';
}


}

/// @nodoc
abstract mixin class $ManagedAnimalCopyWith<$Res>  {
  factory $ManagedAnimalCopyWith(ManagedAnimal value, $Res Function(ManagedAnimal) _then) = _$ManagedAnimalCopyWithImpl;
@useResult
$Res call({
 PublicAnimal animal, String clinicalNotes, List<ClinicalRecord> careRecords
});


$PublicAnimalCopyWith<$Res> get animal;

}
/// @nodoc
class _$ManagedAnimalCopyWithImpl<$Res>
    implements $ManagedAnimalCopyWith<$Res> {
  _$ManagedAnimalCopyWithImpl(this._self, this._then);

  final ManagedAnimal _self;
  final $Res Function(ManagedAnimal) _then;

/// Create a copy of ManagedAnimal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? animal = null,Object? clinicalNotes = null,Object? careRecords = null,}) {
  return _then(_self.copyWith(
animal: null == animal ? _self.animal : animal // ignore: cast_nullable_to_non_nullable
as PublicAnimal,clinicalNotes: null == clinicalNotes ? _self.clinicalNotes : clinicalNotes // ignore: cast_nullable_to_non_nullable
as String,careRecords: null == careRecords ? _self.careRecords : careRecords // ignore: cast_nullable_to_non_nullable
as List<ClinicalRecord>,
  ));
}
/// Create a copy of ManagedAnimal
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PublicAnimalCopyWith<$Res> get animal {
  
  return $PublicAnimalCopyWith<$Res>(_self.animal, (value) {
    return _then(_self.copyWith(animal: value));
  });
}
}


/// Adds pattern-matching-related methods to [ManagedAnimal].
extension ManagedAnimalPatterns on ManagedAnimal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ManagedAnimal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ManagedAnimal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ManagedAnimal value)  $default,){
final _that = this;
switch (_that) {
case _ManagedAnimal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ManagedAnimal value)?  $default,){
final _that = this;
switch (_that) {
case _ManagedAnimal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PublicAnimal animal,  String clinicalNotes,  List<ClinicalRecord> careRecords)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ManagedAnimal() when $default != null:
return $default(_that.animal,_that.clinicalNotes,_that.careRecords);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PublicAnimal animal,  String clinicalNotes,  List<ClinicalRecord> careRecords)  $default,) {final _that = this;
switch (_that) {
case _ManagedAnimal():
return $default(_that.animal,_that.clinicalNotes,_that.careRecords);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PublicAnimal animal,  String clinicalNotes,  List<ClinicalRecord> careRecords)?  $default,) {final _that = this;
switch (_that) {
case _ManagedAnimal() when $default != null:
return $default(_that.animal,_that.clinicalNotes,_that.careRecords);case _:
  return null;

}
}

}

/// @nodoc


class _ManagedAnimal implements ManagedAnimal {
  const _ManagedAnimal({required this.animal, this.clinicalNotes = '', final  List<ClinicalRecord> careRecords = const []}): _careRecords = careRecords;
  

@override final  PublicAnimal animal;
@override@JsonKey() final  String clinicalNotes;
 final  List<ClinicalRecord> _careRecords;
@override@JsonKey() List<ClinicalRecord> get careRecords {
  if (_careRecords is EqualUnmodifiableListView) return _careRecords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_careRecords);
}


/// Create a copy of ManagedAnimal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ManagedAnimalCopyWith<_ManagedAnimal> get copyWith => __$ManagedAnimalCopyWithImpl<_ManagedAnimal>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ManagedAnimal&&(identical(other.animal, animal) || other.animal == animal)&&(identical(other.clinicalNotes, clinicalNotes) || other.clinicalNotes == clinicalNotes)&&const DeepCollectionEquality().equals(other._careRecords, _careRecords));
}


@override
int get hashCode => Object.hash(runtimeType,animal,clinicalNotes,const DeepCollectionEquality().hash(_careRecords));

@override
String toString() {
  return 'ManagedAnimal(animal: $animal, clinicalNotes: $clinicalNotes, careRecords: $careRecords)';
}


}

/// @nodoc
abstract mixin class _$ManagedAnimalCopyWith<$Res> implements $ManagedAnimalCopyWith<$Res> {
  factory _$ManagedAnimalCopyWith(_ManagedAnimal value, $Res Function(_ManagedAnimal) _then) = __$ManagedAnimalCopyWithImpl;
@override @useResult
$Res call({
 PublicAnimal animal, String clinicalNotes, List<ClinicalRecord> careRecords
});


@override $PublicAnimalCopyWith<$Res> get animal;

}
/// @nodoc
class __$ManagedAnimalCopyWithImpl<$Res>
    implements _$ManagedAnimalCopyWith<$Res> {
  __$ManagedAnimalCopyWithImpl(this._self, this._then);

  final _ManagedAnimal _self;
  final $Res Function(_ManagedAnimal) _then;

/// Create a copy of ManagedAnimal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? animal = null,Object? clinicalNotes = null,Object? careRecords = null,}) {
  return _then(_ManagedAnimal(
animal: null == animal ? _self.animal : animal // ignore: cast_nullable_to_non_nullable
as PublicAnimal,clinicalNotes: null == clinicalNotes ? _self.clinicalNotes : clinicalNotes // ignore: cast_nullable_to_non_nullable
as String,careRecords: null == careRecords ? _self._careRecords : careRecords // ignore: cast_nullable_to_non_nullable
as List<ClinicalRecord>,
  ));
}

/// Create a copy of ManagedAnimal
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PublicAnimalCopyWith<$Res> get animal {
  
  return $PublicAnimalCopyWith<$Res>(_self.animal, (value) {
    return _then(_self.copyWith(animal: value));
  });
}
}

/// @nodoc
mixin _$AnimalPage {

 List<PublicAnimal> get items; int get total; String? get cursor;
/// Create a copy of AnimalPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimalPageCopyWith<AnimalPage> get copyWith => _$AnimalPageCopyWithImpl<AnimalPage>(this as AnimalPage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimalPage&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.total, total) || other.total == total)&&(identical(other.cursor, cursor) || other.cursor == cursor));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),total,cursor);

@override
String toString() {
  return 'AnimalPage(items: $items, total: $total, cursor: $cursor)';
}


}

/// @nodoc
abstract mixin class $AnimalPageCopyWith<$Res>  {
  factory $AnimalPageCopyWith(AnimalPage value, $Res Function(AnimalPage) _then) = _$AnimalPageCopyWithImpl;
@useResult
$Res call({
 List<PublicAnimal> items, int total, String? cursor
});




}
/// @nodoc
class _$AnimalPageCopyWithImpl<$Res>
    implements $AnimalPageCopyWith<$Res> {
  _$AnimalPageCopyWithImpl(this._self, this._then);

  final AnimalPage _self;
  final $Res Function(AnimalPage) _then;

/// Create a copy of AnimalPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? total = null,Object? cursor = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<PublicAnimal>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AnimalPage].
extension AnimalPagePatterns on AnimalPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnimalPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnimalPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnimalPage value)  $default,){
final _that = this;
switch (_that) {
case _AnimalPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnimalPage value)?  $default,){
final _that = this;
switch (_that) {
case _AnimalPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PublicAnimal> items,  int total,  String? cursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnimalPage() when $default != null:
return $default(_that.items,_that.total,_that.cursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PublicAnimal> items,  int total,  String? cursor)  $default,) {final _that = this;
switch (_that) {
case _AnimalPage():
return $default(_that.items,_that.total,_that.cursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PublicAnimal> items,  int total,  String? cursor)?  $default,) {final _that = this;
switch (_that) {
case _AnimalPage() when $default != null:
return $default(_that.items,_that.total,_that.cursor);case _:
  return null;

}
}

}

/// @nodoc


class _AnimalPage implements AnimalPage {
  const _AnimalPage({required final  List<PublicAnimal> items, required this.total, this.cursor}): _items = items;
  

 final  List<PublicAnimal> _items;
@override List<PublicAnimal> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int total;
@override final  String? cursor;

/// Create a copy of AnimalPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalPageCopyWith<_AnimalPage> get copyWith => __$AnimalPageCopyWithImpl<_AnimalPage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimalPage&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.total, total) || other.total == total)&&(identical(other.cursor, cursor) || other.cursor == cursor));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),total,cursor);

@override
String toString() {
  return 'AnimalPage(items: $items, total: $total, cursor: $cursor)';
}


}

/// @nodoc
abstract mixin class _$AnimalPageCopyWith<$Res> implements $AnimalPageCopyWith<$Res> {
  factory _$AnimalPageCopyWith(_AnimalPage value, $Res Function(_AnimalPage) _then) = __$AnimalPageCopyWithImpl;
@override @useResult
$Res call({
 List<PublicAnimal> items, int total, String? cursor
});




}
/// @nodoc
class __$AnimalPageCopyWithImpl<$Res>
    implements _$AnimalPageCopyWith<$Res> {
  __$AnimalPageCopyWithImpl(this._self, this._then);

  final _AnimalPage _self;
  final $Res Function(_AnimalPage) _then;

/// Create a copy of AnimalPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? total = null,Object? cursor = freezed,}) {
  return _then(_AnimalPage(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<PublicAnimal>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$ManagedAnimalPage {

 List<ManagedAnimal> get items; int get total; String? get cursor;
/// Create a copy of ManagedAnimalPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ManagedAnimalPageCopyWith<ManagedAnimalPage> get copyWith => _$ManagedAnimalPageCopyWithImpl<ManagedAnimalPage>(this as ManagedAnimalPage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ManagedAnimalPage&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.total, total) || other.total == total)&&(identical(other.cursor, cursor) || other.cursor == cursor));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),total,cursor);

@override
String toString() {
  return 'ManagedAnimalPage(items: $items, total: $total, cursor: $cursor)';
}


}

/// @nodoc
abstract mixin class $ManagedAnimalPageCopyWith<$Res>  {
  factory $ManagedAnimalPageCopyWith(ManagedAnimalPage value, $Res Function(ManagedAnimalPage) _then) = _$ManagedAnimalPageCopyWithImpl;
@useResult
$Res call({
 List<ManagedAnimal> items, int total, String? cursor
});




}
/// @nodoc
class _$ManagedAnimalPageCopyWithImpl<$Res>
    implements $ManagedAnimalPageCopyWith<$Res> {
  _$ManagedAnimalPageCopyWithImpl(this._self, this._then);

  final ManagedAnimalPage _self;
  final $Res Function(ManagedAnimalPage) _then;

/// Create a copy of ManagedAnimalPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? total = null,Object? cursor = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ManagedAnimal>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ManagedAnimalPage].
extension ManagedAnimalPagePatterns on ManagedAnimalPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ManagedAnimalPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ManagedAnimalPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ManagedAnimalPage value)  $default,){
final _that = this;
switch (_that) {
case _ManagedAnimalPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ManagedAnimalPage value)?  $default,){
final _that = this;
switch (_that) {
case _ManagedAnimalPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ManagedAnimal> items,  int total,  String? cursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ManagedAnimalPage() when $default != null:
return $default(_that.items,_that.total,_that.cursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ManagedAnimal> items,  int total,  String? cursor)  $default,) {final _that = this;
switch (_that) {
case _ManagedAnimalPage():
return $default(_that.items,_that.total,_that.cursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ManagedAnimal> items,  int total,  String? cursor)?  $default,) {final _that = this;
switch (_that) {
case _ManagedAnimalPage() when $default != null:
return $default(_that.items,_that.total,_that.cursor);case _:
  return null;

}
}

}

/// @nodoc


class _ManagedAnimalPage implements ManagedAnimalPage {
  const _ManagedAnimalPage({required final  List<ManagedAnimal> items, required this.total, this.cursor}): _items = items;
  

 final  List<ManagedAnimal> _items;
@override List<ManagedAnimal> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int total;
@override final  String? cursor;

/// Create a copy of ManagedAnimalPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ManagedAnimalPageCopyWith<_ManagedAnimalPage> get copyWith => __$ManagedAnimalPageCopyWithImpl<_ManagedAnimalPage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ManagedAnimalPage&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.total, total) || other.total == total)&&(identical(other.cursor, cursor) || other.cursor == cursor));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),total,cursor);

@override
String toString() {
  return 'ManagedAnimalPage(items: $items, total: $total, cursor: $cursor)';
}


}

/// @nodoc
abstract mixin class _$ManagedAnimalPageCopyWith<$Res> implements $ManagedAnimalPageCopyWith<$Res> {
  factory _$ManagedAnimalPageCopyWith(_ManagedAnimalPage value, $Res Function(_ManagedAnimalPage) _then) = __$ManagedAnimalPageCopyWithImpl;
@override @useResult
$Res call({
 List<ManagedAnimal> items, int total, String? cursor
});




}
/// @nodoc
class __$ManagedAnimalPageCopyWithImpl<$Res>
    implements _$ManagedAnimalPageCopyWith<$Res> {
  __$ManagedAnimalPageCopyWithImpl(this._self, this._then);

  final _ManagedAnimalPage _self;
  final $Res Function(_ManagedAnimalPage) _then;

/// Create a copy of ManagedAnimalPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? total = null,Object? cursor = freezed,}) {
  return _then(_ManagedAnimalPage(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ManagedAnimal>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
