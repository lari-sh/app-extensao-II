// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'managed_animal_search_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ManagedAnimalSearchState implements DiagnosticableTreeMixin {

 ManagedAnimalSearchFilter get filter; ManagedAnimalSearchFilter get draft; List<ManagedAnimal> get items; Map<String, List<int>> get photos; int get total; bool get loading; bool get loadingMore; String? get cursor; String? get message;
/// Create a copy of ManagedAnimalSearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ManagedAnimalSearchStateCopyWith<ManagedAnimalSearchState> get copyWith => _$ManagedAnimalSearchStateCopyWithImpl<ManagedAnimalSearchState>(this as ManagedAnimalSearchState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ManagedAnimalSearchState'))
    ..add(DiagnosticsProperty('filter', filter))..add(DiagnosticsProperty('draft', draft))..add(DiagnosticsProperty('items', items))..add(DiagnosticsProperty('photos', photos))..add(DiagnosticsProperty('total', total))..add(DiagnosticsProperty('loading', loading))..add(DiagnosticsProperty('loadingMore', loadingMore))..add(DiagnosticsProperty('cursor', cursor))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ManagedAnimalSearchState&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.draft, draft) || other.draft == draft)&&const DeepCollectionEquality().equals(other.items, items)&&const DeepCollectionEquality().equals(other.photos, photos)&&(identical(other.total, total) || other.total == total)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.loadingMore, loadingMore) || other.loadingMore == loadingMore)&&(identical(other.cursor, cursor) || other.cursor == cursor)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,filter,draft,const DeepCollectionEquality().hash(items),const DeepCollectionEquality().hash(photos),total,loading,loadingMore,cursor,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ManagedAnimalSearchState(filter: $filter, draft: $draft, items: $items, photos: $photos, total: $total, loading: $loading, loadingMore: $loadingMore, cursor: $cursor, message: $message)';
}


}

/// @nodoc
abstract mixin class $ManagedAnimalSearchStateCopyWith<$Res>  {
  factory $ManagedAnimalSearchStateCopyWith(ManagedAnimalSearchState value, $Res Function(ManagedAnimalSearchState) _then) = _$ManagedAnimalSearchStateCopyWithImpl;
@useResult
$Res call({
 ManagedAnimalSearchFilter filter, ManagedAnimalSearchFilter draft, List<ManagedAnimal> items, Map<String, List<int>> photos, int total, bool loading, bool loadingMore, String? cursor, String? message
});


$ManagedAnimalSearchFilterCopyWith<$Res> get filter;$ManagedAnimalSearchFilterCopyWith<$Res> get draft;

}
/// @nodoc
class _$ManagedAnimalSearchStateCopyWithImpl<$Res>
    implements $ManagedAnimalSearchStateCopyWith<$Res> {
  _$ManagedAnimalSearchStateCopyWithImpl(this._self, this._then);

  final ManagedAnimalSearchState _self;
  final $Res Function(ManagedAnimalSearchState) _then;

/// Create a copy of ManagedAnimalSearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? filter = null,Object? draft = null,Object? items = null,Object? photos = null,Object? total = null,Object? loading = null,Object? loadingMore = null,Object? cursor = freezed,Object? message = freezed,}) {
  return _then(_self.copyWith(
filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as ManagedAnimalSearchFilter,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as ManagedAnimalSearchFilter,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ManagedAnimal>,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as Map<String, List<int>>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,loadingMore: null == loadingMore ? _self.loadingMore : loadingMore // ignore: cast_nullable_to_non_nullable
as bool,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ManagedAnimalSearchState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ManagedAnimalSearchFilterCopyWith<$Res> get filter {
  
  return $ManagedAnimalSearchFilterCopyWith<$Res>(_self.filter, (value) {
    return _then(_self.copyWith(filter: value));
  });
}/// Create a copy of ManagedAnimalSearchState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ManagedAnimalSearchFilterCopyWith<$Res> get draft {
  
  return $ManagedAnimalSearchFilterCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}
}


/// Adds pattern-matching-related methods to [ManagedAnimalSearchState].
extension ManagedAnimalSearchStatePatterns on ManagedAnimalSearchState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ManagedAnimalSearchState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ManagedAnimalSearchState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ManagedAnimalSearchState value)  $default,){
final _that = this;
switch (_that) {
case _ManagedAnimalSearchState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ManagedAnimalSearchState value)?  $default,){
final _that = this;
switch (_that) {
case _ManagedAnimalSearchState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ManagedAnimalSearchFilter filter,  ManagedAnimalSearchFilter draft,  List<ManagedAnimal> items,  Map<String, List<int>> photos,  int total,  bool loading,  bool loadingMore,  String? cursor,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ManagedAnimalSearchState() when $default != null:
return $default(_that.filter,_that.draft,_that.items,_that.photos,_that.total,_that.loading,_that.loadingMore,_that.cursor,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ManagedAnimalSearchFilter filter,  ManagedAnimalSearchFilter draft,  List<ManagedAnimal> items,  Map<String, List<int>> photos,  int total,  bool loading,  bool loadingMore,  String? cursor,  String? message)  $default,) {final _that = this;
switch (_that) {
case _ManagedAnimalSearchState():
return $default(_that.filter,_that.draft,_that.items,_that.photos,_that.total,_that.loading,_that.loadingMore,_that.cursor,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ManagedAnimalSearchFilter filter,  ManagedAnimalSearchFilter draft,  List<ManagedAnimal> items,  Map<String, List<int>> photos,  int total,  bool loading,  bool loadingMore,  String? cursor,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _ManagedAnimalSearchState() when $default != null:
return $default(_that.filter,_that.draft,_that.items,_that.photos,_that.total,_that.loading,_that.loadingMore,_that.cursor,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _ManagedAnimalSearchState with DiagnosticableTreeMixin implements ManagedAnimalSearchState {
  const _ManagedAnimalSearchState({this.filter = const ManagedAnimalSearchFilter(), this.draft = const ManagedAnimalSearchFilter(), final  List<ManagedAnimal> items = const [], final  Map<String, List<int>> photos = const {}, this.total = 0, this.loading = false, this.loadingMore = false, this.cursor, this.message}): _items = items,_photos = photos;
  

@override@JsonKey() final  ManagedAnimalSearchFilter filter;
@override@JsonKey() final  ManagedAnimalSearchFilter draft;
 final  List<ManagedAnimal> _items;
@override@JsonKey() List<ManagedAnimal> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  Map<String, List<int>> _photos;
@override@JsonKey() Map<String, List<int>> get photos {
  if (_photos is EqualUnmodifiableMapView) return _photos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_photos);
}

@override@JsonKey() final  int total;
@override@JsonKey() final  bool loading;
@override@JsonKey() final  bool loadingMore;
@override final  String? cursor;
@override final  String? message;

/// Create a copy of ManagedAnimalSearchState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ManagedAnimalSearchStateCopyWith<_ManagedAnimalSearchState> get copyWith => __$ManagedAnimalSearchStateCopyWithImpl<_ManagedAnimalSearchState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ManagedAnimalSearchState'))
    ..add(DiagnosticsProperty('filter', filter))..add(DiagnosticsProperty('draft', draft))..add(DiagnosticsProperty('items', items))..add(DiagnosticsProperty('photos', photos))..add(DiagnosticsProperty('total', total))..add(DiagnosticsProperty('loading', loading))..add(DiagnosticsProperty('loadingMore', loadingMore))..add(DiagnosticsProperty('cursor', cursor))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ManagedAnimalSearchState&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.draft, draft) || other.draft == draft)&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._photos, _photos)&&(identical(other.total, total) || other.total == total)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.loadingMore, loadingMore) || other.loadingMore == loadingMore)&&(identical(other.cursor, cursor) || other.cursor == cursor)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,filter,draft,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_photos),total,loading,loadingMore,cursor,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ManagedAnimalSearchState(filter: $filter, draft: $draft, items: $items, photos: $photos, total: $total, loading: $loading, loadingMore: $loadingMore, cursor: $cursor, message: $message)';
}


}

/// @nodoc
abstract mixin class _$ManagedAnimalSearchStateCopyWith<$Res> implements $ManagedAnimalSearchStateCopyWith<$Res> {
  factory _$ManagedAnimalSearchStateCopyWith(_ManagedAnimalSearchState value, $Res Function(_ManagedAnimalSearchState) _then) = __$ManagedAnimalSearchStateCopyWithImpl;
@override @useResult
$Res call({
 ManagedAnimalSearchFilter filter, ManagedAnimalSearchFilter draft, List<ManagedAnimal> items, Map<String, List<int>> photos, int total, bool loading, bool loadingMore, String? cursor, String? message
});


@override $ManagedAnimalSearchFilterCopyWith<$Res> get filter;@override $ManagedAnimalSearchFilterCopyWith<$Res> get draft;

}
/// @nodoc
class __$ManagedAnimalSearchStateCopyWithImpl<$Res>
    implements _$ManagedAnimalSearchStateCopyWith<$Res> {
  __$ManagedAnimalSearchStateCopyWithImpl(this._self, this._then);

  final _ManagedAnimalSearchState _self;
  final $Res Function(_ManagedAnimalSearchState) _then;

/// Create a copy of ManagedAnimalSearchState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? filter = null,Object? draft = null,Object? items = null,Object? photos = null,Object? total = null,Object? loading = null,Object? loadingMore = null,Object? cursor = freezed,Object? message = freezed,}) {
  return _then(_ManagedAnimalSearchState(
filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as ManagedAnimalSearchFilter,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as ManagedAnimalSearchFilter,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ManagedAnimal>,photos: null == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as Map<String, List<int>>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,loadingMore: null == loadingMore ? _self.loadingMore : loadingMore // ignore: cast_nullable_to_non_nullable
as bool,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ManagedAnimalSearchState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ManagedAnimalSearchFilterCopyWith<$Res> get filter {
  
  return $ManagedAnimalSearchFilterCopyWith<$Res>(_self.filter, (value) {
    return _then(_self.copyWith(filter: value));
  });
}/// Create a copy of ManagedAnimalSearchState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ManagedAnimalSearchFilterCopyWith<$Res> get draft {
  
  return $ManagedAnimalSearchFilterCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}
}

// dart format on
