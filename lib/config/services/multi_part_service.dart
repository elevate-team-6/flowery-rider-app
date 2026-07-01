import 'package:dio/dio.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/signup/signup_request.dart';
import 'package:flowery_rider_app/features/profile/data/models/request/edit_vehicle_request.dart';
import 'package:injectable/injectable.dart';

@singleton
class MultipartService {
  Future<FormData> createSignUpFormData(SignUpRequest request) async {
    return FormData.fromMap({
      ...request.toJson(),

      if (request.vehicleLicense != null)
        'vehicleLicense': await request.vehicleLicense!.toMultipartFile(),

      if (request.nidImg != null)
        'NIDImg': await request.nidImg!.toMultipartFile(),
    });
  }

  Future<FormData> createEditVehicleFormData(EditVehicleRequest request) async {
    return FormData.fromMap({
      ...request.toJson(),

      if (request.vehicleLicense != null)
        'vehicleLicense': await request.vehicleLicense!.toMultipartFile(),
        
    });
    
  }
}
