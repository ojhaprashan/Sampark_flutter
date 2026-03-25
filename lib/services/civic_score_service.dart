import 'dart:convert';
import 'package:http/http.dart' as http;

class CivicScoreResponse {
  final String status;
  final String message;
  final CivicScoreData? data;

  CivicScoreResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory CivicScoreResponse.fromJson(Map<String, dynamic> json) {
    return CivicScoreResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: json['data'] != null ? CivicScoreData.fromJson(json['data']) : null,
    );
  }
}

class CivicScoreData {
  final String plateDisplay;
  final String plateClean;
  final double avgRating;
  final int totalRatings;
  final String message;
  final bool hasRatings;
  final int starsFull;

  CivicScoreData({
    required this.plateDisplay,
    required this.plateClean,
    required this.avgRating,
    required this.totalRatings,
    required this.message,
    this.hasRatings = false,
    this.starsFull = 0,
  });

  factory CivicScoreData.fromJson(Map<String, dynamic> json) {
    return CivicScoreData(
      plateDisplay: json['plate_display']?.toString() ?? '',
      plateClean: json['plate_clean']?.toString() ?? '',
      avgRating: (json['avg_rating'] is num) ? (json['avg_rating'] as num).toDouble() : 0.0,
      totalRatings: json['total_ratings'] as int? ?? 0,
      message: json['message']?.toString() ?? '',
      hasRatings: json['has_ratings'] as bool? ?? false,
      starsFull: json['stars_full'] as int? ?? 0,
    );
  }
}

class CivicScoreService {
  static const String baseUrl = 'https://app.ngf132.com/app_api';
  static const String submitEndpoint = '/civic_score_submit_api';
  static const String getEndpoint = '/civic_score_get_api';

  // Standard params as found in other services
  static const Map<String, String> _standardParams = {
    'sm': '67s87s6yys66',
    '6s888iop': '6s888iop',
    'dg': 'testYU78dII8iiUIPSISJ',
  };

  /// Submit civic score for a vehicle
  static Future<CivicScoreResponse> submitCivicScore({
    required String plate,
    required int rating,
    required String phone,
    List<String>? reasons,
    String? comment,
  }) async {
    print('🚗 Submitting Civic Score: plate=$plate, rating=$rating, phone=$phone');

    try {
      final url = Uri.parse('$baseUrl$submitEndpoint');

      final Map<String, String> body = {
        ..._standardParams,
        'vehicle_plate': plate.trim().toUpperCase(),
        'rating': rating.toString(),
        'phone': phone.trim(),
      };
      // ... rest of logic stays same ...
      if (comment != null && comment.isNotEmpty) {
        body['comment'] = comment.trim();
      }

      if (reasons != null && reasons.isNotEmpty) {
        for (int i = 0; i < reasons.length; i++) {
          body['reasons[$i]'] = reasons[i];
        }
      }

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

      print('📥 Response: ${response.statusCode} | ${response.body}');

      final jsonResponse = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CivicScoreResponse.fromJson(jsonResponse);
      } else {
        String errorMessage = jsonResponse['message'] ?? 'Something went wrong. Please try again.';
        throw Exception(errorMessage);
      }
    } on Exception catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }

  /// Get civic score details for a vehicle
  static Future<CivicScoreResponse> getCivicScore({
    required String plate,
  }) async {
    print('🔍 Getting Civic Score for: $plate');

    try {
      // Use standard params for AUTH if needed, though API says optional for public read
      final queryParams = {
        ..._standardParams,
        'plate': plate.trim().toUpperCase(),
      };
      
      final uri = Uri.parse('$baseUrl$getEndpoint').replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      print('📥 Response: ${response.statusCode} | ${response.body}');

      final jsonResponse = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return CivicScoreResponse.fromJson(jsonResponse);
      } else {
        String errorMessage = jsonResponse['message'] ?? 'Vehicle not found or API error.';
        throw Exception(errorMessage);
      }
    } on Exception catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }
}
