import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/admin/presentation/controllers/admin_view_controller.dart';
import 'package:app/features/admin/presentation/widgets/admin_tab_view.dart';
import 'package:app/features/admin/presentation/widgets/assign_goal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The `/admin` branch: one tab per [GoalType], each showing every member of
/// the group. Only the member who created it ever reaches this page.
///
/// There is no member picker — the point of the screen is all of them at
/// once — and no History: the admin reaches a past period with the same
/// navigator the goals tabs use, on a date of this screen's own. Who a new
/// goal is for is picked in the sheet instead, one member at a time, and
/// only while the tab in front is the current period.
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
/// Hidden while that tab is off the current period: assigning always lands
/// in now, and navigating to a past period is for acting on what is already
/// there. Unlike the goals page's button, it does not care whose goals are
/// on screen — the admin tab is never on somebody else in a way that would
/// leave nobody to assign to.
class _AssignGoalButton extends ConsumerWidget {
  const _AssignGoalButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The tab index is the type: both come from `GoalType.values`, in order.
    // Rebuilt on every tab change so the label names the tab in front.
    final tabs = DefaultTabController.of(context);
    final selectedDay = ref.watch(adminViewControllerProvider);
    final now = ref.watch(clockProvider)();
    return AnimatedBuilder(
      animation: tabs,
      builder: (context, child) {
        final type = GoalType.values[tabs.index];
        final visible = Period.containing(selectedDay, type);
        final current = Period.containing(now, type);
        if (visible != current) return const SizedBox.shrink();

        return FloatingActionButton.extended(
          onPressed: () => showAssignGoalSheet(context, type),
          icon: const Icon(Icons.add),
          label: Text('Assign ${type.label} goal'),
        );
      },
    );
  }
}
