import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyName = 'userName';
  static const String _keyPhone = 'userPhone';
  static const String _keyCountryCode = 'countryCode';

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Login user
  static Future<void> login({
    required String name,
    required String phone,
    required String countryCode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyPhone, phone);
    await prefs.setString(_keyCountryCode, countryCode);
  }

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Get user data
  static Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyName) ?? '',
      'phone': prefs.getString(_keyPhone) ?? '',
      'countryCode': prefs.getString(_keyCountryCode) ?? '+91',
    };
  }
}
