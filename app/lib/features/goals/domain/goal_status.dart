import 'package:json_annotation/json_annotation.dart';

/// Where a goal stands. Stored in Postgres as `goal_status`.
///
/// The owner can move between any of these while the goal is unverified.
/// Once another member verifies it, [complete] and `verified` are final.
enum GoalStatus {
  @JsonValue('not_started')
  notStarted,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('complete')
  complete;

  /// Value written to the `goal_status` enum.
  String toDb() => switch (this) {
    GoalStatus.notStarted => 'not_started',
    GoalStatus.inProgress => 'in_progress',
    GoalStatus.complete => 'complete',
  };

  static GoalStatus fromDb(String value) => switch (value) {
    'not_started' => GoalStatus.notStarted,
    'in_progress' => GoalStatus.inProgress,
    'complete' => GoalStatus.complete,
    _ => throw ArgumentError.value(value, 'value', 'Unknown goal status'),
  };

  /// Pill / list label: Not started, In progress, or Complete.
  String get label => switch (this) {
    GoalStatus.notStarted => 'Not started',
    GoalStatus.inProgress => 'In progress',
    GoalStatus.complete => 'Complete',
  };
}
