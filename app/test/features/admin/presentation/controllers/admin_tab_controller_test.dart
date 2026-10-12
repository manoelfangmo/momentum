import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/admin/presentation/controllers/admin_tab_controller.dart';
import 'package:app/features/admin/presentation/controllers/admin_view_controller.dart';
import 'package:app/features/admin/presentation/models/member_goals.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:app/features/groups/data/groups_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks.dart';

/// Zoe created the group, so the admin is last by name. Everyone else is in
/// the order `fetchMembers` returns them in, which is by name.
const _zoe = Member(id: 'user-3', name: 'Zoe', groupId: 'group-1');
const _ada = Member(id: 'user-1', name: 'Ada', groupId: 'group-1');
const _grace = Member(id: 'user-2', name: 'Grace', groupId: 'group-1');

/// A Wednesday, so a day in the same week is easy to pick.
final _now = DateTime(2026, 10, 7, 8, 30);

Goal goalCalled(String title, Period period, {required String ownerId}) => Goal(
  id: 'goal-$title',
  ownerId: ownerId,
  groupId: 'group-1',
  title: title,
  type: period.type,
  deadline: period.deadline,
  status: GoalStatus.notStarted,
  verified: false,
  createdAt: period.start,
);

void main() {
  late MockGoalsRepository goals;
  late MockGroupsRepository groups;

  /// Who the signed-in admin is, so a test can take the session away.
  late Member? signedIn;

  setUp(() {
    signedIn = _zoe;
    goals = MockGoalsRepository();
    groups = MockGroupsRepository();
    when(
      goals.fetchGroupGoals(
        groupId: anyNamed('groupId'),
        period: anyNamed('period'),
      ),
    ).thenAnswer((_) async => []);
    when(groups.fetchMembers('group-1'))
        .thenAnswer((_) async => [_ada, _grace, _zoe]);
  });

  ProviderContainer container() {
    final container = ProviderContainer(
      retry: (count, error) => null,
      overrides: [
        goalsRepositoryProvider.overrideWithValue(goals),
        groupsRepositoryProvider.overrideWithValue(groups),
        currentMemberProvider.overrideWith((ref) => signedIn),
        clockProvider.overrideWithValue(() => _now),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<List<MemberGoals>> read(ProviderContainer container, GoalType type) {
    final provider = adminTabDataProvider(type);
    // An async provider does not start until something listens to it.
    container.listen(provider, (_, _) {}, onError: (_, _) {});
    return container.read(provider.future);
  }

  test('files each goal under the member who owns it', () async {
    final today = Period.containing(_now, GoalType.daily);
    final run = goalCalled('Run 5k', today, ownerId: _ada.id);
    final read5 = goalCalled('Read', today, ownerId: _ada.id);
    final stretch = goalCalled('Stretch', today, ownerId: _grace.id);
    when(goals.fetchGroupGoals(groupId: 'group-1', period: today))
        .thenAnswer((_) async => [run, read5, stretch]);

    final sections = await read(container(), GoalType.daily);

    expect(sections.map((section) => section.member), [
      _zoe,
      _ada,
      _grace,
    ], reason: 'the admin comes first, then everyone else by name');
    expect(sections[1].goals, [run, read5]);
    expect(sections[2].goals, [stretch]);
  });

  test('a member with nothing set still has a section', () async {
    final sections = await read(container(), GoalType.daily);

    expect(sections, hasLength(3));
    expect(sections.every((section) => section.goals.isEmpty), isTrue);
  });

  test('leaves out a goal whose owner has left the group', () async {
    final today = Period.containing(_now, GoalType.daily);
    when(goals.fetchGroupGoals(groupId: 'group-1', period: today)).thenAnswer(
      (_) async => [goalCalled('Run 5k', today, ownerId: 'user-gone')],
    );

    final sections = await read(container(), GoalType.daily);

    expect(sections.map((section) => section.member), [_zoe, _ada, _grace]);
    expect(sections.every((section) => section.goals.isEmpty), isTrue);
  });

  test('the Day tab asks for the selected day', () async {
    final day = Period.containing(DateTime(2026, 10, 5), GoalType.daily);
    final c = container();
    c
        .read(adminViewControllerProvider.notifier)
        .selectDay(DateTime(2026, 10, 5, 21));

    await read(c, GoalType.daily);

    verify(goals.fetchGroupGoals(groupId: 'group-1', period: day)).called(1);
  });

  test('the other tabs stay on the current period', () async {
    final c = container();
    c
        .read(adminViewControllerProvider.notifier)
        .selectDay(DateTime(2026, 9, 2));

    for (final type in [GoalType.weekly, GoalType.monthly, GoalType.yearly]) {
      await read(c, type);

      verify(
        goals.fetchGroupGoals(
          groupId: 'group-1',
          period: Period.containing(_now, type),
        ),
      ).called(1);
    }
  });

  test('a session on its way out never asks for goals', () async {
    signedIn = null;

    await expectLater(
      read(container(), GoalType.daily),
      throwsA(isA<NotFoundException>()),
    );
    verifyNever(
      goals.fetchGroupGoals(
        groupId: anyNamed('groupId'),
        period: anyNamed('period'),
      ),
    );
  });

  test('each tab is its own cache', () async {
    final c = container();

    await read(c, GoalType.daily);
    await read(c, GoalType.weekly);

    for (final type in [GoalType.daily, GoalType.weekly]) {
      verify(
        goals.fetchGroupGoals(
          groupId: 'group-1',
          period: Period.containing(_now, type),
        ),
      ).called(1);
    }
  });
}
