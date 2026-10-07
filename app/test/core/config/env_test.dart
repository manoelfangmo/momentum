import 'package:app/core/config/env.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  test('reads the local Supabase URL and anon key', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: '.env');
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    expect(Env.supabaseUrl, 'http://127.0.0.1:54321');
    expect(Env.supabaseAnonKey, isNotEmpty);

    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(Env.supabaseUrl, 'http://10.0.2.2:54321');
  });
}
