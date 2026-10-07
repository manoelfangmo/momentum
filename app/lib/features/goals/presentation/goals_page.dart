import 'package:flutter/material.dart';

/// Placeholder for the Day / Week / Month / Year tabs, built in T09.
class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: const Center(child: Text('Your goals will show up here.')),
    );
  }
}
