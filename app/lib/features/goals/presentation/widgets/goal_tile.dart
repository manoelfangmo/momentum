import 'package:app/core/utils/providers.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/presentation/widgets/goal_actions.dart';
import 'package:app/features/goals/presentation/widgets/goal_menu.dart';
import 'package:app/features/goals/presentation/widgets/goal_status_chip.dart';
import 'package:app/features/goals/presentation/widgets/verified_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// One goal in a list: what it is, when it is due, and where it stands.
///
/// The trailing slot carries the one action the viewer may take and, for the
/// owner of an unverified goal, the rename/delete menu. History renders the
/// same tile, so both work there too.
///
/// The clock comes from [clockProvider] because whether a goal reads as
/// overdue is a fact about now, and tests freeze now.
class GoalTile extends ConsumerWidget {
  const GoalTile({super.key, required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final now = ref.watch(clockProvider)();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(goal.title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Due ${_deadlineLabel.format(goal.deadline)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              GoalStatusChip(status: goal.status),
              VerifiedBadge(goal: goal),
              if (goal.isOverdue(now)) const _OverdueBadge(),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [GoalActions(goal: goal), GoalMenu(goal: goal)],
        ),
      ),
    );
  }
}

/// Past the deadline and not yet counted as done.
///
/// Filled, unlike the status chip, because this is the one thing on the tile
/// that asks the member to do something. Nothing expires: the goal can still
/// change status or be verified.
class _OverdueBadge extends StatelessWidget {
  const _OverdueBadge();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Text(
        'Overdue',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

/// "Oct 7, 2026, 11:59 PM". The year is in there because a deadline read in
/// History can be any year.
final _deadlineLabel = DateFormat('MMM d, y, h:mm a', 'en_US');
