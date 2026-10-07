import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:app/features/history/domain/history_section.dart';
import 'package:app/features/history/presentation/controllers/history_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks.dart';

const _ada = Member(id: 'user-1', name: 'Ada', groupId: 'group-1');

final _now = DateTime(2026, 10, 7, 9);

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
  late Member? signedIn;

  setUp(() {
    signedIn = _ada;
    repository = MockGoalsRepository();
    when(
      repository.fetchGoalsBefore(
        ownerId: anyNamed('ownerId'),
        type: anyNamed('type'),
        before: anyNamed('before'),
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

  Future<List<HistorySection>> read(
    ProviderContainer container,
    GoalType type,
  ) {
    final provider = historySectionsProvider(type);
    container.listen(provider, (_, _) {}, onError: (_, _) {});
    return container.read(provider.future);
  }

  test('asks for the signed-in member, nothing older than this period', () async {
    final yesterday = Period.containing(_now, GoalType.daily).previous();
    final run = goalCalled('Run 5k', yesterday);
    when(
      repository.fetchGoalsBefore(
        ownerId: 'user-1',
        type: GoalType.daily,
        before: Period.containing(_now, GoalType.daily).start,
      ),
    ).thenAnswer((_) async => [run]);
    final c = container();

    final sections = await read(c, GoalType.daily);

    expect(sections, [
      HistorySection(period: yesterday, goals: [run]),
    ]);
    verify(
      repository.fetchGoalsBefore(
        ownerId: 'user-1',
        type: GoalType.daily,
        before: Period.containing(_now, GoalType.daily).start,
      ),
    ).called(1);
  });

  test('each type is its own cache and cutoff', () async {
    final c = container();

    await read(c, GoalType.daily);
    await read(c, GoalType.weekly);

    verify(
      repository.fetchGoalsBefore(
        ownerId: 'user-1',
        type: GoalType.daily,
        before: Period.containing(_now, GoalType.daily).start,
      ),
    ).called(1);
    verify(
      repository.fetchGoalsBefore(
        ownerId: 'user-1',
        type: GoalType.weekly,
        before: Period.containing(_now, GoalType.weekly).start,
      ),
    ).called(1);
  });

  test('never asks for another member', () async {
    await read(container(), GoalType.monthly);

    verify(
      repository.fetchGoalsBefore(
        ownerId: 'user-1',
        type: GoalType.monthly,
        before: Period.containing(_now, GoalType.monthly).start,
      ),
    ).called(1);
    verifyNever(
      repository.fetchGoalsBefore(
        ownerId: 'user-2',
        type: anyNamed('type'),
        before: anyNamed('before'),
      ),
    );
  });

  test('a session on its way out never asks for goals', () async {
    signedIn = null;
    final c = container();

    await expectLater(
      read(c, GoalType.daily),
      throwsA(isA<NotFoundException>()),
    );
    verifyNever(
      repository.fetchGoalsBefore(
        ownerId: anyNamed('ownerId'),
        type: anyNamed('type'),
        before: anyNamed('before'),
      ),
    );
  });

  test('groups the rows the repository returned', () async {
    final monday = Period.containing(DateTime(2026, 10, 5), GoalType.daily);
    final sunday = Period.containing(DateTime(2026, 10, 4), GoalType.daily);
    when(
      repository.fetchGoalsBefore(
        ownerId: 'user-1',
        type: GoalType.daily,
        before: Period.containing(_now, GoalType.daily).start,
      ),
    ).thenAnswer(
      (_) async => [goalCalled('Read', sunday), goalCalled('Run 5k', monday)],
    );

    final sections = await read(container(), GoalType.daily);

    expect(sections.map((section) => section.period), [monday, sunday]);
  });
}
