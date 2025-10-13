import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class location_helper {
  static Future<Map<String, dynamic>?> getCurrentLocationUser() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      print("Current permission: $permission");

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print("🚫 Permission denied or denied forever.");
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          print("🚫 Permission denied permanently or denied.");
          return null;
        }
      }

      print("🔐 Permission: $permission");

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      print("🔐 position: $position");

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;

        String address =
            '${p.name}, ${p.subLocality}, ${p.locality}, ${p.administrativeArea}, ${p.postalCode}';

        return {
          'address': address,
          'latlng': LatLng(position.latitude, position.longitude),
        };
      }

      return null;
    } catch (e) {
      print('📍 Error in location_helper: $e');
      return null;
    }
  }
}


