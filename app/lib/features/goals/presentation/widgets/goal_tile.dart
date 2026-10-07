import 'package:app/core/utils/providers.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:app/features/goals/presentation/widgets/goal_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// One goal in a list: what it is, when it is due, and where it stands.
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
              _StatusPill(status: goal.status),
              if (goal.isOverdue(now)) const _OverdueBadge(),
            ],
          ),
        ),
        trailing: GoalActions(goal: goal),
      ),
    );
  }
}

/// Where the goal stands: grey while pending, green once complete, red when
/// missed.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final GoalStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (label, color) = switch (status) {
      GoalStatus.pending => ('Pending', scheme.outline),
      GoalStatus.complete => ('Complete', _completeColor),
      GoalStatus.missed => ('Missed', scheme.error),
    };

    return _Pill(label: label, color: color);
  }
}

/// Past the deadline and still pending.
///
/// Filled, unlike the status pill, because this is the one thing on the tile
/// that asks the member to do something. Nothing expires: the goal can still
/// be verified or marked missed.
class _OverdueBadge extends StatelessWidget {
  const _OverdueBadge();

  @override
  Widget build(BuildContext context) {
    return _Pill(
      label: 'Overdue',
      color: Theme.of(context).colorScheme.error,
      filled: true,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color, this.filled = false});

  final String label;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.12) : null,
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

/// A [ColorScheme] has no role for "this went well", so complete gets a fixed
/// green rather than a role that means something else.
const _completeColor = Color(0xFF2E7D32);

/// "Oct 7, 2026, 11:59 PM". The year is in there because a deadline read in
/// History can be any year.
final _deadlineLabel = DateFormat('MMM d, y, h:mm a', 'en_US');
