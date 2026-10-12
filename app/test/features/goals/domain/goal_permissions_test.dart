import 'package:app/core/domain/domain.dart';
import 'package:app/features/goals/domain/goal.dart';
import 'package:app/features/goals/domain/goal_permissions.dart';
import 'package:app/features/goals/domain/goal_status.dart';
import 'package:flutter_test/flutter_test.dart';

const _member = 'user-1';
const _other = 'user-2';
const _admin = 'user-3';

/// Who is looking, and at whose goal. The four that behave differently: the
/// admin is two of them because owning the goal takes un-verify away.
enum _Viewer {
  owner('the owner', viewerId: _member, ownerId: _member, isAdmin: false),
  otherMember(
    'another member',
    viewerId: _other,
    ownerId: _member,
    isAdmin: false,
  ),
  adminOwner(
    'the admin on their own goal',
    viewerId: _admin,
    ownerId: _admin,
    isAdmin: true,
  ),
  admin(
    'the admin on a goal they do not own',
    viewerId: _admin,
    ownerId: _member,
    isAdmin: true,
  );

  const _Viewer(
    this.label, {
    required this.viewerId,
    required this.ownerId,
    required this.isAdmin,
  });

  final String label;
  final String viewerId;
  final String ownerId;
  final bool isAdmin;
}

/// The seven answers the matrix produces, named for what they let through.
/// "Manage" is edit and delete, which always move together.
const _nothing = GoalPermissions.none;

const _statusOnly = GoalPermissions(
  canChangeStatus: true,
  canVerify: false,
  canUnverify: false,
  canEdit: false,
  canDelete: false,
);

const _verifyOnly = GoalPermissions(
  canChangeStatus: false,
  canVerify: true,
  canUnverify: false,
  canEdit: false,
  canDelete: false,
);

const _manageOnly = GoalPermissions(
  canChangeStatus: false,
  canVerify: false,
  canUnverify: false,
  canEdit: true,
  canDelete: true,
);

const _statusAndManage = GoalPermissions(
  canChangeStatus: true,
  canVerify: false,
  canUnverify: false,
  canEdit: true,
  canDelete: true,
);

const _statusVerifyAndManage = GoalPermissions(
  canChangeStatus: true,
  canVerify: true,
  canUnverify: false,
  canEdit: true,
  canDelete: true,
);

const _unverifyAndManage = GoalPermissions(
  canChangeStatus: false,
  canVerify: false,
  canUnverify: true,
  canEdit: true,
  canDelete: true,
);

typedef _Row = (
  _Viewer,
  GoalStatus,
  bool verified,
  bool assigned,
  GoalPermissions,
);

/// Every viewer against every goal state: three statuses, verified or not,
/// assigned or not. Verified rows for a status other than complete cannot
/// happen in the database, and are here so the function is total.
const _matrix = <_Row>[
  // The owner moves their own goal, and owns the words on it until either
  // verification locks it or the admin assigned it in the first place.
  (_Viewer.owner, GoalStatus.notStarted, false, false, _statusAndManage),
  (_Viewer.owner, GoalStatus.notStarted, false, true, _statusOnly),
  (_Viewer.owner, GoalStatus.notStarted, true, false, _nothing),
  (_Viewer.owner, GoalStatus.notStarted, true, true, _nothing),
  (_Viewer.owner, GoalStatus.inProgress, false, false, _statusAndManage),
  (_Viewer.owner, GoalStatus.inProgress, false, true, _statusOnly),
  (_Viewer.owner, GoalStatus.inProgress, true, false, _nothing),
  (_Viewer.owner, GoalStatus.inProgress, true, true, _nothing),
  (_Viewer.owner, GoalStatus.complete, false, false, _statusAndManage),
  (_Viewer.owner, GoalStatus.complete, false, true, _statusOnly),
  (_Viewer.owner, GoalStatus.complete, true, false, _nothing),
  (_Viewer.owner, GoalStatus.complete, true, true, _nothing),

  // Everyone else has exactly one thing to offer, and only on a complete
  // goal nobody has verified yet.
  (_Viewer.otherMember, GoalStatus.notStarted, false, false, _nothing),
  (_Viewer.otherMember, GoalStatus.notStarted, false, true, _nothing),
  (_Viewer.otherMember, GoalStatus.notStarted, true, false, _nothing),
  (_Viewer.otherMember, GoalStatus.notStarted, true, true, _nothing),
  (_Viewer.otherMember, GoalStatus.inProgress, false, false, _nothing),
  (_Viewer.otherMember, GoalStatus.inProgress, false, true, _nothing),
  (_Viewer.otherMember, GoalStatus.inProgress, true, false, _nothing),
  (_Viewer.otherMember, GoalStatus.inProgress, true, true, _nothing),
  (_Viewer.otherMember, GoalStatus.complete, false, false, _verifyOnly),
  (_Viewer.otherMember, GoalStatus.complete, false, true, _verifyOnly),
  (_Viewer.otherMember, GoalStatus.complete, true, false, _nothing),
  (_Viewer.otherMember, GoalStatus.complete, true, true, _nothing),

  // On their own goal the admin is an owner who can also rename a verified
  // one. No verify and no un-verify: both are somebody else's to do.
  (_Viewer.adminOwner, GoalStatus.notStarted, false, false, _statusAndManage),
  (_Viewer.adminOwner, GoalStatus.notStarted, false, true, _statusAndManage),
  (_Viewer.adminOwner, GoalStatus.notStarted, true, false, _manageOnly),
  (_Viewer.adminOwner, GoalStatus.notStarted, true, true, _manageOnly),
  (_Viewer.adminOwner, GoalStatus.inProgress, false, false, _statusAndManage),
  (_Viewer.adminOwner, GoalStatus.inProgress, false, true, _statusAndManage),
  (_Viewer.adminOwner, GoalStatus.inProgress, true, false, _manageOnly),
  (_Viewer.adminOwner, GoalStatus.inProgress, true, true, _manageOnly),
  (_Viewer.adminOwner, GoalStatus.complete, false, false, _statusAndManage),
  (_Viewer.adminOwner, GoalStatus.complete, false, true, _statusAndManage),
  (_Viewer.adminOwner, GoalStatus.complete, true, false, _manageOnly),
  (_Viewer.adminOwner, GoalStatus.complete, true, true, _manageOnly),

  // On anyone else's goal the admin reaches everything, and verification is
  // the one state that narrows them: unlock it before moving it.
  (_Viewer.admin, GoalStatus.notStarted, false, false, _statusAndManage),
  (_Viewer.admin, GoalStatus.notStarted, false, true, _statusAndManage),
  (_Viewer.admin, GoalStatus.notStarted, true, false, _unverifyAndManage),
  (_Viewer.admin, GoalStatus.notStarted, true, true, _unverifyAndManage),
  (_Viewer.admin, GoalStatus.inProgress, false, false, _statusAndManage),
  (_Viewer.admin, GoalStatus.inProgress, false, true, _statusAndManage),
  (_Viewer.admin, GoalStatus.inProgress, true, false, _unverifyAndManage),
  (_Viewer.admin, GoalStatus.inProgress, true, true, _unverifyAndManage),
  (_Viewer.admin, GoalStatus.complete, false, false, _statusVerifyAndManage),
  (_Viewer.admin, GoalStatus.complete, false, true, _statusVerifyAndManage),
  (_Viewer.admin, GoalStatus.complete, true, false, _unverifyAndManage),
  (_Viewer.admin, GoalStatus.complete, true, true, _unverifyAndManage),
];

Goal goalOwnedBy(
  String ownerId, {
  GoalStatus status = GoalStatus.notStarted,
  bool verified = false,
  bool assigned = false,
}) => Goal(
  id: 'goal-1',
  ownerId: ownerId,
  assignedBy: assigned ? _admin : null,
  groupId: 'group-1',
  title: 'Run 5k',
  type: GoalType.daily,
  deadline: DateTime(2026, 10, 6, 23, 59, 59, 999),
  status: status,
  verified: verified,
  createdAt: DateTime(2026, 10, 6, 7),
);

void main() {
  group('permissionsFor', () {
    for (final (viewer, status, verified, assigned, expected) in _matrix) {
      final state = [
        status.name,
        if (verified) 'verified' else 'unverified',
        if (assigned) 'assigned' else 'own',
      ].join(' ');

      test('${viewer.label}, $state goal', () {
        expect(
          permissionsFor(
            goalOwnedBy(
              viewer.ownerId,
              status: status,
              verified: verified,
              assigned: assigned,
            ),
            viewerId: viewer.viewerId,
            isAdmin: viewer.isAdmin,
          ),
          expected,
        );
      });
    }

    test('covers every viewer against every goal state once', () {
      expect(
        _matrix.length,
        _Viewer.values.length * GoalStatus.values.length * 2 * 2,
      );
    });
  });

  group('rules the matrix only implies', () {
    test('the deadline passing changes nothing', () {
      final goal = goalOwnedBy(_member, status: GoalStatus.complete);
      final tomorrow = goal.deadline.add(const Duration(days: 1));

      expect(goal.isOverdue(tomorrow), isTrue);
      expect(
        permissionsFor(goal, viewerId: _other, isAdmin: false),
        _verifyOnly,
      );
      expect(
        permissionsFor(goal, viewerId: _member, isAdmin: false),
        _statusAndManage,
      );
    });

    test('un-verifying hands the goal back to its owner', () {
      final verified = goalOwnedBy(
        _member,
        status: GoalStatus.complete,
        verified: true,
      );

      expect(
        permissionsFor(verified, viewerId: _member, isAdmin: false),
        _nothing,
      );
      expect(
        permissionsFor(
          verified.copyWith(verified: false),
          viewerId: _member,
          isAdmin: false,
        ),
        _statusAndManage,
      );
    });

    test('an un-verified goal can be verified again', () {
      final unlocked = goalOwnedBy(_member, status: GoalStatus.complete);

      expect(
        permissionsFor(unlocked, viewerId: _other, isAdmin: false).canVerify,
        isTrue,
      );
    });

    test('editing and deleting always agree', () {
      for (final (viewer, status, verified, assigned, _) in _matrix) {
        final permissions = permissionsFor(
          goalOwnedBy(
            viewer.ownerId,
            status: status,
            verified: verified,
            assigned: assigned,
          ),
          viewerId: viewer.viewerId,
          isAdmin: viewer.isAdmin,
        );

        expect(permissions.canEdit, permissions.canDelete);
      }
    });
  });
}
