import 'package:http/http.dart' as http;
import 'dart:convert';

// Scan Location model
class ScanLocation {
  final String latitude;
  final String longitude;
  final String time;
  final String mapsUrl;

  ScanLocation({
    required this.latitude,
    required this.longitude,
    required this.time,
    required this.mapsUrl,
  });

  factory ScanLocation.fromJson(Map<String, dynamic> json) {
    return ScanLocation(
      latitude: json['lat'] as String? ?? '',
      longitude: json['long'] as String? ?? '',
      time: json['time'] as String? ?? '',
      mapsUrl: json['maps_url'] as String? ?? '',
    );
  }
}

// Scan Locations Response model
class ScanLocationsResponse {
  final String status;
  final String message;
  final int tagId;
  final int count;
  final List<ScanLocation> locations;

  ScanLocationsResponse({
    required this.status,
    required this.message,
    required this.tagId,
    required this.count,
    required this.locations,
  });

  factory ScanLocationsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final locationsJson = data['locations'] as List? ?? [];

    return ScanLocationsResponse(
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      tagId: data['tag_id'] as int? ?? 0,
      count: data['count'] as int? ?? 0,
      locations: locationsJson
          .map((item) => ScanLocation.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

// Scan Location Service
class ScanLocationService {
  static const String _baseUrl = 'https://app.ngf132.com/app_api';

  // Static auth credentials
  static const String _smValue = '67s87s6yys66';
  static const String _keyValue = '6s888iop';
  static const String _dgValue = 'ABCDYU78dII8iiUIPSISJ';

  /// Fetch scan locations for a specific tag
  static Future<ScanLocationsResponse> fetchScanLocations({
    required String phoneWithCountryCode,
    required int tagId,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/tag_locations_api').replace(
        queryParameters: {
          'ph': phoneWithCountryCode,
          'tag_id': tagId.toString(),
          'sm': _smValue,
          '6s888iop': _keyValue,
          'dg': _dgValue,
        },
      );

      print('🔗 API URL: $url');
      print('📋 Request Parameters:');
      print('   - Phone: $phoneWithCountryCode');
      print('   - Tag ID: $tagId');

      final response = await http.get(url);

      print('📡 Response Status Code: ${response.statusCode}');
      print('📝 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('✅ Successfully parsed response: $jsonResponse');
        return ScanLocationsResponse.fromJson(jsonResponse);
      } else {
        print('❌ Error: HTTP ${response.statusCode}');
        throw Exception(
          'Failed to fetch scan locations: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Exception caught: $e');
      throw Exception('Error fetching scan locations: $e');
    }
  }
}
