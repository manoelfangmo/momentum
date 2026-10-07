/// Names in `public.goals`.
///
/// [name] is the table, matching `.from(GoalsTable.name)`. Status is listed
/// even though clients never write it: the column is still selected and read.
abstract final class GoalsTable {
  static const name = 'goals';

  static const id = 'id';
  static const ownerId = 'owner_id';
  static const groupId = 'group_id';
  static const title = 'title';
  static const type = 'type';
  static const deadline = 'deadline';
  static const status = 'status';
  static const createdAt = 'created_at';
}
