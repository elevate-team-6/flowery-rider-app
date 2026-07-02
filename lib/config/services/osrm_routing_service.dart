import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

/// Fetches a road-following route between two points using the public OSRM
/// demo server (free, fine for testing — swap for a paid/self-hosted server
/// in production).
@lazySingleton
class OsrmRoutingService {
  final Dio _dio;

  OsrmRoutingService({Dio? dio}) : _dio = dio ?? Dio();

  static const String _baseUrl =
      'https://router.project-osrm.org/route/v1/driving';

  /// Returns the list of points that draw the driving route from [start] to
  /// [end]. Throws on network / parsing errors so the caller can fall back to
  /// a straight line.
  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    // OSRM expects coordinates as: lon,lat;lon,lat
    final coords =
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}';

    final response = await _dio.get(
      '$_baseUrl/$coords',
      queryParameters: const {
        'overview': 'full', // full-resolution geometry (the winding line)
        'geometries': 'geojson', // easy [lon, lat] coordinate pairs
      },
    );

    final routes = response.data['routes'] as List?;
    if (routes == null || routes.isEmpty) return const [];

    final geometry = routes.first['geometry']['coordinates'] as List;
    // GeoJSON is [lon, lat] — flip to LatLng(lat, lon).
    return geometry
        .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
        .toList();
  }
}
