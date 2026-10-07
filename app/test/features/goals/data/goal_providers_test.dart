import 'package:app/core/domain/domain.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../mocks.dart';

final _today = Period.containing(DateTime(2026, 10, 9, 8), GoalType.daily);
final _thisWeek = Period.containing(DateTime(2026, 10, 9, 8), GoalType.weekly);

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

  setUp(() => repository = MockGoalsRepository());

  ProviderContainer container() {
    final container = ProviderContainer(
      overrides: [goalsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('goalsForPeriod', () {
    test('asks the repository for that member and period', () async {
      final run = goalCalled('Run 5k', _today);
      when(repository.fetchGoals(ownerId: 'user-1', period: _today))
          .thenAnswer((_) async => [run]);
      final goals = goalsForPeriodProvider('user-1', _today);
      final c = container();
      // An async provider does not start until something listens to it.
      c.listen(goals, (_, _) {}, onError: (_, _) {});

      expect(await c.read(goals.future), [run]);
      verify(repository.fetchGoals(ownerId: 'user-1', period: _today))
          .called(1);
    });

    test('keeps one cache per member and period', () async {
      final today = goalCalled('Run 5k', _today);
      final week = goalCalled('Long run', _thisWeek);
      when(repository.fetchGoals(ownerId: 'user-1', period: _today))
          .thenAnswer((_) async => [today]);
      when(repository.fetchGoals(ownerId: 'user-1', period: _thisWeek))
          .thenAnswer((_) async => [week]);
      when(repository.fetchGoals(ownerId: 'user-2', period: _today))
          .thenAnswer((_) async => []);
      final c = container();
      final keys = [
        goalsForPeriodProvider('user-1', _today),
        goalsForPeriodProvider('user-1', _thisWeek),
        goalsForPeriodProvider('user-2', _today),
      ];
      for (final key in keys) {
        c.listen(key, (_, _) {}, onError: (_, _) {});
      }

      expect(await c.read(keys[0].future), [today]);
      expect(await c.read(keys[1].future), [week]);
      expect(await c.read(keys[2].future), isEmpty);
    });

    test('an equal period reuses the first read', () async {
      final sameDay = Period.containing(DateTime(2026, 10, 9, 21), _today.type);
      when(repository.fetchGoals(ownerId: 'user-1', period: _today))
          .thenAnswer((_) async => []);
      final c = container();
      for (final period in [_today, sameDay]) {
        final key = goalsForPeriodProvider('user-1', period);
        c.listen(key, (_, _) {}, onError: (_, _) {});
        await c.read(key.future);
      }

      verify(repository.fetchGoals(ownerId: 'user-1', period: _today))
          .called(1);
    });
  });

  group('historyGoals', () {
    final before = _today.start;

    test('asks the repository for that member, type and cutoff', () async {
      final run = goalCalled('Run 5k', _today);
      when(
        repository.fetchGoalsBefore(
          ownerId: 'user-1',
          type: GoalType.daily,
          before: before,
        ),
      ).thenAnswer((_) async => [run]);
      final history = historyGoalsProvider('user-1', GoalType.daily, before);
      final c = container();
      c.listen(history, (_, _) {}, onError: (_, _) {});

      expect(await c.read(history.future), [run]);
      verify(
        repository.fetchGoalsBefore(
          ownerId: 'user-1',
          type: GoalType.daily,
          before: before,
        ),
      ).called(1);
    });

    test('keeps one cache per member, type and cutoff', () async {
      when(
        repository.fetchGoalsBefore(
          ownerId: anyNamed('ownerId'),
          type: anyNamed('type'),
          before: anyNamed('before'),
        ),
      ).thenAnswer((_) async => []);
      final c = container();
      final keys = [
        historyGoalsProvider('user-1', GoalType.daily, before),
        historyGoalsProvider('user-1', GoalType.weekly, before),
        historyGoalsProvider('user-2', GoalType.daily, before),
      ];
      for (final key in keys) {
        c.listen(key, (_, _) {}, onError: (_, _) {});
        await c.read(key.future);
      }

      verify(
        repository.fetchGoalsBefore(
          ownerId: 'user-1',
          type: GoalType.daily,
          before: before,
        ),
      ).called(1);
      verify(
        repository.fetchGoalsBefore(
          ownerId: 'user-1',
          type: GoalType.weekly,
          before: before,
        ),
      ).called(1);
      verify(
        repository.fetchGoalsBefore(
          ownerId: 'user-2',
          type: GoalType.daily,
          before: before,
        ),
      ).called(1);
    });
  });
}
