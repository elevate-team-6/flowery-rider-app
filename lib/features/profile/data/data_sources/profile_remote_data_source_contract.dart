import 'package:flowery_rider_app/features/profile/data/models/request/edit_vehicle_request.dart';
import 'package:flowery_rider_app/features/profile/data/models/response/profile_response_model.dart';

import '../../../../config/base_response/base_response.dart';

abstract interface class ProfileRemoteDataSourceContract {
  Future<BaseResponse<void>> logout();
  Future<BaseResponse<ProfileResponseModel>> editVehicle(
    EditVehicleRequest request,
  );
}
