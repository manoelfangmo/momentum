// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goals_view_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GoalsViewState {

 String get selectedMemberId; DateTime get selectedDay;
/// Create a copy of GoalsViewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoalsViewStateCopyWith<GoalsViewState> get copyWith => _$GoalsViewStateCopyWithImpl<GoalsViewState>(this as GoalsViewState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as GoalsViewState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoalsViewState&&(identical(other.selectedMemberId, _this.selectedMemberId) || other.selectedMemberId == _this.selectedMemberId)&&(identical(other.selectedDay, _this.selectedDay) || other.selectedDay == _this.selectedDay));
}


@override
int get hashCode {
  final _this = this as GoalsViewState;
  return Object.hash(runtimeType,_this.selectedMemberId,_this.selectedDay);
}

@override
String toString() {
  final _this = this as GoalsViewState;
  return 'GoalsViewState(selectedMemberId: ${_this.selectedMemberId}, selectedDay: ${_this.selectedDay})';
}


}

/// @nodoc
abstract mixin class $GoalsViewStateCopyWith<$Res>  {
  factory $GoalsViewStateCopyWith(GoalsViewState value, $Res Function(GoalsViewState) _then) = _$GoalsViewStateCopyWithImpl;
@useResult
$Res call({
 String selectedMemberId, DateTime selectedDay
});




}
/// @nodoc
class _$GoalsViewStateCopyWithImpl<$Res>
    implements $GoalsViewStateCopyWith<$Res> {
  _$GoalsViewStateCopyWithImpl(this._self, this._then);

  final GoalsViewState _self;
  final $Res Function(GoalsViewState) _then;

/// Create a copy of GoalsViewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedMemberId = null,Object? selectedDay = null,}) {
  return _then(GoalsViewState(
selectedMemberId: null == selectedMemberId ? _self.selectedMemberId : selectedMemberId // ignore: cast_nullable_to_non_nullable
as String,selectedDay: null == selectedDay ? _self.selectedDay : selectedDay // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [GoalsViewState].
extension GoalsViewStatePatterns on GoalsViewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoalsViewState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoalsViewState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoalsViewState value)  $default,){
final _that = this;
switch (_that) {
case _GoalsViewState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoalsViewState value)?  $default,){
final _that = this;
switch (_that) {
case _GoalsViewState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String selectedMemberId,  DateTime selectedDay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoalsViewState() when $default != null:
return $default(_that.selectedMemberId,_that.selectedDay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String selectedMemberId,  DateTime selectedDay)  $default,) {final _that = this;
switch (_that) {
case _GoalsViewState():
return $default(_that.selectedMemberId,_that.selectedDay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String selectedMemberId,  DateTime selectedDay)?  $default,) {final _that = this;
switch (_that) {
case _GoalsViewState() when $default != null:
return $default(_that.selectedMemberId,_that.selectedDay);case _:
  return null;

}
}

}

/// @nodoc


class _GoalsViewState implements GoalsViewState {
  const _GoalsViewState({required this.selectedMemberId, required this.selectedDay});
  

@override final  String selectedMemberId;
@override final  DateTime selectedDay;

/// Create a copy of GoalsViewState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoalsViewStateCopyWith<_GoalsViewState> get copyWith => __$GoalsViewStateCopyWithImpl<_GoalsViewState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoalsViewState&&(identical(other.selectedMemberId, selectedMemberId) || other.selectedMemberId == selectedMemberId)&&(identical(other.selectedDay, selectedDay) || other.selectedDay == selectedDay));
}


@override
int get hashCode {
    return Object.hash(runtimeType,selectedMemberId,selectedDay);
}

@override
String toString() {
    return 'GoalsViewState(selectedMemberId: $selectedMemberId, selectedDay: $selectedDay)';
}


}

/// @nodoc
abstract mixin class _$GoalsViewStateCopyWith<$Res> implements $GoalsViewStateCopyWith<$Res> {
  factory _$GoalsViewStateCopyWith(_GoalsViewState value, $Res Function(_GoalsViewState) _then) = __$GoalsViewStateCopyWithImpl;
@override @useResult
$Res call({
 String selectedMemberId, DateTime selectedDay
});




}
/// @nodoc
class __$GoalsViewStateCopyWithImpl<$Res>
    implements _$GoalsViewStateCopyWith<$Res> {
  __$GoalsViewStateCopyWithImpl(this._self, this._then);

  final _GoalsViewState _self;
  final $Res Function(_GoalsViewState) _then;

/// Create a copy of GoalsViewState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedMemberId = null,Object? selectedDay = null,}) {
  return _then(_GoalsViewState(
selectedMemberId: null == selectedMemberId ? _self.selectedMemberId : selectedMemberId // ignore: cast_nullable_to_non_nullable
as String,selectedDay: null == selectedDay ? _self.selectedDay : selectedDay // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
