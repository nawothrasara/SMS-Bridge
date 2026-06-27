import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _baseUrlKey = "base_url";
  static const String _senderMaskKey = "sender_mask";
  static const String _apiKeyKey = "api_key";

  static const String defaultBaseUrl = "";
  static const String defaultSenderMask = "";
  static const String defaultApiKey = "";

  static Future<void> saveSettings(String url, String mask, String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, url);
    await prefs.setString(_senderMaskKey, mask);
    await prefs.setString(_apiKeyKey, key);
  }

  static Future<Map<String, String>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "baseUrl": prefs.getString(_baseUrlKey) ?? defaultBaseUrl,
      "senderMask": prefs.getString(_senderMaskKey) ?? defaultSenderMask,
      "apiKey": prefs.getString(_apiKeyKey) ?? defaultApiKey,
    };
  }
}
