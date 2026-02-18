// import 'package:geolocator/geolocator.dart';

// class LocationService {
//   static Future<bool> requestPermission() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) return false;

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) return false;
//     }
//     if (permission == LocationPermission.deniedForever) return false;
//     return true;
//   }

//   static Future<Position?> getCurrentPosition() async {
//     final hasPermission = await requestPermission();
//     if (!hasPermission) return null;

//     return await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//       timeLimit: const Duration(seconds: 15),
//     );
//   }

//   static Future<String> getAddressFromCoordinates(
//     double lat,
//     double lng,
//   ) async {
//     // Return coordinates as string if geocoding not available
//     return 'Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}';
//   }
// }






import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static Future<bool> requestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
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

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );
  }

  /// ✅ ONLY address string (NO "Lat/Lng" fallback)
  static Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return '';

      final p = placemarks.first;

      final parts = <String>[
        p.name ?? '',
        p.street ?? '',
        p.subLocality ?? '',
        p.locality ?? '',
        p.administrativeArea ?? '',
        p.postalCode ?? '',
        p.country ?? '',
      ].where((e) => e.trim().isNotEmpty).toList();

      return parts.join(', ');
    } catch (_) {
      // ✅ If geocoding fails, return empty so DB never stores Lat/Lng string
      return '';
    }
  }
}
