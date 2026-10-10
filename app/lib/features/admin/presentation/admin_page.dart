import 'package:app/core/domain/domain.dart';
import 'package:app/features/admin/presentation/widgets/admin_tab_view.dart';
import 'package:app/features/admin/presentation/widgets/assign_goal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The `/admin` branch: one tab per [GoalType], each showing every member of
/// the group. Only the member who created it ever reaches this page.
///
/// There is no member picker — the point of the screen is all of them at
/// once — and no History: the admin sees the period that is open, and Day is
/// the only tab that moves off it. Who a new goal is for is picked in the
/// sheet instead, one member at a time.
class AdminPage extends ConsumerWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: GoalType.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin'),
          bottom: TabBar(
            tabs: [for (final type in GoalType.values) Tab(text: type.label)],
          ),
        ),
        body: TabBarView(
          children: [
            for (final type in GoalType.values) AdminTabView(type: type),
          ],
        ),
        floatingActionButton: const _AssignGoalButton(),
      ),
    );
  }
}

/// Opens the assign sheet for whichever tab is in front.
///
/// Always there, unlike the goals page's button: the admin tab is never on
/// somebody else's goals in a way that would leave nobody to assign to.
class _AssignGoalButton extends StatelessWidget {
  const _AssignGoalButton();

  @override
  Widget build(BuildContext context) {
    // The tab index is the type: both come from `GoalType.values`, in order.
    // Rebuilt on every tab change so the label names the tab in front.
    final tabs = DefaultTabController.of(context);
    return AnimatedBuilder(
      animation: tabs,
      builder: (context, child) {
        final type = GoalType.values[tabs.index];
        return FloatingActionButton.extended(
          onPressed: () => showAssignGoalSheet(context, type),
          icon: const Icon(Icons.add),
          label: Text('Assign ${type.label} goal'),
        );
      },
    );
  }
}
