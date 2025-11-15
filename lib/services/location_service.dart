import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Fallback coordinates (Trichy, Tamil Nadu)
  final double fallbackLat = 10.10501;
  final double fallbackLon = 78.11336;

  /// Get current location using GPS, with fallback to fixed coordinates
  Future<Map<String, double>> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled. Using fallback location.');
        return _getFallbackLocation();
      }

      // Request location permission
      PermissionStatus permission = await Permission.location.request();

      if (permission.isDenied || permission.isPermanentlyDenied) {
        debugPrint('Location permission denied. Using fallback location.');
        return _getFallbackLocation();
      }

      // Get current position using GPS
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      debugPrint(
        'GPS location obtained: ${position.latitude}, ${position.longitude}',
      );
      return {'lat': position.latitude, 'lon': position.longitude};
    } catch (e) {
      debugPrint('Error getting GPS location: $e. Using fallback location.');
      return _getFallbackLocation();
    }
  }

  /// Returns the fallback location
  Map<String, double> _getFallbackLocation() {
    debugPrint('Using fallback location: $fallbackLat, $fallbackLon');
    return {'lat': fallbackLat, 'lon': fallbackLon};
  }

  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    PermissionStatus status = await Permission.location.status;
    return status.isGranted;
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    return status.isGranted;
  }
}
