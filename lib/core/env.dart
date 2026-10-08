/// Build-time configuration. Pass with
/// `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
class Env {
  Env._();
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Web client id from Google Cloud (used as serverClientId on Android so the
  /// id token audience matches what Supabase expects).
  static const googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
  static const googleIosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

  static const siteUrl = String.fromEnvironment('SITE_URL', defaultValue: 'https://langarseva.app');
  static String get privacyUrl => '$siteUrl/privacy';
  static String get termsUrl => '$siteUrl/terms';
  static String langarShareUrl(String id) => '$siteUrl/l/$id';

  static bool get isConfigured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
