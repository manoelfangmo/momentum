import 'package:app/core/utils/toasts.dart';
import 'package:app/features/goals/application/goal_service.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_action_availability.dart';
import 'package:app/features/goals/presentation/controllers/goal_action_controller.dart';
import 'package:app/features/groups/data/groups_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The one action the viewer may take on [goal], if any.
///
/// Availability comes from [goalActionAvailabilityProvider], so this widget
/// never compares member ids. A confirm sits in front of the repository call.
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
      CanVerify() => _ActionButton(
        label: 'Verify',
        isLoading: isLoading,
        tonal: true,
        onPressed: () => _confirmVerify(context, ref),
      ),
      CanMarkMissed() => _ActionButton(
        label: 'Missed',
        isLoading: isLoading,
        tonal: false,
        onPressed: () => _confirmMissed(context, ref),
      ),
      NoAction() => const SizedBox.shrink(),
    };
  }

  Future<void> _confirmVerify(BuildContext context, WidgetRef ref) async {
    final name = await _ownerName(ref);
    if (!context.mounted) return;
    final confirmed = await _confirm(
      context,
      "Mark '${goal.title}' as complete for $name?",
    );
    if (!context.mounted || !confirmed) return;
    await ref.read(goalActionControllerProvider(goal.id).notifier).verify(goal);
  }

  Future<void> _confirmMissed(BuildContext context, WidgetRef ref) async {
    final confirmed = await _confirm(
      context,
      "Mark '${goal.title}' as missed?",
    );
    if (!context.mounted || !confirmed) return;
    await ref
        .read(goalActionControllerProvider(goal.id).notifier)
        .markMissed(goal);
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
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.isLoading,
    required this.tonal,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final bool tonal;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      visualDensity: VisualDensity.compact,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    final onPress = isLoading ? null : onPressed;
    final child = isLoading
        ? const SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label);

    if (tonal) {
      return FilledButton.tonal(onPressed: onPress, style: style, child: child);
    }
    return TextButton(onPressed: onPress, style: style, child: child);
  }
}
