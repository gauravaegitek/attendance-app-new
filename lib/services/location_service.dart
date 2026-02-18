import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  static Future<Position?> getCurrentPosition() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );
  }

  static Future<String> getAddressFromCoordinates(
    double lat,
    double lng,
  ) async {
    // Return coordinates as string if geocoding not available
    return 'Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}';
  }
}
