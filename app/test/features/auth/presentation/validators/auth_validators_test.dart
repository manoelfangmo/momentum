import 'package:app/features/auth/presentation/validators/auth_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('email needs one @ and a dotted domain', () {
    expect(validateEmail('ada@example.com'), isNull);
    expect(validateEmail('  ada@example.com  '), isNull);
    expect(validateEmail(null), isNotNull);
    expect(validateEmail(''), isNotNull);
    expect(validateEmail('ada@example'), isNotNull);
    expect(validateEmail('ada example.com'), isNotNull);
    expect(validateEmail('a@b@example.com'), isNotNull);
  });

  test('password needs $minPasswordLength characters', () {
    expect(validatePassword('a' * minPasswordLength), isNull);
    expect(validatePassword('a' * (minPasswordLength - 1)), isNotNull);
    expect(validatePassword(null), isNotNull);
  });

  test('password keeps leading and trailing spaces', () {
    expect(validatePassword('  ' * minPasswordLength), isNull);
  });

  test('name is 1 to $maxNameLength characters after trimming', () {
    expect(validateName('Ada'), isNull);
    expect(validateName('a' * maxNameLength), isNull);
    expect(validateName('a' * (maxNameLength + 1)), isNotNull);
    expect(validateName('   '), isNotNull);
    expect(validateName(null), isNotNull);
  });
}
