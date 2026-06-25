import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/core/entities/driver_entity.dart';
import 'package:flowery_rider_app/features/profile/data/models/request/edit_vehicle_request.dart';

abstract interface class ProfileRepoContract {
  Future<BaseResponse<void>> logout();
  Future<BaseResponse<DriverEntity>> editVehicle(EditVehicleRequest request);
}
