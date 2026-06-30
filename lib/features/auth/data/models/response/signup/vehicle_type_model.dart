import 'package:flowery_rider_app/features/auth/domain/entities/vehicle_type_entity.dart';

class VehicleModel {
  final String id;
  final String type;
  final String image;

  const VehicleModel({
    required this.id,
    required this.type,
    required this.image,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      image: json['image'] ?? '',
    );
  }
  VehicleTypeEntity toEntity() {
    return VehicleTypeEntity(id: id, type: type, image: image);
  }
}
