// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_view_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Which day the admin's Day tab is on, as a local midnight.
///
/// Its own notifier rather than a field on `GoalsViewController`: the admin
/// moves between the two screens to compare one member's week with the
/// group's, and a date picked on one has no business moving the other.
///
/// Nothing else is selected here. Every admin tab shows the whole group, and
/// only Day has a date to move — Week, Month and Year are always now.

@ProviderFor(AdminViewController)
final adminViewControllerProvider = AdminViewControllerProvider._();

/// Which day the admin's Day tab is on, as a local midnight.
///
/// Its own notifier rather than a field on `GoalsViewController`: the admin
/// moves between the two screens to compare one member's week with the
/// group's, and a date picked on one has no business moving the other.
///
/// Nothing else is selected here. Every admin tab shows the whole group, and
/// only Day has a date to move — Week, Month and Year are always now.
final class AdminViewControllerProvider
    extends $NotifierProvider<AdminViewController, DateTime> {
  /// Which day the admin's Day tab is on, as a local midnight.
  ///
  /// Its own notifier rather than a field on `GoalsViewController`: the admin
  /// moves between the two screens to compare one member's week with the
  /// group's, and a date picked on one has no business moving the other.
  ///
  /// Nothing else is selected here. Every admin tab shows the whole group, and
  /// only Day has a date to move — Week, Month and Year are always now.
  AdminViewControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminViewControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminViewControllerHash();

  @$internal
  @override
  AdminViewController create() => AdminViewController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$adminViewControllerHash() =>
    r'd01dccb43fcf4a740f6b4354c17c82791284e8df';

/// Which day the admin's Day tab is on, as a local midnight.
///
/// Its own notifier rather than a field on `GoalsViewController`: the admin
/// moves between the two screens to compare one member's week with the
/// group's, and a date picked on one has no business moving the other.
///
/// Nothing else is selected here. Every admin tab shows the whole group, and
/// only Day has a date to move — Week, Month and Year are always now.

abstract class _$AdminViewController extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
