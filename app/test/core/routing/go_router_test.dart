import 'dart:async';

import 'package:app/app.dart';
import 'package:app/core/domain/domain.dart';
import 'package:app/core/routing/app_routes.dart';
import 'package:app/core/routing/go_router.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/features/auth/data/auth_repository.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/presentation/goals_page.dart';
import 'package:app/features/history/presentation/history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// `Override`, the type of a `ProviderContainer` override, lives here rather
// than in the main flutter_riverpod export.
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import '../../mocks.dart';

const _withGroup = Member(id: 'user-1', name: 'Ada', groupId: 'group-1');
const _withoutGroup = Member(id: 'user-1', name: 'Ada');

void main() {
  late ProviderContainer container;

  /// Riverpod retries a failed provider ten times with a growing backoff,
  /// which outlives the test timeout.
  Duration? noRetry(int count, Object error) => null;

  /// Mounts the real app over [overrides] and returns its router, so a test
  /// can read where the redirect left it.
  ///
  /// It has to be [App] rather than a bare `MaterialApp.router`: Riverpod
  /// pauses `goRouter`'s subscription to the current member unless a widget
  /// watches `goRouterProvider`, and then the redirect never hears about a
  /// sign-in.
  Future<GoRouter> pumpRouter(
    WidgetTester tester, {
    required List<Override> overrides,
  }) async {
    container = ProviderContainer(retry: noRetry, overrides: overrides);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const App()),
    );
    await tester.pumpAndSettle();
    return container.read(goRouterProvider);
  }

  /// What tapping a link or opening a deep link does once the app is running.
  Future<void> goTo(
    WidgetTester tester,
    GoRouter router,
    String location,
  ) async {
    router.go(location);
    await tester.pumpAndSettle();
  }

  /// `currentMember` as one fixed answer, with no Supabase behind it.
  List<Override> memberIs(FutureOr<Member?> Function(Ref ref) build) => [
    currentMemberProvider.overrideWith(build),
  ];

  Future<void> tapDestination(WidgetTester tester, String label) async {
    await tester.tap(find.widgetWithText(NavigationDestination, label));
    await tester.pumpAndSettle();
  }

  group('redirect', () {
    testWidgets('waits on the splash screen while the session loads', (
      tester,
    ) async {
      final router = await pumpRouter(
        tester,
        // A future that never completes stands in for the moment before
        // Supabase has restored the session.
        overrides: memberIs((ref) => Completer<Member?>().future),
      );

      expect(router.state.matchedLocation, AppRoutes.splash);
      expect(find.text('Momentum'), findsOneWidget);
    });

    testWidgets('sends a signed-out visitor to sign-in', (tester) async {
      final router = await pumpRouter(
        tester,
        overrides: memberIs((ref) => null),
      );

      expect(router.state.matchedLocation, AppRoutes.signIn);
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('keeps a signed-out visitor out of the shell', (tester) async {
      final router = await pumpRouter(
        tester,
        overrides: memberIs((ref) => null),
      );

      await goTo(tester, router, AppRoutes.goals);

      expect(router.state.matchedLocation, AppRoutes.signIn);
    });

    testWidgets('leaves a signed-out visitor on the public pages', (
      tester,
    ) async {
      final router = await pumpRouter(
        tester,
        overrides: memberIs((ref) => null),
      );

      await goTo(tester, router, AppRoutes.signUp);

      expect(router.state.matchedLocation, AppRoutes.signUp);
    });

    testWidgets('sends a member with no group to onboarding', (tester) async {
      final router = await pumpRouter(
        tester,
        overrides: memberIs((ref) => _withoutGroup),
      );

      expect(router.state.matchedLocation, AppRoutes.onboarding);
    });

    testWidgets('keeps a member with no group out of the shell', (
      tester,
    ) async {
      final router = await pumpRouter(
        tester,
        overrides: memberIs((ref) => _withoutGroup),
      );

      await goTo(tester, router, AppRoutes.history);

      expect(router.state.matchedLocation, AppRoutes.onboarding);
    });

    testWidgets('sends a member with a group to goals', (tester) async {
      final router = await pumpRouter(
        tester,
        overrides: memberIs((ref) => _withGroup),
      );

      expect(router.state.matchedLocation, AppRoutes.goals);
    });

    for (final from in [
      AppRoutes.splash,
      AppRoutes.signIn,
      AppRoutes.signUp,
      AppRoutes.onboarding,
    ]) {
      testWidgets('sends a member with a group away from $from', (
        tester,
      ) async {
        final router = await pumpRouter(
          tester,
          overrides: memberIs((ref) => _withGroup),
        );

        await goTo(tester, router, from);

        expect(router.state.matchedLocation, AppRoutes.goals);
      });
    }

    testWidgets('treats an unreadable member row as signed out', (
      tester,
    ) async {
      final router = await pumpRouter(
        tester,
        overrides: memberIs((ref) => Future.error(const NotFoundException())),
      );

      expect(router.state.matchedLocation, AppRoutes.signIn);
    });
  });

  group('home shell', () {
    testWidgets('the navigation bar moves between the three branches', (
      tester,
    ) async {
      final router = await pumpRouter(
        tester,
        overrides: memberIs((ref) => _withGroup),
      );

      await tapDestination(tester, 'History');
      expect(router.state.matchedLocation, AppRoutes.history);

      await tapDestination(tester, 'Group');
      expect(router.state.matchedLocation, AppRoutes.group);

      await tapDestination(tester, 'Goals');
      expect(router.state.matchedLocation, AppRoutes.goals);
    });

    testWidgets('a branch stays alive while another one is on screen', (
      tester,
    ) async {
      await pumpRouter(tester, overrides: memberIs((ref) => _withGroup));

      await tapDestination(tester, 'History');

      // The indexed stack only takes Goals off screen. Its navigator and the
      // state under it are still there, which is what keeps the tab and
      // scroll position when you come back.
      expect(find.byType(GoalsPage, skipOffstage: false), findsOneWidget);
      expect(find.byType(HistoryPage), findsOneWidget);
    });
  });

  group('reacting to the member changing', () {
    late MockMemberRepository memberRepository;
    late StreamController<String?> userIds;

    setUp(() {
      memberRepository = MockMemberRepository();
      userIds = StreamController<String?>();
      addTearDown(userIds.close);
    });

    /// The real chain with only its Supabase edges replaced: auth ids come
    /// from [userIds], the member row from [memberRepository].
    Future<GoRouter> pumpSession(WidgetTester tester) => pumpRouter(
      tester,
      overrides: [
        authUserIdProvider.overrideWith((ref) => userIds.stream),
        memberRepositoryProvider.overrideWithValue(memberRepository),
      ],
    );

    testWidgets('follows a sign-in and a sign-out without a restart', (
      tester,
    ) async {
      when(
        memberRepository.fetchMember('user-1'),
      ).thenAnswer((_) async => _withGroup);

      final router = await pumpSession(tester);
      expect(router.state.matchedLocation, AppRoutes.splash);

      userIds.add(null);
      await tester.pumpAndSettle();
      expect(router.state.matchedLocation, AppRoutes.signIn);

      userIds.add('user-1');
      await tester.pumpAndSettle();
      expect(router.state.matchedLocation, AppRoutes.goals);

      userIds.add(null);
      await tester.pumpAndSettle();
      expect(router.state.matchedLocation, AppRoutes.signIn);
    });

    testWidgets('leaves onboarding when joining a group is invalidated', (
      tester,
    ) async {
      final rows = <Member>[_withoutGroup, _withGroup];
      when(
        memberRepository.fetchMember('user-1'),
      ).thenAnswer((_) async => rows.removeAt(0));

      final router = await pumpSession(tester);
      userIds.add('user-1');
      await tester.pumpAndSettle();
      expect(router.state.matchedLocation, AppRoutes.onboarding);

      // What the join-group form does once the RPC returns.
      container.invalidate(currentMemberProvider);
      await tester.pumpAndSettle();

      expect(router.state.matchedLocation, AppRoutes.goals);
    });
  });
}
