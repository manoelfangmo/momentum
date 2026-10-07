/// Names of the Postgres functions repositories call with `supabase.rpc(...)`.
///
/// Membership changes live here because clients have no `UPDATE` on
/// `members.group_id`: creating and joining a group are only possible through
/// these two functions.
abstract final class Rpc {
  static const createGroup = 'create_group';
  static const joinGroup = 'join_group';
}
