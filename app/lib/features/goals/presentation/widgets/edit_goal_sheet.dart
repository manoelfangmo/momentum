import 'package:app/core/utils/toasts.dart';
import 'package:app/core/widgets/submit_button.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/presentation/controllers/goal_action_controller.dart';
import 'package:app/features/goals/presentation/validators/goal_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Opens the rename sheet for [goal]. Completes once the sheet is gone,
/// whether it saved or was closed.
Future<void> showEditGoalSheet(BuildContext context, Goal goal) {
  return showModalBottomSheet<void>(
    context: context,
    // The title field is autofocused, so the keyboard is up as the sheet
    // arrives and the sheet has to be free to sit above it.
    isScrollControlled: true,
    builder: (context) => EditGoalSheet(goal: goal),
  );
}

/// Renames one unverified goal.
///
/// The title is the only thing a goal can change: the type decides which tab
/// the goal lives in and the deadline decides its period, so both are shown
/// and neither is editable.
///
/// Its own sheet rather than a mode of `CreateGoalSheet`: the draft here is
/// one field seeded from a row the member already has, saved with a single
/// repository call through [GoalActionController], while creating keeps its
/// draft in a notifier and goes through `GoalService` for the member and the
/// deadline. They share the validator and the layout, not the plumbing.
class EditGoalSheet extends ConsumerStatefulWidget {
  const EditGoalSheet({super.key, required this.goal});

  final Goal goal;

  @override
  ConsumerState<EditGoalSheet> createState() => _EditGoalSheetState();
}

class _EditGoalSheetState extends ConsumerState<EditGoalSheet> {
  final _formKey = GlobalKey<FormState>();

  /// Seeded with the stored title, so the member edits what they wrote
  /// instead of retyping it.
  late final _title = TextEditingController(text: widget.goal.title);

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final controller = goalActionControllerProvider(widget.goal.id);
    if (ref.read(controller).isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(controller.notifier)
        .updateTitle(widget.goal, _title.text.trim());
    if (!mounted) return;

    // The controller keeps a rejection rather than throwing it, so the sheet
    // reads the settled state. It stays open on what was typed.
    if (ref.read(controller) case AsyncError(:final error)) {
      showErrorToast(context, error);
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Watched so the controller outlives the save: it autodisposes, and the
    // tile that was also watching it is gone while this sheet is up.
    final isSaving = ref
        .watch(goalActionControllerProvider(widget.goal.id))
        .isLoading;
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
                  'Edit ${widget.goal.type.label} goal',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _title,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(labelText: 'Goal'),
                  validator: validateGoalTitle,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 8),
                Text(
                  'Due: ${_deadlineLabel.format(widget.goal.deadline)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                SubmitButton(
                  label: 'Save',
                  isLoading: isSaving,
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

/// "Oct 7, 2026, 11:59 PM". The deadline it already has, not a period
/// recomputed from now: an edit never moves the goal to another period.
final _deadlineLabel = DateFormat('MMM d, y, h:mm a', 'en_US');
