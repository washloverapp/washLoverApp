import 'package:location/location.dart';

class LocationService {
  final Location _location = Location();

  Stream<LocationData> get locationStream => _location.onLocationChanged;
}
