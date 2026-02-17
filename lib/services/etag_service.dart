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

class ETagService {
  static const String baseUrl = 'https://app.ngf132.com/app_api';
  static const String endpoint = '/getetag_api';

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
}
