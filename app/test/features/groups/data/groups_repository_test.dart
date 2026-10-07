import 'package:app/core/utils/app_exception.dart';
import 'package:app/features/groups/data/groups_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../mocks.dart';

void main() {
  late MockSupabaseClient supabase;
  late GroupsRepository repository;

  setUp(() {
    supabase = MockSupabaseClient();
    repository = GroupsRepository(supabase);
  });

  group('joinGroup', () {
    test('rejects a code that is not a uuid without calling the rpc', () async {
      await expectLater(
        repository.joinGroup('morning-crew'),
        throwsA(isA<ValidationException>()),
      );

      verifyZeroInteractions(supabase);
    });

    test('rejects a truncated paste', () async {
      await expectLater(
        repository.joinGroup('8f14e45f-ceea-467a-9d2e'),
        throwsA(isA<ValidationException>()),
      );

      verifyZeroInteractions(supabase);
    });
  });
}
