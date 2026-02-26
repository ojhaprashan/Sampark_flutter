import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PremiumData {
  final bool hasPremium;
  final String premiumExpiresAt;
  final String premiumDaysLeft;
  final bool isTrial;

  PremiumData({
    required this.hasPremium,
    required this.premiumExpiresAt,
    required this.premiumDaysLeft,
    required this.isTrial,
  });

  factory PremiumData.fromJson(Map<String, dynamic> json) {
    return PremiumData(
      hasPremium: json['has_premium'] ?? false,
      premiumExpiresAt: json['premium_expires_at'] ?? '',
      premiumDaysLeft: json['premium_days_left'] ?? '',
      isTrial: json['is_trial'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'has_premium': hasPremium,
      'premium_expires_at': premiumExpiresAt,
      'premium_days_left': premiumDaysLeft,
      'is_trial': isTrial,
    };
  }
}

class PremiumResponse {
  final String status;
  final String message;
  final PremiumData? data;

  PremiumResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory PremiumResponse.fromJson(Map<String, dynamic> json) {
    return PremiumResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] != null ? PremiumData.fromJson(json['data']) : null,
    );
  }
}

class PremiumService {
  static const String baseUrl = 'https://app.ngf132.com/app_api';
  static const String endpoint = '/get_premium_api';
  static const String _keyPremiumData = 'premiumData';
  static const String _keyPremiumFetchedPhone = 'premiumFetchedPhone';

  /// Fetch premium data for user (only once per phone number)
  static Future<PremiumData?> fetchPremiumData({
    required String phone,
  }) async {
    try {
      // Check if we've already fetched premium data for this phone
      final prefs = await SharedPreferences.getInstance();
      final lastFetchedPhone = prefs.getString(_keyPremiumFetchedPhone);
      
      // If we already fetched for this phone, return cached data
      if (lastFetchedPhone == phone) {
        final cachedJson = prefs.getString(_keyPremiumData);
        if (cachedJson != null) {
          print('📦 [PremiumService] Using cached premium data for phone: $phone');
          final premiumData = PremiumData.fromJson(jsonDecode(cachedJson));
          return premiumData;
        }
      }

      print('🌐 [PremiumService] Fetching premium data for phone: $phone');
      
      final url = Uri.parse('$baseUrl$endpoint');

      final Map<String, dynamic> body = {
        'sm': '67s87s6yys66',
        '6s888iop': '6s888iop',
        'dg': 'ABCDYU78dII8iiUIPSISJ',
        'ph': phone,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final premiumResponse = PremiumResponse.fromJson(jsonResponse);
        
        if (premiumResponse.data != null) {
          print('✅ [PremiumService] Premium data fetched successfully');
          print('   ├─ Has Premium: ${premiumResponse.data!.hasPremium}');
          print('   ├─ Days Left: ${premiumResponse.data!.premiumDaysLeft}');
          print('   ├─ Is Trial: ${premiumResponse.data!.isTrial}');
          print('   └─ Expires At: ${premiumResponse.data!.premiumExpiresAt}');
          
          // Store premium data locally
          await prefs.setString(
            _keyPremiumData,
            jsonEncode(premiumResponse.data!.toJson()),
          );
          
          // Store phone to know which phone this data is for
          await prefs.setString(_keyPremiumFetchedPhone, phone);
          
          return premiumResponse.data;
        }
      } else {
        throw Exception(
          'API Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ [PremiumService] Error: $e');
      // Try to return cached data even if API fails
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedJson = prefs.getString(_keyPremiumData);
        if (cachedJson != null) {
          return PremiumData.fromJson(jsonDecode(cachedJson));
        }
      } catch (_) {}
      return null;
    }
  }

  /// Get cached premium data without API call
  static Future<PremiumData?> getCachedPremiumData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_keyPremiumData);
      if (cachedJson != null) {
        return PremiumData.fromJson(jsonDecode(cachedJson));
      }
    } catch (e) {
      print('❌ [PremiumService] Error reading cache: $e');
    }
    return null;
  }

  /// Clear premium data (useful on logout)
  static Future<void> clearPremiumData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyPremiumData);
      await prefs.remove(_keyPremiumFetchedPhone);
      print('✅ [PremiumService] Premium data cleared');
    } catch (e) {
      print('❌ [PremiumService] Error clearing data: $e');
    }
  }
}
