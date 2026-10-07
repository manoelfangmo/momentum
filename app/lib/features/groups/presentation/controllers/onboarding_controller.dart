import 'dart:async';

import 'package:app/features/auth/data/member_repository.dart';
import 'package:app/features/groups/data/groups_repository.dart';
import 'package:app/features/groups/domain/group.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_controller.g.dart';

/// Runs the two ways out of onboarding and holds their progress.
///
/// Neither card renders the new [Group]: the member row now has a `groupId`,
/// and invalidating `currentMemberProvider` is what makes the router take the
/// member to `/goals`. The cards watch this for the button spinner and the
/// error toast.
@riverpod
class OnboardingController extends _$OnboardingController {
  @override
  FutureOr<void> build() {}

  Future<void> create(String name) {
    return _run(() => ref.read(groupsRepositoryProvider).createGroup(name));
  }

  Future<void> join(String code) {
    return _run(() => ref.read(groupsRepositoryProvider).joinGroup(code));
  }

  Future<void> _run(Future<Group> Function() action) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(action);

    if (result case AsyncError(:final error, :final stackTrace)) {
      state = AsyncError(error, stackTrace);
      return;
    }

    // The redirect this invalidation triggers disposes the page watching this
    // notifier, so the state is settled first.
    state = const AsyncData(null);
    ref.invalidate(currentMemberProvider);
    ref.invalidate(groupMembersProvider);
  }
}
