/// Supabase configuration constants
///
/// These values are loaded from environment variables at build time.
/// Pass them using --dart-define:
/// flutter run --dart-define=SUPABASE_URL=xxx --dart-define=SUPABASE_PUBLISHABLE_KEY=xxx
class SupabaseConstants {
  SupabaseConstants._();

  /// Supabase project URL
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Supabase publishable key (client-side, respects RLS)
  /// Note: Legacy dashboards may show this as "anon public" key
  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  /// Check if Supabase is configured
  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
}
