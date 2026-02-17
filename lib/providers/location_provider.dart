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
    try {
      print('📍 [LocationProvider] === INITIALIZING LOCATION ===');
      print('📍 [LocationProvider] Step 1: Checking saved location...');
      
      // Step 1: Check if location already exists in local storage
      final savedLocation = await LocationService.getLastLocation();
      
      if (savedLocation != null) {
        print('✅ [LocationProvider] Step 1 RESULT: Found saved location!');
        print('   ├─ Latitude: ${savedLocation.latitude}');
        print('   ├─ Longitude: ${savedLocation.longitude}');
        print('   └─ Timestamp: ${savedLocation.timestamp}');
        
        _currentLocation = savedLocation;
        _permissionAsked = true;
        notifyListeners();
        print('📍 [LocationProvider] === INITIALIZATION COMPLETE (using saved location) ===\n');
        return;
      }

      print('⚠️  [LocationProvider] Step 1 RESULT: No saved location found');
      print('📍 [LocationProvider] Step 2: Checking permission status...');
      
      // Step 2: Check current permission status
      final permissionStatus = await Permission.location.status;
      print('📍 [LocationProvider] Step 2 RESULT: Permission status = $permissionStatus');
      
      if (permissionStatus.isGranted) {
        print('✅ [LocationProvider] Permission is GRANTED - Can fetch location');
        _permissionAsked = true;
        await LocationService.markPermissionAsked();
        await _getCurrentLocation();
      } else {
        print('❌ [LocationProvider] Permission NOT granted - Need to request');
        print('📍 [LocationProvider] Step 3: Requesting permission with default dialog...');
        // Show default Android dialog
        await requestLocationPermission();
      }
      
      print('📍 [LocationProvider] === INITIALIZATION COMPLETE ===\n');
    } catch (e) {
      print('❌ [LocationProvider] Error during initialization: $e');
      _locationError = 'Error initializing location: $e';
      notifyListeners();
    }
  }

  /// Request location permission from user
  /// Shows default Android permission dialog
  Future<void> requestLocationPermission() async {
    try {
      print('\n📍 [LocationProvider] === REQUESTING LOCATION PERMISSION ===');
      print('📍 [LocationProvider] Showing default Android permission dialog...');
      print('⚠️  [LocationProvider] User must tap ALLOW to continue\n');
      
      _isLoadingLocation = true;
      _locationError = null;
      notifyListeners();

      // Request permission - shows default Android dialog
      final PermissionStatus status = await Permission.location.request();
      print('📍 [LocationProvider] User response: $status\n');

      // Mark that permission has been asked
      await LocationService.markPermissionAsked();
      _permissionAsked = true;

      if (status.isDenied) {
        _locationError = 'PERMISSION_DENIED';
        print('❌ [LocationProvider] User DENIED location permission');
        print('⚠️  [LocationProvider] App cannot access location without permission');
      } else if (status.isGranted) {
        print('✅ [LocationProvider] User ALLOWED location permission!');
        print('📍 [LocationProvider] Now fetching current location...\n');
        // Get location after permission is granted
        await _getCurrentLocation();
      } else if (status.isPermanentlyDenied) {
        _locationError = 'PERMISSION_PERMANENTLY_DENIED';
        print('❌ [LocationProvider] Permission PERMANENTLY DENIED');
        print('⚠️  [LocationProvider] User must enable in settings: Settings > App > Permissions > Location');
      }

      print('📍 [LocationProvider] === PERMISSION REQUEST COMPLETE ===\n');
      notifyListeners();
    } catch (e) {
      _locationError = 'ERROR_REQUESTING_PERMISSION: $e';
      print('❌ [LocationProvider] Error requesting permission: $e\n');
      notifyListeners();
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  /// Get current location and save it
  Future<void> _getCurrentLocation() async {
    try {
      print('\n📍 [LocationProvider] === FETCHING CURRENT LOCATION ===');
      
      _isLoadingLocation = true;
      _locationError = null;
      notifyListeners();

      // Step 1: Check if location services are enabled on device
      print('📍 [LocationProvider] STEP 1: Checking if location services are enabled...');
      final isLocationServiceEnabled =
          await Geolocator.isLocationServiceEnabled();
      print('📍 [LocationProvider] Location services enabled: $isLocationServiceEnabled');

      if (!isLocationServiceEnabled) {
        _locationError = 'LOCATION_SERVICES_DISABLED';
        print('❌ [LocationProvider] LOCATION SERVICES ARE OFF');
        print('⚠️  [LocationProvider] User must enable Location/GPS in device settings');
        print('📍 [LocationProvider] Showing message to user to enable location...');
        notifyListeners();
        return;
      }
      
      print('✅ [LocationProvider] STEP 1 RESULT: Location services are ENABLED');

      // Step 2: Get current position with timeout
      print('\n📍 [LocationProvider] STEP 2: Requesting GPS coordinates from device...');
      print('📍 [LocationProvider] Accuracy: BEST | Timeout: 30 seconds');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 30),
      );

      print('✅ [LocationProvider] STEP 2 RESULT: GPS coordinates received!');
      print('   ├─ Latitude:  ${position.latitude}');
      print('   ├─ Longitude: ${position.longitude}');
      print('   ├─ Accuracy:  ${position.accuracy.toStringAsFixed(2)}m');
      print('   └─ Timestamp: ${position.timestamp}');

      // Step 3: Save location locally
      print('\n📍 [LocationProvider] STEP 3: Saving coordinates to local storage...');
      await LocationService.saveLocation(
        position.latitude,
        position.longitude,
      );
      print('✅ [LocationProvider] STEP 3 RESULT: Coordinates saved!');

      // Step 4: Update provider state
      _currentLocation = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
      );

      print('\n✅ [LocationProvider] FINAL RESULT: Location saved successfully!');
      print('   ├─ Latitude:  ${_currentLocation!.latitude}');
      print('   ├─ Longitude: ${_currentLocation!.longitude}');
      print('   └─ Status:    SAVED TO STORAGE ✅');
      print('📍 [LocationProvider] === LOCATION FETCH COMPLETE ===\n');
      
      _locationError = null;
      notifyListeners();
    } catch (e) {
      String errorMsg = e.toString();
      _locationError = errorMsg;
      print('❌ [LocationProvider] GPS FETCH FAILED');
      print('   └─ Error: $errorMsg');

      // Try to load last saved location as fallback
      print('\n📍 [LocationProvider] FALLBACK: Attempting to load last saved location...');
      _currentLocation = await LocationService.getLastLocation();

      if (_currentLocation != null) {
        print('✅ [LocationProvider] FALLBACK SUCCESS!');
        print('   ├─ Latitude:  ${_currentLocation!.latitude}');
        print('   ├─ Longitude: ${_currentLocation!.longitude}');
        print('   └─ Timestamp: ${_currentLocation!.timestamp}');
        _locationError = 'Using previous location. Current GPS fetch failed.';
      } else {
        print('❌ [LocationProvider] FALLBACK FAILED - No previous location saved');
        _locationError = 'GPS_FETCH_FAILED: $errorMsg';
      }
      print('📍 [LocationProvider] === LOCATION FETCH FAILED ===\n');

      notifyListeners();
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  /// Open location settings when location services are disabled or permission denied
  Future<void> openLocationSettings() async {
    try {
      print('\n📍 [LocationProvider] === OPENING LOCATION SETTINGS ===');
      print('📍 [LocationProvider] Redirecting user to device settings...');
      print('⚠️  [LocationProvider] Steps:');
      print('   1. Enable Location/GPS in settings');
      print('   2. Return to app');
      print('   3. Location will be fetched automatically\n');
      
      await Geolocator.openLocationSettings();
      
      print('✅ [LocationProvider] Settings opened - waiting for user to enable location...');
      print('📍 [LocationProvider] === WAITING FOR USER ===\n');
    } catch (e) {
      print('❌ [LocationProvider] Error opening settings: $e\n');
    }
  }

  /// Manually refresh location
  Future<void> refreshLocation() async {
    print('\n📍 [LocationProvider] === MANUAL LOCATION REFRESH REQUESTED ===');
    print('📍 [LocationProvider] Triggering new location fetch...');
    await _getCurrentLocation();
    print('📍 [LocationProvider] === REFRESH COMPLETE ===\n');
  }

  /// Load last saved location from storage
  Future<void> loadLastLocation() async {
    try {
      print('\n📍 [LocationProvider] === LOADING LAST SAVED LOCATION ===');
      
      _isLoadingLocation = true;
      notifyListeners();

      print('📍 [LocationProvider] Searching SharedPreferences...');
      final location = await LocationService.getLastLocation();
      _currentLocation = location;

      if (location == null) {
        _locationError = 'No saved location found in storage';
        print('⚠️  [LocationProvider] $_locationError');
      } else {
        print('✅ [LocationProvider] Saved location found:');
        print('   ├─ Latitude:  ${location.latitude}');
        print('   ├─ Longitude: ${location.longitude}');
        print('   └─ Timestamp: ${location.timestamp}');
        _locationError = null;
      }

      print('📍 [LocationProvider] === LOAD COMPLETE ===\n');
      notifyListeners();
    } catch (e) {
      _locationError = 'Error loading location: $e';
      print('❌ [LocationProvider] Exception: $e');
      notifyListeners();
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  /// Clear all location data
  Future<void> clearLocation() async {
    try {
      print('📍 [LocationProvider] Clearing location data...');
      
      await LocationService.clearLocationData();
      _currentLocation = null;
      _locationError = null;
      notifyListeners();
      print('✅ [LocationProvider] Location data cleared');
    } catch (e) {
      _locationError = 'Error clearing location: $e';
      print('❌ [LocationProvider] $_locationError');
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
    if (_currentLocation == null) {
      print('❌ [LocationProvider] Current location is null, cannot calculate distance');
      return null;
    }

    final distance = Geolocator.distanceBetween(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      otherLat,
      otherLng,
    ) / 1000; // Convert meters to kilometers
    
    print('📍 [LocationProvider] Distance calculated: ${distance.toStringAsFixed(2)} km');
    return distance;
  }
}
