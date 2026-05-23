class SupabaseConfig {
  const SupabaseConfig._();

  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const devUserId = String.fromEnvironment('SUPABASE_DEV_USER_ID');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
  static bool get hasDevUserId => devUserId.isNotEmpty;
}
