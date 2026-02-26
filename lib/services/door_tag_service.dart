import 'dart:convert';
import 'package:http/http.dart' as http;

// ==================
// Response Models
// ==================

class DoorCallResponse {
  final String status;
  final String message;
  final String? maskedNumber;

  DoorCallResponse({
    required this.status,
    required this.message,
    this.maskedNumber,
  });

  factory DoorCallResponse.fromJson(Map<String, dynamic> json) {
    // If status is success but no masked_number, provide a default masked number

    return DoorCallResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      maskedNumber: "080 7117 5127",
    );
  }
}

class DoorMessageResponse {
  final String status;
  final String message;

  DoorMessageResponse({
    required this.status,
    required this.message,
  });

  factory DoorMessageResponse.fromJson(Map<String, dynamic> json) {
    return DoorMessageResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

// ==================
// Door Tag Service
// ==================

class DoorTagService {
  static const String baseUrl = 'https://app.ngf132.com/app_api';
  static const String smValue = '67s87s6yys66';
  static const String sixs888iopValue = '6s888iop';
  static const String dgValue = 'testYU78dII8iiUIPSISJ';

  /// Notify owner for door tag call
  /// Params: plate (door tag id), phoneu (10-digit), lat, long optional
  static Future<DoorCallResponse> notifyOwnerForCall({
    required String doorTagId,
    required String phoneNumber,
    double? latitude,
    double? longitude,
  }) async {
    try {
      print('📞 Notifying door tag owner for call...');
      print('Door Tag ID: $doorTagId, Phone: $phoneNumber');

      final url = Uri.parse('$baseUrl/owner_call_door_api');

      final Map<String, String> body = {
        'sm': smValue,
        '6s888iop': sixs888iopValue,
        'dg': dgValue,
        'plate': doorTagId,
        'phoneu': phoneNumber,
        if (latitude != null) 'lat': latitude.toString(),
        if (longitude != null) 'long': longitude.toString(),
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
        print('✅ Door call notification response: $jsonResponse');
        return DoorCallResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
          'API Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error notifying door tag owner for call: $e');
      rethrow;
    }
  }

  /// Notify owner for door tag message
  /// Params: plate (door tag cr_id), reason (1–5), name, mess (optional), phoneu (required), lat, long optional
  /// Reason codes: 1=Delivery, 2=Friend, 3=Security, 4=Neighbor, 5=Someone
  static Future<DoorMessageResponse> notifyOwnerForMessage({
    required String doorTagId,
    required int reasonCode, // 1-5
    required String visitorName,
    required String phoneNumber,
    String? message,
    double? latitude,
    double? longitude,
  }) async {
    try {
      print('💬 Notifying door tag owner for message...');
      print('Door Tag ID: $doorTagId, Reason: $reasonCode, Phone: $phoneNumber');

      final url = Uri.parse('$baseUrl/door_owner_msg_api');

      final Map<String, String> body = {
        'sm': smValue,
        '6s888iop': sixs888iopValue,
        'dg': dgValue,
        'plate': doorTagId,
        'reason': reasonCode.toString(),
        'name': visitorName,
        'phoneu': phoneNumber,
        if (message != null && message.isNotEmpty) 'mess': message,
        if (latitude != null) 'lat': latitude.toString(),
        if (longitude != null) 'long': longitude.toString(),
      };

      print('Request body: $body');

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
        print('✅ Door message notification response: $jsonResponse');
        return DoorMessageResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
          'API Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error notifying door tag owner for message: $e');
      rethrow;
    }
  }
}
