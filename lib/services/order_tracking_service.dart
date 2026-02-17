import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String orderId;
  final String status;
  final String statusCode;
  final String statusMessage;
  final String name;
  final String quantity;
  final String qtyShow;
  final String pin;
  final double amount;
  final bool cod;
  final String? trackUrl;
  final String? courierName;
  final String? shipComp;
  final String orderDate;
  final String? deliveredDate;
  final bool confirmed;
  final bool ndr;
  final bool returnAlert;
  final bool claimRaised;
  final String address;
  final String city;
  final String state;
  final String statusColor;

  OrderItem({
    required this.orderId,
    required this.status,
    required this.statusCode,
    required this.statusMessage,
    required this.name,
    required this.quantity,
    required this.qtyShow,
    required this.pin,
    required this.amount,
    required this.cod,
    this.trackUrl,
    this.courierName,
    this.shipComp,
    required this.orderDate,
    this.deliveredDate,
    required this.confirmed,
    required this.ndr,
    required this.returnAlert,
    required this.claimRaised,
    required this.address,
    required this.city,
    required this.state,
    required this.statusColor,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    String statusColor = 'grey';
    final status = json['status']?.toString().toLowerCase() ?? '';
    
    if (status.contains('delivered')) {
      statusColor = 'green';
    } else if (status.contains('shipped') || status.contains('transit') || status.contains('in-transit')) {
      statusColor = 'orange';
    } else if (status.contains('pending')) {
      statusColor = 'blue';
    } else if (status.contains('cancelled')) {
      statusColor = 'red';
    }

    return OrderItem(
      orderId: json['order_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Unknown',
      statusCode: json['status_code']?.toString() ?? '',
      statusMessage: json['status_message']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '',
      qtyShow: json['qty_show']?.toString() ?? '',
      pin: json['pin']?.toString() ?? '',
      amount: (json['amount'] is num) 
          ? (json['amount'] as num).toDouble() 
          : double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      cod: json['cod'] == true || json['cod']?.toString().toLowerCase() == 'true',
      trackUrl: json['track_url']?.toString(),
      courierName: json['courier_name']?.toString(),
      shipComp: json['ship_comp']?.toString(),
      orderDate: json['order_date']?.toString() ?? '',
      deliveredDate: json['delivered_date']?.toString(),
      confirmed: json['confirmed'] == true || json['confirmed']?.toString().toLowerCase() == 'true',
      ndr: json['ndr'] == true || json['ndr']?.toString().toLowerCase() == 'true',
      returnAlert: json['return_alert'] == true || json['return_alert']?.toString().toLowerCase() == 'true',
      claimRaised: json['claim_raised'] == true || json['claim_raised']?.toString().toLowerCase() == 'true',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      statusColor: statusColor,
    );
  }
}

class OrderTrackingResponse {
  final String status;
  final String message;
  final OrderItem? orderDetails;
  final List<OrderItem> recentOrders;

  OrderTrackingResponse({
    required this.status,
    required this.message,
    this.orderDetails,
    required this.recentOrders,
  });

  factory OrderTrackingResponse.fromJson(Map<String, dynamic> json) {
    OrderItem? orderDetails;
    List<OrderItem> recentOrders = [];

    if (json['data'] is Map) {
      orderDetails = OrderItem.fromJson(json['data']);
    }

    if (json['recent_orders'] is List) {
      recentOrders = (json['recent_orders'] as List)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (json['orders'] is List) {
      recentOrders = (json['orders'] as List)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return OrderTrackingResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      orderDetails: orderDetails,
      recentOrders: recentOrders,
    );
  }
}

class OrderTrackingService {
  static const String baseUrl = 'https://app.ngf132.com/app_api';
  static const String endpoint = '/order_track_api';

  static Future<OrderTrackingResponse> fetchOrderDetails({
    required String orderId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      
      final Map<String, String> queryParams = {
        'sm': '67s87s6yys66',
        '6s888iop': '6s888iop',
        'dg': 'ABCDYU78dII8iiUIPSISJ',
        'o': orderId,
      };

      print('\n📦 Track Order API Request');
      print('📍 URL: $url');
      print('📩 Params: $queryParams\n');

      final response = await http.get(
        url.replace(queryParameters: queryParams),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Connection timed out. Please try again.'),
      );

      print('✅ Track Order API Response Code: ${response.statusCode}');
      print('✅ Track Order API Body: ${response.body}\n');

      // 1. Try to decode the JSON regardless of status code
      Map<String, dynamic> jsonResponse = {};
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (_) {
        // If body is not JSON (e.g., HTML error page), we handle it below based on status code
      }

      // 2. If the API returned a specific message in the JSON, use it.
      // This works for 200, 400, 404, 500, etc. as long as the server sends JSON.
      if (jsonResponse.containsKey('message') && jsonResponse['message'] != null) {
        String apiMessage = jsonResponse['message'].toString();
        
        // If status code is NOT 200, throw the API message as an error
        if (response.statusCode != 200) {
          throw Exception(apiMessage);
        }
        
        // If status code IS 200, but logic status is false (e.g. "Order not found")
        if (jsonResponse['status'] == 'false' || jsonResponse['status'] == false) {
          throw Exception(apiMessage);
        }
      } 
      // 3. If NO JSON message was found (decoding failed or no 'message' key)
      else if (response.statusCode != 200) {
        throw Exception('Server Error: ${response.statusCode}');
      }

      // 4. Success case
      return OrderTrackingResponse.fromJson(jsonResponse);

    } catch (e) {
      print('❌ Track Order API Error: $e\n');
      
      // ✅ Clean the message (remove "Exception: ")
      String cleanMessage = e.toString();
      if (cleanMessage.startsWith('Exception: ')) {
        cleanMessage = cleanMessage.replaceFirst('Exception: ', '');
      }
      
      // Throw the raw message from the API or our cleaned string
      throw Exception(cleanMessage);
    }
  }

  static Color getStatusColor(String statusColor) {
    switch (statusColor.toLowerCase()) {
      case 'green':
        return const Color(0xFF4CAF50);
      case 'orange':
        return const Color(0xFFFF9800);
      case 'blue':
        return const Color(0xFF2196F3);
      case 'red':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}