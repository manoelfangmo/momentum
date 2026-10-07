import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Host the Android emulator uses to reach the development machine's loopback.
const androidEmulatorLoopbackHost = '10.0.2.2';

/// Rewrites `localhost` / `127.0.0.1` to [androidEmulatorLoopbackHost] when
/// [isAndroid] is true. Other platforms keep the URL unchanged.
String rewriteSupabaseUrl(String url, {required bool isAndroid}) {
  if (!isAndroid) return url;
  final uri = Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty) return url;
  if (uri.host != 'localhost' && uri.host != '127.0.0.1') return url;
  return uri.replace(host: androidEmulatorLoopbackHost).toString();
}

/// Supabase connection settings.
///
/// Precedence: `--dart-define=SUPABASE_URL` / `SUPABASE_ANON_KEY`, then `app/.env`.
abstract final class Env {
  static const supabaseUrlDefine = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKeyDefine = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  static String get supabaseUrl {
    return rewriteSupabaseUrl(
      _required('SUPABASE_URL', supabaseUrlDefine),
      isAndroid: _isAndroid,
    );
  }

  static String get supabaseAnonKey =>
      _required('SUPABASE_ANON_KEY', supabaseAnonKeyDefine);

  static bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static String _required(String key, String fromDefine) {
    if (fromDefine.isNotEmpty) return fromDefine;
    final fromFile = dotenv.maybeGet(key);
    if (fromFile != null && fromFile.isNotEmpty) return fromFile;
    throw StateError(
      '$key is missing. Set it in app/.env or pass --dart-define=$key=...',
    );
  }
}
