import 'package:app/core/domain/domain.dart';
import 'package:app/features/history/presentation/widgets/history_type_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The `/history` branch: one tab per [GoalType], always the signed-in
/// member's own ended periods. There is no member picker.
class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: GoalType.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
          bottom: TabBar(
            tabs: [
              for (final type in GoalType.values) Tab(text: type.label),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            for (final type in GoalType.values) HistoryTypeList(type: type),
          ],
        ),
      ),
    );
  }
}
