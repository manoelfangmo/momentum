import 'package:app/core/utils/toasts.dart';
import 'package:app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ends the session.
///
/// Navigates nowhere: dropping the session empties `currentMemberProvider`,
/// and the redirect takes it from there.
class SignOutButton extends ConsumerWidget {
  const SignOutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = ref.watch(authControllerProvider).isLoading;
    ref.listen(authControllerProvider, (previous, next) {
      if (next case AsyncError(:final error)) showErrorToast(context, error);
    });

    return TextButton(
      onPressed: isBusy
          ? null
          : () => ref.read(authControllerProvider.notifier).signOut(),
      child: const Text('Sign out'),
    );
  }
}
