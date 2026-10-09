import 'package:app/core/utils/toasts.dart';
import 'package:app/features/goals/application/goal_service.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_action_availability.dart';
import 'package:app/features/goals/presentation/controllers/goal_action_controller.dart';
import 'package:app/features/goals/presentation/widgets/goal_status_picker.dart';
import 'package:app/features/groups/data/groups_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The one action the viewer may take on [goal], if any.
///
/// Availability comes from [goalActionAvailabilityProvider], so this widget
/// never compares member ids. Status changes go straight to the picker;
/// verify sits behind a confirm because it cannot be undone.
class GoalActions extends ConsumerWidget {
  const GoalActions({super.key, required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availability = ref.watch(goalActionAvailabilityProvider(goal));
    final isLoading = ref
        .watch(goalActionControllerProvider(goal.id))
        .isLoading;
    ref.listen(goalActionControllerProvider(goal.id), (previous, next) {
      if (next case AsyncError(:final error)) showErrorToast(context, error);
    });

    return switch (availability) {
      CanChangeStatus() => GoalStatusPicker(goal: goal),
      CanVerify() => _VerifyButton(
        isLoading: isLoading,
        onPressed: () => _confirmVerify(context, ref),
      ),
      NoAction() => goal.verified
          ? Icon(
              Icons.lock_outline,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            )
          : const SizedBox.shrink(),
    };
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

  /// The owner's name for the verify copy. Looked up from the group, not from
  /// comparing ids to decide the action.
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
class _VerifyButton extends StatelessWidget {
  const _VerifyButton({required this.isLoading, required this.onPressed});

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
          : const Text('Verify'),
    );
  }
}
