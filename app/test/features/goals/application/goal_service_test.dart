import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/application/goal_service.dart';
import 'package:app/features/goals/data/goals_repository.dart';
import 'package:app/features/goals/data/models.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_action_availability.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../mocks.dart';

const _ada = Member(id: 'user-1', name: 'Ada', groupId: 'group-1');
const _grace = Member(id: 'user-2', name: 'Grace', groupId: 'group-1');
const _unjoined = Member(id: 'user-3', name: 'Lin');

/// A Friday morning: the week it lands in ends on Sunday the 11th.
final _frozen = DateTime(2026, 10, 9, 8, 30);

Goal goalOwnedBy(
  String ownerId, {
  GoalStatus status = GoalStatus.notStarted,
  bool verified = false,
}) => Goal(
  id: 'goal-1',
  ownerId: ownerId,
  groupId: 'group-1',
  title: 'Run 5k',
  type: GoalType.daily,
  deadline: DateTime(2026, 10, 9, 23, 59, 59, 999),
  status: status,
  verified: verified,
  createdAt: _frozen,
);

void main() {
  late MockGoalsRepository repository;

  setUp(() {
    repository = MockGoalsRepository();
    when(repository.createGoal(any))
        .thenAnswer((_) async => goalOwnedBy(_ada.id));
  });

  ProviderContainer containerFor(Member? signedIn) {
    final container = ProviderContainer(
      overrides: [
        goalsRepositoryProvider.overrideWithValue(repository),
        currentMemberProvider.overrideWith((ref) async => signedIn),
        clockProvider.overrideWithValue(() => _frozen),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// The captured command, so a test can assert on what was sent rather than
  /// on how the service put it together.
  CreateGoalCommand sentCommand() =>
      verify(repository.createGoal(captureAny)).captured.single
          as CreateGoalCommand;

  group('createGoal', () {
    test('owns the goal to the signed-in member and their group', () async {
      await containerFor(_ada)
          .read(goalServiceProvider)
          .createGoal(title: 'Run 5k', type: GoalType.daily);

      final command = sentCommand();
      expect(command.ownerId, _ada.id);
      expect(command.groupId, _ada.groupId);
      expect(command.title, 'Run 5k');
    });

    test(
      'deadlines a goal at the end of the current period of its type',
      () async {
        final service = containerFor(_ada).read(goalServiceProvider);

        for (final type in GoalType.values) {
          await service.createGoal(title: 'Run 5k', type: type);

          final command = sentCommand();
          expect(command.type, type);
          expect(command.deadline, Period.containing(_frozen, type).deadline);
          clearInteractions(repository);
        }
      },
    );

    test(
      'takes the deadline from the clock, not from the wall clock',
      () async {
        await containerFor(_ada)
            .read(goalServiceProvider)
            .createGoal(title: 'Run 5k', type: GoalType.weekly);

        // The week of Monday the 5th, which only holds if the clock is frozen.
        expect(sentCommand().deadline, DateTime(2026, 10, 11, 23, 59, 59, 999));
      },
    );

    test('returns the stored goal the repository read back', () async {
      final stored = goalOwnedBy(_ada.id);
      when(repository.createGoal(any)).thenAnswer((_) async => stored);

      final goal = await containerFor(_ada)
          .read(goalServiceProvider)
          .createGoal(title: 'Run 5k', type: GoalType.daily);

      expect(goal, stored);
    });

    test('fails without inserting when the member has no group', () async {
      await expectLater(
        containerFor(_unjoined)
            .read(goalServiceProvider)
            .createGoal(title: 'Run 5k', type: GoalType.daily),
        throwsA(isA<NotFoundException>()),
      );
      verifyZeroInteractions(repository);
    });

    test('fails without inserting when nobody is signed in', () async {
      await expectLater(
        containerFor(null)
            .read(goalServiceProvider)
            .createGoal(title: 'Run 5k', type: GoalType.daily),
        throwsA(isA<NotFoundException>()),
      );
      verifyZeroInteractions(repository);
    });
  });

  group('goalActionAvailability', () {
    Future<GoalActionAvailability> availability(
      Member? signedIn,
      Goal goal,
    ) async {
      final container = containerFor(signedIn);
      container.listen(currentMemberProvider, (_, _) {}, onError: (_, _) {});
      // The provider reads the member synchronously, so it has to be resolved
      // before the first read.
      await container.read(currentMemberProvider.future);
      return container.read(goalActionAvailabilityProvider(goal));
    }

    test('offers the owner a way to change status', () async {
      expect(
        await availability(_ada, goalOwnedBy(_ada.id)),
        const CanChangeStatus(),
      );
    });

    test('offers everyone else a verify on an unverified complete goal', () async {
      expect(
        await availability(
          _grace,
          goalOwnedBy(_ada.id, status: GoalStatus.complete),
        ),
        const CanVerify(),
      );
    });

    test('offers nothing on a verified goal', () async {
      final verified = goalOwnedBy(
        _ada.id,
        status: GoalStatus.complete,
        verified: true,
      );

      expect(await availability(_grace, verified), const NoAction());
    });

    test('offers nothing while there is no member to compare against', () {
      final container = containerFor(null);

      expect(
        container.read(goalActionAvailabilityProvider(goalOwnedBy(_ada.id))),
        const NoAction(),
      );
    });

    test('keeps one cache per goal', () async {
      final container = containerFor(_grace);
      container.listen(currentMemberProvider, (_, _) {}, onError: (_, _) {});
      await container.read(currentMemberProvider.future);
      final mine = goalOwnedBy(_grace.id);
      final theirs = goalOwnedBy(_ada.id, status: GoalStatus.complete);

      expect(
        container.read(goalActionAvailabilityProvider(mine)),
        const CanChangeStatus(),
      );
      expect(
        container.read(goalActionAvailabilityProvider(theirs)),
        const CanVerify(),
      );
    });
  });

  group('canManageGoal', () {
    Future<bool> canManageFor(Member? signedIn, Goal goal) async {
      final container = containerFor(signedIn);
      container.listen(currentMemberProvider, (_, _) {}, onError: (_, _) {});
      await container.read(currentMemberProvider.future);
      return container.read(canManageGoalProvider(goal));
    }

    test('lets the owner manage their unverified goal', () async {
      expect(await canManageFor(_ada, goalOwnedBy(_ada.id)), isTrue);
    });

    test('does not let anyone else manage it', () async {
      expect(await canManageFor(_grace, goalOwnedBy(_ada.id)), isFalse);
    });

    test('locks the goal for the owner once it is verified', () async {
      final verified = goalOwnedBy(
        _ada.id,
        status: GoalStatus.complete,
        verified: true,
      );

      expect(await canManageFor(_ada, verified), isFalse);
    });

    test('offers nothing while there is no member to compare against', () {
      final container = containerFor(null);

      expect(container.read(canManageGoalProvider(goalOwnedBy(_ada.id))), isFalse);
    });
  });
}
