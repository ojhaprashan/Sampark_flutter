import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'premium_service.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyName = 'userName';
  static const String _keyPhone = 'userPhone';
  static const String _keyCountryCode = 'countryCode';
  static const String _keyVehicles = 'userVehicles';
  static const String _keyEmail = 'userEmail';
  static const String _keyCity = 'userCity';
  static const String _keyVerified = 'userVerified';

  // ✅ Notifier for user data changes
  static final ValueNotifier<int> userDataNotifier = ValueNotifier<int>(0);

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Signup user
  static Future<void> signup({
    required String name,
    required String phone,
    required String countryCode,
    List<Map<String, String>>? vehicles,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    // Ensure phone is clean (no whitespace, no country code prefix)
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '').trim();
    final cleanCountryCode = countryCode.trim();

    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyName, name.trim());
    await prefs.setString(_keyPhone, cleanPhone);
    await prefs.setString(_keyCountryCode, cleanCountryCode);

    // Store vehicles if provided
    if (vehicles != null && vehicles.isNotEmpty) {
      await prefs.setString(_keyVehicles, jsonEncode(vehicles));
    }

    // ✅ Fetch premium data after signup (with country code + phone)
    final fullPhone = cleanCountryCode.replaceFirst('+', '') + cleanPhone;
    await PremiumService.fetchPremiumData(phone: fullPhone);

    // ✅ Notify listeners that user data changed
    userDataNotifier.value++;
  }

  // Login user from OTP/PIN verification (with complete user data from API)
  static Future<void> loginFromAPI({
    required String phone,
    required String countryCode,
    String? name,
    String? email,
    String? city,
    bool verified = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    // Ensure phone is clean (no whitespace, no country code prefix)
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '').trim();
    final cleanCountryCode = countryCode.replaceAll(RegExp(r'\s+'), '').trim();
    final cleanName = name?.trim() ?? 'Sampark User';
    final cleanEmail = email?.trim() ?? '';
    final cleanCity = city?.trim() ?? '';

    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyName, cleanName);
    await prefs.setString(_keyPhone, cleanPhone);
    await prefs.setString(_keyCountryCode, cleanCountryCode);
    await prefs.setString(_keyEmail, cleanEmail);
    await prefs.setString(_keyCity, cleanCity);
    await prefs.setBool(_keyVerified, verified);

    print('💾 [AuthService] User data saved from API');
    print('   ├─ Name: $cleanName');
    print('   ├─ Email: $cleanEmail');
    print('   ├─ City: $cleanCity');
    print('   ├─ Verified: $verified');
    print('   └─ Phone: +$cleanCountryCode $cleanPhone');

    // ✅ Fetch premium data after login
    final fullPhone = cleanCountryCode + cleanPhone;
    await PremiumService.fetchPremiumData(phone: fullPhone);

    // ✅ Notify listeners that user data changed
    userDataNotifier.value++;
  }

  // Login user
  static Future<void> login({
    required String name,
    required String phone,
    required String countryCode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    // Ensure phone is clean (no whitespace, no country code prefix)
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '').trim();
    final cleanCountryCode = countryCode.trim();

    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyName, name.trim());
    await prefs.setString(_keyPhone, cleanPhone);
    await prefs.setString(_keyCountryCode, cleanCountryCode);

    // ✅ Fetch premium data after login (with country code + phone)
    final fullPhone = cleanCountryCode.replaceFirst('+', '') + cleanPhone;
    await PremiumService.fetchPremiumData(phone: fullPhone);

    // ✅ Notify listeners that user data changed
    userDataNotifier.value++;
  }

  // Add vehicle
  static Future<void> addVehicle({
    required String type,
    required String number,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    // Clean vehicle data
    final cleanType = type.trim();
    final cleanNumber = number.replaceAll(RegExp(r'\s+'), '').trim().toUpperCase();

    // Get existing vehicles
    final vehiclesJson = prefs.getString(_keyVehicles);
    final vehicles = vehiclesJson != null
        ? List<Map<String, dynamic>>.from(jsonDecode(vehiclesJson))
        : <Map<String, dynamic>>[];

    // Add new vehicle with cleaned data
    vehicles.add({
      'type': cleanType,
      'number': cleanNumber,
    });

    // Save updated vehicles
    await prefs.setString(_keyVehicles, jsonEncode(vehicles));

    // ✅ Notify listeners that user data changed
    userDataNotifier.value++;
  }

  // Get vehicles
  static Future<List<Map<String, dynamic>>> getVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    final vehiclesJson = prefs.getString(_keyVehicles);
    if (vehiclesJson == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(vehiclesJson));
  }

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Clear all user data
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyName);
    await prefs.remove(_keyPhone);
    await prefs.remove(_keyCountryCode);
    await prefs.remove(_keyVehicles);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyCity);
    await prefs.remove(_keyVerified);
    
    // ✅ Clear premium data as well
    await PremiumService.clearPremiumData();
    
    // ✅ Delete FCM token
    // Uncomment when firebase_notification_service is imported
    // await FirebaseNotificationService.deleteToken();

    // ✅ Notify listeners that user data changed
    userDataNotifier.value++;
  }

  // Get user data
  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final vehicles = await getVehicles();

    return {
      'name': prefs.getString(_keyName) ?? '',
      'phone': prefs.getString(_keyPhone) ?? '',
      'countryCode': prefs.getString(_keyCountryCode) ?? '91',
      'email': prefs.getString(_keyEmail) ?? '',
      'city': prefs.getString(_keyCity) ?? '',
      'verified': prefs.getBool(_keyVerified) ?? false,
      'vehicles': vehicles,
    };
  }
}
