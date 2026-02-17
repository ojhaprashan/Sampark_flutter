import 'dart:convert';
import 'package:http/http.dart' as http;

class TagProfileResponse {
  final String status;
  final String message;
  final TagProfileData data;

  TagProfileResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TagProfileResponse.fromJson(Map<String, dynamic> json) {
    return TagProfileResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: TagProfileData.fromJson(json['data'] ?? {}),
    );
  }
}

class TagProfileData {
  final int tagId;
  final String tagPublicId;
  final String plateNumber;
  final String tagType;
  final String tagTypeCode;
  final String statusCode;
  final String statusLabel;
  final bool isActive;
  final bool isPaused;
  final bool isDemoTag;
  final String demoCode;
  final bool isPremium;
  final CallFlags callFlags;
  final bool hasSecondaryNumber;

  TagProfileData({
    required this.tagId,
    required this.tagPublicId,
    required this.plateNumber,
    required this.tagType,
    required this.tagTypeCode,
    required this.statusCode,
    required this.statusLabel,
    required this.isActive,
    required this.isPaused,
    required this.isDemoTag,
    required this.demoCode,
    required this.isPremium,
    required this.callFlags,
    required this.hasSecondaryNumber,
  });

  factory TagProfileData.fromJson(Map<String, dynamic> json) {
    return TagProfileData(
      tagId: json['tag_id'] ?? 0,
      tagPublicId: json['tag_public_id'] ?? '',
      plateNumber: json['plate_number'] ?? '',
      tagType: json['tag_type'] ?? '',
      tagTypeCode: json['tag_type_code'] ?? '',
      statusCode: json['status_code']?.toString() ?? '0',
      statusLabel: json['status_label'] ?? '',
      isActive: json['is_active'] ?? false,
      isPaused: json['is_paused'] ?? false,
      isDemoTag: json['is_demo_tag'] ?? false,
      demoCode: json['demo_code']?.toString() ?? '0',
      isPremium: json['is_premium'] ?? false,
      callFlags: CallFlags.fromJson(json['call_flags'] ?? {}),
      hasSecondaryNumber: json['has_secondary_number'] ?? false,
    );
  }
}

class CallFlags {
  final bool callsEnabled;
  final bool whatsappEnabled;
  final bool callMaskingEnabled;
  final bool videoCallEnabled;

  CallFlags({
    required this.callsEnabled,
    required this.whatsappEnabled,
    required this.callMaskingEnabled,
    required this.videoCallEnabled,
  });

  factory CallFlags.fromJson(Map<String, dynamic> json) {
    return CallFlags(
      callsEnabled: json['calls_enabled'] ?? false,
      whatsappEnabled: json['whatsapp_enabled'] ?? false,
      callMaskingEnabled: json['call_masking_enabled'] ?? false,
      videoCallEnabled: json['video_call_enabled'] ?? false,
    );
  }
}

class TagProfileService {
  static const String baseUrl = 'https://app.ngf132.com/app_api';
  static const String endpoint = '/get_tag_profile_api';

  /// Fetch tag profile by calling the API
  static Future<TagProfileResponse> getTagProfile({
 
    required int tagId,
  }) async {
    try {
       print('Fetching tag profile for tag ID: $tagId');
      final url = Uri.parse('$baseUrl$endpoint');

      final Map<String, dynamic> body = {
        'sm': '67s87s6yys66',
        '6s888iop': '6s888iop', // App client identifier
        'dg': 'testYU78dII8iiUIPSISJ',
        'tag_id': tagId.toString(),
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
        return TagProfileResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
          'API Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch tag profile: $e');
    }
  }
}
