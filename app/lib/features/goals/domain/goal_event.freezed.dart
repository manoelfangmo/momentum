// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goal_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GoalEvent {

 String get id; String get goalId; String get actorId; GoalAction get action;@LocalDateTimeConverter() DateTime get timestamp;
/// Create a copy of GoalEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoalEventCopyWith<GoalEvent> get copyWith => _$GoalEventCopyWithImpl<GoalEvent>(this as GoalEvent, _$identity);

  /// Serializes this GoalEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GoalEvent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoalEvent&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.goalId, _this.goalId) || other.goalId == _this.goalId)&&(identical(other.actorId, _this.actorId) || other.actorId == _this.actorId)&&(identical(other.action, _this.action) || other.action == _this.action)&&(identical(other.timestamp, _this.timestamp) || other.timestamp == _this.timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GoalEvent;
  return Object.hash(runtimeType,_this.id,_this.goalId,_this.actorId,_this.action,_this.timestamp);
}

@override
String toString() {
  final _this = this as GoalEvent;
  return 'GoalEvent(id: ${_this.id}, goalId: ${_this.goalId}, actorId: ${_this.actorId}, action: ${_this.action}, timestamp: ${_this.timestamp})';
}


}

/// @nodoc
abstract mixin class $GoalEventCopyWith<$Res>  {
  factory $GoalEventCopyWith(GoalEvent value, $Res Function(GoalEvent) _then) = _$GoalEventCopyWithImpl;
@useResult
$Res call({
 String id, String goalId, String actorId, GoalAction action,@LocalDateTimeConverter() DateTime timestamp
});




}
/// @nodoc
class _$GoalEventCopyWithImpl<$Res>
    implements $GoalEventCopyWith<$Res> {
  _$GoalEventCopyWithImpl(this._self, this._then);

  final GoalEvent _self;
  final $Res Function(GoalEvent) _then;

/// Create a copy of GoalEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? goalId = null,Object? actorId = null,Object? action = null,Object? timestamp = null,}) {
  return _then(GoalEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,goalId: null == goalId ? _self.goalId : goalId // ignore: cast_nullable_to_non_nullable
as String,actorId: null == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as GoalAction,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [GoalEvent].
extension GoalEventPatterns on GoalEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoalEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoalEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoalEvent value)  $default,){
final _that = this;
switch (_that) {
case _GoalEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoalEvent value)?  $default,){
final _that = this;
switch (_that) {
case _GoalEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String goalId,  String actorId,  GoalAction action, @LocalDateTimeConverter()  DateTime timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoalEvent() when $default != null:
return $default(_that.id,_that.goalId,_that.actorId,_that.action,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String goalId,  String actorId,  GoalAction action, @LocalDateTimeConverter()  DateTime timestamp)  $default,) {final _that = this;
switch (_that) {
case _GoalEvent():
return $default(_that.id,_that.goalId,_that.actorId,_that.action,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String goalId,  String actorId,  GoalAction action, @LocalDateTimeConverter()  DateTime timestamp)?  $default,) {final _that = this;
switch (_that) {
case _GoalEvent() when $default != null:
return $default(_that.id,_that.goalId,_that.actorId,_that.action,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoalEvent implements GoalEvent {
  const _GoalEvent({required this.id, required this.goalId, required this.actorId, required this.action, @LocalDateTimeConverter() required this.timestamp});
  factory _GoalEvent.fromJson(Map<String, dynamic> json) => _$GoalEventFromJson(json);

@override final  String id;
@override final  String goalId;
@override final  String actorId;
@override final  GoalAction action;
@override@LocalDateTimeConverter() final  DateTime timestamp;

/// Create a copy of GoalEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoalEventCopyWith<_GoalEvent> get copyWith => __$GoalEventCopyWithImpl<_GoalEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoalEventToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoalEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.goalId, goalId) || other.goalId == goalId)&&(identical(other.actorId, actorId) || other.actorId == actorId)&&(identical(other.action, action) || other.action == action)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,goalId,actorId,action,timestamp);
}

@override
String toString() {
    return 'GoalEvent(id: $id, goalId: $goalId, actorId: $actorId, action: $action, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$GoalEventCopyWith<$Res> implements $GoalEventCopyWith<$Res> {
  factory _$GoalEventCopyWith(_GoalEvent value, $Res Function(_GoalEvent) _then) = __$GoalEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String goalId, String actorId, GoalAction action,@LocalDateTimeConverter() DateTime timestamp
});




}
/// @nodoc
class __$GoalEventCopyWithImpl<$Res>
    implements _$GoalEventCopyWith<$Res> {
  __$GoalEventCopyWithImpl(this._self, this._then);

  final _GoalEvent _self;
  final $Res Function(_GoalEvent) _then;

/// Create a copy of GoalEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? goalId = null,Object? actorId = null,Object? action = null,Object? timestamp = null,}) {
  return _then(_GoalEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,goalId: null == goalId ? _self.goalId : goalId // ignore: cast_nullable_to_non_nullable
as String,actorId: null == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as GoalAction,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
