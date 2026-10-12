// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_goal_form_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The draft behind the new goal sheet, and the submit that turns it into a
/// row.
///
/// Autodisposing, so closing the sheet throws the draft away and the next one
/// opens empty.

@ProviderFor(CreateGoalFormNotifier)
final createGoalFormProvider = CreateGoalFormNotifierProvider._();

/// The draft behind the new goal sheet, and the submit that turns it into a
/// row.
///
/// Autodisposing, so closing the sheet throws the draft away and the next one
/// opens empty.
final class CreateGoalFormNotifierProvider
    extends $NotifierProvider<CreateGoalFormNotifier, CreateGoalFormState> {
  /// The draft behind the new goal sheet, and the submit that turns it into a
  /// row.
  ///
  /// Autodisposing, so closing the sheet throws the draft away and the next one
  /// opens empty.
  CreateGoalFormNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createGoalFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createGoalFormNotifierHash();

  @$internal
  @override
  CreateGoalFormNotifier create() => CreateGoalFormNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateGoalFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateGoalFormState>(value),
    );
  }
}

String _$createGoalFormNotifierHash() =>
    r'b0112a07588d1ba0ba51e30e5e05fead53158348';

/// The draft behind the new goal sheet, and the submit that turns it into a
/// row.
///
/// Autodisposing, so closing the sheet throws the draft away and the next one
/// opens empty.

abstract class _$CreateGoalFormNotifier extends $Notifier<CreateGoalFormState> {
  CreateGoalFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CreateGoalFormState, CreateGoalFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CreateGoalFormState, CreateGoalFormState>,
              CreateGoalFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
