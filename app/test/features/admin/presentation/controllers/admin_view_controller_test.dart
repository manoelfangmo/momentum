import 'package:app/core/domain/domain.dart';
import 'package:app/core/utils/providers.dart';
import 'package:app/features/admin/presentation/controllers/admin_view_controller.dart';
import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/goals/presentation/controllers/goals_view_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _ada = Member(id: 'user-1', name: 'Ada', groupId: 'group-1');

void main() {
  final now = DateTime(2026, 10, 7, 8, 30);

  ProviderContainer container() {
    final container = ProviderContainer(
      retry: (count, error) => null,
      overrides: [
        currentMemberProvider.overrideWith((ref) => _ada),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('starts on the clock day', () {
    expect(
      container().read(adminViewControllerProvider),
      DateTime(2026, 10, 7),
    );
  });

  test('selectDay keeps the day it was given, at local midnight', () {
    final c = container();

    c
        .read(adminViewControllerProvider.notifier)
        .selectDay(DateTime(2026, 10, 2, 21, 5));

    expect(c.read(adminViewControllerProvider), DateTime(2026, 10, 2));
  });

  test('the goals tabs keep their own day', () {
    final c = container();
    c.listen(goalsViewControllerProvider, (_, _) {});

    c
        .read(adminViewControllerProvider.notifier)
        .selectDay(DateTime(2026, 10, 2));

    expect(
      c.read(goalsViewControllerProvider).selectedDay,
      DateTime(2026, 10, 7),
    );
  });

  test('and moving the goals tabs leaves the admin day alone', () {
    final c = container();
    c.listen(adminViewControllerProvider, (_, _) {});

    c
        .read(goalsViewControllerProvider.notifier)
        .selectDay(DateTime(2026, 10, 2));

    expect(c.read(adminViewControllerProvider), DateTime(2026, 10, 7));
  });
}
