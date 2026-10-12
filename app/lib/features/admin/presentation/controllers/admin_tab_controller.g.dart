// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_tab_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Which period the [type] admin tab is on.
///
/// Only Day follows a selection. Week, Month and Year are the period
/// containing now and there is no way back through them: ended periods are
/// History's, and the admin screen has none.
///
/// A provider of its own so the tab's data and its header read one answer
/// rather than each working the rule out again.

@ProviderFor(adminPeriod)
final adminPeriodProvider = AdminPeriodFamily._();

/// Which period the [type] admin tab is on.
///
/// Only Day follows a selection. Week, Month and Year are the period
/// containing now and there is no way back through them: ended periods are
/// History's, and the admin screen has none.
///
/// A provider of its own so the tab's data and its header read one answer
/// rather than each working the rule out again.

final class AdminPeriodProvider
    extends $FunctionalProvider<Period, Period, Period>
    with $Provider<Period> {
  /// Which period the [type] admin tab is on.
  ///
  /// Only Day follows a selection. Week, Month and Year are the period
  /// containing now and there is no way back through them: ended periods are
  /// History's, and the admin screen has none.
  ///
  /// A provider of its own so the tab's data and its header read one answer
  /// rather than each working the rule out again.
  AdminPeriodProvider._({
    required AdminPeriodFamily super.from,
    required GoalType super.argument,
  }) : super(
         retry: null,
         name: r'adminPeriodProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adminPeriodHash();

  @override
  String toString() {
    return r'adminPeriodProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Period> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Period create(Ref ref) {
    final argument = this.argument as GoalType;
    return adminPeriod(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Period value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Period>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AdminPeriodProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adminPeriodHash() => r'd97684ad9433ab8b66b62d6e9a53d08623d5222e';

/// Which period the [type] admin tab is on.
///
/// Only Day follows a selection. Week, Month and Year are the period
/// containing now and there is no way back through them: ended periods are
/// History's, and the admin screen has none.
///
/// A provider of its own so the tab's data and its header read one answer
/// rather than each working the rule out again.

final class AdminPeriodFamily extends $Family
    with $FunctionalFamilyOverride<Period, GoalType> {
  AdminPeriodFamily._()
    : super(
        retry: null,
        name: r'adminPeriodProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Which period the [type] admin tab is on.
  ///
  /// Only Day follows a selection. Week, Month and Year are the period
  /// containing now and there is no way back through them: ended periods are
  /// History's, and the admin screen has none.
  ///
  /// A provider of its own so the tab's data and its header read one answer
  /// rather than each working the rule out again.

  AdminPeriodProvider call(GoalType type) =>
      AdminPeriodProvider._(argument: type, from: this);

  @override
  String toString() => r'adminPeriodProvider';
}

/// Every member of the admin's group with their [type] goals for that period.
///
/// One section per member, the ones with nothing set included: the admin is
/// looking for who has not started as much as for who has finished. The
/// signed-in admin comes first, then everyone else by name, which is the
/// order the members read arrives in.
///
/// A family keyed by [type]: the four tabs are four caches, and each one
/// reloads on its own.

@ProviderFor(adminTabData)
final adminTabDataProvider = AdminTabDataFamily._();

/// Every member of the admin's group with their [type] goals for that period.
///
/// One section per member, the ones with nothing set included: the admin is
/// looking for who has not started as much as for who has finished. The
/// signed-in admin comes first, then everyone else by name, which is the
/// order the members read arrives in.
///
/// A family keyed by [type]: the four tabs are four caches, and each one
/// reloads on its own.

final class AdminTabDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MemberGoals>>,
          List<MemberGoals>,
          FutureOr<List<MemberGoals>>
        >
    with
        $FutureModifier<List<MemberGoals>>,
        $FutureProvider<List<MemberGoals>> {
  /// Every member of the admin's group with their [type] goals for that period.
  ///
  /// One section per member, the ones with nothing set included: the admin is
  /// looking for who has not started as much as for who has finished. The
  /// signed-in admin comes first, then everyone else by name, which is the
  /// order the members read arrives in.
  ///
  /// A family keyed by [type]: the four tabs are four caches, and each one
  /// reloads on its own.
  AdminTabDataProvider._({
    required AdminTabDataFamily super.from,
    required GoalType super.argument,
  }) : super(
         retry: null,
         name: r'adminTabDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adminTabDataHash();

  @override
  String toString() {
    return r'adminTabDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<MemberGoals>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MemberGoals>> create(Ref ref) {
    final argument = this.argument as GoalType;
    return adminTabData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminTabDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adminTabDataHash() => r'026d259dbaf344e5cc5181956928929ae6225b90';

/// Every member of the admin's group with their [type] goals for that period.
///
/// One section per member, the ones with nothing set included: the admin is
/// looking for who has not started as much as for who has finished. The
/// signed-in admin comes first, then everyone else by name, which is the
/// order the members read arrives in.
///
/// A family keyed by [type]: the four tabs are four caches, and each one
/// reloads on its own.

final class AdminTabDataFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<MemberGoals>>, GoalType> {
  AdminTabDataFamily._()
    : super(
        retry: null,
        name: r'adminTabDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Every member of the admin's group with their [type] goals for that period.
  ///
  /// One section per member, the ones with nothing set included: the admin is
  /// looking for who has not started as much as for who has finished. The
  /// signed-in admin comes first, then everyone else by name, which is the
  /// order the members read arrives in.
  ///
  /// A family keyed by [type]: the four tabs are four caches, and each one
  /// reloads on its own.

  AdminTabDataProvider call(GoalType type) =>
      AdminTabDataProvider._(argument: type, from: this);

  @override
  String toString() => r'adminTabDataProvider';
}
