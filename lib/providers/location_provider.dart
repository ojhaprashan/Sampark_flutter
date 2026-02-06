import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:my_new_app/services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  LocationData? _currentLocation;
  bool _isLoadingLocation = false;
  String? _locationError;
  bool _permissionAsked = false;

  // Getters
  LocationData? get currentLocation => _currentLocation;
  bool get isLoadingLocation => _isLoadingLocation;
  String? get locationError => _locationError;
  bool get permissionAsked => _permissionAsked;
  bool get hasLocation => _currentLocation != null;

  /// Initialize location provider (check permissions and get location)
  Future<void> initializeLocation() async {
    _permissionAsked = await LocationService.hasAskedForPermission();
    
    if (_permissionAsked) {
      // Permission already asked, just get the current location
      await _getCurrentLocation();
    }
  }

  /// Request location permission from user
  /// Uses custom dialog only - suppresses system dialog by checking first
  Future<void> requestLocationPermission() async {
    try {
      _isLoadingLocation = true;
      _locationError = null;
      notifyListeners();

      // Check current permission status first to avoid system dialog
      PermissionStatus status = await Permission.location.status;
      
      // If not determined, request the permission
      if (status.isDenied) {
        status = await Permission.location.request();
      }

      // Mark that permission has been asked (do this after requesting)
      await LocationService.markPermissionAsked();
      _permissionAsked = true;

      if (status.isDenied) {
        _locationError = 'Location permission denied';
        print('❌ $_locationError');
      } else if (status.isGranted) {
        print('✅ Location permission granted');
        // Get location after permission is granted
        await _getCurrentLocation();
      } else if (status.isPermanentlyDenied) {
        _locationError =
            'Location permission permanently denied. Please enable it in settings.';
        print('⚠️ $_locationError');
      }

      notifyListeners();
    } catch (e) {
      _locationError = 'Error requesting location permission: $e';
      print('❌ $_locationError');
      notifyListeners();
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  /// Get current location and save it
  Future<void> _getCurrentLocation() async {
    try {
      _isLoadingLocation = true;
      _locationError = null;
      notifyListeners();

      // Check if location services are enabled
      final isLocationServiceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!isLocationServiceEnabled) {
        _locationError = 'Location services are disabled';
        print('❌ $_locationError');
        notifyListeners();
        return;
      }

      // Get current position with timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 30),
      );

      // Save location locally
      await LocationService.saveLocation(
        position.latitude,
        position.longitude,
      );

      // Update current location
      _currentLocation = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
      );

      print('✅ Current location: $_currentLocation');
      notifyListeners();
    } catch (e) {
      _locationError = 'Error getting location: $e';
      print('❌ $_locationError');

      // Try to load last saved location
      _currentLocation = await LocationService.getLastLocation();

      if (_currentLocation != null) {
        _locationError =
            'Using last saved location. Current location unavailable.';
      }

      notifyListeners();
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  /// Manually refresh location
  Future<void> refreshLocation() async {
    await _getCurrentLocation();
  }

  /// Load last saved location from storage
  Future<void> loadLastLocation() async {
    try {
      _isLoadingLocation = true;
      notifyListeners();

      final location = await LocationService.getLastLocation();
      _currentLocation = location;

      if (location == null) {
        _locationError = 'No saved location found';
      }

      notifyListeners();
    } catch (e) {
      _locationError = 'Error loading location: $e';
      print('❌ $_locationError');
      notifyListeners();
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  /// Clear all location data
  Future<void> clearLocation() async {
    try {
      await LocationService.clearLocationData();
      _currentLocation = null;
      _locationError = null;
      notifyListeners();
      print('✅ Location data cleared');
    } catch (e) {
      _locationError = 'Error clearing location: $e';
      print('❌ $_locationError');
      notifyListeners();
    }
  }

  /// Get location formatted as string
  String getLocationString() {
    if (_currentLocation == null) return 'Location not available';
    return '${_currentLocation!.latitude}, ${_currentLocation!.longitude}';
  }

  /// Calculate distance between two coordinates (in kilometers)
  double? calculateDistance(double otherLat, double otherLng) {
    if (_currentLocation == null) return null;

    return Geolocator.distanceBetween(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      otherLat,
      otherLng,
    ) / 1000; // Convert meters to kilometers
  }
}
