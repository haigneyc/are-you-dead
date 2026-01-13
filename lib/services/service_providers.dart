import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'supabase_service.dart';
import 'supabase_service_interface.dart';

part 'service_providers.g.dart';

/// Provides the Supabase service instance.
/// Override this provider in tests to inject a mock.
@Riverpod(keepAlive: true)
ISupabaseService supabaseService(SupabaseServiceRef ref) {
  return SupabaseService();
}
