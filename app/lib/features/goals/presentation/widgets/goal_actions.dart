import 'package:app/core/utils/toasts.dart';
import 'package:app/features/goals/application/goal_service.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/presentation/controllers/goal_action_controller.dart';
import 'package:app/features/goals/presentation/widgets/goal_status_picker.dart';
import 'package:app/features/groups/data/groups_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the viewer may do to [goal], as a row under the tile.
///
/// Permissions come from [goalPermissionsProvider], so this widget never
/// compares member ids or works out who the admin is. They are not
/// alternatives: the admin looking at another member's complete goal gets
/// both a status picker and a Verify. Status changes go straight to the
/// picker; verifying and un-verifying sit behind a confirm because each one
/// moves a goal someone else owns.
///
/// Laid out as a [Wrap] rather than a [Row] because the number of controls
/// is not fixed, and a narrow screen should drop the last one to a second
/// line instead of overflowing. The padding is here rather than on the tile
/// so a viewer with nothing on offer takes up no space at all.
class GoalActions extends ConsumerWidget {
  const GoalActions({super.key, required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(goalPermissionsProvider(goal));
    final isLoading = ref
        .watch(goalActionControllerProvider(goal.id))
        .isLoading;
    ref.listen(goalActionControllerProvider(goal.id), (previous, next) {
      if (next case AsyncError(:final error)) showErrorToast(context, error);
    });

    final controls = [
      if (permissions.canChangeStatus) GoalStatusPicker(goal: goal),
      if (permissions.canVerify)
        _ActionButton(
          label: 'Verify',
          isLoading: isLoading,
          onPressed: () => _confirmVerify(context, ref),
        ),
      if (permissions.canUnverify)
        _ActionButton(
          label: 'Un-verify',
          isLoading: isLoading,
          onPressed: () => _confirmUnverify(context, ref),
        ),
    ];

    // A verified goal with nothing on offer reads as closed rather than as
    // empty space, which is the one case worth drawing.
    if (controls.isEmpty) {
      if (!goal.verified) return const SizedBox.shrink();
      controls.add(
        Icon(
          Icons.lock_outline,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: controls,
      ),
    );
  }

  Future<void> _confirmVerify(BuildContext context, WidgetRef ref) async {
    final name = await _ownerName(ref);
    if (!context.mounted) return;
    final confirmed = await _confirm(
      context,
      "Verify '${goal.title}' for $name? This can't be undone.",
    );
    if (!context.mounted || !confirmed) return;
    await ref.read(goalActionControllerProvider(goal.id).notifier).verify(goal);
  }

  Future<void> _confirmUnverify(BuildContext context, WidgetRef ref) async {
    final name = await _ownerName(ref);
    if (!context.mounted) return;
    final confirmed = await _confirm(
      context,
      "Un-verify '${goal.title}' for $name? It stays complete, and anyone "
      'but them can verify it again.',
    );
    if (!context.mounted || !confirmed) return;
    await ref
        .read(goalActionControllerProvider(goal.id).notifier)
        .unverify(goal);
  }

  /// The owner's name for the confirm copy. Looked up from the group, not
  /// from comparing ids to decide the action.
  Future<String> _ownerName(WidgetRef ref) async {
    try {
      final members = await ref.read(groupMembersProvider(goal.groupId).future);
      for (final member in members) {
        if (member.id == goal.ownerId) return member.name;
      }
    } catch (_) {
      // The name is only for the confirm copy; the RPC still runs.
    }
    return 'them';
  }
}

Future<bool> _confirm(BuildContext context, String message) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ) ??
      false;
}

/// Compact enough to sit in a [ListTile] trailing slot.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: isLoading ? null : onPressed,
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: isLoading
          ? const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}
