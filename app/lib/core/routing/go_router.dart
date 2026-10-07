import 'package:app/core/domain/domain.dart';
import 'package:app/core/routing/app_routes.dart';
import 'package:app/core/routing/home_page.dart';
import 'package:app/core/routing/splash_page.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/auth/presentation/sign_in_page.dart';
import 'package:app/features/auth/presentation/sign_up_page.dart';
import 'package:app/features/goals/presentation/goals_page.dart';
import 'package:app/features/groups/presentation/group_page.dart';
import 'package:app/features/groups/presentation/onboarding_page.dart';
import 'package:app/features/history/presentation/history_page.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'go_router.g.dart';

/// The one router, built once.
///
/// Signing in, signing out, and joining a group all change where a visitor
/// belongs. None of them rebuilds this provider: the member change notifies
/// [_RouterRefresh], go_router re-runs [_redirectFor], and the existing
/// navigator state survives.
///
/// Read this through `ref.watch` from the widget tree, the way `App` does.
/// Riverpod pauses the subscription below while nothing is watching, and a
/// paused subscription means a sign-in the redirect never hears about.
@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  final refresh = _RouterRefresh();
  ref.listen(
    currentMemberProvider,
    (_, _) => refresh.notify(),
    onError: (_, _) => refresh.notify(),
  );
  ref.onDispose(refresh.dispose);

  // Made here rather than at the top level so a second router in a test does
  // not fight the first one over the same global keys.
  final goalsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'goals');
  final historyNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'history');
  final groupNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'group');

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) =>
        _redirectFor(ref.read(currentMemberProvider), state.matchedLocation),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, _) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (_, _) => const SignInPage(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (_, _) => const SignUpPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) => const OnboardingPage(),
      ),
      // One branch per navigation bar destination, each with its own
      // navigator, so switching destinations keeps the other two as they were.
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => HomePage(shell: shell),
        branches: [
          StatefulShellBranch(
            navigatorKey: goalsNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.goals,
                builder: (_, _) => const GoalsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: historyNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.history,
                builder: (_, _) => const HistoryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: groupNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.group,
                builder: (_, _) => const GroupPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// The screens a member with a group is finished with.
const _preHomeRoutes = <String>{
  AppRoutes.splash,
  AppRoutes.signIn,
  AppRoutes.signUp,
  AppRoutes.onboarding,
};

/// Where [location] should actually send this visitor, or null to let them
/// through.
///
/// Runs on every navigation, including the ones it causes itself, so each
/// branch has to let its own destination pass or the router loops.
String? _redirectFor(AsyncValue<Member?> currentMember, String location) {
  // Nothing to decide on yet: Supabase is still restoring the session. A
  // refresh keeps the previous value, so only start-up reaches this.
  if (currentMember.isLoading && !currentMember.hasValue) {
    return location == AppRoutes.splash ? null : AppRoutes.splash;
  }

  // Signed out, or the member row refused to load. Either way the only
  // screens that work are the public ones.
  final member = currentMember.value;
  if (member == null) {
    return AppRoutes.publicRoutes.contains(location) ? null : AppRoutes.signIn;
  }

  // Signed in with no group: onboarding is the only screen with anything on
  // it, and the rest of the app assumes a group id.
  if (member.groupId == null) {
    return location == AppRoutes.onboarding ? null : AppRoutes.onboarding;
  }

  return _preHomeRoutes.contains(location) ? AppRoutes.goals : null;
}

/// The bridge from Riverpod to go_router.
///
/// `refreshListenable` is the only way to tell a [GoRouter] to run its
/// redirect again, which is what lets one router instance follow the session.
class _RouterRefresh extends ChangeNotifier {
  void notify() => notifyListeners();
}
