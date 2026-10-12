// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member_goals.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MemberGoals {

 Member get member; List<Goal> get goals;
/// Create a copy of MemberGoals
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberGoalsCopyWith<MemberGoals> get copyWith => _$MemberGoalsCopyWithImpl<MemberGoals>(this as MemberGoals, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MemberGoals;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberGoals&&(identical(other.member, _this.member) || other.member == _this.member)&&const DeepCollectionEquality().equals(other.goals, _this.goals));
}


@override
int get hashCode {
  final _this = this as MemberGoals;
  return Object.hash(runtimeType,_this.member,const DeepCollectionEquality().hash(_this.goals));
}

@override
String toString() {
  final _this = this as MemberGoals;
  return 'MemberGoals(member: ${_this.member}, goals: ${_this.goals})';
}


}

/// @nodoc
abstract mixin class $MemberGoalsCopyWith<$Res>  {
  factory $MemberGoalsCopyWith(MemberGoals value, $Res Function(MemberGoals) _then) = _$MemberGoalsCopyWithImpl;
@useResult
$Res call({
 Member member, List<Goal> goals
});


$MemberCopyWith<$Res> get member;

}
/// @nodoc
class _$MemberGoalsCopyWithImpl<$Res>
    implements $MemberGoalsCopyWith<$Res> {
  _$MemberGoalsCopyWithImpl(this._self, this._then);

  final MemberGoals _self;
  final $Res Function(MemberGoals) _then;

/// Create a copy of MemberGoals
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? member = null,Object? goals = null,}) {
  return _then(MemberGoals(
member: null == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as Member,goals: null == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as List<Goal>,
  ));
}
/// Create a copy of MemberGoals
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MemberCopyWith<$Res> get member {
  
  return $MemberCopyWith<$Res>(_self.member, (value) {
    return _then(_self.copyWith(member: value));
  });
}
}


/// Adds pattern-matching-related methods to [MemberGoals].
extension MemberGoalsPatterns on MemberGoals {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberGoals value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberGoals() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberGoals value)  $default,){
final _that = this;
switch (_that) {
case _MemberGoals():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberGoals value)?  $default,){
final _that = this;
switch (_that) {
case _MemberGoals() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Member member,  List<Goal> goals)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberGoals() when $default != null:
return $default(_that.member,_that.goals);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Member member,  List<Goal> goals)  $default,) {final _that = this;
switch (_that) {
case _MemberGoals():
return $default(_that.member,_that.goals);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Member member,  List<Goal> goals)?  $default,) {final _that = this;
switch (_that) {
case _MemberGoals() when $default != null:
return $default(_that.member,_that.goals);case _:
  return null;

}
}

}

/// @nodoc


class _MemberGoals implements MemberGoals {
  const _MemberGoals({required this.member, required  List<Goal> goals}): _goals = goals;
  

@override final  Member member;
 final  List<Goal> _goals;
@override List<Goal> get goals {
  if (_goals is EqualUnmodifiableListView) return _goals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_goals);
}


/// Create a copy of MemberGoals
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberGoalsCopyWith<_MemberGoals> get copyWith => __$MemberGoalsCopyWithImpl<_MemberGoals>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberGoals&&(identical(other.member, member) || other.member == member)&&const DeepCollectionEquality().equals(other.goals, _goals));
}


@override
int get hashCode {
    return Object.hash(runtimeType,member,const DeepCollectionEquality().hash(_goals));
}

@override
String toString() {
    return 'MemberGoals(member: $member, goals: $goals)';
}


}

/// @nodoc
abstract mixin class _$MemberGoalsCopyWith<$Res> implements $MemberGoalsCopyWith<$Res> {
  factory _$MemberGoalsCopyWith(_MemberGoals value, $Res Function(_MemberGoals) _then) = __$MemberGoalsCopyWithImpl;
@override @useResult
$Res call({
 Member member, List<Goal> goals
});


@override $MemberCopyWith<$Res> get member;

}
/// @nodoc
class __$MemberGoalsCopyWithImpl<$Res>
    implements _$MemberGoalsCopyWith<$Res> {
  __$MemberGoalsCopyWithImpl(this._self, this._then);

  final _MemberGoals _self;
  final $Res Function(_MemberGoals) _then;

/// Create a copy of MemberGoals
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? member = null,Object? goals = null,}) {
  return _then(_MemberGoals(
member: null == member ? _self.member : member // ignore: cast_nullable_to_non_nullable
as Member,goals: null == goals ? _self._goals : goals // ignore: cast_nullable_to_non_nullable
as List<Goal>,
  ));
}

/// Create a copy of MemberGoals
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MemberCopyWith<$Res> get member {
  
  return $MemberCopyWith<$Res>(_self.member, (value) {
    return _then(_self.copyWith(member: value));
  });
}
}

// dart format on
