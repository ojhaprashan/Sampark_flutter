import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String timestamp;
  final String status;
  final String? type;
  final String? plate;
  final int? tagId;
  final String? vtype;
  final bool isDemoTag;
  final String? name;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.status,
    this.type,
    this.plate,
    this.tagId,
    this.vtype,
    this.isDemoTag = false,
    this.name,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id']?.toString() ?? '',
      title: json['type_label'] ?? 'Notification',
      message: json['reason_label'] ?? json['message'] ?? '',
      timestamp: json['date'] ?? '',
      status: 'unread',
      type: json['type']?.toString(),
      plate: json['plate']?.toString(),
      tagId: json['tag_id'],
      vtype: json['vtype']?.toString(),
      isDemoTag: json['is_demo'] ?? false,
      name: json['name']?.toString(),
    );
  }
}

class NotificationResponse {
  final String status;
  final String message;
  final List<NotificationItem> notifications;

  NotificationResponse({
    required this.status,
    required this.message,
    required this.notifications,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    // Handle nested data structure: data contains notifications array
    final dataObj = json['data'];
    List<NotificationItem> items = [];

    if (dataObj is Map<String, dynamic>) {
      // data is an object, get notifications array from it
      final notificationsList = dataObj['notifications'] ?? [];
      items = (notificationsList as List)
          .map((item) => NotificationItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (dataObj is List) {
      // data is directly a list
      items = (dataObj as List)
          .map((item) => NotificationItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return NotificationResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      notifications: items,
    );
  }
}

class NotificationService {
  static const String baseUrl = 'https://app.ngf132.com/app_api';
  static const String endpoint = '/tag_notif_api';
  static const String globalEndpoint = '/list_notifications_api';

  /// Fetch notifications for a specific tag
  static Future<NotificationResponse> fetchNotifications({
    required String tagInternalId,
    required String phone,
    String countryCode = '91',
    int limit = 50,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');

      final Map<String, dynamic> body = {
        'sm': '67s87s6yys66',
        '6s888iop': '6s888iop',
        'dg': 'ABCDYU78dII8iiUIPSISJ',
        'id': tagInternalId,
        'phone': phone,
        'code_co': countryCode,
        'limit': limit.toString(),
      };

      print('\n📬 Fetch Tag Notifications API Request');
      print('📍 URL: $url');
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
        print('✅ Fetch Tag Notifications API Response: ${response.body}\n');
        return NotificationResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
          'API Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Tag Notification API Error: $e\n');
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  /// Fetch global notifications for user (no tag required)
  static Future<NotificationResponse> fetchGlobalNotifications({
    required String phone,
    String countryCode = '91',
    int limit = 50,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl$globalEndpoint?sm=67s87s6yys66&6s888iop=6s888iop&dg=ABCDYU78dII8iiUIPSISJ&ph=$phone&limit=$limit',
      );

      print('\n📬 Fetch Global Notifications API Request');
      print('📍 URL: $url');
      print('📦 Phone: $phone, Limit: $limit\n');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('✅ Fetch Global Notifications API Response: ${response.body}\n');
        return NotificationResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
          'API Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Global Notification API Error: $e\n');
      throw Exception('Failed to fetch global notifications: $e');
    }
  }
}