// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'go_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The one router, built once.
///
/// Signing in, signing out, and joining a group all change where a visitor
/// belongs. None of them rebuilds this provider: the member change notifies
/// [_RouterRefresh], go_router re-runs [_redirectFor], and the existing
/// navigator state survives.
///
/// Read this through `ref.watch` from the widget tree, the way `App` does.
/// Riverpod pauses the subscription below while nothing is watching, and a
/// paused subscription means a sign-in the redirect never hears about.

@ProviderFor(goRouter)
final goRouterProvider = GoRouterProvider._();

/// The one router, built once.
///
/// Signing in, signing out, and joining a group all change where a visitor
/// belongs. None of them rebuilds this provider: the member change notifies
/// [_RouterRefresh], go_router re-runs [_redirectFor], and the existing
/// navigator state survives.
///
/// Read this through `ref.watch` from the widget tree, the way `App` does.
/// Riverpod pauses the subscription below while nothing is watching, and a
/// paused subscription means a sign-in the redirect never hears about.

final class GoRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The one router, built once.
  ///
  /// Signing in, signing out, and joining a group all change where a visitor
  /// belongs. None of them rebuilds this provider: the member change notifies
  /// [_RouterRefresh], go_router re-runs [_redirectFor], and the existing
  /// navigator state survives.
  ///
  /// Read this through `ref.watch` from the widget tree, the way `App` does.
  /// Riverpod pauses the subscription below while nothing is watching, and a
  /// paused subscription means a sign-in the redirect never hears about.
  GoRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return goRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$goRouterHash() => r'6a56d76655c343c7cdd2728ea6182f5cdd5a9fc0';
