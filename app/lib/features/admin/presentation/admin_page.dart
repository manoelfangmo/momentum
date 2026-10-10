import 'package:app/core/domain/domain.dart';
import 'package:app/features/admin/presentation/widgets/admin_tab_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The `/admin` branch: one tab per [GoalType], each showing every member of
/// the group. Only the member who created it ever reaches this page.
///
/// There is no member picker — the point of the screen is all of them at
/// once — and no History: the admin sees the period that is open, and Day is
/// the only tab that moves off it.
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
      ),
    );
  }
}
