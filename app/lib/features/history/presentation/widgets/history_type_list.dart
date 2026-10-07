import 'package:app/core/domain/domain.dart';
import 'package:app/core/widgets/app_loading.dart';
import 'package:app/core/widgets/empty_state.dart';
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
      data: (sections) => RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: sections.isEmpty ? _EmptyHistory(type: type) : _list(sections),
      ),
      loading: () => const AppLoading(),
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
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        for (final section in sections) ...[
          HistoryPeriodHeader(period: section.period, goals: section.goals),
          for (final goal in section.goals) GoalTile(goal: goal),
        ],
      ],
    );
  }

  /// Re-reads past goals, then waits for the tab to rebuild so the indicator
  /// spins until there is something new on screen.
  Future<void> _refresh(WidgetRef ref) {
    ref.invalidate(historyGoalsProvider);
    return ref
        .read(historySectionsProvider(type).future)
        .then((_) {}, onError: (_, _) {});
  }
}

/// Nothing in any ended period of this type.
class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.type});

  final GoalType type;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        EmptyState(
          icon: Icons.history,
          message: 'No past ${type.label} goals yet.',
        ),
      ],
    );
  }
}
