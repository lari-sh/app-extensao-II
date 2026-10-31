// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'animal_query.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnimalQuery {

 String get name; AnimalSpecies? get species; AnimalSex? get sex; AnimalSize? get size;
/// Create a copy of AnimalQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimalQueryCopyWith<AnimalQuery> get copyWith => _$AnimalQueryCopyWithImpl<AnimalQuery>(this as AnimalQuery, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimalQuery&&(identical(other.name, name) || other.name == name)&&(identical(other.species, species) || other.species == species)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.size, size) || other.size == size));
}


@override
int get hashCode => Object.hash(runtimeType,name,species,sex,size);

@override
String toString() {
  return 'AnimalQuery(name: $name, species: $species, sex: $sex, size: $size)';
}


}

/// @nodoc
abstract mixin class $AnimalQueryCopyWith<$Res>  {
  factory $AnimalQueryCopyWith(AnimalQuery value, $Res Function(AnimalQuery) _then) = _$AnimalQueryCopyWithImpl;
@useResult
$Res call({
 String name, AnimalSpecies? species, AnimalSex? sex, AnimalSize? size
});




}
/// @nodoc
class _$AnimalQueryCopyWithImpl<$Res>
    implements $AnimalQueryCopyWith<$Res> {
  _$AnimalQueryCopyWithImpl(this._self, this._then);

  final AnimalQuery _self;
  final $Res Function(AnimalQuery) _then;

/// Create a copy of AnimalQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? species = freezed,Object? sex = freezed,Object? size = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,species: freezed == species ? _self.species : species // ignore: cast_nullable_to_non_nullable
as AnimalSpecies?,sex: freezed == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as AnimalSex?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as AnimalSize?,
  ));
}

}


/// Adds pattern-matching-related methods to [AnimalQuery].
extension AnimalQueryPatterns on AnimalQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnimalQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnimalQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnimalQuery value)  $default,){
final _that = this;
switch (_that) {
case _AnimalQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnimalQuery value)?  $default,){
final _that = this;
switch (_that) {
case _AnimalQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  AnimalSpecies? species,  AnimalSex? sex,  AnimalSize? size)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnimalQuery() when $default != null:
return $default(_that.name,_that.species,_that.sex,_that.size);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  AnimalSpecies? species,  AnimalSex? sex,  AnimalSize? size)  $default,) {final _that = this;
switch (_that) {
case _AnimalQuery():
return $default(_that.name,_that.species,_that.sex,_that.size);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  AnimalSpecies? species,  AnimalSex? sex,  AnimalSize? size)?  $default,) {final _that = this;
switch (_that) {
case _AnimalQuery() when $default != null:
return $default(_that.name,_that.species,_that.sex,_that.size);case _:
  return null;

}
}

}

/// @nodoc


class _AnimalQuery implements AnimalQuery {
  const _AnimalQuery({this.name = '', this.species, this.sex, this.size});
  

@override@JsonKey() final  String name;
@override final  AnimalSpecies? species;
@override final  AnimalSex? sex;
@override final  AnimalSize? size;

/// Create a copy of AnimalQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalQueryCopyWith<_AnimalQuery> get copyWith => __$AnimalQueryCopyWithImpl<_AnimalQuery>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimalQuery&&(identical(other.name, name) || other.name == name)&&(identical(other.species, species) || other.species == species)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.size, size) || other.size == size));
}


@override
int get hashCode => Object.hash(runtimeType,name,species,sex,size);

@override
String toString() {
  return 'AnimalQuery(name: $name, species: $species, sex: $sex, size: $size)';
}


}

/// @nodoc
abstract mixin class _$AnimalQueryCopyWith<$Res> implements $AnimalQueryCopyWith<$Res> {
  factory _$AnimalQueryCopyWith(_AnimalQuery value, $Res Function(_AnimalQuery) _then) = __$AnimalQueryCopyWithImpl;
@override @useResult
$Res call({
 String name, AnimalSpecies? species, AnimalSex? sex, AnimalSize? size
});




}
/// @nodoc
class __$AnimalQueryCopyWithImpl<$Res>
    implements _$AnimalQueryCopyWith<$Res> {
  __$AnimalQueryCopyWithImpl(this._self, this._then);

  final _AnimalQuery _self;
  final $Res Function(_AnimalQuery) _then;

/// Create a copy of AnimalQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? species = freezed,Object? sex = freezed,Object? size = freezed,}) {
  return _then(_AnimalQuery(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,species: freezed == species ? _self.species : species // ignore: cast_nullable_to_non_nullable
as AnimalSpecies?,sex: freezed == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as AnimalSex?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as AnimalSize?,
  ));
}


}

// dart format on
