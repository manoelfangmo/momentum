// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GoalEvent _$GoalEventFromJson(Map<String, dynamic> json) => _GoalEvent(
  id: json['id'] as String,
  goalId: json['goal_id'] as String,
  groupId: json['group_id'] as String,
  goalOwnerId: json['goal_owner_id'] as String,
  goalTitle: json['goal_title'] as String,
  actorId: json['actor_id'] as String,
  action: $enumDecode(_$GoalActionEnumMap, json['action']),
  newStatus: $enumDecodeNullable(_$GoalStatusEnumMap, json['new_status']),
  timestamp: const LocalDateTimeConverter().fromJson(
    json['timestamp'] as String,
  ),
);

Map<String, dynamic> _$GoalEventToJson(_GoalEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'goal_id': instance.goalId,
      'group_id': instance.groupId,
      'goal_owner_id': instance.goalOwnerId,
      'goal_title': instance.goalTitle,
      'actor_id': instance.actorId,
      'action': _$GoalActionEnumMap[instance.action]!,
      'new_status': _$GoalStatusEnumMap[instance.newStatus],
      'timestamp': const LocalDateTimeConverter().toJson(instance.timestamp),
    };

const _$GoalActionEnumMap = {
  GoalAction.created: 'created',
  GoalAction.assigned: 'assigned',
  GoalAction.statusChanged: 'status_changed',
  GoalAction.verified: 'verified',
  GoalAction.unverified: 'unverified',
  GoalAction.titleEdited: 'title_edited',
  GoalAction.deleted: 'deleted',
};

const _$GoalStatusEnumMap = {
  GoalStatus.notStarted: 'not_started',
  GoalStatus.inProgress: 'in_progress',
  GoalStatus.complete: 'complete',
};
