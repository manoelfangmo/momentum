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

final _pending = Goal(
  id: 'goal-1',
  ownerId: 'user-1',
  groupId: 'group-1',
  title: 'Run 5k',
  type: GoalType.daily,
  deadline: _today.deadline,
  status: GoalStatus.pending,
  createdAt: _today.start,
);

final _other = _pending.copyWith(id: 'goal-2', title: 'Read');

void main() {
  late MockGoalsRepository goals;
  late ProviderContainer container;

  setUp(() {
    goals = MockGoalsRepository();
    when(goals.verifyComplete(any)).thenAnswer((_) async => _pending);
    when(goals.markMissed(any)).thenAnswer((_) async => _pending);
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
    controller(_pending.id);

    expect(state(_pending.id), const AsyncData<void>(null));
    verifyZeroInteractions(goals);
  });

  test('verify forwards the goal id', () async {
    await controller(_pending.id).verify(_pending);

    verify(goals.verifyComplete(_pending.id)).called(1);
    expect(state(_pending.id).hasError, isFalse);
  });

  test('markMissed forwards the goal id', () async {
    await controller(_pending.id).markMissed(_pending);

    verify(goals.markMissed(_pending.id)).called(1);
    expect(state(_pending.id).hasError, isFalse);
  });

  test('re-reads the goals on screen so the tile can update', () async {
    container.listen(goalsForPeriodProvider('user-1', _today), (_, _) {});
    await container.read(goalsForPeriodProvider('user-1', _today).future);

    await controller(_pending.id).verify(_pending);
    await container.read(goalsForPeriodProvider('user-1', _today).future);

    verify(goals.fetchGoals(ownerId: 'user-1', period: _today)).called(2);
  });

  test('re-reads history so a missed past goal updates there too', () async {
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

    await controller(_pending.id).markMissed(_pending);
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
    when(goals.verifyComplete(any)).thenAnswer((_) => inFlight.future);

    final pending = controller(_pending.id).verify(_pending);
    expect(state(_pending.id).isLoading, isTrue);

    inFlight.complete(_pending);
    await pending;
    expect(state(_pending.id).isLoading, isFalse);
  });

  test('a loading tile does not lock a different goal', () async {
    final inFlight = Completer<Goal>();
    when(goals.verifyComplete(_pending.id)).thenAnswer((_) => inFlight.future);
    controller(_other.id);

    final pending = controller(_pending.id).verify(_pending);
    expect(state(_pending.id).isLoading, isTrue);
    expect(state(_other.id).isLoading, isFalse);

    inFlight.complete(_pending);
    await pending;
  });

  test('a rejected RPC lands in the state instead of being thrown', () async {
    when(goals.verifyComplete(any)).thenThrow(
      const ValidationException(
        'That goal was already settled. Refresh to see where it landed.',
      ),
    );

    await controller(_pending.id).verify(_pending);

    expect(
      state(_pending.id).error,
      isA<ValidationException>().having(
        (e) => e.message,
        'message',
        startsWith('That goal was already settled.'),
      ),
    );
  });

  test('a retry clears the previous error', () async {
    when(goals.markMissed(any)).thenThrow(const NetworkException());
    await controller(_pending.id).markMissed(_pending);
    expect(state(_pending.id).hasError, isTrue);

    when(goals.markMissed(any)).thenAnswer((_) async => _pending);
    await controller(_pending.id).markMissed(_pending);

    expect(state(_pending.id).hasError, isFalse);
  });
}
