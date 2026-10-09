/// Names in `public.goal_events`.
///
/// [name] is the table, matching `.from(GoalEventsTable.name)`. Clients never
/// insert events: the status RPCs write them in the same transaction.
abstract final class GoalEventsTable {
  static const name = 'goal_events';

  static const id = 'id';
  static const goalId = 'goal_id';
  static const actorId = 'actor_id';
  static const action = 'action';
  static const timestamp = 'timestamp';
  static const newStatus = 'new_status';
}
