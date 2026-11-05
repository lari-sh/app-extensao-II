// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'managed_animals_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ManagedAnimalsState implements DiagnosticableTreeMixin {

 List<ManagedAnimal> get items; int get total; String? get cursor; bool get loading; String? get message;
/// Create a copy of ManagedAnimalsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ManagedAnimalsStateCopyWith<ManagedAnimalsState> get copyWith => _$ManagedAnimalsStateCopyWithImpl<ManagedAnimalsState>(this as ManagedAnimalsState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ManagedAnimalsState'))
    ..add(DiagnosticsProperty('items', items))..add(DiagnosticsProperty('total', total))..add(DiagnosticsProperty('cursor', cursor))..add(DiagnosticsProperty('loading', loading))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ManagedAnimalsState&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.total, total) || other.total == total)&&(identical(other.cursor, cursor) || other.cursor == cursor)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),total,cursor,loading,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ManagedAnimalsState(items: $items, total: $total, cursor: $cursor, loading: $loading, message: $message)';
}


}

/// @nodoc
abstract mixin class $ManagedAnimalsStateCopyWith<$Res>  {
  factory $ManagedAnimalsStateCopyWith(ManagedAnimalsState value, $Res Function(ManagedAnimalsState) _then) = _$ManagedAnimalsStateCopyWithImpl;
@useResult
$Res call({
 List<ManagedAnimal> items, int total, String? cursor, bool loading, String? message
});




}
/// @nodoc
class _$ManagedAnimalsStateCopyWithImpl<$Res>
    implements $ManagedAnimalsStateCopyWith<$Res> {
  _$ManagedAnimalsStateCopyWithImpl(this._self, this._then);

  final ManagedAnimalsState _self;
  final $Res Function(ManagedAnimalsState) _then;

/// Create a copy of ManagedAnimalsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? total = null,Object? cursor = freezed,Object? loading = null,Object? message = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ManagedAnimal>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ManagedAnimalsState].
extension ManagedAnimalsStatePatterns on ManagedAnimalsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ManagedAnimalsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ManagedAnimalsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ManagedAnimalsState value)  $default,){
final _that = this;
switch (_that) {
case _ManagedAnimalsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ManagedAnimalsState value)?  $default,){
final _that = this;
switch (_that) {
case _ManagedAnimalsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ManagedAnimal> items,  int total,  String? cursor,  bool loading,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ManagedAnimalsState() when $default != null:
return $default(_that.items,_that.total,_that.cursor,_that.loading,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ManagedAnimal> items,  int total,  String? cursor,  bool loading,  String? message)  $default,) {final _that = this;
switch (_that) {
case _ManagedAnimalsState():
return $default(_that.items,_that.total,_that.cursor,_that.loading,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ManagedAnimal> items,  int total,  String? cursor,  bool loading,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _ManagedAnimalsState() when $default != null:
return $default(_that.items,_that.total,_that.cursor,_that.loading,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _ManagedAnimalsState with DiagnosticableTreeMixin implements ManagedAnimalsState {
  const _ManagedAnimalsState({final  List<ManagedAnimal> items = const [], this.total = 0, this.cursor, this.loading = false, this.message}): _items = items;
  

 final  List<ManagedAnimal> _items;
@override@JsonKey() List<ManagedAnimal> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  int total;
@override final  String? cursor;
@override@JsonKey() final  bool loading;
@override final  String? message;

/// Create a copy of ManagedAnimalsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ManagedAnimalsStateCopyWith<_ManagedAnimalsState> get copyWith => __$ManagedAnimalsStateCopyWithImpl<_ManagedAnimalsState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ManagedAnimalsState'))
    ..add(DiagnosticsProperty('items', items))..add(DiagnosticsProperty('total', total))..add(DiagnosticsProperty('cursor', cursor))..add(DiagnosticsProperty('loading', loading))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ManagedAnimalsState&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.total, total) || other.total == total)&&(identical(other.cursor, cursor) || other.cursor == cursor)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),total,cursor,loading,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ManagedAnimalsState(items: $items, total: $total, cursor: $cursor, loading: $loading, message: $message)';
}


}

/// @nodoc
abstract mixin class _$ManagedAnimalsStateCopyWith<$Res> implements $ManagedAnimalsStateCopyWith<$Res> {
  factory _$ManagedAnimalsStateCopyWith(_ManagedAnimalsState value, $Res Function(_ManagedAnimalsState) _then) = __$ManagedAnimalsStateCopyWithImpl;
@override @useResult
$Res call({
 List<ManagedAnimal> items, int total, String? cursor, bool loading, String? message
});




}
/// @nodoc
class __$ManagedAnimalsStateCopyWithImpl<$Res>
    implements _$ManagedAnimalsStateCopyWith<$Res> {
  __$ManagedAnimalsStateCopyWithImpl(this._self, this._then);

  final _ManagedAnimalsState _self;
  final $Res Function(_ManagedAnimalsState) _then;

/// Create a copy of ManagedAnimalsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? total = null,Object? cursor = freezed,Object? loading = null,Object? message = freezed,}) {
  return _then(_ManagedAnimalsState(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ManagedAnimal>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
