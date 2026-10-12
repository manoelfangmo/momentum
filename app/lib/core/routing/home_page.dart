import 'package:app/core/routing/app_routes.dart';
import 'package:app/features/groups/data/groups_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The signed-in shell: one [NavigationBar] above the branches of the
/// [StatefulShellRoute] in `go_router.dart`.
///
/// [shell] is the indexed stack of branch navigators, so leaving Goals and
/// coming back finds the same tab and scroll position.
///
/// Admin is in the bar for the group admin alone, which leaves the bar's
/// indexes out of step with the branch indexes [StatefulNavigationShell]
/// counts in. Each destination names its route instead, and the branch
/// holding that route is looked up on the shell.
class HomePage extends ConsumerWidget {
  const HomePage({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A flag still loading reads as not the admin, the same way the router's
    // redirect reads it, so the bar never offers a destination the redirect
    // would turn away.
    final isAdmin = ref.watch(isGroupAdminProvider).value ?? false;
    final visible = [
      for (final destination in _destinations)
        if (isAdmin || !destination.adminOnly) destination,
    ];
    final branches = [
      for (final destination in visible) _branchOf(destination.route),
    ];
    final selected = branches.indexOf(shell.currentIndex);

    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        // The branch on screen is not in the bar for the frame between an
        // admin losing the flag and the redirect moving them off `/admin`.
        selectedIndex: selected < 0 ? 0 : selected,
        // Tapping the branch you are already on pops it back to its first
        // page; tapping another one restores where you left it.
        onDestinationSelected: (index) => shell.goBranch(
          branches[index],
          initialLocation: branches[index] == shell.currentIndex,
        ),
        destinations: [
          for (final destination in visible)
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: destination.label,
            ),
        ],
      ),
    );
  }

  /// Which branch of the shell opens on [route].
  int _branchOf(String route) => shell.route.branches.indexWhere(
    (branch) => branch.defaultRoute?.path == route,
  );
}

/// One destination of the navigation bar, in the order the bar shows them.
class _Destination {
  const _Destination({
    required this.route,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.adminOnly = false,
  });

  /// The path of the branch this opens, not an index: Admin is the last
  /// branch but the second destination, and it is missing from the bar
  /// entirely for everyone but the admin.
  final String route;

  final IconData icon;
  final IconData selectedIcon;
  final String label;

  /// Only in the bar for the member who created the group.
  final bool adminOnly;
}

const _destinations = [
  _Destination(
    route: AppRoutes.goals,
    icon: Icons.check_circle_outline,
    selectedIcon: Icons.check_circle,
    label: 'Goals',
  ),
  _Destination(
    route: AppRoutes.admin,
    icon: Icons.shield_outlined,
    selectedIcon: Icons.shield,
    label: 'Admin',
    adminOnly: true,
  ),
  _Destination(
    route: AppRoutes.history,
    icon: Icons.history_outlined,
    selectedIcon: Icons.history,
    label: 'History',
  ),
  _Destination(
    route: AppRoutes.group,
    icon: Icons.group_outlined,
    selectedIcon: Icons.group,
    label: 'Group',
  ),
];
