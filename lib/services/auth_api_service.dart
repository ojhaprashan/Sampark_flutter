import 'package:http/http.dart' as http;
import 'dart:convert';

class OTPResponse {
  final String status;
  final String message;
  final bool requirePin;
  final bool sent;

  OTPResponse({
    required this.status,
    required this.message,
    required this.requirePin,
    required this.sent,
  });

  factory OTPResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return OTPResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      requirePin: data['require_pin'] ?? false,
      sent: data['sent'] ?? false,
    );
  }
}

class VerifyOTPResponse {
  final String status;
  final String message;
  final bool success;
  final String? token;
  // User data from response
  final bool? verified;
  final String? userEmail;
  final String? userPhone;
  final String? userName;
  final String? userCity;

  VerifyOTPResponse({
    required this.status,
    required this.message,
    required this.success,
    this.token,
    this.verified,
    this.userEmail,
    this.userPhone,
    this.userName,
    this.userCity,
  });

  factory VerifyOTPResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    
    return VerifyOTPResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      success: json['status']?.toString().toLowerCase() == 'success',
      token: json['token']?.toString(),
      verified: data['verified'] ?? false,
      userEmail: data['email']?.toString(),
      userPhone: data['phone']?.toString(),
      userName: data['name']?.toString(),
      userCity: data['city']?.toString(),
    );
  }
}

class CheckPhoneResponse {
  final String status;
  final String message;
  final bool verified;
  final String name;
  final String? email;
  final String phone;
  final String city;
  final bool isNewUser; // true if new_user: 1

  CheckPhoneResponse({
    required this.status,
    required this.message,
    required this.verified,
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.isNewUser,
  });

  factory CheckPhoneResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    
    return CheckPhoneResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      verified: data['verified'] ?? false,
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString(),
      phone: data['phone']?.toString() ?? '',
      city: data['city']?.toString() ?? '',
      isNewUser: (data['new_user'] ?? 0) == 1,
    );
  }
}

class UpdateFCMTokenResponse {
  final String status;
  final String message;
  final bool success;

  UpdateFCMTokenResponse({
    required this.status,
    required this.message,
    required this.success,
  });

  factory UpdateFCMTokenResponse.fromJson(Map<String, dynamic> json) {
    return UpdateFCMTokenResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      success: json['status']?.toString().toLowerCase() == 'success',
    );
  }
}

class AuthAPIService {
  static const String baseUrl = 'https://app.ngf132.com/app_api';
  static const String requestOTPEndpoint = '/request_otp_api';
  static const String verifyOTPEndpoint = '/verify_otp_api';
  static const String checkPhoneEndpoint = '/check_phone_api';
  static const String updateFCMTokenEndpoint = '/update_fcm_token_api';

  // Standard params for all requests
  static const Map<String, String> _standardParams = {
    'sm': '67s87s6yys66',
    '6s888iop': '6s888iop',
    'dg': 'ABCDYU78dII8iiUIPSISJ',
  };

  /// Request OTP - Send phone number to get OTP or get PIN prompt
  /// Returns OTPResponse with requirePin flag and sent flag
  /// 
  /// If requirePin = true: User has PIN set, ask for PIN instead of OTP
  /// If sent = true: OTP was sent successfully
  static Future<OTPResponse> requestOTP({
    required String phone, // Full phone number e.g. 919876543210
  }) async {
    try {
      final url = Uri.parse('$baseUrl$requestOTPEndpoint');

      final Map<String, String> body = {
        ..._standardParams,
        'phone': phone.trim(),
      };

      print('📞 [AuthAPI] Requesting OTP');
      print('   ├─ Phone: $phone');
      print('   ├─ Endpoint: $baseUrl$requestOTPEndpoint');
      print('   └─ Sending request...');

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

      print('📬 [AuthAPI] Response received: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final otpResponse = OTPResponse.fromJson(jsonResponse);

        print('✅ [AuthAPI] OTP Request Success');
        print('   ├─ Status: ${otpResponse.status}');
        print('   ├─ Message: ${otpResponse.message}');
        print('   ├─ Require PIN: ${otpResponse.requirePin}');
        print('   └─ Sent: ${otpResponse.sent}');

        return otpResponse;
      } else {
        print('❌ [AuthAPI] Error: ${response.statusCode}');
        print('   └─ Body: ${response.body}');
        throw Exception('Failed to request OTP: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [AuthAPI] Error requesting OTP: $e');
      throw Exception('Error requesting OTP: $e');
    }
  }

  /// Verify OTP/PIN - Submit OTP or PIN along with phone
  /// 
  /// Parameters:
  /// - phone: Full phone number e.g. 919876543210
  /// - otp: 4-digit OTP (use if PIN was not required)
  /// - pin: 4-digit PIN (use if require_pin was true)
  /// - fcmToken: Optional FCM token for push notifications
  static Future<VerifyOTPResponse> verifyOTP({
    required String phone,
    String? otp,
    String? pin,
    String? fcmToken,
  }) async {
    try {
      // Must provide either OTP or PIN
      if (((otp == null || otp.isEmpty) && (pin == null || pin.isEmpty))) {
        throw Exception('Either OTP or PIN must be provided');
      }

      // OTP and PIN must be 4 digits
      if (otp != null && otp.length != 4) {
        throw Exception('OTP must be 4 digits');
      }
      if (pin != null && pin.length != 4) {
        throw Exception('PIN must be 4 digits');
      }

      final url = Uri.parse('$baseUrl$verifyOTPEndpoint');

      final Map<String, String> body = {
        ..._standardParams,
        'phone': phone.trim(),
      };

      // Add OTP or PIN
      if (otp != null && otp.isNotEmpty) {
        body['otp'] = otp;
      }
      if (pin != null && pin.isNotEmpty) {
        body['pin'] = pin;
      }

      // Add FCM token if provided
      if (fcmToken != null && fcmToken.isNotEmpty) {
        body['token'] = fcmToken;
      }

      print('🔐 [AuthAPI] Verifying OTP/PIN');
      print('   ├─ Phone: $phone');
      print('   ├─ OTP: ${otp != null ? '****' : 'N/A'}');
      print('   ├─ PIN: ${pin != null ? '****' : 'N/A'}');
      print('   ├─ FCM Token: $fcmToken');
      print('   ├─ Endpoint: $baseUrl$verifyOTPEndpoint');
      print('   └─ Sending request...');

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

      print('📬 [AuthAPI] Response received: ${response.statusCode}');

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final verifyResponse = VerifyOTPResponse.fromJson(jsonResponse);

      if (response.statusCode == 200) {
        print('✅ [AuthAPI] Verification Complete');
        print('   ├─ Status: ${verifyResponse.status}');
        print('   ├─ Message: ${verifyResponse.message}');
        print('   ├─ Success: ${verifyResponse.success}');
        print('   └─ Token: ${verifyResponse.token != null ? 'Received' : 'N/A'}');

        return verifyResponse;
      } else {
        print('❌ [AuthAPI] Error: ${response.statusCode}');
        print('   ├─ Status: ${verifyResponse.status}');
        print('   └─ Message: ${verifyResponse.message}');
        // Throw the actual API message, not generic error
        throw Exception(verifyResponse.message);
      }
    } catch (e) {
      print('❌ [AuthAPI] Error verifying OTP: $e');
      throw Exception('Error verifying OTP: $e');
    }
  }

  /// Check phone number - Creates account if new user, retrieves data if existing user
  /// 
  /// This API:
  /// - Creates a new account if the phone number is new (returns new_user: 1)
  /// - Returns existing user data if the phone already exists
  /// - Both return the same structure with user info
  /// 
  /// Parameters:
  /// - phone: Full phone number e.g. 919876543210
  static Future<CheckPhoneResponse> checkPhone({
    required String phone,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$checkPhoneEndpoint');

      final Map<String, String> body = {
        ..._standardParams,
        'phone': phone.trim(),
      };

      print('📱 [AuthAPI] Checking phone number');
      print('   ├─ Phone: $phone');
      print('   ├─ Endpoint: $baseUrl$checkPhoneEndpoint');
      print('   └─ Sending request...');

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

      print('📬 [AuthAPI] Response received: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final checkPhoneResponse = CheckPhoneResponse.fromJson(jsonResponse);

        print('✅ [AuthAPI] Check Phone Success');
        print('   ├─ Status: ${checkPhoneResponse.status}');
        print('   ├─ Message: ${checkPhoneResponse.message}');
        print('   ├─ Is New User: ${checkPhoneResponse.isNewUser}');
        print('   ├─ Name: ${checkPhoneResponse.name}');
        print('   ├─ Email: ${checkPhoneResponse.email}');
        print('   ├─ City: ${checkPhoneResponse.city}');
        print('   └─ Phone: ${checkPhoneResponse.phone}');

        return checkPhoneResponse;
      } else {
        print('❌ [AuthAPI] Error: ${response.statusCode}');
        print('   └─ Body: ${response.body}');
        throw Exception('Failed to check phone: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [AuthAPI] Error checking phone: $e');
      throw Exception('Error checking phone: $e');
    }
  }

  /// Update FCM Token - Send FCM token for push notifications
  /// 
  /// Parameters:
  /// - phone: Full phone number e.g. 919876543210
  /// - fcmToken: Firebase Cloud Messaging token
  /// - platform: Device platform (android/ios)
  static Future<UpdateFCMTokenResponse> updateFCMToken({
    required String phone,
    required String fcmToken,
    String platform = 'android',
  }) async {
    try {
      final url = Uri.parse('$baseUrl$updateFCMTokenEndpoint');

      final Map<String, String> body = {
        ..._standardParams,
        'phone': phone.trim(),
        'token': fcmToken.trim(),
        'platform': platform,
      };

      print('📱 [AuthAPI] Updating FCM Token');
      print('   ├─ Phone: $phone');
      print('   ├─ Platform: $platform');
      print('   ├─ Token: ${fcmToken.substring(0, 20)}...');
      print('   ├─ Endpoint: $baseUrl$updateFCMTokenEndpoint');
      print('   └─ Sending request...');

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

      print('📬 [AuthAPI] Response received: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final updateResponse = UpdateFCMTokenResponse.fromJson(jsonResponse);

        print('✅ [AuthAPI] FCM Token Updated');
        print('   ├─ Status: ${updateResponse.status}');
        print('   ├─ Message: ${updateResponse.message}');
        print('   └─ Success: ${updateResponse.success}');

        return updateResponse;
      } else {
        print('❌ [AuthAPI] Error: ${response.statusCode}');
        print('   └─ Body: ${response.body}');
        throw Exception('Failed to update FCM token: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [AuthAPI] Error updating FCM token: $e');
      throw Exception('Error updating FCM token: $e');
    }
  }

  /// Validate full phone number format
  /// Must be 10-15 digits and only numbers
  static bool validatePhoneNumber(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.length < 10 || cleanPhone.length > 15) {
      return false;
    }
    return true;
  }

  /// Format phone number to include country code if missing
  /// e.g. "9876543210" with countryCode "91" -> "919876543210"
  static String formatPhoneNumber(String phone, String countryCode) {
    String cleanPhone = phone.replaceAll(RegExp(r'\s+'), '').trim();

    // Remove + if present
    if (cleanPhone.startsWith('+')) {
      cleanPhone = cleanPhone.substring(1);
    }

    String cleanCountryCode = countryCode.replaceAll(RegExp(r'\s+'), '').trim();
    if (cleanCountryCode.startsWith('+')) {
      cleanCountryCode = cleanCountryCode.substring(1);
    }

    // Remove country code prefix if already present
    if (cleanPhone.startsWith(cleanCountryCode)) {
      cleanPhone = cleanPhone.substring(cleanCountryCode.length);
    }

    // Combine country code + phone
    return cleanCountryCode + cleanPhone;
  }
}
