import 'dart:convert';
import 'package:http/http.dart' as http;


class VehicleSearchResponse {
  final String status;
  final String message;
  final VehicleSearchData data;


  VehicleSearchResponse({
    required this.status,
    required this.message,
    required this.data,
  });


  factory VehicleSearchResponse.fromJson(Map<String, dynamic> json) {
    return VehicleSearchResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: VehicleSearchData.fromJson(json['data'] ?? {}),
    );
  }
}


class VehicleSearchData {
  final String plate;
  final bool tagFound;
  final int tagId;
  final String carUrl;
  final VehicleInfo vehicle;
  final String message;  // ✅ Add message from API


  VehicleSearchData({
    required this.plate,
    required this.tagFound,
    required this.tagId,
    required this.carUrl,
    required this.vehicle,
    required this.message,
  });


  factory VehicleSearchData.fromJson(Map<String, dynamic> json) {
    return VehicleSearchData(
      plate: json['plate'] ?? '',
      tagFound: json['tag_found'] ?? false,
      tagId: json['tag_id'] ?? 0,
      carUrl: json['car_url'] ?? '',
      vehicle: VehicleInfo.fromJson(json['vehicle'] ?? {}),
      message: json['message'] ?? '',  // ✅ Get message from API response
    );
  }
}


class VehicleInfo {
  final String fuelType;
  final String color;
  final String model;
  final String ownerNameMasked;
  final String state;
  final String norms;
  final String manufacturerName;


  VehicleInfo({
    required this.fuelType,
    required this.color,
    required this.model,
    required this.ownerNameMasked,
    required this.state,
    required this.norms,
    required this.manufacturerName,
  });


  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      fuelType: json['fuel_descr'] ?? '',
      color: json['color'] ?? '',
      model: json['model'] ?? '',
      ownerNameMasked: json['owner_name_masked'] ?? '',
      state: json['state'] ?? '',
      norms: json['norms_descr'] ?? '',
      manufacturerName: json['vehicle_manufacturer_name'] ?? '',
    );
  }
}


class VehicleSearchService {
  static const String baseUrl = 'https://app.ngf132.com/app_api';
  static const String endpoint = '/search_api';


  /// Search vehicle by plate number
  static Future<VehicleSearchResponse> searchVehicle({
    required String plate,
    required String phone,
  }) async {
    print('🔍 Search Request: plate=$plate, phone=$phone');

    try {
      final url = Uri.parse('$baseUrl$endpoint');

      final Map<String, dynamic> body = {
        'sm': '67s87s6yys66',
        '6s888iop': '6s888iop',
        'dg': 'testYU78dII8iiUIPSISJ',
        'plate': plate,
        'phone': phone,
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

      print('📥 Response: ${response.statusCode} | ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return VehicleSearchResponse.fromJson(jsonResponse);
      } else {
        // Extract error message from API response
        String errorMessage = 'Something went wrong. Please try again.';
        try {
          final jsonResponse = jsonDecode(response.body);
          errorMessage = jsonResponse['message'] ?? errorMessage;
        } catch (e) {
          // If JSON parsing fails, use default message
          errorMessage = 'API Error: ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } on Exception catch (e) {
      print('❌ Error: $e');
      // Re-throw to preserve the extracted message
      rethrow;
    }
  }
}
