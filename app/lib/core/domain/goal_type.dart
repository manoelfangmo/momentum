import 'package:json_annotation/json_annotation.dart';

/// How long a goal lasts. Stored in Postgres as `goal_type`.
enum GoalType {
  @JsonValue('daily')
  daily,
  @JsonValue('weekly')
  weekly,
  @JsonValue('monthly')
  monthly,
  @JsonValue('yearly')
  yearly;

  /// Value written to the `goal_type` enum.
  String toDb() => switch (this) {
    GoalType.daily => 'daily',
    GoalType.weekly => 'weekly',
    GoalType.monthly => 'monthly',
    GoalType.yearly => 'yearly',
  };

  static GoalType fromDb(String value) => switch (value) {
    'daily' => GoalType.daily,
    'weekly' => GoalType.weekly,
    'monthly' => GoalType.monthly,
    'yearly' => GoalType.yearly,
    _ => throw ArgumentError.value(value, 'value', 'Unknown goal type'),
  };

  /// Tab label: Day, Week, Month, or Year.
  String get label => switch (this) {
    GoalType.daily => 'Day',
    GoalType.weekly => 'Week',
    GoalType.monthly => 'Month',
    GoalType.yearly => 'Year',
  };
}
