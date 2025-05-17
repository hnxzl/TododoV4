import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _usernameKey = 'tododo_username';
  static const String _themeKey = 'tododo_theme';
  static const String _notifKey = 'tododo_notification';

  // Username
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  static Future<void> setUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  // Theme mode: true = dark, false = light
  static Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  static Future<void> setThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  // Notification enabled
  static Future<bool> isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notifKey) ?? true;
  }

  static Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifKey, enabled);
  }
}
