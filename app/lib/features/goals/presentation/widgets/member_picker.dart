import 'package:app/core/domain/domain.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/presentation/controllers/goals_view_controller.dart';
import 'package:app/features/groups/data/groups_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whose goals the tabs show, chosen from everyone in [groupId].
///
/// It writes to the shared view controller rather than to a tab, which is what
/// makes one choice in the app bar apply to Day, Week, Month and Year at once.
class MemberPicker extends ConsumerWidget {
  const MemberPicker({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(groupMembersProvider(groupId));
    final signedInId = ref.watch(currentMemberProvider).value?.id;
    final selectedId = ref.watch(goalsViewControllerProvider).selectedMemberId;

    return membersAsync.when(
      data: (members) => members.isEmpty
          ? IconButton(
              icon: const Icon(Icons.person_outline),
              tooltip: 'No members in this group yet. Tap to try again.',
              onPressed: () => ref.invalidate(groupMembersProvider(groupId)),
            )
          : _PickerButton(
              members: _meFirst(members, signedInId),
              signedInId: signedInId,
              selectedId: selectedId,
              onSelected: ref
                  .read(goalsViewControllerProvider.notifier)
                  .selectMember,
            ),
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (error, stackTrace) => IconButton(
        icon: const Icon(Icons.person_off_outlined),
        tooltip: 'We could not load your group. Tap to try again.',
        onPressed: () => ref.invalidate(groupMembersProvider(groupId)),
      ),
    );
  }
}

class _PickerButton extends StatelessWidget {
  const _PickerButton({
    required this.members,
    required this.signedInId,
    required this.selectedId,
    required this.onSelected,
  });

  final List<Member> members;
  final String? signedInId;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Whose goals to show',
      initialValue: selectedId,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final member in members)
          PopupMenuItem(
            value: member.id,
            child: Text(_nameFor(member, signedInId)),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_selectedName()),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  /// The selection can outlive the list it came from — someone could leave the
  /// group while the page is open — so an id with no row falls back to "Me".
  String _selectedName() {
    for (final member in members) {
      if (member.id == selectedId) return _nameFor(member, signedInId);
    }
    return _me;
  }
}

/// The signed-in member reads as "Me" wherever they appear.
String _nameFor(Member member, String? signedInId) =>
    member.id == signedInId ? _me : member.name;

/// The signed-in member first, then everyone else in the order the repository
/// returned them, which is by name.
List<Member> _meFirst(List<Member> members, String? signedInId) {
  return [
    for (final member in members)
      if (member.id == signedInId) member,
    for (final member in members)
      if (member.id != signedInId) member,
  ];
}

const _me = 'Me';
