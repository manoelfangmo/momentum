import 'package:app/core/utils/toasts.dart';
import 'package:app/features/goals/application/goal_service.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/presentation/controllers/goal_action_controller.dart';
import 'package:app/features/goals/presentation/widgets/edit_goal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Rename and delete for the owner of an unverified goal.
///
/// Whether to show it at all comes from [canManageGoalProvider], so this
/// widget never compares member ids. Renaming opens a sheet; deleting sits
/// behind a confirm because it takes the goal and its history with it.
class GoalMenu extends ConsumerWidget {
  const GoalMenu({super.key, required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(canManageGoalProvider(goal))) {
      return const SizedBox.shrink();
    }

    // Watched, not read: the controller autodisposes, and a delete has to
    // outlive the menu entry that started it. It also says when another
    // action on this goal is still running.
    final isBusy = ref.watch(goalActionControllerProvider(goal.id)).isLoading;

    final colors = Theme.of(context).colorScheme;
    return PopupMenuButton<_GoalMenuAction>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'Goal options',
      enabled: !isBusy,
      onSelected: (action) => _run(context, ref, action),
      itemBuilder: (context) => [
        const PopupMenuItem(value: _GoalMenuAction.edit, child: Text('Edit')),
        PopupMenuItem(
          value: _GoalMenuAction.delete,
          child: Text('Delete', style: TextStyle(color: colors.error)),
        ),
      ],
    );
  }

  void _run(BuildContext context, WidgetRef ref, _GoalMenuAction action) {
    switch (action) {
      case _GoalMenuAction.edit:
        showEditGoalSheet(context, goal);
      case _GoalMenuAction.delete:
        _confirmDelete(context, ref);
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _DeleteDialog(title: goal.title),
    );
    if (!context.mounted || confirmed != true) return;

    final controller = goalActionControllerProvider(goal.id);
    await ref.read(controller.notifier).delete(goal);
    if (!context.mounted) return;

    // The controller keeps a rejection rather than throwing it. On success
    // the tile is on its way out, so the toast is the only thing left to
    // say it worked.
    if (ref.read(controller) case AsyncError(:final error)) {
      showErrorToast(context, error);
      return;
    }
    showSuccessToast(context, 'Goal deleted');
  }
}

enum _GoalMenuAction { edit, delete }

class _DeleteDialog extends StatelessWidget {
  const _DeleteDialog({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AlertDialog(
      content: Text("Delete '$title'? This can't be undone."),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: colors.onError,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
