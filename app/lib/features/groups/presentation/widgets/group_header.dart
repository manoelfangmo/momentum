import 'package:app/features/groups/domain/group.dart';
import 'package:flutter/material.dart';

/// The group's name and its invite code.
///
/// The code is the group's id, so it is shown here rather than fetched: this
/// is the one place a member can read it to pass it on. Selectable because
/// copying by hand has to work when the clipboard button does not.
class GroupHeader extends StatelessWidget {
  const GroupHeader({super.key, required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedLabel = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your group', style: mutedLabel),
        const SizedBox(height: 4),
        Text(group.name, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 16),
        Text('Invite code', style: mutedLabel),
        const SizedBox(height: 4),
        SelectableText(
          group.id,
          style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
        ),
      ],
    );
  }
}
