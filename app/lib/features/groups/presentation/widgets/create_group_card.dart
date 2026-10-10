import 'package:app/core/widgets/submit_button.dart';
import 'package:app/features/groups/presentation/controllers/onboarding_controller.dart';
import 'package:app/features/groups/presentation/validators/group_validators.dart';
import 'package:app/features/groups/presentation/widgets/onboarding_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Start a new group. The creator becomes its first member, so there is
/// nothing left to do here on success: the router moves on.
class CreateGroupCard extends ConsumerStatefulWidget {
  const CreateGroupCard({super.key});

  @override
  ConsumerState<CreateGroupCard> createState() => _CreateGroupCardState();
}

class _CreateGroupCardState extends ConsumerState<CreateGroupCard> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(onboardingControllerProvider.notifier)
        .create(_name.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    // Shared with the join card, so a submit in either one locks both.
    final isBusy = ref.watch(onboardingControllerProvider).isLoading;

    return OnboardingCard(
      title: 'Create a group',
      subtitle: 'You get an invite code to send to everyone else.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: 'Group name'),
              validator: validateGroupName,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            SubmitButton(
              label: 'Create group',
              isLoading: isBusy,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
