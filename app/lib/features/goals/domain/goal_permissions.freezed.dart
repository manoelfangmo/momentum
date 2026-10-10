// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goal_permissions.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GoalPermissions {

 bool get canChangeStatus; bool get canVerify; bool get canUnverify; bool get canEdit; bool get canDelete;
/// Create a copy of GoalPermissions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoalPermissionsCopyWith<GoalPermissions> get copyWith => _$GoalPermissionsCopyWithImpl<GoalPermissions>(this as GoalPermissions, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as GoalPermissions;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoalPermissions&&(identical(other.canChangeStatus, _this.canChangeStatus) || other.canChangeStatus == _this.canChangeStatus)&&(identical(other.canVerify, _this.canVerify) || other.canVerify == _this.canVerify)&&(identical(other.canUnverify, _this.canUnverify) || other.canUnverify == _this.canUnverify)&&(identical(other.canEdit, _this.canEdit) || other.canEdit == _this.canEdit)&&(identical(other.canDelete, _this.canDelete) || other.canDelete == _this.canDelete));
}


@override
int get hashCode {
  final _this = this as GoalPermissions;
  return Object.hash(runtimeType,_this.canChangeStatus,_this.canVerify,_this.canUnverify,_this.canEdit,_this.canDelete);
}

@override
String toString() {
  final _this = this as GoalPermissions;
  return 'GoalPermissions(canChangeStatus: ${_this.canChangeStatus}, canVerify: ${_this.canVerify}, canUnverify: ${_this.canUnverify}, canEdit: ${_this.canEdit}, canDelete: ${_this.canDelete})';
}


}

/// @nodoc
abstract mixin class $GoalPermissionsCopyWith<$Res>  {
  factory $GoalPermissionsCopyWith(GoalPermissions value, $Res Function(GoalPermissions) _then) = _$GoalPermissionsCopyWithImpl;
@useResult
$Res call({
 bool canChangeStatus, bool canVerify, bool canUnverify, bool canEdit, bool canDelete
});




}
/// @nodoc
class _$GoalPermissionsCopyWithImpl<$Res>
    implements $GoalPermissionsCopyWith<$Res> {
  _$GoalPermissionsCopyWithImpl(this._self, this._then);

  final GoalPermissions _self;
  final $Res Function(GoalPermissions) _then;

/// Create a copy of GoalPermissions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? canChangeStatus = null,Object? canVerify = null,Object? canUnverify = null,Object? canEdit = null,Object? canDelete = null,}) {
  return _then(GoalPermissions(
canChangeStatus: null == canChangeStatus ? _self.canChangeStatus : canChangeStatus // ignore: cast_nullable_to_non_nullable
as bool,canVerify: null == canVerify ? _self.canVerify : canVerify // ignore: cast_nullable_to_non_nullable
as bool,canUnverify: null == canUnverify ? _self.canUnverify : canUnverify // ignore: cast_nullable_to_non_nullable
as bool,canEdit: null == canEdit ? _self.canEdit : canEdit // ignore: cast_nullable_to_non_nullable
as bool,canDelete: null == canDelete ? _self.canDelete : canDelete // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GoalPermissions].
extension GoalPermissionsPatterns on GoalPermissions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoalPermissions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoalPermissions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoalPermissions value)  $default,){
final _that = this;
switch (_that) {
case _GoalPermissions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoalPermissions value)?  $default,){
final _that = this;
switch (_that) {
case _GoalPermissions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool canChangeStatus,  bool canVerify,  bool canUnverify,  bool canEdit,  bool canDelete)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoalPermissions() when $default != null:
return $default(_that.canChangeStatus,_that.canVerify,_that.canUnverify,_that.canEdit,_that.canDelete);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool canChangeStatus,  bool canVerify,  bool canUnverify,  bool canEdit,  bool canDelete)  $default,) {final _that = this;
switch (_that) {
case _GoalPermissions():
return $default(_that.canChangeStatus,_that.canVerify,_that.canUnverify,_that.canEdit,_that.canDelete);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool canChangeStatus,  bool canVerify,  bool canUnverify,  bool canEdit,  bool canDelete)?  $default,) {final _that = this;
switch (_that) {
case _GoalPermissions() when $default != null:
return $default(_that.canChangeStatus,_that.canVerify,_that.canUnverify,_that.canEdit,_that.canDelete);case _:
  return null;

}
}

}

/// @nodoc


class _GoalPermissions implements GoalPermissions {
  const _GoalPermissions({required this.canChangeStatus, required this.canVerify, required this.canUnverify, required this.canEdit, required this.canDelete});
  

@override final  bool canChangeStatus;
@override final  bool canVerify;
@override final  bool canUnverify;
@override final  bool canEdit;
@override final  bool canDelete;

/// Create a copy of GoalPermissions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoalPermissionsCopyWith<_GoalPermissions> get copyWith => __$GoalPermissionsCopyWithImpl<_GoalPermissions>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoalPermissions&&(identical(other.canChangeStatus, canChangeStatus) || other.canChangeStatus == canChangeStatus)&&(identical(other.canVerify, canVerify) || other.canVerify == canVerify)&&(identical(other.canUnverify, canUnverify) || other.canUnverify == canUnverify)&&(identical(other.canEdit, canEdit) || other.canEdit == canEdit)&&(identical(other.canDelete, canDelete) || other.canDelete == canDelete));
}


@override
int get hashCode {
    return Object.hash(runtimeType,canChangeStatus,canVerify,canUnverify,canEdit,canDelete);
}

@override
String toString() {
    return 'GoalPermissions(canChangeStatus: $canChangeStatus, canVerify: $canVerify, canUnverify: $canUnverify, canEdit: $canEdit, canDelete: $canDelete)';
}


}

/// @nodoc
abstract mixin class _$GoalPermissionsCopyWith<$Res> implements $GoalPermissionsCopyWith<$Res> {
  factory _$GoalPermissionsCopyWith(_GoalPermissions value, $Res Function(_GoalPermissions) _then) = __$GoalPermissionsCopyWithImpl;
@override @useResult
$Res call({
 bool canChangeStatus, bool canVerify, bool canUnverify, bool canEdit, bool canDelete
});




}
/// @nodoc
class __$GoalPermissionsCopyWithImpl<$Res>
    implements _$GoalPermissionsCopyWith<$Res> {
  __$GoalPermissionsCopyWithImpl(this._self, this._then);

  final _GoalPermissions _self;
  final $Res Function(_GoalPermissions) _then;

/// Create a copy of GoalPermissions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? canChangeStatus = null,Object? canVerify = null,Object? canUnverify = null,Object? canEdit = null,Object? canDelete = null,}) {
  return _then(_GoalPermissions(
canChangeStatus: null == canChangeStatus ? _self.canChangeStatus : canChangeStatus // ignore: cast_nullable_to_non_nullable
as bool,canVerify: null == canVerify ? _self.canVerify : canVerify // ignore: cast_nullable_to_non_nullable
as bool,canUnverify: null == canUnverify ? _self.canUnverify : canUnverify // ignore: cast_nullable_to_non_nullable
as bool,canEdit: null == canEdit ? _self.canEdit : canEdit // ignore: cast_nullable_to_non_nullable
as bool,canDelete: null == canDelete ? _self.canDelete : canDelete // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
