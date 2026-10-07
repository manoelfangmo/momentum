import 'package:app/core/routing/app_routes.dart';
import 'package:app/features/auth/presentation/widgets/auth_footer_link.dart';
import 'package:app/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:app/features/auth/presentation/widgets/sign_up_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpPage extends ConsumerWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: AuthFormCard(
        title: 'Create your account',
        subtitle: 'Then create a group or join the one you were invited to.',
        footer: AuthFooterLink(
          prompt: 'Already have an account?',
          actionLabel: 'Sign in',
          path: AppRoutes.signIn,
        ),
        child: SignUpForm(),
      ),
    );
  }
}
