import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsService {
  late final PolylinePoints _polylinePoints;

  DirectionsService({required String googleApiKey}) {
    // ใส่ API key ตอนสร้าง instance ของ PolylinePoints
    _polylinePoints = PolylinePoints(apiKey: googleApiKey);
  }

  Future<List<LatLng>> getRouteCoordinates({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    List<LatLng> routePoints = [];

    try {
      final request = PolylineRequest(
        origin: PointLatLng(startLat, startLng),
        destination: PointLatLng(endLat, endLng),
        mode: TravelMode.driving,
      );

      final PolylineResult result =
          await _polylinePoints.getRouteBetweenCoordinates(request: request);

      if (result.points.isNotEmpty) {
        routePoints = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
      } else {
        // print('❌ ไม่พบเส้นทาง: ${result.errorMessage}');
      }
    } catch (e) {
      print('⚠️ เกิดข้อผิดพลาดในการเรียกเส้นทาง: $e');
    }

    return routePoints;
  }
}
