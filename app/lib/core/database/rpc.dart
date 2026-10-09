/// Names of the Postgres functions repositories call with `supabase.rpc(...)`.
///
/// Membership changes live here because clients have no `UPDATE` on
/// `members.group_id`: creating and joining a group are only possible through
/// these two functions. Every write to a goal is the same — no client
/// `UPDATE` or `DELETE` on `goals` — and the two status functions also write
/// the matching `goal_events` row in the same transaction.
abstract final class Rpc {
  static const createGroup = 'create_group';
  static const joinGroup = 'join_group';
  static const setGoalStatus = 'set_goal_status';
  static const verifyGoal = 'verify_goal';
  static const updateGoalTitle = 'update_goal_title';
  static const deleteGoal = 'delete_goal';

  /// Argument names the SQL functions take. Repositories pass these rather
  /// than repeating the `p_` literals at each call.
  static const pName = 'p_name';
  static const pGroupId = 'p_group_id';
  static const pGoalId = 'p_goal_id';
  static const pStatus = 'p_status';
  static const pTitle = 'p_title';
}
