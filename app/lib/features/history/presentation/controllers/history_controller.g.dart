// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in member's past [type] goals, grouped by ended period.
///
/// History is self-only: there is no member picker. [before] is the start of
/// the current period, so the period still open stays on Goals.
///
/// A family keyed by [type]: the four tabs are four caches.
///
/// TODO: paginate past periods instead of loading all of them.

@ProviderFor(historySections)
final historySectionsProvider = HistorySectionsFamily._();

/// The signed-in member's past [type] goals, grouped by ended period.
///
/// History is self-only: there is no member picker. [before] is the start of
/// the current period, so the period still open stays on Goals.
///
/// A family keyed by [type]: the four tabs are four caches.
///
/// TODO: paginate past periods instead of loading all of them.

final class HistorySectionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HistorySection>>,
          List<HistorySection>,
          FutureOr<List<HistorySection>>
        >
    with
        $FutureModifier<List<HistorySection>>,
        $FutureProvider<List<HistorySection>> {
  /// The signed-in member's past [type] goals, grouped by ended period.
  ///
  /// History is self-only: there is no member picker. [before] is the start of
  /// the current period, so the period still open stays on Goals.
  ///
  /// A family keyed by [type]: the four tabs are four caches.
  ///
  /// TODO: paginate past periods instead of loading all of them.
  HistorySectionsProvider._({
    required HistorySectionsFamily super.from,
    required GoalType super.argument,
  }) : super(
         retry: null,
         name: r'historySectionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$historySectionsHash();

  @override
  String toString() {
    return r'historySectionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<HistorySection>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<HistorySection>> create(Ref ref) {
    final argument = this.argument as GoalType;
    return historySections(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HistorySectionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$historySectionsHash() => r'eefcc2d9e9849861b8b1c59f81da13d8e9552c6f';

/// The signed-in member's past [type] goals, grouped by ended period.
///
/// History is self-only: there is no member picker. [before] is the start of
/// the current period, so the period still open stays on Goals.
///
/// A family keyed by [type]: the four tabs are four caches.
///
/// TODO: paginate past periods instead of loading all of them.

final class HistorySectionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<HistorySection>>, GoalType> {
  HistorySectionsFamily._()
    : super(
        retry: null,
        name: r'historySectionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The signed-in member's past [type] goals, grouped by ended period.
  ///
  /// History is self-only: there is no member picker. [before] is the start of
  /// the current period, so the period still open stays on Goals.
  ///
  /// A family keyed by [type]: the four tabs are four caches.
  ///
  /// TODO: paginate past periods instead of loading all of them.

  HistorySectionsProvider call(GoalType type) =>
      HistorySectionsProvider._(argument: type, from: this);

  @override
  String toString() => r'historySectionsProvider';
}
