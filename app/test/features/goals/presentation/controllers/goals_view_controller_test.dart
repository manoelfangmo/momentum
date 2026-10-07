import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/presentation/controllers/goals_view_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _ada = Member(id: 'user-1', name: 'Ada', groupId: 'group-1');
const _zoe = Member(id: 'user-3', name: 'Zoe', groupId: 'group-2');

void main() {
  final now = DateTime(2026, 10, 7, 8, 30);

  /// Who the override answers with. Reassigning it and invalidating is how a
  /// test plays a sign-in as someone else.
  late Member? signedIn;

  setUp(() => signedIn = _ada);

  /// The member is returned synchronously, the way the page sees it: the router
  /// waits for the member row before `/goals` is reachable.
  ProviderContainer container() {
    final container = ProviderContainer(
      retry: (count, error) => null,
      overrides: [
        currentMemberProvider.overrideWith((ref) => signedIn),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('starts on the signed-in member and on today', () {
    final state = container().read(goalsViewControllerProvider);

    expect(state.selectedMemberId, 'user-1');
    expect(state.selectedDay, DateTime(2026, 10, 7));
  });

  test('selectMember changes whose goals every tab shows', () {
    final c = container();

    c.read(goalsViewControllerProvider.notifier).selectMember('user-2');

    expect(c.read(goalsViewControllerProvider).selectedMemberId, 'user-2');
  });

  test('selectDay keeps the day it was given, at local midnight', () {
    final c = container();

    c
        .read(goalsViewControllerProvider.notifier)
        .selectDay(DateTime(2026, 10, 2, 21, 5));

    expect(
      c.read(goalsViewControllerProvider).selectedDay,
      DateTime(2026, 10, 2),
    );
  });

  test('resetDayToToday comes back to the clock day', () {
    final c = container();
    final controller = c.read(goalsViewControllerProvider.notifier);

    controller.selectDay(DateTime(2026, 10, 2));
    controller.resetDayToToday();

    expect(
      c.read(goalsViewControllerProvider).selectedDay,
      DateTime(2026, 10, 7),
    );
  });

  test('another member row starts the selection over', () {
    final c = container();
    c.listen(goalsViewControllerProvider, (_, _) {});
    c.read(goalsViewControllerProvider.notifier).selectMember('user-2');

    signedIn = _zoe;
    c.invalidate(currentMemberProvider);

    expect(c.read(goalsViewControllerProvider).selectedMemberId, 'user-3');
  });

  test('selects nobody while there is no member', () {
    signedIn = null;
    final c = container();

    expect(
      c.read(goalsViewControllerProvider).selectedMemberId,
      noMemberSelected,
    );
  });
}
