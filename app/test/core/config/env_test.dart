import 'package:app/core/config/env.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rewrites loopback hosts for the Android emulator', () {
    expect(
      rewriteSupabaseUrl('http://127.0.0.1:54321', isAndroid: true),
      'http://10.0.2.2:54321',
    );
    expect(
      rewriteSupabaseUrl('http://localhost:54321', isAndroid: true),
      'http://10.0.2.2:54321',
    );
    expect(
      rewriteSupabaseUrl('http://127.0.0.1:54321', isAndroid: false),
      'http://127.0.0.1:54321',
    );
    expect(
      rewriteSupabaseUrl('https://example.supabase.co', isAndroid: true),
      'https://example.supabase.co',
    );
  });

  test('throws when --dart-define values are missing', () {
    expect(
      () => Env.supabaseUrl,
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('--dart-define=SUPABASE_URL='),
        ),
      ),
    );
    expect(
      () => Env.supabaseAnonKey,
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('--dart-define=SUPABASE_ANON_KEY='),
        ),
      ),
    );
  });
}
