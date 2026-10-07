import 'package:json_annotation/json_annotation.dart';

/// Where a goal stands. Stored in Postgres as `goal_status`.
///
/// Only [pending] can change: [complete] and [missed] are final, which the
/// status RPCs and `availabilityFor` both enforce.
enum GoalStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('complete')
  complete,
  @JsonValue('missed')
  missed,
}
