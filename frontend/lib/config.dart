/// Project: https://supabase.com/dashboard/project/tjmhpizqqdemthkcfwls
/// Use publishable key only (never the secret key in the app).
class AppConfig {
  static const supabaseUrl = 'https://tjmhpizqqdemthkcfwls.supabase.co';
  static const supabaseAnonKey =
      'sb_publishable_d1QEIdcyFbYC7omYa2oNHA_2cEtdJp_';

  /// ESP32 local IP from Serial Monitor (same Wi‑Fi as phone/PC).
  static const esp32BaseUrl = 'http://192.168.1.154';

  static bool get isConfigured =>
      supabaseUrl.startsWith('https://') &&
      !supabaseAnonKey.startsWith('YOUR_');

  static bool get hasEsp32 =>
      esp32BaseUrl.startsWith('http://') &&
      !esp32BaseUrl.contains('ESP32_IP_HERE');
}
