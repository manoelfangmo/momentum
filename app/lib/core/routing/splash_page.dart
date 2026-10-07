import 'package:flutter/material.dart';

/// What the app shows while Supabase restores the session and the member row
/// loads. The redirect leaves this screen the moment it knows who is here.
///
/// Deliberately static: the wait is usually a few frames, and a spinner that
/// appears and disappears that fast reads as a flicker.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Momentum',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
