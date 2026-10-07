// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_goal_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreateGoalFormState {

 String get title;
/// Create a copy of CreateGoalFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateGoalFormStateCopyWith<CreateGoalFormState> get copyWith => _$CreateGoalFormStateCopyWithImpl<CreateGoalFormState>(this as CreateGoalFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CreateGoalFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateGoalFormState&&(identical(other.title, _this.title) || other.title == _this.title));
}


@override
int get hashCode {
  final _this = this as CreateGoalFormState;
  return Object.hash(runtimeType,_this.title);
}

@override
String toString() {
  final _this = this as CreateGoalFormState;
  return 'CreateGoalFormState(title: ${_this.title})';
}


}

/// @nodoc
abstract mixin class $CreateGoalFormStateCopyWith<$Res>  {
  factory $CreateGoalFormStateCopyWith(CreateGoalFormState value, $Res Function(CreateGoalFormState) _then) = _$CreateGoalFormStateCopyWithImpl;
@useResult
$Res call({
 String title
});




}
/// @nodoc
class _$CreateGoalFormStateCopyWithImpl<$Res>
    implements $CreateGoalFormStateCopyWith<$Res> {
  _$CreateGoalFormStateCopyWithImpl(this._self, this._then);

  final CreateGoalFormState _self;
  final $Res Function(CreateGoalFormState) _then;

/// Create a copy of CreateGoalFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,}) {
  return _then(CreateGoalFormState(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateGoalFormState].
extension CreateGoalFormStatePatterns on CreateGoalFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateGoalFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateGoalFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateGoalFormState value)  $default,){
final _that = this;
switch (_that) {
case _CreateGoalFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateGoalFormState value)?  $default,){
final _that = this;
switch (_that) {
case _CreateGoalFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateGoalFormState() when $default != null:
return $default(_that.title);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title)  $default,) {final _that = this;
switch (_that) {
case _CreateGoalFormState():
return $default(_that.title);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title)?  $default,) {final _that = this;
switch (_that) {
case _CreateGoalFormState() when $default != null:
return $default(_that.title);case _:
  return null;

}
}

}

/// @nodoc


class _CreateGoalFormState implements CreateGoalFormState {
  const _CreateGoalFormState({this.title = ''});
  

@override@JsonKey() final  String title;

/// Create a copy of CreateGoalFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateGoalFormStateCopyWith<_CreateGoalFormState> get copyWith => __$CreateGoalFormStateCopyWithImpl<_CreateGoalFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateGoalFormState&&(identical(other.title, title) || other.title == title));
}


@override
int get hashCode {
    return Object.hash(runtimeType,title);
}

@override
String toString() {
    return 'CreateGoalFormState(title: $title)';
}


}

/// @nodoc
abstract mixin class _$CreateGoalFormStateCopyWith<$Res> implements $CreateGoalFormStateCopyWith<$Res> {
  factory _$CreateGoalFormStateCopyWith(_CreateGoalFormState value, $Res Function(_CreateGoalFormState) _then) = __$CreateGoalFormStateCopyWithImpl;
@override @useResult
$Res call({
 String title
});




}
/// @nodoc
class __$CreateGoalFormStateCopyWithImpl<$Res>
    implements _$CreateGoalFormStateCopyWith<$Res> {
  __$CreateGoalFormStateCopyWithImpl(this._self, this._then);

  final _CreateGoalFormState _self;
  final $Res Function(_CreateGoalFormState) _then;

/// Create a copy of CreateGoalFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,}) {
  return _then(_CreateGoalFormState(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
