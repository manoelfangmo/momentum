// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Runs the two ways out of onboarding and holds their progress.
///
/// Neither card renders the new [Group]: the member row now has a `groupId`,
/// and invalidating `currentMemberProvider` is what makes the router take the
/// member to `/goals`. The cards watch this for the button spinner and the
/// error toast.

@ProviderFor(OnboardingController)
final onboardingControllerProvider = OnboardingControllerProvider._();

/// Runs the two ways out of onboarding and holds their progress.
///
/// Neither card renders the new [Group]: the member row now has a `groupId`,
/// and invalidating `currentMemberProvider` is what makes the router take the
/// member to `/goals`. The cards watch this for the button spinner and the
/// error toast.
final class OnboardingControllerProvider
    extends $AsyncNotifierProvider<OnboardingController, void> {
  /// Runs the two ways out of onboarding and holds their progress.
  ///
  /// Neither card renders the new [Group]: the member row now has a `groupId`,
  /// and invalidating `currentMemberProvider` is what makes the router take the
  /// member to `/goals`. The cards watch this for the button spinner and the
  /// error toast.
  OnboardingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingControllerHash();

  @$internal
  @override
  OnboardingController create() => OnboardingController();
}

String _$onboardingControllerHash() =>
    r'f8f9f57c309218ad88ab4f5d221324c68fb27b1c';

/// Runs the two ways out of onboarding and holds their progress.
///
/// Neither card renders the new [Group]: the member row now has a `groupId`,
/// and invalidating `currentMemberProvider` is what makes the router take the
/// member to `/goals`. The cards watch this for the button spinner and the
/// error toast.

abstract class _$OnboardingController extends $AsyncNotifier<void> {
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
