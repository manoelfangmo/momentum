import 'package:app/core/utils/json_converters.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal_event.freezed.dart';
part 'goal_event.g.dart';

/// What a member did to a goal. Stored in Postgres as `goal_action`.
enum GoalAction {
  @JsonValue('verified_complete')
  verifiedComplete,
  @JsonValue('marked_missed')
  markedMissed,
}

/// One status change, naming who made it and when.
///
/// Events are written by `verify_goal_complete` and `mark_goal_missed` in the
/// same transaction as the status change, never by a client.
@freezed
abstract class GoalEvent with _$GoalEvent {
  const factory GoalEvent({
    required String id,
    required String goalId,
    required String actorId,
    required GoalAction action,
    @LocalDateTimeConverter() required DateTime timestamp,
  }) = _GoalEvent;

  factory GoalEvent.fromJson(Map<String, Object?> json) =>
      _$GoalEventFromJson(json);
}
