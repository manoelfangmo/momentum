import 'package:flutter/material.dart';

/// Placeholder for the past periods list, built in T13.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: const Center(child: Text('Finished periods will show up here.')),
    );
  }
}
