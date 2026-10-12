import 'dart:async';

import 'package:app/features/auth/data/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

/// Runs the three auth actions and holds their progress.
///
/// There is no result to carry: the session change drives the rest of the
/// app through `authUserIdProvider`. The forms watch this for the button
/// spinner and the error toast.
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) {
    return _run(
      () => ref
          .read(authRepositoryProvider)
          .signUp(name: name, email: email, password: password),
    );
  }

  Future<void> signIn({required String email, required String password}) {
    return _run(
      () => ref.read(authRepositoryProvider).signIn(
        email: email,
        password: password,
      ),
    );
  }

  Future<void> signOut() {
    return _run(() => ref.read(authRepositoryProvider).signOut());
  }

  Future<void> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(action);
  }
}
