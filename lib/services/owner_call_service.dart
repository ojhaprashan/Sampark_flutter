import 'package:http/http.dart' as http;
import 'dart:convert';

class OwnerCallService {
  static const String baseUrl = 'https://app.ngf132.com/app_api';
  static const String endpoint = '/owner_call_api';

  /// Make a call to the vehicle owner with location and phone verification
  static Future<OwnerCallResponse> makeOwnerCall({
    required String plateNumber,
    required String last4Digits,
    required String userPhoneNumber,
    required double latitude,
    required double longitude,
    int? tagId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');

      final Map<String, dynamic> body = {
        'sm': '67s87s6yys66',
        '6s888iop': '6s888iop', // App client identifier
        'dg': 'testYU78dII8iiUIPSISJ',
        'plate': tagId?.toString() ?? '', // Tag ID for identification
        'plateno': last4Digits, // Full plate number
        'last4': last4Digits, // Last 4 digits for verification
        'phoneu': userPhoneNumber, // User's phone number
        'lat': latitude.toString(),
        'long': longitude.toString(),
      };

      print('📞 [OwnerCallService] Making owner call request');
      print('   ├─ Plate: $plateNumber');
      print('   ├─ Tag ID: ${tagId?.toString() ?? ''}');
      print('   ├─ Last 4 Digits: $last4Digits');
      print('   ├─ User Phone: $userPhoneNumber');
      print('   ├─ Location: $latitude, $longitude');
      print('   └─ Endpoint: $baseUrl$endpoint');

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
      print("response ${response.body}");
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('✅ [OwnerCallService] Call request successful');
        print('   └─ Response: ${jsonResponse.toString()}');
        
        // Generate masked number for display (can be customized based on actual response)
        final maskedNumber = _generateMaskedNumber();
        
        return OwnerCallResponse.fromJson(jsonResponse, maskedNumber);
      } else {
        print('❌ [OwnerCallService] API Error: ${response.statusCode}');
        
        // Try to extract error message from JSON response
        String errorMessage = 'Something went wrong. Please try again.';
        try {
          final errorJson = jsonDecode(response.body);
          if (errorJson['message'] != null) {
            errorMessage = errorJson['message'];
          } else if (errorJson['msg'] != null) {
            errorMessage = errorJson['msg'];
          }
        } catch (_) {
          // If JSON parsing fails, use the raw body
          errorMessage = response.body;
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ [OwnerCallService] Exception: $e');
      rethrow;
    }
  }

  /// Generate masked phone number for display
  /// This can be customized or replaced with API response value
  static String _generateMaskedNumber() {
   
    return '080 7117 5127';
  }

  /// Make an international call for MT (Lost & Found) tags using owner_call_inter_api
  /// Params: plate (required – tag id), phoneu (required – local part), code_co (required – country code), lat, long
  static Future<OwnerCallResponse> makeInterNationalCall({
    required int tagId,
    required String phoneLocal, // Local part without country code (e.g., 9876543210)
    required String countryCode, // Country code (e.g., 91 for India, 1 for USA, 44 for UK)
    required double latitude,
    required double longitude,
  }) async {
    try {
      const String internationalEndpoint = '/owner_call_inter_api';
      final url = Uri.parse('$baseUrl$internationalEndpoint');
      print("url $url");

      final Map<String, dynamic> body = {
        'sm': '67s87s6yys66',
        '6s888iop': '6s888iop', // App client identifier
        'dg': 'testYU78dII8iiUIPSISJ',
        'plate': tagId.toString(), // Tag ID
        'phoneu': phoneLocal, // Local part of phone number
        'code_co': countryCode, // Country code
        'lat': latitude.toString(),
        'long': longitude.toString(),
      };

      print('📞 [OwnerCallService] Making international call request (MT tag)');
      print('   ├─ Tag ID: $tagId');
      print('   ├─ Phone (local): $phoneLocal');
      print('   ├─ Country Code: $countryCode');
      print('   ├─ Location: $latitude, $longitude');
      print('   └─ Endpoint: $baseUrl$internationalEndpoint');

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
        print('✅ [OwnerCallService] International call request successful');
        print('   └─ Response: ${jsonResponse.toString()}');
        
        final maskedNumber = _generateMaskedNumber();
        
        return OwnerCallResponse.fromJson(jsonResponse, maskedNumber);
      } else {
        print('❌ [OwnerCallService] API Error: ${response.statusCode}');
        
        String errorMessage = 'Something went wrong. Please try again.';
        try {
          final errorJson = jsonDecode(response.body);
          if (errorJson['message'] != null) {
            errorMessage = errorJson['message'];
          } else if (errorJson['msg'] != null) {
            errorMessage = errorJson['msg'];
          }
        } catch (_) {
          errorMessage = response.body;
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ [OwnerCallService] Exception: $e');
      rethrow;
    }
  }
}

/// Response model for owner call API
class OwnerCallResponse {
  final bool success;
  final String? message;
  final String? maskedNumber;
  final Map<String, dynamic>? data;

  OwnerCallResponse({
    required this.success,
    this.message,
    this.maskedNumber,
    this.data,
  });

  factory OwnerCallResponse.fromJson(Map<String, dynamic> json, [String? defaultMaskedNumber]) {
    return OwnerCallResponse(
      success: json['success'] == true || json['status'] == 'success',
      message: json['message'] ?? json['msg'],
      maskedNumber: json['masked_number'] ?? json['maskedNumber'] ?? defaultMaskedNumber,
      data: json['data'],
    );
  }

  @override
  String toString() => 'OwnerCallResponse(success: $success, message: $message, maskedNumber: $maskedNumber)';
}
