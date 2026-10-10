import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/features/admin/presentation/controllers/assign_goal_form_notifier.dart';
import 'package:app/features/goals/application/goal_service.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks.dart';

final _now = DateTime(2026, 10, 7, 9);

final _assigned = Goal(
  id: 'goal-1',
  ownerId: 'user-2',
  assignedBy: 'user-1',
  groupId: 'group-1',
  title: 'Run 5k',
  type: GoalType.daily,
  deadline: Period.containing(_now, GoalType.daily).deadline,
  status: GoalStatus.notStarted,
  verified: false,
  createdAt: _now,
);

void main() {
  late MockGoalService service;
  late MockGoalsRepository goals;

  setUp(() {
    service = MockGoalService();
    goals = MockGoalsRepository();
    when(
      service.assignGoal(
        ownerId: anyNamed('ownerId'),
        title: anyNamed('title'),
        type: anyNamed('type'),
      ),
    ).thenAnswer((_) async => _assigned);
    when(
      goals.fetchGoals(
        ownerId: anyNamed('ownerId'),
        period: anyNamed('period'),
      ),
    ).thenAnswer((_) async => []);
    when(
      goals.fetchGroupGoals(
        groupId: anyNamed('groupId'),
        period: anyNamed('period'),
      ),
    ).thenAnswer((_) async => []);
  });

  /// The notifier autodisposes, so a listener stands in for the open sheet and
  /// keeps the draft from being collected between calls.
  (ProviderContainer, AssignGoalFormNotifier) formContainer() {
    final container = ProviderContainer(
      retry: (count, error) => null,
      overrides: [
        goalServiceProvider.overrideWithValue(service),
        goalsRepositoryProvider.overrideWithValue(goals),
      ],
    );
    addTearDown(container.dispose);
    container.listen(assignGoalFormProvider, (_, _) {});
    return (container, container.read(assignGoalFormProvider.notifier));
  }

  test('opens with nobody picked and nothing typed', () {
    final (container, _) = formContainer();

    expect(container.read(assignGoalFormProvider).ownerId, isNull);
    expect(container.read(assignGoalFormProvider).title, '');
  });

  test('holds the member and the title', () {
    final (container, form) = formContainer();

    form.ownerChanged('user-2');
    form.titleChanged('Run 5k');

    expect(container.read(assignGoalFormProvider).ownerId, 'user-2');
    expect(container.read(assignGoalFormProvider).title, 'Run 5k');
  });

  test('submits the trimmed title for the member and type given', () async {
    final (_, form) = formContainer();
    form.ownerChanged('user-2');
    form.titleChanged('  Run 5k  ');

    await form.submit(type: GoalType.weekly);

    verify(
      service.assignGoal(
        ownerId: 'user-2',
        title: 'Run 5k',
        type: GoalType.weekly,
      ),
    ).called(1);
  });

  test('refuses to submit before a member is picked', () async {
    final (_, form) = formContainer();
    form.titleChanged('Run 5k');

    await expectLater(
      form.submit(type: GoalType.daily),
      throwsA(isA<ValidationException>()),
    );
    verifyNever(
      service.assignGoal(
        ownerId: anyNamed('ownerId'),
        title: anyNamed('title'),
        type: anyNamed('type'),
      ),
    );
  });

  test('empties the draft once the goal is assigned', () async {
    final (container, form) = formContainer();
    form.ownerChanged('user-2');
    form.titleChanged('Run 5k');

    await form.submit(type: GoalType.daily);

    expect(container.read(assignGoalFormProvider).ownerId, isNull);
    expect(container.read(assignGoalFormProvider).title, '');
  });

  test("re-reads the admin tab and the owner's own tab", () async {
    final (container, form) = formContainer();
    final period = Period.containing(_now, GoalType.daily);
    container.listen(groupGoalsForPeriodProvider('group-1', period), (_, _) {});
    container.listen(goalsForPeriodProvider('user-2', period), (_, _) {});
    await container.read(groupGoalsForPeriodProvider('group-1', period).future);
    await container.read(goalsForPeriodProvider('user-2', period).future);

    form.ownerChanged('user-2');
    form.titleChanged('Run 5k');
    await form.submit(type: GoalType.daily);
    await container.read(groupGoalsForPeriodProvider('group-1', period).future);
    await container.read(goalsForPeriodProvider('user-2', period).future);

    verify(goals.fetchGroupGoals(groupId: 'group-1', period: period)).called(2);
    verify(goals.fetchGoals(ownerId: 'user-2', period: period)).called(2);
  });

  test('keeps the draft when the save fails, and rethrows', () async {
    when(
      service.assignGoal(
        ownerId: anyNamed('ownerId'),
        title: anyNamed('title'),
        type: anyNamed('type'),
      ),
    ).thenThrow(const NetworkException());
    final (container, form) = formContainer();
    form.ownerChanged('user-2');
    form.titleChanged('Run 5k');

    await expectLater(
      form.submit(type: GoalType.daily),
      throwsA(isA<NetworkException>()),
    );
    expect(container.read(assignGoalFormProvider).ownerId, 'user-2');
    expect(container.read(assignGoalFormProvider).title, 'Run 5k');
  });
}
