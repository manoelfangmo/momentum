import 'package:app/core/domain/domain.dart';
import 'package:app/core/widgets/error_retry.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/groups/data/groups_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Everyone in [groupId], with the signed-in member marked.
///
/// A [Column] rather than its own scrollable: the group page is already a
/// list, and a group is small enough to render whole.
class MemberList extends ConsumerWidget {
  const MemberList({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final membersAsync = ref.watch(groupMembersProvider(groupId));
    final signedInId = ref.watch(currentMemberProvider).value?.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Members',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        membersAsync.when(
          data: (members) => Column(
            children: [
              for (final member in members)
                _MemberTile(member: member, isYou: member.id == signedInId),
            ],
          ),
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => ErrorRetry(
            message: 'We could not load the members of this group.',
            onRetry: () => ref.invalidate(groupMembersProvider(groupId)),
          ),
        ),
      ],
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member, required this.isYou});

  final Member member;
  final bool isYou;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(child: Text(_initial(member.name))),
      title: Text(member.name),
      trailing: isYou
          ? Text(
              'You',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            )
          : null,
    );
  }

  /// The database guarantees a non-empty name, but a name of only spaces
  /// would still leave nothing to show.
  String _initial(String name) {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase();
  }
}
