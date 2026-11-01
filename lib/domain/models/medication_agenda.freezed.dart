// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medication_agenda.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MedicationDaySummary {

 String get day; int get pending; int get completed; int get cancelled;
/// Create a copy of MedicationDaySummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicationDaySummaryCopyWith<MedicationDaySummary> get copyWith => _$MedicationDaySummaryCopyWithImpl<MedicationDaySummary>(this as MedicationDaySummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicationDaySummary&&(identical(other.day, day) || other.day == day)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.cancelled, cancelled) || other.cancelled == cancelled));
}


@override
int get hashCode => Object.hash(runtimeType,day,pending,completed,cancelled);

@override
String toString() {
  return 'MedicationDaySummary(day: $day, pending: $pending, completed: $completed, cancelled: $cancelled)';
}


}

/// @nodoc
abstract mixin class $MedicationDaySummaryCopyWith<$Res>  {
  factory $MedicationDaySummaryCopyWith(MedicationDaySummary value, $Res Function(MedicationDaySummary) _then) = _$MedicationDaySummaryCopyWithImpl;
@useResult
$Res call({
 String day, int pending, int completed, int cancelled
});




}
/// @nodoc
class _$MedicationDaySummaryCopyWithImpl<$Res>
    implements $MedicationDaySummaryCopyWith<$Res> {
  _$MedicationDaySummaryCopyWithImpl(this._self, this._then);

  final MedicationDaySummary _self;
  final $Res Function(MedicationDaySummary) _then;

/// Create a copy of MedicationDaySummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? day = null,Object? pending = null,Object? completed = null,Object? cancelled = null,}) {
  return _then(_self.copyWith(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,cancelled: null == cancelled ? _self.cancelled : cancelled // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicationDaySummary].
extension MedicationDaySummaryPatterns on MedicationDaySummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicationDaySummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicationDaySummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicationDaySummary value)  $default,){
final _that = this;
switch (_that) {
case _MedicationDaySummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicationDaySummary value)?  $default,){
final _that = this;
switch (_that) {
case _MedicationDaySummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String day,  int pending,  int completed,  int cancelled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicationDaySummary() when $default != null:
return $default(_that.day,_that.pending,_that.completed,_that.cancelled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String day,  int pending,  int completed,  int cancelled)  $default,) {final _that = this;
switch (_that) {
case _MedicationDaySummary():
return $default(_that.day,_that.pending,_that.completed,_that.cancelled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String day,  int pending,  int completed,  int cancelled)?  $default,) {final _that = this;
switch (_that) {
case _MedicationDaySummary() when $default != null:
return $default(_that.day,_that.pending,_that.completed,_that.cancelled);case _:
  return null;

}
}

}

/// @nodoc


class _MedicationDaySummary implements MedicationDaySummary {
  const _MedicationDaySummary({required this.day, this.pending = 0, this.completed = 0, this.cancelled = 0});
  

@override final  String day;
@override@JsonKey() final  int pending;
@override@JsonKey() final  int completed;
@override@JsonKey() final  int cancelled;

/// Create a copy of MedicationDaySummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicationDaySummaryCopyWith<_MedicationDaySummary> get copyWith => __$MedicationDaySummaryCopyWithImpl<_MedicationDaySummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicationDaySummary&&(identical(other.day, day) || other.day == day)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.cancelled, cancelled) || other.cancelled == cancelled));
}


@override
int get hashCode => Object.hash(runtimeType,day,pending,completed,cancelled);

@override
String toString() {
  return 'MedicationDaySummary(day: $day, pending: $pending, completed: $completed, cancelled: $cancelled)';
}


}

/// @nodoc
abstract mixin class _$MedicationDaySummaryCopyWith<$Res> implements $MedicationDaySummaryCopyWith<$Res> {
  factory _$MedicationDaySummaryCopyWith(_MedicationDaySummary value, $Res Function(_MedicationDaySummary) _then) = __$MedicationDaySummaryCopyWithImpl;
@override @useResult
$Res call({
 String day, int pending, int completed, int cancelled
});




}
/// @nodoc
class __$MedicationDaySummaryCopyWithImpl<$Res>
    implements _$MedicationDaySummaryCopyWith<$Res> {
  __$MedicationDaySummaryCopyWithImpl(this._self, this._then);

  final _MedicationDaySummary _self;
  final $Res Function(_MedicationDaySummary) _then;

/// Create a copy of MedicationDaySummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? day = null,Object? pending = null,Object? completed = null,Object? cancelled = null,}) {
  return _then(_MedicationDaySummary(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,cancelled: null == cancelled ? _self.cancelled : cancelled // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$MedicationMonth {

 String get month; DateTime get serverNow; String get shelterToday; List<MedicationDaySummary> get days;
/// Create a copy of MedicationMonth
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicationMonthCopyWith<MedicationMonth> get copyWith => _$MedicationMonthCopyWithImpl<MedicationMonth>(this as MedicationMonth, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicationMonth&&(identical(other.month, month) || other.month == month)&&(identical(other.serverNow, serverNow) || other.serverNow == serverNow)&&(identical(other.shelterToday, shelterToday) || other.shelterToday == shelterToday)&&const DeepCollectionEquality().equals(other.days, days));
}


@override
int get hashCode => Object.hash(runtimeType,month,serverNow,shelterToday,const DeepCollectionEquality().hash(days));

@override
String toString() {
  return 'MedicationMonth(month: $month, serverNow: $serverNow, shelterToday: $shelterToday, days: $days)';
}


}

/// @nodoc
abstract mixin class $MedicationMonthCopyWith<$Res>  {
  factory $MedicationMonthCopyWith(MedicationMonth value, $Res Function(MedicationMonth) _then) = _$MedicationMonthCopyWithImpl;
@useResult
$Res call({
 String month, DateTime serverNow, String shelterToday, List<MedicationDaySummary> days
});




}
/// @nodoc
class _$MedicationMonthCopyWithImpl<$Res>
    implements $MedicationMonthCopyWith<$Res> {
  _$MedicationMonthCopyWithImpl(this._self, this._then);

  final MedicationMonth _self;
  final $Res Function(MedicationMonth) _then;

/// Create a copy of MedicationMonth
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? serverNow = null,Object? shelterToday = null,Object? days = null,}) {
  return _then(_self.copyWith(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,serverNow: null == serverNow ? _self.serverNow : serverNow // ignore: cast_nullable_to_non_nullable
as DateTime,shelterToday: null == shelterToday ? _self.shelterToday : shelterToday // ignore: cast_nullable_to_non_nullable
as String,days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<MedicationDaySummary>,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicationMonth].
extension MedicationMonthPatterns on MedicationMonth {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicationMonth value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicationMonth() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicationMonth value)  $default,){
final _that = this;
switch (_that) {
case _MedicationMonth():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicationMonth value)?  $default,){
final _that = this;
switch (_that) {
case _MedicationMonth() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String month,  DateTime serverNow,  String shelterToday,  List<MedicationDaySummary> days)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicationMonth() when $default != null:
return $default(_that.month,_that.serverNow,_that.shelterToday,_that.days);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String month,  DateTime serverNow,  String shelterToday,  List<MedicationDaySummary> days)  $default,) {final _that = this;
switch (_that) {
case _MedicationMonth():
return $default(_that.month,_that.serverNow,_that.shelterToday,_that.days);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String month,  DateTime serverNow,  String shelterToday,  List<MedicationDaySummary> days)?  $default,) {final _that = this;
switch (_that) {
case _MedicationMonth() when $default != null:
return $default(_that.month,_that.serverNow,_that.shelterToday,_that.days);case _:
  return null;

}
}

}

/// @nodoc


class _MedicationMonth implements MedicationMonth {
  const _MedicationMonth({required this.month, required this.serverNow, required this.shelterToday, final  List<MedicationDaySummary> days = const []}): _days = days;
  

@override final  String month;
@override final  DateTime serverNow;
@override final  String shelterToday;
 final  List<MedicationDaySummary> _days;
@override@JsonKey() List<MedicationDaySummary> get days {
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_days);
}


/// Create a copy of MedicationMonth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicationMonthCopyWith<_MedicationMonth> get copyWith => __$MedicationMonthCopyWithImpl<_MedicationMonth>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicationMonth&&(identical(other.month, month) || other.month == month)&&(identical(other.serverNow, serverNow) || other.serverNow == serverNow)&&(identical(other.shelterToday, shelterToday) || other.shelterToday == shelterToday)&&const DeepCollectionEquality().equals(other._days, _days));
}


@override
int get hashCode => Object.hash(runtimeType,month,serverNow,shelterToday,const DeepCollectionEquality().hash(_days));

@override
String toString() {
  return 'MedicationMonth(month: $month, serverNow: $serverNow, shelterToday: $shelterToday, days: $days)';
}


}

/// @nodoc
abstract mixin class _$MedicationMonthCopyWith<$Res> implements $MedicationMonthCopyWith<$Res> {
  factory _$MedicationMonthCopyWith(_MedicationMonth value, $Res Function(_MedicationMonth) _then) = __$MedicationMonthCopyWithImpl;
@override @useResult
$Res call({
 String month, DateTime serverNow, String shelterToday, List<MedicationDaySummary> days
});




}
/// @nodoc
class __$MedicationMonthCopyWithImpl<$Res>
    implements _$MedicationMonthCopyWith<$Res> {
  __$MedicationMonthCopyWithImpl(this._self, this._then);

  final _MedicationMonth _self;
  final $Res Function(_MedicationMonth) _then;

/// Create a copy of MedicationMonth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? serverNow = null,Object? shelterToday = null,Object? days = null,}) {
  return _then(_MedicationMonth(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,serverNow: null == serverNow ? _self.serverNow : serverNow // ignore: cast_nullable_to_non_nullable
as DateTime,shelterToday: null == shelterToday ? _self.shelterToday : shelterToday // ignore: cast_nullable_to_non_nullable
as String,days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<MedicationDaySummary>,
  ));
}


}

/// @nodoc
mixin _$MedicationDayPage {

 String get day; DateTime get serverNow; int get agendaVersion; List<MedicationApplication> get items; String? get cursor;
/// Create a copy of MedicationDayPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicationDayPageCopyWith<MedicationDayPage> get copyWith => _$MedicationDayPageCopyWithImpl<MedicationDayPage>(this as MedicationDayPage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicationDayPage&&(identical(other.day, day) || other.day == day)&&(identical(other.serverNow, serverNow) || other.serverNow == serverNow)&&(identical(other.agendaVersion, agendaVersion) || other.agendaVersion == agendaVersion)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.cursor, cursor) || other.cursor == cursor));
}


@override
int get hashCode => Object.hash(runtimeType,day,serverNow,agendaVersion,const DeepCollectionEquality().hash(items),cursor);

@override
String toString() {
  return 'MedicationDayPage(day: $day, serverNow: $serverNow, agendaVersion: $agendaVersion, items: $items, cursor: $cursor)';
}


}

/// @nodoc
abstract mixin class $MedicationDayPageCopyWith<$Res>  {
  factory $MedicationDayPageCopyWith(MedicationDayPage value, $Res Function(MedicationDayPage) _then) = _$MedicationDayPageCopyWithImpl;
@useResult
$Res call({
 String day, DateTime serverNow, int agendaVersion, List<MedicationApplication> items, String? cursor
});




}
/// @nodoc
class _$MedicationDayPageCopyWithImpl<$Res>
    implements $MedicationDayPageCopyWith<$Res> {
  _$MedicationDayPageCopyWithImpl(this._self, this._then);

  final MedicationDayPage _self;
  final $Res Function(MedicationDayPage) _then;

/// Create a copy of MedicationDayPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? day = null,Object? serverNow = null,Object? agendaVersion = null,Object? items = null,Object? cursor = freezed,}) {
  return _then(_self.copyWith(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,serverNow: null == serverNow ? _self.serverNow : serverNow // ignore: cast_nullable_to_non_nullable
as DateTime,agendaVersion: null == agendaVersion ? _self.agendaVersion : agendaVersion // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<MedicationApplication>,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicationDayPage].
extension MedicationDayPagePatterns on MedicationDayPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicationDayPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicationDayPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicationDayPage value)  $default,){
final _that = this;
switch (_that) {
case _MedicationDayPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicationDayPage value)?  $default,){
final _that = this;
switch (_that) {
case _MedicationDayPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String day,  DateTime serverNow,  int agendaVersion,  List<MedicationApplication> items,  String? cursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicationDayPage() when $default != null:
return $default(_that.day,_that.serverNow,_that.agendaVersion,_that.items,_that.cursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String day,  DateTime serverNow,  int agendaVersion,  List<MedicationApplication> items,  String? cursor)  $default,) {final _that = this;
switch (_that) {
case _MedicationDayPage():
return $default(_that.day,_that.serverNow,_that.agendaVersion,_that.items,_that.cursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String day,  DateTime serverNow,  int agendaVersion,  List<MedicationApplication> items,  String? cursor)?  $default,) {final _that = this;
switch (_that) {
case _MedicationDayPage() when $default != null:
return $default(_that.day,_that.serverNow,_that.agendaVersion,_that.items,_that.cursor);case _:
  return null;

}
}

}

/// @nodoc


class _MedicationDayPage implements MedicationDayPage {
  const _MedicationDayPage({required this.day, required this.serverNow, required this.agendaVersion, final  List<MedicationApplication> items = const [], this.cursor}): _items = items;
  

@override final  String day;
@override final  DateTime serverNow;
@override final  int agendaVersion;
 final  List<MedicationApplication> _items;
@override@JsonKey() List<MedicationApplication> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? cursor;

/// Create a copy of MedicationDayPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicationDayPageCopyWith<_MedicationDayPage> get copyWith => __$MedicationDayPageCopyWithImpl<_MedicationDayPage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicationDayPage&&(identical(other.day, day) || other.day == day)&&(identical(other.serverNow, serverNow) || other.serverNow == serverNow)&&(identical(other.agendaVersion, agendaVersion) || other.agendaVersion == agendaVersion)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.cursor, cursor) || other.cursor == cursor));
}


@override
int get hashCode => Object.hash(runtimeType,day,serverNow,agendaVersion,const DeepCollectionEquality().hash(_items),cursor);

@override
String toString() {
  return 'MedicationDayPage(day: $day, serverNow: $serverNow, agendaVersion: $agendaVersion, items: $items, cursor: $cursor)';
}


}

/// @nodoc
abstract mixin class _$MedicationDayPageCopyWith<$Res> implements $MedicationDayPageCopyWith<$Res> {
  factory _$MedicationDayPageCopyWith(_MedicationDayPage value, $Res Function(_MedicationDayPage) _then) = __$MedicationDayPageCopyWithImpl;
@override @useResult
$Res call({
 String day, DateTime serverNow, int agendaVersion, List<MedicationApplication> items, String? cursor
});




}
/// @nodoc
class __$MedicationDayPageCopyWithImpl<$Res>
    implements _$MedicationDayPageCopyWith<$Res> {
  __$MedicationDayPageCopyWithImpl(this._self, this._then);

  final _MedicationDayPage _self;
  final $Res Function(_MedicationDayPage) _then;

/// Create a copy of MedicationDayPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? day = null,Object? serverNow = null,Object? agendaVersion = null,Object? items = null,Object? cursor = freezed,}) {
  return _then(_MedicationDayPage(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,serverNow: null == serverNow ? _self.serverNow : serverNow // ignore: cast_nullable_to_non_nullable
as DateTime,agendaVersion: null == agendaVersion ? _self.agendaVersion : agendaVersion // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<MedicationApplication>,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$MedicationTreatmentPage {

 List<MedicationTreatment> get items; String? get cursor;
/// Create a copy of MedicationTreatmentPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicationTreatmentPageCopyWith<MedicationTreatmentPage> get copyWith => _$MedicationTreatmentPageCopyWithImpl<MedicationTreatmentPage>(this as MedicationTreatmentPage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicationTreatmentPage&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.cursor, cursor) || other.cursor == cursor));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),cursor);

@override
String toString() {
  return 'MedicationTreatmentPage(items: $items, cursor: $cursor)';
}


}

/// @nodoc
abstract mixin class $MedicationTreatmentPageCopyWith<$Res>  {
  factory $MedicationTreatmentPageCopyWith(MedicationTreatmentPage value, $Res Function(MedicationTreatmentPage) _then) = _$MedicationTreatmentPageCopyWithImpl;
@useResult
$Res call({
 List<MedicationTreatment> items, String? cursor
});




}
/// @nodoc
class _$MedicationTreatmentPageCopyWithImpl<$Res>
    implements $MedicationTreatmentPageCopyWith<$Res> {
  _$MedicationTreatmentPageCopyWithImpl(this._self, this._then);

  final MedicationTreatmentPage _self;
  final $Res Function(MedicationTreatmentPage) _then;

/// Create a copy of MedicationTreatmentPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? cursor = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<MedicationTreatment>,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicationTreatmentPage].
extension MedicationTreatmentPagePatterns on MedicationTreatmentPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicationTreatmentPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicationTreatmentPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicationTreatmentPage value)  $default,){
final _that = this;
switch (_that) {
case _MedicationTreatmentPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicationTreatmentPage value)?  $default,){
final _that = this;
switch (_that) {
case _MedicationTreatmentPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MedicationTreatment> items,  String? cursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicationTreatmentPage() when $default != null:
return $default(_that.items,_that.cursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MedicationTreatment> items,  String? cursor)  $default,) {final _that = this;
switch (_that) {
case _MedicationTreatmentPage():
return $default(_that.items,_that.cursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MedicationTreatment> items,  String? cursor)?  $default,) {final _that = this;
switch (_that) {
case _MedicationTreatmentPage() when $default != null:
return $default(_that.items,_that.cursor);case _:
  return null;

}
}

}

/// @nodoc


class _MedicationTreatmentPage implements MedicationTreatmentPage {
  const _MedicationTreatmentPage({final  List<MedicationTreatment> items = const [], this.cursor}): _items = items;
  

 final  List<MedicationTreatment> _items;
@override@JsonKey() List<MedicationTreatment> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? cursor;

/// Create a copy of MedicationTreatmentPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicationTreatmentPageCopyWith<_MedicationTreatmentPage> get copyWith => __$MedicationTreatmentPageCopyWithImpl<_MedicationTreatmentPage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicationTreatmentPage&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.cursor, cursor) || other.cursor == cursor));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),cursor);

@override
String toString() {
  return 'MedicationTreatmentPage(items: $items, cursor: $cursor)';
}


}

/// @nodoc
abstract mixin class _$MedicationTreatmentPageCopyWith<$Res> implements $MedicationTreatmentPageCopyWith<$Res> {
  factory _$MedicationTreatmentPageCopyWith(_MedicationTreatmentPage value, $Res Function(_MedicationTreatmentPage) _then) = __$MedicationTreatmentPageCopyWithImpl;
@override @useResult
$Res call({
 List<MedicationTreatment> items, String? cursor
});




}
/// @nodoc
class __$MedicationTreatmentPageCopyWithImpl<$Res>
    implements _$MedicationTreatmentPageCopyWith<$Res> {
  __$MedicationTreatmentPageCopyWithImpl(this._self, this._then);

  final _MedicationTreatmentPage _self;
  final $Res Function(_MedicationTreatmentPage) _then;

/// Create a copy of MedicationTreatmentPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? cursor = freezed,}) {
  return _then(_MedicationTreatmentPage(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<MedicationTreatment>,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$MedicationHistoryPage {

 MedicationApplication get application; List<MedicationApplicationEvent> get items; String? get cursor;
/// Create a copy of MedicationHistoryPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicationHistoryPageCopyWith<MedicationHistoryPage> get copyWith => _$MedicationHistoryPageCopyWithImpl<MedicationHistoryPage>(this as MedicationHistoryPage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicationHistoryPage&&(identical(other.application, application) || other.application == application)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.cursor, cursor) || other.cursor == cursor));
}


@override
int get hashCode => Object.hash(runtimeType,application,const DeepCollectionEquality().hash(items),cursor);

@override
String toString() {
  return 'MedicationHistoryPage(application: $application, items: $items, cursor: $cursor)';
}


}

/// @nodoc
abstract mixin class $MedicationHistoryPageCopyWith<$Res>  {
  factory $MedicationHistoryPageCopyWith(MedicationHistoryPage value, $Res Function(MedicationHistoryPage) _then) = _$MedicationHistoryPageCopyWithImpl;
@useResult
$Res call({
 MedicationApplication application, List<MedicationApplicationEvent> items, String? cursor
});


$MedicationApplicationCopyWith<$Res> get application;

}
/// @nodoc
class _$MedicationHistoryPageCopyWithImpl<$Res>
    implements $MedicationHistoryPageCopyWith<$Res> {
  _$MedicationHistoryPageCopyWithImpl(this._self, this._then);

  final MedicationHistoryPage _self;
  final $Res Function(MedicationHistoryPage) _then;

/// Create a copy of MedicationHistoryPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? application = null,Object? items = null,Object? cursor = freezed,}) {
  return _then(_self.copyWith(
application: null == application ? _self.application : application // ignore: cast_nullable_to_non_nullable
as MedicationApplication,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<MedicationApplicationEvent>,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of MedicationHistoryPage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MedicationApplicationCopyWith<$Res> get application {
  
  return $MedicationApplicationCopyWith<$Res>(_self.application, (value) {
    return _then(_self.copyWith(application: value));
  });
}
}


/// Adds pattern-matching-related methods to [MedicationHistoryPage].
extension MedicationHistoryPagePatterns on MedicationHistoryPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicationHistoryPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicationHistoryPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicationHistoryPage value)  $default,){
final _that = this;
switch (_that) {
case _MedicationHistoryPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicationHistoryPage value)?  $default,){
final _that = this;
switch (_that) {
case _MedicationHistoryPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MedicationApplication application,  List<MedicationApplicationEvent> items,  String? cursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicationHistoryPage() when $default != null:
return $default(_that.application,_that.items,_that.cursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MedicationApplication application,  List<MedicationApplicationEvent> items,  String? cursor)  $default,) {final _that = this;
switch (_that) {
case _MedicationHistoryPage():
return $default(_that.application,_that.items,_that.cursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MedicationApplication application,  List<MedicationApplicationEvent> items,  String? cursor)?  $default,) {final _that = this;
switch (_that) {
case _MedicationHistoryPage() when $default != null:
return $default(_that.application,_that.items,_that.cursor);case _:
  return null;

}
}

}

/// @nodoc


class _MedicationHistoryPage implements MedicationHistoryPage {
  const _MedicationHistoryPage({required this.application, final  List<MedicationApplicationEvent> items = const [], this.cursor}): _items = items;
  

@override final  MedicationApplication application;
 final  List<MedicationApplicationEvent> _items;
@override@JsonKey() List<MedicationApplicationEvent> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? cursor;

/// Create a copy of MedicationHistoryPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicationHistoryPageCopyWith<_MedicationHistoryPage> get copyWith => __$MedicationHistoryPageCopyWithImpl<_MedicationHistoryPage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicationHistoryPage&&(identical(other.application, application) || other.application == application)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.cursor, cursor) || other.cursor == cursor));
}


@override
int get hashCode => Object.hash(runtimeType,application,const DeepCollectionEquality().hash(_items),cursor);

@override
String toString() {
  return 'MedicationHistoryPage(application: $application, items: $items, cursor: $cursor)';
}


}

/// @nodoc
abstract mixin class _$MedicationHistoryPageCopyWith<$Res> implements $MedicationHistoryPageCopyWith<$Res> {
  factory _$MedicationHistoryPageCopyWith(_MedicationHistoryPage value, $Res Function(_MedicationHistoryPage) _then) = __$MedicationHistoryPageCopyWithImpl;
@override @useResult
$Res call({
 MedicationApplication application, List<MedicationApplicationEvent> items, String? cursor
});


@override $MedicationApplicationCopyWith<$Res> get application;

}
/// @nodoc
class __$MedicationHistoryPageCopyWithImpl<$Res>
    implements _$MedicationHistoryPageCopyWith<$Res> {
  __$MedicationHistoryPageCopyWithImpl(this._self, this._then);

  final _MedicationHistoryPage _self;
  final $Res Function(_MedicationHistoryPage) _then;

/// Create a copy of MedicationHistoryPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? application = null,Object? items = null,Object? cursor = freezed,}) {
  return _then(_MedicationHistoryPage(
application: null == application ? _self.application : application // ignore: cast_nullable_to_non_nullable
as MedicationApplication,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<MedicationApplicationEvent>,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of MedicationHistoryPage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MedicationApplicationCopyWith<$Res> get application {
  
  return $MedicationApplicationCopyWith<$Res>(_self.application, (value) {
    return _then(_self.copyWith(application: value));
  });
}
}

// dart format on
