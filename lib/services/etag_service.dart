import 'dart:convert';
import 'package:http/http.dart' as http;

class ETagResponse {
  final String status;
  final String message;
  final ETagData data;

  ETagResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ETagResponse.fromJson(Map<String, dynamic> json) {
    return ETagResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: ETagData.fromJson(json['data'] ?? {}),
    );
  }
}

class ETagData {
  final int tagId;
  final String plate;
  final bool hasETag;
  final String downloadUrl;
  final String pdfFile;
  final String etagGeneratedAt;
  final bool canGenerateNow;

  ETagData({
    required this.tagId,
    required this.plate,
    required this.hasETag,
    required this.downloadUrl,
    required this.pdfFile,
    required this.etagGeneratedAt,
    required this.canGenerateNow,
  });

  factory ETagData.fromJson(Map<String, dynamic> json) {
    return ETagData(
      tagId: json['tag_id'] ?? 0,
      plate: json['plate'] ?? '',
      hasETag: json['has_etag'] ?? false,
      downloadUrl: json['download_url'] ?? '',
      pdfFile: json['pdf_file'] ?? '',
      etagGeneratedAt: json['etag_generated_at'] ?? '',
      canGenerateNow: json['can_generate_now'] ?? false,
    );
  }
}

class DemoETagStep1Response {
  final bool status;
  final int code;
  final String message;
  final String? cookie;

  DemoETagStep1Response({
    required this.status,
    required this.code,
    required this.message,
    this.cookie,
  });

  factory DemoETagStep1Response.fromJson(Map<String, dynamic> json, String? cookie) {
    return DemoETagStep1Response(
      status: json['status'] == true || json['status'] == 'success',
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      cookie: cookie,
    );
  }
}

class DemoETagStep2Response {
  final bool status;
  final int code;
  final String message;

  DemoETagStep2Response({
    required this.status,
    required this.code,
    required this.message,
  });

  factory DemoETagStep2Response.fromJson(Map<String, dynamic> json) {
    return DemoETagStep2Response(
      status: json['status'] == true || json['status'] == 'success',
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}

class ETagService {
  static const String baseUrl = 'https://app.ngf132.com/app_api';
  static const String endpoint = '/getetag_api';
  static const String demoEndpoint = '/demo_car_add_api';

  static const Map<String, String> _standardParams = {
    'sm': '67s87s6yys66',
    '6s888iop': '6s888iop',
    'dg': 'ABCDYU78dII8iiUIPSISJ',
  };

  /// Get eTag for a vehicle
  static Future<ETagResponse> getETag({
    required String tagId,
    required String phone,
    required String countryCode,
  }) async {
    print('📥 eTag Request: tagId=$tagId, phone=$phone, countryCode=$countryCode');

    try {
      final url = Uri.parse('$baseUrl$endpoint');

      final Map<String, dynamic> body = {
        'sm': '67s87s6yys66',
        '6s888iop': '6s888iop',
        'dg': 'ABCDYU78dII8iiUIPSISJ',
        'v': tagId,
        'phone': phone,
        'code_co': countryCode.replaceFirst('+', ''),
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

      print('📬 Response: ${response.statusCode} | ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return ETagResponse.fromJson(jsonResponse);
      } else {
        // Extract error message from API response
        String errorMessage = 'Something went wrong. Please try again.';
        try {
          final jsonResponse = jsonDecode(response.body);
          errorMessage = jsonResponse['message'] ?? errorMessage;
        } catch (e) {
          errorMessage = 'API Error: ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } on Exception catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }

  /// Request OTP for Demo ETag
  static Future<DemoETagStep1Response> requestDemoETagOTP({
    required String name,
    required String phone,
    required String plate,
    required String email,
    required String vty,
  }) async {
    print('📥 Demo eTag Step 1 Request: phone=$phone, plate=$plate');

    try {
      final url = Uri.parse('$baseUrl$demoEndpoint');

      final Map<String, String> body = {
        ..._standardParams,
        'step': '1',
        'name': name,
        'phone': phone,
        'plate': plate,
        'email': email,
        'vty': vty,
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

      print('📬 Step 1 Response: ${response.statusCode} | ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse;
        try {
          jsonResponse = jsonDecode(response.body);
        } catch (e) {
          // Handle cases where API returns plain text instead of JSON
          if (response.body.contains('Too many OTP attempts')) {
            throw Exception('Too many OTP attempts. Please try again in an hour.');
          }
          if (response.body.toLowerCase().contains('<!doctype html>')) {
            throw Exception('Server is temporarily unavailable. Please try again later.');
          }
          throw Exception(response.body.length > 60 ? 'Unexpected server response. Please try again.' : response.body);
        }
        
        // Extract cookie if present
        String? cookieInfo = response.headers['set-cookie'];
        
        final status = jsonResponse['status'];
        final isSuccess = status == true || status == 'success' || jsonResponse['code'] == 200;
        
        if (isSuccess) {
          return DemoETagStep1Response.fromJson(jsonResponse, cookieInfo);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to send OTP.');
        }
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } on Exception catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }

  /// Verify OTP for Demo ETag
  static Future<DemoETagStep2Response> verifyDemoETagOTP({
    required String otp,
    String? cookie,
  }) async {
    print('📥 Demo eTag Step 2 Request for OTP');

    try {
      final url = Uri.parse('$baseUrl$demoEndpoint');

      final Map<String, String> body = {
        ..._standardParams,
        'step': '2',
        'otp': otp,
        'k': '0',
      };
      
      final Map<String, String> headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      };
      
      if (cookie != null && cookie.isNotEmpty) {
        headers['Cookie'] = cookie;
      }

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      print('📬 Step 2 Response: ${response.statusCode} | ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse;
        try {
          jsonResponse = jsonDecode(response.body);
        } catch (e) {
          // Handle cases where API returns plain text instead of JSON
          if (response.body.contains('Too many OTP attempts')) {
            throw Exception('Too many OTP attempts. Please try again in an hour.');
          }
           if (response.body.toLowerCase().contains('<!doctype html>')) {
            throw Exception('Server is temporarily unavailable. Please try again later.');
          }
          throw Exception(response.body.length > 60 ? 'Unexpected server response. Please try again.' : response.body);
        }
        
        final status = jsonResponse['status'];
        final isSuccess = status == true || status == 'success' || jsonResponse['code'] == 200;
        
        if (isSuccess) {
          return DemoETagStep2Response.fromJson(jsonResponse);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to verify OTP.');
        }
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } on Exception catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }
}
