import 'package:app/core/widgets/app_loading.dart';
import 'package:app/core/widgets/error_retry.dart';
import 'package:app/features/groups/data/groups_repository.dart';
import 'package:app/features/groups/domain/group.dart';
import 'package:app/features/groups/presentation/widgets/copy_group_code_button.dart';
import 'package:app/features/groups/presentation/widgets/group_header.dart';
import 'package:app/features/groups/presentation/widgets/member_list.dart';
import 'package:app/features/groups/presentation/widgets/sign_out_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The `/group` branch: who is in the group, the code to invite more people,
/// and the way out of the session.
class GroupPage extends ConsumerWidget {
  const GroupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(currentGroupProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group'),
        actions: const [SignOutButton()],
      ),
      body: groupAsync.when(
        data: (group) => RefreshIndicator(
          onRefresh: () {
            ref.invalidate(currentGroupProvider);
            ref.invalidate(groupMembersProvider(group.id));
            return ref
                .read(currentGroupProvider.future)
                .then((_) {}, onError: (_, _) {});
          },
          child: _GroupDetails(group: group),
        ),
        loading: () => const AppLoading(),
        error: (error, stackTrace) => ErrorRetry(
          message: 'We could not load your group.',
          onRetry: () => ref.invalidate(currentGroupProvider),
        ),
      ),
    );
  }
}

class _GroupDetails extends StatelessWidget {
  const _GroupDetails({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        GroupHeader(group: group),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: CopyGroupCodeButton(code: group.id),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 8),
        MemberList(groupId: group.id),
      ],
    );
  }
}
