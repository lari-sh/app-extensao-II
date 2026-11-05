// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'public_list_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AnimalCardState implements DiagnosticableTreeMixin {

 String get id; String get name; String get description; String get statusLabel; String? get photoId; List<int>? get photo; bool get isFavorite;
/// Create a copy of AnimalCardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnimalCardStateCopyWith<AnimalCardState> get copyWith => _$AnimalCardStateCopyWithImpl<AnimalCardState>(this as AnimalCardState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AnimalCardState'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('description', description))..add(DiagnosticsProperty('statusLabel', statusLabel))..add(DiagnosticsProperty('photoId', photoId))..add(DiagnosticsProperty('photo', photo))..add(DiagnosticsProperty('isFavorite', isFavorite));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnimalCardState&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.statusLabel, statusLabel) || other.statusLabel == statusLabel)&&(identical(other.photoId, photoId) || other.photoId == photoId)&&const DeepCollectionEquality().equals(other.photo, photo)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,statusLabel,photoId,const DeepCollectionEquality().hash(photo),isFavorite);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AnimalCardState(id: $id, name: $name, description: $description, statusLabel: $statusLabel, photoId: $photoId, photo: $photo, isFavorite: $isFavorite)';
}


}

/// @nodoc
abstract mixin class $AnimalCardStateCopyWith<$Res>  {
  factory $AnimalCardStateCopyWith(AnimalCardState value, $Res Function(AnimalCardState) _then) = _$AnimalCardStateCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, String statusLabel, String? photoId, List<int>? photo, bool isFavorite
});




}
/// @nodoc
class _$AnimalCardStateCopyWithImpl<$Res>
    implements $AnimalCardStateCopyWith<$Res> {
  _$AnimalCardStateCopyWithImpl(this._self, this._then);

  final AnimalCardState _self;
  final $Res Function(AnimalCardState) _then;

/// Create a copy of AnimalCardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? statusLabel = null,Object? photoId = freezed,Object? photo = freezed,Object? isFavorite = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,statusLabel: null == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String,photoId: freezed == photoId ? _self.photoId : photoId // ignore: cast_nullable_to_non_nullable
as String?,photo: freezed == photo ? _self.photo : photo // ignore: cast_nullable_to_non_nullable
as List<int>?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AnimalCardState].
extension AnimalCardStatePatterns on AnimalCardState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnimalCardState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnimalCardState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnimalCardState value)  $default,){
final _that = this;
switch (_that) {
case _AnimalCardState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnimalCardState value)?  $default,){
final _that = this;
switch (_that) {
case _AnimalCardState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String statusLabel,  String? photoId,  List<int>? photo,  bool isFavorite)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnimalCardState() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.statusLabel,_that.photoId,_that.photo,_that.isFavorite);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String statusLabel,  String? photoId,  List<int>? photo,  bool isFavorite)  $default,) {final _that = this;
switch (_that) {
case _AnimalCardState():
return $default(_that.id,_that.name,_that.description,_that.statusLabel,_that.photoId,_that.photo,_that.isFavorite);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  String statusLabel,  String? photoId,  List<int>? photo,  bool isFavorite)?  $default,) {final _that = this;
switch (_that) {
case _AnimalCardState() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.statusLabel,_that.photoId,_that.photo,_that.isFavorite);case _:
  return null;

}
}

}

/// @nodoc


class _AnimalCardState with DiagnosticableTreeMixin implements AnimalCardState {
  const _AnimalCardState({required this.id, required this.name, required this.description, required this.statusLabel, this.photoId, final  List<int>? photo, this.isFavorite = false}): _photo = photo;
  

@override final  String id;
@override final  String name;
@override final  String description;
@override final  String statusLabel;
@override final  String? photoId;
 final  List<int>? _photo;
@override List<int>? get photo {
  final value = _photo;
  if (value == null) return null;
  if (_photo is EqualUnmodifiableListView) return _photo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey() final  bool isFavorite;

/// Create a copy of AnimalCardState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnimalCardStateCopyWith<_AnimalCardState> get copyWith => __$AnimalCardStateCopyWithImpl<_AnimalCardState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'AnimalCardState'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('description', description))..add(DiagnosticsProperty('statusLabel', statusLabel))..add(DiagnosticsProperty('photoId', photoId))..add(DiagnosticsProperty('photo', photo))..add(DiagnosticsProperty('isFavorite', isFavorite));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnimalCardState&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.statusLabel, statusLabel) || other.statusLabel == statusLabel)&&(identical(other.photoId, photoId) || other.photoId == photoId)&&const DeepCollectionEquality().equals(other._photo, _photo)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,statusLabel,photoId,const DeepCollectionEquality().hash(_photo),isFavorite);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'AnimalCardState(id: $id, name: $name, description: $description, statusLabel: $statusLabel, photoId: $photoId, photo: $photo, isFavorite: $isFavorite)';
}


}

/// @nodoc
abstract mixin class _$AnimalCardStateCopyWith<$Res> implements $AnimalCardStateCopyWith<$Res> {
  factory _$AnimalCardStateCopyWith(_AnimalCardState value, $Res Function(_AnimalCardState) _then) = __$AnimalCardStateCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, String statusLabel, String? photoId, List<int>? photo, bool isFavorite
});




}
/// @nodoc
class __$AnimalCardStateCopyWithImpl<$Res>
    implements _$AnimalCardStateCopyWith<$Res> {
  __$AnimalCardStateCopyWithImpl(this._self, this._then);

  final _AnimalCardState _self;
  final $Res Function(_AnimalCardState) _then;

/// Create a copy of AnimalCardState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? statusLabel = null,Object? photoId = freezed,Object? photo = freezed,Object? isFavorite = null,}) {
  return _then(_AnimalCardState(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,statusLabel: null == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String,photoId: freezed == photoId ? _self.photoId : photoId // ignore: cast_nullable_to_non_nullable
as String?,photo: freezed == photo ? _self._photo : photo // ignore: cast_nullable_to_non_nullable
as List<int>?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$PublicListState implements DiagnosticableTreeMixin {

 List<AnimalCardState> get items; bool get busy; bool get favoritesReady; Set<String> get updatingFavorites; int get total; String? get cursor; String? get message; AnimalQuery get query;
/// Create a copy of PublicListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicListStateCopyWith<PublicListState> get copyWith => _$PublicListStateCopyWithImpl<PublicListState>(this as PublicListState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'PublicListState'))
    ..add(DiagnosticsProperty('items', items))..add(DiagnosticsProperty('busy', busy))..add(DiagnosticsProperty('favoritesReady', favoritesReady))..add(DiagnosticsProperty('updatingFavorites', updatingFavorites))..add(DiagnosticsProperty('total', total))..add(DiagnosticsProperty('cursor', cursor))..add(DiagnosticsProperty('message', message))..add(DiagnosticsProperty('query', query));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicListState&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.favoritesReady, favoritesReady) || other.favoritesReady == favoritesReady)&&const DeepCollectionEquality().equals(other.updatingFavorites, updatingFavorites)&&(identical(other.total, total) || other.total == total)&&(identical(other.cursor, cursor) || other.cursor == cursor)&&(identical(other.message, message) || other.message == message)&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),busy,favoritesReady,const DeepCollectionEquality().hash(updatingFavorites),total,cursor,message,query);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'PublicListState(items: $items, busy: $busy, favoritesReady: $favoritesReady, updatingFavorites: $updatingFavorites, total: $total, cursor: $cursor, message: $message, query: $query)';
}


}

/// @nodoc
abstract mixin class $PublicListStateCopyWith<$Res>  {
  factory $PublicListStateCopyWith(PublicListState value, $Res Function(PublicListState) _then) = _$PublicListStateCopyWithImpl;
@useResult
$Res call({
 List<AnimalCardState> items, bool busy, bool favoritesReady, Set<String> updatingFavorites, int total, String? cursor, String? message, AnimalQuery query
});


$AnimalQueryCopyWith<$Res> get query;

}
/// @nodoc
class _$PublicListStateCopyWithImpl<$Res>
    implements $PublicListStateCopyWith<$Res> {
  _$PublicListStateCopyWithImpl(this._self, this._then);

  final PublicListState _self;
  final $Res Function(PublicListState) _then;

/// Create a copy of PublicListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? busy = null,Object? favoritesReady = null,Object? updatingFavorites = null,Object? total = null,Object? cursor = freezed,Object? message = freezed,Object? query = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<AnimalCardState>,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,favoritesReady: null == favoritesReady ? _self.favoritesReady : favoritesReady // ignore: cast_nullable_to_non_nullable
as bool,updatingFavorites: null == updatingFavorites ? _self.updatingFavorites : updatingFavorites // ignore: cast_nullable_to_non_nullable
as Set<String>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as AnimalQuery,
  ));
}
/// Create a copy of PublicListState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnimalQueryCopyWith<$Res> get query {
  
  return $AnimalQueryCopyWith<$Res>(_self.query, (value) {
    return _then(_self.copyWith(query: value));
  });
}
}


/// Adds pattern-matching-related methods to [PublicListState].
extension PublicListStatePatterns on PublicListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicListState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicListState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicListState value)  $default,){
final _that = this;
switch (_that) {
case _PublicListState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicListState value)?  $default,){
final _that = this;
switch (_that) {
case _PublicListState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AnimalCardState> items,  bool busy,  bool favoritesReady,  Set<String> updatingFavorites,  int total,  String? cursor,  String? message,  AnimalQuery query)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicListState() when $default != null:
return $default(_that.items,_that.busy,_that.favoritesReady,_that.updatingFavorites,_that.total,_that.cursor,_that.message,_that.query);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AnimalCardState> items,  bool busy,  bool favoritesReady,  Set<String> updatingFavorites,  int total,  String? cursor,  String? message,  AnimalQuery query)  $default,) {final _that = this;
switch (_that) {
case _PublicListState():
return $default(_that.items,_that.busy,_that.favoritesReady,_that.updatingFavorites,_that.total,_that.cursor,_that.message,_that.query);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AnimalCardState> items,  bool busy,  bool favoritesReady,  Set<String> updatingFavorites,  int total,  String? cursor,  String? message,  AnimalQuery query)?  $default,) {final _that = this;
switch (_that) {
case _PublicListState() when $default != null:
return $default(_that.items,_that.busy,_that.favoritesReady,_that.updatingFavorites,_that.total,_that.cursor,_that.message,_that.query);case _:
  return null;

}
}

}

/// @nodoc


class _PublicListState with DiagnosticableTreeMixin implements PublicListState {
  const _PublicListState({final  List<AnimalCardState> items = const [], this.busy = false, this.favoritesReady = false, final  Set<String> updatingFavorites = const {}, this.total = 0, this.cursor, this.message, this.query = const AnimalQuery()}): _items = items,_updatingFavorites = updatingFavorites;
  

 final  List<AnimalCardState> _items;
@override@JsonKey() List<AnimalCardState> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  bool busy;
@override@JsonKey() final  bool favoritesReady;
 final  Set<String> _updatingFavorites;
@override@JsonKey() Set<String> get updatingFavorites {
  if (_updatingFavorites is EqualUnmodifiableSetView) return _updatingFavorites;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_updatingFavorites);
}

@override@JsonKey() final  int total;
@override final  String? cursor;
@override final  String? message;
@override@JsonKey() final  AnimalQuery query;

/// Create a copy of PublicListState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicListStateCopyWith<_PublicListState> get copyWith => __$PublicListStateCopyWithImpl<_PublicListState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'PublicListState'))
    ..add(DiagnosticsProperty('items', items))..add(DiagnosticsProperty('busy', busy))..add(DiagnosticsProperty('favoritesReady', favoritesReady))..add(DiagnosticsProperty('updatingFavorites', updatingFavorites))..add(DiagnosticsProperty('total', total))..add(DiagnosticsProperty('cursor', cursor))..add(DiagnosticsProperty('message', message))..add(DiagnosticsProperty('query', query));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicListState&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.favoritesReady, favoritesReady) || other.favoritesReady == favoritesReady)&&const DeepCollectionEquality().equals(other._updatingFavorites, _updatingFavorites)&&(identical(other.total, total) || other.total == total)&&(identical(other.cursor, cursor) || other.cursor == cursor)&&(identical(other.message, message) || other.message == message)&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),busy,favoritesReady,const DeepCollectionEquality().hash(_updatingFavorites),total,cursor,message,query);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'PublicListState(items: $items, busy: $busy, favoritesReady: $favoritesReady, updatingFavorites: $updatingFavorites, total: $total, cursor: $cursor, message: $message, query: $query)';
}


}

/// @nodoc
abstract mixin class _$PublicListStateCopyWith<$Res> implements $PublicListStateCopyWith<$Res> {
  factory _$PublicListStateCopyWith(_PublicListState value, $Res Function(_PublicListState) _then) = __$PublicListStateCopyWithImpl;
@override @useResult
$Res call({
 List<AnimalCardState> items, bool busy, bool favoritesReady, Set<String> updatingFavorites, int total, String? cursor, String? message, AnimalQuery query
});


@override $AnimalQueryCopyWith<$Res> get query;

}
/// @nodoc
class __$PublicListStateCopyWithImpl<$Res>
    implements _$PublicListStateCopyWith<$Res> {
  __$PublicListStateCopyWithImpl(this._self, this._then);

  final _PublicListState _self;
  final $Res Function(_PublicListState) _then;

/// Create a copy of PublicListState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? busy = null,Object? favoritesReady = null,Object? updatingFavorites = null,Object? total = null,Object? cursor = freezed,Object? message = freezed,Object? query = null,}) {
  return _then(_PublicListState(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<AnimalCardState>,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,favoritesReady: null == favoritesReady ? _self.favoritesReady : favoritesReady // ignore: cast_nullable_to_non_nullable
as bool,updatingFavorites: null == updatingFavorites ? _self._updatingFavorites : updatingFavorites // ignore: cast_nullable_to_non_nullable
as Set<String>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as AnimalQuery,
  ));
}

/// Create a copy of PublicListState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AnimalQueryCopyWith<$Res> get query {
  
  return $AnimalQueryCopyWith<$Res>(_self.query, (value) {
    return _then(_self.copyWith(query: value));
  });
}
}

// dart format on
