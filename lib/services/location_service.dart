// lib/services/location_service.dart

import 'package:geolocator/geolocator.dart';

class LocationService {
  // Get current location
  static Future<String> getCurrentLocation() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return 'Location services are disabled.';
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();

      // If permission is denied, ask for it
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'Location permission denied.';
        }
      }

      // If permission is permanently denied
      if (permission == LocationPermission.deniedForever) {
        return 'Location permission permanently denied.';
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Create Google Maps link
      String googleMapsLink =
          'https://www.google.com/maps?q=${position.latitude},${position.longitude}';

      return googleMapsLink;
    } catch (e) {
      return 'Could not get location.';
    }
  }

  // Get location as text
  static Future<String> getLocationText() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return 'Location unavailable';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'Location unavailable';
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return 'Lat: ${position.latitude}, Long: ${position.longitude}';
    } catch (e) {
      return 'Location unavailable';
    }
  }
}