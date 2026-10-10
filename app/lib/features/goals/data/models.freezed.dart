// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreateGoalCommand {

 String get ownerId; String get groupId; String get title; GoalType get type;@LocalDateTimeConverter() DateTime get deadline;
/// Create a copy of CreateGoalCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateGoalCommandCopyWith<CreateGoalCommand> get copyWith => _$CreateGoalCommandCopyWithImpl<CreateGoalCommand>(this as CreateGoalCommand, _$identity);

  /// Serializes this CreateGoalCommand to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CreateGoalCommand;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateGoalCommand&&(identical(other.ownerId, _this.ownerId) || other.ownerId == _this.ownerId)&&(identical(other.groupId, _this.groupId) || other.groupId == _this.groupId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.deadline, _this.deadline) || other.deadline == _this.deadline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CreateGoalCommand;
  return Object.hash(runtimeType,_this.ownerId,_this.groupId,_this.title,_this.type,_this.deadline);
}

@override
String toString() {
  final _this = this as CreateGoalCommand;
  return 'CreateGoalCommand(ownerId: ${_this.ownerId}, groupId: ${_this.groupId}, title: ${_this.title}, type: ${_this.type}, deadline: ${_this.deadline})';
}


}

/// @nodoc
abstract mixin class $CreateGoalCommandCopyWith<$Res>  {
  factory $CreateGoalCommandCopyWith(CreateGoalCommand value, $Res Function(CreateGoalCommand) _then) = _$CreateGoalCommandCopyWithImpl;
@useResult
$Res call({
 String ownerId, String groupId, String title, GoalType type,@LocalDateTimeConverter() DateTime deadline
});




}
/// @nodoc
class _$CreateGoalCommandCopyWithImpl<$Res>
    implements $CreateGoalCommandCopyWith<$Res> {
  _$CreateGoalCommandCopyWithImpl(this._self, this._then);

  final CreateGoalCommand _self;
  final $Res Function(CreateGoalCommand) _then;

/// Create a copy of CreateGoalCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ownerId = null,Object? groupId = null,Object? title = null,Object? type = null,Object? deadline = null,}) {
  return _then(CreateGoalCommand(
ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as GoalType,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateGoalCommand].
extension CreateGoalCommandPatterns on CreateGoalCommand {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateGoalCommand value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateGoalCommand() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateGoalCommand value)  $default,){
final _that = this;
switch (_that) {
case _CreateGoalCommand():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateGoalCommand value)?  $default,){
final _that = this;
switch (_that) {
case _CreateGoalCommand() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ownerId,  String groupId,  String title,  GoalType type, @LocalDateTimeConverter()  DateTime deadline)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateGoalCommand() when $default != null:
return $default(_that.ownerId,_that.groupId,_that.title,_that.type,_that.deadline);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ownerId,  String groupId,  String title,  GoalType type, @LocalDateTimeConverter()  DateTime deadline)  $default,) {final _that = this;
switch (_that) {
case _CreateGoalCommand():
return $default(_that.ownerId,_that.groupId,_that.title,_that.type,_that.deadline);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ownerId,  String groupId,  String title,  GoalType type, @LocalDateTimeConverter()  DateTime deadline)?  $default,) {final _that = this;
switch (_that) {
case _CreateGoalCommand() when $default != null:
return $default(_that.ownerId,_that.groupId,_that.title,_that.type,_that.deadline);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createFactory: false)

class _CreateGoalCommand implements CreateGoalCommand {
  const _CreateGoalCommand({required this.ownerId, required this.groupId, required this.title, required this.type, @LocalDateTimeConverter() required this.deadline});
  

@override final  String ownerId;
@override final  String groupId;
@override final  String title;
@override final  GoalType type;
@override@LocalDateTimeConverter() final  DateTime deadline;

/// Create a copy of CreateGoalCommand
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateGoalCommandCopyWith<_CreateGoalCommand> get copyWith => __$CreateGoalCommandCopyWithImpl<_CreateGoalCommand>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateGoalCommandToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateGoalCommand&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.deadline, deadline) || other.deadline == deadline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,ownerId,groupId,title,type,deadline);
}

@override
String toString() {
    return 'CreateGoalCommand(ownerId: $ownerId, groupId: $groupId, title: $title, type: $type, deadline: $deadline)';
}


}

/// @nodoc
abstract mixin class _$CreateGoalCommandCopyWith<$Res> implements $CreateGoalCommandCopyWith<$Res> {
  factory _$CreateGoalCommandCopyWith(_CreateGoalCommand value, $Res Function(_CreateGoalCommand) _then) = __$CreateGoalCommandCopyWithImpl;
@override @useResult
$Res call({
 String ownerId, String groupId, String title, GoalType type,@LocalDateTimeConverter() DateTime deadline
});




}
/// @nodoc
class __$CreateGoalCommandCopyWithImpl<$Res>
    implements _$CreateGoalCommandCopyWith<$Res> {
  __$CreateGoalCommandCopyWithImpl(this._self, this._then);

  final _CreateGoalCommand _self;
  final $Res Function(_CreateGoalCommand) _then;

/// Create a copy of CreateGoalCommand
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ownerId = null,Object? groupId = null,Object? title = null,Object? type = null,Object? deadline = null,}) {
  return _then(_CreateGoalCommand(
ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as GoalType,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$AssignGoalCommand {

@JsonKey(name: Rpc.pOwnerId) String get ownerId;@JsonKey(name: Rpc.pTitle) String get title;@JsonKey(name: Rpc.pType) GoalType get type;@JsonKey(name: Rpc.pDeadline)@LocalDateTimeConverter() DateTime get deadline;
/// Create a copy of AssignGoalCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssignGoalCommandCopyWith<AssignGoalCommand> get copyWith => _$AssignGoalCommandCopyWithImpl<AssignGoalCommand>(this as AssignGoalCommand, _$identity);

  /// Serializes this AssignGoalCommand to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AssignGoalCommand;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssignGoalCommand&&(identical(other.ownerId, _this.ownerId) || other.ownerId == _this.ownerId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.deadline, _this.deadline) || other.deadline == _this.deadline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AssignGoalCommand;
  return Object.hash(runtimeType,_this.ownerId,_this.title,_this.type,_this.deadline);
}

@override
String toString() {
  final _this = this as AssignGoalCommand;
  return 'AssignGoalCommand(ownerId: ${_this.ownerId}, title: ${_this.title}, type: ${_this.type}, deadline: ${_this.deadline})';
}


}

/// @nodoc
abstract mixin class $AssignGoalCommandCopyWith<$Res>  {
  factory $AssignGoalCommandCopyWith(AssignGoalCommand value, $Res Function(AssignGoalCommand) _then) = _$AssignGoalCommandCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: Rpc.pOwnerId) String ownerId,@JsonKey(name: Rpc.pTitle) String title,@JsonKey(name: Rpc.pType) GoalType type,@JsonKey(name: Rpc.pDeadline)@LocalDateTimeConverter() DateTime deadline
});




}
/// @nodoc
class _$AssignGoalCommandCopyWithImpl<$Res>
    implements $AssignGoalCommandCopyWith<$Res> {
  _$AssignGoalCommandCopyWithImpl(this._self, this._then);

  final AssignGoalCommand _self;
  final $Res Function(AssignGoalCommand) _then;

/// Create a copy of AssignGoalCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ownerId = null,Object? title = null,Object? type = null,Object? deadline = null,}) {
  return _then(AssignGoalCommand(
ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as GoalType,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AssignGoalCommand].
extension AssignGoalCommandPatterns on AssignGoalCommand {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssignGoalCommand value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssignGoalCommand() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssignGoalCommand value)  $default,){
final _that = this;
switch (_that) {
case _AssignGoalCommand():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssignGoalCommand value)?  $default,){
final _that = this;
switch (_that) {
case _AssignGoalCommand() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: Rpc.pOwnerId)  String ownerId, @JsonKey(name: Rpc.pTitle)  String title, @JsonKey(name: Rpc.pType)  GoalType type, @JsonKey(name: Rpc.pDeadline)@LocalDateTimeConverter()  DateTime deadline)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssignGoalCommand() when $default != null:
return $default(_that.ownerId,_that.title,_that.type,_that.deadline);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: Rpc.pOwnerId)  String ownerId, @JsonKey(name: Rpc.pTitle)  String title, @JsonKey(name: Rpc.pType)  GoalType type, @JsonKey(name: Rpc.pDeadline)@LocalDateTimeConverter()  DateTime deadline)  $default,) {final _that = this;
switch (_that) {
case _AssignGoalCommand():
return $default(_that.ownerId,_that.title,_that.type,_that.deadline);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: Rpc.pOwnerId)  String ownerId, @JsonKey(name: Rpc.pTitle)  String title, @JsonKey(name: Rpc.pType)  GoalType type, @JsonKey(name: Rpc.pDeadline)@LocalDateTimeConverter()  DateTime deadline)?  $default,) {final _that = this;
switch (_that) {
case _AssignGoalCommand() when $default != null:
return $default(_that.ownerId,_that.title,_that.type,_that.deadline);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createFactory: false)

class _AssignGoalCommand implements AssignGoalCommand {
  const _AssignGoalCommand({@JsonKey(name: Rpc.pOwnerId) required this.ownerId, @JsonKey(name: Rpc.pTitle) required this.title, @JsonKey(name: Rpc.pType) required this.type, @JsonKey(name: Rpc.pDeadline)@LocalDateTimeConverter() required this.deadline});
  

@override@JsonKey(name: Rpc.pOwnerId) final  String ownerId;
@override@JsonKey(name: Rpc.pTitle) final  String title;
@override@JsonKey(name: Rpc.pType) final  GoalType type;
@override@JsonKey(name: Rpc.pDeadline)@LocalDateTimeConverter() final  DateTime deadline;

/// Create a copy of AssignGoalCommand
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssignGoalCommandCopyWith<_AssignGoalCommand> get copyWith => __$AssignGoalCommandCopyWithImpl<_AssignGoalCommand>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssignGoalCommandToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssignGoalCommand&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.deadline, deadline) || other.deadline == deadline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,ownerId,title,type,deadline);
}

@override
String toString() {
    return 'AssignGoalCommand(ownerId: $ownerId, title: $title, type: $type, deadline: $deadline)';
}


}

/// @nodoc
abstract mixin class _$AssignGoalCommandCopyWith<$Res> implements $AssignGoalCommandCopyWith<$Res> {
  factory _$AssignGoalCommandCopyWith(_AssignGoalCommand value, $Res Function(_AssignGoalCommand) _then) = __$AssignGoalCommandCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: Rpc.pOwnerId) String ownerId,@JsonKey(name: Rpc.pTitle) String title,@JsonKey(name: Rpc.pType) GoalType type,@JsonKey(name: Rpc.pDeadline)@LocalDateTimeConverter() DateTime deadline
});




}
/// @nodoc
class __$AssignGoalCommandCopyWithImpl<$Res>
    implements _$AssignGoalCommandCopyWith<$Res> {
  __$AssignGoalCommandCopyWithImpl(this._self, this._then);

  final _AssignGoalCommand _self;
  final $Res Function(_AssignGoalCommand) _then;

/// Create a copy of AssignGoalCommand
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ownerId = null,Object? title = null,Object? type = null,Object? deadline = null,}) {
  return _then(_AssignGoalCommand(
ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as GoalType,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
