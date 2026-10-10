import 'package:app/core/domain/domain.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/stats/domain/compute_completion.dart';
import 'package:app/features/stats/presentation/widgets/completion_badge.dart';
import 'package:flutter/material.dart';

/// Names the ended period a group of history goals belongs to, with that
/// period's completion rate under the label.
class HistoryPeriodHeader extends StatelessWidget {
  const HistoryPeriodHeader({
    super.key,
    required this.period,
    required this.goals,
  });

  final Period period;
  final List<Goal> goals;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(period.label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          CompletionBadge(completionFor(goals)),
        ],
      ),
    );
  }
}
