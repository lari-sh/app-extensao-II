// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'adoption_contact_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AdoptionContactState {

 bool get loading; bool get opening; bool get canContact; String get animalName; String get linkNotice; String? get message;
/// Create a copy of AdoptionContactState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdoptionContactStateCopyWith<AdoptionContactState> get copyWith => _$AdoptionContactStateCopyWithImpl<AdoptionContactState>(this as AdoptionContactState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdoptionContactState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.opening, opening) || other.opening == opening)&&(identical(other.canContact, canContact) || other.canContact == canContact)&&(identical(other.animalName, animalName) || other.animalName == animalName)&&(identical(other.linkNotice, linkNotice) || other.linkNotice == linkNotice)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,loading,opening,canContact,animalName,linkNotice,message);

@override
String toString() {
  return 'AdoptionContactState(loading: $loading, opening: $opening, canContact: $canContact, animalName: $animalName, linkNotice: $linkNotice, message: $message)';
}


}

/// @nodoc
abstract mixin class $AdoptionContactStateCopyWith<$Res>  {
  factory $AdoptionContactStateCopyWith(AdoptionContactState value, $Res Function(AdoptionContactState) _then) = _$AdoptionContactStateCopyWithImpl;
@useResult
$Res call({
 bool loading, bool opening, bool canContact, String animalName, String linkNotice, String? message
});




}
/// @nodoc
class _$AdoptionContactStateCopyWithImpl<$Res>
    implements $AdoptionContactStateCopyWith<$Res> {
  _$AdoptionContactStateCopyWithImpl(this._self, this._then);

  final AdoptionContactState _self;
  final $Res Function(AdoptionContactState) _then;

/// Create a copy of AdoptionContactState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loading = null,Object? opening = null,Object? canContact = null,Object? animalName = null,Object? linkNotice = null,Object? message = freezed,}) {
  return _then(_self.copyWith(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,opening: null == opening ? _self.opening : opening // ignore: cast_nullable_to_non_nullable
as bool,canContact: null == canContact ? _self.canContact : canContact // ignore: cast_nullable_to_non_nullable
as bool,animalName: null == animalName ? _self.animalName : animalName // ignore: cast_nullable_to_non_nullable
as String,linkNotice: null == linkNotice ? _self.linkNotice : linkNotice // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AdoptionContactState].
extension AdoptionContactStatePatterns on AdoptionContactState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdoptionContactState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdoptionContactState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdoptionContactState value)  $default,){
final _that = this;
switch (_that) {
case _AdoptionContactState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdoptionContactState value)?  $default,){
final _that = this;
switch (_that) {
case _AdoptionContactState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool loading,  bool opening,  bool canContact,  String animalName,  String linkNotice,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdoptionContactState() when $default != null:
return $default(_that.loading,_that.opening,_that.canContact,_that.animalName,_that.linkNotice,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool loading,  bool opening,  bool canContact,  String animalName,  String linkNotice,  String? message)  $default,) {final _that = this;
switch (_that) {
case _AdoptionContactState():
return $default(_that.loading,_that.opening,_that.canContact,_that.animalName,_that.linkNotice,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool loading,  bool opening,  bool canContact,  String animalName,  String linkNotice,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _AdoptionContactState() when $default != null:
return $default(_that.loading,_that.opening,_that.canContact,_that.animalName,_that.linkNotice,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _AdoptionContactState implements AdoptionContactState {
  const _AdoptionContactState({this.loading = false, this.opening = false, this.canContact = false, this.animalName = '', this.linkNotice = 'No WhatsApp, você revisa e envia a mensagem quando quiser. O link público da ficha ainda não está disponível.', this.message});
  

@override@JsonKey() final  bool loading;
@override@JsonKey() final  bool opening;
@override@JsonKey() final  bool canContact;
@override@JsonKey() final  String animalName;
@override@JsonKey() final  String linkNotice;
@override final  String? message;

/// Create a copy of AdoptionContactState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdoptionContactStateCopyWith<_AdoptionContactState> get copyWith => __$AdoptionContactStateCopyWithImpl<_AdoptionContactState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdoptionContactState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.opening, opening) || other.opening == opening)&&(identical(other.canContact, canContact) || other.canContact == canContact)&&(identical(other.animalName, animalName) || other.animalName == animalName)&&(identical(other.linkNotice, linkNotice) || other.linkNotice == linkNotice)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,loading,opening,canContact,animalName,linkNotice,message);

@override
String toString() {
  return 'AdoptionContactState(loading: $loading, opening: $opening, canContact: $canContact, animalName: $animalName, linkNotice: $linkNotice, message: $message)';
}


}

/// @nodoc
abstract mixin class _$AdoptionContactStateCopyWith<$Res> implements $AdoptionContactStateCopyWith<$Res> {
  factory _$AdoptionContactStateCopyWith(_AdoptionContactState value, $Res Function(_AdoptionContactState) _then) = __$AdoptionContactStateCopyWithImpl;
@override @useResult
$Res call({
 bool loading, bool opening, bool canContact, String animalName, String linkNotice, String? message
});




}
/// @nodoc
class __$AdoptionContactStateCopyWithImpl<$Res>
    implements _$AdoptionContactStateCopyWith<$Res> {
  __$AdoptionContactStateCopyWithImpl(this._self, this._then);

  final _AdoptionContactState _self;
  final $Res Function(_AdoptionContactState) _then;

/// Create a copy of AdoptionContactState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loading = null,Object? opening = null,Object? canContact = null,Object? animalName = null,Object? linkNotice = null,Object? message = freezed,}) {
  return _then(_AdoptionContactState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,opening: null == opening ? _self.opening : opening // ignore: cast_nullable_to_non_nullable
as bool,canContact: null == canContact ? _self.canContact : canContact // ignore: cast_nullable_to_non_nullable
as bool,animalName: null == animalName ? _self.animalName : animalName // ignore: cast_nullable_to_non_nullable
as String,linkNotice: null == linkNotice ? _self.linkNotice : linkNotice // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
