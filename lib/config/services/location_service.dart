import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class LocationService {
  Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> checkPermission() {
    return Geolocator.checkPermission();
  }

  Future<LocationPermission> requestPermission() {
    return Geolocator.requestPermission();
  }

  /// Last cached fix — instant, and reliable on emulators that already have a
  /// location set. Returns null if there is no cached position.
  Future<Position?> getLastKnownPosition() {
    return Geolocator.getLastKnownPosition();
  }

  Future<Position> getCurrentPosition({LocationSettings? settings}) {
    return Geolocator.getCurrentPosition(locationSettings: settings);
  }
}
