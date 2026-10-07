import 'package:app/core/domain/domain.dart';
import 'package:app/core/widgets/error_retry.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/presentation/widgets/goal_tile.dart';
import 'package:app/features/history/domain/history_section.dart';
import 'package:app/features/history/presentation/controllers/history_controller.dart';
import 'package:app/features/history/presentation/widgets/history_period_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One History tab: the viewer's past [type] goals, grouped by ended period.
class HistoryTypeList extends ConsumerWidget {
  const HistoryTypeList({super.key, required this.type});

  final GoalType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionsAsync = ref.watch(historySectionsProvider(type));

    return sectionsAsync.when(
      data: (sections) =>
          sections.isEmpty ? _EmptyHistory(type: type) : _list(sections),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => ErrorRetry(
        message: 'We could not load these goals.',
        onRetry: () {
          ref.invalidate(historyGoalsProvider);
          ref.invalidate(historySectionsProvider(type));
        },
      ),
    );
  }

  Widget _list(List<HistorySection> sections) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        for (final section in sections) ...[
          HistoryPeriodHeader(period: section.period),
          for (final goal in section.goals) GoalTile(goal: goal),
        ],
      ],
    );
  }
}

/// Nothing in any ended period of this type.
class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.type});

  final GoalType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
      children: [
        Icon(
          Icons.history,
          size: 40,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        Text(
          'No past ${type.label} goals yet.',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleSmall,
        ),
      ],
    );
  }
}
