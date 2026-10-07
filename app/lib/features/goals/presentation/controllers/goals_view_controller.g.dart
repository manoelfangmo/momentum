// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goals_view_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The selection the four goal tabs share.
///
/// It lives above the tabs rather than inside one, so picking a member or a
/// day holds while the member moves between Day, Week, Month and Year.
///
/// Watching the member row rather than reading it means a sign-in or a group
/// change starts the page over on that member, which is the only sensible
/// thing to show once the previous selection may no longer be in the group.

@ProviderFor(GoalsViewController)
final goalsViewControllerProvider = GoalsViewControllerProvider._();

/// The selection the four goal tabs share.
///
/// It lives above the tabs rather than inside one, so picking a member or a
/// day holds while the member moves between Day, Week, Month and Year.
///
/// Watching the member row rather than reading it means a sign-in or a group
/// change starts the page over on that member, which is the only sensible
/// thing to show once the previous selection may no longer be in the group.
final class GoalsViewControllerProvider
    extends $NotifierProvider<GoalsViewController, GoalsViewState> {
  /// The selection the four goal tabs share.
  ///
  /// It lives above the tabs rather than inside one, so picking a member or a
  /// day holds while the member moves between Day, Week, Month and Year.
  ///
  /// Watching the member row rather than reading it means a sign-in or a group
  /// change starts the page over on that member, which is the only sensible
  /// thing to show once the previous selection may no longer be in the group.
  GoalsViewControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalsViewControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalsViewControllerHash();

  @$internal
  @override
  GoalsViewController create() => GoalsViewController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoalsViewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoalsViewState>(value),
    );
  }
}

String _$goalsViewControllerHash() =>
    r'ad0226332734c50bf72bf2cd16dc6214bcfdba4f';

/// The selection the four goal tabs share.
///
/// It lives above the tabs rather than inside one, so picking a member or a
/// day holds while the member moves between Day, Week, Month and Year.
///
/// Watching the member row rather than reading it means a sign-in or a group
/// change starts the page over on that member, which is the only sensible
/// thing to show once the previous selection may no longer be in the group.

abstract class _$GoalsViewController extends $Notifier<GoalsViewState> {
  GoalsViewState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<GoalsViewState, GoalsViewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GoalsViewState, GoalsViewState>,
              GoalsViewState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
