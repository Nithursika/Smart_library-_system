import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';

class LedService {
  LedService._();
  static final LedService instance = LedService._();

  static const _prefsKey = 'esp32_base_url';
  String? _overrideUrl;

  Future<void> loadSavedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    _overrideUrl = prefs.getString(_prefsKey);
  }

  String get baseUrl {
    final override = _overrideUrl?.trim();
    if (override != null && override.isNotEmpty) return override;
    return AppConfig.esp32BaseUrl;
  }

  bool get isConfigured {
    final url = baseUrl;
    return url.startsWith('http://') && !url.contains('ESP32_IP_HERE');
  }

  Future<void> setBaseUrl(String url) async {
    final cleaned = url.trim().replaceAll(RegExp(r'/+$'), '');
    _overrideUrl = cleaned;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, cleaned);
  }

  Future<String> lightShelf(String shelf) async {
    if (!isConfigured) {
      return 'Set ESP32 IP in Settings';
    }

    final uri = Uri.parse('$baseUrl/light').replace(
      queryParameters: {'shelf': shelf},
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return 'LED on for $shelf (auto-off in 30s)';
      }
      return 'ESP32 error ${response.statusCode}';
    } catch (e) {
      return 'Cannot reach ESP32 ($e). Same Wi‑Fi? Correct IP?';
    }
  }

  Future<String> turnOff() async {
    if (!isConfigured) {
      return 'Set ESP32 IP in Settings';
    }

    final uri = Uri.parse('$baseUrl/off');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return 'LED off';
      }
      return 'ESP32 error ${response.statusCode}';
    } catch (e) {
      return 'Cannot reach ESP32 ($e)';
    }
  }
}
