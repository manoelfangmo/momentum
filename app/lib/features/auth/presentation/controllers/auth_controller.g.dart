// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Runs the three auth actions and holds their progress.
///
/// There is no result to carry: the session change drives the rest of the
/// app through `authUserIdProvider`. The forms watch this for the button
/// spinner and the error toast.

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

/// Runs the three auth actions and holds their progress.
///
/// There is no result to carry: the session change drives the rest of the
/// app through `authUserIdProvider`. The forms watch this for the button
/// spinner and the error toast.
final class AuthControllerProvider
    extends $AsyncNotifierProvider<AuthController, void> {
  /// Runs the three auth actions and holds their progress.
  ///
  /// There is no result to carry: the session change drives the rest of the
  /// app through `authUserIdProvider`. The forms watch this for the button
  /// spinner and the error toast.
  AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();
}

String _$authControllerHash() => r'95c50e5228ca48e72e12e8fb5923ac597158ed6e';

/// Runs the three auth actions and holds their progress.
///
/// There is no result to carry: the session change drives the rest of the
/// app through `authUserIdProvider`. The forms watch this for the button
/// spinner and the error toast.

abstract class _$AuthController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
