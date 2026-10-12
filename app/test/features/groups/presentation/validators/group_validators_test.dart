import 'package:app/features/groups/presentation/validators/group_validators.dart';
import 'package:flutter_test/flutter_test.dart';

const _code = '8f14e45f-ceea-467a-9d2e-1b2a3c4d5e6f';

void main() {
  group('validateGroupName', () {
    test('accepts a name', () {
      expect(validateGroupName('Morning crew'), isNull);
    });

    test('rejects nothing, or only whitespace', () {
      expect(validateGroupName(null), 'Enter a name for the group.');
      expect(validateGroupName('   '), 'Enter a name for the group.');
    });

    test('measures the trimmed name against the column check', () {
      expect(validateGroupName(' ${'a' * maxGroupNameLength} '), isNull);
      expect(
        validateGroupName('a' * (maxGroupNameLength + 1)),
        'Use $maxGroupNameLength characters or fewer.',
      );
    });
  });

  group('validateGroupCode', () {
    test('accepts a uuid, pasted with whitespace around it', () {
      expect(validateGroupCode(_code), isNull);
      expect(validateGroupCode('  $_code\n'), isNull);
      expect(validateGroupCode(_code.toUpperCase()), isNull);
    });

    test('rejects nothing', () {
      expect(validateGroupCode(null), 'Paste the invite code you were sent.');
      expect(validateGroupCode(' '), 'Paste the invite code you were sent.');
    });

    test('rejects anything that is not a uuid', () {
      const notACode = 'That does not look like an invite code.';

      expect(validateGroupCode('Morning crew'), notACode);
      // A paste that lost its last block.
      expect(validateGroupCode(_code.substring(0, 30)), notACode);
      expect(validateGroupCode('$_code-$_code'), notACode);
    });
  });
}
