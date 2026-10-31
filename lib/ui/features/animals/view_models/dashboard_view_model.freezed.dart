// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DashboardState implements DiagnosticableTreeMixin {

 Map<AnimalStatus, ManagedAnimalPage> get pages; Map<AnimalStatus, int> get counts; bool get loading; bool get busy; bool get listMode; bool get uncertain; bool get canRetry; String? get message;
/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardStateCopyWith<DashboardState> get copyWith => _$DashboardStateCopyWithImpl<DashboardState>(this as DashboardState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'DashboardState'))
    ..add(DiagnosticsProperty('pages', pages))..add(DiagnosticsProperty('counts', counts))..add(DiagnosticsProperty('loading', loading))..add(DiagnosticsProperty('busy', busy))..add(DiagnosticsProperty('listMode', listMode))..add(DiagnosticsProperty('uncertain', uncertain))..add(DiagnosticsProperty('canRetry', canRetry))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardState&&const DeepCollectionEquality().equals(other.pages, pages)&&const DeepCollectionEquality().equals(other.counts, counts)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.listMode, listMode) || other.listMode == listMode)&&(identical(other.uncertain, uncertain) || other.uncertain == uncertain)&&(identical(other.canRetry, canRetry) || other.canRetry == canRetry)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(pages),const DeepCollectionEquality().hash(counts),loading,busy,listMode,uncertain,canRetry,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'DashboardState(pages: $pages, counts: $counts, loading: $loading, busy: $busy, listMode: $listMode, uncertain: $uncertain, canRetry: $canRetry, message: $message)';
}


}

/// @nodoc
abstract mixin class $DashboardStateCopyWith<$Res>  {
  factory $DashboardStateCopyWith(DashboardState value, $Res Function(DashboardState) _then) = _$DashboardStateCopyWithImpl;
@useResult
$Res call({
 Map<AnimalStatus, ManagedAnimalPage> pages, Map<AnimalStatus, int> counts, bool loading, bool busy, bool listMode, bool uncertain, bool canRetry, String? message
});




}
/// @nodoc
class _$DashboardStateCopyWithImpl<$Res>
    implements $DashboardStateCopyWith<$Res> {
  _$DashboardStateCopyWithImpl(this._self, this._then);

  final DashboardState _self;
  final $Res Function(DashboardState) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pages = null,Object? counts = null,Object? loading = null,Object? busy = null,Object? listMode = null,Object? uncertain = null,Object? canRetry = null,Object? message = freezed,}) {
  return _then(_self.copyWith(
pages: null == pages ? _self.pages : pages // ignore: cast_nullable_to_non_nullable
as Map<AnimalStatus, ManagedAnimalPage>,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as Map<AnimalStatus, int>,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,listMode: null == listMode ? _self.listMode : listMode // ignore: cast_nullable_to_non_nullable
as bool,uncertain: null == uncertain ? _self.uncertain : uncertain // ignore: cast_nullable_to_non_nullable
as bool,canRetry: null == canRetry ? _self.canRetry : canRetry // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardState].
extension DashboardStatePatterns on DashboardState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardState value)  $default,){
final _that = this;
switch (_that) {
case _DashboardState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardState value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<AnimalStatus, ManagedAnimalPage> pages,  Map<AnimalStatus, int> counts,  bool loading,  bool busy,  bool listMode,  bool uncertain,  bool canRetry,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
return $default(_that.pages,_that.counts,_that.loading,_that.busy,_that.listMode,_that.uncertain,_that.canRetry,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<AnimalStatus, ManagedAnimalPage> pages,  Map<AnimalStatus, int> counts,  bool loading,  bool busy,  bool listMode,  bool uncertain,  bool canRetry,  String? message)  $default,) {final _that = this;
switch (_that) {
case _DashboardState():
return $default(_that.pages,_that.counts,_that.loading,_that.busy,_that.listMode,_that.uncertain,_that.canRetry,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<AnimalStatus, ManagedAnimalPage> pages,  Map<AnimalStatus, int> counts,  bool loading,  bool busy,  bool listMode,  bool uncertain,  bool canRetry,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
return $default(_that.pages,_that.counts,_that.loading,_that.busy,_that.listMode,_that.uncertain,_that.canRetry,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _DashboardState with DiagnosticableTreeMixin implements DashboardState {
  const _DashboardState({final  Map<AnimalStatus, ManagedAnimalPage> pages = const {}, final  Map<AnimalStatus, int> counts = const {}, this.loading = false, this.busy = false, this.listMode = false, this.uncertain = false, this.canRetry = false, this.message}): _pages = pages,_counts = counts;
  

 final  Map<AnimalStatus, ManagedAnimalPage> _pages;
@override@JsonKey() Map<AnimalStatus, ManagedAnimalPage> get pages {
  if (_pages is EqualUnmodifiableMapView) return _pages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_pages);
}

 final  Map<AnimalStatus, int> _counts;
@override@JsonKey() Map<AnimalStatus, int> get counts {
  if (_counts is EqualUnmodifiableMapView) return _counts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_counts);
}

@override@JsonKey() final  bool loading;
@override@JsonKey() final  bool busy;
@override@JsonKey() final  bool listMode;
@override@JsonKey() final  bool uncertain;
@override@JsonKey() final  bool canRetry;
@override final  String? message;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardStateCopyWith<_DashboardState> get copyWith => __$DashboardStateCopyWithImpl<_DashboardState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'DashboardState'))
    ..add(DiagnosticsProperty('pages', pages))..add(DiagnosticsProperty('counts', counts))..add(DiagnosticsProperty('loading', loading))..add(DiagnosticsProperty('busy', busy))..add(DiagnosticsProperty('listMode', listMode))..add(DiagnosticsProperty('uncertain', uncertain))..add(DiagnosticsProperty('canRetry', canRetry))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardState&&const DeepCollectionEquality().equals(other._pages, _pages)&&const DeepCollectionEquality().equals(other._counts, _counts)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.listMode, listMode) || other.listMode == listMode)&&(identical(other.uncertain, uncertain) || other.uncertain == uncertain)&&(identical(other.canRetry, canRetry) || other.canRetry == canRetry)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_pages),const DeepCollectionEquality().hash(_counts),loading,busy,listMode,uncertain,canRetry,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'DashboardState(pages: $pages, counts: $counts, loading: $loading, busy: $busy, listMode: $listMode, uncertain: $uncertain, canRetry: $canRetry, message: $message)';
}


}

/// @nodoc
abstract mixin class _$DashboardStateCopyWith<$Res> implements $DashboardStateCopyWith<$Res> {
  factory _$DashboardStateCopyWith(_DashboardState value, $Res Function(_DashboardState) _then) = __$DashboardStateCopyWithImpl;
@override @useResult
$Res call({
 Map<AnimalStatus, ManagedAnimalPage> pages, Map<AnimalStatus, int> counts, bool loading, bool busy, bool listMode, bool uncertain, bool canRetry, String? message
});




}
/// @nodoc
class __$DashboardStateCopyWithImpl<$Res>
    implements _$DashboardStateCopyWith<$Res> {
  __$DashboardStateCopyWithImpl(this._self, this._then);

  final _DashboardState _self;
  final $Res Function(_DashboardState) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pages = null,Object? counts = null,Object? loading = null,Object? busy = null,Object? listMode = null,Object? uncertain = null,Object? canRetry = null,Object? message = freezed,}) {
  return _then(_DashboardState(
pages: null == pages ? _self._pages : pages // ignore: cast_nullable_to_non_nullable
as Map<AnimalStatus, ManagedAnimalPage>,counts: null == counts ? _self._counts : counts // ignore: cast_nullable_to_non_nullable
as Map<AnimalStatus, int>,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,listMode: null == listMode ? _self.listMode : listMode // ignore: cast_nullable_to_non_nullable
as bool,uncertain: null == uncertain ? _self.uncertain : uncertain // ignore: cast_nullable_to_non_nullable
as bool,canRetry: null == canRetry ? _self.canRetry : canRetry // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
