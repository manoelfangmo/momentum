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
