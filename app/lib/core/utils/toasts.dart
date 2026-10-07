import 'package:flutter/material.dart';

import 'app_exception.dart';

/// Shows a failure at the bottom of the screen.
///
/// Takes the raw error rather than a string so the mapping from
/// [AppException] to user-facing copy lives in one place.
void showErrorToast(BuildContext context, Object error) {
  final colors = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        backgroundColor: colors.error,
        content: Text(
          _messageFor(error),
          style: TextStyle(color: colors.onError),
        ),
      ),
    );
}

const _fallbackMessage = 'Something went wrong. Please try again.';

String _messageFor(Object error) => switch (error) {
  AuthException(:final message) => message,
  ValidationException(:final message) => message,
  NetworkException() => 'No connection. Check your network and try again.',
  NotFoundException() => 'We could not find that.',
  PermissionException() => 'You are not allowed to do that.',
  _ => _fallbackMessage,
};
