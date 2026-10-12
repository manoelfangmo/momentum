import 'package:flutter/material.dart';

/// What a screen shows instead of data when the provider behind it failed.
///
/// [onRetry] belongs to the caller because only the caller knows which
/// provider to invalidate.
class ErrorRetry extends StatelessWidget {
  const ErrorRetry({
    super.key,
    this.message = 'Something went wrong.',
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
