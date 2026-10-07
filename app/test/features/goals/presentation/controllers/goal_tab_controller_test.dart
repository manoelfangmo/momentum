import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:app/features/goals/presentation/controllers/goal_tab_controller.dart';
import 'package:app/features/goals/presentation/controllers/goals_view_controller.dart';
import 'package:app/features/goals/presentation/models/goal_tab_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks.dart';

const _ada = Member(id: 'user-1', name: 'Ada', groupId: 'group-1');

/// A Wednesday, so a day in the same week is easy to pick.
final _now = DateTime(2026, 10, 7, 8, 30);

Goal goalCalled(String title, Period period) => Goal(
  id: 'goal-$title',
  ownerId: 'user-1',
  groupId: 'group-1',
  title: title,
  type: period.type,
  deadline: period.deadline,
  status: GoalStatus.pending,
  createdAt: period.start,
);

void main() {
  late MockGoalsRepository repository;

  /// Who the signed-in member is, so a test can take the session away.
  late Member? signedIn;

  setUp(() {
    signedIn = _ada;
    repository = MockGoalsRepository();
    when(
      repository.fetchGoals(
        ownerId: anyNamed('ownerId'),
        period: anyNamed('period'),
      ),
    ).thenAnswer((_) async => []);
  });

  ProviderContainer container() {
    final container = ProviderContainer(
      retry: (count, error) => null,
      overrides: [
        goalsRepositoryProvider.overrideWithValue(repository),
        currentMemberProvider.overrideWith((ref) => signedIn),
        clockProvider.overrideWithValue(() => _now),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<GoalTabData> read(ProviderContainer container, GoalType type) {
    final provider = goalTabDataProvider(type);
    // An async provider does not start until something listens to it.
    container.listen(provider, (_, _) {}, onError: (_, _) {});
    return container.read(provider.future);
  }

  test('the Day tab asks for the selected day', () async {
    final day = Period.containing(DateTime(2026, 10, 5), GoalType.daily);
    final goal = goalCalled('Run 5k', day);
    when(
      repository.fetchGoals(ownerId: 'user-1', period: day),
    ).thenAnswer((_) async => [goal]);
    final c = container();
    c.read(goalsViewControllerProvider.notifier).selectDay(DateTime(2026, 10, 5, 21));

    final tab = await read(c, GoalType.daily);

    expect(tab.period, day);
    expect(tab.goals, [goal]);
  });

  test('the other tabs stay on the current period', () async {
    final c = container();
    c.read(goalsViewControllerProvider.notifier).selectDay(DateTime(2026, 9, 2));

    for (final type in [GoalType.weekly, GoalType.monthly, GoalType.yearly]) {
      final tab = await read(c, type);
      expect(tab.period, Period.containing(_now, type));
    }
  });

  test('the member picked applies to every tab', () async {
    final c = container();
    c.read(goalsViewControllerProvider.notifier).selectMember('user-2');

    for (final type in GoalType.values) {
      final tab = await read(c, type);
      expect(tab.memberId, 'user-2');
      verify(
        repository.fetchGoals(
          ownerId: 'user-2',
          period: Period.containing(_now, type),
        ),
      ).called(1);
    }
  });

  test('a session on its way out never asks for goals', () async {
    signedIn = null;
    final c = container();

    await expectLater(
      read(c, GoalType.daily),
      throwsA(isA<NotFoundException>()),
    );
    verifyNever(
      repository.fetchGoals(
        ownerId: anyNamed('ownerId'),
        period: anyNamed('period'),
      ),
    );
  });

  test('each tab is its own cache', () async {
    final c = container();

    await read(c, GoalType.daily);
    await read(c, GoalType.weekly);

    verify(
      repository.fetchGoals(
        ownerId: 'user-1',
        period: Period.containing(_now, GoalType.daily),
      ),
    ).called(1);
    verify(
      repository.fetchGoals(
        ownerId: 'user-1',
        period: Period.containing(_now, GoalType.weekly),
      ),
    ).called(1);
  });
}
