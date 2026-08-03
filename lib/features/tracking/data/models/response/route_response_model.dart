import 'package:json_annotation/json_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'route_response_model.g.dart';

@JsonSerializable(createToJson: false)
class RouteResponseModel {
  final List<RouteModel>? routes;

  const RouteResponseModel({this.routes});

  factory RouteResponseModel.fromJson(Map<String, dynamic> json) =>
      _$RouteResponseModelFromJson(json);

  List<LatLng> toEntity() {
    final coordinates = (routes?.isNotEmpty ?? false)
        ? routes!.first.geometry?.coordinates
        : null;
    if (coordinates == null) return const [];
    return coordinates
        .where((c) => c.length >= 2)
        .map((c) => LatLng(c[1], c[0]))
        .toList();
  }
}

@JsonSerializable(createToJson: false)
class RouteModel {
  final RouteGeometryModel? geometry;

  const RouteModel({this.geometry});

  factory RouteModel.fromJson(Map<String, dynamic> json) =>
      _$RouteModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class RouteGeometryModel {
  final List<List<double>>? coordinates;

  const RouteGeometryModel({this.coordinates});

  factory RouteGeometryModel.fromJson(Map<String, dynamic> json) =>
      _$RouteGeometryModelFromJson(json);
}
