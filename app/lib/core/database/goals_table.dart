/// Names in `public.goals`.
///
/// [name] is the table, matching `.from(GoalsTable.name)`. Status is listed
/// even though clients never write it: the column is still selected and read.
///
/// [assignedBy] is null on a goal its owner made, and the admin who assigned
/// it otherwise.
abstract final class GoalsTable {
  static const name = 'goals';

  static const id = 'id';
  static const ownerId = 'owner_id';
  static const assignedBy = 'assigned_by';
  static const groupId = 'group_id';
  static const title = 'title';
  static const type = 'type';
  static const deadline = 'deadline';
  static const status = 'status';
  static const verified = 'verified';
  static const createdAt = 'created_at';
}
