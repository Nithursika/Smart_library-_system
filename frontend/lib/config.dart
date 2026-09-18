/// Project: https://supabase.com/dashboard/project/tjmhpizqqdemthkcfwls
/// Use publishable key only (never the secret key in the app).
class AppConfig {
  static const supabaseUrl = 'https://tjmhpizqqdemthkcfwls.supabase.co';
  static const supabaseAnonKey =
      'sb_publishable_d1QEIdcyFbYC7omYa2oNHA_2cEtdJp_';

  static bool get isConfigured =>
      supabaseUrl.startsWith('https://') &&
      !supabaseAnonKey.startsWith('YOUR_');
}
