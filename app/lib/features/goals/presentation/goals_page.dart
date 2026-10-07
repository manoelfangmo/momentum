import 'package:app/core/domain/domain.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/presentation/widgets/goal_tab_view.dart';
import 'package:app/features/goals/presentation/widgets/member_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The `/goals` branch: one tab per [GoalType], all of them showing the member
/// the app bar picker selected.
///
/// The page itself fetches nothing. Each tab watches the provider it renders,
/// and the picker writes to the selection they all read.
class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The router keeps a member without a group off this page, so this is only
    // null for the moment before the member row lands.
    final groupId = ref.watch(currentMemberProvider).value?.groupId;

    return DefaultTabController(
      length: GoalType.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Goals'),
          actions: [if (groupId != null) MemberPicker(groupId: groupId)],
          bottom: TabBar(
            tabs: [
              for (final type in GoalType.values) Tab(text: type.label),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            for (final type in GoalType.values) GoalTabView(type: type),
          ],
        ),
      ),
    );
  }
}
