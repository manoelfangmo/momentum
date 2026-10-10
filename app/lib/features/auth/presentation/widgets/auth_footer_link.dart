import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The "Already have an account? Sign in" line under an auth form.
///
/// A [Wrap] rather than a [Row] so the link drops to its own line on a narrow
/// screen instead of overflowing.
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.path,
  });

  final String prompt;
  final String actionLabel;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(prompt),
        TextButton(
          onPressed: () => context.go(path),
          child: Text(actionLabel),
        ),
      ],
    );
  }
}
