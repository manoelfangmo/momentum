import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/groups/data/groups_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Assigned by Ada" on a goal the admin gave its owner.
///
/// Why the owner has no menu on this goal, said on the tile rather than left
/// for them to work out from the controls that are missing. The owner can
/// still move its status; the wording is the admin's.
///
/// Nothing at all on a goal its owner set themselves, which is most of them,
/// and nothing while the group is still loading: a tile that grows a line a
/// moment after it appears reads worse than one that never had it.
class AssignedByLabel extends ConsumerWidget {
  const AssignedByLabel({super.key, required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignedBy = goal.assignedBy;
    if (assignedBy == null) return const SizedBox.shrink();

    final name = ref
        .watch(groupMembersProvider(goal.groupId))
        .value
        ?.where((member) => member.id == assignedBy)
        .firstOrNull
        ?.name;
    if (name == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Text(
      'Assigned by $name',
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
