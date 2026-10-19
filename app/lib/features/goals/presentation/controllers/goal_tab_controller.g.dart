// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_tab_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the [type] tab shows: the shared selection turned into a period, and
/// the selected member's goals for it.
///
/// Every tab follows `selectedDay`. Day is that date, Week the week that
/// contains it, Month its month, Year its year — one moment at four zooms,
/// so moving any tab moves the other three.
///
/// A family keyed by [type]: the four tabs are four caches, and each one
/// reloads on its own.

@ProviderFor(goalTabData)
final goalTabDataProvider = GoalTabDataFamily._();

/// What the [type] tab shows: the shared selection turned into a period, and
/// the selected member's goals for it.
///
/// Every tab follows `selectedDay`. Day is that date, Week the week that
/// contains it, Month its month, Year its year — one moment at four zooms,
/// so moving any tab moves the other three.
///
/// A family keyed by [type]: the four tabs are four caches, and each one
/// reloads on its own.

final class GoalTabDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<GoalTabData>,
          GoalTabData,
          FutureOr<GoalTabData>
        >
    with $FutureModifier<GoalTabData>, $FutureProvider<GoalTabData> {
  /// What the [type] tab shows: the shared selection turned into a period, and
  /// the selected member's goals for it.
  ///
  /// Every tab follows `selectedDay`. Day is that date, Week the week that
  /// contains it, Month its month, Year its year — one moment at four zooms,
  /// so moving any tab moves the other three.
  ///
  /// A family keyed by [type]: the four tabs are four caches, and each one
  /// reloads on its own.
  GoalTabDataProvider._({
    required GoalTabDataFamily super.from,
    required GoalType super.argument,
  }) : super(
         retry: null,
         name: r'goalTabDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$goalTabDataHash();

  @override
  String toString() {
    return r'goalTabDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<GoalTabData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GoalTabData> create(Ref ref) {
    final argument = this.argument as GoalType;
    return goalTabData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GoalTabDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$goalTabDataHash() => r'e0c1db2a9f0aefe30e11926a3831dda36979f364';

/// What the [type] tab shows: the shared selection turned into a period, and
/// the selected member's goals for it.
///
/// Every tab follows `selectedDay`. Day is that date, Week the week that
/// contains it, Month its month, Year its year — one moment at four zooms,
/// so moving any tab moves the other three.
///
/// A family keyed by [type]: the four tabs are four caches, and each one
/// reloads on its own.

final class GoalTabDataFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<GoalTabData>, GoalType> {
  GoalTabDataFamily._()
    : super(
        retry: null,
        name: r'goalTabDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What the [type] tab shows: the shared selection turned into a period, and
  /// the selected member's goals for it.
  ///
  /// Every tab follows `selectedDay`. Day is that date, Week the week that
  /// contains it, Month its month, Year its year — one moment at four zooms,
  /// so moving any tab moves the other three.
  ///
  /// A family keyed by [type]: the four tabs are four caches, and each one
  /// reloads on its own.

  GoalTabDataProvider call(GoalType type) =>
      GoalTabDataProvider._(argument: type, from: this);

  @override
  String toString() => r'goalTabDataProvider';
}
