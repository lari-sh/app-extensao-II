// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'managed_animal_search_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ManagedAnimalSearchFilter {

 String get query; String get color; AnimalSpecies? get species; AnimalSex? get sex; AnimalSize? get size; AnimalStatus? get status;
/// Create a copy of ManagedAnimalSearchFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ManagedAnimalSearchFilterCopyWith<ManagedAnimalSearchFilter> get copyWith => _$ManagedAnimalSearchFilterCopyWithImpl<ManagedAnimalSearchFilter>(this as ManagedAnimalSearchFilter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ManagedAnimalSearchFilter&&(identical(other.query, query) || other.query == query)&&(identical(other.color, color) || other.color == color)&&(identical(other.species, species) || other.species == species)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.size, size) || other.size == size)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,query,color,species,sex,size,status);

@override
String toString() {
  return 'ManagedAnimalSearchFilter(query: $query, color: $color, species: $species, sex: $sex, size: $size, status: $status)';
}


}

/// @nodoc
abstract mixin class $ManagedAnimalSearchFilterCopyWith<$Res>  {
  factory $ManagedAnimalSearchFilterCopyWith(ManagedAnimalSearchFilter value, $Res Function(ManagedAnimalSearchFilter) _then) = _$ManagedAnimalSearchFilterCopyWithImpl;
@useResult
$Res call({
 String query, String color, AnimalSpecies? species, AnimalSex? sex, AnimalSize? size, AnimalStatus? status
});




}
/// @nodoc
class _$ManagedAnimalSearchFilterCopyWithImpl<$Res>
    implements $ManagedAnimalSearchFilterCopyWith<$Res> {
  _$ManagedAnimalSearchFilterCopyWithImpl(this._self, this._then);

  final ManagedAnimalSearchFilter _self;
  final $Res Function(ManagedAnimalSearchFilter) _then;

/// Create a copy of ManagedAnimalSearchFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? color = null,Object? species = freezed,Object? sex = freezed,Object? size = freezed,Object? status = freezed,}) {
  return _then(_self.copyWith(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,species: freezed == species ? _self.species : species // ignore: cast_nullable_to_non_nullable
as AnimalSpecies?,sex: freezed == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as AnimalSex?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as AnimalSize?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AnimalStatus?,
  ));
}

}


/// Adds pattern-matching-related methods to [ManagedAnimalSearchFilter].
extension ManagedAnimalSearchFilterPatterns on ManagedAnimalSearchFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ManagedAnimalSearchFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ManagedAnimalSearchFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ManagedAnimalSearchFilter value)  $default,){
final _that = this;
switch (_that) {
case _ManagedAnimalSearchFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ManagedAnimalSearchFilter value)?  $default,){
final _that = this;
switch (_that) {
case _ManagedAnimalSearchFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query,  String color,  AnimalSpecies? species,  AnimalSex? sex,  AnimalSize? size,  AnimalStatus? status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ManagedAnimalSearchFilter() when $default != null:
return $default(_that.query,_that.color,_that.species,_that.sex,_that.size,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query,  String color,  AnimalSpecies? species,  AnimalSex? sex,  AnimalSize? size,  AnimalStatus? status)  $default,) {final _that = this;
switch (_that) {
case _ManagedAnimalSearchFilter():
return $default(_that.query,_that.color,_that.species,_that.sex,_that.size,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query,  String color,  AnimalSpecies? species,  AnimalSex? sex,  AnimalSize? size,  AnimalStatus? status)?  $default,) {final _that = this;
switch (_that) {
case _ManagedAnimalSearchFilter() when $default != null:
return $default(_that.query,_that.color,_that.species,_that.sex,_that.size,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _ManagedAnimalSearchFilter extends ManagedAnimalSearchFilter {
  const _ManagedAnimalSearchFilter({this.query = '', this.color = '', this.species, this.sex, this.size, this.status}): super._();
  

@override@JsonKey() final  String query;
@override@JsonKey() final  String color;
@override final  AnimalSpecies? species;
@override final  AnimalSex? sex;
@override final  AnimalSize? size;
@override final  AnimalStatus? status;

/// Create a copy of ManagedAnimalSearchFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ManagedAnimalSearchFilterCopyWith<_ManagedAnimalSearchFilter> get copyWith => __$ManagedAnimalSearchFilterCopyWithImpl<_ManagedAnimalSearchFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ManagedAnimalSearchFilter&&(identical(other.query, query) || other.query == query)&&(identical(other.color, color) || other.color == color)&&(identical(other.species, species) || other.species == species)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.size, size) || other.size == size)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,query,color,species,sex,size,status);

@override
String toString() {
  return 'ManagedAnimalSearchFilter(query: $query, color: $color, species: $species, sex: $sex, size: $size, status: $status)';
}


}

/// @nodoc
abstract mixin class _$ManagedAnimalSearchFilterCopyWith<$Res> implements $ManagedAnimalSearchFilterCopyWith<$Res> {
  factory _$ManagedAnimalSearchFilterCopyWith(_ManagedAnimalSearchFilter value, $Res Function(_ManagedAnimalSearchFilter) _then) = __$ManagedAnimalSearchFilterCopyWithImpl;
@override @useResult
$Res call({
 String query, String color, AnimalSpecies? species, AnimalSex? sex, AnimalSize? size, AnimalStatus? status
});




}
/// @nodoc
class __$ManagedAnimalSearchFilterCopyWithImpl<$Res>
    implements _$ManagedAnimalSearchFilterCopyWith<$Res> {
  __$ManagedAnimalSearchFilterCopyWithImpl(this._self, this._then);

  final _ManagedAnimalSearchFilter _self;
  final $Res Function(_ManagedAnimalSearchFilter) _then;

/// Create a copy of ManagedAnimalSearchFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? color = null,Object? species = freezed,Object? sex = freezed,Object? size = freezed,Object? status = freezed,}) {
  return _then(_ManagedAnimalSearchFilter(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,species: freezed == species ? _self.species : species // ignore: cast_nullable_to_non_nullable
as AnimalSpecies?,sex: freezed == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as AnimalSex?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as AnimalSize?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AnimalStatus?,
  ));
}


}

// dart format on
