import 'package:flowery_rider_app/core/extensions/app_multipart_file.dart';

class EditVehicleRequest {
  final String vehicleType;
  final String vehicleNumber;
  final AppMultipartFile? vehicleLicense;

  const EditVehicleRequest({
    required this.vehicleType,
    required this.vehicleNumber,
    required this.vehicleLicense,
  });

  Map<String, dynamic> toJson() {
    return {'vehicleType': vehicleType, 'vehicleNumber': vehicleNumber};
  }
}
