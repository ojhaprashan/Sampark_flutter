import 'package:shared_preferences/shared_preferences.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  /// Convert LocationData to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create LocationData from JSON
  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, time: $timestamp)';
  }
}

class LocationService {
  static const String _keyLastLocation = 'last_location';
  static const String _keyLocationPermissionAsked = 'location_permission_asked';

  /// Save location to local storage
  static Future<void> saveLocation(double latitude, double longitude) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationData = LocationData(
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
      );
      
      final jsonString = _locationToJson(locationData.toJson());
      await prefs.setString(_keyLastLocation, jsonString);
      
      print('✅ Location saved: $locationData');
    } catch (e) {
      print('❌ Error saving location: $e');
    }
  }

  /// Get last saved location from local storage
  static Future<LocationData?> getLastLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyLastLocation);
      
      if (jsonString == null) {
        print('📍 No location found in local storage');
        return null;
      }
      
      final jsonMap = _jsonToLocation(jsonString);
      final locationData = LocationData.fromJson(jsonMap);
      
      print('✅ Location retrieved: $locationData');
      return locationData;
    } catch (e) {
      print('❌ Error retrieving location: $e');
      return null;
    }
  }

  /// Check if location permission has been asked before
  static Future<bool> hasAskedForPermission() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyLocationPermissionAsked) ?? false;
    } catch (e) {
      print('❌ Error checking permission status: $e');
      return false;
    }
  }

  /// Mark that location permission has been asked
  static Future<void> markPermissionAsked() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyLocationPermissionAsked, true);
      print('✅ Permission request marked as asked');
    } catch (e) {
      print('❌ Error marking permission as asked: $e');
    }
  }

  /// Clear saved location data
  static Future<void> clearLocationData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyLastLocation);
      print('✅ Location data cleared');
    } catch (e) {
      print('❌ Error clearing location data: $e');
    }
  }

  /// Helper method to convert LocationData to JSON string
  static String _locationToJson(Map<String, dynamic> data) {
    return '${data['latitude']},${data['longitude']},${data['timestamp']}';
  }

  /// Helper method to convert JSON string to Map
  static Map<String, dynamic> _jsonToLocation(String jsonString) {
    final parts = jsonString.split(',');
    return {
      'latitude': double.parse(parts[0]),
      'longitude': double.parse(parts[1]),
      'timestamp': parts[2],
    };
  }

  /// Get location age in seconds
  static Future<int?> getLocationAgeInSeconds() async {
    try {
      final location = await getLastLocation();
      if (location == null) return null;
      
      final age = DateTime.now().difference(location.timestamp).inSeconds;
      return age;
    } catch (e) {
      print('❌ Error getting location age: $e');
      return null;
    }
  }
}
