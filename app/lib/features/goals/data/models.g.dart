// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$CreateGoalCommandToJson(_CreateGoalCommand instance) =>
    <String, dynamic>{
      'owner_id': instance.ownerId,
      'group_id': instance.groupId,
      'title': instance.title,
      'type': _$GoalTypeEnumMap[instance.type]!,
      'deadline': const LocalDateTimeConverter().toJson(instance.deadline),
    };

const _$GoalTypeEnumMap = {
  GoalType.daily: 'daily',
  GoalType.weekly: 'weekly',
  GoalType.monthly: 'monthly',
  GoalType.yearly: 'yearly',
};

Map<String, dynamic> _$AssignGoalCommandToJson(_AssignGoalCommand instance) =>
    <String, dynamic>{
      'p_owner_id': instance.ownerId,
      'p_title': instance.title,
      'p_type': _$GoalTypeEnumMap[instance.type]!,
      'p_deadline': const LocalDateTimeConverter().toJson(instance.deadline),
    };
