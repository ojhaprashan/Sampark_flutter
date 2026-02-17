import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class WalletData {
  final double balance;
  final String userId;
  final List<WalletTransaction> transactions;

  WalletData({
    required this.balance,
    required this.userId,
    required this.transactions,
  });

  factory WalletData.fromJson(Map<String, dynamic> json) {
    // Convert balance to double and round to 2 decimal places
    double balance = 0.0;
    if (json['balance'] != null) {
      balance = (json['balance'] as num).toDouble();
      // Round to 2 decimal places
      balance = double.parse(balance.toStringAsFixed(2));
    }

    final List<WalletTransaction> transactions = [];
    if (json['transactions'] != null) {
      for (var item in json['transactions']) {
        transactions.add(WalletTransaction.fromJson(item));
      }
    }

    return WalletData(
      balance: balance,
      userId: json['user_id']?.toString() ?? '',
      transactions: transactions,
    );
  }
}

class WalletTransaction {
  final int wId;
  final double amount;
  final String type; // CR or DR
  final String date;
  final String details;
  final String status; // 0 = Failed, 1 = Success, 2 = Pending
  final String statusText;
  final String orderId;

  WalletTransaction({
    required this.wId,
    required this.amount,
    required this.type,
    required this.date,
    required this.details,
    required this.status,
    required this.statusText,
    required this.orderId,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      wId: json['w_wid'] as int? ?? 0,
      amount: (json['w_amount'] as num?)?.toDouble() ?? 0.0,
      type: json['w_cr_db'] as String? ?? 'CR',
      date: json['w_date'] as String? ?? '',
      details: json['w_details'] as String? ?? '',
      status: json['w_status']?.toString() ?? '0',
      statusText: json['w_status_text'] as String? ?? 'Unknown',
      orderId: json['w_order_id'] as String? ?? '',
    );
  }
}

class WalletService {
  static const String _baseUrl = 'https://app.ngf132.com/app_api/wallet';

  // Credentials
  static const String _smValue = '67s87s6yys66';
  static const String _keyValue = '6s888iop';
  static const String _dgValue = 'testYU78dII8iiUIPSISJ';

  /// Fetch wallet data for user
  static Future<WalletData> fetchWallet({
    required String phone,
  }) async {
    try {
      // Check internet connectivity first
      print('🔍 Checking internet connectivity...');
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isEmpty || result[0].rawAddress.isEmpty) {
          throw Exception('No internet connection');
        }
        print('✅ Internet connection available');
      } on SocketException catch (_) {
        throw Exception('No internet connection. Please check your network settings.');
      }

      final body = {
        'sm': _smValue,
        '6s888iop': _keyValue,
        'dg': _dgValue,
        'phone': phone,
      };

      print('🔵 Making request to: $_baseUrl');
      print('🔵 Body parameters:');
      print('   - phone: $phone');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout after 30 seconds');
        },
      );

      print('✅ Response status: ${response.statusCode}');
      print('✅ Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return WalletData.fromJson(jsonData);
      } else {
        throw Exception('Failed to load wallet data. Status code: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      print('❌ SocketException: $e');
      throw Exception('Network error: Cannot connect to server. Please check your internet connection and try again.');
    } on http.ClientException catch (e) {
      print('❌ ClientException: $e');
      throw Exception('Connection failed: Please check your internet connection.');
    } on FormatException catch (e) {
      print('❌ FormatException: $e');
      throw Exception('Invalid response from server');
    } catch (e) {
      print('❌ Unknown Error: $e');
      throw Exception('Error fetching wallet: $e');
    }
  }
}
