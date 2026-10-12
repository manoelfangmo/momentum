// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assign_goal_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AssignGoalFormState {

 String? get ownerId; String get title;
/// Create a copy of AssignGoalFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssignGoalFormStateCopyWith<AssignGoalFormState> get copyWith => _$AssignGoalFormStateCopyWithImpl<AssignGoalFormState>(this as AssignGoalFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AssignGoalFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssignGoalFormState&&(identical(other.ownerId, _this.ownerId) || other.ownerId == _this.ownerId)&&(identical(other.title, _this.title) || other.title == _this.title));
}


@override
int get hashCode {
  final _this = this as AssignGoalFormState;
  return Object.hash(runtimeType,_this.ownerId,_this.title);
}

@override
String toString() {
  final _this = this as AssignGoalFormState;
  return 'AssignGoalFormState(ownerId: ${_this.ownerId}, title: ${_this.title})';
}


}

/// @nodoc
abstract mixin class $AssignGoalFormStateCopyWith<$Res>  {
  factory $AssignGoalFormStateCopyWith(AssignGoalFormState value, $Res Function(AssignGoalFormState) _then) = _$AssignGoalFormStateCopyWithImpl;
@useResult
$Res call({
 String? ownerId, String title
});




}
/// @nodoc
class _$AssignGoalFormStateCopyWithImpl<$Res>
    implements $AssignGoalFormStateCopyWith<$Res> {
  _$AssignGoalFormStateCopyWithImpl(this._self, this._then);

  final AssignGoalFormState _self;
  final $Res Function(AssignGoalFormState) _then;

/// Create a copy of AssignGoalFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ownerId = freezed,Object? title = null,}) {
  return _then(AssignGoalFormState(
ownerId: freezed == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AssignGoalFormState].
extension AssignGoalFormStatePatterns on AssignGoalFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssignGoalFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssignGoalFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssignGoalFormState value)  $default,){
final _that = this;
switch (_that) {
case _AssignGoalFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssignGoalFormState value)?  $default,){
final _that = this;
switch (_that) {
case _AssignGoalFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? ownerId,  String title)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssignGoalFormState() when $default != null:
return $default(_that.ownerId,_that.title);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? ownerId,  String title)  $default,) {final _that = this;
switch (_that) {
case _AssignGoalFormState():
return $default(_that.ownerId,_that.title);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? ownerId,  String title)?  $default,) {final _that = this;
switch (_that) {
case _AssignGoalFormState() when $default != null:
return $default(_that.ownerId,_that.title);case _:
  return null;

}
}

}

/// @nodoc


class _AssignGoalFormState implements AssignGoalFormState {
  const _AssignGoalFormState({this.ownerId, this.title = ''});
  

@override final  String? ownerId;
@override@JsonKey() final  String title;

/// Create a copy of AssignGoalFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssignGoalFormStateCopyWith<_AssignGoalFormState> get copyWith => __$AssignGoalFormStateCopyWithImpl<_AssignGoalFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssignGoalFormState&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.title, title) || other.title == title));
}


@override
int get hashCode {
    return Object.hash(runtimeType,ownerId,title);
}

@override
String toString() {
    return 'AssignGoalFormState(ownerId: $ownerId, title: $title)';
}


}

/// @nodoc
abstract mixin class _$AssignGoalFormStateCopyWith<$Res> implements $AssignGoalFormStateCopyWith<$Res> {
  factory _$AssignGoalFormStateCopyWith(_AssignGoalFormState value, $Res Function(_AssignGoalFormState) _then) = __$AssignGoalFormStateCopyWithImpl;
@override @useResult
$Res call({
 String? ownerId, String title
});




}
/// @nodoc
class __$AssignGoalFormStateCopyWithImpl<$Res>
    implements _$AssignGoalFormStateCopyWith<$Res> {
  __$AssignGoalFormStateCopyWithImpl(this._self, this._then);

  final _AssignGoalFormState _self;
  final $Res Function(_AssignGoalFormState) _then;

/// Create a copy of AssignGoalFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ownerId = freezed,Object? title = null,}) {
  return _then(_AssignGoalFormState(
ownerId: freezed == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
