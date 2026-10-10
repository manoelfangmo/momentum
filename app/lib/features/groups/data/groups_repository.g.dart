// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'groups_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(groupsRepository)
final groupsRepositoryProvider = GroupsRepositoryProvider._();

final class GroupsRepositoryProvider
    extends
        $FunctionalProvider<
          GroupsRepository,
          GroupsRepository,
          GroupsRepository
        >
    with $Provider<GroupsRepository> {
  GroupsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupsRepositoryHash();

  @$internal
  @override
  $ProviderElement<GroupsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GroupsRepository create(Ref ref) {
    return groupsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupsRepository>(value),
    );
  }
}

String _$groupsRepositoryHash() => r'e8b96a8bb91ad62f127d40de40163e26ddd0355d';

/// The signed-in member's group.
///
/// The router keeps a member without a group on onboarding, so by the time
/// anything watches this there is a group id to read.

@ProviderFor(currentGroup)
final currentGroupProvider = CurrentGroupProvider._();

/// The signed-in member's group.
///
/// The router keeps a member without a group on onboarding, so by the time
/// anything watches this there is a group id to read.

final class CurrentGroupProvider
    extends $FunctionalProvider<AsyncValue<Group>, Group, FutureOr<Group>>
    with $FutureModifier<Group>, $FutureProvider<Group> {
  /// The signed-in member's group.
  ///
  /// The router keeps a member without a group on onboarding, so by the time
  /// anything watches this there is a group id to read.
  CurrentGroupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentGroupProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentGroupHash();

  @$internal
  @override
  $FutureProviderElement<Group> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Group> create(Ref ref) {
    return currentGroup(ref);
  }
}

String _$currentGroupHash() => r'db8dd4dfe9b10be3c04167aaef55fcc02b55f4b8';

/// Everyone in [groupId]. A family, so the group page and the member picker
/// in the goals tabs share one cache.

@ProviderFor(groupMembers)
final groupMembersProvider = GroupMembersFamily._();

/// Everyone in [groupId]. A family, so the group page and the member picker
/// in the goals tabs share one cache.

final class GroupMembersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Member>>,
          List<Member>,
          FutureOr<List<Member>>
        >
    with $FutureModifier<List<Member>>, $FutureProvider<List<Member>> {
  /// Everyone in [groupId]. A family, so the group page and the member picker
  /// in the goals tabs share one cache.
  GroupMembersProvider._({
    required GroupMembersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupMembersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupMembersHash();

  @override
  String toString() {
    return r'groupMembersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Member>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Member>> create(Ref ref) {
    final argument = this.argument as String;
    return groupMembers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupMembersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupMembersHash() => r'2716c7537e73d5fcb2f77edcc9592882f59fb6f8';

/// Everyone in [groupId]. A family, so the group page and the member picker
/// in the goals tabs share one cache.

final class GroupMembersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Member>>, String> {
  GroupMembersFamily._()
    : super(
        retry: null,
        name: r'groupMembersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Everyone in [groupId]. A family, so the group page and the member picker
  /// in the goals tabs share one cache.

  GroupMembersProvider call(String groupId) =>
      GroupMembersProvider._(argument: groupId, from: this);

  @override
  String toString() => r'groupMembersProvider';
}

/// Whether the signed-in member is the admin of their group.
///
/// The admin is whoever created the group, so there is nothing to read but
/// `groups.created_by`: no admin column, no admin table, one per group, no
/// transfer. `is_group_admin()` answers the same question in SQL, which is
/// what actually guards the admin RPCs; this decides what the app offers.
///
/// False rather than an error for a member with no group — they are on
/// onboarding, where there is no admin to be.

@ProviderFor(isGroupAdmin)
final isGroupAdminProvider = IsGroupAdminProvider._();

/// Whether the signed-in member is the admin of their group.
///
/// The admin is whoever created the group, so there is nothing to read but
/// `groups.created_by`: no admin column, no admin table, one per group, no
/// transfer. `is_group_admin()` answers the same question in SQL, which is
/// what actually guards the admin RPCs; this decides what the app offers.
///
/// False rather than an error for a member with no group — they are on
/// onboarding, where there is no admin to be.

final class IsGroupAdminProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the signed-in member is the admin of their group.
  ///
  /// The admin is whoever created the group, so there is nothing to read but
  /// `groups.created_by`: no admin column, no admin table, one per group, no
  /// transfer. `is_group_admin()` answers the same question in SQL, which is
  /// what actually guards the admin RPCs; this decides what the app offers.
  ///
  /// False rather than an error for a member with no group — they are on
  /// onboarding, where there is no admin to be.
  IsGroupAdminProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isGroupAdminProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isGroupAdminHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return isGroupAdmin(ref);
  }
}

String _$isGroupAdminHash() => r'22a7ba1d13547fde070a787e51b282b75d83265d';
