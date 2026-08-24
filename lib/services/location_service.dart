import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // DDU Nadiad Coordinates
  static const double dduLatitude = 22.6841;
  static const double dduLongitude = 72.8805;

  Future<bool> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('[LocationService] Location error: $e');
      return null;
    }
  }

  Future<String> detectCurrentCampus() async {
    final position = await getCurrentPosition();
    if (position == null) {
      return 'DDU, Nadiad, Gujarat'; // Default campus
    }

    final distanceInMeters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      dduLatitude,
      dduLongitude,
    );

    // If within 5 kilometers of DDU
    if (distanceInMeters <= 5000) {
      return '📍 DDU Campus, Nadiad (GPS Verified)';
    } else {
      return '📍 Nadiad Region, Gujarat';
    }
  }
}
