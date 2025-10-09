import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationHelper {
  static Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

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
      print('📍 Error in LocationHelper: $e');
      return null;
    }
  }
}
