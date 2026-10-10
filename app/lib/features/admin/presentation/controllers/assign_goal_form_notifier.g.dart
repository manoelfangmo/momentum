// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assign_goal_form_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The draft behind the assign sheet, and the submit that turns it into a
/// row someone else owns.
///
/// Autodisposing, so closing the sheet throws the draft away and the next one
/// opens with nobody picked.

@ProviderFor(AssignGoalFormNotifier)
final assignGoalFormProvider = AssignGoalFormNotifierProvider._();

/// The draft behind the assign sheet, and the submit that turns it into a
/// row someone else owns.
///
/// Autodisposing, so closing the sheet throws the draft away and the next one
/// opens with nobody picked.
final class AssignGoalFormNotifierProvider
    extends $NotifierProvider<AssignGoalFormNotifier, AssignGoalFormState> {
  /// The draft behind the assign sheet, and the submit that turns it into a
  /// row someone else owns.
  ///
  /// Autodisposing, so closing the sheet throws the draft away and the next one
  /// opens with nobody picked.
  AssignGoalFormNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assignGoalFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assignGoalFormNotifierHash();

  @$internal
  @override
  AssignGoalFormNotifier create() => AssignGoalFormNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssignGoalFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssignGoalFormState>(value),
    );
  }
}

String _$assignGoalFormNotifierHash() =>
    r'1b1097653d018ff46786d25b84ceac5fdebbf06d';

/// The draft behind the assign sheet, and the submit that turns it into a
/// row someone else owns.
///
/// Autodisposing, so closing the sheet throws the draft away and the next one
/// opens with nobody picked.

abstract class _$AssignGoalFormNotifier extends $Notifier<AssignGoalFormState> {
  AssignGoalFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AssignGoalFormState, AssignGoalFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AssignGoalFormState, AssignGoalFormState>,
              AssignGoalFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
