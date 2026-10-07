/// Names in `public.members`.
///
/// [name] is the table, matching `.from(GoalsTable.name)`. The `name` column is
/// [memberName] so the two do not collide.
abstract final class MembersTable {
  static const name = 'members';

  static const id = 'id';
  static const memberName = 'name';
  static const groupId = 'group_id';
  static const createdAt = 'created_at';
}
