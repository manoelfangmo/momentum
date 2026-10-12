import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// "Due: end of this week (Sun, Oct 11)" — when a goal of [type] drafted now
/// would fall due.
///
/// The period containing now, read from [clockProvider], which is where a new
/// goal lands whatever day a Day tab happens to be showing. Both sheets that
/// make a goal show it and neither lets it be edited, so the member can see
/// what they are committing to and the admin what they are asking for.
class CurrentPeriodDueLabel extends ConsumerWidget {
  const CurrentPeriodDueLabel({super.key, required this.type});

  final GoalType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deadline = Period.containing(
      ref.watch(clockProvider)(),
      type,
    ).deadline;
    final when = switch (type) {
      GoalType.daily => 'today',
      GoalType.weekly => 'this week',
      GoalType.monthly => 'this month',
      GoalType.yearly => 'this year',
    };

    final theme = Theme.of(context);
    return Text(
      'Due: end of $when (${_deadlineDay.format(deadline)})',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

final _deadlineDay = DateFormat('EEE, MMM d', 'en_US');
