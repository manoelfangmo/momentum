/// Names in `public.groups`.
///
/// [name] is the table, matching `.from(GroupsTable.name)`. The `name` column
/// is [groupName] so the two do not collide.
abstract final class GroupsTable {
  static const name = 'groups';

  static const id = 'id';
  static const groupName = 'name';
  static const createdBy = 'created_by';
  static const createdAt = 'created_at';
}
