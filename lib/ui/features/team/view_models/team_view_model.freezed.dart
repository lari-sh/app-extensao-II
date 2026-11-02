// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TeamState implements DiagnosticableTreeMixin {

 TeamTab get tab; List<TeamMember> get members; List<TeamInvitation> get invitations; String? get nextCursor; bool get loading; bool get busy; bool get uncertain; String? get message;
/// Create a copy of TeamState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamStateCopyWith<TeamState> get copyWith => _$TeamStateCopyWithImpl<TeamState>(this as TeamState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'TeamState'))
    ..add(DiagnosticsProperty('tab', tab))..add(DiagnosticsProperty('members', members))..add(DiagnosticsProperty('invitations', invitations))..add(DiagnosticsProperty('nextCursor', nextCursor))..add(DiagnosticsProperty('loading', loading))..add(DiagnosticsProperty('busy', busy))..add(DiagnosticsProperty('uncertain', uncertain))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamState&&(identical(other.tab, tab) || other.tab == tab)&&const DeepCollectionEquality().equals(other.members, members)&&const DeepCollectionEquality().equals(other.invitations, invitations)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.uncertain, uncertain) || other.uncertain == uncertain)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,tab,const DeepCollectionEquality().hash(members),const DeepCollectionEquality().hash(invitations),nextCursor,loading,busy,uncertain,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'TeamState(tab: $tab, members: $members, invitations: $invitations, nextCursor: $nextCursor, loading: $loading, busy: $busy, uncertain: $uncertain, message: $message)';
}


}

/// @nodoc
abstract mixin class $TeamStateCopyWith<$Res>  {
  factory $TeamStateCopyWith(TeamState value, $Res Function(TeamState) _then) = _$TeamStateCopyWithImpl;
@useResult
$Res call({
 TeamTab tab, List<TeamMember> members, List<TeamInvitation> invitations, String? nextCursor, bool loading, bool busy, bool uncertain, String? message
});




}
/// @nodoc
class _$TeamStateCopyWithImpl<$Res>
    implements $TeamStateCopyWith<$Res> {
  _$TeamStateCopyWithImpl(this._self, this._then);

  final TeamState _self;
  final $Res Function(TeamState) _then;

/// Create a copy of TeamState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tab = null,Object? members = null,Object? invitations = null,Object? nextCursor = freezed,Object? loading = null,Object? busy = null,Object? uncertain = null,Object? message = freezed,}) {
  return _then(_self.copyWith(
tab: null == tab ? _self.tab : tab // ignore: cast_nullable_to_non_nullable
as TeamTab,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<TeamMember>,invitations: null == invitations ? _self.invitations : invitations // ignore: cast_nullable_to_non_nullable
as List<TeamInvitation>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,uncertain: null == uncertain ? _self.uncertain : uncertain // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamState].
extension TeamStatePatterns on TeamState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamState value)  $default,){
final _that = this;
switch (_that) {
case _TeamState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamState value)?  $default,){
final _that = this;
switch (_that) {
case _TeamState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TeamTab tab,  List<TeamMember> members,  List<TeamInvitation> invitations,  String? nextCursor,  bool loading,  bool busy,  bool uncertain,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamState() when $default != null:
return $default(_that.tab,_that.members,_that.invitations,_that.nextCursor,_that.loading,_that.busy,_that.uncertain,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TeamTab tab,  List<TeamMember> members,  List<TeamInvitation> invitations,  String? nextCursor,  bool loading,  bool busy,  bool uncertain,  String? message)  $default,) {final _that = this;
switch (_that) {
case _TeamState():
return $default(_that.tab,_that.members,_that.invitations,_that.nextCursor,_that.loading,_that.busy,_that.uncertain,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TeamTab tab,  List<TeamMember> members,  List<TeamInvitation> invitations,  String? nextCursor,  bool loading,  bool busy,  bool uncertain,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _TeamState() when $default != null:
return $default(_that.tab,_that.members,_that.invitations,_that.nextCursor,_that.loading,_that.busy,_that.uncertain,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _TeamState with DiagnosticableTreeMixin implements TeamState {
  const _TeamState({this.tab = TeamTab.active, final  List<TeamMember> members = const [], final  List<TeamInvitation> invitations = const [], this.nextCursor, this.loading = false, this.busy = false, this.uncertain = false, this.message}): _members = members,_invitations = invitations;
  

@override@JsonKey() final  TeamTab tab;
 final  List<TeamMember> _members;
@override@JsonKey() List<TeamMember> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}

 final  List<TeamInvitation> _invitations;
@override@JsonKey() List<TeamInvitation> get invitations {
  if (_invitations is EqualUnmodifiableListView) return _invitations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_invitations);
}

@override final  String? nextCursor;
@override@JsonKey() final  bool loading;
@override@JsonKey() final  bool busy;
@override@JsonKey() final  bool uncertain;
@override final  String? message;

/// Create a copy of TeamState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamStateCopyWith<_TeamState> get copyWith => __$TeamStateCopyWithImpl<_TeamState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'TeamState'))
    ..add(DiagnosticsProperty('tab', tab))..add(DiagnosticsProperty('members', members))..add(DiagnosticsProperty('invitations', invitations))..add(DiagnosticsProperty('nextCursor', nextCursor))..add(DiagnosticsProperty('loading', loading))..add(DiagnosticsProperty('busy', busy))..add(DiagnosticsProperty('uncertain', uncertain))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamState&&(identical(other.tab, tab) || other.tab == tab)&&const DeepCollectionEquality().equals(other._members, _members)&&const DeepCollectionEquality().equals(other._invitations, _invitations)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.uncertain, uncertain) || other.uncertain == uncertain)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,tab,const DeepCollectionEquality().hash(_members),const DeepCollectionEquality().hash(_invitations),nextCursor,loading,busy,uncertain,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'TeamState(tab: $tab, members: $members, invitations: $invitations, nextCursor: $nextCursor, loading: $loading, busy: $busy, uncertain: $uncertain, message: $message)';
}


}

/// @nodoc
abstract mixin class _$TeamStateCopyWith<$Res> implements $TeamStateCopyWith<$Res> {
  factory _$TeamStateCopyWith(_TeamState value, $Res Function(_TeamState) _then) = __$TeamStateCopyWithImpl;
@override @useResult
$Res call({
 TeamTab tab, List<TeamMember> members, List<TeamInvitation> invitations, String? nextCursor, bool loading, bool busy, bool uncertain, String? message
});




}
/// @nodoc
class __$TeamStateCopyWithImpl<$Res>
    implements _$TeamStateCopyWith<$Res> {
  __$TeamStateCopyWithImpl(this._self, this._then);

  final _TeamState _self;
  final $Res Function(_TeamState) _then;

/// Create a copy of TeamState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tab = null,Object? members = null,Object? invitations = null,Object? nextCursor = freezed,Object? loading = null,Object? busy = null,Object? uncertain = null,Object? message = freezed,}) {
  return _then(_TeamState(
tab: null == tab ? _self.tab : tab // ignore: cast_nullable_to_non_nullable
as TeamTab,members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<TeamMember>,invitations: null == invitations ? _self._invitations : invitations // ignore: cast_nullable_to_non_nullable
as List<TeamInvitation>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,uncertain: null == uncertain ? _self.uncertain : uncertain // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$InviteMemberState implements DiagnosticableTreeMixin {

 StaffRole get role; bool get busy; bool get uncertain; bool get sent; Map<String, String> get errors; String? get message;
/// Create a copy of InviteMemberState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InviteMemberStateCopyWith<InviteMemberState> get copyWith => _$InviteMemberStateCopyWithImpl<InviteMemberState>(this as InviteMemberState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'InviteMemberState'))
    ..add(DiagnosticsProperty('role', role))..add(DiagnosticsProperty('busy', busy))..add(DiagnosticsProperty('uncertain', uncertain))..add(DiagnosticsProperty('sent', sent))..add(DiagnosticsProperty('errors', errors))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InviteMemberState&&(identical(other.role, role) || other.role == role)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.uncertain, uncertain) || other.uncertain == uncertain)&&(identical(other.sent, sent) || other.sent == sent)&&const DeepCollectionEquality().equals(other.errors, errors)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,role,busy,uncertain,sent,const DeepCollectionEquality().hash(errors),message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'InviteMemberState(role: $role, busy: $busy, uncertain: $uncertain, sent: $sent, errors: $errors, message: $message)';
}


}

/// @nodoc
abstract mixin class $InviteMemberStateCopyWith<$Res>  {
  factory $InviteMemberStateCopyWith(InviteMemberState value, $Res Function(InviteMemberState) _then) = _$InviteMemberStateCopyWithImpl;
@useResult
$Res call({
 StaffRole role, bool busy, bool uncertain, bool sent, Map<String, String> errors, String? message
});




}
/// @nodoc
class _$InviteMemberStateCopyWithImpl<$Res>
    implements $InviteMemberStateCopyWith<$Res> {
  _$InviteMemberStateCopyWithImpl(this._self, this._then);

  final InviteMemberState _self;
  final $Res Function(InviteMemberState) _then;

/// Create a copy of InviteMemberState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? role = null,Object? busy = null,Object? uncertain = null,Object? sent = null,Object? errors = null,Object? message = freezed,}) {
  return _then(_self.copyWith(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as StaffRole,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,uncertain: null == uncertain ? _self.uncertain : uncertain // ignore: cast_nullable_to_non_nullable
as bool,sent: null == sent ? _self.sent : sent // ignore: cast_nullable_to_non_nullable
as bool,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [InviteMemberState].
extension InviteMemberStatePatterns on InviteMemberState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InviteMemberState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InviteMemberState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InviteMemberState value)  $default,){
final _that = this;
switch (_that) {
case _InviteMemberState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InviteMemberState value)?  $default,){
final _that = this;
switch (_that) {
case _InviteMemberState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StaffRole role,  bool busy,  bool uncertain,  bool sent,  Map<String, String> errors,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InviteMemberState() when $default != null:
return $default(_that.role,_that.busy,_that.uncertain,_that.sent,_that.errors,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StaffRole role,  bool busy,  bool uncertain,  bool sent,  Map<String, String> errors,  String? message)  $default,) {final _that = this;
switch (_that) {
case _InviteMemberState():
return $default(_that.role,_that.busy,_that.uncertain,_that.sent,_that.errors,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StaffRole role,  bool busy,  bool uncertain,  bool sent,  Map<String, String> errors,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _InviteMemberState() when $default != null:
return $default(_that.role,_that.busy,_that.uncertain,_that.sent,_that.errors,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _InviteMemberState with DiagnosticableTreeMixin implements InviteMemberState {
  const _InviteMemberState({this.role = StaffRole.employee, this.busy = false, this.uncertain = false, this.sent = false, final  Map<String, String> errors = const {}, this.message}): _errors = errors;
  

@override@JsonKey() final  StaffRole role;
@override@JsonKey() final  bool busy;
@override@JsonKey() final  bool uncertain;
@override@JsonKey() final  bool sent;
 final  Map<String, String> _errors;
@override@JsonKey() Map<String, String> get errors {
  if (_errors is EqualUnmodifiableMapView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_errors);
}

@override final  String? message;

/// Create a copy of InviteMemberState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InviteMemberStateCopyWith<_InviteMemberState> get copyWith => __$InviteMemberStateCopyWithImpl<_InviteMemberState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'InviteMemberState'))
    ..add(DiagnosticsProperty('role', role))..add(DiagnosticsProperty('busy', busy))..add(DiagnosticsProperty('uncertain', uncertain))..add(DiagnosticsProperty('sent', sent))..add(DiagnosticsProperty('errors', errors))..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InviteMemberState&&(identical(other.role, role) || other.role == role)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.uncertain, uncertain) || other.uncertain == uncertain)&&(identical(other.sent, sent) || other.sent == sent)&&const DeepCollectionEquality().equals(other._errors, _errors)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,role,busy,uncertain,sent,const DeepCollectionEquality().hash(_errors),message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'InviteMemberState(role: $role, busy: $busy, uncertain: $uncertain, sent: $sent, errors: $errors, message: $message)';
}


}

/// @nodoc
abstract mixin class _$InviteMemberStateCopyWith<$Res> implements $InviteMemberStateCopyWith<$Res> {
  factory _$InviteMemberStateCopyWith(_InviteMemberState value, $Res Function(_InviteMemberState) _then) = __$InviteMemberStateCopyWithImpl;
@override @useResult
$Res call({
 StaffRole role, bool busy, bool uncertain, bool sent, Map<String, String> errors, String? message
});




}
/// @nodoc
class __$InviteMemberStateCopyWithImpl<$Res>
    implements _$InviteMemberStateCopyWith<$Res> {
  __$InviteMemberStateCopyWithImpl(this._self, this._then);

  final _InviteMemberState _self;
  final $Res Function(_InviteMemberState) _then;

/// Create a copy of InviteMemberState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? role = null,Object? busy = null,Object? uncertain = null,Object? sent = null,Object? errors = null,Object? message = freezed,}) {
  return _then(_InviteMemberState(
role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as StaffRole,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,uncertain: null == uncertain ? _self.uncertain : uncertain // ignore: cast_nullable_to_non_nullable
as bool,sent: null == sent ? _self.sent : sent // ignore: cast_nullable_to_non_nullable
as bool,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
