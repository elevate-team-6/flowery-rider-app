import 'package:latlong2/latlong.dart';

/// Constants for the tracking map screen: tile server, camera defaults, and the
/// live-tracking cadence. Kept in one place so they're easy to tune / swap
/// (e.g. moving off the public OSM tile server in production).
abstract class MapConstants {
  /// OpenStreetMap raster tile template.
  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// User-agent sent to the tile server (per the OSM tile usage policy).
  static const String tileUserAgent = 'flowery_rider_app';

  /// Default map zoom level.
  static const double defaultZoom = 15;

  /// Center shown until the location / target resolves (central Cairo).
  static const LatLng fallbackCenter = LatLng(30.0444, 31.2357);

  /// Minimum movement (metres) before the live position stream emits a new
  /// fix. Keeps the marker updating as the rider moves without waking the GPS
  /// for a rider standing still.
  static const int liveDistanceFilter = 10;
}
