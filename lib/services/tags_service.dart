import 'package:http/http.dart' as http;
import 'dart:convert';

// Tag Call Status model
class TagCallStatus {
  bool callsEnabled;
  bool whatsappEnabled;
  bool callMaskingEnabled;
  bool videoCallEnabled;

  TagCallStatus({
    required this.callsEnabled,
    required this.whatsappEnabled,
    required this.callMaskingEnabled,
    required this.videoCallEnabled,
  });

  factory TagCallStatus.fromJson(Map<String, dynamic> json) {
    return TagCallStatus(
      callsEnabled: json['calls_enabled'] as bool? ?? false,
      whatsappEnabled: json['whatsapp_enabled'] as bool? ?? false,
      callMaskingEnabled: json['call_masking_enabled'] as bool? ?? false,
      videoCallEnabled: json['video_call_enabled'] as bool? ?? false,
    );
  }
}

// Tag Settings model for detailed tag information
class TagSettings {
  final String status;
  final String message;
  final TagSettingsData data;

  TagSettings({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TagSettings.fromJson(Map<String, dynamic> json) {
    return TagSettings(
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      data: TagSettingsData.fromJson(json['data'] as Map<String, dynamic>? ?? {}),
    );
  }
}

// Tag Settings Data model
class TagSettingsData {
  final int tagId;
  final String tagPublicId;
  final String displayName;
  final String status;
  final TagCallStatus callStatus;
  final bool hasSecondaryNumber;

  TagSettingsData({
    required this.tagId,
    required this.tagPublicId,
    required this.displayName,
    required this.status,
    required this.callStatus,
    required this.hasSecondaryNumber,
  });

  factory TagSettingsData.fromJson(Map<String, dynamic> json) {
    return TagSettingsData(
      tagId: json['tag_id'] as int? ?? 0,
      tagPublicId: json['tag_public_id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      status: json['status'] as String? ?? '',
      callStatus: TagCallStatus.fromJson(
        json['call_status'] as Map<String, dynamic>? ?? {},
      ),
      hasSecondaryNumber: json['has_secondary_number'] as bool? ?? false,
    );
  }
}

// Tag model for category-based fetch
class Tag {
  final String tagInternalId;
  final String tagPublicId;
  final String displayName;
  final String status;
  final String manageUrl;

  Tag({
    required this.tagInternalId,
    required this.tagPublicId,
    required this.displayName,
    required this.status,
    required this.manageUrl,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      tagInternalId: json['tag_internal_id'] as String,
      tagPublicId: json['tag_public_id'] as String,
      displayName: json['display_name'] as String,
      status: json['status'] as String,
      manageUrl: json['manage_url'] as String,
    );
  }
}

class TagsByCategory {
  final String status;
  final int count;
  final List<Tag> tags;

  TagsByCategory({
    required this.status,
    required this.count,
    required this.tags,
  });

  factory TagsByCategory.fromJson(Map<String, dynamic> json) {
    return TagsByCategory(
      status: json['status'] as String,
      count: json['count'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((tag) => Tag.fromJson(tag as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class UserTagsStats {
  final String status;
  final String phone;
  final bool hasActiveTags;
  final TagsSummary summary;

  UserTagsStats({
    required this.status,
    required this.phone,
    required this.hasActiveTags,
    required this.summary,
  });

  factory UserTagsStats.fromJson(Map<String, dynamic> json) {
    return UserTagsStats(
      status: json['status'] as String,
      phone: json['phone'] as String,
      hasActiveTags: json['has_active_tags'] as bool? ?? false,
      summary: TagsSummary.fromJson(json['summary'] as Map<String, dynamic>),
    );
  }
}

class TagsSummary {
  final int carTags;
  final int bikeTags;
  final int businessTags;
  final int menuTags;
  final int emergencyTags;
  final int doorTags;

  TagsSummary({
    required this.carTags,
    required this.bikeTags,
    required this.businessTags,
    required this.menuTags,
    required this.emergencyTags,
    required this.doorTags,
  });

  factory TagsSummary.fromJson(Map<String, dynamic> json) {
    return TagsSummary(
      carTags: json['car_tags'] as int? ?? 0,
      bikeTags: json['bike_tags'] as int? ?? 0,
      businessTags: json['business_tags'] as int? ?? 0,
      menuTags: json['menu_tags'] as int? ?? 0,
      emergencyTags: json['emergency_tags'] as int? ?? 0,
      doorTags: json['door_tags'] as int? ?? 0,
    );
  }

  int getTotalTags() {
    return carTags + bikeTags + businessTags + menuTags + emergencyTags + doorTags;
  }
}

class TagsService {
  static const String _baseUrl = 'https://app.ngf132.com/app_api/get_user_stats_api';

  static Future<UserTagsStats> fetchUserTags({
    required String phone,
    required String smValue,
    required String dgValue,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'sm': smValue,
          '6s888iop': '6s888iop', // App client identifier
          'dg': dgValue,
          'ph': phone, // User phone number
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return UserTagsStats.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to load tags. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching user tags: $e');
    }
  }

  // Fetch tags by category
  static const String _getCategoryTagsUrl =
      'https://app.ngf132.com/app_api/get_my_tags_by_category_api';

  static Future<TagsByCategory> fetchTagsByCategory({
    required String type,
    required String phone,
    required String smValue,
    required String dgValue,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_getCategoryTagsUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'type': type, // c=car, b=bike, bs=business, MT=lost_found, DR=door
          'ph': phone, // User phone with country code (e.g., 919903466487)
          'sm': smValue,
          '6s888iop': '6s888iop', // App client identifier
          'dg': dgValue,
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TagsByCategory.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to load tags. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching tags by category: $e');
    }
  }

  // Fetch tag settings/details including call status
  static const String _getTagSettingsUrl =
      'https://app.ngf132.com/app_api/get_tag_settings_api';

  static Future<TagSettings> fetchTagSettings({
    required String tagId,
    required String phone,
    required String smValue,
    required String dgValue,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_getTagSettingsUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'tag_id': tagId, // Tag internal ID from the list API
          'ph': phone, // User phone with country code (e.g., 919903466487)
          'sm': smValue,
          '6s888iop': '6s888iop', // App client identifier
          'dg': dgValue,
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return TagSettings.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to load tag settings. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching tag settings: $e');
    }
  }

  // Update tag settings/call status
  static const String _manageTagSettingsUrl =
      'https://app.ngf132.com/app_api/manage_tag_settings_api';

  static Future<Map<String, dynamic>> updateTagSettings({
    required String tagId,
    required String phone,
    required bool callsEnabled,
    required bool whatsappEnabled,
    required bool callMaskingEnabled,
    required bool videoCallEnabled,
    required String smValue,
    required String dgValue,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_manageTagSettingsUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'tag_id': tagId,
          'ph': phone,
          'sm': smValue,
          '6s888iop': '6s888iop',
          'dg': dgValue,
          'status': 'active',
          'enable_calls': callsEnabled ? '1' : '0',
          'whatsapp_enabled': whatsappEnabled ? '1' : '0',
          'call_masking_enabled': callMaskingEnabled ? '1' : '0',
          'video_call_enabled': videoCallEnabled ? '1' : '0',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData;
      } else {
        throw Exception(
          'Failed to update tag settings. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error updating tag settings: $e');
    }
  }
}

