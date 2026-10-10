import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/core/widgets/app_loading.dart';
import 'package:app/core/widgets/day_selector.dart';
import 'package:app/core/widgets/error_retry.dart';
import 'package:app/features/admin/presentation/controllers/admin_tab_controller.dart';
import 'package:app/features/admin/presentation/controllers/admin_view_controller.dart';
import 'package:app/features/admin/presentation/models/member_goals.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/presentation/widgets/goal_tile.dart';
import 'package:app/features/groups/data/groups_repository.dart';
import 'package:app/features/stats/domain/compute_completion.dart';
import 'package:app/features/stats/presentation/widgets/completion_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One tab of the admin page: everyone in the group and their [type] goals
/// for the period that tab is on.
///
/// The tiles are the ones the goals tabs use, so the admin gets the controls
/// their permissions already give them on another member's goal.
class AdminTabView extends ConsumerWidget {
  const AdminTabView({super.key, required this.type});

  final GoalType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabAsync = ref.watch(adminTabDataProvider(type));

    return tabAsync.when(
      data: (sections) => _TabBody(type: type, sections: sections),
      loading: () => const AppLoading(),
      error: (error, stackTrace) => ErrorRetry(
        message: "We could not load your group's goals.",
        onRetry: () {
          // The failure is cached on one of the two reads this provider
          // awaited, and without data there is no group or period to name —
          // so both families go.
          ref.invalidate(groupGoalsForPeriodProvider);
          ref.invalidate(groupMembersProvider);
          ref.invalidate(adminTabDataProvider(type));
        },
      ),
    );
  }
}

class _TabBody extends ConsumerWidget {
  const _TabBody({required this.type, required this.sections});

  final GoalType type;
  final List<MemberGoals> sections;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _PeriodHeader(period: ref.watch(adminPeriodProvider(type))),
        // Only the Day tab has a date to move: the others always show the
        // period containing now.
        if (type == GoalType.daily) const _AdminDaySelector(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _refresh(ref),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: sections.length,
              itemBuilder: (context, index) =>
                  _MemberSection(section: sections[index]),
            ),
          ),
        ),
      ],
    );
  }

  /// Re-reads the group's goals, then waits for the tab to rebuild so the
  /// indicator spins until there is something new on screen.
  ///
  /// The whole family rather than this period's key: the other three tabs
  /// are looking at the same group, and a stale one is not worth naming each
  /// key to avoid. A failure is not rethrown — the rebuilt tab renders it as
  /// its error state, and the indicator only needs the future to finish.
  Future<void> _refresh(WidgetRef ref) {
    ref.invalidate(groupGoalsForPeriodProvider);
    return ref
        .read(adminTabDataProvider(type).future)
        .then((_) {}, onError: (_, _) {});
  }
}

/// Which period every section below is counted over.
class _PeriodHeader extends StatelessWidget {
  const _PeriodHeader({required this.period});

  final Period period;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          period.label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

/// The shared day selector pointed at the admin's own date, so moving a day
/// here leaves the goals tabs where they were.
class _AdminDaySelector extends ConsumerWidget {
  const _AdminDaySelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DaySelector(
      selectedDay: ref.watch(adminViewControllerProvider),
      now: ref.watch(clockProvider)(),
      onDaySelected: ref.read(adminViewControllerProvider.notifier).selectDay,
    );
  }
}

/// One member: their name, how much of the period they have verified, and
/// every goal of theirs in it.
class _MemberSection extends StatelessWidget {
  const _MemberSection({required this.section});

  final MemberGoals section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(section.member.name, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          CompletionBadge(completionFor(section.goals)),
          const SizedBox(height: 4),
          if (section.goals.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No goals',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            for (final goal in section.goals) GoalTile(goal: goal),
        ],
      ),
    );
  }
}
