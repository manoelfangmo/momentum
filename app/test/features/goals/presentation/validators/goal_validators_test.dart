import 'package:app/features/goals/presentation/validators/goal_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validateGoalTitle', () {
    test('accepts a title', () {
      expect(validateGoalTitle('Run 5k'), isNull);
    });

    test('rejects nothing, or only whitespace', () {
      expect(validateGoalTitle(null), 'Say what you want to get done.');
      expect(validateGoalTitle('   '), 'Say what you want to get done.');
    });

    test('measures the trimmed title against the column check', () {
      expect(validateGoalTitle(' ${'a' * maxGoalTitleLength} '), isNull);
      expect(
        validateGoalTitle('a' * (maxGoalTitleLength + 1)),
        'Use $maxGoalTitleLength characters or fewer.',
      );
    });
  });
}
