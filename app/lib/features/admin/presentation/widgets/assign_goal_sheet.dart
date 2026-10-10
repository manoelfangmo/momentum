import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/toasts.dart';
import 'package:app/core/widgets/submit_button.dart';
import 'package:app/features/admin/presentation/controllers/assign_goal_form_notifier.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/presentation/validators/goal_validators.dart';
import 'package:app/features/goals/presentation/widgets/current_period_due_label.dart';
import 'package:app/features/groups/data/groups_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the assign sheet for [type], the type of the admin tab it was opened
/// from. Completes once the sheet is gone, whether it saved or was closed.
Future<void> showAssignGoalSheet(BuildContext context, GoalType type) {
  return showModalBottomSheet<void>(
    context: context,
    // The title field is autofocused, so the keyboard is up as the sheet
    // arrives and the sheet has to be free to sit above it.
    isScrollControlled: true,
    builder: (context) => AssignGoalSheet(type: type),
  );
}

/// Gives one member of the group one goal of [type].
///
/// The admin's version of `CreateGoalSheet`, with the one thing that sheet
/// has no need for: who the goal is for. One member at a time, themselves
/// included — picking themselves makes a normal own goal, because
/// `assign_goal` only stamps `assigned_by` when the owner is somebody else.
///
/// The deadline is the end of the current period of [type] and is shown
/// rather than chosen. The Day tab's date picker does not reach it: the admin
/// can look back at a past day, but a goal they set now is for now.
class AssignGoalSheet extends ConsumerStatefulWidget {
  const AssignGoalSheet({super.key, required this.type});

  final GoalType type;

  @override
  ConsumerState<AssignGoalSheet> createState() => _AssignGoalSheetState();
}

class _AssignGoalSheetState extends ConsumerState<AssignGoalSheet> {
  final _formKey = GlobalKey<FormState>();

  /// Local to the sheet because that is as long as it matters: the sheet is
  /// gone the moment the save lands.
  bool _isSaving = false;

  Future<void> _submit() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      await ref.read(assignGoalFormProvider.notifier).submit(type: widget.type);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      // The draft is still in the notifier, so the sheet stays open on the
      // member and title the admin picked rather than asking again.
      if (!mounted) return;
      setState(() => _isSaving = false);
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watched, not read: the notifier autodisposes, and this listener is what
    // keeps the draft alive between keystrokes.
    final form = ref.watch(assignGoalFormProvider.notifier);
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Assign ${widget.type.label} goal',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _MemberField(onChanged: form.ownerChanged),
                const SizedBox(height: 16),
                TextFormField(
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(labelText: 'Goal'),
                  validator: validateGoalTitle,
                  onChanged: form.titleChanged,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 8),
                CurrentPeriodDueLabel(type: widget.type),
                const SizedBox(height: 20),
                SubmitButton(
                  label: 'Save',
                  isLoading: _isSaving,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Who the goal is for: anyone in the group, the admin included.
///
/// Nothing is selected when the sheet opens. Assigning to the wrong person is
/// a goal somebody has to delete, so the admin says who every time rather
/// than correcting a default.
class _MemberField extends ConsumerWidget {
  const _MemberField({required this.onChanged});

  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The router keeps a member without a group off the admin page, so these
    // are only null for the moment before the member row lands.
    final viewer = ref.watch(currentMemberProvider).value;
    final groupId = viewer?.groupId;
    if (groupId == null) return const _MemberFieldPlaceholder();

    final membersAsync = ref.watch(groupMembersProvider(groupId));
    return membersAsync.when(
      data: (members) => DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: 'For'),
        // Rejected before the RPC is called, so the admin never gets a
        // server error for the one field the sheet can check itself.
        validator: (value) => value == null ? 'Choose who this is for.' : null,
        items: [
          for (final member in _meFirst(members, viewer!.id))
            DropdownMenuItem(
              value: member.id,
              child: Text(member.id == viewer.id ? 'Me' : member.name),
            ),
        ],
        onChanged: onChanged,
      ),
      loading: () => const _MemberFieldPlaceholder(),
      error: (error, stackTrace) => _MemberFieldError(
        onRetry: () => ref.invalidate(groupMembersProvider(groupId)),
      ),
    );
  }
}

/// The signed-in admin first, then everyone else in the order the repository
/// returned them, which is by name.
List<Member> _meFirst(List<Member> members, String viewerId) {
  return [
    for (final member in members)
      if (member.id == viewerId) member,
    for (final member in members)
      if (member.id != viewerId) member,
  ];
}

/// A field-shaped gap, so the sheet does not jump as the group lands.
class _MemberFieldPlaceholder extends StatelessWidget {
  const _MemberFieldPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const InputDecorator(
      decoration: InputDecoration(labelText: 'For'),
      child: SizedBox(
        height: 20,
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}

class _MemberFieldError extends StatelessWidget {
  const _MemberFieldError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'For',
        errorText: 'We could not load your group.',
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton(onPressed: onRetry, child: const Text('Try again')),
      ),
    );
  }
}
