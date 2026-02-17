import 'dart:convert';
import 'package:http/http.dart' as http;

class OfflineQRResponse {
  final String status;
  final String message;
  final OfflineQRData data;

  OfflineQRResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory OfflineQRResponse.fromJson(Map<String, dynamic> json) {
    return OfflineQRResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: OfflineQRData.fromJson(json['data'] ?? {}),
    );
  }
}

class OfflineQRData {
  final int tagId;
  final String plate;
  final String downloadUrl;
  final String pdfFile;

  OfflineQRData({
    required this.tagId,
    required this.plate,
    required this.downloadUrl,
    required this.pdfFile,
  });

  factory OfflineQRData.fromJson(Map<String, dynamic> json) {
    return OfflineQRData(
      tagId: json['tag_id'] ?? 0,
      plate: json['plate'] ?? '',
      downloadUrl: json['download_url'] ?? '',
      pdfFile: json['pdf_file'] ?? '',
    );
  }
}

class OfflineQRService {
  static const String baseUrl = 'https://app.ngf132.com/app_api';
  static const String endpoint = '/offline_qr_api';

  /// Generate offline QR code
  static Future<OfflineQRResponse> generateOfflineQR({
    required String tagId,
    required String phone,
    required String countryCode,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');

      // Remove '+' from country code if present
      final cleanCountryCode = countryCode.replaceFirst('+', '');

      final Map<String, dynamic> body = {
        'sm': '67s87s6yys66',
        '6s888iop': '6s888iop', // App client identifier
        'dg': 'ABCDYU78dII8iiUIPSISJ',
        'tgid': tagId, // Tag ID
        'phone': phone, // Phone number
        'code_co': cleanCountryCode, // Country code
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
        return OfflineQRResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
          'API Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to generate offline QR: $e');
    }
  }
}
