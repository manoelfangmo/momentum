import 'dart:async';

import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/app_exception.dart';
import 'package:app/features/auth/data/auth_repository.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/groups/data/groups_repository.dart';
import 'package:app/features/groups/domain/group.dart';
import 'package:app/features/groups/presentation/controllers/onboarding_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks.dart';

const _code = '8f14e45f-ceea-467a-9d2e-1b2a3c4d5e6f';
const _group = Group(id: _code, name: 'Morning crew', createdBy: 'user-1');
const _ada = Member(id: 'user-1', name: 'Ada', groupId: _code);

void main() {
  late MockGroupsRepository groups;
  late MockMemberRepository members;
  late ProviderContainer container;

  setUp(() {
    groups = MockGroupsRepository();
    members = MockMemberRepository();
    when(members.fetchMember(any)).thenAnswer((_) async => _ada);

    container = ProviderContainer(
      overrides: [
        groupsRepositoryProvider.overrideWithValue(groups),
        // The real currentMemberProvider, so the invalidation the controller
        // relies on can be observed as a second member read.
        authUserIdProvider.overrideWith((ref) => Stream.value('user-1')),
        memberRepositoryProvider.overrideWithValue(members),
      ],
    );
    addTearDown(container.dispose);
    // Subscribe so the notifier survives between reads instead of rebuilding.
    container.listen(onboardingControllerProvider, (_, _) {});
  });

  OnboardingController controller() =>
      container.read(onboardingControllerProvider.notifier);

  AsyncValue<void> state() => container.read(onboardingControllerProvider);

  test('starts idle, not loading', () {
    expect(state(), const AsyncData<void>(null));
    verifyZeroInteractions(groups);
  });

  test('create forwards the name', () async {
    when(groups.createGroup(any)).thenAnswer((_) async => _group);

    await controller().create('Morning crew');

    verify(groups.createGroup('Morning crew')).called(1);
    expect(state().hasError, isFalse);
  });

  test('join forwards the code', () async {
    when(groups.joinGroup(any)).thenAnswer((_) async => _group);

    await controller().join(_code);

    verify(groups.joinGroup(_code)).called(1);
    expect(state().hasError, isFalse);
  });

  test('invalidates the current member so the router can redirect', () async {
    container.listen(currentMemberProvider, (_, _) {}, onError: (_, _) {});
    await container.read(currentMemberProvider.future);
    verify(members.fetchMember('user-1')).called(1);

    when(groups.joinGroup(any)).thenAnswer((_) async => _group);
    await controller().join(_code);
    await container.pump();
    // The reload only reaches the repository once the rebuilt provider has
    // awaited the user id again.
    await container.read(currentMemberProvider.future);

    verify(members.fetchMember('user-1')).called(1);
  });

  test('is loading while the call is in flight', () async {
    final inFlight = Completer<Group>();
    when(groups.createGroup(any)).thenAnswer((_) => inFlight.future);

    final submitted = controller().create('Morning crew');
    expect(state().isLoading, isTrue);

    inFlight.complete(_group);
    await submitted;
    expect(state().isLoading, isFalse);
  });

  test('a rejected join lands in the state and leaves the member alone', () async {
    container.listen(currentMemberProvider, (_, _) {}, onError: (_, _) {});
    await container.read(currentMemberProvider.future);
    // Consumed, so the verifyNever below only sees a reload caused by the join.
    verify(members.fetchMember('user-1')).called(1);
    when(groups.joinGroup(any))
        .thenThrow(const ValidationException('No group has that code.'));

    await controller().join(_code);
    await container.pump();

    expect(
      state().error,
      isA<ValidationException>().having(
        (e) => e.message,
        'message',
        'No group has that code.',
      ),
    );
    verifyNever(members.fetchMember('user-1'));
  });

  test('a retry clears the previous error', () async {
    when(groups.createGroup(any)).thenThrow(const NetworkException());
    await controller().create('Morning crew');
    expect(state().hasError, isTrue);

    when(groups.createGroup(any)).thenAnswer((_) async => _group);
    await controller().create('Morning crew');

    expect(state().hasError, isFalse);
  });
}
