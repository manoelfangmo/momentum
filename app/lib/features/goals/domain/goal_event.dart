import 'package:app/core/utils/json_converters.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'goal_status.dart';

part 'goal_event.freezed.dart';
part 'goal_event.g.dart';

/// What a member did to a goal. Stored in Postgres as `goal_action`.
enum GoalAction {
  @JsonValue('status_changed')
  statusChanged,
  @JsonValue('verified')
  verified,
}

/// One status change or verification, naming who made it and when.
///
/// Events are written by `set_goal_status` and `verify_goal` in the same
/// transaction as the row change, never by a client. [newStatus] is set only
/// for [GoalAction.statusChanged].
@freezed
abstract class GoalEvent with _$GoalEvent {
  const factory GoalEvent({
    required String id,
    required String goalId,
    required String actorId,
    required GoalAction action,
    GoalStatus? newStatus,
    @LocalDateTimeConverter() required DateTime timestamp,
  }) = _GoalEvent;

  factory GoalEvent.fromJson(Map<String, Object?> json) =>
      _$GoalEventFromJson(json);
}
