import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'providers.g.dart';

/// The one Supabase client.
///
/// Repositories take their client from here instead of reaching for
/// [Supabase.instance], so a test can swap it out.
@Riverpod(keepAlive: true)
SupabaseClient supabase(Ref ref) => Supabase.instance.client;

/// Time source for period math.
///
/// Features call `ref.watch(clockProvider)()` instead of [DateTime.now]
/// so tests can freeze the clock.
@Riverpod(keepAlive: true)
DateTime Function() clock(Ref ref) => DateTime.now;
