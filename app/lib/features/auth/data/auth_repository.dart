import 'package:app/core/utils/app_exception.dart';
import 'package:app/core/utils/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
// Supabase has an AuthException too. Hide it so the unqualified name is the
// one this repository throws, and reach for the Supabase one through `gotrue`.
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:supabase_flutter/supabase_flutter.dart' as gotrue
    show AuthException;

part 'auth_repository.g.dart';

/// Supabase Auth. Nothing else in the app touches `client.auth`.
class AuthRepository {
  AuthRepository(this._supabase);

  final SupabaseClient _supabase;

  /// Replays the restored session to each new listener, then every change.
  Stream<AuthState> authStateChanges() => _supabase.auth.onAuthStateChange;

  String? get currentUserID => _supabase.auth.currentUser?.id;

  /// `data` becomes `raw_user_meta_data`, which the `on_auth_user_created`
  /// trigger reads to fill `members.name`.
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) {
    return _guard(
      () => _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      ),
    );
  }

  Future<void> signIn({required String email, required String password}) {
    return _guard(
      () => _supabase.auth.signInWithPassword(email: email, password: password),
    );
  }

  Future<void> signOut() => _guard(_supabase.auth.signOut);

  Future<void> _guard(Future<void> Function() call) async {
    try {
      await call();
    } on AuthRetryableFetchException {
      throw const NetworkException();
    } on gotrue.AuthException catch (error) {
      throw AuthException(error.message);
    }
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    AuthRepository(ref.read(supabaseProvider));

/// Id of the signed-in user, or null when signed out.
///
/// Kept alive because the session outlives any one screen, and it is what
/// `currentMemberProvider` and the router watch.
@Riverpod(keepAlive: true)
Stream<String?> authUserId(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return _userIds(repository).distinct();
}

/// The id Supabase already restored comes first, so a listener that attaches
/// after start-up does not wait for an auth event that may never arrive.
Stream<String?> _userIds(AuthRepository repository) async* {
  yield repository.currentUserID;
  yield* repository.authStateChanges().map((state) => state.session?.user.id);
}
