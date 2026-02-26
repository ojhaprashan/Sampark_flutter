import 'dart:convert';
import 'package:http/http.dart' as http;

class EmergencyContact {
  final int tagId;
  final bool hasEmergency;
  final String? primaryPhone;
  final String? secondaryPhone;
  final String? bloodGroup;
  final String? insurance;
  final String? note;

  EmergencyContact({
    required this.tagId,
    required this.hasEmergency,
    this.primaryPhone,
    this.secondaryPhone,
    this.bloodGroup,
    this.insurance,
    this.note,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      tagId: json['tag_id'] ?? 0,
      hasEmergency: json['has_emergency'] == true || json['has_emergency'] == 1,
      primaryPhone: json['ephone']?.toString(),
      secondaryPhone: json['ephone2']?.toString(),
      bloodGroup: json['blood_group']?.toString(),
      insurance: json['insurance']?.toString(),
      note: json['note']?.toString(),
    );
  }
}

class EmergencyResponse {
  final String status;
  final String message;
  final EmergencyContact data;

  EmergencyResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory EmergencyResponse.fromJson(Map<String, dynamic> json) {
    return EmergencyResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: EmergencyContact.fromJson(json['data'] ?? {}),
    );
  }
}

class EmergencyService {
  static const String baseUrl = 'https://app.ngf132.com/app_api';
  static const String endpoint = '/emergency_api';
  static const String updateEndpoint = '/update_emergency_api';  // ✅ Add update endpoint

  /// Fetch emergency contact information for a tag
  static Future<EmergencyResponse> fetchEmergencyInfo({
    required int tagId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');

      final Map<String, String> body = {
        'sm': '67s87s6yys66',
        '6s888iop': '6s888iop',
        'dg': 'ABCDYU78dII8iiUIPSISJ',
        'qrid': tagId.toString(),
      };

      print('\n🚨 Emergency API Request');
      print('📍 URL: $url');
      print('🆔 Tag ID: $tagId');
      print('📦 Body: $body\n');

      final response = await http.get(
        url.replace(queryParameters: body),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('✅ Emergency API Response: ${response.body}\n');
        return EmergencyResponse.fromJson(jsonResponse);
      } else {
        // Extract clean error message from response
        try {
          final jsonResponse = jsonDecode(response.body);
          final errorMessage = jsonResponse['message'] ?? 'Failed to fetch emergency info';
          throw Exception(errorMessage);
        } catch (e) {
          throw Exception('Failed to fetch emergency information');
        }
      }
    } catch (e) {
      print('❌ Emergency API Error: $e\n');
      throw Exception('Failed to fetch emergency information: $e');
    }
  }

  /// ✅ Update emergency contact information for a tag
  static Future<Map<String, dynamic>> updateEmergencyInfo({
    required int tagId,
    required String phone,
    required int status,  // 1 for enable, 0 for disable
    required String? phone1,  // Primary emergency phone
    required String? phone2,  // Secondary emergency phone
    required String? bloodGroup,
    required String? insurance,
    required String? note,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$updateEndpoint');

      final Map<String, String> body = {
        'sm': '67s87s6yys66',
        '6s888iop': '6s888iop',
        'dg': 'ABCDYU78dII8iiUIPSISJ',
        'tag_id': tagId.toString(),
        'ph': phone,
        'status': status.toString(),
      };

      // ✅ Add optional fields if provided
      if (phone1 != null && phone1.isNotEmpty) {
        body['phone1'] = phone1;
      }
      if (phone2 != null && phone2.isNotEmpty) {
        body['phone2'] = phone2;
      }
      if (bloodGroup != null && bloodGroup.isNotEmpty) {
        body['blood'] = bloodGroup;
      }
      if (insurance != null && insurance.isNotEmpty) {
        body['insurance'] = insurance;
      }
      if (note != null && note.isNotEmpty) {
        body['note'] = note;
      }

      print('\n🚨 Update Emergency API Request');
      print('📍 URL: $url');
      print('🆔 Tag ID: $tagId');
      print('📦 Body: $body\n');

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
        print('✅ Update Emergency API Response: ${response.body}\n');
        return jsonResponse;
      } else {
        // Extract clean error message from response
        try {
          final jsonResponse = jsonDecode(response.body);
          final errorMessage = jsonResponse['message'] ?? 'Failed to update emergency info';
          throw Exception(errorMessage);
        } catch (e) {
          throw Exception('Failed to update emergency information');
        }
      }
    } catch (e) {
      print('❌ Update Emergency API Error: $e\n');
      throw Exception('Failed to update emergency information: $e');
    }
  }
}
