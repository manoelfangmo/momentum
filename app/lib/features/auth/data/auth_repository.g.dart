// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'0c608e320cde0d7d39a0a62d19d993d621847c9d';

/// Id of the signed-in user, or null when signed out.
///
/// Kept alive because the session outlives any one screen, and it is what
/// `currentMemberProvider` and the router watch.

@ProviderFor(authUserId)
final authUserIdProvider = AuthUserIdProvider._();

/// Id of the signed-in user, or null when signed out.
///
/// Kept alive because the session outlives any one screen, and it is what
/// `currentMemberProvider` and the router watch.

final class AuthUserIdProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, Stream<String?>>
    with $FutureModifier<String?>, $StreamProvider<String?> {
  /// Id of the signed-in user, or null when signed out.
  ///
  /// Kept alive because the session outlives any one screen, and it is what
  /// `currentMemberProvider` and the router watch.
  AuthUserIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authUserIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authUserIdHash();

  @$internal
  @override
  $StreamProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String?> create(Ref ref) {
    return authUserId(ref);
  }
}

String _$authUserIdHash() => r'd6f18020e4c43a08fe2b04ca0c01e9abf1c19e54';
