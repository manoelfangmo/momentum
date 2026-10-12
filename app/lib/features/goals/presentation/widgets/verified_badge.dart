import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:flutter/material.dart';

/// Whether anyone has verified [goal], or that a complete one is still waiting.
///
/// Verified is a check and the word. Complete but not yet verified is a muted
/// label instead, so the owner can see why the control is still there. Other
/// statuses have nothing to say here.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (goal.verified) {
      final color = theme.colorScheme.primary;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            'Verified',
            style: theme.textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      );
    }
    if (goal.status == GoalStatus.complete) {
      return Text(
        'Awaiting verification',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
