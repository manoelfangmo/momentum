import 'package:app/core/widgets/submit_button.dart';
import 'package:app/features/groups/presentation/controllers/onboarding_controller.dart';
import 'package:app/features/groups/presentation/validators/group_validators.dart';
import 'package:app/features/groups/presentation/widgets/onboarding_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Join someone else's group with the code they sent.
///
/// The code is the group's id. Nothing is looked up before the RPC: whether a
/// group has that id is a question only `join_group` is allowed to answer.
class JoinGroupCard extends ConsumerStatefulWidget {
  const JoinGroupCard({super.key});

  @override
  ConsumerState<JoinGroupCard> createState() => _JoinGroupCardState();
}

class _JoinGroupCardState extends ConsumerState<JoinGroupCard> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(onboardingControllerProvider.notifier)
        .join(_code.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = ref.watch(onboardingControllerProvider).isLoading;

    return OnboardingCard(
      title: 'Join a group',
      subtitle: 'Paste the invite code from someone already in the group.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _code,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: 'Invite code'),
              validator: validateGroupCode,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            SubmitButton(
              label: 'Join group',
              isLoading: isBusy,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
