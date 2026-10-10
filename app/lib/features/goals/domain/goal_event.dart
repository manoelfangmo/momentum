import 'package:app/core/utils/json_converters.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'goal_status.dart';

part 'goal_event.freezed.dart';
part 'goal_event.g.dart';

/// What happened to a goal. Stored in Postgres as `goal_action`, in the
/// lifecycle order the enum lists: a goal is made, moved, verified, and gone.
enum GoalAction {
  @JsonValue('created')
  created,
  @JsonValue('assigned')
  assigned,
  @JsonValue('status_changed')
  statusChanged,
  @JsonValue('verified')
  verified,
  @JsonValue('unverified')
  unverified,
  @JsonValue('title_edited')
  titleEdited,
  @JsonValue('deleted')
  deleted,
}

/// One thing that happened to a goal, naming who did it and when.
///
/// Events are written by the goal RPCs and by the insert trigger on `goals`,
/// in the same transaction as the row change, never by a client.
/// [newStatus] is set only for [GoalAction.statusChanged].
///
/// [groupId], [goalOwnerId], and [goalTitle] are the goal as it was at that
/// moment, not a join: [goalId] is a plain uuid with no foreign key, so an
/// event outlives the goal it describes. [GoalAction.titleEdited] therefore
/// records only the actor and the time — [goalTitle] is the title it had just
/// been given.
@freezed
abstract class GoalEvent with _$GoalEvent {
  const factory GoalEvent({
    required String id,
    required String goalId,
    required String groupId,
    required String goalOwnerId,
    required String goalTitle,
    required String actorId,
    required GoalAction action,
    GoalStatus? newStatus,
    @LocalDateTimeConverter() required DateTime timestamp,
  }) = _GoalEvent;

  factory GoalEvent.fromJson(Map<String, Object?> json) =>
      _$GoalEventFromJson(json);
}
