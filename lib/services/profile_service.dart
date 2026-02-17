import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ProfileService {
  static const String baseUrl = 'https://app.ngf132.com/app_api';
  
  // Authentication parameters
  static const String smValue = '67s87s6yys66';
  static const String sixsValue = '6s888iop';
  static const String dgValue = 'ABCDYU78dII8iiUIPSISJ';

  /// Fetches user profile data from the API
  /// Params: ph (required – full phone with country code, e.g. 919876543210)
  static Future<Map<String, dynamic>> getProfile({
    required String phone,
  }) async {
    try {
      print('👤 Fetching profile for phone: $phone');
      
      final response = await http.post(
        Uri.parse('$baseUrl/get_profile_api'),
        body: {
          'sm': smValue,
          '6s888iop': sixsValue,
          'dg': dgValue,
          'ph': phone,
        },
      ).timeout(const Duration(seconds: 30));

      print('📊 Response Status: ${response.statusCode}');
      print('📝 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Check if status is 'success' (string) or true (boolean)
        final statusSuccess = data['status'] == 'success' || data['status'] == true || data['success'] == true;
        
        if (statusSuccess) {
          print('✅ Profile fetched successfully');
          
          // Extract profile data from 'data' field
          final profileData = data['data'] ?? {};
          print('📦 Profile data keys: ${profileData.keys}');
          return {
            'success': true,
            'message': data['message'] ?? 'Profile fetched successfully',
            'data': profileData,
          };
        } else {
          print('❌ API returned false status: ${data['status']}');
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to fetch profile',
            'data': {},
          };
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        return {
          'success': false,
          'message': 'HTTP Error: ${response.statusCode}',
          'data': {},
        };
      }
    } catch (e) {
      print('❌ Exception in getProfile: $e');
      return {
        'success': false,
        'message': 'Error fetching profile: $e',
        'data': {},
      };
    }
  }

  /// Updates user profile data via the API
  /// Params: ph (required), name (required), email (required), 
  /// address, zip, state, city, gender, about, fb, tw, ins, yt, bl, dob
  
  
  static Future<Map<String, dynamic>> updateProfile({
    required String phone,
    required String name,
    required String email,
    String? address,
    String? zip,
    String? state,
    String? city,
    String? gender,
    String? about,
    String? facebook,
    String? twitter,
    String? instagram,
    String? youtube,
    String? blog,
    String? dateOfBirth,
  }) async {
    try {
      print('📝 Updating profile for phone: $phone');
      print('   Name: $name');
      print('   Email: $email');

      final body = {
        'sm': smValue,
        '6s888iop': sixsValue,
        'dg': dgValue,
        'ph': phone,
        'name': name,
        'email': email,
      };

      // Add optional parameters only if they are provided and not empty
      if (address != null && address.isNotEmpty) body['address'] = address;
      if (zip != null && zip.isNotEmpty) body['zip'] = zip;
      if (state != null && state.isNotEmpty) body['state'] = state;
      if (city != null && city.isNotEmpty) body['city'] = city;
      if (gender != null && gender.isNotEmpty) body['gender'] = gender;
      if (about != null && about.isNotEmpty) body['about'] = about;
      if (facebook != null && facebook.isNotEmpty) body['fb'] = facebook;
      if (twitter != null && twitter.isNotEmpty) body['tw'] = twitter;
      if (instagram != null && instagram.isNotEmpty) body['ins'] = instagram;
      if (youtube != null && youtube.isNotEmpty) body['yt'] = youtube;
      if (blog != null && blog.isNotEmpty) body['bl'] = blog;
      if (dateOfBirth != null && dateOfBirth.isNotEmpty) body['dob'] = dateOfBirth;

      print('📊 Request body keys: ${body.keys.join(', ')}');

      final response = await http.post(
        Uri.parse('$baseUrl/update_profile_api'),
        body: body,
      ).timeout(const Duration(seconds: 30));

      print('📊 Response Status: ${response.statusCode}');
      print('📝 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Check if status is 'success' (string) or true (boolean)
        final statusSuccess = data['status'] == 'success' || data['status'] == true || data['success'] == true;
        
        if (statusSuccess) {
          print('✅ Profile updated successfully');
          return {
            'success': true,
            'message': data['message'] ?? 'Profile updated successfully',
          };
        } else {
          print('❌ API returned false status: ${data['status']}');
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to update profile',
          };
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        return {
          'success': false,
          'message': 'HTTP Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Exception in updateProfile: $e');
      return {
        'success': false,
        'message': 'Error updating profile: $e',
      };
    }
  }
}
