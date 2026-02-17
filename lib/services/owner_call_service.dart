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
        'plate': tagId?.toString() ?? '', // Last 4 digits for verification
        'plateno': plateNumber, // Full plate number
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

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('✅ [OwnerCallService] Call request successful');
        print('   └─ Response: ${jsonResponse.toString()}');
        return OwnerCallResponse.fromJson(jsonResponse);
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

  factory OwnerCallResponse.fromJson(Map<String, dynamic> json) {
    return OwnerCallResponse(
      success: json['success'] == true || json['status'] == 'success',
      message: json['message'] ?? json['msg'],
      maskedNumber: json['masked_number'] ?? json['maskedNumber'],
      data: json['data'],
    );
  }

  @override
  String toString() => 'OwnerCallResponse(success: $success, message: $message)';
}
