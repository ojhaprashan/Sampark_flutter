import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class VehicleProfileService {
  static const String _baseUrl = 'https://app.ngf132.com/app_api/add_profile_vehicles';

  // Credentials
  static const String _smValue = '67s87s6yys66';
  static const String _keyValue = '6s888iop';
  static const String _dgValue = 'testYU78dII8iiUIPSISJ';

  /// Add vehicles to user profile
  static Future<Map<String, dynamic>> addProfileVehicles({
    required String phone,
    required List<Map<String, String>> vehicles,
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

      // Format vehicles for API - convert to JSON string
      final vehiclesJson = jsonEncode(vehicles);

      final body = {
        'sm': _smValue,
        '6s888iop': _keyValue,
        'dg': _dgValue,
        'phone': phone,
        'vehicles': vehiclesJson,
      };
      print("body: $body");
      print('🔵 Making request to: $_baseUrl');
      print('🔵 Body parameters:');
      print('   - phone: $phone');
      print('   - vehicles: $vehiclesJson');

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

        // Check if vehicles were added successfully
        final added = jsonData['added'] as int? ?? 0;
        final skipped = jsonData['skipped'] as int? ?? 0;

        return {
          'status': 'success',
          'message': 'Vehicles added successfully',
          'added': added,
          'skipped': skipped,
          'data': jsonData,
        };
      } else {
        throw Exception(
          'Server error: ${response.statusCode}',
        );
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
      throw Exception('Error: $e');
    }
  }
}
