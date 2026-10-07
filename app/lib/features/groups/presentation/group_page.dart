import 'package:flutter/material.dart';

/// Placeholder for the member list and the invite code, built in T07.
class GroupPage extends StatelessWidget {
  const GroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group')),
      body: const Center(child: Text('Your group will show up here.')),
    );
  }
}
