import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The signed-in shell: one [NavigationBar] above the three branches of the
/// [StatefulShellRoute] in `go_router.dart`.
///
/// [shell] is the indexed stack of branch navigators, so leaving Goals and
/// coming back finds the same tab and scroll position.
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        // Tapping the branch you are already on pops it back to its first
        // page; tapping another one restores where you left it.
        onDestinationSelected: (index) => shell.goBranch(
          index,
          initialLocation: index == shell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Goals',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group),
            label: 'Group',
          ),
        ],
      ),
    );
  }
}
