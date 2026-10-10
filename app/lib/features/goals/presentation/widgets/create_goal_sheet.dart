import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/toasts.dart';
import 'package:app/core/widgets/submit_button.dart';
import 'package:app/features/goals/presentation/controllers/create_goal_form_notifier.dart';
import 'package:app/features/goals/presentation/validators/goal_validators.dart';
import 'package:app/features/goals/presentation/widgets/current_period_due_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the new goal sheet for [type], the type of the tab it was opened
/// from. Completes once the sheet is gone, whether it saved or was closed.
Future<void> showCreateGoalSheet(BuildContext context, GoalType type) {
  return showModalBottomSheet<void>(
    context: context,
    // The title field is autofocused, so the keyboard is up as the sheet
    // arrives and the sheet has to be free to sit above it.
    isScrollControlled: true,
    builder: (context) => CreateGoalSheet(type: type),
  );
}

/// Sets one goal of [type] for the signed-in member.
///
/// There is nothing to choose but the title: the tab decided the type, and the
/// deadline is the end of the current period of that type, shown here so the
/// member can see what they are committing to.
class CreateGoalSheet extends ConsumerStatefulWidget {
  const CreateGoalSheet({super.key, required this.type});

  final GoalType type;

  @override
  ConsumerState<CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends ConsumerState<CreateGoalSheet> {
  final _formKey = GlobalKey<FormState>();

  /// Local to the sheet because that is as long as it matters: the sheet is
  /// gone the moment the save lands.
  bool _isSaving = false;

  Future<void> _submit() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      await ref.read(createGoalFormProvider.notifier).submit(type: widget.type);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      // The draft is still in the notifier, so the sheet stays open on the
      // title the member typed rather than making them type it again.
      if (!mounted) return;
      setState(() => _isSaving = false);
      showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watched, not read: the notifier autodisposes, and this listener is what
    // keeps the draft alive between keystrokes. Watching `.notifier` rather
    // than the state means typing does not rebuild the sheet.
    final form = ref.watch(createGoalFormProvider.notifier);
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
                  'New ${widget.type.label} goal',
                  style: theme.textTheme.titleLarge,
                ),
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
