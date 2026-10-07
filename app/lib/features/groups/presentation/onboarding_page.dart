import 'package:flutter/material.dart';

/// Placeholder for create-a-group and join-a-group, built in T07.
///
/// The redirect pins a member with no `groupId` here, and lets them out as
/// soon as joining invalidates `currentMemberProvider`.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join a group')),
      body: const Center(
        child: Text('Create a group or join one to get started.'),
      ),
    );
  }
}
