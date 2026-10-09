// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Goal _$GoalFromJson(Map<String, dynamic> json) => _Goal(
  id: json['id'] as String,
  ownerId: json['owner_id'] as String,
  groupId: json['group_id'] as String,
  title: json['title'] as String,
  type: $enumDecode(_$GoalTypeEnumMap, json['type']),
  deadline: const LocalDateTimeConverter().fromJson(json['deadline'] as String),
  status: $enumDecode(_$GoalStatusEnumMap, json['status']),
  verified: json['verified'] as bool,
  createdAt: const LocalDateTimeConverter().fromJson(
    json['created_at'] as String,
  ),
);

Map<String, dynamic> _$GoalToJson(_Goal instance) => <String, dynamic>{
  'id': instance.id,
  'owner_id': instance.ownerId,
  'group_id': instance.groupId,
  'title': instance.title,
  'type': _$GoalTypeEnumMap[instance.type]!,
  'deadline': const LocalDateTimeConverter().toJson(instance.deadline),
  'status': _$GoalStatusEnumMap[instance.status]!,
  'verified': instance.verified,
  'created_at': const LocalDateTimeConverter().toJson(instance.createdAt),
};

const _$GoalTypeEnumMap = {
  GoalType.daily: 'daily',
  GoalType.weekly: 'weekly',
  GoalType.monthly: 'monthly',
  GoalType.yearly: 'yearly',
};

const _$GoalStatusEnumMap = {
  GoalStatus.notStarted: 'not_started',
  GoalStatus.inProgress: 'in_progress',
  GoalStatus.complete: 'complete',
};
