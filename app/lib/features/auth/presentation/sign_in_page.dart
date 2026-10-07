import 'package:app/core/routing/app_routes.dart';
import 'package:app/features/auth/presentation/widgets/auth_footer_link.dart';
import 'package:app/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:app/features/auth/presentation/widgets/sign_in_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: AuthFormCard(
        title: 'Welcome back',
        subtitle: 'Sign in to keep your group moving.',
        footer: AuthFooterLink(
          prompt: 'New here?',
          actionLabel: 'Create an account',
          path: AppRoutes.signUp,
        ),
        child: SignInForm(),
      ),
    );
  }
}
