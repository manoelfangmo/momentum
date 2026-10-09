import 'dart:async';

import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:app/features/goals/presentation/controllers/goal_action_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks.dart';

final _now = DateTime(2026, 10, 7, 9);
final _today = Period.containing(_now, GoalType.daily);

final _goal = Goal(
  id: 'goal-1',
  ownerId: 'user-1',
  groupId: 'group-1',
  title: 'Run 5k',
  type: GoalType.daily,
  deadline: _today.deadline,
  status: GoalStatus.notStarted,
  verified: false,
  createdAt: _today.start,
);

final _other = _goal.copyWith(id: 'goal-2', title: 'Read');

void main() {
  late MockGoalsRepository goals;
  late ProviderContainer container;

  setUp(() {
    goals = MockGoalsRepository();
    when(goals.verify(any)).thenAnswer((_) async => _goal);
    when(
      goals.setStatus(any, any),
    ).thenAnswer((_) async => _goal);
    when(goals.updateTitle(any, any)).thenAnswer((_) async => _goal);
    when(goals.deleteGoal(any)).thenAnswer((_) async {});
    when(
      goals.fetchGoals(
        ownerId: anyNamed('ownerId'),
        period: anyNamed('period'),
      ),
    ).thenAnswer((_) async => []);

    container = ProviderContainer(
      retry: (count, error) => null,
      overrides: [goalsRepositoryProvider.overrideWithValue(goals)],
    );
    addTearDown(container.dispose);
  });

  /// The notifier autodisposes, so a listener stands in for the tile.
  GoalActionController controller(String goalId) {
    container.listen(goalActionControllerProvider(goalId), (_, _) {});
    return container.read(goalActionControllerProvider(goalId).notifier);
  }

  AsyncValue<void> state(String goalId) =>
      container.read(goalActionControllerProvider(goalId));

  test('starts idle, not loading', () {
    controller(_goal.id);

    expect(state(_goal.id), const AsyncData<void>(null));
    verifyZeroInteractions(goals);
  });

  test('verify forwards the goal id', () async {
    await controller(_goal.id).verify(_goal);

    verify(goals.verify(_goal.id)).called(1);
    expect(state(_goal.id).hasError, isFalse);
  });

  test('setStatus forwards the goal id and status', () async {
    await controller(_goal.id).setStatus(_goal, GoalStatus.inProgress);

    verify(goals.setStatus(_goal.id, GoalStatus.inProgress)).called(1);
    expect(state(_goal.id).hasError, isFalse);
  });

  test('updateTitle forwards the goal id and the title', () async {
    await controller(_goal.id).updateTitle(_goal, 'Long run');

    verify(goals.updateTitle(_goal.id, 'Long run')).called(1);
    expect(state(_goal.id).hasError, isFalse);
  });

  test('delete forwards the goal id', () async {
    await controller(_goal.id).delete(_goal);

    verify(goals.deleteGoal(_goal.id)).called(1);
    expect(state(_goal.id).hasError, isFalse);
  });

  test('a delete re-reads the list the goal was in', () async {
    container.listen(goalsForPeriodProvider('user-1', _today), (_, _) {});
    await container.read(goalsForPeriodProvider('user-1', _today).future);

    await controller(_goal.id).delete(_goal);
    await container.read(goalsForPeriodProvider('user-1', _today).future);

    verify(goals.fetchGoals(ownerId: 'user-1', period: _today)).called(2);
  });

  test('a rejected delete lands in the state', () async {
    when(goals.deleteGoal(any)).thenThrow(
      const PermissionException('Only the member who set a goal can delete it.'),
    );

    await controller(_goal.id).delete(_goal);

    expect(state(_goal.id).error, isA<PermissionException>());
  });

  test('re-reads the goals on screen so the tile can update', () async {
    container.listen(goalsForPeriodProvider('user-1', _today), (_, _) {});
    await container.read(goalsForPeriodProvider('user-1', _today).future);

    await controller(_goal.id).verify(_goal);
    await container.read(goalsForPeriodProvider('user-1', _today).future);

    verify(goals.fetchGoals(ownerId: 'user-1', period: _today)).called(2);
  });

  test('re-reads history so a past goal updates there too', () async {
    final before = _today.start;
    when(
      goals.fetchGoalsBefore(
        ownerId: anyNamed('ownerId'),
        type: anyNamed('type'),
        before: anyNamed('before'),
      ),
    ).thenAnswer((_) async => []);
    container.listen(
      historyGoalsProvider('user-1', GoalType.daily, before),
      (_, _) {},
    );
    await container.read(
      historyGoalsProvider('user-1', GoalType.daily, before).future,
    );

    await controller(_goal.id).setStatus(_goal, GoalStatus.complete);
    await container.read(
      historyGoalsProvider('user-1', GoalType.daily, before).future,
    );

    verify(
      goals.fetchGoalsBefore(
        ownerId: 'user-1',
        type: GoalType.daily,
        before: before,
      ),
    ).called(2);
  });

  test('is loading while the call is in flight', () async {
    final inFlight = Completer<Goal>();
    when(goals.verify(any)).thenAnswer((_) => inFlight.future);

    final submitted = controller(_goal.id).verify(_goal);
    expect(state(_goal.id).isLoading, isTrue);

    inFlight.complete(_goal);
    await submitted;
    expect(state(_goal.id).isLoading, isFalse);
  });

  test('a loading tile does not lock a different goal', () async {
    final inFlight = Completer<Goal>();
    when(goals.verify(_goal.id)).thenAnswer((_) => inFlight.future);
    controller(_other.id);

    final submitted = controller(_goal.id).verify(_goal);
    expect(state(_goal.id).isLoading, isTrue);
    expect(state(_other.id).isLoading, isFalse);

    inFlight.complete(_goal);
    await submitted;
  });

  test('a rejected RPC lands in the state instead of being thrown', () async {
    when(goals.verify(any)).thenThrow(
      const ValidationException(
        'That goal is already verified. Refresh to see it.',
      ),
    );

    await controller(_goal.id).verify(_goal);

    expect(
      state(_goal.id).error,
      isA<ValidationException>().having(
        (e) => e.message,
        'message',
        startsWith('That goal is already verified.'),
      ),
    );
  });

  test('a retry clears the previous error', () async {
    when(goals.setStatus(any, any)).thenThrow(const NetworkException());
    await controller(_goal.id).setStatus(_goal, GoalStatus.inProgress);
    expect(state(_goal.id).hasError, isTrue);

    when(goals.setStatus(any, any)).thenAnswer((_) async => _goal);
    await controller(_goal.id).setStatus(_goal, GoalStatus.inProgress);

    expect(state(_goal.id).hasError, isFalse);
  });
}
