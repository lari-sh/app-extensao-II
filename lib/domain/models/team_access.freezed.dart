// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_access.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TeamMember {

 String get id; String get name; String get email; StaffRole get role; bool get active; int get version;
/// Create a copy of TeamMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamMemberCopyWith<TeamMember> get copyWith => _$TeamMemberCopyWithImpl<TeamMember>(this as TeamMember, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamMember&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.active, active) || other.active == active)&&(identical(other.version, version) || other.version == version));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,email,role,active,version);

@override
String toString() {
  return 'TeamMember(id: $id, name: $name, email: $email, role: $role, active: $active, version: $version)';
}


}

/// @nodoc
abstract mixin class $TeamMemberCopyWith<$Res>  {
  factory $TeamMemberCopyWith(TeamMember value, $Res Function(TeamMember) _then) = _$TeamMemberCopyWithImpl;
@useResult
$Res call({
 String id, String name, String email, StaffRole role, bool active, int version
});




}
/// @nodoc
class _$TeamMemberCopyWithImpl<$Res>
    implements $TeamMemberCopyWith<$Res> {
  _$TeamMemberCopyWithImpl(this._self, this._then);

  final TeamMember _self;
  final $Res Function(TeamMember) _then;

/// Create a copy of TeamMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = null,Object? role = null,Object? active = null,Object? version = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as StaffRole,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamMember].
extension TeamMemberPatterns on TeamMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamMember value)  $default,){
final _that = this;
switch (_that) {
case _TeamMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamMember value)?  $default,){
final _that = this;
switch (_that) {
case _TeamMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String email,  StaffRole role,  bool active,  int version)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamMember() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.role,_that.active,_that.version);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String email,  StaffRole role,  bool active,  int version)  $default,) {final _that = this;
switch (_that) {
case _TeamMember():
return $default(_that.id,_that.name,_that.email,_that.role,_that.active,_that.version);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String email,  StaffRole role,  bool active,  int version)?  $default,) {final _that = this;
switch (_that) {
case _TeamMember() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.role,_that.active,_that.version);case _:
  return null;

}
}

}

/// @nodoc


class _TeamMember implements TeamMember {
  const _TeamMember({required this.id, required this.name, required this.email, required this.role, required this.active, required this.version});
  

@override final  String id;
@override final  String name;
@override final  String email;
@override final  StaffRole role;
@override final  bool active;
@override final  int version;

/// Create a copy of TeamMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamMemberCopyWith<_TeamMember> get copyWith => __$TeamMemberCopyWithImpl<_TeamMember>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamMember&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.active, active) || other.active == active)&&(identical(other.version, version) || other.version == version));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,email,role,active,version);

@override
String toString() {
  return 'TeamMember(id: $id, name: $name, email: $email, role: $role, active: $active, version: $version)';
}


}

/// @nodoc
abstract mixin class _$TeamMemberCopyWith<$Res> implements $TeamMemberCopyWith<$Res> {
  factory _$TeamMemberCopyWith(_TeamMember value, $Res Function(_TeamMember) _then) = __$TeamMemberCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String email, StaffRole role, bool active, int version
});




}
/// @nodoc
class __$TeamMemberCopyWithImpl<$Res>
    implements _$TeamMemberCopyWith<$Res> {
  __$TeamMemberCopyWithImpl(this._self, this._then);

  final _TeamMember _self;
  final $Res Function(_TeamMember) _then;

/// Create a copy of TeamMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = null,Object? role = null,Object? active = null,Object? version = null,}) {
  return _then(_TeamMember(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as StaffRole,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$TeamInvitation {

 String get id; String get name; String get email; StaffRole get role; String get status; int get generation; int get version; DateTime get expiresAt; String get deliveryState; int get retryAfter; bool get passwordReady;
/// Create a copy of TeamInvitation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamInvitationCopyWith<TeamInvitation> get copyWith => _$TeamInvitationCopyWithImpl<TeamInvitation>(this as TeamInvitation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamInvitation&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.version, version) || other.version == version)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.deliveryState, deliveryState) || other.deliveryState == deliveryState)&&(identical(other.retryAfter, retryAfter) || other.retryAfter == retryAfter)&&(identical(other.passwordReady, passwordReady) || other.passwordReady == passwordReady));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,email,role,status,generation,version,expiresAt,deliveryState,retryAfter,passwordReady);

@override
String toString() {
  return 'TeamInvitation(id: $id, name: $name, email: $email, role: $role, status: $status, generation: $generation, version: $version, expiresAt: $expiresAt, deliveryState: $deliveryState, retryAfter: $retryAfter, passwordReady: $passwordReady)';
}


}

/// @nodoc
abstract mixin class $TeamInvitationCopyWith<$Res>  {
  factory $TeamInvitationCopyWith(TeamInvitation value, $Res Function(TeamInvitation) _then) = _$TeamInvitationCopyWithImpl;
@useResult
$Res call({
 String id, String name, String email, StaffRole role, String status, int generation, int version, DateTime expiresAt, String deliveryState, int retryAfter, bool passwordReady
});




}
/// @nodoc
class _$TeamInvitationCopyWithImpl<$Res>
    implements $TeamInvitationCopyWith<$Res> {
  _$TeamInvitationCopyWithImpl(this._self, this._then);

  final TeamInvitation _self;
  final $Res Function(TeamInvitation) _then;

/// Create a copy of TeamInvitation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = null,Object? role = null,Object? status = null,Object? generation = null,Object? version = null,Object? expiresAt = null,Object? deliveryState = null,Object? retryAfter = null,Object? passwordReady = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as StaffRole,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,generation: null == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,deliveryState: null == deliveryState ? _self.deliveryState : deliveryState // ignore: cast_nullable_to_non_nullable
as String,retryAfter: null == retryAfter ? _self.retryAfter : retryAfter // ignore: cast_nullable_to_non_nullable
as int,passwordReady: null == passwordReady ? _self.passwordReady : passwordReady // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamInvitation].
extension TeamInvitationPatterns on TeamInvitation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamInvitation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamInvitation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamInvitation value)  $default,){
final _that = this;
switch (_that) {
case _TeamInvitation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamInvitation value)?  $default,){
final _that = this;
switch (_that) {
case _TeamInvitation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String email,  StaffRole role,  String status,  int generation,  int version,  DateTime expiresAt,  String deliveryState,  int retryAfter,  bool passwordReady)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamInvitation() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.role,_that.status,_that.generation,_that.version,_that.expiresAt,_that.deliveryState,_that.retryAfter,_that.passwordReady);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String email,  StaffRole role,  String status,  int generation,  int version,  DateTime expiresAt,  String deliveryState,  int retryAfter,  bool passwordReady)  $default,) {final _that = this;
switch (_that) {
case _TeamInvitation():
return $default(_that.id,_that.name,_that.email,_that.role,_that.status,_that.generation,_that.version,_that.expiresAt,_that.deliveryState,_that.retryAfter,_that.passwordReady);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String email,  StaffRole role,  String status,  int generation,  int version,  DateTime expiresAt,  String deliveryState,  int retryAfter,  bool passwordReady)?  $default,) {final _that = this;
switch (_that) {
case _TeamInvitation() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.role,_that.status,_that.generation,_that.version,_that.expiresAt,_that.deliveryState,_that.retryAfter,_that.passwordReady);case _:
  return null;

}
}

}

/// @nodoc


class _TeamInvitation extends TeamInvitation {
  const _TeamInvitation({required this.id, required this.name, required this.email, required this.role, required this.status, required this.generation, required this.version, required this.expiresAt, required this.deliveryState, this.retryAfter = 0, this.passwordReady = false}): super._();
  

@override final  String id;
@override final  String name;
@override final  String email;
@override final  StaffRole role;
@override final  String status;
@override final  int generation;
@override final  int version;
@override final  DateTime expiresAt;
@override final  String deliveryState;
@override@JsonKey() final  int retryAfter;
@override@JsonKey() final  bool passwordReady;

/// Create a copy of TeamInvitation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamInvitationCopyWith<_TeamInvitation> get copyWith => __$TeamInvitationCopyWithImpl<_TeamInvitation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamInvitation&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.generation, generation) || other.generation == generation)&&(identical(other.version, version) || other.version == version)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.deliveryState, deliveryState) || other.deliveryState == deliveryState)&&(identical(other.retryAfter, retryAfter) || other.retryAfter == retryAfter)&&(identical(other.passwordReady, passwordReady) || other.passwordReady == passwordReady));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,email,role,status,generation,version,expiresAt,deliveryState,retryAfter,passwordReady);

@override
String toString() {
  return 'TeamInvitation(id: $id, name: $name, email: $email, role: $role, status: $status, generation: $generation, version: $version, expiresAt: $expiresAt, deliveryState: $deliveryState, retryAfter: $retryAfter, passwordReady: $passwordReady)';
}


}

/// @nodoc
abstract mixin class _$TeamInvitationCopyWith<$Res> implements $TeamInvitationCopyWith<$Res> {
  factory _$TeamInvitationCopyWith(_TeamInvitation value, $Res Function(_TeamInvitation) _then) = __$TeamInvitationCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String email, StaffRole role, String status, int generation, int version, DateTime expiresAt, String deliveryState, int retryAfter, bool passwordReady
});




}
/// @nodoc
class __$TeamInvitationCopyWithImpl<$Res>
    implements _$TeamInvitationCopyWith<$Res> {
  __$TeamInvitationCopyWithImpl(this._self, this._then);

  final _TeamInvitation _self;
  final $Res Function(_TeamInvitation) _then;

/// Create a copy of TeamInvitation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = null,Object? role = null,Object? status = null,Object? generation = null,Object? version = null,Object? expiresAt = null,Object? deliveryState = null,Object? retryAfter = null,Object? passwordReady = null,}) {
  return _then(_TeamInvitation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as StaffRole,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,generation: null == generation ? _self.generation : generation // ignore: cast_nullable_to_non_nullable
as int,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,deliveryState: null == deliveryState ? _self.deliveryState : deliveryState // ignore: cast_nullable_to_non_nullable
as String,retryAfter: null == retryAfter ? _self.retryAfter : retryAfter // ignore: cast_nullable_to_non_nullable
as int,passwordReady: null == passwordReady ? _self.passwordReady : passwordReady // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$TeamPage {

 List<TeamMember> get members; List<TeamInvitation> get invitations; String? get nextCursor;
/// Create a copy of TeamPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamPageCopyWith<TeamPage> get copyWith => _$TeamPageCopyWithImpl<TeamPage>(this as TeamPage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamPage&&const DeepCollectionEquality().equals(other.members, members)&&const DeepCollectionEquality().equals(other.invitations, invitations)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(members),const DeepCollectionEquality().hash(invitations),nextCursor);

@override
String toString() {
  return 'TeamPage(members: $members, invitations: $invitations, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class $TeamPageCopyWith<$Res>  {
  factory $TeamPageCopyWith(TeamPage value, $Res Function(TeamPage) _then) = _$TeamPageCopyWithImpl;
@useResult
$Res call({
 List<TeamMember> members, List<TeamInvitation> invitations, String? nextCursor
});




}
/// @nodoc
class _$TeamPageCopyWithImpl<$Res>
    implements $TeamPageCopyWith<$Res> {
  _$TeamPageCopyWithImpl(this._self, this._then);

  final TeamPage _self;
  final $Res Function(TeamPage) _then;

/// Create a copy of TeamPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? members = null,Object? invitations = null,Object? nextCursor = freezed,}) {
  return _then(_self.copyWith(
members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<TeamMember>,invitations: null == invitations ? _self.invitations : invitations // ignore: cast_nullable_to_non_nullable
as List<TeamInvitation>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamPage].
extension TeamPagePatterns on TeamPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamPage value)  $default,){
final _that = this;
switch (_that) {
case _TeamPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamPage value)?  $default,){
final _that = this;
switch (_that) {
case _TeamPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TeamMember> members,  List<TeamInvitation> invitations,  String? nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamPage() when $default != null:
return $default(_that.members,_that.invitations,_that.nextCursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TeamMember> members,  List<TeamInvitation> invitations,  String? nextCursor)  $default,) {final _that = this;
switch (_that) {
case _TeamPage():
return $default(_that.members,_that.invitations,_that.nextCursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TeamMember> members,  List<TeamInvitation> invitations,  String? nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _TeamPage() when $default != null:
return $default(_that.members,_that.invitations,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc


class _TeamPage implements TeamPage {
  const _TeamPage({final  List<TeamMember> members = const [], final  List<TeamInvitation> invitations = const [], this.nextCursor}): _members = members,_invitations = invitations;
  

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

/// Create a copy of TeamPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamPageCopyWith<_TeamPage> get copyWith => __$TeamPageCopyWithImpl<_TeamPage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamPage&&const DeepCollectionEquality().equals(other._members, _members)&&const DeepCollectionEquality().equals(other._invitations, _invitations)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_members),const DeepCollectionEquality().hash(_invitations),nextCursor);

@override
String toString() {
  return 'TeamPage(members: $members, invitations: $invitations, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$TeamPageCopyWith<$Res> implements $TeamPageCopyWith<$Res> {
  factory _$TeamPageCopyWith(_TeamPage value, $Res Function(_TeamPage) _then) = __$TeamPageCopyWithImpl;
@override @useResult
$Res call({
 List<TeamMember> members, List<TeamInvitation> invitations, String? nextCursor
});




}
/// @nodoc
class __$TeamPageCopyWithImpl<$Res>
    implements _$TeamPageCopyWith<$Res> {
  __$TeamPageCopyWithImpl(this._self, this._then);

  final _TeamPage _self;
  final $Res Function(_TeamPage) _then;

/// Create a copy of TeamPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? members = null,Object? invitations = null,Object? nextCursor = freezed,}) {
  return _then(_TeamPage(
members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<TeamMember>,invitations: null == invitations ? _self._invitations : invitations // ignore: cast_nullable_to_non_nullable
as List<TeamInvitation>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$TeamReceipt {

 String get state; String? get code; TeamInvitation? get invitation; TeamMember? get member;
/// Create a copy of TeamReceipt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamReceiptCopyWith<TeamReceipt> get copyWith => _$TeamReceiptCopyWithImpl<TeamReceipt>(this as TeamReceipt, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamReceipt&&(identical(other.state, state) || other.state == state)&&(identical(other.code, code) || other.code == code)&&(identical(other.invitation, invitation) || other.invitation == invitation)&&(identical(other.member, member) || other.member == member));
}


@override
int get hashCode => Object.hash(runtimeType,state,code,invitation,member);

@override
String toString() {
  return 'TeamReceipt(state: $state, code: $code, invitation: $invitation, member: $member)';
}


}

/// @nodoc
abstract mixin class $TeamReceiptCopyWith<$Res>  {
  factory $TeamReceiptCopyWith(TeamReceipt value, $Res Function(TeamReceipt) _then) = _$TeamReceiptCopyWithImpl;
@useResult
$Res call({
 String state, String? code, TeamInvitation? invitation, TeamMember? member
});


$TeamInvitationCopyWith<$Res>? get invitation;$TeamMemberCopyWith<$Res>? get member;

}
/// @nodoc
class _$TeamReceiptCopyWithImpl<$Res>
    implements $TeamReceiptCopyWith<$Res> {
  _$TeamReceiptCopyWithImpl(this._self, this._then);

  final TeamReceipt _self;
  final $Res Function(TeamReceipt) _then;

/// Create a copy of TeamReceipt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? state = null,Object? code = freezed,Object? invitation = freezed,Object? member = freezed,}) {
  return _then(_self.copyWith(
state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,invitation: freezed == invitation ? _self.invitation : invitation // ignore: cast_nullable_to_non_nullable
as TeamInvitation?,member: freezed == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as TeamMember?,
  ));
}
/// Create a copy of TeamReceipt
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamInvitationCopyWith<$Res>? get invitation {
    if (_self.invitation == null) {
    return null;
  }

  return $TeamInvitationCopyWith<$Res>(_self.invitation!, (value) {
    return _then(_self.copyWith(invitation: value));
  });
}/// Create a copy of TeamReceipt
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamMemberCopyWith<$Res>? get member {
    if (_self.member == null) {
    return null;
  }

  return $TeamMemberCopyWith<$Res>(_self.member!, (value) {
    return _then(_self.copyWith(member: value));
  });
}
}


/// Adds pattern-matching-related methods to [TeamReceipt].
extension TeamReceiptPatterns on TeamReceipt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamReceipt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamReceipt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamReceipt value)  $default,){
final _that = this;
switch (_that) {
case _TeamReceipt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamReceipt value)?  $default,){
final _that = this;
switch (_that) {
case _TeamReceipt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String state,  String? code,  TeamInvitation? invitation,  TeamMember? member)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamReceipt() when $default != null:
return $default(_that.state,_that.code,_that.invitation,_that.member);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String state,  String? code,  TeamInvitation? invitation,  TeamMember? member)  $default,) {final _that = this;
switch (_that) {
case _TeamReceipt():
return $default(_that.state,_that.code,_that.invitation,_that.member);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String state,  String? code,  TeamInvitation? invitation,  TeamMember? member)?  $default,) {final _that = this;
switch (_that) {
case _TeamReceipt() when $default != null:
return $default(_that.state,_that.code,_that.invitation,_that.member);case _:
  return null;

}
}

}

/// @nodoc


class _TeamReceipt implements TeamReceipt {
  const _TeamReceipt({required this.state, this.code, this.invitation, this.member});
  

@override final  String state;
@override final  String? code;
@override final  TeamInvitation? invitation;
@override final  TeamMember? member;

/// Create a copy of TeamReceipt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamReceiptCopyWith<_TeamReceipt> get copyWith => __$TeamReceiptCopyWithImpl<_TeamReceipt>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamReceipt&&(identical(other.state, state) || other.state == state)&&(identical(other.code, code) || other.code == code)&&(identical(other.invitation, invitation) || other.invitation == invitation)&&(identical(other.member, member) || other.member == member));
}


@override
int get hashCode => Object.hash(runtimeType,state,code,invitation,member);

@override
String toString() {
  return 'TeamReceipt(state: $state, code: $code, invitation: $invitation, member: $member)';
}


}

/// @nodoc
abstract mixin class _$TeamReceiptCopyWith<$Res> implements $TeamReceiptCopyWith<$Res> {
  factory _$TeamReceiptCopyWith(_TeamReceipt value, $Res Function(_TeamReceipt) _then) = __$TeamReceiptCopyWithImpl;
@override @useResult
$Res call({
 String state, String? code, TeamInvitation? invitation, TeamMember? member
});


@override $TeamInvitationCopyWith<$Res>? get invitation;@override $TeamMemberCopyWith<$Res>? get member;

}
/// @nodoc
class __$TeamReceiptCopyWithImpl<$Res>
    implements _$TeamReceiptCopyWith<$Res> {
  __$TeamReceiptCopyWithImpl(this._self, this._then);

  final _TeamReceipt _self;
  final $Res Function(_TeamReceipt) _then;

/// Create a copy of TeamReceipt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? state = null,Object? code = freezed,Object? invitation = freezed,Object? member = freezed,}) {
  return _then(_TeamReceipt(
state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,invitation: freezed == invitation ? _self.invitation : invitation // ignore: cast_nullable_to_non_nullable
as TeamInvitation?,member: freezed == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as TeamMember?,
  ));
}

/// Create a copy of TeamReceipt
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamInvitationCopyWith<$Res>? get invitation {
    if (_self.invitation == null) {
    return null;
  }

  return $TeamInvitationCopyWith<$Res>(_self.invitation!, (value) {
    return _then(_self.copyWith(invitation: value));
  });
}/// Create a copy of TeamReceipt
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamMemberCopyWith<$Res>? get member {
    if (_self.member == null) {
    return null;
  }

  return $TeamMemberCopyWith<$Res>(_self.member!, (value) {
    return _then(_self.copyWith(member: value));
  });
}
}

// dart format on
