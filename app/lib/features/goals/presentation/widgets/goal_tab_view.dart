import 'package:app/core/domain/domain.dart';
import 'package:app/core/widgets/error_retry.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/presentation/controllers/goal_tab_controller.dart';
import 'package:app/features/goals/presentation/models/goal_tab_data.dart';
import 'package:app/features/goals/presentation/widgets/goal_tile.dart';
import 'package:app/features/groups/data/groups_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One tab of the goals page: the selected member's [type] goals for the
/// period that tab is on.
///
/// Everything it needs arrives as one [GoalTabData], so loading, failure and
/// data are decided once here instead of per piece of the layout.
class GoalTabView extends ConsumerWidget {
  const GoalTabView({super.key, required this.type});

  final GoalType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabAsync = ref.watch(goalTabDataProvider(type));

    return tabAsync.when(
      data: (tab) => _TabBody(type: type, tab: tab),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => ErrorRetry(
        message: 'We could not load these goals.',
        onRetry: () {
          // The failure is cached on the goals read, which this provider only
          // awaited, and without data there is no member or period to name —
          // so the whole family goes.
          ref.invalidate(goalsForPeriodProvider);
          ref.invalidate(goalTabDataProvider(type));
        },
      ),
    );
  }
}

class _TabBody extends ConsumerWidget {
  const _TabBody({required this.type, required this.tab});

  final GoalType type;
  final GoalTabData tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _TabHeader(tab: tab),
        // T11 puts the Day selector here, between the header and the list.
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _refresh(ref),
            child: tab.goals.isEmpty ? const _NoGoals() : _list(),
          ),
        ),
      ],
    );
  }

  Widget _list() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      // Deep at the bottom so the new goal button does not sit on the last
      // tile.
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      itemCount: tab.goals.length,
      itemBuilder: (context, index) => GoalTile(goal: tab.goals[index]),
    );
  }

  /// Re-reads the goals, then waits for the tab to rebuild so the indicator
  /// spins until there is something new on screen.
  ///
  /// A failure is not rethrown: the rebuilt tab renders it as its error state,
  /// and the indicator only needs the future to finish.
  Future<void> _refresh(WidgetRef ref) {
    ref.invalidate(goalsForPeriodProvider(tab.memberId, tab.period));
    return ref
        .read(goalTabDataProvider(type).future)
        .then((_) {}, onError: (_, _) {});
  }
}

/// Which period the tab is on, and whose goals these are.
class _TabHeader extends StatelessWidget {
  const _TabHeader({required this.tab});

  final GoalTabData tab;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tab.period.label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 2),
          _OwnerLabel(memberId: tab.memberId),
          // T14 adds this period's completion stats here.
        ],
      ),
    );
  }
}

/// "Your goals" when the tab is on the viewer, "Ada's goals" for anyone else
/// in the group.
class _OwnerLabel extends ConsumerWidget {
  const _OwnerLabel({required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final viewer = ref.watch(currentMemberProvider).value;
    final groupId = viewer?.groupId;
    final members = memberId == viewer?.id || groupId == null
        ? const <Member>[]
        : ref.watch(groupMembersProvider(groupId)).value ?? const <Member>[];

    return Text(
      _labelFor(memberId, viewer?.id, members),
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

String _labelFor(String memberId, String? viewerId, List<Member> members) {
  if (memberId == viewerId) return 'Your goals';
  for (final member in members) {
    if (member.id == memberId) return "${member.name}'s goals";
  }
  // The picker only offers members it has already loaded, so this is the gap
  // between picking someone and their row arriving here.
  return 'Goals';
}

/// Nothing set for this period.
///
/// A list rather than a centred column so the pull to refresh still works on
/// an empty tab.
class _NoGoals extends StatelessWidget {
  const _NoGoals();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
      children: [
        Icon(
          Icons.flag_outlined,
          size: 40,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        Text(
          'No goals for this period yet.',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Pull down to refresh.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
