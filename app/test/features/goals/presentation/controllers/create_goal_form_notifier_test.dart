import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/features/goals/application/goal_service.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:app/features/goals/presentation/controllers/create_goal_form_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks.dart';

final _now = DateTime(2026, 10, 7, 9);

final _saved = Goal(
  id: 'goal-1',
  ownerId: 'user-1',
  groupId: 'group-1',
  title: 'Run 5k',
  type: GoalType.daily,
  deadline: Period.containing(_now, GoalType.daily).deadline,
  status: GoalStatus.pending,
  createdAt: _now,
);

void main() {
  late MockGoalService service;
  late MockGoalsRepository goals;

  setUp(() {
    service = MockGoalService();
    goals = MockGoalsRepository();
    when(
      service.createGoal(title: anyNamed('title'), type: anyNamed('type')),
    ).thenAnswer((_) async => _saved);
    when(
      goals.fetchGoals(
        ownerId: anyNamed('ownerId'),
        period: anyNamed('period'),
      ),
    ).thenAnswer((_) async => []);
  });

  /// The notifier autodisposes, so a listener stands in for the open sheet and
  /// keeps the draft from being collected between calls.
  (ProviderContainer, CreateGoalFormNotifier) formContainer() {
    final container = ProviderContainer(
      retry: (count, error) => null,
      overrides: [
        goalServiceProvider.overrideWithValue(service),
        goalsRepositoryProvider.overrideWithValue(goals),
      ],
    );
    addTearDown(container.dispose);
    container.listen(createGoalFormProvider, (_, _) {});
    return (container, container.read(createGoalFormProvider.notifier));
  }

  test('opens empty', () {
    final (container, _) = formContainer();

    expect(container.read(createGoalFormProvider).title, '');
  });

  test('holds what is typed', () {
    final (container, form) = formContainer();

    form.titleChanged('Run 5k');

    expect(container.read(createGoalFormProvider).title, 'Run 5k');
  });

  test('submits the trimmed title for the type it was given', () async {
    final (_, form) = formContainer();
    form.titleChanged('  Run 5k  ');

    await form.submit(type: GoalType.weekly);

    verify(
      service.createGoal(title: 'Run 5k', type: GoalType.weekly),
    ).called(1);
  });

  test('empties the draft once the goal is saved', () async {
    final (container, form) = formContainer();
    form.titleChanged('Run 5k');

    await form.submit(type: GoalType.daily);

    expect(container.read(createGoalFormProvider).title, '');
  });

  test('re-reads the goals on screen so the new one shows', () async {
    final (container, form) = formContainer();
    final period = Period.containing(_now, GoalType.daily);
    container.listen(goalsForPeriodProvider('user-1', period), (_, _) {});
    await container.read(goalsForPeriodProvider('user-1', period).future);

    await form.submit(type: GoalType.daily);
    await container.read(goalsForPeriodProvider('user-1', period).future);

    verify(goals.fetchGoals(ownerId: 'user-1', period: period)).called(2);
  });

  test('keeps the draft when the save fails, and rethrows', () async {
    when(
      service.createGoal(title: anyNamed('title'), type: anyNamed('type')),
    ).thenThrow(const NetworkException());
    final (container, form) = formContainer();
    form.titleChanged('Run 5k');

    await expectLater(
      form.submit(type: GoalType.daily),
      throwsA(isA<NetworkException>()),
    );
    expect(container.read(createGoalFormProvider).title, 'Run 5k');
  });
}
