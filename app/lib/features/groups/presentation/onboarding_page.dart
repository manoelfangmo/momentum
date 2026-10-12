import 'package:app/core/utils/toasts.dart';
import 'package:app/features/groups/presentation/controllers/onboarding_controller.dart';
import 'package:app/features/groups/presentation/widgets/create_group_card.dart';
import 'package:app/features/groups/presentation/widgets/join_group_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The only screen a member without a group sees: create one, or join one
/// with a code.
///
/// Neither card navigates. The redirect pins a member with no `groupId` here
/// and lets them out to `/goals` as soon as `currentMemberProvider` reports
/// one.
class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listened to here rather than in each card: the two share one controller,
    // and one failure should not raise two toasts.
    ref.listen(onboardingControllerProvider, (previous, next) {
      if (next case AsyncError(:final error)) showErrorToast(context, error);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Get started')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CreateGroupCard(),
                  SizedBox(height: 16),
                  JoinGroupCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
