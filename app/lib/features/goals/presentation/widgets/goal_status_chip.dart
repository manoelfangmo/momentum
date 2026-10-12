import 'package:app/features/goals/domain/goal_status.dart';
import 'package:flutter/material.dart';

/// Where the goal stands, coloured from the theme.
///
/// Neutral while not started, secondary (amber-leaning) while in progress,
/// primary once complete. The label comes from [GoalStatus.label].
class GoalStatusChip extends StatelessWidget {
  const GoalStatusChip({super.key, required this.status});

  final GoalStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = switch (status) {
      GoalStatus.notStarted => scheme.outline,
      GoalStatus.inProgress => scheme.secondary,
      GoalStatus.complete => scheme.primary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Text(
        status.label,
        style: theme.textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
