import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_providers.g.dart';

@riverpod
SupabaseClient supabaseClient(Ref ref) {
  return Supabase.instance.client;
}

@riverpod
Stream<AuthState> authState(Ref ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange;
}
