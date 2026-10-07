// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GoalEvent _$GoalEventFromJson(Map<String, dynamic> json) => _GoalEvent(
  id: json['id'] as String,
  goalId: json['goal_id'] as String,
  actorId: json['actor_id'] as String,
  action: $enumDecode(_$GoalActionEnumMap, json['action']),
  timestamp: const LocalDateTimeConverter().fromJson(
    json['timestamp'] as String,
  ),
);

Map<String, dynamic> _$GoalEventToJson(_GoalEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'goal_id': instance.goalId,
      'actor_id': instance.actorId,
      'action': _$GoalActionEnumMap[instance.action]!,
      'timestamp': const LocalDateTimeConverter().toJson(instance.timestamp),
    };

const _$GoalActionEnumMap = {
  GoalAction.verifiedComplete: 'verified_complete',
  GoalAction.markedMissed: 'marked_missed',
};
