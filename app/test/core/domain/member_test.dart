import 'package:app/core/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromJson reads snake_case group_id', () {
    final member = Member.fromJson({
      'id': 'member-1',
      'name': 'Ada',
      'group_id': 'group-1',
    });

    expect(member.id, 'member-1');
    expect(member.name, 'Ada');
    expect(member.groupId, 'group-1');
    expect(member.toJson(), {
      'id': 'member-1',
      'name': 'Ada',
      'group_id': 'group-1',
    });
  });

  test('groupId may be null', () {
    final member = Member.fromJson({
      'id': 'member-1',
      'name': 'Ada',
      'group_id': null,
    });

    expect(member.groupId, isNull);
    expect(member, const Member(id: 'member-1', name: 'Ada'));
  });
}
