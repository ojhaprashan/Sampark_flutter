import 'package:http/http.dart' as http;
import 'dart:convert';

class SaveTagLocationResponse {
  final String status;
  final String message;
  final Map<String, dynamic> data;

  SaveTagLocationResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SaveTagLocationResponse.fromJson(Map<String, dynamic> json) {
    return SaveTagLocationResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] ?? {},
    );
  }
}

class SaveTagLocationService {
  static const String baseUrl = 'https://app.ngf132.com/app_api';
  static const String endpoint = '/save_tag_location_api';

  /// Save tag location - Called when user views tag details after scan
  /// 
  /// Params:
  /// - tagId (required): internal tag id (cr_id)
  /// - latitude (required): latitude as string/number
  /// - longitude (required): longitude as string/number
  /// - phoneNumber (optional): phone number sending the coordinates
  static Future<SaveTagLocationResponse> saveTagLocation({
    required int tagId,
    required double latitude,
    required double longitude,
    String? phoneNumber,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');

      final Map<String, dynamic> body = {
        'sm': '67s87s6yys66',
        '6s888iop': '6s888iop', // App client identifier
        'dg': 'testYU78dII8iiUIPSISJ',
        'tag_id': tagId.toString(),
        'lat': latitude.toString(),
        'long': longitude.toString(),
      };

      // Add optional phone number if provided
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        body['phone'] = phoneNumber;
      }

      print('📍 [SaveTagLocationService] Saving tag location');
      print('   ├─ Tag ID: $tagId');
      print('   ├─ Latitude: $latitude');
      print('   ├─ Longitude: $longitude');
      print('   ├─ Phone: ${phoneNumber ?? 'N/A'}');
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

      print('📬 [SaveTagLocationService] Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);
          print('✅ [SaveTagLocationService] Location saved successfully');
          print('   └─ Response: ${jsonResponse.toString()}');
          return SaveTagLocationResponse.fromJson(jsonResponse);
        } catch (e) {
          // If response is not valid JSON, still treat as success
          print('⚠️ [SaveTagLocationService] Response is not JSON, treating as success');
          return SaveTagLocationResponse(
            status: 'success',
            message: 'Location saved',
            data: {},
          );
        }
      } else {
        print('❌ [SaveTagLocationService] API Error: ${response.statusCode}');
        print('   └─ Response: ${response.body}');

        String errorMessage = 'Failed to save location. Please try again.';
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
      print('❌ [SaveTagLocationService] Error: $e');
      rethrow;
    }
  }
}
