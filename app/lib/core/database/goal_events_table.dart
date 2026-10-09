/// Names in `public.goal_events`.
///
/// [name] is the table, matching `.from(GoalEventsTable.name)`. Clients never
/// insert events: the goal RPCs and the insert trigger on `goals` write them
/// in the same transaction as the change.
///
/// [goalId] is a plain uuid, not a foreign key, and [groupId], [goalOwnerId],
/// and [goalTitle] are the goal as it was at that moment. An event outlives
/// the goal it describes.
abstract final class GoalEventsTable {
  static const name = 'goal_events';

  static const id = 'id';
  static const goalId = 'goal_id';
  static const actorId = 'actor_id';
  static const action = 'action';
  static const timestamp = 'timestamp';
  static const newStatus = 'new_status';
  static const groupId = 'group_id';
  static const goalOwnerId = 'goal_owner_id';
  static const goalTitle = 'goal_title';
}
