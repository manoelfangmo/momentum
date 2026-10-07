/// Names of the Postgres functions repositories call with `supabase.rpc(...)`.
///
/// Membership changes live here because clients have no `UPDATE` on
/// `members.group_id`: creating and joining a group are only possible through
/// these two functions. Goal status changes are the same — no client `UPDATE`
/// on `goals` — and each function writes the matching `goal_events` row in the
/// same transaction.
abstract final class Rpc {
  static const createGroup = 'create_group';
  static const joinGroup = 'join_group';
  static const verifyGoalComplete = 'verify_goal_complete';
  static const markGoalMissed = 'mark_goal_missed';

  /// Argument names the SQL functions take. Repositories pass these rather
  /// than repeating the `p_` literals at each call.
  static const pName = 'p_name';
  static const pGroupId = 'p_group_id';
  static const pGoalId = 'p_goal_id';
}
