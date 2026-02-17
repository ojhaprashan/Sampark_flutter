import 'dart:convert';
import 'package:http/http.dart' as http;

class QRSignupResponse {
  final String status;
  final String message;
  final QRSignupData data;

  QRSignupResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory QRSignupResponse.fromJson(Map<String, dynamic> json) {
    return QRSignupResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: QRSignupData.fromJson(json['data'] ?? {}),
    );
  }
}

class QRSignupData {
  final int tagId;
  final String tagPublicId;
  final String qrCode;
  final String qrCodeSuffix;
  final String tagType;
  final String statusCode;
  final bool needsSignup;
  final String? redirectUrl;
  final String? carUrl;

  QRSignupData({
    required this.tagId,
    required this.tagPublicId,
    required this.qrCode,
    required this.qrCodeSuffix,
    required this.tagType,
    required this.statusCode,
    required this.needsSignup,
    this.redirectUrl,
    this.carUrl,
  });

  factory QRSignupData.fromJson(Map<String, dynamic> json) {
    return QRSignupData(
      tagId: json['tag_id'] ?? 0,
      tagPublicId: json['tag_public_id'] ?? '',
      qrCode: json['qr_code'] ?? '',
      qrCodeSuffix: json['qr_code_suffix'] ?? '',
      tagType: json['tag_type'] ?? '',
      statusCode: json['status_code']?.toString() ?? '0',
      needsSignup: json['needs_signup'] ?? false,
      redirectUrl: json['redirect_url'],
      carUrl: json['car_url'],
    );
  }
}

class ActivateTagResponse {
  final String status;
  final String message;
  final ActivateTagData data;

  ActivateTagResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ActivateTagResponse.fromJson(Map<String, dynamic> json) {
    return ActivateTagResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: ActivateTagData.fromJson(json['data'] ?? {}),
    );
  }
}

class ActivateTagData {
  final int tagId;
  final bool activated;

  ActivateTagData({
    required this.tagId,
    required this.activated,
  });

  factory ActivateTagData.fromJson(Map<String, dynamic> json) {
    return ActivateTagData(
      tagId: json['tag_id'] ?? 0,
      activated: json['activated'] ?? false,
    );
  }
}

class QRSignupService {
  static const String baseUrl = 'https://app.ngf132.com/app_api';
  static const String endpoint = '/qr_signup_api';
  static const String activateEndpoint = '/activate_tag_api';

  /// Verify QR code by calling the API
  static Future<QRSignupResponse> verifyQRCode({
    required String code,
    String pin = '',
    String phone = '',
    String countryCode = '+91',
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');

      final Map<String, dynamic> body = {
        'sm': '67s87s6yys66',
        '6s888iop': '6s888iop', // App client identifier
        'dg': 'testYU78dII8iiUIPSISJ',
        'code': code, // QR code from scan
      };

      print('🔵 Verify QR Code API Request');
      print('📍 URL: $url');
      print('📦 Body: $body');

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
        print('✅ Verify QR Code API Response: ${response.body}');
        return QRSignupResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
          'API Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to verify QR code: $e');
    }
  }

  /// Activate a tag with owner details
  static Future<ActivateTagResponse> activateTag({
    required String codeS, // tag id from URL
    required String qrcode, // PIN from URL
    required String carno, // vehicle plate number
    required String name, // owner name
    required String phone, // 10-digit mobile
    String codeT = 'c', // vehicle type: c, b, etc
    String codeCo = '91', // country code
  }) async {
    try {
      final url = Uri.parse('$baseUrl$activateEndpoint');

      final Map<String, dynamic> body = {
        'sm': '67s87s6yys66',
        '6s888iop': '6s888iop', // App client identifier
        'dg': 'ABCDYU78dII8iiUIPSISJ',
        'code_s': codeS, // tag id
        'qrcode': qrcode, // PIN
        'carno': carno, // vehicle plate
        'code_t': codeT, // vehicle type
        'name': name, // owner name
        'phone': phone, // 10-digit phone
        'code_co': codeCo, // country code
      };

      print('🟢 Activate Tag API Request');
      print('📍 URL: $url');
      print('📦 Body: $body');

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
        print('✅ Activate Tag API Response: ${response.body}');
        return ActivateTagResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
          'API Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to activate tag: $e');
    }
  }
}
