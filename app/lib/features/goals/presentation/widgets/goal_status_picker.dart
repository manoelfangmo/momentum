import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:app/features/goals/presentation/controllers/goal_action_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lets the owner move an unverified goal between statuses.
///
/// A menu rather than a segmented control so it fits the tile's trailing
/// slot. There is no confirm: any direction is allowed until someone
/// verifies. Complete mentions that a groupmate has to do that.
class GoalStatusPicker extends ConsumerWidget {
  const GoalStatusPicker({super.key, required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref
        .watch(goalActionControllerProvider(goal.id))
        .isLoading;

    if (isLoading) {
      return const SizedBox.square(
        dimension: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return PopupMenuButton<GoalStatus>(
      initialValue: goal.status,
      tooltip: 'Change status',
      onSelected: (status) {
        if (status == goal.status) return;
        ref
            .read(goalActionControllerProvider(goal.id).notifier)
            .setStatus(goal, status);
      },
      itemBuilder: (context) => [
        for (final status in GoalStatus.values)
          PopupMenuItem(
            value: status,
            child: _StatusItem(status: status, selected: status == goal.status),
          ),
      ],
      child: const _CurrentStatus(),
    );
  }
}

class _CurrentStatus extends StatelessWidget {
  const _CurrentStatus();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Status', style: theme.textTheme.labelLarge),
        Icon(Icons.arrow_drop_down, color: theme.colorScheme.onSurfaceVariant),
      ],
    );
  }
}

class _StatusItem extends StatelessWidget {
  const _StatusItem({required this.status, required this.selected});

  final GoalStatus status;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(status.label),
            if (selected) ...[
              const SizedBox(width: 8),
              Icon(Icons.check, size: 18, color: theme.colorScheme.primary),
            ],
          ],
        ),
        if (status == GoalStatus.complete) ...[
          const SizedBox(height: 2),
          Text(
            'A groupmate needs to verify this.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
