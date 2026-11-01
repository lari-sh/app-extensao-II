// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'animal_detail_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnimalDetailState implements DiagnosticableTreeMixin {

 String get title; String get description; String get characteristics; String get statusLabel; bool get busy; bool get copying; bool get canAdopt; bool get hasAnimal; List<String> get tags; Map<String, String> get publicInformation; List<int>? get photo; String? get message;
/// Create a copy of AnimalDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimalDetailStateCopyWith<AnimalDetailState> get copyWith => _$AnimalDetailStateCopyWithImpl<AnimalDetailState>(this as AnimalDetailState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AnimalDetailState'))
    ..add(DiagnosticsProperty('title', title))..add(DiagnosticsProperty('description', description))..add(DiagnosticsProperty('characteristics', characteristics))..add(DiagnosticsProperty('statusLabel', statusLabel))..add(DiagnosticsProperty('busy', busy))..add(DiagnosticsProperty('copying', copying))..add(DiagnosticsProperty('canAdopt', canAdopt))..add(DiagnosticsProperty('hasAnimal', hasAnimal))..add(DiagnosticsProperty('tags', tags))..add(DiagnosticsProperty('publicInformation', publicInformation))..add(DiagnosticsProperty('photo', photo))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimalDetailState&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.characteristics, characteristics) || other.characteristics == characteristics)&&(identical(other.statusLabel, statusLabel) || other.statusLabel == statusLabel)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.copying, copying) || other.copying == copying)&&(identical(other.canAdopt, canAdopt) || other.canAdopt == canAdopt)&&(identical(other.hasAnimal, hasAnimal) || other.hasAnimal == hasAnimal)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.publicInformation, publicInformation)&&const DeepCollectionEquality().equals(other.photo, photo)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,title,description,characteristics,statusLabel,busy,copying,canAdopt,hasAnimal,const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(publicInformation),const DeepCollectionEquality().hash(photo),message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AnimalDetailState(title: $title, description: $description, characteristics: $characteristics, statusLabel: $statusLabel, busy: $busy, copying: $copying, canAdopt: $canAdopt, hasAnimal: $hasAnimal, tags: $tags, publicInformation: $publicInformation, photo: $photo, message: $message)';
}


}

/// @nodoc
abstract mixin class $AnimalDetailStateCopyWith<$Res>  {
  factory $AnimalDetailStateCopyWith(AnimalDetailState value, $Res Function(AnimalDetailState) _then) = _$AnimalDetailStateCopyWithImpl;
@useResult
$Res call({
 String title, String description, String characteristics, String statusLabel, bool busy, bool copying, bool canAdopt, bool hasAnimal, List<String> tags, Map<String, String> publicInformation, List<int>? photo, String? message
});




}
/// @nodoc
class _$AnimalDetailStateCopyWithImpl<$Res>
    implements $AnimalDetailStateCopyWith<$Res> {
  _$AnimalDetailStateCopyWithImpl(this._self, this._then);

  final AnimalDetailState _self;
  final $Res Function(AnimalDetailState) _then;

/// Create a copy of AnimalDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? description = null,Object? characteristics = null,Object? statusLabel = null,Object? busy = null,Object? copying = null,Object? canAdopt = null,Object? hasAnimal = null,Object? tags = null,Object? publicInformation = null,Object? photo = freezed,Object? message = freezed,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,characteristics: null == characteristics ? _self.characteristics : characteristics // ignore: cast_nullable_to_non_nullable
as String,statusLabel: null == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,copying: null == copying ? _self.copying : copying // ignore: cast_nullable_to_non_nullable
as bool,canAdopt: null == canAdopt ? _self.canAdopt : canAdopt // ignore: cast_nullable_to_non_nullable
as bool,hasAnimal: null == hasAnimal ? _self.hasAnimal : hasAnimal // ignore: cast_nullable_to_non_nullable
as bool,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,publicInformation: null == publicInformation ? _self.publicInformation : publicInformation // ignore: cast_nullable_to_non_nullable
as Map<String, String>,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as List<int>?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AnimalDetailState].
extension AnimalDetailStatePatterns on AnimalDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnimalDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnimalDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnimalDetailState value)  $default,){
final _that = this;
switch (_that) {
case _AnimalDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnimalDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _AnimalDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String description,  String characteristics,  String statusLabel,  bool busy,  bool copying,  bool canAdopt,  bool hasAnimal,  List<String> tags,  Map<String, String> publicInformation,  List<int>? photo,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnimalDetailState() when $default != null:
return $default(_that.title,_that.description,_that.characteristics,_that.statusLabel,_that.busy,_that.copying,_that.canAdopt,_that.hasAnimal,_that.tags,_that.publicInformation,_that.photo,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String description,  String characteristics,  String statusLabel,  bool busy,  bool copying,  bool canAdopt,  bool hasAnimal,  List<String> tags,  Map<String, String> publicInformation,  List<int>? photo,  String? message)  $default,) {final _that = this;
switch (_that) {
case _AnimalDetailState():
return $default(_that.title,_that.description,_that.characteristics,_that.statusLabel,_that.busy,_that.copying,_that.canAdopt,_that.hasAnimal,_that.tags,_that.publicInformation,_that.photo,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String description,  String characteristics,  String statusLabel,  bool busy,  bool copying,  bool canAdopt,  bool hasAnimal,  List<String> tags,  Map<String, String> publicInformation,  List<int>? photo,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _AnimalDetailState() when $default != null:
return $default(_that.title,_that.description,_that.characteristics,_that.statusLabel,_that.busy,_that.copying,_that.canAdopt,_that.hasAnimal,_that.tags,_that.publicInformation,_that.photo,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _AnimalDetailState with DiagnosticableTreeMixin implements AnimalDetailState {
  const _AnimalDetailState({this.title = 'Detalhes do animal', this.description = '', this.characteristics = '', this.statusLabel = '', this.busy = false, this.copying = false, this.canAdopt = false, this.hasAnimal = false, final  List<String> tags = const [], final  Map<String, String> publicInformation = const {}, final  List<int>? photo, this.message}): _tags = tags,_publicInformation = publicInformation,_photo = photo;
  

@override@JsonKey() final  String title;
@override@JsonKey() final  String description;
@override@JsonKey() final  String characteristics;
@override@JsonKey() final  String statusLabel;
@override@JsonKey() final  bool busy;
@override@JsonKey() final  bool copying;
@override@JsonKey() final  bool canAdopt;
@override@JsonKey() final  bool hasAnimal;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

 final  Map<String, String> _publicInformation;
@override@JsonKey() Map<String, String> get publicInformation {
  if (_publicInformation is EqualUnmodifiableMapView) return _publicInformation;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_publicInformation);
}

 final  List<int>? _photo;
@override List<int>? get photo {
  final value = _photo;
  if (value == null) return null;
  if (_photo is EqualUnmodifiableListView) return _photo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? message;

/// Create a copy of AnimalDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalDetailStateCopyWith<_AnimalDetailState> get copyWith => __$AnimalDetailStateCopyWithImpl<_AnimalDetailState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AnimalDetailState'))
    ..add(DiagnosticsProperty('title', title))..add(DiagnosticsProperty('description', description))..add(DiagnosticsProperty('characteristics', characteristics))..add(DiagnosticsProperty('statusLabel', statusLabel))..add(DiagnosticsProperty('busy', busy))..add(DiagnosticsProperty('copying', copying))..add(DiagnosticsProperty('canAdopt', canAdopt))..add(DiagnosticsProperty('hasAnimal', hasAnimal))..add(DiagnosticsProperty('tags', tags))..add(DiagnosticsProperty('publicInformation', publicInformation))..add(DiagnosticsProperty('photo', photo))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimalDetailState&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.characteristics, characteristics) || other.characteristics == characteristics)&&(identical(other.statusLabel, statusLabel) || other.statusLabel == statusLabel)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.copying, copying) || other.copying == copying)&&(identical(other.canAdopt, canAdopt) || other.canAdopt == canAdopt)&&(identical(other.hasAnimal, hasAnimal) || other.hasAnimal == hasAnimal)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._publicInformation, _publicInformation)&&const DeepCollectionEquality().equals(other._photo, _photo)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,title,description,characteristics,statusLabel,busy,copying,canAdopt,hasAnimal,const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_publicInformation),const DeepCollectionEquality().hash(_photo),message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AnimalDetailState(title: $title, description: $description, characteristics: $characteristics, statusLabel: $statusLabel, busy: $busy, copying: $copying, canAdopt: $canAdopt, hasAnimal: $hasAnimal, tags: $tags, publicInformation: $publicInformation, photo: $photo, message: $message)';
}


}

/// @nodoc
abstract mixin class _$AnimalDetailStateCopyWith<$Res> implements $AnimalDetailStateCopyWith<$Res> {
  factory _$AnimalDetailStateCopyWith(_AnimalDetailState value, $Res Function(_AnimalDetailState) _then) = __$AnimalDetailStateCopyWithImpl;
@override @useResult
$Res call({
 String title, String description, String characteristics, String statusLabel, bool busy, bool copying, bool canAdopt, bool hasAnimal, List<String> tags, Map<String, String> publicInformation, List<int>? photo, String? message
});




}
/// @nodoc
class __$AnimalDetailStateCopyWithImpl<$Res>
    implements _$AnimalDetailStateCopyWith<$Res> {
  __$AnimalDetailStateCopyWithImpl(this._self, this._then);

  final _AnimalDetailState _self;
  final $Res Function(_AnimalDetailState) _then;

/// Create a copy of AnimalDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? description = null,Object? characteristics = null,Object? statusLabel = null,Object? busy = null,Object? copying = null,Object? canAdopt = null,Object? hasAnimal = null,Object? tags = null,Object? publicInformation = null,Object? photo = freezed,Object? message = freezed,}) {
  return _then(_AnimalDetailState(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,characteristics: null == characteristics ? _self.characteristics : characteristics // ignore: cast_nullable_to_non_nullable
as String,statusLabel: null == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,copying: null == copying ? _self.copying : copying // ignore: cast_nullable_to_non_nullable
as bool,canAdopt: null == canAdopt ? _self.canAdopt : canAdopt // ignore: cast_nullable_to_non_nullable
as bool,hasAnimal: null == hasAnimal ? _self.hasAnimal : hasAnimal // ignore: cast_nullable_to_non_nullable
as bool,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,publicInformation: null == publicInformation ? _self._publicInformation : publicInformation // ignore: cast_nullable_to_non_nullable
as Map<String, String>,photo: freezed == photo ? _self._photo : photo // ignore: cast_nullable_to_non_nullable
as List<int>?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
