import 'package:flowery_rider_app/features/auth/data/models/response/signup/vehicle_type_model.dart';

class VehicleResponse {
  final List<VehicleModel> vehicles;

  const VehicleResponse({required this.vehicles});

  factory VehicleResponse.fromJson(Map<String, dynamic> json) {
    return VehicleResponse(
      vehicles: (json['vehicles'] as List<dynamic>? ?? [])
          .map((e) => VehicleModel.fromJson(e))
          .toList(),
    );
  }
}
